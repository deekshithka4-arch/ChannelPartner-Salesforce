@IsTest
private class CPOnboardingTriggerHandlerTest {

    @IsTest
    static void testChannelPartnerCreation() {

        Channel_Partner__c cp =
            new Channel_Partner__c();

        cp.Company_Name__c =
            'ABC Realty';

        cp.Contact_Person__c =
            'Rahul Kumar';

        cp.Email__c =
            'rahul@abcrealty.com';

        cp.Mobile__c =
            '9876543210';

        cp.Partner_Type__c =
            'Company';

        cp.PAN_Number__c =
            'ABCDE1234F';

        cp.CP_Status__c =
            'Submitted';

        insert cp;

        Channel_Partner__c result = [
            SELECT Id,
                   CP_Status__c,
                   KYC_Status__c,
                   CP_Sourcing_Executive__c
            FROM Channel_Partner__c
            WHERE Id = :cp.Id
        ];

        System.assertEquals(
            'Assigned',
            result.CP_Status__c
        );

        System.assertEquals(
            'Submitted',
            result.KYC_Status__c
        );

        System.assertNotEquals(
            null,
            result.CP_Sourcing_Executive__c
        );
    }
}