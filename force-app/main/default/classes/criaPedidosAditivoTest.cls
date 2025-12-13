@IsTest(seeAllData=true)
public class criaPedidosAditivoTest {
    
    @IsTest
    static void teste1(){
        Aditivos_Contratuais__c contrato = [SELECT ID, Status__c FROM Aditivos_Contratuais__c WHERE ID = 'a1jU4000001hiI9IAI'];
        contrato.Status__c = 'Aprovado';
        update contrato;
    }
    
}