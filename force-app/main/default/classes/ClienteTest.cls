@isTest(seeAllData=true)
public class ClienteTest {

    @isTest
    private static void teste2() {
         Cliente.gambiarra();
        List<Account> a = [SELECT ID, Name, CNPJ__c, Data_do_Ultimo_Pedido__c, Data_da_Ultima_Venda__c FROM Account WHERE CNPJ__c != '' LIMIT 1];

        if (!a.isEmpty()) {
            String b = a[0].CNPJ__c;
            String c = Cliente.maisInformacoesDaEmpresaCliente(b);
            System.debug('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa: ' + c);
        } else {
            String b = '12121312';
            String c = Cliente.maisInformacoesDaEmpresaCliente(b);
            System.debug('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa: ' + c);
        }

        Test.setMock(HttpCalloutMock.class, new MockClient());

        String cidade2 = 'Goiânia';
        String estado2 = 'GO';
        Integer e2 = 1;
        try {
           
            String result2 = Cliente.procuraCidadeSemCriarNovaConta(cidade2, e2);
            String result3 = Cliente.procuraGeral(e2);
            //Cliente.consultaEmpresasAPI(cidade2, estado2,10, false);
        } catch (Exception d) {
            System.debug('errrrrouuueee' + d);
        }
    }

    @isTest
    static void testGetLatLongFromAddress() {
        
        GoogleGeocodingService.gambiarra();
  

        // Add assertions here if needed
    }
}