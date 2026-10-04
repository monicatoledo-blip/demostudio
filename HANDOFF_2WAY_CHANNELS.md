# Handoff — add SMS / RCS / WhatsApp channels to 2-Way Simulators

Read first: memory `project-demo-story-factory`, `reference-lwc-lws-iframe-preview`, `reference_rcs_sim_pair_invariant`. Plan: `~/.claude/plans/glowing-discovering-taco.md`. Everything below is in **`~/DemoStudio`**, deploy org **meshmesh** (API v67, default), repo `monicatoledo-blip/demostudio` branch `main`. **Additive only** — don't break the unified-profile generator. Commit per step; it auto-pushes nothing, run `git push` yourself.

## Goal
Email is fully built. Add the other three channels — they're a **mechanical repeat**: a different ported template + a channel-aware preview + a channel-aware field set. `Two_Way_Simulator__c.Channel__c` already has Email/SMS/RCS/WhatsApp.

## The email implementation to mirror
- **Template:** static resource `demoStoryEmailTemplate` = verbatim `~/Cumulus Simulated Experiences Site/experience-simulator/public/cumulus.html`.
- **Preview:** `StoryEmailPreviewController.cls` reads the record's `Config_JSON__c`, token-substitutes over the template, returns HTML; `StoryEmailPreview.page` outputs it; `demoStoryStudio` loads it in an iframe via relative `/apex/StoryEmailPreview?id=<id>&v=<n>` (LWS blocks srcdoc/blob/data — this relative-URL VF pattern is the ONLY thing that works). Scripts are KEPT (2-way Reply + avatar need them).
- **Config model:** `demoStoryStudio.js` `DEFAULTS` + `INDUSTRY_PACKS`; the Studio writes `Config_JSON__c`.

## Steps
1. **Port templates** → static resources `demoStorySmsTemplate`, `demoStoryWhatsappTemplate`, `demoStoryRcsTemplate` from `public/sms.html`, `public/whatsapp.html`, `public/rcs.html`. (`.resource` + `.resource-meta.xml` contentType text/html, like demoStoryEmailTemplate.)
2. **Generalize the preview controller** → pick the template + token map by the record's `Channel__c`. The channel token maps + thread-HTML builders live in the Experience Generator `public/script.js`:
   - token replacement block ~lines 10941-11020 (SMS/WhatsApp/RCS tokens: `[[SMS_THREAD_HTML]]`, `[[SMS_THEME]]`, `[[WHATSAPP_THREAD_HTML]]`, `[[RCS_THREAD_HTML]]`, `[[RCS_DEVICE]]`, `[[RCS_BRAND_*]]`, etc.).
   - thread builders: `getMessagingRows` (7169), `buildAppleSmsThreadHtml`/`buildWhatsAppThreadHtml` (~7201/7234 area), `buildRcsThreadHtml` (7948). These turn the `messages` array (same {sender:'user'|'bot',text} shape the email uses) into bubble HTML — PORT the bubble HTML to Apex (string building) and inject into the channel's thread token.
   - **RCS pairing invariant** (see memory): quickReply↔richCard pairing is POSITIONAL (follow-up must be the next sibling). Honor it if you port RCS cards/chips.
3. **Channel-aware Story Studio** — show the right sections per `config.channel`:
   - SMS/WhatsApp: Brand (name/logo/colors), Agent (name/avatar), the 2-way **Messages** thread, maybe a theme (light/dark). Hide email-only fields (subject, hero, 2-column, bullets, CTA).
   - RCS: brand card fields + messages + device/theme.
   - Email section stays as-is for Channel=Email. Simplest: a `get isEmail/isSms/...` from `config.channel` (set it from the record's Channel__c in `wiredStory`, like Industry is), and gate the Email Template section + add channel sections.
4. **Download filename** already derives `2-way_<brand>_<channel>_<date>.html` (channel-agnostic — fine).
5. **Perm set** `Demo_Story_Factory`: add page/class access for any new VF page/controller.
6. **Test:** New Experience → Channel=SMS → Story Studio preview renders the SMS sim; thread plays; Reset works.

## Carry-forward rules / gotchas
- LWS: iframe only loads http(s)/relative/about:blank; keep the VF-via-/apex pattern. Apex `map` var name collides with type `Map` — don't name vars `map`.
- Cloudinary upload CSP (`api_cloudinary_com`) already deployed; image picker (`demoStoryImage`) is reusable for any channel's images/avatars.
- Native same-org Apex callouts need no Named Credential (session token) — see `reference-native-p13n-apex-deploy` (relevant only if you add the SP/Adaptive-Web deploy later, not for these channels).
- **Apex test debt (do before any `push-to-autocumulus`):** DemoStoryGenerator, DemoBrandKitService, StoryEmailPreviewController, TwoWaySimulatorNaming have no tests yet.
- Hard-refresh after every LWC deploy (Lightning caches aggressively).

## Later / separate sessions
- **MCA email integration** (make the generated email appear in Marketing Cloud Advanced, component-based) — own session, needs the MC MCP authenticated (`/mcp`).
- **Adaptive Web / Personalization** object (the native SP deploy via `DemoStudioDeployService` is already proven) and **MCP Simulators** (Slack/Teams) objects — future verticals of the same factory.
