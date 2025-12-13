@isTest
private class LMDDetailControllerTest {
    @isTest
    static void testLMDDetailController() {
        L_M_D__c lmDetail = new L_M_D__c(T_tulo_do_Documento__c = 'Test Document', C_digo_do_Documento__c = '123');
        insert lmDetail;

        PageReference pageRef = Page.PDF_QUALIDADE_LMD;
        Test.setCurrentPage(pageRef);

        ApexPages.StandardController stdController = new ApexPages.StandardController(lmDetail);
        LMDDetailController controller = new LMDDetailController(stdController);

        List<Historico_de_Revisao__c> orderedHistRicos = controller.getOrderedHistRicos();

        System.assertEquals(0, orderedHistRicos.size());
    }
}