@isTest(seeAllData=true)
public class PesquisaSatisfTest {
	@isTest static void testCallout() {
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new MockPesquisaSatisf());
        
        // Call method to test.
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock. 
        PesquisaSatisf.enviar('8016e000005K45R');
        PesquisaSatisf.enviar('8016e000005IsJT');
        PesquisaSatisf.enviarSERV('0WO5A000000jjjX');
        PesquisaSatisf.enviarLOCAC('a1Y5A000009wdBY');
        
        // Verify response received contains fake values
        
}
}