public with sharing class InsumoController {
    
    @AuraEnabled(cacheable=true)
    public static List<Product2> searchProducts(String productCode) {
        String query = 'SELECT Id, ProductCode, Name, Marca__c, URL_da_Imagem__c, Valor_de_Venda__c FROM Product2 WHERE ProductCode = :productCode LIMIT 10';
        return Database.query(query);
    }
    
    @AuraEnabled
    public static void sendSelectedProducts(String productData, String idRegistro) {
        // Desserializa o JSON em uma lista de objetos SelectedProduct
        List<SelectedProduct> selectedProducts = (List<SelectedProduct>) JSON.deserialize(productData, List<SelectedProduct>.class);
        List<Insumo_do_contrato__c> insumos = new List<Insumo_do_contrato__c>();
        
        // Processa os produtos selecionados
        for (SelectedProduct product : selectedProducts) {
            String productId = product.Id;
            Integer quantity = product.quantity;
            Double value = product.value;
            
            // Lógica para lidar com os dados do produto selecionado
            System.debug('Product ID: ' + productId + ', Quantity: ' + quantity + ', Value: ' + value);
            Insumo_do_contrato__c insumo = new Insumo_do_contrato__c();
            insumo.Contrato_de_Fornecimento_de_Insumo__c = idRegistro;
            insumo.Produto__c = productId;
            insumo.Valor_unitario__c = value;
            insumo.Quantidade__c = quantity;
            insumos.add(insumo);
        }
        try{
            insert insumos;
        }
        catch(Exception e){
            system.debug(e.getMessage());
            throw new AuraHandledException('Erro ao inserir produtos: ' + e.getMessage());
        }
    }
    public class SelectedProduct {
        @AuraEnabled public String Id { get; set; }
        @AuraEnabled public Integer quantity { get; set; }
        @AuraEnabled public Double value { get; set; }
        
        // Construtor
        public SelectedProduct(String Id, Integer quantity, Double value) {
            this.Id = Id;
            this.quantity = quantity;
            this.value = value;
        }
    }
    
}