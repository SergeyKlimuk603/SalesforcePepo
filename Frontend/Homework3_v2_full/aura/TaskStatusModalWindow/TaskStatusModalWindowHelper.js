({
	closeModal : function(component) {
		let createEvent = component.getEvent("closeModal");
        createEvent.fire();
	},
    
    getStatusPicklist : function(component) {
        let action = component.get("c.getStatusPicklist");
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.statusPicklist", response.getReturnValue());
            } else {
                console.log("TaskStatusModalWindowHelper не удалось получить список статусов.");
            }
            component.set("v.runSpinner", false);
        });
        $A.enqueueAction(action);
    },
    
    saveTaskStatus : function(component, taskStatus) {
		let createEvent = component.getEvent("saveTaskStatus");
        createEvent.setParams({
            taskStatus : taskStatus
        });
        createEvent.fire();
	},
})