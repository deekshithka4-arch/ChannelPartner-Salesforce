public with sharing class AssetSurveyTriggerHandler {
    public static void handleBeforeInsert(List<Asset_Survey__c> newSurveys) {
        populateOutletAndDefaults(newSurveys);
    }

    public static void handleBeforeUpdate(List<Asset_Survey__c> newSurveys, Map<Id, Asset_Survey__c> oldMap) {
        populateOutletAndDefaults(newSurveys);
    }

    private static void populateOutletAndDefaults(List<Asset_Survey__c> surveys) {
        Set<Id> outletIds = new Set<Id>();
        Set<String> outletNames = new Set<String>();

        for (Asset_Survey__c asv : surveys) {
            if (asv.Outlet__c != null) {
                outletIds.add(asv.Outlet__c);
            } else if (String.isNotBlank(asv.Outlet_Name__c)) {
                outletNames.add(asv.Outlet_Name__c.trim());
            }

            // Default status if empty
            if (String.isBlank(asv.Status__c)) {
                asv.Status__c = 'Working';
            }

            // Default given date if empty
            if (asv.Given_Date__c == null) {
                asv.Given_Date__c = Date.today();
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

        for (Asset_Survey__c asv : surveys) {
            // Outlet sync: Always ensure Outlet_Name__c matches the Outlet record
            if (asv.Outlet__c != null && outletsById.containsKey(asv.Outlet__c)) {
                Outlet__c out = outletsById.get(asv.Outlet__c);
                asv.Outlet_Name__c = String.isNotBlank(out.Name) ? out.Name : out.Outlet_Name__c;
            } else if (asv.Outlet__c == null && String.isNotBlank(asv.Outlet_Name__c)) {
                String key = asv.Outlet_Name__c.trim().toLowerCase();
                if (outletsByName.containsKey(key)) {
                    asv.Outlet__c = outletsByName.get(key);
                }
            }
        }
    }
}