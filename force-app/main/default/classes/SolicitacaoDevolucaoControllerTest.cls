@isTest
public class SolicitacaoDevolucaoControllerTest {
    
    @testSetup
    static void setupTestData() {
        // Criar registro de Solicitação de Devolução
        Solicita_o_de_devolu_o__c solicitacao = new Solicita_o_de_devolu_o__c();
        // Adicione campos obrigatórios se houver
        // solicitacao.Campo_Obrigatorio__c = 'valor';
        insert solicitacao;
        
        // Criar registros de Item da Solicitação de Devolução
        List<Item_da_Solicita_o_de_devolu_o__c> itens = new List<Item_da_Solicita_o_de_devolu_o__c>();
        
        for (Integer i = 0; i < 5; i++) {
            Item_da_Solicita_o_de_devolu_o__c item = new Item_da_Solicita_o_de_devolu_o__c();
            item.Solicita_o_de_devolu_o__c = solicitacao.Id;
            item.Quantidade__c = i + 1;         
            item.Status__c = 'Novo';
            // Adicione outros campos conforme necessário
            itens.add(item);
        }
        
        insert itens;
    }
    
    @isTest
    static void testConstrutorPadrao() {
        Test.startTest();
        SolicitacaoDevolucaoController controller = new SolicitacaoDevolucaoController();
        Test.stopTest();
        
        System.assertNotEquals(null, controller, 'Controller não deve ser nulo');
        System.assertEquals(0, controller.getTotalItens(), 'Deve ter 0 itens inicialmente');
    }
    
    @isTest
    static void testConstrutorComStandardController() {
        // Buscar a solicitação criada no setup
        Solicita_o_de_devolu_o__c solicitacao = [
            SELECT Id FROM Solicita_o_de_devolu_o__c LIMIT 1
        ];
        
        // Configurar StandardController
        ApexPages.StandardController stdController = new ApexPages.StandardController(solicitacao);
        
        Test.startTest();
        SolicitacaoDevolucaoController controller = new SolicitacaoDevolucaoController(stdController);
        Test.stopTest();
        
        System.assertNotEquals(null, controller, 'Controller não deve ser nulo');
        System.assertEquals(5, controller.getTotalItens(), 'Deve ter 5 itens');
        System.assertEquals(true, controller.getTemItens(), 'Deve ter itens');
    }
    
    @isTest
    static void testCarregarItens() {
        // Buscar a solicitação criada no setup
        Solicita_o_de_devolu_o__c solicitacao = [
            SELECT Id FROM Solicita_o_de_devolu_o__c LIMIT 1
        ];
        
        SolicitacaoDevolucaoController controller = new SolicitacaoDevolucaoController();
        controller.solicitacaoDevolucaoId = solicitacao.Id;
        
        Test.startTest();
        controller.carregarItens();
        Test.stopTest();
        
        System.assertEquals(5, controller.listaItens.size(), 'Deve retornar 5 itens');
        System.assertEquals(5, controller.getTotalItens(), 'Total deve ser 5');
        System.assertEquals(true, controller.getTemItens(), 'Deve ter itens');
    }
    
    @isTest
    static void testCarregarItensSemId() {
        SolicitacaoDevolucaoController controller = new SolicitacaoDevolucaoController();
        controller.solicitacaoDevolucaoId = null;
        
        Test.startTest();
        controller.carregarItens();
        Test.stopTest();
        
        System.assertEquals(0, controller.listaItens.size(), 'Deve retornar 0 itens');
        System.assertEquals(false, controller.getTemItens(), 'Não deve ter itens');
    }
    
    @isTest
    static void testGetTotalItens() {
        Solicita_o_de_devolu_o__c solicitacao = [
            SELECT Id FROM Solicita_o_de_devolu_o__c LIMIT 1
        ];
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(solicitacao);
        SolicitacaoDevolucaoController controller = new SolicitacaoDevolucaoController(stdController);
        
        Test.startTest();
        Integer total = controller.getTotalItens();
        Test.stopTest();
        
        System.assertEquals(5, total, 'Total deve ser 5');
    }
    
    @isTest
    static void testGetTemItens() {
        Solicita_o_de_devolu_o__c solicitacao = [
            SELECT Id FROM Solicita_o_de_devolu_o__c LIMIT 1
        ];
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(solicitacao);
        SolicitacaoDevolucaoController controller = new SolicitacaoDevolucaoController(stdController);
        
        Test.startTest();
        Boolean temItens = controller.getTemItens();
        Test.stopTest();
        
        System.assertEquals(true, temItens, 'Deve ter itens');
    }
}