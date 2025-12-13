@isTest(seeAllData=true)
public class enviaContratoFornecimentoTest {
    @isTest
    private static void testeCtrFornec(){        
        Test.setMock(HttpCalloutMock.class, new MockClicksign());
        // Call method to test. 
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock.
        string ide = 'a0fU4000009WDOL';
        Contrato_de_Fornecimento_de_Insumo__c contrato = [SELECT ID FROM Contrato_de_Fornecimento_de_Insumo__c WHERE ID =: ide];
        contrato.Acao_interna__c = true;
        contrato.Status__c = 'Aprovado';
        update contrato;
    }
}