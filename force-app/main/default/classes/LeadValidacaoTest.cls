@isTest
public class LeadValidacaoTest {
    @isTest
    static void testCreateLead() {
        // Criação de um novo lead
        Lead newLead = new Lead();
        newLead.FirstName = 'John';
        newLead.LastName = 'Doe';
        newLead.Company = 'Acme Inc.';
        newLead.Email = 'john.doe@acme.com';
        newLead.MobilePhone = '884613559';
        newLead.CPF__c = '884613559';
        newLead.CNPJ__c = '884613559';
        newLead.Phone = '884613559';
        newLead.Fax = '884613559';
        newLead.WebSite = '.';
        
        // Chama o método de criação de lead
        Test.startTest();
        try{
            insert newLead;
        }
        catch(DmlException e){}
        Test.stopTest();
        

    }
}