public with sharing class BRUtils {
    
    // TODO: Move to Custom Metadata
    public static Id hasEquipmentChargeProdId = '01t7R000009fDorQAE'; 
    public static Id hasInsuranceChargeProdId = '01t7R000009fDpBQAU';
    public static Id hasPollutionChargeProdId = '01t7R000009fDslQAE';
    public static string STANDARD_PB_ID = '01s7R000005ISl5QAG'; // TODO: CHANGE THIS !!!
    public static string ACCOUNT_ID = '0017R00002srF44QAE'; // TODO: CHANGE THIS !!! 
    public static string CHARGE_ENDPOINT = 'https://85e779eb-089e-43cf-9dc4-f84c5333cad9.mock.pstmn.io'; // my own mock service...
    public static boolean RUN_OI_TRIGGER = true;


    public static map<Id, PricebookEntry> getPriceBookEntries(set<Id> productIds){
  
        map<Id, PricebookEntry> pbMap = new map<Id, PricebookEntry>();
        try{   
            list<PricebookEntry> pbEntries = [SELECT Id, Product2Id, UnitPrice 
                                                FROM PricebookEntry 
                                                WHERE Product2Id in : productIds AND Pricebook2Id = : STANDARD_PB_ID];

            for(PricebookEntry pbe : pbEntries){
                pbMap.put(pbe.Product2Id, pbe);
            }                                            
        }catch(Exception e){
            // write to log or so...
        }
        return pbMap;    
    }


// at the moment this method returns empty set if there is no charges and if the method fails ... 
// TODO : distinguish these cases (...for example add '#SUCCESS#' or '#ERROR#' values to the set...)

    public static set<string> callChargeEndpoint(string productExtId, decimal qty){

        set<string> chargesToReturn = new set<string>();
        try{            
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(CHARGE_ENDPOINT);
            request.setMethod('POST');
            request.setBody(
                '[' + 
                '{' + 
                '"product": "' + productExtId + '",' + 
                '"quantity": "' + qty + '"' + 
                '}' + 
                ']');
            HttpResponse response = http.send(request);
            Map<String, Object> chargesMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            Object charges = chargesMap.get('charges');
            list<Object> charges2 = (list<Object>) charges;
            for(Object s : charges2){
                chargesToReturn.add((string)s);
            }
        }catch(Exception e){
            // write to log or so...
        }
        return chargesToReturn;
    }
}
