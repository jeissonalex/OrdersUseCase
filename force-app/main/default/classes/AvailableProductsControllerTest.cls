/**
* @author Jeisson Hernandez (JH)
* @description Test Apex class controller of AvailableProductsController apex class
* @date 05-27-2021
* Version
* ---------------------------------------------------------------------------------------------------
* No.   Date        Author                  Description
* ---   -----       -------                 ---------------------------------------------------------
* 1.0   05-27-2020  Jeisson Hernandez(JH)   Class creation
*/
@isTest
private class AvailableProductsControllerTest 
{
    @testSetup 
    static void setup() 
    {
        // Insert Account

        Account objAccount = new Account();
        objAccount.Name = 'Test Account';
        insert objAccount;

        // Insert Product 1
        Product2 objProduct1 = new Product2();
        objProduct1.Name = 'Test Product 1';
        objProduct1.Description='Test Product Entry 1';
        objProduct1.productCode = 'ABC';
        objProduct1.isActive = true;
        insert objProduct1;
        
        // Insert Product 2
        Product2 objProduct2 = new Product2();
        objProduct2.Name = 'Test Product 2';
        objProduct2.Description='Test Product Entry 2';
        objProduct2.productCode = 'DEF';
        objProduct2.isActive = true;
        insert objProduct2;


        Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 objPricebook2 = new Pricebook2();
        objPricebook2.Id = pricebookId;
        objPricebook2.Name = 'Standard Price Book';
        update objPricebook2;

        // Insert PricebookEntry 1
        PricebookEntry objStandardPrice1 = new PricebookEntry();
        objStandardPrice1.Pricebook2Id = pricebookId;
        objStandardPrice1.Product2Id = objProduct1.Id;
        objStandardPrice1.UnitPrice = 1000;
        objStandardPrice1.IsActive = true;
        objStandardPrice1.UseStandardPrice = false;
        insert objStandardPrice1;

        // Insert PricebookEntry 2
        PricebookEntry objStandardPrice2 = new PricebookEntry();
        objStandardPrice2.Pricebook2Id = pricebookId;
        objStandardPrice2.Product2Id = objProduct2.Id;
        objStandardPrice2.UnitPrice = 2000;
        objStandardPrice2.IsActive = true;
        objStandardPrice2.UseStandardPrice = false;
        insert objStandardPrice2;

        // Insert Order
        
        Order objOrder = new Order();
        objOrder.Name = 'Test Order ';
        objOrder.Status = 'Draft';
        objOrder.EffectiveDate = system.today();
        objOrder.EndDate = system.today() + 4;
        objOrder.AccountId = objAccount.id;
        objOrder.Pricebook2Id =  pricebookId;       
        insert objOrder;
        
        // Insert Order Item

        OrderItem objOrderItem1 = new OrderItem();
        objOrderItem1.OrderId = objOrder.id;
        objOrderItem1.Quantity = 1;
        objOrderItem1.UnitPrice = 1000;
        objOrderItem1.Product2id = objProduct1.id;
        objOrderItem1.PricebookEntryId=objStandardPrice1.id;
        insert objOrderItem1;
    }

    @isTest
    static void testGetAvailableProducts()
    {
        Order objOrder = [SELECT Id FROM Order LIMIT 1];
        Test.startTest();
        List<AvailableProductsController.AvailableProductsWrapper> lstAvailableProducts = AvailableProductsController.getAvailableProducts(objOrder.Id);
        System.assertEquals(2, lstAvailableProducts.size(),'AMOUNT OF AVAILABLE PRODUCTS ISNOT CORRECT');
        Test.stopTest();
    }


    @isTest
    static void testAddNewProductToOrder()
    {
        Order objOrder = [SELECT Id FROM Order LIMIT 1];
        PricebookEntry objPricebookEntry2 = [SELECT Id,Product2Id,UnitPrice FROM PricebookEntry WHERE Product2.Name ='Test Product 2' LIMIT 1];
        Test.startTest();
        AvailableProductsController.addProductToOrder(objOrder.Id,objPricebookEntry2.Product2Id,objPricebookEntry2.Id,objPricebookEntry2.UnitPrice);       
        List<OrderItem> lstOrderItems = [SELECT Product2Id,Product2.ProductCode,
                                              PricebookEntryId,OrderId,
                                              Product2.Name,UnitPrice
                                         FROM OrderItem
                                         WHERE OrderId =: objOrder.Id];
        System.assertEquals(2, lstOrderItems.size(),'AMOUNT OF ORDER PRODUCTS ISNOT CORRECT');
        Test.stopTest();
    }

    @isTest
    static void testAddExistintProductToOrder()
    {
        Order objOrder = [SELECT Id FROM Order LIMIT 1];
        PricebookEntry objPricebookEntry1 = [SELECT Id,Product2Id,UnitPrice FROM PricebookEntry WHERE Product2.Name ='Test Product 1' LIMIT 1];
        Test.startTest();
        AvailableProductsController.addProductToOrder(objOrder.Id,objPricebookEntry1.Product2Id,objPricebookEntry1.Id,objPricebookEntry1.UnitPrice);       
        List<OrderItem> lstOrderItem = [SELECT Product2Id,Product2.ProductCode,
                                              PricebookEntryId,OrderId,
                                              Product2.Name,UnitPrice,Quantity
                                         FROM OrderItem
                                         WHERE OrderId =: objOrder.Id
                                         AND PricebookEntryId =:objPricebookEntry1.Id 
                                         AND Quantity =2];
        System.assertEquals(2, lstOrderItem[0].Quantity,'QUANTITY OF EXISTING PRODUCTS OF THE ORDER ISNOT CORRECT');
        Test.stopTest();
    }

    @isTest
    static void testAddProductToOrderException()
    {
        PricebookEntry objPricebookEntry2 = [SELECT Id,Product2Id,UnitPrice FROM PricebookEntry WHERE Product2.Name ='Test Product 2' LIMIT 1];
        Test.startTest();
        try 
        {
            AvailableProductsController.addProductToOrder(null,objPricebookEntry2.Product2Id,objPricebookEntry2.Id,objPricebookEntry2.UnitPrice);       
        }
        catch (Exception e) 
        {
            System.assert(e.getMessage() =='Script-thrown exception', 'NULL ORDER WAS FOUND');
        }          
        Test.stopTest();
    }
}