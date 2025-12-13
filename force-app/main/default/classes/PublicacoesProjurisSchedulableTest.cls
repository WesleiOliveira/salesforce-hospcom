@IsTest
public class PublicacoesProjurisSchedulableTest {
    @IsTest
    static void PublicacoesProjurisSchedulableTest() {
        // Configura o mock HTTP
        Test.setMock(HttpCalloutMock.class, new PublicacoesProjurisMock());

        // Define a expressão cron para o agendamento
String cronExp= '0 0 * * * ?';

        // Agendar a execução
        Test.startTest();
        PublicacoesProjurisSchedulable job = new PublicacoesProjurisSchedulable();
        System.schedule('Executar a cada 30 minutos', cronExp, job);
        Test.stopTest();

        // Verificações (se necessário)
        // Por exemplo, verificar se os registros foram criados ou atualizados
        // List<Publicacao__c> publicacoes = [SELECT Id FROM Publicacao__c];
        // System.assertEquals(1, publicacoes.size());
    }

    // Classe mock para simular a resposta da API
    private class PublicacoesProjurisMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"content":[{"createdBy":{"id":null,"name":null,"login":null,"status":null},"createdDate":"2024-09-02T15:00:02.649662Z","lastModifiedBy":null,"lastModifiedDate":"2024-09-02T15:00:02.649662Z","id":4784928,"message":null,"status":"NAO_ATRIBUIDA","numeroProcesso":"18.0014","processo":null,"codigo":"752425","dataPublicacao":"2024-09-03T00:00:00","dataLeitura":null,"ignorado":null,"atribuido":null,"lido":null,"responsaveis":[],"termoEncontrado":"COMERCIO DE ALIM","nomeRelacionado":"COMERCIO DE ALIMENTOS LTDA","comarca":"GOIANIA","estado":"Goiás - GO","vara":"14ª VARA DO TRABALHO DE GOIANIA","forum":"14A VARA DO TRABALHO","diario":"","oab":"","descricao":"teste","observacao":"","justificativa":null}]}');
            res.setStatusCode(200);
            return res;
        }
    }
}