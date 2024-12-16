import { LightningElement,api,track } from 'lwc';
import createInvoice from '@salesforce/apex/createInvoiceController.createInvoice';
import { NavigationMixin } from 'lightning/navigation';
export default class DisplayJSON extends NavigationMixin(LightningElement) {
       @api jsonData; 
       @track recId; 
    connectedCallback() {
        const urlParams = new URLSearchParams(window.location.search);
        const jsonString = urlParams.get('c__jsonData'); 
        this.recId = urlParams.get('c__recordId');
        if (jsonString) {
            let jsonData = JSON.parse(jsonString);
            this.jsonData = JSON.stringify(jsonData, null, 2); 
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