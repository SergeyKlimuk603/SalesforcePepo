public class ApdateAccountFromLeadBatch1 implements Database.Batchable<sObject>{
    
    String query = 'SELECT Id, ConvertedAccountId, Email FROM Lead WHERE NeedToProcess__c = true';
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<Lead> scope) {
        Mistakes_Log__c mistake = new Mistakes_Log__c(Name = '' + System.now());
        try {
        	List<Account> accounts = new List<Account>();
        	for (Lead lead : scope) {
            	accounts.add(new Account(Id = lead.ConvertedAccountId, Email__c = lead.Email));
        	}
        	Database.update(accounts, true);
        }
        catch (DmlException dmlExs) {
            String 	failedRecordsIds = '';
        	String 	failedRecordsMessages = '';
            for (Integer i = 0; i < dmlExs.getNumDml(); i++) {
                failedRecordsIds += dmlExs.getDmlId(i) + ',,';
                failedRecordsMessages += dmlExs.getDmlMessage(i) + ',,';
            }
            mistake.Failed_Records_Ids__c = failedRecordsIds;
        	mistake.Failed_Records_Messages__c = failedRecordsMessages;
            Database.insert(mistake, false);
/*            
            System.debug('DmlException сработал');
            System.debug('dmlEx.getDmlId = ' + dmlExs.getDmlId(0));
            System.debug('dmlEx.getDmlIndex = ' + dmlExs.getDmlIndex(0));
            System.debug('dmlEx.getDmlMessage = ' + dmlExs.getDmlMessage(0));
            System.debug('dmlEx.getDmlStatusCode = ' + dmlExs.getDmlStatusCode(0));
            System.debug('dmlEx.getMessage = ' + dmlExs.getMessage());
            System.debug('dmlEx.getStackTraceString = ' + dmlExs .getStackTraceString());
            System.debug('dmlEx.getNumDml = ' + dmlExs.getNumDml());
*/
        } 
        catch (Exception ex) {
            mistake.Message__c = ex.getMessage();
            mistake.StackTrace__c = ex.getStackTraceString();
            Database.insert(mistake, false);
        }      
    }
    
    public void finish(Database.BatchableContext bc) {}
}