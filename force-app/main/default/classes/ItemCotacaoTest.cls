@isTest(seeAllData=true)
public class ItemCotacaoTest {
    @isTest
    private static void teste1(){
        ItemCotacao.inserirPai('0Q06e000003YLhdCAG', '01t5A0000089eZj','descricao', 1);
    }
    @isTest
    private static void teste2(){
        ItemCotacao.deleta('0Q06e000003YLhdCAG','0QL6e00000Bw8UOGAZ');
    }
    @isTest
    private static void teste3(){
        ItemCotacao.inserirFilho('0Q06e000003YLhdCAG', '01t5A000008Keul','descricao', 5);
    }
    @isTest
    private static void teste4(){
        ItemCotacao.ordena('[{"idProduto":"0QL6e00000Bw8UOGAZ","posicaoProduto":1},{"idProduto":"0QL6e00000BwLIvGAN","posicaoProduto":2}]');
    }
    @isTest
    private static void teste5(){
        ItemCotacao.atualiza('0QL6e00000Bw8UOGAZ', 11000, 2, 0, 'string descricao', 1);
    }
    @isTest
    private static void teste6(){
        ItemCotacao.atualizaPai('0QL6e00000Bw8UOGAZ', 5);
    }
    @isTest
    private static void teste7(){
        try{
            ItemCotacao.atualiza('0QL6e00000JR8SEGA1', 11000, 2, 0, 'string descricao', 1);
        }
        catch(Exception e){
            
        }
    }
    @isTest    
    private static void teste8(){
        ItemCotacao.removerFilhos('0Q06e000003YLhdCAG', 710);
        ItemCotacao.trash();
    }
}