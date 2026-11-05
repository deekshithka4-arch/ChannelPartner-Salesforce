public with sharing class SFANDMSController {
    
    public class InitPayload {
        @AuraEnabled public List<Employee__c> employees;
        @AuraEnabled public List<Geography__c> geographies;
        @AuraEnabled public List<Beat__c> beats;
        @AuraEnabled public List<Outlet__c> outlets;
        @AuraEnabled public List<PJP__c> pjps;
        @AuraEnabled public List<Distributor__c> distributors;
        @AuraEnabled public List<Primary_Order__c> primaryOrders;
        @AuraEnabled public List<Primary_Return__c> primaryReturns;
        @AuraEnabled public List<DMS_Ticket__c> dmsTickets;
        @AuraEnabled public List<Sales_Order__c> secondaryOrders;
        @AuraEnabled public List<Distributor_Stock__c> distributorStocks;
        @AuraEnabled public List<DMS_Stock__c> dmsStocks;
        @AuraEnabled public List<Secondary_Order__c> secondaryOrderRecords;
        @AuraEnabled public List<DMS_Return__c> dmsReturns;
        @AuraEnabled public List<Sales_Return__c> salesReturns;
        @AuraEnabled public List<Product__c> products;
        @AuraEnabled public List<Distributor_Officer_Login__c> distributorOfficers;
        @AuraEnabled public List<Distributor_Primary_Approval__c> primaryApprovals;
        @AuraEnabled public List<Distributor_Return_Approval__c> returnApprovals;
        @AuraEnabled public List<UserSummary> users;
        @AuraEnabled public String currentUserName;
        @AuraEnabled public String currentUserEmail;
    }

    public class UserSummary {
        @AuraEnabled public Id id;
        @AuraEnabled public String name;
        @AuraEnabled public String username;
        @AuraEnabled public String email;
    }

    @AuraEnabled(cacheable=true)
    public static InitPayload getInitialData() {
        InitPayload payload = new InitPayload();
        payload.currentUserName = UserInfo.getName();
        payload.currentUserEmail = UserInfo.getUserEmail();

        payload.employees = [
            SELECT Id, Name, Aadhaar_Number__c, PAN_Number__c, Phone_Number__c, Emergency_Contact__c,
                   Geography__c, Geography__r.Name, Hierarchy__c, Employee_Level__c, Access_Channel__c, Reporting_Manager__c, Reporting_Manager__r.Name,
                   Lead_Owner__c, Lead_Owner__r.Name,
                   Distributor__c, PJP__c, PJP__r.Name, Profile_Picture__c, Status__c, CreatedDate
            FROM Employee__c
            WITH USER_MODE
            ORDER BY CreatedDate DESC
        ];

        payload.geographies = [
            SELECT Id, Name, Nation__c, State__c, District__c, Town__c, Municipal__c, Village__c, CreatedDate
            FROM Geography__c
            WITH USER_MODE
            ORDER BY Name ASC
        ];

        payload.beats = [
            SELECT Id, Name, Beat_ID__c, Beat_Name__c, Beat_Assigned_To__c, Beat_Assigned_To__r.Name,
                   Distributor__c, Geography__c, Geography__r.Name, CreatedDate
            FROM Beat__c
            WITH USER_MODE
            ORDER BY CreatedDate DESC
        ];

        payload.outlets = [
            SELECT Id, Name, Outlet_Name__c, Outlet_Owner_Name__c, Contact_No__c, Email__c,
                   Aadhaar__c, PAN__c, Geo_Location__Latitude__s, Geo_Location__Longitude__s,
                   Geography__c, Geography__r.Name, Beat__c, Beat__r.Name, CreatedDate
            FROM Outlet__c
            WITH USER_MODE
            ORDER BY CreatedDate DESC
        ];

        payload.pjps = [
            SELECT Id, Name, Employee__c, Employee__r.Name, Employee__r.Status__c,
                   Lead_Owner__c, Lead_Owner__r.Name, Lead_Owner__r.Email,
                   Status__c, Approval_Comments__c, Approval_Date__c, CreatedDate
            FROM PJP__c
            WITH USER_MODE
            ORDER BY CreatedDate DESC
        ];

        payload.distributors = [
            SELECT Id, Name, Distributor_Code__c, Distributor_Owner_Name__c, Mobile_Number__c, Contact_Person__c, Email__c, Phone__c,
                   GSTIN__c, Address__c, City__c, State__c, Pincode__c, Distributor_Officer__c,
                   Max_Outlets__c, Assigned_SR_Count__c, DMS_Portal_Enabled__c, Status__c, CreatedDate
            FROM Distributor__c
            WITH USER_MODE
            ORDER BY Name ASC
        ];

        payload.primaryOrders = [
            SELECT Id, Name, Distributor_Name__c, Employee_Name__c, Total_Cases__c,
                   Gross_Amount__c, Tax_Amount__c, Total_Amount__c, Status__c,
                   DO_Approval_Status__c, DO_Remarks__c, Approved_By__c, Items_Summary__c,
                   Primary_Scheme_Applied__c, Order_Date__c, Invoice_Number__c,
                   Dispatch_Status__c, Payment_Terms__c, Payment_Status__c,
                   Expected_Delivery_Date__c, Transporter_Name__c, LR_Number__c, CreatedDate
            FROM Primary_Order__c
            WITH USER_MODE
            ORDER BY CreatedDate DESC
        ];

        payload.primaryReturns = [
            SELECT Id, Name, Distributor_Name__c, Employee_Name__c, Product_Name__c,
                   Return_Reason__c, Cases__c, Total_Amount__c, Status__c, DO_Remarks__c,
                   Return_Date__c, Batch_Number__c, Expiry_Date__c,
                   Credit_Note_Number__c, Credit_Note_Amount__c,
                   Inspection_Status__c, Action_Taken__c, CreatedDate
            FROM Primary_Return__c
            WITH USER_MODE
            ORDER BY CreatedDate DESC
        ];

        payload.dmsTickets = [
            SELECT Id, Name, Distributor_Name__c, Category__c, Subject__c, Description__c,
                   Status__c, Priority__c, Resolution_Notes__c, Raised_By__c,
                   Contact_Number__c, Assigned_To__c, Target_Resolution_Date__c,
                   Resolution_Date__c, Customer_Satisfaction__c, CreatedDate
            FROM DMS_Ticket__c
            WITH USER_MODE
            ORDER BY CreatedDate DESC
        ];

        payload.secondaryOrders = [
            SELECT Id, Name, Outlet__c, Outlet_Name__c, Product__c, Product_Name__c,
                   Total_Amount__c, Gross_Amount__c, Tax_Amount__c, Total_Qty__c,
                   Order_Type__c, Distributor_Name__c, Distributor_Approval_Status__c,
                   Distributor_Remarks__c, Status__c, Unit_Type__c, Pieces_Per_Case__c,
                   Supplied_Pieces__c, Case_Breaking_Applied__c, Fulfillment_Status__c, CreatedDate
            FROM Sales_Order__c
            WITH USER_MODE
            ORDER BY CreatedDate DESC
            LIMIT 50
        ];

        payload.distributorStocks = [
            SELECT Id, Name, Distributor_Name__c, Product_Name__c, Pieces_Per_Case__c,
                   Purchased_Cases__c, Full_Cases_In_Stock__c, Loose_Pieces_In_Stock__c,
                   Total_Available_Pieces__c, Sold_Pieces__c, Sold_Cases__c,
                   Broken_Cases_Count__c, Stock_Status__c, CreatedDate
            FROM Distributor_Stock__c
            WITH USER_MODE
            ORDER BY Distributor_Name__c ASC, Product_Name__c ASC
        ];

        payload.dmsStocks = [
            SELECT Id, Name, Distributor_Name__c, Product_Name__c, Pieces_Per_Case__c,
                   Purchased_Cases__c, Full_Cases_In_Stock__c, Available_Packets__c,
                   Damaged_Returned_Packets__c, Case_Conversion__c,
                   Total_Available_Pieces__c, Total_Available_Cases__c, Supplied_Cases__c,
                   Supplied_Pieces__c, Damaged_Returned_Cases__c, Remaining_Cases__c,
                   Broken_Cases_Count__c, Stock_Status__c, CreatedDate
            FROM DMS_Stock__c
            WITH USER_MODE
            ORDER BY Distributor_Name__c ASC, Product_Name__c ASC
        ];

        payload.secondaryOrderRecords = [
            SELECT Id, Name, Outlet_Name__c, Distributor_Name__c, Product_Name__c,
                   Quantity__c, Unit_Type__c, Pieces_Per_Case__c, Total_Amount__c,
                   Gross_Amount__c, Tax_Amount__c, Status__c, Stock_Availability__c,
                   Supplied_Quantity__c, Remaining_Stock_After_Supply__c,
                   Case_Breaking_Applied__c, Sales_Officer_Name__c, Order_Date__c,
                   Distributor_Remarks__c, CreatedDate
            FROM Secondary_Order__c
            WITH USER_MODE
            ORDER BY CreatedDate DESC
            LIMIT 50
        ];

        payload.dmsReturns = [
            SELECT Id, Name, Distributor_Name__c, Product_Name__c, Damaged_Cases__c,
                   Return_Reason__c, Batch_Number__c, Expiry_Date__c, Total_Claim_Amount__c,
                   Status__c, Previous_Stock_Cases__c, Updated_Stock_Cases__c,
                   Credit_Note_Number__c, Credit_Note_Amount__c, Remarks__c, CreatedDate
            FROM DMS_Return__c
            WITH USER_MODE
            ORDER BY CreatedDate DESC
            LIMIT 50
        ];

        payload.salesReturns = [
            SELECT Id, Name, Outlet_Name__c, Distributor_Name__c, Product_Name__c,
                   Returned_Quantity__c, Unit_Type__c, Return_Reason__c, Batch_Number__c,
                   Total_Refund_Amount__c, Status__c, Sales_Officer_Name__c, Remarks__c, CreatedDate
            FROM Sales_Return__c
            WITH USER_MODE
            ORDER BY CreatedDate DESC
            LIMIT 50
        ];

        payload.products = [
            SELECT Id, Name, Product_Name__c, Case_Price__c, Pieces_Per_Case__c,
                   Primary_Scheme_Details__c, Product_Price_MRP__c, Product_Price_RBP__c
            FROM Product__c
            WITH USER_MODE
            ORDER BY Name ASC
        ];

        payload.distributorOfficers = [
            SELECT Id, Name, Officer_Name__c, Email__c, Username__c, Password__c,
                   Role__c, Designation__c, Status__c, Phone__c, CurrencyIsoCode, CreatedDate
            FROM Distributor_Officer_Login__c
            WITH USER_MODE
            ORDER BY Name ASC
        ];

        payload.primaryApprovals = [
            SELECT Id, Name, Distributor_Officer__c, Distributor_Officer__r.Name,
                   Primary_Order__c, Primary_Order__r.Name,
                   Primary_Order_Number__c, Distributor_Name__c, Product_Company__c, Product_Name__c,
                   Scheme_Applied__c, Order_Date__c, Invoice_Number__c,
                   Payment_Terms__c, Payment_Status__c, Dispatch_Status__c, Delivery_Status__c,
                   Transporter_Name__c, LR_Number__c, Expected_Delivery_Date__c,
                   DO_Approval_Status__c, Approval_Status__c, Approved_By__c, Approval_Date__c,
                   DO_Remarks__c, Remarks__c, Gross_Amount__c, Tax_Amount__c, Total_Amount__c,
                   Paid_Cases__c, Free_Cases__c, Total_Cases__c, Total_Pieces__c,
                   Items_Summary__c, Items_JSON__c, Barcode_Scan_Status__c, CreatedDate
            FROM Distributor_Primary_Approval__c
            WITH USER_MODE
            ORDER BY CreatedDate DESC
        ];

        payload.returnApprovals = [
            SELECT Id, Name, Distributor_Officer__c, Distributor_Officer__r.Name,
                   Return_Number__c, Distributor_Name__c, Product_Name__c,
                   Damaged_Cases__c, Return_Reason__c, Total_Claim_Amount__c,
                   Approval_Status__c, Approved_By__c, Credit_Note_Number__c,
                   Credit_Note_Amount__c, Status__c, Remarks__c, CreatedDate
            FROM Distributor_Return_Approval__c
            WITH USER_MODE
            ORDER BY CreatedDate DESC
        ];

        payload.users = new List<UserSummary>();
        for (User u : [SELECT Id, Name, Username, Email FROM User WHERE IsActive = true WITH USER_MODE ORDER BY Name ASC]) {
            UserSummary us = new UserSummary();
            us.id = u.Id;
            us.name = u.Name;
            us.username = u.Username;
            us.email = u.Email;
            payload.users.add(us);
        }

        return payload;
    }

    @AuraEnabled
    public static Employee__c getEmployeeDetails(Id employeeId) {
        if (employeeId == null) return null;
        return [
            SELECT Id, Name, Distributor__c, Geography__c, Geography__r.Name, Status__c, Phone_Number__c,
                   Lead_Owner__c, Lead_Owner__r.Name
            FROM Employee__c
            WHERE Id = :employeeId
            WITH USER_MODE
            LIMIT 1
        ];
    }

    @AuraEnabled
    public static Employee__c createEmployee(Employee__c employee) {
        if (employee == null) {
            throw new AuraHandledException('Invalid employee details.');
        }

        // Validate Aadhaar (exactly 12 numeric digits)
        if (String.isNotBlank(employee.Aadhaar_Number__c)) {
            Pattern pAadhaar = Pattern.compile('^[0-9]{12}$');
            if (employee.Aadhaar_Number__c.length() != 12 || !pAadhaar.matcher(employee.Aadhaar_Number__c).matches()) {
                throw new AuraHandledException('Aadhaar Number must be exactly 12 numeric digits.');
            }
        }

        // Validate PAN (exactly 10 alphanumeric characters)
        if (String.isNotBlank(employee.PAN_Number__c)) {
            Pattern pPan = Pattern.compile('^[a-zA-Z0-9]{10}$');
            if (employee.PAN_Number__c.length() != 10 || !pPan.matcher(employee.PAN_Number__c).matches()) {
                throw new AuraHandledException('PAN Number must be exactly 10 alphanumeric characters.');
            }
        }

        if (String.isBlank(employee.Status__c)) {
            employee.Status__c = 'Pending';
        }

        insert as user employee;
        return [
            SELECT Id, Name, Aadhaar_Number__c, PAN_Number__c, Phone_Number__c, Emergency_Contact__c,
                   Geography__c, Geography__r.Name, Hierarchy__c, Reporting_Manager__c, Reporting_Manager__r.Name,
                   Lead_Owner__c, Lead_Owner__r.Name,
                   Distributor__c, PJP__c, PJP__r.Name, Profile_Picture__c, Status__c, CreatedDate
            FROM Employee__c
            WHERE Id = :employee.Id
            WITH USER_MODE
        ];
    }

    @AuraEnabled
    public static Geography__c createGeography(Geography__c geo) {
        if (geo == null) throw new AuraHandledException('Invalid geography details.');
        insert as user geo;
        return [
            SELECT Id, Name, Nation__c, State__c, District__c, Town__c, Municipal__c, Village__c, CreatedDate
            FROM Geography__c
            WHERE Id = :geo.Id
            WITH USER_MODE
        ];
    }

    @AuraEnabled
    public static Beat__c createBeat(Beat__c beat) {
        if (beat == null) throw new AuraHandledException('Invalid beat details.');

        // If Beat Assigned To is provided, auto-fill Distributor and Geography from Employee if empty
        if (beat.Beat_Assigned_To__c != null) {
            Employee__c emp = [SELECT Id, Distributor__c, Geography__c FROM Employee__c WHERE Id = :beat.Beat_Assigned_To__c WITH USER_MODE LIMIT 1];
            if (String.isBlank(beat.Distributor__c) && String.isNotBlank(emp.Distributor__c)) {
                beat.Distributor__c = emp.Distributor__c;
            }
            if (beat.Geography__c == null && emp.Geography__c != null) {
                beat.Geography__c = emp.Geography__c;
            }
        }

        insert as user beat;
        return [
            SELECT Id, Name, Beat_ID__c, Beat_Name__c, Beat_Assigned_To__c, Beat_Assigned_To__r.Name,
                   Distributor__c, Geography__c, Geography__r.Name, CreatedDate
            FROM Beat__c
            WHERE Id = :beat.Id
            WITH USER_MODE
        ];
    }

    @AuraEnabled
    public static Outlet__c createOutlet(Outlet__c outlet, Decimal latitude, Decimal longitude) {
        if (outlet == null) throw new AuraHandledException('Invalid outlet details.');

        if (latitude != null && longitude != null) {
            outlet.Geo_Location__Latitude__s = latitude;
            outlet.Geo_Location__Longitude__s = longitude;
        }

        if (outlet.Geography__c == null && outlet.Beat__c != null) {
            Beat__c beat = [SELECT Id, Geography__c FROM Beat__c WHERE Id = :outlet.Beat__c WITH USER_MODE LIMIT 1];
            if (beat.Geography__c != null) {
                outlet.Geography__c = beat.Geography__c;
            }
        }

        insert as user outlet;
        return [
            SELECT Id, Name, Outlet_Name__c, Outlet_Owner_Name__c, Contact_No__c, Email__c,
                   Aadhaar__c, PAN__c, Geo_Location__Latitude__s, Geo_Location__Longitude__s,
                   Geography__c, Geography__r.Name, Beat__c, Beat__r.Name, CreatedDate
            FROM Outlet__c
            WHERE Id = :outlet.Id
            WITH USER_MODE
        ];
    }

    @AuraEnabled
    public static PJP__c createPJP(PJP__c pjp) {
        if (pjp == null) throw new AuraHandledException('Invalid PJP details.');
        if (String.isBlank(pjp.Status__c)) {
            pjp.Status__c = 'Draft';
        }
        insert as user pjp;
        return [
            SELECT Id, Name, Employee__c, Employee__r.Name, Employee__r.Status__c,
                   Lead_Owner__c, Lead_Owner__r.Name, Lead_Owner__r.Email,
                   Status__c, Approval_Comments__c, Approval_Date__c, CreatedDate
            FROM PJP__c
            WHERE Id = :pjp.Id
            WITH USER_MODE
        ];
    }

    @AuraEnabled
    public static Map<String, Object> getPJPApprovalDetails(Id pjpId) {
        if (pjpId == null) throw new AuraHandledException('Invalid PJP ID.');

        PJP__c pjp = [
            SELECT Id, Name, Status__c, Lead_Owner__c, Lead_Owner__r.Name,
                   Employee__c, Employee__r.Name, Employee__r.Status__c,
                   Employee__r.Reporting_Manager__c, Employee__r.Reporting_Manager__r.Name,
                   Employee__r.Reporting_Manager__r.Lead_Owner__c, Employee__r.Reporting_Manager__r.Lead_Owner__r.Name,
                   Employee__r.Reporting_Manager__r.OwnerId
            FROM PJP__c
            WHERE Id = :pjpId
            LIMIT 1
        ];

        Map<String, Object> details = new Map<String, Object>();
        details.put('pjpId', pjp.Id);
        details.put('pjpName', pjp.Name);
        details.put('pjpStatus', pjp.Status__c);
        details.put('hasEmployee', pjp.Employee__c != null);
        details.put('employeeName', pjp.Employee__c != null ? pjp.Employee__r.Name : 'No Employee Assigned');
        details.put('employeeStatus', pjp.Employee__c != null ? pjp.Employee__r.Status__c : 'N/A');
        
        Boolean hasManager = (pjp.Employee__c != null && pjp.Employee__r.Reporting_Manager__c != null);
        details.put('hasReportingManager', hasManager);
        details.put('reportingManagerName', hasManager ? pjp.Employee__r.Reporting_Manager__r.Name : 'None');

        String approverName = 'None';
        Id approverUserId = null;
        if (hasManager) {
            if (pjp.Employee__r.Reporting_Manager__r.Lead_Owner__c != null) {
                approverUserId = pjp.Employee__r.Reporting_Manager__r.Lead_Owner__c;
                approverName = pjp.Employee__r.Reporting_Manager__r.Lead_Owner__r.Name;
            } else if (pjp.Employee__r.Reporting_Manager__r.OwnerId != null) {
                approverUserId = pjp.Employee__r.Reporting_Manager__r.OwnerId;
                List<User> uList = [SELECT Id, Name FROM User WHERE Id = :approverUserId LIMIT 1];
                if (!uList.isEmpty()) approverName = uList[0].Name;
            }
        }
        if (approverUserId == null && pjp.Lead_Owner__c != null) {
            approverUserId = pjp.Lead_Owner__c;
            approverName = pjp.Lead_Owner__r != null ? pjp.Lead_Owner__r.Name : 'Lead Owner';
        }

        details.put('approverUserId', approverUserId);
        details.put('approverUserName', approverName);
        details.put('canSubmit', pjp.Employee__c != null && hasManager && approverUserId != null);

        return details;
    }

    @AuraEnabled
    public static Map<String, Object> submitPJPForApproval(Id pjpId) {
        if (pjpId == null) throw new AuraHandledException('Invalid PJP ID.');

        PJP__c pjp = [
            SELECT Id, Name, Status__c, Lead_Owner__c, Lead_Owner__r.Name,
                   Employee__c, Employee__r.Name, Employee__r.Status__c,
                   Employee__r.Reporting_Manager__c, Employee__r.Reporting_Manager__r.Name,
                   Employee__r.Reporting_Manager__r.Lead_Owner__c, Employee__r.Reporting_Manager__r.Lead_Owner__r.Name,
                   Employee__r.Reporting_Manager__r.OwnerId
            FROM PJP__c
            WHERE Id = :pjpId
            LIMIT 1
        ];

        if (pjp.Employee__c == null) {
            throw new AuraHandledException('Please assign an Employee to this PJP before submitting for approval.');
        }

        if (pjp.Employee__r.Reporting_Manager__c == null) {
            throw new AuraHandledException('Employee ' + pjp.Employee__r.Name + ' does not have a Reporting Manager assigned. Please assign a Reporting Manager before submitting.');
        }

        // Identify the approver User: Reporting Manager's Lead Owner user (or OwnerId)
        Id approverUserId = pjp.Employee__r.Reporting_Manager__r.Lead_Owner__c;
        if (approverUserId == null) {
            approverUserId = pjp.Employee__r.Reporting_Manager__r.OwnerId;
        }

        String approverName = (pjp.Employee__r.Reporting_Manager__r.Lead_Owner__c != null && pjp.Employee__r.Reporting_Manager__r.Lead_Owner__r.Name != null)
            ? pjp.Employee__r.Reporting_Manager__r.Lead_Owner__r.Name
            : pjp.Employee__r.Reporting_Manager__r.Name;

        pjp.Lead_Owner__c = approverUserId;
        pjp.Status__c = 'Submitted';
        pjp.Approval_Date__c = null;
        pjp.Approval_Comments__c = null;
        update pjp;

        // Ensure Employee status remains Pending until manual approval
        if (pjp.Employee__c != null) {
            Employee__c emp = [SELECT Id, Status__c, PJP__c FROM Employee__c WHERE Id = :pjp.Employee__c LIMIT 1];
            if (emp.Status__c != 'Pending') {
                emp.Status__c = 'Pending';
                update emp;
            }
        }

        // Submit via standard Salesforce Approval Process for manual approval
        try {
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setComments('Submitted for Reporting Manager approval: ' + pjp.Employee__r.Reporting_Manager__r.Name);
            req.setObjectId(pjp.Id);
            req.setSubmitterId(UserInfo.getUserId());
            req.setNextApproverIds(new Id[] { approverUserId });
            Approval.ProcessResult res = Approval.process(req);
        } catch (Exception ex) {
            System.debug('Standard approval process note: ' + ex.getMessage());
        }

        // Create an Activity Task for the Approver User to review
        if (approverUserId != null) {
            Task approvalTask = new Task(
                OwnerId = approverUserId,
                Subject = 'PJP Approval Request: ' + pjp.Employee__r.Name,
                Description = 'Permanent Journey Plan (' + pjp.Name + ') for Employee ' + 
                              pjp.Employee__r.Name + ' has been submitted for your approval. Please review and approve/reject.',
                Status = 'Not Started',
                Priority = 'High',
                ActivityDate = Date.today().addDays(1),
                WhatId = pjp.Id
            );
            Database.insert(approvalTask, false);
        }

        // Also attempt CustomNotification if type exists
        try {
            CustomNotificationType notifType = [
                SELECT Id FROM CustomNotificationType 
                WHERE DeveloperName = 'PJP_Approval_Notification' 
                LIMIT 1
            ];
            if (notifType != null && approverUserId != null) {
                Messaging.CustomNotification notification = new Messaging.CustomNotification();
                notification.setTitle('PJP Approval Request');
                notification.setBody('PJP ' + pjp.Name + ' for Employee ' + pjp.Employee__r.Name + ' has been submitted for your approval.');
                notification.setNotificationTypeId(notifType.Id);
                notification.setTargetId(pjp.Id);
                notification.send(new Set<String>{ String.valueOf(approverUserId) });
            }
        } catch (Exception ex) {
            // Non-critical fallback
        }

        Map<String, Object> result = new Map<String, Object>();
        result.put('success', true);
        result.put('message', 'PJP submitted for approval to ' + approverName + '! Status is now Submitted (Pending Approval).');
        result.put('approverName', approverName);
        result.put('reportingManager', pjp.Employee__r.Reporting_Manager__r.Name);
        return result;
    }

    @AuraEnabled
    public static Map<String, Object> approvePJP(Id pjpId, String comments) {
        if (pjpId == null) throw new AuraHandledException('Invalid PJP ID.');

        PJP__c pjp = [
            SELECT Id, Name, Employee__c, Employee__r.Name, Lead_Owner__c, Status__c
            FROM PJP__c
            WHERE Id = :pjpId
            LIMIT 1
        ];

        // Also approve pending standard approval workitem if one exists
        try {
            List<ProcessInstanceWorkitem> workItems = [
                SELECT Id FROM ProcessInstanceWorkitem 
                WHERE ProcessInstance.TargetObjectId = :pjp.Id
                LIMIT 1
            ];
            if (!workItems.isEmpty()) {
                Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
                req.setComments(String.isNotBlank(comments) ? comments : 'Approved');
                req.setAction('Approve');
                req.setWorkitemId(workItems[0].Id);
                Approval.process(req);
            }
        } catch (Exception ex) {
            System.debug('Approval workitem note: ' + ex.getMessage());
        }

        pjp.Status__c = 'Approved';
        pjp.Approval_Comments__c = String.isNotBlank(comments) ? comments : 'Approved';
        pjp.Approval_Date__c = System.now();
        update pjp;

        // Crucial requirement: Update Employee status from Pending to Approved and link PJP!
        if (pjp.Employee__c != null) {
            Employee__c emp = [SELECT Id, Status__c, PJP__c FROM Employee__c WHERE Id = :pjp.Employee__c LIMIT 1];
            emp.Status__c = 'Approved';
            emp.PJP__c = pjp.Id;
            update emp;
        }

        // Close open approval tasks
        try {
            List<Task> openTasks = [
                SELECT Id, Status FROM Task 
                WHERE WhatId = :pjp.Id AND Status != 'Completed'
            ];
            for (Task t : openTasks) {
                t.Status = 'Completed';
            }
            if (!openTasks.isEmpty()) {
                update openTasks;
            }
        } catch (Exception ex) {
            // Non-critical
        }

        Map<String, Object> result = new Map<String, Object>();
        result.put('success', true);
        result.put('message', 'PJP approved! Employee status has been updated from Pending to Approved.');
        return result;
    }

    @AuraEnabled
    public static Map<String, Object> rejectPJP(Id pjpId, String comments) {
        if (pjpId == null) throw new AuraHandledException('Invalid PJP ID.');

        PJP__c pjp = [
            SELECT Id, Name, Employee__c, Employee__r.Name, Lead_Owner__c, Status__c
            FROM PJP__c
            WHERE Id = :pjpId
            LIMIT 1
        ];

        try {
            List<ProcessInstanceWorkitem> workItems = [
                SELECT Id FROM ProcessInstanceWorkitem 
                WHERE ProcessInstance.TargetObjectId = :pjp.Id
                LIMIT 1
            ];
            if (!workItems.isEmpty()) {
                Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
                req.setComments(String.isNotBlank(comments) ? comments : 'Rejected');
                req.setAction('Reject');
                req.setWorkitemId(workItems[0].Id);
                Approval.process(req);
            }
        } catch (Exception ex) {
            System.debug('Approval workitem note: ' + ex.getMessage());
        }

        pjp.Status__c = 'Rejected';
        pjp.Approval_Comments__c = String.isNotBlank(comments) ? comments : 'Rejected';
        pjp.Approval_Date__c = System.now();
        update pjp;

        if (pjp.Employee__c != null) {
            Employee__c emp = [SELECT Id, Status__c, Name FROM Employee__c WHERE Id = :pjp.Employee__c LIMIT 1];
            emp.Status__c = 'Rejected';
            update emp;
        }

        // Close open approval tasks
        try {
            List<Task> openTasks = [
                SELECT Id, Status FROM Task 
                WHERE WhatId = :pjp.Id AND Status != 'Completed'
            ];
            for (Task t : openTasks) {
                t.Status = 'Completed';
            }
            if (!openTasks.isEmpty()) {
                update openTasks;
            }
        } catch (Exception ex) {
            // Non-critical
        }

        Map<String, Object> result = new Map<String, Object>();
        result.put('success', true);
        result.put('message', 'PJP rejected. Employee status updated to Rejected.');
        return result;
    }

    @AuraEnabled
    public static Map<String, Object> uploadProfilePicture(Id employeeId, String fileName, String base64Data) {
        if (employeeId == null || String.isBlank(base64Data)) {
            throw new AuraHandledException('Invalid employee or image data.');
        }

        ContentVersion cv = new ContentVersion();
        cv.Title = String.isNotBlank(fileName) ? fileName : 'ProfilePicture_' + employeeId;
        cv.PathOnClient = String.isNotBlank(fileName) ? fileName : 'profile_picture.png';
        cv.VersionData = EncodingUtil.base64Decode(base64Data);
        cv.IsMajorVersion = true;
        insert as user cv;

        Id contentDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id WITH USER_MODE LIMIT 1].ContentDocumentId;

        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = contentDocId;
        cdl.LinkedEntityId = employeeId;
        cdl.ShareType = 'V';
        cdl.Visibility = 'AllUsers';
        insert as user cdl;

        String imageUrl = '/sfc/servlet.shepherd/version/download/' + cv.Id;
        Employee__c emp = new Employee__c(
            Id = employeeId,
            Profile_Picture__c = '<p><img src="' + imageUrl + '" alt="Profile Picture" style="max-height: 180px; border-radius: 8px;" /></p>'
        );
        update as user emp;

        Map<String, Object> res = new Map<String, Object>();
        res.put('success', true);
        res.put('imageUrl', imageUrl);
        res.put('contentVersionId', cv.Id);
        return res;
    }

    // =========================================================
    // DMS & DISTRIBUTOR EXTENSION METHODS
    // =========================================================

    @AuraEnabled
    public static Distributor__c toggleDistributorPortal(Id distributorId, Boolean isEnabled) {
        if (distributorId == null) throw new AuraHandledException('Invalid distributor ID');
        Distributor__c dist = new Distributor__c(Id = distributorId, DMS_Portal_Enabled__c = isEnabled);
        update as user dist;
        return [
            SELECT Id, Name, Distributor_Code__c, Distributor_Owner_Name__c, Mobile_Number__c, Contact_Person__c, Email__c, Phone__c,
                   GSTIN__c, Address__c, City__c, State__c, Pincode__c, Distributor_Officer__c,
                   Max_Outlets__c, Assigned_SR_Count__c, DMS_Portal_Enabled__c, Status__c, CreatedDate
            FROM Distributor__c
            WHERE Id = :distributorId
            WITH USER_MODE
            LIMIT 1
        ];
    }

    @AuraEnabled
    public static Primary_Order__c approvePrimaryOrder(Id orderId, String remarks) {
        if (orderId == null) throw new AuraHandledException('Invalid primary order ID');
        Primary_Order__c po = new Primary_Order__c(
            Id = orderId,
            Status__c = 'DO Approved',
            DO_Approval_Status__c = 'DO Approved',
            DO_Remarks__c = String.isNotBlank(remarks) ? remarks : 'Approved by DO Officer',
            Approved_By__c = UserInfo.getName()
        );
        update as user po;
        return [
            SELECT Id, Name, Distributor_Name__c, Employee_Name__c, Total_Cases__c,
                   Gross_Amount__c, Tax_Amount__c, Total_Amount__c, Status__c,
                   DO_Approval_Status__c, DO_Remarks__c, Approved_By__c, Items_Summary__c,
                   Primary_Scheme_Applied__c, Order_Date__c, Invoice_Number__c,
                   Dispatch_Status__c, Payment_Terms__c, Payment_Status__c,
                   Expected_Delivery_Date__c, Transporter_Name__c, LR_Number__c, CreatedDate
            FROM Primary_Order__c
            WHERE Id = :orderId
            WITH USER_MODE
            LIMIT 1
        ];
    }

    @AuraEnabled
    public static Primary_Order__c rejectPrimaryOrder(Id orderId, String remarks) {
        if (orderId == null) throw new AuraHandledException('Invalid primary order ID');
        Primary_Order__c po = new Primary_Order__c(
            Id = orderId,
            Status__c = 'DO Rejected',
            DO_Approval_Status__c = 'DO Rejected',
            DO_Remarks__c = String.isNotBlank(remarks) ? remarks : 'Rejected by DO Officer',
            Approved_By__c = UserInfo.getName()
        );
        update as user po;
        return [
            SELECT Id, Name, Distributor_Name__c, Employee_Name__c, Total_Cases__c,
                   Gross_Amount__c, Tax_Amount__c, Total_Amount__c, Status__c,
                   DO_Approval_Status__c, DO_Remarks__c, Approved_By__c, Items_Summary__c,
                   Primary_Scheme_Applied__c, Order_Date__c, Invoice_Number__c,
                   Dispatch_Status__c, Payment_Terms__c, Payment_Status__c,
                   Expected_Delivery_Date__c, Transporter_Name__c, LR_Number__c, CreatedDate
            FROM Primary_Order__c
            WHERE Id = :orderId
            WITH USER_MODE
            LIMIT 1
        ];
    }

    @AuraEnabled
    public static Primary_Return__c approvePrimaryReturn(Id returnId, String remarks) {
        if (returnId == null) throw new AuraHandledException('Invalid return ID');
        Primary_Return__c pr = new Primary_Return__c(
            Id = returnId,
            Status__c = 'DO Approved',
            DO_Remarks__c = String.isNotBlank(remarks) ? remarks : 'Return Approved by DO'
        );
        update as user pr;
        return [
            SELECT Id, Name, Distributor_Name__c, Employee_Name__c, Product_Name__c,
                   Return_Reason__c, Cases__c, Total_Amount__c, Status__c, DO_Remarks__c,
                   Return_Date__c, Batch_Number__c, Expiry_Date__c,
                   Credit_Note_Number__c, Credit_Note_Amount__c,
                   Inspection_Status__c, Action_Taken__c, CreatedDate
            FROM Primary_Return__c
            WHERE Id = :returnId
            WITH USER_MODE
            LIMIT 1
        ];
    }

    @AuraEnabled
    public static Primary_Return__c rejectPrimaryReturn(Id returnId, String remarks) {
        if (returnId == null) throw new AuraHandledException('Invalid return ID');
        Primary_Return__c pr = new Primary_Return__c(
            Id = returnId,
            Status__c = 'DO Rejected',
            DO_Remarks__c = String.isNotBlank(remarks) ? remarks : 'Return Rejected by DO'
        );
        update as user pr;
        return [
            SELECT Id, Name, Distributor_Name__c, Employee_Name__c, Product_Name__c,
                   Return_Reason__c, Cases__c, Total_Amount__c, Status__c, DO_Remarks__c,
                   Return_Date__c, Batch_Number__c, Expiry_Date__c,
                   Credit_Note_Number__c, Credit_Note_Amount__c,
                   Inspection_Status__c, Action_Taken__c, CreatedDate
            FROM Primary_Return__c
            WHERE Id = :returnId
            WITH USER_MODE
            LIMIT 1
        ];
    }

    @AuraEnabled
    public static DMS_Ticket__c updateDmsTicketStatus(Id ticketId, String status, String resolutionNotes) {
        if (ticketId == null) throw new AuraHandledException('Invalid ticket ID');
        DMS_Ticket__c dt = new DMS_Ticket__c(
            Id = ticketId,
            Status__c = status,
            Resolution_Notes__c = resolutionNotes
        );
        update as user dt;
        return [
            SELECT Id, Name, Distributor_Name__c, Category__c, Subject__c, Description__c,
                   Status__c, Priority__c, Resolution_Notes__c, Raised_By__c,
                   Contact_Number__c, Assigned_To__c, Target_Resolution_Date__c,
                   Resolution_Date__c, Customer_Satisfaction__c, CreatedDate
            FROM DMS_Ticket__c
            WHERE Id = :ticketId
            WITH USER_MODE
            LIMIT 1
        ];
    }

    @AuraEnabled
    public static Distributor__c createDistributor(Distributor__c distributor) {
        if (distributor == null) throw new AuraHandledException('Invalid distributor data');
        insert as user distributor;
        return [
            SELECT Id, Name, Distributor_Code__c, Distributor_Owner_Name__c, Mobile_Number__c, Contact_Person__c, Email__c, Phone__c,
                   GSTIN__c, Address__c, City__c, State__c, Pincode__c, Distributor_Officer__c,
                   Max_Outlets__c, Assigned_SR_Count__c, DMS_Portal_Enabled__c, Status__c, CreatedDate
            FROM Distributor__c
            WHERE Id = :distributor.Id
            WITH USER_MODE
            LIMIT 1
        ];
    }

    @AuraEnabled
    public static Primary_Order__c createPrimaryOrder(Primary_Order__c order) {
        if (order == null) throw new AuraHandledException('Invalid order data');
        if (String.isBlank(order.Status__c)) order.Status__c = 'Pending DO Approval';
        if (String.isBlank(order.DO_Approval_Status__c)) order.DO_Approval_Status__c = 'Pending DO Approval';
        insert as user order;
        return [
            SELECT Id, Name, Distributor_Name__c, Employee_Name__c, Total_Cases__c,
                   Gross_Amount__c, Tax_Amount__c, Total_Amount__c, Status__c,
                   DO_Approval_Status__c, DO_Remarks__c, Approved_By__c, Items_Summary__c,
                   Primary_Scheme_Applied__c, Order_Date__c, Invoice_Number__c,
                   Dispatch_Status__c, Payment_Terms__c, Payment_Status__c,
                   Expected_Delivery_Date__c, Transporter_Name__c, LR_Number__c, CreatedDate
            FROM Primary_Order__c
            WHERE Id = :order.Id
            WITH USER_MODE
            LIMIT 1
        ];
    }

    @AuraEnabled
    public static Distributor_Stock__c breakDistributorCase(Id stockId, Integer casesToBreak) {
        if (stockId == null) throw new AuraHandledException('Invalid Stock ID');
        if (casesToBreak == null || casesToBreak <= 0) casesToBreak = 1;

        Distributor_Stock__c stock = [
            SELECT Id, Name, Distributor_Name__c, Product_Name__c, Pieces_Per_Case__c,
                   Purchased_Cases__c, Full_Cases_In_Stock__c, Loose_Pieces_In_Stock__c,
                   Total_Available_Pieces__c, Sold_Pieces__c, Sold_Cases__c,
                   Broken_Cases_Count__c, Stock_Status__c
            FROM Distributor_Stock__c
            WHERE Id = :stockId
            WITH USER_MODE
            LIMIT 1
        ];

        Decimal currentFullCases = stock.Full_Cases_In_Stock__c != null ? stock.Full_Cases_In_Stock__c : 0;
        if (currentFullCases < casesToBreak) {
            throw new AuraHandledException('Not enough full cases in stock to break. Available: ' + currentFullCases);
        }

        Decimal pcsPerCase = stock.Pieces_Per_Case__c != null && stock.Pieces_Per_Case__c > 0 ? stock.Pieces_Per_Case__c : 20;
        stock.Full_Cases_In_Stock__c = currentFullCases - casesToBreak;
        stock.Broken_Cases_Count__c = (stock.Broken_Cases_Count__c != null ? stock.Broken_Cases_Count__c : 0) + casesToBreak;
        stock.Loose_Pieces_In_Stock__c = (stock.Loose_Pieces_In_Stock__c != null ? stock.Loose_Pieces_In_Stock__c : 0) + (casesToBreak * pcsPerCase);
        stock.Total_Available_Pieces__c = (stock.Full_Cases_In_Stock__c * pcsPerCase) + stock.Loose_Pieces_In_Stock__c;

        if (stock.Total_Available_Pieces__c <= 0) {
            stock.Stock_Status__c = 'Out of Stock';
        } else if (stock.Total_Available_Pieces__c <= 50) {
            stock.Stock_Status__c = 'Low Stock';
        } else {
            stock.Stock_Status__c = 'In Stock';
        }

        update as user stock;

        return [
            SELECT Id, Name, Distributor_Name__c, Product_Name__c, Pieces_Per_Case__c,
                   Purchased_Cases__c, Full_Cases_In_Stock__c, Loose_Pieces_In_Stock__c,
                   Total_Available_Pieces__c, Sold_Pieces__c, Sold_Cases__c,
                   Broken_Cases_Count__c, Stock_Status__c, CreatedDate
            FROM Distributor_Stock__c
            WHERE Id = :stock.Id
            WITH USER_MODE
            LIMIT 1
        ];
    }

    @AuraEnabled
    public static Sales_Order__c fulfillSecondaryOrder(Id orderId, String fulfillmentStatus, String remarks) {
        if (orderId == null) throw new AuraHandledException('Invalid Secondary Order ID');
        
        Sales_Order__c order = [
            SELECT Id, Name, Outlet__c, Outlet_Name__c, Product__c, Product_Name__c,
                   Total_Amount__c, Gross_Amount__c, Tax_Amount__c, Total_Qty__c,
                   Order_Type__c, Distributor_Name__c, Distributor_Approval_Status__c,
                   Distributor_Remarks__c, Status__c, Unit_Type__c, Pieces_Per_Case__c,
                   Supplied_Pieces__c, Case_Breaking_Applied__c, Fulfillment_Status__c
            FROM Sales_Order__c
            WHERE Id = :orderId
            WITH USER_MODE
            LIMIT 1
        ];

        order.Fulfillment_Status__c = String.isNotBlank(fulfillmentStatus) ? fulfillmentStatus : 'Dispatched';
        if (String.isNotBlank(remarks)) {
            order.Distributor_Remarks__c = remarks;
        }

        // Deduct from Distributor_Stock__c if available
        if (String.isNotBlank(order.Distributor_Name__c) && String.isNotBlank(order.Product_Name__c)) {
            List<Distributor_Stock__c> stocks = [
                SELECT Id, Name, Distributor_Name__c, Product_Name__c, Pieces_Per_Case__c,
                       Purchased_Cases__c, Full_Cases_In_Stock__c, Loose_Pieces_In_Stock__c,
                       Total_Available_Pieces__c, Sold_Pieces__c, Sold_Cases__c,
                       Broken_Cases_Count__c, Stock_Status__c
                FROM Distributor_Stock__c
                WHERE Distributor_Name__c = :order.Distributor_Name__c
                  AND Product_Name__c = :order.Product_Name__c
                WITH USER_MODE
                LIMIT 1
            ];

            if (!stocks.isEmpty()) {
                Distributor_Stock__c stock = stocks[0];
                Decimal pcsPerCase = stock.Pieces_Per_Case__c != null && stock.Pieces_Per_Case__c > 0 ? stock.Pieces_Per_Case__c : 20;
                Decimal qty = order.Total_Qty__c != null ? order.Total_Qty__c : 1;
                
                Decimal piecesNeeded = 0;
                if (order.Unit_Type__c == 'Cases') {
                    piecesNeeded = qty * pcsPerCase;
                    stock.Full_Cases_In_Stock__c = Math.max(0, (stock.Full_Cases_In_Stock__c != null ? stock.Full_Cases_In_Stock__c : 0) - qty);
                    stock.Sold_Cases__c = (stock.Sold_Cases__c != null ? stock.Sold_Cases__c : 0) + qty;
                } else {
                    // Pieces order - requires checking loose pieces vs case breaking
                    piecesNeeded = qty;
                    Decimal looseAvailable = stock.Loose_Pieces_In_Stock__c != null ? stock.Loose_Pieces_In_Stock__c : 0;
                    
                    if (looseAvailable >= piecesNeeded) {
                        // Satisfied directly from existing loose pieces
                        stock.Loose_Pieces_In_Stock__c = looseAvailable - piecesNeeded;
                    } else {
                        // Case breaking needed!
                        Decimal remainingNeeded = piecesNeeded - looseAvailable;
                        Integer casesToBreak = (Integer)Math.ceil((Double)remainingNeeded / (Double)pcsPerCase);
                        Decimal fullAvailable = stock.Full_Cases_In_Stock__c != null ? stock.Full_Cases_In_Stock__c : 0;
                        if (casesToBreak > fullAvailable) {
                            casesToBreak = fullAvailable.intValue();
                        }
                        
                        stock.Full_Cases_In_Stock__c = fullAvailable - casesToBreak;
                        stock.Broken_Cases_Count__c = (stock.Broken_Cases_Count__c != null ? stock.Broken_Cases_Count__c : 0) + casesToBreak;
                        stock.Loose_Pieces_In_Stock__c = (looseAvailable + (casesToBreak * pcsPerCase)) - piecesNeeded;
                        order.Case_Breaking_Applied__c = true;
                    }
                }

                order.Supplied_Pieces__c = piecesNeeded;
                stock.Sold_Pieces__c = (stock.Sold_Pieces__c != null ? stock.Sold_Pieces__c : 0) + piecesNeeded;
                stock.Total_Available_Pieces__c = ((stock.Full_Cases_In_Stock__c != null ? stock.Full_Cases_In_Stock__c : 0) * pcsPerCase) + 
                                                  (stock.Loose_Pieces_In_Stock__c != null ? stock.Loose_Pieces_In_Stock__c : 0);
                
                if (stock.Total_Available_Pieces__c <= 0) {
                    stock.Stock_Status__c = 'Out of Stock';
                } else if (stock.Total_Available_Pieces__c <= 50) {
                    stock.Stock_Status__c = 'Low Stock';
                } else {
                    stock.Stock_Status__c = 'In Stock';
                }

                update as user stock;
            }
        }

        update as user order;

        return [
            SELECT Id, Name, Outlet__c, Outlet_Name__c, Product__c, Product_Name__c,
                   Total_Amount__c, Gross_Amount__c, Tax_Amount__c, Total_Qty__c,
                   Order_Type__c, Distributor_Name__c, Distributor_Approval_Status__c,
                   Distributor_Remarks__c, Status__c, Unit_Type__c, Pieces_Per_Case__c,
                   Supplied_Pieces__c, Case_Breaking_Applied__c, Fulfillment_Status__c, CreatedDate
            FROM Sales_Order__c
            WHERE Id = :order.Id
            WITH USER_MODE
            LIMIT 1
        ];
    }

    @AuraEnabled
    public static Primary_Order__c markPrimaryOrderDelivered(Id orderId) {
        if (orderId == null) throw new AuraHandledException('Invalid Primary Order ID');
        Primary_Order__c po = [
            SELECT Id, Name, Distributor_Name__c, Total_Cases__c, Status__c, Dispatch_Status__c
            FROM Primary_Order__c
            WHERE Id = :orderId
            WITH USER_MODE
            LIMIT 1
        ];

        po.Dispatch_Status__c = 'Delivered';
        po.Status__c = 'Delivered';
        update as user po;

        // Automatically update/add stock to DMS_Stock__c
        if (String.isNotBlank(po.Distributor_Name__c)) {
            Decimal cases = po.Total_Cases__c != null ? po.Total_Cases__c : 10;
            List<DMS_Stock__c> stocks = [
                SELECT Id, Name, Distributor_Name__c, Product_Name__c, Purchased_Cases__c,
                       Full_Cases_In_Stock__c, Total_Available_Cases__c, Remaining_Cases__c
                FROM DMS_Stock__c
                WHERE Distributor_Name__c = :po.Distributor_Name__c
                WITH USER_MODE
                LIMIT 1
            ];

            if (!stocks.isEmpty()) {
                DMS_Stock__c st = stocks[0];
                st.Purchased_Cases__c = (st.Purchased_Cases__c != null ? st.Purchased_Cases__c : 0) + cases;
                st.Full_Cases_In_Stock__c = (st.Full_Cases_In_Stock__c != null ? st.Full_Cases_In_Stock__c : 0) + cases;
                st.Total_Available_Cases__c = (st.Total_Available_Cases__c != null ? st.Total_Available_Cases__c : 0) + cases;
                st.Remaining_Cases__c = (st.Remaining_Cases__c != null ? st.Remaining_Cases__c : 0) + cases;
                st.Stock_Status__c = 'In Stock';
                update as user st;
            }
        }

        return po;
    }

    @AuraEnabled
    public static Secondary_Order__c acceptSecondaryOrder(Id orderId) {
        if (orderId == null) throw new AuraHandledException('Invalid Secondary Order ID');
        Secondary_Order__c so = [
            SELECT Id, Name, Status__c, Product_Name__c, Quantity__c, Distributor_Name__c
            FROM Secondary_Order__c
            WHERE Id = :orderId
            WITH USER_MODE
            LIMIT 1
        ];

        so.Status__c = 'Approved';
        update as user so;
        return so;
    }

    @AuraEnabled
    public static Secondary_Order__c supplySecondaryOrder(Id orderId, String remarks) {
        if (orderId == null) throw new AuraHandledException('Invalid Secondary Order ID');
        Secondary_Order__c so = [
            SELECT Id, Name, Outlet_Name__c, Distributor_Name__c, Product_Name__c,
                   Quantity__c, Unit_Type__c, Status__c, Supplied_Quantity__c,
                   Remaining_Stock_After_Supply__c, Distributor_Remarks__c
            FROM Secondary_Order__c
            WHERE Id = :orderId
            WITH USER_MODE
            LIMIT 1
        ];

        so.Status__c = 'Supplied';
        so.Supplied_Quantity__c = so.Quantity__c != null ? so.Quantity__c : 5;
        if (String.isNotBlank(remarks)) so.Distributor_Remarks__c = remarks;

        // Deduct from DMS_Stock__c (e.g. 10 cases - 5 cases = 5 remaining cases)
        if (String.isNotBlank(so.Distributor_Name__c) && String.isNotBlank(so.Product_Name__c)) {
            List<DMS_Stock__c> stocks = [
                SELECT Id, Name, Distributor_Name__c, Product_Name__c, Full_Cases_In_Stock__c,
                       Total_Available_Cases__c, Supplied_Cases__c, Remaining_Cases__c, Stock_Status__c
                FROM DMS_Stock__c
                WHERE Distributor_Name__c = :so.Distributor_Name__c
                  AND Product_Name__c = :so.Product_Name__c
                WITH USER_MODE
                LIMIT 1
            ];

            if (!stocks.isEmpty()) {
                DMS_Stock__c st = stocks[0];
                Decimal qty = so.Quantity__c != null ? so.Quantity__c : 1;
                st.Full_Cases_In_Stock__c = Math.max(0, (st.Full_Cases_In_Stock__c != null ? st.Full_Cases_In_Stock__c : 0) - qty);
                st.Supplied_Cases__c = (st.Supplied_Cases__c != null ? st.Supplied_Cases__c : 0) + qty;
                st.Remaining_Cases__c = Math.max(0, (st.Remaining_Cases__c != null ? st.Remaining_Cases__c : 0) - qty);
                st.Total_Available_Cases__c = st.Remaining_Cases__c;
                if (st.Remaining_Cases__c <= 0) st.Stock_Status__c = 'Out of Stock';
                else if (st.Remaining_Cases__c <= 3) st.Stock_Status__c = 'Low Stock';
                else st.Stock_Status__c = 'In Stock';
                update as user st;

                so.Remaining_Stock_After_Supply__c = st.Remaining_Cases__c;
            }
        }

        update as user so;
        return so;
    }

    @AuraEnabled
    public static DMS_Return__c createDmsReturn(DMS_Return__c dmsRet) {
        if (dmsRet == null) throw new AuraHandledException('Invalid Return data');
        if (String.isBlank(dmsRet.Status__c)) dmsRet.Status__c = 'Submitted';
        insert as user dmsRet;

        // Automatically deduct damaged case from DMS_Stock__c (e.g. 10 cases -> 9 cases)
        if (String.isNotBlank(dmsRet.Distributor_Name__c) && String.isNotBlank(dmsRet.Product_Name__c)) {
            List<DMS_Stock__c> stocks = [
                SELECT Id, Name, Distributor_Name__c, Product_Name__c, Full_Cases_In_Stock__c,
                       Total_Available_Cases__c, Damaged_Returned_Cases__c, Remaining_Cases__c
                FROM DMS_Stock__c
                WHERE Distributor_Name__c = :dmsRet.Distributor_Name__c
                  AND Product_Name__c = :dmsRet.Product_Name__c
                WITH USER_MODE
                LIMIT 1
            ];

            if (!stocks.isEmpty()) {
                DMS_Stock__c st = stocks[0];
                Decimal damaged = dmsRet.Damaged_Cases__c != null ? dmsRet.Damaged_Cases__c : 1;
                dmsRet.Previous_Stock_Cases__c = st.Remaining_Cases__c;
                st.Damaged_Returned_Cases__c = (st.Damaged_Returned_Cases__c != null ? st.Damaged_Returned_Cases__c : 0) + damaged;
                st.Full_Cases_In_Stock__c = Math.max(0, (st.Full_Cases_In_Stock__c != null ? st.Full_Cases_In_Stock__c : 0) - damaged);
                st.Remaining_Cases__c = Math.max(0, (st.Remaining_Cases__c != null ? st.Remaining_Cases__c : 0) - damaged);
                st.Total_Available_Cases__c = st.Remaining_Cases__c;
                update as user st;

                dmsRet.Updated_Stock_Cases__c = st.Remaining_Cases__c;
                update as user dmsRet;
            }
        }

        return dmsRet;
    }

    @AuraEnabled
    public static Sales_Return__c createSalesReturn(Sales_Return__c salesRet) {
        if (salesRet == null) throw new AuraHandledException('Invalid Sales Return data');
        if (String.isBlank(salesRet.Status__c)) salesRet.Status__c = 'Collected by SR';
        insert as user salesRet;
        return salesRet;
    }

    @AuraEnabled
    public static Distributor_Primary_Approval__c approveDistributorPrimaryOrder(Id approvalId, String remarks) {
        if (approvalId == null) throw new AuraHandledException('Invalid Approval ID');
        Distributor_Primary_Approval__c pa = [
            SELECT Id, Name, Approval_Status__c, Remarks__c, Delivery_Status__c, Approved_By__c, Approval_Date__c
            FROM Distributor_Primary_Approval__c
            WHERE Id = :approvalId
            WITH USER_MODE
            LIMIT 1
        ];
        pa.Approval_Status__c = 'Approved';
        pa.Approved_By__c = UserInfo.getName();
        pa.Approval_Date__c = Date.today();
        if (String.isNotBlank(remarks)) pa.Remarks__c = remarks;
        update as user pa;
        return pa;
    }

    @AuraEnabled
    public static Distributor_Primary_Approval__c rejectDistributorPrimaryOrder(Id approvalId, String remarks) {
        if (approvalId == null) throw new AuraHandledException('Invalid Approval ID');
        Distributor_Primary_Approval__c pa = [
            SELECT Id, Name, Approval_Status__c, Remarks__c, Approved_By__c, Approval_Date__c
            FROM Distributor_Primary_Approval__c
            WHERE Id = :approvalId
            WITH USER_MODE
            LIMIT 1
        ];
        pa.Approval_Status__c = 'Rejected';
        pa.Approved_By__c = UserInfo.getName();
        pa.Approval_Date__c = Date.today();
        if (String.isNotBlank(remarks)) pa.Remarks__c = remarks;
        update as user pa;
        return pa;
    }

    @AuraEnabled
    public static Distributor_Return_Approval__c approveDistributorReturn(Id approvalId, String remarks) {
        if (approvalId == null) throw new AuraHandledException('Invalid Return Approval ID');
        Distributor_Return_Approval__c ra = [
            SELECT Id, Name, Approval_Status__c, Status__c, Remarks__c, Approved_By__c
            FROM Distributor_Return_Approval__c
            WHERE Id = :approvalId
            WITH USER_MODE
            LIMIT 1
        ];
        ra.Approval_Status__c = 'Approved';
        ra.Status__c = 'Approved';
        ra.Approved_By__c = UserInfo.getName();
        if (String.isNotBlank(remarks)) ra.Remarks__c = remarks;
        update as user ra;
        return ra;
    }

    @AuraEnabled
    public static Distributor_Return_Approval__c rejectDistributorReturn(Id approvalId, String remarks) {
        if (approvalId == null) throw new AuraHandledException('Invalid Return Approval ID');
        Distributor_Return_Approval__c ra = [
            SELECT Id, Name, Approval_Status__c, Status__c, Remarks__c, Approved_By__c
            FROM Distributor_Return_Approval__c
            WHERE Id = :approvalId
            WITH USER_MODE
            LIMIT 1
        ];
        ra.Approval_Status__c = 'Rejected';
        ra.Status__c = 'Rejected';
        ra.Approved_By__c = UserInfo.getName();
        if (String.isNotBlank(remarks)) ra.Remarks__c = remarks;
        update as user ra;
        return ra;
    }
}