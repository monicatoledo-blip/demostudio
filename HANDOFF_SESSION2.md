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

## Landmines / how to work here
- **No browser automation** (Playwright blocked). To verify a VF/preview render, headless-screenshot the authenticated page: `sf org open -p "/apex/StoryEmailPreview?id=<id>" --url-only -o meshmesh` → `"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" --headless=new --screenshot=...`. For LWC/Lightning UI, rely on Monica's screenshots.
- **`PageReference.getContent()` runs in a SEPARATE context** — its `System.debug` is NOT in the anon-Apex log and its LimitException is uncatchable from anon. To debug a VF controller, add a temp public method that runs the pipeline directly and call it from anon.
- **Apex reserved-ish names:** don't name vars `map`, `inner`, `time`, `desc`.
- **getContent() can't run after a callout** — pre-warm sessions/content before HTTP in the transaction.
- Commit + push each working step; deploy to meshmesh and have Monica hard-refresh.
- Attribution line for commits: `Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>`.
