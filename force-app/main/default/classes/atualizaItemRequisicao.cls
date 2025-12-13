public class atualizaItemRequisicao {
   @AuraEnabled
    public static void atualizaItem(string idsItens, string statusAtual){
        
        String idsItensQ = idsItens ;
        
        List<String> lstIds =   idsItensQ.split(',');//separa cada id de itens e adciona em uma lista.
        
        List <Item_Requerido__c> itensParaAtualizar = [SELECT name, id ,Status_do_Item__c , Requisi_o_Interna_Relacionada__c, Quantidade__c FROM Item_Requerido__c WHERE id IN :lstIds ];
        
        
        
        for(Integer i = 0; i < itensParaAtualizar.size(); i++ ){
            
            itensParaAtualizar[i].Status_do_Item__c = statusAtual;
            
            update  itensParaAtualizar[i];
            
        }
        
        String a = 'a';
        String b = 'b';
        String c = 'c';
        String d = 'd';
        
       System.debug(itensParaAtualizar); 
    }
}