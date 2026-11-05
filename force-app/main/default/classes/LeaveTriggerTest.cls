@isTest
private class LeaveTriggerTest {
    @isTest
    static void testLeaveSyncAndDefaults() {
        Geography__c geo = new Geography__c(
            Name = 'Bengaluru South Test Geo 6',
            Nation__c = 'India',
            State__c = 'Karnataka',
            District__c = 'Bengaluru',
            Town__c = 'Bengaluru',
            Municipal__c = 'BBMP'
        );
        insert geo;

        Employee__c emp = new Employee__c(
            Name = 'Suresh Nair',
            Geography__c = geo.Id,
            Phone_Number__c = '9876543214',
            Aadhaar_Number__c = '123456789013',
            PAN_Number__c = 'ABCDE1234G'
        );
        insert emp;

        // Test 1: Insert with Employee__c Lookup - verifies Employee_Name__c sync and custom values
        Leave__c l1 = new Leave__c(
            Employee__c = emp.Id,
            Leave_Date__c = Date.newInstance(2026, 10, 15),
            Type__c = 'Sick Leave',
            Status__c = 'Approved',
            Approver_Name__c = 'Ashok (Branch Manager)',
            Reason__c = 'Medical checkup and viral fever recovery'
        );
        insert l1;

        Leave__c insertedL1 = [SELECT Id, Name, Employee_Name__c, Leave_Date__c, Date__c, Type__c, Leave_Type__c, Status__c, Approver_Name__c, Reason__c FROM Leave__c WHERE Id = :l1.Id];
        System.assertEquals('Suresh Nair', insertedL1.Employee_Name__c);
        System.assertEquals('Sick Leave', insertedL1.Type__c);
        System.assertEquals('Sick Leave', insertedL1.Leave_Type__c);
        System.assertEquals('Approved', insertedL1.Status__c);
        System.assertEquals(Date.newInstance(2026, 10, 15), insertedL1.Date__c);

        // Test 2: Insert with Employee_Name__c text - verifies lookup resolution and defaults
        Leave__c l2 = new Leave__c(
            Employee_Name__c = 'Suresh Nair'
        );
        insert l2;

        Leave__c insertedL2 = [SELECT Id, Employee__c, Employee_Name__c, Leave_Date__c, Type__c, Status__c, Approver_Name__c FROM Leave__c WHERE Id = :l2.Id];
        System.assertEquals(emp.Id, insertedL2.Employee__c);
        System.assertEquals(Date.today(), insertedL2.Leave_Date__c);
        System.assertEquals('Casual Leave', insertedL2.Type__c);
        System.assertEquals('Hold', insertedL2.Status__c);
        System.assertNotEquals(null, insertedL2.Approver_Name__c);

        // Test 3: Update
        l2.Status__c = 'Rejected';
        update l2;

        Leave__c updatedL2 = [SELECT Id, Status__c FROM Leave__c WHERE Id = :l2.Id];
        System.assertEquals('Rejected', updatedL2.Status__c);
    }
}