import { LightningElement, api } from 'lwc';

// Match each currency to a locale so the format feels native.
// Falls back to en-US for unknown codes.
const LOCALE_BY_CURRENCY = {
    USD: 'en-US',
    EUR: 'en-IE',
    GBP: 'en-GB',
    CAD: 'en-CA',
    AUD: 'en-AU',
    JPY: 'ja-JP',
    MXN: 'es-MX',
    INR: 'en-IN'
};

export default class DemoUnifiedProfileHeader extends LightningElement {
    @api persona;
    @api theme;
    @api identities;
    @api segments;

    // Optional caller-supplied initial tab. Once the user clicks a tab
    // in the header, their manual choice wins (userOverrode).
    _initialTab = 'card';
    userOverrode = false;
    @api
    get initialTab() { return this._initialTab; }
    set initialTab(v) {
        if (v && (v === 'card' || v === 'individuals') && v !== this._initialTab) {
            this._initialTab = v;
            if (!this.userOverrode) this.activeTab = v;
        }
    }

    get decoratedSegments() {
        return (this.segments || []).map((s, i) => ({
            ...s,
            _key: s.Id || `seg-${i}`
        }));
    }
    get hasSegments() {
        return this.decoratedSegments.length > 0;
    }

    activeTab = 'card'; // 'card' | 'individuals'

    get fullName() {
        if (!this.persona) return '';
        return `${this.persona.First_Name__c || ''} ${this.persona.Last_Name__c || ''}`.trim();
    }

    get subtitle() {
        if (!this.persona) return '';
        const parts = [];
        if (this.persona.Title__c) parts.push(this.persona.Title__c);
        if (this.persona.Company__c) parts.push(this.persona.Company__c);
        return parts.join(' | ');
    }

    get engagementValue() {
        return this.persona && this.persona.Engagement_Score__c != null
            ? `${this.persona.Engagement_Score__c}%`
            : '—';
    }

    get engagementPct() {
        return Math.min(100, Math.max(0, (this.persona && this.persona.Engagement_Score__c) || 0));
    }
    get engagementDashOffset() {
        // Circle circumference = 2 * pi * r = 2 * pi * 42 ≈ 263.89
        const circumference = 263.89;
        return circumference - (circumference * this.engagementPct) / 100;
    }
    get engagementRingStyle() {
        return '';
    }

    get propensityBarStyle() {
        const map = { 'Low': 15, 'Medium': 45, 'High': 75, 'Very High': 95 };
        const pct = map[this.persona && this.persona.Propensity__c] || 50;
        return `--propensity-pct: ${pct}%;`;
    }

    get formattedLTV() {
        const v = this.persona && this.persona.LTV__c;
        if (v == null) return '—';
        const code = (this.persona && this.persona.Currency_Code__c) || 'USD';
        // Locale is picked to match the currency for a native-feeling format
        // (e.g. €11,450 with EUR, ¥11450 with JPY). Falls back to en-US.
        const locale = LOCALE_BY_CURRENCY[code] || 'en-US';
        try {
            return v.toLocaleString(locale, {
                style: 'currency',
                currency: code,
                maximumFractionDigits: code === 'JPY' ? 0 : 0
            });
        } catch (e) {
            // Bad currency code → fall back to plain formatting
            return v.toLocaleString('en-US');
        }
    }

    get logoUrl() {
        if (!this.theme) return null;
        if (this.theme.Logo_URL__c) return this.theme.Logo_URL__c;
        if (this.theme.Logo_Static_Resource__c) return `/resource/${this.theme.Logo_Static_Resource__c}`;
        return null;
    }

    get hasLogo() { return !!this.logoUrl; }

    get isCardActive()        { return this.activeTab === 'card'; }
    get isIndividualsActive() { return this.activeTab === 'individuals'; }
    get cardTabClass()        { return this.isCardActive        ? 'demo-tab demo-tab--active' : 'demo-tab'; }
    get individualsTabClass() { return this.isIndividualsActive ? 'demo-tab demo-tab--active' : 'demo-tab'; }

    get emails()    { return (this.identities || []).filter((i) => i.Type__c === 'Email'); }
    get phones()    { return (this.identities || []).filter((i) => i.Type__c === 'Phone'); }
    get addresses() { return (this.identities || []).filter((i) => i.Type__c === 'Address'); }
    get emailCount()   { return this.emails.length; }
    get phoneCount()   { return this.phones.length; }
    get addressCount() { return this.addresses.length; }
    get hasEmails()    { return this.emailCount > 0; }
    get hasPhones()    { return this.phoneCount > 0; }
    get hasAddresses() { return this.addressCount > 0; }
    get individualCount() {
        return (this.identities || []).length;
    }

    showCardTab()        { this.activeTab = 'card'; this.userOverrode = true; }
    showIndividualsTab() { this.activeTab = 'individuals'; this.userOverrode = true; }

    // Avatar fallback logic
    avatarLoadFailed = false;

    get showAvatarImage() {
        return !!(this.persona && this.persona.Avatar_URL__c) && !this.avatarLoadFailed;
    }

    get avatarInitials() {
        if (!this.persona) return '?';
        const f = (this.persona.First_Name__c || '').trim()[0] || '';
        const l = (this.persona.Last_Name__c || '').trim()[0] || '';
        return `${f}${l}`.toUpperCase() || '?';
    }

    handleAvatarError() {
        this.avatarLoadFailed = true;
    }
}
