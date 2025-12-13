trigger AcessoVendedor on Order (after insert) {
    
    for(Order pedido: Trigger.new){
        if(pedido.Igual__c == false){           
            OrderShare os = new OrderShare();
                    os.orderid = pedido.id;
                    os.OrderAccessLevel = 'Edit';
                    os.UserOrGroupId = pedido.vendedor__r.id;
                try{
                    insert os;
                    }
                catch(DmlException e){}
            }
      }
}