@isTest
public class LMD_CriaHistoricoTEST {
    
	@isTest
    static void TESTE() {
        L_M_D__c lmd = new L_M_D__c();
        lmd.Objetivo__c = 'TESTE';
        insert lmd;
        
        lmd.Objetivo__c = 'TESTES';
        update lmd;

    }

}