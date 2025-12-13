@isTest
private class ListagemIMEs_PMP_Test {

    @isTest
    static void testListagemIMEs() {
        
        ManutencaoPreventivadeApoio__c testeIME = new ManutencaoPreventivadeApoio__c();
            
        ApexPages.StandardController controller = new ApexPages.StandardController(testeIME);
        ListagemIMEs_PMP controllerExtension = new ListagemIMEs_PMP(controller);
        controllerExtension.listagemIMEs();

        List<ManutencaoPreventivadeApoio__c> imesList = controllerExtension.imesList;
        List<ManutencaoPreventivadeApoio__c> pmpList = controllerExtension.pmpList;

        List<Gest_o_de_Documentos__c> documentos = controllerExtension.documentos;
        
		
        System.debug('Lista: '  +  GestaoDocumentos.obterDocumentosVigentes());
        System.debug('Lista: '  +  documentos);
        System.debug('Lista: '  + imesList );
        System.debug('Lista: '  + pmpList );
    }
}