({
	closeModal : function(component) {
		let createEvent = component.getEvent("closeModal");
        createEvent.fire();
	},
    
    saveTasksStatus : function(component, taskStatus) {
        //console.log('MyOpenTasksModalWindowHelper taskStatus: ' + taskStatus);
        let createEvent = component.getEvent("saveTaskStatus");
        createEvent.setParams({
            "taskStatus" : taskStatus
        });
        createEvent.fire();
    },
    
    getStatusPicklist : function(component) {
        let action = component.get("c.getStatusPicklist");
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.statusPicklist", response.getReturnValue());
            } else {
                System.debug("MyPoenTasksModalWindowHelper не удалось получить список статусов");
            }
        });
        $A.enqueueAction(action);
    }
})