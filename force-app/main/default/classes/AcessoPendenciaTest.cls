@isTest(seeAllData=true)
public class AcessoPendenciaTest {

    @isTest public static void teste(){
        Pendencia__c pendencia = new Pendencia__c();
        pendencia.Responsavel__c = '0055A00000BDnLZ';
        insert pendencia;
    }
}