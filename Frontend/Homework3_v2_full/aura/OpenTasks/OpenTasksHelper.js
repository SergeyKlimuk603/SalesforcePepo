({
	getColumnAndAction : function(component) {
        let actions = [
            {label: 'Edit', name: 'edit'},
            {label: 'Delete', name: 'delete'},
            {label: 'View', name: 'view'}
        ];
		let columns = [
            {label: 'Subject', fieldName: 'Subject', type: 'picklist'},
            {label: 'Status', fieldName: 'Status', type: 'picklist'},
            {label: 'Due date', fieldName: 'ActivityDate', type: 'data'},
            {label: 'Comments', fieldName: 'Description', type: 'text'},
            {type: 'action', typeAttributes: {rowActions: actions}}
        ];
		component.set('v.columns', columns);
	},
    
    getOpenTasks : function(component) {
        component.set("v.runSpinner", true);
        let action = component.get("c.gerOpenTasks");
        let pageSize = component.get("v.pageSize");
        let pageNumber = component.get("v.pageNumber");
        action.setParams({
            pageSize: pageSize,
            pageNumber: pageNumber
        });
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
            	let resultData = response.getReturnValue();
                //console.log('OpenTasksHelper getOpenTasks resultData: ' + resultData.totalRecords);
                component.set("v.data", resultData.taskList);
                component.set("v.pageNumber", resultData.pageNumber);
                component.set("v.totalPages", Math.ceil(resultData.totalRecords/pageSize));
                component.set("v.totalRecords", resultData.totalRecords);
                component.set("v.recordStart", resultData.recordStart);
                component.set("v.recordEnd", resultData.recordEnd);
                
                component.set("v.runSpinner", false);
            }
        });
        $A.enqueueAction(action);
    },
    
    showModal : function(component) {
        component.set('v.showModalWindow', true);
    },
    
    closeModal : function(component) {
        component.set('v.showModalWindow', false);
    },
    
    saveTaskStatus : function(component, event) {
        let taskStatus = event.getParam("taskStatus");
        let selectedRows = component.find('taskTable').getSelectedRows();
        let selectedRowsId = [];
        for (let i = 0; i < selectedRows.length; i++) {
            selectedRowsId[i] = selectedRows[i].Id;
        }
        console.log('OpenTasksHelper saveTaskStatus selectedRowsId: ' + JSON.stringify(selectedRowsId));
    	let action = component.get("c.updateStatusRecords");
        action.setParams({
            recordIds: selectedRowsId,
            newStatus: taskStatus
        });
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                this.getOpenTasks(component);
            	this.showToast(response.getState(),
                           "Records was updated successfully.",
                           "success");
            } else {
                this.showToast(response.getState(),
                           "Something is wrong.",
                           "error");
            }
            
        });
        $A.enqueueAction(action);
        
    },
    
    showToast : function(title, message, type) {
    	var toastEvent = $A.get("e.force:showToast");
    	toastEvent.setParams({
        	title: title,
        	message: message,
            type: type
    	});
    	toastEvent.fire();
    },
})