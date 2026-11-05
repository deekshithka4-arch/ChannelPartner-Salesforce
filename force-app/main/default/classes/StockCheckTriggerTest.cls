@isTest
private class StockCheckTriggerTest {
    @isTest
    static void testStockCheckSyncAndDefaults() {
        Geography__c geo = new Geography__c(
            Name = 'Bengaluru South Test Geo 2',
            Nation__c = 'India',
            State__c = 'Karnataka',
            District__c = 'Bengaluru',
            Town__c = 'Bengaluru',
            Municipal__c = 'BBMP'
        );
        insert geo;

        Outlet__c outlet = new Outlet__c(
            Name = 'Mega Retail Mart',
            Geography__c = geo.Id,
            Outlet_Name__c = 'Mega Retail Mart',
            Contact_No__c = '9876543210'
        );
        insert outlet;

        Product__c prod = new Product__c(
            Name = 'Parle-G Original Glucose',
            Product_Name__c = 'Parle-G Original Glucose',
            Product_Code__c = 'PG-GLU-250',
            Brand__c = 'Parle'
        );
        insert prod;

        // Test 1: Insert with Lookups - verifies Outlet_Name__c and Product_Name__c sync and defaults
        Stock_Check__c sc1 = new Stock_Check__c(
            Outlet__c = outlet.Id,
            Product__c = prod.Id,
            Quantity__c = 150
        );
        insert sc1;

        Stock_Check__c insertedSc1 = [SELECT Id, Outlet_Name__c, Product_Name__c, How_Many_Qty__c, Manufacturing_Date__c FROM Stock_Check__c WHERE Id = :sc1.Id];
        System.assertEquals('Mega Retail Mart', insertedSc1.Outlet_Name__c);
        System.assertEquals('Parle-G Original Glucose', insertedSc1.Product_Name__c);
        System.assertEquals(150, insertedSc1.How_Many_Qty__c);
        System.assertNotEquals(null, insertedSc1.Manufacturing_Date__c);

        // Test 2: Insert with Names - verifies lookup resolution
        Stock_Check__c sc2 = new Stock_Check__c(
            Outlet_Name__c = 'Mega Retail Mart',
            Product_Name__c = 'Parle-G Original Glucose',
            Quantity__c = 75,
            Manufacturing_Date__c = Date.today().addDays(-15)
        );
        insert sc2;

        Stock_Check__c insertedSc2 = [SELECT Id, Outlet__c, Product__c, Quantity__c FROM Stock_Check__c WHERE Id = :sc2.Id];
        System.assertEquals(outlet.Id, insertedSc2.Outlet__c);
        System.assertEquals(prod.Id, insertedSc2.Product__c);

        // Test 3: Update
        sc2.Quantity__c = 80;
        update sc2;

        Stock_Check__c updatedSc2 = [SELECT Id, Quantity__c FROM Stock_Check__c WHERE Id = :sc2.Id];
        System.assertEquals(80, updatedSc2.Quantity__c);
    }
}