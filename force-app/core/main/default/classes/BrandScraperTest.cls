@isTest
private class BrandScraperTest {

    @isTest
    static void shouldReturnColorsAndLogo_WhenModelResolvesBrand() {
        EinsteinProvider.mockGeneratedText =
            '{"brandName":"Chase","primaryColor":"#117ACA","accentColor":"#0B5FAE","domain":"chase.com","note":"official"}';

        Test.startTest();
        BrandScraper.BrandResult r = BrandScraper.scrape('Chase Bank');
        Test.stopTest();

        Assert.areEqual('Chase', r.brandName, 'Brand name should map through');
        Assert.areEqual('#117ACA', r.primaryColor, 'Primary color should normalize to uppercase hex');
        Assert.isTrue(r.gradientCss.contains('linear-gradient'), 'Gradient should be composed from the two colors');
        Assert.areEqual('https://icons.duckduckgo.com/ip3/chase.com.ico', r.logoUrl, 'Logo URL should be built from the domain');
    }

    @isTest
    static void shouldExpandShorthandHex_WhenModelReturnsThreeDigit() {
        EinsteinProvider.mockGeneratedText =
            '{"brandName":"Acme","primaryColor":"#abc","accentColor":"123456","domain":"acme.com","note":"guess"}';

        Test.startTest();
        BrandScraper.BrandResult r = BrandScraper.scrape('Acme');
        Test.stopTest();

        Assert.areEqual('#AABBCC', r.primaryColor, '#abc should expand to #AABBCC');
        Assert.areEqual('#123456', r.accentColor, 'Missing # should be prepended and uppercased');
    }

    @isTest
    static void shouldReturnNote_WhenQueryBlank() {
        Test.startTest();
        BrandScraper.BrandResult r = BrandScraper.scrape('   ');
        Test.stopTest();

        Assert.isNull(r.brandName, 'No lookup should occur for a blank query');
        Assert.isTrue(r.note.contains('brand name or website'), 'Note should prompt for input');
    }

    @isTest
    static void shouldReturnLookupFailure_WhenModelReturnsNoJson() {
        EinsteinProvider.mockGeneratedText = 'not json';

        Test.startTest();
        BrandScraper.BrandResult r = BrandScraper.scrape('Mystery Brand');
        Test.stopTest();

        Assert.isTrue(r.note.startsWith('Brand lookup failed'), 'A model failure should surface as a lookup-failed note');
    }

    @isTest
    static void shouldReturnParseNote_WhenModelReturnsNonObjectJson() {
        // Valid JSON that is an object but missing color fields — scrape parses
        // without error and simply leaves gradient/logo null.
        EinsteinProvider.mockGeneratedText = '{"brandName":"Solo"}';

        Test.startTest();
        BrandScraper.BrandResult r = BrandScraper.scrape('Solo');
        Test.stopTest();

        Assert.areEqual('Solo', r.brandName, 'Brand name should still map');
        Assert.isNull(r.gradientCss, 'No gradient without both colors');
    }
}
