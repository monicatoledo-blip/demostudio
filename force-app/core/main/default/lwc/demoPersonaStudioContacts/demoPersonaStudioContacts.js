import { LightningElement, api, wire, track } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getContactsForPersona from '@salesforce/apex/DemoStudioService.getContactsForPersona';
import searchContacts from '@salesforce/apex/DemoStudioService.searchContacts';
import assignContactsToPersona from '@salesforce/apex/DemoStudioService.assignContactsToPersona';
import unassignContacts from '@salesforce/apex/DemoStudioService.unassignContacts';

export default class DemoPersonaStudioContacts extends LightningElement {
    @api personaId;
    @api personaName;

    @track assigned = [];
    @track searchTerm = '';
    @track searchResults = [];
    @track isSearching = false;
    @track scope = 'mine'; // 'mine' | 'all'
    wiredResult;

    @wire(getContactsForPersona, { personaId: '$personaId', scope: '$scope' })
    wired(result) {
        this.wiredResult = result;
        if (result.data) this.assigned = result.data;
    }

    get hasAssigned() { return this.assigned && this.assigned.length > 0; }
    get assignedCount() { return this.assigned ? this.assigned.length : 0; }
    get hasResults() { return this.searchResults && this.searchResults.length > 0; }

    get decoratedResults() {
        return (this.searchResults || []).map((c) => ({
            ...c,
            accountName: c.Account ? c.Account.Name : '',
            recordUrl: `/lightning/r/Contact/${c.Id}/view`,
            alreadyAssigned: c.Demo_Persona__c === this.personaId,
            takenByOther: c.Demo_Persona__c && c.Demo_Persona__c !== this.personaId,
            statusLabel: this.statusLabelFor(c),
            statusClass: this.statusClassFor(c)
        }));
    }

    statusLabelFor(c) {
        if (c.Demo_Persona__c === this.personaId) return 'Assigned to this persona';
        if (c.Demo_Persona__c) return 'Has different persona';
        return '';
    }
    statusClassFor(c) {
        if (c.Demo_Persona__c === this.personaId) return 'result-status result-status--mine';
        if (c.Demo_Persona__c) return 'result-status result-status--other';
        return 'result-status';
    }

    get decoratedAssigned() {
        return (this.assigned || []).map((c) => ({
            ...c,
            accountName: c.Account ? c.Account.Name : '',
            recordUrl: `/lightning/r/Contact/${c.Id}/view`
        }));
    }

    handleSearchChange(e) {
        this.searchTerm = e.target.value;
        this.doSearch();
    }

    async doSearch() {
        this.isSearching = true;
        try {
            this.searchResults = await searchContacts({ term: this.searchTerm, scope: this.scope });
        } catch (err) {
            this.searchResults = [];
        } finally {
            this.isSearching = false;
        }
    }

    connectedCallback() {
        this.doSearch();
    }

    get scopeOptions() {
        return [
            { label: 'Mine', value: 'mine' },
            { label: 'All',  value: 'all'  }
        ];
    }

    handleScopeChange(e) {
        this.scope = e.detail.value;
        this.doSearch();
    }

    get scopeEmptyCopy() {
        return this.scope === 'mine'
            ? "You haven't assigned any Contacts yet. Switch to All to browse everyone's demo Contacts."
            : 'No matches. Try a broader search or check that the Contact exists in this org.';
    }

    // Optimistically rewrite the current search results so the "assigned"
    // tag reflects the mutation immediately. searchContacts is cacheable,
    // so an imperative re-fetch returns the stale record; we patch the
    // local list instead of waiting for the cache to invalidate.
    _patchSearchResults(contactId, newPersonaValue) {
        if (!this.searchResults || !this.searchResults.length) return;
        this.searchResults = this.searchResults.map((c) =>
            c.Id === contactId ? { ...c, Demo_Persona__c: newPersonaValue } : c
        );
    }

    async handleAssign(e) {
        const contactId = e.currentTarget.dataset.id;
        try {
            await assignContactsToPersona({ contactIds: [contactId], personaId: this.personaId });
            this._patchSearchResults(contactId, this.personaId);
            this.dispatchEvent(new ShowToastEvent({
                title: 'Contact assigned',
                message: 'Persona linked. The Contact page will now render this persona.',
                variant: 'success'
            }));
            await refreshApex(this.wiredResult);
        } catch (err) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Assignment failed',
                message: (err && err.body && err.body.message) || err.message || 'Unknown error',
                variant: 'error'
            }));
        }
    }

    async handleUnassign(e) {
        const contactId = e.currentTarget.dataset.id;
        try {
            await unassignContacts({ contactIds: [contactId] });
            this._patchSearchResults(contactId, null);
            this.dispatchEvent(new ShowToastEvent({
                title: 'Contact unassigned',
                variant: 'success'
            }));
            await refreshApex(this.wiredResult);
        } catch (err) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Unassignment failed',
                message: (err && err.body && err.body.message) || err.message || 'Unknown error',
                variant: 'error'
            }));
        }
    }
}
