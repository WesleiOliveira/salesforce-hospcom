@isTest
private class AprovacoesControllerTest {
	
    @isTest
    private static void teste1(){
        Test.startTest();
        AprovacoesController obj = new AprovacoesController();
        obj.aprovId = '04g5A0000024nE5QAI';
        obj.aprovarInd();
        obj.reprovarInd();
        obj.AprovarTodos();
        Test.stopTest();
    }
}