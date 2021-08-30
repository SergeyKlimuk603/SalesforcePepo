public class OpenTasksController {
	@AuraEnabled
    public static TaskDataTableWrapper gerOpenTasks(Integer pageSize, Integer pageNumber) {
        Id currentUserId = UserInfo.getUserId();
        Integer offset = (pageNumber - 1) * pageSize;
        Integer totalRecords = [SELECT COUNT()
                                FROM Task 
                				WHERE Status != 'Completed' AND CreatedById = :currentUserId];
        Integer recordEnd = pageSize * pageNumber;
        
        TaskDataTableWrapper taskWrapper = new TaskDataTableWrapper();
        taskWrapper.pageSize = pageSize;
        taskWrapper.pageNumber = pageNumber;
        taskWrapper.totalRecords = totalRecords;
        taskWrapper.recordStart = offset + 1;
        taskWrapper.recordEnd = totalRecords >= recordEnd ? recordEnd : totalRecords;
        taskWrapper.taskList = [SELECT Id, Subject, Status, ActivityDate, Description
                				FROM Task 
                				WHERE Status != 'Completed' AND CreatedById = :currentUserId
                                ORDER BY ActivityDate
                				LIMIT :pageSize
                				OFFSET :offset];
        return taskWrapper;
    }
    
    @AuraEnabled
    public static List<String> getStatusPicklist() {
        List<String> statusPicklist = new List<String>();
        Schema.DescribeFieldResult fieldResult = Task.Status.getDescribe();
        List<Schema.PicklistEntry> picklist = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry picklistVal : picklist) {
            statusPicklist.add(picklistVal.getLabel());
        }
        return statusPicklist;
    }
    
    @AuraEnabled
    public static void updateStatusRecords(List<Id> recordIds, String newStatus) {
        List<sObject> records = new List<sObject>();
        for (Id recordId : recordIds) {
            sObject task = new Task(Id = recordId, Status = newStatus);
            records.add(task);
        }
        update records;
    }
    
    public class TaskDataTableWrapper {
        @AuraEnabled
        public Integer pageSize;
        @AuraEnabled
        public Integer pageNumber;
        @AuraEnabled
        public Integer totalRecords;
        @AuraEnabled
        public Integer recordStart;
        @AuraEnabled
        public Integer recordEnd;
        @AuraEnabled
        public List<Task> taskList;
    }
}