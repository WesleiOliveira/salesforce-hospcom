@isTest(seeAllData=true)
private class TestedeContratodeServicos {
    
    // Teste de classes
    
    @isTest static void TestedeContratodeServicos(){
        Contrato_de_Servi_o__c testecontrato = new Contrato_de_Servi_o__c(
            Locador_a__c = '0015A00001yGbVZQA0', //Teste:001W000000mOVSw Prod: 0015A00001yGbVZQA0
            Locat_rio_a__c = '0015A00001yGbVZQA0' //Teste:001W000000mOVSw Prod: 0015A00001yGbVZQA0
         
        );
        insert testecontrato;
        testecontrato.Locador_a__c = '001i00000085QYbAAM'; //Teste: 001W000000mLBpY Prod: 001i00000085QYbAAM 
        testecontrato.Manut_Corretiva_Apenas_Mao_de_Obra__c = true;
        testecontrato.Manut_Corretiva_Mao_de_Obra_e_Pecas__c = true;
        testecontrato.Manut_Preventiva_Apenas_Mao_de_Obra__c = true;
        testecontrato.Manut_Preventiva_Mao_de_Obra_e_Pecas__c=true;
        testecontrato.Calibra_o__c=true;
        testecontrato.Ensaio_de_Seguran_a_El_trica__c=true;
          testecontrato.RecordTypeId = '0125A000001Qydf'; 
        update testecontrato;
        
         testecontrato.RecordTypeId = '0125A000001QydL'; 
        update testecontrato;
    }   
}