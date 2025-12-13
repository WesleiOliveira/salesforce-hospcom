@isTest(seeAllData=true)
public class RegistroDeDemoRapidaValidaTest {
    @isTest
    static void teste1() {

        // Cria um novo registro sem sobreposição
        Registro_de_Demo_Rapida__c record2 = new Registro_de_Demo_Rapida__c(
            Comodato__c = 'a0KU400001HKYmQ',
            Data_da_Demonstracao__c = Date.newInstance(2024, 10, 7),
            Data_de_Termino_da_Demonstracao__c = Date.newInstance(2024, 10, 8)
        );

        Test.startTest();
        insert record2;
        Test.stopTest();

    }

}