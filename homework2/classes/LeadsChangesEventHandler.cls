/*
 * Класс получает изменения в Leads при срабатывании 
 * триггера LeadsChangesEventTrigger
 * Обеспечивает поиск Accounts в которых необходимо применить
 * изменения сделанные в соответствующих Leads, проверяет - существуют
 * ли такие аккаунты (к моменту изменения Leads их могли уже и удалить)
 * и обновляет существующие записи Accounts
 */

public class LeadsChangesEventHandler extends TriggerHandler {
    
    protected override void beforeInsert() {}
    protected override void beforeUpdate() {}
    protected override void beforeDelete() {}
    protected override void afterUpdate() {} 
    protected override void afterDelete() {}
    protected override void afterUndelete() {}
    
    protected override void afterInsert() {
        // Получаем список измененных лидов
        List<LeadChanges> convertedChangedLeads = getConvertedChangedLeads();
        // Получаем из базы аккаунты, которые необходимо обновить
		List<Account> accounts = getAccounts(convertedChangedLeads);        
        // Обновляем данные в полученных аккаунтах
        updateAccounts(accounts, convertedChangedLeads);  
    }
    
    // Получаем список измененных лидов
    private List<LeadChanges> getConvertedChangedLeads() {
        // Получаем PlatformEvent
        Leads_Changes__e leadsChangesEvent = (Leads_Changes__e)Trigger.New[0];
        // Получаем из PlatformEvent список лидов с изменениями
        return (List<LeadChanges>) JSON.deserialize(leadsChangesEvent.RawData__c, List<LeadChanges>.class);
    }
    
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
}