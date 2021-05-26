({
 	handleForceRefreshViewForLWC: function(component, event, helper) {
        component.find("availableProductsLWC").loadAvailableProducts();
    },       
 	forceRefreshView: function(component, event, helper) 
    {
        let refresh = $A.get('e.force:refreshView');
        if (refresh) refresh.fire();
    },
})