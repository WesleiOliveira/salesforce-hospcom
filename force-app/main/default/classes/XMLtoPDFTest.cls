@IsTest(seeAllData=true)
private class XMLtoPDFTest {
    
    @IsTest
    static void testFetchAndSavePdfSuccess() {
        // Cria um mock para a resposta HTTP que a classe PdfApiHandler espera
        String mockBase64Pdf = 'JVBERi0xLjQKJcfsj6IKNCAwIG9iago8PC9MZW5ndGggMTIzND4+CnN0cmVhbQp4nFVWT+pyVRDbP3PPOHbqZh5OFgbflHEJFQ4byJ5Qp9uBeKFboQKaQg1K3p8vyf56nwCpFT4uFA3mST7gP02BsfJK' +
            '5x+7DeqPvB+uwPvB7zrnviU7H+buTuq6X4mfgPKowNyo/l+1f/g/nC5eTOg/kB4K8AhU+AX7/QNVv1gv1kgrX5l/YUfn7eXYz8y80edpX52rfzw3rmL/HdQ3hWeYXmUfiX5i9Yv3K36KP/A5/lffZ3jf0'+
            'fH/77wz/IzOX2f7eZ3fn5wn5oXzr9rf/a/6/bX/Xfzrf7c5fvpUwr8X/B+nB+eT9of7a/Xfzrf+f+X/bd/80PlVPl+YJpBmD0gKIDw4MCgoyMjMKZW5kc3RyZWFtCmVuZG9iagp4cmVmCjAgNDkKMDAwMDA' +
            'wMDAxMCAwMDAwMCBuCjAwMDAwMDAwMzYgMDAwMDAgbgoKdHJhaWxlcgo8PC9TaXplIDEwPj4Kc3RhcnR4cmVmCjQwCiUlRU9GCg==';
        
        // Configura o mock da resposta HTTP
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(mockBase64Pdf));
        
        // Chama o método que você deseja testar
        String documentUrl = XMLtoPDF.salvaDANFE('a3RU40000008KXq');
        // Verifica se o documento foi criado e a URL foi retornada
        System.assertNotEquals(null, documentUrl);
        System.assert(documentUrl.contains('/servlet/servlet.FileDownload?file='), 'URL deve conter /servlet/servlet.FileDownload?file=');
        
        // Verifica se o documento foi realmente inserido
        Document[] docs = [SELECT Id, Name FROM Document WHERE Name LIKE 'Arquivo PDF NF 35259%'];
        System.assertEquals(1, docs.size());
        System.assert(docs[0].Name.startsWith('Arquivo PDF NF '), 'O nome do documento deve começar com "Arquivo PDF NF "');
    }
    
    @IsTest
    static void testFetchAndSavePdfSuccess2() {
        // Cria um mock para a resposta HTTP que a classe PdfApiHandler espera
        String mockBase64Pdf = 'PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiPz4KPENvbXBOZnNlIHhtbG5zPSJodHRwOi8vd3d3LmFicmFzZi5vcmcuYnIvbmZzZS54c2QiPjxOZnNlIHZlcnNhbz0iMi4wMiI+PEluZk5mc2UgSWQ9Ik5GUzUyMDg3MDcyMjQ5NDk0MTYwMDAwMTIzMDAwMDAwMDAwMDIwNzI0MDg3NzA3NTg3NzE5Ij48TnVtZXJvPjIwNzwvTnVtZXJvPjxDb2RpZ29WZXJpZmljYWNhbz5ORlM1MjA4NzA3MjI0OTQ5NDE2MDAwMDEyMzAwMDAwMDAwMDAyMDcyNDA4NzcwNzU4NzcxOTwvQ29kaWdvVmVyaWZpY2FjYW8+PERhdGFFbWlzc2FvPjIwMjQtMDgtMjdUMTY6NDY6MzY8L0RhdGFFbWlzc2FvPjxWYWxvcmVzTmZzZT48VmFsb3JMaXF1aWRvTmZzZT40MDAuMDA8L1ZhbG9yTGlxdWlkb05mc2U+PC9WYWxvcmVzTmZzZT48UHJlc3RhZG9yU2Vydmljbz48SWRlbnRpZmljYWNhb1ByZXN0YWRvcj48Q3BmQ25waj48Q25waj40OTQ5NDE2MDAwMDEyMzwvQ25waj48L0NwZkNucGo+PC9JZGVudGlmaWNhY2FvUHJlc3RhZG9yPjxSYXphb1NvY2lhbD40OS40OTQuMTYwIFZBTERJUiBERSBQQVVMQTwvUmF6YW9Tb2NpYWw+PEVuZGVyZWNvPjxFbmRlcmVjbz5JUElSQU5HQTwvRW5kZXJlY28+PE51bWVybz4xOTc8L051bWVybz48QmFpcnJvPkpBUkRJTSBHVUFOQUJBUkE8L0JhaXJybz48Q29kaWdvTXVuaWNpcGlvPjUyMDg3MDc8L0NvZGlnb011bmljaXBpbz48VWY+R088L1VmPjxDZXA+NzQ2NzU0MDA8L0NlcD48L0VuZGVyZWNvPjxDb250YXRvPjxUZWxlZm9uZT42Mjk5MjEyNDc0NzwvVGVsZWZvbmU+PEVtYWlsPm1hcnRhY2FybGFmcmVpdGFzMDEwQGdtYWlsLmNvbTwvRW1haWw+PC9Db250YXRvPjwvUHJlc3RhZG9yU2Vydmljbz48T3JnYW9HZXJhZG9yPjxDb2RpZ29NdW5pY2lwaW8+NTIwODcwNzwvQ29kaWdvTXVuaWNpcGlvPjwvT3JnYW9HZXJhZG9yPjxEZWNsYXJhY2FvUHJlc3RhY2FvU2Vydmljbz48SW5mRGVjbGFyYWNhb1ByZXN0YWNhb1NlcnZpY28gSWQ9IkRQUzUyMDg3MDcyNDk0OTQxNjAwMDAxMjMwMDkwMDAwMDAwMDAwMDAwMDI0NCI+PFJwcyBJZD0iRFBTNTIwODcwNzI0OTQ5NDE2MDAwMDEyMzAwOTAwMDAwMDAwMDAwMDAwMjQ0Ij48SWRlbnRpZmljYWNhb1Jwcz48TnVtZXJvPjI0NDwvTnVtZXJvPjxTZXJpZT45MDA8L1NlcmllPjwvSWRlbnRpZmljYWNhb1Jwcz48RGF0YUVtaXNzYW8+MjAyNC0wOC0yNzwvRGF0YUVtaXNzYW8+PFN0YXR1cz4xPC9TdGF0dXM+PC9ScHM+PENvbXBldGVuY2lhPjIwMjQtMDgtMjc8L0NvbXBldGVuY2lhPjxTZXJ2aWNvPjxWYWxvcmVzPjxWYWxvclNlcnZpY29zPjQwMC4wMDwvVmFsb3JTZXJ2aWNvcz48L1ZhbG9yZXM+PElzc1JldGlkbz4yPC9Jc3NSZXRpZG8+PEl0ZW1MaXN0YVNlcnZpY28+MDcwOTwvSXRlbUxpc3RhU2Vydmljbz48RGlzY3JpbWluYWNhbz5sb2NhY2FvIGRlIGNhY2FtYmE8L0Rpc2NyaW1pbmFjYW8+PENvZGlnb011bmljaXBpbz41MjA4NzA3PC9Db2RpZ29NdW5pY2lwaW8+PENvZGlnb1BhaXM+MTA1ODwvQ29kaWdvUGFpcz48RXhpZ2liaWxpZGFkZUlTUz4xPC9FeGlnaWJpbGlkYWRlSVNTPjxNdW5pY2lwaW9JbmNpZGVuY2lhPjUyMDg3MDc8L011bmljaXBpb0luY2lkZW5jaWE+PC9TZXJ2aWNvPjxQcmVzdGFkb3I+PENwZkNucGo+PENucGo+NDk0OTQxNjAwMDAxMjM8L0NucGo+PC9DcGZDbnBqPjwvUHJlc3RhZG9yPjxUb21hZG9yPjxJZGVudGlmaWNhY2FvVG9tYWRvcj48Q3BmQ25waj48Q25waj4wNTc0MzI4ODAwMDEwODwvQ25waj48L0NwZkNucGo+PC9JZGVudGlmaWNhY2FvVG9tYWRvcj48UmF6YW9Tb2NpYWw+SE9TUENPTSBFUVVJUEFNRU5UT1MgSE9TUElUQUxBUkVTIExUREE8L1JhemFvU29jaWFsPjxFbmRlcmVjbz48RW5kZXJlY28+MTA0PC9FbmRlcmVjbz48TnVtZXJvPjc0PC9OdW1lcm8+PEJhaXJybz5TRVRPUiBTVUw8L0JhaXJybz48Q29kaWdvTXVuaWNpcGlvPjUyMDg3MDc8L0NvZGlnb011bmljaXBpbz48Q2VwPjc0MDgzMzAwPC9DZXA+PC9FbmRlcmVjbz48L1RvbWFkb3I+PFJlZ2ltZUVzcGVjaWFsVHJpYnV0YWNhbz4wPC9SZWdpbWVFc3BlY2lhbFRyaWJ1dGFjYW8+PE9wdGFudGVTaW1wbGVzTmFjaW9uYWw+MTwvT3B0YW50ZVNpbXBsZXNOYWNpb25hbD48SW5jZW50aXZvRmlzY2FsPjI8L0luY2VudGl2b0Zpc2NhbD48L0luZkRlY2xhcmFjYW9QcmVzdGFjYW9TZXJ2aWNvPjwvRGVjbGFyYWNhb1ByZXN0YWNhb1NlcnZpY28+PC9JbmZOZnNlPjwvTmZzZT48L0NvbXBOZnNlPg==';
        
        // Configura o mock da resposta HTTP
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(mockBase64Pdf));
        
        // Chama o método que você deseja testar
        String documentUrl = XMLtoPDF.salvaDANFE('a3RU40000008KWE');
        // Verifica se o documento foi criado e a URL foi retornada
        System.assertNotEquals(null, documentUrl);
        System.assert(documentUrl.contains('/servlet/servlet.FileDownload?file='), 'URL deve conter /servlet/servlet.FileDownload?file=');
        
        // Verifica se o documento foi realmente inserido
        Document[] docs = [SELECT Id, Name FROM Document WHERE Name LIKE 'Arquivo PDF NFS 207%'];
        System.assertEquals(1, docs.size());
        System.assert(docs[0].Name.startsWith('Arquivo PDF NFS '), 'O nome do documento deve começar com "Arquivo PDF NFS "');
    }
    
    // Classe interna para mock de respostas HTTP
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        String base64Response;
        
        MockHttpResponseGenerator(String base64Response) {
            this.base64Response = base64Response;
        }
        
        public HTTPResponse respond(HTTPRequest req) {
            // Cria uma resposta HTTP simulada
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(base64Response);
            res.setStatusCode(200);
            return res;
        }
    }
    @IsTest
    static void lanca(){
        XMLtoPDF.lancaNota('a3RU40000008KXq', 'a1bU4000002zxy5');
    }
    @IsTest
    static void lancaContrato(){
        try{
            XMLtoPDF.lancaNotaContrato('a3RU40000008KXq', 'a3A6e000007TbWa');
        }
        catch(Exception e){
            system.debug(e.getMessage());
        }
    }
}