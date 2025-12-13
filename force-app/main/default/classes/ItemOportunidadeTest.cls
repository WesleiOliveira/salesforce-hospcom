@isTest(seeAllData=true)
public class ItemOportunidadeTest {
    @isTest
    private static void teste1(){
        ItemOportunidade.inserirPai('0066e00001fwWaYAAU', '01tU40000044eML','descricao', 1);
    }
    @isTest
    private static void teste2(){
        ItemOportunidade.inserirFilho('0066e00001fwWaYAAU', '01t5A000008Keul','descricao', 1);

}
    @isTest
    private static void teste3(){
        ItemOportunidade.ordena('[{"idProduto":"00kU400000Be9zE","posicaoProduto":1},{"idProduto":"00kU400000AVoJ8IAL","posicaoProduto":2}]');

}
    @isTest
    private static void teste4(){
    	ItemOportunidade.atualiza('00kU400000E3mT3IAJ', 11000, 2, 0, 'string descricao',1);

}
    @isTest
    private static void teste5(){
        ItemOportunidade.deleta('006U400000E57C9IAJ','00kU400000E3mT3IAJ');
        ItemOportunidade.trash();

}
}