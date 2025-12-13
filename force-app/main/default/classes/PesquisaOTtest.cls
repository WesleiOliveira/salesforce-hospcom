@isTest(seeAllData=true)
public class PesquisaOTtest {
	@isTest
    private static void teste(){
        WorkOrder OT = [SELECT ID, Status, Pesq_Satisfacao_Enviada__c FROM WorkOrder WHERE ID = '0WO6e000003rAcs'];
        
        Test.setMock(HttpCalloutMock.class, new MockPesquisaSatisf());
        update OT;
        // Call method to test.
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock. 
        PesquisaSatisf.enviarSERV(OT.Id);
    }
}