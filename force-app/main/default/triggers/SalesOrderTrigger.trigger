/**********************
Trigger Name : SalesOrderTrigger
Company : Fingertipplus
Created Date : 19-10-2026
@description : This trigger handles before-insert and before-update
operations on Sales_Order__c records by delegating the business logic
to the SalesOrderTriggerHandler class.
Used By : SalesOrderTriggerHandler
Test Class : SalesOrderTriggerTest

Change Log:
Ver | Author | Date       | Description
1.0 |         | 19-10-2026 | Initial version

**********************/

trigger SalesOrderTrigger on Sales_Order__c (before insert, before update) {
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            // Invoke handler method to process Sales Order records before insertion.
            SalesOrderTriggerHandler.handleBeforeInsert(Trigger.new);
        } else if (Trigger.isUpdate) {
            // Invoke handler method to process Sales Order records before update,
            // passing both the new record values and the previous record values.
            SalesOrderTriggerHandler.handleBeforeUpdate(Trigger.new, Trigger.oldMap);
        }
    }
}