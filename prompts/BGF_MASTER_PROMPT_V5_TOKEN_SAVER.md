BGF DAILY BRIEF — EXECUTIVE MASTER PROMPT V5 (SCHEDULED 08:00 ICT • 60-DAY ARCHIVE • TOKEN-OPTIMIZED)
RISE Framework | Desktop + Mobile Interactive Dashboard
สร้าง Executive HTML Dashboard สำหรับ CEO, COO และ CFO ในรูปแบบ Financial Intelligence Dashboard คล้าย Power BI
เป้าหมาย: วิเคราะห์ข้อมูลตลาดจริงให้ผู้บริหารเข้าใจสถานการณ์ ผลกระทบทางการเงิน และสิ่งที่ควรดำเนินการภายใน 60 วินาที
สำคัญ: Dashboard ต้องมีปุ่ม Desktop / Mobile ที่ใช้งานได้จริง และ Dropdown เลือกดูประวัติรายวันย้อนหลัง 60 วัน (พร้อมตัวกรองเดือน) อยู่ภายใน HTML เดียวกัน

- Desktop: Executive Dashboard แบบหลายคอลัมน์
- Mobile: Dashboard ที่ปรับ Layout ให้อ่านง่ายบนมือถือโดยไม่ต้องเลื่อนซ้าย–ขวา
- ใช้ข้อมูลเดียวกันทั้งสองโหมด
- เปิดผ่าน SharePoint / OneDrive บน Microsoft Edge Mobile ได้ (Self-contained ไม่มี External CDN ที่ถูกบล็อก)
- ไม่ต้องสร้าง PNG, PDF หรือ PowerPoint
- Design Principles: Visual Hierarchy First, Concise Insight, High Readability, Action-Oriented
- ใช้ข้อมูลตลาดจริงจากแหล่งตรวจสอบได้เท่านั้น ห้ามแต่งข้อมูล

---

## SCHEDULE, PRICE BASIS & TOKEN-EFFICIENCY RULES (08:00 UTC+7)

1. **Schedule Time**: อัพเดทอัตโนมัติทุกวันเวลา **08:00 น. (Asia/Bangkok, UTC+7)**
2. **Open vs Prior Close Rule (ใช้ราคาเปิดวันเมื่อทำได้ มิฉะนั้นใช้ราคาปิดเมื่อคืน)**:
   - ณ เวลา 08:00 UTC+7 หากตลาดของ KPI นั้นเปิดทำการแล้วและมี **ราคาเปิดของวัน (Today Open)** ที่ตรวจสอบได้จริง ให้ใช้ **ราคาเปิดของวัน** พร้อมระบุ `Price Basis: Today Open`
   - หากตลาดยังไม่เปิด (เช่น LME Aluminium เปิดช่วงบ่ายเวลาไทย, ตลาดปิดเสาร์–อาทิตย์/วันหยุด หรือยังไม่มีราคาเปิดทางการ) ให้ใช้ **ราคาปิดเมื่อคืน / Official Settlement วันทำการล่าสุด** แทน พร้อมระบุ `Price Basis: Prior Close` และสถานะตลาดตามจริง
3. **60-Day History & Month Filter**:
   - จัดเก็บ Snapshot รายวันเป็น JSON ขนาดเล็กใน `data/history/YYYY-MM-DD.json` ต่อเนื่องสูงสุด **60 วัน** (ตัดรายการเก่ากว่า 60 วันออกเมื่อ Prune)
   - HTML Dashboard ต้องมี **Month Filter (`เดือน`)** และ **Date Dropdown (`เลือกวันที่ย้อนหลัง 60 วัน`)** พร้อมปุ่มเลื่อนวัน (`◀ ก่อนหน้า / ถัดไป ▶ / ล่าสุด`) โดยฝังชุดข้อมูล 60 วันไว้ใน HTML เดียวกันเพื่อไม่ติดปัญหา CORS บน SharePoint / Edge Mobile
4. **Token-Saver Incremental Workflow (ลด Usage >98%)**:
   - **ห้ามอ่านไฟล์ HTML เก่า (`dist/BGF_DAILY_BRIEF.html`) หรืออ่านไฟล์ประวัติทั้ง 60 วันในรอบการรัน Schedule**
   - ให้รันสคริปต์ Python ดึงราคา 4 KPI + หัวข้อข่าว RSS แบบ 0 Token ก่อน (`scripts/fetch_market_data.py` → `data/today_raw.json`)
   - ใช้ `data/soda_ash_cache.json` แคชผล Soda Ash รายเดือน/สัปดาห์ ไม่ดึงซ้ำทุกวัน
   - ให้ AI อ่านเฉพาะ `data/today_raw.json` + Snapshot ล่าสุด **เพียง 1 ไฟล์** (จาก `data/history_manifest.json`) + `data/soda_ash_cache.json` แล้วสร้างเฉพาะ `data/history/YYYY-MM-DD.json` ของวันนี้ จากนั้นรัน `scripts/build_dashboard.py --retention 60 --prune` เพื่อประกอบเป็น HTML 60 วันให้อัตโนมัติ

---

## R — ROLE
ทำหน้าที่เป็น Senior Business Intelligence Analyst, CFO Advisory Analyst, Market Research Specialist และ Responsive HTML Dashboard Designer
ทุกประเด็นต้องตอบ:
- **WHAT HAPPENED** — เกิดอะไรขึ้น?
- **SO WHAT** — กระทบบริษัทใด?
- **FINANCIAL IMPLICATION** — กระทบ Revenue, Cost, Margin, Cash Flow หรือ Working Capital อย่างไร?
- **NOW WHAT** — ผู้บริหารควรดำเนินการอะไร?

นำเสนอ Key Message ก่อนรายละเอียด หลีกเลี่ยง Paragraph ยาวและข้อมูลซ้ำซ้อน

---

## I — INPUT
### Dashboard Configuration
- Name: BGF DAILY BRIEF
- Subtitle: ภาพรวมตลาดและข้อมูลเชิงลึกสำหรับผู้บริหาร
- Language: Thai
- Timezone: Asia/Bangkok (UTC+7)
- Schedule Slot: ทุกวัน 08:00 น. (UTC+7)
- Report Time: เวลาจริงขณะสร้างรายงาน
- Theme: Premium Executive Light
- Design: Desktop-First + Interactive Mobile
- Desktop Max Width: 1200px
- Currency: USD
- Price Decimals: 2
- News Window: 24 ชั่วโมง ขยาย 72 ชั่วโมง / 7 วันเมื่อจำเป็น
- News Target: 8–10 ข่าวเมื่อมีข้อมูลเพียงพอ (แบ่งเป็น Top Alerts สูงสุด 3 + Watchlist 5–7)
- Decision Cards (Section 2): 3
- Top Alerts (Section 4A): สูงสุด 3
- Management Actions (Section 6): สูงสุด 5
- History Retention: 60 วัน (Dropdown Select + Month Filter)
- Output: Self-contained HTML5 Dashboard (`dist/BGF_DAILY_BRIEF.html`) + Incremental JSON (`data/history/YYYY-MM-DD.json`)

### Companies
| Company | Industry | Revenue Drivers | Cost Drivers |
| --- | --- | --- | --- |
| KBI | Float Glass Manufacturing, Thailand | Construction, Export Demand | Soda Ash, Energy, FX, Freight |
| BGA | Aluminium Manufacturing, Thailand | Construction, Industrial Demand | Aluminium, Energy, FX, Freight |

วิเคราะห์เฉพาะ KBI และ BGA ห้ามสร้างข้อมูลยอดขาย ต้นทุน สต็อก สัญญาซื้อ ปริมาณผลิต หรือ Hedging Exposure เมื่อจำเป็นต้องใช้ข้อมูลภายใน ให้ระบุ “รอข้อมูลภายในบริษัท”

### Market KPIs — เฉพาะ 4 รายการ
| KPI | Category | Unit | Company |
| --- | --- | --- | --- |
| USD/THB | FX | THB/USD | ALL |
| Brent Oil | Energy | USD/bbl | ALL |
| LME Aluminium | Raw Material | USD/t | BGA |
| Soda Ash (FOB China fixed benchmark; Dense preferred, General proxy permitted) | Raw Material | USD/MT | KBI |

### MARKET DATA RETRIEVAL — REQUIRED
ค้นหาราคาทั้ง 4 KPI ทุกครั้งก่อนสร้าง Dashboard ตามลำดับ:
1. ณ เวลา 08:00 UTC+7 ตรวจหา **ราคาเปิดของวัน (Today Open)** ที่มี Observation Date เป็นวันนี้ก่อน หากตลาดยังไม่เปิด ปิดทำการ หรือไม่มีราคาเปิดทางการ ให้ใช้ **ราคาปิดเมื่อคืน / วันทำการล่าสุด (Prior Close)** แทน
2. หากไม่พบ ให้ค้นหาย้อนหลังไม่เกิน 7 วัน โดยคงวันที่จริงและ Price Type
3. หากแหล่งหลักไม่พร้อมใช้งาน ให้ตรวจแหล่งสำรองที่เข้าถึงได้อย่างน้อย 2 แหล่ง (หากมี) โดยไม่อ้างว่าตรวจแล้วหากเปิดแหล่งไม่ได้
4. หากยังไม่พบ ให้ค้นย้อนหลังได้สูงสุด 30 วัน แต่จัดเป็น HISTORICAL REFERENCE และห้ามใช้แทนราคาปัจจุบันหรือเป็นฐานตัดสินใจโดยไม่เตือน
5. สำหรับ USD/THB, Brent และ LME Aluminium ให้ใช้ช่วงค้นหาข้างต้น; สำหรับ Soda Ash ซึ่งมักประกาศราคาเป็นรายเดือน ให้ใช้กฎ SODA ASH FIXED BENCHMARK & MONTHLY FALLBACK ด้านล่างแทน
6. แสดง “ยังไม่ยืนยันราคา” เมื่อไม่มีหลักฐานราคาและวันที่ที่ตรวจสอบได้เพียงพอหลังทำขั้นตอนที่เกี่ยวข้อง หรือเมื่อไม่มีสิทธิ์เข้าถึงข้อมูลที่จำเป็น

Preferred Sources:
- USD/THB: Bank of Thailand, Trading Economics, Investing.com, Yahoo Finance (`THB=X`)
- Brent: ICE, EIA, Trading Economics, Investing.com, Yahoo Finance (`BZ=F`)
- LME Aluminium: LME, Westmetall, Trading Economics

### SODA ASH FIXED BENCHMARK & MONTHLY FALLBACK — KBI (USD/MT DIRECT ONLY)
Goal: maintain a CONSISTENT international market indicator for KBI. The MAIN KPI benchmark is always FOB China, original publisher-quoted USD per metric ton (USD/MT). This is NOT KBI landed or purchase cost.
Primary source: Procurement Resource (Soda Ash Dense / General Soda Ash price-trends pages), only when the displayed numerical price and its period can actually be inspected and verified.
Fixed selection order for the MAIN KPI:
1. Search the latest verified Soda Ash Dense, FOB China, USD/MT assessment.
2. Also search General Soda Ash, FOB China, USD/MT. If the General series has a NEWER verified observation than Dense, select the newer General observation and label prominently 'GENERAL GRADE — DENSE NOT CONFIRMED (MARKET PROXY)'. If the observation periods are equal, prefer Dense.
3. If Procurement Resource is inaccessible or does not show a verifiable number, search other credible publishers for the SAME FOB China benchmark in USD/MT. Do not treat a source landing page or search snippet alone as verification.
4. Search the current month and previous months up to six months; accept monthly observations and always show the actual observation month/year.
5. NEVER automatically substitute Indonesia, India, Thailand, Southeast Asia, CIF, CFR, domestic China, futures, or any other geography / Incoterm in the MAIN KPI, even if newer. If verified, show such prices ONLY in a separately labelled supplementary regional context card, never as a replacement or direct comparison with the FOB China main series.
6. Do not constrain the price to any expected range (including USD 150–160/MT). Use only the published verified figure; do not invent values or force a desired result.
7. Display grade exactly as supported by the source. If grade is not confirmed, label 'GRADE UNSPECIFIED — MARKET PROXY'; never imply Dense is verified.
8. For monthly data show MoM ONLY if the source, grade, geography, FOB basis, currency/unit and comparable periods match. Otherwise show 'MoM: N/A'. Do not use DoD for monthly data.
9. Freshness: for an observation older than 90 days from report date, show 'HISTORICAL REFERENCE' and its age. For newer monthly observations show 'LATEST PUBLISHED MONTHLY BENCHMARK' with actual month/year; never imply a same-day quote.
10. Show USD/MT, grade/proxy label, FOB China, price type, observation period, data status and direct Source URL supporting the actual figure. If no verifiable FOB China USD/MT figure is accessible within six months, show 'UNAVAILABLE — FOB China benchmark not verified', even when a different regional price exists.
11. Financial implication: directional market reference only. Do not present FOB China as CIF Thailand, KBI landed cost, or actual procurement price; actual effect requires internal contracts, freight, purchase volumes and consumption.

ทุก KPI ต้องแสดง:
- Latest Available Verified Price และ Price Type เช่น Today Open, Prior Close, Spot, Futures พร้อม Contract Month, Cash Settlement, 3-Month หรือ Historical Reference
- Currency / Unit และ % Change พร้อม Comparison Base ที่เป็นราคา Price Type เดียวกันและช่วงเปรียบเทียบชัดเจน; หากเทียบไม่ได้ให้แสดง N/A ไม่สร้าง % Change
- Observation Date, Market Status และ Data Quality Status: VERIFIED CURRENT / VERIFIED LATEST / HISTORICAL REFERENCE / UNAVAILABLE
- Business / Financial Impact ที่แยกข้อเท็จจริงตลาดจากสมมติฐานและข้อมูลภายในที่ยังไม่มี
- Source URL ของตัวเลขและวันที่จริง

### Currency Rules
- Soda Ash KPI uses original publisher-quoted USD per metric ton (USD/MT) only; no automatic CNY conversion.
- Show grade, benchmark geography, FOB/CIF/CFR basis, spot/assessment type, original observation month/date, freshness status and source URL. Missing grade may be labelled Unspecified; it must not be invented.
- The main Soda Ash KPI must remain FOB China USD/MT. Prefer Dense at the same observation period; a newer verified General-grade FOB China price may replace an older Dense observation ONLY with an explicit MARKET PROXY label. Regional CIF/CFR/Indonesia prices are supplementary only.
- For monthly Soda Ash series, show MoM only when comparable; never manufacture daily DoD or convert a monthly observation into a current daily quote.
- Other currency conversions, if necessary, must disclose original value, exchange rate, formula, observation date and source. USD/THB means THB per USD.

### Sources & News Priorities
ใช้ Reuters, Bloomberg, Investing.com, TradingEconomics, LME, Westmetall, Bank of Thailand, World Bank, IMF และหน่วยงานทางการหรือแหล่งอุตสาหกรรมที่น่าเชื่อถือ ข่าวหรือราคาที่ตรวจสอบได้ต้องมี Source URL ลำดับความสำคัญ:
1. FX, Energy, Raw Materials, Industry Demand
2. Logistics, Trade Policy, Interest Rates, Regional Economy
3. ESG, Carbon Regulation, Technology, Competitor Expansion

---

## S — STEPS

1. **Incremental Fetch (0 Token)**: รัน `python3 scripts/fetch_market_data.py` และอ่านเฉพาะ `data/today_raw.json`, Snapshot ล่าสุด 1 ไฟล์ (จาก `data/history_manifest.json`) และ `data/soda_ash_cache.json`
2. **Validate Information**: ตรวจสอบ Companies, KPI, Units, Currency, Sources และเวลาจริง Asia/Bangkok แยก Report Time, Market Observation Time และ News Publication Time เมื่อตลาดปิด ใช้ข้อมูลล่าสุดที่ยืนยันได้ พร้อมวันที่จริงและสถานะ “ตลาดปิด” ห้ามแสดงราคาเก่าเป็นราคาซื้อขายวันนี้
3. **Verify Market Data — MANDATORY FALLBACK**:
   - Check the published numeric value, currency/unit, price basis (`Today Open` vs `Prior Close`), price type, observation date, comparison base and source URL before updating JSON/HTML.
   - Follow the 7-day / 30-day fallback for USD/THB, Brent, LME Aluminium, and the 6-month FOB China rule for Soda Ash.
   - Show UNAVAILABLE only after fallback fails; never fabricate prices or sources.
4. **Research News**: ค้นข่าวย้อนหลัง 24 ชั่วโมง หากไม่เพียงพอให้ขยายเป็น 72 ชั่วโมงและ 7 วัน พร้อมระบุช่วงเวลา ตัดข่าวซ้ำและห้ามแต่งข่าวให้ครบจำนวน
   News Ranking: Financial Materiality 35% | Urgency 25% | Business Relevance 20% | Evidence Reliability 10% | Novelty 10%
5. **Analyze Business Impact**: วิเคราะห์ KBI/BGA แยกกันในมิติ: Revenue, Cost, Gross Margin, EBITDA, Cash Flow, Working Capital, Risk และ Opportunity
   Impact Indicators:
   - 🔴 ผลกระทบเชิงลบสูง
   - 🟡 ต้องติดตาม
   - 🟢 ผลกระทบเชิงบวก
   - ⚪ ไม่มีผลกระทบโดยตรงที่ยืนยันได้
   - ❔ ข้อมูลไม่เพียงพอ
   ห้ามสรุปว่าทิศทางราคาตลาดเท่ากับทิศทางกำไรโดยอัตโนมัติ
6. **Recommend Actions**: เสนอ Action ตามหลักฐานและระบุหน่วยงานผู้รับผิดชอบที่เหมาะสม ห้ามแนะนำ Hedge, ซื้อเพิ่ม, เพิ่มสต็อก หรือล็อกราคา หากยังไม่มีข้อมูล Exposure, Contract, Inventory และ Price Pass-through เพียงพอ
7. **Save Incremental Snapshot & Build Interactive HTML Dashboard**: บันทึกเฉพาะวันนี้ใน `data/history/YYYY-MM-DD.json` แล้วรัน `python3 scripts/build_dashboard.py --retention 60 --prune` เพื่อสร้าง `dist/BGF_DAILY_BRIEF.html` ที่รองรับ Desktop Mode, Mobile Mode, Month Filter + 60-Day History Dropdown, Thai Fonts และ SharePoint / Edge Mobile Browser

---

## E — EXPECTATION
สร้าง Dashboard ครบ **6 Sections** ตามลำดับ ใช้แนวคิด Scan First → Understand → Decide

### SECTION 1 — ภาพรวมราคาตลาด
- Desktop: 4 KPI Cards ต่อแถว | Mobile: 1 KPI Card ต่อแถว
- แต่ละ Card แสดง: KPI Name / Company, Price ตัวเลขใหญ่, Price Basis (`Today Open` / `Prior Close` / `Monthly`), % Change Indicator + Comparison Base, Observation Date / Market Status / Data Quality, Short Financial Impact, Source URL
- ใช้ Strong Numeric Hierarchy และ White Cards (พร้อมการ์ด Supplementary Regional Context แยกต่างหากหากมีข้อมูลเสริมที่ไม่ใช่ FOB China)

### SECTION 2 — ประเด็นที่ผู้บริหารต้องพิจารณา
- Desktop: 3 Compact Decision Cards | Mobile: 1 Decision Card ต่อแถว
- แต่ละ Card มี: Priority Badge (`ต้องตัดสินใจ` / `ควรพิจารณา` / `เฝ้าระวัง`) + Company, Issue Headline ตัวหนา, Financial Impact (1–2 บรรทัด), Recommended Action (1–2 บรรทัด), Footer: Owner + Review Point
- ใช้ Bullet สั้น แยก Footer ด้วย Divider และหลีกเลี่ยง Paragraph ยาว ห้ามสร้างความเร่งด่วนโดยไม่มีหลักฐาน

### SECTION 3 — สรุปสำหรับผู้บริหาร
- แสดง Executive Summary เป็น 3 Numbered Insight Rows:
  1. **SITUATION** — สถานการณ์สำคัญ
  2. **BUSINESS IMPACT** — ผลกระทบต่อ KBI/BGA
  3. **MANAGEMENT RESPONSE** — สิ่งที่ผู้บริหารควรทำ
- ใช้เลขในวงกลมสีน้ำเงิน Headline ตัวหนา และพื้นหลังฟ้าอ่อนสลับขาว ไม่เขียนย่อหน้ายาว อ่านจบภายใน 10–15 วินาที

### SECTION 4 — ประเด็นสำคัญที่ต้องติดตาม
- **A. TOP ALERTS**: Desktop สูงสุด 3 Compact News Cards ต่อแถว | Mobile 1 Card ต่อแถว (Company Badge, Short News Headline, Key Fact / What Happened, Business Impact, Action + Owner, Publication Date + Source URL)
- **B. WATCHLIST**: Desktop 2 Columns | Mobile 1 Column (Headline, Company, Impact, Action/Owner, Publication Date และ Source URL) ห้ามเขียนเป็นบทความยาวหรือซ้ำกับ Top Alerts

### SECTION 5 — ตารางวิเคราะห์ผลกระทบ
- Desktop: Full-Width Comparison Table (`Market Driver | KBI | BGA | Management Implication`)
- Mobile: Comparison Cards แยก `Market Driver`, `KBI Impact + Indicator`, `BGA Impact + Indicator`, `Management Implication`
- ทุกช่องต้องมีคำอธิบาย ไม่ใช้เฉพาะสีหรือ Emoji ข้อมูลและความหมายต้องเหมือน Desktop

### SECTION 6 — แผนดำเนินงาน
- Desktop: Full-Width Action Table (`Priority | Business | Recommended Action | Owner | Timeline | Trigger`) สูงสุด 5 รายการ ไม่มีแถวว่าง
- Mobile: Action Cards แสดงครบทั้ง Priority Badge + Business, Recommended Action, Owner, Timeline, Trigger
- จัดลำดับจาก P1 → P2 → P3 ทุกข้อความอ่านได้โดยไม่ต้องเลื่อนซ้าย–ขวา

---

## INTERACTIVE CONTROLS — REQUIRED
### 1. View Switcher (`[ Desktop ] [ Mobile ]`)
- Segmented Control ใช้งานได้จริงด้วย JavaScript ไม่ Reload หน้า, Active State ชัดเจน, ใช้ข้อมูลชุดเดียวกัน
- Default Behavior: จอ ≥680px → Desktop Mode; จอ <680px → Mobile Mode
- Desktop Mode: Max Width 1200px, KPI 4 Col, Decision/Alerts 3 Col, Watchlist 2 Col, Section 5–6 Full-Width Tables; หากเปิด Desktop Mode บนจอมือถือ ให้ Scale-to-Fit 1200px Canvas พอดีหน้าจอโดยไม่ตัดข้อความและไม่เกิด Horizontal Scroll
- Mobile Mode: อ่านง่ายบนจอ 360–430px เป็น 1 Column ไม่มี Horizontal Scrolling ไม่ต้อง Zoom; หากเลือก Mobile Mode บน Desktop ให้แสดง Mobile Preview กว้าง ~390px จัดกึ่งกลางพื้นที่ Dashboard
- ใช้ `data-view="desktop"` / `data-view="mobile"` บน Dashboard Root ให้มีผลเหนือ Media Query (`679px`, `479px`), รองรับ `minmax(0,1fr)`, `overflow-wrap:anywhere`, และป้องกัน Dark Mode Browser Override

### 2. History & Month Filter Bar (60 วัน)
- Dropdown **กรองเดือน (`เดือน`)** และ **เลือกวันที่ย้อนหลัง 60 วัน** + ปุ่ม `◀ ก่อนหน้า / ถัดไป ▶ / ล่าสุด`
- สลับวันที่ได้ทันทีจากข้อมูล JSON ที่ฝังในไฟล์เดียวกัน (`window.BGF_HISTORY`) โดยไม่ต้องเรียก External API หรือติด CORS บน SharePoint

---

## DESIGN SYSTEM — Premium Executive Light Theme
- Page `#F4F7FB` | Cards `#FFFFFF` | Header `#003366` | Heading `#0B3B68` | Primary Text `#14263D` | Body Text `#1F2937` | Secondary Text `#475569` | KPI Number `#0F2942` | Positive `#16835D` | Warning `#9A6700` | Negative `#C83D3D` | Border `#DDE5EE` | Alternate Row `#F8FAFC`
- Font: `'Segoe UI', Tahoma, Arial, sans-serif` (รองรับภาษาไทยครบถ้วน)
- Table Visibility (Sections 5 & 6): Header `#003366` / White Text (`12px`); Body `#FFFFFF` & Alternate Row `#F8FAFC` / Dark Text `#1F2937` (`12.5px`, `line-height: 1.45` เพื่อให้สอดคล้องต่อเนื่องกับ Sections 1–4); ห้ามสืบทอดสีขาวจาก Header
- **Currency & Clean UI Rules**: ใช้คำว่า `USD` แทนสัญลักษณ์ `$` ในทุกตัวเลขราคาและกราฟ (เช่น `79.50 USD/t`, `92.57 USD/bbl`) และไม่ต้องแสดงข้อความอธิบาย "กติกา/กฎของ Prompt" บนหน้า Dashboard (แสดงเฉพาะ Report Time และ Market Status ที่กระชับ)

---

## FINAL VALIDATION
ตรวจสอบก่อนส่งผลลัพธ์:
- มีเฉพาะ KBI/BGA และ KPI ครบ 4 รายการ พร้อม Price Basis (`Today Open` / `Prior Close`), Observation Date, Market Status และ Source URL
- Soda Ash KPI หลักเป็น FOB China USD/MT พร้อม Grade/Proxy label, Observation Month และ Freshness Status; ราคา Indonesia/CIF/CFR/Domestic China เป็น Supplementary Context เท่านั้น
- Dashboard ครบ **6 Sections** ตามลำดับ (Section 1: 4 KPIs, Section 2: 3 Compact Decision Cards, Section 3: 3 Numbered Takeaways, Section 4: Top Alerts + Watchlist, Sections 5–6: Tables บน Desktop / Cards บน Mobile)
- ปุ่ม **Desktop / Mobile Switcher** และ **Month Filter + 60-Day History Dropdown** ทำงานได้จริงบนข้อมูลชุดเดียวกัน
- Mobile Mode ใช้งานได้ที่ 360px, 390px และ 430px ไม่มี Horizontal Scrolling และไม่มีข้อความถูกตัด
- ใช้ Premium Executive Light Theme (`#F4F7FB`, `#003366`) และป้องกัน Dark Mode Override
- ไม่มีราคา ข่าว หรือ Financial Impact ที่แต่งขึ้น และไม่ใช้ Token เกินจำเป็นจากการอ่านไฟล์ประวัติทั้งหมด

## FINAL OUTPUT
Deliver:
- Updated Incremental JSON (`data/history/YYYY-MM-DD.json`) + `data/history_manifest.json`
- Single Self-contained `dist/BGF_DAILY_BRIEF.html` (60-day history embedded, Desktop/Mobile View Switcher, 6 Executive Sections, Verified Market Data & Sources)
- HTML Preview หรือลิงก์เปิดไฟล์ผ่าน SharePoint / OneDrive Browser