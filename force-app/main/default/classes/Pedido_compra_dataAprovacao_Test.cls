@isTest(seeAllData=true)
private class Pedido_compra_dataAprovacao_Test {

    @isTest
    static void testAtualizacaoDataAprovacao() {
       
        List<Pedido_de_compra__c> pedidoTeste = [SELECT Id, name, Data_de_aprova_o__c, Status__c FROM Pedido_de_compra__c WHERE id = 'a1e6e00002qdyQWAAY' LIMIT 1];
        
        // Verifica se há registros retornados pela consulta
        if (!pedidoTeste.isEmpty()) {
            System.debug('Cotação de compra: ' + pedidoTeste[0]);

            pedidoTeste[0].Data_de_aprova_o__c = null;
            update pedidoTeste[0];
        } else {
            System.debug('Nenhum registro encontrado para a consulta.');
        }
    }
}