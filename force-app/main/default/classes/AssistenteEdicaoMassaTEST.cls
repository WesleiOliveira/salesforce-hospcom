@isTest(seeAllData=true)
public class AssistenteEdicaoMassaTEST {

    @isTest
	public static void AssistenteEdicaoMassaTeste(){
        
        List<Order> os = [SELECT id FROM Order LIMIT 10];
        
        for(Order o : os){
            ApexPages.StandardController sc = new ApexPages.StandardController(o);
            AssistenteEdicaoMassa aem = new AssistenteEdicaoMassa(sc);
            aem.Efetiva();
        }
        
    }
    
}