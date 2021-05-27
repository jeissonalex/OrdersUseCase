import { LightningElement,api} from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
//Apex Methods
import getOrderProducts from '@salesforce/apex/OrderProductsController.getOrderProducts';
import isOrderActivated from '@salesforce/apex/OrderProductsController.isOrderActivated';
import activateOrder from '@salesforce/apex/OrderProductsController.activateOrder';

//Custom Labels
import NoResultsFound from "@salesforce/label/c.NoResultsFound";
import Success from "@salesforce/label/c.Success";
import OrderProductsLabel from "@salesforce/label/c.OrderProducts";
import OrderActivated from "@salesforce/label/c.OrderActivated";


//Constants
const columns = [
    { label: 'Name', fieldName: 'name',sortable: true},
    {
        label: 'Unit Price',
        fieldName: 'unitPrice',
        type: 'currency',
        sortable: true,
        cellAttributes: { alignment: 'left' },
    },
    {
        label: 'Quantity',
        fieldName: 'quantity',
        type: 'currency',
        sortable: true,
        cellAttributes: { alignment: 'left' },
    },    
    {
        label: 'Total Price',
        fieldName: 'totalPrice',
        type: 'currency',
        sortable: true,
        cellAttributes: { alignment: 'left' },
    },    
];
export default class OrderProducts extends LightningElement 
{

    @api recordId;

    data;
    columns;
    defaultSortDirection;
    sortDirection;
    sortedBy;
    showLoadingSpinner;
    noResults;
    orderId;
    blnOrderActivated;
    strNoresultsFound;
    strOrderProducts;
    strSuccessMessage;
    strSuccess;

    // Constructor of the LWC
    constructor() 
    {
        super();
        this.data = [];
        this.columns = columns;
        this.showLoadingSpinner =true;
        this.noResults = false;
        this.defaultSortDirection = 'asc';
        this.sortDirection = 'asc';
        this.strNoresultsFound = NoResultsFound;
        this.strOrderProducts = OrderProductsLabel;
        this.strSuccessMessage = OrderActivated;
        this.strSuccess = Success;
        this.blnOrderActivated = false;
    }

    connectedCallback() 
    { 
        this.validateOrderStatus();
        this.loadOrderProducts();
    }
    //Method to find out the status of the order
    @api
    validateOrderStatus()
    {
        this.showLoadingSpinner = true;
        isOrderActivated({strOrderId: this.recordId})
        .then(result => 
        {
            console.log('@@@result ',result);
            if(result)
            {
                this.blnOrderActivated = true;
                this.showLoadingSpinner = false;
            }
            else
            {
                this.blnOrderActivated = false;
                this.showLoadingSpinner = false; 
            }
        })
        .catch(error => 
        {
            this.noResults = true;
            this.error = error;
            this.showLoadingSpinner = false;
            console.log('@@@error ',error);
        });        
    }

    //Method to get the order products
    @api
    loadOrderProducts()
    {
        console.log('@@@loadOrderProducts ',this.recordId);
        this.showLoadingSpinner = true;
        getOrderProducts({strOrderId: this.recordId})
        .then(result => 
        {
            
            if(result.length > 0 )
            {
                this.noResults = false;
                let recs = [];
                result.forEach(orderProductsWrapper => {
                    let record = {};
                    record.name = orderProductsWrapper.name;
                    record.unitPrice = orderProductsWrapper.unitPrice;
                    record.quantity = orderProductsWrapper.quantity;
                    record.totalPrice = orderProductsWrapper.totalPrice;
                    recs.push(record);
                });
                this.data = recs;
                this.showLoadingSpinner = false;
            }
            else
            {
                this.noResults = true;
                this.showLoadingSpinner = false; 
            }
        })
        .catch(error => 
        {
            this.noResults = true;
            this.error = error;
            this.showLoadingSpinner = false;
            console.log('@@@error ',error);
        });        
    }    
    
    //Method to sort data table values
    sortBy(field, reverse, primer) 
    {
        const key = primer
            ? function(x) {
                  return primer(x[field]);
              }
            : function(x) {
                  return x[field];
              };

        return function(a, b) {
            a = key(a);
            b = key(b);
            return reverse * ((a > b) - (b > a));
        };
    }

    //Method to handle onsort event
    onHandleSort(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.data];

        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        this.data = cloneData;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
    }
    //Method to change the status of the Order to 'Activated'
    activateOrder(event)
    {
        activateOrder({strOrderId: this.recordId})
        .then(result => 
        {
            this.dispatchEvent(new ShowToastEvent({
                title: this.strSuccess,
                message: this.strSuccessMessage,
                variant: 'success'
            }),);
            this.forceRefreshView();
        })
        .catch(error => 
        {
            this.error = error;
            console.log('ERROR',JSON.stringify(error));
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: this.friendlyErrorMessage(error.body.message),
                variant: 'error'
            }),);  
        });        
    }
    
    //Method to sent an event to OrderProductsRefresher Aura component and refresh view
    //without reload the page
    forceRefreshView() 
    {
        this.dispatchEvent(new CustomEvent("forceRefreshView", { detail: null }));
    }    

    //Method to show error messages in a friendly way, for now only removes tags of 
    //custom validation exceptions but can be improved.
    friendlyErrorMessage(errorMessage)
    {
        if(errorMessage.includes("FIELD_CUSTOM_VALIDATION_EXCEPTION")){
            let errorSplit = errorMessage.split("FIELD_CUSTOM_VALIDATION_EXCEPTION, ");
            if(errorSplit != null && errorSplit[1] !== undefined){
                errorMessage = errorSplit[1].replace(/(?=\S*['_])([\[a-zA-Z'_\]]+)/g,"");
                errorMessage = errorMessage.slice(0, -2);
            }
        }
        return errorMessage;
    }    
}