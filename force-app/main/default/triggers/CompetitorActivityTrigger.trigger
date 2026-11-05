trigger CompetitorActivityTrigger on Competitor_Activity__c (before insert, before update) {
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            CompetitorActivityTriggerHandler.handleBeforeInsert(Trigger.new);
        } else if (Trigger.isUpdate) {
            CompetitorActivityTriggerHandler.handleBeforeUpdate(Trigger.new, Trigger.oldMap);
        }
    }
}