trigger criaVendedorSAPTrigger on User (after insert) {
    Id specificProfileId = '00e6e000002JQQs';

    // Itera sobre os usuários recém-criados
    for (User user : Trigger.New) {
        // Verifica se o usuário foi criado com o perfil ou departamento específico
        if (user.ProfileId == specificProfileId || user.Departamento3__c == 'Compras' || user.Departamento3__c == 'Serviço') {
            // Chama a classe que faz a chamada ao endpoint
            criaVendedorSAP.callEndpoint(user.Id);
        }
    }
}