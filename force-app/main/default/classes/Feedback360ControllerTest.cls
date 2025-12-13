@isTest
public class Feedback360ControllerTest {
@isTest
    private static void save(){
        Test.startTest();
        Feedback360Controller obj = new Feedback360Controller();
        obj.Assunto='Teste';
        obj.Tipo ='Sugestão';
        obj.Descricao ='Teste';
        obj.salvar();
        Test.stopTest();
    }
    @isTest
    private static void save2(){
        Test.startTest();
        Feedback360Controller obj = new Feedback360Controller();
        obj.Assunto='';
        obj.Tipo ='Sugestão';
        obj.Descricao ='Teste';
        obj.salvar();
        Test.stopTest();
    }
}