public class DocumentosRegistros {
    
    @AuraEnabled
    public static List<Map<String, Object>> documentosOts(String idComodato, Integer offset_1, Integer limit_1) {
        List<Map<String, Object>> anexos = new List<Map<String, Object>>();
        
        List<Produto_da_demonstracao__c> produtos = [
            SELECT Id, Name, CreatedDate, Ativo__c
            FROM Produto_da_demonstracao__c
            WHERE Demonstracao__c = :idComodato
            ORDER BY CreatedDate
            LIMIT :limit_1 OFFSET :offset_1
        ];
        
        for (Produto_da_demonstracao__c produto : produtos) {
            anexos.addAll(ativoComodato(produto.Ativo__c));
        }
        
        System.debug('Total de anexos encontrados: ' + anexos.size());
        return anexos;
    }
    
    public static List<Map<String, Object>> ativoComodato(String idProduto) {
        List<Map<String, Object>> anexos = new List<Map<String, Object>>();
        
        List<Asset> ativos = [
            SELECT Id, Name 
            FROM Asset
            WHERE Id = :idProduto
        ];
        
        for (Asset ativo : ativos) {
            anexos.addAll(ordensTrabalho(ativo.Id, ativo.Name));
        }
        
        return anexos;
    }
    
    public static List<Map<String, Object>> ordensTrabalho(String idAtivo, String nomeAtivo) {
        List<Map<String, Object>> anexos = new List<Map<String, Object>>();
        
        List<WorkOrder> ordens = [
            SELECT Id, Subject 
            FROM WorkOrder
            WHERE AssetId = :idAtivo
            ORDER BY CreatedDate desc
            LIMIT 2
        ];
        
        for (WorkOrder ordem : ordens) {
            anexos.addAll(pegatodososanexos(ordem.Id, ordem.Subject, idAtivo, nomeAtivo));
        }
        
        return anexos;
    }
    
    public static List<Map<String, Object>> pegatodososanexos(String idOrdemTrabalho, String nomeOrdemTrabalho, String idAtivo, String nomeAtivo) {
        List<Map<String, Object>> anexos = new List<Map<String, Object>>();
        
        List<ContentDocumentLink> contentDocumentLinks = [
            SELECT ContentDocumentId, LinkedEntityId
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :idOrdemTrabalho
            LIMIT 3
        ];
        
        for (ContentDocumentLink cdl : contentDocumentLinks) {
            ContentVersion cv = [
                SELECT Title, VersionData
                FROM ContentVersion
                WHERE ContentDocumentId = :cdl.ContentDocumentId
                ORDER BY CreatedDate DESC
                LIMIT 1
            ];
            
            if (cv != null) {
                Map<String, Object> anexo = new Map<String, Object>();
                anexo.put('nomeDocumento', cv.Title);
                anexo.put('base64', EncodingUtil.base64Encode(cv.VersionData));
                anexo.put('idAtivo', idAtivo);
                anexo.put('nomeAtivo', nomeAtivo);
                anexo.put('idOrdemTrabalho', idOrdemTrabalho);
                anexo.put('nomeOrdemTrabalho', nomeOrdemTrabalho);
                anexos.add(anexo);
            }
        }
        
        String a = 'a';
        
        a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';
        
        return anexos;
    }

	//---------------------------------------------------------------------------------------
    @AuraEnabled
    public static List<Map<String, Object>> documentosOts_Demo(String idPedido, Integer offset_1, Integer limit_1) {
        List<Map<String, Object>> anexos = new List<Map<String, Object>>();
        
        List<OrderItem> produtos = [
            SELECT Id,Description , CreatedDate
            FROM OrderItem
            WHERE OrderId = :idPedido
            ORDER BY CreatedDate
            LIMIT :limit_1 OFFSET :offset_1
        ];
        
        for (OrderItem produto : produtos) {
            anexos.addAll(ativoProdutoDoPedido(produto.Description));
        }
        
        System.debug('Total de anexos encontrados: ' + anexos.size());
        return anexos;
    }

    public static List<Map<String, Object>> ativoProdutoDoPedido(String numeroDeSerie_Produto) {
        List<Map<String, Object>> anexos = new List<Map<String, Object>>();
        
        List<Asset> ativos = [
            SELECT Id, Name, SerialNumber
            FROM Asset
            WHERE SerialNumber = :numeroDeSerie_Produto
            LIMIT 1
        ];
        
        for (Asset ativo : ativos) {
            anexos.addAll(ordensTrabalho(ativo.Id, ativo.Name));
        }
        
        return anexos;
    }
   
    
    
    //--------------------------------------------------------------------------------------
    @AuraEnabled
    public static List<Map<String, Object>> documentosOts_contratos(String idContrato, Integer offset_1, Integer limit_1) {
        List<Map<String, Object>> anexos = new List<Map<String, Object>>();
        
        List<Ativos_do_Contrato__c> produtos = [
            SELECT Id,N_de_S_rie__c , CreatedDate
            FROM Ativos_do_Contrato__c
            WHERE Contrato_de_Servico__c =: idContrato
            ORDER BY CreatedDate
            LIMIT :limit_1 OFFSET :offset_1
        ];
        
        for (Ativos_do_Contrato__c produto : produtos) {
            anexos.addAll(ativoProdutoDoPedido(produto.N_de_S_rie__c));
        }
        
        System.debug('Total de anexos encontrados: ' + anexos.size());
        return anexos;
    }

   
}