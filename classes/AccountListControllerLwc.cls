public with sharing class AccountListControllerLwc {

    @AuraEnabled(cacheable=true)
    public static list<Account> queryAccountsByEmployeeNumber(Integer numberOfEmployees) {
        return [
            SELECT Name
            FROM Account
            WHERE NumberOfEmployees >= :numberOfEmployees
        ];
    }

    @AuraEnabled(cacheable=true)
    public static list<Account> queryAccountsByRevenue(Decimal annualRevenue) {
        return [
            SELECT Name
            FROM Account
            WHERE AnnualRevenue >= :annualRevenue
        ];
    }
}