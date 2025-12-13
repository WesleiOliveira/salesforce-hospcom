@isTest(seeAllData=true)

//aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
public class AssistenteComprasTest {
    @isTest
    private static void teste1(){
        AssistenteCompras.inserirFornecedores('a1e6e00001Oai3lAAB','001i00000085QYbAAM','001i000000dbfNdAAI,0015A00002HCt35QAD');
    }
    @isTest
    private static void teste2(){
        AssistenteCompras.inserirProdutos('a1e6e00001Oai3lAAB', '01t5A000008Koao', '', 'a1b6e000004E6xfAAC', 4);
        AssistenteCompras.inserirProdutosOpp('a1e6e00001Oai3lAAB', '01t5A000008Koao', '00kU40000057bWh-4', 'a1b6e000004E6xfAAC', 4);
        AssistenteCompras.inserirProdutos('a1e6e00001Oai3lAAB', '01t5A000008Koao', '8026e00000ESmTT-4', 'a1b6e000004E6xfAAC', 4);
        AssistenteCompras.inserirRequisicoes('a1e6e00001Oai3lAAB', 'a226e00000BmTS1', 'descricao teste', 'a1b6e000004E6xfAAC', 4);
        
    }
    @isTest
    private static void teste3(){
        AssistenteCompras.atualizaProdutos('a1d6e00000AlyWNAAZ', 3, 'UN', 'Teste');
        AssistenteCompras.removeProduto('a1d6e00000AlyG8AAJ');
    }
    @isTest
    private static void teste4(){
        AssistenteCompras.confirmaDestinacao('a1gU4000001nwOs', 1);
        AssistenteCompras.confirmaDestinacao('a1gU4000001nwOs', 3);
        
    }
    @isTest
    private static void teste5(){
        AssistenteCompras.destina('a1cU4000001IKvlIAG', '802U4000019eGDRIA2', 2);
        AssistenteCompras.destina('a1cU4000001IKvlIAG', '802U4000019eGDRIA2', 1);
        AssistenteCompras.destina('a1cU4000001IKvlIAG', '802U4000019eGDRIA2', 0);
        
    }
    @isTest
    private static void teste6(){
        AssistenteCompras.statusItemPC('a1c6e000009zPfE', 'CMP - AG. ENTREGA FORNECEDOR');
        AssistenteCompras.recebeEstoque('a1c6e000009zPfE', 2, '2022-11-11');
        AssistenteCompras.recebeEstoque('a1c6e000009zPfE', 3, '2022-11-11');
    }
    @isTest
    private static void teste7(){
        try{
            AssistenteCompras.recebeItemDestinado('a1c6e000009zPfE', 'a1g6e000006mbvD', 1, '2022-11-11');
            AssistenteCompras.recebeItemDestinado('a1c6e000009zPfE', 'a1g6e000006mbvD', 2, '2022-11-11');
        }
        catch(Exception e){
        }
    }
    @isTest
    private static void teste8(){
        
        List<String> itens = new List<String>{
            'a1c6e000009zOcF',
            'a1c6e000009vx0w',
            'a1c6e000009vx0r'
        };
        
        Map<String, Object> resultado = AssistenteCompras.atualizaStatusItensDoPedidoDeCompra(
            'a1b6e000004E6xf',
        'CMP - AG. ENTREGA FORNECEDOR',
        itens
            );
        
        String itensPC = 'a1c6e000009zPYVAA2,a1c6e000009zPfDAAU';
        String idprodutos = '01t6e000008CFpsAAG,01t6e000009aWUwAAM';
        AssistenteCompras.prazoRecebimento('802U400000WkQpS,802U400000WkuPl','2022-11-11','a1b6e000004EZ1bAAG');
        
        try{
            
            AssistenteCompras.deletaDestinacao('a1gU4000001nwOs');
        }
        catch(Exception e){
            
        }
    }
    
    @isTest
    private static void teste9(){
        string teste ='{recebimento:a076e00000mtLvqAAE, valor: 2003.3},{recebimento:a076e00000mtLvqAAE, valor: 200.10}';
        AssistenteCompras.geraPagamentos('005i0000005d2fF', teste);
    }
    @isTest
    private static void teste10(){
        try{
            AssistenteCompras.statusTodos('a1bU40000024X7VIAU', 'Em coleta');
            AssistenteCompras.cancelaItem('a1c6e000009zPfE');
            AssistenteCompras.cancelaItem('a1c6e000009zQH6');
        }
        catch(Exception e){
            
        }
    }
    @isTest
    private static void teste11(){
        try{
            AssistenteCompras.tomadaDePreco('[{"idProduto":"a1cU4000000Fs6XIAS","valorProduto":"150.00"};{"idProduto":"a1cU4000000Fs6YIAS","valorProduto":"132.00"};{"idProduto":"a1cU4000000Fs6ZIAS","valorProduto":"77.00"};{"idProduto":"a1cU4000000Fx6DIAS","valorProduto":"200.00"};{"idProduto":"a1cU4000000Fx6EIAS","valorProduto":"140.00"};{"idProduto":"a1cU4000000Fx6FIAS","valorProduto":"340.00"}]', '[{"idFornecedor":"a1bU4000001lyg5IAA","CondicaoPagamento":"10 X","DescricaoPagamento":"TESTE","FormaPagamento":"Dinheiro","Frete":"CIF","Prazo":"15","Transportadora":"001i000000sQiSFAA0","MoedaFrete":"BRL","ValorFrete":"5.346,00","TipoFrete":"CIF"},{"idFornecedor":"a1bU4000001evwfIAA","CondicaoPagamento":"05/30/60 Dias","DescricaoPagamento":"TESTE","FormaPagamento":"Boleto","Frete":"FOB","Prazo":"2024-05-31","Transportadora":"001i000000sQiSFAA0","MoedaFrete":"BRL","ValorFrete":"0,00","TipoFrete":"FOB"},{"idFornecedor":"a1bU4000001evwgIAA","CondicaoPagamento":"05/30 Dias","DescricaoPagamento":"TESTE","FormaPagamento":"Dinheiro","Frete":"FOB","Prazo":"6","Transportadora":"001i000000sQiSFAA0","MoedaFrete":"EUR","ValorFrete":"0,00","TipoFrete":"FOB"},{"idFornecedor":"a1bU4000001evwhIAA","CondicaoPagamento":"05/30 Dias","DescricaoPagamento":"TESTE","FormaPagamento":"Dinheiro","Frete":"FOB","Prazo":"20","Transportadora":"001i000000sQiSFAA0","MoedaFrete":"EUR","ValorFrete":"0,00","TipoFrete":"FOB"},{"idFornecedor":"a1bU4000001evwiIAA","CondicaoPagamento":"Entrada + 30/60/90/120 Dias","DescricaoPagamento":"TESTE","FormaPagamento":"Dinheiro","Frete":"FOB","Prazo":"22","Transportadora":"001i000000sQiSFAA0","MoedaFrete":"BRL","ValorFrete":"0,00","TipoFrete":"FOB"}]','a1eU400000053QHIAY','Justificativa');
        }
        catch(Exception e){
        }
    }
    @isTest
    private static void teste12(){
        try{
            AssistenteCompras.decisaoCompra('a1eU400000053QH','a1cU4000000Fs6X;a1cU4000000Fx6D');
        }
        catch(Exception e){
        }
    }
    @isTest
    private static void teste13(){
        AssistenteCompras.cloneFornecedorWithChildren('a1b6e000004E6xf','001i000000dbfNd');
    }
    @isTest
    private static void teste14(){
        AssistenteCompras.trash();
    }
}