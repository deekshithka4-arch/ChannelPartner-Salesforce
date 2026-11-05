@isTest
private class CompetitorActivityTriggerTest {
    @isTest
    static void testCompetitorActivitySyncAndDefaults() {
        Geography__c geo = new Geography__c(
            Name = 'Bengaluru South Test Geo',
            Nation__c = 'India',
            State__c = 'Karnataka',
            District__c = 'Bengaluru',
            Town__c = 'Bengaluru',
            Municipal__c = 'BBMP'
        );
        insert geo;

        Outlet__c outlet = new Outlet__c(
            Name = 'Grand Supermarket',
            Geography__c = geo.Id,
            Outlet_Name__c = 'Grand Supermarket',
            Contact_No__c = '9876543210'
        );
        insert outlet;

        // Test 1: Insert with Outlet__c lookup - verifies Outlet_Name__c auto-population and Schemes_Any__c default
        Competitor_Activity__c ca1 = new Competitor_Activity__c(
            Outlet__c = outlet.Id,
            Competitor_Name__c = 'Sunfeast Mom\'s Magic',
            Company__c = 'ITC Limited',
            MRP__c = 30.00,
            RBP__c = 24.50,
            Image__c = 'https://example.com/competitor1.jpg'
        );
        insert ca1;

        Competitor_Activity__c insertedCa1 = [SELECT Id, Outlet_Name__c, Schemes_Any__c, Compitator_Name__c FROM Competitor_Activity__c WHERE Id = :ca1.Id];
        System.assertEquals('Grand Supermarket', insertedCa1.Outlet_Name__c);
        System.assertEquals('None', insertedCa1.Schemes_Any__c);
        System.assertEquals('Sunfeast Mom\'s Magic', insertedCa1.Compitator_Name__c);

        // Test 2: Insert with Outlet_Name__c text - verifies Outlet__c resolution
        Competitor_Activity__c ca2 = new Competitor_Activity__c(
            Outlet_Name__c = 'Grand Supermarket',
            Competitor_Name__c = 'Cadbury Oreo Vanilla',
            Company__c = 'Mondelez India',
            MRP__c = 35.00,
            RBP__c = 28.00,
            Schemes_Any__c = 'Buy 10 Get 1 Free'
        );
        insert ca2;

        Competitor_Activity__c insertedCa2 = [SELECT Id, Outlet__c, Schemes_Any__c FROM Competitor_Activity__c WHERE Id = :ca2.Id];
        System.assertEquals(outlet.Id, insertedCa2.Outlet__c);
        System.assertEquals('Buy 10 Get 1 Free', insertedCa2.Schemes_Any__c);

        // Test 3: Update
        ca2.MRP__c = 40.00;
        update ca2;

        Competitor_Activity__c updatedCa2 = [SELECT Id, MRP__c FROM Competitor_Activity__c WHERE Id = :ca2.Id];
        System.assertEquals(40.00, updatedCa2.MRP__c);
    }
}