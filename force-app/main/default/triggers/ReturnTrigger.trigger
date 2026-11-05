trigger ReturnTrigger on Return__c (before insert, before update) {
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            ReturnTriggerHandler.handleBeforeInsert(Trigger.new);
        } else if (Trigger.isUpdate) {
            ReturnTriggerHandler.handleBeforeUpdate(Trigger.new, Trigger.oldMap);
        }
    }
}