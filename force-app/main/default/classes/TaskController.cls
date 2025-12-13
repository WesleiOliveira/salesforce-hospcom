public with sharing class TaskController {
    
    @AuraEnabled
    public static Map<String, Object> getTaskDetails(Id taskId) {
        
        Task task = [SELECT Id, OwnerId, Data_interna__c, Id_gestor__c
                     FROM Task 
                     WHERE Id = :taskId LIMIT 1];
        
        User currentUser = [SELECT Id, ProfileId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        
        Boolean podeEditar = (task.OwnerId == UserInfo.getUserId()) || 
            (currentUser.ProfileId == '00ei0000000nKA9') ||  
            (currentUser.Id == task.Id_gestor__c); 
        
        
            return new Map<String, Object>{
                'task' => task,
                    'podeEditar' => podeEditar 
                    };
      }
    
    @AuraEnabled
    public static void updateTaskInternalDate(Id taskId, Date newDate) {
        Task task = [SELECT Id, Data_interna__c FROM Task WHERE Id = :taskId LIMIT 1];
        task.Data_interna__c = newDate;
        update task;
    } 
}