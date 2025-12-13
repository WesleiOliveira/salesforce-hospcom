@isTest(seealldata = true)

public class listagem_hrTest {

    //LMD Sandbox: a0g530000062hwWAAQ
    //LMD Produção: a0g6e00000J4FLSAA3
    @isTest
    static void testListagem_hr() {
        // Crie um registro de PSQ__c para teste
        PSQ__c psqRecord = new PSQ__c(
            Name = 'Test PSQ Record',
			C_digo_do_Documento__c = '1231232'
            
        );
        insert psqRecord;

        // Crie alguns registros de HISTORICO_DE_REVISAO__c relacionados ao PSQ__c
        HISTORICO_DE_REVISAO__c historico1 = new HISTORICO_DE_REVISAO__c(
            Procedimento_do_Sistema_de_Qualidade__c = psqRecord.Id
        );
        insert historico1;

        HISTORICO_DE_REVISAO__c historico2 = new HISTORICO_DE_REVISAO__c(
            Procedimento_do_Sistema_de_Qualidade__c = psqRecord.Id
            
        );
        insert historico2;

        // Crie um objeto StandardController para o registro de PSQ__c
        ApexPages.StandardController controller = new ApexPages.StandardController(psqRecord);

        // Crie uma instância da classe listagem_hr
        listagem_hr listagem = new listagem_hr(controller);

        // Execute o método listagem_hr(PSQ__c psq) da classe
        listagem.listagem_hr(psqRecord);

      
    }
    
}