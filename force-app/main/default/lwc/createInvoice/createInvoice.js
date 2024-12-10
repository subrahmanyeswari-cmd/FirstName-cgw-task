import { LightningElement, track, api, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import getRecord from '@salesforce/apex/createInvoiceController.getRecord';
export default class CreateInvoice extends LightningElement {
    @track recId;
    @track fieldMap;
    @track params = [];
    @wire(CurrentPageReference)
    currentPageRef;

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


}