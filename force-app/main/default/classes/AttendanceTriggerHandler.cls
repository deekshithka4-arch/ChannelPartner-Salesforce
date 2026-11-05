public with sharing class AttendanceTriggerHandler {
    public static void handleBeforeInsert(List<Attendance__c> newRecords) {
        populateRelationshipsAndDefaults(newRecords);
    }

    public static void handleBeforeUpdate(List<Attendance__c> newRecords, Map<Id, Attendance__c> oldMap) {
        populateRelationshipsAndDefaults(newRecords);
    }

    private static void populateRelationshipsAndDefaults(List<Attendance__c> records) {
        Set<Id> empIds = new Set<Id>();
        Set<String> empNames = new Set<String>();

        for (Attendance__c a : records) {
            if (a.Employee__c != null) {
                empIds.add(a.Employee__c);
            } else if (String.isNotBlank(a.Employee_Name__c)) {
                empNames.add(a.Employee_Name__c.trim());
            }

            // Defaults
            if (a.Start_Time__c == null) {
                a.Start_Time__c = Datetime.now();
            }
            if (String.isBlank(a.Status__c)) {
                a.Status__c = 'Present';
            }
            if (a.Geo_Location__Latitude__s == null && a.Geo_Location__Longitude__s == null) {
                // Default to Bengaluru central office coordinates
                a.Geo_Location__Latitude__s = 12.9716;
                a.Geo_Location__Longitude__s = 77.5946;
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

        for (Attendance__c a : records) {
            // Employee sync
            if (a.Employee__c != null && employeesById.containsKey(a.Employee__c)) {
                a.Employee_Name__c = employeesById.get(a.Employee__c).Name;
            } else if (a.Employee__c == null && String.isNotBlank(a.Employee_Name__c)) {
                String key = a.Employee_Name__c.trim().toLowerCase();
                if (employeesByName.containsKey(key)) {
                    a.Employee__c = employeesByName.get(key);
                }
            }
        }
    }
}