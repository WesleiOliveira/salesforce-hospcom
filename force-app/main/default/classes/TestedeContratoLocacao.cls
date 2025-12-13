@isTest(seeAllData=true)
private class TestedeContratoLocacao {
    
    // Teste de classes
    @isTest private static void Teste2(){
        Contrato_de_Servi_o__c testecontrato2 = new Contrato_de_Servi_o__c(
            Locador_a__c = '0015A00001yGbVZQA0', 
            Locat_rio_a__c = '0015A00001yGbVZQA0', 
            Cliente__c = '0015A00001yGbVZQA0',
            Internado_no_Hospital__c = '0015A00001yGbVZQA0',
            RecordTypeId = '0126e000001YbJL',                                //Teste:0127i000001xkgy Prod: 0126e000001YbJL
            Cl_usula_Primeira_Editada__c = false,
            Cl_usula_Segunda_Editada__c = false,
            Cl_usula_Terceira_Editada__c = false,
            Cl_usula_Quarta_Editada__c = false,
            Cl_usula_Quinta_Editada__c = false,
            Cl_usula_Sexta_Editada__c = false,
            Cl_usula_S_tima_Editada__c = false,
            Cl_usula_Oitava_Editada__c = false,
            Cl_usula_Nona_Editada__c = false,
            Cl_usula_D_cima_Editada__c = false,
            Cl_usula_D_cima_Primeira_Editada__c = false
      
        );
        insert testecontrato2;       
    } 
    @isTest private static void Teste1(){
        Contrato_de_Servi_o__c testecontrato = new Contrato_de_Servi_o__c(
            Locador_a__c = '0015A00001yGbVZQA0', 
            Locat_rio_a__c = '0015A00001yGbVZQA0', 
            Cliente__c = '0015A00001yGbVZQA0',
            Internado_no_Hospital__c = '0015A00001yGbVZQA0',
            RecordTypeId = '0125A000001Qydf',
            Cl_usula_Primeira_Editada__c = false,
            Cl_usula_Segunda_Editada__c = false,
            Cl_usula_Terceira_Editada__c = false,
            Cl_usula_Quarta_Editada__c = false,
            Cl_usula_Quinta_Editada__c = false,
            Cl_usula_Sexta_Editada__c = false,
            Cl_usula_S_tima_Editada__c = false,
            Cl_usula_Oitava_Editada__c = false,
            Cl_usula_Nona_Editada__c = false,
            Cl_usula_D_cima_Editada__c = false,
            Cl_usula_D_cima_Primeira_Editada__c = false,
            Contrato_de_AltoFluxo__c = 'SIM'
      
        );
        insert testecontrato;       
    }
    @isTest private static void Teste3(){
        Contrato_de_Servi_o__c testecontrato3 = new Contrato_de_Servi_o__c(
            Locador_a__c = '0015A00001yGbVZQA0', 
            Locat_rio_a__c = '0015A00001yGbVZQA0', 
            Cliente__c = '0015A00001yGbVZQA0',
            Internado_no_Hospital__c = '0015A00001yGbVZQA0',
            RecordTypeId = '0125A000001Qydf',
            Cl_usula_Primeira_Editada__c = false,
            Cl_usula_Segunda_Editada__c = false,
            Cl_usula_Terceira_Editada__c = false,
            Cl_usula_Quarta_Editada__c = false,
            Cl_usula_Quinta_Editada__c = false,
            Cl_usula_Sexta_Editada__c = false,
            Cl_usula_S_tima_Editada__c = false,
            Cl_usula_Oitava_Editada__c = false,
            Cl_usula_Nona_Editada__c = false,
            Cl_usula_D_cima_Editada__c = false,
            Cl_usula_D_cima_Primeira_Editada__c = false,
            Contrato_de_AltoFluxo__c = 'NÃO'
      
        );
        insert testecontrato3;       
    } 
    
    
}