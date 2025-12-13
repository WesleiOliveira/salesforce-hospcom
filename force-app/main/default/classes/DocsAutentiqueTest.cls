@isTest
public class DocsAutentiqueTest {
	@isTest static void testCallout() {
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new MockDocsAutentique());
        
        // Call method to test.
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock. 
       DocsAutentique.busca();
}
}