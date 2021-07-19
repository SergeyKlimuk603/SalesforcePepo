/*
 * Триггер срабатывающий на изменения в Leads
 */

trigger LeadChangedTrigger on Lead (before insert, before update, before delete,
                                   after insert, after update, after delete, after undelete) {
	new LeadChangedHandler().run(Trigger.operationType);
}