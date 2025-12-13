@isTest
public class ContaPreenchimentoTEST {

    @isTest
    public static void ontaPreenchimento(){
		
        String cnpj = '05.743.288/0001-08';

        Account a = new Account();
        a.Name = 'Teste';
        a.CNPJ__c = cnpj;
       
        insert a;

        //ContaPreenchimento cp = new ContaPreenchimento();
        ContaPreenchimento.ChamarReceita(a.id,cnpj);
        
        
    }
    
    
}