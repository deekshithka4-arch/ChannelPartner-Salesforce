public with sharing class BeatTriggerHandler {
    public static void handleBefore(List<Beat__c> newBeats, Map<Id, Beat__c> oldMap) {
        Set<Id> empIds = new Set<Id>();
        for (Beat__c beat : newBeats) {
            // Remove duplicate second Beat Name field value completely as requested
            beat.Beat_Name__c = null;

            if (beat.Beat_Assigned_To__c != null) {
                Boolean isNew = (oldMap == null);
                Boolean changed = !isNew && (oldMap.get(beat.Id).Beat_Assigned_To__c != beat.Beat_Assigned_To__c);
                if (isNew || changed || beat.Geography__c == null || String.isBlank(beat.Distributor__c)) {
                    empIds.add(beat.Beat_Assigned_To__c);
                }
            }
        }

        if (!empIds.isEmpty()) {
            Map<Id, Employee__c> empMap = new Map<Id, Employee__c>(
                [SELECT Id, Name, Distributor__c, Geography__c FROM Employee__c WHERE Id IN :empIds WITH USER_MODE]
            );

            for (Beat__c beat : newBeats) {
                if (beat.Beat_Assigned_To__c != null && empMap.containsKey(beat.Beat_Assigned_To__c)) {
                    Employee__c emp = empMap.get(beat.Beat_Assigned_To__c);
                    if (String.isNotBlank(emp.Distributor__c) && (String.isBlank(beat.Distributor__c) || (oldMap != null && oldMap.get(beat.Id).Beat_Assigned_To__c != beat.Beat_Assigned_To__c))) {
                        beat.Distributor__c = emp.Distributor__c;
                    }
                    if (emp.Geography__c != null && (beat.Geography__c == null || (oldMap != null && oldMap.get(beat.Id).Beat_Assigned_To__c != beat.Beat_Assigned_To__c))) {
                        beat.Geography__c = emp.Geography__c;
                    }
                }
            }
        }
    }
}