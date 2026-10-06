/**
 * Backs the WebExperiencePreview Visualforce page — the live, branded Adaptive Web
 * preview for a Demo_Story__c, the native port of the Experience Generator adaptive
 * sim. It does NOT render the HTML itself. The ported EG content engine
 * (demoWebEngine static resource) runs client-side in the VF page and PREFERS live
 * DOM input .value over its formData param, so this controller only produces the
 * driver config: a `dom` map (shim <input> id -> value, the 126 content ids the
 * engine reads via getElementById) and a `form` map (the formData-carried keys:
 * colors, logo, hero/insight image urls, brand initials). The page builds hidden
 * inputs from `dom`, passes `form` as formData, runs the engine unmodified, and
 * drops the resolved HTML into a srcdoc iframe.
 *
 * Separate from StoryEmailPreviewController by design — the 2-way sims are untouched.
 */
public with sharing class WebExperiencePreviewController {

    // formData-carried keys (read from the engine's formData param, NOT getElementById).
    private static final Set<String> FORM_KEYS = new Set<String>{
        'adaptivePrimaryColor', 'adaptiveAccentColor', 'heroGradientColor', 'heroGradientColor2',
        'adaptiveBrandInitials', 'adaptiveColdHeroUrl', 'adaptiveHeroImageUrl', 'adaptiveNavLogoUrl',
        'adaptiveInsightImg1', 'adaptiveInsightImg2', 'adaptiveInsightImg3'
    };

    // Returned to the page as JSON: { dom: {...}, form: {...} }.
    public String getConfigJson() {
        String storyId = ApexPages.currentPage().getParameters().get('id');
        Map<String, Object> dom = new Map<String, Object>();
        Map<String, Object> form = new Map<String, Object>();
        if (String.isBlank(storyId)) {
            return JSON.serialize(new Map<String, Object>{ 'dom' => dom, 'form' => form });
        }

        Demo_Story__c s;
        for (Demo_Story__c r : [
            SELECT Id, Name, Brand__c, Industry__c, Primary_Color__c, Accent_Color__c,
                   Logo_URL__c, Brand_Domain__c, Persona__c, Config_JSON__c,
                   Brand_Kit__c, Brand_Kit__r.Name, Brand_Kit__r.Primary_Color__c,
                   Brand_Kit__r.Accent_Color__c, Brand_Kit__r.Logo_URL__c,
                   Brand_Kit__r.Secondary_Logo_URL__c
            FROM Demo_Story__c WHERE Id = :storyId LIMIT 1
        ]) { s = r; }
        if (s == null) {
            return JSON.serialize(new Map<String, Object>{ 'dom' => dom, 'form' => form });
        }

        // --- resolve brand: the linked Brand Kit (Demo_Theme__c) is the base; the
        //     record's own fields override it (lets an SE tweak a single value);
        //     Config_JSON overrides everything below. Mirrors the 2-way sims, so
        //     swapping the Brand Kit re-skins the site live.
        Demo_Theme__c kit = s.Brand_Kit__r;
        String brandName = coalesce(s.Brand__c, kit == null ? null : kit.Name);
        String primary   = coalesce(s.Primary_Color__c, kit == null ? null : kit.Primary_Color__c);
        String accent    = coalesce(s.Accent_Color__c, kit == null ? null : kit.Accent_Color__c);
        String logo      = coalesce(s.Logo_URL__c, kit == null ? null : kit.Logo_URL__c);

        putIf(dom, 'adaptiveBrandName', brandName);
        putIf(dom, 'adaptiveWebSubIndustry', industryKey(s.Industry__c));
        putIf(form, 'adaptivePrimaryColor', primary);
        putIf(form, 'adaptiveAccentColor', accent);
        putIf(form, 'adaptiveNavLogoUrl', logo);
        putIf(form, 'adaptiveBrandInitials', initials(brandName));
        // Hero gradient defaults to the brand's primary/accent when not overridden.
        putIf(form, 'heroGradientColor', primary);
        putIf(form, 'heroGradientColor2', accent);

        // --- persona (lookup) -> adaptivePersona* shim fields --------------------
        if (s.Persona__c != null) {
            for (Demo_Persona__c p : [
                SELECT Name, First_Name__c, Last_Name__c, Primary_Email__c, Primary_Phone__c, Company__c
                FROM Demo_Persona__c WHERE Id = :s.Persona__c LIMIT 1
            ]) {
                String first = String.isNotBlank(p.First_Name__c)
                    ? p.First_Name__c
                    : (p.Name != null ? p.Name.split(' ')[0] : null);
                putIf(dom, 'adaptivePersonaFirstName', first);
                putIf(dom, 'adaptivePersonaLastName', p.Last_Name__c);
                putIf(dom, 'adaptivePersonaEmail', p.Primary_Email__c);
                putIf(dom, 'adaptivePersonaPhone', p.Primary_Phone__c);
                putIf(dom, 'adaptivePersonaCompany', p.Company__c);
            }
        }

        // --- Config_JSON overrides win (SE edits + AI copy) ----------------------
        // Every key routes to form if it's a formData-carried key, else to the dom
        // shim. Blank values are skipped so the engine falls back to its per-industry
        // defaults for anything the SE hasn't set.
        if (String.isNotBlank(s.Config_JSON__c)) {
            try {
                Map<String, Object> cfg = (Map<String, Object>) JSON.deserializeUntyped(s.Config_JSON__c);
                for (String k : cfg.keySet()) {
                    Object v = cfg.get(k);
                    if (v == null || String.isBlank(String.valueOf(v))) continue;
                    if (FORM_KEYS.contains(k)) form.put(k, v);
                    else dom.put(k, v);
                }
            } catch (Exception e) { /* malformed config -> ignore, use field-derived drivers */ }
        }

        // The engine resolves [[BRAND_NAME]]/${brandName} (and persona/agent tokens)
        // from the formData arg, NOT the DOM shim (brandPlain = formData.adaptiveBrandName,
        // getAdaptivePersona checks formData first). So mirror the brand/agent/persona
        // values into `form` too — otherwise ${brandName} resolves to empty.
        for (String k : new List<String>{
            'adaptiveBrandName', 'adaptiveAgentName', 'adaptivePersonaFirstName',
            'adaptivePersonaLastName', 'adaptivePersonaEmail', 'adaptivePersonaPhone',
            'adaptivePersonaCompany', 'adaptivePersonaZip'
        }) {
            if (dom.containsKey(k) && !form.containsKey(k)) form.put(k, dom.get(k));
        }

        return JSON.serialize(new Map<String, Object>{ 'dom' => dom, 'form' => form });
    }

    private static void putIf(Map<String, Object> m, String k, String v) {
        if (String.isNotBlank(v)) m.put(k, v);
    }

    private static String coalesce(String a, String b) {
        return String.isNotBlank(a) ? a : b;
    }

    // Brand initials for the engine's avatar/placeholder (adaptiveBrandInitials).
    private static String initials(String brand) {
        if (String.isBlank(brand)) return null;
        List<String> parts = brand.trim().split('\\s+');
        String ini = '';
        for (String p : parts) {
            if (String.isNotBlank(p)) ini += p.substring(0, 1).toUpperCase();
            if (ini.length() >= 2) break;
        }
        return ini;
    }

    // Map a Demo_Story Industry__c picklist value to the engine's sub-industry key.
    // The adaptive-web engine ships only FINS sub-industries (retailBanking,
    // commercialBanking, wealthManagement, assetManagement, insurance), so non-FINS
    // verticals return null and the engine falls back to retailBanking. An explicit
    // Config_JSON 'adaptiveWebSubIndustry' always overrides this. (The per-industry
    // copy breadth is an engine limitation to revisit — e.g. a storefront sim in
    // Phase B for retail/commerce.)
    private static String industryKey(String industry) {
        if (String.isBlank(industry)) return null;
        String i = industry.toLowerCase();
        if (i.contains('wealth')) return 'wealthManagement';
        if (i.contains('asset')) return 'assetManagement';
        if (i.contains('commercial')) return 'commercialBanking';
        if (i.contains('insurance')) return 'insurance';
        if (i.contains('financial') || i.contains('bank')) return 'retailBanking';
        return null;
    }
}
