trigger AssetSurveyTrigger on Asset_Survey__c (before insert, before update) {
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            AssetSurveyTriggerHandler.handleBeforeInsert(Trigger.new);
        } else if (Trigger.isUpdate) {
            AssetSurveyTriggerHandler.handleBeforeUpdate(Trigger.new, Trigger.oldMap);
        }
    }
}