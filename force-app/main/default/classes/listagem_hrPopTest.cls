@isTest(seealldata = true)

public class listagem_hrPopTest {

    //LMD Sandbox: a0g530000062hwWAAQ
    //LMD Produção: a0g6e00000J4FLSAA3
    @isTest
    static void testListagem_hr() {
        // Crie um registro de PSQ__c para teste
        POP__c popRecord = new POP__c(
            Name = 'Test PSQ Record',
      C_digo_do_Documento__c = '1231232'
            
        );
        insert popRecord;

        // Crie alguns registros de HISTORICO_DE_REVISAO__c relacionados ao PSQ__c
        HISTORICO_DE_REVISAO__c historico1 = new HISTORICO_DE_REVISAO__c(
            Procedimento_Operacional_Padr_o__c = popRecord.Id
        );
        insert historico1;

        HISTORICO_DE_REVISAO__c historico2 = new HISTORICO_DE_REVISAO__c(
            Procedimento_Operacional_Padr_o__c = popRecord.Id
            
        );
        insert historico2;

        // Crie um objeto StandardController para o registro de PSQ__c
        ApexPages.StandardController controller = new ApexPages.StandardController(popRecord);

        // Crie uma instância da classe listagem_hr
        listagem_hrPop listagem = new listagem_hrPop(controller);

        // Execute o método listagem_hr(PSQ__c psq) da classe
        listagem.listagem_hr(popRecord);

      
    }
    
}