public class UpdateImageUrlClass {

    @AuraEnabled
    public static void updateImageUrl(Id recordId, String imageUrl) {
        // Valida o ID e a URL antes de proceder
        if (recordId == null || String.isEmpty(imageUrl)) {
            throw new AuraHandledException('ID ou URL da imagem inválidos.');
        }
        
        try {
            // Tenta buscar o comunicado e atualizar o campo Link_da_imagem__c
            Comunicado__c comunicado = [SELECT Id, Link_da_imagem__c FROM Comunicado__c WHERE Id = :recordId LIMIT 1];
            comunicado.Link_da_imagem__c = imageUrl;
            update comunicado;
        } catch (QueryException e) {
            throw new AuraHandledException('Registro não encontrado para o ID fornecido.');
        } catch (Exception e) {
            throw new AuraHandledException('Erro ao atualizar o campo: ' + e.getMessage());
        }
    }
}