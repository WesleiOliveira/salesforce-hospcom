@isTest
public class ChecklistControllerTest {
    @isTest
    static void testChecklistController() {
        // Criando um exemplo de JSON válido
        String jsonExemplo = '{"titulo":"Checklist de Instalação","secoes":[{"titulo":"Dados do Cliente","campos":[{"label":"Nome","tipo":"texto","valor":"Empresa X"},{"label":"Data","tipo":"data","valor":"2025-04-29"}]}]}';
        
        Checklist_Preenchido__c checklist = new Checklist_Preenchido__c(
            Name = 'Teste Checklist',
            JSON_resposta__c = jsonExemplo
        );
        insert checklist;
        
        Test.startTest();
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(checklist);
        ChecklistController controller = new ChecklistController(stdCtrl);
        
        System.assertEquals('Checklist de Instalação', controller.getTitulo());
        System.assertEquals(1, controller.getSecoes().size());
        System.assertEquals('Dados do Cliente', controller.getSecoes()[0].titulo);
        System.assertEquals(2, controller.getSecoes()[0].campos.size());
        Test.stopTest();
    }
    @isTest
    static void testSalvar() {
        Test.startTest();
        ChecklistController.salva('0WOU4000000W9GT', 'a3rU4000000KFpJ', 'json');
        Test.stopTest();
        
    }
}