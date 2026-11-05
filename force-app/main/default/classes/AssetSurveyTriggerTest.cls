@isTest
private class AssetSurveyTriggerTest {
    @isTest
    static void testAssetSurveySyncAndDefaults() {
        Geography__c geo = new Geography__c(
            Name = 'Bengaluru South Survey Test',
            Nation__c = 'India',
            State__c = 'Karnataka',
            District__c = 'Bengaluru',
            Town__c = 'Bengaluru',
            Municipal__c = 'BBMP'
        );
        insert geo;

        Outlet__c outlet = new Outlet__c(
            Name = 'Green Leaf Mart',
            Geography__c = geo.Id,
            Outlet_Name__c = 'Green Leaf Mart',
            Contact_No__c = '9876543210'
        );
        insert outlet;

        // Test 1: Insert with Outlet__c lookup - verifies Outlet_Name__c auto-population and defaults
        Asset_Survey__c asv1 = new Asset_Survey__c(
            Outlet__c = outlet.Id,
            Asset_Name__c = 'Visicooler 200L',
            Asset_Code__c = 'AST-VC-001',
            Picture__c = 'https://example.com/asset1.jpg'
        );
        insert asv1;

        Asset_Survey__c insertedAsv1 = [SELECT Id, Outlet_Name__c, Status__c, Given_Date__c FROM Asset_Survey__c WHERE Id = :asv1.Id];
        System.assertEquals('Green Leaf Mart', insertedAsv1.Outlet_Name__c);
        System.assertEquals('Working', insertedAsv1.Status__c);
        System.assertEquals(Date.today(), insertedAsv1.Given_Date__c);

        // Test 2: Insert with Outlet_Name__c text - verifies Outlet__c resolution
        Asset_Survey__c asv2 = new Asset_Survey__c(
            Outlet_Name__c = 'Green Leaf Mart',
            Asset_Name__c = 'Display Rack',
            Asset_Code__c = 'AST-DR-002',
            Status__c = 'Damaged',
            Given_Date__c = Date.today().addDays(-30)
        );
        insert asv2;

        Asset_Survey__c insertedAsv2 = [SELECT Id, Outlet__c, Status__c FROM Asset_Survey__c WHERE Id = :asv2.Id];
        System.assertEquals(outlet.Id, insertedAsv2.Outlet__c);
        System.assertEquals('Damaged', insertedAsv2.Status__c);

        // Test 3: Update
        asv2.Status__c = 'Under Maintenance';
        update asv2;

        Asset_Survey__c updatedAsv2 = [SELECT Id, Status__c FROM Asset_Survey__c WHERE Id = :asv2.Id];
        System.assertEquals('Under Maintenance', updatedAsv2.Status__c);
    }
}