global without sharing class BRSearchProductContr {

    @AuraEnabled
    public static list<Product2> searchProduct(
        decimal distance
    ){
        try {
            return [
                SELECT Id, Name, Distance__c, hasEquipmentCharge__c, hasInsuranceCharge__c, hasPollutionCharge__c
                FROM Product2     
                WHERE Distance__c <= : distance
                ORDER BY Name
                LIMIT 100
            ]; 
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    @AuraEnabled
    public static list<OrderItem> addOrderItems(
        list<Id> productIds
    ){
        try {
            map<Id, PricebookEntry> pbEntriesMap = BRUtils.getPriceBookEntries(new set<Id> (productIds));

// TODO: CHANGE THIS: every time a user clicks on 'Add to Basket' a new order is created, which is wrong!

            Order newOrder = new Order();
            newOrder.AccountId = BRUtils.ACCOUNT_ID;
            newOrder.EffectiveDate = System.today();
            newOrder.Status = 'Draft';
            newOrder.PriceBook2Id = BRUtils.STANDARD_PB_ID;
            insert newOrder;

            list<OrderItem> newOrderItems = new list<OrderItem>();
            for(PricebookEntry pbe : pbEntriesMap.Values()){
                OrderItem newLineItem = new OrderItem();
                newLineItem.OrderId = newOrder.id;
                newLineItem.Quantity = 1;
                newLineItem.UnitPrice = pbe.UnitPrice; 
                newLineItem.Product2Id = pbe.Product2Id;
                newLineItem.PricebookEntryId = pbe.Id;
                newOrderItems.add(newLineItem);
            }
            insert newOrderItems;
            
// re-query order items to get extra (charge) products + product names

            list<OrderItem> orderItems = [SELECT Id, Quantity, UnitPrice, Product2.Name, OrderId
                                        FROM OrderItem 
                                        WHERE OrderId = : newOrder.id];

            return orderItems;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    @AuraEnabled
    public static list<OrderItem> removeOrderItems(
        list<string> orderItemIds,
        string orderId
    ){
        try {
            list<OrderItem> orderItemsToDelete = [SELECT Id, Quantity, UnitPrice, Product2.Name, OrderId
                                        FROM OrderItem 
                                        WHERE Id IN : orderItemIds];
            if(orderItemsToDelete.size() > 0){
                delete orderItemsToDelete;
            }

            list<OrderItem> orderItems = [SELECT Id, Quantity, UnitPrice, Product2.Name, OrderId
                                        FROM OrderItem 
                                        WHERE OrderId = : orderId];
            return orderItems;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}