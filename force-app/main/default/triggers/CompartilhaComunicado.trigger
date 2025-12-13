trigger CompartilhaComunicado on Comunicado__c (after insert, after update) {
    List<Comunicado__Share> cs = new List<Comunicado__Share>();
    List<String> departamentos = new List<String>();
    Id proprietario;
    Id idComunicado = null;
    
    for(Comunicado__c comunicado : trigger.new){
        if(!String.isBlank(comunicado.Departamentos__c)){
            departamentos = comunicado.Departamentos__c.split(';');
            proprietario = comunicado.OwnerId;
        }
        idComunicado = comunicado.Id;
    }
    if(departamentos.size()>0){
        List<User> usuarios = [SELECT ID FROM USER WHERE Departamento3__c IN : departamentos AND IsActive = true AND ProfileId != '00ei0000000nKA9' AND ID != : proprietario AND Profile.UserLicense.Name = 'Partner Community'];
        
        for(User usuario : usuarios){
            Comunicado__Share comunicadoShare = new Comunicado__Share();
            comunicadoShare.AccessLevel = 'Edit';
            comunicadoShare.UserOrGroupId = usuario.Id;
            comunicadoShare.ParentId = idComunicado;
            cs.add(comunicadoShare);
        }
        if(cs.size()>0){
            insert cs;
        }
    }
}