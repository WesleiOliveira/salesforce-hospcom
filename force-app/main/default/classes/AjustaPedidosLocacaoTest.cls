@IsTest(seeAllData=true)
public class AjustaPedidosLocacaoTest {
    
    @IsTest
    static void teste1(){
        AjustaPedidosLocacao.verificarEAtualizarValores('a1YU4000000lOF0MAM');   
        AjustaPedidosLocacao.dummy();   
    }
    
}