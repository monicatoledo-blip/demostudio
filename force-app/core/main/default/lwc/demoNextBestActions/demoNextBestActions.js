import { LightningElement, api } from 'lwc';
import { pickImageForContext } from 'c/demoNbaImageLibrary';

// SVG static-resource illustrations shipped in the org. Used as the tier
// BELOW the curated Cloudinary library — kicks in only if the library image
// itself fails to load (offline, CSP blocked, etc). Same category keys as
// Category__c picklist.
const CATEGORY_FALLBACK_RESOURCES = {
    'Direct Action':     '/resource/NBA_Fallback_Direct_Action',
    'Cash Optimization': '/resource/NBA_Fallback_Cash_Optimization',
    'Cross-Sell':        '/resource/NBA_Fallback_Cross_Sell',
    'Next-Best-Action':  '/resource/NBA_Fallback_Cross_Sell',
    'Retention':         '/resource/NBA_Fallback_Retention',
    'Risk':              '/resource/NBA_Fallback_Risk'
};
const GENERIC_FALLBACK_RESOURCE = '/resource/NBA_Fallback_Generic';

// Absolute last-resort background if the letter tile takes over.
const AVATAR_FALLBACK_INITIAL_BG = 'linear-gradient(135deg,#0A1F44,#1F5FBF)';

export default class DemoNextBestActions extends LightningElement {
    @api nbas;

    // Three-tier failure tracking:
    //   user URL fails      -> _failedUser[key]      -> fall to library image
    //   library image fails -> _failedLibrary[key]   -> fall to SVG static resource
    //   SVG resource fails  -> _failedResource[key]  -> fall to letter tile
    _failedUser = {};
    _failedLibrary = {};
    _failedResource = {};

    get hasNbas() {
        return this.decoratedNbas.length > 0;
    }

    get decoratedNbas() {
        return (this.nbas || []).map((r, i) => {
            const key = r.Id || `nba-${i}`;
            const userUrl = (r.Image_URL__c && String(r.Image_URL__c).trim()) || '';
            const userFailed = !!this._failedUser[key];
            const libraryFailed = !!this._failedLibrary[key];
            const resourceFailed = !!this._failedResource[key];

            // Semantic pick from the Cloudinary library. Scores each library
            // image's description against the NBA's title + why-suggestion so
            // an NBA about student loans gets the student photo, not a random
            // cross-sell image. Deterministic — same NBA copy → same image.
            const libraryEntry = pickImageForContext(r.Category__c, {
                title: r.Title__c || key,
                why: r.Why_This_Suggestion__c,
                brand: r.Brand__c
            });
            const libraryUrl = libraryEntry ? libraryEntry.url : '';
            const resourceUrl = CATEGORY_FALLBACK_RESOURCES[r.Category__c] || GENERIC_FALLBACK_RESOURCE;

            // Walk down the tiers based on what has failed so far.
            let effectiveUrl = '';
            let stage = 'letter';
            if (userUrl && !userFailed) {
                effectiveUrl = userUrl;
                stage = 'user';
            } else if (libraryUrl && !libraryFailed) {
                effectiveUrl = libraryUrl;
                stage = 'library';
            } else if (!resourceFailed) {
                effectiveUrl = resourceUrl;
                stage = 'resource';
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

    // Called by <img onerror>. Look up which tier is currently being shown
    // via dataset.stage and mark THAT tier as failed, so the getter re-runs
    // and swaps to the next tier down.
    handleImageError(e) {
        const key = e.currentTarget.dataset.key;
        const stage = e.currentTarget.dataset.stage;
        if (!key) return;
        if (stage === 'user') {
            this._failedUser = { ...this._failedUser, [key]: true };
        } else if (stage === 'library') {
            this._failedLibrary = { ...this._failedLibrary, [key]: true };
        } else if (stage === 'resource') {
            this._failedResource = { ...this._failedResource, [key]: true };
        }
    }
}
