trigger ChannelPartnerTrigger
on Channel_Partner__c (before insert) {

    if (Trigger.isBefore && Trigger.isInsert) {

        CPOnboardingTriggerHandler.handleBeforeInsert(
            Trigger.new
        );

    }
}