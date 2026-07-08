import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import generateCollectionForPersona from '@salesforce/apex/DemoStudioPersonaGenerator.generateCollectionForPersona';

export default class DemoPersonaStudioCollection extends LightningElement {
    @api title;
    @api collection; // 'identities' | 'insights' | 'activities' | 'journeys' | 'kpis' | 'alerts' | 'segments' | 'nbas'
    @api rows;
    @api typeOptions;   // primary picklist options (Type/Category/BU)
    @api statusOptions; // secondary (used by journeys)
    @api personaId;     // needed by file-upload widgets (e.g. NBA image upload)
    acceptedImageFormats = ['.png', '.jpg', '.jpeg', '.gif', '.svg', '.webp'];

    @track isSparkling = false;

    // Show sparkle buttons only on collections that AI can generate meaningfully.
    // (Skips identities — those are usually tied to real contact info.)
    get canSparkle() {
        return !!this.personaId && ['kpis','alerts','segments','nbas','insights','activities','journeys'].includes(this.collection);
    }

    async handleSparkleRegenerate() { await this._sparkle('replace'); }
    async handleSparkleAdd()        { await this._sparkle('append'); }

    async _sparkle(mode) {
        if (!this.personaId) return;
        this.isSparkling = true;
        try {
            const existing = JSON.stringify((this.rows || []).map(({ _index, _key, ...rest }) => rest));
            const result = await generateCollectionForPersona({
                personaId: this.personaId,
                collectionKey: this.collection,
                mode,
                existingRowsJson: existing,
                extraHint: ''
            });
            if (result && result.error) {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'AI generation failed',
                    message: result.error,
                    variant: 'error'
                }));
                return;
            }
            let newRows = [];
            try { newRows = JSON.parse(result.rowsJson) || []; } catch (e) { newRows = []; }
            if (!newRows.length) {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'AI returned no rows',
                    message: 'Try a different mode or check the persona has enough context.',
                    variant: 'warning'
                }));
                return;
            }
            this.dispatchEvent(new CustomEvent('sparkle', {
                detail: { collection: this.collection, mode, rows: newRows }
            }));
            this.dispatchEvent(new ShowToastEvent({
                title: mode === 'replace' ? 'Regenerated' : 'Added new rows',
                message: `${newRows.length} row${newRows.length === 1 ? '' : 's'} ${mode === 'replace' ? 'replaced' : 'appended'}. Auto-save will persist.`,
                variant: 'success'
            }));
        } finally {
            this.isSparkling = false;
        }
    }

    get isIdentities() { return this.collection === 'identities'; }
    get isInsights()   { return this.collection === 'insights'; }
    get isActivities() { return this.collection === 'activities'; }
    get isJourneys()   { return this.collection === 'journeys'; }
    get isKpis()       { return this.collection === 'kpis'; }
    get isAlerts()     { return this.collection === 'alerts'; }
    get isSegments()   { return this.collection === 'segments'; }
    get isNbas()       { return this.collection === 'nbas'; }

    onFieldChange(e) {
        const index = parseInt(e.target.dataset.index, 10);
        const field = e.target.dataset.field;
        const type = e.target.type;
        let value;
        if (type === 'checkbox' || type === 'toggle') {
            value = e.target.checked;
        } else {
            value = e.detail && e.detail.value !== undefined ? e.detail.value : e.target.value;
            if (type === 'number' && value !== '' && value != null) value = Number(value);
        }
        this.dispatchEvent(new CustomEvent('change', {
            detail: {
                collection: this.collection,
                index,
                field,
                value
            }
        }));
    }

    // Icon picker uses a component event with its own detail shape.
    onIconPick(e) {
        const { value, rowIndex, fieldName } = e.detail || {};
        if (fieldName == null || rowIndex == null) return;
        this.dispatchEvent(new CustomEvent('change', {
            detail: {
                collection: this.collection,
                index: parseInt(rowIndex, 10),
                field: fieldName,
                value
            }
        }));
    }

    // NBA hero image upload — mirrors demoPersonaStudioIdentity.handleAvatarUploaded.
    // The uploaded file becomes a ContentVersion attached to the persona; we
    // build a Shepherd download URL and stuff it into the row's Image_URL__c.
    onNbaImageUpload(e) {
        const index = parseInt(e.target.dataset.index, 10);
        const files = e.detail.files || [];
        if (!files.length) return;
        const cv = files[0].contentVersionId || files[0].contentBodyId;
        const url = `/sfc/servlet.shepherd/version/download/${cv}`;
        this.dispatchEvent(new CustomEvent('change', {
            detail: {
                collection: this.collection,
                index,
                field: 'Image_URL__c',
                value: url
            }
        }));
    }

    onAdd() {
        this.dispatchEvent(new CustomEvent('add', {
            detail: { collection: this.collection }
        }));
    }

    onRemove(e) {
        const index = parseInt(e.currentTarget.dataset.index, 10);
        this.dispatchEvent(new CustomEvent('remove', {
            detail: { collection: this.collection, index }
        }));
    }
}
