/**
* @author Jeisson Hernandez (JH)
* @description Apex class controller of LWC availableProducts
* @date 05-25-2021
* Version
* ---------------------------------------------------------------------------------------------------
* No.   Date        Author                  Description
* ---   -----       -------                 ---------------------------------------------------------
* 1.0   05-25-2020  Jeisson Hernandez(JH)   Class creation
*/
public with sharing class AvailableProductsController 
{
    /**
     * @description Method to get all available products for an order, order products are listed at the top. 
     * @param  strOrderId Order's Id.
     * @return List<AvailableProductsWrapper> List of Wrapper class with the available products sorted.
     */
    @AuraEnabled
    public static List<AvailableProductsWrapper> getAvailableProducts(String strOrderId) 
    {
        Map<String,AvailableProductsWrapper> mapAvailableProducts = new Map<String,AvailableProductsWrapper>();
        Map<String,AvailableProductsWrapper> mapOrderProducts = new Map<String,AvailableProductsWrapper>();
        //JH Available products are queried from PricebookEntry object and from 'Standard Price Book'
        for (PricebookEntry objPriceBookEntry : [SELECT Id,Name,Pricebook2Id,Pricebook2.Name,
                                                        Product2Id,Product2.ProductCode,
                                                        UnitPrice,UseStandardPrice 
                                                FROM PricebookEntry 
                                                WHERE Pricebook2.Name ='Standard Price Book' 
                                                ORDER BY Name]) 
        {
            AvailableProductsWrapper objAvailableProdWrapper = new AvailableProductsWrapper();
            objAvailableProdWrapper.name = objPriceBookEntry.Name;
            objAvailableProdWrapper.listPrice = objPriceBookEntry.UnitPrice;
            objAvailableProdWrapper.priceBookEntryId = objPriceBookEntry.Id;
            objAvailableProdWrapper.productId = objPriceBookEntry.Product2Id;
            mapAvailableProducts.put(objPriceBookEntry.Id,objAvailableProdWrapper);
        }
        //JH Order products are queried from OrderItem object using Order Id.
        for (OrderItem objOrderItem : [SELECT Product2Id,Product2.ProductCode,
                                              PricebookEntryId,OrderId,
                                              Product2.Name,UnitPrice
                                       FROM OrderItem
                                       WHERE OrderId =: strOrderId]) 
        {
            AvailableProductsWrapper objAvailableProdWrapper = new AvailableProductsWrapper();
            objAvailableProdWrapper.name = objOrderItem.Product2.Name;
            objAvailableProdWrapper.listPrice = objOrderItem.UnitPrice;
            objAvailableProdWrapper.priceBookEntryId = objOrderItem.PricebookEntryId;
            objAvailableProdWrapper.productId = objOrderItem.Product2Id;
            mapOrderProducts.put(objOrderItem.PricebookEntryId,objAvailableProdWrapper);
        }
        //JH From available products map are removed the order products
        for (String strPriceBookEntryId : mapOrderProducts.keySet())
        {
            if (mapAvailableProducts.containsKey(strPriceBookEntryId)) 
            {
                mapAvailableProducts.remove(strPriceBookEntryId);
            }
        }
        //JH To the order products map are added the available products in order to display order products at the top. 
        for (AvailableProductsWrapper objProdWrapper : mapAvailableProducts.values()) 
        {
            mapOrderProducts.put(objProdWrapper.priceBookEntryId,objProdWrapper);
        }
       
        return mapOrderProducts.values();
    }

    /**
     * @description Method to add a product to the order
     * @param  strOrderId          Order's Id
     * @param  strProductId        Product's Id
     * @param  strPricebookEntryId PricebookEntry's Id
     * @param  decUnitPrice        List Price's Product
     */
    @AuraEnabled
    public static void addProductToOrder(String strOrderId,String strProductId,String strPricebookEntryId,Decimal decUnitPrice)
    {
        try 
        {
            List<OrderItem> lstOrderItem = new List<OrderItem>();
            lstOrderItem = [SELECT Product2Id,Product2.ProductCode,Quantity,
                                   PricebookEntryId,OrderId,Product2.Name,UnitPrice
                                    FROM OrderItem
                                    WHERE OrderId =: strOrderId 
                                    AND   Product2Id =: strProductId LIMIT 1];
            if(!lstOrderItem.isEmpty())
            {
                lstOrderItem[0].Quantity +=1;
                update lstOrderItem[0];
            }
            else 
            {
                OrderItem objOrderItem = new OrderItem();
                objOrderItem.Product2Id = strProductId;
                objOrderItem.PricebookEntryId =strPricebookEntryId;
                objOrderItem.OrderId = strOrderId;
                objOrderItem.Quantity = 1;
                objOrderItem.UnitPrice = decUnitPrice;
                insert objOrderItem;
            }                                             
        } 
        catch (Exception e) 
        {
            System.debug('***Exception: addProductToOrder: ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    } 

    /** @description AvailableProductsWrapper Wrapper Class*/
    public class AvailableProductsWrapper
    {
        @auraEnabled public String name {get; set;}
        @auraEnabled public Decimal listPrice {get; set;}
        @auraEnabled public String priceBookEntryId {get; set;}
        @auraEnabled public String productId {get; set;}
    }
}