@isTest(seeAllData=true)
public class metaTest {
    
    @isTest
    static void setupTestData() {
        // Criando um usuário de teste como vendedor
        User vendedor =  [SELECT ID FROM USER WHERE Profile.Name LIKE 'Executivo%' AND IsActive = true LIMIT 1];
        
        // Criando registros de Goal__c
        List<Goal__c> goals = [SELECT ID FROM Goal__c WHERE Vendedor__c != null AND Ano__c = 2025];
    }
    
    @isTest
    static void testGetGoals() {
        // Pegando o vendedor criado no setup
        User vendedor =  [SELECT ID FROM USER WHERE Profile.Name LIKE 'Executivo%' AND IsActive = true LIMIT 1];
        
        Test.startTest();
        List<Goal__c> result = meta.getGoals(vendedor.Id);
        Test.stopTest();
        
    }
    
    @isTest
    static void testSaveGoals() {
        // Pegando o vendedor criado no setup
        User vendedor =  [SELECT ID FROM USER WHERE Profile.Name LIKE 'Executivo%' AND IsActive = true LIMIT 1];
        
        // Criando uma nova meta
        List<Goal__c> newGoals = new List<Goal__c>{
            new Goal__c(
                Vendedor__c = vendedor.Id,
                Linha__c = 'PMLS',
                Inicio__c = Date.newInstance(2025, 4, 1),
                Final__c = Date.newInstance(2025, 4, 30),
                Meta__c = 500
            )
                };
                    
                    Test.startTest();
        meta.saveGoals(newGoals);
        Test.stopTest();
        
        // Verificando se a meta foi salva
        List<Goal__c> savedGoals = [SELECT Id FROM Goal__c WHERE Vendedor__c = :vendedor.Id AND Linha__c = 'PMLS'];
        System.assertEquals(1, savedGoals.size(), 'A meta deveria ter sido salva');
    }
    
    @isTest
    static void testSaveGoals_EmptyList() {
        try {
            Test.startTest();
            meta.saveGoals(new List<Goal__c>());
            Test.stopTest();
        } catch (Exception e) {
        }
    }
}