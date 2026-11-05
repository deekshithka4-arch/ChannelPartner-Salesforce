public with sharing class PJPTriggerHandler {
    
    public static void handleBefore(List<PJP__c> newPjps, Map<Id, PJP__c> oldMap) {
        Set<Id> empIds = new Set<Id>();
        for (PJP__c pjp : newPjps) {
            Boolean isNew = (oldMap == null);
            Boolean empChanged = !isNew && (oldMap.get(pjp.Id).Employee__c != pjp.Employee__c);
            
            // Auto-populate Lead_Owner__c from Reporting Manager's user if Lead_Owner__c is null or Employee changed
            if (pjp.Employee__c != null && (isNew || empChanged || pjp.Lead_Owner__c == null)) {
                empIds.add(pjp.Employee__c);
            }

            // Sync approval date/comments if status changed to Approved
            Boolean statusChangedToApproved = (pjp.Status__c == 'Approved') && 
                (isNew || oldMap.get(pjp.Id).Status__c != 'Approved');
            if (statusChangedToApproved) {
                if (pjp.Approval_Date__c == null) {
                    pjp.Approval_Date__c = System.now();
                }
                if (String.isBlank(pjp.Approval_Comments__c)) {
                    pjp.Approval_Comments__c = 'Approved';
                }
            }
        }

        if (!empIds.isEmpty()) {
            Map<Id, Employee__c> empMap = new Map<Id, Employee__c>([
                SELECT Id, Reporting_Manager__c, Reporting_Manager__r.Lead_Owner__c, Reporting_Manager__r.OwnerId
                FROM Employee__c
                WHERE Id IN :empIds
            ]);

            for (PJP__c pjp : newPjps) {
                if (pjp.Employee__c != null && empMap.containsKey(pjp.Employee__c)) {
                    Employee__c emp = empMap.get(pjp.Employee__c);
                    if (emp.Reporting_Manager__c != null) {
                        Id managerUserId = emp.Reporting_Manager__r.Lead_Owner__c != null
                            ? emp.Reporting_Manager__r.Lead_Owner__c
                            : emp.Reporting_Manager__r.OwnerId;
                        if (managerUserId != null && (pjp.Lead_Owner__c == null || oldMap == null || oldMap.get(pjp.Id).Employee__c != pjp.Employee__c)) {
                            pjp.Lead_Owner__c = managerUserId;
                        }
                    }
                }
            }
        }
    }

    public static void handleAfter(List<PJP__c> newPjps, Map<Id, PJP__c> oldMap) {
        Set<Id> approvedEmployeeIds = new Set<Id>();
        Set<Id> rejectedEmployeeIds = new Set<Id>();
        Map<Id, Id> empToPjpMap = new Map<Id, Id>();

        for (PJP__c pjp : newPjps) {
            Boolean isNew = (oldMap == null);
            Boolean statusChanged = isNew || (oldMap.get(pjp.Id).Status__c != pjp.Status__c);

            if (statusChanged && pjp.Employee__c != null) {
                if (pjp.Status__c == 'Approved') {
                    approvedEmployeeIds.add(pjp.Employee__c);
                    empToPjpMap.put(pjp.Employee__c, pjp.Id);
                } else if (pjp.Status__c == 'Rejected') {
                    rejectedEmployeeIds.add(pjp.Employee__c);
                }
            }
        }

        List<Employee__c> empsToUpdate = new List<Employee__c>();

        if (!approvedEmployeeIds.isEmpty()) {
            List<Employee__c> emps = [
                SELECT Id, Status__c, PJP__c 
                FROM Employee__c 
                WHERE Id IN :approvedEmployeeIds
            ];
            for (Employee__c emp : emps) {
                Boolean needsUpdate = false;
                if (emp.Status__c != 'Approved') {
                    emp.Status__c = 'Approved';
                    needsUpdate = true;
                }
                Id targetPjpId = empToPjpMap.get(emp.Id);
                if (targetPjpId != null && emp.PJP__c != targetPjpId) {
                    emp.PJP__c = targetPjpId;
                    needsUpdate = true;
                }
                if (needsUpdate) {
                    empsToUpdate.add(emp);
                }
            }
        }

        if (!rejectedEmployeeIds.isEmpty()) {
            List<Employee__c> emps = [
                SELECT Id, Status__c 
                FROM Employee__c 
                WHERE Id IN :rejectedEmployeeIds
            ];
            for (Employee__c emp : emps) {
                if (emp.Status__c == 'Pending') {
                    emp.Status__c = 'Rejected';
                    empsToUpdate.add(emp);
                }
            }
        }

        if (!empsToUpdate.isEmpty()) {
            update empsToUpdate;
        }
    }
}