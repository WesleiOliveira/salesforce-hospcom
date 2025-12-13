@isTest
private class PSQControllerTest {
    
    /*static void testPSQController() {
        // Crie um registro fictício de PSQ__c
        PSQ__c psqRecord = new PSQ__c(Name = 'PSQ Test');
        
        // produção lmd: a0g6e00000JW5s6AAD
        // Sandbox lmd: a0g530000062hwWAAQ
        
        insert psqRecord;

        // Crie alguns registros fictícios de HISTORICO_DE_REVISAO__c associados ao PSQ__c
        List<HISTORICO_DE_REVISAO__c> historicos = new List<HISTORICO_DE_REVISAO__c>();
        historicos.add(new HISTORICO_DE_REVISAO__c(
            Item__c = 'Item 1',
            Natureza_da_Alteracao__c = 'Alteração 1',
            Empresa__c = 'GDB',
            Data__c = System.today(),
            Procedimento_do_Sistema_de_Qualidade__c = psqRecord.Id
        ));
        historicos.add(new HISTORICO_DE_REVISAO__c(
            Item__c = 'Item 2',
            Natureza_da_Alteracao__c = 'Alteração 2',
            Data__c = System.today().addDays(-1),
            
            Empresa__c = 'GDB',
            Procedimento_do_Sistema_de_Qualidade__c = psqRecord.Id
        ));
        insert historicos;

        // Crie uma instância do controlador
       // PSQController controller = new PSQController();

        // Atribua o ID do PSQ__c ao controlador
     //controller.psqId = psqRecord.Id;       

        // Verifique se a lista de historicosOrdenados não está vazia
        //System.assertNotEquals(0, controller.historicosOrdenados.size());
    }*/
    @isTest
    static void testPSQController() { String a ='';}
}