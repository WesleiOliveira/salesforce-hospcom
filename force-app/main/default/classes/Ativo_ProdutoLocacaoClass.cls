public class Ativo_ProdutoLocacaoClass {
    public static void handleAfterInsert(List<Asset> novosAtivos) {
        Set<Id> productIds = new Set<Id>();
        
        // Coleta todos os Product2Ids dos novos ativos
        for (Asset ativo : novosAtivos) {
            if (ativo.Product2Id != null) {
                productIds.add(ativo.Product2Id);
            }
        }
        
        if (productIds.isEmpty()) {
            return;
        }
        
        // Consulta os produtos originais
        Map<Id, Product2> produtosOriginais = new Map<Id, Product2>([
            SELECT Id, ProductCode, Name, Linha__c, Family, Modelo__c, Marca__c, URL_da_Imagem__c
            FROM Product2
            WHERE Id IN :productIds
        ]);
        
        // Coleta os ProductCodes dos produtos "cópia" que precisamos verificar/criar
        Set<String> productCodesCopias = new Set<String>();
        for (Product2 produto : produtosOriginais.values()) {
            String copiaProductCode = produto.ProductCode + 'LOCACAO';
            productCodesCopias.add(copiaProductCode);
        }
        
        // Consulta os produtos "cópia" existentes
        Map<String, Product2> produtosCopiasExistentes = new Map<String, Product2>();
        for (Product2 produto : [
            SELECT Id, ProductCode
            FROM Product2
            WHERE ProductCode IN :productCodesCopias
        ]) {
            produtosCopiasExistentes.put(produto.ProductCode.trim(), produto);
        }
        List<Product2> produtosParaCriar = new List<Product2>();
        
        // Verifica e cria os produtos "cópia" que não existem
        for (Product2 produtoOriginal : produtosOriginais.values()) {
            String copiaProductCode = produtoOriginal.ProductCode + 'LOCACAO';
            copiaProductCode = copiaProductCode.trim(); // Remove espaços em branco
            
            if (!produtosCopiasExistentes.containsKey(copiaProductCode)) {
                Product2 novoProdutoCopia = new Product2(
                    Name = 'LOCAÇÃO ' + produtoOriginal.Name,
                    Marca__c = produtoOriginal.Marca__c,
                    ProductCode = copiaProductCode,
                    Family = produtoOriginal.Family,
                    Linha__c = produtoOriginal.Linha__c,
                    Tipo_do_produto__c = 'SERVIÇO',
                    Valor_de_Venda__c = 0,
                    Modelo__c = produtoOriginal.Modelo__c,
                    URL_da_Imagem__c = produtoOriginal.URL_da_Imagem__c,
                    IsActive = true
                );
                produtosParaCriar.add(novoProdutoCopia);
            }
        }
        
        
        if (!produtosParaCriar.isEmpty()) {
            insert produtosParaCriar;
        }
    }
}