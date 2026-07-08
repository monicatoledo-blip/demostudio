import { LightningElement, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { refreshApex } from '@salesforce/apex';
import listSegments from '@salesforce/apex/DataCloudSegmentService.listSegments';

const COLUMNS = [
    {
        label: 'Segment',
        fieldName: 'linkUrl',
        type: 'url',
        typeAttributes: { label: { fieldName: 'Name' }, target: '_self' },
        wrapText: true
    },
    { label: 'Status', fieldName: 'Status__c', type: 'text', initialWidth: 120 },
    { label: 'Population', fieldName: 'Population_Count__c', type: 'number', cellAttributes: { alignment: 'right' }, initialWidth: 120 },
    { label: 'Schedule', fieldName: 'Publish_Schedule__c', type: 'text', initialWidth: 120 },
    { label: 'Last Refreshed', fieldName: 'Last_Refreshed__c', type: 'date', initialWidth: 180 },
    { label: 'Modified', fieldName: 'LastModifiedDate', type: 'date', initialWidth: 180 }
];

export default class DcSegmentList extends NavigationMixin(LightningElement) {
    columns = COLUMNS;
    scope = 'all';
    _rawResult;

    @wire(listSegments, { scope: '$scope' })
    wiredSegments(result) {
        this._rawResult = result;
    }

    get scopeOptions() {
        return [
            { label: 'All segments', value: 'all' },
            { label: 'My segments', value: 'mine' }
        ];
    }

    get segments() {
        const rows = this._rawResult?.data;
        if (!rows) return [];
        return rows.map(r => ({
            ...r,
            linkUrl: `/lightning/r/Demo_Segment__c/${r.Id}/view`
        }));
    }

    get loading() { return !this._rawResult || (!this._rawResult.data && !this._rawResult.error); }
    get errorMessage() { return this._rawResult?.error?.body?.message; }

    handleScopeChange(e) { this.scope = e.detail.value; }
    handleRefresh() { if (this._rawResult) refreshApex(this._rawResult); }

    handleNewSegment() {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: { objectApiName: 'Demo_Segment__c', actionName: 'new' }
        });
    }
}
