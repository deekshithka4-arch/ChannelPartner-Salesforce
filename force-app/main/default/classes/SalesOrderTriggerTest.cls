@isTest
private class SalesOrderTriggerTest {
    @isTest
    static void testSalesOrderSyncAndCalculation() {
        Geography__c geo = new Geography__c(
            Name = 'Bengaluru South Test',
            Nation__c = 'India',
            State__c = 'Karnataka',
            District__c = 'Bengaluru',
            Town__c = 'Bengaluru',
            Municipal__c = 'BBMP'
        );
        insert geo;

        Outlet__c outlet = new Outlet__c(
            Name = 'Test Super Mart',
            Geography__c = geo.Id,
            Outlet_Name__c = 'Test Super Mart',
            Contact_No__c = '9876543210'
        );
        insert outlet;

        Product__c prod = new Product__c(
            Name = 'Test Biscuit 100g',
            Product_Name__c = 'Test Biscuit 100g',
            Product_Code__c = 'SKU-TB-100',
            Brand__c = 'Parle'
        );
        insert prod;

        Sales_Order__c so1 = new Sales_Order__c(
            Outlet__c = outlet.Id,
            Product__c = prod.Id,
            Total_Qty__c = 10,
            Gross_Amount__c = 500,
            Tax_Amount__c = 90,
            Schemes_Any__c = 'None'
        );
        insert so1;

        Sales_Order__c insertedSo1 = [SELECT Id, Outlet_Name__c, Product_Name__c, SKU__c, Total_Amount__c FROM Sales_Order__c WHERE Id = :so1.Id];
        System.assertEquals('Test Super Mart', insertedSo1.Outlet_Name__c);
        System.assertEquals('Test Biscuit 100g', insertedSo1.Product_Name__c);
        System.assertEquals('SKU-TB-100', insertedSo1.SKU__c);
        System.assertEquals(590, insertedSo1.Total_Amount__c);

        Sales_Order__c so2 = new Sales_Order__c(
            Outlet_Name__c = 'Test Super Mart',
            Product_Name__c = 'Test Biscuit 100g',
            Total_Qty__c = 5,
            Gross_Amount__c = 250,
            Tax_Amount__c = 45
        );
        insert so2;

        Sales_Order__c insertedSo2 = [SELECT Id, Outlet__c, Product__c, SKU__c FROM Sales_Order__c WHERE Id = :so2.Id];
        System.assertEquals(outlet.Id, insertedSo2.Outlet__c);
        System.assertEquals(prod.Id, insertedSo2.Product__c);

        so2.Gross_Amount__c = 300;
        so2.Total_Amount__c = null;
        update so2;

        Sales_Order__c updatedSo2 = [SELECT Id, Total_Amount__c FROM Sales_Order__c WHERE Id = :so2.Id];
        System.assertEquals(345, updatedSo2.Total_Amount__c);

        Sales_Order__c so3 = new Sales_Order__c(
            Outlet_Name__c = 'Test Super Mart',
            Product_Name__c = 'Test Biscuit 100g',
            Total_Qty__c = 4,
            Gross_Amount__c = 110.50,
            Total_Amount__c = 130.39
        );
        insert so3;

        Sales_Order__c insertedSo3 = [SELECT Id, Tax_Amount__c FROM Sales_Order__c WHERE Id = :so3.Id];
        System.assertEquals(19.89, insertedSo3.Tax_Amount__c);
    }
}