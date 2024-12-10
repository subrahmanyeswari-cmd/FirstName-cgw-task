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
	public static Map<String,String> getRecord(Map<String,String> params, string recordId){
		String query = 'SELECT Id';
		String childObj = params.get('c__child_relationship_name');
		String lineItemQuery = 'SELECT Id ';
		List<String> keys = new List<String>(params.keySet());
		if(!keys.isEmpty()){
			String firstKey = keys[0];
			params.remove(firstKey);
		}
		for(String param : params.values()){
			if(param != 'Invoice_Line_Items__r'){
				if(param != 'Line_Description__c' && param != 'Quantity__c' && param != 'Unit_Price__c' ){
					query = query + ',' + param;
				}
				else{
					lineItemQuery = lineItemquery + ',' + param;
				}
			}
			
		}
		query = query + ' FROM Opportunity WHERE Id = :recordId';
		system.debug('query == '+query);
		Opportunity opp = Database.query(query);

		lineItemQuery = 'Select Id,Opportunity__c ,(' +lineItemQuery + ' FROM Invoice_Line_Items__r) FROM Invoice__c WHERE Opportunity__c = :recordId';
		system.debug('lin -- '+lineItemQuery);
		List<Invoice__c> invoiceList = Database.query(lineItemQuery);
		Map<Id,Invoice_Line_Item__c> lineItemMap = new Map<Id,Invoice_Line_Item__c>();

		for(Invoice__c inv : invoiceList){
		//	lineItemMap.put(inv.Id);
			for(Invoice_Line_Item__c item : inv.Invoice_Line_Items__r){
				lineItemMap.put(recordId,item);
			}
		}
		Date createdDate1 = opp.CreatedDate.date();
		String invoiceDate = opp.CloseDate.format();
		
		String invoiceDueDate =createdDate1.format();
		Map<String,String> response = new Map<String,String>();
		response.put('orgin_record',recordId);
		response.put('account',opp.Account.Name);
		response.put('invoice_date',invoiceDate);
		response.put('invoice_due_date',invoiceDueDate);
		response.put('child_relationship_name',childObj);
		system.debug('map -- '+lineItemMap);
		response.put('line_item_description',lineItemMap.get(opp.id).Line_Description__c);
		response.put('line_item_quantity',String.valueOf(lineItemMap.get(opp.Id).Quantity__c));
		response.put('line_item_unit_price', String.valueOf(lineItemMap.get(opp.Id).Unit_Price__c));
		


		system.debug('item - '+query);

		return response;


	}
	
	
}