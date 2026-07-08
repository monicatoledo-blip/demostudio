# DemoStudio — Project Reference

Canonical reference for the DemoStudio project and its add-on modules. Living doc — update as modules ship.

## What this project is

DemoStudio is a Salesforce DX project that gives Solution Engineers a **build-time accelerator**: pre-built LWCs, custom objects, and Agentforce agents that stand in for real customer data during demos. Instead of seeding a fresh org with realistic records before every meeting, SEs open DemoStudio, pick a persona archetype, and get a demo-ready environment in minutes.

**Target orgs:** 1–2 shared demo orgs that SEs point to. Not distributed as a package (yet).

**Not to be confused with:** `~/Workshop Tool/` — a separate, older project on the same machine.

## Modules

Each module is independently deployable via its own `packageDirectories` entry.

| Module | Directory | Status | Description |
|---|---|---|---|
| Core | `force-app/core/` | Shipped (v1) | Persona Studio, Theme Studio, Unified Profile, Agentforce agent |
| Segments | `force-app/segments/` | Planned | Data Cloud Segment Simulator (this doc's Module 2 onward) |
| Journeys | `force-app/journeys/` | Future | Marketing Cloud / Journey Builder simulator |
| Activations | `force-app/activations/` | Future | Activation targets for published segments |

## Shipping strategy

Multi-`packageDirectories` in one repo. No Dev Hub, no Unlocked Packages until the project outgrows 2 target orgs.

```
force-app/
  core/       ← v1 of DemoStudio
  segments/   ← Data Cloud Segment Simulator
  …future modules as sibling directories
```

**Deploy commands:**

```bash
# Deploy core module
sf project deploy start --source-dir force-app/core --target-org shared-demo

# Deploy segments module (once core is deployed)
sf project deploy start --source-dir force-app/segments --target-org shared-demo

# Deploy everything
sf project deploy start --target-org shared-demo
```

**Rollback / partial redeploy:** delete a component from a module directory and redeploy that directory. Salesforce CLI won't remove server-side components on deploy — use `sf project delete source` for that.

## Module: Core

Everything that shipped in DemoStudio v1. Under `force-app/core/main/default/`.

### Custom objects

- **`Demo_Persona__c`** — parent persona record. Fields include `First_Name__c`, `Last_Name__c`, `Company__c`, `Title__c`, `Segment__c` (free-text), `Lifecycle_Stage__c`, `Propensity__c`, `Risk_Tier__c`, `Engagement_Score__c`, `LTV__c`, `Theme__c` (lookup → `Demo_Theme__c`), `Suggested_Opener__c`, `Component_Recipe__c`.
- **Persona children** (all Master-Detail on `Persona__c` → `Demo_Persona__c`, all have `Sort_Order__c`):
  - `Demo_Persona_Identity__c` — Label, Type (Email/Phone/…), Value
  - `Demo_Persona_Insight__c` — Category, Title, CTA_Label, Image_URL, Why_This_Suggestion
  - `Demo_Persona_Activity__c` — Type, Title, Description, Icon, Timestamp_Label
  - `Demo_Persona_Journey__c` — Journey_Name, Business_Unit, Status, Enrolled_Date
  - `Demo_Persona_Segment__c` — Label (segment tags per persona)
  - `Demo_Persona_Kpi__c`, `Demo_Persona_Alert__c`, `Demo_Persona_Nba__c` — bundle collections
- **`Demo_Theme__c`** — brand kit. Colors, fonts, logos, header style.
- **`Persona_Archetype__mdt`** — 4 records: Commercial_Cross_Sell, Wealth_HNW, Retail_SMB, Marketing_Engagement.
- **`Demo_Studio_Config__mdt`** — global config (single Default record).

### Apex classes

- **`DemoStudioService`** — READ adapter. `@AuraEnabled(cacheable=true)` methods: `getPersonaBundleForContact`, `getPersonaBundle`, `getContactsForPersona`, `searchContacts`, `listArchetypes`, `getArchetypePayload`, `listThemes`, `getTheme`. Save methods: `saveTheme`, `savePersonaBundle`, `assignContactsToPersona`, `unassignContacts`.
- **`DemoStudioPersonaBuilder`** — invocable from Flow; builds persona+children from JSON.
- **`DemoStudioPersonaGenerator`** — router with `generateForLwc()` and `generateCollectionForPersona()`. Delegates to `IPersonaProvider`.
- **Providers:** `IPersonaProvider`, `ArchetypeProvider`, `EinsteinProvider`, `PersonaPromptBuilder`, `BrandScraper`.

### LWCs

- **`demoPersonaStudio`** — Persona record-page shell (Story / Identity / Contacts / Collection / Recipe / Theme tabs). Custom CSS + SLDS icons, not `lightning-tabset`. Theme injected via CSS vars.
- **Persona tabs:** `demoPersonaStudioStory`, `demoPersonaStudioIdentity`, `demoPersonaStudioContacts`, `demoPersonaStudioCollection`, `demoPersonaStudioRecipe`, `demoPersonaStudioTheme`.
- **`demoPersonaGenerator`** — chat modal for archetype-based generation.
- **Profile widgets:** `demoUnifiedProfileHeader`, `demoUnifiedProfileShell`, `demoActivityTimeline`, `demoActiveJourneyTracker`, `demoAgentforceBrief`, `demoAiInsightsAlerts`, `demoCrossSellInsights`, `demoKpiStatRow`, `demoLikelihoodScoreCard`, `demoNextBestActions`, `demoRelatedIdentities`.
- **`demoThemeStudio`** — brand kit editor.
- **`demoPreviewFrame`** — live preview shell.
- **Utilities:** `demoIconPicker`, `demoLogoColorExtractor`, `demoPersonaDefaults`, `demoStudioHelp`.

### App / navigation

- Custom app: `Demo_Studio.app` with nav items Personas, Themes, Contacts.
- FlexiPages: `Persona_Studio_Record_Page`, `Contact_Demo_Studio_Record_Page`, `Theme_Studio_Record_Page`.
- Action overrides on the three objects route the standard View to the FlexiPages.

### Permission set

`Demo_Studio_Admin` — CRUD + ViewAll + ModifyAll on all persona/theme objects, class access to all DemoStudio Apex, tab visibility, app visibility, exhaustive FLS on persona/theme fields.

### Agentforce agent

`Demo_Studio_Persona_Agent` (AgentforceEmployeeAgent). Subagents: `persona_generator`, `off_topic`, `ambiguous_question`. Spec: `specs/Demo_Studio_Persona_Agent-AgentSpec.md`.

## Module: Segments (Data Cloud Segment Simulator)

**Status: planned.** Under `force-app/segments/main/default/` (created empty during Module 1 reorg).

### Why

SEs need to demo Data Cloud segmentation without seeding a real Data Cloud instance. This module stands in: pixel-close Segment Builder UI, real SOQL population counts against a synthetic Individual pool, publish flow that materializes membership records. Personas from Core can be tagged as members of published segments.

### Design principles

- **Fully customizable, vertical-neutral.** DMO schema is generic. Verticals layered on via swappable seed packs + custom fields added in Setup.
- **Describe-driven filter UI.** Any field on `Demo_DMO_Individual__c` (standard or custom) appears in the attribute picker automatically. No code change required.
- **Real SOQL, real counts.** Population numbers come from actual queries — not hardcoded.

### Synthetic DMO schema

Under `force-app/segments/main/default/objects/`:

- **`Demo_DMO_Individual__c`** (~5,000 seeded rows) — Identity (name/email/phone/DOB/age formula/gender), Location (country/state/city/postal), Segmentation dimensions (`Household_Income__c`, `Lifecycle_Stage__c`, `Engagement_Score__c`, `Ltv__c`, `Tier__c`, `Preferred_Channel__c`, `Consent_Marketing__c`, `Consent_Sms__c`, `Last_Interaction_Date__c`), Extensibility (`Vertical_Tags__c` multi-picklist, `Custom_Attributes__c` JSON escape hatch).
- **`Demo_DMO_Event__c`** (~50,000 rows) — MD to Individual. `Event_Type__c` picklist (EmailOpen/EmailClick/SmsClick/PageView/FormSubmit/Login/AppointmentBooked/PurchaseCompleted/OnboardingStepComplete), `Event_Date__c`, `Event_Value__c`, `Channel__c`, `Source__c`.
- **`Demo_DMO_Transaction__c`** (~15,000 rows) — MD to Individual. `Transaction_Date__c`, `Amount__c`, `Category__c`, `Product_Name__c`, `Status__c`.
- **`Demo_Segment__c`** — the segment record. `Description__c`, `Segment_On__c`, `Status__c` (Draft/Published/Publishing/Archived), `Filter_Json__c`, `Population_Count__c`, `Last_Refreshed__c`, `Publish_Schedule__c`, `Owner_Persona__c` (lookup → `Demo_Persona__c`).
- **`Demo_Segment_Membership__c`** — junction, materialized on publish. MD to both Segment and Individual.

### Apex

- **`DataCloudSegmentService`** — `@AuraEnabled` reads (`listSegments`, `getSegment`, `describeIndividualDmo`, `countMatching`, `sampleMatching`) and writes (`saveSegment`, `publishSegment`, `linkPersonaToSegment`).
- **`DataCloudFilterCompiler`** — parses filter tree JSON, produces safe WHERE clause with bind vars. Field/operator whitelist against describe result. Related-attribute filters compile to sub-queries: `Id IN (SELECT Individual__c FROM Demo_DMO_Event__c WHERE …)`.
- **`DmoSeedRunner`** — reads a Static Resource seed pack, bulk-inserts individuals/events/transactions.
- Tests: `DataCloudSegmentServiceTest`, `DataCloudFilterCompilerTest`, `DmoSeedRunnerTest` — ≥75% coverage, operator-matrix + injection tests.

### LWCs

- **`dcSegmentBuilder`** — top-level shell. Three-pane grid: attribute picker | canvas | metadata. Debounced live count (1500ms).
- **`dcAttributePicker`** — left rail. Tree of direct + related attributes, search box, click-to-add.
- **`dcSegmentCanvas`** — center. Include/Exclude containers with nested AND/OR groups. Operator dropdown driven by field type. Related-attribute rows expand into inline sub-filters.
- **`dcSegmentMetadata`** — right. Population count (animated), publish schedule, owner persona lookup, sample members panel.
- **`dcSegmentList`** — Segments home tab.
- **`dcSeedAdmin`** — admin-only seed runner UI.

### App / permission set

- Custom app `Data_Cloud_Studio` OR new nav item on existing `Demo_Studio` app (decide at build time).
- Tabs: `Demo_Segment__c`, `Demo_DMO_Individual__c`, `Demo_DMO_Event__c`, `Demo_DMO_Transaction__c`, `dcSeedAdmin`.
- FlexiPages: `Segment_Builder_Record_Page`, `Segments_Home_Page`.
- Permission set: `Data_Cloud_Studio_Admin`.

### Seed data packs

Static Resources at `force-app/segments/main/default/staticresources/`:

- `demoDmoSeedFins.resource` — banking + wealth + insurance + asset mgmt
- `demoDmoSeedHealthcare.resource` — patient tier, appointments, procedures
- `demoDmoSeedRetail.resource` — loyalty tier, cart/purchase events, orders
- `demoDmoSeedOnboarding.resource` — new-user cohort, step completion, activation

Generated offline by `scripts/generate-seed.js` (dev-time only, not deployed).

## Development workflow

### First-time setup

```bash
git clone <this-repo-url> DemoStudio
cd DemoStudio
sf org login web --alias shared-demo
sf project deploy start --target-org shared-demo
sf org assign permset --name Demo_Studio_Admin --target-org shared-demo
```

Once Segments module ships, also:

```bash
sf org assign permset --name Data_Cloud_Studio_Admin --target-org shared-demo
sf apex run --file scripts/apex/seedDmoData.apex --target-org shared-demo
```

### Per-feature loop

1. Branch: `git checkout -b feature/<short-name>`
2. Edit under the appropriate module directory
3. Deploy just that module: `sf project deploy start --source-dir force-app/<module> --target-org shared-demo`
4. Test in-org
5. `git commit`, `git push`, open PR

### Adding a new module

1. Create `force-app/<module>/main/default/`
2. Add to `sfdx-project.json` `packageDirectories`
3. Document it in this file under **Modules** and add a **Module: `<Name>`** section

## Verification checklist (Segments module)

Run these after deploying Segments to confirm end-to-end health:

- [ ] `sf project deploy start --source-dir force-app/segments --target-org <org>` succeeds
- [ ] `sf apex run tests --class-names DataCloudSegmentServiceTest DataCloudFilterCompilerTest DmoSeedRunnerTest --target-org <org>` — all pass, ≥75% coverage
- [ ] Assign `Data_Cloud_Studio_Admin` permission set
- [ ] Seed Admin: run FINS pack, verify row counts (5k / 50k / 15k) via `sf data query`
- [ ] Build a segment with `Household_Income__c > 100000`, verify count matches `SELECT COUNT() FROM Demo_DMO_Individual__c WHERE Household_Income__c > 100000`
- [ ] Related-attribute filter: "Individuals with Events where Event_Type__c = 'EmailOpen' in last 30 days" — verify count matches manual SOQL
- [ ] Add a custom field to `Demo_DMO_Individual__c` in Setup, reload builder, confirm it appears in attribute picker
- [ ] Publish a segment, confirm `Demo_Segment_Membership__c` rows equal population count
- [ ] Link persona to segment, confirm it shows up in `Demo_Persona_Segment__c`
- [ ] Switch seed pack (Healthcare), verify attribute picker still shows all fields, sample members reflect healthcare data

## References

- Plan file: `~/.claude/plans/reactive-whistling-glacier.md`
- Agent spec: `specs/Demo_Studio_Persona_Agent-AgentSpec.md`
- Salesforce DX docs: https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/
