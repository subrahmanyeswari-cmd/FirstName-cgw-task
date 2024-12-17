import { LightningElement,api,track,wire } from 'lwc';
import createInvoice from '@salesforce/apex/createInvoiceController.createInvoice';
import { NavigationMixin } from 'lightning/navigation';
import { CurrentPageReference } from 'lightning/navigation';
export default class DisplayJSON extends NavigationMixin(LightningElement) {
    @api jsonData; 
    @track recId; 
    @wire(CurrentPageReference)
    currentPageRef;

connectedCallback() {
    if (this.currentPageRef && this.currentPageRef.state) {
        const urlParams = this.currentPageRef.state;
        const jsonString = urlParams.c__jsonData;
        this.recId = urlParams.c__recordId;
        if (jsonString) {
            try {
                let jsonData = JSON.parse(jsonString);
                this.jsonData = JSON.stringify(jsonData, null, 2); // Pretty-print JSON
            } catch (error) {
                console.error('Error parsing JSON string:', error);
            }
        }
    } else {
        console.error('CurrentPageReference is not available or missing state.');
    }

}

createInvoice(){    
    createInvoice({jsonData : this.jsonData,recordId : this.recId})
    .then(result =>{
        this.navigateToRecord(result);
    })
    .catch(error => {

    })
}

navigateToRecord(recordId){
        this[NavigationMixin.Navigate]({
        type: 'standard__recordPage',
        attributes: {
            recordId: recordId, 
            objectApiName: 'Invoice__c', 
            actionName: 'view' 
        }
    });

}

}