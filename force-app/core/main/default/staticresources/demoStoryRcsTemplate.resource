<!DOCTYPE html>
<html lang="en" data-device="[[RCS_DEVICE]]" data-theme="[[RCS_THEME]]">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>2-Way RCS Simulator</title>
    <style>
      /* ------------------------------------------------------------------
         Cumulus RCS Simulator — device-gated chrome via html[data-device]
         Android (Google Messages) shipped in Phase A; iOS added in Phase C.
         ------------------------------------------------------------------ */
      * { box-sizing: border-box; margin: 0; padding: 0; }
      html, body { height: 100%; min-height: 0; }
      body {
        min-height: 100%;
        font-family: -apple-system, BlinkMacSystemFont, "SF Pro Text", "Segoe UI",
          Roboto, Helvetica, Arial, sans-serif;
        background: radial-gradient(ellipse 120% 80% at 50% 0%, #f4f2fb 0%, #ecebf4 45%, #e2e0eb 100%);
        color: #111;
        display: flex; align-items: center; justify-content: center;
        padding: 16px;
        overflow: auto;
      }

      .phone-shell {
        flex-shrink: 1;
        max-width: 100%;
        width: 440px;
        height: 96vh;
        max-height: 960px;
        margin: 0 auto;
        border-radius: 42px;
        border: 8px solid #1a1a24;
        background: #fff;
        display: flex;
        flex-direction: column;
        overflow: hidden;
        box-shadow: 0 24px 80px rgba(0,0,0,0.35), 0 0 0 1px rgba(255,255,255,0.06) inset;
      }

      /* Device gating: hide the other chrome's markup entirely. */
      html[data-device="android"] [data-chrome="ios"] { display: none !important; }
      html[data-device="ios"] [data-chrome="android"] { display: none !important; }

      /* ============================================================
         ANDROID CHROME (Google Messages)
         ============================================================ */
      html[data-device="android"] .phone-shell { border-color: #1e1e28; }

      .a-status {
        display: flex; justify-content: space-between; align-items: center;
        padding: 10px 18px 4px;
        font-size: 12px; color: #333; font-weight: 600;
      }
      .a-status .status-right { display: flex; gap: 6px; align-items: center; }
      .a-status svg { width: 14px; height: 14px; fill: currentColor; }

      .a-header {
        display: flex; align-items: center; gap: 10px;
        padding: 6px 12px 10px;
        border-bottom: 1px solid rgba(0,0,0,0.06);
        background: #fff;
      }
      .a-header .a-back { width: 28px; text-align: center; color: #444; font-size: 20px; cursor: default; user-select: none; }
      .a-header .a-avatar {
        width: 34px; height: 34px; border-radius: 50%;
        background: var(--rcs-brand, #2A94D6);
        color: #fff;
        display: flex; align-items: center; justify-content: center;
        font-weight: 700; font-size: 13px;
        overflow: hidden;
        flex-shrink: 0;
      }
      .a-header .a-avatar img { width: 100%; height: 100%; object-fit: cover; }
      .a-header .a-name {
        flex: 1; min-width: 0;
        display: flex; align-items: center; gap: 6px;
        font-size: 16px; font-weight: 500; color: #202124;
        overflow: hidden; text-overflow: ellipsis; white-space: nowrap;
      }
      .a-header .a-verified {
        width: 16px; height: 16px; flex-shrink: 0;
        color: #5f6368;
      }
      .a-header .a-verified svg { width: 100%; height: 100%; fill: currentColor; }
      .a-header .a-menu { color: #5f6368; font-size: 20px; user-select: none; padding: 4px; }

      .thread {
        flex: 1;
        overflow-y: auto;
        padding: 14px 12px 8px;
        display: flex; flex-direction: column;
        gap: 6px;
        background: #fff;
      }

      /* Rows + bubbles */
      .rcs-row { display: flex; }
      .rcs-row-bot { justify-content: flex-start; }
      .rcs-row-user { justify-content: flex-end; }

      .rcs-bubble {
        max-width: 78%;
        padding: 10px 14px;
        border-radius: 20px;
        font-size: 15px;
        line-height: 1.35;
        word-wrap: break-word;
        white-space: pre-wrap;
      }
      html[data-device="android"] .rcs-bubble-bot {
        background: #e8eaed; color: #202124;
        border-bottom-left-radius: 6px;
      }
      html[data-device="android"] .rcs-bubble-user {
        background: var(--rcs-brand, #2A94D6);
        color: #fff;
        border-bottom-right-radius: 6px;
      }

      /* Chip row (quick replies + suggested actions) */
      .rcs-chips-row {
        display: flex; flex-wrap: wrap;
        gap: 8px;
        padding: 4px 0 2px;
        max-width: 100%;
      }
      .rcs-chip {
        appearance: none;
        border: 1px solid rgba(0,0,0,0.14);
        background: #fff;
        color: var(--rcs-brand, #2A94D6);
        border-radius: 999px;
        padding: 8px 14px;
        font-size: 14px;
        font-weight: 500;
        cursor: default;
        white-space: nowrap;
        display: inline-flex;
        align-items: center;
        gap: 6px;
        line-height: 1;
      }
      .rcs-chip svg { flex-shrink: 0; }
      .rcs-chip-has-icon { padding-left: 10px; }
      html[data-device="android"] .rcs-chip {
        border-color: rgba(0,0,0,0.14);
      }

      /* Unsubscribe pill above composer */
      .a-unsub {
        display: flex; justify-content: center; align-items: center; gap: 6px;
        padding: 6px 10px;
        font-size: 12px; color: #5f6368;
      }
      .a-unsub .a-unsub-pill {
        background: #f1f3f4;
        padding: 6px 12px;
        border-radius: 999px;
        color: #1a73e8;
        cursor: default;
      }

      .composer {
        display: flex; align-items: center; gap: 8px;
        padding: 8px 10px 12px;
        border-top: 1px solid rgba(0,0,0,0.06);
        background: #fff;
      }
      .composer .c-icon {
        width: 34px; height: 34px; border-radius: 50%;
        background: #f1f3f4;
        display: flex; align-items: center; justify-content: center;
        color: #5f6368; flex-shrink: 0;
      }
      .composer .c-icon svg { width: 18px; height: 18px; fill: currentColor; }
      .composer .c-input {
        flex: 1;
        background: #f1f3f4;
        border-radius: 22px;
        padding: 10px 14px;
        font-size: 14px; color: #5f6368;
      }
      .composer .c-send {
        width: 34px; height: 34px; border-radius: 50%;
        background: var(--rcs-brand, #2A94D6);
        color: #fff;
        display: flex; align-items: center; justify-content: center;
        flex-shrink: 0;
      }
      .composer .c-send svg { width: 16px; height: 16px; fill: currentColor; }

      /* Click-to-reveal: rows added with .hidden-msg are fully collapsed
         (display: none) so they don't reserve layout space. When revealed
         they animate in from below. */
      .rcs-row.hidden-msg { display: none !important; }
      .rcs-row.just-revealed {
        animation: rcs-row-in 220ms ease forwards;
      }
      @keyframes rcs-row-in {
        from { opacity: 0; transform: translateY(8px); }
        to   { opacity: 1; transform: none; }
      }

      /* Rich cards */
      .rcs-card {
        max-width: 88%;
        background: #fff;
        border: 1px solid rgba(0,0,0,0.08);
        border-radius: 16px;
        overflow: hidden;
        box-shadow: 0 2px 8px rgba(0,0,0,0.06);
      }
      .rcs-card-vertical { display: flex; flex-direction: column; }
      .rcs-card-horizontal { display: flex; flex-direction: row; align-items: stretch; max-width: 92%; }
      .rcs-card-media { background: #f1f3f4; overflow: hidden; }
      .rcs-card-vertical .rcs-card-media img,
      .rcs-card-vertical .rcs-card-media video,
      .rcs-card-horizontal .rcs-card-media img,
      .rcs-card-horizontal .rcs-card-media video { width: 100%; height: 100%; display: block; object-fit: cover; background: #000; }
      .rcs-card-vertical .rcs-card-media-small  { height: 120px; }
      .rcs-card-vertical .rcs-card-media-medium { height: 180px; }
      .rcs-card-vertical .rcs-card-media-large  { height: 260px; }
      /* Horizontal cards: the media column must have an intrinsic height —
         min-height + flex-stretch is not enough when the card body is short
         (single-button rich card default), the img height:100% collapses to
         zero. Explicit height per size class keeps the image visible. */
      .rcs-card-horizontal .rcs-card-media { width: 40%; flex-shrink: 0; }
      .rcs-card-horizontal .rcs-card-media-small  { height: 110px; }
      .rcs-card-horizontal .rcs-card-media-medium { height: 140px; }
      .rcs-card-horizontal .rcs-card-media-large  { height: 180px; }
      .rcs-card-body { padding: 14px 16px; display: flex; flex-direction: column; gap: 6px; }
      .rcs-card-horizontal .rcs-card-body { flex: 1; }
      .rcs-card-title-text {
        font-size: 15px; font-weight: 600; color: #202124; margin: 0;
      }
      .rcs-card-desc {
        font-size: 14px; color: #3c4043; margin: 0;
        line-height: 1.4;
      }
      .rcs-card-buttons {
        display: flex; flex-direction: column; gap: 0;
        margin-top: 4px;
        border-top: 1px solid rgba(0,0,0,0.06);
      }
      .rcs-card-btn {
        appearance: none; background: none; border: none;
        padding: 12px 4px;
        font-size: 14px; font-weight: 500;
        color: var(--rcs-brand, #2A94D6);
        text-align: left;
        border-bottom: 1px solid rgba(0,0,0,0.06);
        cursor: default;
        transition: background 120ms ease;
      }
      .rcs-card-btn:last-child { border-bottom: none; }

      /* Carousel */
      .rcs-carousel {
        display: flex;
        gap: 10px;
        overflow-x: auto;
        overflow-y: hidden;
        scroll-snap-type: x mandatory;
        padding-bottom: 4px;
        max-width: 100%;
        width: 100%;
      }
      .rcs-carousel-item {
        flex: 0 0 78%;
        max-width: 78%;
        scroll-snap-align: start;
      }
      .rcs-carousel::-webkit-scrollbar { height: 4px; }
      .rcs-carousel::-webkit-scrollbar-thumb { background: rgba(0,0,0,0.15); border-radius: 4px; }

      /* Primary tap-hint intentionally removed — the pulsing ring was more
         distracting than helpful. The primary chip/button still receives the
         tap-target behavior; SEs learn the convention from the config panel
         (★ Primary badge) rather than from a visual on the phone. */

      /* Interactive chip / button — tap = highlight + brand tint */
      .rcs-chip, .rcs-card-btn { cursor: pointer; transition: background 140ms ease, color 140ms ease, border-color 140ms ease; }
      .rcs-chip.is-selected {
        background: var(--rcs-brand, #2A94D6);
        color: #fff;
        border-color: var(--rcs-brand, #2A94D6);
      }
      .rcs-card-btn.is-selected {
        background: color-mix(in srgb, var(--rcs-brand, #2A94D6) 12%, transparent);
      }
      .rcs-chip:active, .rcs-card-btn:active {
        transform: scale(0.98);
      }

      /* Preview hint (only when thread is empty of revealed content) */
      .empty-hint {
        text-align: center; color: #9aa0a6; font-size: 12px; padding: 24px 12px;
      }

      /* ============================================================
         Brand-info card (cold-open) — mirrors the "brand card" a
         recipient sees when they tap the sender's name in the thread.
         ============================================================ */
      .rcs-brand-card {
        position: absolute;
        inset: 0;
        z-index: 30;
        overflow-y: auto;
        cursor: pointer;
        transition: opacity 260ms ease, transform 260ms ease;
        background: #fff;
      }
      /* iOS variant keeps the SF Pro contact-sheet look */
      .rcs-detail-ios {
        min-height: 100%;
        background: #f2f2f7;
        display: flex;
        flex-direction: column;
        padding: 20px 18px 32px;
        gap: 12px;
        font-family: -apple-system, BlinkMacSystemFont, "SF Pro Text", "Segoe UI",
          Roboto, Helvetica, Arial, sans-serif;
      }
      .rcs-brand-card.is-dismissed {
        opacity: 0;
        transform: translateY(-8px);
        pointer-events: none;
      }
      .rcs-detail-back {
        color: var(--rcs-brand, #2A94D6);
        font-size: 30px;
        line-height: 1;
        width: 36px; height: 36px;
        display: flex; align-items: center; justify-content: center;
        border-radius: 50%;
        background: rgba(0,0,0,0.05);
        cursor: default;
        user-select: none;
        flex-shrink: 0;
      }
      .rcs-detail-header {
        display: flex; flex-direction: column; align-items: center;
        gap: 6px;
        padding: 4px 0 12px;
        text-align: center;
      }
      .rcs-detail-icon {
        width: 74px; height: 74px;
        border-radius: 18px;      /* squircle-like on iOS */
        background: var(--rcs-brand, #2A94D6);
        color: #fff;
        display: flex; align-items: center; justify-content: center;
        font-family: "Open Sans", sans-serif;
        font-weight: 700;
        font-size: 20px;
        overflow: hidden;
        margin-bottom: 6px;
        box-shadow: 0 4px 14px rgba(0,0,0,0.10);
        position: relative;
      }
      .rcs-detail-icon img {
        width: 100%; height: 100%; object-fit: cover; display: block;
      }
      .rcs-detail-icon img + .rcs-brand-card-logo-fallback { display: none; }
      .rcs-detail-name {
        font-size: 24px;
        font-weight: 700;
        color: #000;
        margin: 0;
        letter-spacing: -0.4px;
      }
      .rcs-detail-usage {
        font-size: 11px;
        font-weight: 600;
        letter-spacing: 1.5px;
        color: rgba(60,60,67,0.6);
        text-transform: uppercase;
      }
      .rcs-detail-verified {
        font-size: 13px;
        color: rgba(60,60,67,0.6);
      }
      .rcs-detail-toggles {
        background: #fff;
        border-radius: 12px;
        padding: 4px 16px;
      }
      .rcs-detail-toggle-row {
        display: flex; align-items: center; justify-content: space-between;
        padding: 12px 0;
        font-size: 15px; color: #000;
        border-bottom: 0.5px solid rgba(60,60,67,0.16);
      }
      .rcs-detail-toggle-row:last-child { border-bottom: none; }
      .rcs-detail-toggle {
        width: 44px; height: 26px;
        background: rgba(120,120,128,0.32);
        border-radius: 999px;
        position: relative;
        flex-shrink: 0;
      }
      .rcs-detail-toggle-thumb {
        position: absolute;
        top: 2px; left: 2px;
        width: 22px; height: 22px;
        background: #fff;
        border-radius: 50%;
        box-shadow: 0 2px 4px rgba(0,0,0,0.15);
      }
      .rcs-detail-section-heading {
        font-size: 13px;
        font-weight: 400;
        color: #000;
        margin: 12px 4px 4px;
        letter-spacing: -0.1px;
      }
      .rcs-detail-card {
        background: #fff;
        border-radius: 12px;
        padding: 12px 16px;
      }
      .rcs-detail-about {
        margin: 0;
        font-size: 15px;
        color: #000;
        line-height: 1.4;
      }
      .rcs-detail-card-list { padding: 0 16px; }
      .rcs-detail-list-row {
        padding: 10px 0;
        border-bottom: 0.5px solid rgba(60,60,67,0.16);
      }
      .rcs-detail-list-row:last-child { border-bottom: none; }
      .rcs-detail-list-label {
        font-size: 12px;
        color: rgba(60,60,67,0.6);
        margin-bottom: 2px;
      }
      .rcs-detail-list-value {
        font-size: 15px;
        color: var(--rcs-brand, #2A94D6);
        word-break: break-word;
      }
      .rcs-detail-btn {
        display: block;
        width: 100%;
        background: #fff;
        border: none;
        border-radius: 12px;
        padding: 14px 16px;
        margin-top: 10px;
        font-size: 15px;
        color: var(--rcs-brand, #2A94D6);
        cursor: default;
        text-align: center;
        font-family: inherit;
      }
      .rcs-detail-btn-danger { color: #ff453a; }

      /* Spotlight — parent tells us to highlight the message the SE is editing.
         Applied to .rcs-row (rows are detached from their parent .rcs-msg-group
         at boot and re-appended directly to the thread, so we can't rely on
         the group container to carry the highlight). */
      .rcs-msg-group,
      .rcs-row {
        transition: box-shadow 200ms ease, background 200ms ease;
        border-radius: 12px;
      }
      .rcs-msg-group.is-spotlit,
      .rcs-row.is-spotlit {
        background: rgba(42, 148, 214, 0.10);
        box-shadow: 0 0 0 2px rgba(42, 148, 214, 0.45);
        animation: rcs-spotlight-pulse 1.4s ease;
      }
      @keyframes rcs-spotlight-pulse {
        0%   { background: rgba(42, 148, 214, 0.25); box-shadow: 0 0 0 3px rgba(42, 148, 214, 0.55); }
        60%  { background: rgba(42, 148, 214, 0.14); box-shadow: 0 0 0 2px rgba(42, 148, 214, 0.4); }
        100% { background: rgba(42, 148, 214, 0.00); box-shadow: 0 0 0 0 rgba(42, 148, 214, 0);   }
      }

      /* Action toast (simulates cross-app hand-off for URL/dial/location/calendar) */
      .rcs-toast {
        position: absolute;
        left: 50%;
        bottom: 92px;
        transform: translate(-50%, 12px);
        background: rgba(20, 20, 24, 0.92);
        color: #fff;
        padding: 10px 16px;
        border-radius: 22px;
        font-size: 13px;
        max-width: 82%;
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
        opacity: 0;
        pointer-events: none;
        z-index: 20;
        box-shadow: 0 4px 20px rgba(0,0,0,0.25);
      }
      .rcs-toast-in {
        animation: rcs-toast-in 200ms ease forwards;
      }
      .rcs-toast-out {
        animation: rcs-toast-out 240ms ease forwards;
      }
      @keyframes rcs-toast-in {
        from { opacity: 0; transform: translate(-50%, 12px); }
        to   { opacity: 1; transform: translate(-50%, 0); }
      }
      @keyframes rcs-toast-out {
        from { opacity: 1; transform: translate(-50%, 0); }
        to   { opacity: 0; transform: translate(-50%, 12px); }
      }
      .phone-shell { position: relative; }  /* anchor for absolute toast */

      /* ============================================================
         iOS CHROME (Apple Messages) — activated when html[data-device="ios"]
         RCS on iPhone renders green (like SMS) but with rich features,
         centered brand-avatar header, and a "Text Message · RCS" placeholder.
         ============================================================ */
      html[data-device="ios"] body {
        background: radial-gradient(ellipse 120% 80% at 50% 0%, #f0f0f5 0%, #e5e5eb 50%, #d8d8e0 100%);
      }
      html[data-device="ios"] .phone-shell {
        border-color: #d8d8dc;
        border-width: 6px;
      }

      .i-status {
        display: flex; justify-content: space-between; align-items: center;
        padding: 12px 22px 6px;
        font-size: 15px; font-weight: 600; color: #000;
      }
      .i-status-right { display: flex; gap: 5px; align-items: center; color: #000; }
      .i-status-right svg { height: 12px; width: auto; fill: currentColor; }

      .i-header {
        display: flex; align-items: center; gap: 6px;
        padding: 4px 12px 12px;
        position: relative;
        background: rgba(247, 247, 250, 0.9);
        backdrop-filter: blur(20px);
        -webkit-backdrop-filter: blur(20px);
        border-bottom: 0.5px solid rgba(0,0,0,0.12);
      }
      .i-back {
        color: #007aff;
        font-size: 32px;
        line-height: 1;
        cursor: default; user-select: none;
        width: 40px; text-align: left;
        flex-shrink: 0;
        margin-top: 6px;
      }
      .i-brand-block {
        flex: 1;
        display: flex; flex-direction: column;
        align-items: center; justify-content: center;
        gap: 2px;
        min-width: 0;
      }
      .i-avatar {
        width: 34px; height: 34px;
        /* iOS uses a squircle (rounded square), not a circle, for RBM brand icons */
        border-radius: 9px;
        background: var(--rcs-brand, #2A94D6);
        color: #fff;
        display: flex; align-items: center; justify-content: center;
        font-weight: 700; font-size: 13px;
        overflow: hidden;
        margin-bottom: 2px;
      }
      .i-avatar img { width: 100%; height: 100%; object-fit: cover; }
      .i-brand-name {
        display: flex; align-items: center; gap: 2px;
        font-size: 11px; color: #000;
        white-space: nowrap;
      }
      .i-brand-chevron {
        color: rgba(60,60,67,0.5);
        font-size: 13px;
      }
      /* Balance the back button so brand block stays centered */
      .i-header::after {
        content: "";
        width: 40px;
        flex-shrink: 0;
      }

      /* iOS bubbles */
      html[data-device="ios"] .rcs-bubble {
        border-radius: 18px;
        max-width: 74%;
      }
      html[data-device="ios"] .rcs-bubble-bot {
        background: #e5e5ea; color: #000;
        border-bottom-left-radius: 4px;
      }
      html[data-device="ios"] .rcs-bubble-user {
        /* RCS on iOS renders green (distinct from blue iMessage) */
        background: #34c759; color: #fff;
        border-bottom-right-radius: 4px;
      }

      /* iOS chip row */
      html[data-device="ios"] .rcs-chips-row {
        flex-direction: column;
        align-items: flex-start;
        gap: 4px;
        margin-left: 8px;
      }
      html[data-device="ios"] .rcs-chip {
        border: none;
        background: transparent;
        color: #007aff;
        padding: 2px 0;
        font-size: 15px;
      }
      html[data-device="ios"] .rcs-chip.is-selected {
        background: transparent;
        color: #007aff;
        font-weight: 600;
        text-decoration: underline;
      }
      /* iOS action-hint appears only when a chip row is actually rendered.
         For simplicity we show it always in iOS mode; if no chips, it's harmless. */
      .i-actions-hint {
        text-align: center;
        font-size: 11px;
        color: rgba(60,60,67,0.6);
        padding: 4px 12px 0;
      }

      /* iOS cards match Android styling (rich cards look similar) but with
         green button text to match iOS RCS convention. */
      html[data-device="ios"] .rcs-card-btn {
        color: #007aff;
      }
      html[data-device="ios"] .rcs-card-btn.is-selected {
        background: rgba(0, 122, 255, 0.1);
      }

      /* iOS composer */
      .i-composer {
        display: flex; align-items: center; gap: 8px;
        padding: 8px 10px 16px;
        border-top: 0.5px solid rgba(0,0,0,0.12);
        background: rgba(247, 247, 250, 0.9);
        backdrop-filter: blur(20px);
        -webkit-backdrop-filter: blur(20px);
      }
      .i-composer-plus {
        width: 34px; height: 34px; border-radius: 50%;
        background: #e5e5ea;
        color: #8e8e93;
        display: flex; align-items: center; justify-content: center;
        font-size: 22px; font-weight: 300;
        flex-shrink: 0;
      }
      .i-composer-input {
        flex: 1;
        background: #fff;
        border: 0.5px solid rgba(60,60,67,0.18);
        border-radius: 18px;
        padding: 8px 14px;
        font-size: 15px; color: rgba(60,60,67,0.5);
      }
      .i-composer-mic {
        width: 34px; height: 34px;
        display: flex; align-items: center; justify-content: center;
        color: #8e8e93;
        flex-shrink: 0;
      }
      .i-composer-mic svg { width: 20px; height: 20px; fill: currentColor; }

      /* ============================================================
         DARK MODE — applied via html[data-theme="dark"], works with
         either Android or iOS chrome. Mirrors the OS-level dark theme.
         Only the phone chrome + thread go dark; the outer workspace
         behind the phone stays light so the demo reads cleanly.
         ============================================================ */
      html[data-theme="dark"] .phone-shell {
        background: #000;
        border-color: #0a0a0a;
      }

      /* Android dark */
      html[data-theme="dark"][data-device="android"] .a-status { color: #e8eaed; }
      html[data-theme="dark"][data-device="android"] .a-header {
        background: #0f0f14;
        border-bottom-color: rgba(255,255,255,0.08);
      }
      html[data-theme="dark"][data-device="android"] .a-header .a-name { color: #e8eaed; }
      html[data-theme="dark"][data-device="android"] .a-menu,
      html[data-theme="dark"][data-device="android"] .a-back { color: #b8bcc4; }
      html[data-theme="dark"][data-device="android"] .thread { background: #0a0a0e; }
      html[data-theme="dark"][data-device="android"] .rcs-bubble-bot {
        background: #2c2c30; color: #e8eaed;
      }
      html[data-theme="dark"][data-device="android"] .a-unsub { color: #9aa0a6; }
      html[data-theme="dark"][data-device="android"] .a-unsub-pill {
        background: #1f2024; color: #8ab4f8;
      }
      html[data-theme="dark"][data-device="android"] .composer {
        background: #0f0f14; border-top-color: rgba(255,255,255,0.08);
      }
      html[data-theme="dark"][data-device="android"] .composer .c-input {
        background: #1f2024; color: #9aa0a6;
      }
      html[data-theme="dark"][data-device="android"] .composer .c-icon {
        background: #1f2024; color: #b8bcc4;
      }

      /* iOS dark */
      html[data-theme="dark"][data-device="ios"] .i-status { color: #fff; }
      html[data-theme="dark"][data-device="ios"] .i-header {
        background: rgba(15, 15, 20, 0.9);
        border-bottom-color: rgba(255,255,255,0.12);
      }
      html[data-theme="dark"][data-device="ios"] .i-brand-name { color: #fff; }
      html[data-theme="dark"][data-device="ios"] .i-brand-chevron { color: rgba(255,255,255,0.45); }
      html[data-theme="dark"][data-device="ios"] .thread { background: #000; }
      html[data-theme="dark"][data-device="ios"] .rcs-bubble-bot {
        background: #2c2c2e; color: #fff;
      }
      html[data-theme="dark"][data-device="ios"] .i-actions-hint { color: rgba(235,235,245,0.55); }
      html[data-theme="dark"][data-device="ios"] .i-composer {
        background: rgba(15, 15, 20, 0.9);
        border-top-color: rgba(255,255,255,0.12);
      }
      html[data-theme="dark"][data-device="ios"] .i-composer-input {
        background: #1c1c1e;
        border-color: rgba(255,255,255,0.14);
        color: rgba(235,235,245,0.55);
      }
      html[data-theme="dark"][data-device="ios"] .i-composer-plus,
      html[data-theme="dark"][data-device="ios"] .i-composer-mic { color: #8e8e93; }
      html[data-theme="dark"][data-device="ios"] .i-composer-plus { background: #2c2c2e; }

      /* Rich cards in dark mode — dark card surface, light text, keep media background dark */
      html[data-theme="dark"] .rcs-card {
        background: #1c1c1e;
        border-color: rgba(255,255,255,0.08);
        box-shadow: 0 2px 8px rgba(0,0,0,0.4);
      }
      html[data-theme="dark"] .rcs-card-title-text { color: #f2f2f7; }
      html[data-theme="dark"] .rcs-card-desc { color: rgba(235,235,245,0.7); }
      html[data-theme="dark"] .rcs-card-buttons { border-top-color: rgba(255,255,255,0.10); }
      html[data-theme="dark"] .rcs-card-btn {
        color: #8ab4f8;
        border-bottom-color: rgba(255,255,255,0.10);
      }
      html[data-theme="dark"][data-device="ios"] .rcs-card-btn { color: #0a84ff; }
      html[data-theme="dark"] .rcs-card-btn.is-selected {
        background: rgba(138, 180, 248, 0.15);
      }
      html[data-theme="dark"] .rcs-card-media { background: #0a0a0c; }

      /* Chips in dark mode */
      html[data-theme="dark"][data-device="android"] .rcs-chip {
        background: #1c1c1e;
        border-color: rgba(255,255,255,0.14);
        color: #8ab4f8;
      }
      html[data-theme="dark"][data-device="ios"] .rcs-chip { color: #0a84ff; }
      html[data-theme="dark"] .rcs-chip.is-selected {
        background: #0a84ff; color: #fff; border-color: #0a84ff;
      }

      /* Contact-detail sheet in dark mode (matches real iOS 18) */
      html[data-theme="dark"] .rcs-detail-ios { background: #000; }
      html[data-theme="dark"] .rcs-brand-card { background: #000; }
      html[data-theme="dark"] .rcs-detail-name { color: #fff; }
      html[data-theme="dark"] .rcs-detail-usage,
      html[data-theme="dark"] .rcs-detail-verified { color: rgba(235,235,245,0.55); }
      html[data-theme="dark"] .rcs-detail-toggles,
      html[data-theme="dark"] .rcs-detail-card,
      html[data-theme="dark"] .rcs-detail-btn { background: #1c1c1e; }
      html[data-theme="dark"] .rcs-detail-toggle-row { color: #fff; border-bottom-color: rgba(255,255,255,0.12); }
      html[data-theme="dark"] .rcs-detail-section-heading { color: #fff; }
      html[data-theme="dark"] .rcs-detail-about { color: #fff; }
      html[data-theme="dark"] .rcs-detail-list-row { border-bottom-color: rgba(255,255,255,0.12); }
      html[data-theme="dark"] .rcs-detail-list-label { color: rgba(235,235,245,0.55); }
      html[data-theme="dark"] .rcs-detail-back { background: rgba(255,255,255,0.1); color: #fff; }

      /* Once an SE taps a chip in a suggested-actions row, the row is "consumed" —
         real RCS clears these chips after tap so they don't linger. */
      .rcs-row.rcs-consumed,
      .rcs-msg-group.rcs-consumed {
        opacity: 0;
        max-height: 0;
        margin: 0;
        overflow: hidden;
        transition: opacity 200ms ease, max-height 220ms ease, margin 220ms ease;
      }

      /* Typing indicator — 3 pulsing dots in a bot-side bubble that we show
         briefly before injecting the real brand message. */
      .rcs-typing {
        display: inline-flex;
        align-items: center;
        gap: 4px;
        padding: 12px 16px;
        border-radius: 20px;
        border-bottom-left-radius: 6px;
      }
      html[data-device="android"] .rcs-typing { background: #e8eaed; }
      html[data-device="ios"] .rcs-typing { background: #e5e5ea; }
      html[data-theme="dark"][data-device="android"] .rcs-typing { background: #2c2c30; }
      html[data-theme="dark"][data-device="ios"] .rcs-typing { background: #2c2c2e; }
      /* When "you" (the recipient) are typing, the bubble sits right-side */
      .rcs-typing-user { border-bottom-left-radius: 20px; border-bottom-right-radius: 6px; }
      .rcs-typing-dot {
        width: 7px; height: 7px;
        border-radius: 50%;
        background: rgba(0,0,0,0.45);
        animation: rcs-typing-bounce 1.2s infinite ease-in-out;
      }
      html[data-theme="dark"] .rcs-typing-dot { background: rgba(255,255,255,0.55); }
      .rcs-typing-dot:nth-child(2) { animation-delay: 0.15s; }
      .rcs-typing-dot:nth-child(3) { animation-delay: 0.3s; }
      @keyframes rcs-typing-bounce {
        0%, 60%, 100% { transform: translateY(0); opacity: 0.5; }
        30%           { transform: translateY(-4px); opacity: 1; }
      }

      /* User echo bubble with "Selected Option" caption. The stack hugs
         the bubble's natural width (align-items: flex-end shrinks it to
         content), then the tag sits below flush-right. */
      .rcs-user-stack {
        display: inline-flex;
        flex-direction: column;
        align-items: flex-end;
        gap: 2px;
        max-width: 82%;
      }
      .rcs-user-stack .rcs-bubble { max-width: 100%; }
      /* Short echo-bubbles (from tapping a chip) shouldn't wrap; long typed
         messages (the mortgage question etc.) should. Toggle via class. */
      .rcs-user-stack .rcs-bubble.rcs-bubble-nowrap { white-space: nowrap; }
      .rcs-user-tag {
        font-size: 11px;
        color: rgba(60,60,67,0.6);
        padding-right: 4px;
        white-space: nowrap;
      }
      html[data-theme="dark"] .rcs-user-tag { color: rgba(235,235,245,0.55); }

      /* ============================================================
         Device-gated detail views: only one variant renders at a time
         based on the html[data-device] attribute.
         ============================================================ */
      html[data-device="android"] .rcs-detail-ios { display: none !important; }
      html[data-device="ios"]     .rcs-detail-android { display: none !important; }

      /* ============================================================
         Android detail (Google Messages "contact info" pattern):
         top bar → wide banner → circular avatar overlapping →
         brand name w/ verified checkmark → round action row → sections
         ============================================================ */
      .rcs-detail-android {
        display: flex;
        flex-direction: column;
        min-height: 100%;
        background: #fff;
        font-family: "Google Sans", Roboto, system-ui, -apple-system, sans-serif;
        color: #202124;
      }
      .rcs-detail-a-topbar {
        display: flex; align-items: center; gap: 18px;
        padding: 14px 16px;
        font-size: 20px;
        color: #202124;
      }
      .rcs-detail-a-back { font-size: 22px; line-height: 1; user-select: none; }
      .rcs-detail-a-title { font-weight: 500; font-size: 17px; flex: 1; }
      .rcs-detail-a-kebab { font-size: 20px; color: #5f6368; user-select: none; }
      .rcs-detail-a-banner {
        width: 100%; height: 140px;
        background: linear-gradient(180deg, #7fc0ea 0%, #4a9ed5 100%);
        overflow: hidden; position: relative;
        flex-shrink: 0;
      }
      .rcs-detail-a-banner img {
        position: absolute; inset: 0;
        width: 100%; height: 100%; object-fit: cover;
      }
      .rcs-detail-a-logo {
        width: 96px; height: 96px;
        border-radius: 50%;
        background: var(--rcs-brand, #2A94D6);
        border: 4px solid #fff;
        margin: -48px auto 0;
        overflow: hidden;
        display: flex; align-items: center; justify-content: center;
        color: #fff;
        font-family: "Open Sans", sans-serif;
        font-weight: 700; font-size: 22px;
        box-shadow: 0 3px 10px rgba(0,0,0,0.10);
        position: relative; z-index: 1;
        flex-shrink: 0;
      }
      .rcs-detail-a-logo img { width: 100%; height: 100%; object-fit: cover; display: block; }
      .rcs-detail-a-logo img + .rcs-brand-card-logo-fallback { display: none; }
      .rcs-detail-a-name {
        text-align: center;
        margin: 14px 20px 4px;
        font-size: 22px; font-weight: 500;
        display: flex; align-items: center; justify-content: center; gap: 6px;
      }
      .rcs-detail-a-tagline {
        text-align: center;
        font-size: 14px; color: #5f6368;
        margin: 0 20px 22px;
      }
      .rcs-detail-a-actions {
        display: flex; gap: 8px;
        justify-content: center;
        padding: 0 16px 20px;
      }
      .rcs-detail-a-action {
        display: flex; flex-direction: column; align-items: center; gap: 6px;
        min-width: 68px;
        font-size: 12px; color: #1a73e8;
      }
      .rcs-detail-a-action-icon {
        width: 48px; height: 48px;
        border-radius: 50%;
        background: #e8f0fe;
        display: flex; align-items: center; justify-content: center;
        color: #1a73e8;
      }
      /* Tabs (Info / Options) */
      .rcs-detail-a-tabs {
        display: flex;
        border-bottom: 1px solid #e8eaed;
      }
      .rcs-detail-a-tab {
        flex: 1;
        background: none;
        border: none;
        padding: 14px 0;
        font-family: inherit;
        font-size: 14px;
        color: #5f6368;
        cursor: pointer;
        position: relative;
      }
      .rcs-detail-a-tab.is-active {
        color: #1a73e8;
        font-weight: 500;
      }
      .rcs-detail-a-tab.is-active::after {
        content: "";
        position: absolute; left: 0; right: 0; bottom: -1px;
        height: 3px; background: #1a73e8;
      }
      /* Info-tab rows (icon-left, value-above-label) */
      .rcs-detail-a-tab-panel { padding: 4px 0; }
      .rcs-detail-a-info-row {
        display: flex;
        align-items: center;
        gap: 22px;
        padding: 14px 20px;
        border-bottom: 1px solid #e8eaed;
      }
      .rcs-detail-a-info-row:last-child { border-bottom: none; }
      .rcs-detail-a-info-icon {
        color: #5f6368;
        flex-shrink: 0;
      }
      .rcs-detail-a-info-value {
        font-size: 15px;
        color: #202124;
        margin-bottom: 2px;
      }
      .rcs-detail-a-info-label {
        font-size: 12px;
        color: #5f6368;
      }
      /* Dark mode overrides */
      html[data-theme="dark"] .rcs-detail-a-tab { color: rgba(232,234,237,0.6); }
      html[data-theme="dark"] .rcs-detail-a-tab.is-active { color: #8ab4f8; }
      html[data-theme="dark"] .rcs-detail-a-tab.is-active::after { background: #8ab4f8; }
      html[data-theme="dark"] .rcs-detail-a-tabs { border-bottom-color: rgba(255,255,255,0.08); }
      html[data-theme="dark"] .rcs-detail-a-info-row { border-bottom-color: rgba(255,255,255,0.08); }
      html[data-theme="dark"] .rcs-detail-a-info-value { color: #e8eaed; }
      html[data-theme="dark"] .rcs-detail-a-info-label,
      html[data-theme="dark"] .rcs-detail-a-info-icon { color: rgba(232,234,237,0.6); }
      html[data-theme="dark"] .rcs-detail-a-tagline { color: rgba(232,234,237,0.6); }
      .rcs-detail-a-section {
        padding: 14px 20px;
        border-top: 1px solid #e8eaed;
      }
      .rcs-detail-a-section-title {
        font-size: 13px; font-weight: 500; color: #1a73e8;
        margin-bottom: 8px;
      }
      .rcs-detail-a-section-body {
        font-size: 14px; line-height: 1.5; color: #3c4043;
      }
      .rcs-detail-a-row {
        display: flex; flex-direction: column;
        padding: 8px 0;
      }
      .rcs-detail-a-row-label { font-size: 12px; color: #5f6368; }
      .rcs-detail-a-row-value { font-size: 14px; color: #202124; word-break: break-word; }

      /* Android detail — dark mode */
      html[data-theme="dark"] .rcs-detail-android { background: #202124; color: #e8eaed; }
      html[data-theme="dark"] .rcs-detail-a-topbar { color: #e8eaed; }
      html[data-theme="dark"] .rcs-detail-a-logo { border-color: #202124; }
      html[data-theme="dark"] .rcs-detail-a-name { color: #e8eaed; }
      html[data-theme="dark"] .rcs-detail-a-verified,
      html[data-theme="dark"] .rcs-detail-a-verified-line { color: #9aa0a6; }
      html[data-theme="dark"] .rcs-detail-a-action { color: #8ab4f8; }
      html[data-theme="dark"] .rcs-detail-a-action-icon { background: #202b3e; color: #8ab4f8; }
      html[data-theme="dark"] .rcs-detail-a-section { border-top-color: rgba(255,255,255,0.08); }
      html[data-theme="dark"] .rcs-detail-a-section-title { color: #8ab4f8; }
      html[data-theme="dark"] .rcs-detail-a-section-body { color: #e8eaed; }
      html[data-theme="dark"] .rcs-detail-a-row-label { color: rgba(232,234,237,0.6); }
      html[data-theme="dark"] .rcs-detail-a-row-value { color: #e8eaed; }

      /* Recipient compose typing + send + agent typing indicator (mirrors the
         SMS/WhatsApp sims). Composer input gets a blinking caret while typing. */
      .c-input.is-typing, .i-composer-input.is-typing { color: inherit; }
      .rcs-caret {
        display: inline-block; width: 2px; height: 1.05em; background: currentColor;
        margin-left: 1px; vertical-align: -2px; animation: rcsblink 1s steps(1) infinite;
      }
      @keyframes rcsblink { 50% { opacity: 0; } }
      .c-send.rcs-ready, .i-composer-mic.rcs-ready { color: var(--rcs-brand, #2a94d6); cursor: pointer; }
      .rcs-chip, .rcs-card-btn { cursor: pointer; }
      .rcs-typing-dots { display: inline-flex; gap: 4px; align-items: center; padding: 2px 0; }
      .rcs-typing-dots .tdot {
        width: 7px; height: 7px; border-radius: 50%; background: currentColor; opacity: 0.5;
        animation: rcstbounce 1.2s infinite ease-in-out;
      }
      .rcs-typing-dots .tdot:nth-child(2) { animation-delay: 0.18s; }
      .rcs-typing-dots .tdot:nth-child(3) { animation-delay: 0.36s; }
      @keyframes rcstbounce { 0%,60%,100%{ transform: translateY(0); opacity:.4 } 30%{ transform: translateY(-4px); opacity:.9 } }
    </style>
  </head>
  <body style="--rcs-brand: [[RCS_BRAND_COLOR]];">
    <div class="phone-shell" id="phoneShell">
      <!-- ==================== BRAND-INFO CARD (on-demand) ====================
           Hidden by default. Shown when the recipient taps the sender name/
           avatar at the top of the thread — mirrors the "brand card" a
           recipient sees when they tap into the sender in Google Messages
           / iMessage. Tap anywhere → dismisses and returns to the thread. -->
      <div class="rcs-brand-card is-dismissed" id="rcsBrandCard" role="dialog" aria-label="Brand info" aria-hidden="true">
      <!-- iOS variant (dark-mode-friendly contact sheet, matches iPhone screenshot) -->
      <div class="rcs-detail-ios" data-chrome="ios">
        <div class="rcs-detail-back" aria-hidden="true">‹</div>
        <div class="rcs-detail-header">
          <div class="rcs-detail-icon">
            <img id="rcsBrandCardLogo" src="[[RCS_BRAND_LOGO_URL]]" alt="" onerror="this.style.display='none'" />
            <span class="rcs-brand-card-logo-fallback" aria-hidden="true">[[RCS_BRAND_INITIALS]]</span>
          </div>
          <h2 class="rcs-detail-name">[[RCS_BRAND_NAME]]</h2>
          <div class="rcs-detail-usage">PROMOTIONAL</div>
          <div class="rcs-detail-verified">Verified by Salesforce</div>
        </div>

        <div class="rcs-detail-toggles">
          <div class="rcs-detail-toggle-row">
            <span>Hide Alerts</span>
            <span class="rcs-detail-toggle" aria-hidden="true"><span class="rcs-detail-toggle-thumb"></span></span>
          </div>
          <div class="rcs-detail-toggle-row">
            <span>Send Read Receipts</span>
            <span class="rcs-detail-toggle" aria-hidden="true"><span class="rcs-detail-toggle-thumb"></span></span>
          </div>
        </div>

        <h3 class="rcs-detail-section-heading">About</h3>
        <div class="rcs-detail-card">
          <p class="rcs-detail-about">[[RCS_BRAND_DESC]]</p>
        </div>

        <h3 class="rcs-detail-section-heading">Details</h3>
        <div class="rcs-detail-card rcs-detail-card-list">
          <div class="rcs-detail-list-row">
            <div class="rcs-detail-list-label">Website</div>
            <div class="rcs-detail-list-value">[[RCS_BRAND_WEBSITE]]</div>
          </div>
          <div class="rcs-detail-list-row">
            <div class="rcs-detail-list-label">Email</div>
            <div class="rcs-detail-list-value">[[RCS_BRAND_EMAIL]]</div>
          </div>
          <div class="rcs-detail-list-row">
            <div class="rcs-detail-list-label">Terms &amp; Conditions</div>
            <div class="rcs-detail-list-value">[[RCS_BRAND_TERMS_URL]]</div>
          </div>
        </div>

        <button type="button" class="rcs-detail-btn">Report Spam</button>
        <button type="button" class="rcs-detail-btn rcs-detail-btn-danger">Block this Sender</button>
      </div>

      <!-- Android variant (Google Messages "contact info" pattern) -->
      <div class="rcs-detail-android" data-chrome="android">
        <div class="rcs-detail-a-topbar">
          <span class="rcs-detail-a-back" aria-hidden="true">←</span>
          <span class="rcs-detail-a-title">Info &amp; options</span>
          <span class="rcs-detail-a-kebab" aria-hidden="true">⋮</span>
        </div>
        <div class="rcs-detail-a-banner">
          <img src="[[RCS_BRAND_BANNER_URL]]" alt="" onerror="this.style.display='none'" />
        </div>
        <div class="rcs-detail-a-logo">
          <img src="[[RCS_BRAND_LOGO_URL]]" alt="" onerror="this.style.display='none'" />
          <span class="rcs-brand-card-logo-fallback" aria-hidden="true">[[RCS_BRAND_INITIALS]]</span>
        </div>
        <h2 class="rcs-detail-a-name">[[RCS_BRAND_NAME]]</h2>
        <div class="rcs-detail-a-tagline">[[RCS_BRAND_DESC]]</div>

        <div class="rcs-detail-a-actions">
          <div class="rcs-detail-a-action"><div class="rcs-detail-a-action-icon"><svg viewBox="0 0 24 24" width="22" height="22"><path fill="currentColor" d="M20 15.5c-1.2 0-2.5-.2-3.6-.6a1 1 0 0 0-1 .2l-2.2 2.2a15 15 0 0 1-6.6-6.6l2.2-2.2a1 1 0 0 0 .2-1c-.4-1.2-.6-2.4-.6-3.6a1 1 0 0 0-1-1H4a1 1 0 0 0-1 1c0 9.4 7.6 17 17 17a1 1 0 0 0 1-1v-3.4a1 1 0 0 0-1-1z"/></svg></div><span>Call</span></div>
          <div class="rcs-detail-a-action"><div class="rcs-detail-a-action-icon"><svg viewBox="0 0 24 24" width="22" height="22"><path fill="currentColor" d="M12 2a10 10 0 1 0 10 10A10 10 0 0 0 12 2zm7 9h-3.1a15.9 15.9 0 0 0-1.3-4.6A8 8 0 0 1 19 11zM12 4a13.7 13.7 0 0 1 2 7h-4a13.7 13.7 0 0 1 2-7zM4.3 13H8a15.9 15.9 0 0 0 1.3 4.6A8 8 0 0 1 4.3 13z"/></svg></div><span>Website</span></div>
          <div class="rcs-detail-a-action"><div class="rcs-detail-a-action-icon"><svg viewBox="0 0 24 24" width="22" height="22"><path fill="currentColor" d="M20 4H4c-1.1 0-1.99.9-1.99 2L2 18c0 1.1.9 2 2 2h16c1.1 0 2-.9 2-2V6c0-1.1-.9-2-2-2zm0 4l-8 5-8-5V6l8 5 8-5v2z"/></svg></div><span>Email</span></div>
        </div>

        <div class="rcs-detail-a-tabs" role="tablist">
          <button type="button" class="rcs-detail-a-tab is-active" role="tab" aria-selected="true">Info</button>
          <button type="button" class="rcs-detail-a-tab" role="tab" aria-selected="false">Options</button>
        </div>

        <div class="rcs-detail-a-tab-panel">
          <div class="rcs-detail-a-info-row">
            <span class="rcs-detail-a-info-icon" aria-hidden="true"><svg viewBox="0 0 24 24" width="20" height="20"><path fill="currentColor" d="M20 15.5c-1.2 0-2.5-.2-3.6-.6a1 1 0 0 0-1 .2l-2.2 2.2a15 15 0 0 1-6.6-6.6l2.2-2.2a1 1 0 0 0 .2-1c-.4-1.2-.6-2.4-.6-3.6a1 1 0 0 0-1-1H4a1 1 0 0 0-1 1c0 9.4 7.6 17 17 17a1 1 0 0 0 1-1v-3.4a1 1 0 0 0-1-1z"/></svg></span>
            <div>
              <div class="rcs-detail-a-info-value">[[RCS_BRAND_PHONE]]</div>
              <div class="rcs-detail-a-info-label">From U.S. and Canada</div>
            </div>
          </div>
          <div class="rcs-detail-a-info-row">
            <span class="rcs-detail-a-info-icon" aria-hidden="true"><svg viewBox="0 0 24 24" width="20" height="20"><path fill="currentColor" d="M12 2a10 10 0 1 0 10 10A10 10 0 0 0 12 2zm7 9h-3.1a15.9 15.9 0 0 0-1.3-4.6A8 8 0 0 1 19 11zM12 4a13.7 13.7 0 0 1 2 7h-4a13.7 13.7 0 0 1 2-7zM4.3 13H8a15.9 15.9 0 0 0 1.3 4.6A8 8 0 0 1 4.3 13z"/></svg></span>
            <div>
              <div class="rcs-detail-a-info-value">[[RCS_BRAND_WEBSITE]]</div>
              <div class="rcs-detail-a-info-label">Website</div>
            </div>
          </div>
          <div class="rcs-detail-a-info-row">
            <span class="rcs-detail-a-info-icon" aria-hidden="true"><svg viewBox="0 0 24 24" width="20" height="20"><path fill="currentColor" d="M20 4H4c-1.1 0-1.99.9-1.99 2L2 18c0 1.1.9 2 2 2h16c1.1 0 2-.9 2-2V6c0-1.1-.9-2-2-2zm0 4l-8 5-8-5V6l8 5 8-5v2z"/></svg></span>
            <div>
              <div class="rcs-detail-a-info-value">[[RCS_BRAND_EMAIL]]</div>
              <div class="rcs-detail-a-info-label">Email</div>
            </div>
          </div>
        </div>
      </div>
      </div>

      <!-- ==================== ANDROID CHROME ==================== -->
      <div class="a-status" data-chrome="android">
        <span>9:41</span>
        <div class="status-right" aria-hidden="true">
          <svg viewBox="0 0 24 24"><path d="M2 22h20V2H2v20zm2-2V4h16v16H4z"/></svg>
          <svg viewBox="0 0 24 24"><path d="M12 3C7 3 2.7 5 0 8l12 14L24 8C21.3 5 17 3 12 3z"/></svg>
          <svg viewBox="0 0 24 24"><path d="M15.67 4H14V2h-4v2H8.33C7.6 4 7 4.6 7 5.33v15.33C7 21.4 7.6 22 8.33 22h7.33c.74 0 1.34-.6 1.34-1.33V5.33C17 4.6 16.4 4 15.67 4z"/></svg>
        </div>
      </div>

      <header class="a-header" data-chrome="android">
        <div class="a-back" aria-hidden="true">‹</div>
        <div class="a-avatar" id="brandAvatar" aria-hidden="true">
          <span id="brandInitials">[[RCS_BRAND_INITIALS]]</span>
        </div>
        <div class="a-name">
          <span id="brandName">[[RCS_BRAND_NAME]]</span>
          <span class="a-verified" id="brandVerified" data-verified="[[RCS_VERIFIED]]" title="Verified sender">
            <svg viewBox="0 0 24 24"><path d="M12 1L3 5v6c0 5.55 3.84 10.74 9 12 5.16-1.26 9-6.45 9-12V5l-9-4zm-2 15l-4-4 1.4-1.4L10 13.2l6.6-6.6L18 8l-8 8z"/></svg>
          </span>
        </div>
        <div class="a-menu" aria-hidden="true">⋮</div>
      </header>

      <!-- ==================== iOS CHROME ==================== -->
      <div class="i-status" data-chrome="ios">
        <span class="i-time">9:41</span>
        <div class="i-status-right" aria-hidden="true">
          <svg viewBox="0 0 20 12"><path d="M0 10h3v2H0zM5 8h3v4H5zM10 5h3v7h-3zM15 0h3v12h-3z"/></svg>
          <svg viewBox="0 0 20 14"><path d="M10 3c2.5 0 4.8.9 6.6 2.3l1.4-1.4A11 11 0 0 0 10 0C6.4 0 3.1 1.4 0 3.9L1.4 5.3A9 9 0 0 1 10 3zm0 4c1.4 0 2.7.5 3.7 1.3l1.4-1.4A7 7 0 0 0 10 5a7 7 0 0 0-5.1 1.9l1.4 1.4C7.3 7.5 8.6 7 10 7zm0 4a2 2 0 1 1 0 4 2 2 0 0 1 0-4z"/></svg>
          <svg viewBox="0 0 26 12"><rect x="0" y="1" width="22" height="10" rx="2.5" ry="2.5" fill="none" stroke="currentColor" stroke-width="1.2"/><rect x="2" y="3" width="18" height="6" rx="1"/></svg>
        </div>
      </div>

      <header class="i-header" data-chrome="ios">
        <div class="i-back" aria-hidden="true">‹</div>
        <div class="i-brand-block">
          <div class="i-avatar" id="brandAvatarIos" aria-hidden="true">
            <span>[[RCS_BRAND_INITIALS]]</span>
          </div>
          <div class="i-brand-name">
            <span>[[RCS_BRAND_NAME]]</span>
            <span class="i-brand-chevron" aria-hidden="true">›</span>
          </div>
        </div>
      </header>

      <!-- Thread -->
      <div id="rcsThreadScroll" class="thread">
        [[RCS_THREAD_HTML]]
        <div class="empty-hint" id="rcsEmptyHint" hidden>Tap anywhere in the phone to reveal messages</div>
      </div>

      <!-- Unsubscribe pill (Android) -->
      <div class="a-unsub" data-chrome="android">
        <span class="a-unsub-pill">Unsubscribe to stop receiving messages</span>
      </div>

      <!-- iOS action hint (below chips) -->
      <div class="i-actions-hint" data-chrome="ios" id="iosActionsHint">
        <span id="iosActionsHintBrand">[[RCS_BRAND_NAME]]</span> will see actions you select
      </div>

      <!-- Composer (Android) -->
      <footer class="composer" data-chrome="android">
        <div class="c-icon" aria-hidden="true">
          <svg viewBox="0 0 24 24"><path d="M19 3H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm-5 12l-3-3.72L9 15h9l-3-4z"/></svg>
        </div>
        <div class="c-icon" aria-hidden="true">
          <svg viewBox="0 0 24 24"><path d="M9 2 7.17 4H4c-1.1 0-2 .9-2 2v12c0 1.1.9 2 2 2h16c1.1 0 2-.9 2-2V6c0-1.1-.9-2-2-2h-3.17L15 2H9zm3 15c-2.76 0-5-2.24-5-5s2.24-5 5-5 5 2.24 5 5-2.24 5-5 5z"/></svg>
        </div>
        <div class="c-input">RCS message</div>
        <div class="c-send" aria-hidden="true">
          <svg viewBox="0 0 24 24"><path d="M2.01 21L23 12 2.01 3 2 10l15 2-15 2z"/></svg>
        </div>
      </footer>

      <!-- Composer (iOS) -->
      <footer class="i-composer" data-chrome="ios">
        <div class="i-composer-plus" aria-hidden="true">＋</div>
        <div class="i-composer-input">Text Message · RCS</div>
        <div class="i-composer-mic" aria-hidden="true">
          <svg viewBox="0 0 24 24"><path d="M12 14c1.66 0 3-1.34 3-3V5c0-1.66-1.34-3-3-3S9 3.34 9 5v6c0 1.66 1.34 3 3 3zm5.3-3c0 3-2.54 5.1-5.3 5.1S6.7 14 6.7 11H5c0 3.41 2.72 6.23 6 6.72V21h2v-3.28c3.28-.48 6-3.3 6-6.72h-1.7z"/></svg>
        </div>
      </footer>
    </div>

    <script>
      (function () {
        var root = document.documentElement;
        var device = root.getAttribute("data-device") === "ios" ? "ios" : "android";
        function q(sel) { return document.querySelector(sel); }

        // Brand avatar logo (Android circle + iOS squircle) + verified check.
        var LOGO_URL = "[[RCS_BRAND_LOGO_URL]]";
        if (LOGO_URL) {
          ["brandAvatar", "brandAvatarIos"].forEach(function (id) {
            var el = document.getElementById(id);
            if (el) el.innerHTML = '<img alt="" src="' + LOGO_URL + '" />';
          });
        }
        var verified = document.getElementById("brandVerified");
        if (verified && verified.getAttribute("data-verified") !== "verified") verified.style.display = "none";

        // Brand-info card: tap the sender header to show, tap the card to dismiss.
        var brandCard = document.getElementById("rcsBrandCard");
        function showBrandCard() { if (brandCard) { brandCard.classList.remove("is-dismissed"); brandCard.setAttribute("aria-hidden", "false"); } }
        function dismissBrandCard() { if (brandCard) { brandCard.classList.add("is-dismissed"); brandCard.setAttribute("aria-hidden", "true"); } }
        if (brandCard) brandCard.addEventListener("click", function (e) { e.stopPropagation(); dismissBrandCard(); });
        [".a-name", ".a-avatar", ".i-brand-block"].forEach(function (sel) {
          var el = q(sel);
          if (el) el.addEventListener("click", function (e) { e.stopPropagation(); showBrandCard(); });
        });

        var thread = document.getElementById("rcsThreadScroll");
        var phone = document.getElementById("phoneShell");
        var hint = document.getElementById("rcsEmptyHint");
        if (hint) hint.hidden = true;
        var pill = device === "ios" ? q(".i-composer-input") : q(".c-input");
        var sendEl = device === "ios" ? q(".i-composer-mic") : q(".c-send");
        if (!phone || !thread) return;

        var rows = Array.prototype.slice.call(thread.querySelectorAll(".rcs-row"));
        var idx = 0, mode = "idle", draft = "";
        var PLACEHOLDER = pill ? (pill.textContent || "RCS message") : "RCS message";

        function scrollBottom() {
          thread.scrollTop = thread.scrollHeight;
          requestAnimationFrame(function () { thread.scrollTop = thread.scrollHeight; });
        }
        function senderOf(r) { return r.getAttribute("data-sender") === "user" ? "user" : "bot"; }
        function textOf(r) { var c = r.querySelector(".rcs-copy"); return c ? (c.textContent || "").trim() : ""; }
        function reveal(r) { r.classList.remove("hidden-msg"); r.classList.add("just-revealed"); scrollBottom(); }

        function setPill(text, withCaret) {
          if (!pill) return;
          pill.textContent = "";
          pill.appendChild(document.createTextNode(text && text.length ? text : (withCaret ? "" : PLACEHOLDER)));
          if (withCaret) { var caret = document.createElement("span"); caret.className = "rcs-caret"; pill.appendChild(caret); }
        }
        function resetPill() {
          if (pill) { pill.classList.remove("is-typing"); setPill(PLACEHOLDER, false); }
          if (sendEl) sendEl.classList.remove("rcs-ready");
        }

        function playBrandRun() {
          while (idx < rows.length && senderOf(rows[idx]) === "bot") { reveal(rows[idx]); idx += 1; }
          if (idx < rows.length) awaitRecipient();
          else { resetPill(); mode = "idle"; }
        }
        function awaitRecipient() {
          mode = "awaiting";
          if (pill) pill.classList.add("is-typing");
          if (sendEl) sendEl.classList.remove("rcs-ready");
          setPill("", true);
          scrollBottom();
        }
        function startRecipientTyping() {
          var full = textOf(rows[idx]);
          if (!full) { draft = ""; armSend(); return; }
          mode = "typing";
          if (pill) pill.classList.add("is-typing");
          draft = "";
          var i = 0;
          (function typeNext() {
            if (i >= full.length) { armSend(); return; }
            draft += full.charAt(i); i += 1; setPill(draft, true);
            var prev = full.charAt(i - 1);
            var delay = 40 + Math.random() * 45;
            if (prev === " " && Math.random() < 0.12) delay += 110 + Math.random() * 140;
            else if (".,!?".indexOf(prev) >= 0 && Math.random() < 0.25) delay += 150 + Math.random() * 200;
            setTimeout(typeNext, delay);
          })();
        }
        function armSend() { mode = "ready"; setPill(draft, true); if (sendEl) sendEl.classList.add("rcs-ready"); }

        function showTyping() {
          hideTyping();
          var row = document.createElement("div");
          row.className = "rcs-row rcs-row-bot"; row.id = "rcsTypingRow";
          row.innerHTML = '<div class="rcs-bubble rcs-bubble-bot"><div class="rcs-typing-dots"><span class="tdot"></span><span class="tdot"></span><span class="tdot"></span></div></div>';
          thread.appendChild(row); scrollBottom();
        }
        function hideTyping() { var t = document.getElementById("rcsTypingRow"); if (t && t.parentNode) t.parentNode.removeChild(t); }

        function advanceAfterRecipient() {
          resetPill(); mode = "idle";
          if (idx < rows.length && senderOf(rows[idx]) === "bot") {
            showTyping();
            setTimeout(function () { hideTyping(); playBrandRun(); }, 1100);
          } else { playBrandRun(); }
        }
        function sendRecipient() {
          if (mode !== "ready") return;
          reveal(rows[idx]); idx += 1;
          advanceAfterRecipient();
        }
        // Tapping a quick-reply chip (or card button) IS the recipient replying:
        // post the pill's label as their message and continue the thread.
        function pillReply(label) {
          if (mode !== "awaiting" && mode !== "ready" && mode !== "typing") return;
          if (idx >= rows.length || senderOf(rows[idx]) !== "user") return;
          var copy = rows[idx].querySelector(".rcs-copy");
          if (copy && label) copy.textContent = label;
          reveal(rows[idx]); idx += 1;
          advanceAfterRecipient();
        }
        thread.addEventListener("click", function (e) {
          var pill = e.target.closest(".rcs-chip, .rcs-card-btn");
          if (!pill) return;
          e.stopPropagation();
          pillReply((pill.getAttribute("data-label") || pill.textContent || "").trim());
        });

        if (pill) pill.addEventListener("click", function (e) {
          e.stopPropagation();
          if (mode === "awaiting") startRecipientTyping();
          else if (mode === "ready") sendRecipient();
        });
        if (sendEl) sendEl.addEventListener("click", function (e) { e.stopPropagation(); if (mode === "ready") sendRecipient(); });
        phone.addEventListener("click", function () { if (mode === "ready") sendRecipient(); });

        resetPill();
        playBrandRun();
      })();
    </script>
  </body>
</html>
