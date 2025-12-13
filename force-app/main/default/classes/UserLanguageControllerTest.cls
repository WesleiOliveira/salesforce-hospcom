@IsTest(SeeAllData=true)
public class UserLanguageControllerTest {
    @IsTest
    static void testUpdateUserLanguage() {
        // Obtém um usuário já existente no sistema
        User existingUser = [SELECT Id, LanguageLocaleKey FROM User LIMIT 1];

        // Executa o método para atualizar o idioma
        Test.startTest();
        UserLanguageController.updateUserLanguage(existingUser.Id, 'pt_BR');
        Test.stopTest();

        // Verifica se o idioma foi atualizado corretamente
        User updatedUser = [SELECT LanguageLocaleKey FROM User WHERE Id = :existingUser.Id];
        System.assertEquals('pt_BR', updatedUser.LanguageLocaleKey, 'O idioma do usuário deve ser atualizado para pt_BR.');
    }
}