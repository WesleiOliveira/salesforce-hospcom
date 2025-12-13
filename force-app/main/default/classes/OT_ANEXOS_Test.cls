@isTest(seeAllData=true)
public class OT_ANEXOS_Test {
    
	@isTest
    static void Teste(){
        
        try{
            WorkOrder ot = new Workorder();
            
            ot.id ='0WO6e000003gLIGGA2';
            ot.Status = 'FECHADO CONCLUÍDO';
            update ot;
            System.debug('status: ' + ot);
        }catch(Exception e){
            System.debug('ERRO: ' + e);
        }
        
    }
    
}