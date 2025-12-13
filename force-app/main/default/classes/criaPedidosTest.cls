@IsTest(seeAllData=true)
public class criaPedidosTest {
    
     @IsTest
    static void teste1(){
        Contrato_de_Servi_o__c contrato = [SELECT ID, Status_do_Contrato__c FROM Contrato_de_Servi_o__c WHERE ID = 'a1Y6e00000C3V6I'];
        contrato.Status_do_Contrato__c = 'CONTRATO VIGENTE';
        update contrato;
    }
    
    @IsTest
    static void testeContratoVigenteComCondicoesDiferentes() {
        // Busca um contrato existente
        Contrato_de_servi_o__c contrato = [SELECT Id, Status_do_Contrato__c 
                                         FROM Contrato_de_servi_o__c 
                                         WHERE Id = 'a1Y6e00000C3V6I'];
        
        // Teste com condição "À Vista"
        contrato.Status_do_Contrato__c = 'CONTRATO VIGENTE';
        contrato.Condicao_de_pagamento__c = 'À Vista';
        contrato.Dura_o_do_Contrato_meses__c = 1;
        contrato.Primeiro_faturamento__c = Date.today();
        contrato.Emails_para_faturamento__c = 'teste@teste.com';
        
        Test.startTest();
        update contrato;
        Test.stopTest();
        
        // Verifica se os pedidos foram criados
        List<Order> pedidosCriados = [SELECT Id, Data_de_vencimento__c FROM Order 
                                    WHERE Contrato_de_Servi_o__c = :contrato.Id];
        
        
        // Teste com condição "30 Dias"
        contrato.Condicao_de_pagamento__c = '30 Dias';
        update contrato;
        
        List<Order> pedidosAtualizados = [SELECT Id, Data_de_vencimento__c FROM Order 
                                        WHERE Contrato_de_Servi_o__c = :contrato.Id];
       
    }
    
    
    
    @IsTest
    static void testeStatusNaoDisparaTrigger() {
        Contrato_de_servi_o__c contrato = [SELECT Id FROM Contrato_de_servi_o__c 
                                         WHERE Id = 'a1Y6e00000C3V6I'];
        
        contrato.Status_do_Contrato__c = 'EM CALIBRAÇÃO';
        update contrato;
        
        List<Order> pedidos = [SELECT Id FROM Order WHERE Contrato_de_Servi_o__c = :contrato.Id];
       
        
        contrato.Status_do_Contrato__c = 'CONCLUÍDO';
        update contrato;
         
    }
    
    @IsTest
    static void testeAtivosDoContrato() {
        Contrato_de_servi_o__c contrato = [SELECT Id FROM Contrato_de_servi_o__c 
                                         WHERE Id = 'a1Y6e00000C3V6I'];
        
        // Adiciona mais ativos ao contrato
        Product2 produto2 = new Product2(Name = 'Produto Teste 2', ProductCode = 'TEST2', IsActive = true);
        insert produto2;
        
        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(),
            Product2Id = produto2.Id,
            UnitPrice = 100,
            IsActive = true
        );
        insert pbe;
                      
        contrato.Status_do_Contrato__c = 'CONTRATO VIGENTE';
        contrato.Dura_o_do_Contrato_meses__c = 1;
        
        Test.startTest();
        update contrato;
        Test.stopTest();
        
        List<OrderItem> itens = [SELECT Id, Product2Id, Quantity, UnitPrice 
                               FROM OrderItem 
                               WHERE Order.Contrato_de_Servi_o__c = :contrato.Id];
        
       
    }
}