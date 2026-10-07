# Handoff — Wire "Deploy to Org" to real Salesforce Personalization (SP) for the native Website Studio

**Mission:** make the **Deploy to Org** button on a Personalized Website (`Demo_Story__c`) actually
stand up real **Salesforce Personalization** in meshmesh — so the adaptive-web demo is "demo → deploy,"
not just a sim. Adaptive Web itself is now mature (RCG storefront + 9 verticals + Flux imagery, all
shipped); SP backend wiring is the next focused chunk.

Working dir `~/DemoStudio` (repo monicatoledo-blip/demostudio, branch main, deploy org **meshmesh**,
API v67 / P13N v67). Commit messages end with:
`Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>` (no backticks in msgs — zsh).

## READ FIRST (memories)
- `reference-native-p13n-apex-deploy` — the native Apex deploy pattern (session-token same-org callout,
  Connect REST shapes for schema/transformer/point, StaticResource hosting, teardown order + retries).
- `reference-p13n-connect-rest` — the WPM gate learnings. **CRITICAL gotchas:** (1) WPM's PP picker only
  lists PPs bound to a **REAL-TIME profile data graph** (meshmesh has `Real_Time_Personalization`);
  (2) WPM reads **content zones/page types from the sitemap registered to the CONNECTOR** (Setup → Data
  Cloud → Websites & Mobile Apps → connector → Replace Sitemap), NOT the page's inline sitemap;
  (3) transformer DELETE is the SINGULAR query-param form `external-apps/transformer?idOrName=` (plural
  path silently no-ops); (4) no decision `criteria` on the API tier.
- `project-demostudio-web-commerce` (this project) + `project-sp-demo-builder` (the Heroku app this was
  ported from — its `buildConnectorSitemap` is the thing to port to Apex) + `reference-mca-email-content-model`
  (the getContent()/API-session pattern + the `UserInfo.getSessionId()` 401 gotcha).

## CURRENT STATE (what's already there)
- **`DemoStudioDeployService.cls`** (356 lines) WORKS end-to-end for the OLD stage-driven model: creates
  a Content Schema + WebApp Handlebars transformer + Personalization Point w/ decision, hosts HTML as a
  Tooling-API StaticResource, and tears all of it down (order: points → transformers → schemas → static
  resources, with retries). Entry points `@AuraEnabled deployStory(Id)` / `teardownStory(Id)`; impls
  `deployStoryImpl` / `teardownStoryImpl` are anon-callable. Artifacts tracked in
  `Demo_Story__c.Deployed_Artifacts__c` (JSON) + `Status__c`.
- **THE BLOCKER:** `deployStoryImpl` reads child **`Demo_Stage__c`** records (looks for a `Channel__c ==
  'Adaptive Web'` stage) and throws **"Story has no Adaptive Web stage to deploy."** The Website Studio
  stores EVERYTHING in **`Demo_Story__c.Config_JSON__c`** (no Demo_Stage__c children), so Deploy throws
  today. Fields on the Story: `Data_Space__c, Connector_Id__c, Profile_Data_Graph__c, Config_JSON__c,
  Deployed_Artifacts__c, Last_Deployed__c, Status__c, Rtom_Enabled__c, Industry__c, Brand__c, colors…`.
- The studio (`personalizedWebsiteStudio`) toolbar already calls deploy/teardown.
- Deploy uses `UserInfo.getSessionId()` for the same-org callout — ⚠️ in a Lightning @AuraEnabled context
  that's a UI-only session that 401s against Connect REST. **Fix like StoryMcaExportService did:** source
  an API-enabled session from a VF page (`{!$Api.Session_ID}`), pre-warmed before any callout. (StoryMcaSession
  page already exists + is granted in a perm set — reuse that pattern.)

## TASKS (suggested order; each shippable)
1. **Reconcile `deployStoryImpl` to read `Config_JSON__c`** instead of `Demo_Stage__c`. Parse the config;
   derive the hero decision attributes (header / subheader / cta / backgroundImageUrl) from the web fields
   (`coldHeroHeading`/`coldHeroEyebrow`/`intentTriggerText`/`adaptiveHeroImageUrl` or the warm equivalents).
   Keep the existing schema/transformer/point/decision creation. Make deploy work for BOTH a flavor-less
   services record and an RCG commerce record (same fields exist).
2. **Fix the session** (API-enabled VF session, per above) so the Connect REST callouts don't 401 when the
   button is clicked in Lightning. (Deploy is callout-after-DML → runs in its own transaction; fine from a
   button, but anon tests need their own run.)
3. **Bind to a REAL-TIME profile data graph** so the created PP surfaces in WPM. Resolve the org's RT graph
   (meshmesh = `Real_Time_Personalization`); hard-require it (clear error if absent). (See the FK-SOQL
   resolver pattern in `reference-mca-email-content-model` for discovering a per-org graph.)
4. **Port `buildConnectorSitemap` to Apex** (from the Heroku SP Demo Builder — `~/Projects/sfpersonalizationnextgen/sf/*.js`
   or the `brand-sp-app` repo). Emit a connector-uploadable sitemap (single always-matching Homepage page
   type + the sim's content zones) and expose it (a) as a downloadable file + instructions to Replace Sitemap
   on the connector, and/or (b) auto-register if the API allows. This is what makes WPM show the zones/points.
5. **Hosted landing page (optional / hard):** hosting the FULLY RESOLVED sim HTML (what "Download HTML"
   produces) as a StaticResource needs the JS engine to run — Apex can't run it, and `getContent()` on
   WebExperiencePreview returns the UNRESOLVED shell (engine runs client-side). Options: defer (host the
   raw template, or skip the landing and only deploy SP objects + sitemap), OR have the Studio POST the
   iframe's resolved `lastHtml` (it already has it for Download) to an Apex endpoint that hosts it as a
   StaticResource. **Recommend: client-posts-resolved-HTML** — the LWC already holds the resolved HTML.
6. **Open-in-WPM** affordance + verify the point/zone appears in the WPM Embedded-Content picker end-to-end.
7. **Tests:** `DemoStudioDeployServiceTest` for the Config_JSON path (mock the callouts like
   StoryMcaExportServiceTest does) before any push-to-autocumulus.

## VERIFY / GOTCHAS
- Test deploy from **anon Apex** calling `deployStoryImpl(storyId)` (callout-after-DML = own transaction).
  meshmesh seed RCG record: **`a3BKh000001DdpfMAC`**. Don't deploy to Cumulus Jr.
- `AuraHandledException` can't be thrown from anon — throw a custom exception in the impl, convert at the
  @AuraEnabled boundary.
- Teardown must stay correct (singular transformer delete + retry on DEPENDENCY_EXISTS).
- Playwright is blocked on the managed device — verify WPM visually via Monica's screenshots.

## DONE THIS SESSION (context)
RCG storefront flavor (template + PLP catalog + cart ticker), 9 verticals + dining content, Flux (fal.ai
FLUX1.1 [pro]) imagery everywhere except FINS (Monica's curated set), image-library keyword search,
editable Product Catalog config section, RTOM offer-reframe on warm tiles. Image pipeline + resumable
generator backed up at `~/rcg_build`. Latest commit on main: see `git log`.
