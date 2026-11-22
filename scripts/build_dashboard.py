#!/usr/bin/env python3
"""
BGF Daily Brief — Self-Contained HTML5 Dashboard Compiler (Master Prompt V5)
- Exact 6 Executive Sections (Scan First -> Understand -> Decide)
- Exact Premium Executive Light Design System (#F4F7FB, #003366, #1F2937)
- Interactive View Switcher (data-view="desktop" / "mobile" with >=680px default & Scale-to-Fit)
- 60-Day History Dropdown + Month Filter embedded in a single SharePoint/Edge-Mobile-safe HTML file
"""

from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any

ROOT_DIR = Path(__file__).resolve().parent.parent
DATA_DIR = ROOT_DIR / "data"
HISTORY_DIR = DATA_DIR / "history"
MANIFEST_PATH = DATA_DIR / "history_manifest.json"
DIST_DIR = ROOT_DIR / "dist"
OUTPUT_HTML = DIST_DIR / "BGF_DAILY_BRIEF.html"

HTML_TEMPLATE = r"""<!DOCTYPE html>
<html lang="th">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=5.0" />
  <meta name="color-scheme" content="light" />
  <title>BGF DAILY BRIEF — Executive Financial Intelligence Dashboard</title>
  <style>
    :root {
      color-scheme: light;
      --bg-page: #F4F7FB;
      --bg-card: #FFFFFF;
      --bg-header: #003366;
      --text-heading: #0B3B68;
      --text-primary: #14263D;
      --text-body: #1F2937;
      --text-secondary: #475569;
      --text-kpi: #0F2942;
      --positive: #16835D;
      --positive-bg: #ECFDF5;
      --warning: #9A6700;
      --warning-bg: #FFFBEB;
      --negative: #C83D3D;
      --negative-bg: #FEF2F2;
      --border: #DDE5EE;
      --alt-row: #F8FAFC;
      --accent-blue-bg: #EFF6FF;
      --font-sans: 'Segoe UI', Tahoma, 'Noto Sans Thai', 'Sarabun', Arial, sans-serif;
    }

    * { box-sizing: border-box; }
    html, body {
      margin: 0;
      padding: 0;
      background: var(--bg-page);
      color: var(--text-body);
      font-family: var(--font-sans);
      font-size: 14px;
      line-height: 1.5;
      -webkit-text-size-adjust: 100%;
    }
    a { color: #0B3B68; text-decoration: none; font-weight: 600; overflow-wrap: anywhere; }
    a:hover { text-decoration: underline; }

    /* Sticky Executive Header (#003366) */
    .topbar {
      background: var(--bg-header);
      color: #FFFFFF;
      border-bottom: 3px solid #0B3B68;
      position: sticky;
      top: 0;
      z-index: 50;
      box-shadow: 0 2px 10px rgba(0, 51, 102, 0.18);
    }
    .topbar-inner {
      max-width: 1200px;
      margin: 0 auto;
      padding: 12px 16px;
      display: flex;
      flex-wrap: wrap;
      align-items: center;
      justify-content: space-between;
      gap: 12px;
    }
    .brand-wrap {
      display: flex;
      align-items: center;
      gap: 12px;
      min-width: 0;
    }
    .brand-badge {
      width: 40px;
      height: 40px;
      border-radius: 8px;
      background: #FFFFFF;
      color: var(--bg-header);
      display: flex;
      align-items: center;
      justify-content: center;
      font-weight: 800;
      font-size: 15px;
      flex-shrink: 0;
    }
    .brand-title {
      font-size: 18px;
      font-weight: 800;
      color: #FFFFFF;
      line-height: 1.2;
    }
    .brand-sub {
      font-size: 12px;
      color: #DBEAFE;
      margin-top: 2px;
    }

    /* Segmented View Switcher */
    .view-switcher {
      display: inline-flex;
      background: rgba(255, 255, 255, 0.14);
      border: 1px solid rgba(255, 255, 255, 0.28);
      border-radius: 8px;
      padding: 3px;
      gap: 4px;
    }
    .view-btn {
      border: none;
      background: transparent;
      color: #E2E8F0;
      font-family: inherit;
      font-size: 12.5px;
      font-weight: 700;
      padding: 6px 14px;
      border-radius: 6px;
      cursor: pointer;
      min-height: 34px;
      transition: background 0.15s ease, color 0.15s ease;
    }
    .view-btn.active {
      background: #FFFFFF;
      color: var(--bg-header);
      box-shadow: 0 1px 3px rgba(0, 0, 0, 0.22);
    }

    /* 60-Day History & Month Filter Bar */
    .history-bar {
      background: var(--bg-card);
      border-bottom: 1px solid var(--border);
    }
    .history-inner {
      max-width: 1200px;
      margin: 0 auto;
      padding: 10px 16px;
      display: flex;
      flex-wrap: wrap;
      align-items: center;
      justify-content: space-between;
      gap: 10px;
    }
    .history-controls {
      display: flex;
      flex-wrap: wrap;
      align-items: center;
      gap: 8px;
    }
    .ctrl-label {
      display: inline-flex;
      align-items: center;
      gap: 6px;
      font-size: 12.5px;
      font-weight: 700;
      color: var(--text-primary);
    }
    .select-box {
      font-family: inherit;
      font-size: 13px;
      font-weight: 600;
      color: var(--text-primary);
      background: var(--alt-row);
      border: 1px solid var(--border);
      border-radius: 6px;
      padding: 6px 10px;
      min-height: 36px;
      max-width: 100%;
    }
    .btn-step {
      font-family: inherit;
      font-size: 12px;
      font-weight: 700;
      color: var(--text-primary);
      background: var(--alt-row);
      border: 1px solid var(--border);
      border-radius: 6px;
      padding: 6px 10px;
      min-height: 36px;
      cursor: pointer;
    }
    .btn-step:hover:not(:disabled) { background: #E2E8F0; }
    .btn-step:disabled { opacity: 0.45; cursor: not-allowed; }
    .history-badges {
      display: flex;
      flex-wrap: wrap;
      align-items: center;
      gap: 6px;
    }

    /* Viewport Stage & Scale-to-Fit Root */
    .stage-outer {
      width: 100%;
      padding: 16px 12px 44px;
      overflow-x: hidden;
    }
    .scale-wrapper {
      width: 100%;
      margin: 0 auto;
      position: relative;
    }
    #dashboardRoot {
      width: 100%;
      max-width: 1200px;
      margin: 0 auto;
      display: flex;
      flex-direction: column;
      gap: 16px;
      transform-origin: top left;
    }

    /* View Mode Overrides (data-view takes precedence over media queries) */
    #dashboardRoot[data-view="desktop"] {
      width: 100%;
      max-width: 1200px;
    }
    #dashboardRoot[data-view="desktop"] .grid-4 {
      grid-template-columns: repeat(2, minmax(0, 1fr));
    }
    #dashboardRoot[data-view="desktop"] .grid-3 {
      grid-template-columns: repeat(3, minmax(0, 1fr));
    }
    #dashboardRoot[data-view="desktop"] .grid-2 {
      grid-template-columns: repeat(2, minmax(0, 1fr));
    }
    #dashboardRoot[data-view="desktop"] .meta-strip {
      grid-template-columns: repeat(2, minmax(0, 1fr));
    }
    #dashboardRoot[data-view="desktop"] .desktop-only-table { display: block; }
    #dashboardRoot[data-view="desktop"] .mobile-only-cards { display: none; }
    #dashboardRoot[data-view="desktop"] .kpi-type-line { display: none; }
    #dashboardRoot[data-view="desktop"] .kpi-meta-block { min-height: 40px; }
    #dashboardRoot[data-view="desktop"] .mobile-acc-bar { display: none; }
    #dashboardRoot[data-view="desktop"] .acc-chevron { display: none; }
    #dashboardRoot[data-view="desktop"] .mobile-only-badge { display: none; }
    #dashboardRoot[data-view="desktop"] .desktop-only-sub { display: inline; }
    #dashboardRoot[data-view="desktop"] .acc-section.is-collapsed .acc-body { display: block; }

    /* Mobile Mode (also used for 390px preview on desktop) */
    #dashboardRoot[data-view="mobile"] {
      width: 100%;
      max-width: 390px;
      margin: 0 auto;
      background: var(--bg-page);
    }
    .stage-outer.mobile-preview-bg {
      background: #CBD5E1;
      padding: 18px 10px 44px;
    }
    .stage-outer.mobile-preview-bg #dashboardRoot[data-view="mobile"] {
      border: 6px solid var(--bg-header);
      border-radius: 22px;
      padding: 12px;
      box-shadow: 0 18px 40px rgba(0, 51, 102, 0.25);
    }
    #dashboardRoot[data-view="mobile"] .grid-4,
    #dashboardRoot[data-view="mobile"] .grid-3,
    #dashboardRoot[data-view="mobile"] .grid-2,
    #dashboardRoot[data-view="mobile"] .meta-strip {
      grid-template-columns: minmax(0, 1fr);
    }
    #dashboardRoot[data-view="mobile"] .desktop-only-table { display: none; }
    #dashboardRoot[data-view="mobile"] .mobile-only-cards { display: flex; flex-direction: column; gap: 10px; }
    #dashboardRoot[data-view="mobile"] .mobile-date-card { display: flex; }
    #dashboardRoot[data-view="mobile"] .acc-chevron { display: inline-flex; }
    #dashboardRoot[data-view="mobile"] .mobile-only-badge { display: inline-flex; }
    #dashboardRoot[data-view="mobile"] .desktop-only-sub { display: none; }
    #dashboardRoot[data-view="mobile"] .acc-section.is-collapsed .acc-body { display: none; }

    /* Mobile Inline Date & Month Selector Card */
    .mobile-date-card {
      display: none;
      flex-direction: column;
      gap: 8px;
      background: var(--bg-card);
      border: 1px solid var(--border);
      border-radius: 10px;
      padding: 10px 12px;
      box-shadow: 0 1px 3px rgba(15, 41, 66, 0.06);
    }
    .mobile-date-row {
      display: flex;
      align-items: center;
      gap: 6px;
    }
    .mobile-date-row .select-box {
      flex: 1;
      min-width: 0;
      font-size: 12.5px;
      padding: 6px 8px;
      min-height: 34px;
    }
    .mobile-date-row .btn-step {
      padding: 5px 9px;
      min-height: 34px;
      flex-shrink: 0;
    }

    /* Collapsible Mobile Accordion Sections — Uniform Alignment Across All 6 Sections */
    .card.acc-section,
    .acc-section {
      padding: 0;
      overflow: hidden;
    }
    .acc-section.plain-sec {
      background: transparent;
      border: none;
      box-shadow: none;
    }
    #dashboardRoot[data-view="mobile"] .card.acc-section,
    #dashboardRoot[data-view="mobile"] .acc-section.plain-sec {
      background: var(--bg-card);
      border: 1px solid var(--border);
      border-radius: 10px;
      box-shadow: 0 1px 3px rgba(15, 41, 66, 0.06);
      padding: 0;
    }
    .acc-header {
      width: 100%;
      background: transparent;
      border: none;
      padding: 13px 16px 10px;
      margin: 0;
      display: flex;
      flex-wrap: wrap;
      align-items: center;
      justify-content: space-between;
      gap: 8px;
      text-align: left;
      font-family: inherit;
      cursor: default;
    }
    .acc-section.plain-sec .acc-header {
      padding: 0 0 10px;
    }
    #dashboardRoot[data-view="mobile"] .acc-header,
    #dashboardRoot[data-view="mobile"] .acc-section.plain-sec .acc-header {
      cursor: pointer;
      padding: 11px 12px;
      border-left: 4px solid var(--bg-header);
      flex-wrap: nowrap;
      align-items: center;
      min-height: 52px;
    }
    #dashboardRoot[data-view="mobile"] .acc-header .section-title {
      font-size: 13px;
      line-height: 1.35;
      flex: 1;
      min-width: 0;
    }
    #dashboardRoot[data-view="mobile"] .acc-section:not(.is-collapsed) .acc-header {
      background: var(--bg-header);
      border-bottom: 1px solid #0B3B68;
    }
    #dashboardRoot[data-view="mobile"] .acc-section:not(.is-collapsed) .acc-header .section-title,
    #dashboardRoot[data-view="mobile"] .acc-section:not(.is-collapsed) .acc-header .section-sub {
      color: #FFFFFF;
    }
    #dashboardRoot[data-view="mobile"] .acc-section:not(.is-collapsed) .acc-header .acc-count-pill {
      background: rgba(255, 255, 255, 0.2);
      color: #FFFFFF;
      border-color: rgba(255, 255, 255, 0.35);
    }
    .acc-header-right {
      display: inline-flex;
      align-items: center;
      gap: 6px;
      margin-left: auto;
      flex-shrink: 0;
    }
    .acc-chevron {
      width: 24px;
      height: 24px;
      border-radius: 999px;
      align-items: center;
      justify-content: center;
      font-size: 11px;
      font-weight: 800;
      background: #E6EEF7;
      color: var(--bg-header);
      flex-shrink: 0;
    }
    #dashboardRoot[data-view="mobile"] .acc-section:not(.is-collapsed) .acc-chevron {
      background: rgba(255, 255, 255, 0.22);
      color: #FFFFFF;
    }
    .acc-body {
      padding: 0 16px 14px;
    }
    .acc-section.plain-sec .acc-body {
      padding: 0;
    }
    #dashboardRoot[data-view="mobile"] .acc-body,
    #dashboardRoot[data-view="mobile"] .acc-section.plain-sec .acc-body {
      padding: 11px 12px 12px;
    }

    /* Desktop Overview forced on small mobile screen (<680px) -> Scale-to-Fit 1200px Canvas */
    #dashboardRoot[data-view="desktop"].scaled-desktop {
      width: 1200px;
      max-width: 1200px;
      margin: 0;
    }

    /* Auto Responsive Fallback at 679px and 479px */
    @media (max-width: 679px) {
      .stage-outer { padding: 12px 10px 36px; }
      .topbar-inner, .history-inner { padding: 10px 12px; }
      .select-box { width: 100%; }
      #dashboardRoot:not([data-view="desktop"]) .grid-4,
      #dashboardRoot:not([data-view="desktop"]) .grid-3,
      #dashboardRoot:not([data-view="desktop"]) .grid-2,
      #dashboardRoot:not([data-view="desktop"]) .meta-strip {
        grid-template-columns: minmax(0, 1fr);
      }
      #dashboardRoot:not([data-view="desktop"]) .desktop-only-table { display: none; }
      #dashboardRoot:not([data-view="desktop"]) .mobile-only-cards { display: flex; flex-direction: column; gap: 10px; }
      #dashboardRoot:not([data-view="desktop"]) .mobile-date-card { display: flex; }
      #dashboardRoot:not([data-view="desktop"]) .acc-chevron { display: inline-flex; }
      #dashboardRoot:not([data-view="desktop"]) .acc-section.is-collapsed .acc-body { display: none; }
      #dashboardRoot:not([data-view="desktop"]) .card.acc-section,
      #dashboardRoot:not([data-view="desktop"]) .acc-section.plain-sec { background: var(--bg-card); border: 1px solid var(--border); border-radius: 10px; padding: 0; }
      #dashboardRoot:not([data-view="desktop"]) .acc-header,
      #dashboardRoot:not([data-view="desktop"]) .acc-section.plain-sec .acc-header { cursor: pointer; padding: 11px 12px; border-left: 4px solid var(--bg-header); flex-wrap: nowrap; min-height: 52px; }
      #dashboardRoot:not([data-view="desktop"]) .acc-body,
      #dashboardRoot:not([data-view="desktop"]) .acc-section.plain-sec .acc-body { padding: 11px 12px 12px; }
    }
    @media (max-width: 479px) {
      .brand-title { font-size: 15px; }
      .kpi-number { font-size: 22px; }
    }

    /* Common Layout & Cards */
    .grid-4, .grid-3, .grid-2, .meta-strip {
      display: grid;
      gap: 12px;
    }
    .card {
      background: var(--bg-card);
      border: 1px solid var(--border);
      border-radius: 10px;
      padding: 14px 16px;
      box-shadow: 0 1px 3px rgba(15, 41, 66, 0.06);
      min-width: 0;
      overflow-wrap: anywhere;
    }
    .section-head {
      display: flex;
      flex-wrap: wrap;
      align-items: center;
      justify-content: space-between;
      gap: 8px;
      margin-bottom: 10px;
    }
    .section-title {
      margin: 0;
      font-size: 14.5px;
      font-weight: 800;
      color: var(--text-heading);
    }
    .section-sub {
      font-size: 12px;
      color: var(--text-secondary);
    }

    /* Pills & Badges */
    .pill {
      display: inline-flex;
      align-items: center;
      gap: 4px;
      font-size: 11px;
      font-weight: 700;
      padding: 2px 8px;
      border-radius: 999px;
      white-space: nowrap;
      border: 1px solid transparent;
    }
    .pill-navy { background: #E6EEF7; color: #003366; border-color: #BFD3EA; }
    .pill-pos { background: var(--positive-bg); color: var(--positive); border-color: #A7F3D0; }
    .pill-warn { background: var(--warning-bg); color: var(--warning); border-color: #FDE68A; }
    .pill-neg { background: var(--negative-bg); color: var(--negative); border-color: #FECACA; }
    .pill-slate { background: var(--alt-row); color: var(--text-secondary); border-color: var(--border); }

    /* Meta Strip */
    .meta-box {
      background: var(--bg-card);
      border: 1px solid var(--border);
      border-radius: 8px;
      padding: 10px 12px;
      min-width: 0;
      overflow-wrap: anywhere;
    }
    .meta-k { font-size: 11px; font-weight: 700; color: var(--text-secondary); text-transform: uppercase; }
    .meta-v { font-size: 12.5px; font-weight: 700; color: var(--text-primary); margin-top: 2px; }

    /* Section 1: KPI Cards */
    .kpi-card {
      background: var(--bg-card);
      border: 1px solid var(--border);
      border-top: 4px solid var(--bg-header);
      border-radius: 10px;
      padding: 12px 13px;
      display: flex;
      flex-direction: column;
      gap: 7px;
      box-shadow: 0 1px 3px rgba(15, 41, 66, 0.06);
      min-width: 0;
      overflow-wrap: anywhere;
    }
    .kpi-card.is-unavail { border-top-color: var(--warning); background: #FFFCF5; }
    .kpi-top-meta {
      display: flex;
      justify-content: space-between;
      align-items: center;
      gap: 6px;
      font-size: 11px;
      color: var(--text-secondary);
      min-height: 22px;
    }
    .kpi-date-tag {
      font-size: 11px;
      font-weight: 700;
      color: #0B3B68;
      background: #E6EEF7;
      border: 1px solid #BFD3EA;
      padding: 2px 7px;
      border-radius: 999px;
      white-space: nowrap;
      flex-shrink: 0;
    }
    .kpi-title {
      font-size: 13.5px;
      font-weight: 800;
      color: #0B3B68;
      white-space: nowrap;
      overflow: hidden;
      text-overflow: ellipsis;
      line-height: 1.3;
    }
    .kpi-price-row {
      display: flex;
      align-items: baseline;
      flex-wrap: nowrap;
      gap: 5px;
      margin: 2px 0;
      min-height: 30px;
    }
    .kpi-number {
      font-size: 24px;
      font-weight: 800;
      color: var(--text-kpi);
      letter-spacing: -0.4px;
      line-height: 1.15;
      white-space: nowrap;
    }
    .kpi-number.unavail-lbl { font-size: 16px; color: var(--warning); white-space: normal; }
    .kpi-unit {
      font-size: 11.5px;
      font-weight: 700;
      color: var(--text-secondary);
      white-space: nowrap;
    }
    .kpi-meta-block {
      font-size: 11.5px;
      color: var(--text-secondary);
      line-height: 1.42;
      display: flex;
      flex-direction: column;
      gap: 2px;
      min-height: 64px;
    }
    .kpi-meta-line {
      overflow-wrap: anywhere;
    }
    .kpi-impact-box {
      background: var(--alt-row);
      border: 1px solid var(--border);
      border-radius: 8px;
      padding: 8px 10px;
      font-size: 12.5px;
      line-height: 1.45;
      color: var(--text-body);
      flex: 1;
      display: flex;
      align-items: flex-start;
    }
    .kpi-foot {
      display: flex;
      justify-content: space-between;
      align-items: center;
      gap: 8px;
      font-size: 11px;
      color: var(--text-secondary);
      border-top: 1px solid var(--border);
      padding-top: 6px;
    }

    /* Supplementary Context */
    .supp-box {
      background: var(--bg-card);
      border: 1px dashed var(--text-secondary);
      border-radius: 10px;
      padding: 12px 14px;
    }
    .supp-grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
      gap: 10px;
      margin-top: 8px;
    }
    .supp-card {
      background: var(--alt-row);
      border: 1px solid var(--border);
      border-radius: 8px;
      padding: 10px;
      font-size: 12.5px;
      line-height: 1.45;
      color: var(--text-body);
    }

    /* Section 2: Compact Decision Cards */
    .decision-card {
      background: var(--bg-card);
      border: 1px solid var(--border);
      border-radius: 10px;
      padding: 13px;
      display: flex;
      flex-direction: column;
      gap: 7px;
      box-shadow: 0 1px 3px rgba(15, 41, 66, 0.06);
      min-width: 0;
      overflow-wrap: anywhere;
    }
    .decision-headline {
      font-size: 13.5px;
      font-weight: 800;
      color: var(--text-heading);
      line-height: 1.35;
    }
    .decision-bullet {
      font-size: 12.5px;
      line-height: 1.45;
      color: var(--text-body);
      margin: 0;
    }
    .decision-foot {
      border-top: 1px solid var(--border);
      padding-top: 7px;
      margin-top: auto;
      font-size: 11.5px;
      line-height: 1.4;
      color: var(--text-secondary);
    }

    /* Section 3: 3 Numbered Insight Rows */
    .exec-rows {
      display: flex;
      flex-direction: column;
      border: 1px solid var(--border);
      border-radius: 10px;
      overflow: hidden;
      background: var(--bg-card);
    }
    .exec-row {
      display: flex;
      align-items: flex-start;
      gap: 12px;
      padding: 11px 14px;
      background: #FFFFFF;
      border-bottom: 1px solid var(--border);
    }
    .exec-row:nth-child(odd) { background: var(--accent-blue-bg); }
    .exec-row:last-child { border-bottom: none; }
    .num-circle {
      width: 26px;
      height: 26px;
      border-radius: 999px;
      background: var(--bg-header);
      color: #FFFFFF;
      font-weight: 800;
      font-size: 12.5px;
      display: flex;
      align-items: center;
      justify-content: center;
      flex-shrink: 0;
      margin-top: 2px;
    }
    .exec-row-title {
      font-size: 11.5px;
      font-weight: 800;
      color: var(--text-heading);
      text-transform: uppercase;
    }
    .exec-row-head {
      font-size: 13.5px;
      font-weight: 800;
      color: var(--text-primary);
      margin: 2px 0;
      line-height: 1.35;
    }
    .exec-row-detail {
      font-size: 12.5px;
      line-height: 1.45;
      color: var(--text-body);
      margin: 0;
    }

    /* Section 4: Top Alerts & Watchlist */
    .news-card {
      background: var(--bg-card);
      border: 1px solid var(--border);
      border-radius: 10px;
      padding: 13px;
      display: flex;
      flex-direction: column;
      gap: 7px;
      min-width: 0;
      overflow-wrap: anywhere;
    }
    .news-headline {
      font-size: 13.5px;
      font-weight: 800;
      color: var(--text-primary);
      line-height: 1.35;
    }
    .news-line {
      font-size: 12.5px;
      line-height: 1.45;
      color: var(--text-body);
      background: var(--alt-row);
      padding: 5px 8px;
      border-radius: 6px;
    }
    .chip-row { display: flex; flex-wrap: wrap; gap: 6px; }
    .chip-btn {
      font-family: inherit;
      font-size: 12px;
      font-weight: 700;
      padding: 5px 12px;
      border-radius: 999px;
      border: 1px solid var(--border);
      background: var(--alt-row);
      color: var(--text-secondary);
      cursor: pointer;
      min-height: 32px;
    }
    .chip-btn.active {
      background: var(--bg-header);
      color: #FFFFFF;
      border-color: var(--bg-header);
    }

    /* Sections 5 & 6: Tables (Desktop) & Cards (Mobile) */
    .table-wrap { width: 100%; overflow-x: auto; }
    table.exec-table {
      width: 100%;
      border-collapse: collapse;
      font-size: 12.5px;
      line-height: 1.45;
      background: #FFFFFF;
    }
    table.exec-table thead th {
      background: #003366;
      color: #FFFFFF;
      text-align: left;
      font-weight: 700;
      font-size: 12px;
      padding: 9px 10px;
      border: 1px solid #0B3B68;
    }
    table.exec-table tbody tr {
      background: #FFFFFF;
      color: #1F2937;
    }
    table.exec-table tbody tr:nth-child(even) {
      background: #F8FAFC;
      color: #1F2937;
    }
    table.exec-table tbody td {
      padding: 9px 10px;
      border: 1px solid var(--border);
      vertical-align: top;
      color: #1F2937;
      overflow-wrap: anywhere;
    }
    .mobile-card-item {
      background: #FFFFFF;
      border: 1px solid var(--border);
      border-radius: 10px;
      padding: 11px 12px;
      font-size: 12.5px;
      line-height: 1.45;
      color: #1F2937;
      display: flex;
      flex-direction: column;
      gap: 6px;
      overflow-wrap: anywhere;
    }

    .footer-note {
      text-align: center;
      font-size: 12px;
      color: var(--text-secondary);
      padding: 8px 0 14px;
    }
  </style>
</head>
<body>
  <header class="topbar">
    <div class="topbar-inner">
      <div class="brand-wrap">
        <div class="brand-badge">BGF</div>
        <div>
          <div class="brand-title">BGF DAILY BRIEF</div>
          <div class="brand-sub">ภาพรวมตลาดและข้อมูลเชิงลึกสำหรับผู้บริหาร (CEO • COO • CFO)</div>
        </div>
      </div>
      <div class="view-switcher" role="group" aria-label="View Mode Switcher">
        <button type="button" class="view-btn" id="btnDesktop" onclick="setViewMode('desktop')">Desktop</button>
        <button type="button" class="view-btn" id="btnMobile" onclick="setViewMode('mobile')">Mobile</button>
      </div>
    </div>
  </header>

  <section class="history-bar" id="historyBar" aria-label="60-Day History Filter">
    <div class="history-inner">
      <div class="history-controls">
        <label class="ctrl-label">
          <span>เดือน:</span>
          <select id="monthFilter" class="select-box" aria-label="Filter by month"></select>
        </label>
        <label class="ctrl-label">
          <span>วันที่:</span>
          <select id="dateSelect" class="select-box" aria-label="Select date"></select>
        </label>
        <button type="button" class="btn-step" id="btnPrevDay" title="วันก่อนหน้า">◀</button>
        <button type="button" class="btn-step" id="btnNextDay" title="วันถัดไป">▶</button>
        <button type="button" class="btn-step" id="btnLatest">ล่าสุด</button>
      </div>
      <div class="history-badges" id="historyMeta"></div>
    </div>
  </section>

  <main class="stage-outer" id="stageOuter">
    <div class="scale-wrapper" id="scaleWrapper">
      <div id="dashboardRoot" data-view="desktop"></div>
    </div>
  </main>

  <script>
    window.BGF_HISTORY = __BGF_HISTORY_JSON__;

    const TH_PUBLIC_HOLIDAYS = {
      '2026-01-01': 'วันขึ้นปีใหม่',
      '2026-01-02': 'วันหยุดพิเศษปีใหม่',
      '2026-03-03': 'วันมาฆบูชา',
      '2026-04-06': 'วันจักรี',
      '2026-04-13': 'วันสงกรานต์',
      '2026-04-14': 'วันสงกรานต์',
      '2026-04-15': 'วันสงกรานต์',
      '2026-05-01': 'วันแรงงานแห่งชาติ',
      '2026-05-04': 'วันฉัตรมงคล',
      '2026-06-01': 'ชดเชยวันวิสาขบูชา',
      '2026-06-03': 'วันเฉลิมพระชนมพรรษาพระราชินี',
      '2026-07-29': 'วันอาสาฬหบูชา',
      '2026-08-12': 'วันแม่แห่งชาติ',
      '2026-10-13': 'วันนวมินทรมหาราช',
      '2026-10-23': 'วันปิยมหาราช',
      '2026-12-05': 'วันชาติ / วันพ่อแห่งชาติ',
      '2026-12-07': 'ชดเชยวันพ่อแห่งชาติ',
      '2026-12-10': 'วันรัฐธรรมนูญ',
      '2026-12-31': 'วันสิ้นปี',
      '2027-01-01': 'วันขึ้นปีใหม่',
      '2027-02-22': 'ชดเชยวันมาฆบูชา',
      '2027-04-06': 'วันจักรี',
      '2027-04-13': 'วันสงกรานต์',
      '2027-04-14': 'วันสงกรานต์',
      '2027-04-15': 'วันสงกรานต์',
      '2027-05-03': 'ชดเชยวันแรงงานแห่งชาติ',
      '2027-05-04': 'วันฉัตรมงคล',
      '2027-05-20': 'วันวิสาขบูชา',
      '2027-06-03': 'วันเฉลิมพระชนมพรรษาพระราชินี',
      '2027-07-19': 'วันอาสาฬหบูชา',
      '2027-07-20': 'วันเข้าพรรษา',
      '2027-08-12': 'วันแม่แห่งชาติ',
      '2027-10-13': 'วันนวมินทรมหาราช',
      '2027-10-25': 'ชดเชยวันปิยมหาราช',
      '2027-12-05': 'วันชาติ / วันพ่อแห่งชาติ',
      '2027-12-06': 'ชดเชยวันพ่อแห่งชาติ',
      '2027-12-10': 'วันรัฐธรรมนูญ',
      '2027-12-31': 'วันสิ้นปี'
    };

    const state = {
      selectedMonth: 'ALL',
      selectedDate: window.BGF_HISTORY.length ? window.BGF_HISTORY[0].date : '',
      watchlistFilter: 'ALL',
      viewMode: window.innerWidth >= 680 ? 'desktop' : 'mobile',
      userLockedMode: false,
      mobileOpenSections: { s1: true, s2: false, s3: false, s4: false, s5: false, s6: false }
    };

    function escapeHtml(str) {
      if (str === null || str === undefined) return '';
      return String(str)
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;')
        .replace(/'/g, '&#39;');
    }

    function applyResponsiveLayout() {
      const root = document.getElementById('dashboardRoot');
      const wrapper = document.getElementById('scaleWrapper');
      const stage = document.getElementById('stageOuter');
      const historyBar = document.getElementById('historyBar');
      const vw = window.innerWidth;

      root.setAttribute('data-view', state.viewMode);
      document.getElementById('btnDesktop').classList.toggle('active', state.viewMode === 'desktop');
      document.getElementById('btnMobile').classList.toggle('active', state.viewMode === 'mobile');
      if (historyBar) {
        historyBar.style.display = state.viewMode === 'mobile' ? 'none' : '';
      }

      // Reset scaling first
      root.classList.remove('scaled-desktop');
      root.style.transform = '';
      wrapper.style.height = '';
      stage.classList.remove('mobile-preview-bg');

      if (state.viewMode === 'desktop' && vw < 680) {
        // Desktop Overview on Mobile: Scale-to-Fit 1200px canvas cleanly with dynamic height
        root.classList.add('scaled-desktop');
        const availW = Math.max(300, stage.clientWidth - 20);
        const scale = Math.min(1, availW / 1200);
        root.style.transform = `scale(${scale.toFixed(4)})`;
        requestAnimationFrame(() => {
          const naturalH = root.scrollHeight;
          wrapper.style.height = `${Math.ceil(naturalH * scale)}px`;
        });
      } else if (state.viewMode === 'mobile' && vw >= 680) {
        // Mobile Preview on Desktop: centered 390px preview
        stage.classList.add('mobile-preview-bg');
      }
    }

    function setViewMode(mode) {
      state.userLockedMode = true;
      state.viewMode = mode;
      applyResponsiveLayout();
    }

    function toggleMobileSection(secKey) {
      state.mobileOpenSections[secKey] = !state.mobileOpenSections[secKey];
      renderDashboard();
    }

    function onMobileMonthChange(val) {
      state.selectedMonth = val;
      populateMonthFilter();
      populateDateSelect();
      renderDashboard();
    }

    function onMobileDateChange(val) {
      state.selectedDate = val;
      populateDateSelect();
      renderDashboard();
    }

    function stepDay(delta) {
      const filtered = getFilteredHistory();
      const idx = filtered.findIndex(x => x.date === state.selectedDate);
      const nextIdx = idx + delta;
      if (idx >= 0 && nextIdx >= 0 && nextIdx < filtered.length) {
        state.selectedDate = filtered[nextIdx].date;
        populateDateSelect();
        renderDashboard();
      }
    }

    function goLatestDate() {
      state.selectedMonth = 'ALL';
      populateMonthFilter();
      if (window.BGF_HISTORY.length) state.selectedDate = window.BGF_HISTORY[0].date;
      populateDateSelect();
      renderDashboard();
    }

    function populateMonthFilter() {
      const monthSelect = document.getElementById('monthFilter');
      const monthsMap = new Map();
      window.BGF_HISTORY.forEach(item => {
        if (!monthsMap.has(item.month_key)) {
          monthsMap.set(item.month_key, { label: item.month_label_th, count: 0 });
        }
        monthsMap.get(item.month_key).count += 1;
      });

      let html = `<option value="ALL">ทั้งหมด (${window.BGF_HISTORY.length} วัน)</option>`;
      Array.from(monthsMap.entries()).forEach(([k, v]) => {
        html += `<option value="${escapeHtml(k)}">${escapeHtml(v.label)} (${v.count})</option>`;
      });
      monthSelect.innerHTML = html;
      monthSelect.value = state.selectedMonth;
    }

    function getFilteredHistory() {
      if (state.selectedMonth === 'ALL') return window.BGF_HISTORY;
      return window.BGF_HISTORY.filter(x => x.month_key === state.selectedMonth);
    }

    function formatShortDateOption(item, latestDate) {
      const iso = item.date || '';
      const parts = iso.split('-');
      let ddmmyyyy = iso;
      let wdLabel = '';
      if (parts.length === 3) {
        ddmmyyyy = `${parts[2]}.${parts[1]}.${parts[0]}`;
        const dObj = new Date(Date.UTC(Number(parts[0]), Number(parts[1]) - 1, Number(parts[2])));
        const wds = ['อา.', 'จ.', 'อ.', 'พ.', 'พฤ.', 'ศ.', 'ส.'];
        wdLabel = ` (${wds[dObj.getUTCDay()]})`;
      }
      const tag = iso === latestDate ? ' [ล่าสุด]' : '';
      let shortStatus = item.short_status_th || '';
      if (!shortStatus) {
        if (item.is_holiday || TH_PUBLIC_HOLIDAYS[iso]) {
          shortStatus = 'วันหยุดนักขัตฤกษ์';
        } else if (item.is_weekend || (item.market_status_overall || '').includes('ตลาดปิด')) {
          shortStatus = 'ตลาดปิด';
        } else {
          shortStatus = 'ตลาดเปิด';
        }
      }
      return `${ddmmyyyy}${wdLabel}${tag} - ${shortStatus}`;
    }

    function populateDateSelect() {
      const dateSelect = document.getElementById('dateSelect');
      const filtered = getFilteredHistory();
      if (!filtered.length) return;
      if (!filtered.some(x => x.date === state.selectedDate)) {
        state.selectedDate = filtered[0].date;
      }
      const latestDate = window.BGF_HISTORY[0]?.date;
      dateSelect.innerHTML = filtered.map(item => {
        const label = formatShortDateOption(item, latestDate);
        return `<option value="${escapeHtml(item.date)}">${escapeHtml(label)}</option>`;
      }).join('');
      dateSelect.value = state.selectedDate;

      const idx = filtered.findIndex(x => x.date === state.selectedDate);
      document.getElementById('btnPrevDay').disabled = idx >= filtered.length - 1;
      document.getElementById('btnNextDay').disabled = idx <= 0;
    }

    function renderLmeSvgChart(series) {
      if (!series || series.length < 2) return '';
      const w = 760, h = 185, padL = 68, padR = 16, padT = 16, padB = 26;
      const plotW = w - padL - padR;
      const plotH = h - padT - padB;
      const allVals = series.flatMap(p => [p.cash, p.m3]);
      const minV = Math.floor(Math.min(...allVals) / 50) * 50 - 30;
      const maxV = Math.ceil(Math.max(...allVals) / 50) * 50 + 30;
      const span = Math.max(1, maxV - minV);
      const xOf = (i) => padL + (i / (series.length - 1)) * plotW;
      const yOf = (v) => padT + (1 - (v - minV) / span) * plotH;

      const cashPath = series.map((p, i) => `${i === 0 ? 'M' : 'L'}${xOf(i).toFixed(1)},${yOf(p.cash).toFixed(1)}`).join(' ');
      const m3Path = series.map((p, i) => `${i === 0 ? 'M' : 'L'}${xOf(i).toFixed(1)},${yOf(p.m3).toFixed(1)}`).join(' ');

      let gridSvg = '';
      for (let t = 0; t <= 4; t++) {
        const val = minV + (span * t) / 4;
        const y = yOf(val).toFixed(1);
        gridSvg += `<line x1="${padL}" y1="${y}" x2="${w - padR}" y2="${y}" stroke="#DDE5EE" stroke-dasharray="3,3" />`;
        gridSvg += `<text x="${padL - 6}" y="${Number(y) + 4}" text-anchor="end" font-size="10" fill="#475569">${Math.round(val).toLocaleString()} USD</text>`;
      }

      const first = series[0], mid = series[Math.floor(series.length / 2)], last = series[series.length - 1];
      const spread = (last.cash - last.m3).toFixed(2);
      return `
        <div style="display:flex; flex-wrap:wrap; gap:12px; font-size:12px; color:#475569; margin-bottom:6px; align-items:center;">
          <span><strong style="color:#003366;">● LME Cash:</strong> ${last.cash.toLocaleString('en-US',{minimumFractionDigits:2})} USD/t</span>
          <span><strong style="color:#16835D;">● LME 3-Month:</strong> ${last.m3.toLocaleString('en-US',{minimumFractionDigits:2})} USD/t</span>
          <span class="pill pill-warn">Backwardation: +${Number(spread).toLocaleString('en-US',{minimumFractionDigits:2})} USD/t</span>
        </div>
        <svg viewBox="0 0 ${w} ${h}" width="100%" height="auto" role="img" aria-label="LME Aluminium 60-Day Curve">
          ${gridSvg}
          <path d="${m3Path}" fill="none" stroke="#16835D" stroke-width="2.2" />
          <path d="${cashPath}" fill="none" stroke="#003366" stroke-width="2.6" />
          <circle cx="${xOf(series.length - 1).toFixed(1)}" cy="${yOf(last.cash).toFixed(1)}" r="4" fill="#003366" />
          <circle cx="${xOf(series.length - 1).toFixed(1)}" cy="${yOf(last.m3).toFixed(1)}" r="4" fill="#16835D" />
          <text x="${padL}" y="${h - 6}" font-size="10.5" fill="#475569">${escapeHtml(first.d)}</text>
          <text x="${(padL + plotW / 2).toFixed(1)}" y="${h - 6}" text-anchor="middle" font-size="10.5" fill="#475569">${escapeHtml(mid.d)}</text>
          <text x="${w - padR}" y="${h - 6}" text-anchor="end" font-size="10.5" fill="#475569">${escapeHtml(last.d)}</text>
        </svg>
      `;
    }

    function renderDashboard() {
      const data = window.BGF_HISTORY.find(x => x.date === state.selectedDate) || window.BGF_HISTORY[0];
      if (!data) return;

      document.getElementById('historyMeta').innerHTML = `
        <span class="pill pill-navy">เก็บประวัติแล้ว ${window.BGF_HISTORY.length}/60 วัน</span>
        <span class="pill pill-slate">Schedule: ${escapeHtml(data.scheduled_slot_bkk || '08:00 ICT (UTC+7)')}</span>
      `;

      // SECTION 1: 4 Market KPIs
      const kpiHtml = (data.kpis || []).map(k => {
        const isUnavail = k.data_quality === 'UNAVAILABLE' || k.price === null;
        const chgPill = k.change_pct === null ? 'pill-slate' : (k.change_pct > 0 ? 'pill-neg' : (k.change_pct < 0 ? 'pill-pos' : 'pill-slate'));
        const badgeText = k.price_badge_th || (k.price_basis === 'Today Open'
          ? `ราคาเปิด ณ ${k.observation_date}`
          : (k.price_basis === 'Prior Close' ? `ราคาปิด ณ ${k.observation_date}` : `ดัชนี ณ ${k.observation_date}`));
        return `
          <article class="kpi-card ${isUnavail ? 'is-unavail' : ''}">
            <div class="kpi-top-meta">
              <span>${escapeHtml(k.category)} • <strong>${escapeHtml(k.company)}</strong></span>
              <span class="kpi-date-tag">${escapeHtml(badgeText)}</span>
            </div>
            <div class="kpi-title" title="${escapeHtml(k.name)}">${escapeHtml(k.name)}</div>
            <div class="kpi-price-row">
              <span class="kpi-number ${isUnavail ? 'unavail-lbl' : ''}">${escapeHtml(k.price_display)}</span>
              <span class="kpi-unit">${escapeHtml(k.unit)}</span>
              <span class="pill ${chgPill}" style="margin-left:auto;">${escapeHtml(k.change_display)}</span>
            </div>
            <div class="kpi-meta-block">
              <div class="kpi-meta-line" title="${escapeHtml(k.price_precision_note)}"><strong>Detail:</strong> ${escapeHtml(k.price_precision_note)}</div>
              <div class="kpi-meta-line" title="${escapeHtml(k.comparison_base)}"><strong>Compare:</strong> ${escapeHtml(k.comparison_base)}</div>
              <div class="kpi-meta-line kpi-type-line" title="${escapeHtml(k.price_type)}"><strong>Type:</strong> ${escapeHtml(k.price_type)}</div>
            </div>
            <div class="kpi-impact-box">${escapeHtml(k.financial_impact)}</div>
            <div class="kpi-foot">
              <span>${escapeHtml(k.source_name)}</span>
              <a href="${escapeHtml(k.source_url)}" target="_blank" rel="noopener noreferrer">Source URL ↗</a>
            </div>
          </article>
        `;
      }).join('');

      const suppHtml = (data.soda_ash_supplementary_context || []).map(s => `
        <div class="supp-card">
          <div style="font-weight:800; color:#0B3B68;">${escapeHtml(s.label)}</div>
          <div style="font-size:13.5px; font-weight:800; color:#0F2942; margin:3px 0;">${escapeHtml(s.price)}</div>
          <div style="color:#475569;">${escapeHtml(s.usd_note)}</div>
          <div style="margin-top:5px; display:flex; justify-content:space-between; font-size:11.5px; color:#475569;">
            <span>งวด: ${escapeHtml(s.period)}</span>
            <a href="${escapeHtml(s.source_url)}" target="_blank" rel="noopener noreferrer">${escapeHtml(s.source_name)} ↗</a>
          </div>
        </div>
      `).join('');

      // SECTION 2: 3 Compact Decision Cards
      const decisionHtml = (data.decision_cards || []).map(d => {
        const badgeCls = d.priority_status === 'ต้องตัดสินใจ' ? 'pill-neg' : (d.priority_status === 'ควรพิจารณา' ? 'pill-warn' : 'pill-navy');
        return `
          <article class="decision-card">
            <div style="display:flex; justify-content:space-between; align-items:center; gap:6px;">
              <span class="pill ${badgeCls}">${escapeHtml(d.priority_status)}</span>
              <span class="pill pill-slate">${escapeHtml(d.company)}</span>
            </div>
            <div class="decision-headline">${escapeHtml(d.headline)}</div>
            <p class="decision-bullet"><strong>• Financial Impact:</strong> ${escapeHtml(d.financial_impact)}</p>
            <p class="decision-bullet"><strong>• Recommended Action:</strong> ${escapeHtml(d.recommended_action)}</p>
            <div class="decision-foot">
              <div><strong>Owner:</strong> ${escapeHtml(d.owner)}</div>
              <div><strong>Review Point:</strong> ${escapeHtml(d.review_point)}</div>
            </div>
          </article>
        `;
      }).join('');

      // SECTION 3: 3 Numbered Insight Rows
      const execRowsHtml = (data.executive_3rows || []).map(r => `
        <div class="exec-row">
          <div class="num-circle">${escapeHtml(r.num)}</div>
          <div style="min-width:0;">
            <div class="exec-row-title">${escapeHtml(r.label)}</div>
            <div class="exec-row-head">${escapeHtml(r.headline)}</div>
            <p class="exec-row-detail">${escapeHtml(r.detail)}</p>
          </div>
        </div>
      `).join('');

      // SECTION 4A: Top Alerts (max 3) & SECTION 4B: Watchlist (remaining)
      const allNews = data.news || [];
      const topAlerts = allNews.filter(n => n.tier === 'top_alert').slice(0, 3);
      const watchlistRaw = allNews.filter(n => n.tier !== 'top_alert');
      const watchlist = watchlistRaw.filter(n => state.watchlistFilter === 'ALL' || n.company === state.watchlistFilter);

      const renderNewsCard = (n) => `
        <article class="news-card">
          <div style="display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:6px;">
            <span class="pill pill-navy">${escapeHtml(n.company)}</span>
            <span style="font-size:11.5px; color:#475569;">${escapeHtml(n.published_at)}</span>
          </div>
          <div class="news-headline">${escapeHtml(n.title)}</div>
          <div class="news-line"><strong>WHAT:</strong> ${escapeHtml(n.what)}</div>
          <div class="news-line"><strong>IMPACT (SO WHAT / FINANCIAL):</strong> ${escapeHtml(n.so_what)} — ${escapeHtml(n.financial)}</div>
          <div class="news-line"><strong>ACTION / OWNER:</strong> ${escapeHtml(n.now_what)} (${escapeHtml(n.owner || 'ผู้บริหาร')})</div>
          <div style="display:flex; justify-content:space-between; align-items:center; font-size:11.5px; color:#475569; margin-top:auto; padding-top:4px;">
            <span>${escapeHtml(n.source_name)}</span>
            <a href="${escapeHtml(n.source_url)}" target="_blank" rel="noopener noreferrer">Source URL ↗</a>
          </div>
        </article>
      `;

      // SECTION 5: Impact Analysis Table & Mobile Cards
      const matrixDesktopRows = (data.impact_matrix || []).map(row => `
        <tr>
          <td><strong>${escapeHtml(row.driver)}</strong></td>
          <td><div><strong>${escapeHtml(row.kbi_indicator)}</strong></div><div>${escapeHtml(row.kbi_text)}</div></td>
          <td><div><strong>${escapeHtml(row.bga_indicator)}</strong></div><div>${escapeHtml(row.bga_text)}</div></td>
          <td>${escapeHtml(row.management_implication)}</td>
        </tr>
      `).join('');

      const matrixMobileCards = (data.impact_matrix || []).map(row => `
        <div class="mobile-card-item">
          <div style="font-weight:800; color:#0B3B68;">${escapeHtml(row.driver)}</div>
          <div><strong>KBI Impact (${escapeHtml(row.kbi_indicator)}):</strong> ${escapeHtml(row.kbi_text)}</div>
          <div><strong>BGA Impact (${escapeHtml(row.bga_indicator)}):</strong> ${escapeHtml(row.bga_text)}</div>
          <div style="background:#EFF6FF; padding:6px 8px; border-radius:6px;"><strong>Management Implication:</strong> ${escapeHtml(row.management_implication)}</div>
        </div>
      `).join('');

      // SECTION 6: Management Action Plan Table & Mobile Cards
      const actionDesktopRows = (data.management_actions || []).slice(0, 5).map(a => `
        <tr>
          <td><span class="pill ${a.priority === 'P1' ? 'pill-neg' : (a.priority === 'P2' ? 'pill-warn' : 'pill-navy')}">${escapeHtml(a.priority)}</span></td>
          <td><strong>${escapeHtml(a.business)}</strong></td>
          <td>${escapeHtml(a.action)}</td>
          <td><strong>${escapeHtml(a.owner)}</strong></td>
          <td>${escapeHtml(a.timeline)}</td>
          <td>${escapeHtml(a.trigger)}</td>
        </tr>
      `).join('');

      const actionMobileCards = (data.management_actions || []).slice(0, 5).map(a => `
        <div class="mobile-card-item">
          <div style="display:flex; justify-content:space-between; align-items:center; gap:6px;">
            <span class="pill ${a.priority === 'P1' ? 'pill-neg' : (a.priority === 'P2' ? 'pill-warn' : 'pill-navy')}">${escapeHtml(a.priority)}</span>
            <span class="pill pill-slate">${escapeHtml(a.business)}</span>
          </div>
          <div style="font-weight:700; color:#14263D;">${escapeHtml(a.action)}</div>
          <div><strong>Owner:</strong> ${escapeHtml(a.owner)} | <strong>Timeline:</strong> ${escapeHtml(a.timeline)}</div>
          <div style="color:#475569;"><strong>Trigger:</strong> ${escapeHtml(a.trigger)}</div>
        </div>
      `).join('');

      const wrapAccSection = (secKey, title, subDesktop, badgeMobile, bodyHtml, isPlain = false) => {
        const isOpen = !!state.mobileOpenSections[secKey];
        const cls = `${isPlain ? 'acc-section plain-sec' : 'card acc-section'} ${isOpen ? '' : 'is-collapsed'}`;
        return `
          <section class="${cls}" data-sec="${secKey}">
            <button type="button" class="acc-header" onclick="toggleMobileSection('${secKey}')" aria-expanded="${isOpen ? 'true' : 'false'}">
              <h2 class="section-title">${title}</h2>
              <div class="acc-header-right">
                <span class="section-sub desktop-only-sub">${subDesktop}</span>
                <span class="pill pill-navy acc-count-pill mobile-only-badge">${badgeMobile}</span>
                <span class="acc-chevron">${isOpen ? '▲' : '▼'}</span>
              </div>
            </button>
            <div class="acc-body">${bodyHtml}</div>
          </section>
        `;
      };

      const sec1Body = `
        <div class="grid-4">${kpiHtml}</div>
        <div class="supp-box" style="margin-top:12px;">
          <div class="section-head" style="margin-bottom:4px;">
            <strong style="font-size:13px; color:#0B3B68;">ข้อมูลอ้างอิงภูมิภาคเพิ่มเติม (Soda Ash Supplementary Context)</strong>
            <span class="pill pill-warn">ไม่ใช้แทน Benchmark หลัก FOB China USD/MT</span>
          </div>
          <div class="supp-grid">${suppHtml}</div>
        </div>
        <div style="margin-top:12px; padding-top:10px; border-top:1px solid #DDE5EE;">
          <div style="font-size:13px; font-weight:700; color:#0B3B68; margin-bottom:4px;">แนวโน้ม LME Aluminium 60 วัน (Cash-Settlement vs 3-Month — Westmetall)</div>
          ${renderLmeSvgChart(data.lme_60d_series)}
        </div>
      `;

      const sec4Body = `
        <div style="font-size:13px; font-weight:800; color:#0B3B68; margin-bottom:8px;">A. TOP ALERTS</div>
        <div class="grid-3" style="margin-bottom:14px;">${topAlerts.map(renderNewsCard).join('')}</div>
        <div class="section-head" style="border-top:1px solid #DDE5EE; padding-top:12px;">
          <div style="font-size:13px; font-weight:800; color:#0B3B68;">B. WATCHLIST (${watchlist.length} ข่าว)</div>
          <div class="chip-row">
            ${['ALL', 'KBI', 'BGA'].map(f => `
              <button type="button" class="chip-btn ${state.watchlistFilter === f ? 'active' : ''}" onclick="setWatchlistFilter('${f}')">
                ${f === 'ALL' ? 'ทั้งหมด' : f}
              </button>
            `).join('')}
          </div>
        </div>
        <div class="grid-2">${watchlist.map(renderNewsCard).join('')}</div>
      `;

      const sec5Body = `
        <div class="desktop-only-table table-wrap">
          <table class="exec-table">
            <thead>
              <tr>
                <th style="width:22%;">Market Driver</th>
                <th style="width:26%;">KBI (Float Glass)</th>
                <th style="width:26%;">BGA (Aluminium)</th>
                <th style="width:26%;">Management Implication</th>
              </tr>
            </thead>
            <tbody>${matrixDesktopRows}</tbody>
          </table>
        </div>
        <div class="mobile-only-cards">${matrixMobileCards}</div>
      `;

      const sec6Body = `
        <div class="desktop-only-table table-wrap">
          <table class="exec-table">
            <thead>
              <tr>
                <th style="width:8%;">Priority</th>
                <th style="width:12%;">Business</th>
                <th style="width:34%;">Recommended Action</th>
                <th style="width:12%;">Owner</th>
                <th style="width:14%;">Timeline</th>
                <th style="width:20%;">Trigger</th>
              </tr>
            </thead>
            <tbody>${actionDesktopRows}</tbody>
          </table>
        </div>
        <div class="mobile-only-cards">${actionMobileCards}</div>
      `;

      const decCount = (data.decision_cards || []).length;
      const rowCount = (data.executive_3rows || []).length;
      const newsCount = allNews.length;
      const driverCount = (data.impact_matrix || []).length;
      const actCount = Math.min(5, (data.management_actions || []).length);

      const mMonthsMap = new Map();
      window.BGF_HISTORY.forEach(item => {
        if (!mMonthsMap.has(item.month_key)) {
          mMonthsMap.set(item.month_key, { label: item.month_label_th, count: 0 });
        }
        mMonthsMap.get(item.month_key).count += 1;
      });
      const mMonthOpts = `<option value="ALL" ${state.selectedMonth === 'ALL' ? 'selected' : ''}>ทุกเดือน (${window.BGF_HISTORY.length} วัน)</option>` +
        Array.from(mMonthsMap.entries()).map(([k, v]) =>
          `<option value="${escapeHtml(k)}" ${state.selectedMonth === k ? 'selected' : ''}>${escapeHtml(v.label)} (${v.count})</option>`
        ).join('');
      const mFiltered = getFilteredHistory();
      const mLatestDate = window.BGF_HISTORY[0]?.date;
      const mDateOpts = mFiltered.map(item => {
        const lbl = formatShortDateOption(item, mLatestDate);
        return `<option value="${escapeHtml(item.date)}" ${item.date === state.selectedDate ? 'selected' : ''}>${escapeHtml(lbl)}</option>`;
      }).join('');
      const mIdx = mFiltered.findIndex(x => x.date === state.selectedDate);
      const mPrevDis = mIdx >= mFiltered.length - 1 ? 'disabled' : '';
      const mNextDis = mIdx <= 0 ? 'disabled' : '';

      document.getElementById('dashboardRoot').innerHTML = `
        <section class="mobile-date-card" aria-label="Mobile Date Selector">
          <div class="mobile-date-row">
            <select class="select-box" aria-label="เลือกเดือน (Mobile)" onchange="onMobileMonthChange(this.value)">${mMonthOpts}</select>
            <button type="button" class="btn-step" onclick="goLatestDate()">ล่าสุด</button>
          </div>
          <div class="mobile-date-row">
            <button type="button" class="btn-step" onclick="stepDay(1)" ${mPrevDis} title="วันก่อนหน้า">◀</button>
            <select class="select-box" aria-label="เลือกวันที่ (Mobile)" onchange="onMobileDateChange(this.value)">${mDateOpts}</select>
            <button type="button" class="btn-step" onclick="stepDay(-1)" ${mNextDis} title="วันถัดไป">▶</button>
          </div>
        </section>

        <section class="meta-strip" aria-label="Report Metadata">
          <div class="meta-box">
            <div class="meta-k">Report Time (Asia/Bangkok)</div>
            <div class="meta-v">${escapeHtml(data.report_time_bkk)}</div>
          </div>
          <div class="meta-box">
            <div class="meta-k">Market Status</div>
            <div class="meta-v">${escapeHtml(data.market_status_overall)}</div>
          </div>
        </section>

        ${wrapAccSection('s1', 'SECTION 1 — ภาพรวมราคาตลาด (4 Market KPIs)', `รายงานวันที่ ${escapeHtml(data.display_date_th)}`, '4 KPIs + กราฟ', sec1Body, false)}
        ${wrapAccSection('s2', 'SECTION 2 — ประเด็นที่ผู้บริหารต้องพิจารณา', '3 Compact Decision Cards', `${decCount} ประเด็น`, `<div class="grid-3">${decisionHtml}</div>`, true)}
        ${wrapAccSection('s3', 'SECTION 3 — สรุปสำหรับผู้บริหาร', 'อ่านจบภายใน 10–15 วินาที', `${rowCount} ข้อ`, `<div class="exec-rows">${execRowsHtml}</div>`, true)}
        ${wrapAccSection('s4', 'SECTION 4 — ประเด็นสำคัญที่ต้องติดตาม', 'A. Top Alerts (สูงสุด 3) • B. Watchlist', `${newsCount} ข่าว`, sec4Body, false)}
        ${wrapAccSection('s5', 'SECTION 5 — ตารางวิเคราะห์ผลกระทบ (KBI vs BGA)', 'วิเคราะห์แยกตาม Market Driver พร้อมตัวชี้วัดและคำอธิบาย', `${driverCount} ปัจจัย`, sec5Body, false)}
        ${wrapAccSection('s6', 'SECTION 6 — แผนดำเนินงาน (สูงสุด 5 รายการ)', 'จัดลำดับ P1 → P2 → P3 • ไม่มีแถวว่าง', `${actCount} แผน`, sec6Body, false)}

        <footer class="footer-note">
          BGF DAILY BRIEF V5 • Self-Contained HTML5 (SharePoint / OneDrive / Microsoft Edge Mobile) • ประวัติย้อนหลังสูงสุด 60 วัน
        </footer>
      `;

      applyResponsiveLayout();
    }

    function setWatchlistFilter(company) {
      state.watchlistFilter = company;
      renderDashboard();
    }

    function init() {
      populateMonthFilter();
      populateDateSelect();
      renderDashboard();

      document.getElementById('monthFilter').addEventListener('change', (e) => {
        state.selectedMonth = e.target.value;
        populateDateSelect();
        renderDashboard();
      });
      document.getElementById('dateSelect').addEventListener('change', (e) => {
        state.selectedDate = e.target.value;
        populateDateSelect();
        renderDashboard();
      });
      document.getElementById('btnPrevDay').addEventListener('click', () => {
        const filtered = getFilteredHistory();
        const idx = filtered.findIndex(x => x.date === state.selectedDate);
        if (idx >= 0 && idx < filtered.length - 1) {
          state.selectedDate = filtered[idx + 1].date;
          populateDateSelect();
          renderDashboard();
        }
      });
      document.getElementById('btnNextDay').addEventListener('click', () => {
        const filtered = getFilteredHistory();
        const idx = filtered.findIndex(x => x.date === state.selectedDate);
        if (idx > 0) {
          state.selectedDate = filtered[idx - 1].date;
          populateDateSelect();
          renderDashboard();
        }
      });
      document.getElementById('btnLatest').addEventListener('click', () => {
        state.selectedMonth = 'ALL';
        populateMonthFilter();
        if (window.BGF_HISTORY.length) state.selectedDate = window.BGF_HISTORY[0].date;
        populateDateSelect();
        renderDashboard();
      });
      window.addEventListener('resize', () => {
        if (!state.userLockedMode) {
          state.viewMode = window.innerWidth >= 680 ? 'desktop' : 'mobile';
        }
        applyResponsiveLayout();
      });
    }

    init();
  </script>
</body>
</html>
"""


def load_snapshots(retention_days: int = 60, prune_old: bool = False) -> list[dict[str, Any]]:
    HISTORY_DIR.mkdir(parents=True, exist_ok=True)
    files = sorted(HISTORY_DIR.glob("*.json"), reverse=True)
    kept_files = files[:retention_days]
    if prune_old and len(files) > retention_days:
        for old_file in files[retention_days:]:
            old_file.unlink()
    return [json.loads(f.read_text(encoding="utf-8")) for f in kept_files]


def update_manifest(snapshots: list[dict[str, Any]], retention_days: int = 60) -> None:
    entries = [
        {
            "date": s["date"],
            "display_date_th": s["display_date_th"],
            "month_key": s["month_key"],
            "month_label_th": s["month_label_th"],
            "market_status": s["market_status_overall"],
            "file": f"history/{s['date']}.json",
        }
        for s in snapshots
    ]
    manifest = {
        "retention_days": retention_days,
        "timezone": "Asia/Bangkok",
        "schedule_cron_bkk": "0 8 * * *",
        "total_days": len(entries),
        "latest_date": entries[0]["date"] if entries else None,
        "entries": entries,
    }
    MANIFEST_PATH.write_text(json.dumps(manifest, ensure_ascii=False, indent=2), encoding="utf-8")


def main() -> None:
    parser = argparse.ArgumentParser(description="Build self-contained 60-day BGF HTML dashboard.")
    parser.add_argument("--retention", type=int, default=60, help="Max rolling days to bundle.")
    parser.add_argument("--prune", action="store_true", help="Delete snapshots older than retention days.")
    args = parser.parse_args()

    snapshots = load_snapshots(retention_days=args.retention, prune_old=args.prune)
    update_manifest(snapshots, retention_days=args.retention)

    DIST_DIR.mkdir(parents=True, exist_ok=True)
    history_json = json.dumps(snapshots, ensure_ascii=False, separators=(",", ":"))
    html_out = HTML_TEMPLATE.replace("__BGF_HISTORY_JSON__", history_json)
    OUTPUT_HTML.write_text(html_out, encoding="utf-8")
    (DIST_DIR / "index.html").write_text(html_out, encoding="utf-8")
    (DIST_DIR / "BGF_DAILY_BRIEF.aspx").write_text(html_out, encoding="utf-8")
    print(f"[OK] Built {OUTPUT_HTML}, index.html & BGF_DAILY_BRIEF.aspx ({len(snapshots)} days bundled, {len(html_out):,} bytes)")


if __name__ == "__main__":
    main()
