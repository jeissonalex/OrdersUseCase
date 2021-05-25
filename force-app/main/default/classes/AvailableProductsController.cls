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
        //JH Available products are queried from PricebookEntry object and from 'Standard' Pricebook
        for (PricebookEntry objPriceBookEntry : [SELECT Id,Name,Pricebook2.Name,
                                                        Product2Id,Product2.ProductCode,
                                                        UnitPrice,UseStandardPrice 
                                                FROM PricebookEntry 
                                                WHERE Pricebook2.Name ='Standard' 
                                                ORDER BY Name]) 
        {
            AvailableProductsWrapper objAvailableProdWrapper = new AvailableProductsWrapper();
            objAvailableProdWrapper.name = objPriceBookEntry.Name;
            objAvailableProdWrapper.listPrice = objPriceBookEntry.UnitPrice;
            objAvailableProdWrapper.productCode = objPriceBookEntry.Product2.ProductCode;
            mapAvailableProducts.put(objPriceBookEntry.Product2.ProductCode,objAvailableProdWrapper);
        }
        //JH Order products are queried from OrderItem object using Order Id.
        for (OrderItem objOrderItem : [SELECT Product2Id,Product2.ProductCode,
                                              OrderId,Product2.Name,UnitPrice
                                       FROM OrderItem
                                       WHERE OrderId =: strOrderId]) 
        {
            AvailableProductsWrapper objAvailableProdWrapper = new AvailableProductsWrapper();
            objAvailableProdWrapper.name = objOrderItem.Product2.Name;
            objAvailableProdWrapper.listPrice = objOrderItem.UnitPrice;
            objAvailableProdWrapper.productCode = objOrderItem.Product2.ProductCode;
            mapOrderProducts.put(objOrderItem.Product2.ProductCode,objAvailableProdWrapper);
        }
        //JH From available products map are removed the order products
        for (String strOrderProductCode : mapOrderProducts.keySet())
        {
            if (mapAvailableProducts.containsKey(strOrderProductCode)) 
            {
                mapAvailableProducts.remove(strOrderProductCode);
            }
        }
        //JH To the order products map are added the available products in order to display order products at the top. 
        for (AvailableProductsWrapper objProdWrapper : mapAvailableProducts.values()) 
        {
            mapOrderProducts.put(objProdWrapper.productCode,objProdWrapper);
        }
       
        return mapOrderProducts.values();
    }

    /**AvailableProductsWrapper Wrapper Class*/
    public class AvailableProductsWrapper
    {
        @auraEnabled public String name {get; set;}
        @auraEnabled public Decimal listPrice {get; set;}
        @auraEnabled public String productCode {get; set;}
    }
}
