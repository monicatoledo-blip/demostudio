import { LightningElement, api } from 'lwc';

export default class DemoPersonaStudioIdentity extends LightningElement {
    @api persona;
    @api propensityOptions;
    @api riskOptions;
    @api lifecycleOptions;

    // Display Currency picklist for money values (LTV / KPIs). Pure display —
    // does NOT enable org-level multi-currency.
    get currencyOptions() {
        return [
            { label: 'USD — US Dollar',        value: 'USD' },
            { label: 'EUR — Euro',             value: 'EUR' },
            { label: 'GBP — British Pound',    value: 'GBP' },
            { label: 'CAD — Canadian Dollar',  value: 'CAD' },
            { label: 'AUD — Australian Dollar',value: 'AUD' },
            { label: 'JPY — Japanese Yen',     value: 'JPY' },
            { label: 'MXN — Mexican Peso',     value: 'MXN' },
            { label: 'INR — Indian Rupee',     value: 'INR' }
        ];
    }

    acceptedAvatarFormats = ['.png', '.jpg', '.jpeg', '.gif', '.svg', '.webp'];

    get hasAvatar() {
        return !!(this.persona && this.persona.Avatar_URL__c);
    }

    get initials() {
        const f = (this.persona && this.persona.First_Name__c) || '';
        const l = (this.persona && this.persona.Last_Name__c) || '';
        return `${(f[0] || '').toUpperCase()}${(l[0] || '').toUpperCase()}` || '?';
    }

    bubbleChange(e) {
        const field = e.target.dataset.field;
        const value = e.detail.value !== undefined ? e.detail.value : e.target.value;
        const numeric = e.target.type === 'number';
        this.dispatchEvent(new CustomEvent('change', {
            detail: { field, value: numeric ? Number(value) : value }
        }));
    }

    handleAvatarUploaded(e) {
        const files = e.detail.files || [];
        if (!files.length) return;
        // lightning-file-upload creates ContentDocuments attached to recordId.
        // The public download URL: /sfc/servlet.shepherd/version/download/<contentVersionId>
        // For the LWC to render the image, use the ContentVersion download URL.
        const cv = files[0].contentVersionId || files[0].contentBodyId;
        const url = `/sfc/servlet.shepherd/version/download/${cv}`;
        this.dispatchEvent(new CustomEvent('change', {
            detail: { field: 'Avatar_URL__c', value: url }
        }));
    }
}
