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
import generateSms from '@salesforce/apex/DemoStoryGenerator.generateSms';
import generateRcs from '@salesforce/apex/DemoStoryGenerator.generateRcs';

const FIELDS = [CFG, BRAND_KIT, PERSONA_FIELD, INDUSTRY_FIELD, CHANNEL_FIELD];

// Default email config (Cumulus-flavored) — overlaid by the saved Config_JSON__c.
// Mirrors the Experience Generator email config for parity.
const DEFAULTS = {
    // Channel + messaging-channel appearance (shared by SMS/WhatsApp/RCS)
    channel: 'Email',
    theme: 'light',
    device: 'android',
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
// Marketing-first starter threads for messaging channels (SMS/WhatsApp/RCS),
// one per Salesforce industry: the brand's outreach shows first, then the
// recipient replies, then the agent answers — reading like the email's 2-way
// reply. Brand/first-name tokens re-render live.
const bot = (text) => ({ sender: 'bot', text, imageUrl: '' });
const usr = (text) => ({ sender: 'user', text, imageUrl: '' });
const MESSAGING_PACKS = {
    'Financial Services': [
        bot('Hi [[CUSTOMER_FIRST_NAME]], it’s [[BRAND_NAME]]. Your round-ups just added $50 to savings this month 🎉 Want to put it on autopilot?'),
        usr('Oh nice! How does that work exactly?'),
        bot('Every card purchase rounds up to the next dollar and the change moves straight to savings — automatically. Reply BOOST and I’ll double it — or I can connect you with your relationship manager to set a savings goal.')
    ],
    'Health & Life Sciences': [
        bot('Hi [[CUSTOMER_FIRST_NAME]], it’s [[BRAND_NAME]]. Your annual wellness visit is due and members get a $0 copay this month 🩺 Want the next opening?'),
        usr('Sure — what times are open this week?'),
        bot('I’ve got Wed 9:40am or Thu 2:15pm with Dr. Patel. Reply with one and I’ll lock it in and text a reminder — or I can have a care coordinator call you.')
    ],
    'Retail & Consumer Goods': [
        bot('[[CUSTOMER_FIRST_NAME]], the jacket in your cart is almost gone — here’s 15% off to finish checkout today 🛍️'),
        usr('Do you have it in a medium?'),
        bot('Yes! Medium’s in stock and ships free. Reply BUY and I’ll apply the 15% and send tracking — or I can loop in a shopping specialist.')
    ],
    'Manufacturing': [
        bot('Hi [[CUSTOMER_FIRST_NAME]], [[BRAND_NAME]] here. Your pump’s maintenance window opens next week — reserve a tech slot to avoid downtime?'),
        usr('What does the service include?'),
        bot('Full inspection, seal + filter replacement, and a 12-month performance warranty. Reply BOOK and I’ll schedule on-site Tue or Thu — or I can connect you with your account manager.')
    ],
    'Communications, Media & Technology': [
        bot('[[CUSTOMER_FIRST_NAME]], you’re eligible to upgrade to [[BRAND_NAME]] Gigabit — same bill, 3x faster 📶 Want it?'),
        usr('Will I need a new router?'),
        bot('Nope — your current router works, or grab our Wi-Fi 7 unit free for 12 months. Reply YES and I’ll ship a self-install kit — or a specialist can finish the setup with you.')
    ],
    'Public Sector': [
        bot('Hi [[CUSTOMER_FIRST_NAME]], this is [[BRAND_NAME]]. Your permit renewal is due in 10 days — renew by text in about 2 minutes?'),
        usr('What do I need to renew?'),
        bot('Just your permit ID and a card on file. Reply RENEW and I’ll walk you through it — or I can connect you with a representative.')
    ],
    'Consumer Business Services': [
        bot('[[CUSTOMER_FIRST_NAME]], [[BRAND_NAME]] members get 25% off your next stay this month 🏨 Want me to find dates?'),
        usr('Can I use points toward a beach weekend?'),
        bot('Absolutely — your points cover 2 nights beachfront. Reply HOLD and I’ll lock Fri–Sun with free cancellation — or I can hand you to a concierge to finalize.')
    ],
    'Travel & Hospitality': [
        bot('Where to next, [[CUSTOMER_FIRST_NAME]]? [[BRAND_NAME]] just unlocked member fares to your favorite spots ✈️'),
        usr('Any deals for a long weekend somewhere warm?'),
        bot('Yes — round-trip plus 2 nights starts at $420 to three beach cities, with free changes. Reply GO and I’ll hold it — or I can connect you with a travel concierge to finalize.')
    ],
    'Energy & Utilities': [
        bot('Hi [[CUSTOMER_FIRST_NAME]], [[BRAND_NAME]] here. Shift usage off-peak and you could cut about 15% off your bill ⚡ Want the free plan?'),
        usr('How does the off-peak plan work?'),
        bot('Power’s cheaper nights and weekends; we auto-nudge big appliances to those windows. Reply START and I’ll enroll you — or I can connect you with a representative.')
    ]
};
// Fallback thread when the record's industry has no pack.
const MESSAGING_SEED_MESSAGES = MESSAGING_PACKS['Financial Services'];
function messagingSeedFor(industry) {
    const pack = MESSAGING_PACKS[industry] || MESSAGING_SEED_MESSAGES;
    return pack.map((m) => ({ ...m }));
}

// RCS seed — showcases the channel's signature pieces: quick-reply chips on
// the opening message and a rich card as the agent's answer, ending on an
// agent escalation. Returns fresh (deep) objects each call.
// Exact Experience-Generator default RCS thread (getDefaultRcsMessages),
// brand/first-name tokenized so it re-brands. Default media points at the live
// EG asset host; the SE can swap it. "Download the App" is a quickReply with a
// rich-card response → plays the next card (positional pairing).
const RCS_ASSET_HOST = 'https://whispering-coast-03303-5bb1f6fb1c95.herokuapp.com';
// Per-industry copy for the RCS seed. Structure (card → chips → paired card →
// recipient Q → brand reply) stays constant; copy verticalizes. Financial
// Services is the base; others override.
const RCS_VERTICALS = {
    'Health & Life Sciences': {
        t1: 'Your care plan is ready, [[CUSTOMER_FIRST_NAME]]', d1: 'Appointments, reminders, and results — all in one place with [[BRAND_NAME]].', cta1: 'View my care plan',
        chipA: 'See benefits', chipRich: 'Get the app', chipDial: 'Call the nurse line',
        t3: 'Care in your pocket', d3: 'Message your care team, refill prescriptions, and join video visits from the [[BRAND_NAME]] app.', cta3: 'Download the app',
        q: 'Can I message my doctor through the app?', a: 'Let me connect you with a care coordinator who can set that up for you.'
    },
    'Retail & Consumer Goods': {
        t1: 'Your cart misses you, [[CUSTOMER_FIRST_NAME]]', d1: 'The items you loved are still here — plus a members-only offer from [[BRAND_NAME]].', cta1: 'Complete my order',
        chipA: 'See the offer', chipRich: 'Get the app', chipDial: 'Call support',
        t3: 'Shop faster in the app', d3: 'Save your cart, track orders, and get early access to drops with the [[BRAND_NAME]] app.', cta3: 'Download the app',
        q: 'Do you have this in a medium?', a: 'Let me get a shopping specialist to confirm stock and help you check out.'
    },
    'Manufacturing': {
        t1: 'Your service window is open, [[CUSTOMER_FIRST_NAME]]', d1: 'Schedule preventive maintenance and avoid downtime with [[BRAND_NAME]].', cta1: 'Book service',
        chipA: 'See coverage', chipRich: 'Get the app', chipDial: 'Call your rep',
        t3: 'Manage equipment on the go', d3: 'Track service history, parts, and warranties from the [[BRAND_NAME]] app.', cta3: 'Download the app',
        q: 'What does the service plan cover?', a: 'Let me connect you with your account manager to walk through the plan.'
    },
    'Communications, Media & Technology': {
        t1: 'Your upgrade is ready, [[CUSTOMER_FIRST_NAME]]', d1: 'Faster speeds, same bill — [[BRAND_NAME]] has an upgrade waiting for you.', cta1: 'See my upgrade',
        chipA: 'See plans', chipRich: 'Get the app', chipDial: 'Call us',
        t3: 'Manage your plan in the app', d3: 'Check data, pay bills, and get support from the [[BRAND_NAME]] app.', cta3: 'Download the app',
        q: 'Will I need a new router?', a: 'Let me get a specialist to confirm what you need and finish the setup.'
    },
    'Public Sector': {
        t1: 'Action needed, [[CUSTOMER_FIRST_NAME]]', d1: 'Your renewal is due soon — handle it by text with [[BRAND_NAME]].', cta1: 'Start renewal',
        chipA: 'See requirements', chipRich: 'Get the app', chipDial: 'Call a caseworker',
        t3: 'Services in the app', d3: 'Submit forms, track status, and get reminders from the [[BRAND_NAME]] app.', cta3: 'Download the app',
        q: 'What documents do I need?', a: 'Let me connect you with a representative who can walk you through it.'
    },
    'Consumer Business Services': {
        t1: 'Your getaway is calling, [[CUSTOMER_FIRST_NAME]]', d1: 'Member rates on your next stay, reserved by [[BRAND_NAME]].', cta1: 'See member rates',
        chipA: 'See offers', chipRich: 'Get the app', chipDial: 'Call concierge',
        t3: 'Travel with the app', d3: 'Book stays, manage trips, and unlock perks from the [[BRAND_NAME]] app.', cta3: 'Download the app',
        q: 'Can I use points toward a beach weekend?', a: 'Let me get a concierge to hold the dates and finalize with you.'
    },
    'Travel & Hospitality': {
        t1: 'Where to next, [[CUSTOMER_FIRST_NAME]]?', d1: 'Member fares to your favorite spots just unlocked with [[BRAND_NAME]].', cta1: 'See member fares',
        chipA: 'See deals', chipRich: 'Get the app', chipDial: 'Call travel desk',
        t3: 'Your trips, in the app', d3: 'Book flights and stays, get gate alerts, and manage trips with the [[BRAND_NAME]] app.', cta3: 'Download the app',
        q: 'Any deals for a long weekend somewhere warm?', a: 'Let me get a travel concierge to hold an itinerary and finalize with you.'
    },
    'Energy & Utilities': {
        t1: 'Lower your bill, [[CUSTOMER_FIRST_NAME]]', d1: 'Shift usage off-peak and save — [[BRAND_NAME]] made you a free plan.', cta1: 'See my plan',
        chipA: 'See the plan', chipRich: 'Get the app', chipDial: 'Call us',
        t3: 'Manage energy in the app', d3: 'Track usage, pay bills, and get outage alerts from the [[BRAND_NAME]] app.', cta3: 'Download the app',
        q: 'How does the off-peak plan work?', a: 'Let me connect you with a representative to enroll you — no equipment needed.'
    }
};
// Financial Services base copy (the EG default); verticals override it.
const RCS_FINANCE = {
    t1: 'Smart Wealth is ready for you, [[CUSTOMER_FIRST_NAME]]',
    d1: 'Round-ups, auto-savings, and personalized offers — all synced to your [[BRAND_NAME]] checking account.',
    cta1: 'Open my dashboard',
    chipA: 'Go Paperless', chipRich: 'Download the App', chipDial: 'Call my Banker',
    t3: 'Let’s make it official',
    d3: 'Did you know you can have [[BRAND_NAME]] with you on the go whenever you need us? Download on your app store today!',
    cta3: 'Take me to the App Store',
    q: 'Am I eligible for a refi on my mortgage with [[BRAND_NAME]]?',
    a: 'Let me get someone who can help! Your banker will get in touch with you shortly.'
};
function rcsSeedFor(industry) {
    const v = { ...RCS_FINANCE, ...(RCS_VERTICALS[industry] || {}) };
    const seed = [
        { sender: 'bot', type: 'richCardVertical', typingDuration: 'off',
          // Initial card media = brand primary logo (blank -> logo-on-gradient placeholder).
          card: { mediaType: 'image', mediaUrl: '', mediaSize: 'medium',
            title: v.t1, description: v.d1,
            buttons: [{ label: v.cta1, action: 'openUrl', target: '' }] } },
        { sender: 'bot', type: 'suggestedActions', typingDuration: 'off',
          chips: [
            { label: v.chipA, action: 'openUrl', target: 'https://' },
            { label: v.chipRich, action: 'quickReply', responseType: 'richCard' },
            { label: v.chipDial, action: 'dial', target: '+15551234567' }
          ] },
        { sender: 'bot', type: 'richCardVertical', typingDuration: 'medium', triggeredBy: v.chipRich,
          // Generic (unbranded) "on the go" lifestyle photo.
          card: { mediaType: 'image', mediaUrl: 'https://res.cloudinary.com/dfx98jgdc/image/upload/v1788281554/experience-generator/bbnai2sruqpxwkiud3xb.png', mediaSize: 'medium',
            title: v.t3, description: v.d3,
            buttons: [{ label: v.cta3, action: 'openUrl', target: 'https://apps.apple.com/' }] } },
        { sender: 'user', type: 'text', text: v.q },
        { sender: 'bot', type: 'text', typingDuration: 'long', text: v.a }
    ];
    return JSON.parse(JSON.stringify(seed)); // deep clone
}
// Seed the right thread for a messaging channel.
function seedFor(channel, industry) {
    return channel === 'RCS' ? rcsSeedFor(industry) : messagingSeedFor(industry);
}

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

// RCS message types + per-type tone (color separation) + help text — ported
// from the Experience Generator's RCS message builder (RCS_STEP_TONES).
const RCS_TYPES = [
    { value: 'text', label: 'Text' },
    { value: 'quickReplies', label: 'Text + quick replies' },
    { value: 'richCardVertical', label: 'Rich card — vertical' },
    { value: 'richCardHorizontal', label: 'Rich card — horizontal' },
    { value: 'cardCarousel', label: 'Card carousel' },
    { value: 'suggestedActions', label: 'Suggested actions (chips only)' }
];
const RCS_TONES = {
    text: { accent: '#2a94d6', bg: '#f3f9fd', label: '#1c6fa6' },
    quickReplies: { accent: '#7a5af0', bg: '#f7f5ff', label: '#5a3fd0' },
    richCardVertical: { accent: '#e0892a', bg: '#fdf7ee', label: '#b56a12' },
    richCardHorizontal: { accent: '#e0892a', bg: '#fdf7ee', label: '#b56a12' },
    cardCarousel: { accent: '#1f9d6b', bg: '#f1faf5', label: '#147a51' },
    suggestedActions: { accent: '#c15b90', bg: '#fdf4f9', label: '#8a3a67' }
};
const RCS_HELP = {
    text: 'A plain message bubble.',
    quickReplies: 'A message with tappable quick-reply chips (up to 11) beneath it.',
    richCardVertical: 'Rich card with media on top, then title, description, and buttons.',
    richCardHorizontal: 'Rich card with media beside the title, description, and buttons.',
    cardCarousel: 'Horizontally scrolling set of cards (2–10). Vertical layout per card.',
    suggestedActions: 'Standalone chip row — no anchor message. Great for follow-up options ("Continue", "Learn more") after a card.'
};
const RCS_TYPING = [
    { value: 'off', label: 'No typing indicator' },
    { value: 'short', label: 'Typing… short' },
    { value: 'medium', label: 'Typing… medium' },
    { value: 'long', label: 'Typing… long' }
];

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
            // Personas may populate only the Name field (not First/Last) — fall
            // back to Name so the thread's first-name token still resolves.
            const full = ((p.First_Name__c || '') + ' ' + (p.Last_Name__c || '')).trim() || (p.Name || '');
            const newFirst = p.First_Name__c || (p.Name ? p.Name.trim().split(' ')[0] : this.config.customerFirstName);
            this._commit({
                personaId: personaId,
                customerName: full || this.config.customerName,
                customerFirstName: newFirst,
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
        // Fresh messaging record: seed the marketing-first 2-way thread for the
        // record's industry (the email industry packs are recipient-first).
        const prevInd = this._recordIndustry;
        if (!raw && channel !== 'Email') {
            this.config = { ...this.config, messages: seedFor(channel, ind) };
        } else if (raw && channel !== 'Email' && channel !== 'RCS' && ind && prevInd && ind !== prevInd && this.isPristineThread()) {
            // Existing messaging record whose Industry changed and whose thread
            // is still an unedited seed — swap in the new industry's thread and
            // persist it. (Hand-edited threads are left untouched. RCS uses one
            // showcase thread, so it isn't industry-swapped here.)
            this.config = { ...this.config, messages: seedFor(channel, ind) };
            this.saved = false;
            this.scheduleAutosave();
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

    // Current recipient first name (from persona / customer profile) used to
    // bake [[CUSTOMER_FIRST_NAME]] into messaging threads so the editor reads
    // naturally instead of showing a raw token.
    get firstName() {
        return this.config.customerFirstName || (this.config.customerName || '').split(' ')[0] || 'there';
    }
    // Bake live tokens into messaging thread text so the editor shows real
    // values (persona first name + brand) instead of [[TOKENS]]. Re-baked when
    // the persona or brand kit changes (see applyPersonaById / applyKitById).
    // Resolve the live tokens in a single message's text for EDITOR DISPLAY.
    // Storage keeps the tokens, so persona/brand swaps reflect automatically and
    // the server render resolves them for the preview. (Edited text stores as-is.)
    resolveTokens(text) {
        const fn = this.firstName;
        const br = this.config.brandName || 'the brand';
        return (text || '').replace(/\[\[CUSTOMER_FIRST_NAME\]\]/g, fn).replace(/\[\[BRAND_NAME\]\]/g, br);
    }

    // True when the current thread still equals one of the industry seed packs
    // (i.e. the SE hasn't hand-edited it), so it's safe to re-seed on an
    // Industry change. Compared on sender+text only.
    isPristineThread() {
        const norm = (arr) => JSON.stringify((arr || []).map((m) => ({ sender: m.sender, text: m.text })));
        const cur = norm(this.config.messages);
        return Object.keys(MESSAGING_PACKS).some((k) => norm(MESSAGING_PACKS[k]) === cur);
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
    get deviceOptions() {
        return [{ label: 'Android', value: 'android' }, { label: 'iPhone', value: 'ios' }];
    }
    get rcsTypeOptions() { return RCS_TYPES; }
    get rcsTypingOptions() { return RCS_TYPING; }
    get rcsActionOptions() {
        return [
            { label: 'Quick reply', value: 'quickReply' },
            { label: 'Open URL', value: 'openUrl' },
            { label: 'Dial phone', value: 'dial' },
            { label: 'View location', value: 'viewLocation' },
            { label: 'Add to calendar', value: 'createCalendarEvent' }
        ];
    }
    get rcsResponseOptions() {
        return [
            { label: 'No scripted response', value: '' },
            { label: 'Text bubble', value: 'text' },
            { label: 'Rich card (auto-appends next in thread)', value: 'richCard' }
        ];
    }
    // Build a display descriptor for one chip/button (action row).
    _actionRow(x, ci) {
        const o = (x && typeof x === 'object') ? x : { label: x || '', action: 'quickReply' };
        const action = o.action || 'quickReply';
        const showTarget = ['openUrl', 'dial', 'viewLocation', 'createCalendarEvent'].includes(action);
        const targetLabel = action === 'dial' ? 'Phone' : action === 'viewLocation' ? 'Location'
            : action === 'createCalendarEvent' ? 'Event' : 'URL';
        const responseType = o.responseType || '';
        return {
            ci, label: o.label || '', action, target: o.target || '',
            responseType, response: o.response || '',
            isQuickReply: action === 'quickReply', showTarget, targetLabel,
            showRespText: responseType === 'text', triggersCard: responseType === 'richCard'
        };
    }
    handleRcsType(e) {
        const i = parseInt(e.currentTarget.dataset.i, 10);
        this._patchMsg(i, { type: e.detail.value });
    }
    handleTyping(e) {
        const i = parseInt(e.currentTarget.dataset.i, 10);
        this._patchMsg(i, { typingDuration: e.detail.value });
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
        // RCS mirrors the EG labels (Brand / Recipient); others keep Customer/Agent.
        if (this.isRcs) {
            return [
                { label: 'Brand', value: 'bot' },
                { label: 'Recipient', value: 'user' }
            ];
        }
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
        const msgs = this.config.messages || [];
        const remove = new Set([i]);
        // Preserve the quickReply->richCard pairing: deleting the triggering
        // message also removes its coupled follow-up (the next message if it's
        // triggeredBy), and deleting a triggered card removes nothing extra.
        const cur = msgs[i];
        const triggers = cur && []
            .concat(Array.isArray(cur.chips) ? cur.chips : [])
            .concat(cur.card && Array.isArray(cur.card.buttons) ? cur.card.buttons : [])
            .some((x) => x && typeof x === 'object' && x.responseType === 'richCard');
        if (triggers && msgs[i + 1] && msgs[i + 1].triggeredBy) remove.add(i + 1);
        this._commit({ messages: msgs.filter((m, idx) => !remove.has(idx)) });
    }
    _commit(patch) {
        this.config = { ...this.config, ...patch };
        this.saved = false;
        this.scheduleAutosave();
    }
    get decoratedMessages() {
        return (this.config.messages || []).map((m, i) => {
            const card = m.card || {};
            const type = m.type || 'text';
            const tone = RCS_TONES[type] || RCS_TONES.text;
            // Pairing banners: a chip/button whose response is a rich card
            // triggers the next message; the paired card carries triggeredBy.
            const trig = []
                .concat(Array.isArray(m.chips) ? m.chips : [])
                .concat(Array.isArray(card.buttons) ? card.buttons : [])
                .find((x) => x && typeof x === 'object' && x.responseType === 'richCard');
            return {
                i, sender: m.sender || 'user', text: this.resolveTokens(m.text),
                imageUrl: m.imageUrl || '',
                rowLabel: 'Message ' + (i + 1),
                isBot: (m.sender || 'user') === 'bot',
                // ---- RCS authoring row (EG parity) ----
                rcs: this.isRcs,
                rcsType: type,
                typingDuration: m.typingDuration || 'off',
                help: RCS_HELP[type] || '',
                triggeredByLabel: m.triggeredBy || '',
                triggersRichCard: !!trig,
                badgeStyle: 'background:' + tone.accent + ';',
                rowStyle: '--rcs-accent:' + tone.accent + ';--rcs-bg:' + tone.bg + ';--rcs-label:' + tone.label + ';',
                // which body to render (RCS)
                isText: this.isRcs && type === 'text',
                isQuickReplies: this.isRcs && type === 'quickReplies',
                isCard: this.isRcs && (type === 'richCardVertical' || type === 'richCardHorizontal'),
                isCarousel: this.isRcs && type === 'cardCarousel',
                isSuggested: this.isRcs && type === 'suggestedActions',
                // non-RCS messaging keeps the simple bubble+image editor
                showSimple: !this.isRcs,
                showRcsImage: this.isRcs && (type === 'text' || type === 'quickReplies'),
                chipRows: (Array.isArray(m.chips) ? m.chips : []).map((ch, ci) => this._actionRow(ch, ci)),
                buttonRows: (Array.isArray(card.buttons) ? card.buttons : []).map((b, ci) => this._actionRow(b, ci)),
                cardTitle: this.resolveTokens(card.title),
                cardDesc: this.resolveTokens(card.description),
                cardMedia: card.mediaUrl || ''
            };
        });
    }
    _patchMsg(i, patch) {
        const msgs = this.config.messages.map((m, idx) => idx === i ? { ...m, ...patch } : m);
        this._commit({ messages: msgs });
    }
    _patchCard(i, field, value) {
        const msgs = this.config.messages.map((m, idx) => {
            if (idx !== i) return m;
            const card = { ...(m.card || {}), [field]: value };
            // A message becomes a rich card once it has any card content; clears
            // back to a text bubble when all card content is removed.
            const hasCard = ['title', 'description', 'mediaUrl'].some((k) => (card[k] || '').trim())
                || (Array.isArray(card.buttons) && card.buttons.length);
            let type = m.type;
            if (hasCard && type !== 'richCardHorizontal') type = 'richCardVertical';
            else if (!hasCard && (type === 'richCardVertical' || type === 'richCardHorizontal')) type = 'text';
            return { ...m, card, type };
        });
        this._commit({ messages: msgs });
    }
    // Comma-separated labels, preserving any action/response on existing items
    // (chips/buttons can be rich objects {label,action,response,...}).
    _labels(arr) {
        return Array.isArray(arr) ? arr.map((x) => (x && typeof x === 'object' ? (x.label || '') : x)).join(', ') : '';
    }
    _mergeLabels(existing, value) {
        const labels = (value || '').split(',').map((s) => s.trim()).filter((s) => s);
        const prev = Array.isArray(existing) ? existing : [];
        return labels.map((label, i) => {
            const p = prev[i];
            if (p && typeof p === 'object') return { ...p, label };
            return { label, action: 'quickReply' };
        });
    }
    handleCardText(e) {
        const i = parseInt(e.currentTarget.dataset.i, 10);
        this._patchCard(i, e.currentTarget.dataset.field, e.target.value);
    }

    // ---- structured chip / card-button authoring (EG parity) ----
    // list = 'chips' (on the message) or 'buttons' (on the message's card).
    _getList(m, list) {
        if (list === 'buttons') return Array.isArray(m.card && m.card.buttons) ? m.card.buttons : [];
        return Array.isArray(m.chips) ? m.chips : [];
    }
    _setList(i, list, nextList, extraPairLabel) {
        let msgs = this.config.messages.map((m, idx) => {
            if (idx !== i) return m;
            if (list === 'buttons') return { ...m, card: { ...(m.card || {}), buttons: nextList } };
            return { ...m, chips: nextList };
        });
        if (extraPairLabel) msgs = this._ensurePairedCard(msgs, i, extraPairLabel);
        this._commit({ messages: msgs });
    }
    _asObj(x) { return (x && typeof x === 'object') ? { ...x } : { label: x || '', action: 'quickReply' }; }
    _rowFieldPatch(i, list, c, patch, pairLabel) {
        const arr = this._getList(this.config.messages[i], list).map((x, j) => j === c ? { ...this._asObj(x), ...patch } : x);
        this._setList(i, list, arr, pairLabel);
    }
    addChip(e) {
        const i = parseInt(e.currentTarget.dataset.i, 10);
        this._setList(i, 'chips', [...this._getList(this.config.messages[i], 'chips'), { label: 'New chip', action: 'quickReply' }]);
    }
    removeChip(e) {
        const i = parseInt(e.currentTarget.dataset.i, 10); const c = parseInt(e.currentTarget.dataset.c, 10);
        this._setList(i, 'chips', this._getList(this.config.messages[i], 'chips').filter((x, j) => j !== c));
    }
    addButton(e) {
        const i = parseInt(e.currentTarget.dataset.i, 10);
        this._setList(i, 'buttons', [...this._getList(this.config.messages[i], 'buttons'), { label: 'New button', action: 'openUrl' }]);
    }
    removeButton(e) {
        const i = parseInt(e.currentTarget.dataset.i, 10); const c = parseInt(e.currentTarget.dataset.c, 10);
        this._setList(i, 'buttons', this._getList(this.config.messages[i], 'buttons').filter((x, j) => j !== c));
    }
    // Field edits — dataset: i (message), c (item), list ('chips'|'buttons'), field.
    handleActionLabel(e) { this._rowFieldPatch(+e.currentTarget.dataset.i, e.currentTarget.dataset.list, +e.currentTarget.dataset.c, { label: e.target.value }); }
    handleActionTarget(e) { this._rowFieldPatch(+e.currentTarget.dataset.i, e.currentTarget.dataset.list, +e.currentTarget.dataset.c, { target: e.target.value }); }
    handleActionText(e) { this._rowFieldPatch(+e.currentTarget.dataset.i, e.currentTarget.dataset.list, +e.currentTarget.dataset.c, { response: e.target.value }); }
    handleActionType(e) {
        this._rowFieldPatch(+e.currentTarget.dataset.i, e.currentTarget.dataset.list, +e.currentTarget.dataset.c, { action: e.detail.value });
    }
    handleActionResponse(e) {
        const i = +e.currentTarget.dataset.i, c = +e.currentTarget.dataset.c, list = e.currentTarget.dataset.list;
        const rt = e.detail.value;
        const label = this._asObj(this._getList(this.config.messages[i], list)[c]).label;
        // Setting a rich-card response inserts the paired follow-up card after this message.
        this._rowFieldPatch(i, list, c, { responseType: rt }, rt === 'richCard' ? label : null);
    }
    // Insert a paired rich-card message right after message i (positional
    // pairing) unless the next message is already a triggered follow-up.
    _ensurePairedCard(msgs, i, label) {
        const nxt = msgs[i + 1];
        if (nxt && nxt.triggeredBy) {
            return msgs.map((m, idx) => idx === i + 1 ? { ...m, triggeredBy: label } : m);
        }
        const paired = {
            sender: 'bot', type: 'richCardVertical', typingDuration: 'medium', triggeredBy: label,
            card: { mediaType: 'image', mediaUrl: '', mediaSize: 'medium',
                title: 'Follow-up card',
                description: 'Edit this card — it plays after the recipient taps “' + label + '.”',
                buttons: [] }
        };
        const out = msgs.slice();
        out.splice(i + 1, 0, paired);
        return out;
    }
    handleCardImage(e) {
        const i = parseInt(e.currentTarget.dataset.i, 10);
        this._patchCard(i, 'mediaUrl', e.detail.url);
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
        if (this.isMessaging) {
            // Messaging channels only have a thread — swap in that industry's.
            this._commit({ messages: seedFor(this.channel, this.genIndustry) });
            return;
        }
        const pack = INDUSTRY_PACKS[this.genIndustry];
        if (pack) this._commit({ ...pack });
    }

    async runGenerate() {
        this.generating = true;
        try {
            const args = { industry: this.genIndustry, brand: this.config.brandName, context: this.genContext, angle: this.genAngle };
            // RCS generates the structured row model; other messaging channels a
            // text thread; email the full email + thread.
            const raw = this.isRcs ? await generateRcs(args)
                : this.isMessaging ? await generateSms(args) : await generateEmail(args);
            if (this.isRcs) this.applyGenRcsJson(JSON.parse(raw));
            else this.applyGenJson(JSON.parse(raw));
            this.showGenerate = false;
            const what = this.isMessaging ? 'AI drafted your 2-way conversation. Edit anything.' : 'AI drafted your email + conversation. Edit anything.';
            this.toast('Generated', what, 'success');
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
                .map((m) => ({ sender: m.sender === 'bot' ? 'bot' : 'user', text: m.text, imageUrl: m.imageUrl || '' }));
        }
        // If the AI picked up a specific recipient from the context, set the
        // Customer Profile so the [[CUSTOMER_FIRST_NAME]] token resolves to them.
        // Normalize: first name = first word (the model sometimes returns the
        // full name in customerFirstName).
        const full = gen.customerName || gen.customerFirstName;
        if (full) {
            patch.customerName = full;
            patch.customerFirstName = (gen.customerFirstName || full).trim().split(/\s+/)[0];
        }
        this._commit(patch);
    }

    // Apply a structured RCS payload (types + chips + cards + pairing). Sanitizes
    // to the Studio's message shape and keeps mediaUrl blank so the SE adds art.
    applyGenRcsJson(gen) {
        const patch = {};
        const full = gen.customerName || gen.customerFirstName;
        if (full) {
            patch.customerName = full;
            patch.customerFirstName = (gen.customerFirstName || full).trim().split(/\s+/)[0];
        }
        const okAction = (a) => ['quickReply', 'openUrl', 'dial', 'viewLocation', 'createCalendarEvent'].includes(a) ? a : 'quickReply';
        const okResp = (r) => (r === 'richCard' || r === 'text') ? r : '';
        const mapItem = (x) => (x && typeof x === 'object') ? {
            label: x.label || '', action: okAction(x.action), target: x.target || '',
            response: x.response || '', responseType: okResp(x.responseType)
        } : { label: String(x || ''), action: 'quickReply' };
        const mapCard = (c) => c && typeof c === 'object' ? {
            mediaType: c.mediaType === 'video' ? 'video' : 'image', mediaUrl: '', mediaSize: c.mediaSize || 'medium',
            title: c.title || '', description: c.description || '',
            buttons: Array.isArray(c.buttons) ? c.buttons.map(mapItem) : []
        } : undefined;
        const TYPES = ['text', 'quickReplies', 'richCardVertical', 'richCardHorizontal', 'cardCarousel', 'suggestedActions'];
        if (Array.isArray(gen.messages) && gen.messages.length) {
            patch.messages = gen.messages.map((m) => {
                const type = TYPES.includes(m.type) ? m.type : 'text';
                const out = { sender: m.sender === 'user' ? 'user' : 'bot', type };
                if (m.typingDuration) out.typingDuration = m.typingDuration;
                if (m.triggeredBy) out.triggeredBy = m.triggeredBy;
                if (m.text) out.text = m.text;
                if (Array.isArray(m.chips)) out.chips = m.chips.map(mapItem);
                if (m.card) out.card = mapCard(m.card);
                return out;
            });
        }
        this._commit(patch);
    }

    // ---- "How to prepare this" — a prompt that helps the SE WRITE the context ----
    // (returns plain text to paste into the Campaign context box; no JSON ever).
    @track showCopyPrompt = false;
    toggleCopyPrompt() { this.showCopyPrompt = !this.showCopyPrompt; }

    // Channel noun used throughout the Generate modal copy.
    get genNoun() { return this.isEmail ? 'email' : this.channelLabel; }
    get genModalTitle() { return 'Generate ' + this.channelLabel + ' with AI'; }
    get genModalSub() {
        return this.isEmail
            ? 'Describe the campaign — Einstein drafts the branded email and the 2-way conversation.'
            : 'Describe the campaign — Einstein drafts the 2-way ' + this.channelLabel + ' conversation.';
    }

    get copyablePrompt() {
        const brand = this.config.brandName || 'the customer';
        const sub = this.config.customerName || 'the primary contact';
        const ind = this.genIndustry;
        const noun = this.genNoun;
        const opener = this.isEmail ? 'The email' : 'The opening ' + noun;
        return [
            'Review everything you have on ' + brand + ' — all my meeting notes, call transcripts, and discovery for '
            + 'this account — and research ' + brand + ' on the web if you can (recent news, priorities, products, pains).',
            'Based on what we have ACTUALLY discussed with them so far, propose a marketing ' + noun + ' campaign for ' + brand
            + ' (' + ind + ') that the stakeholders I have been meeting with would resonate with — tied to their real '
            + 'priorities from our conversations, not a generic pitch. ' + opener + ' should invite a 2-way interaction '
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
