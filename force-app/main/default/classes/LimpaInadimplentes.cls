@RestResource(urlMapping='/limpainadimp')
global class LimpaInadimplentes {
    @HttpGet
    global static void doPost() {
        List<Account> inadimplentes = [SELECT ID, Inadiplente__c FROM Account WHERE Inadiplente__c = true];
        
        for(Account inadimplente : inadimplentes){
            inadimplente.Inadiplente__c = false;
        }
        update inadimplentes;
    }
}