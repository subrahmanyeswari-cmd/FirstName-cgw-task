import { LightningElement,api,wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { CurrentPageReference } from 'lightning/navigation';
export default class CreateInvoiceParent extends NavigationMixin(LightningElement) {
      wireRecordId; //this will hold the current record id fetched from pagereference
    currectRecordId; //this will hold the current record id fetched from getter and setter
    

     @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            console.log('currentPageReference ', currentPageReference);
            //it gets executed before the connected callback and avilable to use
            this.wireRecordId = currentPageReference.state.recordId;
            console.log('in -- ',this.wireRecordId);
        }
    }
    connectedCallback() {
        this.navigateToComponent();
    }
    navigateToComponent() {
        console.log('next');
    this[NavigationMixin.Navigate]({
      // Pass in pageReference
      type: 'standard__component',
      attributes: {
      componentName: 'c__createInvoice',
      },
      state: {
        c__origin_record : this.wireRecordId,
        c__account : 'Account.Name',
        c__invoice_date : 'CloseDate',
        c__invoice_due_date : 'CreatedDate',
        c__child_relationship_name : 'Invoice_Line_Items__r',
        c__line_item_description : 'Line_Description__c',
        c__line_item_quantity : 'Quantity__c',
        c__line_item_unit_price : 'Unit_Price__c'
        }
    });
  }

}