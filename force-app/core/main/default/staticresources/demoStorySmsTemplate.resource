<!DOCTYPE html>
<html lang="en" data-theme="[[SMS_THEME]]">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>2-Way SMS Simulator</title>
    <style>
      * {
        box-sizing: border-box;
        margin: 0;
        padding: 0;
      }

      html,
      body {
        height: 100%;
        min-height: 0;
      }

      body {
        min-height: 100%;
        font-family: -apple-system, BlinkMacSystemFont, "SF Pro Text", "Segoe UI",
          Roboto, Helvetica, Arial, sans-serif;
        /* Wallpaper stays light in BOTH modes (mirrors RCS). Only the phone
           screen itself changes with data-theme. */
        background: radial-gradient(ellipse 120% 80% at 50% 0%, #f4f2fb 0%, #ecebf4 45%, #e2e0eb 100%);
        color: #111;
        display: flex;
        align-items: center;
        justify-content: center;
        padding: 16px;
        box-sizing: border-box;
        overflow: auto;
      }

      .phone-shell {
        flex-shrink: 1;
        min-width: 0;
        max-width: 100%;
        width: auto;
        height: 90vh;
        max-height: 812px;
        aspect-ratio: 9 / 19.5;
        margin: 0 auto;
        border-radius: 40px;
        border: 8px solid #333;
        background: #000;
        display: flex;
        flex-direction: column;
        overflow: hidden;
        box-shadow: 0 24px 80px rgba(0, 0, 0, 0.65), 0 0 0 1px rgba(255, 255, 255, 0.06) inset;
      }

      .msg-header {
        flex-shrink: 0;
        display: flex;
        align-items: center;
        gap: 8px;
        padding: 12px 14px 14px;
        padding-top: max(12px, env(safe-area-inset-top, 12px));
        background: #000;
        border-bottom: 0.5px solid rgba(255, 255, 255, 0.12);
      }

      .back-btn {
        flex-shrink: 0;
        color: #0a84ff;
        font-size: 17px;
        font-weight: 400;
        letter-spacing: -0.2px;
        cursor: default;
        user-select: none;
        min-width: 56px;
      }

      .header-center {
        flex: 1;
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;
        gap: 4px;
        min-width: 0;
      }

      .header-avatar {
        width: 36px;
        height: 36px;
        border-radius: 50%;
        object-fit: cover;
        background: #3a3a3c;
      }

      .header-title {
        font-size: 15px;
        font-weight: 600;
        color: #fff;
        text-align: center;
        max-width: 100%;
        overflow: hidden;
        text-overflow: ellipsis;
        white-space: nowrap;
      }

      .header-sub {
        font-size: 11px;
        color: #8e8e93;
        font-weight: 400;
        letter-spacing: 0.02em;
      }

      #smsThreadScroll {
        flex: 1;
        min-height: 0;
        overflow-y: auto;
        overflow-x: hidden;
        padding: 16px 12px 20px;
        display: flex;
        flex-direction: column;
        gap: 10px;
        background: #000;
        -webkit-overflow-scrolling: touch;
        scrollbar-width: none;
        -ms-overflow-style: none;
      }

      #smsThreadScroll::-webkit-scrollbar {
        display: none;
      }

      .row {
        display: flex;
        width: 100%;
      }

      .row-user {
        justify-content: flex-end;
      }

      .row-bot {
        justify-content: flex-start;
      }

      .message-group {
        display: flex;
        flex-direction: column;
        gap: 4px;
        max-width: 75%;
        align-items: stretch;
      }

      .message-group.hidden-msg {
        display: none;
        opacity: 0;
      }

      .message-group:not(.hidden-msg) {
        display: flex;
      }

      .message {
        max-width: 100%;
        padding: 10px 14px;
        font-size: 17px;
        line-height: 1.35;
        word-wrap: break-word;
        overflow-wrap: break-word;
        transition: opacity 0.22s ease, transform 0.22s ease;
      }

      .message.bubble-user {
        background: #34c759;
        color: #fff;
        border-radius: 18px 18px 4px 18px;
      }

      .message.bubble-bot {
        background: #262628;
        color: #fff;
        border-radius: 18px 18px 18px 4px;
      }

      .msg-bubble-stack {
        display: flex;
        flex-direction: column;
        gap: 8px;
      }

      .msg-attached-image {
        max-width: 100%;
        border-radius: 12px;
        display: block;
        vertical-align: middle;
      }

      .composer {
        flex-shrink: 0;
        display: flex;
        align-items: center;
        gap: 10px;
        padding: 10px 12px 14px;
        padding-bottom: max(14px, env(safe-area-inset-bottom, 14px));
        background: #1c1c1e;
        border-top: 0.5px solid rgba(255, 255, 255, 0.12);
      }

      .composer-icon {
        flex-shrink: 0;
        width: 28px;
        height: 28px;
        display: flex;
        align-items: center;
        justify-content: center;
        color: #0a84ff;
      }

      .composer-icon svg {
        width: 22px;
        height: 22px;
        fill: currentColor;
      }

      .input-pill {
        flex: 1;
        background: #262628;
        border-radius: 20px;
        padding: 10px 16px;
        font-size: 17px;
        color: #8e8e93;
        line-height: 1.2;
      }

      /* ============================================================
         LIGHT MODE — applied via html[data-theme="light"]. Palette
         mirrors real iOS Messages in light mode (white thread bg,
         dark text, receiver bubbles #e5e5ea). Sender bubbles stay
         SMS-green (#34c759). Wallpaper around the phone stays pale in
         both modes (see body{}); only the phone screen changes.
         ============================================================ */
      html[data-theme="light"] .phone-shell {
        border-color: #1a1a24;
        background: #fff;
        box-shadow: 0 24px 80px rgba(0, 0, 0, 0.35), 0 0 0 1px rgba(255, 255, 255, 0.06) inset;
      }
      html[data-theme="light"] .msg-header {
        background: #f6f6f6;
        border-bottom: 0.5px solid rgba(0, 0, 0, 0.1);
      }
      html[data-theme="light"] .header-title { color: #000; }
      html[data-theme="light"] .header-sub { color: #6d6d72; }
      html[data-theme="light"] #smsThreadScroll {
        background: #fff;
      }
      html[data-theme="light"] .message.bubble-bot {
        background: #e5e5ea;
        color: #000;
      }
      html[data-theme="light"] .composer {
        background: #f6f6f6;
        border-top: 0.5px solid rgba(0, 0, 0, 0.1);
      }
      html[data-theme="light"] .input-pill {
        background: #ececec;
        color: #8e8e93;
      }
    </style>
  </head>
  <body>
    <div
      id="phoneShell"
      class="phone-shell"
      role="application"
      aria-label="Simulated Messages — tap to reveal the next message"
    >
      <header class="msg-header">
        <div class="back-btn" aria-hidden="true">&#8249;</div>
        <div class="header-center">
          <img
            class="header-avatar"
            src="[[MARKETING_AVATAR_URL]]"
            alt=""
            width="36"
            height="36"
            loading="eager"
            referrerpolicy="no-referrer"
          />
          <div class="header-title">[[MESSAGING_AGENT_HEADER]]</div>
          <div class="header-sub">Text Message • SMS</div>
        </div>
        <div style="width: 56px; flex-shrink: 0" aria-hidden="true"></div>
      </header>

      <div id="smsThreadScroll" class="thread">
        [[SMS_THREAD_HTML]]
      </div>

      <footer class="composer">
        <div class="composer-icon" aria-hidden="true">
          <svg viewBox="0 0 24 24" aria-hidden="true">
            <path d="M19 13h-6v6h-2v-6H5v-2h6V5h2v6h6v2z" />
          </svg>
        </div>
        <div class="input-pill">Text Message • SMS</div>
        <div class="composer-icon" aria-hidden="true">
          <svg viewBox="0 0 24 24" aria-hidden="true">
            <path
              d="M12 14c1.66 0 3-1.34 3-3V5c0-1.66-1.34-3-3-3S9 3.34 9 5v6c0 1.66 1.34 3 3 3zm5.3-3c0 3-2.54 5.1-5.3 5.1S6.7 14 6.7 11H5c0 3.41 2.72 6.23 6 6.72V21h2v-3.28c3.28-.48 6-3.3 6-6.72h-1.7z"
            />
          </svg>
        </div>
      </footer>

      <div style="text-align: center; padding: 20px; font-size: 12px; color: #666666;">
        <p style="margin: 0 0 5px 0;">© Cumulus Financial. All rights reserved.</p>
        <p style="margin: 0; font-size: 11px;">Built for Salesforce Solution Engineers</p>
      </div>
    </div>

    <script>
      (function () {
        var thread = document.getElementById("smsThreadScroll");
        var phone = document.getElementById("phoneShell");
        if (!phone || !thread) return;

        var messages = phone.querySelectorAll(".message-group");
        // Messages pre-shown (no .hidden-msg) stay visible; tapping reveals the rest.
        var nextIndex = phone.querySelectorAll(".message-group:not(.hidden-msg)").length;

        function scrollThreadToBottom() {
          thread.scrollTop = thread.scrollHeight;
        }

        function revealNext() {
          if (nextIndex >= messages.length) return;
          messages[nextIndex].classList.remove("hidden-msg");
          nextIndex += 1;
          scrollThreadToBottom();
          requestAnimationFrame(scrollThreadToBottom);
        }

        phone.addEventListener("click", revealNext);
      })();
    </script>
  </body>
</html>
