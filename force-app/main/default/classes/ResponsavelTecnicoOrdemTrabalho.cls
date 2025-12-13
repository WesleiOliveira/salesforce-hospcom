@isTest(seeAllData=true)
public class ResponsavelTecnicoOrdemTrabalho {

    @isTest
    public static void test(){
        WorkOrder o = new WorkOrder();
    
        o.Id = '0WO6e000000bFtBGAU';
        o.T_cnico_Respons_vel__c = 'DEIBLY ARAUJO';
        update o;
        
        o.T_cnico_Respons_vel__c = 'NILSON TORQUATO';
        update o;        
    }
    
}