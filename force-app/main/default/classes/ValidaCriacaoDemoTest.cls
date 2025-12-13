@isTest(seeAllData=true)
public class ValidaCriacaoDemoTest {
  
  @isTest static void Teste1(){
    Order pedidoOriginal = [
      SELECT   QuoteId, AccountId, EffectiveDate, Status,  Necess_rio_Treinamento__c, Pedido_da_Linha_de_OPME__c, 
          Entrega_parcial__c, Prazo_de_entrega__c, Faturamento_Feito__c, Vendedor__c
      FROM  Order
      WHERE   Id = '8016e0000094TLuAAM'
    ];
    Order pedidoNovo = pedidoOriginal.clone(false, false, false, false);
    pedidoNovo.RecordTypeId = Schema.getGlobalDescribe().get('Order').getDescribe().getRecordTypeInfosByName().get('Demonstração').getRecordTypeId();
    pedidoNovo.EffectiveDate = SYSTEM.today();
    pedidoNovo.Status = 'Rascunho';
      try{
          insert pedidoNovo;
      }
      catch(DmlException e){
          
      }

  }
}