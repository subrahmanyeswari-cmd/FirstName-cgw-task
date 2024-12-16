import { LightningElement, track, api, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { NavigationMixin } from 'lightning/navigation';
import getRecord from '@salesforce/apex/createInvoiceController.getRecord';
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
                this.jsonData = result;
                let jsonData = JSON.parse(result);
                this.processJsonData(jsonData);
            })
            .catch(error => {
                console.log('error -- ', JSON.stringify(error));
            })
    }
    handleNavigate() {
         this.navigateNewScreen();
  
    }

    navigateNewScreen() {
        console.log('here');
        this[NavigationMixin.Navigate]({
            type: 'standard__component',
            attributes: {
                componentName: 'c__displayJSON'  
            },
            state: {
                c__jsonData: this.jsonData,
                c__recordId: this.recId
            }
        });
    }

    processJsonData(data) { 
        let fieldMap = []; // Process main fields 
        fieldMap.push({ key : 'orgin_record' , value: this.recId});
        fieldMap.push({ key : 'account' , value: this.recId});
        fieldMap.push({ key : 'invoice_date' , value: data.DateValue});
        fieldMap.push({ key : 'invoice_due_date' , value: data.DueDate});
        fieldMap.push({ key : 'child_relationship_name' , value:  this.currentPageRef.state.c__child_relationship_name});

    
       data.LineItems.forEach((item, index) => { 
            fieldMap.push({ key: 'line_item_description ', value: item.Description }); 
            fieldMap.push({ key: 'line_item_quantity ', value: item.Quantity }); 
            fieldMap.push({ key: 'line_item_unit_price ', value: item.UnitAmount }); 
       });  
            this.fieldMap = fieldMap; 
            console.log('firld -- ',JSON.stringify(this.fieldMap));
            }


}