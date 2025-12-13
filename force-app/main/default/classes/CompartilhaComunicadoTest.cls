@isTest(seeAllData=true)
public class CompartilhaComunicadoTest {
    @isTest
    private static void teste1(){
        Comunicado__c comunicado = new Comunicado__c();
        comunicado.Titulo__c = 'Teste';
        comunicado.Departamentos__c = 'Administrativo;Desenvolvimento';
        insert comunicado;
    }
}