@isTest
public class OT_dataTerminoTEST {

	@isTest
    public static void teste(){
        
        WorkOrder wo = new WorkOrder();
        wo.StartDate = DateTime.newInstance(2023, 1, 1);
        wo.Respons_vel_pela_negocia_o__c = '00531000006UzZsAAK';
        insert wo;
        
        wo.Status = 'SERVIÇO CONCLUÍDO';
        update wo;
        
    }
    
}