({
	getTasks : function(component) {
		let action = component.get("c.getTasks");
        action.setCallback(this, function(response) {
            component.set('v.tasksList', response.getReturnValue())
        });
        $A.enqueueAction(action);
	},
    
    closeModal : function(component) {
        component.set('v.showModalWindow', false);
    },
    
    saveTaskStatus : function(component, selectedRows, newTasksStatus) {
        console.log('saveTaskStatus');
        this.closeModal(component);
        let action = component.get("c.updateTasks");
        action.setParams({
           "tasks": selectedRows,
           "newStatus": newTasksStatus
        });
        action.setCallback(this, function(response) {
            component.reInit();
            this.showToast(response.getState(), "Records was updated successfully.");
        });
        $A.enqueueAction(action);
    },
    
    
    showToast : function(title, message) {
    	var toastEvent = $A.get("e.force:showToast");
    	toastEvent.setParams({
        	title: title,
        	message: message,
            type: 'success'
    	});
    	toastEvent.fire();
    }
})