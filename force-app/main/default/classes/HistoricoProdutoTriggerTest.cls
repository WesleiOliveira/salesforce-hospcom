@IsTest(seeAllData=true)
public class HistoricoProdutoTriggerTest {
    @IsTest
    public static void testHistoricoProdutoTrigger() {
        
        
        
        String objetoJSON = '{"StockKeepingUnit__c":"00034530","Linha__c":"OUTROS","ProductCode__c":"1265","Family__c":"OUTROS","Name":"TESssssTE","Tipo_do_Produto__c":"EQUIPAMENTO","Marca__c":"OUTROS","Num_Anvisa__c":"456789","Modelo__c":"OUTROS","IsActive__c":"true","Valor_de_Venda__c":"1000","Ativo_no_commerce__c":"true","Description__c":"teste","Observacoes__c":"d", "Produto__c":"01t5A000008BV2c" }';
        
      
        Id recordId = HistoricoProduto.criarHistorico(objetoJSON);
        
        List<Historico_do_produto__c> hpList = [SELECT Id, Status__c FROM Historico_do_produto__c WHERE Id = :recordId];
        
        if (!hpList.isEmpty()) {
            Historico_do_produto__c hp = hpList[0];
            
         
            System.debug('Status antes da alteração: ' +  hp.Status__c);
            hp.Status__c = 'APROVADO';
            
            update hp;
        } else {
            System.debug('Registro Historico_do_produto__c não encontrado.');
        }
    }
}