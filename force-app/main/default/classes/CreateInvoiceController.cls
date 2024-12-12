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
					query = query + ',' + param;
			}
			
		}
		query = query + ' FROM Opportunity WHERE Id = :recordId';
		Opportunity opp = Database.query(query);

		Date createdDate1 = opp.CreatedDate.date();
		String invoiceDate = opp.CloseDate.format();		
		String invoiceDueDate =createdDate1.format();
		Map<String,String> response = new Map<String,String>();
		response.put('orgin_record',recordId);
		response.put('account',opp.Account.Name);
		response.put('invoice_date',invoiceDate);
		response.put('invoice_due_date',invoiceDueDate);
		response.put('child_relationship_name',childObj);
		response.put('line_item_description',opp.Description);
		response.put('line_item_quantity',String.valueOf(opp.TotalOpportunityQuantity));
		response.put('line_item_unit_price', String.valueOf(opp.Unit__c));
		
		return response;
	}

	@AuraEnabled
	public static String createJSON(String recordId){
		system.debug('rec -- '+recordId);
		Opportunity opp = [Select Id,Account.Name,CreatedDate,CloseDate,Unit__c,Description,TotalOpportunityQuantity From Opportunity WHere Id = :recordId];
		 LineItem lineItem = new LineItem(
                opp.Description,
                String.valueOf(opp.TotalOpportunityQuantity),  
                String.valueOf(opp.Unit__c), 
                '200', 
                '20' 
            );
			 ContactValue contactVal = new ContactValue('eaa28f49-6028-4b6e-bb12-d8f6278073fc');
		List<LineItem> lineItemList = new List<LineItem>{lineItem};
		jsonWrapper wrap = new jsonWrapper('ACCREC'
											,contactVal 
											,String.valueOf(opp.CreatedDate)
											,String.valueOf(opp.CreatedDate)
											,String.valueOf(opp.CloseDate)
											,String.valueOf(opp.CloseDate)
											,'Exclusive'
										, lineItemList );
										
		String jsonString = JSON.serialize(wrap);
		return jsonString;
		
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
    
    
    public jsonWrapper(String typeVal , ContactValue contactVal, String dateValue, String dateString, String dueDate, String dueDateString, String lineAmountTypes, List<LineItem> lineItems) {
        this.Type = typeVal;
        this.ContactVal= contactVal;
     	this.DateValue = dateValue;
        this.DateString = dateString;
        this.DueDate = dueDate;
        this.DueDateString = dueDateString;
      	this.LineAmountTypes = lineAmountTypes;
        this.LineItems = lineItems; 
    }
}

public class LineItem {
    public String Description;
    public String Quantity;
    public String UnitAmount;
    public String AccountCode;
    public String DiscountRate;
    
  
    public LineItem(String description, String quantity, String unitAmount, String accountCode, String discountRate) {
        this.Description = description;
        this.Quantity = quantity;
        this.UnitAmount = unitAmount;
        this.AccountCode = accountCode;
        this.DiscountRate = discountRate;
    }
}

public class ContactValue {
    public String ContactID;
   
    public ContactValue(String contactID) {
        this.ContactID = contactID;
    }
}

	
	
}