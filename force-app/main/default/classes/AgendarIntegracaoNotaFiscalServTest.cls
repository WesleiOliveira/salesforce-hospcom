@isTest
public class AgendarIntegracaoNotaFiscalServTest {
    @isTest
    static void testExecute() {
        // Configura o Mock para as chamadas HTTP
        Test.setMock(HttpCalloutMock.class, new MockAgendaNFS());
        
        // Inicia o teste de chamada do método
        Test.startTest();
        AgendarIntegracaoNotaFiscalServ.execute(null);
        Test.stopTest();
        
        // Verificações podem ser feitas para garantir que os dados foram inseridos corretamente
        List<Nota_buscada__c> notas = [SELECT Id, Chave_de_Acesso__c FROM Nota_buscada__c];
        System.assertEquals(1, notas.size());
        System.assertEquals('NFS52087072251102449000100000000000014624087671016084', notas[0].Chave_de_Acesso__c);
    }
}