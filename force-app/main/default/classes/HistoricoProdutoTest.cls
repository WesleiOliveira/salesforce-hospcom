@IsTest
public class HistoricoProdutoTest {
    @IsTest
    static void testEnviarParaAprovacao() {
        
        String objetoJSON = '{"StockKeepingUnit__c":"00034530","Linha__c":"IMAGEM ULTRASSOM","ProductCode__c":"123456465","Family__c":"ALTO FLUXO","Name":"TESTE","Tipo_do_Produto__c":"EQUIPAMENTO","Marca__c":"ABC","Num_Anvisa__c":"456789","Modelo__c":"CATEGORIA A","IsActive__c":"true","Valor_de_Venda__c":"1000","Ativo_no_commerce__c":"true","Description__c":"","Observacoes__c":"d"}';
        String objetoJSONERROR = '{"StockKeepingUnit__c":"00034530","Linha__c":"asdasd","ProductCode__c":"123456465","Family__c":"ALTO FLUXO","Name":"TESTE","Tipo_do_Produto__c":"EQUIPAMENTO","Marca__c":"ABC","Num_Anvisa__c":"456789","Modelo__c":"CATEGORIA A","IsActive__c":"true","Valor_de_Venda__c":"1000","Ativo_no_commerce__c":"true","Description__c":"","Observacoes__c":"d"}';
        
        //HistoricoProduto historicoProduto = new HistoricoProduto();
        HistoricoProduto.criarHistorico(objetoJSON);
        
        
        //HistoricoProduto historicoProdutoAprovacao = new HistoricoProduto();
        HistoricoProduto.criarHistoricoComAprovacao(objetoJSON);
        
        
        try{
            // HistoricoProduto historicoProdutoERROR = new HistoricoProduto();
            HistoricoProduto.criarHistorico(objetoJSONERROR);
            
            //HistoricoProduto historicoProdutoAprovacaoERROR = new HistoricoProduto();
            HistoricoProduto.criarHistoricoComAprovacao(objetoJSONERROR);
        }
        catch(Exception e){
            
        }
    }
}