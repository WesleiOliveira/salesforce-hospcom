public class ValidacoesContato {
     
    public class Resp {
        String status; 
    }
    
    public virtual class BaseException extends Exception {}
    public class OtherException extends BaseException {}
    
    @future(callout=true)
    public static void consultaWhatsappAsync(String numero, String idContato) {
        
        Boolean phoneORemail = true;
        
        
        Contact contatocriado = [
                                    SELECT Id, Name,Whatsapp__c, FirstName, Phone
                                    FROM Contact 
                                    WHERE  Id =: idContato
                                ];
        
        String apiUrl = 'http://177.153.60.164:3000/valid-whatsapp-number';
        
        HttpRequest request = new HttpRequest();
        request.setEndpoint(apiUrl);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json; charset=UTF-8');
        request.setHeader('Accept', 'application/json');
        
        Map<String, String> requestBodyMap = new Map<String, String>{
            'number' => numero
        };
        String requestBody = JSON.serialize(requestBodyMap);
        request.setBody(requestBody);
        
        Http http = new Http();
        
            HttpResponse response = http.send(request);
            
                String responseBody = response.getBody();
                Resp resposta = (Resp)JSON.deserialize(responseBody, Resp.class);
                
                System.debug('Item: ' + resposta.status);
        
        if(resposta.status == 'false'){
            //delete contatocriado;
            deleteContato(contatocriado, phoneORemail);
        }
              
    }
    
     @future(callout=true)
    public static void consultaEmailAsync(String email, String idContato) {
        
        Boolean phoneORemail = false;
        
        Contact contatocriado = [
                                    SELECT Id, Name,Whatsapp__c, FirstName, Phone
                                    FROM Contact 
                                    WHERE  Id =: idContato
                                ];
        
        String apiUrl = 'http://177.153.60.164:3000/valid-email';
        
        HttpRequest request = new HttpRequest();
        request.setEndpoint(apiUrl);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json; charset=UTF-8');
        request.setHeader('Accept', 'application/json');
        
        Map<String, String> requestBodyMap = new Map<String, String>{
            'email' => email
        };
        String requestBody = JSON.serialize(requestBodyMap);
        request.setBody(requestBody);
        
        Http http = new Http();
        
            HttpResponse response = http.send(request);
            
                String responseBody = response.getBody();
                Resp resposta = (Resp)JSON.deserialize(responseBody, Resp.class);
                
                System.debug('Item: ' + resposta.status);
        
        if(resposta.status == 'false'){
            //delete contatocriado;
            deleteContato(contatocriado, phoneORemail);
        }
              
    }
    
    @AuraEnabled
    public static void consultaWhatsapp(String numero, String telefone, String idContato) {
        
        if(numero != NULL){
            consultaWhatsappAsync(numero,  idContato);
        }
        if(telefone != NULL){
            consultaWhatsappAsync(telefone,  idContato);
        }
        
        
    }
    
     @AuraEnabled
    public static void consultaEmail(String email, String idContato) {
          if(email != NULL){
       		consultaEmailAsync(email, idContato);        
          }
    }
    
    public static void deleteContato(Contact contato, Boolean phoneORemail){
        
        System.debug('Contato será apagado será apagada');
        delete contato;
        
        if(phoneORemail == true){
           sendMessage( contato.id, 'Alerta!', 'Você tentou criar um contato com um número de telefone que não está no WhatsApp. Por favor, tente cria-lo novamente utilizando um número de telefone associado ao WhatsApp.');
        }else{
            sendMessage( contato.id, 'Alerta!', 'Você tentou criar um contato com email inválido. Por favor, tente cria-lo novamente utilizando um email valido.');
        }
    }
    
    public static void sendMessage(String destinatario, String assunto, String corpoMensagem){
        
        EmailMessage novaMensagem = new EmailMessage();

        novaMensagem.Subject = assunto;
        novaMensagem.HtmlBody = corpoMensagem;
        novaMensagem.ToAddress = destinatario;

        insert novaMensagem;
        System.debug('Mensagem enviada com sucesso para: ' + destinatario);
    }
        
        }