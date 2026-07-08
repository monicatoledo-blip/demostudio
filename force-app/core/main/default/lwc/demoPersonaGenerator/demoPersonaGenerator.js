import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import generatePersona from '@salesforce/apex/DemoStudioPersonaGenerator.generateForLwc';

/**
 * demoPersonaGenerator — richer input surface for AI persona generation.
 *
 * Input:  large textarea (transcript / notes / brief) + optional Brand and
 *         Industry / Story-Angle hints to steer the LLM.
 * Output: emits an `apply` event with the parsed persona bundle, which
 *         demoPersonaStudio.handleGeneratorApply merges into the working state.
 *
 * v2 dispatches through a preview-first flow: user generates → we hold the
 * result internally and show a summary card with Apply / Regenerate / Cancel
 * buttons before mutating anything in the parent.
 */
export default class DemoPersonaGenerator extends LightningElement {
    @api brand;
    isOpen = false;
    isBusy = false;

    // Input state
    storyContext = '';   // deal / champion / industry framing
    personaBrief = '';   // (optional) the fictional customer to build
    industry = '';
    storyAngle = '';
    showStoryPromptHelp = false;
    showPersonaPromptHelp = false;

    // Copy-to-clipboard prompts. Paste into Granola / Notebook LM / Gemini /
    // ChatGPT / Claude / whatever the SE uses, then paste the output back here.
    get storyContextPrompt() {
        return 'Summarize the deal I\'m working on into a "story context" for a Salesforce demo. Include: the customer, the internal champion (name + role), what they\'re trying to solve, the specific use case, and the pitch angle (cross-sell, retention, unified profile, etc.). Ignore anything that sounds like a to-do or blocker. Keep it under 200 words. Write it as one continuous paragraph, not bullets.';
    }
    get personaBriefPrompt() {
        return 'Based on what you know about the customer and the deal, describe ONE fictional customer that the champion would show off in a demo. Include: name, role, company, tenure, one distinctive engagement or product signal, and why they are a great example of the story angle. NOT the champion themselves — a customer THEIR bankers/reps would work. Keep it under 100 words.';
    }
    toggleStoryPromptHelp()  { this.showStoryPromptHelp = !this.showStoryPromptHelp; }
    togglePersonaPromptHelp() { this.showPersonaPromptHelp = !this.showPersonaPromptHelp; }
    async copyStoryPrompt()  { await this._copyToClipboard(this.storyContextPrompt, 'Story context prompt copied'); }
    async copyPersonaPrompt(){ await this._copyToClipboard(this.personaBriefPrompt, 'Persona prompt copied'); }
    async _copyToClipboard(text, toastTitle) {
        try {
            if (navigator && navigator.clipboard) await navigator.clipboard.writeText(text);
            this.dispatchEvent(new ShowToastEvent({ title: toastTitle, message: 'Paste into your AI tool of choice — Granola, Notebook LM, Gemini, ChatGPT, Slack AI, whatever.', variant: 'success' }));
        } catch (e) {
            this.dispatchEvent(new ShowToastEvent({ title: 'Copy failed', message: 'Select the text manually and copy.', variant: 'error' }));
        }
    }

    // Preview state (set after successful generation)
    @track candidate;      // { summary, personaJson, providerUsed, payload }
    @track candidateSummary = '';
    @track previewFocus = 'composition'; // 'composition' | 'identity' | 'story' | 'kpis' | 'alerts' | ...

    get previewFocusTabs() {
        const t = this.previewFocus;
        return [
            { key: 'composition', label: 'Full Composition',   className: t === 'composition' ? 'pv-tab pv-tab--active' : 'pv-tab' },
            { key: 'identity',    label: 'UP Card',            className: t === 'identity'    ? 'pv-tab pv-tab--active' : 'pv-tab' },
            { key: 'story',       label: 'Brief',              className: t === 'story'       ? 'pv-tab pv-tab--active' : 'pv-tab' },
            { key: 'kpis',        label: 'KPIs',               className: t === 'kpis'        ? 'pv-tab pv-tab--active' : 'pv-tab' },
            { key: 'alerts',      label: 'AI Alerts',          className: t === 'alerts'      ? 'pv-tab pv-tab--active' : 'pv-tab' },
            { key: 'insights',    label: 'Cross-Sell',         className: t === 'insights'    ? 'pv-tab pv-tab--active' : 'pv-tab' },
            { key: 'nbas',        label: 'Next Best Actions',  className: t === 'nbas'        ? 'pv-tab pv-tab--active' : 'pv-tab' },
            { key: 'activities',  label: 'Activities',         className: t === 'activities'  ? 'pv-tab pv-tab--active' : 'pv-tab' },
            { key: 'journeys',    label: 'Journeys',           className: t === 'journeys'    ? 'pv-tab pv-tab--active' : 'pv-tab' }
        ];
    }

    get previewLayout() {
        return this.previewFocus === 'composition' ? 'three-col' : 'stack';
    }

    // Feed demoPreviewFrame a synthetic bundle. Composition tab passes
    // 'recipe' focus so the frame renders whatever the candidate recipe
    // says; other tabs use their key as focus for the isolated per-widget view.
    get previewPassFocus() {
        return this.previewFocus === 'composition' ? 'recipe' : this.previewFocus;
    }

    get candidateBundle() {
        const c = this.candidate && this.candidate.payload;
        if (!c) return null;
        // The candidate has `recipe` as an object. demoPreviewFrame expects
        // it stringified onto persona.Component_Recipe__c. Splice it in
        // without mutating the original payload.
        const persona = { ...(c.persona || {}) };
        if (c.recipe) {
            try { persona.Component_Recipe__c = JSON.stringify(c.recipe); } catch (e) {}
        }
        return {
            persona,
            theme: null,
            identities: c.identities || [],
            insights: c.insights || [],
            activities: c.activities || [],
            journeys: c.journeys || [],
            kpis: c.kpis || [],
            alerts: c.alerts || [],
            segments: c.segments || [],
            nbas: c.nbas || []
        };
    }

    handlePreviewTab(e) {
        this.previewFocus = e.currentTarget.dataset.key;
    }

    @api
    open() {
        this.isOpen = true;
        this.storyContext = '';
        this.personaBrief = '';
        this.industry = '';
        this.storyAngle = '';
        this.candidate = null;
        this.candidateSummary = '';
    }

    close() {
        this.isOpen = false;
        this.candidate = null;
    }

    // -------- Input handlers --------

    handleStoryContextChange(e) { this.storyContext = e.target.value; }
    handlePersonaBriefChange(e) { this.personaBrief = e.target.value; }
    handleIndustryChange(e) { this.industry = e.detail.value; }
    handleStoryAngleChange(e) { this.storyAngle = e.detail.value; }

    get industryOptions() {
        return [
            { label: 'Financial Services',  value: 'FSI' },
            { label: 'Wealth Management',   value: 'Wealth' },
            { label: 'Retail Banking',      value: 'Retail Banking' },
            { label: 'Commercial Banking',  value: 'Commercial Banking' },
            { label: 'Insurance',           value: 'Insurance' },
            { label: 'Healthcare',          value: 'HLS' },
            { label: 'Retail',              value: 'Retail' },
            { label: 'Manufacturing',       value: 'MFG' },
            { label: 'Technology',          value: 'Tech' }
        ];
    }
    get storyAngleOptions() {
        return [
            { label: 'Cross-sell / Upsell',     value: 'Cross-Sell' },
            { label: 'Retention / Save',        value: 'Retention' },
            { label: 'Onboarding',              value: 'Onboarding' },
            { label: 'Application in Flight',   value: 'In-Flight Application' },
            { label: 'Wealth / HNW Advisory',   value: 'Wealth Advisory' },
            { label: 'Marketing Engagement',    value: 'Marketing' },
            { label: 'Service / Case Resolution', value: 'Service' }
        ];
    }

    get generateDisabled() {
        // Story Context is required. Persona Brief is optional — Einstein
        // will invent a plausible customer if it's blank.
        return this.isBusy || !this.storyContext || !this.storyContext.trim();
    }

    // -------- Generation --------

    // Compose a labeled brief so the model can distinguish story context
    // (the deal / champion / narrative) from persona description (the
    // fictional customer the demo will show). The provider treats these
    // as separate sections.
    _composedBrief() {
        const parts = [];
        if (this.industry) parts.push(`Industry: ${this.industry}.`);
        if (this.storyAngle) parts.push(`Story angle: ${this.storyAngle}.`);
        if (this.brand) parts.push(`Brand: ${this.brand}.`);
        parts.push('## STORY CONTEXT (deal framing, champion notes, business case — this is the SETTING, not the persona)');
        parts.push(this.storyContext.trim());
        if (this.personaBrief && this.personaBrief.trim()) {
            parts.push('## PERSONA TO BUILD (the fictional customer that will appear on the demo record)');
            parts.push(this.personaBrief.trim());
        } else {
            parts.push('## PERSONA TO BUILD');
            parts.push('(No specific customer provided — invent a plausible one that fits the story context above.)');
        }
        return parts.join('\n\n');
    }

    async handleGenerate() {
        this.isBusy = true;
        this.candidate = null;
        try {
            const composed = this._composedBrief();
            const result = await generatePersona({ brief: composed, brandHint: this.brand }) || {};
            const rawJson = result.personaJson;
            let payload = null;
            if (rawJson) {
                try { payload = JSON.parse(rawJson); } catch (e) { payload = null; }
                if (payload && this.brand && payload.persona) {
                    payload.persona.Brand__c = this.brand;
                }
            }

            this.candidate = { ...result, payload };
            this.candidateSummary = this._summarizeCandidate(payload) || result.summary || 'Persona generated.';
            this.previewFocus = 'composition';

            if (!payload) {
                // Provider likely returned a clarifying question with a null payload.
                // Keep the input visible; show the summary as guidance.
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Need more detail',
                    message: result.summary || 'Try adding more context.',
                    variant: 'info'
                }));
                this.candidate = null;
            }
        } catch (err) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Generation failed',
                message: (err && err.body && err.body.message) || err.message || 'Unknown error',
                variant: 'error'
            }));
        } finally {
            this.isBusy = false;
        }
    }

    _summarizeCandidate(payload) {
        if (!payload) return '';
        const p = payload.persona || {};
        const name = `${p.First_Name__c || ''} ${p.Last_Name__c || ''}`.trim();
        const parts = [];
        if (name) parts.push(name);
        if (p.Title__c) parts.push(p.Title__c);
        if (p.Company__c) parts.push(p.Company__c);
        const chips = [];
        if ((payload.kpis || []).length)       chips.push(`${payload.kpis.length} KPIs`);
        if ((payload.alerts || []).length)     chips.push(`${payload.alerts.length} alerts`);
        if ((payload.segments || []).length)   chips.push(`${payload.segments.length} segments`);
        if ((payload.insights || []).length)   chips.push(`${payload.insights.length} cross-sell`);
        if ((payload.nbas || []).length)       chips.push(`${payload.nbas.length} NBAs`);
        if ((payload.activities || []).length) chips.push(`${payload.activities.length} activities`);
        if ((payload.journeys || []).length)   chips.push(`${payload.journeys.length} journeys`);
        return parts.join(' · ') + (chips.length ? ` — includes ${chips.join(', ')}` : '');
    }

    handleApply() {
        if (!this.candidate || !this.candidate.payload) return;
        this.dispatchEvent(new CustomEvent('apply', { detail: this.candidate.payload }));
        this.dispatchEvent(new ShowToastEvent({
            title: 'Persona applied to preview',
            message: 'Auto-save is picking up the changes. Review the tabs and tweak anything.',
            variant: 'success'
        }));
        this.close();
    }

    handleRegenerate() {
        this.candidate = null;
        this.handleGenerate();
    }

    // -------- View flags --------
    get showInputForm() { return !this.candidate; }
    get showPreview()   { return !!this.candidate; }
    get providerBadge() { return this.candidate && this.candidate.providerUsed ? this.candidate.providerUsed : ''; }
}
