@isTest(SeeAllData=true)
public class OtAgendaTeste {
    
    
    static testMethod void OtAgendaTesteGeral1(){ 
        WorkOrder ot = new WorkOrder();
        ot = [
            SELECT	AccountId, AssetId, Acess_rios_que_Acompanham_o_Equipamento__c, ContactId, Subject, Data_Agendada_para_Servi_o__c, Data_Prevista_para_o_Fim_do_Servi_o__c, Categoria__c, Status, Priority, T_cnico_Respons_vel__c, Local_de_Atendimento__c, Description, RecordTypeId
           	FROM	WorkOrder
            //WHERE   Id = '0WO0q00000003Wi'
            WHERE	Id = '0WO5A000000XezU'
        ];        

        test.startTest();       
            ot.Status = 'AGUARDANDO ATENDIMENTO';
            update ot;
        test.stopTest();
    }
    
    
    static testMethod void OtAgendaTesteGeral2(){ 
        WorkOrder ot = new WorkOrder();
        ot = [
            SELECT	AccountId, AssetId, Acess_rios_que_Acompanham_o_Equipamento__c, ContactId, Subject, Data_Agendada_para_Servi_o__c, Data_Prevista_para_o_Fim_do_Servi_o__c, Categoria__c, Status, Priority, T_cnico_Respons_vel__c, Local_de_Atendimento__c, Description, RecordTypeId
           	FROM	WorkOrder
            //WHERE   Id = '0WO0q0000008iB1'
            WHERE	Id = '0WO5A000000XfDv'
        ];        
        
        test.startTest();       
            ot.Data_Prevista_para_o_Fim_do_Servi_o__c += 1;
            update ot;
        test.stopTest();
    }
    
    static testMethod void OtAgendaTesteGeral3(){ 
        WorkOrder ot = new WorkOrder();
        ot = [
            SELECT	AccountId, AssetId, Acess_rios_que_Acompanham_o_Equipamento__c, ContactId, Subject, Data_Agendada_para_Servi_o__c, Data_Prevista_para_o_Fim_do_Servi_o__c, Categoria__c, Status, Priority, T_cnico_Respons_vel__c, Local_de_Atendimento__c, Description, RecordTypeId
           	FROM	WorkOrder
            //WHERE   Id = '0WO0q0000008iB1'
            WHERE	Id = '0WO5A000000XfDv'
        ];        
        
        test.startTest();       
            ot.OwnerId = '00531000007iKqT';
            update ot;
        test.stopTest();
    }
    

}