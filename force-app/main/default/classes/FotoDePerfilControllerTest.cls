@isTest(seeAllData=true)
public class FotoDePerfilControllerTest {

        public Recrutamento__c recrutamento {get;set;}

@isTest
    static void FotoDePerfilControllerTest(){ 
     	FotoDePerfilController.getProfilePicture(Id.valueOf('a105A00000Ioz0s')); 
    
    } 
    
@isTest
    static void saveAttach(){
    	FotoDePerfilController.saveAttachment(Id.valueOf('a105A00000Ioz0s'),('b'), ('teste'), ('jpeg'));
    
	    }
}