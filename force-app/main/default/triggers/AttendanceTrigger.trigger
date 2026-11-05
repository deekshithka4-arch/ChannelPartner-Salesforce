trigger AttendanceTrigger on Attendance__c (before insert, before update) {
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            AttendanceTriggerHandler.handleBeforeInsert(Trigger.new);
        } else if (Trigger.isUpdate) {
            AttendanceTriggerHandler.handleBeforeUpdate(Trigger.new, Trigger.oldMap);
        }
    }
}