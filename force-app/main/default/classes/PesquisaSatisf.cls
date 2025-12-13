global class PesquisaSatisf {

    Public Static List<String> orderEmail; 

    //Pesquisa de Satisfação Dep. Comercial
    
    @future(callout=true)
    public static void enviar(id oid){
        Order pedido = [SELECT OrderNumber, QuoteId, Contrato_de_Servi_o__c, Departamento3__c, Ordem_de_trabalho__c, Natureza_de_Opera_o__c, Pesq_Satisfacao_Enviada__c FROM Order WHERE Id =: oid];
        Account conta;
        Contact contato;
        
        if(pedido.QuoteId != null && pedido.Departamento3__c == 'Comercial'){
            Quote cotacao = [SELECT ContactId FROM Quote WHERE Id =: pedido.QuoteId];
        	contato = [SELECT Name, Email FROM Contact WHERE Id =: cotacao.ContactId];
          
			HttpRequest r = new HttpRequest();
            r.setEndpoint('https://app.binds.co/api/seeds');
            Blob headerValue = Blob.valueOf('desenvolvimento@hospcom.net' + ':' + 'hosp@3241');
            String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);
            r.setHeader('Authorization', authorizationHeader);
            r.setHeader('Content-Type', 'application/json');
            r.setMethod('POST');
            r.setBody('{"collector": "611d6cd5adc7fcb5e6411880","from": {"name":"'+ contato.Name 	 +'","email": "'+ contato.Email +'"},"metadata": {"pedido": "'+ pedido.OrderNumber +'"}}');
     
            HttpResponse response = new HttpResponse();
          try {
            response = new Http().send(r);
            }
          catch(System.CalloutException e)  {
                System.debug('Callout error: '+ e);
                System.debug(response.toString());                
            }
		        
        Integer statusCode = response.getStatusCode();
        System.debug('TESTEAQUI ' + statusCode);
        
        if(statusCode == 201){
            integer test = 1;
           pedido.Pesq_Satisfacao_Enviada__c = true;
        
        	try{
                update pedido;
        		}
            catch(Exception e) {
                System.debug('ERRO: '+ e);
        		}

        }                    
            System.Debug(LoggingLevel.INFO,'#### response: ' + response);
            System.Debug(LoggingLevel.INFO,'#### response.getBody: ' + response.getBody()); 
            System.Debug(LoggingLevel.INFO,'#### response.getStatus: ' + response.getStatusCode()); 

    }
    }
    
    // Pesquisa de Satisfação Dep. de Serviços
    
    @future(callout=true)
    public static void enviarSERV(id oid){
        WorkOrder OT = [SELECT WorkOrderNumber, ContactId, E_mail__c, Pesq_Satisfacao_Enviada__c FROM WorkOrder WHERE Id =: oid];
        Contact contato = [SELECT Name FROM Contact WHERE ID =: OT.ContactId];
        
          
			HttpRequest r = new HttpRequest();
            r.setEndpoint('https://app.binds.co/api/seeds');
            Blob headerValue = Blob.valueOf('desenvolvimento@hospcom.net' + ':' + 'hosp@3241');
            String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);
            r.setHeader('Authorization', authorizationHeader);
            r.setHeader('Content-Type', 'application/json');
            r.setMethod('POST');
            r.setBody('{"collector": "612e4442adc7fcb5e62db209","from": {"name":"'+ contato.Name +'","email": "'+ OT.E_mail__c +'"},"metadata": {"pedido": "'+ OT.WorkOrderNumber +'"}}');
     
            HttpResponse response = new HttpResponse();
          try {
            response = new Http().send(r);
            }
          catch(System.CalloutException e)  {
                System.debug('Callout error: '+ e);
                System.debug(response.toString());                
            }
		        
        Integer statusCode = response.getStatusCode();
        System.debug('TESTEAQUI ' + statusCode);
        
        if(statusCode == 201){
            integer test = 1;
           OT.Pesq_Satisfacao_Enviada__c = true;
        
        	try{
                update OT;
        		}
            catch(Exception e) {
                System.debug('ERRO: '+ e);
        		}

        }                    
            System.Debug(LoggingLevel.INFO,'#### response: ' + response);
            System.Debug(LoggingLevel.INFO,'#### response.getBody: ' + response.getBody()); 
            System.Debug(LoggingLevel.INFO,'#### response.getStatus: ' + response.getStatusCode()); 

    }
    
    // Pesquisa de Satisfação Dep. de Locação

    @future(callout=true)
    public static void enviarLOCAC(id oid){
        Contrato_de_Servi_o__c CL = [SELECT Name, Cliente__c, N_mero_da_Proposta_Contrato__c, Contato_do_Locat_rio__c, Dura_o_do_Contrato_meses__c, Tipo_da_Dura_o__c, Pesq_Satisfacao_Enviada__c FROM Contrato_de_Servi_o__c WHERE Id =: oid];
        string nome;
        string email;
        
        if(CL.Contato_do_Locat_rio__c != null){ 
            Contact contato = [SELECT Name, Email FROM Contact WHERE ID =: CL.Contato_do_Locat_rio__c];
            nome = contato.Name;
            email = contato.Email;
        }
        else{
            Account conta = [SELECT Name, PersonEmail FROM Account WHERE Id =: CL.Cliente__c];
            nome = conta.Name;
            email = conta.PersonEmail;
        }
        
			HttpRequest r = new HttpRequest();
            r.setEndpoint('https://app.binds.co/api/seeds');
            Blob headerValue = Blob.valueOf('desenvolvimento@hospcom.net' + ':' + 'hosp@3241');
            String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);
            r.setHeader('Authorization', authorizationHeader);
            r.setHeader('Content-Type', 'application/json');
            r.setMethod('POST');
            r.setBody('{"collector": "612e456eadc7fcb5e62ead02","from": {"name":"'+ nome +'","email": "'+ email +'"},"metadata": {"pedido": "'+ CL.N_mero_da_Proposta_Contrato__c +'"}}');
     
            HttpResponse response = new HttpResponse();
          try {
            response = new Http().send(r);
            }
          catch(System.CalloutException e)  {
                System.debug('Callout error: '+ e);
                System.debug(response.toString());                
            }
		        
        Integer statusCode = response.getStatusCode();
        System.debug('TESTEAQUI ' + statusCode);
        
        if(statusCode == 201){
            integer test = 1;
           CL.Pesq_Satisfacao_Enviada__c = true;
        
        	try{
                update CL;
        		}
            catch(Exception e) {
                System.debug('ERRO: '+ e);
        		}

        }                    
            System.Debug(LoggingLevel.INFO,'#### response: ' + response);
            System.Debug(LoggingLevel.INFO,'#### response.getBody: ' + response.getBody()); 
            System.Debug(LoggingLevel.INFO,'#### response.getStatus: ' + response.getStatusCode()); 


    }
    }