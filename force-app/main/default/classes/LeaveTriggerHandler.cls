public with sharing class LeaveTriggerHandler {
    public static void handleBeforeInsert(List<Leave__c> newRecords) {
        populateRelationshipsAndDefaults(newRecords);
    }

    public static void handleBeforeUpdate(List<Leave__c> newRecords, Map<Id, Leave__c> oldMap) {
        populateRelationshipsAndDefaults(newRecords);
    }

    private static void populateRelationshipsAndDefaults(List<Leave__c> records) {
        Set<Id> empIds = new Set<Id>();
        Set<String> empNames = new Set<String>();

        for (Leave__c l : records) {
            if (l.Employee__c != null) {
                empIds.add(l.Employee__c);
            } else if (String.isNotBlank(l.Employee_Name__c)) {
                empNames.add(l.Employee_Name__c.trim());
            }

            // Defaults
            if (l.Leave_Date__c == null) {
                l.Leave_Date__c = Date.today();
            }
            if (String.isBlank(l.Type__c)) {
                l.Type__c = 'Casual Leave';
            }
            if (String.isBlank(l.Status__c)) {
                l.Status__c = 'Hold';
            }
            if (String.isBlank(l.Approver_Name__c)) {
                l.Approver_Name__c = 'Ashok (Branch Manager)';
            }
        }

        Map<Id, Employee__c> employeesById = new Map<Id, Employee__c>();
        if (!empIds.isEmpty()) {
            employeesById = new Map<Id, Employee__c>([SELECT Id, Name FROM Employee__c WHERE Id IN :empIds]);
        }

        Map<String, Id> employeesByName = new Map<String, Id>();
        if (!empNames.isEmpty()) {
            for (Employee__c emp : [SELECT Id, Name FROM Employee__c WHERE Name IN :empNames]) {
                if (String.isNotBlank(emp.Name)) {
                    employeesByName.put(emp.Name.toLowerCase(), emp.Id);
                }
            }
        }

        for (Leave__c l : records) {
            // Employee sync
            if (l.Employee__c != null && employeesById.containsKey(l.Employee__c)) {
                l.Employee_Name__c = employeesById.get(l.Employee__c).Name;
            } else if (l.Employee__c == null && String.isNotBlank(l.Employee_Name__c)) {
                String key = l.Employee_Name__c.trim().toLowerCase();
                if (employeesByName.containsKey(key)) {
                    l.Employee__c = employeesByName.get(key);
                }
            }
        }
    }
}