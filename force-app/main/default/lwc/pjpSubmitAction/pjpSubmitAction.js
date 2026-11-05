import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import { notifyRecordUpdateAvailable } from 'lightning/uiRecordApi';
import getPJPApprovalDetails from '@salesforce/apex/SFANDMSController.getPJPApprovalDetails';
import submitPJPForApproval from '@salesforce/apex/SFANDMSController.submitPJPForApproval';

export default class PjpSubmitAction extends LightningElement {
    @api recordId;
    @track isLoading = false;
    @track approvalInfo = null;

    connectedCallback() {
        if (this.recordId) {
            this.loadApprovalDetails();
        }
    }

    loadApprovalDetails() {
        this.isLoading = true;
        getPJPApprovalDetails({ pjpId: this.recordId })
            .then(data => {
                this.approvalInfo = data;
                this.isLoading = false;
            })
            .catch(error => {
                this.isLoading = false;
                console.error('Error loading PJP details:', error);
            });
    }

    get targetApproverText() {
        if (this.approvalInfo && this.approvalInfo.approverUserName) {
            return this.approvalInfo.approverUserName;
        }
        return 'Reporting Manager';
    }

    get isAlreadyApproved() {
        return this.approvalInfo && this.approvalInfo.pjpStatus === 'Approved';
    }

    get isAlreadySubmitted() {
        return this.approvalInfo && this.approvalInfo.pjpStatus === 'Submitted';
    }

    get isSubmitDisabled() {
        return this.isLoading || 
               (this.approvalInfo && !this.approvalInfo.canSubmit) ||
               this.isAlreadyApproved ||
               this.isAlreadySubmitted;
    }

    async handleSubmit() {
        this.isLoading = true;
        try {
            const result = await submitPJPForApproval({ pjpId: this.recordId });
            this.isLoading = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Submitted for Approval',
                    message: result.message || 'PJP submitted for approval successfully.',
                    variant: 'success'
                })
            );
            await notifyRecordUpdateAvailable([{ recordId: this.recordId }]);
            this.dispatchEvent(new CloseActionScreenEvent());
            setTimeout(() => {
                window.location.reload();
            }, 600);
        } catch (error) {
            this.isLoading = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error Submitting PJP',
                    message: error.body ? error.body.message : error.message,
                    variant: 'error'
                })
            );
        }
    }

    handleCancel() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }
}