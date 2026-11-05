trigger BeatTrigger on Beat__c (before insert, before update) {
    BeatTriggerHandler.handleBefore(Trigger.new, Trigger.oldMap);
}