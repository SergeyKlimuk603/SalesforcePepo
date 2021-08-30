({
    init : function(component, event, helper) {
		helper.getStatusPicklist(component);
	},
    
	closeModal : function(component, event, helper) {
		helper.closeModal(component);
	},
    
    saveTasksStatus : function(component, event, helper) {
		let taskStatus = component.get('v.selectedStatus');
        if (taskStatus === "") {
            //TODO Create ERROR message
        } else {
            helper.saveTaskStatus(component, taskStatus);
        }
	}
})