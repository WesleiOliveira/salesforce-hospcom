@isTest(seeAllData=true)
public class anexaTaxasPCTest {

    // Mock interno da resposta da API ChatPDF
    private class ChatGPTMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setHeader('Content-Type', 'application/json');

            // Simula resposta com dois impostos
            String mockJson = '{"content":"```json\n[\n    {\"descricao\": \"Frete Internacional + taxas de origem\", \"valor\": 39630.00},\n    {\"descricao\": \"Seguro (porta a porta)\", \"valor\": 15984.00},\n    {\"descricao\": \"Imposto de Importação - Ι.Ι.\", \"valor\": 159693.41},\n    {\"descricao\": \"Imposto de Prod. Ind. - I.Ρ.Ι.\", \"valor\": 61609.88},\n    {\"descricao\": \"PIS/PASEP\", \"valor\": 20928.74},\n    {\"descricao\": \"COFINS\", \"valor\": 97164.96},\n    {\"descricao\": \"Taxa SISCOMEX\", \"valor\": 447.30},\n    {\"descricao\": \"ICMS\", \"valor\": 507566.83},\n    {\"descricao\": \"AFRMM 8%\", \"valor\": 3383.36},\n    {\"descricao\": \"Capatazias\", \"valor\": 2662.00},\n    {\"descricao\": \"Desconsolidação + taxas de destino\", \"valor\": 3480.00},\n    {\"descricao\": \"Armazenagem zona primaria (15 dias) + DDC - Descarga direta no caminhão\", \"valor\": 22200.00},\n    {\"descricao\": \"Transporte remoção (DTA)\", \"valor\": 0.00},\n    {\"descricao\": \"Armazenagem zona secundaria\", \"valor\": 0.00},\n    {\"descricao\": \"Transporte Nacional / Entrega no Cliente\", \"valor\": 0.00},\n    {\"descricao\": \"Despesa LI (Anvisa / DECEX / INMETRO / ANP / MAPA / OUTROS)\", \"valor\": 0.00},\n    {\"descricao\": \"Desembaraço Aduaneiro\", \"valor\": 0.00},\n    {\"descricao\": \"S.D.A\", \"valor\": 0.00},\n    {\"descricao\": \"Expediente\", \"valor\": 1958.00},\n    {\"descricao\": \"Taxa de Licença de Importação\", \"valor\": 1518.00},\n    {\"descricao\": \"Taxa de Emissão GLME\", \"valor\": 1720.00}\n]\n```"}';
            
            res.setBody(JSON.serialize(
                new Map<String, Object>{
                    'choices' => new List<Object>{
                        new Map<String, Object>{
                            'message' => new Map<String, Object>{
                                'content' => mockJson
                            }
                        }
                    }
                }
            ));
            return res;
        }
    }

    @isTest
    public static void testeUploadEProcessamentoComIdFixo() {
        Id fornecedorId = 'a1bU4000005aV8rIAE'; // ID fixo de Fornecedor__c existente no org de teste

        String fakeBase64 = EncodingUtil.base64Encode(Blob.valueOf('teste'));
        String fileName = 'Taxas Efetivas.pdf';

        // Primeiro, envia o PDF e obtém a URL pública
        String publicUrl = anexaTaxasPC.uploadPdfAndGetPublicUrl(
            fornecedorId,
            fileName,
            fakeBase64
        );


        // Define o mock da chamada externa
        Test.setMock(HttpCalloutMock.class, new ChatGPTMock());

        Test.startTest();
        anexaTaxasPC.processarPdfViaChatPdf(publicUrl, fileName, fornecedorId);
        Test.stopTest();

        // Verifica se os registros de pagamento foram criados corretamente
        List<Pagamento_importacao__c> registros = [
            SELECT Descricao__c, Valor_previsto__c, Pedido_de_compra__c
            FROM Pagamento_importacao__c
            WHERE Pedido_de_compra__c = :fornecedorId
        ];

        Set<String> descricoes = new Set<String>();
        for (Pagamento_importacao__c p : registros) {
            descricoes.add(p.Descricao__c);
        }

        //System.assert(descricoes.contains('ICMS'), 'Deve conter o imposto ICMS');
        //System.assert(descricoes.contains('PIS'), 'Deve conter o imposto PIS');
    }
}