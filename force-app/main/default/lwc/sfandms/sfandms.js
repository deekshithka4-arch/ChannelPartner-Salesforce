import { LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getInitialData from '@salesforce/apex/SFANDMSController.getInitialData';
import getEmployeeDetails from '@salesforce/apex/SFANDMSController.getEmployeeDetails';
import createEmployee from '@salesforce/apex/SFANDMSController.createEmployee';
import createGeography from '@salesforce/apex/SFANDMSController.createGeography';
import createBeat from '@salesforce/apex/SFANDMSController.createBeat';
import createOutlet from '@salesforce/apex/SFANDMSController.createOutlet';
import createPJP from '@salesforce/apex/SFANDMSController.createPJP';
import submitPJPForApproval from '@salesforce/apex/SFANDMSController.submitPJPForApproval';
import approvePJP from '@salesforce/apex/SFANDMSController.approvePJP';
import rejectPJP from '@salesforce/apex/SFANDMSController.rejectPJP';
import uploadProfilePicture from '@salesforce/apex/SFANDMSController.uploadProfilePicture';
import toggleDistributorPortal from '@salesforce/apex/SFANDMSController.toggleDistributorPortal';
import approvePrimaryOrder from '@salesforce/apex/SFANDMSController.approvePrimaryOrder';
import rejectPrimaryOrder from '@salesforce/apex/SFANDMSController.rejectPrimaryOrder';
import approvePrimaryReturn from '@salesforce/apex/SFANDMSController.approvePrimaryReturn';
import rejectPrimaryReturn from '@salesforce/apex/SFANDMSController.rejectPrimaryReturn';
import updateDmsTicketStatus from '@salesforce/apex/SFANDMSController.updateDmsTicketStatus';
import createDistributor from '@salesforce/apex/SFANDMSController.createDistributor';
import createPrimaryOrder from '@salesforce/apex/SFANDMSController.createPrimaryOrder';
import approveDistributorPrimaryOrder from '@salesforce/apex/SFANDMSController.approveDistributorPrimaryOrder';
import rejectDistributorPrimaryOrder from '@salesforce/apex/SFANDMSController.rejectDistributorPrimaryOrder';
import approveDistributorReturn from '@salesforce/apex/SFANDMSController.approveDistributorReturn';
import rejectDistributorReturn from '@salesforce/apex/SFANDMSController.rejectDistributorReturn';

export default class SfaAndMs extends LightningElement {
    @track isLoading = true;
    @track activeTab = 'employees';

    @track currentUserName = 'Deekshith K A';
    @track currentUserEmail = 'deekshithka44.c14f379f8adf@agentforce.com';

    @track employees = [];
    @track geographies = [];
    @track beats = [];
    @track outlets = [];
    @track pjps = [];
    @track users = [];
    @track distributors = [];
    @track primaryOrders = [];
    @track primaryReturns = [];
    @track dmsTickets = [];
    @track secondaryOrders = [];
    @track products = [];
    @track distributorOfficers = [];
    @track primaryApprovals = [];
    @track returnApprovals = [];

    // Search keys
    @track empSearchKey = '';
    @track geoSearchKey = '';
    @track beatSearchKey = '';
    @track outletSearchKey = '';
    @track pjpSearchKey = '';
    @track distSearchKey = '';
    @track poSearchKey = '';
    @track ticketSearchKey = '';
    @track returnSearchKey = '';
    @track doSearchKey = '';
    @track primaryApprovalSearchKey = '';
    @track returnApprovalSearchKey = '';

    // Modals
    @track showNewEmployeeModal = false;
    @track showNewGeoModal = false;
    @track showNewBeatModal = false;
    @track showNewOutletModal = false;
    @track showNewPjpModal = false;
    @track showApprovalModal = false;
    @track showNewDistModal = false;
    @track showNewPoModal = false;
    @track showApprovalDetailModal = false;
    @track selectedApproval = null;

    // Validation messages
    @track aadhaarError = '';
    @track panError = '';
    @track autoFillAlert = '';

    // Profile Picture upload state
    @track profilePicBase64 = '';
    @track profilePicFileName = '';
    @track profilePicPreview = '';

    // Form Objects
    @track newEmp = {
        Name: '',
        Aadhaar_Number__c: '',
        PAN_Number__c: '',
        Phone_Number__c: '',
        Emergency_Contact__c: '',
        Geography__c: '',
        Hierarchy__c: '',
        Reporting_Manager__c: '',
        Lead_Owner__c: '',
        Distributor__c: '',
        PJP__c: '',
        Profile_Picture__c: '',
        Status__c: 'Pending'
    };

    @track newGeo = {
        Name: '',
        Nation__c: 'India',
        State__c: '',
        District__c: '',
        Town__c: '',
        Municipal__c: '',
        Village__c: ''
    };

    @track newBeat = {
        Name: '',
        Beat_Assigned_To__c: '',
        Distributor__c: '',
        Geography__c: ''
    };

    @track newOutlet = {
        Name: '',
        Outlet_Owner_Name__c: '',
        Contact_No__c: '',
        Email__c: '',
        Aadhaar__c: '',
        PAN__c: '',
        lat: null,
        lng: null,
        Geography__c: '',
        Beat__c: ''
    };

    @track newPjp = {
        Name: '',
        Employee__c: '',
        Lead_Owner__c: '',
        Status__c: 'Draft'
    };

    @track newDist = {
        Name: '',
        Distributor_Code__c: '',
        Distributor_Owner_Name__c: '',
        Mobile_Number__c: '',
        Contact_Person__c: '',
        Phone__c: '',
        Email__c: '',
        GSTIN__c: '',
        Address__c: '',
        City__c: 'Bengaluru',
        State__c: 'Karnataka',
        Pincode__c: '560001',
        Max_Outlets__c: 100,
        Distributor_Officer__c: '',
        DMS_Portal_Enabled__c: true,
        Status__c: 'Active'
    };

    @track newPo = {
        Distributor_Name__c: '',
        Employee_Name__c: '',
        Total_Cases__c: 15,
        Gross_Amount__c: 45000,
        Tax_Amount__c: 8100,
        Total_Amount__c: 53100,
        Primary_Scheme_Applied__c: 'Buy 10 Cases Get 1 Case Free (10% Primary Discount)',
        Items_Summary__c: '',
        Status__c: 'Pending DO Approval',
        DO_Approval_Status__c: 'Pending DO Approval'
    };

    // Approval action state
    @track targetPjpId = '';
    @track approvalActionType = 'approve'; // 'approve' or 'reject'
    @track approvalComments = '';

    connectedCallback() {
        this.loadData();
    }

    loadData() {
        this.isLoading = true;
        getInitialData()
            .then(data => {
                this.currentUserName = data.currentUserName;
                this.currentUserEmail = data.currentUserEmail;
                this.employees = data.employees || [];
                this.geographies = data.geographies || [];
                this.beats = data.beats || [];
                this.outlets = data.outlets || [];
                this.pjps = data.pjps || [];
                this.users = data.users || [];
                this.distributors = data.distributors || [];
                this.primaryOrders = data.primaryOrders || [];
                this.primaryReturns = data.primaryReturns || [];
                this.dmsTickets = data.dmsTickets || [];
                this.secondaryOrders = data.secondaryOrders || [];
                this.products = data.products || [];
                this.distributorOfficers = data.distributorOfficers || [];
                this.primaryApprovals = data.primaryApprovals || [];
                this.returnApprovals = data.returnApprovals || [];
                this.isLoading = false;
            })
            .catch(error => {
                this.isLoading = false;
                this.showToast('Error', 'Failed to load SFA & DMS data: ' + (error.body ? error.body.message : error.message), 'error');
            });
    }

    refreshData() {
        this.loadData();
        this.showToast('Refreshed', 'All data refreshed from Salesforce', 'info');
    }

    // Counts
    get employeeCount() { return this.employees.length; }
    get pendingEmpCount() { return this.employees.filter(e => e.Status__c === 'Pending').length; }
    get geographyCount() { return this.geographies.length; }
    get beatCount() { return this.beats.length; }
    get outletCount() { return this.outlets.length; }
    get pjpCount() { return this.pjps.length; }
    get pendingPjpCount() { return this.pjps.filter(p => p.Status__c === 'Submitted').length; }
    get distributorCount() { return this.distributors.length; }
    get primaryOrderCount() { return this.primaryOrders.length; }
    get pendingPoCount() { return this.primaryOrders.filter(o => o.DO_Approval_Status__c === 'Pending DO Approval' || o.Status__c === 'Pending DO Approval').length; }
    get openTicketCount() { return this.dmsTickets.filter(t => t.Status__c === 'Open').length; }
    get returnCount() { return this.primaryReturns.length; }
    get distributorOfficerCount() { return this.distributorOfficers.length; }
    get primaryApprovalCount() { return this.primaryApprovals.length; }
    get returnApprovalCount() { return this.returnApprovals.length; }
    get pendingPrimaryApprovalCount() {
        return this.primaryApprovals.filter(a => a.Approval_Status__c === 'Pending' || a.Approval_Status__c === 'Pending DO Approval').length;
    }
    get pendingReturnApprovalCount() {
        return this.returnApprovals.filter(r => r.Approval_Status__c === 'Pending' || r.Approval_Status__c === 'Pending DO Approval').length;
    }

    // Options for comboboxes
    get geoOptions() {
        return this.geographies.map(g => ({ label: g.Name, value: g.Id }));
    }

    get empOptions() {
        return this.employees.map(e => ({ label: e.Name + (e.Distributor__c ? ` (${e.Distributor__c})` : ''), value: e.Id }));
    }

    get beatOptions() {
        return this.beats.map(b => ({ label: b.Name, value: b.Id }));
    }

    get userOptions() {
        return this.users.map(u => ({ label: u.name + ' (' + u.username + ')', value: u.id }));
    }

    get pjpOptions() {
        return this.pjps.map(p => ({ label: p.Name + (p.empName ? ` - ${p.empName}` : ''), value: p.Id }));
    }

    get distOptions() {
        return this.distributors.map(d => ({ label: `${d.Name} (${d.Distributor_Code__c || 'DMS'})`, value: d.Name }));
    }

    get productOptions() {
        return this.products.map(p => ({ label: `${p.Name} (₹${p.Case_Price__c || 0}/case)`, value: p.Name }));
    }

    get pipOptions() {
        return [
            { label: 'No', value: 'No' },
            { label: 'Yes', value: 'Yes' },
            { label: 'Under PIP', value: 'Under PIP' }
        ];
    }

    get statusOptions() {
        return [
            { label: 'Pending', value: 'Pending' },
            { label: 'Approved', value: 'Approved' },
            { label: 'Rejected', value: 'Rejected' }
        ];
    }

    get hierarchyOptions() {
        return [
            { label: 'Sales Officer', value: 'Sales Officer' },
            { label: 'Area Sales Manager', value: 'Area Sales Manager' },
            { label: 'Manager', value: 'Manager' },
            { label: 'Sales Manager', value: 'Sales Manager' },
            { label: 'Executive Sales Manager', value: 'Executive Sales Manager' },
            { label: 'Sales Representative', value: 'Sales Representative' },
            { label: 'Territory Sales Manager', value: 'Territory Sales Manager' },
            { label: 'Regional Sales Manager', value: 'Regional Sales Manager' },
            { label: 'Zonal Sales Manager', value: 'Zonal Sales Manager' },
            { label: 'National Sales Manager', value: 'National Sales Manager' }
        ];
    }

    get nationOptions() {
        return [
            { label: 'India', value: 'India' },
            { label: 'United States', value: 'United States' },
            { label: 'United Kingdom', value: 'United Kingdom' },
            { label: 'United Arab Emirates', value: 'United Arab Emirates' },
            { label: 'Australia', value: 'Australia' },
            { label: 'Canada', value: 'Canada' },
            { label: 'Singapore', value: 'Singapore' },
            { label: 'Germany', value: 'Germany' },
            { label: 'France', value: 'France' },
            { label: 'Japan', value: 'Japan' },
            { label: 'China', value: 'China' },
            { label: 'Brazil', value: 'Brazil' },
            { label: 'South Africa', value: 'South Africa' },
            { label: 'Saudi Arabia', value: 'Saudi Arabia' },
            { label: 'New Zealand', value: 'New Zealand' },
            { label: 'Bangladesh', value: 'Bangladesh' },
            { label: 'Sri Lanka', value: 'Sri Lanka' },
            { label: 'Nepal', value: 'Nepal' },
            { label: 'Bhutan', value: 'Bhutan' },
            { label: 'Maldives', value: 'Maldives' },
            { label: 'Malaysia', value: 'Malaysia' },
            { label: 'Indonesia', value: 'Indonesia' },
            { label: 'Thailand', value: 'Thailand' },
            { label: 'Vietnam', value: 'Vietnam' },
            { label: 'Philippines', value: 'Philippines' },
            { label: 'Italy', value: 'Italy' },
            { label: 'Spain', value: 'Spain' },
            { label: 'Netherlands', value: 'Netherlands' },
            { label: 'Switzerland', value: 'Switzerland' },
            { label: 'Sweden', value: 'Sweden' },
            { label: 'Norway', value: 'Norway' },
            { label: 'Denmark', value: 'Denmark' },
            { label: 'Ireland', value: 'Ireland' },
            { label: 'Mexico', value: 'Mexico' },
            { label: 'Argentina', value: 'Argentina' },
            { label: 'Egypt', value: 'Egypt' },
            { label: 'Nigeria', value: 'Nigeria' },
            { label: 'Kenya', value: 'Kenya' },
            { label: 'South Korea', value: 'South Korea' },
            { label: 'Russia', value: 'Russia' },
            { label: 'Turkey', value: 'Turkey' },
            { label: 'Qatar', value: 'Qatar' },
            { label: 'Oman', value: 'Oman' },
            { label: 'Kuwait', value: 'Kuwait' },
            { label: 'Bahrain', value: 'Bahrain' },
            { label: 'Other', value: 'Other' }
        ];
    }

    get stateOptions() {
        return [
            { label: 'Andaman and Nicobar Islands', value: 'Andaman and Nicobar Islands' },
            { label: 'Andhra Pradesh', value: 'Andhra Pradesh' },
            { label: 'Arunachal Pradesh', value: 'Arunachal Pradesh' },
            { label: 'Assam', value: 'Assam' },
            { label: 'Bihar', value: 'Bihar' },
            { label: 'Chandigarh', value: 'Chandigarh' },
            { label: 'Chhattisgarh', value: 'Chhattisgarh' },
            { label: 'Dadra and Nagar Haveli and Daman and Diu', value: 'Dadra and Nagar Haveli and Daman and Diu' },
            { label: 'Delhi', value: 'Delhi' },
            { label: 'Goa', value: 'Goa' },
            { label: 'Gujarat', value: 'Gujarat' },
            { label: 'Haryana', value: 'Haryana' },
            { label: 'Himachal Pradesh', value: 'Himachal Pradesh' },
            { label: 'Jammu and Kashmir', value: 'Jammu and Kashmir' },
            { label: 'Jharkhand', value: 'Jharkhand' },
            { label: 'Karnataka', value: 'Karnataka' },
            { label: 'Kerala', value: 'Kerala' },
            { label: 'Ladakh', value: 'Ladakh' },
            { label: 'Lakshadweep', value: 'Lakshadweep' },
            { label: 'Madhya Pradesh', value: 'Madhya Pradesh' },
            { label: 'Maharashtra', value: 'Maharashtra' },
            { label: 'Manipur', value: 'Manipur' },
            { label: 'Meghalaya', value: 'Meghalaya' },
            { label: 'Mizoram', value: 'Mizoram' },
            { label: 'Nagaland', value: 'Nagaland' },
            { label: 'Odisha', value: 'Odisha' },
            { label: 'Puducherry', value: 'Puducherry' },
            { label: 'Punjab', value: 'Punjab' },
            { label: 'Rajasthan', value: 'Rajasthan' },
            { label: 'Sikkim', value: 'Sikkim' },
            { label: 'Tamil Nadu', value: 'Tamil Nadu' },
            { label: 'Telangana', value: 'Telangana' },
            { label: 'Tripura', value: 'Tripura' },
            { label: 'Uttar Pradesh', value: 'Uttar Pradesh' },
            { label: 'Uttarakhand', value: 'Uttarakhand' },
            { label: 'West Bengal', value: 'West Bengal' }
        ];
    }

    // Tab Selection
    handleTabSelect(event) {
        this.activeTab = event.target.value;
    }

    handleQuickAdd() {
        if (this.activeTab === 'employees') this.openNewEmployeeModal();
        else if (this.activeTab === 'geography') this.openNewGeoModal();
        else if (this.activeTab === 'beats') this.openNewBeatModal();
        else if (this.activeTab === 'outlets') this.openNewOutletModal();
        else if (this.activeTab === 'pjp') this.openNewPjpModal();
        else if (this.activeTab === 'distributors') this.openNewDistModal();
        else if (this.activeTab === 'primaryOrders') this.openNewPoModal();
    }

    // Search Handlers
    handleEmpSearch(event) { this.empSearchKey = event.target.value.toLowerCase(); }
    handleGeoSearch(event) { this.geoSearchKey = event.target.value.toLowerCase(); }
    handleBeatSearch(event) { this.beatSearchKey = event.target.value.toLowerCase(); }
    handleOutletSearch(event) { this.outletSearchKey = event.target.value.toLowerCase(); }
    handlePjpSearch(event) { this.pjpSearchKey = event.target.value.toLowerCase(); }
    handleDistSearch(event) { this.distSearchKey = event.target.value.toLowerCase(); }
    handlePoSearch(event) { this.poSearchKey = event.target.value.toLowerCase(); }
    handleTicketSearch(event) { this.ticketSearchKey = event.target.value.toLowerCase(); }
    handleReturnSearch(event) { this.returnSearchKey = event.target.value.toLowerCase(); }

    // Form Field Handlers
    handleEmpFieldChange(event) {
        const field = event.target.dataset.field;
        const val = event.target.value;
        this.newEmp = { ...this.newEmp, [field]: val };

        // Real-time Aadhaar validation
        if (field === 'Aadhaar_Number__c') {
            if (val && (val.length !== 12 || !/^[0-9]{12}$/.test(val))) {
                this.aadhaarError = 'Aadhaar must contain exactly 12 numeric digits (current length: ' + val.length + ')';
            } else {
                this.aadhaarError = '';
            }
        }

        // Real-time PAN validation
        if (field === 'PAN_Number__c') {
            if (val && (val.length !== 10 || !/^[a-zA-Z0-9]{10}$/.test(val))) {
                this.panError = 'PAN must contain exactly 10 alphanumeric characters (current length: ' + val.length + ')';
            } else {
                this.panError = '';
            }
        }
    }

    handleGeoFieldChange(event) {
        const field = event.target.dataset.field;
        this.newGeo = { ...this.newGeo, [field]: event.target.value };
    }

    handleBeatFieldChange(event) {
        const field = event.target.dataset.field;
        this.newBeat = { ...this.newBeat, [field]: event.target.value };
    }

    // CRUCIAL: AUTO-ADD DISTRIBUTOR & GEOGRAPHY ON BEAT ASSIGNED TO EMPLOYEE
    handleBeatAssignedToChange(event) {
        const selectedEmpId = event.target.value;
        this.newBeat = { ...this.newBeat, Beat_Assigned_To__c: selectedEmpId };

        if (!selectedEmpId) {
            this.autoFillAlert = '';
            return;
        }

        const selectedEmp = this.employees.find(e => e.Id === selectedEmpId);
        if (selectedEmp) {
            this.newBeat.Distributor__c = selectedEmp.Distributor__c || '';
            this.newBeat.Geography__c = selectedEmp.Geography__c || '';
            this.autoFillAlert = `✨ Auto-populated Distributor (${selectedEmp.Distributor__c || 'N/A'}) and Geography from Employee "${selectedEmp.Name}"!`;
            this.showToast('Auto-populated', `Distributor and Geography auto-filled from ${selectedEmp.Name}`, 'success');
        } else {
            getEmployeeDetails({ employeeId: selectedEmpId })
                .then(emp => {
                    if (emp) {
                        this.newBeat.Distributor__c = emp.Distributor__c || '';
                        this.newBeat.Geography__c = emp.Geography__c || '';
                        this.autoFillAlert = `✨ Auto-populated Distributor and Geography from Employee "${emp.Name}"!`;
                    }
                })
                .catch(() => {});
        }
    }

    handleOutletFieldChange(event) {
        const field = event.target.dataset.field;
        this.newOutlet = { ...this.newOutlet, [field]: event.target.value };
    }

    handleOutletBeatChange(event) {
        const beatId = event.target.value;
        let geoId = this.newOutlet.Geography__c;
        if (beatId) {
            const beatObj = this.beats.find(b => b.Id === beatId);
            if (beatObj && beatObj.Geography__c) {
                geoId = beatObj.Geography__c;
            }
        }
        this.newOutlet = {
            ...this.newOutlet,
            Beat__c: beatId,
            Geography__c: geoId
        };
    }

    handlePjpFieldChange(event) {
        const field = event.target.dataset.field;
        this.newPjp = { ...this.newPjp, [field]: event.target.value };
    }

    handleDistFieldChange(event) {
        const field = event.target.dataset.field;
        const val = event.target.type === 'checkbox' ? event.target.checked : event.target.value;
        this.newDist = { ...this.newDist, [field]: val };
    }

    handlePoFieldChange(event) {
        const field = event.target.dataset.field;
        let val = event.target.value;
        if (field === 'Total_Cases__c' || field === 'Gross_Amount__c' || field === 'Tax_Amount__c' || field === 'Total_Amount__c') {
            val = Number(val);
        }
        this.newPo = { ...this.newPo, [field]: val };
    }

    // Modal toggles
    openNewEmployeeModal() {
        this.aadhaarError = '';
        this.panError = '';
        this.profilePicBase64 = '';
        this.profilePicFileName = '';
        this.profilePicPreview = '';
        this.newEmp = {
            Name: '',
            Aadhaar_Number__c: '',
            PAN_Number__c: '',
            Phone_Number__c: '',
            Emergency_Contact__c: '',
            Geography__c: this.geographies.length > 0 ? this.geographies[0].Id : '',
            Hierarchy__c: '',
            Reporting_Manager__c: '',
            Lead_Owner__c: '',
            Distributor__c: '',
            PJP__c: '',
            Profile_Picture__c: '',
            Status__c: 'Pending'
        };
        this.showNewEmployeeModal = true;
    }

    handleProfilePicUpload(event) {
        const file = event.target.files[0];
        if (file) {
            this.profilePicFileName = file.name;
            const reader = new FileReader();
            reader.onload = () => {
                this.profilePicPreview = reader.result;
                const base64 = reader.result.split(',')[1];
                this.profilePicBase64 = base64;
            };
            reader.readAsDataURL(file);
        }
    }

    openNewGeoModal() {
        this.newGeo = {
            Name: '',
            Nation__c: 'India',
            State__c: '',
            District__c: '',
            Town__c: '',
            Municipal__c: '',
            Village__c: ''
        };
        this.showNewGeoModal = true;
    }

    openNewBeatModal() {
        this.autoFillAlert = '';
        this.newBeat = {
            Name: '',
            Beat_Assigned_To__c: '',
            Distributor__c: '',
            Geography__c: ''
        };
        this.showNewBeatModal = true;
    }

    openNewOutletModal() {
        const defaultBeatId = this.beats.length > 0 ? this.beats[0].Id : '';
        const defaultBeat = this.beats.find(b => b.Id === defaultBeatId);
        this.newOutlet = {
            Name: '',
            Outlet_Owner_Name__c: '',
            Contact_No__c: '',
            Email__c: '',
            Aadhaar__c: '',
            PAN__c: '',
            lat: 12.9716,
            lng: 77.5946,
            Geography__c: defaultBeat && defaultBeat.Geography__c ? defaultBeat.Geography__c : '',
            Beat__c: defaultBeatId
        };
        this.showNewOutletModal = true;
    }

    openNewPjpModal() {
        const defaultEmpId = this.employees.length > 0 ? this.employees[0].Id : '';
        const defaultEmp = this.employees.find(e => e.Id === defaultEmpId);
        this.newPjp = {
            Name: defaultEmp ? `PJP - ${defaultEmp.Name} - Oct 2026` : 'PJP - ' + (this.pjps.length + 1),
            Employee__c: defaultEmpId,
            Lead_Owner__c: this.users.length > 0 ? this.users[0].id : '',
            Status__c: 'Draft'
        };
        this.showNewPjpModal = true;
    }

    openNewDistModal() {
        this.newDist = {
            Name: '',
            Distributor_Code__c: 'DST-' + Math.floor(1000 + Math.random() * 9000),
            Distributor_Owner_Name__c: '',
            Mobile_Number__c: '',
            Contact_Person__c: '',
            Phone__c: '',
            Email__c: '',
            GSTIN__c: '',
            Address__c: '',
            City__c: 'Bengaluru',
            State__c: 'Karnataka',
            Pincode__c: '560001',
            Max_Outlets__c: 100,
            Distributor_Officer__c: this.currentUserName || 'Deekshith K A',
            DMS_Portal_Enabled__c: true,
            Status__c: 'Active'
        };
        this.showNewDistModal = true;
    }

    openNewPoModal() {
        const defaultDist = this.distributors.length > 0 ? this.distributors[0].Name : 'Bangalore Central Agency';
        const defaultEmp = this.employees.length > 0 ? this.employees[0].Name : 'Viresh';
        this.newPo = {
            Distributor_Name__c: defaultDist,
            Employee_Name__c: defaultEmp,
            Total_Cases__c: 15,
            Gross_Amount__c: 45000,
            Tax_Amount__c: 8100,
            Total_Amount__c: 53100,
            Primary_Scheme_Applied__c: 'Buy 10 Cases Get 1 Case Free (10% Primary Discount)',
            Items_Summary__c: 'Parle-G 250g (10 Cases), Britannia Good Day 200g (5 Cases)',
            Status__c: 'Pending DO Approval',
            DO_Approval_Status__c: 'Pending DO Approval'
        };
        this.showNewPoModal = true;
    }

    closeModals() {
        this.showNewEmployeeModal = false;
        this.showNewGeoModal = false;
        this.showNewBeatModal = false;
        this.showNewOutletModal = false;
        this.showNewPjpModal = false;
        this.showApprovalModal = false;
        this.showNewDistModal = false;
        this.showNewPoModal = false;
    }

    // Save Handlers
    saveEmployee() {
        if (!this.newEmp.Name) {
            this.showToast('Error', 'Employee Name is required.', 'error');
            return;
        }

        if (this.newEmp.Aadhaar_Number__c && (this.newEmp.Aadhaar_Number__c.length !== 12 || !/^[0-9]{12}$/.test(this.newEmp.Aadhaar_Number__c))) {
            this.showToast('Validation Error', 'Aadhaar Number must be exactly 12 numeric digits.', 'error');
            return;
        }

        if (this.newEmp.PAN_Number__c && (this.newEmp.PAN_Number__c.length !== 10 || !/^[a-zA-Z0-9]{10}$/.test(this.newEmp.PAN_Number__c))) {
            this.showToast('Validation Error', 'PAN Number must be exactly 10 alphanumeric characters.', 'error');
            return;
        }

        this.isLoading = true;
        createEmployee({ employee: this.newEmp })
            .then(created => {
                if (this.profilePicBase64) {
                    return uploadProfilePicture({
                        employeeId: created.Id,
                        fileName: this.profilePicFileName,
                        base64Data: this.profilePicBase64
                    }).then(() => {
                        this.showToast('Success', `Employee ${created.Name} created with Profile Picture!`, 'success');
                        this.closeModals();
                        this.loadData();
                    });
                } else {
                    this.showToast('Success', `Employee ${created.Name} created successfully!`, 'success');
                    this.closeModals();
                    this.loadData();
                }
            })
            .catch(error => {
                this.isLoading = false;
                this.showToast('Error Creating Employee', error.body ? error.body.message : error.message, 'error');
            });
    }

    saveGeography() {
        if (!this.newGeo.Name) {
            this.showToast('Error', 'Geography Name is required.', 'error');
            return;
        }
        this.isLoading = true;
        createGeography({ geo: this.newGeo })
            .then(created => {
                this.showToast('Success', `Geography ${created.Name} created successfully!`, 'success');
                this.closeModals();
                this.loadData();
            })
            .catch(error => {
                this.isLoading = false;
                this.showToast('Error Creating Geography', error.body ? error.body.message : error.message, 'error');
            });
    }

    saveBeat() {
        if (!this.newBeat.Name) {
            this.showToast('Error', 'Beat Name is required.', 'error');
            return;
        }
        this.isLoading = true;
        const beatPayload = {
            Name: this.newBeat.Name,
            Beat_Assigned_To__c: this.newBeat.Beat_Assigned_To__c || null,
            Distributor__c: this.newBeat.Distributor__c || null,
            Geography__c: this.newBeat.Geography__c || null
        };
        createBeat({ beat: beatPayload })
            .then(created => {
                this.showToast('Success', `Beat ${created.Name} (${created.Beat_ID__c || 'Created'}) created successfully!`, 'success');
                this.closeModals();
                this.loadData();
            })
            .catch(error => {
                this.isLoading = false;
                this.showToast('Error Creating Beat', error.body ? error.body.message : error.message, 'error');
            });
    }

    saveOutlet() {
        if (!this.newOutlet.Name) {
            this.showToast('Error', 'Outlet Name is required.', 'error');
            return;
        }
        this.isLoading = true;
        const lat = this.newOutlet.lat ? parseFloat(this.newOutlet.lat) : null;
        const lng = this.newOutlet.lng ? parseFloat(this.newOutlet.lng) : null;
        if (!this.newOutlet.Geography__c && this.newOutlet.Beat__c) {
            const beatObj = this.beats.find(b => b.Id === this.newOutlet.Beat__c);
            if (beatObj && beatObj.Geography__c) {
                this.newOutlet.Geography__c = beatObj.Geography__c;
            }
        }
        createOutlet({ outlet: this.newOutlet, latitude: lat, longitude: lng })
            .then(created => {
                this.showToast('Success', `Outlet ${created.Name} created successfully!`, 'success');
                this.closeModals();
                this.loadData();
            })
            .catch(error => {
                this.isLoading = false;
                this.showToast('Error Creating Outlet', error.body ? error.body.message : error.message, 'error');
            });
    }

    savePjp() {
        if (!this.newPjp.Name || !this.newPjp.Employee__c || !this.newPjp.Lead_Owner__c) {
            this.showToast('Error', 'PJP Name, Employee, and Lead Owner are required.', 'error');
            return;
        }
        this.isLoading = true;
        createPJP({ pjp: this.newPjp })
            .then(created => {
                this.showToast('Success', `PJP ${created.Name} created successfully!`, 'success');
                this.closeModals();
                this.loadData();
            })
            .catch(error => {
                this.isLoading = false;
                this.showToast('Error Creating PJP', error.body ? error.body.message : error.message, 'error');
            });
    }

    saveDistributor() {
        if (!this.newDist.Name) {
            this.showToast('Error', 'Distributor Name is required.', 'error');
            return;
        }
        this.isLoading = true;
        createDistributor({ distributor: this.newDist })
            .then(res => {
                this.showToast('Success', `Distributor "${res.Name}" created successfully!`, 'success');
                this.closeModals();
                this.loadData();
            })
            .catch(error => {
                this.isLoading = false;
                this.showToast('Error Creating Distributor', error.body ? error.body.message : error.message, 'error');
            });
    }

    savePrimaryOrder() {
        if (!this.newPo.Distributor_Name__c || !this.newPo.Total_Cases__c) {
            this.showToast('Error', 'Distributor and Total Cases are required.', 'error');
            return;
        }
        this.isLoading = true;
        createPrimaryOrder({ order: this.newPo })
            .then(res => {
                this.showToast('Success', `Primary Order "${res.Name}" created with DO Approval Pending!`, 'success');
                this.closeModals();
                this.loadData();
            })
            .catch(error => {
                this.isLoading = false;
                this.showToast('Error Creating Primary Order', error.body ? error.body.message : error.message, 'error');
            });
    }

    handleToggleDistributor(event) {
        const distId = event.target.dataset.id;
        const currentEnabled = event.target.dataset.enabled === 'true' || event.target.dataset.enabled === true;
        this.isLoading = true;
        toggleDistributorPortal({ distributorId: distId, enablePortal: !currentEnabled })
            .then(res => {
                this.showToast('Success', `Distributor ${res.Name} DMS Portal ${res.DMS_Portal_Enabled__c ? 'Enabled' : 'Disabled'}`, 'success');
                this.loadData();
            })
            .catch(error => {
                this.isLoading = false;
                this.showToast('Error Updating Distributor', error.body ? error.body.message : error.message, 'error');
            });
    }

    handleApprovePo(event) {
        const orderId = event.target.dataset.id;
        this.isLoading = true;
        approvePrimaryOrder({ orderId, remarks: 'DO Approved for dispatch & invoicing' })
            .then(res => {
                this.showToast('DO Approved', `Primary Order ${res.Name} Approved! Stock dispatched to distributor.`, 'success');
                this.loadData();
            })
            .catch(error => {
                this.isLoading = false;
                this.showToast('Error Approving Primary Order', error.body ? error.body.message : error.message, 'error');
            });
    }

    handleRejectPo(event) {
        const orderId = event.target.dataset.id;
        this.isLoading = true;
        rejectPrimaryOrder({ orderId, remarks: 'DO Rejected: Credit limit exceeded / invalid items' })
            .then(res => {
                this.showToast('DO Rejected', `Primary Order ${res.Name} Rejected.`, 'warning');
                this.loadData();
            })
            .catch(error => {
                this.isLoading = false;
                this.showToast('Error Rejecting Primary Order', error.body ? error.body.message : error.message, 'error');
            });
    }

    handleApproveReturn(event) {
        const returnId = event.target.dataset.id;
        this.isLoading = true;
        approvePrimaryReturn({ returnId, remarks: 'DO Approved replacement/credit memo' })
            .then(res => {
                this.showToast('DO Approved', `Primary Return ${res.Name} Approved! Credit memo issued.`, 'success');
                this.loadData();
            })
            .catch(error => {
                this.isLoading = false;
                this.showToast('Error Approving Return', error.body ? error.body.message : error.message, 'error');
            });
    }

    handleRejectReturn(event) {
        const returnId = event.target.dataset.id;
        this.isLoading = true;
        rejectPrimaryReturn({ returnId, remarks: 'DO Rejected: Expiry warranty void' })
            .then(res => {
                this.showToast('DO Rejected', `Primary Return ${res.Name} Rejected.`, 'warning');
                this.loadData();
            })
            .catch(error => {
                this.isLoading = false;
                this.showToast('Error Rejecting Return', error.body ? error.body.message : error.message, 'error');
            });
    }

    handleTicketStatusChange(event) {
        const ticketId = event.target.dataset.id;
        const newStatus = event.target.dataset.status;
        this.isLoading = true;
        updateDmsTicketStatus({ ticketId, status: newStatus, resolutionNotes: `Status changed to ${newStatus} from SFA & DMS Enterprise Portal` })
            .then(res => {
                this.showToast('Ticket Updated', `Ticket ${res.Name} is now ${res.Status__c}`, 'success');
                this.loadData();
            })
            .catch(error => {
                this.isLoading = false;
                this.showToast('Error Updating Ticket', error.body ? error.body.message : error.message, 'error');
            });
    }

    // PJP APPROVAL WORKFLOW
    handleSubmitPjpAction(event) {
        const pjpId = event.target.dataset.id;
        this.isLoading = true;
        submitPJPForApproval({ pjpId })
            .then(res => {
                this.showToast('Submitted for Approval', res.message, 'success');
                this.loadData();
            })
            .catch(error => {
                this.isLoading = false;
                this.showToast('Error Submitting PJP', error.body ? error.body.message : error.message, 'error');
            });
    }

    handleOpenApproveModal(event) {
        this.targetPjpId = event.target.dataset.id;
        this.approvalActionType = 'approve';
        this.approvalComments = 'Approved as requested.';
        this.showApprovalModal = true;
    }

    handleOpenRejectModal(event) {
        this.targetPjpId = event.target.dataset.id;
        this.approvalActionType = 'reject';
        this.approvalComments = 'Rejected. Please review journey dates and beats.';
        this.showApprovalModal = true;
    }

    handleApprovalCommentsChange(event) {
        this.approvalComments = event.target.value;
    }

    get approvalModalTitle() {
        return this.approvalActionType === 'approve' ? 'Approve PJP' : 'Reject PJP';
    }

    get approvalModalPrompt() {
        return this.approvalActionType === 'approve'
            ? 'Approving this PJP will update the associated Employee status from Pending to APPROVED.'
            : 'Rejecting this PJP will update the status to Rejected.';
    }

    get approvalModalVariant() {
        return this.approvalActionType === 'approve' ? 'success' : 'destructive';
    }

    get approvalModalActionLabel() {
        return this.approvalActionType === 'approve' ? 'Approve & Update Employee' : 'Confirm Reject';
    }

    confirmApprovalAction() {
        this.isLoading = true;
        if (this.approvalActionType === 'approve') {
            approvePJP({ pjpId: this.targetPjpId, comments: this.approvalComments })
                .then(res => {
                    this.showToast('PJP Approved!', res.message, 'success');
                    this.closeModals();
                    this.loadData();
                })
                .catch(error => {
                    this.isLoading = false;
                    this.showToast('Error Approving PJP', error.body ? error.body.message : error.message, 'error');
                });
        } else {
            rejectPJP({ pjpId: this.targetPjpId, comments: this.approvalComments })
                .then(res => {
                    this.showToast('PJP Rejected', res.message, 'warning');
                    this.closeModals();
                    this.loadData();
                })
                .catch(error => {
                    this.isLoading = false;
                    this.showToast('Error Rejecting PJP', error.body ? error.body.message : error.message, 'error');
                });
        }
    }

    // Processed Lists
    get filteredEmployees() {
        return this.employees
            .filter(e => {
                if (!this.empSearchKey) return true;
                return (
                    (e.Name && e.Name.toLowerCase().includes(this.empSearchKey)) ||
                    (e.Aadhaar_Number__c && e.Aadhaar_Number__c.includes(this.empSearchKey)) ||
                    (e.PAN_Number__c && e.PAN_Number__c.toLowerCase().includes(this.empSearchKey)) ||
                    (e.Distributor__c && e.Distributor__c.toLowerCase().includes(this.empSearchKey)) ||
                    (e.Lead_Owner__r && e.Lead_Owner__r.Name.toLowerCase().includes(this.empSearchKey))
                );
            })
            .map(e => ({
                ...e,
                Hierarchy__c: e.Hierarchy__c || '-',
                Employee_Level__c: e.Employee_Level__c || (e.Hierarchy__c === 'National Sales Manager' ? 'L6 - National Sales Manager' : (e.Hierarchy__c === 'Manager' ? 'L5 - Zonal Sales Manager' : 'L2 - Sales Officer')),
                Access_Channel__c: e.Access_Channel__c || (e.Hierarchy__c === 'National Sales Manager' || e.Hierarchy__c === 'Manager' ? 'Web' : 'Only Mobile'),
                channelBadgeClass: (e.Access_Channel__c === 'Web' || e.Hierarchy__c === 'National Sales Manager' || e.Hierarchy__c === 'Manager') ? 'slds-badge slds-theme_info' : 'slds-badge slds-theme_success',
                geoName: e.Geography__r ? e.Geography__r.Name : '-',
                mgrName: e.Reporting_Manager__r ? e.Reporting_Manager__r.Name : '-',
                leadOwnerName: e.Lead_Owner__r ? e.Lead_Owner__r.Name : '-',
                pjpName: e.PJP__r ? e.PJP__r.Name : '-',
                statusBadgeClass:
                    e.Status__c === 'Approved'
                        ? 'slds-badge slds-theme_success'
                        : e.Status__c === 'Rejected'
                        ? 'slds-badge slds-theme_error'
                        : 'slds-badge slds-theme_warning'
            }));
    }

    get hasEmployees() { return this.filteredEmployees.length > 0; }

    get filteredGeographies() {
        return this.geographies.filter(g => {
            if (!this.geoSearchKey) return true;
            return (
                (g.Name && g.Name.toLowerCase().includes(this.geoSearchKey)) ||
                (g.State__c && g.State__c.toLowerCase().includes(this.geoSearchKey)) ||
                (g.District__c && g.District__c.toLowerCase().includes(this.geoSearchKey))
            );
        });
    }

    get hasGeographies() { return this.filteredGeographies.length > 0; }

    get filteredBeats() {
        return this.beats
            .filter(b => {
                if (!this.beatSearchKey) return true;
                return (
                    (b.Name && b.Name.toLowerCase().includes(this.beatSearchKey)) ||
                    (b.Beat_ID__c && b.Beat_ID__c.toLowerCase().includes(this.beatSearchKey))
                );
            })
            .map(b => ({
                ...b,
                empName: b.Beat_Assigned_To__r ? b.Beat_Assigned_To__r.Name : 'Unassigned',
                geoName: b.Geography__r ? b.Geography__r.Name : '-'
            }));
    }

    get hasBeats() { return this.filteredBeats.length > 0; }

    get filteredOutlets() {
        return this.outlets
            .filter(o => {
                if (!this.outletSearchKey) return true;
                return (
                    (o.Name && o.Name.toLowerCase().includes(this.outletSearchKey)) ||
                    (o.Outlet_Owner_Name__c && o.Outlet_Owner_Name__c.toLowerCase().includes(this.outletSearchKey))
                );
            })
            .map(o => ({
                ...o,
                geoName: o.Geography__r ? o.Geography__r.Name : '-',
                beatName: o.Beat__r ? o.Beat__r.Name : '-',
                locationDisplay:
                    o.Geo_Location__Latitude__s && o.Geo_Location__Longitude__s
                        ? `${o.Geo_Location__Latitude__s}, ${o.Geo_Location__Longitude__s}`
                        : 'Not Set'
            }));
    }

    get hasOutlets() { return this.filteredOutlets.length > 0; }

    get filteredPjps() {
        return this.pjps
            .filter(p => {
                if (!this.pjpSearchKey) return true;
                return (
                    (p.Name && p.Name.toLowerCase().includes(this.pjpSearchKey)) ||
                    (p.Employee__r && p.Employee__r.Name.toLowerCase().includes(this.pjpSearchKey))
                );
            })
            .map(p => {
                const isDraft = !p.Status__c || p.Status__c === 'Draft';
                const isSubmitted = p.Status__c === 'Submitted';
                const isApproved = p.Status__c === 'Approved';
                const isRejected = p.Status__c === 'Rejected';
                const empStatus = p.Employee__r ? p.Employee__r.Status__c : '-';
                return {
                    ...p,
                    empName: p.Employee__r ? p.Employee__r.Name : '-',
                    ownerName: p.Lead_Owner__r ? p.Lead_Owner__r.Name : '-',
                    empStatus,
                    isDraft,
                    isSubmitted,
                    isApproved,
                    isRejected,
                    statusBadgeClass: isApproved
                        ? 'slds-badge slds-theme_success'
                        : isSubmitted
                        ? 'slds-badge slds-theme_warning'
                        : isRejected
                        ? 'slds-badge slds-theme_error'
                        : 'slds-badge slds-badge_lightest',
                    empStatusBadgeClass:
                        empStatus === 'Approved'
                            ? 'slds-badge slds-theme_success'
                            : empStatus === 'Rejected'
                            ? 'slds-badge slds-theme_error'
                            : 'slds-badge slds-theme_warning'
                };
            });
    }

    get hasPjps() { return this.filteredPjps.length > 0; }

    get filteredDistributors() {
        return this.distributors
            .filter(d => {
                if (!this.distSearchKey) return true;
                return (
                    (d.Name && d.Name.toLowerCase().includes(this.distSearchKey)) ||
                    (d.Distributor_Code__c && d.Distributor_Code__c.toLowerCase().includes(this.distSearchKey)) ||
                    (d.Distributor_Owner_Name__c && d.Distributor_Owner_Name__c.toLowerCase().includes(this.distSearchKey)) ||
                    (d.Contact_Person__c && d.Contact_Person__c.toLowerCase().includes(this.distSearchKey)) ||
                    (d.Mobile_Number__c && d.Mobile_Number__c.toLowerCase().includes(this.distSearchKey)) ||
                    (d.Email__c && d.Email__c.toLowerCase().includes(this.distSearchKey)) ||
                    (d.City__c && d.City__c.toLowerCase().includes(this.distSearchKey))
                );
            })
            .map(d => ({
                ...d,
                ownerNameDisplay: d.Distributor_Owner_Name__c || d.Contact_Person__c || '-',
                mobileDisplay: d.Mobile_Number__c || d.Phone__c || '-'
            }));
    }

    get hasDistributors() { return this.filteredDistributors.length > 0; }

    get filteredPrimaryOrders() {
        return this.primaryOrders
            .filter(po => {
                if (!this.poSearchKey) return true;
                return (
                    (po.Name && po.Name.toLowerCase().includes(this.poSearchKey)) ||
                    (po.Distributor_Name__c && po.Distributor_Name__c.toLowerCase().includes(this.poSearchKey)) ||
                    (po.Employee_Name__c && po.Employee_Name__c.toLowerCase().includes(this.poSearchKey)) ||
                    (po.Status__c && po.Status__c.toLowerCase().includes(this.poSearchKey))
                );
            })
            .map(po => {
                const isApproved = po.DO_Approval_Status__c === 'DO Approved' || po.Status__c === 'DO Approved';
                const isRejected = po.DO_Approval_Status__c === 'DO Rejected' || po.Status__c === 'DO Rejected';
                const isPending = !isApproved && !isRejected;
                return {
                    ...po,
                    isApproved,
                    isRejected,
                    isPending
                };
            });
    }

    get hasPrimaryOrders() { return this.filteredPrimaryOrders.length > 0; }

    get filteredDmsTickets() {
        return this.dmsTickets
            .filter(t => {
                if (!this.ticketSearchKey) return true;
                return (
                    (t.Name && t.Name.toLowerCase().includes(this.ticketSearchKey)) ||
                    (t.Subject__c && t.Subject__c.toLowerCase().includes(this.ticketSearchKey)) ||
                    (t.Category__c && t.Category__c.toLowerCase().includes(this.ticketSearchKey)) ||
                    (t.Distributor_Name__c && t.Distributor_Name__c.toLowerCase().includes(this.ticketSearchKey))
                );
            })
            .map(t => ({
                ...t,
                isOpen: t.Status__c === 'Open',
                isInProgress: t.Status__c === 'In Progress',
                isClosed: t.Status__c === 'Closed',
                isRejected: t.Status__c === 'Rejected'
            }));
    }

    get hasDmsTickets() { return this.filteredDmsTickets.length > 0; }

    get filteredPrimaryReturns() {
        return this.primaryReturns
            .filter(r => {
                if (!this.returnSearchKey) return true;
                return (
                    (r.Name && r.Name.toLowerCase().includes(this.returnSearchKey)) ||
                    (r.Product_Name__c && r.Product_Name__c.toLowerCase().includes(this.returnSearchKey)) ||
                    (r.Distributor_Name__c && r.Distributor_Name__c.toLowerCase().includes(this.returnSearchKey))
                );
            })
            .map(r => ({
                ...r,
                isApproved: r.Status__c === 'DO Approved',
                isRejected: r.Status__c === 'DO Rejected',
                isPending: r.Status__c !== 'DO Approved' && r.Status__c !== 'DO Rejected'
            }));
    }

    get hasPrimaryReturns() { return this.filteredPrimaryReturns.length > 0; }

    get purchasedVsSoldAnalytics() {
        if (!this.products || this.products.length === 0) {
            return [];
        }
        return this.products.map(p => {
            const piecesPerCase = p.Pieces_Per_Case__c || 48;
            const casePrice = p.Case_Price__c || 1000;
            // Count purchased cases
            let purchasedCases = 0;
            for (const po of this.primaryOrders) {
                if (po.Items_Summary__c && po.Items_Summary__c.includes(p.Name)) {
                    purchasedCases += 10;
                } else {
                    purchasedCases += Math.floor((po.Total_Cases__c || 0) / (this.products.length || 1));
                }
            }
            if (purchasedCases === 0) purchasedCases = 15;

            // Count sold secondary
            let soldPieces = 0;
            for (const so of this.secondaryOrders) {
                if (so.Product_Name__c === p.Name || (so.Product__r && so.Product__r.Name === p.Name)) {
                    soldPieces += (so.Total_Qty__c || 12);
                }
            }
            if (soldPieces === 0) soldPieces = 120;
            const soldCases = (soldPieces / piecesPerCase).toFixed(1);
            const stockCases = Math.max(0, purchasedCases - parseFloat(soldCases)).toFixed(1);
            const stockPieces = Math.max(0, (purchasedCases * piecesPerCase) - soldPieces);

            return {
                name: p.Name,
                piecesPerCase,
                casePrice,
                purchasedCases,
                soldCases,
                soldPieces,
                stockCases,
                stockPieces,
                stockStatus: parseFloat(stockCases) > 5 ? 'Healthy Stock' : 'Low Stock - Reorder DO',
                scheme: p.Primary_Scheme_Details__c || '10+1 Scheme'
            };
        });
    }

    // ==================== DISTRIBUTOR OFFICER & APPROVALS GETTERS ====================
    get activeOfficer() {
        if (!this.distributorOfficers || this.distributorOfficers.length === 0) {
            return {
                Id: 'a0eaj00000UEHyzAAH',
                Name: 'Ashok',
                Officer_Name__c: 'Ashok',
                Email__c: 'ashokkalasapura@gmail.com',
                Username__c: 'ashokkalasapura@gmail.com',
                Password__c: 'Ashok@123',
                Role__c: 'Distributor Officer',
                Designation__c: 'Distributor Officer (DO)',
                Phone__c: '9845112233',
                Status__c: 'Active',
                CurrencyIsoCode: 'INR'
            };
        }
        return this.distributorOfficers[0];
    }

    get filteredDistributorOfficers() {
        return this.distributorOfficers.filter(o => {
            if (!this.doSearchKey) return true;
            const q = this.doSearchKey.toLowerCase();
            return (
                (o.Name && o.Name.toLowerCase().includes(q)) ||
                (o.Officer_Name__c && o.Officer_Name__c.toLowerCase().includes(q)) ||
                (o.Email__c && o.Email__c.toLowerCase().includes(q)) ||
                (o.Username__c && o.Username__c.toLowerCase().includes(q)) ||
                (o.Role__c && o.Role__c.toLowerCase().includes(q))
            );
        });
    }

    get hasDistributorOfficers() {
        return this.filteredDistributorOfficers.length > 0;
    }

    get filteredPrimaryApprovals() {
        return this.primaryApprovals.filter(a => {
            if (!this.primaryApprovalSearchKey) return true;
            const q = this.primaryApprovalSearchKey.toLowerCase();
            return (
                (a.Name && a.Name.toLowerCase().includes(q)) ||
                (a.Primary_Order_Number__c && a.Primary_Order_Number__c.toLowerCase().includes(q)) ||
                (a.Distributor_Name__c && a.Distributor_Name__c.toLowerCase().includes(q)) ||
                (a.Product_Name__c && a.Product_Name__c.toLowerCase().includes(q))
            );
        }).map(a => ({
            ...a,
            isApproved: a.Approval_Status__c === 'Approved',
            isRejected: a.Approval_Status__c === 'Rejected',
            isPending: a.Approval_Status__c !== 'Approved' && a.Approval_Status__c !== 'Rejected'
        }));
    }

    get hasPrimaryApprovals() {
        return this.filteredPrimaryApprovals.length > 0;
    }

    get filteredReturnApprovals() {
        return this.returnApprovals.filter(r => {
            if (!this.returnApprovalSearchKey) return true;
            const q = this.returnApprovalSearchKey.toLowerCase();
            return (
                (r.Name && r.Name.toLowerCase().includes(q)) ||
                (r.Return_Number__c && r.Return_Number__c.toLowerCase().includes(q)) ||
                (r.Distributor_Name__c && r.Distributor_Name__c.toLowerCase().includes(q)) ||
                (r.Product_Name__c && r.Product_Name__c.toLowerCase().includes(q))
            );
        }).map(r => ({
            ...r,
            isApproved: r.Approval_Status__c === 'Approved',
            isRejected: r.Approval_Status__c === 'Rejected',
            isPending: r.Approval_Status__c !== 'Approved' && r.Approval_Status__c !== 'Rejected'
        }));
    }

    get hasReturnApprovals() {
        return this.filteredReturnApprovals.length > 0;
    }

    handleDOSearch(event) {
        this.doSearchKey = event.target.value;
    }

    handlePrimaryApprovalSearch(event) {
        this.primaryApprovalSearchKey = event.target.value;
    }

    handleReturnApprovalSearch(event) {
        this.returnApprovalSearchKey = event.target.value;
    }

    handleApprovePrimaryApproval(event) {
        const id = event.target.dataset.id;
        this.isLoading = true;
        approveDistributorPrimaryOrder({ approvalId: id, remarks: 'Approved by DO in Salesforce Org' })
            .then(() => {
                this.showToast('Success', 'Primary Order approved successfully!', 'success');
                this.loadData();
            })
            .catch(error => {
                this.isLoading = false;
                this.showToast('Error', error.body ? error.body.message : error.message, 'error');
            });
    }

    handleRejectPrimaryApproval(event) {
        const id = event.target.dataset.id;
        this.isLoading = true;
        rejectDistributorPrimaryOrder({ approvalId: id, remarks: 'Rejected by DO' })
            .then(() => {
                this.showToast('Success', 'Primary Order rejected', 'warning');
                this.loadData();
            })
            .catch(error => {
                this.isLoading = false;
                this.showToast('Error', error.body ? error.body.message : error.message, 'error');
            });
    }

    handleApproveReturnApproval(event) {
        const id = event.target.dataset.id;
        this.isLoading = true;
        approveDistributorReturn({ approvalId: id, remarks: 'Approved return claim' })
            .then(() => {
                this.showToast('Success', 'Return claim approved successfully!', 'success');
                this.loadData();
            })
            .catch(error => {
                this.isLoading = false;
                this.showToast('Error', error.body ? error.body.message : error.message, 'error');
            });
    }

    handleRejectReturnApproval(event) {
        const id = event.target.dataset.id;
        this.isLoading = true;
        rejectDistributorReturn({ approvalId: id, remarks: 'Rejected return claim' })
            .then(() => {
                this.showToast('Success', 'Return claim rejected', 'warning');
                this.loadData();
            })
            .catch(error => {
                this.isLoading = false;
                this.showToast('Error', error.body ? error.body.message : error.message, 'error');
            });
    }

    handleViewApprovalDetail(event) {
        const id = event.target.dataset.id;
        const app = this.primaryApprovals.find(a => a.Id === id);
        if (app) {
            let items = [];
            if (app.Items_JSON__c) {
                try {
                    items = JSON.parse(app.Items_JSON__c);
                } catch (e) {
                    items = [];
                }
            }
            this.selectedApproval = {
                ...app,
                parsedItems: items,
                hasItems: items && items.length > 0
            };
            this.showApprovalDetailModal = true;
        }
    }

    closeApprovalDetailModal() {
        this.showApprovalDetailModal = false;
        this.selectedApproval = null;
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}