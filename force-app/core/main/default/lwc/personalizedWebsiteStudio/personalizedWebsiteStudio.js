import { LightningElement, api, wire, track } from 'lwc';
import { getRecord, getFieldValue, updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import listBrandKits from '@salesforce/apex/DemoBrandKitService.listBrandKits';
import listPersonas from '@salesforce/apex/DemoBrandKitService.listPersonas';
import deployStory from '@salesforce/apex/DemoStudioDeployService.deployStory';
import teardownStory from '@salesforce/apex/DemoStudioDeployService.teardownStory';

import NAME from '@salesforce/schema/Demo_Story__c.Name';
import BRANDKIT from '@salesforce/schema/Demo_Story__c.Brand_Kit__c';
import PERSONA from '@salesforce/schema/Demo_Story__c.Persona__c';
import INDUSTRY from '@salesforce/schema/Demo_Story__c.Industry__c';
import RTOM from '@salesforce/schema/Demo_Story__c.Rtom_Enabled__c';
import CONFIG from '@salesforce/schema/Demo_Story__c.Config_JSON__c';
import STATUS from '@salesforce/schema/Demo_Story__c.Status__c';

const FIELDS = [NAME, BRANDKIT, PERSONA, INDUSTRY, RTOM, CONFIG, STATUS];

const SECTIONS = [
    { id: 'branding', label: 'Branding', icon: 'utility:palette' },
    { id: 'customer', label: 'Customer Profile', icon: 'utility:user' },
    { id: 'content', label: 'Content', icon: 'utility:page' },
    { id: 'offers', label: 'Real-Time Offers', icon: 'utility:offer' }
];

/**
 * Website Studio — the builder for a Personalized Website (Demo_Story__c). Mirrors
 * demoStoryStudio's chrome (toolbar + rail + editor + resizer + live preview) for
 * cohesion, with a leaner editor. The preview iframe loads the WebExperiencePreview
 * VF page (same relative /apex/ pattern the 2-way uses under LWS). Autosaves field
 * edits + a content-override Config_JSON, then bumps a nonce to reload the preview.
 * Separate component from demoStoryStudio — the 2-way path is untouched.
 */
export default class PersonalizedWebsiteStudio extends LightningElement {
    @api recordId;
    @track active = 'branding';
    @track brandKits = [];
    @track personaOptions = [];
    @track cfg = {};            // content overrides (Config_JSON__c)
    brandKitId;
    personaId;
    industry = 'Financial Services';
    rtom = false;
    nonce = Date.now();
    saveState = 'saved';
    deploying = false;
    _loaded = false;
    _t;

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
        if (data) this.brandKits = data.map((k) => ({
            ...k, cls: 'kit-tile' + (k.value === this.brandKitId ? ' kit-tile--active' : '')
        }));
    }
    @wire(listPersonas) wiredPersonas({ data }) {
        if (data) this.personaOptions = data.map((p) => ({ label: p.label, value: p.value }));
    }

    get sections() {
        return SECTIONS.map((s) => ({ ...s, cls: 'studio-tab' + (s.id === this.active ? ' studio-tab--active' : '') }));
    }
    get isBranding() { return this.active === 'branding'; }
    get isCustomer() { return this.active === 'customer'; }
    get isContent() { return this.active === 'content'; }
    get isOffers() { return this.active === 'offers'; }

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
        return '/apex/WebExperiencePreview?id=' + this.recordId + '&n=' + this.nonce;
    }
    get saveClass() {
        return 'save-status save-status--' + (this.saveState === 'saved' ? 'saved' : 'pending');
    }
    get saveLabel() { return this.saveState === 'saved' ? 'All changes saved' : 'Saving…'; }
    get industryOptions() {
        return ['Financial Services', 'Health & Life Sciences', 'Retail & Consumer Goods',
            'Manufacturing', 'Communications, Media & Technology', 'Public Sector',
            'Consumer Business Services', 'Travel & Hospitality', 'Energy & Utilities'].map((i) => ({ label: i, value: i }));
    }
    get personaValue() { return this.personaId; }
    get deployed() { return this._status === 'Deployed'; }

    // content-override fields surfaced in the Content section (write Config_JSON keys)
    get contentFields() {
        return [
            { key: 'coldHeroHeading', label: 'Hero headline' },
            { key: 'coldHeroParagraph1', label: 'Hero paragraph' },
            { key: 'warmInsight1Title', label: 'Personalized insight 1 — title' },
            { key: 'warmInsight2Title', label: 'Personalized insight 2 — title' },
            { key: 'warmInsight3Title', label: 'Personalized insight 3 — title' }
        ].map((f) => ({ ...f, value: this.cfg[f.key] || '' }));
    }

    handleTab(e) { this.active = e.currentTarget.dataset.id; }

    pickKit(e) {
        this.brandKitId = e.currentTarget.dataset.value;
        this.brandKits = this.brandKits.map((k) => ({
            ...k, cls: 'kit-tile' + (k.value === this.brandKitId ? ' kit-tile--active' : '')
        }));
        this.queueSave();
    }
    handlePersona(e) { this.personaId = e.detail.value; this.queueSave(); }
    handleIndustry(e) { this.industry = e.detail.value; this.queueSave(); }
    handleRtom(e) { this.rtom = e.target.checked; this.queueSave(); }
    handleContent(e) {
        const k = e.currentTarget.dataset.key;
        this.cfg = { ...this.cfg, [k]: e.target.value };
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
            this.nonce = Date.now();            // reload the preview with saved state
        } catch (e) {
            this.saveState = 'pending';
            this.toast('Save failed', (e && e.body && e.body.message) || e.message, 'error');
        }
    }

    handleResetPreview() { this.nonce = Date.now(); }

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
