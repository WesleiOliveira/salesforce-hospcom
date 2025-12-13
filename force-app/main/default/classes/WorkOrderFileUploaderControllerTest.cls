@IsTest(SeeAllData=true)
public class WorkOrderFileUploaderControllerTest {
    
    @IsTest
    public static void testAttachFilesToWorkOrder() {
        // ID do WorkOrderNumber e FileId existentes para teste
        String workOrderNumber = '00028162';
        String fileId = '069U400000CNfA6IAL';
        
        // Criação de uma lista de FileDetails
        List<WorkOrderFileUploaderController.FileDetails> fileDetailsList = new List<WorkOrderFileUploaderController.FileDetails>();
        
        WorkOrderFileUploaderController.FileDetails fileDetail = new WorkOrderFileUploaderController.FileDetails();
        fileDetail.workOrderNumber = workOrderNumber;
        fileDetail.fileId = fileId;
        
        fileDetailsList.add(fileDetail);
        
        // Chamar o método do controlador para anexar arquivos à WorkOrder
        Test.startTest();
        WorkOrderFileUploaderController.attachFilesToWorkOrder(fileDetailsList);
        Test.stopTest();
        
        // Verificar se o ContentDocumentLink foi criado corretamente
        WorkOrder workOrder = [SELECT Id FROM WorkOrder WHERE WorkOrderNumber = :workOrderNumber LIMIT 1];
        ContentDocumentLink cdl = [SELECT Id, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId = :workOrder.Id LIMIT 1];
        
        System.assertEquals(fileId, cdl.ContentDocumentId);
        System.assertEquals(workOrder.Id, cdl.LinkedEntityId);
    }
}