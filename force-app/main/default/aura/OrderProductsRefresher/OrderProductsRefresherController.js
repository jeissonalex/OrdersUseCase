({
 	handleForceRefreshViewForLWC: function(component, event, helper) {
        component.find("orderProductsLWC").validateOrderStatus();
        component.find("orderProductsLWC").loadOrderProducts();
    },       
 	forceRefreshView: function(component, event, helper) 
    {
        let refresh = $A.get('e.force:refreshView');
        if (refresh) refresh.fire();
    },
})