trigger SchemeDurationTrigger on Scheme__c (before insert, before update) {
    // 1. Gather all Buy_Product__c IDs to fetch product MRP & RBP
    Set<Id> prodIds = new Set<Id>();
    for (Scheme__c sc : Trigger.new) {
        if (sc.Buy_Product__c != null) {
            prodIds.add(sc.Buy_Product__c);
        }
    }
    
    Map<Id, Product__c> prodMap = new Map<Id, Product__c>();
    if (!prodIds.isEmpty()) {
        prodMap = new Map<Id, Product__c>([
            SELECT Id, Name, Product_Price_MRP__c, Product_Price_RBP__c 
            FROM Product__c 
            WHERE Id IN :prodIds
        ]);
    }

    for (Scheme__c sc : Trigger.new) {
        // --- Product Pricing: Product MRP and Product RBP ALWAYS come automatically from Buy Product ---
        if (sc.Buy_Product__c != null && prodMap.containsKey(sc.Buy_Product__c)) {
            Product__c p = prodMap.get(sc.Buy_Product__c);
            sc.Product_MRP__c = p.Product_Price_MRP__c;
            sc.Product_RBP__c = p.Product_Price_RBP__c;
        } else if (sc.Buy_Product__c == null) {
            sc.Product_MRP__c = null;
            sc.Product_RBP__c = null;
        }
        
        // Determine base price: RBP takes precedence if > 0, else MRP
        Decimal basePrice = (sc.Product_RBP__c != null && sc.Product_RBP__c > 0) ? sc.Product_RBP__c : (sc.Product_MRP__c != null ? sc.Product_MRP__c : 0);
        
        // Auto-calculate Discount Amount when Discount Percentage is provided
        if (sc.Discount_Percentage__c != null && basePrice > 0) {
            sc.Discount_Amount__c = (basePrice * (sc.Discount_Percentage__c / 100.0)).setScale(2, System.RoundingMode.HALF_UP);
        } else if (sc.Discount_Percentage__c == null) {
            sc.Discount_Amount__c = null;
        }
        
        // Auto-calculate Total Savings: Discount Amount + Case Offer Price + Bundle Offer Price
        Boolean hasPricing = (sc.Discount_Amount__c != null || sc.Case_Offer_Price__c != null || sc.Bundle_Price__c != null);
        if (hasPricing) {
            Decimal totalSavings = 0;
            if (sc.Discount_Amount__c != null) {
                totalSavings += sc.Discount_Amount__c;
            }
            if (sc.Case_Offer_Price__c != null) {
                totalSavings += sc.Case_Offer_Price__c;
            }
            if (sc.Bundle_Price__c != null) {
                totalSavings += sc.Bundle_Price__c;
            }
            sc.Total_Savings__c = totalSavings.setScale(2, System.RoundingMode.HALF_UP);
        } else {
            sc.Total_Savings__c = null;
        }

        // --- Duration & Start / End Date Logic ---
        Scheme__c oldSc = (Trigger.isUpdate && Trigger.oldMap != null) ? Trigger.oldMap.get(sc.Id) : null;
        Boolean durationChanged = (oldSc == null) || (sc.Duration_or_Timeline__c != oldSc.Duration_or_Timeline__c);
        Boolean startDateChanged = (oldSc == null) || (sc.Start_Date__c != oldSc.Start_Date__c);
        Boolean endDateChanged = (oldSc == null) || (sc.End_Date__c != oldSc.End_Date__c);
        
        // Case 1: Duration is provided, Start Date is provided, and (End Date is null OR duration was explicitly changed)
        if (sc.Duration_or_Timeline__c != null && sc.Start_Date__c != null && (sc.End_Date__c == null || (durationChanged && !endDateChanged))) {
            try {
                Integer durationVal = Integer.valueOf(sc.Duration_or_Timeline__c.trim());
                if (durationVal > 0) {
                    sc.End_Date__c = sc.Start_Date__c.addDays(durationVal - 1);
                }
            } catch (Exception e) {
                // If Duration_or_Timeline is not a plain number, ignore
            }
        }
        // Case 2: Start Date and End Date are provided, and (Duration is null OR End Date / Start Date changed)
        else if (sc.Start_Date__c != null && sc.End_Date__c != null && (sc.Duration_or_Timeline__c == null || (endDateChanged && !durationChanged))) {
            Integer days = sc.Start_Date__c.daysBetween(sc.End_Date__c) + 1;
            if (days > 0) {
                sc.Duration_or_Timeline__c = String.valueOf(days);
            }
        }
    }
}