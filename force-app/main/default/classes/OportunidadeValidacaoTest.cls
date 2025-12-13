@isTest(seeAllData=true)
public class OportunidadeValidacaoTest {
	@isTest
    static void testCreateOpp(){
        Opportunity opp = new Opportunity();
        opp.Name = 'OPP Teste';
        opp.Data_e_hora_do_procedimento__c = system.now();
        opp.RecordTypeID = '0126e000001lAu7';
        opp.StageName = 'OPEN';
        opp.CloseDate = system.today() + 30;
        opp.Instrumentador__c = '005i0000005d2fF';
        opp.Instrumentador_2__c = '005i0000005d2fF';
        opp.Instrumentador_3__c = '005i0000005d2fF';
            
		Test.startTest();
        try{
            insert opp;
        }
        catch(DmlException e){}
        Test.stopTest();
    }
}