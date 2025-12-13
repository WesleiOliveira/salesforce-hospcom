@IsTest(seeAllData=true)
public class criaVendedorSAPTest {

    @IsTest
    static void testUserProfileTrigger() {
        // Define o mock para simular a resposta da chamada HTTP
        Test.setMock(HttpCalloutMock.class, new MockCriaVendedorSAP());
        
        // Define o ID do perfil de teste
        Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'Executivo de Contas' LIMIT 1];

        // Simula a criação de um novo usuário com o perfil específico
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'testuser@example.com',
            Username = 'testuser' + DateTime.now().getTime() + '@example.com',
            Alias = 'tuser',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = testProfile.Id,
            ContactId = '0036e00003y21MU'
        );

        Test.startTest();
        insert testUser;
        Test.stopTest();

        // Verifica se o usuário foi criado com o perfil correto
        User insertedUser = [SELECT Id, ProfileId FROM User WHERE Id = :testUser.Id];
        System.assertEquals(testProfile.Id, insertedUser.ProfileId);
    }
}