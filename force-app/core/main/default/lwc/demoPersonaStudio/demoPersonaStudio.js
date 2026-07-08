import { LightningElement, api, wire, track } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getPersonaBundle from '@salesforce/apex/DemoStudioService.getPersonaBundle';
import savePersonaBundle from '@salesforce/apex/DemoStudioService.savePersonaBundle';
import {
    PLACEHOLDER_IDENTITIES,
    PLACEHOLDER_INSIGHTS,
    PLACEHOLDER_ACTIVITIES,
    PLACEHOLDER_JOURNEYS,
    PLACEHOLDER_KPIS,
    PLACEHOLDER_ALERTS,
    PLACEHOLDER_SEGMENTS,
    PLACEHOLDER_NBAS
} from 'c/demoPersonaDefaults';

// Editor rows to seed when the persona has none saved yet. We strip the
// synthetic Id so the save path treats them as fresh inserts (real Id gets
// assigned on save).
function seed(defaults) {
    return defaults.map((d) => {
        const { Id, ...rest } = d;
        return rest;
    });
}

// Rail is (mostly) flat, but Identity is a parent group with sub-entries
// for the widgets that render inside the header card (UP Card / Segments /
// Individuals). All other collections stay top-level.
const TABS = [
    { key: 'theme',    label: 'Brand Kit', icon: 'utility:color_swatch' },
    { key: 'recipe',   label: 'Recipe', icon: 'utility:layout' },
    {
        key: 'identity-group', label: 'Identity', icon: 'utility:user', group: true,
        children: [
            { key: 'identity',   label: 'UP Card',     icon: 'utility:profile' },
            { key: 'segments',   label: 'Segments',    icon: 'utility:apps' },
            { key: 'identities', label: 'Individuals', icon: 'utility:groups' }
        ]
    },
    { key: 'story',      label: 'Story',      icon: 'utility:einstein' },
    { key: 'kpis',       label: 'KPIs',       icon: 'utility:chart' },
    { key: 'alerts',     label: 'AI Alerts',  icon: 'utility:notification' },
    { key: 'insights',   label: 'Cross-Sell Insights', icon: 'utility:trending' },
    { key: 'nbas',       label: 'Next Best Actions',   icon: 'utility:target' },
    { key: 'activities', label: 'Activities', icon: 'utility:date_time' },
    { key: 'journeys',   label: 'Journeys',   icon: 'utility:flow' },
    { key: 'contacts',   label: 'Assigned Contacts', icon: 'utility:contact' }
];

export default class DemoPersonaStudio extends LightningElement {
    @api recordId;

    @track working;
    wiredResult;
    activeTab = 'theme';
    isSaving = false;
    isDirty = false;
    recipeSelectorCollapsed = false;

    // Auto-save state
    autoSaveTimer;
    autoSaveDelayMs = 1500;
    lastSavedAt;
    saveStatus = 'idle'; // 'idle' | 'pending' | 'saving' | 'saved' | 'error'
    saveError;

    @wire(getPersonaBundle, { personaId: '$recordId' })
    wired(result) {
        this.wiredResult = result;
        if (!result.data) return;
        // Don't clobber in-progress edits. isSaving stays true across the
        // save→refreshApex window; without it a keystroke landing between
        // "isDirty = false" and refresh completion loses to the server copy.
        if (this.isDirty || this.isSaving) return;
        const bundle = this.cloneBundle(result.data);
        // Seed empty collections with placeholder demo rows so users have
        // something to customize instead of a blank editor. isDirty stays
        // false — nothing persists until the user actually edits.
        this._seedEmptyCollections(bundle);
        this.working = bundle;
        this.applyTheme();
    }

    // Centralized dirty-marker. Kicks off a debounced auto-save.
    _markDirty() {
        this.isDirty = true;
        this.saveStatus = 'pending';
        this._scheduleAutoSave();
    }

    _scheduleAutoSave() {
        if (this.autoSaveTimer) clearTimeout(this.autoSaveTimer);
        this.autoSaveTimer = setTimeout(() => {
            this.autoSaveTimer = null;
            this._doAutoSave();
        }, this.autoSaveDelayMs);
    }

    async _doAutoSave() {
        // Bail if there's nothing to save or the persona hasn't loaded yet.
        if (!this.isDirty) return;
        if (this.isSaving) {
            // Another save in flight — reschedule to catch the latest state.
            this._scheduleAutoSave();
            return;
        }
        const p = this.working && this.working.persona;
        if (!p || !p.Id) return;
        this.isSaving = true;
        this.saveStatus = 'saving';
        try {
            await savePersonaBundle({ payloadJson: JSON.stringify(this.working) });
            this.isDirty = false;
            this.saveStatus = 'saved';
            this.saveError = undefined;
            await refreshApex(this.wiredResult);
        } catch (err) {
            this.saveStatus = 'error';
            this.saveError = (err && err.body && err.body.message) || err.message || 'Unknown error';
        } finally {
            this.isSaving = false;
        }
    }

    disconnectedCallback() {
        if (this.autoSaveTimer) clearTimeout(this.autoSaveTimer);
    }

    _seedEmptyCollections(bundle) {
        if (!bundle.identities || bundle.identities.length === 0) bundle.identities = seed(PLACEHOLDER_IDENTITIES);
        if (!bundle.insights   || bundle.insights.length === 0)   bundle.insights   = seed(PLACEHOLDER_INSIGHTS);
        if (!bundle.activities || bundle.activities.length === 0) bundle.activities = seed(PLACEHOLDER_ACTIVITIES);
        if (!bundle.journeys   || bundle.journeys.length === 0)   bundle.journeys   = seed(PLACEHOLDER_JOURNEYS);
        if (!bundle.kpis       || bundle.kpis.length === 0)       bundle.kpis       = seed(PLACEHOLDER_KPIS);
        if (!bundle.alerts     || bundle.alerts.length === 0)     bundle.alerts     = seed(PLACEHOLDER_ALERTS);
        if (!bundle.segments   || bundle.segments.length === 0)   bundle.segments   = seed(PLACEHOLDER_SEGMENTS);
        if (!bundle.nbas       || bundle.nbas.length === 0)       bundle.nbas       = seed(PLACEHOLDER_NBAS);
    }

    cloneBundle(b) {
        return JSON.parse(JSON.stringify(b || {}));
    }

    applyTheme() {
        const t = this.working && this.working.theme;
        if (!t) return;
        const host = this.template.host;
        if (t.Primary_Color__c)  host.style.setProperty('--demo-primary', t.Primary_Color__c);
        if (t.Accent_Color__c)   host.style.setProperty('--demo-accent', t.Accent_Color__c);
        if (t.Font_Family__c)    host.style.setProperty('--demo-font', t.Font_Family__c);

        // Solid header themes fill the card with Primary_Color__c; Gradient
        // themes use the stored gradient. Fall back to the default gradient
        // only when neither is set.
        const bg = (t.Header_Style__c === 'Solid')
            ? (t.Primary_Color__c || '#0070d2')
            : (t.Background_Gradient__c || 'linear-gradient(135deg,#032d60,#0070d2)');
        host.style.setProperty('--demo-bg-gradient', bg);

        // Derive foreground from the effective header background so light
        // themes flip text to dark. Same math as the shell/preview.
        const sample = (t.Header_Style__c === 'Solid') ? (t.Primary_Color__c || '#0070d2')
            : ((/#([0-9a-fA-F]{6})/.exec(t.Background_Gradient__c || '') || [])[1]
                ? '#' + (/#([0-9a-fA-F]{6})/.exec(t.Background_Gradient__c || ''))[1]
                : (t.Primary_Color__c || '#0070d2'));
        const light = this._isLightHex(sample);
        host.style.setProperty('--demo-fg', light ? '#181818' : '#ffffff');
        host.style.setProperty('--demo-fg-muted', light ? 'rgba(0,0,0,0.65)' : 'rgba(255,255,255,0.75)');
        host.style.setProperty('--demo-fg-divider', light ? 'rgba(0,0,0,0.12)' : 'rgba(255,255,255,0.15)');
        host.style.setProperty('--demo-fg-chip-bg', light ? 'rgba(0,0,0,0.06)' : 'rgba(255,255,255,0.08)');
        host.style.setProperty('--demo-fg-chip-border', light ? 'rgba(0,0,0,0.18)' : 'rgba(255,255,255,0.22)');

        // Separate luminance check for --demo-primary so yellow primaries
        // get dark badge/pill text.
        const primaryLight = this._isLightHex(t.Primary_Color__c || '#0070d2');
        host.style.setProperty('--demo-primary-fg', primaryLight ? '#181818' : '#ffffff');
    }
    _isLightHex(hex) {
        if (!hex || hex[0] !== '#') return false;
        let h = hex.slice(1);
        if (h.length === 3) h = h.split('').map((c) => c + c).join('');
        const r = parseInt(h.slice(0, 2), 16);
        const g = parseInt(h.slice(2, 4), 16);
        const b = parseInt(h.slice(4, 6), 16);
        return ((0.299 * r + 0.587 * g + 0.114 * b) / 255) > 0.65;
    }

    // Flatten the TABS structure for template rendering. Group parents keep
    // their child items; child items get an extra --child class. Active state
    // considers both the direct match and (for parent groups) whether any of
    // their children are the active tab.
    get tabs() {
        return TABS.map((t) => {
            if (t.group) {
                const anyChildActive = (t.children || []).some((c) => c.key === this.activeTab);
                const childActive = (t.children || []).find((c) => c.key === this.activeTab);
                return {
                    ...t,
                    isGroup: true,
                    className: anyChildActive ? 'studio-tab studio-tab--group studio-tab--parent-active' : 'studio-tab studio-tab--group',
                    // Only render children when the group is "open" (any child active OR the group itself was clicked).
                    // For simplicity, keep them always visible so the user can see all sub-options.
                    decoratedChildren: (t.children || []).map((c) => ({
                        ...c,
                        className: c.key === this.activeTab
                            ? 'studio-tab studio-tab--child studio-tab--active'
                            : 'studio-tab studio-tab--child'
                    }))
                };
            }
            return {
                ...t,
                isGroup: false,
                className: t.key === this.activeTab ? 'studio-tab studio-tab--active' : 'studio-tab'
            };
        });
    }

    get persona()    { return (this.working && this.working.persona)    || {}; }
    get theme()      { return (this.working && this.working.theme)      || {}; }
    get identities() { return (this.working && this.working.identities) || []; }
    get insights()   { return (this.working && this.working.insights)   || []; }
    get activities() { return (this.working && this.working.activities) || []; }
    get journeys()   { return (this.working && this.working.journeys)   || []; }
    get kpis()       { return (this.working && this.working.kpis)       || []; }
    get alerts()     { return (this.working && this.working.alerts)     || []; }
    get segments()   { return (this.working && this.working.segments)   || []; }
    get nbas()       { return (this.working && this.working.nbas)       || []; }

    get showIdentity()   { return this.activeTab === 'identity'; }
    get showStory()      { return this.activeTab === 'story'; }
    get showIdentities() { return this.activeTab === 'identities'; }
    get showInsights()   { return this.activeTab === 'insights'; }
    get showActivities() { return this.activeTab === 'activities'; }
    get showJourneys()   { return this.activeTab === 'journeys'; }
    get showKpis()       { return this.activeTab === 'kpis'; }
    get showAlerts()     { return this.activeTab === 'alerts'; }
    get showSegments()   { return this.activeTab === 'segments'; }
    get showNbas()       { return this.activeTab === 'nbas'; }
    get showTheme()      { return this.activeTab === 'theme'; }
    get showRecipe()     { return this.activeTab === 'recipe'; }
    get showContacts()   { return this.activeTab === 'contacts'; }
    get showPreview()    { return true; }
    // On the Contacts tab, show the fully composed recipe view (not a
    // per-tab focused subset). Everywhere else, follow the active tab.
    get previewFocus() {
        return this.activeTab === 'contacts' ? 'recipe' : this.activeTab;
    }

    // Layout: 3-column composed view when the Recipe tab or Contacts tab
    // is active (either wants to see the full record page). Everywhere
    // else, single-column stack focused on the current tab.
    get previewLayout() {
        return (this.activeTab === 'recipe' || this.activeTab === 'contacts')
            ? 'three-col'
            : 'stack';
    }

    // On Recipe when the picker is collapsed, the editor pane shrinks so
    // the preview canvas can span nearly the full studio width.
    get splitClass() {
        if (this.activeTab === 'recipe' && this.recipeSelectorCollapsed) {
            return 'studio-split studio-split--preview-wide';
        }
        if (this.activeTab === 'recipe' || this.activeTab === 'contacts') {
            return 'studio-split studio-split--preview-wide-fit';
        }
        return 'studio-split';
    }

    handleRecipeCollapse(e) {
        this.recipeSelectorCollapsed = !!(e.detail && e.detail.collapsed);
    }

    handleTabClick(e) {
        const key = e.currentTarget.dataset.key;
        // Clicking a group parent opens its first child.
        const group = TABS.find((t) => t.group && t.key === key);
        if (group && group.children && group.children.length) {
            this.activeTab = group.children[0].key;
            return;
        }
        this.activeTab = key;
    }

    handlePersonaChange(e) {
        const { field, value, themeSnapshot } = e.detail;
        // Flip isDirty FIRST so any wire re-fire triggered mid-update takes
        // the "leave working alone" branch and can't clobber the pending edit.
        this._markDirty();
        const nextPersona = { ...(this.working && this.working.persona), [field]: value };
        // Reassign this.working so LWC reactivity fires and children (preview) re-render.
        this.working = { ...(this.working || {}), persona: nextPersona };
        // When the theme lookup changes, also swap the working theme object so
        // the preview restyles instantly instead of waiting for a save+reload.
        if (field === 'Theme__c' && themeSnapshot) {
            this.working = { ...this.working, theme: themeSnapshot };
            this.applyTheme();
        }
    }

    handleChildChange(e) {
        const { collection, index, field, value } = e.detail;
        const list = [...(this.working[collection] || [])];
        list[index] = { ...list[index], [field]: value };
        this.working = { ...this.working, [collection]: list };
        this._markDirty();
    }

    handleAddChild(e) {
        const collection = e.detail.collection;
        const list = [...(this.working[collection] || []), this.defaultRow(collection)];
        this.working = { ...this.working, [collection]: list };
        this._markDirty();
    }

    handleRemoveChild(e) {
        const { collection, index } = e.detail;
        const list = [...(this.working[collection] || [])];
        list.splice(index, 1);
        this.working = { ...this.working, [collection]: list };
        this._markDirty();
    }

    // Sparkle merge — Einstein returned new rows for one collection.
    // mode='replace' wipes the old rows; mode='append' concatenates.
    handleSparkleMerge(e) {
        const { collection, mode, rows } = e.detail || {};
        if (!collection || !rows) return;
        const clean = (rows || []).map(({ Id, ...rest }) => rest);
        const current = (this.working && this.working[collection]) || [];
        const next = mode === 'append' ? [...current, ...clean] : clean;
        this.working = { ...(this.working || {}), [collection]: next };
        this._markDirty();
    }

    defaultRow(collection) {
        switch (collection) {
            case 'identities': return { Type__c: 'Email', Value__c: '', Label__c: 'Primary', Sort_Order__c: 99 };
            case 'insights':   return { Title__c: '', Category__c: 'Cross-Sell', Why_This_Suggestion__c: '', Image_URL__c: '', CTA_Label__c: 'Take Action', Sort_Order__c: 99 };
            case 'activities': return { Type__c: 'Email', Title__c: '', Description__c: '', Timestamp_Label__c: 'Today', Icon__c: 'utility:activity', Sort_Order__c: 99 };
            case 'journeys':   return { Journey_Name__c: '', Business_Unit__c: 'Commercial', Status__c: 'Active', Enrolled_Date__c: new Date().toISOString().slice(0,10) };
            case 'kpis':       return { Label__c: '', Value__c: '', Sublabel__c: '', Is_Highlighted__c: false, Sort_Order__c: 99 };
            case 'alerts':     return { Category_Label__c: '', Category_Style__c: 'Info', Title__c: '', Body__c: '', Sort_Order__c: 99 };
            case 'segments':   return { Label__c: '', Sort_Order__c: 99 };
            case 'nbas':       return { Title__c: '', Category__c: 'Direct Action', Why_This_Suggestion__c: '', CTA_Label__c: 'Take Action', Image_URL__c: '', Sort_Order__c: 99 };
            default: return {};
        }
    }

    // Decorated getters for template loops (index in dataset)
    get decoratedIdentities() {
        return (this.identities || []).map((r, i) => ({ ...r, _index: i, _key: r.Id || `new-${i}` }));
    }
    get decoratedInsights() {
        return (this.insights || []).map((r, i) => ({ ...r, _index: i, _key: r.Id || `new-${i}` }));
    }
    get decoratedActivities() {
        return (this.activities || []).map((r, i) => ({ ...r, _index: i, _key: r.Id || `new-${i}` }));
    }
    get decoratedJourneys() {
        return (this.journeys || []).map((r, i) => ({ ...r, _index: i, _key: r.Id || `new-${i}` }));
    }
    get decoratedKpis() {
        return (this.kpis || []).map((r, i) => ({ ...r, _index: i, _key: r.Id || `new-${i}` }));
    }
    get decoratedAlerts() {
        return (this.alerts || []).map((r, i) => ({ ...r, _index: i, _key: r.Id || `new-${i}` }));
    }
    get decoratedSegments() {
        return (this.segments || []).map((r, i) => ({ ...r, _index: i, _key: r.Id || `new-${i}` }));
    }
    get decoratedNbas() {
        return (this.nbas || []).map((r, i) => ({ ...r, _index: i, _key: r.Id || `new-${i}` }));
    }

    get alertStyleOptions() {
        return ['Info','Success','Warning','Danger'].map((v) => ({ label: v, value: v }));
    }

    get propensityOptions() {
        return ['Low','Medium','High','Very High'].map((v) => ({ label: v, value: v }));
    }
    get riskOptions() {
        return ['Low','Medium','High'].map((v) => ({ label: v, value: v }));
    }
    get lifecycleOptions() {
        return ['Prospect','Lead','Active Customer','Cross-Sell Target','Churn Risk'].map((v) => ({ label: v, value: v }));
    }
    get identityTypeOptions() {
        return ['Email','Phone','Address'].map((v) => ({ label: v, value: v }));
    }
    get insightCategoryOptions() {
        return ['Cross-Sell','Next-Best-Action','Risk','Retention'].map((v) => ({ label: v, value: v }));
    }
    get activityTypeOptions() {
        return ['Email','SMS','Web','Doc','Call','Meeting'].map((v) => ({ label: v, value: v }));
    }
    get buOptions() {
        return ['Commercial','Wealth','Retail','Corporate Comms','Treasury'].map((v) => ({ label: v, value: v }));
    }
    get journeyStatusOptions() {
        return ['Active','Paused','Completed','Exited'].map((v) => ({ label: v, value: v }));
    }

    get saveDisabled() { return this.isSaving || !this.isDirty; }
    get saveLabel() { return this.isSaving ? 'Saving…' : (this.isDirty ? 'Save Changes' : 'Saved'); }

    // Auto-save UI
    get saveStatusText() {
        switch (this.saveStatus) {
            case 'pending': return 'Unsaved changes…';
            case 'saving':  return 'Saving…';
            case 'saved':   return 'All changes saved';
            case 'error':   return 'Save failed';
            default:        return 'All changes saved';
        }
    }
    get saveStatusIcon() {
        switch (this.saveStatus) {
            case 'saving':  return 'utility:sync';
            case 'saved':   return 'utility:success';
            case 'error':   return 'utility:warning';
            default:        return null;
        }
    }
    get saveStatusPillClass() {
        return `save-status save-status--${this.saveStatus || 'idle'}`;
    }
    get showManualSave() {
        // Show a manual save button when auto-save failed or there are pending
        // changes the user might want to commit immediately.
        return this.saveStatus === 'error' || this.saveStatus === 'pending';
    }
    handleManualSave() {
        if (this.autoSaveTimer) { clearTimeout(this.autoSaveTimer); this.autoSaveTimer = null; }
        this._doAutoSave();
    }

    get previewLabel() {
        if (this.activeTab === 'contacts') return 'Full Composition';
        const tab = TABS.find((t) => t.key === this.activeTab);
        return tab ? tab.label : 'Preview';
    }

    get personaName() {
        const p = this.persona || {};
        return `${p.First_Name__c || ''} ${p.Last_Name__c || ''}`.trim() || (p.Name || '');
    }

    get studioSubtitle() {
        const p = this.persona || {};
        const parts = [];
        const name = `${p.First_Name__c || ''} ${p.Last_Name__c || ''}`.trim();
        if (name) parts.push(name);
        if (p.Title__c) parts.push(p.Title__c);
        if (p.Brand__c) parts.push(p.Brand__c);
        return parts.join(' · ');
    }

    helpSteps = [
        { title: 'Set the Brand', desc: 'On the Identity tab, fill in "Brand / Customer" (e.g. Cumulus Bank) so you remember which customer this persona is for.' },
        { title: 'Pick a Brand Kit', desc: 'Brand Kits are managed on their own tab (Demo Studio → Brand Kits). Assign one to this persona to control colors, gradient, and logo.' },
        { title: 'Fill in Identity + Story', desc: 'Identity = who they are (name, title, avatar, LTV). Story = the Agentforce brief (intent, key context, suggested opener) and likelihood scores.' },
        { title: 'Add child records', desc: 'Individuals (emails/phones), Insights (cross-sell cards), Activities (timeline), Journeys (BU enrollments). Use Add Row / delete controls per tab.' },
        { title: 'Choose components in Recipe', desc: 'Recipe tab is a checklist — pick which LWCs render on the Contact page. Left rail sits beside the record, Center is the main story, Right rail is auxiliary.' },
        { title: 'Live Preview follows your tab', desc: 'The preview pane on the right shows only what the current tab affects. Switch to Recipe to see the full composed view.' },
        { title: 'Save, then assign to a Contact', desc: 'Click Save. Open any Contact in Demo Studio → set Demo Persona = this record. The Contact page reskins to this branded profile.' }
    ];

    async handleSave() {
        this.isSaving = true;
        try {
            await savePersonaBundle({ payloadJson: JSON.stringify(this.working) });
            await refreshApex(this.wiredResult);
            this.isDirty = false;
            this.dispatchEvent(new ShowToastEvent({
                title: 'Persona saved',
                message: `${this.persona.First_Name__c || ''} ${this.persona.Last_Name__c || ''} updated.`,
                variant: 'success'
            }));
        } catch (err) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Save failed',
                message: (err && err.body && err.body.message) || err.message || 'Unknown error',
                variant: 'error'
            }));
        } finally {
            this.isSaving = false;
        }
    }

    handleRevert() {
        if (this.wiredResult && this.wiredResult.data) {
            this.working = this.cloneBundle(this.wiredResult.data);
            this.isDirty = false;
        }
    }

    openGenerator() {
        const g = this.refs && this.refs.generator;
        if (g) g.open();
    }

    handleGeneratorApply(e) {
        const payload = e.detail || {};
        const w = this.working || {};
        // Merge persona fields, preserve Id and Theme lookup
        if (payload.persona) {
            const keptId = w.persona && w.persona.Id;
            const keptTheme = w.persona && w.persona.Theme__c;
            w.persona = { ...(w.persona || {}), ...payload.persona };
            if (keptId) w.persona.Id = keptId;
            if (keptTheme && !w.persona.Theme__c) w.persona.Theme__c = keptTheme;
        }
        if (payload.recipe) {
            w.persona.Component_Recipe__c = JSON.stringify(payload.recipe);
        }
        // Replace child collections wholesale (generator supplies the story shape).
        // Strips any incoming Id fields so save-time inserts fresh rows attached
        // to this persona; prevents accidental relinks to another persona's rows.
        const stripIds = (list) => (list || []).map(({ Id, ...rest }) => rest);
        if (payload.identities) w.identities = stripIds(payload.identities);
        if (payload.insights)   w.insights   = stripIds(payload.insights);
        if (payload.activities) w.activities = stripIds(payload.activities);
        if (payload.journeys)   w.journeys   = stripIds(payload.journeys);
        if (payload.kpis)       w.kpis       = stripIds(payload.kpis);
        if (payload.alerts)     w.alerts     = stripIds(payload.alerts);
        if (payload.segments)   w.segments   = stripIds(payload.segments);
        if (payload.nbas)       w.nbas       = stripIds(payload.nbas);
        this.working = { ...w };
        this._markDirty();
    }
}
