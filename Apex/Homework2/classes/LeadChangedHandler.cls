/*
 * Класс обрабатывающий изменения в Leads при срабатывании 
 * триггера LeadChangedTrigger
 * Обеспечивает поиск сконвертированных Leads в которых были 
 * сделаны изменения в полях и отправляет список этих изменений
 * в виде PlatformEvent Leads_Changes__e
 */

public class LeadChangedHandler extends TriggerHandler {
    
    public static final Set<String> fieldsToUpdate = new Set<String>{'Phone', 'Description'};
    
	protected override void afterUpdate() { 
        // Получаем список конвертированных измененных Leads
        List<LeadChanges> convertedChangedLeads = 
        	getConvertedChangedLeads((Map<Id, Lead>) Trigger.OldMap, (Map<Id, Lead>) Trigger.NewMap);
        // Если полученный список не пустой то формируем PlatformEvent
        if (!convertedChangedLeads.isEmpty()) {
            createPlatformEvent(convertedChangedLeads);  
        }  
    }
    
    // Получаем список конвертированных измененных Leads
    private List<LeadChanges> getConvertedChangedLeads(Map<Id, Lead> oldMap, Map<Id, Lead> newMap) {
        // Список объектов для передачи изменений сделанных в Leads
        List<LeadChanges> convertedChangedLeads = new List<LeadChanges>();
        // Ищем изменения в сконвертированных лидах
        for (Id leadId : newMap.keySet()) {
            LeadChanges leadChanges = null;
            Lead oldLead = oldMap.get(leadId);
            Lead newLead = newMap.get(leadId);
            if (newLead.IsConverted && oldLead.IsConverted) {
                for (String field : fieldsToUpdate) {
                    if (oldLead.get(field) != newLead.get(field)) {
                        if (leadChanges == null) {
                            leadChanges = new LeadChanges(newLead.Id, newLead.ConvertedAccountId);
                        }
                        leadChanges.getListOfChanges().put(field, (String)newLead.get(field));
                    }
                }
                convertedChangedLeads.add(leadChanges);       
            }
        }
        return convertedChangedLeads;
    }
/*    
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
*/
    
    // Создаем PlatformEvent и отправляем его в EventBus
    private void createPlatformEvent(List<LeadChanges> listForSend) {
        List<Leads_Changes__e> events = new List<Leads_Changes__e>();
        // Сериализуем список полученных лидов
        String serializedLeads = JSON.serialize(listForSend);
        System.debug(serializedLeads);
        // Добавляем в список PlatformEvent
        events.add(new Leads_Changes__e(RawData__c = serializedLeads));
        // Публикуем PlatformEvent и заодно получаем результат публикации
        List<Database.SaveResult> results = EventBus.publish(events);
        for (Database.SaveResult sr : results) {
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
}