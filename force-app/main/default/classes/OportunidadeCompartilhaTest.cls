@isTest(seeAllData=true)
public class OportunidadeCompartilhaTest {
	@isTest
    static void testCreateOpp(){
        Opportunity opp = [SELECT ID FROM Opportunity WHERE ID = '0066e00001fwWaYAAU'];
        opp.Name = 'OPP Teste';
        opp.Data_e_hora_do_procedimento__c = system.now();
            
		Test.startTest();
        try{
            update opp;
        }
        catch(DmlException e){}
        Test.stopTest();
    }

    @isTest
    static void testDeleteOpp(){
        Opportunity opp = [SELECT ID FROM Opportunity WHERE ID = '0065A00000ipxfmQAA'];
            
		Test.startTest();
        try{
            delete opp;
        }
        catch(DmlException e){}
        Test.stopTest();
    }


}