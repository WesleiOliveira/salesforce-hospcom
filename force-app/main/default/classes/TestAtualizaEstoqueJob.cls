@isTest(SeeAllData=true)
private class TestAtualizaEstoqueJob implements HttpCalloutMock {

    // Simula os dados que virão do callout (SKU e WHSCODE já existentes)
    static String sku = '115-007057-00';
    static String whs = '305';

    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('[{"ITEMCODE":"' + sku + '","WHSCODE":"' + whs + '","ONHAND":0}]');
        res.setStatusCode(200);
        return res;
    }

    @isTest static void testeJob() {
        // Busca a entrada existente que você sabe que tem esses dados
        List<Entrada_de_Estoque__c> entradas = [
    SELECT Id, Em_estoque__c
    FROM Entrada_de_Estoque__c
    WHERE Produto__r.ProductCode = :sku AND Estoque__r.Codigo__c = :whs
    LIMIT 1
];
System.debug('mapa'+ entradas);
System.assert(!entradas.isEmpty(), 'Nenhuma entrada encontrada com SKU e WHS especificados');

Entrada_de_Estoque__c entrada = entradas[0];


        // Registra o mock da resposta
        Test.setMock(HttpCalloutMock.class, new TestAtualizaEstoqueJob());

        Test.startTest();
        new AtualizaEstoqueJob().execute(null);
        Test.stopTest();

        Entrada_de_Estoque__c atualizado = [
            SELECT Em_estoque__c FROM Entrada_de_Estoque__c WHERE Id = :entrada.Id
        ];

        System.assertEquals(0, atualizado.Em_estoque__c, 'O estoque deveria ter sido atualizado para 0');
    }
}