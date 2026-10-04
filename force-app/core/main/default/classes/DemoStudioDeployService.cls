/**
 * DemoStudioDeployService
 *
 * Native "demo to deploy" engine for the Demo Story Factory. Deploys the
 * Self-Service Personalization objects for a Demo_Story__c into THIS org via
 * the Data 360 Personalization Connect REST API, and hosts the generated
 * experience HTML as a StaticResource via the Tooling API.
 *
 * Ported from the (Heroku/Node) SP Demo Builder sf/p13n.js + sf/deploy.js, but
 * driven by the declarative Demo_Story__c / Demo_Stage__c records instead of
 * hardcoded SCHEMA_DEFS/PP_DEFS. Same-org callouts authenticate with the
 * running user's session token (verified working on meshmesh 2026-10-04: no
 * Named Credential / Remote Site Setting needed for anonymous/sync Apex).
 *
 * ADDITIVE ONLY: this class and its records are independent of the existing
 * Demo Studio unified-profile generator; nothing here touches those objects.
 *
 * Connect REST quirks carried over (all verified against the SDO):
 *   - schema create: personalizationType 'ManualContent'; attributes [{name,label}]
 *   - transformer create: NO description, NO transformerCategory; channel WebApp,
 *     transformerType Handlebars, transformerTypeDetails {html,script,componentName}
 *   - point create: NO criteria (rejected for non-UI tier); decisions are
 *     unconditional, state 'Live'
 *   - transformer DELETE: SINGULAR query-param resource (?idOrName=) + verify
 *     gone (plural path-param DELETE is a silent no-op)
 *   - teardown order: points -> transformers -> schemas -> static resources
 */
public with sharing class DemoStudioDeployService {

    private static final String API = 'v67.0';
    private static final String PBASE = '/services/data/' + API + '/personalization';
    private static final String TOOLING_SR = '/services/data/' + API + '/tooling/sobjects/StaticResource';

    public class DeployException extends Exception {}

    /** JSON record of everything created, persisted on the Story for teardown. */
    public class Artifacts {
        public String dataSpace;
        public String connectorId;
        public List<String> schemas = new List<String>();
        public List<String> transformers = new List<String>();
        public List<String> points = new List<String>();
        public List<String> staticResources = new List<String>();
    }

    // ---------------------------------------------------------------- callout

    private static HttpResponse send(String method, String path, String bodyJson) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(URL.getOrgDomainUrl().toExternalForm() + path);
        req.setMethod(method);
        req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
        req.setHeader('Content-Type', 'application/json');
        req.setTimeout(120000);
        if (bodyJson != null) req.setBody(bodyJson);
        return new Http().send(req);
    }

    private static Map<String, Object> okJson(HttpResponse res, String action) {
        Integer sc = res.getStatusCode();
        if (sc < 200 || sc >= 300) {
            throw new DeployException(action + ' failed (' + sc + '): ' + res.getBody());
        }
        String b = res.getBody();
        if (String.isBlank(b)) return new Map<String, Object>();
        Object parsed = JSON.deserializeUntyped(b);
        return (parsed instanceof Map<String, Object>) ? (Map<String, Object>) parsed : new Map<String, Object>{ 'raw' => parsed };
    }

    // ---------------------------------------------------------- api-name util

    /** Connect-REST-safe API name: letters/numbers/underscores, no leading digit. */
    @TestVisible
    private static String apiName(String label) {
        String s = (label == null ? '' : label).replaceAll('[^A-Za-z0-9]+', '_');
        s = s.replaceAll('^_+|_+$', '');
        if (s.length() > 0 && s.substring(0, 1).isNumeric()) s = '_' + s;
        return s;
    }

    // ------------------------------------------------------------- transformer

    @TestVisible
    private static String heroTransformerHtml() {
        return String.join(new List<String>{
            '<style>',
            '.sfdcep-banner{margin:0 auto;width:100%;min-height:600px;display:flex;flex-flow:column wrap;justify-content:center;font-family:Arial,Helvetica,sans-serif;background-size:cover;background-position:center;}',
            '.sfdcep-banner-header{font-size:32px;padding-bottom:24px;font-weight:600;color:#fff;text-align:center;text-shadow:0 1px 4px rgba(0,0,0,.4);}',
            '.sfdcep-banner-subheader{font-size:20px;font-weight:400;color:#fff;text-align:center;padding-bottom:24px;text-shadow:0 1px 4px rgba(0,0,0,.4);}',
            '.sfdcep-banner-eyebrow{font-size:14px;font-weight:700;letter-spacing:.08em;text-transform:uppercase;color:#fff;text-align:center;padding-bottom:12px;text-shadow:0 1px 4px rgba(0,0,0,.4);}',
            '</style>',
            '<div class="sfdcep-banner" style="background:url(\'{{subVar \'BackgroundImageUrl\'}}\') no-repeat center/cover;">',
            '  <div class="sfdcep-banner-eyebrow">{{subVar \'Eyebrow\'}}</div>',
            '  <div class="sfdcep-banner-header">{{subVar \'Header\'}}</div>',
            '  <div class="sfdcep-banner-subheader">{{subVar \'Subheader\'}}</div>',
            '</div>'
        }, '\n');
    }

    private static final List<String> HERO_ATTRS = new List<String>{
        'BackgroundImageUrl', 'Eyebrow', 'Header', 'Subheader', 'CallToActionText'
    };

    private static Map<String, Object> substitutionDefinitionsFor(List<String> attrs) {
        Map<String, Object> defs = new Map<String, Object>();
        for (String a : attrs) {
            defs.put(a, new Map<String, Object>{
                'configType' => 'SchemaPath',
                'defaultValue' => '[attributes].[' + a + ']',
                'label' => a,
                'overridable' => true,
                'required' => false
            });
        }
        return defs;
    }

    // ------------------------------------------------------------ create ops

    /** Create a Content Schema; returns its API name. */
    private static String createSchema(String label, String dataSpace, List<String> attrs) {
        List<Object> attrDefs = new List<Object>();
        for (String a : attrs) attrDefs.add(new Map<String, Object>{ 'name' => a, 'label' => a });
        Map<String, Object> body = new Map<String, Object>{
            'name' => apiName(label),
            'label' => label,
            'dataSpaceName' => dataSpace,
            'personalizationType' => 'ManualContent',
            'attributes' => attrDefs
        };
        okJson(send('POST', PBASE + '/personalization-schemas', JSON.serialize(body)), 'Create schema "' + label + '"');
        return apiName(label);
    }

    /** Create a WebApp Handlebars transformer; returns its API name. */
    private static String createTransformer(String label, String dataSpace, String schemaName, String html, List<String> attrs) {
        Map<String, Object> body = new Map<String, Object>{
            'name' => apiName(label),
            'label' => label,
            'channel' => 'WebApp',
            'dataSpace' => dataSpace,
            'schemaReference' => schemaName,
            'isEnabled' => true,
            'transformerType' => 'Handlebars',
            'substitutionDefinitions' => substitutionDefinitionsFor(attrs),
            'transformerTypeDetails' => new Map<String, Object>{ 'html' => html, 'script' => null, 'componentName' => null }
        };
        okJson(send('POST', PBASE + '/external-apps/transformers', JSON.serialize(body)), 'Create transformer "' + label + '"');
        return apiName(label);
    }

    /** Create a Personalization Point with one unconditional (always-on) decision. */
    private static String createPoint(String label, String dataSpace, String profileGraph, String schemaName,
                                      String decisionLabel, Map<String, String> attrValues) {
        List<Object> avs = new List<Object>();
        for (String k : attrValues.keySet()) {
            avs.add(new Map<String, Object>{ 'attributeName' => k, 'value' => attrValues.get(k) });
        }
        Map<String, Object> decision = new Map<String, Object>{
            'name' => apiName(decisionLabel),
            'label' => decisionLabel,
            'attributeValues' => avs,
            'state' => 'Live'
        };
        Map<String, Object> body = new Map<String, Object>{
            'name' => apiName(label),
            'label' => label,
            'dataSpaceName' => dataSpace,
            'source' => 'PersonalizationApp',
            'isAuthenticationRequired' => false,
            'schemaName' => schemaName,
            'decisions' => new List<Object>{ decision }
        };
        if (String.isNotBlank(profileGraph)) body.put('profileDataGraphName', profileGraph);
        okJson(send('POST', PBASE + '/personalization-points', JSON.serialize(body)), 'Create point "' + label + '"');
        return apiName(label);
    }

    /** Host HTML as a StaticResource (Tooling API); returns its 18-char Id. */
    private static String createStaticResource(String name, String html) {
        Map<String, Object> body = new Map<String, Object>{
            'Name' => apiName(name),
            'ContentType' => 'text/html',
            'CacheControl' => 'Public',
            'Body' => EncodingUtil.base64Encode(Blob.valueOf(html))
        };
        Map<String, Object> res = okJson(send('POST', TOOLING_SR, JSON.serialize(body)), 'Create StaticResource "' + name + '"');
        return (String) res.get('id');
    }

    // ------------------------------------------------------------- delete ops

    private static String enc(String s) { return EncodingUtil.urlEncode(s, 'UTF-8'); }
    private static String schemaPath(String n) { return PBASE + '/personalization-schemas/' + enc(n); }
    private static String pointPath(String n) { return PBASE + '/personalization-points/' + enc(n); }
    // SINGULAR query-param resource (the plural path-param DELETE is a silent no-op).
    private static String transformerPath(String n) { return PBASE + '/external-apps/transformer?idOrName=' + enc(n); }
    private static String srPath(String id) { return TOOLING_SR + '/' + id; }

    /** True if the resource is gone: a 2xx, or a not-found response. */
    private static Boolean tryDelete(String path) {
        HttpResponse res = send('DELETE', path, null);
        Integer sc = res.getStatusCode();
        if (sc >= 200 && sc < 300) return true;
        String b = (res.getBody() == null ? '' : res.getBody()).toLowerCase();
        return sc == 404 || b.contains('not found') || b.contains('no resource found') || b.contains('does not exist');
    }

    /** Retry delete to ride out transient DEPENDENCY_EXISTS after a parent delete. */
    private static Boolean deleteWithRetry(String path, Integer maxTries) {
        for (Integer i = 0; i < maxTries; i++) {
            try { if (tryDelete(path)) return true; } catch (Exception e) {}
        }
        return false;
    }

    // -------------------------------------------------------------- read util

    private static String str(Map<String, Object> m, String k) {
        Object v = (m == null) ? null : m.get(k);
        return v == null ? '' : String.valueOf(v);
    }

    // ------------------------------------------------------------- public API

    /**
     * Deploy a Demo_Story__c into this org. Creates the hero experience
     * (schema + transformer + point w/ decision) from the story's Adaptive Web
     * stage content, and hosts the generated page HTML as a StaticResource.
     * Persists artifact ids on the story and sets Status to Deployed. On any
     * failure, rolls back what it created and sets Status to Error.
     */
    @AuraEnabled
    public static String deployStory(Id storyId) {
        try {
            return deployStoryImpl(storyId);
        } catch (Exception e) {
            AuraHandledException ahe = new AuraHandledException(e.getMessage());
            ahe.setMessage(e.getMessage());
            throw ahe;
        }
    }

    /** Core deploy; throws DeployException on failure. Callable from anon/tests. */
    public static String deployStoryImpl(Id storyId) {
        Demo_Story__c story = [
            SELECT Id, Name, Data_Space__c, Connector_Id__c, Profile_Data_Graph__c,
                   (SELECT Id, Stage_Type__c, Channel__c, Surface__c, Sort_Order__c, Content_JSON__c
                    FROM Stages__r ORDER BY Sort_Order__c ASC NULLS LAST)
            FROM Demo_Story__c WHERE Id = :storyId LIMIT 1
        ];
        String ds = String.isBlank(story.Data_Space__c) ? 'default' : story.Data_Space__c;
        String graph = String.isBlank(story.Profile_Data_Graph__c) ? 'Real_Time_Personalization' : story.Profile_Data_Graph__c;
        String prefix = story.Name;
        Artifacts art = new Artifacts();
        art.dataSpace = ds;
        art.connectorId = story.Connector_Id__c;

        // find the hero content: the Adaptive Web stage targeting homepage_hero,
        // else the first Adaptive Web stage.
        Demo_Stage__c heroStage;
        for (Demo_Stage__c st : story.Stages__r) {
            if (st.Channel__c == 'Adaptive Web') {
                if (st.Surface__c == 'homepage_hero') { heroStage = st; break; }
                if (heroStage == null) heroStage = st;
            }
        }
        if (heroStage == null) {
            throw new DeployException('Story has no Adaptive Web stage to deploy.');
        }
        Map<String, Object> c = (Map<String, Object>) JSON.deserializeUntyped(
            String.isBlank(heroStage.Content_JSON__c) ? '{}' : heroStage.Content_JSON__c);

        try {
            String heroSchema = createSchema(prefix + ' - Hero Banner', ds, HERO_ATTRS);
            art.schemas.add(heroSchema);
            String heroXf = createTransformer(prefix + ' - Hero Banner', ds, heroSchema, heroTransformerHtml(), HERO_ATTRS);
            art.transformers.add(heroXf);
            Map<String, String> heroVals = new Map<String, String>{
                'BackgroundImageUrl' => str(c, 'backgroundImageUrl'),
                'Eyebrow' => str(c, 'eyebrow'),
                'Header' => str(c, 'header'),
                'Subheader' => str(c, 'subheader'),
                'CallToActionText' => str(c, 'cta')
            };
            String heroPoint = createPoint(prefix + ' - Homepage Hero', ds, graph, heroSchema,
                prefix + ' - Personalized', heroVals);
            art.points.add(heroPoint);

            String html = str(c, 'html');
            if (String.isBlank(html)) {
                html = '<!doctype html><html><body><h1>' + str(c, 'header') + '</h1><p>' + str(c, 'subheader') + '</p></body></html>';
            }
            String srId = createStaticResource(prefix + '_Experience', html);
            art.staticResources.add(srId);

            story.Deployed_Artifacts__c = JSON.serialize(art);
            story.Status__c = 'Deployed';
            story.Last_Deployed__c = System.now();
            update story;
            return story.Deployed_Artifacts__c;

        } catch (Exception e) {
            rollback(art);
            story.Status__c = 'Error';
            story.Deployed_Artifacts__c = JSON.serialize(art);
            update story;
            throw new DeployException('Deploy failed: ' + e.getMessage());
        }
    }

    /** Tear down everything a story created, in dependency-safe order. */
    @AuraEnabled
    public static void teardownStory(Id storyId) {
        try {
            teardownStoryImpl(storyId);
        } catch (Exception e) {
            AuraHandledException ahe = new AuraHandledException(e.getMessage());
            ahe.setMessage(e.getMessage());
            throw ahe;
        }
    }

    /** Core teardown; throws DeployException if any org artifact survives. */
    public static void teardownStoryImpl(Id storyId) {
        Demo_Story__c story = [SELECT Id, Status__c, Deployed_Artifacts__c FROM Demo_Story__c WHERE Id = :storyId LIMIT 1];
        if (String.isBlank(story.Deployed_Artifacts__c)) return;
        Artifacts art = (Artifacts) JSON.deserialize(story.Deployed_Artifacts__c, Artifacts.class);
        List<String> orphans = rollback(art);
        if (!orphans.isEmpty()) {
            // keep the artifact record so a retry can finish the cleanup
            story.Status__c = 'Error';
            update story;
            throw new DeployException('Teardown left orphans: ' + String.join(orphans, ', '));
        }
        story.Status__c = 'Draft';
        story.Deployed_Artifacts__c = null;
        story.Last_Deployed__c = null;
        update story;
    }

    /**
     * Delete in dependency-safe order (points -> transformers -> schemas ->
     * static resources), with retry. Returns a list of anything that could not
     * be removed so callers can report orphans instead of a false success.
     */
    private static List<String> rollback(Artifacts art) {
        List<String> orphans = new List<String>();
        if (art == null) return orphans;
        for (String p : art.points) { if (!deleteWithRetry(pointPath(p), 3)) orphans.add('point:' + p); }
        for (String t : art.transformers) { if (!deleteWithRetry(transformerPath(t), 3)) orphans.add('transformer:' + t); }
        for (String s : art.schemas) { if (!deleteWithRetry(schemaPath(s), 4)) orphans.add('schema:' + s); }
        for (String sr : art.staticResources) { if (!deleteWithRetry(srPath(sr), 3)) orphans.add('staticResource:' + sr); }
        return orphans;
    }
}
