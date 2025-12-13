public class ColaboradoresController {
    public List <Contact> colaboradores				{get;set;}
    public List <Contact> colaboradoresAniv 		{get;set;}
    
    public ColaboradoresController(){
        
        colaboradores = [SELECT FirstName, LastName, Tipo_Sanguineo__c, Alergia__c, Department, Title, MobilePhone, BirthDate From Contact Where AccountId = '001i00000085QYb'  order By Name];
        
        colaboradoresAniv = [SELECT FirstName, Title, MobilePhone, Department, BirthDate From Contact Where AccountId = '001i00000085QYb' and BirthDate = THIS_MONTH  order By Name];
    }
}