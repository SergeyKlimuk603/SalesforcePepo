global class UpdateAccountFromLeadSchedule implements Schedulable{
    global void execute(SchedulableContext ctx) {
        Database.executeBatch(new ApdateAccountFromLeadBatch(), 3);
    }
}