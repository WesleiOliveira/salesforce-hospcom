trigger PedidoCompartilhaVendedor on Order (after insert, after update) {
    if(RecursiveHandler.IsNotRecursive){
        RecursiveHandler.IsNotRecursive = false;
                 
        for(Integer i = 0 ; i < Trigger.new.size() ; i++){
            if(Trigger.isInsert || Trigger.new[i].Vendedor__c != Trigger.old[i].Vendedor__c){
            	List<OrderShare> os = [SELECT Id, OrderAccessLevel, RowCause FROM OrderShare WHERE OrderId = :Trigger.new[i].Id and UserOrGroupId = :Trigger.new[i].Vendedor__c];
            	if(os.size() < 1){ OrderShare ors = new OrderShare(); ors.OrderId = Trigger.new[i].Id; ors.UserOrGroupId = Trigger.new[i].Vendedor__c; ors.OrderAccessLevel = 'Edit'; insert ors; }
            }
        }
    }
}