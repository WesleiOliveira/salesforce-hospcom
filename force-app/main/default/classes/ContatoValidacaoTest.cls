@isTest(seeAllData=true)
public class ContatoValidacaoTest {
    @isTest
    public static void teste(){
        Contact contato = [SELECT ID FROM CONTACT WHERE ID = '0036e00004D9g4x'];
        contato.Phone = '(62) 99177-7411';
        update contato;
    }
    public static void teste2(){
        Contact contato = [SELECT ID FROM CONTACT WHERE ID = '0036e00004D9g4x'];
        contato.Phone = '(6299177-7411';
        try{
            update contato;
        }
        catch(Exception e){
            
        }
    }
    public static void teste3(){
        Contact contato = [SELECT ID FROM CONTACT WHERE ID = '0036e00004D9g4x'];
        contato.MobilePhone = '(62)99177-7411';
        try{
            update contato;
        }
        catch(Exception e){
            
        }
    }
}