public class DocumentUploadController {
    @AuraEnabled
    public static void uploadDocuments(String files, Id recordId) {
        List<Map<String, String>> fileList = (List<Map<String, String>>) JSON.deserialize(files, List<Map<String, String>>.class);
        
        for (Map<String, String> fileData : fileList) {
            String fileName = fileData.get('fileName');
            String base64Content = fileData.get('content');
            Blob fileBlob = EncodingUtil.base64Decode(base64Content);

            // Extrai o número da OT do nome do arquivo
            String workOrderNumber = fileName.replace('.pdf', '');
            
            // Consulta a OT com base no número (supondo que esse número está em um campo customizado na OT)
            WorkOrder ot = [SELECT Id FROM WorkOrder WHERE WorkOrderNumber = :workOrderNumber LIMIT 1];
            
            if (ot != null) {
                // Cria o anexo
                Attachment att = new Attachment();
                att.ParentId = ot.Id; // Associa ao registro OT
                att.Name = fileName;
                att.Body = fileBlob;
                att.ContentType = 'application/pdf';
                insert att;
            }
        }
    }
}