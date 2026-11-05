@isTest
private class PrimaryOrderTriggerTest {
    @isTest
    static void testTaxAndAmountCalculation() {
        Primary_Order__c po = new Primary_Order__c(
            Distributor_Name__c = 'Bhavani Distributor',
            Per_Case_Price__c = 10,
            Total_Cases__c = 12,
            Tax_Percentage__c = 10
        );
        insert po;
        
        Primary_Order__c insertedPo = [SELECT Gross_Amount__c, Tax_Amount__c, Total_Amount__c FROM Primary_Order__c WHERE Id = :po.Id];
        System.assertEquals(120.00, insertedPo.Gross_Amount__c, 'Gross amount should be 120');
        System.assertEquals(12.00, insertedPo.Tax_Amount__c, 'Tax amount should be 12');
        System.assertEquals(132.00, insertedPo.Total_Amount__c, 'Total amount should be 132');
        
        // Test update: user enters 5% tax on 23,600 gross
        insertedPo.Gross_Amount__c = 23600.00;
        insertedPo.Tax_Percentage__c = 5.00;
        update insertedPo;
        
        Primary_Order__c updatedPo = [SELECT Gross_Amount__c, Tax_Amount__c, Total_Amount__c FROM Primary_Order__c WHERE Id = :po.Id];
        System.assertEquals(1180.00, updatedPo.Tax_Amount__c, 'Tax amount should be 1180 for 5% of 23600');
        System.assertEquals(24780.00, updatedPo.Total_Amount__c, 'Total amount should be 24780');

        // Test Partially Paid: Gross 20,400 + Tax 1,020 = 21,420, minus 5,000 = 16,420 (from user screenshot PO-0004)
        updatedPo.Gross_Amount__c = 20400.00;
        updatedPo.Tax_Percentage__c = 5.00;
        updatedPo.Payment_Status__c = 'Partially Paid';
        updatedPo.Partially_Paid_Amount__c = 5000.00;
        update updatedPo;

        Primary_Order__c partialPo = [SELECT Gross_Amount__c, Tax_Amount__c, Total_Amount__c, Partially_Paid_Amount__c FROM Primary_Order__c WHERE Id = :po.Id];
        System.assertEquals(1020.00, partialPo.Tax_Amount__c, 'Tax amount should be 1020');
        System.assertEquals(16420.00, partialPo.Total_Amount__c, 'Total amount should be 21420 - 5000 = 16420');
    }
}