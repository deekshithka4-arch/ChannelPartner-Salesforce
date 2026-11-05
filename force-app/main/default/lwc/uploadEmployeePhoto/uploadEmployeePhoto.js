import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import uploadProfilePicture from '@salesforce/apex/SFANDMSController.uploadProfilePicture';

export default class UploadEmployeePhoto extends LightningElement {
    @api recordId;
    @track fileName = '';
    @track base64Data = '';
    @track previewUrl = '';
    @track isUploading = false;

    get isSaveDisabled() {
        return !this.base64Data || this.isUploading;
    }

    handleFileChange(event) {
        const file = event.target.files[0];
        if (file) {
            this.fileName = file.name;
            const reader = new FileReader();
            reader.onload = () => {
                this.previewUrl = reader.result;
                const base64 = reader.result.split(',')[1];
                this.base64Data = base64;
            };
            reader.readAsDataURL(file);
        }
    }

    handleResetFile() {
        this.fileName = '';
        this.base64Data = '';
        this.previewUrl = '';
    }

    handleCancel() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    handleUpload() {
        if (!this.base64Data || !this.recordId) return;
        this.isUploading = true;
        uploadProfilePicture({ employeeId: this.recordId, fileName: this.fileName, base64Data: this.base64Data })
            .then(() => {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Success',
                    message: 'Profile picture uploaded successfully!',
                    variant: 'success'
                }));
                this.dispatchEvent(new CloseActionScreenEvent());
                setTimeout(() => {
                    window.location.reload();
                }, 800);
            })
            .catch(error => {
                this.isUploading = false;
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Error',
                    message: error.body ? error.body.message : error.message,
                    variant: 'error'
                }));
            });
    }
}