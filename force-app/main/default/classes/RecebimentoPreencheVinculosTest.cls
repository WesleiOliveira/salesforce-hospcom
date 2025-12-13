@isTest(seeAllData=true)
public class RecebimentoPreencheVinculosTest {

    @isTest
    static void testRecebimentoPreencheVinculos() {
        // Criar registros de Recebimentos__c
        Recebimentos__c recebimento1 = new Recebimentos__c(
            Name = '12344',
            Numero_Pedido__c = '00015553',
            Numero_Faturamento__c = ''
        );

        
       insert recebimento1;
    }
    
    @isTest
    static void testRecebimentoPreencheVinculos2() {
        // Criar registros de Recebimentos__c
        Recebimentos__c recebimento1 = new Recebimentos__c(
            Name = '12344',
            Numero_Pedido__c = '00015553',
            Numero_Faturamento__c = '26040',
            Titulo_SAP__c = '1054',
            Vendedor_do_recebimento__c = 'Karlla Roberta Cunha Barbosa'
        );

        
       insert recebimento1;
        
        recebimento1.Vendedor_do_recebimento__c = 'Tatiane Oliveira';
        update recebimento1;
    }
}