trigger copiaFoto on User (after update) {
    // Usar um conjunto para garantir que os usuários sejam atualizados apenas uma vez
    Set<Id> userIds = new Set<Id>();
    for (User usuario : Trigger.new) {
        userIds.add(usuario.Id);
    }

    // Realizar uma única consulta SOQL para obter os usuários atualizados
    List<User> usersToUpdate = [SELECT Id, MediumPhotoUrl, URL_Foto__c FROM User WHERE Id IN :userIds and IsActive = true];

    // Criar uma lista para armazenar os usuários que precisam ser atualizados
    List<User> usersToSave = new List<User>();

    for (User usu : usersToUpdate) {
        // Verificar se o campo precisa ser atualizado
        if (usu.URL_Foto__c != usu.MediumPhotoUrl) {
            usu.URL_Foto__c = usu.MediumPhotoUrl;
            usersToSave.add(usu);
        }
    }

    // Tentar atualizar os usuários fora do loop
    try {
        if (!usersToSave.isEmpty()) {
            update usersToSave;
        }
    } catch (Exception e) {
        System.debug(e.getMessage());
    }
}