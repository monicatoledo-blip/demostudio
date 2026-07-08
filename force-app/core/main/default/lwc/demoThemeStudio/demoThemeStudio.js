import { LightningElement, api, wire, track } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getTheme from '@salesforce/apex/DemoStudioService.getTheme';
import saveTheme from '@salesforce/apex/DemoStudioService.saveTheme';
import scrapeBrand from '@salesforce/apex/BrandScraper.scrape';
import { extractDominantColors } from 'c/demoLogoColorExtractor';

const HEADER_STYLES = ['Gradient', 'Solid'];

const GRADIENT_PRESETS = [
    { label: 'Cumulus Navy → Blue', start: '#0A1F44', end: '#1C3B7B' },
    { label: 'Salesforce Blue',     start: '#032D60', end: '#0070D2' },
    { label: 'Emerald / Teal',      start: '#064E3B', end: '#0F766E' },
    { label: 'Sunset Amber',        start: '#7C2D12', end: '#F97316' },
    { label: 'Charcoal → Slate',    start: '#111827', end: '#374151' },
    { label: 'Rose → Berry',        start: '#9F1239', end: '#DB2777' },
    { label: 'Deep Purple',         start: '#2E1065', end: '#6D28D9' },
    { label: 'White / Light',       start: '#FFFFFF', end: '#F1F5F9' },
    { label: 'Off-White Warm',      start: '#FDFBF7', end: '#F5EFE6' }
];

// Known-safe hosts that already ship with the DemoStudio CSP allowlist.
// Keep this in sync with force-app/core/main/default/cspTrustedSites/*.cspTrustedSite-meta.xml
const PRE_ALLOWED_HOSTS = new Set([
    'randomuser.me',
    'images.unsplash.com',
    'www.gravatar.com',
    'logo.clearbit.com',
    'icons.duckduckgo.com'
]);

function buildGradient(angle, start, end) {
    return `linear-gradient(${angle}deg,${start} 0%,${end} 100%)`;
}

// Parse "linear-gradient(135deg,#xxx 0%,#yyy 100%)" back into {angle,start,end}
function parseGradient(g) {
    if (!g) return { angle: 135, start: '#0A1F44', end: '#1C3B7B' };
    const m = /linear-gradient\(\s*(\d+)deg\s*,\s*(#[0-9a-fA-F]{3,8})[^,]*,\s*(#[0-9a-fA-F]{3,8})/.exec(g);
    if (!m) return { angle: 135, start: '#0A1F44', end: '#1C3B7B' };
    return { angle: parseInt(m[1], 10), start: m[2], end: m[3] };
}

export default class DemoThemeStudio extends LightningElement {
    @api recordId;

    @track working;
    @track gradientAngle = 135;
    @track gradientStart = '#0A1F44';
    @track gradientEnd = '#1C3B7B';
    @track aiQuery = '';
    @track aiBusy = false;
    @track aiNote = '';
    @track colorSampleBusy = false;
    wiredResult;
    isSaving = false;
    isDirty = false;

    acceptedLogoFormats = ['.png', '.jpg', '.jpeg', '.gif', '.svg', '.webp'];

    helpSteps = [
        { title: 'Name the Theme', desc: 'Pick a name that identifies the customer or brand (e.g. "Cumulus Bank", "Acme Wealth").' },
        { title: 'Choose colors', desc: 'Primary is the accent color (buttons, badges, ring). Accent is a secondary tone used on chips and icon backgrounds.' },
        { title: 'Pick a background', desc: 'Header Style = Solid uses the Primary color as the background. Gradient gives you an angle slider + Start/End colors, or pick a preset chip.' },
        { title: 'Add the logo', desc: 'Paste a URL to a hosted logo, or upload an image directly. If the URL is on a new host, a "Copy CSP metadata" button appears — copy that snippet and deploy it once to allow the domain.' },
        { title: 'Save', desc: 'Save persists the theme. Any Persona using this Theme instantly picks up the new colors and logo.' }
    ];

    @wire(getTheme, { themeId: '$recordId' })
    wired(result) {
        this.wiredResult = result;
        if (result.data) {
            this.working = { ...result.data };
            const parsed = parseGradient(this.working.Background_Gradient__c);
            this.gradientAngle = parsed.angle;
            this.gradientStart = parsed.start;
            this.gradientEnd = parsed.end;
            this.isDirty = false;
        }
    }

    get theme() { return this.working || {}; }

    get headerStyleOptions() {
        return HEADER_STYLES.map((v) => ({ label: v, value: v }));
    }

    get gradientPresetOptions() {
        const current = this.theme.Background_Gradient__c;
        return GRADIENT_PRESETS.map((g) => {
            const value = buildGradient(135, g.start, g.end);
            return {
                label: g.label,
                value,
                start: g.start,
                end: g.end,
                swatchStyle: `background:${value};`,
                styleAttr: current === value ? 'outline:2px solid var(--demo-primary);outline-offset:1px;' : ''
            };
        });
    }

    get primaryColor()   { return this.theme.Primary_Color__c   || '#0070d2'; }
    get accentColor()    { return this.theme.Accent_Color__c    || '#032d60'; }
    get headerStyle()    { return this.theme.Header_Style__c    || 'Gradient'; }
    get isSolid()        { return this.headerStyle === 'Solid'; }

    get backgroundCss() {
        if (this.isSolid) return this.primaryColor;
        return this.theme.Background_Gradient__c || buildGradient(this.gradientAngle, this.gradientStart, this.gradientEnd);
    }

    get logoUrlField() { return this.theme.Logo_URL__c || ''; }

    get logoSrc() {
        if (this.logoUrlField) return this.logoUrlField;
        if (this.theme.Logo_Static_Resource__c) return `/resource/${this.theme.Logo_Static_Resource__c}`;
        return null;
    }
    get hasLogo() { return !!this.logoSrc; }

    // Cascade: primary URL (usually DuckDuckGo or an uploaded file) → Clearbit
    //          → give up (broken img; auto-fill can be re-run with a different domain).
    // Stage 0 = whatever's in Logo_URL__c. Stage 1 = swap to Clearbit for the
    // same domain. Stage 2 = null (img hides).
    logoFallbackStage = 0;
    get effectiveLogoSrc() {
        const src = this.logoSrc;
        if (!src) return null;
        if (this.logoFallbackStage === 0) return src;
        if (this.logoFallbackStage === 1) {
            // Extract domain from either provider's URL, or from the user's URL host.
            const ddgMatch = /icons\.duckduckgo\.com\/ip3\/([^/?]+?)(?:\.ico)?$/.exec(src);
            const cbMatch  = /logo\.clearbit\.com\/([^/?]+)/.exec(src);
            let domain = null;
            if (ddgMatch) domain = ddgMatch[1];
            else if (cbMatch) domain = cbMatch[1];
            else {
                try { domain = new URL(src).host; } catch (e) { /* ignore */ }
            }
            if (!domain) return null;
            // If we started at DuckDuckGo, try Clearbit. If we started at Clearbit
            // (or a user URL), try DuckDuckGo.
            if (/icons\.duckduckgo\.com/.test(src)) return `https://logo.clearbit.com/${domain}`;
            return `https://icons.duckduckgo.com/ip3/${domain}.ico`;
        }
        return null;
    }
    handleLogoLoadError() {
        if (this.logoFallbackStage < 2) this.logoFallbackStage++;
    }

    handleLogoUploaded(e) {
        const files = e.detail.files || [];
        if (!files.length) return;
        const cv = files[0].contentVersionId || files[0].contentBodyId;
        const url = `/sfc/servlet.shepherd/version/download/${cv}`;
        this.working = { ...this.working, Logo_URL__c: url };
        this.isDirty = true;
        this.logoFallbackStage = 0; // uploaded a real file — start the cascade over
    }

    // CSP hint for URL logos
    get cspWarningInfo() {
        if (!this.logoUrlField) return null;
        let host;
        try { host = new URL(this.logoUrlField).host; } catch (e) { return null; }
        if (!host || PRE_ALLOWED_HOSTS.has(host)) return null;
        return {
            host,
            sfdxCommand: this.buildCspCommand(host)
        };
    }
    get needsCspHint() { return !!this.cspWarningInfo; }
    get cspHost() { return this.cspWarningInfo ? this.cspWarningInfo.host : ''; }
    get cspCommand() { return this.cspWarningInfo ? this.cspWarningInfo.sfdxCommand : ''; }

    buildCspCommand(host) {
        const safe = host.replace(/[^a-z0-9]/gi, '_');
        return `# Save as force-app/core/main/default/cspTrustedSites/${safe}.cspTrustedSite-meta.xml then \`sf project deploy start\`
<?xml version="1.0" encoding="UTF-8"?>
<CspTrustedSite xmlns="http://soap.sforce.com/2006/04/metadata">
  <endpointUrl>https://${host}</endpointUrl>
  <isActive>true</isActive>
  <isApplicableToImgSrc>true</isApplicableToImgSrc>
</CspTrustedSite>`;
    }

    // Foreground derivation: light gradients get dark text, dark gradients white.
    get _sampleHex() {
        if (this.isSolid) return this.primaryColor;
        const m = /#([0-9a-fA-F]{6})/.exec(this.theme.Background_Gradient__c || '');
        if (m) return `#${m[1]}`;
        // Fallback: use gradient start
        return this.gradientStart || this.primaryColor;
    }
    get _isLightBg() {
        const hex = this._sampleHex;
        if (!hex || hex[0] !== '#') return false;
        let h = hex.slice(1);
        if (h.length === 3) h = h.split('').map((c) => c + c).join('');
        const r = parseInt(h.slice(0, 2), 16);
        const g = parseInt(h.slice(2, 4), 16);
        const b = parseInt(h.slice(4, 6), 16);
        return ((0.299 * r + 0.587 * g + 0.114 * b) / 255) > 0.65;
    }
    get _fgVars() {
        const l = this._isLightBg;
        return [
            `--demo-fg:${l ? '#181818' : '#ffffff'}`,
            `--demo-fg-muted:${l ? 'rgba(0,0,0,0.65)' : 'rgba(255,255,255,0.75)'}`,
            `--demo-fg-divider:${l ? 'rgba(0,0,0,0.12)' : 'rgba(255,255,255,0.15)'}`,
            `--demo-fg-chip-bg:${l ? 'rgba(0,0,0,0.06)' : 'rgba(255,255,255,0.18)'}`,
            `--demo-fg-chip-border:${l ? 'rgba(0,0,0,0.18)' : 'rgba(255,255,255,0.22)'}`
        ].join(';');
    }

    // Live preview styles
    get previewGradientStyle() { return `background:${this.backgroundCss};`; }
    get miniCardStyle() { return `background:${this.backgroundCss}; ${this._fgVars};`; }
    get miniBadgeStyle() {
        // Match the same luminance flip we use on the record page: light
        // primaries (yellow, off-white) get dark text; dark primaries stay white.
        const l = this._isLightBadgeBg;
        return `background:${this.primaryColor}; color:${l ? '#181818' : '#ffffff'};`;
    }
    get _isLightBadgeBg() {
        const hex = this.primaryColor;
        if (!hex || hex[0] !== '#') return false;
        let h = hex.slice(1);
        if (h.length === 3) h = h.split('').map((c) => c + c).join('');
        const r = parseInt(h.slice(0, 2), 16);
        const g = parseInt(h.slice(2, 4), 16);
        const b = parseInt(h.slice(4, 6), 16);
        return ((0.299 * r + 0.587 * g + 0.114 * b) / 255) > 0.65;
    }
    get primarySwatchStyle() { return `background:${this.primaryColor};`; }
    get accentSwatchStyle()  { return `background:${this.accentColor};`; }

    get saveDisabled() { return this.isSaving || !this.isDirty; }
    get saveLabel() { return this.isSaving ? 'Saving…' : (this.isDirty ? 'Save Changes' : 'Saved'); }
    get gradientAngleLabel() { return `${this.gradientAngle}°`; }

    handleFieldChange(e) {
        const field = e.target.dataset.field;
        const value = e.detail.value !== undefined ? e.detail.value : e.target.value;
        this.working = { ...this.working, [field]: value };
        this.isDirty = true;
        // If the user just changed the logo URL, reset the cascade so we try
        // the new URL from stage 0.
        if (field === 'Logo_URL__c') this.logoFallbackStage = 0;
    }

    handleColorInput(e) {
        const field = e.target.dataset.field;
        this.working = { ...this.working, [field]: e.target.value };
        this.isDirty = true;
    }

    handleGradientAngle(e) {
        this.gradientAngle = parseInt(e.target.value, 10);
        this.syncGradientToTheme();
    }
    handleGradientStart(e) {
        this.gradientStart = e.target.value;
        this.syncGradientToTheme();
    }
    handleGradientEnd(e) {
        this.gradientEnd = e.target.value;
        this.syncGradientToTheme();
    }

    syncGradientToTheme() {
        this.working = {
            ...this.working,
            Background_Gradient__c: buildGradient(this.gradientAngle, this.gradientStart, this.gradientEnd)
        };
        this.isDirty = true;
    }

    handlePresetClick(e) {
        this.gradientStart = e.currentTarget.dataset.start;
        this.gradientEnd = e.currentTarget.dataset.end;
        this.gradientAngle = 135;
        this.syncGradientToTheme();
    }

    // ----- AI brand auto-fill -----
    handleAiQueryChange(e) { this.aiQuery = e.target.value; this.aiNote = ''; }
    handleAiKey(e) {
        if (e.key === 'Enter' && this.aiQuery && this.aiQuery.trim()) {
            e.preventDefault();
            this.handleBrandScrape();
        }
    }

    async handleBrandScrape() {
        const q = (this.aiQuery || '').trim();
        if (!q) return;
        this.aiBusy = true;
        this.aiNote = '';
        try {
            const r = await scrapeBrand({ query: q });
            if (!r) {
                this.aiNote = 'No response from Einstein.';
                return;
            }
            // Apply what came back into the working theme. User can still edit any field after.
            const next = { ...(this.working || {}) };
            if (r.brandName) next.Name = r.brandName;
            if (r.primaryColor) next.Primary_Color__c = r.primaryColor;
            if (r.accentColor) next.Accent_Color__c = r.accentColor;
            if (r.gradientCss) {
                next.Background_Gradient__c = r.gradientCss;
                // Sync sliders + swatches
                if (r.primaryColor) this.gradientStart = r.primaryColor;
                if (r.accentColor)  this.gradientEnd   = r.accentColor;
                this.gradientAngle = 135;
            }
            if (r.logoUrl) next.Logo_URL__c = r.logoUrl;
            this.working = next;
            this.isDirty = true;
            this.logoFallbackStage = 0; // fresh URL — start the cascade over

            // Now try to derive colors from the ACTUAL logo pixels. LLM color
            // guesses miss (Edward Jones = yellow/black, not maroon). Pixel
            // sampling is factual. If it fails (tainted canvas, timeout,
            // monochrome favicon), we silently keep the LLM's colors.
            if (r.logoUrl) {
                this._deriveColorsFromLogo(r.logoUrl, { silent: true });
            }

            const parts = [];
            if (r.brandName) parts.push(r.brandName);
            if (r.primaryColor) parts.push(r.primaryColor);
            if (r.accentColor) parts.push(r.accentColor);
            this.aiNote = 'Filled: ' + parts.join(' · ') + (r.note ? ' — ' + r.note : '');
            this.dispatchEvent(new ShowToastEvent({
                title: 'Brand auto-filled',
                message: r.brandName || 'Colors and logo applied. Tweak anything, then Save.',
                variant: 'success'
            }));
        } catch (err) {
            this.aiNote = 'Lookup failed: ' + ((err && err.body && err.body.message) || err.message || 'Unknown error');
        } finally {
            this.aiBusy = false;
        }
    }

    // ----- Derive colors from the actual logo image -----

    // Manual button: samples the currently-loaded logo. Used when the user
    // uploaded their own file OR wants to redo extraction after Auto-fill.
    async handleDeriveColors() {
        const src = this.logoSrc;
        if (!src) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'No logo loaded',
                message: 'Run Auto-fill or upload a logo first.',
                variant: 'warning'
            }));
            return;
        }
        await this._deriveColorsFromLogo(src, { silent: false });
    }

    async _deriveColorsFromLogo(url, options) {
        const silent = options && options.silent;
        this.colorSampleBusy = true;
        try {
            const colors = await extractDominantColors(url);
            if (!colors) {
                if (!silent) {
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'Could not extract colors',
                        message: 'The logo may be too small, monochrome, or CORS-blocked. Try a different logo.',
                        variant: 'warning'
                    }));
                }
                return;
            }
            const next = { ...(this.working || {}) };
            next.Primary_Color__c = colors.primary;
            next.Accent_Color__c = colors.accent;
            next.Background_Gradient__c = `linear-gradient(135deg, ${colors.primary} 0%, ${colors.accent} 100%)`;
            this.working = next;
            this.gradientStart = colors.primary;
            this.gradientEnd = colors.accent;
            this.gradientAngle = 135;
            this.isDirty = true;
            this.aiNote = `Colors derived from logo pixels: ${colors.primary} + ${colors.accent}`;
            if (!silent) {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Colors updated from logo',
                    message: `Primary ${colors.primary} · Accent ${colors.accent}`,
                    variant: 'success'
                }));
            }
        } catch (e) {
            if (!silent) {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Color extraction failed',
                    message: e.message || 'Unknown error',
                    variant: 'error'
                }));
            }
        } finally {
            this.colorSampleBusy = false;
        }
    }

    handleCopyCsp() {
        const cmd = this.cspCommand;
        if (!cmd) return;
        // Fallback for LWC: use the Clipboard API if available
        if (navigator && navigator.clipboard) {
            navigator.clipboard.writeText(cmd);
        }
        this.dispatchEvent(new ShowToastEvent({
            title: 'CSP snippet copied',
            message: `Add ${this.cspHost} to CSP Trusted Sites, then paste this SFDX metadata and deploy.`,
            variant: 'success'
        }));
    }

    async handleSave() {
        this.isSaving = true;
        try {
            await saveTheme({ payloadJson: JSON.stringify(this.working) });
            await refreshApex(this.wiredResult);
            this.isDirty = false;
            this.dispatchEvent(new ShowToastEvent({
                title: 'Theme saved',
                message: `${this.working.Name || 'Theme'} updated.`,
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
            this.working = { ...this.wiredResult.data };
            const parsed = parseGradient(this.working.Background_Gradient__c);
            this.gradientAngle = parsed.angle;
            this.gradientStart = parsed.start;
            this.gradientEnd = parsed.end;
            this.isDirty = false;
        }
    }
}
