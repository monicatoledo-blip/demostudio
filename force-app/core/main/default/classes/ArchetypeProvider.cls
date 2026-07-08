/**
 * Deterministic fallback provider. Scores the brief against a curated
 * keyword list per archetype, returns the archetype's canned Payload_JSON__c.
 *
 * This is the original v1 DemoStudioPersonaGenerator logic, extracted into
 * its own class so it can serve as (a) a low-latency default, (b) a fallback
 * when EinsteinProvider errors, and (c) the answer for orgs without Einstein
 * Generative enabled.
 */
public with sharing class ArchetypeProvider implements IPersonaProvider {

    public DemoStudioPersonaGenerator.Result generate(String brief, String brandHint) {
        String lower = brief == null ? '' : brief.toLowerCase();

        List<Persona_Archetype__mdt> archetypes = [
            SELECT DeveloperName, MasterLabel, Category__c, Payload_JSON__c
            FROM Persona_Archetype__mdt
        ];

        Map<String, List<String>> keywords = new Map<String, List<String>>{
            'Commercial_Cross_Sell'   => new List<String>{'commercial banking','commercial account','treasury','vp of treasury','cross-sell treasury','fx hedging','forex','logistics','underwriting','soc-2','mid-market','b2b'},
            'Wealth_HNW'              => new List<String>{'wealth','hnw','high net worth','estate','advisor','trust','retired','executive','investable','millions','high-net-worth','retirement'},
            'Retail_SMB'              => new List<String>{'small business','smb','retail','owner','bakery','line of credit','merchant','tax return','personal loan','consumer','credit card','capital one','chase','wells fargo','citi','capital-one','personal banking'},
            'Marketing_Engagement'    => new List<String>{'marketing','mql','email campaign','open rate','click rate','engagement journey','webinar','nurture','omnichannel','marketing cloud','automated campaign'}
        };

        String bestKey = null;
        Integer bestScore = -1;
        for (Persona_Archetype__mdt a : archetypes) {
            List<String> kws = keywords.get(a.DeveloperName);
            if (kws == null) continue;
            Integer score = 0;
            for (String k : kws) {
                if (lower.contains(k)) score++;
            }
            if (score > bestScore) {
                bestScore = score;
                bestKey = a.DeveloperName;
            }
        }

        if (bestKey == null || bestScore < 1) {
            DemoStudioPersonaGenerator.Result cq = new DemoStudioPersonaGenerator.Result();
            cq.summary = 'I need a bit more to build this persona. Which best describes the story: (a) a consumer / retail banking scenario, (b) a small business owner, (c) a commercial or corporate treasury client, (d) a wealth / HNW client, or (e) a marketing-engagement demo? Reply with the letter or a sentence.';
            cq.personaJson = null;
            return cq;
        }

        Persona_Archetype__mdt chosen;
        for (Persona_Archetype__mdt a : archetypes) {
            if (a.DeveloperName == bestKey) { chosen = a; break; }
        }

        DemoStudioPersonaGenerator.Result r = new DemoStudioPersonaGenerator.Result();
        if (chosen == null || String.isBlank(chosen.Payload_JSON__c)) {
            r.summary = 'No archetype available. Please seed the Persona_Archetype__mdt records.';
            r.personaJson = '{}';
            return r;
        }

        String brand = String.isNotBlank(brandHint) ? brandHint : extractBrand(brief);
        String payload = chosen.Payload_JSON__c;
        if (String.isNotBlank(brand)) {
            payload = injectBrand(payload, brand);
        }
        r.personaJson = payload;
        r.summary = 'Generated a ' + chosen.MasterLabel + ' persona' +
            (String.isNotBlank(brand) ? ' for ' + brand : '') +
            '. Review the tabs and hit Save.';
        return r;
    }

    private static String extractBrand(String brief) {
        if (String.isBlank(brief)) return null;
        for (String prefix : new List<String>{'at ', 'for ', 'client is ', 'brand is '}) {
            Integer idx = brief.toLowerCase().indexOf(prefix);
            if (idx >= 0) {
                Integer start = idx + prefix.length();
                Integer endIdx = brief.length();
                for (String stop : new List<String>{'.', ',', ' who ', ' that ', ' - ', ' — '}) {
                    Integer si = brief.toLowerCase().indexOf(stop, start);
                    if (si > 0 && si < endIdx) endIdx = si;
                }
                String candidate = brief.substring(start, endIdx).trim();
                if (candidate.length() > 0 && candidate.length() < 80) {
                    return candidate;
                }
            }
        }
        return null;
    }

    private static String injectBrand(String json, String brand) {
        String safeBrand = String.valueOf(brand).replace('"', '\\"');
        String replaced = json.replaceAll('"Brand__c"\\s*:\\s*"[^"]*"', '"Brand__c":"' + safeBrand + '"');
        if (replaced != json) return replaced;
        Integer i = json.indexOf('"persona":{');
        if (i < 0) return json;
        Integer insertAt = i + '"persona":{'.length();
        return json.substring(0, insertAt) + '"Brand__c":"' + safeBrand + '",' + json.substring(insertAt);
    }
}
