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
    /**
     * @description Method to transform Order data in JSON format and 
     *              send request to external system
     * @param  strOrderId Order's Id
     * @return String     Response message from the external system
     */ 
    @AuraEnabled
    public static String getJSONRequest(String strOrderId)
    {
        try 
        {
            List<Order> lstOrder = [SELECT Id,Account.AccountNumber,OrderNumber,Type,Status,
                                        (SELECT Product2.Name,Product2.ProductCode,
                                                UnitPrice,Quantity 
                                        FROM OrderItems) 
                                    FROM Order
                                    WHERE Id =:strOrderId];
            DTOOrder objDTOOrder = new DTOOrder();
            //JH Serialize Order information in JSON format
            for (Order objOrder : lstOrder) 
            {
                
                objDTOOrder.accountNumber = objOrder.Account.AccountNumber;
                objDTOOrder.orderNumber = objOrder.OrderNumber;
                objDTOOrder.type = objOrder.Type;
                objDTOOrder.status = objOrder.Status;
                objDTOOrder.orderProducts = new List<DTOOrder.OrderProducts>();
                for (OrderItem objOrderItem : objOrder.OrderItems) 
                {
                    DTOOrder.OrderProducts objDTOOrderItem = new DTOOrder.OrderProducts();
                    objDTOOrderItem.name = objOrderItem.Product2.Name;
                    objDTOOrderItem.code = objOrderItem.Product2.ProductCode;
                    objDTOOrderItem.unitPrice = objOrderItem.UnitPrice;
                    objDTOOrderItem.quantity = (Integer)objOrderItem.Quantity;
                    objDTOOrder.orderProducts.add(objDTOOrderItem);
                }
            }
            String strBody = JSON.serialize(objDTOOrder);
            System.debug('@@Body= ' + strBody);
            //JH Call method to sent JSON Request
            return sentJSONRequest(strBody,strOrderId);
        }
        catch (Exception e) 
        {
            System.debug('***Exception: getJSONRequest: ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @description Method to send the request to external system
     * @param  strBody    Order information in JSON format
     * @param  strOrderId Order's Id
     * @return String     Response message from the external system
     */    
    @AuraEnabled
    public static String sentJSONRequest (String strBody, String strOrderId)
    {
        String strResponse = '';
        //Endpoint URL is stored in WebServicesConfiguration Custom Metadatatype
        WebServicesConfiguration__mdt objWSConf = WebServicesConfiguration__mdt.getInstance('OrderExternalSystem');
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(objWSConf.Endpoint__c);
        request.setMethod(objWSConf.Method__c);
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        // Set the body as a JSON object
        request.setBody(strBody);
        HttpResponse response = http.send(request);
        // Parse the JSON response
        if (response.getStatusCode() != 200) 
        {
            strResponse =System.label.WebServiceError + response.getStatusCode() + ' ' + response.getStatus();
        }
        else 
        {
            activateOrder (strOrderId);
            strResponse = 'OK';
        }
        System.debug('***strResponse: ' + strResponse);
        return strResponse;
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