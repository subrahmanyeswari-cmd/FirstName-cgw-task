import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { CurrentPageReference } from 'lightning/navigation';
export default class CreateInvoiceParent extends NavigationMixin(LightningElement) {
  wireRecordId; //this will hold the current record id fetched from pagereference
  currectRecordId; //this will hold the current record id fetched from getter and setter


  @wire(CurrentPageReference)
  getStateParameters(currentPageReference) {
      if (currentPageReference) {
          console.log('currentPageReference ', currentPageReference);
          this.wireRecordId = currentPageReference.state.recordId; 
          this.navigateToComponent();
      }
  }
  navigateToComponent() {
      this[NavigationMixin.Navigate]({
          // Pass in pageReference
          type: 'standard__component',
          attributes: {
              componentName: 'c__createInvoice',
          },
          state: {
              c__origin_record: this.wireRecordId,
              c__account: 'Account.Name',
              c__invoice_date: 'CloseDate',
              c__invoice_due_date: 'CreatedDate',
              c__child_relationship_name: 'OpportunityLineItems',
              c__line_item_description: 'Custom_Description__c',
              c__line_item_quantity: 'Custom_Quantity__c',
              c__line_item_unit_price: 'UnitPrice'
          }
      });
  }

}