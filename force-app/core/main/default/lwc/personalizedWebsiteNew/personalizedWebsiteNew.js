import { LightningElement, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { createRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import listBrandKits from '@salesforce/apex/DemoBrandKitService.listBrandKits';
import listPersonas from '@salesforce/apex/DemoBrandKitService.listPersonas';
import DEFAULTS_URL from '@salesforce/resourceUrl/webDefaults';

/**
 * Guided create for a Personalized Website — mirrors demoStoryNew for cohesion.
 * Progressive profiling: Brand Kit, Persona, Industry -> Category -> Scenario. The
 * Category/Scenario cascade off webDefaults so the record is BORN with the right
 * industry-specific content (Config_JSON prefilled from the scenario defaults) rather
 * than opening blank. Separate component from demoStoryNew so the 2-way flow is intact.
 */
export default class PersonalizedWebsiteNew extends NavigationMixin(LightningElement) {
    @track brandKits = [];
    @track personaOptions = [];
    @track defaults = {};
    @track brandQuery = '';
    @track personaQuery = '';
    @track brandOpen = false;
    @track personaOpen = false;
    brandKitId;
    personaId;
    industry = 'Financial Services';
    category = '';
    useCase = '';
    rtomEnabled = false;
    creating = false;

    connectedCallback() {
        fetch(DEFAULTS_URL)
            .then((r) => r.json())
            .then((d) => { this.defaults = d || {}; this.initCascade(); })
            .catch(() => { this.defaults = {}; });
    }

    @wire(listBrandKits) wiredKits({ data }) {
        if (data) this.brandKits = data.map((k) => ({ label: k.label, value: k.value }));
    }
    @wire(listPersonas) wiredPersonas({ data }) {
        if (data) this.personaOptions = data.map((p) => ({ label: p.label, value: p.value }));
    }

    get industryOptions() {
        return ['Financial Services', 'Health & Life Sciences', 'Retail & Consumer Goods',
            'Manufacturing', 'Communications, Media & Technology', 'Public Sector',
            'Consumer Business Services', 'Travel & Hospitality', 'Energy & Utilities'].map((i) => ({ label: i, value: i }));
    }

    // --- Industry -> Category -> Scenario cascade (off webDefaults) --------------
    get industryData() { return this.defaults[this.industry] || null; }
    get hasCategories() { const d = this.industryData; return !!(d && d.categories && d.categories.length); }
    get categoryOptions() {
        const d = this.industryData;
        return (d && d.categories ? d.categories : []).map((c) => ({ label: c.label, value: c.key }));
    }
    get useCaseOptions() {
        const d = this.industryData;
        const list = (d && d.scenarios && d.scenarios[this.category]) || [];
        return list.map((u) => ({ label: u.label, value: u.key }));
    }
    initCascade() {
        const d = this.industryData;
        if (d && d.categories && d.categories.length) {
            this.category = d.categories[0].key;
            const sc = d.scenarios[this.category];
            this.useCase = sc && sc[0] ? sc[0].key : '';
        } else { this.category = ''; this.useCase = ''; }
    }

    get brandMatches() { return this._match(this.brandKits, this.brandQuery); }
    get personaMatches() { return this._match(this.personaOptions, this.personaQuery); }
    _match(list, q) {
        const s = (q || '').toLowerCase();
        return (s ? list.filter((o) => (o.label || '').toLowerCase().includes(s)) : list).slice(0, 50);
    }

    handleBrandInput(e) { this.brandQuery = e.target.value; this.brandKitId = null; this.brandOpen = true; }
    handleBrandFocus() { this.brandOpen = true; }
    handleBrandBlur() { window.setTimeout(() => { this.brandOpen = false; }, 200); }
    pickBrand(e) {
        this.brandKitId = e.currentTarget.dataset.value;
        this.brandQuery = e.currentTarget.dataset.label;
        this.brandOpen = false;
    }

    handlePersonaInput(e) { this.personaQuery = e.target.value; this.personaId = null; this.personaOpen = true; }
    handlePersonaFocus() { this.personaOpen = true; }
    handlePersonaBlur() { window.setTimeout(() => { this.personaOpen = false; }, 200); }
    pickPersona(e) {
        this.personaId = e.currentTarget.dataset.value;
        this.personaQuery = e.currentTarget.dataset.label;
        this.personaOpen = false;
    }

    handleIndustry(e) { this.industry = e.detail.value; this.initCascade(); }
    handleCategory(e) {
        this.category = e.detail.value;
        const sc = (this.industryData && this.industryData.scenarios[this.category]) || [];
        this.useCase = sc[0] ? sc[0].key : '';
    }
    handleUseCase(e) { this.useCase = e.detail.value; }
    handleRtom(e) { this.rtomEnabled = e.target.checked; }

    async handleCreate() {
        this.creating = true;
        try {
            const fields = { Industry__c: this.industry, Rtom_Enabled__c: this.rtomEnabled };
            if (this.brandKitId) fields.Brand_Kit__c = this.brandKitId;
            if (this.personaId) fields.Persona__c = this.personaId;
            // Born with the scenario's content so the record opens industry-specific.
            const d = this.industryData;
            const scen = d && d.defaults && d.defaults[this.category] && d.defaults[this.category][this.useCase];
            if (scen) {
                const cfg = { ...scen, adaptiveWebSubIndustry: this.category, adaptiveWebSubUseCase: this.useCase };
                fields.Config_JSON__c = JSON.stringify(cfg);
            }
            const rec = await createRecord({ apiName: 'Demo_Story__c', fields });
            this.dispatchEvent(new ShowToastEvent({ title: 'Personalized Website created', variant: 'success' }));
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: { recordId: rec.id, objectApiName: 'Demo_Story__c', actionName: 'view' }
            });
        } catch (e) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Could not create', message: (e && e.body && e.body.message) || e.message, variant: 'error' }));
        } finally {
            this.creating = false;
        }
    }
}
