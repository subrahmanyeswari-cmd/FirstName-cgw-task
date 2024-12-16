/**
* @File Name : createInvoiceController.cls
* @Description :
* @Author :
* @Last Modified By :
* @Last Modified On : December 10, 2024
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | December 10, 2024 |   | Initial Version
**/

public class CreateInvoiceController {
	@AuraEnabled
	public static String getRecord(Map<String,String> params, string recordId){
		String query = 'SELECT Id';
		String oppLineItemQuery = 'Select Id';
		String childObj = params.get('c__child_relationship_name');
		String lineItemQuery = 'SELECT Id ';
		List<String> keys = new List<String>(params.keySet());
		if(!keys.isEmpty()){
			String firstKey = keys[0];
			params.remove(firstKey);
		}
		for(String param : params.values()){
			if(param != 'OpportunityLineItems'){
				if(param != 'Description' && param != 'Quantity' && param != 'UnitPrice'){
					query = query + ',' + param;
				}
				else{
					oppLineItemQuery = oppLineItemQuery + ',' + param;
				}
					
			}
			
		}
		oppLineItemQuery =  '(' + oppLineItemQuery + ',Discount FROM '+ childObj + ')';
		query = query + ',' + oppLineItemQuery + ' FROM Opportunity WHERE Id = :recordId';
		system.debug('query -- '+query);
		List<Opportunity> oppList = Database.query(query);
		system.debug('opp  -- '+oppList);
	

		jsonWrapper wrap = new jsonWrapper();

		for(Opportunity opp : oppList){
			wrap.Type = 'TESTJSON';
			wrap.DateValue = String.valueOf(opp.CreatedDate);
			wrap.DateString = String.valueOf(opp.CreatedDate);
			wrap.DueDate = String.valueOf(opp.CloseDate);
			wrap.DueDateString = String.valueOf(opp.CloseDate);
			wrap.LineAmountTypes = 'Exclusive';
			wrap.ContactVal = new ContactValue('eaa28f49-6028-4b6e-bb12-d8f6278073fc');
			List<LineItem> lineItemList = new List<LineItem>();
			for(OpportunityLineItem item : opp.OpportunityLineItems){
				LineItem lineItem = new LineItem();
				lineItem.Description = item.Description;
				lineItem.Quantity = item.Quantity;
				lineItem.UnitAmount = item.UnitPrice;
				lineItem.DiscountRate = item.Discount;
				lineItem.AccountCode = 'ACCCODE';
				lineItemList.add(lineItem);
			}
			wrap.LineItems = lineItemList;
		}
		
		String jsonString = JSON.serialize(wrap);
		return jsonString;
	}



	@AuraEnabled
	public static String createInvoice(String jsonData,String recordId){
		String invoiceId;
		jsonWrapper wrapper = (jsonWrapper) JSON.deserialize(jsonData, jsonWrapper.class);
		
		try{
			Invoice__c invoice = new Invoice__c();
		invoice.Due_Date__c =  Date.valueOf(wrapper.DueDate);
		invoice.Opportunity__c = recordId;
		invoice.Invoice_Reference__c = wrapper.Type;

		insert invoice;
		invoiceId =invoice.Id;

		List<Invoice_Line_Item__c> lineItemList = new List<Invoice_Line_Item__c>();
		
		 for (LineItem li : wrapper.LineItems){
			Invoice_Line_Item__c lineItem = new Invoice_Line_Item__c();
			lineItem.Invoice__c = invoice.Id;
			lineItem.Unit_Price__c = li.UnitAmount;
			lineItem.Quantity__c = li.Quantity == null ? 0 : Integer.valueOf(li.Quantity);
			lineItem.Line_Description__c = li.Description;
			lineItemList.add(lineItem);
		 }
		 insert lineItemList;
			 return invoiceId;
		}
		catch(exception e){
			return 'Error: ' + e.getMessage();
		}
		
		

	}

	public class jsonWrapper {
    public String Type;
    public ContactValue ContactVal;
    public String DateValue;
    public String DateString;
    public String DueDate;
    public String DueDateString;
    public String LineAmountTypes;
    public List<LineItem> LineItems;
    
 
}

public class LineItem {
    public String Description;
    public Decimal Quantity;
    public Decimal UnitAmount;
    public String AccountCode;
    public Decimal DiscountRate;
}

public class ContactValue {
    public String ContactID;
   
   public ContactValue(String contactID) {
        this.ContactID = contactID;
    } 
}

	
	
}