public with sharing class TicketTriggerHandler {
    public static void handleBeforeInsert(List<Ticket__c> newTickets) {
        populateRelationshipsAndDefaults(newTickets);
    }

    public static void handleBeforeUpdate(List<Ticket__c> newTickets, Map<Id, Ticket__c> oldMap) {
        populateRelationshipsAndDefaults(newTickets);
    }

    private static void populateRelationshipsAndDefaults(List<Ticket__c> tickets) {
        Set<Id> outletIds = new Set<Id>();
        Set<String> outletNames = new Set<String>();

        for (Ticket__c t : tickets) {
            if (t.Outlet__c != null) {
                outletIds.add(t.Outlet__c);
            } else if (String.isNotBlank(t.Outlet_Name__c)) {
                outletNames.add(t.Outlet_Name__c.trim());
            }

            // Defaults
            if (String.isBlank(t.Status__c)) {
                t.Status__c = 'New';
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

        for (Ticket__c t : tickets) {
            // Outlet sync
            if (t.Outlet__c != null && outletsById.containsKey(t.Outlet__c)) {
                Outlet__c out = outletsById.get(t.Outlet__c);
                t.Outlet_Name__c = String.isNotBlank(out.Name) ? out.Name : out.Outlet_Name__c;
            } else if (t.Outlet__c == null && String.isNotBlank(t.Outlet_Name__c)) {
                String key = t.Outlet_Name__c.trim().toLowerCase();
                if (outletsByName.containsKey(key)) {
                    t.Outlet__c = outletsByName.get(key);
                }
            }
        }
    }
}