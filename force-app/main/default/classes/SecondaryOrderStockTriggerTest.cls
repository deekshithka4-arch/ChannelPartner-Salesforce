@isTest
private class SecondaryOrderStockTriggerTest {
    @isTest
    static void testStockDeductionOnSecondaryOrder() {
        DMS_Stock__c stock = new DMS_Stock__c(
            Distributor_Name__c = 'Test Distributor Co',
            Product_Name__c = 'Test Biscuit SKU',
            Purchased_Cases__c = 90,
            Supplied_Cases__c = 0,
            Remaining_Cases__c = 90,
            Full_Cases_In_Stock__c = 90,
            Pieces_Per_Case__c = 24,
            Stock_Status__c = 'In Stock'
        );
        insert stock;

        Test.startTest();
        Secondary_Order__c so = new Secondary_Order__c(
            Outlet_Name__c = 'Test Retail Outlet',
            Distributor_Name__c = 'Test Distributor Co',
            Product_Name__c = 'Test Biscuit SKU',
            Quantity__c = 5,
            Unit_Type__c = 'Cases',
            Status__c = 'Pending'
        );
        insert so;
        Test.stopTest();

        DMS_Stock__c updatedStock = [
            SELECT Id, Purchased_Cases__c, Supplied_Cases__c, Remaining_Cases__c 
            FROM DMS_Stock__c 
            WHERE Id = :stock.Id
        ];
        System.assertEquals(5, updatedStock.Supplied_Cases__c, 'Supplied cases should be 5');
        System.assertEquals(85, updatedStock.Remaining_Cases__c, 'Remaining cases should be 85 (90 - 5 = 85)');
    }
}