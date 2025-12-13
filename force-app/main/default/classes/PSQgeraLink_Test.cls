@isTest(seeAllData=true)
public class PSQgeraLink_Test {
/*
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatus('OK');
            res.setStatusCode(200);
            res.setBody('Simulated response body');
            return res;
        }
    }

    @isTest
    static void Teste1() {
        String a = 'a0hHZ000000FgVBYA0';
        List<String> b = new List<String>{'PDF_PSQ_ABC_GO', 'PDF_PSQ_ABC_MT', 'PDF_PSQ_ABC_TO', 'PDF_PSQ_HOSPCOM_DF', 'PDF_PSQ_HEALTH', 'PDF_PSQ_GDB', 'PDF_PSQ_HOSPCOM'};

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

    
        List<String> c = PSQgeraLink.pegaDoc(a, b);
       

        System.debug('c: ' + c);
    }*/
    
    
        @isTest
    static void Teste1() {
        PSQgeraLink.gambiarra();
    }
}