# Handoff — Personalized Websites (native Adaptive Web / SP) + Commerce

Working in `~/DemoStudio` (repo `monicatoledo-blip/demostudio`, branch `main`, deploy org **meshmesh**, API v67 / CMS v62 / P13N v67). All work committed + pushed through **`b5074ec`**. Read memory **`project-demostudio-web-commerce`** (has the full detail + RESUME HERE), plus `project-demo-story-factory`, `reference-mca-email-content-model`, `reference-native-p13n-apex-deploy`, `reference-p13n-connect-rest`, `reference-lwc-lws-iframe-preview`.

## Why (interview brief, Desktop PDF)
"Static demo → demo-to-deploy"; Marketing+Commerce as a connected narrative: Data Cloud → Marketing Cloud → Commerce Cloud. Monica's stakeholder = the SE; deliverable = scalable deployable demos. Email→MCA already nails Marketing. This project brings **Personalized Websites / Salesforce Personalization** native, and (next) **Commerce**.

## What's BUILT (live in meshmesh)
- **"Personalized Websites" tab** (object `Demo_Story__c`): guided New (Industry→Category→Scenario cascade, prefills `Config_JSON__c` with the scenario defaults so the record is born industry-specific) → **Website Studio** record-page builder.
- **Website Studio** (`personalizedWebsiteStudio` LWC) mirrors the 2-way chrome: collapsed Brand Kit picker, rail of sections, **full data-driven editor** (every field from `webFieldSchema` rendered via `webField`), **live preview**, section→preview-page navigation (SECTION_VIEW), Cold/Agent/Adapted + Restart, **Download HTML** (in-tab via postMessage), Deploy/Tear Down. Editor shows RESOLVED tokens (brand/persona/agent) while storing tokens.
- **Preview** = `WebExperiencePreview` VF page: runs the **verbatim-ported** `demoWebEngine` (EG adaptive-web content engine) over `demoWebTemplate` (EG adaptive-web.html), fed by a hidden shim form (boolean fields e.g. `card*_bestMatch` are CHECKBOXES; brand/persona/agent passed via **formData**, not just DOM — the engine's `brandPlain`/`getAdaptivePersona` read formData). Agent icon = brand-colored Agentforce astro on a white circle, inlined as a data URI (self-contained, export-safe). Chat composer is a wrapping textarea.
- **8 industries** in `webDefaults` (content + per-industry images + agent name): Financial Services (Penny), Health & Life Sciences (Remy), Travel & Hospitality (Journey), Communications/Media/Technology (Max), Manufacturing (Mack), Public Sector (Ada), Energy & Utilities (Watt), Consumer Business Services (Nova). ~113 tokenized fields/scenario; 0 copy repeats; 0 within-scenario image dupes.
- **Per-industry image library** (`webImageLibrary`) shared by the Website Studio picker AND the 2-way **Hero** picker (`demoStoryImage` gained an optional `libraryImages` override — additive, 2-way otherwise unchanged). Icon fields link to the Font Awesome gallery.
- Record naming trigger `PersonalizedWebsiteNaming` (no more record-ID in the browser tab).

## Image pipeline (curation layer — SEs swap duds via the Browse-library picker)
- `~/.pixabay_key` + `/tmp/imgfetch3.py` (keyword JSON `{hero,cold[3],warm[3],cat[2]}` → Pixabay (browser UA; `per_page=20`, retry/fallback) → **Cloudinary unsigned re-host** cloud `dfx98jgdc` preset `salesforcepersonalization` folder `webimglib` → stable res.cloudinary.com URLs). Dedup within scenario; swap repeats for other images from THAT industry's pool only.
- **Quality upgrade PENDING**: Pixabay is hit-or-miss (Monica curates duds via picker). Monica is getting an **Unsplash** demo key (API approval wait). **Vecteezy** key `bTH3tDoM8Xk1sXg9Ckcz81nk` authenticates (Authorization: Bearer) but **V1 is deprecated → use V2**; the V2 endpoint path is unknown (docs at vecteezy.com/api-docs are JS-rendered; `/v2/resources` and `/v2/content/search` returned empty/HTML). NEXT AGENT: get the V2 search+download endpoint from the rendered docs (or Vecteezy support), then re-run the per-vertical fetch for higher-quality images (reuse imgfetch3's structure, swap the fetch fn).

## OPEN (next priorities)
1. **RCG / Retail & Consumer Goods = the STOREFRONT flavor** (deferred all session). Browsing/catalog + **abandoned-cart** scenario; its OWN template (not the services layout). THE commerce anchor of the three-cloud thread: storefront cart-abandon → Data Cloud → the **MCA abandoned-cart email already built** (`StoryMcaExportService`) → warm personalized return.
2. **Deploy → real SP backend** (not wired for native web): `DemoStudioDeployService.deployStory` reads `Demo_Stage__c` stages, but the studio stores everything in `Demo_Story__c.Config_JSON__c` → it would throw "no Adaptive Web stage". Reconcile to read Config_JSON + host resolved HTML as a StaticResource + **port `buildConnectorSitemap` to Apex** + create personalization points/decisions + Open-in-WPM.
3. **Generate-with-AI paste-back button** — copy-prompt-out/paste-back like the 2-way (`DemoStoryGenerator`/`EinsteinProvider`), per scenario.
4. **RTOM** — optional per-tile flag on Content Tiles → "Real-Time Offer" badge + a real Personalization decision (`Rtom_Enabled__c` master toggle exists).
5. Owed: Apex/Jest tests for `WebExperiencePreviewController` + `personalizedWebsiteStudio` before push-to-autocumulus.

## Gotchas
- After deploying `webDefaults`/`webImageLibrary`, **LOG OUT/IN** (stale cache shows old industries / `custom`).
- **Do NOT touch** the 2-way sims / unified-profile tools except the additive hero-library inherit already done.
- Commit + push each step; deploy to meshmesh; commit attribution `Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>` (no backticks in commit messages — zsh).
