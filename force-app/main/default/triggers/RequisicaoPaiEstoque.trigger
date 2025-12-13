trigger RequisicaoPaiEstoque on Requisicao_de_Item__c (after insert) {

    public static Requisicao_de_item__c Req;
    public Static Requisicao_de_item__c NewReq;
    public Id reqId;
    
    if(RecursiveHandler.IsNotRecursive){
    RecursiveHandler.IsNotRecursive = false;
        
        List <Requisicao_de_item__c> ReqPai = new List <Requisicao_de_item__c>();

    for(Requisicao_de_Item__c ReqItem : trigger.new ){
        if(ReqItem.Nao_acionar_trigger__c == null){
      Requisicao_de_item__c NewReq = new Requisicao_de_item__c();

        Req = [SELECT Id, Item_de_pedido_de_compra__c  FROM Requisicao_de_item__c WHERE Id =: ReqItem.Id limit 1];
        NewReq.Data_de_requisicao__c = System.today();
        NewReq.Quantidade_requisitada__c = ReqItem.Quantidade_requisitada__c;
        NewReq.Item_de_pedido_de_compra__c = ReqItem.Item_de_pedido_de_compra__c;
        NewReq.RecordTypeId = '0126e000001YbImAAK';
    
        ReqPai.add(NewReq);
        
            insert NewReq;
            Req.Requisicao_pai__c = NewReq.Id;
            update Req;
    }
    }
                upsert ReqPai;
    }
    
}