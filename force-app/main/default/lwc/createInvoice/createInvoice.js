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
    const params = {
        ...this.currentPageRef.state, // Spread the existing state
        // If needed, you can filter out unnecessary params here:
        // c__origin_record, c__object_api_name, etc.
    };
    getRecord({ params: params, recordId: this.recId })
        .then(result => {
            if (typeof result === 'string') {
                this.jsonData = JSON.parse(result);
            } else {
                this.jsonData = result;
            }
            this.processJsonData(this.jsonData);
        })
        .catch(error => {
            console.log('error -- ', JSON.stringify(error));
        })
}
handleNavigate() {
        this.navigateNewScreen();

}

navigateNewScreen() {
    const jsonDataString = JSON.stringify(this.jsonData);
    this[NavigationMixin.Navigate]({
        type: 'standard__component',
        attributes: {
            componentName: 'c__displayJSON'  
        },
        state: {
            c__jsonData: jsonDataString,
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
    // fieldMap.push({ key : 'child_relationship_name' , value:  this.currentPageRef.state.c__child_relationship_name});

    // Handle Line Items
    if (data.LineItems && data.LineItems.length > 0) {
        data.LineItems.forEach((item, index) => {

        fieldMap.push({ key: `line_item_description_${index}`, value: item.CustomDescription }); 
        fieldMap.push({ key: `line_item_quantity_${index}`, value: item.CustomQuantity }); 
        fieldMap.push({ key: 'line_item_unit_price ', value: item.UnitAmount });      
    
    });  
} else {
    console.log('No line items found.');
}
        this.fieldMap = fieldMap; 
        }


}