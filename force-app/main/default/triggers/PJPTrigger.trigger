trigger PJPTrigger on PJP__c (before insert, before update, after insert, after update) {
    if (Trigger.isBefore) {
        PJPTriggerHandler.handleBefore(Trigger.new, Trigger.oldMap);
    } else if (Trigger.isAfter) {
        PJPTriggerHandler.handleAfter(Trigger.new, Trigger.oldMap);
    }
}