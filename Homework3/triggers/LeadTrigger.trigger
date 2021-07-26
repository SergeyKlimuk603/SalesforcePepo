trigger LeadTrigger on Lead (before update, after update) {
	new LeadTriggerHandler().run(Trigger.operationType);
}