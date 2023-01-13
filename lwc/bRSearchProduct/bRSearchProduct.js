import { LightningElement, api, wire, track } from 'lwc';

import searchProduct from '@salesforce/apex/BRSearchProductContr.searchProduct';
import addOrderItems from '@salesforce/apex/BRSearchProductContr.addOrderItems';
import removeOrderItems from '@salesforce/apex/BRSearchProductContr.removeOrderItems';


export default class BRSearchProduct extends LightningElement {

    distance = 9999999;

    productsData;
    productsColumns = [
        { label: 'Name', fieldName: 'Name' },
        { label: 'Distance', fieldName: 'Distance'},
        { label: 'HasEquipmentCharge', fieldName: 'HasEquipmentCharge'}, 
        { label: 'HasInsuranceCharge', fieldName: 'HasInsuranceCharge'}, 
        { label: 'HasPollutionCharge', fieldName: 'HasPollutionCharge'}, 
    ];
    selectedProductIds = [];

    orderLinesData;
    orderLinesColumns = [
        { label: '#', fieldName: 'Number' },
        { label: 'Product Name', fieldName: 'ProductName'},
        { label: 'Qty', fieldName: 'Qty'},
    ];

    selectedOrderItemIds = [];
    orderId = '';

    constructor(){
        super();
    }


    handleDistanceChange(event){
        this.distance = event.detail.value;
    }


    handleDistanceSearch(event) {
        
        if(this.distance == undefined || this.distance == null || this.distance == ''){
            this.distance = 9999999;
        }
        searchProduct({
            distance: this.distance
        })
            .then(result => {                
                this.productsData = [];
                for (var key in result) {
                    this.productsData.push({
                        Id : result[key].Id,
                        Name: result[key].Name,
                        Distance: result[key].Distance__c,
                        HasEquipmentCharge: result[key].hasEquipmentCharge__c,
                        HasInsuranceCharge: result[key].hasInsuranceCharge__c,
                        HasPollutionCharge: result[key].hasPollutionCharge__c,                        
                    });
                }
                
            },
            error => {
                console.log('error: ' + JSON.stringify(error));
                alert(error.body.message);
            })
        
    }


    handleProductsSelected(event) {
        this.selectedProductIds = [];
        if(event.detail.selectedRows.length > 0){
            for (var key in (event.detail.selectedRows)) {
                this.selectedProductIds.push(event.detail.selectedRows[key].Id);
            }
        } 
    }


    handleAddToBasket(event) {
        addOrderItems({
            productIds: this.selectedProductIds
        })
        .then(result => {
            let num = 0;
            this.orderLinesData = [];
            for (var key in result) {
                num = num + 1;
                this.orderLinesData.push({
                    Id : result[key].Id,
                    Number: num,
                    Qty: result[key].Quantity,
                    ProductName: result[key].Product2.Name,
                });
                this.orderId = result[key].OrderId;
            }
        },
        error => {
            console.log('error: ' + JSON.stringify(error));
            alert(error.body.message);
        })
    }


    handleOrderLinesSelected(event) {
        this.selectedOrderItemIds = [];
        if(event.detail.selectedRows.length > 0){
            for (var key in (event.detail.selectedRows)) {
                this.selectedOrderItemIds.push(event.detail.selectedRows[key].Id);
            }
        } 
    }


    handleRemoveFromBasket(event) {
        removeOrderItems({
            orderItemIds: this.selectedOrderItemIds,
            orderId : this.orderId
        })
        .then(result => {

            console.log('result: ' + JSON.stringify(result)); 
            let num = 0;
            let tempData = [];
            for (var key in result) {
                num = num + 1;

                // TODO: WE NEED TO CHECK IF THE PRODUCT IS NON-DELITABLE (CHARGE PRODUCT)...

                tempData.push({
                    Id : result[key].Id,
                    Number: num,
                    Qty: result[key].Quantity,
                    ProductName: result[key].Product2.Name,
                });
            }
            this.orderLinesData = tempData; // 'refresh' data in lightning-datatable

            
            // deselect rows (added because of some visual bugs..)
            const LDBelement = this.template.querySelector('[data-id="orderLinesLDB"]');
            LDBelement.selectedRows = [];
            

        },
        error => {
            console.log('error: ' + JSON.stringify(error));
            alert(error.body.message);
        })
    }
}