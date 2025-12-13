@isTest(seeAllData=true)
public class criaPedidosInsumoTest {
@isTest
    private static void testa(){
        Contrato_de_Fornecimento_de_Insumo__c cfi = [SELECT ID FROM Contrato_de_Fornecimento_de_Insumo__c WHERE ID = 'a0fU4000009WDOLIA4'];
        cfi.Acao_interna__c = true;
        cfi.Status__c = 'Vigente';
        update cfi;
    }
}