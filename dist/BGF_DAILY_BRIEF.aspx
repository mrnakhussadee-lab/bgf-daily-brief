<!DOCTYPE html>
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
    window.BGF_HISTORY = [{"date":"2026-11-23","display_date_th":"23 พ.ย. 2026 (จ.)","month_key":"2026-11","month_label_th":"พฤศจิกายน 2026","report_time_bkk":"2026-11-23 10:14 ICT (UTC+7)","scheduled_slot_bkk":"08:00 ICT (UTC+7)","is_weekend":false,"is_holiday":false,"holiday_name_th":"","short_status_th":"ตลาดเปิด","market_status_overall":"วันทำการ • อัปเดตรอบเช้า 08:00 ICT","price_rule_note":"","kpis":[{"id":"usd_thb","name":"USD/THB","category":"FX","unit":"THB/USD","company":"ALL","price":33.95,"price_display":"33.95","price_badge_th":"ราคาปิด ณ 20 พ.ย. 2026","price_precision_note":"BOT 33.953 / TE Spot 33.9510","price_basis":"Prior Close","price_type":"Weighted-avg Interbank / Spot Close","change_pct":-0.06,"change_display":"-0.06% DoD","comparison_base":"เทียบ 19 พ.ย. (33.9700) | +1.10% MoM","observation_date":"2026-11-20","market_status":"ตลาดปิด","data_quality":"VERIFIED LATEST","financial_impact":"บาทอ่อนค่าใกล้ 34.00 THB/USD (+4.79% YoY) กดดันต้นทุนนำเข้าสกุล USD ของ KBI/BGA แต่ช่วยหนุนรายได้ส่งออก (รอข้อมูลภายใน: Net FX Exposure)","source_name":"BOT & Trading Economics","source_url":"https://www.bot.or.th/en/statistics/exchange-rate.html"},{"id":"brent_oil","name":"Brent Oil","category":"Energy","unit":"USD/bbl","company":"ALL","price":92.57,"price_display":"92.57","price_badge_th":"ราคาปิด ณ 20 พ.ย. 2026","price_precision_note":"Previous Close: 91.98 USD/bbl","price_basis":"Prior Close","price_type":"Front-Month Futures/CFD Close","change_pct":0.64,"change_display":"+0.64% DoD","comparison_base":"เทียบ 19 พ.ย. (91.98) | -14.93% MoM","observation_date":"2026-11-20","market_status":"ตลาดปิด","data_quality":"VERIFIED LATEST","financial_impact":"ลดลง 3 สัปดาห์ติด (-14.93% MoM) จากคาดการณ์ซัพพลายล้นตลาด ช่วยบรรเทาต้นทุนเชื้อเพลิงเตาหลอม (KBI) และค่าขนส่ง (KBI/BGA) (รอข้อมูลภายใน)","source_name":"Trading Economics","source_url":"https://tradingeconomics.com/commodity/brent-crude-oil"},{"id":"lme_aluminium","name":"LME Aluminium","category":"Raw Material","unit":"USD/t","company":"BGA","price":3184.5,"price_display":"3,184.50","price_badge_th":"ราคาปิด ณ 20 พ.ย. 2026","price_precision_note":"3M: 2,831.50 USD/t | Stock: 223,525 t","price_basis":"Prior Close","price_type":"LME Official Cash-Settlement","change_pct":2.56,"change_display":"+2.56% DoD","comparison_base":"เทียบ Cash 2026-11-19 (3,105.00 USD/t)","observation_date":"2026-11-20","market_status":"ตลาดปิด (LME เปิดช่วงบ่ายเวลาไทย ใช้ราคา Settlement ล่าสุด)","data_quality":"VERIFIED LATEST","financial_impact":"Cash สูงกว่า 3-Month +353.00 USD/t (Backwardation) และสต็อกต่ำ 223,525 ตัน กดดันต้นทุนและ Working Capital ของ BGA หากซื้อ Spot (รอข้อมูลภายใน)","source_name":"Westmetall (LME)","source_url":"https://www.westmetall.com/en/markdaten.php?action=table&field=LME_Al_cash"},{"id":"soda_ash","name":"Soda Ash (FOB China)","category":"Raw Material","unit":"USD/MT","company":"KBI","price":156.23,"price_display":"156.23","price_badge_th":"ดัชนี ณ ต.ค. 2026","price_precision_note":"General Market Proxy (Dense ล่าสุด August 2026: 161.00 USD/MT)","price_basis":"Monthly Benchmark","price_type":"FOB China Monthly Assessment","change_pct":0.0,"change_display":"0.00% MoM","comparison_base":"เทียบ September 2026 (156.23 USD/MT)","observation_date":"October 2026","market_status":"LATEST PUBLISHED MONTHLY BENCHMARK","data_quality":"VERIFIED LATEST","financial_impact":"FOB China (General Proxy) ทรงตัวระดับต่ำที่ 156.23 USD/MT เป็นสัญญาณทิศทางต้นทุนขาลง แต่ไม่ใช่ราคา Landed Cost จริงของ KBI (รอข้อมูลภายใน)","source_name":"Procurement Resource","source_url":"https://www.procurementresource.com/resource-center/soda-ash-price-trends"}],"soda_ash_supplementary_context":[{"label":"Soda Ash (Dense) — FOB China (งวดก่อนหน้า)","price":"161.00 USD/MT (-5.29% MoM จาก Jul 2026: 170.00 USD/MT)","usd_note":"เกรด Dense บนฐาน FOB China ล่าสุดเดือน ส.ค. 2026 (เก่ากว่า General ต.ค. 2026 จึงใช้ General เป็น Proxy หลัก)","period":"August 2026","source_name":"Procurement Resource (Dense)","source_url":"https://www.procurementresource.com/resource-center/soda-ash-dense-price-trends"},{"label":"East China Domestic Reference (Dense / Light)","price":"RMB 1,150/MT (Dense) | RMB 1,000/MT (Light)","usd_note":"อ้างอิงในประเทศจีน (~172 USD / ~149 USD ที่ RMB 6.7/USD — ไม่ใช่ราคาส่งออก FOB)","period":"5 พ.ย. 2026","source_name":"Jinan ZZ / Chcachem","source_url":"https://www.chcachem.com/news/2026-11-06-china-soda-ash-market-update"},{"label":"APAC Regional Benchmark (CFR Tokyo, Light)","price":"212.33 USD/MT (-3.78% QoQ)","usd_note":"ราคาเฉลี่ย Q3 2026 (CFR Tokyo — ภูมิภาคอื่น ใช้เพื่อบริบทเท่านั้น)","period":"Q3 2026 (ก.ย. 2026)","source_name":"ChemAnalyst","source_url":"https://www.chemanalyst.com/Pricing-data/soda-ash-76"},{"label":"ASEAN Reference (Indonesia)","price":"259.00 USD/MT","usd_note":"ราคาตลาดอินโดนีเซีย เดือน ก.ย. 2026 (บริบทภูมิภาคเท่านั้น)","period":"ก.ย. 2026","source_name":"IMARC Group","source_url":"https://www.imarcgroup.com/soda-ash-pricing-report"}],"decision_cards":[{"priority_status":"ต้องตัดสินใจ","priority_level":"critical","company":"BGA","headline":"LME Aluminium Cash พุ่ง 3,184.50 USD/t (+2.56%) ขณะ Backwardation ถ่าง +353.00 USD/t","financial_impact":"ซื้อ Spot แพงกว่าสัญญา 3-Month (2,831.50 USD/t) ถึง 353.00 USD/t กดดัน Gross Margin และดึง Working Capital เพิ่มขึ้นทันที","recommended_action":"ทบทวนสัดส่วนสัญญาซื้อ Spot เทียบ 3M Forward และตรวจสอบ Lead Time/สต็อกคงเหลือ (รอข้อมูลภายในบริษัท)","owner":"CFO & COO","review_point":"ทบทวนเมื่อ LME 3M–Cash Spread > 250 USD/t หรือสต็อก LME ต่ำกว่า 220,000 ตัน"},{"priority_status":"ควรพิจารณา","priority_level":"warning","company":"ALL (KBI & BGA)","headline":"USD/THB จ่อแนวต้าน 34.00 THB/USD (33.95) ขณะภาคก่อสร้างเอกชนไทย Q3 หด -0.5%","financial_impact":"ต้นทุนนำเข้าสกุล USD สูงขึ้นราว +1.10% MoM ในภาวะที่ตลาดอสังหาฯ ในประเทศชะลอตัว ทำให้ส่งผ่านราคาขายได้จำกัด","recommended_action":"ประเมิน Net USD Exposure ของ KBI/BGA และเตรียมกรอบบริหารความเสี่ยง FX ก่อนประชุม Fed ธ.ค. (รอข้อมูลภายในบริษัท)","owner":"CFO","review_point":"ทบทวนเมื่อ USD/THB ปิดเหนือ 34.00 THB/USD หรือก่อนประชุม FOMC ธ.ค."},{"priority_status":"เฝ้าระวัง","priority_level":"watch","company":"BGA","headline":"อินเดียเปิดไต่สวน Anti-Dumping (AD) อะลูมิเนียม Extrusion จากไทยและ 3 ประเทศ","financial_impact":"เสี่ยงกระทบยอดส่งออกไปอินเดีย (หากมี) และเสี่ยงเกิดสินค้าจีน/เวียดนามไหลย้อนเข้ามาตัดราคาในตลาดไทย/อาเซียน","recommended_action":"ตรวจสอบสัดส่วนรายได้ส่งออกอินเดีย พิกัดสินค้า และเตรียมข้อมูลต้นทุนการผลิตไว้ล่วงหน้า (รอข้อมูลภายในบริษัท)","owner":"CEO & ฝ่ายขาย","review_point":"ติดตามประกาศเบื้องต้นของ DGTR อินเดีย และการเปลี่ยนแปลงราคาเสนอขายในอาเซียน"}],"executive_3rows":[{"num":1,"label":"SITUATION — สถานการณ์สำคัญ","headline":"ตลาดปิดวันเสาร์ อ้างอิงราคาปิดศุกร์ 20 พ.ย. 2026: บาทจ่อ 34.00, LME Cash พุ่ง +2.56%, Brent อ่อนลง -14.93% MoM","detail":"ดอลลาร์แข็งค่าสูงสุดรอบ 19 เดือน (โอกาส Fed ขึ้นดอกเบี้ย ธ.ค. 96%) กดดัน USD/THB ที่ 33.95 และทองคำร่วง 2.8% ขณะที่ LME Aluminium Cash ดีดตัวสู่ 3,184.50 USD/t สวนทาง Brent ที่ลดลงต่อเนื่อง 3 สัปดาห์เหลือ 92.57 USD/bbl และ Soda Ash FOB China (General Proxy ต.ค. 2026) ทรงตัวที่ 156.23 USD/MT"},{"num":2,"label":"BUSINESS IMPACT — ผลกระทบต่อ KBI / BGA","headline":"BGA เผชิญแรงกดดันต้นทุน Spot + คดี AD อินเดีย สูงกว่า KBI ที่ได้อานิสงส์ Brent และ Soda Ash ทรงตัวต่ำ","detail":"ทั้งสองบริษัทรับแรงต้านจากอุปสงค์อสังหาฯ ไทย Q3 (-0.6% YoY) และบาทอ่อน 33.95 แต่ BGA มีความเสี่ยง Margin/Working Capital เพิ่มจาก LME Backwardation +353.00 USD/t และ AD อินเดีย ส่วน KBI ได้แรงหนุนจาก Brent อ่อนตัวและ Soda Ash FOB China 156.23 USD/MT (ผลสุทธิรอข้อมูลสัญญาและ Hedging ภายในบริษัท)"},{"num":3,"label":"MANAGEMENT RESPONSE — สิ่งที่ผู้บริหารควรทำ","headline":"เร่งตรวจสอบ Exposure จริงก่อนตัดสินใจ: คุม LME 3M vs Spot, เช็ก Net FX และจับจองระวางเรือ ธ.ค.","detail":"CFO & COO ตรวจสอบสต็อก-สูตรราคา LME ของ BGA และ Net USD Exposure ของกลุ่มก่อนตัดสินใจล็อกราคาใดๆ; ฝ่ายขาย BGA ตรวจยอดส่งออกอินเดีย; ฝ่ายโลจิสติกส์จองระวางเรือก่อนสายเรือเก็บ PSS ยุโรป 1,000–1,600 USD/FEU ในเดือน ธ.ค."}],"lme_60d_series":[{"d":"2026-09-21","cash":3262.5,"m3":3273.0,"stock":242200},{"d":"2026-09-22","cash":3242.0,"m3":3264.0,"stock":242125},{"d":"2026-09-23","cash":3240.0,"m3":3260.0,"stock":241375},{"d":"2026-09-24","cash":3228.0,"m3":3252.5,"stock":241375},{"d":"2026-09-25","cash":3254.0,"m3":3267.0,"stock":241375},{"d":"2026-09-28","cash":3248.5,"m3":3252.0,"stock":241375},{"d":"2026-09-29","cash":3225.5,"m3":3232.0,"stock":241375},{"d":"2026-09-30","cash":3204.0,"m3":3210.0,"stock":241375},{"d":"2026-10-01","cash":3120.0,"m3":3131.0,"stock":240625},{"d":"2026-10-02","cash":3109.5,"m3":3122.0,"stock":240375},{"d":"2026-10-05","cash":3107.0,"m3":3118.0,"stock":240375},{"d":"2026-10-06","cash":3134.5,"m3":3148.5,"stock":238875},{"d":"2026-10-07","cash":3102.5,"m3":3114.0,"stock":238875},{"d":"2026-10-08","cash":3060.5,"m3":3069.0,"stock":238875},{"d":"2026-10-09","cash":3055.5,"m3":3070.0,"stock":238875},{"d":"2026-10-12","cash":3055.0,"m3":3060.0,"stock":238625},{"d":"2026-10-13","cash":3036.0,"m3":3037.0,"stock":238625},{"d":"2026-10-14","cash":3010.0,"m3":3013.5,"stock":238375},{"d":"2026-10-15","cash":2999.0,"m3":2994.5,"stock":238125},{"d":"2026-10-16","cash":3014.0,"m3":3012.0,"stock":237875},{"d":"2026-10-19","cash":3019.0,"m3":3012.0,"stock":236375},{"d":"2026-10-20","cash":3003.5,"m3":2997.0,"stock":236225},{"d":"2026-10-21","cash":3031.0,"m3":3024.5,"stock":236125},{"d":"2026-10-22","cash":3033.0,"m3":3008.0,"stock":236025},{"d":"2026-10-23","cash":3043.0,"m3":3018.0,"stock":235800},{"d":"2026-10-26","cash":3047.5,"m3":3027.0,"stock":234050},{"d":"2026-10-27","cash":3078.0,"m3":3064.0,"stock":232100},{"d":"2026-10-28","cash":3101.0,"m3":3084.0,"stock":231900},{"d":"2026-10-29","cash":3071.0,"m3":3064.0,"stock":231675},{"d":"2026-10-30","cash":3114.0,"m3":3080.0,"stock":231200},{"d":"2026-11-02","cash":3095.0,"m3":3060.0,"stock":230775},{"d":"2026-11-03","cash":3082.0,"m3":3042.0,"stock":229475},{"d":"2026-11-04","cash":3135.0,"m3":3074.0,"stock":228750},{"d":"2026-11-05","cash":3160.0,"m3":3097.5,"stock":228475},{"d":"2026-11-06","cash":3117.0,"m3":3050.0,"stock":227600},{"d":"2026-11-09","cash":3147.0,"m3":3059.5,"stock":226975},{"d":"2026-11-10","cash":3137.0,"m3":3027.0,"stock":226850},{"d":"2026-11-11","cash":3223.5,"m3":3064.0,"stock":226725},{"d":"2026-11-12","cash":3155.5,"m3":3032.0,"stock":226350},{"d":"2026-11-13","cash":3150.5,"m3":3018.0,"stock":224150},{"d":"2026-11-16","cash":3332.0,"m3":3020.0,"stock":221900},{"d":"2026-11-17","cash":3060.5,"m3":2940.0,"stock":220350},{"d":"2026-11-18","cash":3095.0,"m3":2865.0,"stock":226150},{"d":"2026-11-19","cash":3105.0,"m3":2845.0,"stock":224425},{"d":"2026-11-20","cash":3184.5,"m3":2831.5,"stock":223525}],"news":[{"id":"auto-2026-11-23-1","tier":"watchlist","title":"Thai baht/US dollar weaker on Monday - TradingView","priority_tier":"FX, Energy, Raw Materials, Industry Demand","company":"ALL","published_at":"Mon, 23 Nov 2026 02:20:00 GMT","what":"หัวข้อข่าวล่าสุดจาก Google News — Thailand Baht / Economy: Thai baht/US dollar weaker on Monday - TradingView","so_what":"ติดตามผลกระทบต่อ KBI และ BGA ตามตัวขับเคลื่อนต้นทุน/อุปสงค์ (Automated Feed)","financial":"ประเมินผลกระทบต่อ Margin และ Cash Flow เทียบกับราคา KPI ล่าสุด (รอข้อมูลภายในบริษัท)","now_what":"เปิดลิงก์ต้นทางเพื่อตรวจสอบรายละเอียดเพิ่มเติมก่อนตัดสินใจเชิงพาณิชย์","owner":"ผู้บริหาร / ฝ่ายจัดซื้อ","source_name":"Google News — Thailand Baht / Economy","source_url":"https://news.google.com/rss/articles/CBMiqgFBVV95cUxOVjN2aXlSU0tZTGFud2xrV1ZIcDMzVzFUbWpiS1JhNjRBQm9JVXRjd3BSTEdHUmFOdkdsTTJwWHdyVEgwZHBXODVWaU5WUHBPWUU4dURBQkROd003cl9kSkdlc3Fnb2hodVBxQWItV3d2VVpNN2VGclZFSFQtTEhPcGx3RGNXY2gzYWdNV2Y0WkY1MzVoRkktczdhRW13a0xiaU5mejVybUZsZw?oc=5"},{"id":"auto-2026-11-23-2","tier":"watchlist","title":"Safety checks for Tomorrowland Thailand’s 11–13 Dec debut as organisers forecast 6.132bn baht boost - Nation Thailand","priority_tier":"FX, Energy, Raw Materials, Industry Demand","company":"ALL","published_at":"Mon, 23 Nov 2026 00:57:00 GMT","what":"หัวข้อข่าวล่าสุดจาก Google News — Thailand Baht / Economy: Safety checks for Tomorrowland Thailand’s 11–13 Dec debut as organisers forecast 6.132bn baht boost - Nation Thailand","so_what":"ติดตามผลกระทบต่อ KBI และ BGA ตามตัวขับเคลื่อนต้นทุน/อุปสงค์ (Automated Feed)","financial":"ประเมินผลกระทบต่อ Margin และ Cash Flow เทียบกับราคา KPI ล่าสุด (รอข้อมูลภายในบริษัท)","now_what":"เปิดลิงก์ต้นทางเพื่อตรวจสอบรายละเอียดเพิ่มเติมก่อนตัดสินใจเชิงพาณิชย์","owner":"ผู้บริหาร / ฝ่ายจัดซื้อ","source_name":"Google News — Thailand Baht / Economy","source_url":"https://news.google.com/rss/articles/CBMiYkFVX3lxTFBsc2Y2Wks2MUxLUWFDUlpCUjdiN2w4bVoza3dlY3ZENlpNLVU0OUFjUHUwMjFoN19WOWhQbHA3eW9PeGdpcWU3VDFiTDhkOGZJX0NiclpqS0lQY2tlZFVaZGh3?oc=5"},{"id":"auto-2026-11-23-3","tier":"watchlist","title":"4 ASEAN Central Banks Sign MOU on Local Currency Transaction Framework - SME & Entrepreneurship Magazine","priority_tier":"FX, Energy, Raw Materials, Industry Demand","company":"ALL","published_at":"Mon, 23 Nov 2026 03:00:53 GMT","what":"หัวข้อข่าวล่าสุดจาก Google News — Thailand Baht / Economy: 4 ASEAN Central Banks Sign MOU on Local Currency Transaction Framework - SME & Entrepreneurship Magazine","so_what":"ติดตามผลกระทบต่อ KBI และ BGA ตามตัวขับเคลื่อนต้นทุน/อุปสงค์ (Automated Feed)","financial":"ประเมินผลกระทบต่อ Margin และ Cash Flow เทียบกับราคา KPI ล่าสุด (รอข้อมูลภายในบริษัท)","now_what":"เปิดลิงก์ต้นทางเพื่อตรวจสอบรายละเอียดเพิ่มเติมก่อนตัดสินใจเชิงพาณิชย์","owner":"ผู้บริหาร / ฝ่ายจัดซื้อ","source_name":"Google News — Thailand Baht / Economy","source_url":"https://news.google.com/rss/articles/CBMikgFBVV95cUxONlZ4S28xQXdlaEREZ25Dc2lWZTJ1cVZaSDNLcTI3dnloRzNqdGR1V0dOcUpVWms1OF82bjRIcFIwTWh4MmRQOVB3YnBJRGFiR3VBckZHNVZ2R1BGTGczSXpfTG9OcXp2cTFQd01qU2F0dUdvNjVwY1BVeVJqb3JjS05vdlBDSWxEZWd6YW1Vc1J0dw?oc=5"},{"id":"auto-2026-11-23-4","tier":"watchlist","title":"Convert 500 THB (Thai Baht) to USD (United States Dollar) - Bybit","priority_tier":"FX, Energy, Raw Materials, Industry Demand","company":"ALL","published_at":"Sat, 21 Nov 2026 00:00:00 GMT","what":"หัวข้อข่าวล่าสุดจาก Google News — Thailand Baht / Economy: Convert 500 THB (Thai Baht) to USD (United States Dollar) - Bybit","so_what":"ติดตามผลกระทบต่อ KBI และ BGA ตามตัวขับเคลื่อนต้นทุน/อุปสงค์ (Automated Feed)","financial":"ประเมินผลกระทบต่อ Margin และ Cash Flow เทียบกับราคา KPI ล่าสุด (รอข้อมูลภายในบริษัท)","now_what":"เปิดลิงก์ต้นทางเพื่อตรวจสอบรายละเอียดเพิ่มเติมก่อนตัดสินใจเชิงพาณิชย์","owner":"ผู้บริหาร / ฝ่ายจัดซื้อ","source_name":"Google News — Thailand Baht / Economy","source_url":"https://news.google.com/rss/articles/CBMiXEFVX3lxTFB2ckxOb1ppY2J0eFNrSXVLeWtVQy1laHd5SzFDenVRYkl5Qnk4NFA3dlpielFzZlhLZFJxM0MySzlHTS1BU2E2V2otTGJEUGNfczVZOGd2aWVaVUpT?oc=5"},{"id":"n1","tier":"top_alert","title":"LME Aluminium Cash พุ่ง +2.56% สู่ 3,184.50 USD/t ขณะสต็อกต่ำ 223,525 ตัน","priority_tier":"FX, Energy, Raw Materials, Industry Demand","company":"BGA","published_at":"2026-11-20","what":"LME Cash-Settlement พุ่งขึ้น 79.50 USD/t ในวันศุกร์ ขณะสัญญา 3-Month อ่อนลงเหลือ 2,831.50 USD/t ดัน Backwardation แตะ +353.00 USD/t","so_what":"เพิ่มต้นทุนการซื้ออะลูมิเนียม Spot ของ BGA และกดดัน Working Capital","financial":"ต้นทุนวัตถุดิบ Spot สูงกว่า 3M กว่า 12.4% (รอข้อมูลภายในบริษัท: สัญญาสูตรราคา LME และสต็อก)","now_what":"ตรวจสอบสัดส่วน Spot vs 3M กับฝ่ายจัดซื้อ","owner":"COO & CFO","source_name":"Westmetall / AL Circle","source_url":"https://www.westmetall.com/en/markdaten.php?action=table&field=LME_Al_cash"},{"id":"n2","tier":"top_alert","title":"ดอลลาร์แข็งค่าสูงสุดรอบ 19 เดือน กดดันบาทอ่อนจ่อ 34.00 THB/USD และทองคำโลกร่วง 2.8%","priority_tier":"FX, Energy, Raw Materials, Industry Demand","company":"ALL","published_at":"2026-11-21","what":"CME FedWatch ประเมินโอกาส 96% ที่ Fed จะขึ้นดอกเบี้ย 0.25% ใน ธ.ค. หนุนดอลลาร์แข็งค่าสูงสุดในรอบ 19 เดือน กดดันทั้งบาทอ่อนค่าใกล้ 34.00 THB/USD และ Spot Gold ร่วง 2.8% สู่ 3,518.50 USD/oz (อีกทั้งแรงซื้อทองคำในประเทศช่วงราคาลดลงยิ่งเพิ่มความต้องการดอลลาร์)","so_what":"เพิ่มต้นทุนนำเข้าสกุล USD ของทั้ง KBI และ BGA ในรูปเงินบาท","financial":"กระทบ Cost of Imports และ Margin ขายในประเทศ (รอข้อมูลภายในบริษัท: Net FX Exposure)","now_what":"ทบทวนสถานะ FX Net Exposure ก่อนระดับ 34.00","owner":"CFO","source_name":"The Nation Thailand / BigGo Finance","source_url":"https://www.nationthailand.com/business/trading-investment/40073748"},{"id":"n3","tier":"top_alert","title":"อินเดียเปิดไต่สวน Anti-Dumping (AD) อะลูมิเนียม Extrusion จากไทยและ 3 ประเทศ","priority_tier":"Logistics, Trade Policy, Interest Rates, Regional Economy","company":"BGA","published_at":"2026-11-19","what":"DGTR อินเดียเปิดสอบสวน AD สินค้า Aluminium Extrusion Profiles จากจีน มาเลเซีย เวียดนาม และไทย","so_what":"กระทบความเสี่ยงส่งออกอินเดียของ BGA และการทะลักของสินค้าแข่งราคาในอาเซียน","financial":"อาจกดดัน Export Revenue และราคาขายในประเทศหากคู่แข่งระบายสินค้าเข้าไทย (รอข้อมูลภายในบริษัท)","now_what":"ตรวจสัดส่วนยอดขายไปอินเดียและเตรียมข้อมูลต้นทุน","owner":"CEO & ฝ่ายขาย","source_name":"AL Circle","source_url":"https://www.alcircle.com/news/india-probes-aluminium-dumping-by-china-malaysia-vietnam-thailand-vedanta-hindalco-shares-eyed-122026"},{"id":"n4","tier":"watchlist","title":"Brent ปิด 92.57 USD/bbl ร่วงรายสัปดาห์ต่อเนื่องสัปดาห์ที่ 3 จากคาดการณ์ซัพพลายเกินดุล","priority_tier":"FX, Energy, Raw Materials, Industry Demand","company":"ALL","published_at":"2026-11-20","what":"IEA คาดตลาดน้ำมันเกินดุล ~2 ล้านบาร์เรล/วัน ใน Q4 และการส่งออกผ่านฮอร์มุซฟื้นตัว กด Brent ลดลง -14.93% MoM","so_what":"ช่วยลดแรงกดดันต้นทุนพลังงานเตาหลอมกระจก (KBI) และค่าขนส่ง (KBI/BGA)","financial":"หนุนโอกาสประหยัด Energy & Freight Cost ใน Q1/2027 (รอข้อมูลภายในบริษัท: สูตรค่าพลังงาน)","now_what":"เจรจาปรับลด Fuel Surcharge กับผู้ขนส่ง","owner":"COO & จัดซื้อ","source_name":"Trading Economics","source_url":"https://tradingeconomics.com/commodity/brent-crude-oil"},{"id":"n5","tier":"watchlist","title":"GDP ไทย Q3/2026 โต +2.9% YoY แต่ภาคอสังหาฯ หดตัว -0.6% และก่อสร้างเอกชน -0.5%","priority_tier":"Logistics, Trade Policy, Interest Rates, Regional Economy","company":"ALL","published_at":"2026-11-18","what":"NESDC เผยการลงทุนเครื่องจักรโต +19.1% และก่อสร้างรัฐ +0.6% แต่ที่อยู่อาศัยหด -1.0% และอาคารพาณิชย์ -1.7%","so_what":"กดดันอุปสงค์กระจกและโปรไฟล์อะลูมิเนียมในภาคอสังหาฯ เอกชนไทย","financial":"จำกัด Volume Growth และเพิ่มความเสี่ยง AR Aging กลุ่มผู้รับเหมา/อสังหาฯ","now_what":"ปรับโฟกัสการขายสู่โครงการรัฐ/โรงงานอุตสาหกรรม และตรวจเครดิตลูกหนี้","owner":"CEO & CFO","source_name":"Houseviser (NESDC)","source_url":"https://houseviser.com/news/thailand-gdp-q3-2026-property-drag"},{"id":"n6","tier":"watchlist","title":"Drewry WCI ลดลง 3% เหลือ 4,176 USD/FEU แต่จ่อเก็บค่าธรรมเนียม PSS ยุโรป ธ.ค. นี้","priority_tier":"Logistics, Trade Policy, Interest Rates, Regional Economy","company":"ALL","published_at":"2026-11-19","what":"เส้นทาง Transpacific ลดลง แต่ Asia–Med พุ่ง +6% พร้อมสายเรือประกาศ PSS 1,000–1,600 USD/FEU เริ่ม ธ.ค. และตู้เปล่าคืนเอเชียล่าช้า","so_what":"เพิ่มความเสี่ยงค่าระวางส่งออกและ Lead Time ตู้คอนเทนเนอร์ของ KBI/BGA","financial":"อาจเพิ่ม Freight Cost และยืด Cash Conversion Cycle ช่วงปลายปี","now_what":"เร่งจองระวางเรือก่อน ธ.ค. และเผื่อเวลาคืนตู้เปล่า","owner":"COO & โลจิสติกส์","source_name":"Drewry","source_url":"https://www.drewry.co.uk/maritime-research-opinion-browser/world-container-index-assessed-by-drewry"}],"impact_matrix":[{"driver":"USD/THB อ่อนค่าใกล้ 34.00 (33.95 THB/USD)","kbi_indicator":"🟡 ต้องติดตาม","kbi_text":"เพิ่มต้นทุนนำเข้า Soda Ash และค่าขนส่งสกุล USD ในรูปเงินบาท แต่รายได้ส่งออกช่วยชดเชยบางส่วน (รอข้อมูลภายใน: Net FX Exposure)","bga_indicator":"🟡 ต้องติดตาม","bga_text":"เพิ่มต้นทุนนำเข้าวัตถุดิบอะลูมิเนียมสกุล USD ในรูปบาท ขณะที่ตลาดก่อสร้างในประเทศยังชะลอตัว (รอข้อมูลภายใน: FX Hedge)","management_implication":"CFO ตรวจสอบ Net USD Exposure ของทั้ง KBI และ BGA เพื่อประเมินความจำเป็นในการจัดการความเสี่ยงค่าเงินก่อนประชุม Fed ธ.ค."},{"driver":"Brent Oil อ่อนลงสู่ 92.57 USD/bbl (-14.93% MoM)","kbi_indicator":"🟢 ผลกระทบเชิงบวก","kbi_text":"ช่วยบรรเทาแรงกดดันต้นทุนพลังงานเตาหลอมกระจกและค่าขนส่งระยะกลาง แม้ราคายังสูงกว่าปีก่อน +47.97%","bga_indicator":"🟢 ผลกระทบเชิงบวก","bga_text":"ช่วยลดแรงกดดันค่าขนส่งและพลังงานในกระบวนการผลิต/รีดอะลูมิเนียม","management_implication":"ฝ่ายจัดซื้อเจรจาปรับลด Fuel Surcharge ตามรอบราคาพลังงาน และหลีกเลี่ยงการล็อกสัญญาพลังงานระยะยาวในช่วงขาลง"},{"driver":"LME Aluminium Cash 3,184.50 USD/t (+2.56%) & Backwardation +353.00 USD/t","kbi_indicator":"⚪ ไม่มีผลกระทบโดยตรงที่ยืนยันได้","kbi_text":"KBI ไม่ได้ใช้อะลูมิเนียมเป็นวัตถุดิบหลักในการผลิตกระจกแผ่น","bga_indicator":"🔴 ผลกระทบเชิงลบสูง","bga_text":"ราคา Spot สูงกว่า 3-Month (2,831.50 USD/t) ถึง 353.00 USD/t กดดันต้นทุนวัตถุดิบ Gross Margin และ Working Capital หากพึ่งพาการซื้อแบบ Prompt/Spot","management_implication":"COO และ CFO ตรวจสอบสูตรราคาในสัญญาซื้อ (Spot vs 3M) และระดับสต็อกจริงก่อนพิจารณาปรับแผนสั่งซื้อ"},{"driver":"Soda Ash FOB China 156.23 USD/MT (General Proxy ต.ค. 2026) & ซัพพลายจีนเพียงพอ","kbi_indicator":"🟢 ผลกระทบเชิงบวก","kbi_text":"ราคา FOB China ทรงตัว 0.00% MoM จากภาวะซัพพลายล้นตลาดในจีน ช่วยคุมแรงกดดันต้นทุนวัตถุดิบหลัก (รอข้อมูลภายใน: Landed Cost ของ KBI)","bga_indicator":"⚪ ไม่มีผลกระทบโดยตรงที่ยืนยันได้","bga_text":"BGA ไม่ได้ใช้ Soda Ash เป็นวัตถุดิบหลัก","management_implication":"ฝ่ายจัดซื้อ KBI ใช้ระดับ FOB China (156.23 USD/MT) เป็นข้อมูลเปรียบเทียบต่อรองกับราคาเสนอขายจริงของซัพพลายเออร์"},{"driver":"อสังหาฯ ไทย Q3 หดตัว -0.6% & คดี AD อะลูมิเนียมอินเดีย + PSS ค่าระวาง ธ.ค.","kbi_indicator":"🟡 ต้องติดตาม","kbi_text":"ก่อสร้างเอกชนชะลอ (-0.5%) กดดันยอดขายในประเทศ ขณะที่ PSS ค่าระวางยุโรปอาจกระทบต้นทุนส่งออก","bga_indicator":"🔴 ผลกระทบเชิงลบสูง","bga_text":"เผชิญทั้งอุปสงค์ก่อสร้างเอกชนอ่อนตัว และความเสี่ยงคดี AD อินเดียที่อาจทำให้สินค้าภูมิภาคไหลย้อนมาตัดราคาในไทย","management_implication":"CEO ขยายสัดส่วนการขายสู่กลุ่มโครงการรัฐ/อุตสาหกรรม (+19.1%) พร้อมให้ CFO คุม AR Aging และเร่งจองระวางเรือ"}],"management_actions":[{"priority":"P1","business":"BGA","action":"ตรวจสอบสัดส่วนสัญญาซื้อ LME Aluminium (Spot vs 3-Month) และระดับสต็อกคงคลังเพื่อประเมินผลกระทบ Backwardation +353.00 USD/t","owner":"CFO & COO","timeline":"ทันที (สัปดาห์นี้)","trigger":"Spread Cash–3M > 250.00 USD/t หรือสต็อก LME < 220,000 ตัน"},{"priority":"P1","business":"ALL (KBI & BGA)","action":"รวบรวม Net USD Cash Flow Exposure และสถานะ FX Forward คงเหลือเพื่อเตรียมทางเลือกบริหารความเสี่ยงค่าเงิน","owner":"CFO","timeline":"ทันที (ก่อน ธ.ค.)","trigger":"USD/THB ปิดเหนือ 34.00 THB/USD หรือก่อนประชุม Fed ธ.ค."},{"priority":"P2","business":"BGA","action":"ตรวจสอบยอดส่งออกไปอินเดีย พิกัด HS Code และเตรียมข้อมูลต้นทุนรองรับกรณี DGTR อินเดียไต่สวน Anti-Dumping Extrusion","owner":"CEO & ฝ่ายขาย","timeline":"ภายใน 2 สัปดาห์","trigger":"ประกาศไต่สวน/กำหนดอากรเบื้องต้นจาก DGTR อินเดีย"},{"priority":"P2","business":"KBI","action":"ขอ Quotation เปรียบเทียบ FOB/CIF Soda Ash รอบใหม่และเจรจาปรับลด Fuel Surcharge ตามแนวโน้ม Brent ที่ลดลง -14.93% MoM","owner":"COO & ฝ่ายจัดซื้อ","timeline":"ภายใน 2 สัปดาห์","trigger":"เมื่อได้รับใบเสนอราคางวด ธ.ค. หรือ Brent หลุด 90.00 USD/bbl"},{"priority":"P3","business":"ALL (KBI & BGA)","action":"เร่งจองระวางเรือส่งออกก่อนเก็บ PSS เดือน ธ.ค. และทบทวนวงเงินสินเชื่อลูกหนี้ภาคอสังหาฯ ในประเทศ (AR Aging)","owner":"COO & CFO","timeline":"ก่อน 1 ธ.ค. 2026","trigger":"ประกาศ PSS สายเรือ > 1,000 USD/FEU หรือลูกหนี้ค้างชำระ > 60 วัน"}]},{"date":"2026-11-22","display_date_th":"22 พ.ย. 2026 (อา.)","month_key":"2026-11","month_label_th":"พฤศจิกายน 2026","report_time_bkk":"2026-11-22 17:02 ICT (UTC+7)","scheduled_slot_bkk":"08:00 ICT (UTC+7)","is_weekend":true,"is_holiday":false,"holiday_name_th":"","short_status_th":"ตลาดปิด","market_status_overall":"ตลาดปิด (วันหยุดสุดสัปดาห์) • อ้างอิงราคาปิดวันทำการล่าสุด","price_rule_note":"","kpis":[{"id":"usd_thb","name":"USD/THB","category":"FX","unit":"THB/USD","company":"ALL","price":33.95,"price_display":"33.95","price_badge_th":"ราคาปิด ณ 20 พ.ย. 2026","price_precision_note":"BOT 33.953 / TE Spot 33.9510","price_basis":"Prior Close","price_type":"Weighted-avg Interbank / Spot Close","change_pct":-0.06,"change_display":"-0.06% DoD","comparison_base":"เทียบ 19 พ.ย. (33.9700) | +1.10% MoM","observation_date":"2026-11-20","market_status":"ตลาดปิด","data_quality":"VERIFIED LATEST","financial_impact":"บาทอ่อนค่าใกล้ 34.00 THB/USD (+4.79% YoY) กดดันต้นทุนนำเข้าสกุล USD ของ KBI/BGA แต่ช่วยหนุนรายได้ส่งออก (รอข้อมูลภายใน: Net FX Exposure)","source_name":"BOT & Trading Economics","source_url":"https://www.bot.or.th/en/statistics/exchange-rate.html"},{"id":"brent_oil","name":"Brent Oil","category":"Energy","unit":"USD/bbl","company":"ALL","price":92.57,"price_display":"92.57","price_badge_th":"ราคาปิด ณ 20 พ.ย. 2026","price_precision_note":"Previous Close: 91.98 USD/bbl","price_basis":"Prior Close","price_type":"Front-Month Futures/CFD Close","change_pct":0.64,"change_display":"+0.64% DoD","comparison_base":"เทียบ 19 พ.ย. (91.98) | -14.93% MoM","observation_date":"2026-11-20","market_status":"ตลาดปิด","data_quality":"VERIFIED LATEST","financial_impact":"ลดลง 3 สัปดาห์ติด (-14.93% MoM) จากคาดการณ์ซัพพลายล้นตลาด ช่วยบรรเทาต้นทุนเชื้อเพลิงเตาหลอม (KBI) และค่าขนส่ง (KBI/BGA) (รอข้อมูลภายใน)","source_name":"Trading Economics","source_url":"https://tradingeconomics.com/commodity/brent-crude-oil"},{"id":"lme_aluminium","name":"LME Aluminium","category":"Raw Material","unit":"USD/t","company":"BGA","price":3184.5,"price_display":"3,184.50","price_badge_th":"ราคาปิด ณ 20 พ.ย. 2026","price_precision_note":"3M: 2,831.50 USD/t | Stock: 223,525 t","price_basis":"Prior Close","price_type":"LME Official Cash-Settlement","change_pct":2.56,"change_display":"+2.56% DoD","comparison_base":"เทียบ Cash 2026-11-19 (3,105.00 USD/t)","observation_date":"2026-11-20","market_status":"ตลาดปิด (LME เปิดช่วงบ่ายเวลาไทย ใช้ราคา Settlement ล่าสุด)","data_quality":"VERIFIED LATEST","financial_impact":"Cash สูงกว่า 3-Month +353.00 USD/t (Backwardation) และสต็อกต่ำ 223,525 ตัน กดดันต้นทุนและ Working Capital ของ BGA หากซื้อ Spot (รอข้อมูลภายใน)","source_name":"Westmetall (LME)","source_url":"https://www.westmetall.com/en/markdaten.php?action=table&field=LME_Al_cash"},{"id":"soda_ash","name":"Soda Ash (FOB China)","category":"Raw Material","unit":"USD/MT","company":"KBI","price":156.23,"price_display":"156.23","price_badge_th":"ดัชนี ณ ต.ค. 2026","price_precision_note":"General Market Proxy (Dense ล่าสุด August 2026: 161.00 USD/MT)","price_basis":"Monthly Benchmark","price_type":"FOB China Monthly Assessment","change_pct":0.0,"change_display":"0.00% MoM","comparison_base":"เทียบ September 2026 (156.23 USD/MT)","observation_date":"October 2026","market_status":"LATEST PUBLISHED MONTHLY BENCHMARK","data_quality":"VERIFIED LATEST","financial_impact":"FOB China (General Proxy) ทรงตัวระดับต่ำที่ 156.23 USD/MT เป็นสัญญาณทิศทางต้นทุนขาลง แต่ไม่ใช่ราคา Landed Cost จริงของ KBI (รอข้อมูลภายใน)","source_name":"Procurement Resource","source_url":"https://www.procurementresource.com/resource-center/soda-ash-price-trends"}],"soda_ash_supplementary_context":[{"label":"Soda Ash (Dense) — FOB China (งวดก่อนหน้า)","price":"161.00 USD/MT (-5.29% MoM จาก Jul 2026: 170.00 USD/MT)","usd_note":"เกรด Dense บนฐาน FOB China ล่าสุดเดือน ส.ค. 2026 (เก่ากว่า General ต.ค. 2026 จึงใช้ General เป็น Proxy หลัก)","period":"August 2026","source_name":"Procurement Resource (Dense)","source_url":"https://www.procurementresource.com/resource-center/soda-ash-dense-price-trends"},{"label":"East China Domestic Reference (Dense / Light)","price":"RMB 1,150/MT (Dense) | RMB 1,000/MT (Light)","usd_note":"อ้างอิงในประเทศจีน (~172 USD / ~149 USD ที่ RMB 6.7/USD — ไม่ใช่ราคาส่งออก FOB)","period":"5 พ.ย. 2026","source_name":"Jinan ZZ / Chcachem","source_url":"https://www.chcachem.com/news/2026-11-06-china-soda-ash-market-update"},{"label":"APAC Regional Benchmark (CFR Tokyo, Light)","price":"212.33 USD/MT (-3.78% QoQ)","usd_note":"ราคาเฉลี่ย Q3 2026 (CFR Tokyo — ภูมิภาคอื่น ใช้เพื่อบริบทเท่านั้น)","period":"Q3 2026 (ก.ย. 2026)","source_name":"ChemAnalyst","source_url":"https://www.chemanalyst.com/Pricing-data/soda-ash-76"},{"label":"ASEAN Reference (Indonesia)","price":"259.00 USD/MT","usd_note":"ราคาตลาดอินโดนีเซีย เดือน ก.ย. 2026 (บริบทภูมิภาคเท่านั้น)","period":"ก.ย. 2026","source_name":"IMARC Group","source_url":"https://www.imarcgroup.com/soda-ash-pricing-report"}],"decision_cards":[{"priority_status":"ต้องตัดสินใจ","priority_level":"critical","company":"BGA","headline":"LME Aluminium Cash พุ่ง 3,184.50 USD/t (+2.56%) ขณะ Backwardation ถ่าง +353.00 USD/t","financial_impact":"ซื้อ Spot แพงกว่าสัญญา 3-Month (2,831.50 USD/t) ถึง 353.00 USD/t กดดัน Gross Margin และดึง Working Capital เพิ่มขึ้นทันที","recommended_action":"ทบทวนสัดส่วนสัญญาซื้อ Spot เทียบ 3M Forward และตรวจสอบ Lead Time/สต็อกคงเหลือ (รอข้อมูลภายในบริษัท)","owner":"CFO & COO","review_point":"ทบทวนเมื่อ LME 3M–Cash Spread > 250 USD/t หรือสต็อก LME ต่ำกว่า 220,000 ตัน"},{"priority_status":"ควรพิจารณา","priority_level":"warning","company":"ALL (KBI & BGA)","headline":"USD/THB จ่อแนวต้าน 34.00 THB/USD (33.95) ขณะภาคก่อสร้างเอกชนไทย Q3 หด -0.5%","financial_impact":"ต้นทุนนำเข้าสกุล USD สูงขึ้นราว +1.10% MoM ในภาวะที่ตลาดอสังหาฯ ในประเทศชะลอตัว ทำให้ส่งผ่านราคาขายได้จำกัด","recommended_action":"ประเมิน Net USD Exposure ของ KBI/BGA และเตรียมกรอบบริหารความเสี่ยง FX ก่อนประชุม Fed ธ.ค. (รอข้อมูลภายในบริษัท)","owner":"CFO","review_point":"ทบทวนเมื่อ USD/THB ปิดเหนือ 34.00 THB/USD หรือก่อนประชุม FOMC ธ.ค."},{"priority_status":"เฝ้าระวัง","priority_level":"watch","company":"BGA","headline":"อินเดียเปิดไต่สวน Anti-Dumping (AD) อะลูมิเนียม Extrusion จากไทยและ 3 ประเทศ","financial_impact":"เสี่ยงกระทบยอดส่งออกไปอินเดีย (หากมี) และเสี่ยงเกิดสินค้าจีน/เวียดนามไหลย้อนเข้ามาตัดราคาในตลาดไทย/อาเซียน","recommended_action":"ตรวจสอบสัดส่วนรายได้ส่งออกอินเดีย พิกัดสินค้า และเตรียมข้อมูลต้นทุนการผลิตไว้ล่วงหน้า (รอข้อมูลภายในบริษัท)","owner":"CEO & ฝ่ายขาย","review_point":"ติดตามประกาศเบื้องต้นของ DGTR อินเดีย และการเปลี่ยนแปลงราคาเสนอขายในอาเซียน"}],"executive_3rows":[{"num":1,"label":"SITUATION — สถานการณ์สำคัญ","headline":"ตลาดปิดวันเสาร์ อ้างอิงราคาปิดศุกร์ 20 พ.ย. 2026: บาทจ่อ 34.00, LME Cash พุ่ง +2.56%, Brent อ่อนลง -14.93% MoM","detail":"ดอลลาร์แข็งค่าสูงสุดรอบ 19 เดือน (โอกาส Fed ขึ้นดอกเบี้ย ธ.ค. 96%) กดดัน USD/THB ที่ 33.95 และทองคำร่วง 2.8% ขณะที่ LME Aluminium Cash ดีดตัวสู่ 3,184.50 USD/t สวนทาง Brent ที่ลดลงต่อเนื่อง 3 สัปดาห์เหลือ 92.57 USD/bbl และ Soda Ash FOB China (General Proxy ต.ค. 2026) ทรงตัวที่ 156.23 USD/MT"},{"num":2,"label":"BUSINESS IMPACT — ผลกระทบต่อ KBI / BGA","headline":"BGA เผชิญแรงกดดันต้นทุน Spot + คดี AD อินเดีย สูงกว่า KBI ที่ได้อานิสงส์ Brent และ Soda Ash ทรงตัวต่ำ","detail":"ทั้งสองบริษัทรับแรงต้านจากอุปสงค์อสังหาฯ ไทย Q3 (-0.6% YoY) และบาทอ่อน 33.95 แต่ BGA มีความเสี่ยง Margin/Working Capital เพิ่มจาก LME Backwardation +353.00 USD/t และ AD อินเดีย ส่วน KBI ได้แรงหนุนจาก Brent อ่อนตัวและ Soda Ash FOB China 156.23 USD/MT (ผลสุทธิรอข้อมูลสัญญาและ Hedging ภายในบริษัท)"},{"num":3,"label":"MANAGEMENT RESPONSE — สิ่งที่ผู้บริหารควรทำ","headline":"เร่งตรวจสอบ Exposure จริงก่อนตัดสินใจ: คุม LME 3M vs Spot, เช็ก Net FX และจับจองระวางเรือ ธ.ค.","detail":"CFO & COO ตรวจสอบสต็อก-สูตรราคา LME ของ BGA และ Net USD Exposure ของกลุ่มก่อนตัดสินใจล็อกราคาใดๆ; ฝ่ายขาย BGA ตรวจยอดส่งออกอินเดีย; ฝ่ายโลจิสติกส์จองระวางเรือก่อนสายเรือเก็บ PSS ยุโรป 1,000–1,600 USD/FEU ในเดือน ธ.ค."}],"lme_60d_series":[{"d":"2026-09-21","cash":3262.5,"m3":3273.0,"stock":242200},{"d":"2026-09-22","cash":3242.0,"m3":3264.0,"stock":242125},{"d":"2026-09-23","cash":3240.0,"m3":3260.0,"stock":241375},{"d":"2026-09-24","cash":3228.0,"m3":3252.5,"stock":241375},{"d":"2026-09-25","cash":3254.0,"m3":3267.0,"stock":241375},{"d":"2026-09-28","cash":3248.5,"m3":3252.0,"stock":241375},{"d":"2026-09-29","cash":3225.5,"m3":3232.0,"stock":241375},{"d":"2026-09-30","cash":3204.0,"m3":3210.0,"stock":241375},{"d":"2026-10-01","cash":3120.0,"m3":3131.0,"stock":240625},{"d":"2026-10-02","cash":3109.5,"m3":3122.0,"stock":240375},{"d":"2026-10-05","cash":3107.0,"m3":3118.0,"stock":240375},{"d":"2026-10-06","cash":3134.5,"m3":3148.5,"stock":238875},{"d":"2026-10-07","cash":3102.5,"m3":3114.0,"stock":238875},{"d":"2026-10-08","cash":3060.5,"m3":3069.0,"stock":238875},{"d":"2026-10-09","cash":3055.5,"m3":3070.0,"stock":238875},{"d":"2026-10-12","cash":3055.0,"m3":3060.0,"stock":238625},{"d":"2026-10-13","cash":3036.0,"m3":3037.0,"stock":238625},{"d":"2026-10-14","cash":3010.0,"m3":3013.5,"stock":238375},{"d":"2026-10-15","cash":2999.0,"m3":2994.5,"stock":238125},{"d":"2026-10-16","cash":3014.0,"m3":3012.0,"stock":237875},{"d":"2026-10-19","cash":3019.0,"m3":3012.0,"stock":236375},{"d":"2026-10-20","cash":3003.5,"m3":2997.0,"stock":236225},{"d":"2026-10-21","cash":3031.0,"m3":3024.5,"stock":236125},{"d":"2026-10-22","cash":3033.0,"m3":3008.0,"stock":236025},{"d":"2026-10-23","cash":3043.0,"m3":3018.0,"stock":235800},{"d":"2026-10-26","cash":3047.5,"m3":3027.0,"stock":234050},{"d":"2026-10-27","cash":3078.0,"m3":3064.0,"stock":232100},{"d":"2026-10-28","cash":3101.0,"m3":3084.0,"stock":231900},{"d":"2026-10-29","cash":3071.0,"m3":3064.0,"stock":231675},{"d":"2026-10-30","cash":3114.0,"m3":3080.0,"stock":231200},{"d":"2026-11-02","cash":3095.0,"m3":3060.0,"stock":230775},{"d":"2026-11-03","cash":3082.0,"m3":3042.0,"stock":229475},{"d":"2026-11-04","cash":3135.0,"m3":3074.0,"stock":228750},{"d":"2026-11-05","cash":3160.0,"m3":3097.5,"stock":228475},{"d":"2026-11-06","cash":3117.0,"m3":3050.0,"stock":227600},{"d":"2026-11-09","cash":3147.0,"m3":3059.5,"stock":226975},{"d":"2026-11-10","cash":3137.0,"m3":3027.0,"stock":226850},{"d":"2026-11-11","cash":3223.5,"m3":3064.0,"stock":226725},{"d":"2026-11-12","cash":3155.5,"m3":3032.0,"stock":226350},{"d":"2026-11-13","cash":3150.5,"m3":3018.0,"stock":224150},{"d":"2026-11-16","cash":3332.0,"m3":3020.0,"stock":221900},{"d":"2026-11-17","cash":3060.5,"m3":2940.0,"stock":220350},{"d":"2026-11-18","cash":3095.0,"m3":2865.0,"stock":226150},{"d":"2026-11-19","cash":3105.0,"m3":2845.0,"stock":224425},{"d":"2026-11-20","cash":3184.5,"m3":2831.5,"stock":223525}],"news":[{"id":"n1","tier":"top_alert","title":"LME Aluminium Cash พุ่ง +2.56% สู่ 3,184.50 USD/t ขณะสต็อกต่ำ 223,525 ตัน","priority_tier":"FX, Energy, Raw Materials, Industry Demand","company":"BGA","published_at":"2026-11-20","what":"LME Cash-Settlement พุ่งขึ้น 79.50 USD/t ในวันศุกร์ ขณะสัญญา 3-Month อ่อนลงเหลือ 2,831.50 USD/t ดัน Backwardation แตะ +353.00 USD/t","so_what":"เพิ่มต้นทุนการซื้ออะลูมิเนียม Spot ของ BGA และกดดัน Working Capital","financial":"ต้นทุนวัตถุดิบ Spot สูงกว่า 3M กว่า 12.4% (รอข้อมูลภายในบริษัท: สัญญาสูตรราคา LME และสต็อก)","now_what":"ตรวจสอบสัดส่วน Spot vs 3M กับฝ่ายจัดซื้อ","owner":"COO & CFO","source_name":"Westmetall / AL Circle","source_url":"https://www.westmetall.com/en/markdaten.php?action=table&field=LME_Al_cash"},{"id":"n2","tier":"top_alert","title":"ดอลลาร์แข็งค่าสูงสุดรอบ 19 เดือน กดดันบาทอ่อนจ่อ 34.00 THB/USD และทองคำโลกร่วง 2.8%","priority_tier":"FX, Energy, Raw Materials, Industry Demand","company":"ALL","published_at":"2026-11-21","what":"CME FedWatch ประเมินโอกาส 96% ที่ Fed จะขึ้นดอกเบี้ย 0.25% ใน ธ.ค. หนุนดอลลาร์แข็งค่าสูงสุดในรอบ 19 เดือน กดดันทั้งบาทอ่อนค่าใกล้ 34.00 THB/USD และ Spot Gold ร่วง 2.8% สู่ 3,518.50 USD/oz (อีกทั้งแรงซื้อทองคำในประเทศช่วงราคาลดลงยิ่งเพิ่มความต้องการดอลลาร์)","so_what":"เพิ่มต้นทุนนำเข้าสกุล USD ของทั้ง KBI และ BGA ในรูปเงินบาท","financial":"กระทบ Cost of Imports และ Margin ขายในประเทศ (รอข้อมูลภายในบริษัท: Net FX Exposure)","now_what":"ทบทวนสถานะ FX Net Exposure ก่อนระดับ 34.00","owner":"CFO","source_name":"The Nation Thailand / BigGo Finance","source_url":"https://www.nationthailand.com/business/trading-investment/40073748"},{"id":"n3","tier":"top_alert","title":"อินเดียเปิดไต่สวน Anti-Dumping (AD) อะลูมิเนียม Extrusion จากไทยและ 3 ประเทศ","priority_tier":"Logistics, Trade Policy, Interest Rates, Regional Economy","company":"BGA","published_at":"2026-11-19","what":"DGTR อินเดียเปิดสอบสวน AD สินค้า Aluminium Extrusion Profiles จากจีน มาเลเซีย เวียดนาม และไทย","so_what":"กระทบความเสี่ยงส่งออกอินเดียของ BGA และการทะลักของสินค้าแข่งราคาในอาเซียน","financial":"อาจกดดัน Export Revenue และราคาขายในประเทศหากคู่แข่งระบายสินค้าเข้าไทย (รอข้อมูลภายในบริษัท)","now_what":"ตรวจสัดส่วนยอดขายไปอินเดียและเตรียมข้อมูลต้นทุน","owner":"CEO & ฝ่ายขาย","source_name":"AL Circle","source_url":"https://www.alcircle.com/news/india-probes-aluminium-dumping-by-china-malaysia-vietnam-thailand-vedanta-hindalco-shares-eyed-122026"},{"id":"n4","tier":"watchlist","title":"Brent ปิด 92.57 USD/bbl ร่วงรายสัปดาห์ต่อเนื่องสัปดาห์ที่ 3 จากคาดการณ์ซัพพลายเกินดุล","priority_tier":"FX, Energy, Raw Materials, Industry Demand","company":"ALL","published_at":"2026-11-20","what":"IEA คาดตลาดน้ำมันเกินดุล ~2 ล้านบาร์เรล/วัน ใน Q4 และการส่งออกผ่านฮอร์มุซฟื้นตัว กด Brent ลดลง -14.93% MoM","so_what":"ช่วยลดแรงกดดันต้นทุนพลังงานเตาหลอมกระจก (KBI) และค่าขนส่ง (KBI/BGA)","financial":"หนุนโอกาสประหยัด Energy & Freight Cost ใน Q1/2027 (รอข้อมูลภายในบริษัท: สูตรค่าพลังงาน)","now_what":"เจรจาปรับลด Fuel Surcharge กับผู้ขนส่ง","owner":"COO & จัดซื้อ","source_name":"Trading Economics","source_url":"https://tradingeconomics.com/commodity/brent-crude-oil"},{"id":"n5","tier":"watchlist","title":"GDP ไทย Q3/2026 โต +2.9% YoY แต่ภาคอสังหาฯ หดตัว -0.6% และก่อสร้างเอกชน -0.5%","priority_tier":"Logistics, Trade Policy, Interest Rates, Regional Economy","company":"ALL","published_at":"2026-11-18","what":"NESDC เผยการลงทุนเครื่องจักรโต +19.1% และก่อสร้างรัฐ +0.6% แต่ที่อยู่อาศัยหด -1.0% และอาคารพาณิชย์ -1.7%","so_what":"กดดันอุปสงค์กระจกและโปรไฟล์อะลูมิเนียมในภาคอสังหาฯ เอกชนไทย","financial":"จำกัด Volume Growth และเพิ่มความเสี่ยง AR Aging กลุ่มผู้รับเหมา/อสังหาฯ","now_what":"ปรับโฟกัสการขายสู่โครงการรัฐ/โรงงานอุตสาหกรรม และตรวจเครดิตลูกหนี้","owner":"CEO & CFO","source_name":"Houseviser (NESDC)","source_url":"https://houseviser.com/news/thailand-gdp-q3-2026-property-drag"},{"id":"n6","tier":"watchlist","title":"Drewry WCI ลดลง 3% เหลือ 4,176 USD/FEU แต่จ่อเก็บค่าธรรมเนียม PSS ยุโรป ธ.ค. นี้","priority_tier":"Logistics, Trade Policy, Interest Rates, Regional Economy","company":"ALL","published_at":"2026-11-19","what":"เส้นทาง Transpacific ลดลง แต่ Asia–Med พุ่ง +6% พร้อมสายเรือประกาศ PSS 1,000–1,600 USD/FEU เริ่ม ธ.ค. และตู้เปล่าคืนเอเชียล่าช้า","so_what":"เพิ่มความเสี่ยงค่าระวางส่งออกและ Lead Time ตู้คอนเทนเนอร์ของ KBI/BGA","financial":"อาจเพิ่ม Freight Cost และยืด Cash Conversion Cycle ช่วงปลายปี","now_what":"เร่งจองระวางเรือก่อน ธ.ค. และเผื่อเวลาคืนตู้เปล่า","owner":"COO & โลจิสติกส์","source_name":"Drewry","source_url":"https://www.drewry.co.uk/maritime-research-opinion-browser/world-container-index-assessed-by-drewry"},{"id":"n7","tier":"watchlist","title":"ตลาดอะลูมิเนียมโลกเสี่ยงขาดดุลถึงปี 2028 จากเพดานผลิตจีน 45 ล้านตัน/ปี","priority_tier":"FX, Energy, Raw Materials, Industry Demand","company":"BGA","published_at":"2026-11-19","what":"Emkay Global คาดขาดดุล ~400,000 ตัน/ปี ในปี 2027–2028 ขณะ Alumina อยู่ที่ ~398 USD/t และโรงหลอมอินโดนีเซีย/ตะวันออกกลางฟื้นตัวช้า","so_what":"สร้างแรงหนุนเชิงโครงสร้างต่อต้นทุนวัตถุดิบระยะกลางของ BGA","financial":"จำกัดโอกาสที่ราคา LME จะลงลึกในระยะยาว","now_what":"จัดทำแผน Dual-Sourcing และกรอบจัดซื้อปี 2027","owner":"COO","source_name":"AL Circle","source_url":"https://www.alcircle.com/news/aluminium-supply-crunch-to-persist-till-2028-driven-by-chinas-45mt-cap-low-stocks-122031"},{"id":"n8","tier":"watchlist","title":"Soda Ash FOB China ทรงตัวที่ 156.23 USD/MT (ต.ค. 2026) ขณะโรงงาน Float Glass จีนเข้าซ่อมบำรุง","priority_tier":"FX, Energy, Raw Materials, Industry Demand","company":"KBI","published_at":"2026-11-09","what":"Procurement Resource รายงานราคา FOB China (General) เดือน ต.ค. 2026 อยู่ที่ 156.23 USD/MT (0.00% MoM) และสต็อกในจีนเพิ่มขึ้นหลังสายผลิตกระจกแผ่นเข้าโหมด Cold Repair","so_what":"เป็นบริบทบวกต่ออำนาจต่อรองการจัดซื้อ Soda Ash ของ KBI ในภูมิภาคเอเชีย","financial":"ช่วยจำกัดแรงกดดันต้นทุนวัตถุดิบหลักในระยะสั้น (รอข้อมูลภายในบริษัท: ราคา Landed Cost ของ KBI)","now_what":"ขอ Quotation เปรียบเทียบจากหลายซัพพลายเออร์และไม่เร่งล็อกสัญญาระยะยาวเกินไป","owner":"ฝ่ายจัดซื้อ KBI","source_name":"Procurement Resource / Chcachem","source_url":"https://www.procurementresource.com/resource-center/soda-ash-price-trends"},{"id":"n9","tier":"watchlist","title":"EU เตรียมขยาย CBAM ครอบคลุมสินค้าปลายน้ำอะลูมิเนียม/เหล็ก 180 รายการในปี 2028","priority_tier":"ESG, Carbon Regulation, Technology, Competitor Expansion","company":"BGA","published_at":"2026-11-19","what":"คณะกรรมาธิการยุโรปเสนอขยาย CBAM สู่สินค้าแปรรูปปลายน้ำเพื่อป้องกันการหลบเลี่ยงภาษีคาร์บอน พร้อมเพิ่ม Default Mark-up 10%→30%","so_what":"กระทบความสามารถแข่งขันส่งออกของ BGA ไปตลาด EU หรือ OEM ที่ส่งออกไป EU","financial":"เสี่ยงถูกบวกค่าปรับ Default Carbon หากไม่มีข้อมูล Embedded Emissions จริง","now_what":"เริ่มเก็บข้อมูล Carbon Intensity และแหล่งที่มาวัตถุดิบจากซัพพลายเออร์","owner":"COO & ฝ่ายความยั่งยืน","source_name":"AL Circle","source_url":"https://www.alcircle.com/news/eu-industrial-emissions-fall-3-3-as-cbam-expansion-eyes-more-aluminium-products-122022"}],"impact_matrix":[{"driver":"USD/THB อ่อนค่าใกล้ 34.00 (33.95 THB/USD)","kbi_indicator":"🟡 ต้องติดตาม","kbi_text":"เพิ่มต้นทุนนำเข้า Soda Ash และค่าขนส่งสกุล USD ในรูปเงินบาท แต่รายได้ส่งออกช่วยชดเชยบางส่วน (รอข้อมูลภายใน: Net FX Exposure)","bga_indicator":"🟡 ต้องติดตาม","bga_text":"เพิ่มต้นทุนนำเข้าวัตถุดิบอะลูมิเนียมสกุล USD ในรูปบาท ขณะที่ตลาดก่อสร้างในประเทศยังชะลอตัว (รอข้อมูลภายใน: FX Hedge)","management_implication":"CFO ตรวจสอบ Net USD Exposure ของทั้ง KBI และ BGA เพื่อประเมินความจำเป็นในการจัดการความเสี่ยงค่าเงินก่อนประชุม Fed ธ.ค."},{"driver":"Brent Oil อ่อนลงสู่ 92.57 USD/bbl (-14.93% MoM)","kbi_indicator":"🟢 ผลกระทบเชิงบวก","kbi_text":"ช่วยบรรเทาแรงกดดันต้นทุนพลังงานเตาหลอมกระจกและค่าขนส่งระยะกลาง แม้ราคายังสูงกว่าปีก่อน +47.97%","bga_indicator":"🟢 ผลกระทบเชิงบวก","bga_text":"ช่วยลดแรงกดดันค่าขนส่งและพลังงานในกระบวนการผลิต/รีดอะลูมิเนียม","management_implication":"ฝ่ายจัดซื้อเจรจาปรับลด Fuel Surcharge ตามรอบราคาพลังงาน และหลีกเลี่ยงการล็อกสัญญาพลังงานระยะยาวในช่วงขาลง"},{"driver":"LME Aluminium Cash 3,184.50 USD/t (+2.56%) & Backwardation +353.00 USD/t","kbi_indicator":"⚪ ไม่มีผลกระทบโดยตรงที่ยืนยันได้","kbi_text":"KBI ไม่ได้ใช้อะลูมิเนียมเป็นวัตถุดิบหลักในการผลิตกระจกแผ่น","bga_indicator":"🔴 ผลกระทบเชิงลบสูง","bga_text":"ราคา Spot สูงกว่า 3-Month (2,831.50 USD/t) ถึง 353.00 USD/t กดดันต้นทุนวัตถุดิบ Gross Margin และ Working Capital หากพึ่งพาการซื้อแบบ Prompt/Spot","management_implication":"COO และ CFO ตรวจสอบสูตรราคาในสัญญาซื้อ (Spot vs 3M) และระดับสต็อกจริงก่อนพิจารณาปรับแผนสั่งซื้อ"},{"driver":"Soda Ash FOB China 156.23 USD/MT (General Proxy ต.ค. 2026) & ซัพพลายจีนเพียงพอ","kbi_indicator":"🟢 ผลกระทบเชิงบวก","kbi_text":"ราคา FOB China ทรงตัว 0.00% MoM จากภาวะซัพพลายล้นตลาดในจีน ช่วยคุมแรงกดดันต้นทุนวัตถุดิบหลัก (รอข้อมูลภายใน: Landed Cost ของ KBI)","bga_indicator":"⚪ ไม่มีผลกระทบโดยตรงที่ยืนยันได้","bga_text":"BGA ไม่ได้ใช้ Soda Ash เป็นวัตถุดิบหลัก","management_implication":"ฝ่ายจัดซื้อ KBI ใช้ระดับ FOB China (156.23 USD/MT) เป็นข้อมูลเปรียบเทียบต่อรองกับราคาเสนอขายจริงของซัพพลายเออร์"},{"driver":"อสังหาฯ ไทย Q3 หดตัว -0.6% & คดี AD อะลูมิเนียมอินเดีย + PSS ค่าระวาง ธ.ค.","kbi_indicator":"🟡 ต้องติดตาม","kbi_text":"ก่อสร้างเอกชนชะลอ (-0.5%) กดดันยอดขายในประเทศ ขณะที่ PSS ค่าระวางยุโรปอาจกระทบต้นทุนส่งออก","bga_indicator":"🔴 ผลกระทบเชิงลบสูง","bga_text":"เผชิญทั้งอุปสงค์ก่อสร้างเอกชนอ่อนตัว และความเสี่ยงคดี AD อินเดียที่อาจทำให้สินค้าภูมิภาคไหลย้อนมาตัดราคาในไทย","management_implication":"CEO ขยายสัดส่วนการขายสู่กลุ่มโครงการรัฐ/อุตสาหกรรม (+19.1%) พร้อมให้ CFO คุม AR Aging และเร่งจองระวางเรือ"}],"management_actions":[{"priority":"P1","business":"BGA","action":"ตรวจสอบสัดส่วนสัญญาซื้อ LME Aluminium (Spot vs 3-Month) และระดับสต็อกคงคลังเพื่อประเมินผลกระทบ Backwardation +353.00 USD/t","owner":"CFO & COO","timeline":"ทันที (สัปดาห์นี้)","trigger":"Spread Cash–3M > 250.00 USD/t หรือสต็อก LME < 220,000 ตัน"},{"priority":"P1","business":"ALL (KBI & BGA)","action":"รวบรวม Net USD Cash Flow Exposure และสถานะ FX Forward คงเหลือเพื่อเตรียมทางเลือกบริหารความเสี่ยงค่าเงิน","owner":"CFO","timeline":"ทันที (ก่อน ธ.ค.)","trigger":"USD/THB ปิดเหนือ 34.00 THB/USD หรือก่อนประชุม Fed ธ.ค."},{"priority":"P2","business":"BGA","action":"ตรวจสอบยอดส่งออกไปอินเดีย พิกัด HS Code และเตรียมข้อมูลต้นทุนรองรับกรณี DGTR อินเดียไต่สวน Anti-Dumping Extrusion","owner":"CEO & ฝ่ายขาย","timeline":"ภายใน 2 สัปดาห์","trigger":"ประกาศไต่สวน/กำหนดอากรเบื้องต้นจาก DGTR อินเดีย"},{"priority":"P2","business":"KBI","action":"ขอ Quotation เปรียบเทียบ FOB/CIF Soda Ash รอบใหม่และเจรจาปรับลด Fuel Surcharge ตามแนวโน้ม Brent ที่ลดลง -14.93% MoM","owner":"COO & ฝ่ายจัดซื้อ","timeline":"ภายใน 2 สัปดาห์","trigger":"เมื่อได้รับใบเสนอราคางวด ธ.ค. หรือ Brent หลุด 90.00 USD/bbl"},{"priority":"P3","business":"ALL (KBI & BGA)","action":"เร่งจองระวางเรือส่งออกก่อนเก็บ PSS เดือน ธ.ค. และทบทวนวงเงินสินเชื่อลูกหนี้ภาคอสังหาฯ ในประเทศ (AR Aging)","owner":"COO & CFO","timeline":"ก่อน 1 ธ.ค. 2026","trigger":"ประกาศ PSS สายเรือ > 1,000 USD/FEU หรือลูกหนี้ค้างชำระ > 60 วัน"}]},{"date":"2026-11-21","display_date_th":"21 พ.ย. 2026 (ส.)","month_key":"2026-11","month_label_th":"พฤศจิกายน 2026","report_time_bkk":"2026-11-21 23:02 ICT (UTC+7)","scheduled_slot_bkk":"08:00 ICT (UTC+7)","is_weekend":true,"is_holiday":false,"holiday_name_th":"","short_status_th":"ตลาดปิด","market_status_overall":"ตลาดปิด (วันหยุดสุดสัปดาห์) • อ้างอิงราคาปิด 20 พ.ย. 2026","kpis":[{"id":"usd_thb","name":"USD/THB","category":"FX","unit":"THB/USD","company":"ALL","price":33.95,"price_display":"33.95","price_badge_th":"ราคาปิด ณ 20 พ.ย. 2026","price_precision_note":"BOT 33.953 / TE Spot 33.9510","price_basis":"Prior Close","price_type":"Weighted-avg Interbank / Spot Close","change_pct":-0.06,"change_display":"-0.06% DoD","comparison_base":"เทียบ 19 พ.ย. (33.9700) | +1.10% MoM","observation_date":"2026-11-20","market_status":"ตลาดปิด","data_quality":"VERIFIED LATEST","financial_impact":"บาทอ่อนค่าใกล้ 34.00 THB/USD (+4.79% YoY) กดดันต้นทุนนำเข้าสกุล USD ของ KBI/BGA แต่ช่วยหนุนรายได้ส่งออก (รอข้อมูลภายใน: Net FX Exposure)","source_name":"BOT & Trading Economics","source_url":"https://www.bot.or.th/en/statistics/exchange-rate.html"},{"id":"brent_oil","name":"Brent Oil","category":"Energy","unit":"USD/bbl","company":"ALL","price":92.57,"price_display":"92.57","price_badge_th":"ราคาปิด ณ 20 พ.ย. 2026","price_precision_note":"Previous Close: 91.98 USD/bbl","price_basis":"Prior Close","price_type":"Front-Month Futures/CFD Close","change_pct":0.64,"change_display":"+0.64% DoD","comparison_base":"เทียบ 19 พ.ย. (91.98) | -14.93% MoM","observation_date":"2026-11-20","market_status":"ตลาดปิด","data_quality":"VERIFIED LATEST","financial_impact":"ลดลง 3 สัปดาห์ติด (-14.93% MoM) จากคาดการณ์ซัพพลายล้นตลาด ช่วยบรรเทาต้นทุนเชื้อเพลิงเตาหลอม (KBI) และค่าขนส่ง (KBI/BGA) (รอข้อมูลภายใน)","source_name":"Trading Economics","source_url":"https://tradingeconomics.com/commodity/brent-crude-oil"},{"id":"lme_aluminium","name":"LME Aluminium","category":"Raw Material","unit":"USD/t","company":"BGA","price":3184.5,"price_display":"3,184.50","price_badge_th":"ราคาปิด ณ 20 พ.ย. 2026","price_precision_note":"3M: 2,831.50 USD/t | Stock: 223,525 t","price_basis":"Prior Close","price_type":"LME Official Cash-Settlement","change_pct":2.56,"change_display":"+2.56% DoD","comparison_base":"เทียบ Cash 19 พ.ย. (3,105.00 USD/t)","observation_date":"2026-11-20","market_status":"ตลาดปิด","data_quality":"VERIFIED LATEST","financial_impact":"Cash สูงกว่า 3-Month +353.00 USD/t (Backwardation) และสต็อกต่ำ 223,525 ตัน กดดันต้นทุนและ Working Capital ของ BGA หากซื้อ Spot (รอข้อมูลภายใน)","source_name":"Westmetall (LME)","source_url":"https://www.westmetall.com/en/markdaten.php?action=table&field=LME_Al_cash"},{"id":"soda_ash","name":"Soda Ash (FOB China)","category":"Raw Material","unit":"USD/MT","company":"KBI","price":156.23,"price_display":"156.23","price_badge_th":"ดัชนี ณ ต.ค. 2026","price_precision_note":"General Market Proxy (Dense ส.ค.: 161.00)","price_basis":"Monthly Benchmark","price_type":"FOB China Monthly Assessment","change_pct":0.0,"change_display":"0.00% MoM","comparison_base":"เทียบ ก.ย. 2026 (156.23 USD/MT)","observation_date":"October 2026","market_status":"รายเดือนล่าสุด","data_quality":"VERIFIED LATEST","financial_impact":"FOB China (General Proxy) ทรงตัวระดับต่ำที่ 156.23 USD/MT เป็นสัญญาณทิศทางต้นทุนขาลง แต่ไม่ใช่ราคา Landed Cost จริงของ KBI (รอข้อมูลภายใน)","source_name":"Procurement Resource","source_url":"https://www.procurementresource.com/resource-center/soda-ash-price-trends"}],"soda_ash_supplementary_context":[{"label":"Soda Ash (Dense) — FOB China (งวดก่อนหน้า)","price":"161.00 USD/MT (-5.29% MoM จาก Jul 2026: 170.00 USD/MT)","usd_note":"เกรด Dense บนฐาน FOB China ล่าสุดเดือน ส.ค. 2026 (เก่ากว่า General ต.ค. 2026 จึงใช้ General เป็น Proxy หลัก)","period":"August 2026","source_name":"Procurement Resource (Dense)","source_url":"https://www.procurementresource.com/resource-center/soda-ash-dense-price-trends"},{"label":"East China Domestic Reference (Dense / Light)","price":"RMB 1,150/MT (Dense) | RMB 1,000/MT (Light)","usd_note":"อ้างอิงในประเทศจีน (~172 USD / ~149 USD ที่ RMB 6.7/USD — ไม่ใช่ราคาส่งออก FOB)","period":"5 พ.ย. 2026","source_name":"Jinan ZZ / Chcachem","source_url":"https://www.chcachem.com/news/2026-11-06-china-soda-ash-market-update"},{"label":"APAC Regional Benchmark (CFR Tokyo, Light)","price":"212.33 USD/MT (-3.78% QoQ)","usd_note":"ราคาเฉลี่ย Q3 2026 (CFR Tokyo — ภูมิภาคอื่น ใช้เพื่อบริบทเท่านั้น)","period":"Q3 2026 (ก.ย. 2026)","source_name":"ChemAnalyst","source_url":"https://www.chemanalyst.com/Pricing-data/soda-ash-76"},{"label":"ASEAN Reference (Indonesia)","price":"259.00 USD/MT","usd_note":"ราคาตลาดอินโดนีเซีย เดือน ก.ย. 2026 (บริบทภูมิภาคเท่านั้น)","period":"ก.ย. 2026","source_name":"IMARC Group","source_url":"https://www.imarcgroup.com/soda-ash-pricing-report"}],"decision_cards":[{"priority_status":"ต้องตัดสินใจ","priority_level":"critical","company":"BGA","headline":"LME Aluminium Cash พุ่ง 3,184.50 USD/t (+2.56%) ขณะ Backwardation ถ่าง +353.00 USD/t","financial_impact":"ซื้อ Spot แพงกว่าสัญญา 3-Month (2,831.50 USD/t) ถึง 353.00 USD/t กดดัน Gross Margin และดึง Working Capital เพิ่มขึ้นทันที","recommended_action":"ทบทวนสัดส่วนสัญญาซื้อ Spot เทียบ 3M Forward และตรวจสอบ Lead Time/สต็อกคงเหลือ (รอข้อมูลภายในบริษัท)","owner":"CFO & COO","review_point":"ทบทวนเมื่อ LME 3M–Cash Spread > 250 USD/t หรือสต็อก LME ต่ำกว่า 220,000 ตัน"},{"priority_status":"ควรพิจารณา","priority_level":"warning","company":"ALL (KBI & BGA)","headline":"USD/THB จ่อแนวต้าน 34.00 THB/USD (33.95) ขณะภาคก่อสร้างเอกชนไทย Q3 หด -0.5%","financial_impact":"ต้นทุนนำเข้าสกุล USD สูงขึ้นราว +1.10% MoM ในภาวะที่ตลาดอสังหาฯ ในประเทศชะลอตัว ทำให้ส่งผ่านราคาขายได้จำกัด","recommended_action":"ประเมิน Net USD Exposure ของ KBI/BGA และเตรียมกรอบบริหารความเสี่ยง FX ก่อนประชุม Fed ธ.ค. (รอข้อมูลภายในบริษัท)","owner":"CFO","review_point":"ทบทวนเมื่อ USD/THB ปิดเหนือ 34.00 THB/USD หรือก่อนประชุม FOMC ธ.ค."},{"priority_status":"เฝ้าระวัง","priority_level":"watch","company":"BGA","headline":"อินเดียเปิดไต่สวน Anti-Dumping (AD) อะลูมิเนียม Extrusion จากไทยและ 3 ประเทศ","financial_impact":"เสี่ยงกระทบยอดส่งออกไปอินเดีย (หากมี) และเสี่ยงเกิดสินค้าจีน/เวียดนามไหลย้อนเข้ามาตัดราคาในตลาดไทย/อาเซียน","recommended_action":"ตรวจสอบสัดส่วนรายได้ส่งออกอินเดีย พิกัดสินค้า และเตรียมข้อมูลต้นทุนการผลิตไว้ล่วงหน้า (รอข้อมูลภายในบริษัท)","owner":"CEO & ฝ่ายขาย","review_point":"ติดตามประกาศเบื้องต้นของ DGTR อินเดีย และการเปลี่ยนแปลงราคาเสนอขายในอาเซียน"}],"executive_3rows":[{"num":1,"label":"SITUATION — สถานการณ์สำคัญ","headline":"ตลาดปิดวันเสาร์ อ้างอิงราคาปิดศุกร์ 20 พ.ย. 2026: บาทจ่อ 34.00, LME Cash พุ่ง +2.56%, Brent อ่อนลง -14.93% MoM","detail":"ดอลลาร์แข็งค่าสูงสุดรอบ 19 เดือน (โอกาส Fed ขึ้นดอกเบี้ย ธ.ค. 96%) กดดัน USD/THB ที่ 33.95 และทองคำร่วง 2.8% ขณะที่ LME Aluminium Cash ดีดตัวสู่ 3,184.50 USD/t สวนทาง Brent ที่ลดลงต่อเนื่อง 3 สัปดาห์เหลือ 92.57 USD/bbl และ Soda Ash FOB China (General Proxy ต.ค. 2026) ทรงตัวที่ 156.23 USD/MT"},{"num":2,"label":"BUSINESS IMPACT — ผลกระทบต่อ KBI / BGA","headline":"BGA เผชิญแรงกดดันต้นทุน Spot + คดี AD อินเดีย สูงกว่า KBI ที่ได้อานิสงส์ Brent และ Soda Ash ทรงตัวต่ำ","detail":"ทั้งสองบริษัทรับแรงต้านจากอุปสงค์อสังหาฯ ไทย Q3 (-0.6% YoY) และบาทอ่อน 33.95 แต่ BGA มีความเสี่ยง Margin/Working Capital เพิ่มจาก LME Backwardation +353.00 USD/t และ AD อินเดีย ส่วน KBI ได้แรงหนุนจาก Brent อ่อนตัวและ Soda Ash FOB China 156.23 USD/MT (ผลสุทธิรอข้อมูลสัญญาและ Hedging ภายในบริษัท)"},{"num":3,"label":"MANAGEMENT RESPONSE — สิ่งที่ผู้บริหารควรทำ","headline":"เร่งตรวจสอบ Exposure จริงก่อนตัดสินใจ: คุม LME 3M vs Spot, เช็ก Net FX และจับจองระวางเรือ ธ.ค.","detail":"CFO & COO ตรวจสอบสต็อก-สูตรราคา LME ของ BGA และ Net USD Exposure ของกลุ่มก่อนตัดสินใจล็อกราคาใดๆ; ฝ่ายขาย BGA ตรวจยอดส่งออกอินเดีย; ฝ่ายโลจิสติกส์จองระวางเรือก่อนสายเรือเก็บ PSS ยุโรป 1,000–1,600 USD/FEU ในเดือน ธ.ค."}],"lme_60d_series":[{"d":"2026-09-22","cash":3242.0,"m3":3264.0,"stock":242125},{"d":"2026-09-24","cash":3228.0,"m3":3252.5,"stock":241375},{"d":"2026-09-28","cash":3248.5,"m3":3252.0,"stock":241375},{"d":"2026-09-30","cash":3204.0,"m3":3210.0,"stock":241375},{"d":"2026-10-02","cash":3109.5,"m3":3122.0,"stock":240375},{"d":"2026-10-06","cash":3134.5,"m3":3148.5,"stock":238875},{"d":"2026-10-08","cash":3060.5,"m3":3069.0,"stock":238875},{"d":"2026-10-12","cash":3055.0,"m3":3060.0,"stock":238625},{"d":"2026-10-15","cash":2999.0,"m3":2994.5,"stock":238125},{"d":"2026-10-19","cash":3019.0,"m3":3012.0,"stock":236375},{"d":"2026-10-22","cash":3033.0,"m3":3008.0,"stock":236025},{"d":"2026-10-26","cash":3047.5,"m3":3027.0,"stock":234050},{"d":"2026-10-29","cash":3071.0,"m3":3064.0,"stock":231675},{"d":"2026-11-02","cash":3095.0,"m3":3060.0,"stock":230775},{"d":"2026-11-05","cash":3160.0,"m3":3097.5,"stock":228475},{"d":"2026-11-09","cash":3147.0,"m3":3059.5,"stock":226975},{"d":"2026-11-11","cash":3223.5,"m3":3064.0,"stock":226725},{"d":"2026-11-13","cash":3150.5,"m3":3018.0,"stock":224150},{"d":"2026-11-16","cash":3332.0,"m3":3020.0,"stock":221900},{"d":"2026-11-17","cash":3060.5,"m3":2940.0,"stock":220350},{"d":"2026-11-18","cash":3095.0,"m3":2865.0,"stock":226150},{"d":"2026-11-19","cash":3105.0,"m3":2845.0,"stock":224425},{"d":"2026-11-20","cash":3184.5,"m3":2831.5,"stock":223525}],"news":[{"id":"n1","tier":"top_alert","title":"LME Aluminium Cash พุ่ง +2.56% สู่ 3,184.50 USD/t ขณะสต็อกต่ำ 223,525 ตัน","priority_tier":"FX, Energy, Raw Materials, Industry Demand","company":"BGA","published_at":"2026-11-20","what":"LME Cash-Settlement พุ่งขึ้น 79.50 USD/t ในวันศุกร์ ขณะสัญญา 3-Month อ่อนลงเหลือ 2,831.50 USD/t ดัน Backwardation แตะ +353.00 USD/t","so_what":"เพิ่มต้นทุนการซื้ออะลูมิเนียม Spot ของ BGA และกดดัน Working Capital","financial":"ต้นทุนวัตถุดิบ Spot สูงกว่า 3M กว่า 12.4% (รอข้อมูลภายในบริษัท: สัญญาสูตรราคา LME และสต็อก)","now_what":"ตรวจสอบสัดส่วน Spot vs 3M กับฝ่ายจัดซื้อ","owner":"COO & CFO","source_name":"Westmetall / AL Circle","source_url":"https://www.westmetall.com/en/markdaten.php?action=table&field=LME_Al_cash"},{"id":"n2","tier":"top_alert","title":"ดอลลาร์แข็งค่าสูงสุดรอบ 19 เดือน กดดันบาทอ่อนจ่อ 34.00 THB/USD และทองคำโลกร่วง 2.8%","priority_tier":"FX, Energy, Raw Materials, Industry Demand","company":"ALL","published_at":"2026-11-21","what":"CME FedWatch ประเมินโอกาส 96% ที่ Fed จะขึ้นดอกเบี้ย 0.25% ใน ธ.ค. หนุนดอลลาร์แข็งค่าสูงสุดในรอบ 19 เดือน กดดันทั้งบาทอ่อนค่าใกล้ 34.00 THB/USD และ Spot Gold ร่วง 2.8% สู่ 3,518.50 USD/oz (อีกทั้งแรงซื้อทองคำในประเทศช่วงราคาลดลงยิ่งเพิ่มความต้องการดอลลาร์)","so_what":"เพิ่มต้นทุนนำเข้าสกุล USD ของทั้ง KBI และ BGA ในรูปเงินบาท","financial":"กระทบ Cost of Imports และ Margin ขายในประเทศ (รอข้อมูลภายในบริษัท: Net FX Exposure)","now_what":"ทบทวนสถานะ FX Net Exposure ก่อนระดับ 34.00","owner":"CFO","source_name":"The Nation Thailand / BigGo Finance","source_url":"https://www.nationthailand.com/business/trading-investment/40073748"},{"id":"n3","tier":"top_alert","title":"อินเดียเปิดไต่สวน Anti-Dumping (AD) อะลูมิเนียม Extrusion จากไทยและ 3 ประเทศ","priority_tier":"Logistics, Trade Policy, Interest Rates, Regional Economy","company":"BGA","published_at":"2026-11-19","what":"DGTR อินเดียเปิดสอบสวน AD สินค้า Aluminium Extrusion Profiles จากจีน มาเลเซีย เวียดนาม และไทย","so_what":"กระทบความเสี่ยงส่งออกอินเดียของ BGA และการทะลักของสินค้าแข่งราคาในอาเซียน","financial":"อาจกดดัน Export Revenue และราคาขายในประเทศหากคู่แข่งระบายสินค้าเข้าไทย (รอข้อมูลภายในบริษัท)","now_what":"ตรวจสัดส่วนยอดขายไปอินเดียและเตรียมข้อมูลต้นทุน","owner":"CEO & ฝ่ายขาย","source_name":"AL Circle","source_url":"https://www.alcircle.com/news/india-probes-aluminium-dumping-by-china-malaysia-vietnam-thailand-vedanta-hindalco-shares-eyed-122026"},{"id":"n4","tier":"watchlist","title":"Brent ปิด 92.57 USD/bbl ร่วงรายสัปดาห์ต่อเนื่องสัปดาห์ที่ 3 จากคาดการณ์ซัพพลายเกินดุล","priority_tier":"FX, Energy, Raw Materials, Industry Demand","company":"ALL","published_at":"2026-11-20","what":"IEA คาดตลาดน้ำมันเกินดุล ~2 ล้านบาร์เรล/วัน ใน Q4 และการส่งออกผ่านฮอร์มุซฟื้นตัว กด Brent ลดลง -14.93% MoM","so_what":"ช่วยลดแรงกดดันต้นทุนพลังงานเตาหลอมกระจก (KBI) และค่าขนส่ง (KBI/BGA)","financial":"หนุนโอกาสประหยัด Energy & Freight Cost ใน Q1/2027 (รอข้อมูลภายในบริษัท: สูตรค่าพลังงาน)","now_what":"เจรจาปรับลด Fuel Surcharge กับผู้ขนส่ง","owner":"COO & จัดซื้อ","source_name":"Trading Economics","source_url":"https://tradingeconomics.com/commodity/brent-crude-oil"},{"id":"n5","tier":"watchlist","title":"GDP ไทย Q3/2026 โต +2.9% YoY แต่ภาคอสังหาฯ หดตัว -0.6% และก่อสร้างเอกชน -0.5%","priority_tier":"Logistics, Trade Policy, Interest Rates, Regional Economy","company":"ALL","published_at":"2026-11-18","what":"NESDC เผยการลงทุนเครื่องจักรโต +19.1% และก่อสร้างรัฐ +0.6% แต่ที่อยู่อาศัยหด -1.0% และอาคารพาณิชย์ -1.7%","so_what":"กดดันอุปสงค์กระจกและโปรไฟล์อะลูมิเนียมในภาคอสังหาฯ เอกชนไทย","financial":"จำกัด Volume Growth และเพิ่มความเสี่ยง AR Aging กลุ่มผู้รับเหมา/อสังหาฯ","now_what":"ปรับโฟกัสการขายสู่โครงการรัฐ/โรงงานอุตสาหกรรม และตรวจเครดิตลูกหนี้","owner":"CEO & CFO","source_name":"Houseviser (NESDC)","source_url":"https://houseviser.com/news/thailand-gdp-q3-2026-property-drag"},{"id":"n6","tier":"watchlist","title":"Drewry WCI ลดลง 3% เหลือ 4,176 USD/FEU แต่จ่อเก็บค่าธรรมเนียม PSS ยุโรป ธ.ค. นี้","priority_tier":"Logistics, Trade Policy, Interest Rates, Regional Economy","company":"ALL","published_at":"2026-11-19","what":"เส้นทาง Transpacific ลดลง แต่ Asia–Med พุ่ง +6% พร้อมสายเรือประกาศ PSS 1,000–1,600 USD/FEU เริ่ม ธ.ค. และตู้เปล่าคืนเอเชียล่าช้า","so_what":"เพิ่มความเสี่ยงค่าระวางส่งออกและ Lead Time ตู้คอนเทนเนอร์ของ KBI/BGA","financial":"อาจเพิ่ม Freight Cost และยืด Cash Conversion Cycle ช่วงปลายปี","now_what":"เร่งจองระวางเรือก่อน ธ.ค. และเผื่อเวลาคืนตู้เปล่า","owner":"COO & โลจิสติกส์","source_name":"Drewry","source_url":"https://www.drewry.co.uk/maritime-research-opinion-browser/world-container-index-assessed-by-drewry"},{"id":"n7","tier":"watchlist","title":"ตลาดอะลูมิเนียมโลกเสี่ยงขาดดุลถึงปี 2028 จากเพดานผลิตจีน 45 ล้านตัน/ปี","priority_tier":"FX, Energy, Raw Materials, Industry Demand","company":"BGA","published_at":"2026-11-19","what":"Emkay Global คาดขาดดุล ~400,000 ตัน/ปี ในปี 2027–2028 ขณะ Alumina อยู่ที่ ~398 USD/t และโรงหลอมอินโดนีเซีย/ตะวันออกกลางฟื้นตัวช้า","so_what":"สร้างแรงหนุนเชิงโครงสร้างต่อต้นทุนวัตถุดิบระยะกลางของ BGA","financial":"จำกัดโอกาสที่ราคา LME จะลงลึกในระยะยาว","now_what":"จัดทำแผน Dual-Sourcing และกรอบจัดซื้อปี 2027","owner":"COO","source_name":"AL Circle","source_url":"https://www.alcircle.com/news/aluminium-supply-crunch-to-persist-till-2028-driven-by-chinas-45mt-cap-low-stocks-122031"},{"id":"n8","tier":"watchlist","title":"Soda Ash FOB China ทรงตัวที่ 156.23 USD/MT (ต.ค. 2026) ขณะโรงงาน Float Glass จีนเข้าซ่อมบำรุง","priority_tier":"FX, Energy, Raw Materials, Industry Demand","company":"KBI","published_at":"2026-11-09","what":"Procurement Resource รายงานราคา FOB China (General) เดือน ต.ค. 2026 อยู่ที่ 156.23 USD/MT (0.00% MoM) และสต็อกในจีนเพิ่มขึ้นหลังสายผลิตกระจกแผ่นเข้าโหมด Cold Repair","so_what":"เป็นบริบทบวกต่ออำนาจต่อรองการจัดซื้อ Soda Ash ของ KBI ในภูมิภาคเอเชีย","financial":"ช่วยจำกัดแรงกดดันต้นทุนวัตถุดิบหลักในระยะสั้น (รอข้อมูลภายในบริษัท: ราคา Landed Cost ของ KBI)","now_what":"ขอ Quotation เปรียบเทียบจากหลายซัพพลายเออร์และไม่เร่งล็อกสัญญาระยะยาวเกินไป","owner":"ฝ่ายจัดซื้อ KBI","source_name":"Procurement Resource / Chcachem","source_url":"https://www.procurementresource.com/resource-center/soda-ash-price-trends"},{"id":"n9","tier":"watchlist","title":"EU เตรียมขยาย CBAM ครอบคลุมสินค้าปลายน้ำอะลูมิเนียม/เหล็ก 180 รายการในปี 2028","priority_tier":"ESG, Carbon Regulation, Technology, Competitor Expansion","company":"BGA","published_at":"2026-11-19","what":"คณะกรรมาธิการยุโรปเสนอขยาย CBAM สู่สินค้าแปรรูปปลายน้ำเพื่อป้องกันการหลบเลี่ยงภาษีคาร์บอน พร้อมเพิ่ม Default Mark-up 10%→30%","so_what":"กระทบความสามารถแข่งขันส่งออกของ BGA ไปตลาด EU หรือ OEM ที่ส่งออกไป EU","financial":"เสี่ยงถูกบวกค่าปรับ Default Carbon หากไม่มีข้อมูล Embedded Emissions จริง","now_what":"เริ่มเก็บข้อมูล Carbon Intensity และแหล่งที่มาวัตถุดิบจากซัพพลายเออร์","owner":"COO & ฝ่ายความยั่งยืน","source_name":"AL Circle","source_url":"https://www.alcircle.com/news/eu-industrial-emissions-fall-3-3-as-cbam-expansion-eyes-more-aluminium-products-122022"}],"impact_matrix":[{"driver":"USD/THB อ่อนค่าใกล้ 34.00 (33.95 THB/USD)","kbi_indicator":"🟡 ต้องติดตาม","kbi_text":"เพิ่มต้นทุนนำเข้า Soda Ash และค่าขนส่งสกุล USD ในรูปเงินบาท แต่รายได้ส่งออกช่วยชดเชยบางส่วน (รอข้อมูลภายใน: Net FX Exposure)","bga_indicator":"🟡 ต้องติดตาม","bga_text":"เพิ่มต้นทุนนำเข้าวัตถุดิบอะลูมิเนียมสกุล USD ในรูปบาท ขณะที่ตลาดก่อสร้างในประเทศยังชะลอตัว (รอข้อมูลภายใน: FX Hedge)","management_implication":"CFO ตรวจสอบ Net USD Exposure ของทั้ง KBI และ BGA เพื่อประเมินความจำเป็นในการจัดการความเสี่ยงค่าเงินก่อนประชุม Fed ธ.ค."},{"driver":"Brent Oil อ่อนลงสู่ 92.57 USD/bbl (-14.93% MoM)","kbi_indicator":"🟢 ผลกระทบเชิงบวก","kbi_text":"ช่วยบรรเทาแรงกดดันต้นทุนพลังงานเตาหลอมกระจกและค่าขนส่งระยะกลาง แม้ราคายังสูงกว่าปีก่อน +47.97%","bga_indicator":"🟢 ผลกระทบเชิงบวก","bga_text":"ช่วยลดแรงกดดันค่าขนส่งและพลังงานในกระบวนการผลิต/รีดอะลูมิเนียม","management_implication":"ฝ่ายจัดซื้อเจรจาปรับลด Fuel Surcharge ตามรอบราคาพลังงาน และหลีกเลี่ยงการล็อกสัญญาพลังงานระยะยาวในช่วงขาลง"},{"driver":"LME Aluminium Cash 3,184.50 USD/t (+2.56%) & Backwardation +353.00 USD/t","kbi_indicator":"⚪ ไม่มีผลกระทบโดยตรงที่ยืนยันได้","kbi_text":"KBI ไม่ได้ใช้อะลูมิเนียมเป็นวัตถุดิบหลักในการผลิตกระจกแผ่น","bga_indicator":"🔴 ผลกระทบเชิงลบสูง","bga_text":"ราคา Spot สูงกว่า 3-Month (2,831.50 USD/t) ถึง 353.00 USD/t กดดันต้นทุนวัตถุดิบ Gross Margin และ Working Capital หากพึ่งพาการซื้อแบบ Prompt/Spot","management_implication":"COO และ CFO ตรวจสอบสูตรราคาในสัญญาซื้อ (Spot vs 3M) และระดับสต็อกจริงก่อนพิจารณาปรับแผนสั่งซื้อ"},{"driver":"Soda Ash FOB China 156.23 USD/MT (General Proxy ต.ค. 2026) & ซัพพลายจีนเพียงพอ","kbi_indicator":"🟢 ผลกระทบเชิงบวก","kbi_text":"ราคา FOB China ทรงตัว 0.00% MoM จากภาวะซัพพลายล้นตลาดในจีน ช่วยคุมแรงกดดันต้นทุนวัตถุดิบหลัก (รอข้อมูลภายใน: Landed Cost ของ KBI)","bga_indicator":"⚪ ไม่มีผลกระทบโดยตรงที่ยืนยันได้","bga_text":"BGA ไม่ได้ใช้ Soda Ash เป็นวัตถุดิบหลัก","management_implication":"ฝ่ายจัดซื้อ KBI ใช้ระดับ FOB China (156.23 USD/MT) เป็นข้อมูลเปรียบเทียบต่อรองกับราคาเสนอขายจริงของซัพพลายเออร์"},{"driver":"อสังหาฯ ไทย Q3 หดตัว -0.6% & คดี AD อะลูมิเนียมอินเดีย + PSS ค่าระวาง ธ.ค.","kbi_indicator":"🟡 ต้องติดตาม","kbi_text":"ก่อสร้างเอกชนชะลอ (-0.5%) กดดันยอดขายในประเทศ ขณะที่ PSS ค่าระวางยุโรปอาจกระทบต้นทุนส่งออก","bga_indicator":"🔴 ผลกระทบเชิงลบสูง","bga_text":"เผชิญทั้งอุปสงค์ก่อสร้างเอกชนอ่อนตัว และความเสี่ยงคดี AD อินเดียที่อาจทำให้สินค้าภูมิภาคไหลย้อนมาตัดราคาในไทย","management_implication":"CEO ขยายสัดส่วนการขายสู่กลุ่มโครงการรัฐ/อุตสาหกรรม (+19.1%) พร้อมให้ CFO คุม AR Aging และเร่งจองระวางเรือ"}],"management_actions":[{"priority":"P1","business":"BGA","action":"ตรวจสอบสัดส่วนสัญญาซื้อ LME Aluminium (Spot vs 3-Month) และระดับสต็อกคงคลังเพื่อประเมินผลกระทบ Backwardation +353.00 USD/t","owner":"CFO & COO","timeline":"ทันที (สัปดาห์นี้)","trigger":"Spread Cash–3M > 250.00 USD/t หรือสต็อก LME < 220,000 ตัน"},{"priority":"P1","business":"ALL (KBI & BGA)","action":"รวบรวม Net USD Cash Flow Exposure และสถานะ FX Forward คงเหลือเพื่อเตรียมทางเลือกบริหารความเสี่ยงค่าเงิน","owner":"CFO","timeline":"ทันที (ก่อน ธ.ค.)","trigger":"USD/THB ปิดเหนือ 34.00 THB/USD หรือก่อนประชุม Fed ธ.ค."},{"priority":"P2","business":"BGA","action":"ตรวจสอบยอดส่งออกไปอินเดีย พิกัด HS Code และเตรียมข้อมูลต้นทุนรองรับกรณี DGTR อินเดียไต่สวน Anti-Dumping Extrusion","owner":"CEO & ฝ่ายขาย","timeline":"ภายใน 2 สัปดาห์","trigger":"ประกาศไต่สวน/กำหนดอากรเบื้องต้นจาก DGTR อินเดีย"},{"priority":"P2","business":"KBI","action":"ขอ Quotation เปรียบเทียบ FOB/CIF Soda Ash รอบใหม่และเจรจาปรับลด Fuel Surcharge ตามแนวโน้ม Brent ที่ลดลง -14.93% MoM","owner":"COO & ฝ่ายจัดซื้อ","timeline":"ภายใน 2 สัปดาห์","trigger":"เมื่อได้รับใบเสนอราคางวด ธ.ค. หรือ Brent หลุด 90.00 USD/bbl"},{"priority":"P3","business":"ALL (KBI & BGA)","action":"เร่งจองระวางเรือส่งออกก่อนเก็บ PSS เดือน ธ.ค. และทบทวนวงเงินสินเชื่อลูกหนี้ภาคอสังหาฯ ในประเทศ (AR Aging)","owner":"COO & CFO","timeline":"ก่อน 1 ธ.ค. 2026","trigger":"ประกาศ PSS สายเรือ > 1,000 USD/FEU หรือลูกหนี้ค้างชำระ > 60 วัน"}]},{"date":"2026-11-20","display_date_th":"20 พ.ย. 2026 (ศ.)","month_key":"2026-11","month_label_th":"พฤศจิกายน 2026","report_time_bkk":"2026-11-20 08:00 ICT (UTC+7)","scheduled_slot_bkk":"08:00 ICT (UTC+7)","is_weekend":false,"is_holiday":false,"holiday_name_th":"","short_status_th":"ตลาดเปิด","market_status_overall":"วันทำการ • อ้างอิงราคาปิด 20 พ.ย. 2026","kpis":[{"id":"usd_thb","name":"USD/THB","category":"FX","unit":"THB/USD","company":"ALL","price":33.95,"price_display":"33.95","price_badge_th":"ราคาปิด ณ 20 พ.ย. 2026","price_precision_note":"BOT 33.953 / TE Spot 33.9510","price_basis":"Prior Close","price_type":"Weighted-avg Interbank / Spot Close","change_pct":-0.06,"change_display":"-0.06% DoD","comparison_base":"เทียบ 19 พ.ย. (33.9700)","observation_date":"2026-11-20","market_status":"ปิดตลาดแล้ว","data_quality":"VERIFIED CURRENT","financial_impact":"บาทอ่อนค่าใกล้ 34.00 THB/USD กดดันต้นทุนนำเข้าวัตถุดิบและพลังงานของ KBI/BGA แต่หนุนรายได้ส่งออก (รอข้อมูลภายใน: Net FX Exposure)","source_name":"BOT & Trading Economics","source_url":"https://www.bot.or.th/en/statistics/exchange-rate.html"},{"id":"brent_oil","name":"Brent Oil","category":"Energy","unit":"USD/bbl","company":"ALL","price":92.57,"price_display":"92.57","price_badge_th":"ราคาปิด ณ 20 พ.ย. 2026","price_precision_note":"Previous Close: 91.98 USD/bbl","price_basis":"Prior Close","price_type":"Front-Month Futures/CFD Close","change_pct":0.64,"change_display":"+0.64% DoD","comparison_base":"เทียบ 19 พ.ย. (91.98 USD/bbl)","observation_date":"2026-11-20","market_status":"ปิดตลาดแล้ว","data_quality":"VERIFIED CURRENT","financial_impact":"ดีดตัวเล็กน้อย +0.64% แต่รายเดือนยังลดลง -14.93% ช่วยลดแรงกดดันต้นทุนพลังงานของ KBI และ BGA (รอข้อมูลภายใน)","source_name":"Trading Economics","source_url":"https://tradingeconomics.com/commodity/brent-crude-oil"},{"id":"lme_aluminium","name":"LME Aluminium","category":"Raw Material","unit":"USD/t","company":"BGA","price":3184.5,"price_display":"3,184.50","price_badge_th":"ราคาปิด ณ 20 พ.ย. 2026","price_precision_note":"3M: 2,831.50 USD/t | Stock: 223,525 t","price_basis":"Prior Close","price_type":"LME Official Cash-Settlement","change_pct":2.56,"change_display":"+2.56% DoD","comparison_base":"เทียบ Cash 19 พ.ย. (3,105.00 USD/t)","observation_date":"2026-11-20","market_status":"ปิดตลาดแล้ว","data_quality":"VERIFIED CURRENT","financial_impact":"ราคา Cash พุ่ง +79.50 USD/t กดดันต้นทุน Prompt ของ BGA ขณะที่สัญญา 3M ถูกกว่า 353.00 USD/t (รอข้อมูลภายใน: สัญญาซื้อ & Hedging)","source_name":"Westmetall","source_url":"https://www.westmetall.com/en/markdaten.php?action=table&field=LME_Al_cash"},{"id":"soda_ash","name":"Soda Ash (FOB China)","category":"Raw Material","unit":"USD/MT","company":"KBI","price":156.23,"price_display":"156.23","price_badge_th":"ดัชนี ณ ต.ค. 2026","price_precision_note":"General Market Proxy (Dense ส.ค.: 161.00)","price_basis":"Monthly Benchmark","price_type":"FOB China Monthly Assessment","change_pct":0.0,"change_display":"0.00% MoM","comparison_base":"เทียบ ก.ย. 2026 (156.23 USD/MT)","observation_date":"October 2026","market_status":"รายเดือนล่าสุด","data_quality":"VERIFIED LATEST","financial_impact":"FOB China (General Proxy) ทรงตัวที่ 156.23 USD/MT เดือน ต.ค. 2026 เป็นสัญญาณทิศทางเท่านั้น ไม่ใช่ต้นทุน Landed ของ KBI (รอข้อมูลภายใน)","source_name":"Procurement Resource","source_url":"https://www.procurementresource.com/resource-center/soda-ash-price-trends"}],"soda_ash_supplementary_context":[{"label":"Soda Ash (Dense) — FOB China (งวดก่อนหน้า)","price":"161.00 USD/MT (-5.29% MoM จาก Jul 2026: 170.00 USD/MT)","usd_note":"เกรด Dense บนฐาน FOB China ล่าสุดเดือน ส.ค. 2026 (เก่ากว่า General ต.ค. 2026)","period":"August 2026","source_name":"Procurement Resource (Dense)","source_url":"https://www.procurementresource.com/resource-center/soda-ash-dense-price-trends"},{"label":"East China Domestic Reference (Dense / Light)","price":"RMB 1,150/MT (Dense) | RMB 1,000/MT (Light)","usd_note":"อ้างอิงในประเทศจีน (~172 USD / ~149 USD — ไม่ใช่ราคาส่งออก FOB)","period":"5 พ.ย. 2026","source_name":"Jinan ZZ / Chcachem","source_url":"https://www.chcachem.com/news/2026-11-06-china-soda-ash-market-update"}],"decision_cards":[{"priority_status":"ต้องตัดสินใจ","priority_level":"critical","company":"BGA","headline":"LME Aluminium Cash ดีด +2.56% สู่ 3,184.50 USD/t ดัน Backwardation แตะ +353.00 USD/t","financial_impact":"เพิ่มต้นทุนสั่งซื้อ Prompt/Spot ของ BGA สูงกว่าสัญญา 3-Month อย่างมีนัยสำคัญ","recommended_action":"ตรวจสอบสัญญาสูตรราคา Spot vs 3M และระดับสต็อกคงเหลือของ BGA (รอข้อมูลภายในบริษัท)","owner":"CFO & COO","review_point":"ทบทวนเมื่อ Cash–3M Spread > 250.00 USD/t"},{"priority_status":"ควรพิจารณา","priority_level":"warning","company":"ALL","headline":"USD/THB เคลื่อนไหวใกล้ 34.00 THB/USD (BOT 33.953)","financial_impact":"เพิ่มต้นทุนนำเข้าวัตถุดิบและค่าขนส่งสกุล USD ในรูปเงินบาทของทั้ง KBI และ BGA","recommended_action":"ตรวจสอบ Net USD Exposure และวงเงิน FX Forward ที่เหลืออยู่ (รอข้อมูลภายในบริษัท)","owner":"CFO","review_point":"ทบทวนเมื่อ USD/THB ทะลุ 34.00 THB/USD"},{"priority_status":"เฝ้าระวัง","priority_level":"watch","company":"ALL","headline":"สายเรือเตรียมเก็บ PSS ยุโรป 1,000–1,600 USD/FEU เริ่ม ธ.ค. 2026","financial_impact":"เสี่ยงดันค่าขนส่งส่งออกปลายปีสูงขึ้นแม้ดัชนี WCI รวมจะลดลง 3% WoW","recommended_action":"เร่งสรุปตารางส่งมอบและจองระวางเรือสำหรับออเดอร์เดือน ธ.ค.","owner":"COO & โลจิสติกส์","review_point":"ก่อนสิ้นเดือน พ.ย. 2026"}],"executive_3rows":[{"num":1,"label":"SITUATION — สถานการณ์สำคัญ","headline":"วันศุกร์ 20 พ.ย. LME Cash พุ่ง 3,184.50 USD/t (+2.56%), Brent 92.57 USD/bbl, บาททรงตัว 33.95","detail":"LME Backwardation กว้าง +353.00 USD/t ท่ามกลางสต็อกลดเหลือ 223,525 ตัน ขณะ Brent ลดลงต่อเนื่องสัปดาห์ที่ 3, USD/THB ใกล้แนวต้าน 34.00 และ Soda Ash FOB China (General Proxy) อยู่ที่ 156.23 USD/MT"},{"num":2,"label":"BUSINESS IMPACT — ผลกระทบต่อ KBI / BGA","headline":"BGA รับแรงกดดันต้นทุน Spot สูงกว่า KBI ที่ได้แรงช่วยจาก Brent และ Soda Ash ทรงตัว","detail":"BGA เสี่ยง Margin Compression จาก LME Cash และคดี AD อินเดีย ส่วน KBI รอข้อมูลสัญญา Soda Ash ภายในเทียบกับบาทอ่อน"},{"num":3,"label":"MANAGEMENT RESPONSE — สิ่งที่ผู้บริหารควรทำ","headline":"ตรวจสอบสต็อก-สัญญา LME, Net FX Exposure และจองระวางเรือล่วงหน้า","detail":"CFO และ COO ตรวจ Exposure และสัญญาซื้อภายในบริษัทให้ครบถ้วนก่อนปรับแผนจัดซื้อหรือบริหารความเสี่ยง"}],"lme_60d_series":[{"d":"2026-09-22","cash":3242.0,"m3":3264.0,"stock":242125},{"d":"2026-09-24","cash":3228.0,"m3":3252.5,"stock":241375},{"d":"2026-09-28","cash":3248.5,"m3":3252.0,"stock":241375},{"d":"2026-09-30","cash":3204.0,"m3":3210.0,"stock":241375},{"d":"2026-10-02","cash":3109.5,"m3":3122.0,"stock":240375},{"d":"2026-10-06","cash":3134.5,"m3":3148.5,"stock":238875},{"d":"2026-10-08","cash":3060.5,"m3":3069.0,"stock":238875},{"d":"2026-10-12","cash":3055.0,"m3":3060.0,"stock":238625},{"d":"2026-10-15","cash":2999.0,"m3":2994.5,"stock":238125},{"d":"2026-10-19","cash":3019.0,"m3":3012.0,"stock":236375},{"d":"2026-10-22","cash":3033.0,"m3":3008.0,"stock":236025},{"d":"2026-10-26","cash":3047.5,"m3":3027.0,"stock":234050},{"d":"2026-10-29","cash":3071.0,"m3":3064.0,"stock":231675},{"d":"2026-11-02","cash":3095.0,"m3":3060.0,"stock":230775},{"d":"2026-11-05","cash":3160.0,"m3":3097.5,"stock":228475},{"d":"2026-11-09","cash":3147.0,"m3":3059.5,"stock":226975},{"d":"2026-11-11","cash":3223.5,"m3":3064.0,"stock":226725},{"d":"2026-11-13","cash":3150.5,"m3":3018.0,"stock":224150},{"d":"2026-11-16","cash":3332.0,"m3":3020.0,"stock":221900},{"d":"2026-11-17","cash":3060.5,"m3":2940.0,"stock":220350},{"d":"2026-11-18","cash":3095.0,"m3":2865.0,"stock":226150},{"d":"2026-11-19","cash":3105.0,"m3":2845.0,"stock":224425},{"d":"2026-11-20","cash":3184.5,"m3":2831.5,"stock":223525}],"news":[{"id":"n1","tier":"top_alert","title":"LME Aluminium Cash พุ่ง +2.56% สู่ 3,184.50 USD/t ขณะสต็อกลดเหลือ 223,525 ตัน","priority_tier":"FX, Energy, Raw Materials, Industry Demand","company":"BGA","published_at":"2026-11-20","what":"Westmetall รายงานราคา Cash-Settlement พุ่งขึ้นจาก 3,105.00 เป็น 3,184.50 USD/t","so_what":"ต้นทุนอะลูมิเนียม Spot ของ BGA สูงกว่าสัญญา 3 เดือนถึง 353.00 USD/t","financial":"กดดัน Margin และ Working Capital หากไม่มีสัญญาอ้างอิง 3M (รอข้อมูลภายในบริษัท)","now_what":"ตรวจสอบสัญญาจัดซื้อและสัดส่วน Spot vs 3M","owner":"COO & CFO","source_name":"Westmetall","source_url":"https://www.westmetall.com/en/markdaten.php?action=table&field=LME_Al_cash"},{"id":"n2","tier":"top_alert","title":"ดอลลาร์แข็งค่าสูงสุดรอบ 19 เดือน กดดันบาทอ่อนจ่อ 34.00 THB/USD และทองคำโลกร่วง 2.8%","priority_tier":"FX, Energy, Raw Materials, Industry Demand","company":"ALL","published_at":"2026-11-20","what":"คาดการณ์ Fed ขึ้นดอกเบี้ย 0.25% ใน ธ.ค. หนุนดอลลาร์แข็งค่า กดดันทั้งบาทอ่อนค่าใกล้ 34.00 THB/USD และทองคำร่วงสู่ 3,518.50 USD/oz (แรงซื้อทองคำในประเทศช่วงราคาลงเพิ่มดีมานด์ดอลลาร์)","so_what":"เพิ่มต้นทุนนำเข้าสกุล USD ของทั้ง KBI และ BGA","financial":"เพิ่มความเสี่ยงต้นทุนนำเข้าในรูปเงินบาท (รอข้อมูลภายในบริษัท)","now_what":"ตรวจ Net FX Exposure ที่ระดับ 33.95–34.00","owner":"CFO","source_name":"The Nation Thailand / BigGo Finance","source_url":"https://www.nationthailand.com/business/trading-investment/40073748"},{"id":"n3","tier":"top_alert","title":"อินเดียเปิดไต่สวน Anti-Dumping อะลูมิเนียม Extrusion จากไทย จีน มาเลเซีย เวียดนาม","priority_tier":"Logistics, Trade Policy, Interest Rates, Regional Economy","company":"BGA","published_at":"2026-11-19","what":"DGTR อินเดียเริ่มสอบสวน AD ครอบคลุมสินค้าโปรไฟล์ก่อสร้างและอุตสาหกรรม","so_what":"กระทบความเสี่ยงส่งออกของ BGA และภาวะการแข่งขันในอาเซียน","financial":"เสี่ยงต่อรายได้ส่งออกอินเดียและแรงกดดันราคาขายในประเทศ","now_what":"ตรวจสอบยอดส่งออกไปอินเดียและเตรียมข้อมูลต้นทุน","owner":"CEO & ฝ่ายขาย","source_name":"AL Circle","source_url":"https://www.alcircle.com/news/india-probes-aluminium-dumping-by-china-malaysia-vietnam-thailand-vedanta-hindalco-shares-eyed-122026"},{"id":"n4","tier":"watchlist","title":"Brent ปิด 92.57 USD/bbl (+0.64%) แต่ยังอ่อนตัวลงรายสัปดาห์ต่อเนื่องเป็นสัปดาห์ที่ 3","priority_tier":"FX, Energy, Raw Materials, Industry Demand","company":"ALL","published_at":"2026-11-20","what":"ปริมาณส่งออกผ่านฮอร์มุซฟื้นตัวและ IEA คาดตลาดเกินดุลใน Q4","so_what":"เป็นสัญญาณบวกต่อแนวโน้มต้นทุนพลังงานของ KBI และโลจิสติกส์ของ BGA","financial":"ช่วยพยุง Gross Margin หากราคาน้ำมันทรงตัวต่ำกว่า 95.00 USD/bbl","now_what":"ติดตามประชุม OPEC+ และส่วนลด Fuel Surcharge","owner":"COO & จัดซื้อ","source_name":"Trading Economics","source_url":"https://tradingeconomics.com/commodity/brent-crude-oil"},{"id":"n5","tier":"watchlist","title":"Drewry WCI ลดลงสู่ 4,176 USD/FEU (-3% WoW) แต่สายเรือเตรียมเก็บ PSS ยุโรป ธ.ค. นี้","priority_tier":"Logistics, Trade Policy, Interest Rates, Regional Economy","company":"ALL","published_at":"2026-11-19","what":"เส้นทาง Transpacific อ่อนตัวลง แต่ Asia–Med พุ่ง +6% พร้อมประกาศ PSS 1,000–1,600 USD/FEU","so_what":"กระทบต้นทุนค่าขนส่งส่งออกและระยะเวลาคืนตู้คอนเทนเนอร์ของ KBI/BGA","financial":"เพิ่มความเสี่ยง Freight Cost ปลายปี","now_what":"จองระวางเรือล่วงหน้าสำหรับออเดอร์ส่งมอบ ธ.ค.","owner":"COO & โลจิสติกส์","source_name":"Drewry Maritime Research","source_url":"https://www.drewry.co.uk/maritime-research-opinion-browser/world-container-index-assessed-by-drewry"}],"impact_matrix":[{"driver":"USD/THB 33.95 (-0.06% DoD)","kbi_indicator":"🟡 ต้องติดตาม","kbi_text":"ต้นทุนนำเข้า Soda Ash ในรูปบาททรงตัวสูง (รอข้อมูลภายใน: Net FX)","bga_indicator":"🟡 ต้องติดตาม","bga_text":"ต้นทุนนำเข้าอะลูมิเนียมในรูปบาททรงตัวสูง (รอข้อมูลภายใน: Net FX)","management_implication":"CFO ติดตามแนวต้าน 34.00 THB/USD"},{"driver":"LME Aluminium Cash 3,184.50 USD/t (+2.56%)","kbi_indicator":"⚪ ไม่มีผลกระทบโดยตรงที่ยืนยันได้","kbi_text":"ไม่ใช่วัตถุดิบหลักของ KBI","bga_indicator":"🔴 ผลกระทบเชิงลบสูง","bga_text":"Backwardation +353.00 USD/t กดดันต้นทุน Prompt ของ BGA","management_implication":"COO ตรวจสัดส่วน Spot vs 3M"}],"management_actions":[{"priority":"P1","business":"BGA","action":"ทบทวนสัดส่วน Spot vs 3M Forward หลัง LME Backwardation ถ่างกว้าง +353.00 USD/t (รอข้อมูลภายใน)","owner":"CFO & COO","timeline":"ทันที","trigger":"Spread Cash–3M > 250.00 USD/t"},{"priority":"P1","business":"ALL","action":"ตรวจสอบ Net FX Exposure เพื่อเตรียมทางเลือกบริหารความเสี่ยงหาก USD/THB ทะลุ 34.00","owner":"CFO","timeline":"ทันที","trigger":"USD/THB > 34.00 THB/USD"}]}];

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
