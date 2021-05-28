/**
* @author Jeisson Hernandez (JH)
* @description CallOutMock for OrderProductsController apex class
* @date 05-28-2021
* Version
* ---------------------------------------------------------------------------------------------------
* No.   Date        Author                  Description
* ---   -----       -------                 ---------------------------------------------------------
* 1.0   05-28-2020  Jeisson Hernandez(JH)   Class creation
*/
@isTest
global class OrderHttpCalloutMock implements HttpCalloutMock 
{
    global HTTPResponse respond(HTTPRequest request) 
    {
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('');
        response.setStatusCode(200);
        return response; 
    }
}
