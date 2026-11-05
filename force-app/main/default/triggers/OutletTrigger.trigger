trigger OutletTrigger on Outlet__c (before insert, before update) {
    OutletTriggerHandler.handleBefore(Trigger.new, Trigger.oldMap);
}