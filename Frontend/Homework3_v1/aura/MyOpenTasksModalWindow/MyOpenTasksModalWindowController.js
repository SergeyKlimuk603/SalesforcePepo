({
    init : function(component, event, helper) {
        helper.getStatusPicklist(component);
    },
    
	closeModal : function(component, event, helper) {
		helper.closeModal(component);
	},
    
    saveTasksStatus : function(component, event, helper) {
        let taskStatus = component.get('v.selectedStatus');
        console.log('MyOpenTasksModalWindowController taskStatus: ' + taskStatus);
        helper.saveTasksStatus(component, taskStatus);
    }
})