@IsTest
public class ProcessosProjurisSchedulableTest {
    @IsTest
    static void PublicacoesProjurisSchedulableTest() {
        // Configura o mock HTTP
        Test.setMock(HttpCalloutMock.class, new PublicacoesProjurisMock());
        
        // Define a expressão cron para o agendamento
        String cronExp= '0 0 * * * ?';
        
        // Agendar a execução
        Test.startTest();
        ProcessosProjurisSchedulable job = new ProcessosProjurisSchedulable();
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
            String jsonResponse = '{ "content": [ { "clientePrincipal": { "numeroDocumentoPrincipal": "789012", "nome": "Cliente Teste" }, "dataInicio": "2023-02-06", "numeroProcessoAtual": "789012", "adversoPrincipal": { "nome": "Adverso Teste" }, "natureza": { "nome": "Natureza Teste" }, "id": "001", "procedimento": { "nome": "Procedimento Teste" }, "causaRaizUm": { "nome": "Causa Raiz Teste" }, "tipoProcesso": "Tipo Processo Teste", "pedidoLiminar": true, "naturezaFinanceira": "Natureza Financeira Teste", "jurisdicaoAtual": "Jurisdicao Atual Teste" } ] }';            
            res.setBody(jsonResponse);
            res.setStatusCode(200);
            return res;
        }
    }
}