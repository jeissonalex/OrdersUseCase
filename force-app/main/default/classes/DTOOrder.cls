/**
* @author Jeisson Hernandez (JH)
* @description DTO apex class to encapsulate the web service request for the order's external service web service
* @date 05-27-2021
* Version
* ---------------------------------------------------------------------------------------------------
* No.   Date        Author                  Description
* ---   -----       -------                 ---------------------------------------------------------
* 1.0   05-27-2020  Jeisson Hernandez(JH)   Class creation
*/
public class DTOOrder 
{
    public String accountNumber;
    public String orderNumber;
    public String type;
    public String status;
    public List<OrderProducts> orderProducts;

    public class OrderProducts 
    {
        public String name;
        public String code;
        public Double unitPrice;
        public Integer quantity;
    }
}