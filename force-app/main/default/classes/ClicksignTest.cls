@isTest(seeAllData=true)
public class ClicksignTest {
  @isTest
    private static void teste(){
        
        Test.setMock(HttpCalloutMock.class, new MockClicksign());
        // Call method to test. 
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock.
        string ide = '0Q06e00000407WACAY';
        //Clicksign cs = new Clicksign();
        Clicksign.enviar(ide, 1, true);
        //Clicksign.cancelar(ide);
    }
    @isTest
    private static void teste_1_2(){
        
        Test.setMock(HttpCalloutMock.class, new MockClicksign());
        // Call method to test. 
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock.
        string ide = '0Q06e00000407WACAY';
        //Clicksign cs = new Clicksign();
        Clicksign.enviar(ide, 2, false);
        //Clicksign.cancelar(ide);
    }
    @isTest
    private static void teste2(){
        
        Test.setMock(HttpCalloutMock.class, new MockClicksign());
        // Call method to test. 
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock.
        string ide = '0Q06e00000407WACAY';
        //Clicksign cs = new Clicksign();
        Clicksign.consultar(ide);
        //Clicksign.cancelar(ide);
    }
    @isTest
    private static void teste3(){
        
        Test.setMock(HttpCalloutMock.class, new MockClicksign());
        // Call method to test. 
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock.
        string ide = '0Q06e00000407WACAY';
        //Clicksign cs = new Clicksign();
        //Clicksign.consultar(ide);
        Clicksign.cancelar(ide);
    }
    @isTest
    private static void testeLocacao(){
        
        Test.setMock(HttpCalloutMock.class, new MockClicksign());
        // Call method to test. 
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock.
        string ide = 'a1Y6e00000C3V6IEAV';
        //Clicksign cs = new Clicksign();
        Clicksign.enviarLocacao(ide,1);
        //Clicksign.cancelar(ide);
    }
    @isTest
    private static void testeLocacao4(){
        
        Test.setMock(HttpCalloutMock.class, new MockClicksign());
        // Call method to test. 
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock.
        string ide = 'a1Y6e00000C3V6IEAV';
        //Clicksign cs = new Clicksign();
        Clicksign.enviarLocacao(ide,2);
        //Clicksign.cancelar(ide);
    }
    @isTest
    private static void testeLocacao2(){
        
        Test.setMock(HttpCalloutMock.class, new MockClicksign());
        // Call method to test. 
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock.
        string ide = 'a1Y6e00000C3V6IEAV';
        //Clicksign cs = new Clicksign();
        Clicksign.consultarLocacao(ide);
        //Clicksign.cancelar(ide);
    }
    @isTest
    private static void testeLocacao3(){
        
        Test.setMock(HttpCalloutMock.class, new MockClicksign());
        // Call method to test. 
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock.
        string ide = 'a1Y6e00000C3V6IEAV';
        //Clicksign cs = new Clicksign();
        //Clicksign.consultar(ide);
        Clicksign.cancelarLocacao(ide);
    }
    @isTest
    private static void testeOT(){
        
        Test.setMock(HttpCalloutMock.class, new MockClicksign());
        // Call method to test. 
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock.
        string ide = '0WO6e000003gLIG';
        //Clicksign cs = new Clicksign();
        Clicksign.enviarOT(ide, 1);
        //Clicksign.cancelar(ide);
    }
    @isTest
    private static void testeOT2(){
        
        Test.setMock(HttpCalloutMock.class, new MockClicksign());
        // Call method to test. 
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock.
        string ide = '0WO6e000003gLIG';
        //Clicksign cs = new Clicksign();
        Clicksign.consultarOT(ide);
        //Clicksign.cancelar(ide);
    }
    @isTest
    private static void testeOT3(){
        
        Test.setMock(HttpCalloutMock.class, new MockClicksign());
        // Call method to test. 
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock.
        string ide = '0WO6e000003gLIG';
        //Clicksign cs = new Clicksign();
        //Clicksign.consultar(ide);
        Clicksign.cancelarOT(ide);
    }
    @isTest
    private static void testeDemo(){
        
        Test.setMock(HttpCalloutMock.class, new MockClicksign());
        // Call method to test. 
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock.
        string ide = '8016e000007y5WcAAI';
        //Clicksign cs = new Clicksign();
        Clicksign.enviarDemo(ide);
        //Clicksign.cancelar(ide);
    }
    @isTest
    private static void testeDemo2(){
        
        Test.setMock(HttpCalloutMock.class, new MockClicksign());
        // Call method to test. 
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock.
        string ide = '8016e000007y5WcAAI';
        //Clicksign cs = new Clicksign();
        Clicksign.consultarDemo(ide);
        //Clicksign.cancelar(ide);
    }
    @isTest
    private static void testeDemo3(){
        
        Test.setMock(HttpCalloutMock.class, new MockClicksign());
        // Call method to test. 
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock.
        string ide = '8016e000007y5WcAAI';
        //Clicksign cs = new Clicksign();
        //Clicksign.consultar(ide);
        Clicksign.cancelarDemo(ide);
    }
    @isTest
    private static void testeAditivo(){
        
        Test.setMock(HttpCalloutMock.class, new MockClicksign());
        // Call method to test. 
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock.
        string ide = 'a1j6e00000AoFQEAA3';
        //Clicksign cs = new Clicksign();
        Clicksign.enviarAditivo(ide);
        //Clicksign.cancelar(ide);
    }
    @isTest
    private static void testeAditivo2(){
        
        Test.setMock(HttpCalloutMock.class, new MockClicksign());
        // Call method to test. 
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock.
        string ide = 'a1j6e00000AoFQEAA3';
        //Clicksign cs = new Clicksign();
        Clicksign.consultarAditivo(ide);
        //Clicksign.cancelar(ide);
    }
    @isTest
    private static void testeAditivo3(){
        
        Test.setMock(HttpCalloutMock.class, new MockClicksign());
        // Call method to test. 
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock.
        string ide = 'a1j6e00000AoFQEAA3';
        //Clicksign cs = new Clicksign();
        //Clicksign.consultar(ide);
        Clicksign.cancelarAditivo(ide);
    }
        @isTest
    private static void testeTermo(){
        
        Test.setMock(HttpCalloutMock.class, new MockClicksign());
        // Call method to test. 
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock.
        string ide = '02iU4000000bd2P';
        //Clicksign cs = new Clicksign();
        Clicksign.enviarTermo(ide);
        //Clicksign.cancelar(ide);
    }
    @isTest
    private static void testeTermo2(){
        
        Test.setMock(HttpCalloutMock.class, new MockClicksign());
        // Call method to test. 
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock.
        string ide = '02iU4000000bd2P';
        //Clicksign cs = new Clicksign();
        Clicksign.consultarTermo(ide);
        //Clicksign.cancelar(ide);
    }
    @isTest
    private static void testeTermo3(){
        
        Test.setMock(HttpCalloutMock.class, new MockClicksign());
        // Call method to test. 
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock.
        string ide = '02iU4000000bd2P';
        //Clicksign cs = new Clicksign();
        //Clicksign.consultar(ide);
        Clicksign.cancelarTermo(ide);
    }
     @isTest
    private static void testeComodato(){
        
        Test.setMock(HttpCalloutMock.class, new MockClicksign());
        // Call method to test. 
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock.
        string ide = 'a0K6e00001ngJ4u';
        //Clicksign cs = new Clicksign();
        Clicksign.enviarComodato(ide);
        //Clicksign.cancelar(ide);
    }
    @isTest
    private static void testeComodato2(){
        
        Test.setMock(HttpCalloutMock.class, new MockClicksign());
        // Call method to test. 
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock.
        string ide = 'a0K6e00001ngJ4u';
        //Clicksign cs = new Clicksign();
        Clicksign.consultarComodato(ide);
        //Clicksign.cancelar(ide);
    }
    @isTest
    private static void testeComodato3(){
        
        Test.setMock(HttpCalloutMock.class, new MockClicksign());
        // Call method to test. 
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock.
        string ide = 'a0K6e00001ngJ4u';
        //Clicksign cs = new Clicksign();
        //Clicksign.consultar(ide);
        Clicksign.cancelarComodato(ide);
    }
    @isTest
    private static void testeCompra(){
        
        Test.setMock(HttpCalloutMock.class, new MockClicksign());
        // Call method to test. 
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock.
        string ide = 'a3AU40000000XK9';
        //Clicksign cs = new Clicksign();
        Clicksign.enviarCompra(ide, true);
        //Clicksign.cancelar(ide);
    }
    @isTest
    private static void testeCompra4(){
        
        Test.setMock(HttpCalloutMock.class, new MockClicksign());
        // Call method to test. 
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock.
        string ide = 'a3AU40000000XK9';
        //Clicksign cs = new Clicksign();
        Clicksign.enviarCompra(ide, false);
        //Clicksign.cancelar(ide);
    }
    @isTest
    private static void testeCompra2(){
        
        Test.setMock(HttpCalloutMock.class, new MockClicksign());
        // Call method to test. 
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock.
        string ide = 'a3AU40000000XK9';
        //Clicksign cs = new Clicksign();
        Clicksign.consultarCompra(ide);
        //Clicksign.cancelar(ide);
    }
    @isTest
    private static void testeCompra3(){
        
        Test.setMock(HttpCalloutMock.class, new MockClicksign());
        // Call method to test. 
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock.
        string ide = 'a3AU40000000XK9';
        //Clicksign cs = new Clicksign();
        //Clicksign.consultar(ide);
        Clicksign.cancelarCompra(ide);
    }
     @isTest
    private static void testeAditivoCompra(){
        
        Test.setMock(HttpCalloutMock.class, new MockClicksign());
        // Call method to test. 
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock.
        string ide = 'a3CU4000000zUZ5';
        //Clicksign cs = new Clicksign();
        Clicksign.enviarAditivoCompra(ide);
        //Clicksign.cancelar(ide);
    }
    @isTest
    private static void testeAditivoCompra2(){
        
        Test.setMock(HttpCalloutMock.class, new MockClicksign());
        // Call method to test. 
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock.
        string ide = 'a3CU4000000zUZ5';
        //Clicksign cs = new Clicksign();
        Clicksign.consultarAditivoCompra(ide);
        //Clicksign.cancelar(ide);
    }
    @isTest
    private static void testeAditivoCompra3(){
        
        Test.setMock(HttpCalloutMock.class, new MockClicksign());
        // Call method to test. 
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock.
        string ide = 'a3CU4000000zUZ5';
        //Clicksign cs = new Clicksign();
        //Clicksign.consultar(ide);
        Clicksign.cancelarAditivoCompra(ide);
    }
    @isTest
    private static void testeAditivoComodato(){
        
        Test.setMock(HttpCalloutMock.class, new MockClicksign());
        // Call method to test. 
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock.
        string ide = 'a2FU4000000hn0f';
        //Clicksign cs = new Clicksign();
        Clicksign.enviarAditivoComodato(ide);
        //Clicksign.cancelar(ide);
    }
    @isTest
    private static void testeAditivoComodato2(){
        
        Test.setMock(HttpCalloutMock.class, new MockClicksign());
        // Call method to test. 
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock.
        string ide = 'a2FU4000000hn0f';
        //Clicksign cs = new Clicksign();
        Clicksign.consultarAditivoComodato(ide);
        //Clicksign.cancelar(ide);
    }
    @isTest
    private static void testeAditivoComodato3(){
        
        Test.setMock(HttpCalloutMock.class, new MockClicksign());
        // Call method to test. 
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock.
        string ide = 'a2FU4000000hn0f';
        //Clicksign cs = new Clicksign();
        //Clicksign.consultar(ide);
        Clicksign.cancelarAditivoComodato(ide);
    }
    @isTest
    private static void testeCtrFornec(){
        
        Test.setMock(HttpCalloutMock.class, new MockClicksign());
        // Call method to test. 
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock.
        string ide = 'a0fU4000009WDOL';
        //Clicksign cs = new Clicksign();
        Clicksign.enviarContratoFornecimento(ide);
        //Clicksign.cancelar(ide);
    }
    @isTest
    private static void testeCtrFornec2(){
        
        Test.setMock(HttpCalloutMock.class, new MockClicksign());
        // Call method to test. 
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock.
        string ide = 'a0fU4000009WDOL';
        //Clicksign cs = new Clicksign();
        Clicksign.consultarContratoFornecimento(ide);
        //Clicksign.cancelar(ide);
    }
    @isTest
    private static void testeCtrFornec3(){
        
        Test.setMock(HttpCalloutMock.class, new MockClicksign());
        // Call method to test. 
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock.
        string ide = 'a0fU4000009WDOL';
        //Clicksign cs = new Clicksign();
        //Clicksign.consultar(ide);
        Clicksign.cancelarContratoFornecimento(ide);
    }
}