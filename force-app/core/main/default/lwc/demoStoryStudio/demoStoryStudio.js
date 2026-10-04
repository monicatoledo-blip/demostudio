import { LightningElement, api, track, wire } from 'lwc';
import { getRecord, getFieldValue, updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import CFG from '@salesforce/schema/Two_Way_Simulator__c.Config_JSON__c';
import ID_FIELD from '@salesforce/schema/Two_Way_Simulator__c.Id';
import BRAND_KIT from '@salesforce/schema/Two_Way_Simulator__c.Brand_Kit__c';
import PERSONA_FIELD from '@salesforce/schema/Two_Way_Simulator__c.Persona__c';
import INDUSTRY_FIELD from '@salesforce/schema/Two_Way_Simulator__c.Industry__c';
import CHANNEL_FIELD from '@salesforce/schema/Two_Way_Simulator__c.Channel__c';
import listBrandKits from '@salesforce/apex/DemoBrandKitService.listBrandKits';
import getBrandKit from '@salesforce/apex/DemoBrandKitService.getBrandKit';
import listPersonas from '@salesforce/apex/DemoBrandKitService.listPersonas';
import getPersona from '@salesforce/apex/DemoBrandKitService.getPersona';
import generateEmail from '@salesforce/apex/DemoStoryGenerator.generateEmail';

const FIELDS = [CFG, BRAND_KIT, PERSONA_FIELD, INDUSTRY_FIELD, CHANNEL_FIELD];

// Default email config (Cumulus-flavored) — overlaid by the saved Config_JSON__c.
// Mirrors the Experience Generator email config for parity.
const DEFAULTS = {
    // Channel + messaging-channel appearance (shared by SMS/WhatsApp/RCS)
    channel: 'Email',
    theme: 'light',
    messagingAgentHeader: '',
    // Branding
    subjectLine: 'A smarter way to save is here',
    brandName: 'Cumulus Financial', brandDomain: 'cumulusfinserv.com',
    marketingAvatarUrl: '',
    logoUrl: '',
    logoWidth: '140', primaryColor: '#2894D6', headlineTextColor: '#FFFFFF',
    // Email template
    heroImageUrl: '',
    headline: 'Unlock Smart Wealth Building',
    subHeadline: 'Stop stressing about your savings goals',
    featureColumn1: 'Since you already bank with [[BRAND_NAME]], your accounts sync automatically — checking, savings, and the Smart Wealth add-on in one view. No manual transfers, no exporting statements, and no complex budgeting spreadsheets to keep up. Everything updates in real time, so you always know exactly where you stand.',
    featureColumn2: 'Track your net worth and adjust your savings goals from anywhere with the [[BRAND_NAME]] app. Set a target, switch on automatic round-ups, and watch your progress build without lifting a finger. You will get real-time security alerts on every transaction, and you can pause or change your plan whenever you like.',
    featureColumnTextColor: '#FFFFFF', featureSectionColor: '#03A05B',
    bodyParagraph: 'As a valued [[BRAND_NAME]] customer, you know how important it is to keep your personal finances organized and secure. But what if you could put your wealth-building entirely on autopilot?\n\nWe’re excited to introduce the Smart Wealth add-on, designed specifically to integrate flawlessly with your existing [[BRAND_NAME]] checking and savings accounts.',
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
        { sender: 'bot', text: 'Hi there! Great question! Every time you make a purchase with your [[BRAND_NAME]] debit card, we round up to the nearest dollar and automatically transfer the difference to your Smart Wealth savings account.' }
    ]
};

// Per-industry content starter packs. Picking an industry fills the content
// fields deterministically; ✨Generate can then refine via Einstein.
const INDUSTRY_PACKS = {
    'Travel & Hospitality': {
        subjectLine: 'Your next getaway, already planned',
        headline: 'Where to next?',
        subHeadline: 'Member fares and perks picked for you',
        bodyParagraph: 'Hi [[CUSTOMER_FIRST_NAME]],\n\nYou travel enough to deserve the easy button. [[BRAND_NAME]] just unlocked member-only fares and stays tailored to where you love to go.\n\nBook in a tap, change plans without the stress, and earn rewards on every trip.',
        featureColumn1: 'Unlock member-only fares and bundled stays for the destinations you love, refreshed daily and reserved just for [[BRAND_NAME]] members. We watch prices across airlines and hotels so you do not have to, and flag the best windows to book. The more you travel, the more you save.',
        featureColumn2: 'Plans change, and that is fine — enjoy free changes on most bookings and 24/7 trip support from anywhere in the world. One itinerary keeps your flights, hotels, and cars together, and a concierge is always a reply away. Travel with the confidence that someone has your back.',
        bullet1: 'Price-drop alerts on the routes you watch.',
        bullet2: 'Earn and redeem points on flights, hotels, and cars.',
        bullet3: 'One itinerary for the whole trip.',
        ctaButtonText: 'Plan my trip',
        replyPromptHeadline: 'Questions about your trip?',
        replyPromptBody: 'Reply to this email and [[BRAND_NAME]]\'s travel concierge AI will help with dates, destinations, and perks.',
        messages: [
            { sender: 'user', text: 'Can I use my points toward a beach trip over a long weekend?' },
            { sender: 'bot', text: 'Absolutely — your points cover round-trip airfare plus two nights at several beach destinations. Want me to hold a Fri–Sun itinerary with free changes?' }
        ]
    },
    'Financial Services': {
        subjectLine: 'A smarter way to save is here',
        headline: 'Unlock Smart Wealth Building',
        subHeadline: 'Automatic round-ups that grow your savings',
        bodyParagraph: 'Hi [[CUSTOMER_FIRST_NAME]],\n\nYour everyday spending can quietly build your savings. Turn on round-ups and watch it add up — automatically.',
        featureColumn1: 'Every purchase rounds up to the nearest dollar and the spare change moves straight into savings — automatically, in the background. There is nothing new to download and nothing to remember. It is the easiest way to build a cushion without changing how you spend.',
        featureColumn2: 'Set a goal, track your progress, and adjust anytime from your phone with bank-level security on every session. Get a heads-up before big purchases and a clear view of projected growth. Your money works harder while you stay fully in control.',
        bullet1: 'Seamless: round-ups and deposits sync instantly.',
        bullet2: 'Mobile goal tracking with bank-level security.',
        bullet3: 'Real-time insights before you spend.',
        ctaButtonText: 'See how it works',
        replyPromptHeadline: 'Have questions? Just hit reply!',
        replyPromptBody: 'Reply directly to this email and our AI specialist will answer instantly.',
        messages: [
            { sender: 'user', text: 'How do the round-ups work with my existing accounts?' },
            { sender: 'bot', text: 'Every debit-card purchase rounds up to the nearest dollar and the difference moves to your savings — automatically, no extra apps.' }
        ]
    },
    'Retail & Consumer Goods': {
        subjectLine: 'Your cart misses you — here is 15% off',
        headline: 'Still thinking it over?',
        subHeadline: 'Complete your order and save today',
        bodyParagraph: 'Hi [[CUSTOMER_FIRST_NAME]],\n\nThe items you loved are still waiting. Here is a little something to help you decide.',
        featureColumn1: 'Enjoy free shipping on orders over $50 and members-only early access to new drops before they sell out. Your cart and favorites follow you across every device, so you can pick up right where you left off. Checkout is one tap once your details are saved.',
        featureColumn2: 'Changed your mind? Easy 30-day returns, no questions asked, with a prepaid label in a click. Earn points on every purchase and redeem them for whatever you want next. Plus a price-match guarantee, so you never second-guess a buy.',
        bullet1: 'Members-only early access to new drops.',
        bullet2: 'Points on every purchase.',
        bullet3: 'Price-match guarantee.',
        ctaButtonText: 'Complete my order',
        replyPromptHeadline: 'Need help choosing?',
        replyPromptBody: 'Reply to this email and our shopping assistant will help you pick the right size and style.',
        messages: [
            { sender: 'user', text: 'Do you have this in a medium, and when would it arrive?' },
            { sender: 'bot', text: 'Yes! Medium is in stock and ships free — it would arrive in 2-3 business days with the offer applied at checkout.' }
        ]
    },
    'Consumer Business Services': {
        subjectLine: 'Your getaway is calling',
        headline: 'Escape awaits, [[CUSTOMER_FIRST_NAME]]',
        subHeadline: 'Exclusive member rates on your next stay',
        bodyParagraph: 'Hi [[CUSTOMER_FIRST_NAME]],\n\nYou have been working hard. Treat yourself to a getaway with rates reserved just for members.',
        featureColumn1: 'Enjoy up to 25% off member-only room rates at properties picked for how you like to travel. Earn and redeem points on every stay, and get complimentary upgrades whenever a room opens up. The longer you are a member, the better it gets.',
        featureColumn2: 'Book with total flexibility — free cancellation and easy changes if plans shift. Members get late checkout, priority support, and little perks on arrival. Tell us what you need and our concierge handles the rest.',
        bullet1: 'Earn and redeem points on every stay.',
        bullet2: 'Complimentary room upgrades when available.',
        bullet3: 'Late checkout for members.',
        ctaButtonText: 'Plan my trip',
        replyPromptHeadline: 'Questions about your trip?',
        replyPromptBody: 'Reply to this email and our concierge AI will help you plan dates, rooms, and extras.',
        messages: [
            { sender: 'user', text: 'Can I use my points toward a beachfront room for a long weekend?' },
            { sender: 'bot', text: 'Absolutely — your points cover two nights in a beachfront room, and I can hold Friday-Sunday with free cancellation. Want me to reserve it?' }
        ]
    }
};

// `channels` (optional) restricts a section to specific channels; sections with
// no `channels` key show for every channel. The Email Template section is
// email-only; messaging channels (SMS/WhatsApp/RCS) drop it and keep the rest.
// Marketing-first starter thread for messaging channels (SMS/WhatsApp/RCS):
// the brand's outreach shows first, then the recipient replies, then the agent
// answers — reading like the email's 2-way reply. Brand token re-renders live.
const MESSAGING_SEED_MESSAGES = [
    { sender: 'bot', text: 'Hi [[CUSTOMER_FIRST_NAME]], it’s [[BRAND_NAME]]. Your round-ups just added $50 to savings this month 🎉 Want to put it on autopilot?', imageUrl: '' },
    { sender: 'user', text: 'Oh nice! How does that work exactly?', imageUrl: '' },
    { sender: 'bot', text: 'Every card purchase rounds up to the next dollar and the change moves straight to savings — automatically. Reply BOOST and I’ll double it.', imageUrl: '' }
];

const SECTIONS = [
    { key: 'branding', label: 'Branding', icon: 'utility:brush' },
    { key: 'customer', label: 'Customer Profile', icon: 'utility:user' },
    // On messaging channels the agent identity merges into the Messages
    // section, so the standalone AI Agent tab is email-only.
    { key: 'agent', label: 'AI Agent', icon: 'utility:einstein', channels: ['Email'] },
    { key: 'template', label: 'Email Template', icon: 'utility:email', channels: ['Email'] },
    { key: 'convo', label: 'Messages', icon: 'utility:chat' }
];

// Per-channel chrome: toolbar icon + the "2-Way <x>" label used in the header
// subtitle and the preview pane.
const CHANNEL_META = {
    Email: { icon: 'utility:email', label: 'Email' },
    SMS: { icon: 'utility:sms', label: 'SMS' },
    WhatsApp: { icon: 'utility:chat', label: 'WhatsApp' },
    RCS: { icon: 'utility:comments', label: 'RCS' }
};

export default class DemoStoryStudio extends LightningElement {
    @api recordId;
    @track config = { ...DEFAULTS };
    @track activeSection = 'branding';
    @track previewVersion = 1;
    @track brandKits = [];
    @track showBrandPicker = false;
    @track brandSearch = '';
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

    get selectedKit() {
        const k = (this.brandKits || []).find((x) => x.value === this.config.brandKitId);
        if (!k) return null;
        return { label: k.label, logo: k.logo, hasLogo: !!k.logo,
            swatch: 'background:' + (k.gradient || k.primary || '#0A1F44') + ';' };
    }
    get filteredBrandTiles() {
        const q = (this.brandSearch || '').toLowerCase();
        const tiles = this.brandKitTiles;
        return q ? tiles.filter((t) => (t.label || '').toLowerCase().includes(q)) : tiles;
    }
    get brandChangeLabel() { return this.selectedKit ? 'Change brand' : 'Choose a brand kit'; }
    toggleBrandPicker() { this.showBrandPicker = !this.showBrandPicker; }
    handleBrandSearch(e) { this.brandSearch = e.target.value; }

    async handlePickKit(e) {
        await this.applyKitById(e.currentTarget.dataset.kitid);
        this.showBrandPicker = false;
        this.brandSearch = '';
    }
    async applyKitById(kitId) {
        if (!kitId) return;
        try {
            const k = await getBrandKit({ kitId });
            const primary = k.Primary_Color__c || this.config.primaryColor;
            const accent = k.Accent_Color__c || primary;
            const domain = k.Name ? (k.Name.toLowerCase().replace(/[^a-z0-9]/g, '') + '.com') : this.config.brandDomain;
            this._commit({
                brandKitId: kitId, brandName: k.Name || this.config.brandName, brandDomain: domain,
                primaryColor: primary, ctaButtonColor: primary, logoBgColor: primary,
                featureSectionColor: accent,
                logoUrl: k.Logo_URL__c || this.config.logoUrl,
                marketingAvatarUrl: k.Secondary_Logo_URL__c || k.Logo_URL__c || this.config.marketingAvatarUrl
            });
        } catch (err) {
            this.toast('Brand Kit', (err && err.body && err.body.message) || err.message, 'error');
        }
    }

    @track personaSearch = '';
    get filteredPersonaOptions() {
        const q = (this.personaSearch || '').toLowerCase();
        const all = this.personaOptions || [];
        return q ? all.filter((o) => (o.label || '').toLowerCase().includes(q)) : all;
    }
    handlePersonaSearch(e) { this.personaSearch = e.target.value; }

    // Persona inheritance — fills the customer identity from a Demo Persona.
    handlePersona(e) {
        const personaId = e.detail.value;
        if (!personaId) { this._commit({ personaId: '' }); return; }
        this.applyPersonaById(personaId);
    }
    async applyPersonaById(personaId) {
        if (!personaId) return;
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
        const ind = getFieldValue(data, INDUSTRY_FIELD);
        const channel = getFieldValue(data, CHANNEL_FIELD) || 'Email';
        if (raw) {
            try { this.config = { ...DEFAULTS, ...JSON.parse(raw) }; } catch (e) {}
        } else if (ind && INDUSTRY_PACKS[ind]) {
            // Fresh record: seed the copy from the record's industry pack.
            this.config = { ...this.config, ...INDUSTRY_PACKS[ind] };
        }
        // The record's Channel drives which sections + template render. Keep the
        // config's channel in sync so the VF preview picks the right template.
        if (this.config.channel !== channel) { this.config = { ...this.config, channel }; }
        // Fresh messaging record: seed the marketing-first 2-way thread (the
        // industry packs' threads are email-oriented / recipient-first).
        if (!raw && channel !== 'Email') {
            this.config = { ...this.config, messages: MESSAGING_SEED_MESSAGES.map((m) => ({ ...m })) };
        }
        // If the active section isn't valid for this channel (e.g. Email Template
        // on an SMS record), fall back to the first valid section.
        if (!this.visibleSections.some((s) => s.key === this.activeSection)) {
            this.activeSection = this.visibleSections[0].key;
        }
        if (ind) { this.genIndustry = ind; this._recordIndustry = ind; } // default the AI modal's Industry
        // Default the brand from the Brand Kit chosen at record creation.
        const kitId = getFieldValue(data, BRAND_KIT);
        if (kitId && !this.config.brandKitId) { this.applyKitById(kitId); }
        const pId = getFieldValue(data, PERSONA_FIELD);
        if (pId && !this.config.personaId) { this.applyPersonaById(pId); }
        this.previewVersion++;
    }

    // ---- channel ----
    get channel() { return this.config.channel || 'Email'; }
    get isEmail() { return this.channel === 'Email'; }
    get isSms() { return this.channel === 'SMS'; }
    get isWhatsapp() { return this.channel === 'WhatsApp'; }
    get isRcs() { return this.channel === 'RCS'; }
    // Messaging channels share the Branding/Agent/Messages layout + theme control.
    get isMessaging() { return this.isSms || this.isWhatsapp || this.isRcs; }
    get channelMeta() { return CHANNEL_META[this.channel] || CHANNEL_META.Email; }
    get channelLabel() { return this.channelMeta.label; }
    get channelIcon() { return this.channelMeta.icon; }
    get previewLabel() { return 'Live Preview · 2-Way ' + this.channelLabel; }
    get themeOptions() {
        return [{ label: 'Light', value: 'light' }, { label: 'Dark', value: 'dark' }];
    }

    // ---- sections / nav
    get visibleSections() {
        return SECTIONS.filter((s) => !s.channels || s.channels.includes(this.channel));
    }
    get tabs() {
        return this.visibleSections.map((s) => ({ ...s,
            className: 'studio-tab' + (s.key === this.activeSection ? ' studio-tab--active' : '') }));
    }
    get isBranding() { return this.activeSection === 'branding'; }
    get isTemplate() { return this.activeSection === 'template'; }
    get isCustomer() { return this.activeSection === 'customer'; }
    get isAgent() { return this.activeSection === 'agent'; }
    get isConvo() { return this.activeSection === 'convo'; }
    get subtitle() { return (this.config.brandName || 'New') + ' · 2-Way ' + this.channelLabel; }
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
    // For lightning-combobox (and other components firing detail.value), e.g. theme.
    handleDetailField(e) {
        this._commit({ [e.currentTarget.dataset.field]: e.detail.value });
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
        this._commit({ messages: [...prev, { sender: nextSender, text: '', imageUrl: '' }] });
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
            imageUrl: m.imageUrl || '',
            rowLabel: 'Message ' + (i + 1)
        }));
    }
    // Attach/replace an image on a message (same library picker as the hero).
    handleMsgImage(e) {
        const i = parseInt(e.currentTarget.dataset.i, 10);
        const msgs = this.config.messages.map((m, idx) => idx === i ? { ...m, imageUrl: e.detail.url } : m);
        this._commit({ messages: msgs });
    }

    // ---- preview = Visualforce page loaded by relative URL (LWS-legal), debounced autosave
    scheduleAutosave() {
        if (this._timer) clearTimeout(this._timer);
        this._timer = setTimeout(() => { this.doSave(); }, 450);
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
    // Reload the preview iframe so the 2-way simulation restarts from the top.
    handleResetPreview() { this.previewVersion++; }

    // ---- draggable divider between editor and preview ----
    @track editorWidth = 440;
    get splitStyle() { return 'grid-template-columns: 200px ' + this.editorWidth + 'px 8px 1fr;'; }
    // Re-theme the Story Studio chrome to the selected brand (like Persona Studio).
    get frameStyle() {
        const p = this.config.primaryColor || '#0A1F44';
        const a = this.config.featureSectionColor || this.config.ctaButtonColor || '#1C3B7B';
        return '--demo-bg-gradient: linear-gradient(135deg, ' + p + ' 0%, ' + a + ' 100%);';
    }
    _startX = 0;
    _startW = 440;
    _onMove = (e) => {
        const w = this._startW + (e.clientX - this._startX);
        this.editorWidth = Math.max(300, Math.min(900, w));
    };
    _onUp = () => {
        window.removeEventListener('mousemove', this._onMove);
        window.removeEventListener('mouseup', this._onUp);
    };
    startResize(e) {
        this._startX = e.clientX;
        this._startW = this.editorWidth;
        window.addEventListener('mousemove', this._onMove);
        window.addEventListener('mouseup', this._onUp);
        e.preventDefault();
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

    // ---- AI Generate (industry pack + Einstein) ----
    @track showGenerate = false;
    @track genIndustry = 'Financial Services';
    @track genContext = '';
    @track genAngle = '';
    generating = false;

    get angleOptions() {
        return ['Win-back', 'Cross-sell', 'Onboarding', 'Retention', 'Promotion', 'Re-engagement', 'Nurture', 'Upsell']
            .map((a) => ({ label: a, value: a }));
    }

    get industryOptions() {
        return [
            'Financial Services', 'Health & Life Sciences', 'Retail & Consumer Goods',
            'Manufacturing', 'Communications, Media & Technology', 'Public Sector',
            'Consumer Business Services', 'Travel & Hospitality', 'Energy & Utilities'
        ].map((i) => ({ label: i, value: i }));
    }
    handleGenerate() {
        if (this._recordIndustry) this.genIndustry = this._recordIndustry;
        this.showGenerate = true;
    }
    closeGenerate() { this.showGenerate = false; }
    handleGenContext(e) { this.genContext = e.target.value; }
    handleGenAngle(e) { this.genAngle = e.detail.value; }

    // Picking an industry fills the deterministic starter pack immediately.
    handleGenIndustry(e) {
        this.genIndustry = e.detail.value;
        const pack = INDUSTRY_PACKS[this.genIndustry];
        if (pack) this._commit({ ...pack });
    }

    async runGenerate() {
        this.generating = true;
        try {
            const raw = await generateEmail({ industry: this.genIndustry, brand: this.config.brandName, context: this.genContext, angle: this.genAngle });
            this.applyGenJson(JSON.parse(raw));
            this.showGenerate = false;
            this.toast('Generated', 'AI drafted your email + conversation. Edit anything.', 'success');
        } catch (err) {
            this.toast('Generate failed', (err && err.body && err.body.message) || err.message || 'Could not parse AI output', 'error');
        } finally {
            this.generating = false;
        }
    }

    // Merge an AI JSON payload (from Einstein or pasted-back) into the config.
    applyGenJson(gen) {
        const patch = {};
        ['subjectLine', 'headline', 'subHeadline', 'bodyParagraph', 'featureColumn1', 'featureColumn2',
         'bullet1', 'bullet2', 'bullet3', 'ctaButtonText', 'replyPromptHeadline', 'replyPromptBody']
            .forEach((k) => { if (gen[k]) patch[k] = gen[k]; });
        if (Array.isArray(gen.messages) && gen.messages.length) {
            patch.messages = gen.messages.filter((m) => m && m.text)
                .map((m) => ({ sender: m.sender === 'bot' ? 'bot' : 'user', text: m.text }));
        }
        this._commit(patch);
    }

    // ---- "How to prepare this" — a prompt that helps the SE WRITE the context ----
    // (returns plain text to paste into the Campaign context box; no JSON ever).
    @track showCopyPrompt = false;
    toggleCopyPrompt() { this.showCopyPrompt = !this.showCopyPrompt; }

    get copyablePrompt() {
        const brand = this.config.brandName || 'the customer';
        const sub = this.config.customerName || 'the primary contact';
        const ind = this.genIndustry;
        return [
            'Review everything you have on ' + brand + ' — all my meeting notes, call transcripts, and discovery for '
            + 'this account — and research ' + brand + ' on the web if you can (recent news, priorities, products, pains).',
            'Based on what we have ACTUALLY discussed with them so far, propose a marketing email campaign for ' + brand
            + ' (' + ind + ') that the stakeholders I have been meeting with would resonate with — tied to their real '
            + 'priorities from our conversations, not a generic pitch. The email should invite a 2-way interaction '
            + '(the recipient can reply and an AI agent answers follow-up questions).',
            'Write it as a single "campaign context" paragraph I can paste into a demo tool: the offer, the recipient ('
            + sub + '), the angle, and why it lands given our calls. Under ~180 words, one paragraph, no bullets, no '
            + 'preamble — just the paragraph.'
        ].join('\n\n');
    }

    handleCopyPrompt() {
        const text = this.copyablePrompt;
        if (navigator.clipboard && navigator.clipboard.writeText) {
            navigator.clipboard.writeText(text).then(
                () => this.toast('Copied', 'Paste it into your AI, then paste the paragraph it returns into Campaign context.', 'success'),
                () => this.toast('Copy failed', 'Select the text and copy manually.', 'warning'));
        } else {
            this.toast('Copy', 'Select the prompt text and copy manually.', 'info');
        }
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
