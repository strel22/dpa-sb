public with sharing class ContactController {
    @AuraEnabled(cacheable=true)
    public static List<Contact> getContacts() {
        list<Contact> contacts = new list<Contact>();
        contacts = [
            SELECT FirstName, LastName, Email
            FROM Contact
            WITH SECURITY_ENFORCED
            LIMIT 3
        ];
        
        system.System.debug('contacts.size()=' + contacts.size());
        if(contacts.size() == 3){
            throw new AuraHandledException('Forced error');
        }
        return contacts;
    }
}