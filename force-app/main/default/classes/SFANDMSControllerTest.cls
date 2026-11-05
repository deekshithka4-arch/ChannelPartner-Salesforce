@isTest
private class SFANDMSControllerTest {
    @TestSetup
    static void setupData() {
        Geography__c geo = new Geography__c(
            Name = 'Karnataka Zone 1',
            Nation__c = 'India',
            State__c = 'Karnataka',
            District__c = 'Bengaluru Urban',
            Town__c = 'Bengaluru',
            Municipal__c = 'BBMP',
            Village__c = 'Koramangala'
        );
        insert geo;

        Employee__c managerEmp = new Employee__c(
            Name = 'Manager Ram',
            Aadhaar_Number__c = '987654321098',
            PAN_Number__c = 'MNBVC5678X',
            Phone_Number__c = '9876543299',
            Emergency_Contact__c = '9123456799',
            Geography__c = geo.Id,
            Distributor__c = 'Bangalore Central Distributors',
            Lead_Owner__c = UserInfo.getUserId(),
            Status__c = 'Approved'
        );
        insert managerEmp;

        Employee__c emp = new Employee__c(
            Name = 'Viresh',
            Aadhaar_Number__c = '123456789012',
            PAN_Number__c = 'ABCDE1234F',
            Phone_Number__c = '9876543210',
            Emergency_Contact__c = '9123456789',
            Geography__c = geo.Id,
            Distributor__c = 'Bangalore Central Distributors',
            Reporting_Manager__c = managerEmp.Id,
            Lead_Owner__c = UserInfo.getUserId(),
            Status__c = 'Pending'
        );
        insert emp;

        Beat__c beat = new Beat__c(
            Name = 'South Beat 1',
            Beat_Name__c = 'South Beat 1',
            Beat_Assigned_To__c = emp.Id
        );
        insert beat;

        Outlet__c outlet = new Outlet__c(
            Name = 'Metro Store',
            Outlet_Name__c = 'Metro Store',
            Outlet_Owner_Name__c = 'Ramesh',
            Contact_No__c = '9876543211',
            Email__c = 'ramesh@metro.com',
            Aadhaar__c = '123456789012',
            PAN__c = 'ABCDE1234F',
            Geography__c = geo.Id,
            Beat__c = beat.Id
        );
        insert outlet;

        PJP__c pjp = new PJP__c(
            Name = 'PJP - Viresh - Oct 2026',
            Employee__c = emp.Id,
            Lead_Owner__c = UserInfo.getUserId(),
            Status__c = 'Draft'
        );
        insert pjp;
    }

    @isTest
    static void testGetInitialData() {
        Test.startTest();
        SFANDMSController.InitPayload payload = SFANDMSController.getInitialData();
        Test.stopTest();

        System.assertNotEquals(null, payload, 'Payload should not be null');
        System.assert(payload.employees.size() > 0, 'Employees should be fetched');
        System.assert(payload.geographies.size() > 0, 'Geographies should be fetched');
        System.assert(payload.beats.size() > 0, 'Beats should be fetched');
        System.assert(payload.outlets.size() > 0, 'Outlets should be fetched');
        System.assert(payload.pjps.size() > 0, 'PJPs should be fetched');
    }

    @isTest
    static void testGetEmployeeDetails() {
        Employee__c emp = [SELECT Id FROM Employee__c WHERE Name = 'Viresh' LIMIT 1];
        Test.startTest();
        Employee__c result = SFANDMSController.getEmployeeDetails(emp.Id);
        Test.stopTest();

        System.assertEquals('Viresh', result.Name);
        System.assertEquals('Bangalore Central Distributors', result.Distributor__c);
    }

    @isTest
    static void testBeatAutoPopulationTrigger() {
        Beat__c beat = [SELECT Id, Distributor__c, Geography__c FROM Beat__c LIMIT 1];
        System.assertEquals('Bangalore Central Distributors', beat.Distributor__c, 'Distributor should auto-populate from employee');
        System.assertNotEquals(null, beat.Geography__c, 'Geography should auto-populate from employee');
    }

    @isTest
    static void testOutletAutoPopulationTrigger() {
        Beat__c beat = [SELECT Id, Geography__c FROM Beat__c LIMIT 1];
        System.assertNotEquals(null, beat.Geography__c, 'Beat should have geography');

        Test.startTest();
        // Insert outlet with Beat only, excluding Geography
        Outlet__c outletNoGeo = new Outlet__c(
            Name = 'Quick Mart',
            Outlet_Owner_Name__c = 'Deepak',
            Beat__c = beat.Id
        );
        insert outletNoGeo;
        Test.stopTest();

        Outlet__c queriedOutlet = [SELECT Id, Geography__c, Beat__c FROM Outlet__c WHERE Id = :outletNoGeo.Id];
        System.assertEquals(beat.Geography__c, queriedOutlet.Geography__c, 'Outlet geography must auto-populate from Beat!');
    }

    @isTest
    static void testApprovalFlow() {
        PJP__c pjp = [SELECT Id, Employee__c FROM PJP__c LIMIT 1];
        
        Test.startTest();
        // 0. Test get approval details
        Map<String, Object> details = SFANDMSController.getPJPApprovalDetails(pjp.Id);
        System.assertEquals(true, details.get('hasReportingManager'));
        System.assertEquals(true, details.get('canSubmit'));

        // 1. Submit for approval -> Changes PJP status to Submitted and Employee remains Pending
        Map<String, Object> subResult = SFANDMSController.submitPJPForApproval(pjp.Id);
        System.assertEquals(true, subResult.get('success'));

        PJP__c submittedPjp = [SELECT Status__c, Approval_Comments__c, Approval_Date__c FROM PJP__c WHERE Id = :pjp.Id];
        System.assertEquals('Submitted', submittedPjp.Status__c, 'PJP status must be Submitted after submit!');

        Employee__c emp = [SELECT Status__c, PJP__c FROM Employee__c WHERE Id = :pjp.Employee__c];
        System.assertEquals('Pending', emp.Status__c, 'Employee status must remain Pending until manual approval!');

        // 2. Test manual approve method -> Changes PJP status to Approved and Employee to Approved
        Map<String, Object> appResult = SFANDMSController.approvePJP(pjp.Id, 'Looks good, approved.');
        System.assertEquals(true, appResult.get('success'));

        PJP__c approvedPjp = [SELECT Status__c, Approval_Comments__c, Approval_Date__c FROM PJP__c WHERE Id = :pjp.Id];
        System.assertEquals('Approved', approvedPjp.Status__c, 'PJP status must be Approved after manual approval!');
        System.assertNotEquals(null, approvedPjp.Approval_Date__c);

        Employee__c approvedEmp = [SELECT Status__c, PJP__c FROM Employee__c WHERE Id = :pjp.Employee__c];
        System.assertEquals('Approved', approvedEmp.Status__c, 'Employee status must update to Approved!');
        System.assertEquals(pjp.Id, approvedEmp.PJP__c, 'Employee PJP lookup must update to approved PJP!');

        // 3. Test reject method
        Map<String, Object> rejResult = SFANDMSController.rejectPJP(pjp.Id, 'Rejected due to issues.');
        System.assertEquals(true, rejResult.get('success'));

        Employee__c rejectedEmp = [SELECT Status__c FROM Employee__c WHERE Id = :pjp.Employee__c];
        System.assertEquals('Rejected', rejectedEmp.Status__c);
        Test.stopTest();
    }

    @isTest
    static void testCreateMethods() {
        Geography__c geo = new Geography__c(
            Name = 'Delhi North',
            Nation__c = 'India',
            State__c = 'Delhi'
        );
        Geography__c createdGeo = SFANDMSController.createGeography(geo);
        System.assertNotEquals(null, createdGeo.Id);

        Employee__c newEmp = new Employee__c(
            Name = 'Anita',
            Aadhaar_Number__c = '987654321098',
            PAN_Number__c = 'ZYXWV9876A',
            Phone_Number__c = '9998887776',
            Distributor__c = 'Delhi Distributors',
            Geography__c = createdGeo.Id
        );
        Employee__c createdEmp = SFANDMSController.createEmployee(newEmp);
        System.assertNotEquals(null, createdEmp.Id);

        Beat__c newBeat = new Beat__c(
            Name = 'Delhi Beat 1',
            Beat_Name__c = 'Delhi Beat 1',
            Beat_Assigned_To__c = createdEmp.Id
        );
        Beat__c createdBeat = SFANDMSController.createBeat(newBeat);
        System.assertNotEquals(null, createdBeat.Id);
        System.assertNotEquals(null, createdBeat.Beat_ID__c, 'Beat ID should be auto-generated');
        System.assertEquals('Delhi Distributors', createdBeat.Distributor__c);

        Outlet__c newOutlet = new Outlet__c(
            Name = 'Delhi Supermart',
            Outlet_Name__c = 'Delhi Supermart',
            Outlet_Owner_Name__c = 'Suresh',
            Contact_No__c = '8887776665',
            Email__c = 'suresh@delhi.com',
            Geography__c = createdGeo.Id,
            Beat__c = createdBeat.Id
        );
        Outlet__c createdOutlet = SFANDMSController.createOutlet(newOutlet, 28.7041, 77.1025);
        System.assertNotEquals(null, createdOutlet.Id);

        PJP__c newPjp = new PJP__c(
            Name = 'PJP - Anita - Nov 2026',
            Employee__c = createdEmp.Id,
            Lead_Owner__c = UserInfo.getUserId()
        );
        PJP__c createdPjp = SFANDMSController.createPJP(newPjp);
        System.assertNotEquals(null, createdPjp.Id);

        // Test Profile Picture Upload
        String sampleBase64 = EncodingUtil.base64Encode(Blob.valueOf('FakeImageData'));
        Map<String, Object> uploadResult = SFANDMSController.uploadProfilePicture(createdEmp.Id, 'avatar.png', sampleBase64);
        System.assertEquals(true, uploadResult.get('success'));
        System.assertNotEquals(null, uploadResult.get('imageUrl'));
    }
}