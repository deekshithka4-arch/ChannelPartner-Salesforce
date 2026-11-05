public with sharing class SalesOrderTriggerHandler {
    public static void handleBeforeInsert(List<Sales_Order__c> newOrders) {
        populateRelationshipsAndDetails(newOrders);
    }

    public static void handleBeforeUpdate(List<Sales_Order__c> newOrders, Map<Id, Sales_Order__c> oldMap) {
        populateRelationshipsAndDetails(newOrders);
    }

    private static void populateRelationshipsAndDetails(List<Sales_Order__c> orders) {
        Set<Id> outletIds = new Set<Id>();
        Set<String> outletNames = new Set<String>();
        Set<Id> productIds = new Set<Id>();
        Set<String> productNames = new Set<String>();

        for (Sales_Order__c so : orders) {
            if (so.Outlet__c != null) {
                outletIds.add(so.Outlet__c);
            } else if (String.isNotBlank(so.Outlet_Name__c)) {
                outletNames.add(so.Outlet_Name__c.trim());
            }

            if (so.Product__c != null) {
                productIds.add(so.Product__c);
            } else if (String.isNotBlank(so.Product_Name__c)) {
                productNames.add(so.Product_Name__c.trim());
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
            productsById = new Map<Id, Product__c>([SELECT Id, Name, Product_Name__c, Product_Code__c FROM Product__c WHERE Id IN :productIds]);
        }

        Map<String, Product__c> productsByName = new Map<String, Product__c>();
        if (!productNames.isEmpty()) {
            for (Product__c prod : [SELECT Id, Name, Product_Name__c, Product_Code__c FROM Product__c WHERE Name IN :productNames OR Product_Name__c IN :productNames]) {
                if (String.isNotBlank(prod.Name)) {
                    productsByName.put(prod.Name.toLowerCase(), prod);
                }
                if (String.isNotBlank(prod.Product_Name__c)) {
                    productsByName.put(prod.Product_Name__c.toLowerCase(), prod);
                }
            }
        }

        for (Sales_Order__c so : orders) {
            // Outlet sync: Always ensure Outlet_Name__c matches the Outlet record
            if (so.Outlet__c != null && outletsById.containsKey(so.Outlet__c)) {
                Outlet__c out = outletsById.get(so.Outlet__c);
                so.Outlet_Name__c = String.isNotBlank(out.Name) ? out.Name : out.Outlet_Name__c;
            } else if (so.Outlet__c == null && String.isNotBlank(so.Outlet_Name__c)) {
                String key = so.Outlet_Name__c.trim().toLowerCase();
                if (outletsByName.containsKey(key)) {
                    so.Outlet__c = outletsByName.get(key);
                }
            }

            // Product sync: Always ensure Product_Name__c matches the Product record
            if (so.Product__c != null && productsById.containsKey(so.Product__c)) {
                Product__c p = productsById.get(so.Product__c);
                so.Product_Name__c = String.isNotBlank(p.Name) ? p.Name : p.Product_Name__c;
                if (String.isBlank(so.SKU__c) && String.isNotBlank(p.Product_Code__c)) {
                    so.SKU__c = p.Product_Code__c;
                }
            } else if (so.Product__c == null && String.isNotBlank(so.Product_Name__c)) {
                String key = so.Product_Name__c.trim().toLowerCase();
                if (productsByName.containsKey(key)) {
                    Product__c p = productsByName.get(key);
                    so.Product__c = p.Id;
                    so.Product_Name__c = String.isNotBlank(p.Name) ? p.Name : p.Product_Name__c;
                    if (String.isBlank(so.SKU__c) && String.isNotBlank(p.Product_Code__c)) {
                        so.SKU__c = p.Product_Code__c;
                    }
                }
            }

            // Amount and Tax calculation
            if (so.Total_Amount__c != null && so.Gross_Amount__c != null) {
                if (so.Tax_Amount__c == null || so.Tax_Amount__c == 0) {
                    so.Tax_Amount__c = (so.Total_Amount__c - so.Gross_Amount__c).setScale(2, System.RoundingMode.HALF_UP);
                }
            } else if (so.Gross_Amount__c != null && so.Tax_Amount__c != null && so.Total_Amount__c == null) {
                so.Total_Amount__c = (so.Gross_Amount__c + so.Tax_Amount__c).setScale(2, System.RoundingMode.HALF_UP);
            } else if (so.Gross_Amount__c != null && so.Total_Amount__c == null && so.Tax_Amount__c == null) {
                so.Tax_Amount__c = (so.Gross_Amount__c * 0.18).setScale(2, System.RoundingMode.HALF_UP);
                so.Total_Amount__c = (so.Gross_Amount__c + so.Tax_Amount__c).setScale(2, System.RoundingMode.HALF_UP);
            } else if (so.Total_Amount__c != null && so.Gross_Amount__c == null) {
                if (so.Tax_Amount__c != null) {
                    so.Gross_Amount__c = (so.Total_Amount__c - so.Tax_Amount__c).setScale(2, System.RoundingMode.HALF_UP);
                } else {
                    so.Gross_Amount__c = (so.Total_Amount__c / 1.18).setScale(2, System.RoundingMode.HALF_UP);
                    so.Tax_Amount__c = (so.Total_Amount__c - so.Gross_Amount__c).setScale(2, System.RoundingMode.HALF_UP);
                }
            }
        }
    }
}