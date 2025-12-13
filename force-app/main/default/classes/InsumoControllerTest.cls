@isTest(seeAllData=true)
public class InsumoControllerTest {
    @isTest
    private static void teste1(){
        InsumoController.searchProducts('01tU4000003kIGL');
    }
    @isTest
    private static void teste2(){
        String productData = '[{"Id":"01tU4000004xPg3","quantity":10,"value":99.99},' +
            '{"Id":"01t6e000009etbd","quantity":5,"value":49.99}]';
        
        InsumoController.sendSelectedProducts(productData, 'a0fU4000009WDOL');
    }
}