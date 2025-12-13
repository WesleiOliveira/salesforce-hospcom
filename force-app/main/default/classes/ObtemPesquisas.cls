public class ObtemPesquisas  {
    
    //Busca Pesquisas de Satisfação do Dep Comercial
    
    @future(callout=true)
    public static void busca(){
    HttpRequest r = new HttpRequest();
    r.setEndpoint('https://app.binds.co/api/surveys/611d6cd56499ec2746d09c2c/responses');
    Blob headerValue = Blob.valueOf('desenvolvimento@hospcom.net' + ':' + 'hosp@3241');
    String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);
    r.setHeader('Authorization', authorizationHeader);
    r.setHeader('Content-Type', 'application/json');
    r.setMethod('GET');
                
    HttpResponse response = new HttpResponse();
    
    response = new Http().send(r);
    
    system.debug('RESPOSTA: ' +response.getBody());
        
    List<Object> deserialized = (List<Object>)JSON.deserializeUntyped(response.getBody());
    for(Object o: deserialized){
    	Map<String, Object> obMap = (Map<String, Object>)o;
      
    String st = obMap.toString();
    
    String pedido = st.substringAfter('pedido=').substringBefore('},');
    system.debug(st);
    
    String nota = st.substringAfter('questionTitle=NPS, response=').substringBefore(', responseId');
    
    Integer notaN = integer.valueOf(nota);
    
            
    String respostas;
        
    String promotor = st.substringAfter('questionTitle=Promotores, response=').substringBefore(', responseId');
        
    String neutro = st.substringAfter('questionTitle=Neutros , response=').substringBefore(', responseId');
               
    String detrator = st.substringAfter('questionTitle=Detratores , response=').substringBefore(', responseId');
        
    String telefone = st.substringAfter('questionTitle=Contato, response=').substringBefore(', responseId');
        
        if(promotor != ''){
            respostas = 'Ficamos felizes, nos conte o que você mais gostou: — ' + promotor;
        }
        else if(neutro != ''){
            respostas = 'Pena que não foi um 10, nos conte onde devemos evoluir: — ' +  neutro;
        }
        else if(detrator != ''){
            respostas = 'Lamentamos a experiência, nos conte por gentileza, onde devemos evoluir: — ' +  detrator;
        }
        else{
            respostas = 'Não respondeu as perguntas discursivas.';
        }

    if(pedido != ''){
		Pesquisa_de_Satisfacao__c Ps = new Pesquisa_de_Satisfacao__c();
        Ps.RecordTypeId = '0126e000001pLorAAE';
        Ps.Pedido__c = pedido;
        Ps.Nota__c = notaN;
        Ps.Respostas__c = respostas;
        Ps.Telefone_para_Contato__c = telefone;
        try{
            insert Ps;
        }
        catch(DmlException e){            
        }
    }   
}     	
}
    //Busca Pesquisas de Satisfação do Dep. de Serviços
    
    @future(callout=true)
    public static void buscaDepServicos(){
    HttpRequest r = new HttpRequest();
    r.setEndpoint('https://app.binds.co/api/surveys/612e44421c37542741deb0fa/responses');
    Blob headerValue = Blob.valueOf('desenvolvimento@hospcom.net' + ':' + 'hosp@3241');
    String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);
    r.setHeader('Authorization', authorizationHeader);
    r.setHeader('Content-Type', 'application/json');
    r.setMethod('GET');
                
    HttpResponse response = new HttpResponse();
    
    response = new Http().send(r);
    
    system.debug('RESPOSTA: ' +response.getBody());
        
    List<Object> deserialized = (List<Object>)JSON.deserializeUntyped(response.getBody());
    for(Object o: deserialized){
    	Map<String, Object> obMap = (Map<String, Object>)o;
      
    String st = obMap.toString();
    
    String ot = st.substringAfter('pedido=').substringBefore('},');
    system.debug(st);
    
    String nota = st.substringAfter('questionTitle=NPS, response=').substringBefore(', responseId');
    
    Integer notaN = integer.valueOf(nota);
    
            
    String respostas;
        
    String promotor = st.substringAfter('questionTitle=Promotores, response=').substringBefore(', responseId');
        
    String neutro = st.substringAfter('questionTitle=Neutros , response=').substringBefore(', responseId');
               
    String detrator = st.substringAfter('questionTitle=Detratores , response=').substringBefore(', responseId');
        
    String telefone = st.substringAfter('questionTitle=Contato, response=').substringBefore(', responseId');
             
        if(promotor != ''){
            respostas = 'Ficamos felizes, nos conte o que você mais gostou: — ' + promotor;
        }
        else if(neutro != ''){
            respostas = 'Pena que não foi um 10, nos conte onde devemos evoluir: — ' +  neutro;
        }
        else if(detrator != ''){
            respostas = 'Lamentamos a experiência, nos conte por gentileza, onde devemos evoluir: — ' +  detrator;
        }
        else{
            respostas = 'Não respondeu as perguntas discursivas.';
        }

    if(ot != ''){
		Pesquisa_de_Satisfacao__c Ps = new Pesquisa_de_Satisfacao__c();
        Ps.RecordTypeId = '0126e000001pLp1AAE';
        Ps.OT__c = ot;
        Ps.Nota__c = notaN;
        Ps.Respostas__c = respostas;
        Ps.Telefone_para_Contato__c = telefone;
        try{
            insert Ps;
        }
        catch(DmlException e){            
        }
    }   
}     	
}
    //Busca Pesquisas de Satisfação do Dep. de Locação
    
    @future(callout=true)
    public static void buscaDepLocacao(){
    HttpRequest r = new HttpRequest();
    r.setEndpoint('https://app.binds.co/api/surveys/612e456e1c37542741deb236/responses');
    Blob headerValue = Blob.valueOf('desenvolvimento@hospcom.net' + ':' + 'hosp@3241');
    String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);
    r.setHeader('Authorization', authorizationHeader);
    r.setHeader('Content-Type', 'application/json');
    r.setMethod('GET');
                
    HttpResponse response = new HttpResponse();
    
    response = new Http().send(r);
    
    system.debug('RESPOSTA: ' +response.getBody());
        
    List<Object> deserialized = (List<Object>)JSON.deserializeUntyped(response.getBody());
    for(Object o: deserialized){
    	Map<String, Object> obMap = (Map<String, Object>)o;
      
    String st = obMap.toString();
    
    String cl = st.substringAfter('pedido=').substringBefore('},');
    system.debug(st);
    
    String nota = st.substringAfter('questionTitle=NPS, response=').substringBefore(', responseId');
    
    Integer notaN = integer.valueOf(nota);
    
            
    String respostas;
        
    String promotor = st.substringAfter('questionTitle=Promotores, response=').substringBefore(', responseId');
        
    String neutro = st.substringAfter('questionTitle=Neutros , response=').substringBefore(', responseId');
               
    String detrator = st.substringAfter('questionTitle=Detratores , response=').substringBefore(', responseId');
        
    String telefone = st.substringAfter('questionTitle=Contato, response=').substringBefore(', responseId');
             
        if(promotor != ''){
            respostas = 'Ficamos felizes, nos conte o que você mais gostou: — ' + promotor;
        }
        else if(neutro != ''){
            respostas = 'Pena que não foi um 10, nos conte onde devemos evoluir: — ' +  neutro;
        }
        else if(detrator != ''){
            respostas = 'Lamentamos a experiência, nos conte por gentileza, onde devemos evoluir: — ' +  detrator;
        }
        else{
            respostas = 'Não respondeu as perguntas discursivas.';
        }

    if(cl != ''){
		Pesquisa_de_Satisfacao__c Ps = new Pesquisa_de_Satisfacao__c();
        Ps.RecordTypeId = '0126e000001pLowAAE';
        Ps.ContratoLoc__c = cl;
        Ps.Nota__c = notaN;
        Ps.Respostas__c = respostas;
        Ps.Telefone_para_Contato__c = telefone;
        try{
            insert Ps;
        }
        catch(DmlException e){            
        }
    }   
}     	
}
}