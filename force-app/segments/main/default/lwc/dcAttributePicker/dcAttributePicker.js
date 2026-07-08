import { LightningElement, wire, track } from 'lwc';
import describeIndividualDmo from '@salesforce/apex/DataCloudSegmentService.describeIndividualDmo';

const HIDE_FIELDS = new Set([
    'Id', 'IsDeleted', 'CreatedById', 'CreatedDate',
    'LastModifiedById', 'LastModifiedDate', 'SystemModstamp',
    'OwnerId', 'LastActivityDate', 'LastViewedDate', 'LastReferencedDate',
    'Name'
]);

export default class DcAttributePicker extends LightningElement {
    @track describe;
    @track search = '';
    @track expanded = { direct: true, events: false, transactions: false };
    error;

    @wire(describeIndividualDmo)
    wired({ data, error }) {
        if (data) this.describe = data;
        if (error) this.error = error?.body?.message || String(error);
    }

    get rootAttributes() {
        if (!this.describe) return [];
        return this.filter(this.describe.root.attributes.filter(a => !HIDE_FIELDS.has(a.apiName)));
    }
    get relatedObjects() {
        if (!this.describe) return [];
        return this.describe.relatedObjects.map(o => ({
            ...o,
            expanded: this.expanded[o.apiName === 'Demo_DMO_Event__c' ? 'events' : 'transactions'],
            filteredAttributes: this.filter(o.attributes.filter(a => !HIDE_FIELDS.has(a.apiName)))
        }));
    }
    get loading() { return !this.describe && !this.error; }

    filter(attrs) {
        const q = this.search.trim().toLowerCase();
        if (!q) return attrs;
        return attrs.filter(a =>
            a.label.toLowerCase().includes(q) || a.apiName.toLowerCase().includes(q)
        );
    }

    handleSearch(e) { this.search = e.detail.value; }

    toggleDirect() { this.expanded = { ...this.expanded, direct: !this.expanded.direct }; }
    handleRelatedToggle(e) {
        const objectApi = e.currentTarget.dataset.object;
        const key = objectApi === 'Demo_DMO_Event__c' ? 'events' : 'transactions';
        this.expanded = { ...this.expanded, [key]: !this.expanded[key] };
    }

    get directExpanded() { return this.expanded.direct; }

    handleAttrClick(e) {
        const apiName = e.currentTarget.dataset.field;
        const objectApi = e.currentTarget.dataset.object;
        const attr = this.findAttribute(objectApi, apiName);
        if (!attr) return;
        this.dispatchEvent(new CustomEvent('attributeselect', {
            detail: { object: objectApi, attribute: attr }
        }));
    }

    findAttribute(objectApi, apiName) {
        if (!this.describe) return null;
        const target = objectApi === this.describe.root.apiName
            ? this.describe.root
            : this.describe.relatedObjects.find(o => o.apiName === objectApi);
        return target?.attributes.find(a => a.apiName === apiName);
    }
}
