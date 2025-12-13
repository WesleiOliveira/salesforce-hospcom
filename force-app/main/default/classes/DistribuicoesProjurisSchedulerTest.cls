@isTest
public class DistribuicoesProjurisSchedulerTest {
    
    // Mock para a chamada de autenticação
    private class AuthMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"access_token":"mockAccessToken"}');
            res.setStatusCode(200);
            return res;
        }
    }
    
    // Mock para a chamada da API de distribuição
    private class DistribuicaoMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"content": [{"id": 1, "natureza": {"nome": "Civil"}, "comarca": {"nome": "Comarca X"}, "tribunal": {"nome": "Tribunal Y"}, "jurisdicao": {"nome": "Jurisdicao Z"}, "dataDistribuicao": "2023-01-01", "classeNatureza": "Classe A", "partes": "Parte 1, Parte 2", "valorCausa": 1000.00, "tribunalOriginal": "Tribunal Original", "status": "Status A", "numeroProcesso": "123456", "tipoDistribuicao": "Tipo 1"}]}');
            res.setStatusCode(200);
            return res;
        }
    }
    
    @isTest
    static void testAgendamento() {
        // Configura os mocks
        Test.setMock(HttpCalloutMock.class, new AuthMock());
        Test.setMock(HttpCalloutMock.class, new DistribuicaoMock());
     
        
        // Verifica que não há agendamentos
        List<CronTrigger> triggersAntes = [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = 'Agendamento DistribuicoesProjuris'];
        System.assertEquals(0, triggersAntes.size(), 'Deve haver 0 agendamentos antes do teste');
        
        // Agenda a pesquisa de distribuições
        Test.startTest();
        // Agendar o job
        DistribuicoesProjurisScheduler scheduler = new DistribuicoesProjurisScheduler();
        String cronExp = '0 0 0 17 9 ? 2025';
        System.schedule('Test DistribuicoesProjurisScheduler Job', cronExp, scheduler);
        

        Test.stopTest();

    }
}