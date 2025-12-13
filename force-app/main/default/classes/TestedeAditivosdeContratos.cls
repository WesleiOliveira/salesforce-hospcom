@isTest(seeAllData=true)
private class TestedeAditivosdeContratos {
    @isTest static void TestedeAditivosdeContratos(){
        Aditivos_Contratuais__c testedeaditivocontratual = new Aditivos_Contratuais__c(
        Contrato_de_Servi_o_Relacionado__c = 'a1Y5A000006oSbn',
        Dura_o_Adicional__c = 5,
        Editar_Clausulas__c = false
            
            );
        insert testedeaditivocontratual;
        testedeaditivocontratual.Id = 'a1j5A0000070SUU';
        update testedeaditivocontratual;
    }
}