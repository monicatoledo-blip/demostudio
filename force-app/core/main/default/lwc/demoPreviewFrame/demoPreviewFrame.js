import { LightningElement, api } from 'lwc';
import {
    withPersonaDefaults,
    withIdentitiesDefault,
    withInsightsDefault,
    withActivitiesDefault,
    withJourneysDefault,
    withKpisDefault,
    withAlertsDefault,
    withSegmentsDefault,
    withNbasDefault
} from 'c/demoPersonaDefaults';

const COMPONENT_MAP = {
    demoUnifiedProfileHeader: 'isHeader',
    demoAgentforceBrief: 'isBrief',
    demoCrossSellInsights: 'isCrossSell',
    demoNextBestActions: 'isNba',
    demoLikelihoodScoreCard: 'isLikelihood',
    demoActivityTimeline: 'isTimeline',
    demoActiveJourneyTracker: 'isJourneys',
    demoKpiStatRow: 'isKpiRow',
    demoAiInsightsAlerts: 'isAlerts'
};

function decorateColumn(list) {
    return (list || [])
        .map((c) => c && c.component)
        .filter((name) => !!COMPONENT_MAP[name])
        .map((name) => {
            const flags = {};
            for (const key of Object.values(COMPONENT_MAP)) flags[key] = false;
            flags[COMPONENT_MAP[name]] = true;
            return { name, ...flags };
        });
}

export default class DemoPreviewFrame extends LightningElement {
    _bundle;

    @api focus; // 'identity' | 'story' | 'identities' | 'insights' | 'activities' | 'journeys' | 'theme' | 'recipe'
    @api layout = 'stack'; // 'stack' | 'three-col'

    get isStackLayout() { return this.layout !== 'three-col'; }
    get isThreeColLayout() { return this.layout === 'three-col'; }

    get leftRailComponents() { return decorateColumn(this.recipe.leftRail); }
    get centerComponents() { return decorateColumn(this.recipe.center); }
    get rightRailComponents() { return decorateColumn(this.recipe.rightRail); }

    // Which tab the profile header should open on. Editing Individuals in the
    // studio → open the header's Individuals tab so the user sees what they're
    // editing. Everything else → the Unified Card face.
    get headerInitialTab() {
        return this.focus === 'identities' ? 'individuals' : 'card';
    }

    get leftRailEmpty() { return this.leftRailComponents.length === 0; }
    get centerEmpty() { return this.centerComponents.length === 0; }
    get rightRailEmpty() { return this.rightRailComponents.length === 0; }

    @api
    get bundle() { return this._bundle; }
    set bundle(v) {
        this._bundle = v;
        this.applyTheme();
    }

    get persona()    { return withPersonaDefaults((this._bundle && this._bundle.persona) || {}); }
    get theme()      { return (this._bundle && this._bundle.theme)      || {}; }
    get identities() { return withIdentitiesDefault(this._bundle && this._bundle.identities); }
    get insights()   { return withInsightsDefault(this._bundle && this._bundle.insights); }
    get activities() { return withActivitiesDefault(this._bundle && this._bundle.activities); }
    get journeys()   { return withJourneysDefault(this._bundle && this._bundle.journeys); }
    get kpis()     { return withKpisDefault(this._bundle && this._bundle.kpis); }
    get alerts()   { return withAlertsDefault(this._bundle && this._bundle.alerts); }
    get segments() { return withSegmentsDefault(this._bundle && this._bundle.segments); }
    get nbas()     { return withNbasDefault(this._bundle && this._bundle.nbas); }

    get recipe() {
        const realPersona = (this._bundle && this._bundle.persona) || {};
        try {
            const r = JSON.parse(realPersona.Component_Recipe__c || '{}');
            return {
                leftRail: r.leftRail || [],
                center: r.center || [],
                rightRail: r.rightRail || []
            };
        } catch (e) {
            return { leftRail: [], center: [], rightRail: [] };
        }
    }

    has(slot, name) {
        return (this.recipe[slot] || []).some((c) => c.component === name);
    }

    // Focus-driven visibility. Default (no focus / recipe) = show all recipe-selected components.
    // Otherwise show only what the tab is editing.
    get showHeader() {
        if (this.isFocus('identity', 'identities', 'theme', 'segments')) return true;
        if (this.isRecipeView) return this.has('leftRail', 'demoUnifiedProfileHeader');
        return false;
    }
    get showBrief() {
        if (this.isFocus('story')) return true;
        if (this.isRecipeView) return this.has('center', 'demoAgentforceBrief');
        return false;
    }
    get showCrossSell() {
        if (this.isFocus('insights')) return true;
        if (this.isRecipeView) return this.has('center', 'demoCrossSellInsights');
        return false;
    }
    get showNba() {
        if (this.isFocus('nbas')) return true;
        if (this.isRecipeView) return this.has('center', 'demoNextBestActions') || this.has('rightRail', 'demoNextBestActions') || this.has('leftRail', 'demoNextBestActions');
        return false;
    }
    get showTimeline() {
        if (this.isFocus('activities')) return true;
        if (this.isRecipeView) return this.has('rightRail', 'demoActivityTimeline');
        return false;
    }
    get showLikelihood() {
        if (this.isFocus('story')) return true;  // likelihood scores live in Story tab
        if (this.isRecipeView) return this.has('rightRail', 'demoLikelihoodScoreCard');
        return false;
    }
    get showJourneys() {
        if (this.isFocus('journeys')) return true;
        if (this.isRecipeView) return this.has('rightRail', 'demoActiveJourneyTracker');
        return false;
    }
    get showKpiRow() {
        if (this.isFocus('kpis')) return true;
        if (this.isRecipeView) return this.has('center', 'demoKpiStatRow') || this.has('leftRail', 'demoKpiStatRow') || this.has('rightRail', 'demoKpiStatRow');
        return false;
    }
    get showAlerts() {
        if (this.isFocus('alerts')) return true;
        if (this.isRecipeView) return this.has('center', 'demoAiInsightsAlerts') || this.has('leftRail', 'demoAiInsightsAlerts') || this.has('rightRail', 'demoAiInsightsAlerts');
        return false;
    }

    isFocus(...keys) {
        return keys.includes(this.focus);
    }
    get isRecipeView() {
        return !this.focus || this.focus === 'recipe';
    }

    applyTheme() {
        const t = this._bundle && this._bundle.theme;
        if (!t) return;
        const host = this.template.host;
        if (t.Primary_Color__c) host.style.setProperty('--demo-primary', t.Primary_Color__c);
        if (t.Accent_Color__c) host.style.setProperty('--demo-accent', t.Accent_Color__c);
        const bg = (t.Header_Style__c === 'Solid')
            ? (t.Primary_Color__c || '#0070d2')
            : (t.Background_Gradient__c || 'linear-gradient(135deg,#032d60,#0070d2)');
        host.style.setProperty('--demo-bg-gradient', bg);

        // Derive foreground color from the effective header background so
        // light themes (white / off-white gradients) render dark text and
        // dark themes render white text. `isLight()` samples the gradient's
        // first hex stop as an approximation.
        const sample = this._pickSample(t);
        const light = this._isLight(sample);
        host.style.setProperty('--demo-fg', light ? '#181818' : '#ffffff');
        host.style.setProperty('--demo-fg-muted', light ? 'rgba(0,0,0,0.65)' : 'rgba(255,255,255,0.75)');
        host.style.setProperty('--demo-fg-divider', light ? 'rgba(0,0,0,0.12)' : 'rgba(255,255,255,0.15)');
        host.style.setProperty('--demo-fg-chip-bg', light ? 'rgba(0,0,0,0.06)' : 'rgba(255,255,255,0.08)');
        host.style.setProperty('--demo-fg-chip-border', light ? 'rgba(0,0,0,0.18)' : 'rgba(255,255,255,0.22)');

        // Second luminance check: the badge sits on top of --demo-primary, not
        // on the gradient. Compute a separate fg for anything primary-colored
        // (badge, propensity dot fills, etc.) so yellow primaries get dark text.
        const primaryLight = this._isLight(t.Primary_Color__c || '#0070d2');
        host.style.setProperty('--demo-primary-fg', primaryLight ? '#181818' : '#ffffff');
    }
    _pickSample(t) {
        if (t.Header_Style__c === 'Solid') return t.Primary_Color__c || '#0070d2';
        const m = /#([0-9a-fA-F]{6})/.exec(t.Background_Gradient__c || '');
        return m ? `#${m[1]}` : (t.Primary_Color__c || '#0070d2');
    }
    _isLight(hex) {
        if (!hex || hex[0] !== '#') return false;
        let h = hex.slice(1);
        if (h.length === 3) h = h.split('').map((c) => c + c).join('');
        const r = parseInt(h.slice(0, 2), 16);
        const g = parseInt(h.slice(2, 4), 16);
        const b = parseInt(h.slice(4, 6), 16);
        const lum = (0.299 * r + 0.587 * g + 0.114 * b) / 255;
        return lum > 0.65;
    }
}
