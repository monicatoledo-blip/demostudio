import { LightningElement, api, track, wire } from 'lwc';
import { getRecord, getFieldValue, updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import CFG from '@salesforce/schema/Two_Way_Simulator__c.Config_JSON__c';
import ID_FIELD from '@salesforce/schema/Two_Way_Simulator__c.Id';
import listBrandKits from '@salesforce/apex/DemoBrandKitService.listBrandKits';
import getBrandKit from '@salesforce/apex/DemoBrandKitService.getBrandKit';
import listPersonas from '@salesforce/apex/DemoBrandKitService.listPersonas';
import getPersona from '@salesforce/apex/DemoBrandKitService.getPersona';

const FIELDS = [CFG];

// Default email config (Cumulus-flavored) — overlaid by the saved Config_JSON__c.
// Mirrors the Experience Generator email config for parity.
const DEFAULTS = {
    // Branding
    subjectLine: 'A smarter way to save is here',
    brandName: 'Cumulus Financial', brandDomain: 'cumulusfinserv.com',
    marketingAvatarUrl: '',
    logoUrl: 'https://cumulusfinserv-ad61ddfc9e8c.herokuapp.com/images/cumulus-logo.png',
    logoWidth: '140', primaryColor: '#2894D6', headlineTextColor: '#FFFFFF',
    // Email template
    heroImageUrl: '',
    headline: 'Unlock Smart Wealth Building',
    subHeadline: 'Stop stressing about your savings goals',
    featureColumn1: 'Since you already bank with Cumulus Financial, your accounts sync automatically. No manual transfers or complex budgeting spreadsheets required.',
    featureColumn2: 'Track your net worth and adjust your savings goals from anywhere using the Cumulus Financial app, complete with real-time security alerts.',
    featureColumnTextColor: '#FFFFFF', featureSectionColor: '#03A05B',
    bodyParagraph: 'As a valued Cumulus Financial Bank customer, you know how important it is to keep your personal finances organized and secure. But what if you could put your wealth-building entirely on autopilot?\n\nWe’re excited to introduce the Smart Wealth add-on, designed specifically to integrate flawlessly with your existing Cumulus Financial checking and savings accounts.',
    showBullets: true,
    bullet1: 'Seamless Integration: Your spare change round-ups and automated deposits sync instantly.',
    bullet2: 'Mobile Goal Tracking: Adjust your financial targets and manage your funds from anywhere with bank-level security.',
    bullet3: 'Real-Time Insights: Get personalized spending alerts and see projected growth before you make major purchases.',
    replyPromptHeadline: 'Have questions? Just hit reply!',
    replyPromptBody: 'This isn’t a standard “no-reply” marketing email. We are testing a new interactive inbox experience. Simply reply directly to this email and our virtual specialist will answer you instantly.',
    ctaButtonText: 'Send a Reply', ctaButtonColor: '#2894D6',
    // Customer profile
    customerName: 'Rachel Morris', customerFirstName: 'Rachel',
    customerEmail: 'rachel.morris@company.com', customerAvatarUrl: '',
    customerTitle: 'HR Manager', customerCompany: 'Acme Corporation',
    customerMobile: '(555) 123-4567', address: 'Acme Corporation, 123 Business St',
    // AI agent
    agentName: 'Penny', agentAvatarUrl: '',
    // Conversation
    messages: [
        { sender: 'user', text: 'This sounds great! How exactly do the spare change round-ups work with my existing accounts?' },
        { sender: 'bot', text: 'Hi there! Great question! Every time you make a purchase with your Cumulus Financial debit card, we round up to the nearest dollar and automatically transfer the difference to your Smart Wealth savings account.' }
    ]
};

const SECTIONS = [
    { key: 'branding', label: 'Branding', icon: 'utility:brush' },
    { key: 'template', label: 'Email Template', icon: 'utility:email' },
    { key: 'customer', label: 'Customer Profile', icon: 'utility:user' },
    { key: 'agent', label: 'AI Agent', icon: 'utility:einstein' },
    { key: 'convo', label: 'Messages', icon: 'utility:chat' }
];

export default class DemoStoryStudio extends LightningElement {
    @api recordId;
    @track config = { ...DEFAULTS };
    @track activeSection = 'branding';
    @track previewVersion = 1;
    @track brandKits = [];
    @track personaOptions = [];
    loading = false;
    saved = true;
    _timer;

    @wire(listBrandKits)
    wiredKits({ data }) { if (data) this.brandKits = data; }
    @wire(listPersonas)
    wiredPersonas({ data }) { if (data) this.personaOptions = data; }

    // Brand-kit tiles (visual grid like the Persona tab's Brand Kit switcher)
    get brandKitTiles() {
        return (this.brandKits || []).map((k) => ({
            id: k.value, label: k.label, logo: k.logo, hasLogo: !!k.logo,
            swatch: 'background:' + (k.gradient || k.primary || '#0A1F44') + ';',
            cls: 'kit-tile' + (k.value === this.config.brandKitId ? ' kit-tile--active' : '')
        }));
    }

    async handlePickKit(e) {
        const kitId = e.currentTarget.dataset.kitid;
        try {
            const k = await getBrandKit({ kitId });
            const primary = k.Primary_Color__c || this.config.primaryColor;
            const accent = k.Accent_Color__c || primary;
            this._commit({
                brandKitId: kitId, brandName: k.Name || this.config.brandName,
                primaryColor: primary, ctaButtonColor: primary, logoBgColor: primary,
                featureSectionColor: accent, logoUrl: k.Logo_URL__c || this.config.logoUrl,
                marketingAvatarUrl: k.Logo_URL__c || this.config.marketingAvatarUrl
            });
        } catch (err) {
            this.toast('Brand Kit', (err && err.body && err.body.message) || err.message, 'error');
        }
    }

    // Persona inheritance — fills the customer identity from a Demo Persona.
    async handlePersona(e) {
        const personaId = e.detail.value;
        if (!personaId) { this._commit({ personaId: '' }); return; }
        try {
            const p = await getPersona({ personaId });
            const full = ((p.First_Name__c || '') + ' ' + (p.Last_Name__c || '')).trim();
            this._commit({
                personaId: personaId,
                customerName: full || this.config.customerName,
                customerFirstName: p.First_Name__c || this.config.customerFirstName,
                customerEmail: p.Primary_Email__c || this.config.customerEmail,
                customerTitle: p.Title__c || this.config.customerTitle,
                customerCompany: p.Company__c || this.config.customerCompany,
                customerMobile: p.Primary_Phone__c || this.config.customerMobile,
                customerAvatarUrl: p.Avatar_URL__c || this.config.customerAvatarUrl
            });
        } catch (err) {
            this.toast('Persona', (err && err.body && err.body.message) || err.message, 'error');
        }
    }

    // LWS blocks srcdoc/blob/data iframes; only http(s)/relative URLs are allowed.
    // So the preview loads a Visualforce page that renders the saved config.
    get previewUrl() {
        return this.recordId
            ? '/apex/StoryEmailPreview?id=' + this.recordId + '&v=' + this.previewVersion
            : 'about:blank';
    }

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredStory({ data }) {
        if (!data) return;
        const raw = getFieldValue(data, CFG);
        if (raw) { try { this.config = { ...DEFAULTS, ...JSON.parse(raw) }; } catch (e) {} }
        this.previewVersion++;
    }

    // ---- sections / nav
    get tabs() {
        return SECTIONS.map((s) => ({ ...s,
            className: 'studio-tab' + (s.key === this.activeSection ? ' studio-tab--active' : '') }));
    }
    get isBranding() { return this.activeSection === 'branding'; }
    get isTemplate() { return this.activeSection === 'template'; }
    get isCustomer() { return this.activeSection === 'customer'; }
    get isAgent() { return this.activeSection === 'agent'; }
    get isConvo() { return this.activeSection === 'convo'; }
    get subtitle() { return (this.config.brandName || 'New') + ' · 2-Way Email'; }
    handleTab(e) { this.activeSection = e.currentTarget.dataset.key; }

    // ---- editing
    handleInput(e) {
        const f = e.currentTarget.dataset.field;
        const patch = { [f]: e.target.value };
        if (f === 'customerName') patch.customerFirstName = String(e.target.value || '').split(' ')[0];
        this._commit(patch);
    }
    handleToggle(e) {
        this._commit({ [e.currentTarget.dataset.field]: e.target.checked });
    }
    handleImagePick(e) {
        this._commit({ [e.currentTarget.dataset.field]: e.detail.url });
    }
    get senderOptions() {
        return [
            { label: 'Customer', value: 'user' },
            { label: 'Agent', value: 'bot' }
        ];
    }
    handleMsg(e) {
        const i = parseInt(e.currentTarget.dataset.i, 10);
        const msgs = this.config.messages.map((m, idx) => idx === i ? { ...m, text: e.target.value } : m);
        this._commit({ messages: msgs });
    }
    handleSender(e) {
        const i = parseInt(e.currentTarget.dataset.i, 10);
        const msgs = this.config.messages.map((m, idx) => idx === i ? { ...m, sender: e.detail.value } : m);
        this._commit({ messages: msgs });
    }
    addMessage() {
        const prev = (this.config.messages || []);
        const nextSender = prev.length && prev[prev.length - 1].sender === 'user' ? 'bot' : 'user';
        this._commit({ messages: [...prev, { sender: nextSender, text: '' }] });
    }
    removeMessage(e) {
        const i = parseInt(e.currentTarget.dataset.i, 10);
        this._commit({ messages: this.config.messages.filter((m, idx) => idx !== i) });
    }
    _commit(patch) {
        this.config = { ...this.config, ...patch };
        this.saved = false;
        this.scheduleAutosave();
    }
    get decoratedMessages() {
        return (this.config.messages || []).map((m, i) => ({
            i, sender: m.sender || 'user', text: m.text,
            rowLabel: 'Message ' + (i + 1)
        }));
    }

    // ---- preview = Visualforce page loaded by relative URL (LWS-legal), debounced autosave
    scheduleAutosave() {
        if (this._timer) clearTimeout(this._timer);
        this._timer = setTimeout(() => { this.doSave(); }, 900);
    }
    async doSave() {
        try {
            await updateRecord({ fields: {
                [ID_FIELD.fieldApiName]: this.recordId,
                [CFG.fieldApiName]: JSON.stringify(this.config)
            } });
            this.saved = true;
            this.previewVersion++; // reload the VF preview to reflect saved config
        } catch (e) {
            this.toast('Save failed', (e && e.body && e.body.message) || e.message, 'error');
        }
    }

    // ---- save
    async handleSave() {
        this.loading = true;
        await this.doSave();
        if (this.saved) this.toast('Saved', 'Your experience is saved to the record.', 'success');
        this.loading = false;
    }
    async handleDownload() {
        this.loading = true;
        await this.doSave();
        this.loading = false;
        // VF page with ?download=1 sets a filename so the browser downloads the HTML.
        window.open('/apex/StoryEmailPreview?id=' + this.recordId + '&download=1&v=' + this.previewVersion, '_blank');
    }
    get saveStatusText() { return this.saved ? 'All changes saved' : 'Unsaved changes'; }
    get saveStatusPillClass() { return 'save-status ' + (this.saved ? 'save-status--saved' : 'save-status--pending'); }

    // AI generate — wired to EinsteinProvider in the next pass.
    handleGenerate() {
        this.toast('Coming next', 'One-click AI generate (brand → full branded email + conversation) is the next wire-up.', 'info');
    }

    toast(t, m, v) { this.dispatchEvent(new ShowToastEvent({ title: t, message: m, variant: v })); }
}

// Token substitution mirroring the Experience Generator email path.
function renderEmail(tpl, c) {
    const first = c.customerFirstName || (c.customerName || '').split(' ')[0] || '';
    const initials = (s) => (s || '').split(' ').map((w) => w[0]).join('').slice(0, 2).toUpperCase();
    const body = (c.bodyParagraph || '').replace(/\[\[CUSTOMER_FIRST_NAME\]\]/g, first)
        .split(/\n\n+/).filter((p) => p.trim())
        .map((p) => `<p style="font-size:14px;line-height:1.6;color:#393939;margin:0 0 16px 0;">${p.trim()}</p>`).join('');
    const msgs = JSON.stringify((c.messages || []).map((m) => ({ sender: m.sender, text: m.text })))
        .replace(/</g, '\\u003c').replace(/>/g, '\\u003e').replace(/&/g, '\\u0026');
    const map = {
        BRAND_NAME: c.brandName, BRAND_DOMAIN: c.brandDomain, LOGO_URL: c.logoUrl,
        LOGO_BG_COLOR: c.logoBgColor, LOGO_WIDTH: c.logoWidth, PRIMARY_COLOR: c.primaryColor,
        HERO_IMAGE_URL: c.heroImageUrl, SUBJECT_LINE: c.subjectLine,
        HEADLINE: c.headline, HEADLINE_TEXT_COLOR: c.headlineTextColor, SUB_HEADLINE: c.subHeadline,
        BODY_PARAGRAPH: body, CTA_BUTTON_TEXT: c.ctaButtonText, CTA_BUTTON_COLOR: c.ctaButtonColor,
        FEATURE_SECTION_COLOR: c.featureSectionColor, FEATURE_COLUMN_TEXT_COLOR: c.featureColumnTextColor,
        BULLETS_DISPLAY: 'display:none;',
        AGENT_NAME: c.agentName, AGENT_INITIALS: initials(c.agentName), MARKETING_INITIALS: initials(c.agentName),
        AGENT_AVATAR_URL: '', MARKETING_AVATAR_URL: '', CUSTOMER_AVATAR_URL: '',
        CUSTOMER_NAME: c.customerName, CUSTOMER_FIRST_NAME: first, CUSTOMER_INITIALS: initials(c.customerName),
        CUSTOMER_EMAIL: c.customerEmail, CUSTOMER_TITLE: c.customerTitle,
        CUSTOMER_COMPANY: c.customerCompany, CUSTOMER_MOBILE: '',
        REPLY_PROMPT_HEADLINE: c.replyPromptHeadline, REPLY_PROMPT_BODY: c.replyPromptBody,
        EMAIL_MESSAGES_ARRAY: msgs
    };
    let out = tpl;
    for (const k of Object.keys(map)) {
        out = out.replace(new RegExp('\\[\\[' + k + '\\]\\]', 'g'), map[k] == null ? '' : String(map[k]));
    }
    return out;
}
