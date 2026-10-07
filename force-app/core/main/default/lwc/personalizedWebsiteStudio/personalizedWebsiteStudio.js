import { LightningElement, api, wire, track } from 'lwc';
import { getRecord, getFieldValue, updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import SCHEMA_URL from '@salesforce/resourceUrl/webFieldSchema';
import DEFAULTS_URL from '@salesforce/resourceUrl/webDefaults';
import IMGLIB_URL from '@salesforce/resourceUrl/webImageLibrary';
import listBrandKits from '@salesforce/apex/DemoBrandKitService.listBrandKits';
import listPersonas from '@salesforce/apex/DemoBrandKitService.listPersonas';
import deployStory from '@salesforce/apex/DemoStudioDeployService.deployStory';
import teardownStory from '@salesforce/apex/DemoStudioDeployService.teardownStory';

import BRANDKIT from '@salesforce/schema/Demo_Story__c.Brand_Kit__c';
import PERSONA from '@salesforce/schema/Demo_Story__c.Persona__c';
import INDUSTRY from '@salesforce/schema/Demo_Story__c.Industry__c';
import RTOM from '@salesforce/schema/Demo_Story__c.Rtom_Enabled__c';
import CONFIG from '@salesforce/schema/Demo_Story__c.Config_JSON__c';
import STATUS from '@salesforce/schema/Demo_Story__c.Status__c';

const FIELDS = [BRANDKIT, PERSONA, INDUSTRY, RTOM, CONFIG, STATUS];
const SECTION_ICONS = {
    'brand-customer': 'utility:palette', 'business-line-scenario': 'utility:merge',
    'home-page-content': 'utility:home', 'market-insights': 'utility:knowledge_base',
    'category-page': 'utility:page', 'ai-chat': 'utility:chat', 'offer-overlay-frame': 'utility:resource_capacity',
    'offer-cards': 'utility:cart', 'handoff-form': 'utility:form', 'return-hero': 'utility:image',
    'return-content-tiles': 'utility:tile_card_list', 'advanced': 'utility:settings'
};
// Each editor section maps to the sim "page" it edits, so switching sections
// navigates the preview straight there (and edits reload onto it, not the intro).
const SECTION_VIEW = {
    setup: 'cold', 'business-line-scenario': 'cold', 'home-page-content': 'cold',
    'market-insights': 'cold', 'category-page': 'category', 'ai-chat': 'agent',
    'offer-overlay-frame': 'overlay', 'offer-cards': 'overlay', 'handoff-form': 'landing',
    'return-hero': 'adapted', 'return-content-tiles': 'adapted', 'advanced': 'cold'
};

/**
 * Website Studio — the full lift-and-shift builder for a Personalized Website.
 * Mirrors demoStoryStudio chrome. The editor is DATA-DRIVEN from the webFieldSchema
 * static resource (the Experience Generator adaptive-web form: 12 sections / 137
 * fields) rendered via <c-web-field>; plus a fixed Setup section for the DemoStudio
 * associations (Brand Kit / Persona / Industry / RTOM). Every field edit writes to
 * Config_JSON__c, autosaves, and reloads the live preview. The preview drives the
 * ported adaptive runtime (Cold / Agent / Adapted + Restart). 2-way path untouched.
 */
export default class PersonalizedWebsiteStudio extends LightningElement {
    @api recordId;
    @track active = 'setup';
    @track schemaSections = [];
    @track defaults = {};   // webDefaults: subIndustryKey -> { label, useCases[], defaults{} }
    @track imageLibrary = {}; // webImageLibrary: industry -> [image urls]
    @track brandKits = [];
    @track personaOptions = [];
    @track cfg = {};
    @track showBrandPicker = false;
    @track brandSearch = '';
    brandKitId;
    personaId;
    industry = 'Financial Services';
    rtom = false;
    nonce = Date.now();
    view = 'cold';   // studio opens on Branding (setup) -> show the home page
    saveState = 'saved';
    deploying = false;
    _loaded = false;
    _t;

    connectedCallback() {
        fetch(SCHEMA_URL)
            .then((r) => r.json())
            .then((d) => { this.schemaSections = (d && d.sections) || []; })
            .catch(() => { this.schemaSections = []; });
        fetch(DEFAULTS_URL)
            .then((r) => r.json())
            .then((d) => { this.defaults = d || {}; })
            .catch(() => { this.defaults = {}; });
        fetch(IMGLIB_URL)
            .then((r) => r.json())
            .then((d) => { this.imageLibrary = d || {}; })
            .catch(() => { this.imageLibrary = {}; });
    }

    // The current industry's image pool, fed to each field's picker as the browse grid.
    get industryImages() { return this.imageLibrary[this.industry] || []; }

    // Cascade: Industry (record field) -> Category (sub-industry) -> Scenario.
    // webDefaults is keyed by INDUSTRY label; each has categories[] + scenarios{cat:[]}
    // + defaults{cat:{scenario:{fieldId:value}}}. Only industries that have authored
    // content appear; others fall back to a single "Custom" category.
    get industryData() { return this.defaults[this.industry] || null; }
    get currentCategory() { return this.cfg.adaptiveWebSubIndustry || ''; }
    get categoryOptions() {
        const d = this.industryData;
        const base = (d && d.categories ? d.categories : []).map((c) => ({ label: c.label, value: c.key }));
        return base.length ? base : [{ label: 'Custom (no industry defaults)', value: 'custom' }];
    }
    get useCaseOptions() {
        const d = this.industryData;
        const list = (d && d.scenarios && d.scenarios[this.currentCategory]) || [];
        return list.map((u) => ({ label: u.label, value: u.key }));
    }

    // Editor display: fields are STORED with tokens (${brandName} etc.) so they swap,
    // but shown RESOLVED so the SE sees "Ally", not the raw token. Mirrors the 2-way
    // email editor's emailDisplay. A hand-edited field just stores the literal text.
    get brandNameResolved() {
        const k = this.selectedKit;
        return (k && k.label) || this.cfg.adaptiveBrandName || '';
    }
    get personaFirstName() {
        const p = this.personaOptions.find((o) => o.value === this.personaId);
        if (p && p.label) return p.label.split(' ')[0];
        return this.cfg.adaptivePersonaFirstName || '';
    }
    get agentNameResolved() {
        const a = this.cfg.adaptiveAgentName;
        return a && a.indexOf('${') === -1 ? a : 'Penny';
    }
    resolveTokens(str) {
        if (str == null) return '';
        let out = String(str);
        const b = this.brandNameResolved, fn = this.personaFirstName, an = this.agentNameResolved;
        if (b) out = out.replace(/\$\{brandName\}/g, b).replace(/\[\[BRAND_NAME\]\]/g, b);
        if (fn) out = out.replace(/\$\{firstName\}/g, fn).replace(/\[\[CUSTOMER_FIRST_NAME\]\]/g, fn);
        out = out.replace(/\$\{agentName\}/g, an).replace(/\bPenny\b/g, an);
        return out;
    }

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredRecord({ data }) {
        if (!data) return;
        this.brandKitId = getFieldValue(data, BRANDKIT);
        this.personaId = getFieldValue(data, PERSONA);
        this.industry = getFieldValue(data, INDUSTRY) || 'Financial Services';
        this.rtom = !!getFieldValue(data, RTOM);
        const raw = getFieldValue(data, CONFIG);
        if (raw) { try { this.cfg = JSON.parse(raw); } catch (e) { this.cfg = {}; } }
        this._status = getFieldValue(data, STATUS);
        if (!this._loaded) { this._loaded = true; this.nonce = Date.now(); }
    }
    @wire(listBrandKits) wiredKits({ data }) {
        if (data) { this._kits = data; this.brandKits = data.map((k) => this.kitTile(k)); }
    }
    kitTile(k) {
        return {
            id: k.value, label: k.label, logo: k.logo, hasLogo: !!k.logo,
            swatch: 'background:' + (k.primary || '#0A1F44') + ';',
            cls: 'kit-tile' + (k.value === this.brandKitId ? ' kit-tile--active' : '')
        };
    }

    // Collapsed brand picker (mirrors the 2-way Story Studio): show the selected
    // kit + a Change button that expands a searchable tile grid.
    get selectedKit() {
        const k = (this._kits || []).find((x) => x.value === this.brandKitId);
        if (!k) return null;
        return { label: k.label, logo: k.logo, hasLogo: !!k.logo, swatch: 'background:' + (k.primary || '#0A1F44') + ';' };
    }
    get brandChangeLabel() { return this.selectedKit ? 'Change brand' : 'Choose a brand kit'; }
    get filteredBrandTiles() {
        const q = (this.brandSearch || '').toLowerCase();
        return this.brandKits.filter((k) => !q || (k.label || '').toLowerCase().includes(q)).slice(0, 60);
    }
    toggleBrandPicker() { this.showBrandPicker = !this.showBrandPicker; }
    handleBrandSearch(e) { this.brandSearch = e.target.value; }
    handlePickKit(e) {
        this.brandKitId = e.currentTarget.dataset.kitid;
        this.brandKits = (this._kits || []).map((k) => this.kitTile(k));
        this.showBrandPicker = false;
        this.brandSearch = '';
        this.queueSave();
    }
    @wire(listPersonas) wiredPersonas({ data }) {
        if (data) this.personaOptions = data.map((p) => ({ label: p.label, value: p.value }));
    }

    // --- rail: fixed Setup + the schema sections ---------------------------------
    get tabs() {
        const setup = { id: 'setup', label: 'Branding', icon: 'utility:palette' };
        const rest = this.schemaSections.map((s) => ({
            id: s.id, label: s.label, icon: SECTION_ICONS[s.id] || 'utility:record'
        }));
        return [setup, ...rest].map((t) => ({
            ...t, cls: 'studio-tab' + (t.id === this.active ? ' studio-tab--active' : '')
        }));
    }
    get isSetup() { return this.active === 'setup'; }
    get activeSection() { return this.schemaSections.find((s) => s.id === this.active); }
    get activeTitle() {
        const s = this.activeSection;
        return this.isSetup ? 'Branding' : (s ? s.label : '');
    }
    // active section's fields with current values bound in
    get activeFields() {
        const s = this.activeSection;
        if (!s) return [];
        return s.fields.map((f) => {
            let field = f;
            // Category cascades from Industry; Scenario cascades from Category.
            if (f.id === 'adaptiveWebSubIndustry') {
                field = { ...f, type: 'picklist', options: this.categoryOptions };
            } else if (f.id === 'adaptiveWebSubUseCase') {
                field = { ...f, type: 'picklist', options: this.useCaseOptions };
            }
            const raw = this.cfg[f.id] === undefined ? '' : this.cfg[f.id];
            // Picklists keep raw keys; text/content fields show resolved tokens.
            const value = field.type === 'picklist' ? raw : this.resolveTokens(raw);
            return { field, value };
        });
    }

    get subtitle() {
        const kit = this.brandKits.find((k) => k.value === this.brandKitId);
        return (kit ? kit.label : 'No brand kit') + ' · ' + this.industry;
    }
    get frameStyle() {
        const kit = this.brandKits.find((k) => k.value === this.brandKitId);
        const a = (kit && kit.primary) || '#0A1F44';
        const b = (kit && kit.accent) || '#1C3B7B';
        return `--demo-bg-gradient: linear-gradient(135deg, ${a} 0%, ${b} 100%);`;
    }
    get previewUrl() {
        return '/apex/WebExperiencePreview?id=' + this.recordId + '&n=' + this.nonce + '&view=' + this.view;
    }
    get saveClass() { return 'save-status save-status--' + (this.saveState === 'saved' ? 'saved' : 'pending'); }
    get saveLabel() { return this.saveState === 'saved' ? 'All changes saved' : 'Saving…'; }
    get industryOptions() {
        return ['Financial Services', 'Health & Life Sciences', 'Retail & Consumer Goods',
            'Manufacturing', 'Communications, Media & Technology', 'Public Sector',
            'Consumer Business Services', 'Travel & Hospitality', 'Energy & Utilities'].map((i) => ({ label: i, value: i }));
    }
    get personaValue() { return this.personaId; }
    get deployed() { return this._status === 'Deployed'; }
    get viewTabs() {
        return [{ id: 'cold', label: 'Cold' }, { id: 'agent', label: 'Agent' }, { id: 'adapted', label: 'Adapted' }]
            .map((v) => ({ ...v, cls: 'view-tab' + (v.id === this.view ? ' view-tab--active' : '') }));
    }

    handleTab(e) {
        this.active = e.currentTarget.dataset.id;
        // Always navigate the preview to the page this section edits — instantly via
        // the postMessage harness (no iframe reload). Drive unconditionally (not only
        // on a view change) so e.g. opening AI Chat always re-opens the chat panel
        // even if the sim's state has drifted from `view` since the last drive.
        const v = SECTION_VIEW[this.active] || this.view;
        this.view = v;
        this.driveSim(v);
    }

    handlePersona(e) { this.personaId = e.detail.value; this.queueSave(); }
    handleIndustry(e) {
        this.industry = e.detail.value;
        // Only auto-apply the first Category/Scenario if this industry actually has
        // authored content loaded. Otherwise just persist the industry (don't save a
        // bogus 'custom' — that happens if webDefaults hasn't fetched yet, and it
        // strands the record so the cascade can't recover).
        const d = this.industryData;
        if (d && d.categories && d.categories.length) {
            this.applyCategory(d.categories[0].key);
        } else {
            this.queueSave();
        }
    }
    handleRtom(e) { this.rtom = e.target.checked; this.queueSave(); }

    // data-driven field edit -> Config_JSON
    handleFieldChange(e) {
        const { id, value } = e.detail;
        // Changing Category or Scenario repopulates the content fields with that
        // scenario's default values (so the SE sees what they're overriding).
        if (id === 'adaptiveWebSubIndustry') { this.applyCategory(value); return; }
        if (id === 'adaptiveWebSubUseCase') { this.applyScenario(this.currentCategory, value); return; }
        // "Recommended pick" is mutually exclusive across the 3 offer cards — turning
        // one on turns the others off (radio behavior, not 3 independent toggles).
        const bm = id.match(/^card(\d)_bestMatch$/);
        if (bm && (value === true || value === 'true')) {
            const next = { ...this.cfg };
            ['card1_bestMatch', 'card2_bestMatch', 'card3_bestMatch'].forEach((k) => { next[k] = (k === id); });
            this.cfg = next;
            this.queueSave();
            return;
        }
        this.cfg = { ...this.cfg, [id]: value };
        this.queueSave();
    }
    firstScenarioKey(cat) {
        const d = this.industryData;
        const list = (d && d.scenarios && d.scenarios[cat]) || [];
        return list[0] ? list[0].key : '';
    }
    applyCategory(cat) { this.applyScenario(cat, this.firstScenarioKey(cat)); }
    applyScenario(cat, uc) {
        const d = this.industryData;
        const dd = (d && d.defaults && d.defaults[cat] && d.defaults[cat][uc]) || {};
        this.cfg = { ...this.cfg, ...dd, adaptiveWebSubIndustry: cat, adaptiveWebSubUseCase: uc };
        this.queueSave();
    }

    queueSave() {
        this.saveState = 'pending';
        window.clearTimeout(this._t);
        this._t = window.setTimeout(() => this.save(), 900);
    }
    async save() {
        const fields = { Id: this.recordId };
        fields[BRANDKIT.fieldApiName] = this.brandKitId || null;
        fields[PERSONA.fieldApiName] = this.personaId || null;
        fields[INDUSTRY.fieldApiName] = this.industry;
        fields[RTOM.fieldApiName] = this.rtom;
        fields[CONFIG.fieldApiName] = JSON.stringify(this.cfg);
        try {
            await updateRecord({ fields });
            this.saveState = 'saved';
            this.nonce = Date.now();
        } catch (e) {
            this.saveState = 'pending';
            this.toast('Save failed', (e && e.body && e.body.message) || e.message, 'error');
        }
    }

    // --- preview controls --------------------------------------------------------
    handleView(e) {
        this.view = e.currentTarget.dataset.view;
        this.driveSim(this.view);
    }
    handleRestart() {
        // Re-drive the current view; the sim resets its flow from there.
        this.driveSim(this.view);
        this.nonce = Date.now();
    }
    driveSim(view) {
        const frame = this.template.querySelector('iframe.preview-iframe');
        if (frame && frame.contentWindow) {
            frame.contentWindow.postMessage({ type: 'web-sim-drive', view }, '*');
        }
    }

    handleDownload() {
        // Ask the (already-rendered) preview iframe to save its resolved HTML — same
        // tab, no in-between page. The VF page builds the self-contained file.
        const frame = this.template.querySelector('iframe.preview-iframe');
        if (frame && frame.contentWindow) {
            frame.contentWindow.postMessage({ type: 'web-download' }, '*');
        }
    }

    async handleDeploy() { await this.runBackend(deployStory, 'Deployed to this org'); }
    async handleTeardown() { await this.runBackend(teardownStory, 'Torn down'); }
    async runBackend(fn, verb) {
        this.deploying = true;
        try {
            await fn({ storyId: this.recordId });
            this.toast('Success', verb + '.', 'success');
        } catch (e) {
            this.toast('Backend error', (e && e.body && e.body.message) || e.message, 'error');
        } finally {
            this.deploying = false;
        }
    }
    toast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}
