public class produtosInsercao {
    @AuraEnabled
    public static void inserirProdutos(String jsonString) {
        // Parseando a string JSON para uma lista de objetos
        List<Object> produtosList = (List<Object>) JSON.deserializeUntyped(jsonString);
        
        // Definindo o tamanho do lote para controlar quantos registros serão inseridos de cada vez
        Integer loteTamanho = 1; // Inserir um por vez
        
        // Processando os produtos em lotes
        for (Integer i = 0; i < produtosList.size(); i += loteTamanho) {
            List<Product2> produtosLote = new List<Product2>();
            
            for (Integer j = i; j < Math.min(produtosList.size(), i + loteTamanho); j++) {
                Map<String, Object> produtoMap = (Map<String, Object>) produtosList[j];
                try {
                    // Criando um novo registro de Product2
                    Product2 novoProduto = new Product2();
                    
                    // Mapeando os campos do JSON para os campos do objeto Product2
                    novoProduto.ProductCode = (String) produtoMap.get('Código do Fabricante');
                    novoProduto.Name = (String) produtoMap.get('Nome');
                    novoProduto.Marca__c = (String) produtoMap.get('Marca');
                    novoProduto.Modelo__c = (String) produtoMap.get('Modelo');
                    novoProduto.Linha__c = (String) produtoMap.get('Linha');
                    novoProduto.Family = (String) produtoMap.get('Família');
                    novoProduto.Tipo_do_Produto__c = (String) produtoMap.get('Tipo');
                    novoProduto.Valor_de_Venda__c = Decimal.valueOf((String) produtoMap.get('Valor de venda'));
                    novoProduto.Description = (String) produtoMap.get('Descrição');
                    novoProduto.NCM_do_Produto__c = (String) produtoMap.get('NCM');
                    novoProduto.IsActive = true;
                    
                    // Adicionando o produto à lista do lote
                    produtosLote.add(novoProduto);
                    
                } catch (Exception e) {
                    System.debug('Erro ao processar o produto: ' + e.getMessage());
                }
            }
            
            try {
                insert produtosLote;
            } catch (Exception e) {
                throw new AuraHandledException('Erro ao inserir lote de produtos: ' + e.getMessage());
            }
        }
    }
    @AuraEnabled
    public static void inserirProdutosConsumo(String jsonString) {
        // Parseando a string JSON para uma lista de objetos
        List<Object> produtosList = (List<Object>) JSON.deserializeUntyped(jsonString);
        
        // Definindo o tamanho do lote para controlar quantos registros serão inseridos de cada vez
        Integer loteTamanho = 1; // Inserir um por vez
        
        // Processando os produtos em lotes
        for (Integer i = 0; i < produtosList.size(); i += loteTamanho) {
            List<Product2> produtosLote = new List<Product2>();
            
            for (Integer j = i; j < Math.min(produtosList.size(), i + loteTamanho); j++) {
                Map<String, Object> produtoMap = (Map<String, Object>) produtosList[j];
                try {
                    // Criando um novo registro de Product2
                    Product2 novoProduto = new Product2();
                    
                    string random = produtosInsercao.gerarCodigo();
                    system.debug(random);
                    
                    // Mapeando os campos do JSON para os campos do objeto Product2
                    novoProduto.ProductCode = random;
                    novoProduto.Name = (String) produtoMap.get('Nome');
                    novoProduto.Modelo__c = (String) produtoMap.get('Modelo');
                    novoProduto.Categoria_de_compra__c = (String) produtoMap.get('Categoria de Compra');
                    novoProduto.Description = (String) produtoMap.get('Descrição');
                    novoProduto.Unidade_de_medida__c = (String) produtoMap.get('Unidade de Medida');
                    novoProduto.NCM_do_Produto__c = (String) produtoMap.get('NCM');                    
                    novoProduto.Valor_de_Venda__c = 0;                    
                    novoProduto.Linha__c = 'OUTROS';                    
                    novoProduto.Family = 'OUTROS';                    
                    novoProduto.IsActive = true;
                    
                    // Adicionando o produto à lista do lote
                    produtosLote.add(novoProduto);
                    
                } catch (Exception e) {
                    System.debug('Erro ao processar o produto: ' + e.getMessage());
                }
            }
            
            try {
                insert produtosLote;
            } catch (Exception e) {
                throw new AuraHandledException('Erro ao inserir lote de produtos: ' + e.getMessage());
            }
        }
    }
    public static String gerarCodigo() {
        // Prefixo fixo
        String prefixo = 'CON-';
        
        // Comprimento da parte aleatória da string (excluindo o prefixo)
        Integer comprimentoAleatorio = 10; // Ajuste conforme necessário
        
        // Gerar a parte aleatória
        String parteAleatoria = gerarParteAleatoria(comprimentoAleatorio);
        
        // Concatenar o prefixo com a parte aleatória
        return prefixo + parteAleatoria;
    }
    
    private static String gerarParteAleatoria(Integer comprimento) {
        // Caracteres possíveis para a parte aleatória
        String caracteres = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
        String resultado = '';
        
        // Gerar caracteres aleatórios
        for (Integer i = 0; i < comprimento; i++) {
            Integer index = (Integer) (Math.random() * caracteres.length());
            resultado += caracteres.substring(index, index + 1);
        }
        
        return resultado;
    }
}