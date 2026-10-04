<!DOCTYPE html>
<html lang="en" data-theme="[[WHATSAPP_THEME]]">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>2-Way WhatsApp Simulator</title>
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
        font-family: "Segoe UI", "Helvetica Neue", Helvetica, Arial, sans-serif;
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
        height: 96vh;
        max-height: 960px;
        aspect-ratio: 9 / 19.5;
        margin: 0 auto;
        border-radius: 40px;
        border: 8px solid #2a3942;
        background: #0b141a;
        display: flex;
        flex-direction: column;
        overflow: hidden;
        box-shadow: 0 24px 80px rgba(0, 0, 0, 0.65), 0 0 0 1px rgba(255, 255, 255, 0.04) inset;
      }

      .wa-header {
        flex-shrink: 0;
        display: flex;
        align-items: center;
        gap: 10px;
        padding: 10px 12px;
        padding-top: max(10px, env(safe-area-inset-top, 10px));
        background: #1f2c34;
        border-bottom: 1px solid rgba(0, 0, 0, 0.2);
      }

      .wa-back {
        flex-shrink: 0;
        color: #8696a0;
        font-size: 22px;
        line-height: 1;
        padding: 4px 2px;
        user-select: none;
      }

      .wa-header-avatar {
        width: 40px;
        height: 40px;
        border-radius: 50%;
        object-fit: cover;
        background: #2a3942;
        flex-shrink: 0;
      }

      .wa-header-text {
        flex: 1;
        min-width: 0;
        display: flex;
        flex-direction: column;
        gap: 2px;
      }

      .wa-header-title {
        font-size: 16px;
        font-weight: 500;
        color: #e9edef;
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
      }

      .wa-header-sub {
        font-size: 12px;
        color: #8696a0;
      }

      .wa-header-actions {
        flex-shrink: 0;
        display: flex;
        align-items: center;
        gap: 4px;
      }

      .wa-header-actions button {
        width: 40px;
        height: 40px;
        border: none;
        background: transparent;
        color: #8696a0;
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        cursor: default;
        padding: 0;
      }

      .wa-header-actions svg {
        width: 22px;
        height: 22px;
        fill: currentColor;
      }

      #waThreadScroll {
        flex: 1;
        min-height: 0;
        overflow-y: auto;
        overflow-x: hidden;
        padding: 12px 10px 16px;
        display: flex;
        flex-direction: column;
        gap: 6px;
        background-color: #0b141a;
        background-image: repeating-linear-gradient(
          -45deg,
          transparent,
          transparent 6px,
          rgba(255, 255, 255, 0.015) 6px,
          rgba(255, 255, 255, 0.015) 12px
        );
        -webkit-overflow-scrolling: touch;
        scrollbar-width: none;
        -ms-overflow-style: none;
      }

      #waThreadScroll::-webkit-scrollbar {
        display: none;
      }

      .row {
        display: flex;
        width: 100%;
      }

      .row-outgoing {
        justify-content: flex-end;
      }

      .row-incoming {
        justify-content: flex-start;
      }

      .message {
        max-width: 82%;
        transition: opacity 0.22s ease, transform 0.22s ease;
      }

      .message.hidden-msg {
        display: none;
        opacity: 0;
      }

      .wa-bubble {
        border-radius: 8px;
        padding: 6px 8px 4px 8px;
        position: relative;
        box-shadow: 0 1px 0.5px rgba(0, 0, 0, 0.13);
      }

      .wa-bubble-in {
        background: #202c33;
        color: #e9edef;
      }

      .wa-bubble-out {
        background: #005c4b;
        color: #e9edef;
      }

      .wa-text {
        font-size: 14.2px;
        line-height: 1.45;
        word-wrap: break-word;
        overflow-wrap: break-word;
        padding-right: 2px;
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

      .wa-meta-row {
        display: flex;
        align-items: center;
        justify-content: flex-end;
        gap: 5px;
        margin-top: 4px;
      }

      .wa-time {
        font-size: 11px;
        color: rgba(233, 237, 239, 0.65);
        white-space: nowrap;
        line-height: 1;
      }

      .wa-bubble-out .wa-time {
        color: rgba(233, 237, 239, 0.75);
      }

      .wa-checks {
        font-size: 14px;
        line-height: 1;
        color: #53bdeb;
        letter-spacing: -3px;
        margin-left: 2px;
      }

      .wa-composer {
        flex-shrink: 0;
        display: flex;
        align-items: center;
        gap: 8px;
        padding: 8px 10px 12px;
        padding-bottom: max(12px, env(safe-area-inset-bottom, 12px));
        background: #1f2c34;
        border-top: 1px solid rgba(0, 0, 0, 0.25);
      }

      .wa-composer-icon {
        flex-shrink: 0;
        width: 36px;
        height: 36px;
        border-radius: 50%;
        border: none;
        background: transparent;
        color: #8696a0;
        display: flex;
        align-items: center;
        justify-content: center;
        cursor: default;
        padding: 0;
      }

      .wa-composer-icon svg {
        width: 24px;
        height: 24px;
        fill: currentColor;
      }

      .wa-input-pill {
        flex: 1;
        background: #2a3942;
        border-radius: 24px;
        padding: 10px 16px;
        font-size: 15px;
        color: #8696a0;
        min-height: 42px;
        display: flex;
        align-items: center;
      }

      /* ============================================================
         LIGHT MODE — applied via html[data-theme="light"]. Palette
         matches real WhatsApp in light mode: teal header, cream
         patterned chat background, white incoming bubbles, pale-green
         outgoing bubbles (#d9fdd3), dark text. Wallpaper around the
         phone stays pale in both modes (see body{}); only the phone
         screen changes.
         ============================================================ */
      html[data-theme="light"] .phone-shell {
        border-color: #1a1a24;
        background: #fff;
        box-shadow: 0 24px 80px rgba(0, 0, 0, 0.35), 0 0 0 1px rgba(255, 255, 255, 0.06) inset;
      }
      html[data-theme="light"] .wa-header {
        background: #008069;
        border-bottom: 1px solid rgba(0, 0, 0, 0.1);
      }
      html[data-theme="light"] .wa-back { color: #fff; }
      html[data-theme="light"] .wa-header-avatar { background: #ccd0d5; }
      html[data-theme="light"] .wa-header-title { color: #fff; }
      html[data-theme="light"] .wa-header-sub { color: rgba(255, 255, 255, 0.85); }
      html[data-theme="light"] .wa-header-actions button { color: #fff; }
      html[data-theme="light"] #waThreadScroll {
        background-color: #efeae2;
        background-image: repeating-linear-gradient(
          -45deg,
          transparent,
          transparent 6px,
          rgba(0, 0, 0, 0.02) 6px,
          rgba(0, 0, 0, 0.02) 12px
        );
      }
      html[data-theme="light"] .wa-bubble-in {
        background: #ffffff;
        color: #111b21;
      }
      html[data-theme="light"] .wa-bubble-out {
        background: #d9fdd3;
        color: #111b21;
      }
      html[data-theme="light"] .wa-time {
        color: rgba(0, 0, 0, 0.45);
      }
      html[data-theme="light"] .wa-bubble-out .wa-time {
        color: rgba(0, 0, 0, 0.5);
      }
      html[data-theme="light"] .wa-checks { color: #53bdeb; }
      html[data-theme="light"] .wa-composer {
        background: #f0f2f5;
        border-top: 1px solid rgba(0, 0, 0, 0.08);
      }
      html[data-theme="light"] .wa-composer-icon { color: #54656f; }
      html[data-theme="light"] .wa-input-pill {
        background: #ffffff;
        color: #667781;
      }

      /* Recipient compose typing + send button (mirrors the SMS sim). */
      .wa-input-pill.is-typing { color: #e9edef; cursor: text; }
      html[data-theme="light"] .wa-input-pill.is-typing { color: #111b21; }
      .wa-caret {
        display: inline-block;
        width: 2px;
        height: 1.05em;
        background: currentColor;
        margin-left: 1px;
        vertical-align: -2px;
        animation: wablink 1s steps(1) infinite;
      }
      @keyframes wablink { 50% { opacity: 0; } }
      .wa-send-btn {
        flex-shrink: 0;
        width: 40px;
        height: 40px;
        display: none;
        align-items: center;
        justify-content: center;
        cursor: pointer;
        padding: 0;
        border: none;
        border-radius: 50%;
        background: #00a884;
      }
      .wa-send-btn.show { display: flex; }
      .wa-send-btn svg { width: 22px; height: 22px; fill: #fff; }

      /* Agent typing indicator — incoming bubble with three bouncing dots. */
      .wa-typing { display: flex; gap: 4px; align-items: center; min-width: 40px; padding: 2px 0; }
      .wa-typing .tdot {
        width: 7px; height: 7px; border-radius: 50%;
        background: currentColor; opacity: 0.5;
        animation: watbounce 1.2s infinite ease-in-out;
      }
      .wa-typing .tdot:nth-child(2) { animation-delay: 0.18s; }
      .wa-typing .tdot:nth-child(3) { animation-delay: 0.36s; }
      @keyframes watbounce {
        0%, 60%, 100% { transform: translateY(0); opacity: 0.4; }
        30% { transform: translateY(-4px); opacity: 0.9; }
      }
    </style>
  </head>
  <body>
    <div
      id="phoneShell"
      class="phone-shell"
      role="application"
      aria-label="Simulated WhatsApp — tap to reveal the next message"
    >
      <header class="wa-header">
        <div class="wa-back" aria-hidden="true">‹</div>
        <img
          class="wa-header-avatar"
          src="[[MARKETING_AVATAR_URL]]"
          alt=""
          width="40"
          height="40"
          loading="eager"
          referrerpolicy="no-referrer"
        />
        <div class="wa-header-text">
          <div class="wa-header-title">[[MESSAGING_AGENT_HEADER]]</div>
          <div class="wa-header-sub">Business Account</div>
        </div>
        <div class="wa-header-actions" aria-hidden="true">
          <button type="button" title="Video call">
            <svg viewBox="0 0 24 24" aria-hidden="true">
              <path
                d="M17 10.5V7c0-.55-.45-1-1-1H4c-.55 0-1 .45-1 1v10c0 .55.45 1 1 1h12c.55 0 1-.45 1-1v-3.5l4 4v-11l-4 4z"
              />
            </svg>
          </button>
          <button type="button" title="Voice call">
            <svg viewBox="0 0 24 24" aria-hidden="true">
              <path
                d="M6.62 10.79c1.44 2.83 3.76 5.14 6.59 6.59l2.2-2.2c.27-.27.67-.36 1.02-.24 1.12.37 2.33.57 3.57.57.55 0 1 .45 1 1V20c0 .55-.45 1-1 1-9.39 0-17-7.61-17-17 0-.55.45-1 1-1h3.5c.55 0 1 .45 1 1 0 1.25.2 2.45.57 3.57.11.35.03.74-.25 1.02l-2.2 2.2z"
              />
            </svg>
          </button>
          <button type="button" title="Menu">
            <svg viewBox="0 0 24 24" aria-hidden="true">
              <path
                d="M12 8c1.1 0 2-.9 2-2s-.9-2-2-2-2 .9-2 2 .9 2 2 2zm0 2c-1.1 0-2 .9-2 2s.9 2 2 2 2-.9 2-2-.9-2-2-2zm0 6c-1.1 0-2 .9-2 2s.9 2 2 2 2-.9 2-2-.9-2-2-2z"
              />
            </svg>
          </button>
        </div>
      </header>

      <div id="waThreadScroll" class="wa-thread">
        [[WHATSAPP_THREAD_HTML]]
      </div>

      <footer class="wa-composer">
        <button type="button" class="wa-composer-icon" aria-hidden="true" title="Attach">
          <svg viewBox="0 0 24 24">
            <path d="M19 13h-6v6h-2v-6H5v-2h6V5h2v6h6v2z" />
          </svg>
        </button>
        <div id="waPill" class="wa-input-pill">Message</div>
        <button type="button" class="wa-composer-icon" aria-hidden="true" title="Camera">
          <svg viewBox="0 0 24 24">
            <path
              d="M12 15.2c1.77 0 3.2-1.43 3.2-3.2S13.77 8.8 12 8.8 8.8 10.23 8.8 12s1.43 3.2 3.2 3.2zm7-2.4V7h-2.5l-2-2h-7l-2 2H5v10h14v-4.6z"
            />
          </svg>
        </button>
        <button id="waSendBtn" class="wa-send-btn" type="button" aria-label="Send">
          <svg viewBox="0 0 24 24" aria-hidden="true">
            <path d="M3 20.5v-6l9-2.5-9-2.5v-6l19 8.5z" />
          </svg>
        </button>
      </footer>

      <div style="text-align: center; padding: 20px; font-size: 12px; color: #666666;">
        <p style="margin: 0 0 5px 0;">© [[BRAND_NAME]]. All rights reserved.</p>
        <p style="margin: 0; font-size: 11px;">Built for Salesforce Solution Engineers</p>
      </div>
    </div>

    <script>
      (function () {
        var thread = document.getElementById("waThreadScroll");
        var phone = document.getElementById("phoneShell");
        var pill = document.getElementById("waPill");
        var sendBtn = document.getElementById("waSendBtn");
        if (!phone || !thread) return;

        var rows = Array.prototype.slice.call(phone.querySelectorAll(".row"));
        var idx = 0;
        var mode = "idle"; // idle | awaiting | typing | ready
        var draft = "";
        var PLACEHOLDER = "Message";

        function scrollBottom() {
          thread.scrollTop = thread.scrollHeight;
          requestAnimationFrame(function () { thread.scrollTop = thread.scrollHeight; });
        }
        function reveal(row) {
          var g = row.querySelector(".message");
          if (g) g.classList.remove("hidden-msg");
          scrollBottom();
        }
        function senderOf(row) { return row.getAttribute("data-sender") === "user" ? "user" : "bot"; }
        function textOf(row) {
          var copy = row.querySelector(".msg-copy");
          return copy ? (copy.textContent || "").trim() : "";
        }

        function setPill(text, withCaret) {
          pill.textContent = "";
          pill.appendChild(document.createTextNode(text && text.length ? text : (withCaret ? "" : PLACEHOLDER)));
          if (withCaret) {
            var caret = document.createElement("span");
            caret.className = "wa-caret";
            pill.appendChild(caret);
          }
        }
        function resetPill() {
          pill.classList.remove("is-typing");
          setPill(PLACEHOLDER, false);
          sendBtn.classList.remove("show");
        }

        function playBrandRun() {
          while (idx < rows.length && senderOf(rows[idx]) === "bot") {
            reveal(rows[idx]);
            idx += 1;
          }
          if (idx < rows.length) awaitRecipient();
          else { resetPill(); mode = "idle"; }
        }

        function awaitRecipient() {
          mode = "awaiting";
          pill.classList.add("is-typing");
          sendBtn.classList.remove("show");
          setPill("", true);
          scrollBottom();
        }

        function startRecipientTyping() {
          var full = textOf(rows[idx]);
          if (!full) { draft = ""; armSend(); return; }
          mode = "typing";
          pill.classList.add("is-typing");
          draft = "";
          var i = 0;
          (function typeNext() {
            if (i >= full.length) { armSend(); return; }
            draft += full.charAt(i);
            i += 1;
            setPill(draft, true);
            var prev = full.charAt(i - 1);
            var delay = 40 + Math.random() * 45;
            if (prev === " " && Math.random() < 0.12) delay += 110 + Math.random() * 140;
            else if (".,!?".indexOf(prev) >= 0 && Math.random() < 0.25) delay += 150 + Math.random() * 200;
            setTimeout(typeNext, delay);
          })();
        }
        function armSend() {
          mode = "ready";
          setPill(draft, true);
          sendBtn.classList.add("show");
        }

        function showTyping() {
          hideTyping();
          var row = document.createElement("div");
          row.className = "row row-incoming";
          row.id = "typingRow";
          row.innerHTML =
            '<div class="message wa-incoming"><div class="wa-bubble wa-bubble-in">' +
            '<div class="wa-typing"><span class="tdot"></span><span class="tdot"></span><span class="tdot"></span></div></div></div>';
          thread.appendChild(row);
          scrollBottom();
        }
        function hideTyping() {
          var t = document.getElementById("typingRow");
          if (t && t.parentNode) t.parentNode.removeChild(t);
        }

        function sendRecipient() {
          if (mode !== "ready") return;
          reveal(rows[idx]);
          idx += 1;
          resetPill();
          mode = "idle";
          if (idx < rows.length && senderOf(rows[idx]) === "bot") {
            showTyping();
            setTimeout(function () { hideTyping(); playBrandRun(); }, 1100);
          } else {
            playBrandRun();
          }
        }

        pill.addEventListener("click", function (e) {
          e.stopPropagation();
          if (mode === "awaiting") startRecipientTyping();
          else if (mode === "ready") sendRecipient();
        });
        sendBtn.addEventListener("click", function (e) {
          e.stopPropagation();
          sendRecipient();
        });
        phone.addEventListener("click", function () {
          if (mode === "ready") sendRecipient();
        });

        resetPill();
        playBrandRun();
      })();
    </script>
  </body>
</html>
