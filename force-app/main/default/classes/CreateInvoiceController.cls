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

	List<String> fieldsToSelect = new List<String>();
	String query = 'SELECT Id';
	String oppLineItemQuery = 'SELECT Id';
	String childObj = params.get('c__child_relationship_name');
	// Use a Set to ensure unique fields
	Set<String> oppFieldsSet = new Set<String>();
	Set<String> oppLineItemFieldsSet = new Set<String>();
	// Retrieve all fields from OpportunityLineItem using Describe
	Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get('OpportunityLineItem').getDescribe().fields.getMap();

	// Add all available fields for OpportunityLineItem to the subquery
	List<String> oppLineItemFields = new List<String>();
	for (String fieldName : fieldMap.keySet()) {
		if (fieldName != 'Id') {
		oppLineItemFieldsSet.add(fieldName); // Add each field dynamically
		}
	}
	// If there are fields, join them with commas and add to the subquery
	if (!oppLineItemFieldsSet.isEmpty()) {
		oppLineItemQuery += ', ' + String.join(oppLineItemFieldsSet, ', ');
	}
		oppLineItemQuery += ' FROM ' + childObj;
	
	// Retrieve all fields from Opportunity using Describe
	Map<String, Schema.SObjectField> oppFieldMap = Schema.getGlobalDescribe().get('Opportunity').getDescribe().fields.getMap();

	// Add fields for Opportunity that are needed for the query
	List<String> oppFields = new List<String>();

	// Add all available fields for Opportunity to the main query (excluding Id)
	for (String fieldName : oppFieldMap.keySet()) {
		if (fieldName != 'Id') { // Exclude Id field, as it's already included
		oppFieldsSet.add(fieldName);
		}
	}

	// If there are fields for Opportunity, join them with commas and add to the query
	if (!oppFieldsSet.isEmpty()) {
		query += ', ' + String.join(oppFieldsSet, ', ');
	}

// Add the subquery
	query += ', (' + oppLineItemQuery + ') FROM Opportunity WHERE Id = :recordId';
	System.debug('Final Query: ' + query);

	List<Opportunity> oppList = Database.query(query);
	system.debug('opp  -- '+oppList);

			// Check if records are returned
			if (oppList.isEmpty()) {
				return 'No records found for the given Opportunity Id.';
			}
	
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
			//lineItem.Description = item.Description;
			//lineItem.Quantity = item.Quantity;
			lineItem.UnitAmount = item.UnitPrice;
			lineItem.DiscountRate = item.Discount;
			lineItem.AccountCode = 'ACCCODE';
			lineItem.CustomDescription = (String)item.get('Custom_Description__c'); // Custom field
			lineItem.CustomQuantity = (Decimal)item.get('Custom_Quantity__c'); // Custom field
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
		lineItem.Custom_Description__c = li.CustomDescription; // Add custom field
		lineItem.Custom_Quantity__c = li.CustomQuantity == null ? 0 : Integer.valueOf(li.CustomQuantity); // Add custom field
		
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
public String CustomDescription; // New field
public Decimal CustomQuantity;  // New field
}

public class ContactValue {
public String ContactID;

public ContactValue(String contactID) {
	this.ContactID = contactID;
} 
}	

}