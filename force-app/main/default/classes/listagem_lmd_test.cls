@isTest
public class listagem_lmd_test {

    //LMD Sandbox: 0015300000R5SUL
    //LMD Produção: 001i00000085QYb
    @isTest
    static void testListagem_hr() {
        
        L_M_D__c lmd = new L_M_D__c(Conta_Relacionada__c = '001i00000085QYb', Name = 'nome');
        insert lmd;

        PSQ__c psq = new PSQ__c(L_M_D__c = lmd.Id, Status__c = 'Em vigência');
        insert psq;

        ApexPages.StandardController controller = new ApexPages.StandardController(lmd);

        listagem_lmd listagem = new listagem_lmd(controller);

        listagem.listagem_lmd(lmd);

    }
}