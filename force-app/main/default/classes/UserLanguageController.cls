public with sharing class UserLanguageController {
    @AuraEnabled
    public static void updateUserLanguage(String userId, String languageLocaleKey) {

        User userToUpdate = [SELECT Id, LanguageLocaleKey FROM User WHERE Id = :userId LIMIT 1];
        userToUpdate.LanguageLocaleKey = languageLocaleKey;
        
        update userToUpdate;
    }
}