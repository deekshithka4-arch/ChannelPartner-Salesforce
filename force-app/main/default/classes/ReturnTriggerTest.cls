@isTest
private class ReturnTriggerTest {
    @isTest
    static void testReturnSyncAndDefaults() {
        Geography__c geo = new Geography__c(
            Name = 'Bengaluru South Test Geo 4',
            Nation__c = 'India',
            State__c = 'Karnataka',
            District__c = 'Bengaluru',
            Town__c = 'Bengaluru',
            Municipal__c = 'BBMP'
        );
        insert geo;

        Outlet__c outlet = new Outlet__c(
            Name = 'Super Retail Mart',
            Geography__c = geo.Id,
            Outlet_Name__c = 'Super Retail Mart',
            Contact_No__c = '9876543212'
        );
        insert outlet;

        Product__c prod = new Product__c(
            Name = 'Britannia Bourbon Chocolate',
            Product_Name__c = 'Britannia Bourbon Chocolate',
            Product_Code__c = 'BR-BOUR-200',
            Brand__c = 'Britannia'
        );
        insert prod;

        // Test 1: Insert with Lookups - verifies name sync and defaults
        Return__c ret1 = new Return__c(
            Outlet__c = outlet.Id,
            Product__c = prod.Id,
            Quantity__c = 25,
            Return_Reason__c = 'Damaged Packaging'
        );
        insert ret1;

        Return__c insertedRet1 = [SELECT Id, Name, Outlet_Name__c, Product_Name__c, Quantity__c, How_Many_Qty__c, Manufacturing_Date__c, Return_Reason__c FROM Return__c WHERE Id = :ret1.Id];
        System.assertEquals('Super Retail Mart', insertedRet1.Outlet_Name__c);
        System.assertEquals('Britannia Bourbon Chocolate', insertedRet1.Product_Name__c);
        System.assertEquals(25, insertedRet1.How_Many_Qty__c);
        System.assertEquals('Damaged Packaging', insertedRet1.Return_Reason__c);
        System.assertNotEquals(null, insertedRet1.Manufacturing_Date__c);

        // Test 2: Insert with Names - verifies lookup resolution
        Return__c ret2 = new Return__c(
            Outlet_Name__c = 'Super Retail Mart',
            Product_Name__c = 'Britannia Bourbon Chocolate',
            Quantity__c = 10,
            Manufacturing_Date__c = Date.today().addDays(-45),
            Return_Reason__c = 'Expired / Near Expiry'
        );
        insert ret2;

        Return__c insertedRet2 = [SELECT Id, Outlet__c, Product__c, Quantity__c, Return_Reason__c FROM Return__c WHERE Id = :ret2.Id];
        System.assertEquals(outlet.Id, insertedRet2.Outlet__c);
        System.assertEquals(prod.Id, insertedRet2.Product__c);
        System.assertEquals(10, insertedRet2.Quantity__c);
        System.assertEquals('Expired / Near Expiry', insertedRet2.Return_Reason__c);

        // Test 3: Update
        ret2.Quantity__c = 15;
        update ret2;

        Return__c updatedRet2 = [SELECT Id, Quantity__c FROM Return__c WHERE Id = :ret2.Id];
        System.assertEquals(15, updatedRet2.Quantity__c);
    }
}