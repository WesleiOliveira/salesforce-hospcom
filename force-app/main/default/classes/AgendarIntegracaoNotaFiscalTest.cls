@isTest
public class AgendarIntegracaoNotaFiscalTest {
    
    @isTest
    static void testExecute() {
        // Configura o Mock para as chamadas HTTP
        Test.setMock(HttpCalloutMock.class, new MockAgendaNF());
                
        // Inicia o teste de chamada do método
        Test.startTest();
        AgendarIntegracaoNotaFiscal.execute(null);
        Test.stopTest();
        
        // Verificações podem ser feitas para garantir que os dados foram inseridos corretamente
        List<Nota_buscada__c> notas = [SELECT Id, Chave_de_Acesso__c FROM Nota_buscada__c];
        System.assertEquals(1, notas.size());
        System.assertEquals('12345678901234567890123456789012345678901234', notas[0].Chave_de_Acesso__c);
    }
}