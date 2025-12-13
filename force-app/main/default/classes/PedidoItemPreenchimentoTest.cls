@isTest(seeAllData=true)
public class PedidoItemPreenchimentoTest {
    @isTest static void teste1(){
        OrderItem PP = [SELECT Id, Status__c FROM OrderItem WHERE ID = '802U400000pSplO'];
        PP.Status__c = 'OPR - ANALISE DE COMPRA';
        update PP;
        PP.Status__c = 'CMP - AG. ENTREGA FORNECEDOR';
        update PP;
        PP.Status__c = 'Recebido Fornecedor';
        update PP;
		PP.Status__c = 'Atendido';
        update PP;
        PP.Status__c = 'Cancelado';
        update PP;
    } 
    @isTest static void teste2(){
        OrderItem PP = [SELECT Id, Status__c FROM OrderItem WHERE ID = '8026e00000Dt1lD'];
        PP.Status__c = 'OPR - ANALISE DE COMPRA';
        update PP;
        PP.Status__c = 'CMP - AG. ENTREGA FORNECEDOR';
        update PP;
        PP.Status__c = 'Recebido Fornecedor';
        update PP;
		PP.Status__c = 'Entregue Cliente';
        update PP;
        PP.Status__c = 'Cancelado';
        update PP;
    }
}