public class compromissoController {
    
    @AuraEnabled
    public static void atualizaCompromisso(String eventoId, Boolean checkInRealizado, String justificativa, String image, String name, String dataType, String contentType, String folderName, String feedback, String contatoTratado) {
        
        List <Event> evento = [SELECT Id FROM Event WHERE Id = :eventoId];
        
        system.debug(evento);
        system.debug(evento.size());
        String urlImagem = ImageDocument.insertImage(image, name, dataType, contentType, folderName);
		
        if (evento.size() > 0) {
            // Atualize os campos com os novos valores
            evento[0].checkInRealizado__c = checkInRealizado;
            evento[0].justificativa__c = justificativa;
            evento[0].imagemCheckout__c = urlImagem;
            evento[0].Feedback__c = feedback;
            evento[0].Contato__c = contatoTratado;

            // Realize a atualização do Event
            update evento;
        }
    }
    
    @AuraEnabled
    public static void addCalendar(String idUsuario, String idsCalendario) {
        
        List <User> usuario = [SELECT Id FROM User WHERE Id = :idUsuario];
        
        if (usuario.size() > 0) {
            usuario[0].IdsCalendarios__c = idsCalendario;
            update usuario;
        }
    }
    

}