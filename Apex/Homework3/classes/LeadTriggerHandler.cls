public class LeadTriggerHandler extends TriggerHandler {
    protected override void beforeUpdate() {
        markConvertingLeads((Map<Id, Lead>) Trigger.oldMap, (Map<Id, Lead>) Trigger.newMap);
    }
    
    private void markConvertingLeads(Map<Id, Lead> oldMap, Map<Id, Lead> newMap) {
        System.debug('oldMap = ' + oldMap);
        System.debug('newMap = ' + newMap);
        for (Id leadId : newMap.keySet()) {
            Lead oldLead = oldMap.get(leadId);
            Lead newLead = newMap.get(leadId);
            if (!oldLead.IsConverted && newLead.IsConverted) {
                newLead.NeedToProcess__c = true;
            }
        }    
    }
}