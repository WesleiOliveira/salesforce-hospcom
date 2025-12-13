@isTest(seeAllData=true)
public class AguardandoEntregaTest {
    @isTest
    private static void teste1(){
        Fornecedor__c pc = [SELECT ID FROM Fornecedor__c WHERE ID = 'a1b5A000002H2ch'];
        pc.Status_do_PC__c = 'Em andamento';
        update pc;
    }
}