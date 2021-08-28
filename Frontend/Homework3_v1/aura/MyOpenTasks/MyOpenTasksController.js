({
	init : function(component, event, helper) {
        let columns = [
            {label: 'Subject', fieldName: 'Subject', type: 'picklist'},
            {label: 'Status', fieldName: 'Status', type: 'picklist'},
            {label: 'Due date', fieldName: 'ActivityDate', type: 'data'},
            {label: 'Comments', fieldName: 'Description', type: 'text'}
        ];
		component.set('v.columns', columns);
        helper.getTasks(component);
	},
    
    updateSelectedText: function (component, event) {
        var selectedRows = event.getParam('selectedRows');
        console.log('MyOpenTasksController selectedRows=' + selectedRows);
        component.set('v.selectedRows', selectedRows);
        if (selectedRows.length > 0) {
            component.set('v.isButtonCompleteDisabled', false);
        } else {
            component.set('v.isButtonCompleteDisabled', true);
        }
    },
    
    handleComplete : function(component, event, helper) {
        let selectedRows = component.get("v.selectedRows");
        if (selectedRows.length > 0) {
            component.set('v.showModalWindow', true);
        }     
    },
    
    closeModal : function(component, event, helper) {
        helper.closeModal(component);
    },
    
    saveTaskStatus : function(component, event, helper) {
        let taskStatus = event.getParam("taskStatus");
        let selectedRows = component.get("v.selectedRows");
        helper.saveTaskStatus(component, selectedRows, taskStatus);
    }
})