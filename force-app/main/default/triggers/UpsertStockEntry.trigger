/*
trigger UpsertStockEntry on Entrada_de_Estoque__c (before insert, before update) {
   
    Set<String> uniqueIdentifiers = new Set<String>();
    Set<String> productCodes = new Set<String>();
    Set<String> estoqueCodes = new Set<String>();
    
    Map<String, Entrada_de_Estoque__c> existingRecordsMap = new Map<String, Entrada_de_Estoque__c>();

    // Verificar duplicações dentro dos registros novos/atualizados
    for (Entrada_de_Estoque__c estoque : Trigger.new) {
        String uniqueIdentifier = estoque.Produto__r.ProductCode + '-' + estoque.Estoque__r.Codigo__c;
        System.debug('Verificando entrada: Produto Code: ' + estoque.Produto__r.ProductCode + ', Estoque Code: ' + estoque.Estoque__r.Codigo__c);
        
        if (uniqueIdentifiers.contains(uniqueIdentifier)) {
            estoque.addError('Duplicado: Já existe um registro com este Código de Produto: ' + 
                             estoque.Produto__r.ProductCode + ' e Código de Estoque: ' + 
                             estoque.Estoque__r.Codigo__c + ' neste lote.');
        } else {
            uniqueIdentifiers.add(uniqueIdentifier);
            productCodes.add(estoque.Produto__r.ProductCode);
            estoqueCodes.add(estoque.Estoque__r.Codigo__c);
        }
    }

    System.debug('Unique Identifiers: ' + uniqueIdentifiers);
    System.debug('Product Codes: ' + productCodes);
    System.debug('Estoque Codes: ' + estoqueCodes);

    // Consultar registros existentes no banco de dados com os códigos fornecidos
    List<Entrada_de_Estoque__c> existingRecords = [SELECT Id, Produto__r.ProductCode, Estoque__r.Codigo__c 
                                                   FROM Entrada_de_Estoque__c 
                                                   WHERE Produto__r.ProductCode IN :productCodes
                                                   AND Estoque__r.Codigo__c IN :estoqueCodes];
    
    System.debug('Existing Records from DB: ' + existingRecords);

    // Mapear registros existentes com identificadores únicos
    for (Entrada_de_Estoque__c record : existingRecords) {
        String identifier = record.Produto__r.ProductCode + '-' + record.Estoque__r.Codigo__c;
        existingRecordsMap.put(identifier, record);
    }

    System.debug('Existing Records Map: ' + existingRecordsMap);

    // Verificar duplicação no banco de dados e fornecer o ID do registro duplicado
    for (Entrada_de_Estoque__c estoque : Trigger.new) {
        String uniqueIdentifier = estoque.Produto__r.ProductCode + '-' + estoque.Estoque__r.Codigo__c;
        if (existingRecordsMap.containsKey(uniqueIdentifier)) {
            Entrada_de_Estoque__c duplicado = existingRecordsMap.get(uniqueIdentifier);
            estoque.addError('Duplicado: O valor com Código de Produto: ' + 
                             estoque.Produto__r.ProductCode + ' e Código de Estoque: ' + 
                             estoque.Estoque__r.Codigo__c + ' já existe no registro com ID: ' + duplicado.Id);
        }
    }
}*/trigger UpsertStockEntry on Entrada_de_Estoque__c (before insert, before update) {
    Set<String> existingRecords = new Set<String>();

      List <Entrada_de_Estoque__c>  a = new  List <Entrada_de_Estoque__c>();
    
    
    for (Entrada_de_Estoque__c estrada_de_estoque : Trigger.new)
    {
         a =  [SELECT Id, LastModifiedDate, Em_estoque__c, Confirmado__c, Pedido__c, Estoque__r.Codigo__c, Produto__r.ProductCode, Posicao_no_deposito__c 
        FROM Entrada_de_Estoque__c  WHERE Estoque__r.Codigo__c =: estrada_de_estoque.Estoque__r.Codigo__c AND Produto__r.ProductCode =: estrada_de_estoque.Produto__r.ProductCode];
         
        
        system.debug('tamanho: '+ a.size());
        if (a.size() > 0) {
            estrada_de_estoque.addError('Este registro já existe com os mesmos valores de Estoque e Produto.');
        }
      
    }    
    
    
      
    
   

}