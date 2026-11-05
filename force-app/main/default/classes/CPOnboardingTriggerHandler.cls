public with sharing class CPOnboardingTriggerHandler {

    // ============================================================
    // BEFORE INSERT
    // ============================================================

    public static void handleBeforeInsert(
        List<Channel_Partner__c> newPartners
    ) {

        if (newPartners == null || newPartners.isEmpty()) {
            return;
        }

        User executive = getExecutive();
        User sourcingHead = getSourcingHead();

        for (Channel_Partner__c cp : newPartners) {

            // ----------------------------------------------------
            // 1. CP Status
            // ----------------------------------------------------

            if (String.isBlank(cp.CP_Status__c)) {

                cp.CP_Status__c = 'Submitted';
            }


            // ----------------------------------------------------
            // 2. KYC Status
            // ----------------------------------------------------

            if (String.isBlank(cp.KYC_Status__c)) {

                cp.KYC_Status__c = 'Submitted';
            }


            // ----------------------------------------------------
            // 3. Verification Status
            // NEW CONDITION
            // ----------------------------------------------------

            if (String.isBlank(cp.Verification_Status__c)) {

                cp.Verification_Status__c = 'Pending';
            }


            // ----------------------------------------------------
            // 4. Approval Status
            // NEW CONDITION
            // ----------------------------------------------------

            if (String.isBlank(cp.Approval_Status__c)) {

                cp.Approval_Status__c = 'Pending';
            }


            // ----------------------------------------------------
            // 5. Assign CP Sourcing Executive
            // ----------------------------------------------------

            if (
                cp.CP_Sourcing_Executive__c == null &&
                executive != null
            ) {

                cp.CP_Sourcing_Executive__c =
                    executive.Id;

                cp.CP_Status__c =
                    'Assigned';
            }


            // ----------------------------------------------------
            // 6. Assign CP Sourcing Head
            // ----------------------------------------------------

            if (
                cp.CP_Sourcing_Head__c == null &&
                sourcingHead != null
            ) {

                cp.CP_Sourcing_Head__c =
                    sourcingHead.Id;
            }
        }
    }


    // ============================================================
    // BEFORE UPDATE
    // ============================================================

    public static void handleBeforeUpdate(
        List<Channel_Partner__c> newPartners,
        Map<Id, Channel_Partner__c> oldMap
    ) {

        if (newPartners == null || newPartners.isEmpty()) {
            return;
        }

        for (Channel_Partner__c cp : newPartners) {

            Channel_Partner__c oldCP =
                oldMap.get(cp.Id);


            // ====================================================
            // 1. If Verification Status is blank
            //    keep it Pending
            // ====================================================

            if (String.isBlank(cp.Verification_Status__c)) {

                cp.Verification_Status__c =
                    'Pending';
            }


            // ====================================================
            // 2. If Approval Status is blank
            //    keep it Pending
            // ====================================================

            if (String.isBlank(cp.Approval_Status__c)) {

                cp.Approval_Status__c =
                    'Pending';
            }


            // ====================================================
            // 3. Verification Started
            //
            // Pending
            //     ↓
            // In Progress
            // ====================================================

            if (
                cp.Verification_Status__c ==
                    'In Progress'
                &&
                oldCP.Verification_Status__c !=
                    'In Progress'
            ) {

                cp.CP_Status__c =
                    'Under Verification';

                cp.KYC_Status__c =
                    'Under Review';
            }


            // ====================================================
            // 4. Verification Approved
            //
            // In Progress
            //      ↓
            // Approved
            // ====================================================

            if (
                cp.Verification_Status__c ==
                    'Approved'
                &&
                oldCP.Verification_Status__c !=
                    'Approved'
            ) {

                cp.KYC_Status__c =
                    'Verified';

                cp.CP_Status__c =
                    'Verification Completed';

                cp.Verification_Date__c =
                    Date.today();

                cp.Verified_By__c =
                    UserInfo.getUserId();


                // After successful verification,
                // approval should be Pending.

                cp.Approval_Status__c =
                    'Pending';
            }


            // ====================================================
            // 5. Verification Rejected
            //
            // In Progress
            //      ↓
            // Rejected
            // ====================================================

            if (
                cp.Verification_Status__c ==
                    'Rejected'
                &&
                oldCP.Verification_Status__c !=
                    'Rejected'
            ) {

                cp.KYC_Status__c =
                    'Rejected';

                cp.CP_Status__c =
                    'Rejected';

                cp.Verification_Date__c =
                    Date.today();

                cp.Verified_By__c =
                    UserInfo.getUserId();
            }


            // ====================================================
            // 6. Final Approval
            //
            // Pending
            //    ↓
            // Approved
            // ====================================================

            if (
                cp.Approval_Status__c ==
                    'Approved'
                &&
                oldCP.Approval_Status__c !=
                    'Approved'
            ) {

                // ------------------------------------------------
                // Don't allow approval before verification.
                // ------------------------------------------------

                if (
                    cp.Verification_Status__c !=
                    'Approved'
                ) {

                    cp.addError(
                        'Channel Partner cannot be approved until Verification Status is Approved.'
                    );

                } else {

                    cp.CP_Status__c =
                        'Active';

                    cp.Approval_Date__c =
                        Date.today();

                    cp.Approval_Remarks__c =
                        cp.Approval_Remarks__c;

                    cp.Approved_By__c =
                        UserInfo.getUserId();
                }
            }


            // ====================================================
            // 7. Final Approval Rejected
            //
            // Pending
            //    ↓
            // Rejected
            // ====================================================

            if (
                cp.Approval_Status__c ==
                    'Rejected'
                &&
                oldCP.Approval_Status__c !=
                    'Rejected'
            ) {

                cp.CP_Status__c =
                    'Rejected';

                cp.Approval_Date__c =
                    Date.today();

                cp.Approved_By__c =
                    UserInfo.getUserId();
            }
        }
    }


    // ============================================================
    // GET CP SOURCING EXECUTIVE
    // ============================================================

    private static User getExecutive() {

        List<User> users = [

            SELECT
                Id,
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


    // ============================================================
    // GET CP SOURCING HEAD
    // ============================================================

    private static User getSourcingHead() {

        List<User> users = [

            SELECT
                Id,
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
}