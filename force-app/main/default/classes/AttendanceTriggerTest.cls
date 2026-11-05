@isTest
private class AttendanceTriggerTest {
    @isTest
    static void testAttendanceSyncAndDefaults() {
        Geography__c geo = new Geography__c(
            Name = 'Bengaluru South Test Geo 5',
            Nation__c = 'India',
            State__c = 'Karnataka',
            District__c = 'Bengaluru',
            Town__c = 'Bengaluru',
            Municipal__c = 'BBMP'
        );
        insert geo;

        Employee__c emp = new Employee__c(
            Name = 'Vikram Patil',
            Geography__c = geo.Id,
            Phone_Number__c = '9876543213',
            Aadhaar_Number__c = '123456789012',
            PAN_Number__c = 'ABCDE1234F'
        );
        insert emp;

        // Test 1: Insert with Employee__c Lookup - verifies Employee_Name__c sync, hours calculation, and status default
        Attendance__c a1 = new Attendance__c(
            Employee__c = emp.Id,
            Start_Time__c = Datetime.newInstance(2026, 10, 8, 9, 0, 0),
            End_Time__c = Datetime.newInstance(2026, 10, 8, 18, 0, 0),
            Geo_Location__Latitude__s = 12.971600,
            Geo_Location__Longitude__s = 77.594600
        );
        insert a1;

        Attendance__c insertedA1 = [SELECT Id, Name, Employee_Name__c, Status__c, Total_Hours__c, Attendance_Date__c, Geo_Location__Latitude__s, Geo_Location__Longitude__s FROM Attendance__c WHERE Id = :a1.Id];
        System.assertEquals('Vikram Patil', insertedA1.Employee_Name__c);
        System.assertEquals('Present', insertedA1.Status__c);
        System.assertEquals(9.00, insertedA1.Total_Hours__c);
        System.assertEquals(Date.newInstance(2026, 10, 8), insertedA1.Attendance_Date__c);

        // Test 2: Insert with Employee_Name__c text - verifies lookup resolution and location/time defaults
        Attendance__c a2 = new Attendance__c(
            Employee_Name__c = 'Vikram Patil'
        );
        insert a2;

        Attendance__c insertedA2 = [SELECT Id, Employee__c, Employee_Name__c, Start_Time__c, Status__c, Geo_Location__Latitude__s, Geo_Location__Longitude__s FROM Attendance__c WHERE Id = :a2.Id];
        System.assertEquals(emp.Id, insertedA2.Employee__c);
        System.assertNotEquals(null, insertedA2.Start_Time__c);
        System.assertEquals('Present', insertedA2.Status__c);
        System.assertEquals(12.971600, insertedA2.Geo_Location__Latitude__s);

        // Test 3: Update
        a2.Status__c = 'Half Day';
        update a2;

        Attendance__c updatedA2 = [SELECT Id, Status__c FROM Attendance__c WHERE Id = :a2.Id];
        System.assertEquals('Half Day', updatedA2.Status__c);
    }
}