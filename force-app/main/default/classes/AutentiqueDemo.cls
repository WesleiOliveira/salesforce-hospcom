public class AutentiqueDemo {
    
    public Demonstracao__c Contrato {get;set;}
    
    public String resposta 					{get;set;}
    public String status 					{get;set;}
    public String Mensagem 					{get;set;}
    public String cor 						{get;set;}
    
    public Boolean enviado 					{get;set;}
    public Boolean ContemDocs				{get;set;}
    
    public Integer stts 					{get;set;}
    
public AutentiqueDemo(ApexPages.StandardController controlador) {
        stts = 1;
        ID ContId = controlador.getId();
        
        Contrato = [SELECT Name, Contato__r.Name, RecordTypeId, Contato__r.Email, idDocAutentique__c, Valor_total__c, Oportunidade__r.Faturamento_Feito2__r.CNPJ__c, Nome_da_Testemunha__c, E_mail_da_Testemunha__c, Documento_Assinado__c FROM Demonstracao__c WHERE ID=: ContId];
        
        if(Contrato.idDocAutentique__c == null){
            enviado = false;
            	List <ContentDocumentLink> Anexos = [SELECT ID FROM ContentDocumentLink WHERE LinkedEntityId =: Contrato.Id];
            if(Anexos.isEmpty()){
                ContemDocs = false;
            }
            else{
                ContemDocs = true;
            }
        }
        else {
            enviado = true;
            contemDocs = true;
            HttpRequest req = new HttpRequest();
    		req.setMethod('POST');
    		req.setEndpoint('http://apphospcom.kinghost.net:21220/autentique/status2');
    		req.setHeader('Content-Type','application/x-www-form-urlencoded;charset=UTF-8');
    		req.setBody('&token=hospcomApiDev!#' 
    		+ '&idDocumento=' + Contrato.idDocAutentique__c);
            
            HttpResponse resp = new HttpResponse();

            resp = new Http().send(req);
            
            resposta = resp.getBody();
            
            system.debug(resposta);
            
            status = resposta.substringAfter('"fase":').substringBefore(',"cliente"');
            
            if(status != ''){stts = integer.valueof(status);}                      
            
        }
    }
    public void inserir(){
        if(stts > 4 && Contrato.Documento_Assinado__c == null){
                Contrato.Documento_Assinado__c = 'https://api.autentique.com.br/documentos/' + Contrato.idDocAutentique__c + '/assinado.pdf';
            try{
                update Contrato;
            }
            catch(dmlException e){               
            }
            }
        else{           
        }
    }
    
public void enviar(){

    PageReference pdf = Page.DemonstracaoContrato2;
    pdf.getParameters().put('id', Contrato.ID);
    
    Blob pdfBody;
    String base64PDF;
    
    if (!Test.IsRunningTest()){
		pdfBody = pdf.getContentAsPDF();
     	base64PDF = EncodingUtil.base64Encode(pdfBody);
    }
    	String cliente;
    	String emailCliente;
    
        cliente = Contrato.Contato__r.Name;
        emailCliente = Contrato.Contato__r.Email;
    
    Assinaturas_Autentique__mdt juridico = [SELECT Nome__c, Email__c FROM Assinaturas_Autentique__mdt WHERE DeveloperName ='Juridico'];
    
    Assinaturas_Autentique__mdt financeiro = [SELECT Nome__c, Email__c FROM Assinaturas_Autentique__mdt WHERE DeveloperName ='Financeiro'];
    
    Assinaturas_Autentique__mdt diretoria;
    
    Assinaturas_Autentique__mdt testemunhaDiretoria = [SELECT Nome__c, Email__c FROM Assinaturas_Autentique__mdt WHERE DeveloperName ='Testemunha_Diretoria' ];
    
    String verificadorFinanceiro = '';
    if(Contrato.Valor_total__c >  50000){
        verificadorFinanceiro = 'true';
    }
    else if (Contrato.Valor_total__c <= 50000){
        verificadorFinanceiro = 'false';
    }
    
    String doc = Contrato.Name;            
    
    string token;
    
    if(Contrato.Oportunidade__r.Faturamento_Feito2__r.CNPJ__c  == '27.476.124/0001-02'){
        //Health
        token = '303530b37d26cbf16359bfecb18d48f2cb7d05aa61aea2db743fcdb8beefa2c8';
        diretoria = [SELECT Nome__c, Email__c FROM Assinaturas_Autentique__mdt WHERE DeveloperName ='DiretoriaHealth'];
    }
    else if(Contrato.Oportunidade__r.Faturamento_Feito2__r.CNPJ__c == '05.743.288/0001-08'){
        //Hospcom
        token = 'acbda95d1493a37f30f118429a90f78946c0c593b8c1b708480ac2e048dc9240';
        diretoria = [SELECT Nome__c, Email__c FROM Assinaturas_Autentique__mdt WHERE DeveloperName ='Diretoria'];
    }
    else if(Contrato.Oportunidade__r.Faturamento_Feito2__r.CNPJ__c == '23.813.386/0001-56'){
        //GDB
        token = '05b0137735ab68d84bcb593eff2264e1bf6b2e26d946a953894c4fc2f0f8e400';
        diretoria = [SELECT Nome__c, Email__c FROM Assinaturas_Autentique__mdt WHERE DeveloperName ='DiretoriaGDB'];
    }       
                                        
    String body = '&token=hospcomApiDev!#' 
    + '&docName=' + doc
    + '&file=' + base64PDF + '&client={"name":"'+ cliente +'","email":"'+ EmailCliente +'"}'
    + '&testemunha={"name":"'+ Contrato.Nome_da_Testemunha__c +'","email":"'+ Contrato.E_mail_da_Testemunha__c	+'"}'
    + '&juridico={"name":"'+ juridico.Nome__c +'","email":"'+ juridico.Email__c +'"}'
    + '&diretoria={"name":"'+ diretoria.Nome__c +'","email":"'+ diretoria.Email__c +'"}'
    + '&testemunhaDiretoria={"name":"'+ testemunhaDiretoria.Nome__c +'","email":"'+ testemunhaDiretoria.Email__c +'"}'
    + '&financeiro={"name":"'+ financeiro.Nome__c +'","email":"'+ financeiro.Email__c +'"}' 
    + '&tokenAssinatura='+token
    + '&verificadorFinanceiro=' + verificadorFinanceiro;
    
    System.Debug(body);
  
    HttpRequest request = new HttpRequest();
    request.setMethod('POST');
    request.setEndpoint('http://apphospcom.kinghost.net:21220/autentique');
    request.setHeader('Content-Type','application/x-www-form-urlencoded;charset=UTF-8');
    request.setBody(body);
	request.setTimeout(120000);
    
    HttpResponse response = new HttpResponse();
    response = new Http().send(request);
    
        
    System.Debug(LoggingLevel.INFO,'#### request: ' + request.getBody());
    System.Debug(LoggingLevel.INFO,'#### response: ' + response);
    System.Debug(LoggingLevel.INFO,'#### response.getBody: ' + response.getBody());
    
    String responseBody = response.getBody();
    Integer responseStatus = response.getStatusCode();
    
    if(responseStatus == 200 && !responseBody.contains('Error')){
            Mensagem = 'Documento enviado com sucesso.';
            Cor = 'green';
        	enviado = true;
        
        	String idDocAutentique = responseBody.substringAfter('{"id":"').substringBefore('","name');
    
    		Contrato.idDocAutentique__c = idDocAutentique;
    		update Contrato;
        }
	else{
            Mensagem = 'Não foi possível enviar este documento.';
        	Cor = 'red';
       }
  
}
    public void atualizar(){
        
        HttpRequest requ = new HttpRequest();
        requ.setMethod('POST');
        requ.setEndpoint('http://apphospcom.kinghost.net:21220/autentique/atualiza');
        requ.setHeader('Content-Type','application/x-www-form-urlencoded;charset=UTF-8');
        requ.setBody('&token=hospcomApiDev!#');
        requ.setTimeout(120000);
        
        HttpResponse respons = new HttpResponse();
    	respons = new Http().send(requ);
    
        
    		System.Debug(LoggingLevel.INFO,'#### response: ' + respons);
        Mensagem = '';
    }
}