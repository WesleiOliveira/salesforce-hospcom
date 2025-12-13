@isTest
public class ContaValidacaoTest {
@isTest
    public static void teste(){
        Account contaComercial = new Account(Name = 'Teste LTDA', Type = 'CLIENTE', CNPJ__c = '01.831.939/0001-60', Phone = '(62) 99147-4410');
        insert contaComercial;
    }

}