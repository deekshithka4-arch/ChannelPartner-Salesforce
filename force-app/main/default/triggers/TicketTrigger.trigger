trigger TicketTrigger on Ticket__c (before insert, before update) {
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            TicketTriggerHandler.handleBeforeInsert(Trigger.new);
        } else if (Trigger.isUpdate) {
            TicketTriggerHandler.handleBeforeUpdate(Trigger.new, Trigger.oldMap);
        }
    }
}