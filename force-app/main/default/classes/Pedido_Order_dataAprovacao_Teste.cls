@isTest(seealldata = true)
public class Pedido_Order_dataAprovacao_Teste {
    @isTest
    static void testTrigger() {
        // Obtém o ID de um pedido existente na produção
        Id orderId = '8016e0000095C6OAAU'; // Substitua 'ID_DO_PEDIDO_AQUI' pelo ID real do pedido

        // Consulta o pedido com o ID fornecido
        Order orderToUpdate = [
            SELECT Id, Data_de_aprova_o_do_PV__c 
            FROM Order 
            WHERE Id = :orderId 
            LIMIT 1
        ];

        // Define alguns campos para simular uma edição
        orderToUpdate.Data_de_aprova_o_do_PV__c = null; // Isso é apenas um exemplo, substitua pelos valores necessários

        update orderToUpdate;
    }
}