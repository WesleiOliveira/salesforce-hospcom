@isTest
public class AprovaBrindeTest {

    @isTest
    public static void test() {
        List<String> estados = new List<String>{'Ceará', 'Acre', 'Distrito Federal', 'Mato Grosso do Sul'};
            
        for(Integer i = 0; i < estados.size(); i++) {
            Account a = new Account();
            a.Name = 'teste ' + i;
            a.Raz_o_Social__c = 'teste';
            a.Ownership = 'PRIVADO';
            a.Type = 'CLIENTE FINAL';
            a.BillingState = estados[i];
            insert a;

            Brinde__c b = new Brinde__c();
            b.Conta__c = a.Id;
            insert b;


        }

    }
}