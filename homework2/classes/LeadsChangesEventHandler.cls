/*
 * Класс получает изменения в Leads при срабатывании 
 * триггера LeadsChangesEventTrigger
 * Обеспечивает поиск Accounts в которых необходимо применить
 * изменения сделанные в соответствующих Leads, проверяет - существуют
 * ли такие аккаунты (к моменту изменения Leads их могли уже и удалить)
 * и обновляет существующие записи Accounts
 */

public class LeadsChangesEventHandler extends TriggerHandler {
   
    protected override void afterInsert() {
        for (Leads_Changes__e event : (List<Leads_Changes__e>)Trigger.New) {
            // Получаем список измененных лидов
        	List<LeadChanges> convertedChangedLeads = getConvertedChangedLeads(event);
        	// Получаем из базы аккаунты, которые необходимо обновить
			List<Account> accounts = getAccounts(convertedChangedLeads);        
        	// Обновляем данные в полученных аккаунтах
        	updateAccounts(accounts);
        }   
    }
    
    // Получаем список измененных лидов
    private List<LeadChanges> getConvertedChangedLeads(Leads_Changes__e event) {
        List<LeadChanges> convertedChangedLeads = 
            (List<LeadChanges>) JSON.deserialize(event.RawData__c, List<LeadChanges>.class);
        return convertedChangedLeads;
    }
    
    // Создаем аккаунты, которые необходимо обновить
    private List<Account> getAccounts(List<LeadChanges> convertedChangedLeads) {
        List<Account> accounts = new List<Account>();
        for (LeadChanges leadChanges : convertedChangedLeads) {
            Account account = new Account(Id = leadChanges.getConvertedAccountId());
            for (String field : leadChanges.getListOfChanges().keySet()) {
            	String fieldValue = leadChanges.getListOfChanges().get(field);
                account.put(field, fieldValue);	
            }
            accounts.add(account);
        }
        return accounts;
    }
    
    private void updateAccounts(List<Account> accounts) {
        Database.update(accounts, false);
    }
    
/*
    // Получаем из базы аккаунты, которые необходимо обновить, передаем методу список изменений в Leads
    private List<Account> getAccounts(List<LeadChanges> convertedChangedLeads) {
        // Создаем список для хранения id Accounts, Leads которых были изменены (нужен для поиска этих
        // записей в базе данных)
        List<Id> assountsIds = new List<Id>();
        for (LeadChanges lc : convertedChangedLeads) {
            assountsIds.add(lc.getConvertedAccountId());
        }
        // Получаем из базы аккаунты, которые нужно обновить 
        // (не все аккаунты могут продолжать существовать при изменении их лида)
        return [SELECT Id, Phone, Description FROM Account WHERE Id IN :assountsIds];    
    }

    
    // Обновляем данные в полученных аккаунтах, в метод передаем список Accounts и
    // список изменений в Leads
    private void updateAccounts(Account[] accounts, List<LeadChanges> convertedChangedLeads) {
        if (accounts.size() > 0) {
            Integer i = 0;
        	for (LeadChanges lc : convertedChangedLeads) {
            	if (lc.getConvertedAccountId() == accounts[i].Id) {
                	updateAccount(accounts[i], lc);
                    if (++i > (accounts.size() - 1)) break;
            	}
        	}
            update accounts;
        }
    }

    
    // Обновление записей в аккаунте
    private void updateAccount(Account acct, LeadChanges leadChanges) {
        for (String field : leadChanges.getListOfChanges().keySet()) {
            switch on field {
                when 'Phone' {
                    acct.Phone = leadChanges.getListOfChanges().get(field);
                }
                when 'Description' {
                    acct.Description = leadChanges.getListOfChanges().get(field);
                }
            }
        }
    }
*/
}