import { LightningElement, api, wire, track } from 'lwc';
import { getRecord, getFieldValue, updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import SCHEMA_URL from '@salesforce/resourceUrl/webFieldSchema';
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
    view = 'agent';
    saveState = 'saved';
    deploying = false;
    _loaded = false;
    _t;

    connectedCallback() {
        fetch(SCHEMA_URL)
            .then((r) => r.json())
            .then((d) => { this.schemaSections = (d && d.sections) || []; })
            .catch(() => { this.schemaSections = []; });
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
        return s.fields.map((f) => ({ field: f, value: this.cfg[f.id] === undefined ? '' : this.cfg[f.id] }));
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

    handleTab(e) { this.active = e.currentTarget.dataset.id; }

    handlePersona(e) { this.personaId = e.detail.value; this.queueSave(); }
    handleIndustry(e) { this.industry = e.detail.value; this.queueSave(); }
    handleRtom(e) { this.rtom = e.target.checked; this.queueSave(); }

    // data-driven field edit -> Config_JSON
    handleFieldChange(e) {
        const { id, value } = e.detail;
        this.cfg = { ...this.cfg, [id]: value };
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
