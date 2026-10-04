import { LightningElement, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { createRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import listBrandKits from '@salesforce/apex/DemoBrandKitService.listBrandKits';
import listPersonas from '@salesforce/apex/DemoBrandKitService.listPersonas';

/**
 * Guided create for a 2-Way Simulator — no Experience Name field (the trigger
 * derives it). Brand Kit + Persona are single-field typeaheads.
 */
export default class DemoStoryNew extends NavigationMixin(LightningElement) {
    @track brandKits = [];
    @track personaOptions = [];
    @track brandQuery = '';
    @track personaQuery = '';
    @track brandOpen = false;
    @track personaOpen = false;
    brandKitId;
    personaId;
    channel = 'Email';
    industry = 'Financial Services';
    creating = false;

    @wire(listBrandKits) wiredKits({ data }) {
        if (data) this.brandKits = data.map((k) => ({ label: k.label, value: k.value }));
    }
    @wire(listPersonas) wiredPersonas({ data }) {
        if (data) this.personaOptions = data.map((p) => ({ label: p.label, value: p.value }));
    }

    get channelOptions() {
        return ['Email', 'SMS', 'RCS', 'WhatsApp'].map((c) => ({ label: c, value: c }));
    }
    get industryOptions() {
        return ['Financial Services', 'Health & Life Sciences', 'Retail & Consumer Goods',
            'Manufacturing', 'Communications, Media & Technology', 'Public Sector',
            'Consumer Business Services', 'Travel & Hospitality', 'Energy & Utilities'].map((i) => ({ label: i, value: i }));
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

    handleChannel(e) { this.channel = e.detail.value; }
    handleIndustry(e) { this.industry = e.detail.value; }

    async handleCreate() {
        this.creating = true;
        try {
            const fields = { Channel__c: this.channel, Industry__c: this.industry };
            if (this.brandKitId) fields.Brand_Kit__c = this.brandKitId;
            if (this.personaId) fields.Persona__c = this.personaId;
            const rec = await createRecord({ apiName: 'Two_Way_Simulator__c', fields });
            this.dispatchEvent(new ShowToastEvent({ title: 'Experience created', variant: 'success' }));
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: { recordId: rec.id, objectApiName: 'Two_Way_Simulator__c', actionName: 'view' }
            });
        } catch (e) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Could not create', message: (e && e.body && e.body.message) || e.message, variant: 'error' }));
        } finally {
            this.creating = false;
        }
    }
}
