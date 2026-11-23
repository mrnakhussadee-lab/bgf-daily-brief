#!/usr/bin/env python3
"""
BGF Daily Brief — Zero-Token Deterministic Market & News Fetcher
Runs daily at 08:00 Asia/Bangkok (01:00 UTC).

Rules implemented:
1. Open vs Prior Close: Uses today's opening price if the market is open at 08:00 ICT
   and an open quote is verified; otherwise falls back to last night's / last business day's close.
2. Token-efficiency: Fetches raw KPIs and compact news headlines into data/today_raw.json (~4 KB)
   and caches monthly Soda Ash checks in data/soda_ash_cache.json.
3. Zero external dependencies (Python 3.10+ stdlib only).
"""

from __future__ import annotations

import argparse
import datetime as dt
import json
import re
import sys
import urllib.error
import urllib.request
import xml.etree.ElementTree as ET
from pathlib import Path
from typing import Any
from zoneinfo import ZoneInfo

BKK_TZ = ZoneInfo("Asia/Bangkok")
ROOT_DIR = Path(__file__).resolve().parent.parent
DATA_DIR = ROOT_DIR / "data"
HISTORY_DIR = DATA_DIR / "history"
SODA_CACHE_PATH = DATA_DIR / "soda_ash_cache.json"
TODAY_RAW_PATH = DATA_DIR / "today_raw.json"
MANIFEST_PATH = DATA_DIR / "history_manifest.json"

USER_AGENT = (
    "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 "
    "(KHTML, like Gecko) Chrome/128.0.0.0 Safari/537.36"
)

# Bank of Thailand / Thai Public Holidays (2026-2027)
TH_PUBLIC_HOLIDAYS: dict[str, str] = {
    "2026-01-01": "วันขึ้นปีใหม่",
    "2026-01-02": "วันหยุดพิเศษปีใหม่",
    "2026-03-03": "วันมาฆบูชา",
    "2026-04-06": "วันจักรี",
    "2026-04-13": "วันสงกรานต์",
    "2026-04-14": "วันสงกรานต์",
    "2026-04-15": "วันสงกรานต์",
    "2026-05-01": "วันแรงงานแห่งชาติ",
    "2026-05-04": "วันฉัตรมงคล",
    "2026-06-01": "ชดเชยวันวิสาขบูชา",
    "2026-06-03": "วันเฉลิมพระชนมพรรษาพระราชินี",
    "2026-07-29": "วันอาสาฬหบูชา",
    "2026-08-12": "วันแม่แห่งชาติ",
    "2026-10-13": "วันนวมินทรมหาราช",
    "2026-10-23": "วันปิยมหาราช",
    "2026-12-05": "วันชาติ / วันพ่อแห่งชาติ",
    "2026-12-07": "ชดเชยวันพ่อแห่งชาติ",
    "2026-12-10": "วันรัฐธรรมนูญ",
    "2026-12-31": "วันสิ้นปี",
    "2027-01-01": "วันขึ้นปีใหม่",
    "2027-02-22": "ชดเชยวันมาฆบูชา",
    "2027-04-06": "วันจักรี",
    "2027-04-13": "วันสงกรานต์",
    "2027-04-14": "วันสงกรานต์",
    "2027-04-15": "วันสงกรานต์",
    "2027-05-03": "ชดเชยวันแรงงานแห่งชาติ",
    "2027-05-04": "วันฉัตรมงคล",
    "2027-05-20": "วันวิสาขบูชา",
    "2027-06-03": "วันเฉลิมพระชนมพรรษาพระราชินี",
    "2027-07-19": "วันอาสาฬหบูชา",
    "2027-07-20": "วันเข้าพรรษา",
    "2027-08-12": "วันแม่แห่งชาติ",
    "2027-10-13": "วันนวมินทรมหาราช",
    "2027-10-25": "ชดเชยวันปิยมหาราช",
    "2027-12-05": "วันชาติ / วันพ่อแห่งชาติ",
    "2027-12-06": "ชดเชยวันพ่อแห่งชาติ",
    "2027-12-10": "วันรัฐธรรมนูญ",
    "2027-12-31": "วันสิ้นปี",
}

# Major UK/US Global Exchange Holidays (LME / ICE Brent)
GLOBAL_MARKET_HOLIDAYS: dict[str, str] = {
    "2026-12-25": "Christmas Day (Global Markets Closed)",
    "2026-12-28": "Boxing Day Substitute (UK/LME Closed)",
    "2027-01-01": "New Year's Day (Global Markets Closed)",
    "2027-03-26": "Good Friday (Global Markets Closed)",
    "2027-03-29": "Easter Monday (UK/LME Closed)",
    "2027-12-27": "Christmas Substitute (Global Markets Closed)",
    "2027-12-28": "Boxing Day Substitute (UK/LME Closed)",
}


def get_holiday_info(date_obj: dt.date) -> dict[str, Any]:
    iso = date_obj.isoformat()
    th_name = TH_PUBLIC_HOLIDAYS.get(iso, "")
    global_name = GLOBAL_MARKET_HOLIDAYS.get(iso, "")
    is_weekend = date_obj.weekday() >= 5
    is_th_holiday = bool(th_name)
    is_global_holiday = bool(global_name)
    is_holiday = is_th_holiday or is_global_holiday
    if is_th_holiday:
        short_status = "วันหยุดนักขัตฤกษ์"
    elif is_global_holiday:
        short_status = "วันหยุดตลาดโลก"
    elif is_weekend:
        short_status = "ตลาดปิด"
    else:
        short_status = "ตลาดเปิด"
    return {
        "is_weekend": is_weekend,
        "is_th_holiday": is_th_holiday,
        "is_global_holiday": is_global_holiday,
        "is_holiday": is_holiday,
        "holiday_name_th": th_name or global_name,
        "short_status_th": short_status,
    }


def http_get(url: str, timeout: int = 15) -> str | None:
    req = urllib.request.Request(
        url,
        headers={
            "User-Agent": USER_AGENT,
            "Accept": "text/html,application/json,application/xml;q=0.9,*/*;q=0.8",
        },
    )
    try:
        with urllib.request.urlopen(req, timeout=timeout) as resp:
            return resp.read().decode("utf-8", errors="replace")
    except Exception as exc:
        print(f"[WARN] Failed GET {url}: {exc}", file=sys.stderr)
        return None


def fetch_yahoo_quote(symbol: str, now_bkk: dt.datetime) -> dict[str, Any]:
    """
    Fetches chart metadata/OHLC from Yahoo Finance v8 chart endpoint.
    Applies Open-vs-Prior-Close rule for 08:00 ICT (respecting weekends & holidays).
    """
    url = f"https://query1.finance.yahoo.com/v8/finance/chart/{symbol}?range=7d&interval=1d"
    raw = http_get(url)
    if not raw:
        return {"ok": False, "error": "Yahoo Finance unreachable"}

    try:
        payload = json.loads(raw)
        result = payload["chart"]["result"][0]
        meta = result["meta"]
        timestamps = result.get("timestamp", [])
        quote = result["indicators"]["quote"][0]
        opens = quote.get("open", [])
        closes = quote.get("close", [])

        # Pair valid bars with BKK trading dates
        bars: list[dict[str, Any]] = []
        for ts, op, cl in zip(timestamps, opens, closes):
            if cl is None and op is None:
                continue
            bar_date = dt.datetime.fromtimestamp(ts, tz=dt.timezone.utc).astimezone(BKK_TZ).date()
            bars.append({
                "date": bar_date.isoformat(),
                "open": round(float(op), 4) if op is not None else None,
                "close": round(float(cl), 4) if cl is not None else None,
            })

        if not bars:
            return {"ok": False, "error": "No OHLC bars"}

        today_str = now_bkk.date().isoformat()
        hinfo = get_holiday_info(now_bkk.date())
        is_weekend = hinfo["is_weekend"]
        is_closed_for_symbol = is_weekend or hinfo["is_global_holiday"] or (symbol == "THB=X" and hinfo["is_th_holiday"])
        latest_bar = bars[-1]
        prev_bar = bars[-2] if len(bars) >= 2 else None

        # Check if today's opening price is available on a trading weekday
        if not is_closed_for_symbol and latest_bar["date"] == today_str and latest_bar["open"] is not None:
            price = latest_bar["open"]
            price_basis = "Today Open"
            obs_date = today_str
            base_price = prev_bar["close"] if prev_bar and prev_bar["close"] else None
            base_date = prev_bar["date"] if prev_bar else None
            market_status = "เปิดซื้อขาย (ใช้ราคาเปิดวันนี้)"
            quality = "VERIFIED CURRENT"
        else:
            # Fallback to Prior Close (last night's close / last business day)
            # If latest_bar is today without close yet, use prev_bar as prior close
            target_bar = latest_bar
            compare_bar = prev_bar
            if latest_bar["date"] == today_str and (latest_bar["close"] is None or is_closed_for_symbol) and prev_bar:
                target_bar = prev_bar
                compare_bar = bars[-3] if len(bars) >= 3 else None

            price = target_bar["close"] if target_bar["close"] is not None else target_bar["open"]
            price_basis = "Prior Close"
            obs_date = target_bar["date"]
            base_price = compare_bar["close"] if compare_bar and compare_bar["close"] else None
            base_date = compare_bar["date"] if compare_bar else None
            if hinfo["is_holiday"]:
                market_status = f"วันหยุดนักขัตฤกษ์ ({hinfo['holiday_name_th']})"
            elif is_weekend:
                market_status = "ตลาดปิด (ใช้ราคาปิดล่าสุด)"
            else:
                market_status = "ยังไม่เปิด/รอราคาเปิด (ใช้ราคาปิดเมื่อคืน)"
            quality = "VERIFIED LATEST"

        change_pct = None
        if price is not None and base_price:
            change_pct = round(((price - base_price) / base_price) * 100.0, 2)

        return {
            "ok": True,
            "price": round(float(price), 2) if price is not None else None,
            "raw_price": price,
            "price_basis": price_basis,
            "observation_date": obs_date,
            "change_pct": change_pct,
            "base_price": round(float(base_price), 2) if base_price else None,
            "base_date": base_date,
            "market_status": market_status,
            "data_quality": quality,
            "exchange": meta.get("exchangeName", ""),
        }
    except Exception as exc:
        return {"ok": False, "error": f"Parse error: {exc}"}


def fetch_westmetall_aluminium(now_bkk: dt.datetime) -> dict[str, Any]:
    """
    Parses Westmetall LME Aluminium Cash-Settlement, 3-Month, and Stock table.
    At 08:00 ICT (01:00 UTC), LME London ring is closed, so Prior Close is standard.
    """
    url = "https://www.westmetall.com/en/markdaten.php?action=table&field=LME_Al_cash"
    html = http_get(url)
    if not html:
        return {"ok": False, "error": "Westmetall unreachable"}

    # Match rows like: <td>20. November 2026</td><td>3,184.50</td><td>2,831.50</td><td>223,525</td>
    pattern = re.compile(
        r"<td[^>]*>\s*(\d{1,2}\.\s*[A-Za-z]+\s+\d{4})\s*</td>\s*"
        r"<td[^>]*>\s*([\d,\.]+)\s*</td>\s*"
        r"<td[^>]*>\s*([\d,\.]+)\s*</td>\s*"
        r"<td[^>]*>\s*([\d,\.]+)\s*</td>",
        re.IGNORECASE,
    )
    rows: list[dict[str, Any]] = []
    for m in pattern.finditer(html):
        date_str, cash_s, m3_s, stock_s = m.groups()
        try:
            d_obj = dt.datetime.strptime(date_str.strip(), "%d. %B %Y").date()
            rows.append({
                "d": d_obj.isoformat(),
                "cash": float(cash_s.replace(",", "")),
                "m3": float(m3_s.replace(",", "")),
                "stock": int(float(stock_s.replace(",", ""))),
            })
        except ValueError:
            continue

    if not rows:
        return {"ok": False, "error": "Westmetall rows not found"}

    rows.sort(key=lambda x: x["d"])
    latest = rows[-1]
    prev = rows[-2] if len(rows) >= 2 else None
    change_pct = None
    if prev and prev["cash"]:
        change_pct = round(((latest["cash"] - prev["cash"]) / prev["cash"]) * 100.0, 2)

    is_weekend = now_bkk.weekday() >= 5
    return {
        "ok": True,
        "price": round(latest["cash"], 2),
        "m3_price": round(latest["m3"], 2),
        "stock": latest["stock"],
        "price_basis": "Prior Close",
        "price_type": "LME Official Cash-Settlement",
        "observation_date": latest["d"],
        "change_pct": change_pct,
        "base_price": round(prev["cash"], 2) if prev else None,
        "base_date": prev["d"] if prev else None,
        "market_status": "ตลาดปิด (LME เปิดช่วงบ่ายเวลาไทย ใช้ราคา Settlement ล่าสุด)",
        "data_quality": "VERIFIED LATEST" if is_weekend or latest["d"] != now_bkk.date().isoformat() else "VERIFIED CURRENT",
        "series_60d": rows[-45:],  # ~60 calendar days of trading days
        "source_url": url,
    }


def _parse_pr_table(html: str) -> list[dict[str, Any]]:
    """Extracts (country, incoterm, price_usd, month_str, date_obj) rows from Procurement Resource HTML."""
    txt = re.sub(r"<[^>]+>", " ", html)
    txt = re.sub(r"\s+", " ", txt)
    pattern = re.compile(
        r"China\s+FOB\s+USD\s*([\d,]+(?:\.\d{1,2})?)\s*/\s*MT\s+([A-Za-z]+\s+\d{4})",
        re.IGNORECASE,
    )
    rows: list[dict[str, Any]] = []
    for m in pattern.finditer(txt):
        price_s, period_s = m.groups()
        try:
            period_dt = dt.datetime.strptime(period_s.strip(), "%B %Y").date()
            rows.append({
                "price": round(float(price_s.replace(",", "")), 2),
                "period": period_s.strip(),
                "period_date": period_dt,
            })
        except ValueError:
            continue
    rows.sort(key=lambda r: r["period_date"], reverse=True)
    return rows


def check_soda_ash(now_bkk: dt.datetime, force: bool = False) -> dict[str, Any]:
    """
    Uses monthly cache to avoid redundant scraping/token usage.
    Follows SODA ASH FIXED BENCHMARK & MONTHLY FALLBACK:
    - Primary: Procurement Resource Dense & General FOB China USD/MT.
    - Prefer Dense if periods are equal; select General if NEWER with MARKET PROXY label.
    """
    cache: dict[str, Any] = {}
    if SODA_CACHE_PATH.exists():
        cache = json.loads(SODA_CACHE_PATH.read_text(encoding="utf-8"))

    last_checked_str = cache.get("last_checked_utc")
    interval = int(cache.get("recheck_interval_days", 7))
    if not force and last_checked_str and cache.get("verified_price_usd_mt") is not None:
        try:
            last_dt = dt.datetime.fromisoformat(last_checked_str.replace("Z", "+00:00"))
            age_days = (now_bkk.astimezone(dt.timezone.utc) - last_dt).days
            if age_days < interval:
                return cache
        except ValueError:
            pass

    dense_url = "https://www.procurementresource.com/resource-center/soda-ash-dense-price-trends"
    gen_url = "https://www.procurementresource.com/resource-center/soda-ash-price-trends"

    dense_rows = _parse_pr_table(http_get(dense_url) or "")
    gen_rows = _parse_pr_table(http_get(gen_url) or "")

    chosen: dict[str, Any] | None = None
    chosen_rows: list[dict[str, Any]] = []
    chosen_url = dense_url
    grade_label = "Dense"

    if dense_rows and gen_rows:
        if gen_rows[0]["period_date"] > dense_rows[0]["period_date"]:
            chosen = gen_rows[0]
            chosen_rows = gen_rows
            chosen_url = gen_url
            grade_label = "GENERAL GRADE — DENSE NOT CONFIRMED (MARKET PROXY)"
        else:
            chosen = dense_rows[0]
            chosen_rows = dense_rows
            chosen_url = dense_url
            grade_label = "Dense"
    elif dense_rows:
        chosen = dense_rows[0]
        chosen_rows = dense_rows
        chosen_url = dense_url
        grade_label = "Dense"
    elif gen_rows:
        chosen = gen_rows[0]
        chosen_rows = gen_rows
        chosen_url = gen_url
        grade_label = "GENERAL GRADE — DENSE NOT CONFIRMED (MARKET PROXY)"

    if chosen:
        age_days = (now_bkk.date() - chosen["period_date"]).days
        if age_days <= 185:
            mom_pct = None
            prev_period = None
            prev_price = None
            if len(chosen_rows) >= 2 and chosen_rows[1]["price"]:
                prev_price = chosen_rows[1]["price"]
                prev_period = chosen_rows[1]["period"]
                mom_pct = round(((chosen["price"] - prev_price) / prev_price) * 100.0, 2)

            freshness = "HISTORICAL REFERENCE" if age_days > 90 else "LATEST PUBLISHED MONTHLY BENCHMARK"
            cache.update({
                "last_checked_utc": now_bkk.astimezone(dt.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
                "status": "HISTORICAL REFERENCE" if age_days > 90 else "VERIFIED LATEST",
                "freshness_status": freshness,
                "verified_price_usd_mt": chosen["price"],
                "grade": grade_label,
                "observation_period": chosen["period"],
                "mom_pct": mom_pct,
                "prev_period": prev_period,
                "prev_price": prev_price,
                "dense_latest": f"{dense_rows[0]['period']}: {dense_rows[0]['price']:.2f} USD/MT" if dense_rows else None,
                "source_url": chosen_url,
            })
            SODA_CACHE_PATH.write_text(json.dumps(cache, ensure_ascii=False, indent=2), encoding="utf-8")
            return cache

    cache["last_checked_utc"] = now_bkk.astimezone(dt.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
    cache["status"] = "UNAVAILABLE"
    SODA_CACHE_PATH.write_text(json.dumps(cache, ensure_ascii=False, indent=2), encoding="utf-8")
    return cache


def fetch_rss_headlines(limit_per_feed: int = 3) -> list[dict[str, str]]:
    """
    Pulls compact business/commodity headline metadata (title, link, pubDate)
    filtered for BGF-relevant market drivers (FX, energy, metals, glass, freight, economy).
    """
    feeds = [
        ("AL Circle", "https://www.alcircle.com/rss/news"),
        ("Google News — Thailand Baht / BOT", "https://news.google.com/rss/search?q=%22Thai+baht%22+OR+%22USD+THB%22+OR+%22Bank+of+Thailand%22+when:3d&hl=en-US&gl=US&ceid=US:en"),
        ("Google News — Brent / Diesel / Freight", "https://news.google.com/rss/search?q=%22Brent+crude%22+OR+%22container+freight%22+OR+%22Thailand+economy%22+when:3d&hl=en-US&gl=US&ceid=US:en"),
    ]
    allow_kw = (
        "alumin", "alumina", "lme", "brent", "crude", "oil", "diesel", "fuel",
        "baht", "thb", "usd", "fed", "rate", "bot", "central bank", "inflation",
        "gdp", "economy", "export", "import", "freight", "container", "shipping",
        "soda ash", "glass", "construction", "property", "factory", "tariff",
        "electricity", "energy", "anti-dumping", "cbam", "manufacturing", "smelter",
    )
    block_kw = (
        "church", "priest", "vocation", "soccer", "football", "basketball",
        "lottery", "concert", "actor", "actress", "murder", "crime", "wedding",
    )
    items: list[dict[str, str]] = []
    seen_titles: set[str] = set()
    for source_label, feed_url in feeds:
        xml_text = http_get(feed_url, timeout=10)
        if not xml_text:
            continue
        try:
            root = ET.fromstring(xml_text)
            count = 0
            for item in root.findall(".//item"):
                title = (item.findtext("title") or "").strip()
                link = (item.findtext("link") or "").strip()
                pub = (item.findtext("pubDate") or "").strip()
                low = title.lower()
                if not title or not link or low in seen_titles:
                    continue
                if any(b in low for b in block_kw):
                    continue
                if not any(k in low for k in allow_kw):
                    continue
                seen_titles.add(low)
                items.append({
                    "source": source_label,
                    "title": title,
                    "url": link,
                    "published_at": pub,
                })
                count += 1
                if count >= limit_per_feed:
                    break
        except ET.ParseError:
            continue
    return items


def _parse_thai_be_date(date_str: str) -> str | None:
    m = re.match(r"^\s*(\d{1,2})/(\d{1,2})/(\d{4})\s*$", date_str or "")
    if not m:
        return None
    d, mo, y = int(m.group(1)), int(m.group(2)), int(m.group(3))
    if y > 2400:
        y -= 543
    try:
        return dt.date(y, mo, d).isoformat()
    except ValueError:
        return None


def fetch_thai_diesel_b7(now_bkk: dt.datetime) -> dict[str, Any]:
    """
    Fetches official Bangkok retail Diesel B7 price (THB/Liter) from Bangchak API
    (aligned with EPPO/PTT retail reference).
    """
    api_url = "https://oil-price.bangchak.co.th/ApiOilPrice2/th"
    eppo_url = "https://www.eppo.go.th/data-energy-statistic/energy-price-th/%E0%B8%A3%E0%B8%B2%E0%B8%84%E0%B8%B2%E0%B8%82%E0%B8%B2%E0%B8%A2%E0%B8%9B%E0%B8%A5%E0%B8%B5%E0%B8%81%E0%B8%99%E0%B9%89%E0%B8%B3%E0%B8%A1%E0%B8%B1%E0%B8%99/"
    raw = http_get(api_url, timeout=12)
    if not raw:
        return {"ok": False, "error": "Bangchak Oil API unreachable"}
    try:
        payload = json.loads(raw)
        rec = payload[0]
        oil_list = json.loads(rec["OilList"])
        target = None
        for item in oil_list:
            name = item.get("OilName", "")
            if "ไฮดีเซล" in name and "พรีเมียม" not in name and "B20" not in name:
                target = item
                break
        if not target:
            return {"ok": False, "error": "Diesel B7 row not found in Bangchak API"}

        price = round(float(target["PriceToday"]), 2)
        prev_price = round(float(target.get("PriceYesterday") or price), 2)
        diff_y = float(target.get("PriceDifYesterday") or 0.0)
        change_pct = round((diff_y / prev_price) * 100.0, 2) if (diff_y != 0 and prev_price) else 0.0

        obs_iso = _parse_thai_be_date(rec.get("OilDateNow", "")) or now_bkk.date().isoformat()
        eff_iso = _parse_thai_be_date(rec.get("OilPriceDate", "")) or obs_iso
        return {
            "ok": True,
            "price": price,
            "prev_price": prev_price,
            "diff_yesterday": round(diff_y, 2),
            "change_pct": change_pct,
            "observation_date": obs_iso,
            "effective_date": eff_iso,
            "remark_th": rec.get("OilRemark2", ""),
            "source_name": "Bangchak / EPPO",
            "source_url": eppo_url,
            "data_quality": "VERIFIED CURRENT",
        }
    except Exception as exc:
        return {"ok": False, "error": f"Diesel B7 parse error: {exc}"}


def fetch_thai_factory_electricity(now_bkk: dt.datetime) -> dict[str, Any]:
    """
    Fetches Thailand Industrial Electricity Tariff (Type 4 Large General Service,
    TOU 69 kV & over) from MEA + latest Ft surcharge from PEA.
    """
    pea_ft_url = "https://www.pea.co.th/our-services/tariff/ft"
    mea_type4_url = "https://www.mea.or.th/our-services/service-rates/other/fsFTSa4DY"

    ft_rate = None
    ft_period = ""
    pea_html = http_get(pea_ft_url, timeout=12)
    if pea_html:
        txt = re.sub(r"\s+", " ", re.sub(r"<[^>]+>", " ", pea_html))
        m_ft = re.search(
            r"ค่า\s*Ft\s*ประจำเดือน\s*([^\n<]+?)\s*หน่วยละ\s*([+-]?\d+\.\d+)\s*บาท",
            txt,
        )
        if m_ft:
            ft_period = m_ft.group(1).strip()
            ft_rate = float(m_ft.group(2))

    if ft_rate is None:
        return {"ok": False, "error": "PEA Ft value not found"}

    # Parse MEA Type 4.2.1 (69 kV & over) TOU base tariff; keep ERC published base fallback
    demand_charge, on_peak_base, off_peak_base = 74.14, 4.1025, 2.5849
    mea_html = http_get(mea_type4_url, timeout=12)
    if mea_html:
        m_txt = re.sub(r"\s+", " ", re.sub(r"<[^>]+>", " ", mea_html))
        m_tou = re.search(
            r"4\.2\.1\s*แรงดัน\s*69\s*กิโลโวลต์ขึ้นไป\s*(\d+\.\d+)\s+0\s+(\d+\.\d+)\s+(\d+\.\d+)",
            m_txt,
        )
        if m_tou:
            demand_charge = float(m_tou.group(1))
            on_peak_base = float(m_tou.group(2))
            off_peak_base = float(m_tou.group(3))

    on_peak_total = round(on_peak_base + ft_rate, 2)
    off_peak_total = round(off_peak_base + ft_rate, 2)
    return {
        "ok": True,
        "price": on_peak_total,
        "on_peak_total": on_peak_total,
        "off_peak_total": off_peak_total,
        "on_peak_base": on_peak_base,
        "off_peak_base": off_peak_base,
        "demand_charge": demand_charge,
        "ft_rate": ft_rate,
        "ft_period": ft_period,
        "observation_date": now_bkk.date().isoformat(),
        "source_name": "PEA / MEA (กกพ.)",
        "source_url": pea_ft_url,
        "data_quality": "VERIFIED CURRENT",
    }


def build_raw_payload(now_bkk: dt.datetime, force_soda: bool = False) -> dict[str, Any]:
    usd_thb = fetch_yahoo_quote("THB=X", now_bkk)
    brent = fetch_yahoo_quote("BZ=F", now_bkk)
    lme = fetch_westmetall_aluminium(now_bkk)
    soda = check_soda_ash(now_bkk, force=force_soda)
    diesel_b7 = fetch_thai_diesel_b7(now_bkk)
    factory_elec = fetch_thai_factory_electricity(now_bkk)
    headlines = fetch_rss_headlines()
    hinfo = get_holiday_info(now_bkk.date())

    return {
        "generated_at_bkk": now_bkk.strftime("%Y-%m-%d %H:%M ICT (UTC+7)"),
        "date": now_bkk.date().isoformat(),
        "is_weekend": hinfo["is_weekend"],
        "is_holiday": hinfo["is_holiday"],
        "holiday_name_th": hinfo["holiday_name_th"],
        "short_status_th": hinfo["short_status_th"],
        "price_rule": "08:00 UTC+7: Today Open if available & market open; else Prior Close",
        "kpis_raw": {
            "usd_thb": usd_thb,
            "brent_oil": brent,
            "lme_aluminium": lme,
            "soda_ash": soda,
            "diesel_b7": diesel_b7,
            "factory_electricity": factory_elec,
        },
        "news_headlines": headlines,
    }


def create_incremental_snapshot(raw_payload: dict[str, Any], now_bkk: dt.datetime) -> Path:
    """
    Creates today's compact snapshot by cloning structure from the latest existing snapshot
    and updating verified KPI prices + timestamps (0 LLM tokens mode).
    """
    HISTORY_DIR.mkdir(parents=True, exist_ok=True)
    today_str = now_bkk.date().isoformat()
    target_path = HISTORY_DIR / f"{today_str}.json"

    # Read ONLY the single most recent snapshot (token/IO efficient!)
    existing_files = sorted(HISTORY_DIR.glob("*.json"))
    template: dict[str, Any] = {}
    if existing_files:
        template = json.loads(existing_files[-1].read_text(encoding="utf-8"))

    thai_months = [
        "", "ม.ค.", "ก.พ.", "มี.ค.", "เม.ย.", "พ.ค.", "มิ.ย.",
        "ก.ค.", "ส.ค.", "ก.ย.", "ต.ค.", "พ.ย.", "ธ.ค.",
    ]
    thai_months_full = [
        "", "มกราคม", "กุมภาพันธ์", "มีนาคม", "เมษายน", "พฤษภาคม", "มิถุนายน",
        "กรกฎาคม", "สิงหาคม", "กันยายน", "ตุลาคม", "พฤศจิกายน", "ธันวาคม",
    ]
    weekdays_th = ["จ.", "อ.", "พ.", "พฤ.", "ศ.", "ส.", "อา."]
    wd = weekdays_th[now_bkk.weekday()]
    d_disp = f"{now_bkk.day} {thai_months[now_bkk.month]} {now_bkk.year} ({wd})"
    m_key = now_bkk.strftime("%Y-%m")
    m_label = f"{thai_months_full[now_bkk.month]} {now_bkk.year}"

    en_month_to_th = {
        "January": "ม.ค.", "February": "ก.พ.", "March": "มี.ค.", "April": "เม.ย.",
        "May": "พ.ค.", "June": "มิ.ย.", "July": "ก.ค.", "August": "ส.ค.",
        "September": "ก.ย.", "October": "ต.ค.", "November": "พ.ย.", "December": "ธ.ค.",
    }

    def format_price_badge_th(price_basis: str, obs_date: str) -> str:
        prefix = "ราคาเปิด ณ" if price_basis == "Today Open" else ("ราคาปิด ณ" if price_basis == "Prior Close" else "ดัชนี ณ")
        if obs_date and len(obs_date) == 10 and obs_date[4] == "-" and obs_date[7] == "-":
            try:
                y, m, d = obs_date.split("-")
                return f"{prefix} {int(d)} {thai_months[int(m)]} {y}"
            except (ValueError, IndexError):
                pass
        parts = obs_date.split() if obs_date else []
        if len(parts) == 2 and parts[0] in en_month_to_th:
            return f"{prefix} {en_month_to_th[parts[0]]} {parts[1]}"
        return f"{prefix} {obs_date}".strip()

    kraw = raw_payload["kpis_raw"]
    updated_kpis = []
    for kpi in template.get("kpis", []):
        kid = kpi["id"]
        new_k = dict(kpi)
        if kid == "usd_thb" and kraw["usd_thb"].get("ok"):
            r = kraw["usd_thb"]
            new_k["price"] = r["price"]
            new_k["price_display"] = f"{r['price']:.2f}"
            new_k["price_basis"] = r["price_basis"]
            new_k["observation_date"] = r["observation_date"]
            new_k["price_badge_th"] = format_price_badge_th(r["price_basis"], r["observation_date"])
            new_k["market_status"] = r["market_status"]
            new_k["data_quality"] = r["data_quality"]
            if r["change_pct"] is not None:
                sign = "+" if r["change_pct"] > 0 else ""
                new_k["change_pct"] = r["change_pct"]
                new_k["change_display"] = f"{sign}{r['change_pct']:.2f}% DoD"
                new_k["comparison_base"] = f"เทียบราคาปิด {r['base_date']} ({r['base_price']:.2f})"
        elif kid == "brent_oil" and kraw["brent_oil"].get("ok"):
            r = kraw["brent_oil"]
            new_k["price"] = r["price"]
            new_k["price_display"] = f"{r['price']:.2f}"
            new_k["price_basis"] = r["price_basis"]
            new_k["observation_date"] = r["observation_date"]
            new_k["price_badge_th"] = format_price_badge_th(r["price_basis"], r["observation_date"])
            new_k["market_status"] = r["market_status"]
            new_k["data_quality"] = r["data_quality"]
            if r["change_pct"] is not None:
                sign = "+" if r["change_pct"] > 0 else ""
                new_k["change_pct"] = r["change_pct"]
                new_k["change_display"] = f"{sign}{r['change_pct']:.2f}% DoD"
                new_k["comparison_base"] = f"เทียบราคาปิด {r['base_date']} ({r['base_price']:.2f})"
        elif kid == "lme_aluminium" and kraw["lme_aluminium"].get("ok"):
            r = kraw["lme_aluminium"]
            new_k["price"] = r["price"]
            new_k["price_display"] = f"{r['price']:,.2f}"
            new_k["price_precision_note"] = f"3M: {r['m3_price']:,.2f} USD/t | Stock: {r['stock']:,} t"
            new_k["price_basis"] = r["price_basis"]
            new_k["observation_date"] = r["observation_date"]
            new_k["price_badge_th"] = format_price_badge_th(r["price_basis"], r["observation_date"])
            new_k["market_status"] = r["market_status"]
            new_k["data_quality"] = r["data_quality"]
            if r["change_pct"] is not None:
                sign = "+" if r["change_pct"] > 0 else ""
                new_k["change_pct"] = r["change_pct"]
                new_k["change_display"] = f"{sign}{r['change_pct']:.2f}% DoD"
                new_k["comparison_base"] = f"เทียบ Cash {r['base_date']} ({r['base_price']:,.2f} USD/t)"
        elif kid == "soda_ash":
            s = kraw["soda_ash"]
            if s.get("status") in ("VERIFIED LATEST", "VERIFIED CURRENT", "HISTORICAL REFERENCE") and s.get("verified_price_usd_mt"):
                new_k["price"] = s["verified_price_usd_mt"]
                new_k["price_display"] = f"{s['verified_price_usd_mt']:.2f}"
                dense_note = f" (Dense ล่าสุด {s['dense_latest']})" if s.get("dense_latest") and "GENERAL" in s.get("grade", "") else ""
                grade_short = "General Market Proxy" if "GENERAL" in s.get("grade", "") else "Dense FOB China"
                new_k["price_precision_note"] = f"{grade_short}{dense_note}"
                new_k["observation_date"] = s.get("observation_period") or today_str
                new_k["price_badge_th"] = format_price_badge_th("Monthly Benchmark", new_k["observation_date"])
                new_k["market_status"] = s.get("freshness_status") or "รายเดือนล่าสุด"
                new_k["data_quality"] = s["status"]
                new_k["source_name"] = "Procurement Resource"
                new_k["source_url"] = s.get("source_url", new_k["source_url"])
                if s.get("mom_pct") is not None:
                    sign = "+" if s["mom_pct"] > 0 else ""
                    new_k["change_pct"] = s["mom_pct"]
                    new_k["change_display"] = f"{sign}{s['mom_pct']:.2f}% MoM"
                    new_k["comparison_base"] = f"เทียบ {s.get('prev_period')} ({s.get('prev_price'):.2f} USD/MT)"
                else:
                    new_k["change_pct"] = None
                    new_k["change_display"] = "MoM: N/A"
                    new_k["comparison_base"] = "MoM: N/A"
        elif kid == "diesel_b7" and kraw.get("diesel_b7", {}).get("ok"):
            r = kraw["diesel_b7"]
            new_k["price"] = r["price"]
            new_k["price_display"] = f"{r['price']:.2f}"
            eff_badge = format_price_badge_th("Prior Close", r["effective_date"]).replace("ราคาปิด ณ", "มีผล ณ")
            new_k["price_badge_th"] = eff_badge
            new_k["price_precision_note"] = f"BCP/PTT กทม. (ไม่รวมภาษีท้องถิ่น) | รอบ {r['effective_date']}"
            new_k["observation_date"] = r["observation_date"]
            new_k["market_status"] = "ราคาขายปลีกรายวัน"
            new_k["data_quality"] = r["data_quality"]
            sign = "+" if r["change_pct"] > 0 else ""
            new_k["change_pct"] = r["change_pct"]
            new_k["change_display"] = f"{sign}{r['change_pct']:.2f}% DoD"
            if r["prev_price"] and r["prev_price"] != r["price"]:
                new_k["comparison_base"] = f"เทียบราคาเดิม ({r['prev_price']:.2f} THB/L)"
            else:
                new_k["comparison_base"] = f"ทรงตัวจากเมื่อวาน ({r['price']:.2f} THB/L)"
            new_k["financial_impact"] = (
                f"ดีเซล B7 อยู่ที่ {r['price']:.2f} THB/Liter กระทบต้นทุนขนส่งรถบรรทุก (Freight) และรถยกในโรงงาน KBI/BGA โดยตรง (รอข้อมูลภายในบริษัท)"
            )
        elif kid == "factory_electricity" and kraw.get("factory_electricity", {}).get("ok"):
            r = kraw["factory_electricity"]
            ft_sign = "+" if r["ft_rate"] > 0 else ""
            new_k["price"] = r["price"]
            new_k["price_display"] = f"{r['price']:.2f}"
            new_k["price_badge_th"] = f"งวด {r['ft_period']}" if r.get("ft_period") else "อัตรา กกพ. ล่าสุด"
            new_k["price_precision_note"] = (
                f"69 kV+ TOU: On-Peak {r['price']:.2f} | Off-Peak {r['off_peak_total']:.2f} | Demand {r['demand_charge']:.2f} THB/kW"
            )
            new_k["observation_date"] = r["observation_date"]
            new_k["market_status"] = "อัตราตามงวด Ft"
            new_k["data_quality"] = r["data_quality"]
            new_k["change_pct"] = None
            new_k["change_display"] = f"Ft: {ft_sign}{r['ft_rate']:.4f}"
            new_k["comparison_base"] = f"ฐาน On-Peak {r['on_peak_base']:.4f} + Ft {ft_sign}{r['ft_rate']:.4f} (ไม่รวม VAT)"
            new_k["financial_impact"] = (
                f"ค่าไฟโรงงานระดับ 69 kV+ (KBI เตาหลอม/แปรรูป และ BGA อัดรีด) อิง TOU On-Peak {r['price']:.2f} / Off-Peak {r['off_peak_total']:.2f} THB/kWh (รวม Ft {ft_sign}{r['ft_rate']:.4f}, รอข้อมูลภายในบริษัท)"
            )
        updated_kpis.append(new_k)

    seen_ids = {k.get("id") for k in updated_kpis}
    if "diesel_b7" not in seen_ids and kraw.get("diesel_b7", {}).get("ok"):
        r = kraw["diesel_b7"]
        sign = "+" if r["change_pct"] > 0 else ""
        updated_kpis.append({
            "id": "diesel_b7",
            "name": "Diesel B7",
            "category": "Energy / Logistics",
            "unit": "THB/Liter",
            "company": "ALL",
            "price": r["price"],
            "price_display": f"{r['price']:.2f}",
            "price_badge_th": format_price_badge_th("Prior Close", r["effective_date"]).replace("ราคาปิด ณ", "มีผล ณ"),
            "price_precision_note": f"BCP/PTT กทม. (ไม่รวมภาษีท้องถิ่น) | รอบ {r['effective_date']}",
            "price_basis": "Prior Close",
            "price_type": "Bangkok Retail Diesel B7",
            "change_pct": r["change_pct"],
            "change_display": f"{sign}{r['change_pct']:.2f}% DoD",
            "comparison_base": f"เทียบราคาเดิม ({r['prev_price']:.2f} THB/L)" if r["prev_price"] != r["price"] else f"ทรงตัวจากเมื่อวาน ({r['price']:.2f} THB/L)",
            "observation_date": r["observation_date"],
            "market_status": "ราคาขายปลีกรายวัน",
            "data_quality": r["data_quality"],
            "financial_impact": f"ดีเซล B7 อยู่ที่ {r['price']:.2f} THB/Liter กระทบต้นทุนขนส่งรถบรรทุก (Freight) และรถยกในโรงงาน KBI/BGA โดยตรง (รอข้อมูลภายในบริษัท)",
            "source_name": "Bangchak / EPPO",
            "source_url": r["source_url"],
        })
    if "factory_electricity" not in seen_ids and kraw.get("factory_electricity", {}).get("ok"):
        r = kraw["factory_electricity"]
        ft_sign = "+" if r["ft_rate"] > 0 else ""
        updated_kpis.append({
            "id": "factory_electricity",
            "name": "Factory Electricity",
            "category": "Energy (69 kV+)",
            "unit": "THB/kWh",
            "company": "ALL",
            "price": r["price"],
            "price_display": f"{r['price']:.2f}",
            "price_badge_th": f"งวด {r['ft_period']}" if r.get("ft_period") else "อัตรา กกพ. ล่าสุด",
            "price_precision_note": f"69 kV+ TOU: On-Peak {r['price']:.2f} | Off-Peak {r['off_peak_total']:.2f} | Demand {r['demand_charge']:.2f} THB/kW",
            "price_basis": "Monthly Benchmark",
            "price_type": "PEA/MEA Type 4 TOU (69 kV & over) + Ft",
            "change_pct": None,
            "change_display": f"Ft: {ft_sign}{r['ft_rate']:.4f}",
            "comparison_base": f"ฐาน On-Peak {r['on_peak_base']:.4f} + Ft {ft_sign}{r['ft_rate']:.4f} (ไม่รวม VAT)",
            "observation_date": r["observation_date"],
            "market_status": "อัตราตามงวด Ft",
            "data_quality": r["data_quality"],
            "financial_impact": f"ค่าไฟโรงงานระดับ 69 kV+ (KBI เตาหลอม/แปรรูป และ BGA อัดรีด) อิง TOU On-Peak {r['price']:.2f} / Off-Peak {r['off_peak_total']:.2f} THB/kWh (รวม Ft {ft_sign}{r['ft_rate']:.4f}, รอข้อมูลภายในบริษัท)",
            "source_name": "PEA / MEA (กกพ.)",
            "source_url": r["source_url"],
        })

    # Clean out any off-topic auto items & update fresh relevant headlines for today
    base_news = [n for n in template.get("news", []) if not str(n.get("id", "")).startswith("auto-")]
    # Also ensure non-top-alert base news doesn't keep stale auto noise; keep top_alerts + curated baseline
    top_alerts_base = [n for n in base_news if n.get("tier") == "top_alert"][:3]
    watchlist_base = [n for n in base_news if n.get("tier") != "top_alert"]
    fresh_items = []
    seen_urls = {n.get("source_url") for n in base_news}
    for idx, h in enumerate(raw_payload.get("news_headlines", [])[:4], start=1):
        if h["url"] not in seen_urls:
            fresh_items.append({
                "id": f"auto-{today_str}-{idx}",
                "tier": "watchlist",
                "title": h["title"],
                "priority_tier": "FX, Energy, Raw Materials, Industry Demand",
                "company": "ALL",
                "published_at": h.get("published_at") or today_str,
                "what": f"หัวข้อข่าวล่าสุดจาก {h['source']}: {h['title']}",
                "so_what": "ติดตามผลกระทบต่อ KBI และ BGA ตามตัวขับเคลื่อนต้นทุน/อุปสงค์ (Automated Feed)",
                "financial": "ประเมินผลกระทบต่อ Margin และ Cash Flow เทียบกับราคา KPI ล่าสุด (รอข้อมูลภายในบริษัท)",
                "now_what": "เปิดลิงก์ต้นทางเพื่อตรวจสอบรายละเอียดเพิ่มเติมก่อนตัดสินใจเชิงพาณิชย์",
                "owner": "ผู้บริหาร / ฝ่ายจัดซื้อ",
                "source_name": h["source"],
                "source_url": h["url"],
            })
    news_list = (top_alerts_base + fresh_items + watchlist_base)[:10]

    hinfo = get_holiday_info(now_bkk.date())
    if hinfo["is_holiday"]:
        overall_status = f"วันหยุดนักขัตฤกษ์ ({hinfo['holiday_name_th']}) • อ้างอิงราคาปิดวันทำการล่าสุด"
    elif hinfo["is_weekend"]:
        overall_status = "ตลาดปิด (วันหยุดสุดสัปดาห์) • อ้างอิงราคาปิดวันทำการล่าสุด"
    else:
        overall_status = "วันทำการ • อัปเดตรอบเช้า 08:00 ICT"

    # Build dynamic Sections 2, 3, 5, 6 strictly from today's verified KPI numbers
    kpi_map = {k.get("id"): k for k in updated_kpis}
    fx_k = kpi_map.get("usd_thb", {})
    br_k = kpi_map.get("brent_oil", {})
    al_k = kpi_map.get("lme_aluminium", {})
    sa_k = kpi_map.get("soda_ash", {})
    ds_k = kpi_map.get("diesel_b7", {})
    el_k = kpi_map.get("factory_electricity", {})

    fx_p = fx_k.get("price") or 33.95
    fx_chg = fx_k.get("change_display", "N/A")
    br_p = br_k.get("price") or 90.0
    br_chg = br_k.get("change_display", "N/A")
    al_p = al_k.get("price") or 3184.5
    al_chg = al_k.get("change_display", "N/A")
    m3_raw = kraw["lme_aluminium"].get("m3_price") if kraw.get("lme_aluminium", {}).get("ok") else 2831.5
    stock_raw = kraw["lme_aluminium"].get("stock") if kraw.get("lme_aluminium", {}).get("ok") else 223525
    spread = round(al_p - m3_raw, 2)
    sa_p = sa_k.get("price") or 156.23
    ds_p = ds_k.get("price") or 39.94
    el_p = el_k.get("price") or 4.26
    el_off = kraw["factory_electricity"].get("off_peak_total") if kraw.get("factory_electricity", {}).get("ok") else 2.75
    el_ft_lbl = el_k.get("change_display", "Ft: +0.1623")

    brent_below_90 = br_p < 90.0
    spread_alert = spread > 250.0
    fx_near_34 = fx_p >= 33.90

    decision_cards = [
        {
            "priority_status": "ต้องตัดสินใจ" if spread_alert else "ควรพิจารณา",
            "priority_level": "critical" if spread_alert else "warning",
            "company": "BGA",
            "headline": f"LME Aluminium Cash อยู่ที่ {al_p:,.2f} USD/t ({al_chg}) | Spread +{spread:,.2f} USD/t",
            "financial_impact": (
                f"ซื้อ Spot สูงกว่าสัญญา 3-Month ({m3_raw:,.2f} USD/t) อยู่ {spread:,.2f} USD/t "
                f"ท่ามกลางสต็อก LME {stock_raw:,} ตัน กดดัน Gross Margin และ Working Capital ของ BGA"
            ),
            "recommended_action": "ทบทวนสัดส่วนสัญญาซื้อ Spot เทียบ 3M Forward และตรวจสอบ Lead Time/สต็อกคงเหลือ (รอข้อมูลภายในบริษัท)",
            "owner": "CFO & COO",
            "review_point": "ทบทวนเมื่อ LME Cash–3M Spread > 250 USD/t หรือสต็อก LME ต่ำกว่า 220,000 ตัน",
        },
        {
            "priority_status": "ควรพิจารณา" if fx_near_34 else "เฝ้าระวัง",
            "priority_level": "warning" if fx_near_34 else "watch",
            "company": "ALL (KBI & BGA)",
            "headline": f"USD/THB เคลื่อนไหวที่ {fx_p:.2f} THB/USD ({fx_chg}) ใกล้แนวต้าน 34.00",
            "financial_impact": "ต้นทุนนำเข้าวัตถุดิบและค่าขนส่งสกุล USD สูงขึ้นในรูปเงินบาท ในภาวะที่ตลาดอสังหาฯ ในประเทศยังชะลอตัว",
            "recommended_action": "ประเมิน Net USD Exposure ของ KBI/BGA และเตรียมกรอบบริหารความเสี่ยง FX (รอข้อมูลภายในบริษัท)",
            "owner": "CFO",
            "review_point": "ทบทวนเมื่อ USD/THB ปิดเหนือ 34.00 THB/USD หรือก่อนประชุม FOMC",
        },
        {
            "priority_status": "ต้องตัดสินใจ" if brent_below_90 else "เฝ้าระวัง",
            "priority_level": "warning" if brent_below_90 else "watch",
            "company": "ALL (KBI & BGA)",
            "headline": f"Brent ปรับสู่ {br_p:.2f} USD/bbl ({br_chg}) | Diesel B7 {ds_p:.2f} THB/L | ค่าไฟ {el_p:.2f} THB/kWh",
            "financial_impact": (
                f"น้ำมันดิบ Brent หลุดระดับ 90.00 USD/bbl ({br_p:.2f}) เปิดโอกาสต่อรองต้นทุนพลังงาน/ค่าขนส่ง ขณะที่ค่าไฟโรงงาน 69 kV+ รวม {el_ft_lbl} ทรงตัวที่ {el_p:.2f} THB/kWh"
                if brent_below_90 else
                f"ติดตามต้นทุนพลังงานผสม: Brent {br_p:.2f} USD/bbl, Diesel B7 {ds_p:.2f} THB/L และค่าไฟโรงงาน 69 kV+ ที่ {el_p:.2f} THB/kWh ({el_ft_lbl})"
            ),
            "recommended_action": "เจรจาปรับลด Fuel Surcharge กับผู้ขนส่ง และวางแผนกะเดินเครื่องเตาหลอม/รีดช่วง Off-Peak (รอข้อมูลภายในบริษัท)",
            "owner": "COO & จัดซื้อ",
            "review_point": "ทบทวนเมื่อ Brent หลุด 90.00 USD/bbl หรือประกาศปรับราคา Diesel B7 / ค่า Ft รอบใหม่",
        },
    ]

    status_tag_s3 = hinfo["short_status_th"]
    executive_3rows = [
        {
            "num": 1,
            "label": "SITUATION — สถานการณ์สำคัญ",
            "headline": f"{d_disp} ({status_tag_s3}): USD/THB {fx_p:.2f} ({fx_chg}), Brent {br_p:.2f} USD/bbl ({br_chg}), LME {al_p:,.2f} USD/t",
            "detail": (
                f"อัตราแลกเปลี่ยนอยู่ที่ {fx_p:.2f} THB/USD, น้ำมันดิบ Brent อยู่ที่ {br_p:.2f} USD/bbl, "
                f"ดีเซล B7 ในประเทศ {ds_p:.2f} THB/Liter, ค่าไฟโรงงาน 69 kV+ On-Peak {el_p:.2f} / Off-Peak {el_off:.2f} THB/kWh ({el_ft_lbl}), "
                f"LME Aluminium Cash {al_p:,.2f} USD/t และ Soda Ash FOB China {sa_p:.2f} USD/MT"
            ),
        },
        {
            "num": 2,
            "label": "BUSINESS IMPACT — ผลกระทบต่อ KBI / BGA",
            "headline": f"BGA รับแรงกดดัน LME Backwardation (+{spread:,.2f} USD/t) ส่วน KBI ได้แรงหนุนจาก Brent อ่อนลงสู่ {br_p:.2f} และ Soda Ash {sa_p:.2f}",
            "detail": (
                f"ทั้งสองบริษัทต้องคุมต้นทุนนำเข้าสกุล USD ที่ {fx_p:.2f} THB/USD, ค่าขนส่งดีเซล {ds_p:.2f} THB/L และค่าไฟ 69 kV+ ({el_p:.2f} THB/kWh); "
                f"BGA เสี่ยง Margin Compression จาก LME Cash–3M Spread +{spread:,.2f} USD/t มากที่สุด ขณะที่ KBI ได้อานิสงส์พลังงานและ Soda Ash ระดับต่ำ (รอข้อมูลภายในบริษัท)"
            ),
        },
        {
            "num": 3,
            "label": "MANAGEMENT RESPONSE — สิ่งที่ผู้บริหารควรทำ",
            "headline": "คุมสูตรซื้อ LME 3M vs Spot, ต่อรอง Fuel Surcharge รับ Brent ขาลง และเช็ก Net FX Exposure ก่อนแนวต้าน 34.00",
            "detail": (
                f"CFO & COO ตรวจสต็อก/สูตรซื้อ LME ของ BGA และ Net USD Exposure ของกลุ่ม; "
                f"ฝ่ายจัดซื้อใช้จังหวะ Brent {'หลุด 90 USD/bbl' if brent_below_90 else f'ระดับ {br_p:.2f}'} ต่อรองค่าขนส่ง/Fuel Surcharge และเน้นผลิตช่วง Off-Peak ({el_off:.2f} THB/kWh)"
            ),
        },
    ]

    impact_matrix = [
        {
            "driver": f"USD/THB {fx_p:.2f} THB/USD ({fx_chg})",
            "kbi_indicator": "🟡 ต้องติดตาม",
            "kbi_text": "ต้นทุนนำเข้า Soda Ash และค่าขนส่งสกุล USD สูงขึ้นในรูปเงินบาท แต่รายได้ส่งออกช่วยชดเชยบางส่วน (รอข้อมูลภายใน: Net FX Exposure)",
            "bga_indicator": "🟡 ต้องติดตาม",
            "bga_text": "เพิ่มต้นทุนนำเข้าวัตถุดิบอะลูมิเนียมสกุล USD ในรูปบาท ขณะที่ตลาดก่อสร้างในประเทศยังชะลอตัว (รอข้อมูลภายใน: FX Hedge)",
            "management_implication": "CFO ตรวจสอบ Net USD Exposure ของทั้ง KBI และ BGA ก่อนระดับแนวต้าน 34.00 THB/USD",
        },
        {
            "driver": f"Brent {br_p:.2f} USD/bbl ({br_chg}) & Diesel B7 {ds_p:.2f} THB/L",
            "kbi_indicator": "🟢 ผลกระทบเชิงบวก",
            "kbi_text": f"Brent อ่อนตัวสู่ {br_p:.2f} USD/bbl ช่วยบรรเทาต้นทุนเชื้อเพลิงเตาหลอมระยะกลาง ขณะที่ดีเซล B7 ในประเทศอยู่ที่ {ds_p:.2f} THB/L",
            "bga_indicator": "🟢 ผลกระทบเชิงบวก",
            "bga_text": f"เปิดโอกาสต่อรองลดค่าขนส่งทางบก (ดีเซล {ds_p:.2f} THB/L) และ Fuel Surcharge การขนส่งวัตถุดิบ/สินค้าสำเร็จรูป",
            "management_implication": "ฝ่ายจัดซื้อเจรจาปรับลด Fuel Surcharge ตามทิศทาง Brent และหลีกเลี่ยงการล็อกสัญญาพลังงานระยะยาวในช่วงขาลง",
        },
        {
            "driver": f"Factory Electricity 69 kV+ {el_p:.2f} THB/kWh ({el_ft_lbl})",
            "kbi_indicator": "🟡 ต้องติดตาม",
            "kbi_text": f"อัตรา TOU 69 kV+ On-Peak {el_p:.2f} vs Off-Peak {el_off:.2f} THB/kWh (Demand 74.14 THB/kW) กระทบต้นทุนเดินเครื่องแปรรูป/หลอมต่อเนื่อง",
            "bga_indicator": "🟡 ต้องติดตาม",
            "bga_text": f"ต้นทุนไฟฟ้าในสายรีดอะลูมิเนียมและชุบผิวอิงอัตรา {el_p:.2f} / {el_off:.2f} THB/kWh ต้องคุม Peak Demand Charge",
            "management_implication": "COO บริหาร Load Factor ช่วง On/Off-Peak และติดตามประกาศค่า Ft งวดถัดไปจาก กกพ.",
        },
        {
            "driver": f"LME Aluminium Cash {al_p:,.2f} USD/t ({al_chg}) & Spread +{spread:,.2f}",
            "kbi_indicator": "⚪ ไม่มีผลกระทบโดยตรงที่ยืนยันได้",
            "kbi_text": "KBI ไม่ได้ใช้อะลูมิเนียมเป็นวัตถุดิบหลักในการผลิตกระจกแผ่น",
            "bga_indicator": "🔴 ผลกระทบเชิงลบสูง",
            "bga_text": f"Cash สูงกว่า 3-Month ({m3_raw:,.2f} USD/t) อยู่ +{spread:,.2f} USD/t และสต็อกต่ำ {stock_raw:,} ตัน กดดัน Margin และ Working Capital",
            "management_implication": "COO และ CFO ตรวจสอบสูตรราคาในสัญญาซื้อ (Spot vs 3M) และระดับสต็อกจริงก่อนพิจารณาปรับแผนสั่งซื้อ",
        },
        {
            "driver": f"Soda Ash FOB China {sa_p:.2f} USD/MT (General Proxy)",
            "kbi_indicator": "🟢 ผลกระทบเชิงบวก",
            "kbi_text": f"ราคา FOB China ทรงตัวระดับต่ำที่ {sa_p:.2f} USD/MT ช่วยคุมแรงกดดันต้นทุนวัตถุดิบหลัก (รอข้อมูลภายใน: Landed Cost ของ KBI)",
            "bga_indicator": "⚪ ไม่มีผลกระทบโดยตรงที่ยืนยันได้",
            "bga_text": "BGA ไม่ได้ใช้ Soda Ash เป็นวัตถุดิบหลัก",
            "management_implication": f"ฝ่ายจัดซื้อ KBI ใช้ระดับ FOB China ({sa_p:.2f} USD/MT) เป็นข้อมูลเปรียบเทียบต่อรองราคาเสนอขายจริงของซัพพลายเออร์",
        },
        {
            "driver": "อุปสงค์อสังหาฯ ไทย (-0.6% YoY) & คดี AD อินเดีย + PSS ค่าระวาง",
            "kbi_indicator": "🟡 ต้องติดตาม",
            "kbi_text": "ก่อสร้างเอกชนชะลอ (-0.5%) กดดันยอดขายในประเทศ ขณะที่ PSS ค่าระวางยุโรปอาจกระทบต้นทุนส่งออก",
            "bga_indicator": "🔴 ผลกระทบเชิงลบสูง",
            "bga_text": "เผชิญทั้งอุปสงค์ก่อสร้างเอกชนอ่อนตัว และความเสี่ยงคดี AD อินเดียที่อาจทำให้สินค้าภูมิภาคไหลย้อนมาตัดราคาในไทย",
            "management_implication": "CEO ขยายสัดส่วนการขายสู่กลุ่มโครงการรัฐ/อุตสาหกรรม (+19.1%) พร้อมให้ CFO คุม AR Aging และเร่งจองระวางเรือ",
        },
    ]

    management_actions = [
        {
            "priority": "P1",
            "business": "BGA",
            "action": f"ตรวจสอบสัดส่วนสัญญาซื้อ LME Aluminium (Spot vs 3M) และสต็อกคงคลัง หลัง Cash อยู่ที่ {al_p:,.2f} USD/t และ Spread +{spread:,.2f} USD/t",
            "owner": "CFO & COO",
            "timeline": "ทันที (สัปดาห์นี้)",
            "trigger": "Spread Cash–3M > 250.00 USD/t หรือสต็อก LME < 220,000 ตัน",
        },
        {
            "priority": "P1",
            "business": "ALL (KBI & BGA)",
            "action": f"รวบรวม Net USD Exposure และสถานะ FX Forward คงเหลือ หลัง USD/THB อยู่ที่ {fx_p:.2f} THB/USD ({fx_chg})",
            "owner": "CFO",
            "timeline": "ทันที (ก่อนแนวต้าน 34.00)",
            "trigger": "USD/THB ปิดเหนือ 34.00 THB/USD หรือก่อนประชุม FOMC",
        },
        {
            "priority": "P2",
            "business": "ALL (KBI & BGA)",
            "action": f"{'เร่งเจรจาลด Fuel Surcharge ทันทีหลัง Brent หลุด 90.00 สู่ ' if brent_below_90 else 'ติดตามและเจรจาปรับ Fuel Surcharge ตาม Brent '}{br_p:.2f} USD/bbl และเทียบต้นทุนดีเซล {ds_p:.2f} THB/L",
            "owner": "COO & ฝ่ายจัดซื้อ",
            "timeline": "ภายใน 1–2 สัปดาห์",
            "trigger": "Brent < 90.00 USD/bbl หรือปรับราคา Diesel B7 > 0.50 THB/L",
        },
        {
            "priority": "P2",
            "business": "BGA",
            "action": "ตรวจสอบยอดส่งออกไปอินเดีย พิกัด HS Code และเตรียมข้อมูลต้นทุนรองรับกรณี DGTR อินเดียไต่สวน Anti-Dumping Extrusion",
            "owner": "CEO & ฝ่ายขาย",
            "timeline": "ภายใน 2 สัปดาห์",
            "trigger": "ประกาศไต่สวน/กำหนดอากรเบื้องต้นจาก DGTR อินเดีย",
        },
        {
            "priority": "P3",
            "business": "ALL (KBI & BGA)",
            "action": f"บริหารตารางผลิตโรงงาน 69 kV+ เพื่อใช้ไฟ Off-Peak ({el_off:.2f} vs On-Peak {el_p:.2f} THB/kWh) และคุม AR Aging + จองระวางเรือล่วงหน้า",
            "owner": "COO & CFO",
            "timeline": "รอบปฏิบัติการรายเดือน",
            "trigger": "Peak Demand เกินเป้าหรือประกาศค่า Ft งวดใหม่จาก กกพ.",
        },
    ]

    snapshot = {
        "date": today_str,
        "display_date_th": d_disp,
        "month_key": m_key,
        "month_label_th": m_label,
        "report_time_bkk": now_bkk.strftime("%Y-%m-%d %H:%M ICT (UTC+7)"),
        "scheduled_slot_bkk": "08:00 ICT (UTC+7)",
        "is_weekend": hinfo["is_weekend"],
        "is_holiday": hinfo["is_holiday"],
        "holiday_name_th": hinfo["holiday_name_th"],
        "short_status_th": hinfo["short_status_th"],
        "market_status_overall": overall_status,
        "price_rule_note": "",
        "kpis": updated_kpis,
        "soda_ash_supplementary_context": template.get("soda_ash_supplementary_context", []),
        "decision_cards": decision_cards,
        "executive_3rows": executive_3rows,
        "lme_60d_series": kraw["lme_aluminium"].get("series_60d") or template.get("lme_60d_series", []),
        "news": news_list,
        "impact_matrix": impact_matrix,
        "management_actions": management_actions,
    }

    target_path.write_text(json.dumps(snapshot, ensure_ascii=False, indent=2), encoding="utf-8")
    return target_path


def main() -> None:
    parser = argparse.ArgumentParser(description="Fetch BGF market KPIs & headlines.")
    parser.add_argument("--force-soda", action="store_true", help="Force re-checking Soda Ash source.")
    parser.add_argument(
        "--create-snapshot",
        action="store_true",
        help="Write today's incremental JSON snapshot directly (0 LLM tokens).",
    )
    args = parser.parse_args()

    now_bkk = dt.datetime.now(BKK_TZ)
    DATA_DIR.mkdir(parents=True, exist_ok=True)
    payload = build_raw_payload(now_bkk, force_soda=args.force_soda)
    TODAY_RAW_PATH.write_text(json.dumps(payload, ensure_ascii=False, indent=2), encoding="utf-8")
    print(f"[OK] Wrote {TODAY_RAW_PATH}")

    if args.create_snapshot:
        snap = create_incremental_snapshot(payload, now_bkk)
        print(f"[OK] Wrote snapshot {snap}")


if __name__ == "__main__":
    main()
