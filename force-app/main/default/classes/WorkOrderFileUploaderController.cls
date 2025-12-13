public with sharing class WorkOrderFileUploaderController {
    @AuraEnabled
    public static void attachFilesToWorkOrder(List<FileDetails> fileDetails) {
        List<ContentDocumentLink> contentDocumentLinks = new List<ContentDocumentLink>();
        
        for (FileDetails fileDetail : fileDetails) {
            // Consulta para buscar a Ordem de Trabalho pelo número
            WorkOrder workOrder = [SELECT Id FROM WorkOrder WHERE WorkOrderNumber = :fileDetail.workOrderNumber LIMIT 1];
            
            if (workOrder != null) {
                // Cria um link entre o documento e a Ordem de Trabalho
                ContentDocumentLink cdl = new ContentDocumentLink();
                cdl.ContentDocumentId = fileDetail.fileId;
                cdl.LinkedEntityId = workOrder.Id;
                cdl.ShareType = 'V';
                cdl.Visibility = 'AllUsers';
                contentDocumentLinks.add(cdl);
            }
        }

        // Inserir os links de documentos em massa
        if (contentDocumentLinks.size() > 0) {
            insert contentDocumentLinks;
        }
    }

    // Classe interna para mapear os detalhes do arquivo
    public class FileDetails {
        @AuraEnabled public String fileId { get; set; }
        @AuraEnabled public String workOrderNumber { get; set; }
    }
}