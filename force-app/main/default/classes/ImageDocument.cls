public with sharing class ImageDocument {
    
    @AuraEnabled
    public static string insertImage(String image, String name, String dataType, String contentType, String folderName) {
        // Debug para verificar os parâmetros recebidos
        System.debug('Parametros Recebidos:');
        System.debug('image: ' + image);
        System.debug('name: ' + name);
        System.debug('dataType: ' + dataType);
        System.debug('contentType: ' + contentType);
        System.debug('folderName: ' + folderName);
        
        // Busca a pasta
        List<Folder> pastaLog = [SELECT Id FROM Folder WHERE Name = :folderName];
        System.debug('Pasta Log: ' + pastaLog);
        
        // Verifica se a pasta foi encontrada
        if (pastaLog.isEmpty()) {
            throw new AuraHandledException('Folder not found: ' + folderName);
        }
        
        // Cria o documento
        Document imageDoc = new Document(
            Name = name,
            Body = EncodingUtil.base64Decode(image),
            ContentType = contentType,
            Type = dataType,
            IsPublic = true,
            FolderId = pastaLog[0].Id
        );
        
        // Debug para verificar o documento antes de inserir
        System.debug('Documento a ser inserido: ' + imageDoc);
        
        try {
            insert imageDoc;
            // Debug para verificar se o documento foi inserido corretamente
            System.debug('Documento inserido: ' + imageDoc);
            
            return 'https://hospcom.my.salesforce.com/servlet/servlet.ImageServer?id=' + imageDoc.Id + '&oid=00Di0000000JVhH&lastMod=1718915378000';
        } catch (Exception e) {
            // Debug para capturar a exceção
            System.debug('Erro ao inserir documento: ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    
    @AuraEnabled
    public static Object uploadProduct (String id, String url){
        
        Product2 p = new Product2();
        p.id = id;
        p.URL_da_Imagem__c = url;
        
        try{
	        update p;            
			return p;
        } catch (Exception e){
            return e;
        }
        
    }

	@AuraEnabled
    public static Object uploadWorkOrder (String id, String url){
 		WorkOrder wo = new WorkOrder();
        wo.id = id;
        wo.assinaturaTermino__c = url;
        
        try{
	        update wo;            
			return wo;
        } catch (Exception e){
            return e;
        }
    }
    
    @AuraEnabled
    public static void uploadRetirada(String id, String url) {
        // Cria uma nova instância de Retirada_rapida__c
        Retirada_rapida__c retirada = new Retirada_rapida__c();
        retirada.id = id;
        retirada.AssinaturaTermino__c = url;
        
        try {
            update retirada;            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}