import { LightningElement, wire } from 'lwc';
import queryAccountsByRevenue from '@salesforce/apex/AccountListControllerLwc.queryAccountsByRevenue';

export default class AccountFinder extends LightningElement {
    
    annualRevenue = null;
    @wire(queryAccountsByRevenue, { annualRevenue: '$annualRevenue' }) accounts;

    handleChange(event) {
        this.annualRevenue = event.detail.value; 
        console.log(this.annualRevenue);
        console.log(this.accounts);
    }

    reset(){
        this.annualRevenue = null;
    }
}