@isTest(seeAllData=true)
public class ItemPedidoTest {
    @isTest
    private static void teste1(){
        ItemPedido.inserirPai('8016e00000740KyAAI', '01t5A0000089eZj','descricao', 1);
    }
    @isTest
    private static void teste2(){
        ItemPedido.inserirFilho('8016e00000740KyAAI', '01t5A000008Keul','descricao', 1);

}
    @isTest
    private static void teste3(){
        ItemPedido.ordena('[{"idProduto":"8026e00000DcOHBAA3","posicaoProduto":1},{"idProduto":"8026e00000DcOHD","posicaoProduto":2}]');

}
    @isTest
    private static void teste4(){
    	ItemPedido.atualiza('8026e00000DcOHD', 11000, 2, 'string descricao', 1);

}
    @isTest
    private static void teste5(){
        ItemPedido.deleta('802U40000113x8wIAA');

}
@isTest
    private static void teste6(){
    	ItemPedido.atualizaItem('8026e00000DcOHD', 2, null);

}
    
@isTest
    private static void teste7(){
    	ItemPedido.unificaValores('802U40000113x8wIAA');

}
}