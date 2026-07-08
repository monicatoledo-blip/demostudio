import { LightningElement, api, wire } from 'lwc';
import getPersonaBundleForContact from '@salesforce/apex/DemoStudioService.getPersonaBundleForContact';
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

// Default when a persona has no saved recipe. Ships the full experience so
// a freshly-assigned persona never renders as a nearly-blank page. Users
// can trim/reorder in Persona Studio → Recipe.
const DEFAULT_RECIPE = {
    leftRail: [{ component: 'demoUnifiedProfileHeader' }],
    center: [
        { component: 'demoAgentforceBrief' },
        { component: 'demoCrossSellInsights' },
        { component: 'demoNextBestActions' }
    ],
    rightRail: [
        { component: 'demoLikelihoodScoreCard' },
        { component: 'demoActivityTimeline' },
        { component: 'demoActiveJourneyTracker' }
    ]
};

const COMPONENT_FLAGS = {
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
        .map((entry) => entry && entry.component)
        .filter((name) => !!COMPONENT_FLAGS[name])
        .map((name) => {
            const flags = {};
            for (const k of Object.values(COMPONENT_FLAGS)) flags[k] = false;
            flags[COMPONENT_FLAGS[name]] = true;
            return { name, ...flags };
        });
}

export default class DemoUnifiedProfileShell extends LightningElement {
    @api recordId;

    bundle;
    error;

    @wire(getPersonaBundleForContact, { contactId: '$recordId' })
    wiredBundle({ data, error }) {
        if (data) {
            this.bundle = data;
            this.error = undefined;
            this.applyTheme();
        } else if (error) {
            this.bundle = undefined;
            this.error = error;
        }
    }

    get hasPersona() {
        return !!(this.bundle && this.bundle.persona);
    }

    get recipe() {
        if (!this.hasPersona) return DEFAULT_RECIPE;
        const raw = this.bundle.persona.Component_Recipe__c;
        if (!raw) return DEFAULT_RECIPE;
        try {
            const parsed = JSON.parse(raw);
            return {
                leftRail: parsed.leftRail || [],
                center: parsed.center || [],
                rightRail: parsed.rightRail || []
            };
        } catch (e) {
            return DEFAULT_RECIPE;
        }
    }

    get leftRailComponents() { return decorateColumn(this.recipe.leftRail); }
    get centerComponents() { return decorateColumn(this.recipe.center); }
    get rightRailComponents() { return decorateColumn(this.recipe.rightRail); }

    // Real persona fields always win; anything left blank falls back to
    // a sensible demo default so shipped pages never look empty.
    get persona() { return withPersonaDefaults(this.bundle && this.bundle.persona); }
    get theme() { return this.bundle && this.bundle.theme; }
    get identities() { return withIdentitiesDefault(this.bundle && this.bundle.identities); }
    get insights() { return withInsightsDefault(this.bundle && this.bundle.insights); }
    get activities() { return withActivitiesDefault(this.bundle && this.bundle.activities); }
    get journeys() { return withJourneysDefault(this.bundle && this.bundle.journeys); }
    get kpis()     { return withKpisDefault(this.bundle && this.bundle.kpis); }
    get alerts()   { return withAlertsDefault(this.bundle && this.bundle.alerts); }
    get segments() { return withSegmentsDefault(this.bundle && this.bundle.segments); }
    get nbas()     { return withNbasDefault(this.bundle && this.bundle.nbas); }

    applyTheme() {
        const theme = this.theme;
        if (!theme) return;
        const host = this.template.host;
        if (theme.Primary_Color__c) host.style.setProperty('--demo-primary', theme.Primary_Color__c);
        if (theme.Accent_Color__c) host.style.setProperty('--demo-accent', theme.Accent_Color__c);
        const bg = (theme.Header_Style__c === 'Solid')
            ? (theme.Primary_Color__c || '#0070d2')
            : (theme.Background_Gradient__c || 'linear-gradient(135deg,#032d60,#0070d2)');
        host.style.setProperty('--demo-bg-gradient', bg);

        const sample = this.pickSampleColor(theme);
        const fg = this.isLight(sample) ? '#181818' : '#ffffff';
        const fgMuted = this.isLight(sample) ? 'rgba(0,0,0,0.65)' : 'rgba(255,255,255,0.75)';
        host.style.setProperty('--demo-fg', fg);
        host.style.setProperty('--demo-fg-muted', fgMuted);

        // Separate luminance check for --demo-primary (badge / propensity dot)
        // so a yellow brand primary gets dark text on the pill.
        const primaryLight = this.isLight(theme.Primary_Color__c || '#0070d2');
        host.style.setProperty('--demo-primary-fg', primaryLight ? '#181818' : '#ffffff');
    }

    pickSampleColor(theme) {
        if (theme.Header_Style__c === 'Solid') return theme.Primary_Color__c || '#0070d2';
        const m = /#([0-9a-fA-F]{6})/.exec(theme.Background_Gradient__c || '');
        return m ? `#${m[1]}` : (theme.Primary_Color__c || '#0070d2');
    }

    isLight(hex) {
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
