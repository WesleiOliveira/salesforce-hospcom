@isTest
public class ObtemPesquisasTest {
	@isTest static void testCallout() {
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        // Call method to test.
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock. 
       ObtemPesquisas.busca();
        
        // Verify response received contains fake values
        
}
    @isTest static void testCallout2() {
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator2());
        
        // Call method to test.
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock. 
       ObtemPesquisas.buscaDepServicos();
        
        // Verify response received contains fake values
        
}
    @isTest static void testCallout3() {
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator3());
        
        // Call method to test.
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock. 
       ObtemPesquisas.buscaDepLocacao();
        
        // Verify response received contains fake values
        
}
}