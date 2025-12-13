@isTest(seeAllData=true)
public with sharing class ClonagemPedidosTest {
    
    @isTest
    public static void testClonagem(){

        Test.startTest();
        ClonagemPedidos.clonaPedido('8016e00000803mxAAA', '31/01/2026', '');
        ClonagemPedidos.clonaItemPedido('8016e00000803mxAAA');
        Test.stopTest();
    }

}