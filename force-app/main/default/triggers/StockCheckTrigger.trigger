trigger StockCheckTrigger on Stock_Check__c (before insert, before update) {
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            StockCheckTriggerHandler.handleBeforeInsert(Trigger.new);
        } else if (Trigger.isUpdate) {
            StockCheckTriggerHandler.handleBeforeUpdate(Trigger.new, Trigger.oldMap);
        }
    }
}