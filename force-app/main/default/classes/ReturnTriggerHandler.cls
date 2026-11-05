public with sharing class ReturnTriggerHandler {
    public static void handleBeforeInsert(List<Return__c> newReturns) {
        populateRelationshipsAndDefaults(newReturns);
    }

    public static void handleBeforeUpdate(List<Return__c> newReturns, Map<Id, Return__c> oldMap) {
        populateRelationshipsAndDefaults(newReturns);
    }

    private static void populateRelationshipsAndDefaults(List<Return__c> returns) {
        Set<Id> outletIds = new Set<Id>();
        Set<String> outletNames = new Set<String>();
        Set<Id> productIds = new Set<Id>();
        Set<String> productNames = new Set<String>();

        for (Return__c r : returns) {
            if (r.Outlet__c != null) {
                outletIds.add(r.Outlet__c);
            } else if (String.isNotBlank(r.Outlet_Name__c)) {
                outletNames.add(r.Outlet_Name__c.trim());
            }

            if (r.Product__c != null) {
                productIds.add(r.Product__c);
            } else if (String.isNotBlank(r.Product_Name__c)) {
                productNames.add(r.Product_Name__c.trim());
            }

            // Defaults
            if (r.Quantity__c == null) {
                r.Quantity__c = 0;
            }
            if (r.Manufacturing_Date__c == null) {
                r.Manufacturing_Date__c = Date.today().addMonths(-2);
            }
            if (String.isBlank(r.Return_Reason__c)) {
                r.Return_Reason__c = 'Damaged Packaging';
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

        Map<Id, Product__c> productsById = new Map<Id, Product__c>();
        if (!productIds.isEmpty()) {
            productsById = new Map<Id, Product__c>([SELECT Id, Name, Product_Name__c FROM Product__c WHERE Id IN :productIds]);
        }

        Map<String, Product__c> productsByName = new Map<String, Product__c>();
        if (!productNames.isEmpty()) {
            for (Product__c prod : [SELECT Id, Name, Product_Name__c FROM Product__c WHERE Name IN :productNames OR Product_Name__c IN :productNames]) {
                if (String.isNotBlank(prod.Name)) {
                    productsByName.put(prod.Name.toLowerCase(), prod);
                }
                if (String.isNotBlank(prod.Product_Name__c)) {
                    productsByName.put(prod.Product_Name__c.toLowerCase(), prod);
                }
            }
        }

        for (Return__c r : returns) {
            // Outlet sync
            if (r.Outlet__c != null && outletsById.containsKey(r.Outlet__c)) {
                Outlet__c out = outletsById.get(r.Outlet__c);
                r.Outlet_Name__c = String.isNotBlank(out.Name) ? out.Name : out.Outlet_Name__c;
            } else if (r.Outlet__c == null && String.isNotBlank(r.Outlet_Name__c)) {
                String key = r.Outlet_Name__c.trim().toLowerCase();
                if (outletsByName.containsKey(key)) {
                    r.Outlet__c = outletsByName.get(key);
                }
            }

            // Product sync
            if (r.Product__c != null && productsById.containsKey(r.Product__c)) {
                Product__c p = productsById.get(r.Product__c);
                r.Product_Name__c = String.isNotBlank(p.Name) ? p.Name : p.Product_Name__c;
            } else if (r.Product__c == null && String.isNotBlank(r.Product_Name__c)) {
                String key = r.Product_Name__c.trim().toLowerCase();
                if (productsByName.containsKey(key)) {
                    Product__c p = productsByName.get(key);
                    r.Product__c = p.Id;
                    r.Product_Name__c = String.isNotBlank(p.Name) ? p.Name : p.Product_Name__c;
                }
            }
        }
    }
}