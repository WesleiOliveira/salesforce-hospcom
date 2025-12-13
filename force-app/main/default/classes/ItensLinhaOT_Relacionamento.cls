public class ItensLinhaOT_Relacionamento {

    public static List<WorkOrderLineItem> itens(String idOt){
        
        List<WorkOrderLineItem> itensList = [SELECT ID,  Produto__c, LineItemNumber,  Nome_do_produto__c, Imagem__c, C_digo_do_Produto__c
                                            FROM WorkOrderLineItem
                                            WHERE WorkOrderId =:  idOt
                                            
                                            ];
        

        return itensList; 
        
    }
}