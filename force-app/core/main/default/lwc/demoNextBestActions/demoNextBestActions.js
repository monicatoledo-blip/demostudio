import { LightningElement, api } from 'lwc';

// Category → shipped static-resource illustration. When a user-supplied
// Image_URL is blank or fails to load, we fall back to a category-appropriate
// illustration instead of a big letter. Values match the Category__c
// picklist emitted by demoPersonaStudio.defaultRow('nbas') and archetype JSON.
const CATEGORY_FALLBACK_RESOURCES = {
    'Direct Action':     '/resource/NBA_Fallback_Direct_Action',
    'Cash Optimization': '/resource/NBA_Fallback_Cash_Optimization',
    'Cross-Sell':        '/resource/NBA_Fallback_Cross_Sell',
    'Next-Best-Action':  '/resource/NBA_Fallback_Cross_Sell',
    'Retention':         '/resource/NBA_Fallback_Retention',
    'Risk':              '/resource/NBA_Fallback_Risk'
};
const GENERIC_FALLBACK_RESOURCE = '/resource/NBA_Fallback_Generic';

// Last-resort background if even the static-resource illustration fails
// (unlikely — same-origin, always deployed). The letter tile takes over here.
const AVATAR_FALLBACK_INITIAL_BG = 'linear-gradient(135deg,#0A1F44,#1F5FBF)';

export default class DemoNextBestActions extends LightningElement {
    @api nbas;

    // Two-tier failure tracking. _failedImages fires when the user-supplied
    // URL fails; the row then tries its category illustration. If THAT also
    // fails (e.g. resource missing in a stripped-down org), _failedFallbacks
    // flips and the letter tile takes over.
    _failedImages = {};
    _failedFallbacks = {};

    get hasNbas() {
        return this.decoratedNbas.length > 0;
    }

    get decoratedNbas() {
        return (this.nbas || []).map((r, i) => {
            const key = r.Id || `nba-${i}`;
            const userUrl = (r.Image_URL__c && String(r.Image_URL__c).trim()) || '';
            const userFailed = !!this._failedImages[key];
            const fallbackFailed = !!this._failedFallbacks[key];
            const fallbackUrl = CATEGORY_FALLBACK_RESOURCES[r.Category__c] || GENERIC_FALLBACK_RESOURCE;

            // Which src to render right now.
            let effectiveUrl = '';
            let stage = 'letter';
            if (userUrl && !userFailed) {
                effectiveUrl = userUrl;
                stage = 'user';
            } else if (!fallbackFailed) {
                effectiveUrl = fallbackUrl;
                stage = 'fallback';
            }
            const initial = ((r.Title__c || '?').trim()[0] || '?').toUpperCase();
            return {
                ...r,
                _key: key,
                _hasImage: stage !== 'letter',
                _stage: stage,
                _effectiveUrl: effectiveUrl,
                _initial: initial,
                _fallbackStyle: `background:${AVATAR_FALLBACK_INITIAL_BG};`,
                _ctaLabel: r.CTA_Label__c || 'Take Action'
            };
        });
    }

    // Called by <img onerror>. We look up which tier is currently being shown
    // via dataset.stage and mark THAT tier as failed, so the getter re-runs
    // and swaps to the next tier down.
    handleImageError(e) {
        const key = e.currentTarget.dataset.key;
        const stage = e.currentTarget.dataset.stage;
        if (!key) return;
        if (stage === 'user') {
            this._failedImages = { ...this._failedImages, [key]: true };
        } else if (stage === 'fallback') {
            this._failedFallbacks = { ...this._failedFallbacks, [key]: true };
        }
    }
}
