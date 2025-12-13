@IsTest(SeeAllData=true)
public class vinculaConsumiveisTest {
    @IsTest
    public static void testSendSelectedItems() {
        // IDs de teste
        String comodatoItemId = 'a0MU4000001AKWL';
        List<String> orderItemIds = new List<String> {'802U400000odAFy', '802U400000odAFz'};
            
            // Chamada do método a ser testado
            Test.startTest();
        vinculaConsumiveis.sendSelectedItems(comodatoItemId, orderItemIds, 1);
        Test.stopTest();
        
        // Verificação dos resultados (se aplicável)
        // Aqui você pode adicionar verificações baseadas no que seu método sendSelectedItems faz.
        // Por exemplo, se ele cria registros ou atualiza dados, você pode verificar essas alterações.
        
        System.debug('Teste executado com sucesso.');
    }
    @IsTest
    public static void testSendSelectedItems2() {
        // IDs de teste
        String comodatoItemId = 'a0MU4000001AKWL';
        List<String> orderItemIds = new List<String> {'a39U4000000nKTp'};
            
            // Chamada do método a ser testado
            Test.startTest();
        vinculaConsumiveis.sendSelectedItems2(comodatoItemId, orderItemIds, 2);
        Test.stopTest();
        
        // Verificação dos resultados (se aplicável)
        // Aqui você pode adicionar verificações baseadas no que seu método sendSelectedItems faz.
        // Por exemplo, se ele cria registros ou atualiza dados, você pode verificar essas alterações.
        
        System.debug('Teste executado com sucesso.');
    }
}