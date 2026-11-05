import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import { notifyRecordUpdateAvailable } from 'lightning/uiRecordApi';
import getPJPApprovalDetails from '@salesforce/apex/SFANDMSController.getPJPApprovalDetails';
import approvePJP from '@salesforce/apex/SFANDMSController.approvePJP';
import rejectPJP from '@salesforce/apex/SFANDMSController.rejectPJP';

export default class PjpApproveAction extends LightningElement {
    @api recordId;
    @track isLoading = false;
    @track approvalInfo = null;
    @track decision = 'approve';
    @track comments = 'Approved';

    decisionOptions = [
        { label: 'Approve', value: 'approve' },
        { label: 'Reject', value: 'reject' }
    ];

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

    get isAlreadyApproved() {
        return this.approvalInfo && this.approvalInfo.pjpStatus === 'Approved';
    }

    get isApproveSelected() {
        return this.decision === 'approve';
    }

    get isConfirmDisabled() {
        return this.isLoading || this.isAlreadyApproved;
    }

    handleDecisionChange(event) {
        this.decision = event.detail.value;
        if (this.decision === 'approve') {
            this.comments = 'Approved';
        } else {
            this.comments = 'Rejected';
        }
    }

    handleCommentsChange(event) {
        this.comments = event.detail.value;
    }

    async handleConfirm() {
        this.isLoading = true;
        try {
            if (this.decision === 'approve') {
                const result = await approvePJP({ pjpId: this.recordId, comments: this.comments });
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'PJP Approved',
                        message: result.message || 'PJP and Employee successfully approved!',
                        variant: 'success'
                    })
                );
            } else {
                const result = await rejectPJP({ pjpId: this.recordId, comments: this.comments });
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'PJP Rejected',
                        message: result.message || 'PJP rejected.',
                        variant: 'warning'
                    })
                );
            }
            this.isLoading = false;
            await notifyRecordUpdateAvailable([{ recordId: this.recordId }]);
            this.dispatchEvent(new CloseActionScreenEvent());
            setTimeout(() => {
                window.location.reload();
            }, 600);
        } catch (error) {
            this.isLoading = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error Processing Approval',
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