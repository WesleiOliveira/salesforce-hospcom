@isTest(seeAllData=true)
public class NotificacaoProcessosTest {
    
    @isTest
    static void testEnviarNotificacoes() {
        // Ligar coleta de e-mails enviados
        Test.startTest();
        NotificacaoProcessos.enviarNotificacoes();
        Test.stopTest();        

    }
    
    @isTest
    static void testAgendarEnvioNotificacoesProcessos() {
        Test.startTest();
        String jobId = System.schedule('Teste Envio de Notificações', '0 0 0 * * ?', new AgendarEnvioNotificacoesProcessos());
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
                          FROM CronTrigger WHERE Id = :jobId];
        System.assertEquals('0 0 0 * * ?', ct.CronExpression);
        System.assertEquals(0, ct.TimesTriggered);
        System.assert(ct.NextFireTime != null);
        Test.stopTest();
    }
}