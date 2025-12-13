@isTest
private class AnaliseEquipamentoControllerTest {

    @isTest
    static void testSalvarAnalise_SemCamposPreenchidos() {
        // Cria o objeto vazio
        Analise_de_Equipamento__c analiseVazia = new Analise_de_Equipamento__c();

        Test.startTest();
       
            AnaliseEquipamentoController.salvarAnalise(analiseVazia);
         
        Test.stopTest();
    }
    @isTest
    private static void testa4(){
        AnaliseEquipamentoController.dummy('WERGSFC'); 
    }
}