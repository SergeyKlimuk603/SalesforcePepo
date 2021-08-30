({
    init : function(component, event, helper) {
    	helper.getColumnAndAction(component);
        helper.getOpenTasks(component);
    },
    
	handleRowAction : function(component, event, helper) {
		console.log("OpenTasksController handleRowAction selectedRowList" + component.get("v.selectedRowList"));
	},
    
    rowSelected : function(component, event, helper) {
        var selectedRows = event.getParam('selectedRows');
        component.set("v.selectedRowsCount", selectedRows.length);
	},
    
    handleNext : function(component, event, helper) {
        let pageNumber = component.get("v.pageNumber");
        component.set("v.pageNumber", pageNumber+1);
        helper.getOpenTasks(component);
    },
    
    handlePrev : function(component, event, helper) {
        let pageNumber = component.get("v.pageNumber");
        component.set("v.pageNumber", pageNumber-1);
        helper.getOpenTasks(component);
    },
    
    handleChangeStatus : function(component, event, helper) {
        helper.showModal(component);
    },
    
    closeModal : function(component, event, helper) {
        helper.closeModal(component);
    },
    
    saveTaskStatus : function(component, event, helper) {
        component.set('v.showModalWindow', false);
        helper.saveTaskStatus(component, event);
        helper.closeModal(component);
    }
})