public with sharing class CompetitorActivityTriggerHandler {
    public static void handleBeforeInsert(List<Competitor_Activity__c> newActivities) {
        populateOutletAndDefaults(newActivities);
    }

    public static void handleBeforeUpdate(List<Competitor_Activity__c> newActivities, Map<Id, Competitor_Activity__c> oldMap) {
        populateOutletAndDefaults(newActivities);
    }

    private static void populateOutletAndDefaults(List<Competitor_Activity__c> activities) {
        Set<Id> outletIds = new Set<Id>();
        Set<String> outletNames = new Set<String>();

        for (Competitor_Activity__c ca : activities) {
            if (ca.Outlet__c != null) {
                outletIds.add(ca.Outlet__c);
            } else if (String.isNotBlank(ca.Outlet_Name__c)) {
                outletNames.add(ca.Outlet_Name__c.trim());
            }

            // Default scheme if blank
            if (String.isBlank(ca.Schemes_Any__c)) {
                ca.Schemes_Any__c = 'None';
            }
        }

        Map<Id, Outlet__c> outletsById = new Map<Id, Outlet__c>();
        if (!outletIds.isEmpty()) {
            outletsById = new Map<Id, Outlet__c>([SELECT Id, Name, Outlet_Name__c FROM Outlet__c WHERE Id IN :outletIds]);
        }

        Map<String, Id> outletsByName = new Map<String, Id>();
        if (!outletNames.isEmpty()) {
            for (Outlet__c out : [SELECT Id, Name, Outlet_Name__c FROM Outlet__c WHERE Name IN :outletNames OR Outlet_Name__c IN :outletNames]) {
                if (String.isNotBlank(out.Name)) {
                    outletsByName.put(out.Name.toLowerCase(), out.Id);
                }
                if (String.isNotBlank(out.Outlet_Name__c)) {
                    outletsByName.put(out.Outlet_Name__c.toLowerCase(), out.Id);
                }
            }
        }

        for (Competitor_Activity__c ca : activities) {
            // Outlet sync: Always ensure Outlet_Name__c matches the Outlet record
            if (ca.Outlet__c != null && outletsById.containsKey(ca.Outlet__c)) {
                Outlet__c out = outletsById.get(ca.Outlet__c);
                ca.Outlet_Name__c = String.isNotBlank(out.Name) ? out.Name : out.Outlet_Name__c;
            } else if (ca.Outlet__c == null && String.isNotBlank(ca.Outlet_Name__c)) {
                String key = ca.Outlet_Name__c.trim().toLowerCase();
                if (outletsByName.containsKey(key)) {
                    ca.Outlet__c = outletsByName.get(key);
                }
            }
        }
    }
}