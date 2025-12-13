@isTest(seeAllData=true)
public class PedidoPreenchimentoTest {
@isTest static void Teste2(){
    Order pedidoOriginal = [
      SELECT   Ordem_de_trabalho__c, AccountId, EffectiveDate, Status,  Necess_rio_Treinamento__c, Pedido_da_Linha_de_OPME__c, 
          Entrega_parcial__c, Prazo_de_entrega__c, Faturamento_Feito__c, Vendedor__c, Condicao_de_pagamento__c,
          Forma_de_pagamento2__c, Frete__c
      FROM  Order
      WHERE   Id = '8015A000001ZCgQQAW'
    ];
    Order pedidoNovo = pedidoOriginal.clone(false, false, false, false);
    pedidoNovo.RecordTypeId = Schema.getGlobalDescribe().get('Order').getDescribe().getRecordTypeInfosByName().get('Hospcom').getRecordTypeId();
    pedidoNovo.Pesq_Satisfacao_Enviada__c = true;
    insert pedidoNovo;
  }
@isTest static void Teste3(){
    Order pedidoOriginal = [
      SELECT   Ordem_de_trabalho__c, AccountId, EffectiveDate, Status,  Necess_rio_Treinamento__c, Pedido_da_Linha_de_OPME__c, 
          Entrega_parcial__c, Prazo_de_entrega__c, Faturamento_Feito__c, Vendedor__c, Condicao_de_pagamento__c,
          Forma_de_pagamento2__c, Frete__c
      FROM  Order
      WHERE   Id = '8016e00000769BJ'
    ];
    pedidoOriginal.Pesq_Satisfacao_Enviada__c = true;
    update pedidoOriginal;
    Order pedidoNovo = pedidoOriginal.clone(false, false, false, false);
    pedidoNovo.RecordTypeId = Schema.getGlobalDescribe().get('Order').getDescribe().getRecordTypeInfosByName().get('Hospcom').getRecordTypeId();
    pedidoNovo.Pesq_Satisfacao_Enviada__c = true;
    insert pedidoNovo;
  }
@isTest static void Teste4(){
    Order pedidoOriginal = [
      SELECT   Ordem_de_trabalho__c, AccountId, EffectiveDate, Status,  Necess_rio_Treinamento__c, Pedido_da_Linha_de_OPME__c, 
          Entrega_parcial__c, Prazo_de_entrega__c, Faturamento_Feito__c, Vendedor__c, Condicao_de_pagamento__c,
          Forma_de_pagamento2__c, Frete__c, QuoteId
      FROM  Order
      WHERE   Id = '8015A000002jdzK'
    ];
    pedidoOriginal.Pesq_Satisfacao_Enviada__c = true;
    update pedidoOriginal;
    Order pedidoNovo = pedidoOriginal.clone(false, false, false, false);
    pedidoNovo.RecordTypeId = Schema.getGlobalDescribe().get('Order').getDescribe().getRecordTypeInfosByName().get('Hospcom').getRecordTypeId();
    pedidoNovo.Pesq_Satisfacao_Enviada__c = true;
    insert pedidoNovo;
  }
@isTest static void Teste5(){
    Order pedidoOriginal = [
      SELECT   AccountId, EffectiveDate, Status,  Necess_rio_Treinamento__c, Pedido_da_Linha_de_OPME__c, 
          Entrega_parcial__c, Prazo_de_entrega__c, Faturamento_Feito__c, Vendedor__c, Condicao_de_pagamento__c,
          Forma_de_pagamento2__c, Frete__c, QuoteId, Demonstracao__c
      FROM  Order
      WHERE   Id = '8016e000005JQlS'
    ];
    pedidoOriginal.Pesq_Satisfacao_Enviada__c = true;
    update pedidoOriginal;
    Order pedidoNovo = pedidoOriginal.clone(false, false, false, false);
    pedidoNovo.RecordTypeId = Schema.getGlobalDescribe().get('Order').getDescribe().getRecordTypeInfosByName().get('Hospcom').getRecordTypeId();
    pedidoNovo.Pesq_Satisfacao_Enviada__c = true;
    insert pedidoNovo;
  }
    @isTest static void Teste6(){
    Order pedidoOriginal = [
      SELECT   AccountId, EffectiveDate, Status,  Necess_rio_Treinamento__c, Pedido_da_Linha_de_OPME__c, 
          Entrega_parcial__c, Prazo_de_entrega__c, Faturamento_Feito__c, Vendedor__c, Condicao_de_pagamento__c,
          Forma_de_pagamento2__c, Frete__c, QuoteId, Demonstracao__c
      FROM  Order
      WHERE   Id = '8016e000005JQlS'
    ];
    pedidoOriginal.Pesq_Satisfacao_Enviada__c = true;
    update pedidoOriginal;
    Order pedidoNovo = pedidoOriginal.clone(false, false, false, false);
    pedidoNovo.RecordTypeId = Schema.getGlobalDescribe().get('Order').getDescribe().getRecordTypeInfosByName().get('Hospcom').getRecordTypeId();
    pedidoNovo.Pesq_Satisfacao_Enviada__c = true;
    insert pedidoNovo;
  }
}