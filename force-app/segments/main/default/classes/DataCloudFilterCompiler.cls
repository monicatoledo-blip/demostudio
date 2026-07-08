/**
 * Compiles a segment filter tree (JSON payload from the segment builder LWC)
 * into a safe SOQL WHERE clause. Uses bind vars for values and a strict field
 * + operator whitelist derived from Schema describe to prevent SOQL injection.
 *
 * Filter tree shape (JSON):
 *   Container: { "kind":"container", "operator":"AND"|"OR", "include":true|false, "children":[...] }
 *   Direct:    { "kind":"direct", "field":"Age__c", "op":"gt", "value":25 }
 *   Direct btw:{ "kind":"direct", "field":"Age__c", "op":"between", "value":25, "valueEnd":40 }
 *   Direct in: { "kind":"direct", "field":"Tier__c", "op":"in", "value":["Gold","Platinum"] }
 *   Related:   { "kind":"related", "relatedObject":"Demo_DMO_Event__c",
 *                "op":"exists", "subFilter": { ...container... } }
 *   Related n: { "kind":"related", "relatedObject":"Demo_DMO_Event__c",
 *                "op":"countGte", "value":3, "subFilter":{...} }
 *
 * The compiler returns a WhereClause struct: the WHERE fragment string plus
 * a Map<String,Object> of bind vars. Callers hand both to Database.queryWithBinds.
 */
public with sharing class DataCloudFilterCompiler {

    public class CompileException extends Exception {}

    public class WhereClause {
        public String fragment;
        public Map<String, Object> binds;
        public WhereClause(String f, Map<String, Object> b) {
            this.fragment = f;
            this.binds = b;
        }
    }

    private static final Set<String> ROOT_OBJECTS = new Set<String>{
        'Demo_DMO_Individual__c'
    };

    private static final Set<String> RELATED_OBJECTS = new Set<String>{
        'Demo_DMO_Event__c',
        'Demo_DMO_Transaction__c'
    };

    // Map filter operator token → SOQL comparison operator.
    // Operators like 'in','between','contains','isNull' are handled by dedicated branches below.
    private static final Map<String, String> COMPARISON_OPS = new Map<String, String>{
        'eq' => '=',
        'ne' => '!=',
        'gt' => '>',
        'gte' => '>=',
        'lt' => '<',
        'lte' => '<='
    };

    // Foreign-key field on the related object that points back to the Individual root.
    private static final String RELATED_FK = 'Individual__c';

    private Integer bindCounter = 0;
    private Map<String, Object> binds = new Map<String, Object>();
    private Map<String, Set<String>> allowedFieldsByObject = new Map<String, Set<String>>();

    public static WhereClause compile(String rootObject, String filterJson) {
        if (String.isBlank(filterJson)) {
            return new WhereClause('', new Map<String, Object>());
        }
        if (!ROOT_OBJECTS.contains(rootObject)) {
            throw new CompileException('Unsupported root object: ' + rootObject);
        }
        Object parsed;
        try {
            parsed = JSON.deserializeUntyped(filterJson);
        } catch (Exception e) {
            throw new CompileException('Invalid filter JSON: ' + e.getMessage());
        }
        DataCloudFilterCompiler c = new DataCloudFilterCompiler();
        c.loadAllowedFields(rootObject);
        for (String related : RELATED_OBJECTS) {
            c.loadAllowedFields(related);
        }
        String fragment = c.compileNode((Map<String, Object>) parsed, rootObject);
        return new WhereClause(fragment, c.binds);
    }

    private String compileNode(Map<String, Object> node, String currentObject) {
        String kind = (String) node.get('kind');
        if (kind == 'container') {
            return compileContainer(node, currentObject);
        } else if (kind == 'direct') {
            return compileDirect(node, currentObject);
        } else if (kind == 'related') {
            return compileRelated(node, currentObject);
        }
        throw new CompileException('Unknown filter node kind: ' + kind);
    }

    private String compileContainer(Map<String, Object> node, String currentObject) {
        String operator = String.valueOf(node.get('operator'));
        if (operator != 'AND' && operator != 'OR') {
            throw new CompileException('Container operator must be AND or OR');
        }
        Boolean include = node.containsKey('include') ? (Boolean) node.get('include') : true;
        List<Object> children = (List<Object>) node.get('children');
        if (children == null || children.isEmpty()) {
            return include ? '' : '';
        }
        List<String> parts = new List<String>();
        for (Object childObj : children) {
            String childFragment = compileNode((Map<String, Object>) childObj, currentObject);
            if (String.isNotBlank(childFragment)) {
                parts.add(childFragment);
            }
        }
        if (parts.isEmpty()) {
            return '';
        }
        String joined = '(' + String.join(parts, ' ' + operator + ' ') + ')';
        return include ? joined : ('NOT ' + joined);
    }

    private String compileDirect(Map<String, Object> node, String currentObject) {
        String field = (String) node.get('field');
        String op = (String) node.get('op');
        assertFieldAllowed(currentObject, field);

        if (op == 'isNull') {
            return field + ' = null';
        }
        if (op == 'isNotNull') {
            return field + ' != null';
        }
        if (op == 'contains') {
            String bind = nextBind();
            binds.put(bind, '%' + String.valueOf(node.get('value')) + '%');
            return field + ' LIKE :' + bind;
        }
        if (op == 'startsWith') {
            String bind = nextBind();
            binds.put(bind, String.valueOf(node.get('value')) + '%');
            return field + ' LIKE :' + bind;
        }
        if (op == 'in' || op == 'notIn') {
            Object raw = node.get('value');
            if (!(raw instanceof List<Object>)) {
                throw new CompileException('Operator "' + op + '" requires an array value');
            }
            List<Object> vals = (List<Object>) raw;
            String bind = nextBind();
            binds.put(bind, vals);
            return field + (op == 'in' ? ' IN :' : ' NOT IN :') + bind;
        }
        if (op == 'between') {
            String bindLo = nextBind();
            String bindHi = nextBind();
            binds.put(bindLo, node.get('value'));
            binds.put(bindHi, node.get('valueEnd'));
            return '(' + field + ' >= :' + bindLo + ' AND ' + field + ' <= :' + bindHi + ')';
        }
        if (COMPARISON_OPS.containsKey(op)) {
            String bind = nextBind();
            binds.put(bind, node.get('value'));
            return field + ' ' + COMPARISON_OPS.get(op) + ' :' + bind;
        }
        throw new CompileException('Unsupported operator: ' + op);
    }

    private String compileRelated(Map<String, Object> node, String currentObject) {
        if (currentObject != 'Demo_DMO_Individual__c') {
            throw new CompileException('Related filters only supported at root level');
        }
        String relatedObj = (String) node.get('relatedObject');
        if (!RELATED_OBJECTS.contains(relatedObj)) {
            throw new CompileException('Unsupported related object: ' + relatedObj);
        }
        String op = (String) node.get('op');
        Map<String, Object> subFilter = (Map<String, Object>) node.get('subFilter');
        String subWhere = subFilter == null ? '' : compileNode(subFilter, relatedObj);

        String innerQuery = 'SELECT ' + RELATED_FK + ' FROM ' + relatedObj;
        if (String.isNotBlank(subWhere)) {
            innerQuery += ' WHERE ' + subWhere;
        }

        if (op == 'exists') {
            return 'Id IN (' + innerQuery + ')';
        }
        if (op == 'notExists') {
            return 'Id NOT IN (' + innerQuery + ')';
        }
        // Count-based ops require Individual→Related aggregation, which SOQL sub-queries
        // can't do natively in a WHERE clause. v1 supports exists/notExists only; count
        // ops are reserved for a future enhancement that materializes counts via a
        // scheduled batch onto Demo_DMO_Individual__c.
        throw new CompileException('Related operator not supported in v1: ' + op);
    }

    private void loadAllowedFields(String objectApiName) {
        SObjectType t = Schema.getGlobalDescribe().get(objectApiName);
        if (t == null) {
            throw new CompileException('Unknown object: ' + objectApiName);
        }
        Set<String> allowed = new Set<String>();
        for (String fieldName : t.getDescribe().fields.getMap().keySet()) {
            allowed.add(fieldName.toLowerCase());
        }
        allowedFieldsByObject.put(objectApiName, allowed);
    }

    private void assertFieldAllowed(String objectApiName, String field) {
        if (String.isBlank(field)) {
            throw new CompileException('Filter field is required');
        }
        Set<String> allowed = allowedFieldsByObject.get(objectApiName);
        if (allowed == null || !allowed.contains(field.toLowerCase())) {
            throw new CompileException('Field not permitted on ' + objectApiName + ': ' + field);
        }
    }

    private String nextBind() {
        bindCounter++;
        return 'b' + bindCounter;
    }
}
