/**
* @author Jeisson Hernandez (JH)
* @description Apex class controller of LWC orderProducts
* @date 05-26-2021
* Version
* ---------------------------------------------------------------------------------------------------
* No.   Date        Author                  Description
* ---   -----       -------                 ---------------------------------------------------------
* 1.0   05-26-2020  Jeisson Hernandez(JH)   Class creation
*/
public with sharing class OrderProductsController 
{
    /**
     * @description Method that indicates if the order is activated or not
     * @param  strOrderId Order's Id
     * @return Boolean    true=Order Activated false=Order Not Activated
     */
    @AuraEnabled
    public static Boolean isOrderActivated (String strOrderId)
    {
        try 
        {
            String strStatus = [SELECT Status FROM Order WHERE Id =: strOrderId].Status;
            Boolean isOrderActivated = strStatus =='Activated' ? true : false;
            return isOrderActivated;
        }
        catch (Exception e) 
        {
            System.debug('***Exception: isOrderActivated: ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }
    /**
     * @description Method to change the status of the Order to 'Activated'
     * @param  strOrderId Order's Id
     */
    @AuraEnabled
    public static void activateOrder (String strOrderId)
    {
        try 
        {        
            Order objOrder = [SELECT Id,Status FROM Order WHERE Id =: strOrderId];
            objOrder.Status = 'Activated';
            update objOrder;
        }
        catch (Exception e) 
        {
            System.debug('***Exception: getOrderProducts: ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }                 
    }
    /**
     * @description Method to get the products of the order
     * @param  strOrderId Order's Id
     * @return List<OrderProductsWrapper> List with the order products
     */
    @AuraEnabled
    public static List<OrderProductsWrapper> getOrderProducts(String strOrderId) 
    {
        try 
        {        
            List<OrderProductsWrapper> lstOrderProducts = new List<OrderProductsWrapper>();
            for (OrderItem objOrderItem : [SELECT OrderId,Quantity,Product2.Name,
                                                UnitPrice,TotalPrice
                                        FROM OrderItem
                                        WHERE OrderId =: strOrderId]) 
            {
                OrderProductsWrapper objOrderProductsWrapper = new OrderProductsWrapper();
                objOrderProductsWrapper.name = objOrderItem.Product2.Name;
                objOrderProductsWrapper.unitPrice = objOrderItem.UnitPrice;
                objOrderProductsWrapper.quantity = objOrderItem.Quantity;
                objOrderProductsWrapper.totalPrice = objOrderItem.TotalPrice;
                lstOrderProducts.add(objOrderProductsWrapper);
            }
            return lstOrderProducts;
        }
        catch (Exception e) 
        {
            System.debug('***Exception: getOrderProducts: ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }        
    }

    /** @description OrderProductsWrapper Wrapper Class*/
    public class OrderProductsWrapper
    {
        @auraEnabled public String name {get; set;}
        @auraEnabled public Decimal unitPrice {get; set;}
        @auraEnabled public Decimal quantity {get; set;}
        @auraEnabled public Decimal totalPrice {get; set;}
    }    
}