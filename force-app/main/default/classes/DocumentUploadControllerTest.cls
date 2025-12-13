@IsTest(seealldata=true)
public class DocumentUploadControllerTest {

    
    @IsTest
    static void testUploadDocuments() {
        // Prepara os arquivos em Base64
        String fileContent1 = EncodingUtil.base64Encode(Blob.valueOf('Test PDF 1'));
        String fileContent2 = EncodingUtil.base64Encode(Blob.valueOf('Test PDF 2'));
        
        List<Map<String, String>> fileList = new List<Map<String, String>>();
        
        Map<String, String> file1 = new Map<String, String>();
        file1.put('fileName', '00028162.pdf');
        file1.put('content', fileContent1);
        
      
        
        fileList.add(file1);

        // Chamada ao método uploadDocuments
        Test.startTest();
        DocumentUploadController.uploadDocuments(JSON.serialize(fileList), null);
        Test.stopTest();



    }
}