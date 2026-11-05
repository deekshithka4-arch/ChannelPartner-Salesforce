public with sharing class CPOnboardingService {

    /*
     * STEP 1:
     * Called when a new Channel Partner is created.
     */
    public static void processNewPartners(
        List<Channel_Partner__c> newPartners
    ) {

        if (newPartners == null || newPartners.isEmpty()) {
            return;
        }

        List<Channel_Partner__c> partnersToUpdate =
            new List<Channel_Partner__c>();

        User sourcingExecutive = getSourcingExecutive();

        for (Channel_Partner__c cp : newPartners) {

            if (cp.CP_Status__c == 'Submitted') {

                if (sourcingExecutive != null) {

                    cp.CP_Sourcing_Executive__c =
                        sourcingExecutive.Id;

                    cp.CP_Status__c = 'Assigned';

                    cp.KYC_Status__c = 'Submitted';
                }
            }
        }
    }


    /*
     * STEP 2:
     * Find an active CP Sourcing Executive.
     */
    private static User getSourcingExecutive() {

        List<User> users = [
            SELECT Id,
                   Name,
                   Email
            FROM User
            WHERE IsActive = true
            LIMIT 1
        ];

        if (users.isEmpty()) {
            return null;
        }

        return users[0];
    }


    /*
     * STEP 3:
     * Start verification.
     */
    public static void startVerification(
        Id channelPartnerId
    ) {

        Channel_Partner__c cp = [
            SELECT Id,
                   CP_Status__c,
                   KYC_Status__c
            FROM Channel_Partner__c
            WHERE Id = :channelPartnerId
            LIMIT 1
        ];

        cp.CP_Status__c = 'Under Verification';
        cp.KYC_Status__c = 'Under Review';

        update cp;
    }


    /*
     * STEP 4:
     * Approve verification.
     */
    public static void approveVerification(
        Id channelPartnerId,
        String remarks
    ) {

        Channel_Partner__c cp = [
            SELECT Id,
                   CP_Status__c,
                   KYC_Status__c,
                   Verification_Status__c
            FROM Channel_Partner__c
            WHERE Id = :channelPartnerId
            LIMIT 1
        ];

        cp.CP_Status__c = 'Verification Completed';
        cp.KYC_Status__c = 'Verified';
        cp.Verification_Status__c = 'Approved';

        cp.Verification_Date__c = Date.today();

        cp.Verification_Remarks__c = remarks;

        cp.Verified_By__c = UserInfo.getUserId();

        update cp;
    }


    /*
     * STEP 5:
     * Reject verification.
     */
    public static void rejectVerification(
        Id channelPartnerId,
        String remarks
    ) {

        Channel_Partner__c cp = [
            SELECT Id,
                   CP_Status__c,
                   KYC_Status__c,
                   Verification_Status__c
            FROM Channel_Partner__c
            WHERE Id = :channelPartnerId
            LIMIT 1
        ];

        cp.CP_Status__c = 'Rejected';
        cp.KYC_Status__c = 'Rejected';
        cp.Verification_Status__c = 'Rejected';

        cp.Verification_Date__c = Date.today();

        cp.Verification_Remarks__c = remarks;

        cp.Verified_By__c = UserInfo.getUserId();

        update cp;
    }


    /*
     * STEP 6:
     * Submit CP for final approval.
     */
    public static void submitForApproval(
        Id channelPartnerId
    ) {

        Channel_Partner__c cp = [
            SELECT Id,
                   CP_Status__c
            FROM Channel_Partner__c
            WHERE Id = :channelPartnerId
            LIMIT 1
        ];

        if (cp.CP_Status__c != 'Verification Completed') {

            throw new AuraHandledException(
                'CP must complete verification before approval.'
            );
        }

        cp.CP_Status__c =
            'Submitted for Confirmation';

        cp.Approval_Status__c =
            'Pending';

        update cp;
    }


    /*
     * STEP 7:
     * Final approval.
     */
    public static void approveCP(
        Id channelPartnerId,
        String remarks
    ) {

        Channel_Partner__c cp = [
            SELECT Id,
                   CP_Status__c,
                   Approval_Status__c
            FROM Channel_Partner__c
            WHERE Id = :channelPartnerId
            LIMIT 1
        ];

        if (cp.CP_Status__c !=
            'Submitted for Confirmation') {

            throw new AuraHandledException(
                'CP is not ready for final approval.'
            );
        }

        cp.CP_Status__c = 'Active';

        cp.Approval_Status__c =
            'Approved';

        cp.Approval_Date__c =
            Date.today();

        cp.Approval_Remarks__c =
            remarks;

        cp.Approved_By__c =
            UserInfo.getUserId();

        update cp;
    }


    /*
     * STEP 8:
     * Final rejection.
     */
    public static void rejectCP(
        Id channelPartnerId,
        String remarks
    ) {

        Channel_Partner__c cp = [
            SELECT Id,
                   CP_Status__c,
                   Approval_Status__c
            FROM Channel_Partner__c
            WHERE Id = :channelPartnerId
            LIMIT 1
        ];

        cp.CP_Status__c =
            'Rejected';

        cp.Approval_Status__c =
            'Rejected';

        cp.Approval_Date__c =
            Date.today();

        cp.Approval_Remarks__c =
            remarks;

        cp.Approved_By__c =
            UserInfo.getUserId();

        update cp;
    }
}