import { LightningElement,api } from 'lwc';
import getAvailableProducts from '@salesforce/apex/AvailableProductsController.getAvailableProducts';

const columns = [
    { label: 'Name', fieldName: 'name',sortable: true},
    {
        label: 'List Price',
        fieldName: 'listPrice',
        type: 'currency',
        sortable: true,
        cellAttributes: { alignment: 'left' },
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

    constructor() 
    {
        super();
        this.data = [];
        this.columns = columns;
        this.showLoadingSpinner =true;
        this.noResults = false;
        this.defaultSortDirection = 'asc';
        this.sortDirection = 'asc';
    
    }

    connectedCallback() 
    { 
        this.loadAvailableProducts();
    }


    loadAvailableProducts()
    {
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
                    record.productCode = availableProductsWrapper.productCode;
                    recs.push(record);
                });
                this.data = recs;
                console.log('**lstData',JSON.stringify(this.data));
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

    onHandleSort(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.data];

        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        this.data = cloneData;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
    }
}
