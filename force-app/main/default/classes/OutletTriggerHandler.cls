public with sharing class OutletTriggerHandler {
    public static void handleBefore(List<Outlet__c> newOutlets, Map<Id, Outlet__c> oldMap) {
        Set<Id> beatIds = new Set<Id>();

        for (Outlet__c outlet : newOutlets) {
            // Keep Name and Outlet_Name__c in sync
            if (String.isNotBlank(outlet.Name) && String.isBlank(outlet.Outlet_Name__c)) {
                outlet.Outlet_Name__c = outlet.Name;
            } else if (String.isNotBlank(outlet.Outlet_Name__c) && String.isBlank(outlet.Name)) {
                outlet.Name = outlet.Outlet_Name__c;
            }

            if (outlet.Beat__c != null) {
                Boolean isNew = (oldMap == null);
                Boolean beatChanged = !isNew && (oldMap.get(outlet.Id).Beat__c != outlet.Beat__c);
                if (isNew || beatChanged || outlet.Geography__c == null) {
                    beatIds.add(outlet.Beat__c);
                }
            }
        }

        if (!beatIds.isEmpty()) {
            Map<Id, Beat__c> beatMap = new Map<Id, Beat__c>(
                [SELECT Id, Geography__c FROM Beat__c WHERE Id IN :beatIds WITH USER_MODE]
            );

            for (Outlet__c outlet : newOutlets) {
                if (outlet.Beat__c != null && beatMap.containsKey(outlet.Beat__c)) {
                    Beat__c beat = beatMap.get(outlet.Beat__c);
                    Boolean isNew = (oldMap == null);
                    Boolean beatChanged = !isNew && (oldMap.get(outlet.Id).Beat__c != outlet.Beat__c);

                    // Automatically auto-fill Geography from Beat if Geography is blank or Beat changed
                    if (beat.Geography__c != null && (outlet.Geography__c == null || beatChanged)) {
                        outlet.Geography__c = beat.Geography__c;
                    }
                }
            }
        }
    }
}