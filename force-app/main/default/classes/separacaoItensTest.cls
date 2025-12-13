@isTest(seeAllData=true)
public class separacaoItensTest {
    
    @isTest
    public static void teste0(){
        separacaoItens.salvaComentario('comentario', '801U400000KyzWiIAJ');
    }
    
    @isTest
    public static void teste1(){
        User usuario = [SELECT ID FROM USER WHERE ID = '005i0000005d2fF'];
        System.runAs(usuario) {
            separacaoItens.salvaNS('[{"idItem":"802U4000013au1WIAQ","NumerosSerie":"XXXX,YYYY,ZZZ"},{"idItem":"802U4000013au1XIAQ","NumerosSerie":"XXXX,YYYY,ZZZ"}]');
        }
    }
}