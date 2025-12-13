public class pdfEvento {
    public Campaign evento {get;set;}
    public boolean contido {get;set;}
    public List<Gest_o_de_Documentos__c> documentos {get; set;}
    public List<Id> contatos = new List<Id>();
    
    public pdfEvento(ApexPages.StandardController controller) {
        
        documentos = GestaoDocumentos.obterDocumentosVigentes();       
        User usuario = [SELECT ContactId, ProfileId FROM User WHERE Id =: UserInfo.getUserId()];
        Id contactId = usuario.ContactId;
        contido = false;
        
        List<Membro_Interno_do_Evento__c> membros = [SELECT Contato__c FROM Membro_Interno_do_Evento__c WHERE Evento__c =: ((SObject)controller.getRecord()).Id];
        if(membros.size()>0){
            for(Membro_Interno_do_Evento__c membro : membros){
                contatos.add(membro.Contato__c);       
            }
            if(contatos.contains(contactId) || usuario.ProfileId == '00ei0000000nKA9' || usuario.ProfileId == '00e31000001dwIY'){
                contido = true;
            }
        }
        else{
            if(usuario.ProfileId == '00ei0000000nKA9' || usuario.ProfileId == '00e31000001dwIY'){
                contido = true;
            }

        }
    }
}