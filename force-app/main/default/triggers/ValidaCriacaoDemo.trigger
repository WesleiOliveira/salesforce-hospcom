trigger ValidaCriacaoDemo on Order (before insert) {
    public Id RecordType {get; set;}
    public Id vendedor {get; set;}
    public Id criador {get; set;}
    
    for(Order pedido : Trigger.new){
        RecordType = pedido.RecordTypeId;
		vendedor = pedido.Vendedor__c;        
		criador = pedido.CreatedById;        
    }
    if(!Util.IgnorarErros()){
        if(RecordType == '0126e000001pMEk'){
            
            List<Order> demos = [
                SELECT  Id
                FROM    Order
                WHERE   (Vendedor__c =: vendedor OR Vendedor__c =: criador OR CreatedById =: criador) AND Status = 'Finalizado' AND RecordTypeId = '0126e000001pMEk' AND (Nota_de_envio_assinada__c = FALSE OR Nota_de_retorno_assinada__c = FALSE OR Checklist_assinado__c = FALSE OR Registro_da_demo_assinado__c = FALSE OR Lista_de_participantes_preenchida__c = FALSE OR Equipamentos_acessorios_entregues__c = FALSE)
            ];
            
            for(Order pedido : Trigger.new){
                if(demos.size()>0){
                    pedido.addError('O vendedor e/ou o criador do pedido possui(em) pendências em outras demonstrações. Finalize-as antes de solicitar uma nova demonstração.');
                }
            }
        }
    }
}