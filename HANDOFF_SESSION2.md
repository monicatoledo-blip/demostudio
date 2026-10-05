# Demo Story Factory — Handoff (after 2026-10-05 PM session)

Working in `~/DemoStudio` (repo `monicatoledo-blip/demostudio`, branch `main`, deploy org **meshmesh**, API v67/v62 for CMS). All work below is committed + pushed through **`d5de0cc`** and deployed to meshmesh. Read memory **`reference-mca-email-content-model`**, **`project-demo-story-factory`** (SESSION 2 block), and **`reference-lwc-lws-iframe-preview`** before starting.

## What shipped this session (verified live by Monica unless noted)
1. Preview "Regex too complicated" crash FIXED (`3c17bdf`) — cap base64 image inlining at 80KB + non-regex empty-`<img>` strip; root cause was a ~2MB string blowing `<apex:outputText escape="false">`.
2. Retail/RCG default thread drops the image-dependent "do you have this in a medium" exchange (`a211c42`).
3. `StoryMcaExportServiceTest` — 7 tests, 94% (`cba3bdb`).
4. **MCA "Push to Marketing Cloud" button now works end-to-end in the UI:**
   - Session fix (`61a5aba`): API-enabled session via VF page `StoryMcaSession` (`{!$Api.Session_ID}`) through `getApiSessionId()`. Lightning `UserInfo.getSessionId()` returns a UI-only session → 401.
   - Workspace picker (`990bea5`, `cca9832`): single-field searchable typeahead, remembers last-used (localStorage), defaults to resolved MCA workspace, filtered to `spaceType=='marketing'`.
   - Open-email link (`1c9f77c`): opens the MCA Content Builder via `/lightning/r/ManagedContent/{id}/view?navigationLocation=content_page`.
5. Email editor shows resolved persona/brand values instead of raw `[[TOKENS]]` (`7b4e34b`) — `emailDisplay` getter; storage keeps tokens.
6. "Download HTML" → "Download Simulator File" + tooltip (`998e2b1`).
7. Preview pane scroll fix (`d5de0cc`) — canvas `overflow-y:auto` + iframe `min-height:1040px` so the ~960px phone sims aren't clipped.

## Next tasks (pick with Monica — recommended order)
1. **MCA picker: BU-first + progressive Folder cascade.** Make it **BU (grayed/default when single BU) → CMS Workspace (done) → Folder** with Next buttons. BU source in MCA-on-Core is TBD (Monica has 1 BU).
2. **Folders (BLOCKED — needs a breakthrough):** list/create folders in a workspace. The `"folder"` content type is `CONTENT_TYPE_DISABLED_FOR_API`; the 9Pu folder entity isn't an SObject; `/connect/cms/folders` POST 404s on every body. Only untested lead = the **`ConnectApi.ManagedContent` Apex namespace** (probe one method per anon run — wrong names are compile errors) or authenticated Connect docs. Deploys land in the workspace ROOT today (works). Full trail in `reference-mca-email-content-model` #6.
3. **DC portability** — replace the hardcoded meshmesh PP/decision (`dcPointName`/`dcDecision` in `StoryMcaExportService`) with one created/picked per org.
4. **Per-industry hero-image suite** — the hero/image library reuses the NBA/unified-profile URL collection; point it at an industry-aware collection.
5. **Home page** + a guided "ship a default brand (e.g. Cumulus/FINS) across all demoable pieces" walkthrough.
6. **Cleanup** ~15 throwaway test emails/content (ZZ *, duplicate "2-Way · …") in Default_Content_Workspace + DEMOS — **ask Monica before deleting** (see `feedback-ask-before-delete`); include any emails she created while testing today.

## Testing-found bugs (Monica, 2026-10-05) — ✅ ALL FOUR FIXED + DEPLOYED (commits e95cac5, 80287d8)
- #1 logo width ✅ `normWidth()` appends `px` to a numeric width in `StoryEmailPreviewController` (template emitted unit-less `width:20;`). Madewell had `logoWidth:"20"` → now `20px` (tiny; bump it up).
- #4 `.com.com` ✅ dropped the literal `.com` after `[[BRAND_DOMAIN]]` in the two template spots (domain already ends in `.com`).
- #3 RCS divider stick ✅ `.resizing` class during drag → CSS `pointer-events:none` on the preview iframe so mouseup isn't swallowed; `isResizing` flag in `demoStoryStudio.js`.
- #2 brand search ✅ swapped the Brand Kit search `lightning-input` for a native `<input type=search> oninput` (lightning-input `change` wasn't firing per keystroke). ⚠️ Persona search (`demoStoryStudio.html:133`) still uses the same `lightning-input onchange` pattern — likely the same latent issue; fix if Monica hits it.
- Controller test `StoryEmailPreviewControllerTest` still 7/7 green after the change.
- ⏳ NEEDS MONICA'S LIVE VERIFY (hard-refresh): all four, especially #2 (uncertain root cause) and #3 (divider).

### (original diagnoses, kept for reference)
1. **Primary logo resize does nothing** (email logo above hero). ROOT CAUSE FOUND: email template `demoStoryEmailTemplate.resource` line 1076 renders `style="width: [[LOGO_WIDTH]]; ..."` and `logoWidth` is stored as a BARE NUMBER (`'140'`, the input is `type="number"`), so the CSS becomes `width: 140;` — invalid (no unit) → browser ignores it, logo stays at intrinsic/max-width:100% regardless of the input. FIX: normalize to append `px` when the value is purely numeric, at substitution time — in `StoryEmailPreviewController` (the `LOGO_WIDTH` tok, ~line 296, used by the live preview) AND the LWC download tokens (`demoStoryStudio.js` ~line 1205). (MCA export `StoryMcaExportService` already does `if (!logoW.contains('px') && !logoW.contains('%')) logoW += 'px';` — copy that.) Do NOT just hardcode `px` in the template — a SE could enter `50%`.
2. **Brand search doesn't filter** (contrast: MCA Workspace typeahead filters fine). INVESTIGATED, NO static difference found — brand search markup (`demoStoryStudio.html` 67-69, `type="search"` + `onchange={handleBrandSearch}`), handler (`handleBrandSearch` js:405 → sets `@track brandSearch` js:372), and getter (`filteredBrandTiles` js:398-402, rendered at html:71) are structurally IDENTICAL to the working workspace picker (html:371-379, `filteredMcaWorkspaces`). Could not repro by reading (Playwright blocked). NEEDS from Monica: does typing do nothing live, or does it filter only after you click away (blur)? If blur-only, it's a `lightning-input type=search` onchange-timing quirk → fix by filtering per keystroke. Low-confidence until repro detail.
3. **RCS builder resize divider sticky** — the draggable editor/preview divider won't release; drag gets stuck. NOT yet investigated — look at the divider pointer-down/move/up handlers in `demoStoryStudio.js` (search `divider`/`drag`/`split`/`pointer`/`mouseup`); likely missing pointer-release / `pointercapture` not released, or the mouseup listener bound to the wrong element. Check if it's RCS-specific (channel) or the handle generally.
4. **`.com.com` in the 2-Way email** — ROOT CAUSE FOUND: template renders `marketing@[[BRAND_DOMAIN]].com` (line 1044) and `agent@[[BRAND_DOMAIN]].com` (line 1505), but `BRAND_DOMAIN` already ends in `.com` (default `cumulusfinserv.com`; brand-kit derivation `demoStoryStudio.js:418` appends `.com`). → `...@cumulusfinserv.com.com`. FIX: drop the literal `.com` after `[[BRAND_DOMAIN]]` in those two template lines (grep confirmed exactly 2 occurrences). Verify no other template spot relies on the trailing `.com`.

## Landmines / how to work here
- **No browser automation** (Playwright blocked). To verify a VF/preview render, headless-screenshot the authenticated page: `sf org open -p "/apex/StoryEmailPreview?id=<id>" --url-only -o meshmesh` → `"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" --headless=new --screenshot=...`. For LWC/Lightning UI, rely on Monica's screenshots.
- **`PageReference.getContent()` runs in a SEPARATE context** — its `System.debug` is NOT in the anon-Apex log and its LimitException is uncatchable from anon. To debug a VF controller, add a temp public method that runs the pipeline directly and call it from anon.
- **Apex reserved-ish names:** don't name vars `map`, `inner`, `time`, `desc`.
- **getContent() can't run after a callout** — pre-warm sessions/content before HTTP in the transaction.
- Commit + push each working step; deploy to meshmesh and have Monica hard-refresh.
- Attribution line for commits: `Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>`.
