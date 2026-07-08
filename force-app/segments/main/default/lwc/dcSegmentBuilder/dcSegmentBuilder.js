import { LightningElement, api, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import getSegment from '@salesforce/apex/DataCloudSegmentService.getSegment';
import countMatching from '@salesforce/apex/DataCloudSegmentService.countMatching';
import sampleMatching from '@salesforce/apex/DataCloudSegmentService.sampleMatching';
import saveSegment from '@salesforce/apex/DataCloudSegmentService.saveSegment';
import publishSegment from '@salesforce/apex/DataCloudSegmentService.publishSegment';

const COUNT_DEBOUNCE_MS = 1200;

export default class DcSegmentBuilder extends NavigationMixin(LightningElement) {
    @api recordId;

    @track name = 'Untitled Segment';
    @track description = '';
    @track status = 'Draft';
    @track publishSchedule = 'Daily';
    @track populationCount = 0;
    @track lastRefreshed = null;
    @track sampleMembers = [];
    @track filterTree = { kind:'container', operator:'AND', include:true, children:[] };
    @track counting = false;
    @track publishing = false;
    @track saving = false;

    _wiredSegment;
    _countTimer;

    @wire(getSegment, { segmentId: '$recordId' })
    wired(result) {
        this._wiredSegment = result;
        if (result.data) {
            const s = result.data;
            this.name = s.Name || 'Untitled Segment';
            this.description = s.Description__c || '';
            this.status = s.Status__c || 'Draft';
            this.publishSchedule = s.Publish_Schedule__c || 'Daily';
            this.populationCount = s.Population_Count__c ?? 0;
            this.lastRefreshed = s.Last_Refreshed__c;
            if (s.Filter_Json__c) {
                try {
                    this.filterTree = JSON.parse(s.Filter_Json__c);
                    const canvas = this.template.querySelector('c-dc-segment-canvas');
                    if (canvas) canvas.filterTree = this.filterTree;
                } catch (e) { /* ignore malformed */ }
            }
        }
    }

    get statusVariant() {
        if (this.status === 'Published') return 'success';
        if (this.status === 'Publishing') return 'warning';
        return 'inverse';
    }
    get isPublishDisabled() { return this.publishing || !this.recordId || this.status === 'Publishing'; }
    get isSaveDisabled() { return this.saving; }

    handleAttributeSelect(e) {
        const canvas = this.template.querySelector('c-dc-segment-canvas');
        if (canvas) canvas.addAttribute(e.detail.object, e.detail.attribute);
    }

    handleFilterChange(e) {
        this.filterTree = e.detail;
        this.scheduleCount();
    }

    scheduleCount() {
        clearTimeout(this._countTimer);
        this._countTimer = setTimeout(() => this.runCount(), COUNT_DEBOUNCE_MS);
    }

    async runCount() {
        this.counting = true;
        const json = JSON.stringify(this.filterTree);
        try {
            const [n, samples] = await Promise.all([
                countMatching({ filterJson: json }),
                sampleMatching({ filterJson: json, limitN: 10 })
            ]);
            this.populationCount = n;
            this.sampleMembers = samples;
        } catch (err) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Filter error',
                message: err.body?.message || err.message,
                variant: 'error'
            }));
        } finally {
            this.counting = false;
        }
    }

    handleNameChange(e) { this.name = e.detail; }
    handleDescriptionChange(e) { this.description = e.detail; }
    handleScheduleChange(e) { this.publishSchedule = e.detail; }

    async handleSave() {
        this.saving = true;
        try {
            const payload = {
                Id: this.recordId,
                Name: this.name,
                Description__c: this.description,
                Publish_Schedule__c: this.publishSchedule,
                Filter_Json__c: JSON.stringify(this.filterTree)
            };
            const id = await saveSegment({ segmentJson: JSON.stringify(payload) });
            if (!this.recordId) {
                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: { recordId: id, objectApiName: 'Demo_Segment__c', actionName: 'view' }
                });
            } else {
                if (this._wiredSegment) refreshApex(this._wiredSegment);
                this.dispatchEvent(new ShowToastEvent({ title: 'Saved', variant: 'success' }));
            }
        } catch (err) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Save failed', message: err.body?.message || err.message, variant: 'error'
            }));
        } finally {
            this.saving = false;
        }
    }

    async handlePublish() {
        if (!this.recordId) {
            await this.handleSave();
            return;
        }
        this.publishing = true;
        this.status = 'Publishing';
        try {
            await this.handleSave();
            const pop = await publishSegment({ segmentId: this.recordId });
            this.populationCount = pop;
            this.status = 'Published';
            this.lastRefreshed = new Date().toISOString();
            if (this._wiredSegment) refreshApex(this._wiredSegment);
            this.dispatchEvent(new ShowToastEvent({
                title: 'Segment published',
                message: `${pop} members`,
                variant: 'success'
            }));
        } catch (err) {
            this.status = 'Draft';
            this.dispatchEvent(new ShowToastEvent({
                title: 'Publish failed', message: err.body?.message || err.message, variant: 'error'
            }));
        } finally {
            this.publishing = false;
        }
    }
}
