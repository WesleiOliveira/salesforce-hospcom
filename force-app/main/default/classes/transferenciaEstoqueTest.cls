@isTest(seeAllData=true)
public class transferenciaEstoqueTest {
    @isTest   
    public static void testa(){
        test.startTest();
        transferenciaEstoque.cria('a3YU400000000XtMAI', '01t6e000009ZPWc', 2, '301', '301');
        test.stopTest();
    }
}