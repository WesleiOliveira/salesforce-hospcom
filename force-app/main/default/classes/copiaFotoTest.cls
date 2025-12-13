@isTest(seeAllData=true)
public class copiaFotoTest {
    @isTest
    public static void test1(){
        User usuario = [SELECT ID FROM User WHERE ID = '0056e00000CeZLP'];
        update usuario;
    }
}