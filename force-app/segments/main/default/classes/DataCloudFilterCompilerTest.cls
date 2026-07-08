@isTest
private class DataCloudFilterCompilerTest {

    @isTest
    static void empty_filter_returns_empty_where() {
        DataCloudFilterCompiler.WhereClause wc =
            DataCloudFilterCompiler.compile('Demo_DMO_Individual__c', null);
        System.assertEquals('', wc.fragment, 'null filter → empty fragment');

        DataCloudFilterCompiler.WhereClause wc2 =
            DataCloudFilterCompiler.compile('Demo_DMO_Individual__c', '');
        System.assertEquals('', wc2.fragment, 'blank filter → empty fragment');
    }

    @isTest
    static void direct_eq_uses_bind() {
        String json = '{"kind":"container","operator":"AND","include":true,"children":[' +
                      '{"kind":"direct","field":"Tier__c","op":"eq","value":"Gold"}]}';
        DataCloudFilterCompiler.WhereClause wc =
            DataCloudFilterCompiler.compile('Demo_DMO_Individual__c', json);
        System.assert(wc.fragment.contains('Tier__c = :'), 'should bind Tier__c: ' + wc.fragment);
        System.assertEquals(1, wc.binds.size());
        System.assertEquals('Gold', wc.binds.values()[0]);
    }

    @isTest
    static void direct_between_produces_two_binds() {
        String json = '{"kind":"container","operator":"AND","include":true,"children":[' +
                      '{"kind":"direct","field":"Age__c","op":"between","value":25,"valueEnd":40}]}';
        DataCloudFilterCompiler.WhereClause wc =
            DataCloudFilterCompiler.compile('Demo_DMO_Individual__c', json);
        System.assert(wc.fragment.contains('Age__c >='), wc.fragment);
        System.assert(wc.fragment.contains('Age__c <='), wc.fragment);
        System.assertEquals(2, wc.binds.size());
    }

    @isTest
    static void direct_in_uses_list_bind() {
        String json = '{"kind":"container","operator":"AND","include":true,"children":[' +
                      '{"kind":"direct","field":"Tier__c","op":"in","value":["Gold","Platinum"]}]}';
        DataCloudFilterCompiler.WhereClause wc =
            DataCloudFilterCompiler.compile('Demo_DMO_Individual__c', json);
        System.assert(wc.fragment.contains('Tier__c IN :'), wc.fragment);
        System.assertEquals(1, wc.binds.size());
        System.assert(wc.binds.values()[0] instanceof List<Object>);
    }

    @isTest
    static void container_or_joins_with_or() {
        String json = '{"kind":"container","operator":"OR","include":true,"children":[' +
                      '{"kind":"direct","field":"Tier__c","op":"eq","value":"Gold"},' +
                      '{"kind":"direct","field":"Tier__c","op":"eq","value":"Platinum"}]}';
        DataCloudFilterCompiler.WhereClause wc =
            DataCloudFilterCompiler.compile('Demo_DMO_Individual__c', json);
        System.assert(wc.fragment.contains(' OR '), 'should join with OR: ' + wc.fragment);
    }

    @isTest
    static void exclude_container_wraps_in_not() {
        String json = '{"kind":"container","operator":"AND","include":false,"children":[' +
                      '{"kind":"direct","field":"Tier__c","op":"eq","value":"Gold"}]}';
        DataCloudFilterCompiler.WhereClause wc =
            DataCloudFilterCompiler.compile('Demo_DMO_Individual__c', json);
        System.assert(wc.fragment.startsWith('NOT '), 'should start with NOT: ' + wc.fragment);
    }

    @isTest
    static void related_exists_produces_subquery() {
        String json = '{"kind":"container","operator":"AND","include":true,"children":[' +
                      '{"kind":"related","relatedObject":"Demo_DMO_Event__c","op":"exists",' +
                      '"subFilter":{"kind":"container","operator":"AND","include":true,"children":[' +
                      '{"kind":"direct","field":"Event_Type__c","op":"eq","value":"EmailOpen"}]}}]}';
        DataCloudFilterCompiler.WhereClause wc =
            DataCloudFilterCompiler.compile('Demo_DMO_Individual__c', json);
        System.assert(wc.fragment.contains('Id IN (SELECT Individual__c FROM Demo_DMO_Event__c'),
            'expected subquery: ' + wc.fragment);
    }

    @isTest
    static void isNull_and_isNotNull_dont_bind() {
        String json = '{"kind":"container","operator":"AND","include":true,"children":[' +
                      '{"kind":"direct","field":"Email__c","op":"isNull"},' +
                      '{"kind":"direct","field":"Phone__c","op":"isNotNull"}]}';
        DataCloudFilterCompiler.WhereClause wc =
            DataCloudFilterCompiler.compile('Demo_DMO_Individual__c', json);
        System.assert(wc.fragment.contains('Email__c = null'), wc.fragment);
        System.assert(wc.fragment.contains('Phone__c != null'), wc.fragment);
        System.assertEquals(0, wc.binds.size(), 'null checks don\'t bind');
    }

    @isTest
    static void unknown_field_is_rejected() {
        String json = '{"kind":"container","operator":"AND","include":true,"children":[' +
                      '{"kind":"direct","field":"SecretField__c","op":"eq","value":"x"}]}';
        Boolean threw = false;
        try {
            DataCloudFilterCompiler.compile('Demo_DMO_Individual__c', json);
        } catch (DataCloudFilterCompiler.CompileException e) {
            threw = true;
            System.assert(e.getMessage().contains('Field not permitted'), e.getMessage());
        }
        System.assert(threw, 'expected CompileException for unknown field');
    }

    @isTest
    static void injection_attempt_via_field_name_rejected() {
        String json = '{"kind":"container","operator":"AND","include":true,"children":[' +
                      '{"kind":"direct","field":"Tier__c OR Id != null","op":"eq","value":"x"}]}';
        Boolean threw = false;
        try {
            DataCloudFilterCompiler.compile('Demo_DMO_Individual__c', json);
        } catch (DataCloudFilterCompiler.CompileException e) {
            threw = true;
        }
        System.assert(threw, 'injection attempt should be rejected');
    }

    @isTest
    static void unsupported_operator_rejected() {
        String json = '{"kind":"container","operator":"AND","include":true,"children":[' +
                      '{"kind":"direct","field":"Tier__c","op":"regex","value":"x"}]}';
        Boolean threw = false;
        try {
            DataCloudFilterCompiler.compile('Demo_DMO_Individual__c', json);
        } catch (DataCloudFilterCompiler.CompileException e) {
            threw = true;
        }
        System.assert(threw, 'unsupported operator should be rejected');
    }

    @isTest
    static void unsupported_root_object_rejected() {
        Boolean threw = false;
        try {
            DataCloudFilterCompiler.compile('Contact', '{"kind":"container","operator":"AND","include":true,"children":[]}');
        } catch (DataCloudFilterCompiler.CompileException e) {
            threw = true;
        }
        System.assert(threw, 'unsupported root should be rejected');
    }

    @isTest
    static void contains_wraps_with_percent() {
        String json = '{"kind":"container","operator":"AND","include":true,"children":[' +
                      '{"kind":"direct","field":"First_Name__c","op":"contains","value":"ari"}]}';
        DataCloudFilterCompiler.WhereClause wc =
            DataCloudFilterCompiler.compile('Demo_DMO_Individual__c', json);
        System.assert(wc.fragment.contains('First_Name__c LIKE :'), wc.fragment);
        System.assertEquals('%ari%', wc.binds.values()[0]);
    }

    @isTest
    static void compiled_where_runs_against_soql() {
        Demo_DMO_Individual__c ind = new Demo_DMO_Individual__c(
            First_Name__c = 'Test', Last_Name__c = 'User',
            Tier__c = 'Gold', Household_Income__c = 250000
        );
        insert ind;

        String json = '{"kind":"container","operator":"AND","include":true,"children":[' +
                      '{"kind":"direct","field":"Tier__c","op":"eq","value":"Gold"}]}';
        DataCloudFilterCompiler.WhereClause wc =
            DataCloudFilterCompiler.compile('Demo_DMO_Individual__c', json);
        String soql = 'SELECT COUNT() FROM Demo_DMO_Individual__c WHERE ' + wc.fragment;
        Integer n = Database.countQueryWithBinds(soql, wc.binds, AccessLevel.USER_MODE);
        System.assertEquals(1, n, 'should match the one Gold-tier record');
    }
}
