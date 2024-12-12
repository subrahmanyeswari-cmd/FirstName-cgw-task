import { LightningElement, track, api, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { NavigationMixin } from 'lightning/navigation';
import getRecord from '@salesforce/apex/createInvoiceController.getRecord';
import createJSON from '@salesforce/apex/createInvoiceController.createJSON';
export default class CreateInvoice extends NavigationMixin(LightningElement) {
    @track recId;
    @track fieldMap;
    @track params = [];
    @wire(CurrentPageReference)
    currentPageRef;
    @track jsonData;

    connectedCallback() {
        this.recId = this.currentPageRef.state.c__origin_record;
        this.getOppRecord();
    }
    getOppRecord() {
        getRecord({ params: this.currentPageRef.state, recordId: this.recId })
            .then(result => {
                this.fieldMap = Object.entries(result).map(([key, value]) => ({ key, value }));
            })
            .catch(error => {
                console.log('error -- ', JSON.stringify(error));
            })
    }
    handleNavigate() {
        createJSON({ recordId: this.recId })
            .then(result => {
                this.jsonData = result;
                this.navigateNewScreen();
            })
            .catch(error => {
                console.log('error -- ', JSON.stringify(error));
            })
    }

    navigateNewScreen() {
        console.log('here');
        this[NavigationMixin.Navigate]({
            type: 'standard__component',
            attributes: {
                componentName: 'c__displayJSON'  
            },
            state: {
                c__jsonData: this.jsonData  
            }
        });
    }


}