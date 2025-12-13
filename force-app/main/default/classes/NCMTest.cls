@isTest(seeAllData=true)
public class NCMTest {
    @isTest
    private static void teste(){
        NCM.atualiza('NCM DE TESTE', 'a1HU4000002BSpR');
    }
    @isTest
    private static void teste2(){
        try{
            NCM.atualiza('AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA', 'a1HU4000002BSpR');
        }
        catch(Exception e){
            system.debug(e.getMessage());        
        }
    }
}