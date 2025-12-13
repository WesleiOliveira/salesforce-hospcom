@isTest(seeAllData=true)
public class PesquisaLocTest {
	@isTest
    private static void teste(){
        Contrato_de_Servi_o__c CL = [SELECT ID, Status__c, Pesq_Satisfacao_Enviada__c FROM Contrato_de_Servi_o__c WHERE ID = 'a1Y5A00000BWqeI'];
        
        Test.setMock(HttpCalloutMock.class, new MockPesquisaSatisf());
        update CL;
        // Call method to test.
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock. 
        PesquisaSatisf.enviarLOCAC(CL.Id);
    }
}