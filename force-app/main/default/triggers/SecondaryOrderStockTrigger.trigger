trigger SecondaryOrderStockTrigger on Secondary_Order__c (after insert, after update) {
    Set<String> distNames = new Set<String>();
    Set<String> prodNames = new Set<String>();

    for (Secondary_Order__c so : Trigger.new) {
        if (so.Distributor_Name__c != null && so.Product_Name__c != null) {
            distNames.add(so.Distributor_Name__c.trim());
            prodNames.add(so.Product_Name__c.trim());
        }
    }

    if (distNames.isEmpty()) return;

    Map<String, DMS_Stock__c> stockMap = new Map<String, DMS_Stock__c>();
    for (DMS_Stock__c stk : [
        SELECT Id, Distributor_Name__c, Product_Name__c, Purchased_Cases__c, Supplied_Cases__c,
               Remaining_Cases__c, Full_Cases_In_Stock__c, Total_Available_Cases__c, Total_Available_Pieces__c,
               Pieces_Per_Case__c, Stock_Status__c
        FROM DMS_Stock__c
        WHERE Distributor_Name__c IN :distNames
    ]) {
        String key = (stk.Distributor_Name__c + '_' + stk.Product_Name__c).toLowerCase();
        stockMap.put(key, stk);
    }

    List<DMS_Stock__c> toUpdate = new List<DMS_Stock__c>();
    Set<Id> updatedIds = new Set<Id>();

    for (Secondary_Order__c so : Trigger.new) {
        Boolean isNew = Trigger.isInsert;
        Boolean isStatusChangedToSupplied = Trigger.isUpdate && 
            Trigger.oldMap.get(so.Id).Status__c != so.Status__c && 
            (so.Status__c == 'Supplied' || so.Status__c == 'Approved') &&
            (Trigger.oldMap.get(so.Id).Status__c == 'Draft' || Trigger.oldMap.get(so.Id).Status__c == 'Cancelled');

        if (!isNew && !isStatusChangedToSupplied) continue;

        String key = (so.Distributor_Name__c + '_' + so.Product_Name__c).toLowerCase();
        DMS_Stock__c stk = stockMap.get(key);

        if (stk != null && !updatedIds.contains(stk.Id)) {
            Decimal qty = so.Quantity__c != null ? so.Quantity__c : 1;
            Decimal pcs = stk.Pieces_Per_Case__c != null && stk.Pieces_Per_Case__c > 0 ? stk.Pieces_Per_Case__c : 24;
            Decimal casesToDeduct = (so.Unit_Type__c == 'Pieces') ? (qty / pcs) : qty;

            Decimal currSupplied = stk.Supplied_Cases__c != null ? stk.Supplied_Cases__c : 0;
            Decimal purchased = stk.Purchased_Cases__c != null ? stk.Purchased_Cases__c : 90;
            Decimal newSupplied = currSupplied + casesToDeduct;
            Decimal newRemaining = Math.max(0, purchased - newSupplied);

            stk.Supplied_Cases__c = newSupplied;
            stk.Remaining_Cases__c = newRemaining;
            stk.Full_Cases_In_Stock__c = newRemaining;
            stk.Total_Available_Cases__c = newRemaining;
            stk.Total_Available_Pieces__c = newRemaining * pcs;
            stk.Stock_Status__c = newRemaining > 2 ? 'In Stock' : (newRemaining > 0 ? 'Low Stock' : 'Out of Stock');

            toUpdate.add(stk);
            updatedIds.add(stk.Id);
        }
    }

    if (!toUpdate.isEmpty()) {
        update toUpdate;
    }
}