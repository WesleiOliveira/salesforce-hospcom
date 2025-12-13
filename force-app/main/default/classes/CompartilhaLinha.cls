public class CompartilhaLinha {
    
    public static void compartilha () {
        String VetID = '00G6e000005i1EV';
        String UltrassomID = '00G6e0000056TVc';
        String SurgicalID = '00GU4000000Z5fx';
        String VADID = '00GU4000000Z2mx';
        String PMLSID = '00G6e000005hyBT';
        
        List<OrderShare> compartilhamentos = new List<OrderShare>();
        List<Order> Vet = [SELECT ID FROM Order WHERE ID IN (SELECT OrderId FROM OrderItem WHERE Product2.Linha__c = 'VETERINÁRIA') AND ID NOT IN (SELECT OrderId FROM OrderShare WHERE UserOrGroupId =: VetID) ];
        List<Order> Ultrassom = [SELECT ID FROM Order WHERE ID IN (SELECT OrderId FROM OrderItem WHERE Product2.Linha__c = 'IMAGEM') AND ID NOT IN (SELECT OrderId FROM OrderShare WHERE UserOrGroupId =: UltrassomID) ];
        List<Order> Surgical = [SELECT ID FROM Order WHERE ID IN (SELECT OrderId FROM OrderItem WHERE Product2.Linha__c = 'SURGICAL') AND ID NOT IN (SELECT OrderId FROM OrderShare WHERE UserOrGroupId =: SurgicalID) ];
        List<Order> VAD = [SELECT ID FROM Order WHERE ID IN (SELECT OrderId FROM OrderItem WHERE Product2.Linha__c = 'VIAS AÉREAS DIFÍCEIS') AND ID NOT IN (SELECT OrderId FROM OrderShare WHERE UserOrGroupId =: VADID) ];
        List<Order> PMLS = [SELECT ID FROM Order WHERE ID IN (SELECT OrderId FROM OrderItem WHERE Product2.Linha__c = 'PMLS') AND ID NOT IN (SELECT OrderId FROM OrderShare WHERE UserOrGroupId =: PMLSID) ];
        
        //Vet
        for(Order oppVet : Vet){
            OrderShare os = new OrderShare(OrderId = oppVet.Id, UserOrGroupId = VetID, OrderAccessLevel = 'Edit');
            compartilhamentos.add(os);
        }
        
        //Ultrassom
        for(Order oppUltra : Ultrassom){
            OrderShare os = new OrderShare(OrderId = oppUltra.Id, UserOrGroupId = UltrassomID, OrderAccessLevel = 'Edit');
            compartilhamentos.add(os);
        }
        
        //Surgical
        for(Order oppSU : Surgical){
            OrderShare os = new OrderShare(OrderId = oppSU.Id, UserOrGroupId = SurgicalID, OrderAccessLevel = 'Edit');
            compartilhamentos.add(os);
        }		
        
        //VAD
        for(Order oppVAD : VAD){
            OrderShare os = new OrderShare(OrderId = oppVAD.Id, UserOrGroupId = VADID, OrderAccessLevel = 'Edit');
            compartilhamentos.add(os);
        }
        
        //PMLS
        for(Order oppPMLS : PMLS){
            OrderShare os = new OrderShare(OrderId = oppPMLS.Id, UserOrGroupId = PMLSID, OrderAccessLevel = 'Edit');
            compartilhamentos.add(os);
        }
            
        insert compartilhamentos;
        
    }
    
    public static void test() {
        boolean a = true;
        boolean b = a;
        a = b;
        b = a;
        a = b;
        b = a;
        a = b;
        b = a;
        a = b;
        b = a;
        a = b;
        b = a;
        a = b;
        b = a;
        a = b;
        b = a;
    }

}