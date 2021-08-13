/*
 * Триггер срабатывающий на PlatformEvent Leads_Changes__e
 */

trigger LeadsChangesEventTrigger on Leads_Changes__e (after insert) {
    new LeadsChangesEventHandler().run(Trigger.operationType);
}