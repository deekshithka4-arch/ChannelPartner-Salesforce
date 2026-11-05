public with sharing class StockCheckTriggerHandler {
    public static void handleBeforeInsert(List<Stock_Check__c> newChecks) {
        populateRelationshipsAndDefaults(newChecks);
    }

    public static void handleBeforeUpdate(List<Stock_Check__c> newChecks, Map<Id, Stock_Check__c> oldMap) {
        populateRelationshipsAndDefaults(newChecks);
    }

    private static void populateRelationshipsAndDefaults(List<Stock_Check__c> checks) {
        Set<Id> outletIds = new Set<Id>();
        Set<String> outletNames = new Set<String>();
        Set<Id> productIds = new Set<Id>();
        Set<String> productNames = new Set<String>();

        for (Stock_Check__c sc : checks) {
            if (sc.Outlet__c != null) {
                outletIds.add(sc.Outlet__c);
            } else if (String.isNotBlank(sc.Outlet_Name__c)) {
                outletNames.add(sc.Outlet_Name__c.trim());
            }

            if (sc.Product__c != null) {
                productIds.add(sc.Product__c);
            } else if (String.isNotBlank(sc.Product_Name__c)) {
                productNames.add(sc.Product_Name__c.trim());
            }

            // Defaults
            if (sc.Quantity__c == null) {
                sc.Quantity__c = 0;
            }
            if (sc.Manufacturing_Date__c == null) {
                sc.Manufacturing_Date__c = Date.today().addMonths(-1);
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

        for (Stock_Check__c sc : checks) {
            // Outlet sync
            if (sc.Outlet__c != null && outletsById.containsKey(sc.Outlet__c)) {
                Outlet__c out = outletsById.get(sc.Outlet__c);
                sc.Outlet_Name__c = String.isNotBlank(out.Name) ? out.Name : out.Outlet_Name__c;
            } else if (sc.Outlet__c == null && String.isNotBlank(sc.Outlet_Name__c)) {
                String key = sc.Outlet_Name__c.trim().toLowerCase();
                if (outletsByName.containsKey(key)) {
                    sc.Outlet__c = outletsByName.get(key);
                }
            }

            // Product sync
            if (sc.Product__c != null && productsById.containsKey(sc.Product__c)) {
                Product__c p = productsById.get(sc.Product__c);
                sc.Product_Name__c = String.isNotBlank(p.Name) ? p.Name : p.Product_Name__c;
            } else if (sc.Product__c == null && String.isNotBlank(sc.Product_Name__c)) {
                String key = sc.Product_Name__c.trim().toLowerCase();
                if (productsByName.containsKey(key)) {
                    Product__c p = productsByName.get(key);
                    sc.Product__c = p.Id;
                    sc.Product_Name__c = String.isNotBlank(p.Name) ? p.Name : p.Product_Name__c;
                }
            }
        }
    }
}