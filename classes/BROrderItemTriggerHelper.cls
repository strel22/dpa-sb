public with sharing class BROrderItemTriggerHelper {

    public static void refreshOrderItems(list<OrderItem> orderItems, 
                                        string mode // just for testing purpose...
                                        ){ 

        if(!BRUtils.RUN_OI_TRIGGER){
            return;
        }
        BRUtils.RUN_OI_TRIGGER = false;

        try {
            Id orderId = orderItems[0].OrderId;

            // re-query all orderItems for this order
            list<OrderItem> orderItemsChargeOld = [SELECT Id, Product2Id 
                                                    FROM OrderItem 
                                                    WHERE OrderId = : orderId]; 

            set<Id> productIds = new set<Id> ();
            for(OrderItem oi : orderItemsChargeOld){
                productIds.add(oi.Product2Id);
            }

            // here we need to call the BRUtils.callChargeEndpoint(string productExtId, decimal qty)
            // but ... it's NOT the best practice to make a HTTP call in a trigger and in a loop for each product !!! 
            // I guess it should be called in async request with a message to the user 'calculating charges, please wait' etc 

            list<Product2> products = [SELECT Id, Name, Distance__c, hasEquipmentCharge__c, hasInsuranceCharge__c, hasPollutionCharge__c 
                                        FROM Product2 
                                        WHERE Id IN : productIds];

            decimal hasEquipmentChargeCounter = 0;
            decimal hasInsuranceChargeCounter = 0;
            decimal hasPollutionChargeCounter = 0;
            for(Product2 p : products){
                if(p.hasEquipmentCharge__c){
                    hasEquipmentChargeCounter = hasEquipmentChargeCounter + 1;
                }
                if(p.hasInsuranceCharge__c){
                    hasInsuranceChargeCounter = hasInsuranceChargeCounter + 1;
                }
                if(p.hasPollutionCharge__c){
                    hasPollutionChargeCounter = hasPollutionChargeCounter + 1;
                }
            }

            // delete old charged products

            set<Id> chargeProdOrderItemIds = new set<Id> ();
            for(OrderItem oi : orderItemsChargeOld){
                if(oi.Product2Id == BRUtils.hasEquipmentChargeProdId 
                || oi.Product2Id == BRUtils.hasInsuranceChargeProdId 
                || oi.Product2Id == BRUtils.hasPollutionChargeProdId)
                {
                    chargeProdOrderItemIds.add(oi.Id);
                }
            }
            list<OrderItem> chargeProdOrderItemToDelete = [SELECT Id 
                                                            FROM OrderItem 
                                                            WHERE Id IN : chargeProdOrderItemIds];
            delete chargeProdOrderItemToDelete;

            // create new charged products

            map<Id, PricebookEntry> chargePBEntriesMap = BRUtils.getPriceBookEntries(new set<Id>{
                BRUtils.hasEquipmentChargeProdId, BRUtils.hasInsuranceChargeProdId, BRUtils.hasPollutionChargeProdId });                  

            list<OrderItem> orderItemsChargeNew = new list<OrderItem> ();
            if(hasEquipmentChargeCounter > 0){
                OrderItem oi = new OrderItem();
                oi.OrderId = orderId;
                oi.Quantity = hasEquipmentChargeCounter;
                oi.UnitPrice = chargePBEntriesMap.get(BRUtils.hasEquipmentChargeProdId).UnitPrice;
                oi.PricebookEntryId = chargePBEntriesMap.get(BRUtils.hasEquipmentChargeProdId).Id;
                oi.Product2Id = chargePBEntriesMap.get(BRUtils.hasEquipmentChargeProdId).Product2Id;
                orderItemsChargeNew.add(oi);
            }
            if(hasInsuranceChargeCounter > 0){
                OrderItem oi = new OrderItem();
                oi.OrderId = orderId;
                oi.Quantity = hasInsuranceChargeCounter;
                oi.UnitPrice = chargePBEntriesMap.get(BRUtils.hasInsuranceChargeProdId).UnitPrice;
                oi.PricebookEntryId = chargePBEntriesMap.get(BRUtils.hasInsuranceChargeProdId).Id;
                oi.Product2Id = chargePBEntriesMap.get(BRUtils.hasInsuranceChargeProdId).Product2Id;
                orderItemsChargeNew.add(oi);
            }
            if(hasPollutionChargeCounter > 0){
                OrderItem oi = new OrderItem();
                oi.OrderId = orderId;
                oi.Quantity = hasPollutionChargeCounter;
                oi.UnitPrice = chargePBEntriesMap.get(BRUtils.hasPollutionChargeProdId).UnitPrice;
                oi.PricebookEntryId = chargePBEntriesMap.get(BRUtils.hasPollutionChargeProdId).Id;
                oi.Product2Id = chargePBEntriesMap.get(BRUtils.hasPollutionChargeProdId).Product2Id;
                orderItemsChargeNew.add(oi);
            }
            insert orderItemsChargeNew;
        } catch (Exception e) {
            // TODO: throw error or write to log...
        }
    }
}
