@isTest
private class PJPTriggerTest {

    @isTest
    static void testPJPTriggerAutoLeadOwnerAndApproval() {
        Geography__c geo = new Geography__c(
            Name = 'Karnataka Test',
            Nation__c = 'India',
            State__c = 'Karnataka'
        );
        insert geo;

        // Manager Employee
        Employee__c mgr = new Employee__c(
            Name = 'Test Manager',
            Aadhaar_Number__c = '111122223333',
            PAN_Number__c = 'AAAAA1111A',
            Phone_Number__c = '9111111111',
            Emergency_Contact__c = '9222222222',
            Geography__c = geo.Id,
            Lead_Owner__c = UserInfo.getUserId(),
            Status__c = 'Approved'
        );
        insert mgr;

        // Subordinate Employee
        Employee__c emp = new Employee__c(
            Name = 'Test Subordinate',
            Aadhaar_Number__c = '444455556666',
            PAN_Number__c = 'BBBBB2222B',
            Phone_Number__c = '9333333333',
            Emergency_Contact__c = '9444444444',
            Geography__c = geo.Id,
            Reporting_Manager__c = mgr.Id,
            Status__c = 'Pending'
        );
        insert emp;

        Test.startTest();
        // Insert PJP without Lead Owner -> Trigger should auto-populate from mgr.Lead_Owner__c
        PJP__c pjp = new PJP__c(
            Name = 'Test Subordinate PJP',
            Employee__c = emp.Id,
            Status__c = 'Draft'
        );
        insert pjp;

        PJP__c queriedPjp = [SELECT Id, Lead_Owner__c, Status__c FROM PJP__c WHERE Id = :pjp.Id];
        System.assertEquals(UserInfo.getUserId(), queriedPjp.Lead_Owner__c, 'Lead owner should auto-populate from Manager user');

        // Update PJP Status to Approved -> Trigger should convert Employee Status to Approved!
        queriedPjp.Status__c = 'Approved';
        update queriedPjp;
        Test.stopTest();

        Employee__c updatedEmp = [SELECT Id, Status__c, PJP__c FROM Employee__c WHERE Id = :emp.Id];
        System.assertEquals('Approved', updatedEmp.Status__c, 'Employee status must update from Pending to Approved!');
        System.assertEquals(queriedPjp.Id, updatedEmp.PJP__c, 'Employee PJP lookup must auto-populate with approved PJP!');
    }
}