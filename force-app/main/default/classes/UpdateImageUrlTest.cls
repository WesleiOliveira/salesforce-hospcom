/*@isTest
public class UpdateImageUrlTest {
@isTest
static void testUpdateImageUrl_InvalidId() {
    Boolean exceptionThrown = false;
    try {
        Test.startTest();
        // Passa um ID inválido
        UpdateImageUrlClass.updateImageUrl('a0HU4000000ddUXMAY', 'https://exemplo.com/erro.jpg');
        Test.stopTest();
    } catch (Exception e) { 
        exceptionThrown = true;
        System.debug('Exceção capturada: ' + e.getMessage()); // Para diagnóstico
    }
    
    // Assegura que uma exceção foi lançada
    System.assert(exceptionThrown, 'Nenhuma exceção foi lançada, mas era esperada.');
}

}*/
@isTest
public class UpdateImageUrlTest {

    @isTest
    static void testUpdateImageUrl_InvalidId() {
        Boolean exceptionThrown = false;
        try {
            Test.startTest();
            // Passa um ID inválido
            UpdateImageUrlClass.updateImageUrl('a0HU4000000ddUXMAY', 'https://exemplo.com/erro.jpg');
            Test.stopTest();
        } catch (Exception e) { 
            exceptionThrown = true;
            System.debug('Exceção capturada: ' + e.getMessage()); // Para diagnóstico
        }
        
        // Assegura que uma exceção foi lançada
        System.assert(exceptionThrown, 'Nenhuma exceção foi lançada, mas era esperada.');
    }

    @isTest
    static void testUpdateImageUrl_ValidId() {
        // Cria um registro válido de Comunicado__c
        Comunicado__c comunicado = new Comunicado__c(Titulo__c = 'Teste');
        insert comunicado;

        // URL de teste
        String newImageUrl = 'https://exemplo.com/imagem.jpg';

        Test.startTest();
        // Chama o método para atualizar a URL
        UpdateImageUrlClass.updateImageUrl(comunicado.Id, newImageUrl);
        Test.stopTest();

        // Consulta o registro atualizado
        Comunicado__c updatedComunicado = [SELECT Id, Link_da_imagem__c FROM Comunicado__c WHERE Id = :comunicado.Id];

        // Verifica se a URL foi corretamente atualizada
        System.assertEquals(newImageUrl, updatedComunicado.Link_da_imagem__c, 'A URL da imagem não foi atualizada corretamente.');
    }

    @isTest
    static void testUpdateImageUrl_NullValues() {
        Boolean exceptionThrown = false;
        try {
            Test.startTest();
            UpdateImageUrlClass.updateImageUrl(null, null);
            Test.stopTest();
        } catch (Exception e) {
            exceptionThrown = true;
            System.debug('Exceção capturada: ' + e.getMessage());
        }

        System.assert(exceptionThrown, 'Nenhuma exceção foi lançada para valores nulos.');
    }
}

/*@isTest
public class UpdateImageUrlTest {

    @testSetup
    static void setupTestData() {
        // Cria um registro de teste em Comunicados__c
        Comunicado__c comunicado = new Comunicado__c(
            Titulo__c = 'Teste de Imagem',
            Link_da_imagem__c = 'https://exemplo.com/imagem_inicial.jpg'
        );
        insert comunicado;
    }

    @isTest
    static void testUpdateImageUrl() {
        // Obtém o registro criado no método @testSetup
        Comunicado__c comunicado = [SELECT Id, Link_da_Imagem__c FROM Comunicado__c LIMIT 1];

        // Chama o método a ser testado
        Test.startTest();
        UpdateImageUrlClass.updateImageUrl(comunicado.Id, 'https://exemplo.com/nova_imagem.jpg');
        Test.stopTest();

        // Busca o registro atualizado
        Comunicado__c updatedComunicado = [SELECT Id, Link_da_Imagem__c FROM Comunicado__c WHERE Id = :comunicado.Id];

        // Verifica se o campo foi atualizado corretamente
        System.assertEquals('https://exemplo.com/nova_imagem.jpg', updatedComunicado.Link_da_Imagem__c, 'A URL da imagem não foi atualizada corretamente.');
    }

    @isTest
    static void testUpdateImageUrl_InvalidId() {
        // Testa a função com um ID inexistente para garantir que a exceção seja lançada
        //try {
            Test.startTest();
            // Usando um ID aleatório que não existe para garantir que a exceção seja lançada
            UpdateImageUrlClass.updateImageUrl('a0HU4000000ddUXMAY', 'https://exemplo.com/erro.jpg');
            Test.stopTest();
            System.assert(false, 'Esperava uma exceção, mas o código foi executado sem erro.');
        //} catch (AuraHandledException e) {
         //   System.assert(e.getMessage().contains('Erro ao atualizar o campo'), 'A exceção não foi lançada corretamente.');
      //  }
    }
}*/