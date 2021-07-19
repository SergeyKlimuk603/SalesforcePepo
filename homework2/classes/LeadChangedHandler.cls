/*
 * Класс обрабатывающий изменения в Leads при срабатывании 
 * триггера LeadChangedTrigger
 * Обеспечивает поиск сконвертированных Leads в которых были 
 * сделаны изменения в полях и отправляет список этих изменений
 * в виде PlatformEvent Leads_Changes__e
 */

public class LeadChangedHandler extends TriggerHandler {
    
    protected override void beforeInsert() {}
    protected override void beforeUpdate() {}
    protected override void beforeDelete() {}
    protected override void afterInsert() {}
    protected override void afterDelete() {}
    protected override void afterUndelete() {}
    
	 protected override void afterUpdate() {       
        List<LeadChanges> convertedChangedLeads = 
        	getConvertedChangedLeads((Map<Id, Lead>) Trigger.OldMap, (Map<Id, Lead>) Trigger.NewMap);
        if (convertedChangedLeads.size() > 0) {
            createPlatformEvent(convertedChangedLeads);  
        }  
    }
    
    private List<LeadChanges> getConvertedChangedLeads(Map<Id, Lead> oldMap, Map<Id, Lead> newMap) {
        // Список объектов для передачи изменений сделанных в Leads
        List<LeadChanges> convertedChangedLeads = new List<LeadChanges>();
        // Ищем изменения в сконвертированных лидах
        for (Id leadId : newMap.keySet()) {
            Lead oldLead = oldMap.get(leadId);
            Lead newLead = newMap.get(leadId);
            if (newLead.IsConverted) {
                if ((oldLead.Phone != newLead.Phone) || (oldLead.Description != newLead.Description)) {
                    // Получаем объект для передачи данных об изменениях в Lead
                    LeadChanges leadChanges = getLeadChanges(newLead, oldLead);
                    // Добавляем объект передачи изменений в Lead в список.
                    convertedChangedLeads.add(leadChanges);     
                }
            }
        }
        return convertedChangedLeads;
    }
    
    // Определяем, какие изменения были сделаны в Lead и записываем их в объекте передачи данных
    private LeadChanges getLeadChanges(Lead newLead, Lead oldLead) {
        // Создаем объект для передачи данных об изменениях в Lead
        LeadChanges leadChanges = new LeadChanges(newLead.Id, newLead.ConvertedAccountId);
        // Находим изменения
    	if (oldLead.Phone != newLead.Phone) {
        	leadChanges.getListOfChanges().put('Phone', newLead.Phone);
		}
		if (oldLead.Description != newLead.Description) {
            leadChanges.getListOfChanges().put('Description', newLead.Description);
        }
        return leadChanges;
    }
    
    // Создаем PlatformEvent и отправляем его в EventBus
    private void createPlatformEvent(List<LeadChanges> listForSend) {
        // Сериализуем список полученных лидов
        String serializedLeads = JSON.serialize(listForSend);
        System.debug(serializedLeads);
        // Создаем PlatformEvent
        Leads_Changes__e leadsChanges = new Leads_Changes__e(RawData__c = serializedLeads);
        // Публикуем PlatformEvent и заодно получаем результат публикации
        Database.SaveResult sr = EventBus.publish(leadsChanges);
        if (sr.isSuccess()) {
        System.debug('Successfully published event. Это новое решение');
        } else {
            for(Database.Error err : sr.getErrors()) {
                System.debug('Error returned: ' +
                             err.getStatusCode() +
                             ' - ' +
                             err.getMessage());
            }
        }
    } 
}