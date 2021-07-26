public class ApdateAccountFromLeadBatch implements Database.Batchable<sObject>{
    
    String query = 'SELECT Id, ConvertedAccountId, Email FROM Lead WHERE NeedToProcess__c = true';
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<Lead> scope) {
        Database.SaveResult[] saveResults = null;
        Mistakes_Log__c mistake = new Mistakes_Log__c(Name = '' + System.now());
        Boolean isMistake = false;
        try {
        	List<Account> accounts = new List<Account>();
        	for (Lead lead : scope) {
            	accounts.add(new Account(Id = lead.ConvertedAccountId, Email__c = lead.Email));
        	}
        	saveResults = Database.update(accounts, false);
        } catch (Exception ex) {
            isMistake = true;
            mistake.Message__c = ex.getMessage();
            mistake.StackTrace__c = ex.getStackTraceString();
        }
  
        String 	failedRecordsIds = '';
        String 	failedRecordsMessages = '';
        if (saveResults != null) {
        	for (Integer i = 0; i < scope.size(); i++) {
            	if (saveResults[i].isSuccess()) {
               		scope.get(i).NeedToProcess__c = false;
            	} else {
                	isMistake = true;
                	failedRecordsIds += scope.get(i).Id + ',,,';
                	failedRecordsMessages += saveResults[i].getErrors() + ',,,';    
            	} 
            } 
            Database.update(scope, false);
        }
        
        if (isMistake) {
            mistake.Failed_Records_Ids__c = failedRecordsIds;
        	mistake.Failed_Records_Messages__c = failedRecordsMessages;
        	Database.SaveResult sr = Database.insert(mistake, false);
        }  
    }

    public void finish(Database.BatchableContext bc) {}
}