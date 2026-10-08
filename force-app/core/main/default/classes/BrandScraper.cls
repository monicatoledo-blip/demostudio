/**
 * AI-powered brand scraper for Brand Kit Studio.
 *
 * Takes a brand name or website URL, asks Einstein for the brand's
 * canonical primary + accent colors, and constructs a logo URL from
 * logo.clearbit.com/{domain} — a public endpoint that doesn't require
 * an API key.
 *
 * Trust Layer applies to the Einstein call. The Clearbit endpoint is
 * called only from the browser (image src), not from Apex — so no
 * callout / no named credential needed.
 */
public with sharing class BrandScraper {

    // logo.dev publishable token fallback. The authoritative value lives in
    // Demo_Studio_Config__mdt.Default.Logo_Dev_Token__c (ships with the package
    // and is overridable per-org without a code change). This constant only
    // kicks in if that record didn't come across in a deployment. Publishable
    // (pk_) tokens are client-side keys, not secrets.
    @TestVisible private static final String LOGODEV_FALLBACK_TOKEN = 'pk_C7vSxvfhToSx8jrQYfebCg';

    public class BrandResult {
        @AuraEnabled public String brandName;
        @AuraEnabled public String primaryColor;
        @AuraEnabled public String accentColor;
        @AuraEnabled public String gradientCss;
        @AuraEnabled public String logoUrl;  // high-res primary logo (email header)
        @AuraEnabled public String iconUrl;  // small square icon (agent avatar / footer)
        @AuraEnabled public String domain;
        @AuraEnabled public String note;
    }

    @AuraEnabled
    public static BrandResult scrape(String query) {
        BrandResult r = new BrandResult();
        if (String.isBlank(query)) {
            r.note = 'Please provide a brand name or website URL.';
            return r;
        }
        String prompt = buildPrompt(query.trim());
        String jsonBody;
        try {
            jsonBody = EinsteinProvider.callAndExtractJson(prompt);
        } catch (Exception e) {
            r.note = 'Brand lookup failed: ' + e.getMessage();
            return r;
        }
        try {
            Map<String, Object> parsed = (Map<String, Object>) JSON.deserializeUntyped(jsonBody);
            r.brandName    = String.valueOf(parsed.get('brandName'));
            r.primaryColor = normalizeHex(String.valueOf(parsed.get('primaryColor')));
            r.accentColor  = normalizeHex(String.valueOf(parsed.get('accentColor')));
            r.domain       = String.valueOf(parsed.get('domain'));
            r.note         = String.valueOf(parsed.get('note'));
            if (String.isNotBlank(r.primaryColor) && String.isNotBlank(r.accentColor)) {
                r.gradientCss = 'linear-gradient(135deg, ' + r.primaryColor + ' 0%, ' + r.accentColor + ' 100%)';
            }
            if (String.isNotBlank(r.domain)) {
                // High-res PRIMARY logo (email header) + small SECONDARY icon
                // (agent avatar / footer) from logo.dev when a publishable
                // token is configured; otherwise fall back to the DuckDuckGo
                // favicon so logos still appear with no token. The LWC caches
                // these through Cloudinary (so logo.dev is hit ~once per brand)
                // and applies an onerror cascade (logo.dev -> Clearbit ->
                // favicon -> colored initial tile), so logos keep working even
                // if a provider disappears.
                r.logoUrl = primaryLogoUrl(r.domain);
                r.iconUrl = iconLogoUrl(r.domain);
            }
        } catch (Exception e) {
            r.note = 'Could not parse brand response: ' + e.getMessage();
        }
        return r;
    }

    private static String buildPrompt(String query) {
        return
            'You are a brand identity lookup service. Given a brand name ' +
            'or website URL, return the brand\'s canonical visual identity ' +
            'as JSON only (no prose, no fences).\n\n' +
            'Query: ' + query + '\n\n' +
            'Return this shape exactly:\n' +
            '{\n' +
            '  "brandName": "the official brand name",\n' +
            '  "primaryColor": "#RRGGBB — the brand\'s SIGNATURE color, the one people associate with the logo",\n' +
            '  "accentColor":  "#RRGGBB — a DEEPER or DARKER shade of the primary, OR a genuinely different secondary from the brand\'s palette. Never white, never near-white, never a light gray unless the primary is genuinely dark navy/black.",\n' +
            '  "domain": "canonical primary domain, no protocol, no path (e.g. chase.com)",\n' +
            '  "note": "one short sentence naming your source or noting uncertainty"\n' +
            '}\n\n' +
            'Rules:\n' +
            '- Chase Bank: primary #117ACA (Chase blue), accent #0B5FAE (darker blue). NOT white.\n' +
            '- KeyBank: primary #C8102E (red), accent #0A1F44 (navy).\n' +
            '- Bank of America: primary #E31837 (red), accent #012169 (navy).\n' +
            '- Wells Fargo: primary #D71E28 (red), accent #FFCD41 (gold).\n' +
            '- IBM: primary #0F62FE, accent #002D9C.\n' +
            '- Salesforce: primary #00A1E0, accent #032D60.\n' +
            '- Use these when the query names those brands. For other well-known brands, use their canonical marketing colors.\n' +
            '- For unknown/fictional brands, invent TWO real colors from a plausible brand palette. The accent must be a real color that would appear on a marketing site (dark tone, deep secondary, or a signature complement). NEVER return #FFFFFF, #F0F0F0, #E5E5E5, or any near-white as an accent.\n' +
            '- The two colors should produce a visually rich gradient — different enough that you can see both stops, but from the same brand family (not "blue + orange" random pairings).\n' +
            '- Colors must be uppercase 7-character hex strings starting with #.\n' +
            '- domain must be lowercase, no https://, no trailing slash. Chase → chase.com. KeyBank → key.com.\n\n' +
            'JSON:';
    }

    // Test seam: when non-null, used verbatim ('' => treat as no token).
    @TestVisible private static String tokenOverride;

    // Resolve the logo.dev publishable token from config, falling back to the
    // packaged constant so SDOs work out of the box.
    private static String logoDevToken() {
        if (tokenOverride != null) {
            return String.isBlank(tokenOverride) ? null : tokenOverride.trim();
        }
        Demo_Studio_Config__mdt cfg = Demo_Studio_Config__mdt.getInstance('Default');
        String tok = (cfg == null) ? null : cfg.Logo_Dev_Token__c;
        if (String.isBlank(tok)) tok = LOGODEV_FALLBACK_TOKEN;
        return String.isBlank(tok) ? null : tok.trim();
    }

    private static final String DDG_FAVICON = 'https://icons.duckduckgo.com/ip3/';

    // High-res primary logo for the email header. 256px @2x = 512 physical px,
    // transparent PNG. Falls back to the DuckDuckGo favicon with no token.
    @TestVisible
    private static String primaryLogoUrl(String domain) {
        String tok = logoDevToken();
        if (String.isBlank(tok)) return DDG_FAVICON + domain + '.ico';
        return 'https://img.logo.dev/' + domain + '?token=' + tok +
               '&size=256&retina=true&format=png';
    }

    // Small square icon for agent avatars / footers. Falls back to the
    // DuckDuckGo favicon with no token.
    @TestVisible
    private static String iconLogoUrl(String domain) {
        String tok = logoDevToken();
        if (String.isBlank(tok)) return DDG_FAVICON + domain + '.ico';
        return 'https://img.logo.dev/' + domain + '?token=' + tok +
               '&size=96&format=png';
    }

    private static String normalizeHex(String h) {
        if (String.isBlank(h) || h == 'null') return null;
        String s = h.trim();
        if (!s.startsWith('#')) s = '#' + s;
        if (s.length() == 4) {
            // Expand #RGB → #RRGGBB
            s = '#' + s.substring(1,2).repeat(2) + s.substring(2,3).repeat(2) + s.substring(3,4).repeat(2);
        }
        return s.toUpperCase();
    }
}
