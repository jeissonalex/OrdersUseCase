import { LightningElement,api } from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
//Apex Methods
import getAvailableProducts from '@salesforce/apex/AvailableProductsController.getAvailableProducts';
import addProductToOrder from '@salesforce/apex/AvailableProductsController.addProductToOrder';
//Custom Labels
import NoResultsFound from "@salesforce/label/c.NoResultsFound";
import AvailableProductsLabel from "@salesforce/label/c.AvailableProducts";
import ProductAdded from "@salesforce/label/c.ProductAdded";
import Success from "@salesforce/label/c.Success";

//Constants
const actions = [
    { label: 'Add', name: 'add' },
];

const columns = [
    { label: 'Name', fieldName: 'name',sortable: true},
    {
        label: 'List Price',
        fieldName: 'listPrice',
        type: 'currency',
        sortable: true,
        cellAttributes: { alignment: 'left' },
    },
    {
        type: 'action',
        typeAttributes: { rowActions: actions },
    },
];

export default class AvailableProducts extends LightningElement 
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
    strNoresultsFound;
    strAvailableProducts;
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
        this.strAvailableProducts = AvailableProductsLabel;
        this.strSuccessMessage = ProductAdded;
        this.strSuccess = Success;
    }

    connectedCallback() 
    { 
        this.loadAvailableProducts();
    }

    //Method to get avaliable products sorted
    @api
    loadAvailableProducts()
    {
        this.showLoadingSpinner = true;
        getAvailableProducts({strOrderId: this.recordId})
        .then(result => 
        {
            
            if(result.length > 0 )
            {
                this.noResults = false;
                let recs = [];
                result.forEach(availableProductsWrapper => {
                    let record = {};
                    record.name = availableProductsWrapper.name;
                    record.listPrice = availableProductsWrapper.listPrice;
                    record.priceBookEntryId = availableProductsWrapper.priceBookEntryId;
                    record.productId = availableProductsWrapper.productId;
                    recs.push(record);
                });
                this.data = recs;
                //console.log('**lstData',JSON.stringify(this.data));
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

    //Method to handle row action of datatable
    handleRowAction(event) 
    {
        this.showLoadingSpinner = true;
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        if(actionName === 'add')
        {
            this.addProduct(row);
        }
    }
    
    //Method to add a product to the order
    addProduct(row)
    {
        addProductToOrder({strOrderId: this.recordId, strProductId : row.productId, strPricebookEntryId : row.priceBookEntryId, decUnitPrice : row.listPrice})
        .then(() => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title : this.strSuccess,
                    message : this.successMessage,
                    variant : 'success',
                }),
            )
            this.forceRefreshView();
            this.showLoadingSpinner = false;
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
            this.showLoadingSpinner = false;
        });        
    }
    
    //Method to sent an event to RefreshOderLRP Aura component and refresh view
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