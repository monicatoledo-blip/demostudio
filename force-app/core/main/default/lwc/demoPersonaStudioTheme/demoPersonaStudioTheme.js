import { LightningElement, api, wire, track } from 'lwc';
import listThemes from '@salesforce/apex/DemoStudioService.listThemes';

export default class DemoPersonaStudioTheme extends LightningElement {
    @api theme;
    @api persona;

    @track availableThemes = [];
    themesLoadError;
    @track scope = 'mine'; // 'mine' | 'all'

    @wire(listThemes, { scope: '$scope' })
    wiredThemes({ data, error }) {
        if (data) {
            this.availableThemes = data;
        } else if (error) {
            this.themesLoadError = error.body ? error.body.message : String(error);
        }
    }

    get scopeOptions() {
        return [
            { label: 'Mine', value: 'mine' },
            { label: 'All',  value: 'all'  }
        ];
    }
    handleScopeChange(e) { this.scope = e.detail.value; }

    get themeName() {
        return (this.theme && this.theme.Name) || 'No Brand Kit assigned';
    }
    get primaryColor() { return (this.theme && this.theme.Primary_Color__c) || '#0176d3'; }
    get accentColor()  { return (this.theme && this.theme.Accent_Color__c)  || '#032d60'; }
    get gradient()     { return (this.theme && this.theme.Background_Gradient__c) || ''; }
    get logo()         {
        if (!this.theme) return '';
        if (this.theme.Logo_URL__c) return this.theme.Logo_URL__c;
        if (this.theme.Logo_Static_Resource__c) return `/resource/${this.theme.Logo_Static_Resource__c}`;
        return '';
    }

    get headerStyle()  { return (this.theme && this.theme.Header_Style__c) || 'Gradient'; }
    get isSolid()      { return this.headerStyle === 'Solid'; }
    get backgroundCss() {
        if (this.isSolid) return this.primaryColor;
        return this.gradient || 'linear-gradient(135deg,#032d60,#0070d2)';
    }
    get gradientStyle() { return `background:${this.backgroundCss};`; }
    get primarySwatchStyle() { return `background:${this.primaryColor};`; }
    get accentSwatchStyle() { return `background:${this.accentColor};`; }

    // Foreground vars inline so this mini-card doesn't rely on the parent
    // studio's applyTheme() running first (matters on first render before
    // the wire completes).
    get _sampleHex() {
        if (this.isSolid) return this.primaryColor;
        const m = /#([0-9a-fA-F]{6})/.exec(this.gradient || '');
        return m ? `#${m[1]}` : this.primaryColor;
    }
    get _isLight() {
        const hex = this._sampleHex;
        if (!hex || hex[0] !== '#') return false;
        let h = hex.slice(1);
        if (h.length === 3) h = h.split('').map((c) => c + c).join('');
        const r = parseInt(h.slice(0, 2), 16);
        const g = parseInt(h.slice(2, 4), 16);
        const b = parseInt(h.slice(4, 6), 16);
        return ((0.299 * r + 0.587 * g + 0.114 * b) / 255) > 0.65;
    }
    get miniCardStyle() {
        const l = this._isLight;
        return [
            `background:${this.backgroundCss}`,
            `--demo-fg:${l ? '#181818' : '#ffffff'}`,
            `--demo-fg-muted:${l ? 'rgba(0,0,0,0.65)' : 'rgba(255,255,255,0.75)'}`,
            `--demo-fg-divider:${l ? 'rgba(0,0,0,0.12)' : 'rgba(255,255,255,0.15)'}`,
            `--demo-fg-chip-bg:${l ? 'rgba(0,0,0,0.06)' : 'rgba(255,255,255,0.18)'}`,
            `--demo-fg-chip-border:${l ? 'rgba(0,0,0,0.18)' : 'rgba(255,255,255,0.22)'}`
        ].join(';') + ';';
    }
    get miniBadgeStyle() { return `background:${this.primaryColor}; color:#fff;`; }
    get hasLogo() { return !!this.logo; }

    get currentThemeId() {
        return (this.persona && this.persona.Theme__c) || '';
    }

    get themeOptions() {
        return (this.availableThemes || []).map((t) => ({ label: t.name, value: t.id }));
    }

    get themeChoices() {
        const currentId = this.currentThemeId;
        // Salesforce-blue fallback is intentionally last — we prefer to show
        // the gradient the user actually saved, even if Primary_Color__c is
        // null (a Chase kit auto-filled before we tightened extraction can
        // have null primary but a valid gradient string).
        const FALLBACK = '#0176d3';
        return (this.availableThemes || []).map((t) => {
            const isSolid = t.headerStyle === 'Solid';
            const effectiveBg = isSolid
                ? (t.primaryColor || t.backgroundGradient || FALLBACK)
                : (t.backgroundGradient || t.primaryColor || FALLBACK);
            return {
                id: t.id,
                name: t.name,
                primary: t.primaryColor || FALLBACK,
                accent: t.accentColor || '#032d60',
                gradient: effectiveBg,
                logoUrl: t.logoUrl || '',
                hasLogo: !!t.logoUrl,
                isActive: t.id === currentId,
                cardClass: t.id === currentId
                    ? 'theme-choice theme-choice--active'
                    : 'theme-choice',
                swatchStyle: `background:${effectiveBg};`
            };
        });
    }

    handleThemeSelect(e) {
        const themeId = e.currentTarget.dataset.themeId;
        if (!themeId || themeId === this.currentThemeId) return;
        const picked = (this.availableThemes || []).find((t) => t.id === themeId);
        this.dispatchEvent(new CustomEvent('change', {
            detail: {
                field: 'Theme__c',
                value: themeId,
                // Extra payload so the parent can swap the working theme object
                // immediately (avoids waiting on a Save → reload round-trip).
                themeSnapshot: picked ? {
                    Id: picked.id,
                    Name: picked.name,
                    Primary_Color__c: picked.primaryColor,
                    Accent_Color__c: picked.accentColor,
                    Background_Gradient__c: picked.backgroundGradient,
                    Header_Style__c: picked.headerStyle,
                    Logo_URL__c: picked.logoUrl
                } : null
            }
        }));
    }
}
