@isTest
public class SimpleEntradaDeEstoqueTriggerTest {   
    @isTest 
    static void testDuplicatePrevention() {
        try { 
            // Simulação de estoque e produto usando os IDs fornecidos
            estoque__c estoque = new estoque__c(id = 'a1A5A00000CYT09');
            Product2 produto = new Product2(id = '01t6e000009nWFt');
            
            // Criação da entrada de estoque
            Entrada_de_Estoque__c novaEntrada = new Entrada_de_Estoque__c(
                Produto__c = produto.Id, 
                Estoque__c = estoque.Id
            );
            
            // Insere a nova entrada de estoque para testar a trigger
            insert novaEntrada;
            
            List<Entrada_de_Estoque__c> entradas = [
                SELECT Id, Pedido__c, Estoque__c 
                FROM Entrada_de_Estoque__c 
                WHERE Id = :novaEntrada.Id
            ];
      
          
            
        } catch(Exception e) {
            System.debug('error: ' + e);      
        }
    }
}