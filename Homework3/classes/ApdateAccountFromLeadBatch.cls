public class ApdateAccountFromLeadBatch implements Database.Batchable<sObject>{
    
    String query = 'SELECT Id, ConvertedAccountId, Email FROM Lead WHERE NeedToProcess__c = true';
    Mistakes_Log__c mistake = new Mistakes_Log__c(Name = '' + System.now());
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<Lead> leads) {
        try {
        	List<Account> accounts = new List<Account>();
        	for (Lead lead : leads) {
            	accounts.add(new Account(Id = lead.ConvertedAccountId, Email__c = lead.Email));
        	}
        	Database.SaveResult[] saveResults = Database.update(accounts, false);
            proccessingSaveResults(saveResults, leads);
        } catch (Exception ex) {
            mistake.Message__c = ex.getMessage();
            mistake.StackTrace__c = ex.getStackTraceString();
            Database.insert(mistake, false);
        }
    }
    
    private void proccessingSaveResults(Database.SaveResult[] saveResults, List<Lead> leads) {
        List<Lead> updateLeads = new List<Lead>();
        String 	failedRecordsIds = '';
       	String 	failedRecordsMessages = '';
        for (Integer i = 0; i < saveResults.size(); i++) {
            if (saveResults[i].isSuccess()) {
               	leads.get(i).NeedToProcess__c = false;
                updateLeads.add(leads.get(i));
            } else {
                failedRecordsIds += leads.get(i).Id + ',,,';
                failedRecordsMessages += saveResults[i].getErrors() + ',,,';    
            } 
        }
        updateLeads(updateLeads);
        addErrorsToMistakesLog(failedRecordsIds, failedRecordsMessages);
    }
    
    private void updateLeads(List<Lead> updateLeads) {
        if (!updateLeads.isEmpty()) {
            Database.update(updateLeads, false);
        } 
    }
    
    private void addErrorsToMistakesLog(String Ids, String messages) {
        if (Ids != '') {
            mistake.Failed_Records_Ids__c = Ids;
        	mistake.Failed_Records_Messages__c = messages;
            Database.insert(mistake, false);
         }
    }

    public void finish(Database.BatchableContext bc) {}
}