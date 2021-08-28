public class TasksCloseController {
    
    @AuraEnabled
    public static List<Task> getTasks() {
        Id currentUserId = UserInfo.getUserId();
        List<Task> tasks = [SELECT Id, Subject, Status, ActivityDate, Description, 	CreatedById 
                            FROM Task
                            WHERE Status != 'Completed' AND CreatedById = :currentUserId]; 
    	return tasks;
    }
    
    @AuraEnabled
    public static List<String> getStatusPicklist() {
        List<String> statusPicklist = new List<String>();
        Schema.DescribeFieldResult fieldResult = Task.Status.getDescribe();
        List<Schema.PicklistEntry> picklist = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry picklistVal : picklist) {
            statusPicklist.add(picklistVal.getLabel());
            //System.debug('Values in Status are: ' + statusPicklist);
        }
        return statusPicklist;
    }
    
    @AuraEnabled
    public static void updateTasks(List<Task> tasks, String newStatus) {
        System.debug('updateTasks() run newStatus:' + newStatus);
        for (Task task : tasks) {
            task.Status = newStatus;
        }
        update tasks;
    }
}