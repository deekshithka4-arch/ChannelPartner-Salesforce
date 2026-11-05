trigger LeaveTrigger on Leave__c (before insert, before update) {
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            LeaveTriggerHandler.handleBeforeInsert(Trigger.new);
        } else if (Trigger.isUpdate) {
            LeaveTriggerHandler.handleBeforeUpdate(Trigger.new, Trigger.oldMap);
        }
    }
}