public without sharing class Clicksign {
    @AuraEnabled
    @future(callout=true)
    public static void enviar(string idContrato, integer modoEnvio, Boolean versaoSimplificada){
        
        Quote cotacao = [SELECT ID, OwnerId, QuoteNumber, Contact.idDoSignatario__c, Contact.CPF__c, Contact.FirstName, Contact.LastName, Contact.MobilePhone,
                         Contact.Email, Testemunha__r.idDoSignatario__c, Testemunha__r.FirstName, Testemunha__r.LastName,Testemunha__r.Email, Testemunha__r.CPF__c, Testemunha__r.MobilePhone, Testemunha__r.AccountId,
                         Assinante2__r.Email, Assinante2__r.idDoSignatario__c, Assinante2__r.FirstName, Assinante2__r.LastName, Assinante2__r.CPF__c, Assinante2__r.MobilePhone,
                         Validador__r.Email, Validador__r.idDoSignatario__c, Validador__r.FirstName, Validador__r.LastName, Validador__r.CPF__c, Validador__r.MobilePhone,
                         Validador2__r.Email, Validador2__r.idDoSignatario__c, Validador2__r.FirstName, Validador2__r.LastName, Validador2__r.CPF__c, Validador2__r.MobilePhone,
                         Fiador__c, Fiador__r.idDoSignatario__c, Fiador__r.Name, Fiador__r.CPF__pc, Fiador__r.PersonEmail, Fiador__r.PersonMobilePhone,
                         Conjuge_do_fiador__c, Conjuge_do_fiador__r.idDoSignatario__c, Conjuge_do_fiador__r.Name, Conjuge_do_fiador__r.CPF__pc, Conjuge_do_fiador__r.PersonEmail, Conjuge_do_fiador__r.PersonMobilePhone  
                         FROM Quote 
                         WHERE ID =: idContrato];
        
        
        string endpoint;
        if(modoEnvio == 1)
            endpoint = 'notifications';
        else if(modoEnvio == 2)
            endpoint = 'notify_by_whatsapp';
        
        string idSignatario;
        string idSignatarioTest;
        string idSignatarioFiador;
        string idSignatarioConjugeFiador;
        string idSignatarioAssinante2;
        string idSignatarioValidador;
        string idSignatarioValidador2;
        string cpfTestemunha;
        
        Tokens_Clicksign__mdt juridico = [SELECT DeveloperName, Token__c FROM Tokens_Clicksign__mdt WHERE DeveloperName ='Juridico'];
        Tokens_Clicksign__mdt financeiro = [SELECT DeveloperName, Token__c FROM Tokens_Clicksign__mdt WHERE DeveloperName ='Financeiro'];
        Tokens_Clicksign__mdt adm = [SELECT DeveloperName, Token__c FROM Tokens_Clicksign__mdt WHERE DeveloperName ='Adm'];
        Tokens_Clicksign__mdt geral = [SELECT DeveloperName, Token__c FROM Tokens_Clicksign__mdt WHERE DeveloperName ='Geral'];
        
        string idSignatarioJuridico = juridico.Token__c;
        string idSignatarioFinanceiro = financeiro.Token__c;
        string idSignatarioAdm = adm.Token__c;
        string token = geral.Token__c;
        
        string l0g = '';
        
        HttpRequest req = new HttpRequest();
        PageReference pdf;
        If(versaoSimplificada){
             pdf = Page.CotacaoContratoSimplificado;
        }
        else {
              pdf = Page.CotacaoContrato;              
        }    
        pdf.getParameters().put('id', idContrato);
        
        Blob pdfBody;
        String base64PDF;
        
        if (!Test.IsRunningTest()){
            pdfBody = pdf.getContentAsPDF();
            base64PDF = EncodingUtil.base64Encode(pdfBody);
        }
        else{
            pdfBody = Blob.valueOf('Teste');
            base64PDF = 'TESTE';
        }
        
        dateTime agora = system.now();
        
        String nomeDoDocumento = 'Contrato de compra e venda ' + cotacao.QuoteNumber;
        
        req.setMethod('POST');
        req.setEndpoint('http://oldsite.hospcom.net:21220/clickSign');
        req.setHeader('Content','{"document":{"path": "/' + nomeDoDocumento + '.pdf","content_base64": "data:application/pdf;base64,%","locale": "pt-BR","sequence_enabled": true}}');
        req.setTimeout(120000);
        req.setBody(base64PDF);
        
    //system.debug(req.getBody());
    
    //system.debug('base64:::::' + req.getBody());
    
   HttpResponse resp = new HttpResponse();

try{
resp = new Http().send(req);
} catch(Exception e){
throw new AuraHandledException('PDF muito grande, tente a versão simplificada');
}
    
    system.debug(resp.getBody());
    
    string keyid = resp.getBody();
        
        l0g = 'ID do Documento: ' + keyid +
            + '\n \n Requisição de envio para o Servidor: ' + req;
        
        if(cotacao.Testemunha__r.AccountId == '001i00000085QYbAAM'){
            Dados_colaborador__c dados = [SELECT CPF__c FROM Dados_colaborador__c WHERE Contato__c =: cotacao.Testemunha__c];
            cpfTestemunha = dados.CPF__c;
            l0g = l0g + 'Testemunha da HOSPCOM';
        }
        else{
            cpfTestemunha = cotacao.Testemunha__r.CPF__c;
        }
        l0g = l0g + ' CPF testemunha: ' + cpfTestemunha;
        
        if(resp.getStatusCode() == 200){
            if(!keyId.contains('error')){
                
                Autentique__c doc = new Autentique__c(idDocAutentique__c = keyid, Nome_do_Documento__c = nomeDoDocumento);
                
                cotacao.idDocAutentique__c = keyid;
                cotacao.Data_da_fase__c = SYSTEM.NOW();
                cotacao.Fase__c = '1';
                //Requisição para criar o signatário no Clicksign caso ele ainda não tenha
                string body;
                if(modoEnvio == 1){
                    body = '{' +
                        +'"signer": { ' +
                        +'"email": "'+ cotacao.Contact.Email +'", '+
                        +'"auths": [ ' +
                        +'"email" ' +
                        +'], '+
                        +'"name": "'+ cotacao.Contact.Firstname + ' ' + cotacao.Contact.LastName +'",' +
                        +'"documentation": "'+ cotacao.Contact.CPF__c +'",' +
                        +'"has_documentation": true,' +
                        +'"selfie_enabled": false,'+
                        +'"handwritten_enabled": false,'+
                        +'"official_document_enabled": false,' +
                        +'"liveness_enabled": false,'+
                        +'"facial_biometrics_enabled": false'+
                        +'}'+
                        +'}';
                }
                else if(modoEnvio == 2){
                    body = '{' +
                        +'"signer": { ' +
                        +'"phone_number": "'+ cotacao.Contact.MobilePhone.replace('+55', '').replaceAll('[^0-9]', '') +'", '+
                        +'"auths": [ ' +
                        +'"whatsapp" ' +
                        +'], '+
                        +'"name": "'+ cotacao.Contact.Firstname + ' ' + cotacao.Contact.LastName +'",' +
                        +'"documentation": "'+ cotacao.Contact.CPF__c +'",' +
                        +'"has_documentation": true,' +
                        +'"communicate_by": "whatsapp",' +
                        +'"selfie_enabled": false,'+
                        +'"handwritten_enabled": false,'+
                        +'"official_document_enabled": false,' +
                        +'"liveness_enabled": false,'+
                        +'"facial_biometrics_enabled": false'+
                        +'}'+
                        +'}';
                }
                
                HttpRequest req2 = new HttpRequest();
                req2.setMethod('POST');
                req2.setEndpoint('https://app.clicksign.com/api/v1/signers?access_token='+ token);
                req2.setHeader('Content-Type', 'application/json');
                //req.setTimeout(120000);
                req2.setBody(body);
                HttpResponse respost = new HttpResponse();
                
                respost = new Http().send(req2);
                
                l0g = l0g + ' resposta requisicao criar assinador: ' + respost.getBody();
                
                idSignatario = respost.getBody().substringAfter('"key":"').substringBefore('",'); //salvar id do signatário novo
                
                l0g = l0g + '\n ID DO NOVO SIGNATARIO ADICIONADO:: ' + idSignatario;
                
                //Requisição para adicionar o signatário ao documento
                string body3 = '{"list": {"document_key": "'+ keyid +'",'+
                    +'"signer_key": "'+ idSignatario +'",'+
                    +'"sign_as": "party",'+
                    +'"refusable": true,'+
                    +'"group": 1,'+
                    +'"message": "Prezado,\nPor favor assine o documento.\n\nQualquer dúvida estamos à disposição.\n\nAtenciosamente, \nHOSPCOM"}}';
                
                HttpRequest req3 = new HttpRequest();
                req3.setMethod('POST');
                req3.setEndpoint('https://app.clicksign.com/api/v1/lists?access_token=' + token);
                req3.setHeader('Content-Type', 'application/json');
                //req.setTimeout(120000);
                req3.setBody(body3);
                HttpResponse respost3 = new HttpResponse();
                
                respost3 = new Http().send(req3);
                
                l0g = l0g + '\n resposta requisicao adicionar assinador: ' + respost3.getBody();
                
                string idAssinatura = respost3.getBody().substringAfter('request_signature_key":"').substringBefore('","document'); 
                
                //Requisição para enviar notificação para o assinador
                
                string body4 = '{'+
                    +'"request_signature_key": "'+ idAssinatura +'",'+
                    +'"message": "Prezado,\nPor favor assine o documento.\n\nQualquer dúvida estou à disposição.\n\nAtenciosamente,\nHOSPCOM"}';
                
                HttpRequest req4 = new HttpRequest();
                req4.setMethod('POST');
                req4.setEndpoint('https://app.clicksign.com/api/v1/' + endpoint +'?access_token=' + token);
                req4.setHeader('Content-Type', 'application/json');
                //req.setTimeout(120000);
                req4.setBody(body4);
                HttpResponse respost4 = new HttpResponse();
                
                respost4 = new Http().send(req4);
                
                l0g = l0g + '\n resposta requisicao notificar assinador: ' + respost4.getStatus();
                
                //Testemunha
                
                if(idSignatarioTest == null){
                    string bodyTest;
                    
                    if(modoEnvio == 1){
                        bodyTest = '{' +
                            +'"signer": { ' +
                            +'"email": "'+ cotacao.Testemunha__r.Email +'", '+
                            +'"auths": [ ' +
                            +'"email" ' +
                            +'], '+
                            +'"name": "'+ cotacao.Testemunha__r.Firstname + ' ' + cotacao.Testemunha__r.LastName +'",' +
                            +'"documentation": "'+ cpfTestemunha +'",' +
                            +'"has_documentation": true,' +
                            +'"selfie_enabled": false,'+
                            +'"handwritten_enabled": false,'+
                            +'"official_document_enabled": false,' +
                            +'"liveness_enabled": false,'+
                            +'"facial_biometrics_enabled": false'+
                            +'}'+
                            +'}';
                    }
                    else if(modoEnvio == 2){
                        bodyTest = '{' +
                            +'"signer": { ' +
                            +'"phone_number": "'+ cotacao.Testemunha__r.MobilePhone.replace('+55', '').replaceAll('[^0-9]', '') +'", '+
                            +'"auths": [ ' +
                            +'"whatsapp" ' +
                            +'], '+
                            +'"name": "'+ cotacao.Testemunha__r.Firstname + ' ' + cotacao.Testemunha__r.LastName +'",' +
                            +'"documentation": "'+ cpfTestemunha +'",' +
                            +'"has_documentation": true,' +
                            +'"communicate_by": "whatsapp",' +
                            +'"selfie_enabled": false,'+
                            +'"handwritten_enabled": false,'+
                            +'"official_document_enabled": false,' +
                            +'"liveness_enabled": false,'+
                            +'"facial_biometrics_enabled": false'+
                            +'}'+
                            +'}';
                    }
                    
                    HttpRequest reqTest = new HttpRequest();
                    reqTest.setMethod('POST');
                    reqTest.setEndpoint('https://app.clicksign.com/api/v1/signers?access_token=' + token);
                    reqTest.setHeader('Content-Type', 'application/json');
                    //req.setTimeout(120000);
                    reqTest.setBody(bodyTest);
                    HttpResponse resposTest = new HttpResponse();
                    
                    resposTest = new Http().send(reqTest);
                    
                    l0g = l0g + '\n resposta requisicao criar testemunha: ' + resposTest.getBody();
                    
                    idSignatarioTest = resposTest.getBody().substringAfter('"key":"').substringBefore('",'); //salvar id do signatário novo
                    
                    
                    l0g = l0g + '\n ID DO NOVO TESTEMUNHA ADICIONADO:: ' + idSignatarioTest;                    
                    
                }
                
                //Requisição para adicionar a testemunha ao documento
                string bodyTest2 = '{"list": {"document_key": "'+ keyid +'",'+
                    +'"signer_key": "'+ idSignatarioTest +'",'+
                    +'"sign_as": "witness",'+
                    +'"refusable": true,'+
                    +'"group": 1,'+
                    +'"message": "Prezado,\nPor favor assine o documento.\n\nQualquer dúvida estamos à disposição.\n\nAtenciosamente, \nHOSPCOM"}}';
                
                HttpRequest reqTest2 = new HttpRequest();
                reqTest2.setMethod('POST');
                reqTest2.setEndpoint('https://app.clicksign.com/api/v1/lists?access_token=' + token);
                reqTest2.setHeader('Content-Type', 'application/json');
                //req.setTimeout(120000);
                reqTest2.setBody(bodyTest2);
                HttpResponse resposTest2 = new HttpResponse();
                
                resposTest2 = new Http().send(reqTest2);
                
                l0g = l0g + '\n resposta requisicao adicionar testemunha: ' + resposTest2.getBody();
                
                string idAssinaturaTest = resposTest2.getBody().substringAfter('request_signature_key":"').substringBefore('","document');                                       
                
                //Requisição para enviar notificação para a testemunha
                
                string bodyTest3 = '{'+
                    +'"request_signature_key": "'+ idAssinaturaTest +'",'+
                    +'"message": "Prezado,\nPor favor assine o documento.\n\nQualquer dúvida estou à disposição.\n\nAtenciosamente,\nHOSPCOM"}';
                
                HttpRequest reqTest3 = new HttpRequest();
                reqTest3.setMethod('POST');
                reqTest3.setEndpoint('https://app.clicksign.com/api/v1/'+ endpoint + '?access_token=' + token);
                reqTest3.setHeader('Content-Type', 'application/json');
                //req.setTimeout(120000);
                reqTest3.setBody(bodyTest3);
                HttpResponse resposTest3 = new HttpResponse();
                
                resposTest3 = new Http().send(reqTest3);
                
                l0g = l0g + '\n resposta requisicao notificar testemunha: ' + resposTest3.getStatus();
                
                
                //Caso o contrato tenha fiador                        
                if(cotacao.Fiador__c != null){
                    string bodyFiador;
                    if(modoEnvio == 1){
                        bodyFiador = '{' +
                            +'"signer": { ' +
                            +'"email": "'+ cotacao.Fiador__r.PersonEmail +'", '+
                            +'"auths": [ ' +
                            +'"email" ' +
                            +'], '+
                            +'"name": "'+ cotacao.Fiador__r.Name +'",' +
                            +'"documentation": "'+ cotacao.Fiador__r.CPF__pc +'",' +
                            +'"has_documentation": true,' +
                            +'"selfie_enabled": false,'+
                            +'"handwritten_enabled": false,'+
                            +'"official_document_enabled": false,' +
                            +'"liveness_enabled": false,'+
                            +'"facial_biometrics_enabled": false'+
                            +'}'+
                            +'}';
                    }
                    else if(modoEnvio == 2){
                        bodyFiador = '{' +
                            +'"signer": { ' +
                            +'"phone_number": "'+ cotacao.Fiador__r.PersonMobilePhone.replace('+55', '').replaceAll('[^0-9]', '') +'", '+
                            +'"auths": [ ' +
                            +'"whatsapp" ' +
                            +'], '+
                            +'"name": "'+ cotacao.Fiador__r.Name +'",' +
                            +'"documentation": "'+ cotacao.Fiador__r.CPF__pc +'",' +
                            +'"has_documentation": true,' +
                            +'"communicate_by": "whatsapp",' +
                            +'"selfie_enabled": false,'+
                            +'"handwritten_enabled": false,'+
                            +'"official_document_enabled": false,' +
                            +'"liveness_enabled": false,'+
                            +'"facial_biometrics_enabled": false'+
                            +'}'+
                            +'}';
                    }
                    
                    HttpRequest reqFiador = new HttpRequest();
                    reqFiador.setMethod('POST');
                    reqFiador.setEndpoint('https://app.clicksign.com/api/v1/signers?access_token=' + token);
                    reqFiador.setHeader('Content-Type', 'application/json');
                    //req.setTimeout(120000);
                    reqFiador.setBody(bodyFiador);
                    HttpResponse resposFiador = new HttpResponse();
                    
                    resposFiador = new Http().send(reqFiador);
                    
                    l0g = l0g + '\n resposta requisicao criar fiador: ' + resposFiador.getBody();
                    
                    idSignatarioFiador = resposFiador.getBody().substringAfter('"key":"').substringBefore('",'); //salvar id do signatário novo
                    
                    l0g = l0g + '\n ID DO NOVO FIADOR ADICIONADO:: ' + idSignatarioFiador;
                    
                    
                    //Requisição para adicionar o fiador ao documento
                    string bodyFiador2 = '{"list": {"document_key": "'+ keyid +'",'+
                        +'"signer_key": "'+ idSignatarioFiador +'",'+
                        +'"sign_as": "surety",'+
                        +'"refusable": true,'+
                        +'"group": 1,'+
                        +'"message": "Prezado,\nPor favor assine o documento.\n\nQualquer dúvida estamos à disposição.\n\nAtenciosamente, \nHOSPCOM"}}';
                    
                    HttpRequest reqFiador2 = new HttpRequest();
                    reqFiador2.setMethod('POST');
                    reqFiador2.setEndpoint('https://app.clicksign.com/api/v1/lists?access_token=' + token);
                    reqFiador2.setHeader('Content-Type', 'application/json');
                    //req.setTimeout(120000);
                    reqFiador2.setBody(bodyFiador2);
                    HttpResponse resposFiador2 = new HttpResponse();
                    
                    resposFiador2 = new Http().send(reqFiador2);
                    
                    l0g = l0g + '\n resposta requisicao adicionar fiador: ' + resposFiador2.getBody();
                    
                    string idAssinaturaFiador = resposFiador2.getBody().substringAfter('request_signature_key":"').substringBefore('","document'); 
                    
                    //Requisição para enviar notificação para o fiador
                    
                    string bodyFiador3 = '{'+
                        +'"request_signature_key": "'+ idAssinaturaFiador +'",'+
                        +'"message": "Prezado,\nPor favor assine o documento.\n\nQualquer dúvida estou à disposição.\n\nAtenciosamente,\nHOSPCOM"}';
                    
                    HttpRequest reqFiador3 = new HttpRequest();
                    reqFiador3.setMethod('POST');
                    reqFiador3.setEndpoint('https://app.clicksign.com/api/v1/'+ endpoint + '?access_token=' + token);
                    reqFiador3.setHeader('Content-Type', 'application/json');
                    //req.setTimeout(120000);
                    reqFiador3.setBody(bodyFiador3);
                    HttpResponse resposFiador3 = new HttpResponse();
                    
                    resposFiador3 = new Http().send(reqFiador3);
                    
                    l0g = l0g + '\n resposta requisicao notificar fiador: ' + resposFiador3.getStatus();
                    
                }
                
                //Caso o contrato tenha conjuge do fiador                        
                if(cotacao.Conjuge_do_fiador__c != null){
                    string bodyConjFiador;
                    if(modoEnvio == 1){
                        bodyConjFiador = '{' +
                            +'"signer": { ' +
                            +'"email": "'+ cotacao.Conjuge_do_fiador__r.PersonEmail +'", '+
                            +'"auths": [ ' +
                            +'"email" ' +
                            +'], '+
                            +'"name": "'+ cotacao.Conjuge_do_fiador__r.Name +'",' +
                            +'"documentation": "'+ cotacao.Conjuge_do_fiador__r.CPF__pc +'",' +
                            +'"has_documentation": true,' +
                            +'"selfie_enabled": false,'+
                            +'"handwritten_enabled": false,'+
                            +'"official_document_enabled": false,' +
                            +'"liveness_enabled": false,'+
                            +'"facial_biometrics_enabled": false'+
                            +'}'+
                            +'}';
                    }
                    else if(modoEnvio == 2){
                        bodyConjFiador = '{' +
                            +'"signer": { ' +
                            +'"phone_number": "'+ cotacao.Conjuge_do_fiador__r.PersonMobilePhone.replace('+55', '').replaceAll('[^0-9]', '') +'", '+
                            +'"auths": [ ' +
                            +'"whatsapp" ' +
                            +'], '+
                            +'"name": "'+ cotacao.Conjuge_do_fiador__r.Name +'",' +
                            +'"documentation": "'+ cotacao.Conjuge_do_fiador__r.CPF__pc +'",' +
                            +'"has_documentation": true,' +
                            +'"communicate_by": "whatsapp",' +
                            +'"selfie_enabled": false,'+
                            +'"handwritten_enabled": false,'+
                            +'"official_document_enabled": false,' +
                            +'"liveness_enabled": false,'+
                            +'"facial_biometrics_enabled": false'+
                            +'}'+
                            +'}';
                    }
                    
                    HttpRequest reqConjFiador = new HttpRequest();
                    reqConjFiador.setMethod('POST');
                    reqConjFiador.setEndpoint('https://app.clicksign.com/api/v1/signers?access_token=' + token);
                    reqConjFiador.setHeader('Content-Type', 'application/json');
                    //req.setTimeout(120000);
                    reqConjFiador.setBody(bodyConjFiador);
                    HttpResponse resposConjFiador = new HttpResponse();
                    
                    resposConjFiador = new Http().send(reqConjFiador);
                    
                    l0g = l0g + '\n resposta requisicao criar conjuge: ' + resposConjFiador.getBody();
                    
                    idSignatarioConjugeFiador = resposConjFiador.getBody().substringAfter('"key":"').substringBefore('",'); //salvar id do signatário novo
                    
                    
                    l0g = l0g + '\n ID DO NOVO CONJUGE ADICIONADO:: ' + idSignatarioConjugeFiador;
                    
                    
                    //Requisição para adicionar o conjuge do fiador ao documento
                    string bodyConjFiador2 = '{"list": {"document_key": "'+ keyid +'",'+
                        +'"signer_key": "'+ idSignatarioConjugeFiador +'",'+
                        +'"sign_as": "surety",'+
                        +'"refusable": true,'+
                        +'"group": 1,'+
                        +'"message": "Prezado,\nPor favor assine o documento.\n\nQualquer dúvida estamos à disposição.\n\nAtenciosamente, \nHOSPCOM"}}';
                    
                    HttpRequest reqConjFiador2 = new HttpRequest();
                    reqConjFiador2.setMethod('POST');
                    reqConjFiador2.setEndpoint('https://app.clicksign.com/api/v1/lists?access_token=' + token);
                    reqConjFiador2.setHeader('Content-Type', 'application/json');
                    //req.setTimeout(120000);
                    reqConjFiador2.setBody(bodyConjFiador2);
                    HttpResponse resposConjFiador2 = new HttpResponse();
                    
                    resposConjFiador2 = new Http().send(reqConjFiador2);
                    
                    l0g = l0g + '\n resposta requisicao adicionar conjuge fiador: ' + resposConjFiador2.getBody();
                    
                    string idAssinaturaConjFiador = resposConjFiador2.getBody().substringAfter('request_signature_key":"').substringBefore('","document'); 
                    
                    //Requisição para enviar notificação para o conjuge do fiador
                    
                    string bodyConjFiador3 = '{'+
                        +'"request_signature_key": "'+ idAssinaturaConjFiador +'",'+
                        +'"message": "Prezado,\nPor favor assine o documento.\n\nQualquer dúvida estou à disposição.\n\nAtenciosamente,\nHOSPCOM"}';
                    
                    HttpRequest reqConjFiador3 = new HttpRequest();
                    reqConjFiador3.setMethod('POST');
                    reqConjFiador3.setEndpoint('https://app.clicksign.com/api/v1/' + endpoint +'?access_token=' + token);
                    reqConjFiador3.setHeader('Content-Type', 'application/json');
                    //req.setTimeout(120000);
                    reqConjFiador3.setBody(bodyConjFiador3);
                    HttpResponse resposConjFiador3 = new HttpResponse();
                    
                    resposConjFiador3 = new Http().send(reqConjFiador3);
                    
                    l0g = l0g + '\n resposta requisicao notificar conjuge do fiador: ' + resposConjFiador3.getStatus();
                    
                }
                
                //Adicionar o Assinante 2
                if(cotacao.Assinante2__c != null){
                    string bodyAssin;
                    if(modoEnvio == 1){
                        bodyAssin = '{' +
                            +'"signer": { ' +
                            +'"email": "'+ cotacao.Assinante2__r.Email +'", '+
                            +'"auths": [ ' +
                            +'"email" ' +
                            +'], '+
                            +'"name": "'+ cotacao.Assinante2__r.Firstname + ' ' + cotacao.Assinante2__r.LastName +'",' +
                            +'"documentation": "'+ cotacao.Assinante2__r.CPF__c +'",' +
                            +'"has_documentation": true,' +
                            +'"selfie_enabled": false,'+
                            +'"handwritten_enabled": false,'+
                            +'"official_document_enabled": false,' +
                            +'"liveness_enabled": false,'+
                            +'"facial_biometrics_enabled": false'+
                            +'}'+
                            +'}';
                    }
                    else if(modoEnvio == 2){
                        bodyAssin = '{' +
                            +'"signer": { ' +
                            +'"phone_number": "'+ cotacao.Assinante2__r.MobilePhone.replace('+55', '').replaceAll('[^0-9]', '') +'", '+
                            +'"auths": [ ' +
                            +'"whatsapp" ' +
                            +'], '+
                            +'"name": "'+ cotacao.Assinante2__r.Firstname + ' ' + cotacao.Assinante2__r.LastName +'",' +
                            +'"documentation": "'+ cotacao.Assinante2__r.CPF__c +'",' +
                            +'"has_documentation": true,' +
                            +'"communicate_by": "whatsapp",' +
                            +'"selfie_enabled": false,'+
                            +'"handwritten_enabled": false,'+
                            +'"official_document_enabled": false,' +
                            +'"liveness_enabled": false,'+
                            +'"facial_biometrics_enabled": false'+
                            +'}'+
                            +'}';
                    }
                    
                    HttpRequest reqAssin = new HttpRequest();
                    reqAssin.setMethod('POST');
                    reqAssin.setEndpoint('https://app.clicksign.com/api/v1/signers?access_token='+ token);
                    reqAssin.setHeader('Content-Type', 'application/json');
                    //req.setTimeout(120000);
                    reqAssin.setBody(bodyAssin);
                    HttpResponse respostAssin = new HttpResponse();
                    
                    respostAssin = new Http().send(reqAssin);
                    
                    l0g = l0g + ' resposta requisicao criar assinante 2: ' + respostAssin.getBody();
                    
                    idSignatarioAssinante2 = respostAssin.getBody().substringAfter('"key":"').substringBefore('",'); //salvar id do signatário novo
                    
                    l0g = l0g + '\n ID DO NOVO SIGNATARIO ADICIONADO:: ' + idSignatarioAssinante2;
                    
                    //Requisição para adicionar o assinante2 ao documento
                    string bodyAssin2 = '{"list": {"document_key": "'+ keyid +'",'+
                        +'"signer_key": "'+ idSignatarioAssinante2 +'",'+
                        +'"sign_as": "party",'+
                        +'"refusable": true,'+
                        +'"group": 1,'+
                        +'"message": "Prezado,\nPor favor assine o documento.\n\nQualquer dúvida estamos à disposição.\n\nAtenciosamente, \nHOSPCOM"}}';
                    
                    HttpRequest reqAssin2 = new HttpRequest();
                    reqAssin2.setMethod('POST');
                    reqAssin2.setEndpoint('https://app.clicksign.com/api/v1/lists?access_token=' + token);
                    reqAssin2.setHeader('Content-Type', 'application/json');
                    //req.setTimeout(120000);
                    reqAssin2.setBody(bodyAssin2);
                    HttpResponse respostAssin2 = new HttpResponse();
                    
                    respostAssin2 = new Http().send(reqAssin2);
                    
                    l0g = l0g + '\n resposta requisicao adicionar assinador: ' + respostAssin2.getBody();
                    
                    string idAssinatura2 = respostAssin2.getBody().substringAfter('request_signature_key":"').substringBefore('","document'); 
                    
                    //Requisição para enviar notificação para o assinante2
                    
                    string bodyAssin3 = '{'+
                        +'"request_signature_key": "'+ idAssinatura2 +'",'+
                        +'"message": "Prezado,\nPor favor assine o documento.\n\nQualquer dúvida estou à disposição.\n\nAtenciosamente,\nHOSPCOM"}';
                    
                    HttpRequest reqAssin4 = new HttpRequest();
                    reqAssin4.setMethod('POST');
                    reqAssin4.setEndpoint('https://app.clicksign.com/api/v1/' + endpoint +'?access_token=' + token);
                    reqAssin4.setHeader('Content-Type', 'application/json');
                    //req.setTimeout(120000);
                    reqAssin4.setBody(body4);
                    HttpResponse respostAssin4 = new HttpResponse();
                    
                    respostAssin4 = new Http().send(reqAssin4);
                    
                    l0g = l0g + '\n resposta requisicao notificar assinante 2: ' + respostAssin4.getStatus();
                }
                
                //Adicionar o Validador
                if(cotacao.Validador__c != null){
                    string bodyValidador;
                    if(modoEnvio == 1){
                        bodyValidador = '{' +
                            +'"signer": { ' +
                            +'"email": "'+ cotacao.Validador__r.Email +'", '+
                            +'"auths": [ ' +
                            +'"email" ' +
                            +'], '+
                            +'"name": "'+ cotacao.Validador__r.Firstname + ' ' + cotacao.Validador__r.LastName +'",' +
                            +'"documentation": "'+ cotacao.Validador__r.CPF__c +'",' +
                            +'"has_documentation": true,' +
                            +'"selfie_enabled": false,'+
                            +'"handwritten_enabled": false,'+
                            +'"official_document_enabled": false,' +
                            +'"liveness_enabled": false,'+
                            +'"facial_biometrics_enabled": false'+
                            +'}'+
                            +'}';
                    }
                    else if(modoEnvio == 2){
                        bodyValidador = '{' +
                            +'"signer": { ' +
                            +'"phone_number": "'+ cotacao.Validador__r.MobilePhone.replace('+55', '').replaceAll('[^0-9]', '') +'", '+
                            +'"auths": [ ' +
                            +'"whatsapp" ' +
                            +'], '+
                            +'"name": "'+ cotacao.Validador__r.Firstname + ' ' + cotacao.Validador__r.LastName +'",' +
                            +'"documentation": "'+ cotacao.Validador__r.CPF__c +'",' +
                            +'"has_documentation": true,' +
                            +'"communicate_by": "whatsapp",' +
                            +'"selfie_enabled": false,'+
                            +'"handwritten_enabled": false,'+
                            +'"official_document_enabled": false,' +
                            +'"liveness_enabled": false,'+
                            +'"facial_biometrics_enabled": false'+
                            +'}'+
                            +'}';
                    }
                    
                    HttpRequest reqValidador = new HttpRequest();
                    reqValidador.setMethod('POST');
                    reqValidador.setEndpoint('https://app.clicksign.com/api/v1/signers?access_token='+ token);
                    reqValidador.setHeader('Content-Type', 'application/json');
                    //req.setTimeout(120000);
                    reqValidador.setBody(bodyValidador);
                    HttpResponse respostValidador = new HttpResponse();
                    
                    respostValidador = new Http().send(reqValidador);
                    
                    l0g = l0g + ' resposta requisicao criar validador: ' + respostValidador.getBody();
                    
                    idSignatarioValidador = respostValidador.getBody().substringAfter('"key":"').substringBefore('",'); //salvar id do signatário novo
                    
                    l0g = l0g + '\n ID DO NOVO VALIDADOR ADICIONADO:: ' + idSignatarioValidador;
                    
                    //Requisição para adicionar o validador ao documento
                    string bodyValidador_2 = '{"list": {"document_key": "'+ keyid +'",'+
                        +'"signer_key": "'+ idSignatarioValidador +'",'+
                        +'"sign_as": "validator",'+
                        +'"refusable": true,'+
                        +'"group": 1,'+
                        +'"message": "Prezado,\nPor favor assine o documento.\n\nQualquer dúvida estamos à disposição.\n\nAtenciosamente, \nHOSPCOM"}}';
                    
                    HttpRequest reqValidador_2 = new HttpRequest();
                    reqValidador_2.setMethod('POST');
                    reqValidador_2.setEndpoint('https://app.clicksign.com/api/v1/lists?access_token=' + token);
                    reqValidador_2.setHeader('Content-Type', 'application/json');
                    //req.setTimeout(120000);
                    reqValidador_2.setBody(bodyValidador_2);
                    HttpResponse respostValidador_2 = new HttpResponse();
                    
                    respostValidador_2 = new Http().send(reqValidador_2);
                    
                    l0g = l0g + '\n resposta requisicao adicionar assinador: ' + respostValidador_2.getBody();
                    
                    string idValidador = respostValidador_2.getBody().substringAfter('request_signature_key":"').substringBefore('","document'); 
                    
                    //Requisição para enviar notificação para o validador
                    
                    string bodyValidador_3 = '{'+
                        +'"request_signature_key": "'+ idValidador +'",'+
                        +'"message": "Prezado,\nPor favor assine o documento.\n\nQualquer dúvida estou à disposição.\n\nAtenciosamente,\nHOSPCOM"}';
                    
                    HttpRequest reqValidador_3 = new HttpRequest();
                    reqValidador_3.setMethod('POST');
                    reqValidador_3.setEndpoint('https://app.clicksign.com/api/v1/' + endpoint +'?access_token=' + token);
                    reqValidador_3.setHeader('Content-Type', 'application/json');
                    //req.setTimeout(120000);
                    reqValidador_3.setBody(bodyValidador_3);
                    HttpResponse respostValidador_3 = new HttpResponse();
                    
                    respostValidador_3 = new Http().send(reqValidador_3);
                    
                    l0g = l0g + '\n resposta requisicao notificar validador: ' + respostValidador_3.getStatus();
                }
                
                //Adicionar o Validador 2
                if(cotacao.Validador2__c != null){
                    string bodyValidador2;
                    if(modoEnvio == 1){
                        bodyValidador2 = '{' +
                            +'"signer": { ' +
                            +'"email": "'+ cotacao.Validador2__r.Email +'", '+
                            +'"auths": [ ' +
                            +'"email" ' +
                            +'], '+
                            +'"name": "'+ cotacao.Validador2__r.Firstname + ' ' + cotacao.Validador2__r.LastName +'",' +
                            +'"documentation": "'+ cotacao.Validador2__r.CPF__c +'",' +
                            +'"has_documentation": true,' +
                            +'"selfie_enabled": false,'+
                            +'"handwritten_enabled": false,'+
                            +'"official_document_enabled": false,' +
                            +'"liveness_enabled": false,'+
                            +'"facial_biometrics_enabled": false'+
                            +'}'+
                            +'}';
                    }
                    else if(modoEnvio == 2){
                        bodyValidador2 = '{' +
                            +'"signer": { ' +
                            +'"phone_number": "'+ cotacao.Validador2__r.MobilePhone.replace('+55', '').replaceAll('[^0-9]', '') +'", '+
                            +'"auths": [ ' +
                            +'"whatsapp" ' +
                            +'], '+
                            +'"name": "'+ cotacao.Validador2__r.Firstname + ' ' + cotacao.Validador2__r.LastName +'",' +
                            +'"documentation": "'+ cotacao.Validador2__r.CPF__c +'",' +
                            +'"has_documentation": true,' +
                            +'"communicate_by": "whatsapp",' +
                            +'"selfie_enabled": false,'+
                            +'"handwritten_enabled": false,'+
                            +'"official_document_enabled": false,' +
                            +'"liveness_enabled": false,'+
                            +'"facial_biometrics_enabled": false'+
                            +'}'+
                            +'}';
                    }
                    
                    HttpRequest reqValidador2 = new HttpRequest();
                    reqValidador2.setMethod('POST');
                    reqValidador2.setEndpoint('https://app.clicksign.com/api/v1/signers?access_token='+ token);
                    reqValidador2.setHeader('Content-Type', 'application/json');
                    //req.setTimeout(120000);
                    reqValidador2.setBody(bodyValidador2);
                    HttpResponse respostValidador2 = new HttpResponse();
                    
                    respostValidador2 = new Http().send(reqValidador2);
                    
                    l0g = l0g + ' resposta requisicao criar validador 2: ' + respostValidador2.getBody();
                    
                    idSignatarioValidador2 = respostValidador2.getBody().substringAfter('"key":"').substringBefore('",'); //salvar id do signatário novo
                    
                    l0g = l0g + '\n ID DO NOVO VALIDADOR 2 ADICIONADO:: ' + idSignatarioValidador2;
                    
                    //Requisição para adicionar o validador 2 ao documento
                    string bodyValidador2_2 = '{"list": {"document_key": "'+ keyid +'",'+
                        +'"signer_key": "'+ idSignatarioValidador2 +'",'+
                        +'"sign_as": "validator",'+
                        +'"refusable": true,'+
                        +'"group": 1,'+
                        +'"message": "Prezado,\nPor favor assine o documento.\n\nQualquer dúvida estamos à disposição.\n\nAtenciosamente, \nHOSPCOM"}}';
                    
                    HttpRequest reqValidador2_2 = new HttpRequest();
                    reqValidador2_2.setMethod('POST');
                    reqValidador2_2.setEndpoint('https://app.clicksign.com/api/v1/lists?access_token=' + token);
                    reqValidador2_2.setHeader('Content-Type', 'application/json');
                    //req.setTimeout(120000);
                    reqValidador2_2.setBody(bodyValidador2_2);
                    HttpResponse respostValidador2_2 = new HttpResponse();
                    
                    respostValidador2_2 = new Http().send(reqValidador2_2);
                    
                    l0g = l0g + '\n resposta requisicao adicionar validador 2: ' + respostValidador2_2.getBody();
                    
                    string idValidador2 = respostValidador2_2.getBody().substringAfter('request_signature_key":"').substringBefore('","document'); 
                    
                    //Requisição para enviar notificação para o validador 2
                    
                    string bodyValidador2_3 = '{'+
                        +'"request_signature_key": "'+ idValidador2 +'",'+
                        +'"message": "Prezado,\nPor favor assine o documento.\n\nQualquer dúvida estou à disposição.\n\nAtenciosamente,\nHOSPCOM"}';
                    
                    HttpRequest reqValidador2_3 = new HttpRequest();
                    reqValidador2_3.setMethod('POST');
                    reqValidador2_3.setEndpoint('https://app.clicksign.com/api/v1/' + endpoint +'?access_token=' + token);
                    reqValidador2_3.setHeader('Content-Type', 'application/json');
                    //req.setTimeout(120000);
                    reqValidador2_3.setBody(bodyValidador2_3);
                    HttpResponse respostValidador2_3 = new HttpResponse();
                    
                    respostValidador2_3 = new Http().send(reqValidador2_3);
                    
                    l0g = l0g + '\n resposta requisicao notificar validador 2: ' + respostValidador2_3.getStatus();
                }
                
                //Adicionar o financeiro no processo de assinatura
                string bodyFinanceiro = '{"list": {"document_key": "'+ keyid +'",'+
                    +'"signer_key": "'+ idSignatarioFinanceiro +'",'+
                    +'"sign_as": "approve",'+
                    +'"refusable": true,'+
                    +'"group": 2,'+
                    +'"message": "Prezado,\nPor favor assine o documento.\n\nQualquer dúvida estamos à disposição.\n\nAtenciosamente, \nHOSPCOM"}}';
                
                HttpRequest reqFinanceiro = new HttpRequest();
                reqFinanceiro.setMethod('POST');
                reqFinanceiro.setEndpoint('https://app.clicksign.com/api/v1/lists?access_token=' + token);
                reqFinanceiro.setHeader('Content-Type', 'application/json');
                //req.setTimeout(120000);
                reqFinanceiro.setBody(bodyFinanceiro);
                HttpResponse resposFinanceiro = new HttpResponse();
                
                resposFinanceiro = new Http().send(reqFinanceiro);
                
                l0g = l0g + '\n resposta requisicao adicionar financeiro: ' + resposFinanceiro.getBody();
                
                string idAssinaturaFinanceiro = resposFinanceiro.getBody().substringAfter('request_signature_key":"').substringBefore('","document');
                
                //Adicionar o juridico no processo de assinatura
                string bodyJuridico = '{"list": {"document_key": "'+ keyid +'",'+
                    +'"signer_key": "'+ idSignatarioJuridico +'",'+
                    +'"sign_as": "witness",'+
                    +'"refusable": true,'+
                    +'"group": 3,'+
                    +'"message": "Prezado,\nPor favor assine o documento.\n\nQualquer dúvida estamos à disposição.\n\nAtenciosamente, \nHOSPCOM"}}';
                
                HttpRequest reqJuridico = new HttpRequest();
                reqJuridico.setMethod('POST');
                reqJuridico.setEndpoint('https://app.clicksign.com/api/v1/lists?access_token=' + token);
                reqJuridico.setHeader('Content-Type', 'application/json');
                //req.setTimeout(120000);
                reqJuridico.setBody(bodyJuridico);
                HttpResponse resposJuridico = new HttpResponse();
                
                resposJuridico = new Http().send(reqJuridico);
                
                l0g = l0g + '\n resposta requisicao adicionar juridico: ' + resposJuridico.getBody();
                
                string idAssinaturaJuridico = resposJuridico.getBody().substringAfter('request_signature_key":"').substringBefore('","document');
                
                //Adicionar o administrativo no processo de assinatura
                string bodyAdm = '{"list": {"document_key": "'+ keyid +'",'+
                    +'"signer_key": "'+ idSignatarioAdm +'",'+
                    +'"sign_as": "party",'+
                    +'"refusable": true,'+
                    +'"group": 3,'+
                    +'"message": "Prezado,\nPor favor assine o documento.\n\nQualquer dúvida estamos à disposição.\n\nAtenciosamente, \nHOSPCOM"}}';
                
                HttpRequest reqAdm = new HttpRequest();
                reqAdm.setMethod('POST');
                reqAdm.setEndpoint('https://app.clicksign.com/api/v1/lists?access_token=' + token);
                reqAdm.setHeader('Content-Type', 'application/json');
                //req.setTimeout(120000);
                reqAdm.setBody(bodyAdm);
                HttpResponse resposAdm = new HttpResponse();
                
                resposAdm = new Http().send(reqAdm);
                
                l0g = l0g + '\n resposta requisicao adicionar adm: ' + resposAdm.getBody();
                
                string idAssinaturaAdm = resposAdm.getBody().substringAfter('request_signature_key":"').substringBefore('","document');
                
                
                try{
                    update cotacao;
                    
                    insert doc;
                }
                catch(DmlException e){
                    if(!Test.isRunningTest())
                        throw new AuraHandledException(e.getMessage());
                }
                
                
                //Cria e carrega um documento com as informações para o log
                Document logDoc = new Document(
                    Name = String.valueOf(System.Now().format('yyyy/MM/dd HH:mm:ss')) + ' - Cotação: ' + cotacao.QuoteNumber,
                    Body = Blob.valueOf(l0g),
                    ContentType = 'text/plain',
                    Type = 'txt',
                    IsPublic = false,
                    IsInternalUseOnly = true,
                    FolderId = '00l6e000002JcWd'        
                );
                insert logDoc;
            }
            else{
                throw new AuraHandledException('Erro de envio, forneça as seguintes informações para o suporte: ' + 'StatusCode: ' + resp.getStatusCode() + '; ResponseBody: ' + resp.getBody() + '');  
            }
        }  
        else{
            throw new AuraHandledException('Erro de envio, forneça as seguintes informações para o suporte: ' + 'StatusCode: ' + resp.getStatusCode() + '; ResponseBody: ' + resp.getBody() + '');  
        }
    }
    @AuraEnabled
    public static void cancelar(string idContrato){
        
        Tokens_Clicksign__mdt geral = [SELECT DeveloperName, Token__c FROM Tokens_Clicksign__mdt WHERE DeveloperName ='Geral'];
        
        string token = geral.Token__c;
        
        Quote cotacao = [SELECT ID, idDocAutentique__c
                         FROM Quote 
                         WHERE ID =: idContrato];
        
        
        HttpRequest cancela = new HttpRequest();
        cancela.setMethod('PATCH');
        cancela.setEndpoint('https://app.clicksign.com/api/v1/documents/'+ cotacao.idDocAutentique__c +'/cancel?access_token=' + token);
        cancela.setHeader('Content-Type', 'application/json');
        cancela.setHeader('Accept', 'application/json');
        
        HttpResponse rCancela = new HttpResponse();
        rCancela = new Http().send(cancela);
        
        
        system.debug(rCancela.getBody());
        Integer statusCode = rCancela.getStatusCode();
        cotacao.Fase__c = 'Cancelado';
        cotacao.idDocAutentique__c = '';
        update cotacao;
        
    }
    
    @AuraEnabled
    public static string consultar(string idContrato){
        
        Tokens_Clicksign__mdt geral = [SELECT DeveloperName, Token__c FROM Tokens_Clicksign__mdt WHERE DeveloperName ='Geral'];
        
        string token = geral.Token__c;
        
        Quote cotacao = [SELECT ID, idDocAutentique__c
                         FROM Quote 
                         WHERE ID =: idContrato];
        
        
        HttpRequest consulta = new HttpRequest();
        consulta.setMethod('GET');
        consulta.setEndpoint('https://app.clicksign.com/api/v1/documents/'+ cotacao.idDocAutentique__c +'?access_token=' + token);
        consulta.setHeader('Content-Type', 'application/json');
        consulta.setHeader('Accept', 'application/json');
        //req.setTimeout(120000);
        HttpResponse rConsulta = new HttpResponse();
        rConsulta = new Http().send(consulta);
        
        return rConsulta.getBody();
        
        
    }
    
    
    //Parte do contrato de serviço (locação)
    @AuraEnabled
    public static void enviarLocacao(string idContrato, integer modoEnvio){
        
        Contrato_de_Servi_o__c contrato = [SELECT ID, OwnerId, N_mero_da_Proposta_Contrato__c, Contato_do_Locat_rio__r.idDoSignatario__c, Contato_do_Locat_rio__r.CPF__c, Contato_do_Locat_rio__r.FirstName, Contato_do_Locat_rio__r.LastName, Contato_do_Locat_rio__r.Email, Contato_do_Locat_rio__r.MobilePhone,
                                           Testemunha__r.idDoSignatario__c, Testemunha__r.FirstName, Testemunha__r.LastName, Testemunha__r.Email, Testemunha__r.CPF__c, Testemunha__r.MobilePhone, Testemunha__r.AccountId,
                                           Assinante2__r.idDoSignatario__c, Assinante2__r.FirstName, Assinante2__r.LastName, Assinante2__r.Email, Assinante2__r.CPF__c, Assinante2__r.MobilePhone,
                                           Validador__r.idDoSignatario__c, Validador__r.FirstName, Validador__r.LastName, Validador__r.Email, Validador__r.CPF__c, Validador__r.MobilePhone,
                                           Validador2__r.idDoSignatario__c, Validador2__r.FirstName, Validador2__r.LastName, Validador2__r.Email, Validador2__r.CPF__c, Validador2__r.MobilePhone,
                                           Fiador__c, Fiador__r.idDoSignatario__c, Fiador__r.Name, Fiador__r.CPF__pc, Fiador__r.PersonEmail, Fiador__r.PersonMobilePhone, Vendedor_do_Contrato__c,
                                           Conjuge_do_fiador__c, Conjuge_do_fiador__r.idDoSignatario__c, Conjuge_do_fiador__r.Name, Conjuge_do_fiador__r.CPF__pc, Conjuge_do_fiador__r.PersonEmail, Conjuge_do_fiador__r.PersonMobilePhone, RecordTypeId 
                                           FROM Contrato_de_Servi_o__c 
                                           WHERE ID =: idContrato];
        
        string endpoint;
        if(modoEnvio == 1)
            endpoint = 'notifications';
        else if(modoEnvio == 2)
            endpoint = 'notify_by_whatsapp';
        
        contact signatario = [SELECT idDoSignatario__c FROM Contact WHERE ID =: contrato.Contato_do_Locat_rio__c];
        
        Contact testemunha = [SELECT idDoSignatario__c FROM Contact WHERE ID =: contrato.Testemunha__c];
        
        User vendedor = [SELECT ID, Email, FirstName, LastName, idDoSignatario__c FROM User WHERE ID =: contrato.Vendedor_do_Contrato__c]; 
        
        string idSignatario = contrato.Contato_do_Locat_rio__r.idDoSignatario__c;
        string idSignatarioTest = contrato.Testemunha__r.idDoSignatario__c;
        string idSignatarioFiador = contrato.Fiador__r.idDoSignatario__c;
        string idSignatarioVendedor = vendedor.idDoSignatario__c;
        string idSignatarioConjugeFiador = contrato.Conjuge_do_fiador__r.idDoSignatario__c;
        string idSignatarioAssinante2;
        string idSignatarioValidador;
        string idSignatarioValidador2;
        string cpfTestemunha;
        
        Tokens_Clicksign__mdt juridico = [SELECT DeveloperName, Token__c FROM Tokens_Clicksign__mdt WHERE DeveloperName ='Juridico'];
        Tokens_Clicksign__mdt financeiro = [SELECT DeveloperName, Token__c FROM Tokens_Clicksign__mdt WHERE DeveloperName ='Financeiro'];
        Tokens_Clicksign__mdt adm = [SELECT DeveloperName, Token__c FROM Tokens_Clicksign__mdt WHERE DeveloperName ='Adm'];
        Tokens_Clicksign__mdt geral = [SELECT DeveloperName, Token__c FROM Tokens_Clicksign__mdt WHERE DeveloperName ='Geral'];
        
        string idSignatarioJuridico = juridico.Token__c;
        string idSignatarioFinanceiro = financeiro.Token__c;
        string idSignatarioAdm = adm.Token__c;
        string token = geral.Token__c;
        
        string l0g = '';
        
        HttpRequest req = new HttpRequest();
        
        PageReference pdf;
        
        String nomeDoDocumento;
        if(contrato.RecordTypeId != '0125A000001QydfQAC'){
            nomeDoDocumento = 'Contrato de Prestação de Serviços ' + contrato.N_mero_da_Proposta_Contrato__c;
            pdf = Page.Contratoservicoprivado;
        }
        else{
            nomeDoDocumento = 'Contrato Locação ' + contrato.N_mero_da_Proposta_Contrato__c;
            pdf = Page.ContratoLocacao;            
        }
        
        pdf.getParameters().put('id', idContrato);
        
        Blob pdfBody;
        String base64PDF;
        
        if (!Test.IsRunningTest()){
            pdfBody = pdf.getContentAsPDF();
            base64PDF = EncodingUtil.base64Encode(pdfBody);
        }
        else{
            pdfBody = Blob.valueOf('Teste');
            base64PDF = 'TESTE';
        }
        
        dateTime agora = system.now();
        
        
        
        req.setMethod('POST');
        req.setEndpoint('http://oldsite.hospcom.net:21220/clickSign');
        req.setHeader('Content','{"document":{"path": "/' + nomeDoDocumento + '.pdf","content_base64": "data:application/pdf;base64,%","locale": "pt-BR","sequence_enabled": true}}');
        req.setTimeout(120000);
        req.setBody(base64PDF);
        
        //system.debug(req.getBody());
        
        //system.debug('base64:::::' + req.getBody());
        
        HttpResponse resp = new HttpResponse();
        
        resp = new Http().send(req);
        
        system.debug(resp.getBody());
        
        string keyid = resp.getBody();
        
        l0g = 'ID do Documento: ' + keyid +
            + '\n \n Requisição de envio para o Servidor' + req;
        
        if(contrato.Testemunha__r.AccountId == '001i00000085QYbAAM'){
            Dados_colaborador__c dados = [SELECT CPF__c FROM Dados_colaborador__c WHERE Contato__c =: contrato.Testemunha__c];
            cpfTestemunha = dados.CPF__c;
        }
        else{
            cpfTestemunha = contrato.Testemunha__r.CPF__c;
        }
        
        if(resp.getStatusCode() == 200){
            if(!keyId.contains('error')){
                
                Autentique__c doc = new Autentique__c(idDocAutentique__c = keyid, Nome_do_Documento__c = nomeDoDocumento);
                
                contrato.idDocAutentique__c = keyid;
                contrato.Data_da_fase__c = SYSTEM.NOW();
                contrato.Fase__c = '1';
                //Requisição para criar o signatário no Clicksign caso ele ainda não tenha
                string body;
                if(idSignatario == null){
                    if(modoEnvio == 1){
                        body = '{' +
                            +'"signer": { ' +
                            +'"email": "'+ contrato.Contato_do_Locat_rio__r.Email +'", '+
                            +'"auths": [ ' +
                            +'"email" ' +
                            +'], '+
                            +'"name": "'+ contrato.Contato_do_Locat_rio__r.Firstname + ' ' + contrato.Contato_do_Locat_rio__r.LastName +'",' +
                            +'"documentation": "'+ contrato.Contato_do_Locat_rio__r.CPF__c +'",' +
                            +'"has_documentation": true,' +
                            +'"selfie_enabled": false,'+
                            +'"handwritten_enabled": false,'+
                            +'"official_document_enabled": false,' +
                            +'"liveness_enabled": false,'+
                            +'"facial_biometrics_enabled": false'+
                            +'}'+
                            +'}';
                    }
                    else if(modoEnvio == 2){
                        body = '{' +
                            +'"signer": { ' +
                            +'"phone_number": "'+ contrato.Contato_do_Locat_rio__r.MobilePhone.replace('+55', '').replaceAll('[^0-9]', '') +'", '+
                            +'"auths": [ ' +
                            +'"whatsapp" ' +
                            +'], '+
                            +'"name": "'+ contrato.Contato_do_Locat_rio__r.Firstname + ' ' + contrato.Contato_do_Locat_rio__r.LastName +'",' +
                            +'"documentation": "'+ contrato.Contato_do_Locat_rio__r.CPF__c +'",' +
                            +'"has_documentation": true,' +
                            +'"communicate_by": "whatsapp",' +
                            +'"selfie_enabled": false,'+
                            +'"handwritten_enabled": false,'+
                            +'"official_document_enabled": false,' +
                            +'"liveness_enabled": false,'+
                            +'"facial_biometrics_enabled": false'+
                            +'}'+
                            +'}';
                    }
                    
                    
                    HttpRequest req2 = new HttpRequest();
                    req2.setMethod('POST');
                    req2.setEndpoint('https://app.clicksign.com/api/v1/signers?access_token='+ token);
                    req2.setHeader('Content-Type', 'application/json');
                    //req.setTimeout(120000);
                    req2.setBody(body);
                    HttpResponse respost = new HttpResponse();
                    
                    respost = new Http().send(req2);
                    
                    l0g = l0g + ' resposta requisicao criar assinador: ' + respost.getBody();
                    
                    idSignatario = respost.getBody().substringAfter('"key":"').substringBefore('",'); //salvar id do signatário novo
                    
                    l0g = l0g + '\n ID DO NOVO SIGNATARIO ADICIONADO:: ' + idSignatario;
                    
                }
                
                //Requisição para adicionar o signatário ao documento
                string body3 = '{"list": {"document_key": "'+ keyid +'",'+
                    +'"signer_key": "'+ idSignatario +'",'+
                    +'"sign_as": "party",'+
                    +'"refusable": true,'+
                    +'"group": 1,'+
                    +'"message": "Prezado,\nPor favor assine o documento.\n\nQualquer dúvida estamos à disposição.\n\nAtenciosamente, \nHOSPCOM"}}';
                
                HttpRequest req3 = new HttpRequest();
                req3.setMethod('POST');
                req3.setEndpoint('https://app.clicksign.com/api/v1/lists?access_token=' + token);
                req3.setHeader('Content-Type', 'application/json');
                //req.setTimeout(120000);
                req3.setBody(body3);
                HttpResponse respost3 = new HttpResponse();
                
                respost3 = new Http().send(req3);
                
                l0g = l0g + '\n resposta requisicao adicionar assinador: ' + respost3.getBody();
                
                string idAssinatura = respost3.getBody().substringAfter('request_signature_key":"').substringBefore('","document'); 
                
                //Requisição para enviar notificação para o assinador
                
                string body4 = '{'+
                    +'"request_signature_key": "'+ idAssinatura +'",'+
                    +'"message": "Prezado,\nPor favor assine o documento.\n\nQualquer dúvida estou à disposição.\n\nAtenciosamente,\nHOSPCOM"}';
                
                HttpRequest req4 = new HttpRequest();
                req4.setMethod('POST');
                req4.setEndpoint('https://app.clicksign.com/api/v1/' + endpoint +'?access_token=' + token);
                req4.setHeader('Content-Type', 'application/json');
                //req.setTimeout(120000);
                req4.setBody(body4);
                HttpResponse respost4 = new HttpResponse();
                
                respost4 = new Http().send(req4);
                
                l0g = l0g + '\n resposta requisicao notificar assinador: ' + respost4.getStatus();
                
                //Testemunha
                
                if(idSignatarioTest == null){
                    string bodyTest;
                    
                    if(modoEnvio == 1){
                        bodyTest = '{' +
                            +'"signer": { ' +
                            +'"email": "'+ contrato.Testemunha__r.Email +'", '+
                            +'"auths": [ ' +
                            +'"email" ' +
                            +'], '+
                            +'"name": "'+ contrato.Testemunha__r.Firstname + ' ' + contrato.Testemunha__r.LastName +'",' +
                            +'"documentation": "'+ cpfTestemunha +'",' +
                            +'"has_documentation": true,' +
                            +'"selfie_enabled": false,'+
                            +'"handwritten_enabled": false,'+
                            +'"official_document_enabled": false,' +
                            +'"liveness_enabled": false,'+
                            +'"facial_biometrics_enabled": false'+
                            +'}'+
                            +'}';
                    }
                    else if(modoEnvio == 2){
                        bodyTest = '{' +
                            +'"signer": { ' +
                            +'"phone_number": "'+ contrato.Testemunha__r.MobilePhone.replace('+55', '').replaceAll('[^0-9]', '') +'", '+
                            +'"auths": [ ' +
                            +'"whatsapp" ' +
                            +'], '+
                            +'"name": "'+ contrato.Testemunha__r.Firstname + ' ' + contrato.Testemunha__r.LastName +'",' +
                            +'"documentation": "'+ cpfTestemunha +'",' +
                            +'"has_documentation": true,' +
                            +'"communicate_by": "whatsapp",' +
                            +'"selfie_enabled": false,'+
                            +'"handwritten_enabled": false,'+
                            +'"official_document_enabled": false,' +
                            +'"liveness_enabled": false,'+
                            +'"facial_biometrics_enabled": false'+
                            +'}'+
                            +'}';
                    }
                    
                    HttpRequest reqTest = new HttpRequest();
                    reqTest.setMethod('POST');
                    reqTest.setEndpoint('https://app.clicksign.com/api/v1/signers?access_token=' + token);
                    reqTest.setHeader('Content-Type', 'application/json');
                    //req.setTimeout(120000);
                    reqTest.setBody(bodyTest);
                    HttpResponse resposTest = new HttpResponse();
                    
                    resposTest = new Http().send(reqTest);
                    
                    l0g = l0g + '\n resposta requisicao criar testemunha: ' + resposTest.getBody();
                    
                    idSignatarioTest = resposTest.getBody().substringAfter('"key":"').substringBefore('",'); //salvar id do signatário novo
                    
                    
                    l0g = l0g + '\n ID DO NOVO TESTEMUNHA ADICIONADO:: ' + idSignatarioTest;                    
                    
                }
                
                //Requisição para adicionar a testemunha ao documento
                string bodyTest2 = '{"list": {"document_key": "'+ keyid +'",'+
                    +'"signer_key": "'+ idSignatarioTest +'",'+
                    +'"sign_as": "witness",'+
                    +'"refusable": true,'+
                    +'"group": 1,'+
                    +'"message": "Prezado,\nPor favor assine o documento.\n\nQualquer dúvida estamos à disposição.\n\nAtenciosamente, \nHOSPCOM"}}';
                
                HttpRequest reqTest2 = new HttpRequest();
                reqTest2.setMethod('POST');
                reqTest2.setEndpoint('https://app.clicksign.com/api/v1/lists?access_token=' + token);
                reqTest2.setHeader('Content-Type', 'application/json');
                //req.setTimeout(120000);
                reqTest2.setBody(bodyTest2);
                HttpResponse resposTest2 = new HttpResponse();
                
                resposTest2 = new Http().send(reqTest2);
                
                l0g = l0g + '\n resposta requisicao adicionar testemunha: ' + resposTest2.getBody();
                
                string idAssinaturaTest = resposTest2.getBody().substringAfter('request_signature_key":"').substringBefore('","document');                                       
                
                //Requisição para enviar notificação para a testemunha
                
                string bodyTest3 = '{'+
                    +'"request_signature_key": "'+ idAssinaturaTest +'",'+
                    +'"message": "Prezado,\nPor favor assine o documento.\n\nQualquer dúvida estou à disposição.\n\nAtenciosamente,\nHOSPCOM"}';
                
                HttpRequest reqTest3 = new HttpRequest();
                reqTest3.setMethod('POST');
                reqTest3.setEndpoint('https://app.clicksign.com/api/v1/'+ endpoint + '?access_token=' + token);
                reqTest3.setHeader('Content-Type', 'application/json');
                //req.setTimeout(120000);
                reqTest3.setBody(bodyTest3);
                HttpResponse resposTest3 = new HttpResponse();
                
                resposTest3 = new Http().send(reqTest3);
                
                l0g = l0g + '\n resposta requisicao notificar testemunha: ' + resposTest3.getStatus();
                
                
                //Caso o contrato tenha fiador                        
                if(contrato.Fiador__c != null){
                    string bodyFiador;
                    if(modoEnvio == 1){
                        bodyFiador = '{' +
                            +'"signer": { ' +
                            +'"email": "'+ contrato.Fiador__r.PersonEmail +'", '+
                            +'"auths": [ ' +
                            +'"email" ' +
                            +'], '+
                            +'"name": "'+ contrato.Fiador__r.Name +'",' +
                            +'"documentation": "'+ contrato.Fiador__r.CPF__pc +'",' +
                            +'"has_documentation": true,' +
                            +'"selfie_enabled": false,'+
                            +'"handwritten_enabled": false,'+
                            +'"official_document_enabled": false,' +
                            +'"liveness_enabled": false,'+
                            +'"facial_biometrics_enabled": false'+
                            +'}'+
                            +'}';
                    }
                    else if(modoEnvio == 2){
                        bodyFiador = '{' +
                            +'"signer": { ' +
                            +'"phone_number": "'+ contrato.Fiador__r.PersonMobilePhone.replace('+55', '').replaceAll('[^0-9]', '') +'", '+
                            +'"auths": [ ' +
                            +'"whatsapp" ' +
                            +'], '+
                            +'"name": "'+ contrato.Fiador__r.Name +'",' +
                            +'"documentation": "'+ contrato.Fiador__r.CPF__pc +'",' +
                            +'"has_documentation": true,' +
                            +'"communicate_by": "whatsapp",' +
                            +'"selfie_enabled": false,'+
                            +'"handwritten_enabled": false,'+
                            +'"official_document_enabled": false,' +
                            +'"liveness_enabled": false,'+
                            +'"facial_biometrics_enabled": false'+
                            +'}'+
                            +'}';
                    }
                    
                    HttpRequest reqFiador = new HttpRequest();
                    reqFiador.setMethod('POST');
                    reqFiador.setEndpoint('https://app.clicksign.com/api/v1/signers?access_token=' + token);
                    reqFiador.setHeader('Content-Type', 'application/json');
                    //req.setTimeout(120000);
                    reqFiador.setBody(bodyFiador);
                    HttpResponse resposFiador = new HttpResponse();
                    
                    resposFiador = new Http().send(reqFiador);
                    
                    l0g = l0g + '\n resposta requisicao criar fiador: ' + resposFiador.getBody();
                    
                    idSignatarioFiador = resposFiador.getBody().substringAfter('"key":"').substringBefore('",'); //salvar id do signatário novo
                    
                    l0g = l0g + '\n ID DO NOVO FIADOR ADICIONADO:: ' + idSignatarioFiador;
                    
                    
                    //Requisição para adicionar o fiador ao documento
                    string bodyFiador2 = '{"list": {"document_key": "'+ keyid +'",'+
                        +'"signer_key": "'+ idSignatarioFiador +'",'+
                        +'"sign_as": "surety",'+
                        +'"refusable": true,'+
                        +'"group": 1,'+
                        +'"message": "Prezado,\nPor favor assine o documento.\n\nQualquer dúvida estamos à disposição.\n\nAtenciosamente, \nHOSPCOM"}}';
                    
                    HttpRequest reqFiador2 = new HttpRequest();
                    reqFiador2.setMethod('POST');
                    reqFiador2.setEndpoint('https://app.clicksign.com/api/v1/lists?access_token=' + token);
                    reqFiador2.setHeader('Content-Type', 'application/json');
                    //req.setTimeout(120000);
                    reqFiador2.setBody(bodyFiador2);
                    HttpResponse resposFiador2 = new HttpResponse();
                    
                    resposFiador2 = new Http().send(reqFiador2);
                    
                    l0g = l0g + '\n resposta requisicao adicionar fiador: ' + resposFiador2.getBody();
                    
                    string idAssinaturaFiador = resposFiador2.getBody().substringAfter('request_signature_key":"').substringBefore('","document'); 
                    
                    //Requisição para enviar notificação para o fiador
                    
                    string bodyFiador3 = '{'+
                        +'"request_signature_key": "'+ idAssinaturaFiador +'",'+
                        +'"message": "Prezado,\nPor favor assine o documento.\n\nQualquer dúvida estou à disposição.\n\nAtenciosamente,\nHOSPCOM"}';
                    
                    HttpRequest reqFiador3 = new HttpRequest();
                    reqFiador3.setMethod('POST');
                    reqFiador3.setEndpoint('https://app.clicksign.com/api/v1/'+ endpoint + '?access_token=' + token);
                    reqFiador3.setHeader('Content-Type', 'application/json');
                    //req.setTimeout(120000);
                    reqFiador3.setBody(bodyFiador3);
                    HttpResponse resposFiador3 = new HttpResponse();
                    
                    resposFiador3 = new Http().send(reqFiador3);
                    
                    l0g = l0g + '\n resposta requisicao notificar fiador: ' + resposFiador3.getStatus();
                    
                }
                
                //Caso o contrato tenha conjuge do fiador                        
                if(contrato.Conjuge_do_fiador__c != null){
                    string bodyConjFiador;
                    if(modoEnvio == 1){
                        bodyConjFiador = '{' +
                            +'"signer": { ' +
                            +'"email": "'+ contrato.Conjuge_do_fiador__r.PersonEmail +'", '+
                            +'"auths": [ ' +
                            +'"email" ' +
                            +'], '+
                            +'"name": "'+ contrato.Conjuge_do_fiador__r.Name +'",' +
                            +'"documentation": "'+ contrato.Conjuge_do_fiador__r.CPF__pc +'",' +
                            +'"has_documentation": true,' +
                            +'"selfie_enabled": false,'+
                            +'"handwritten_enabled": false,'+
                            +'"official_document_enabled": false,' +
                            +'"liveness_enabled": false,'+
                            +'"facial_biometrics_enabled": false'+
                            +'}'+
                            +'}';
                    }
                    else if(modoEnvio == 2){
                        bodyConjFiador = '{' +
                            +'"signer": { ' +
                            +'"phone_number": "'+ contrato.Conjuge_do_fiador__r.PersonMobilePhone.replace('+55', '').replaceAll('[^0-9]', '') +'", '+
                            +'"auths": [ ' +
                            +'"whatsapp" ' +
                            +'], '+
                            +'"name": "'+ contrato.Conjuge_do_fiador__r.Name +'",' +
                            +'"documentation": "'+ contrato.Conjuge_do_fiador__r.CPF__pc +'",' +
                            +'"has_documentation": true,' +
                            +'"communicate_by": "whatsapp",' +
                            +'"selfie_enabled": false,'+
                            +'"handwritten_enabled": false,'+
                            +'"official_document_enabled": false,' +
                            +'"liveness_enabled": false,'+
                            +'"facial_biometrics_enabled": false'+
                            +'}'+
                            +'}';
                    }
                    
                    HttpRequest reqConjFiador = new HttpRequest();
                    reqConjFiador.setMethod('POST');
                    reqConjFiador.setEndpoint('https://app.clicksign.com/api/v1/signers?access_token=' + token);
                    reqConjFiador.setHeader('Content-Type', 'application/json');
                    //req.setTimeout(120000);
                    reqConjFiador.setBody(bodyConjFiador);
                    HttpResponse resposConjFiador = new HttpResponse();
                    
                    resposConjFiador = new Http().send(reqConjFiador);
                    
                    l0g = l0g + '\n resposta requisicao criar conjuge: ' + resposConjFiador.getBody();
                    
                    idSignatarioConjugeFiador = resposConjFiador.getBody().substringAfter('"key":"').substringBefore('",'); //salvar id do signatário novo
                    
                    
                    l0g = l0g + '\n ID DO NOVO CONJUGE ADICIONADO:: ' + idSignatarioConjugeFiador;
                    
                    
                    //Requisição para adicionar o conjuge do fiador ao documento
                    string bodyConjFiador2 = '{"list": {"document_key": "'+ keyid +'",'+
                        +'"signer_key": "'+ idSignatarioConjugeFiador +'",'+
                        +'"sign_as": "surety",'+
                        +'"refusable": true,'+
                        +'"group": 1,'+
                        +'"message": "Prezado,\nPor favor assine o documento.\n\nQualquer dúvida estamos à disposição.\n\nAtenciosamente, \nHOSPCOM"}}';
                    
                    HttpRequest reqConjFiador2 = new HttpRequest();
                    reqConjFiador2.setMethod('POST');
                    reqConjFiador2.setEndpoint('https://app.clicksign.com/api/v1/lists?access_token=' + token);
                    reqConjFiador2.setHeader('Content-Type', 'application/json');
                    //req.setTimeout(120000);
                    reqConjFiador2.setBody(bodyConjFiador2);
                    HttpResponse resposConjFiador2 = new HttpResponse();
                    
                    resposConjFiador2 = new Http().send(reqConjFiador2);
                    
                    l0g = l0g + '\n resposta requisicao adicionar conjuge fiador: ' + resposConjFiador2.getBody();
                    
                    string idAssinaturaConjFiador = resposConjFiador2.getBody().substringAfter('request_signature_key":"').substringBefore('","document'); 
                    
                    //Requisição para enviar notificação para o conjuge do fiador
                    
                    string bodyConjFiador3 = '{'+
                        +'"request_signature_key": "'+ idAssinaturaConjFiador +'",'+
                        +'"message": "Prezado,\nPor favor assine o documento.\n\nQualquer dúvida estou à disposição.\n\nAtenciosamente,\nHOSPCOM"}';
                    
                    HttpRequest reqConjFiador3 = new HttpRequest();
                    reqConjFiador3.setMethod('POST');
                    reqConjFiador3.setEndpoint('https://app.clicksign.com/api/v1/' + endpoint +'?access_token=' + token);
                    reqConjFiador3.setHeader('Content-Type', 'application/json');
                    //req.setTimeout(120000);
                    reqConjFiador3.setBody(bodyConjFiador3);
                    HttpResponse resposConjFiador3 = new HttpResponse();
                    
                    resposConjFiador3 = new Http().send(reqConjFiador3);
                    
                    l0g = l0g + '\n resposta requisicao notificar conjuge do fiador: ' + resposConjFiador3.getStatus();
                    
                }
                
                //Adicionar o Assinante 2
                if(contrato.Assinante2__c != null){
                    string bodyAssin;
                    if(modoEnvio == 1){
                        bodyAssin = '{' +
                            +'"signer": { ' +
                            +'"email": "'+ contrato.Assinante2__r.Email +'", '+
                            +'"auths": [ ' +
                            +'"email" ' +
                            +'], '+
                            +'"name": "'+ contrato.Assinante2__r.Firstname + ' ' + contrato.Assinante2__r.LastName +'",' +
                            +'"documentation": "'+ contrato.Assinante2__r.CPF__c +'",' +
                            +'"has_documentation": true,' +
                            +'"selfie_enabled": false,'+
                            +'"handwritten_enabled": false,'+
                            +'"official_document_enabled": false,' +
                            +'"liveness_enabled": false,'+
                            +'"facial_biometrics_enabled": false'+
                            +'}'+
                            +'}';
                    }
                    else if(modoEnvio == 2){
                        bodyAssin = '{' +
                            +'"signer": { ' +
                            +'"phone_number": "'+ contrato.Assinante2__r.MobilePhone.replace('+55', '').replaceAll('[^0-9]', '') +'", '+
                            +'"auths": [ ' +
                            +'"whatsapp" ' +
                            +'], '+
                            +'"name": "'+ contrato.Assinante2__r.Firstname + ' ' + contrato.Assinante2__r.LastName +'",' +
                            +'"documentation": "'+ contrato.Assinante2__r.CPF__c +'",' +
                            +'"has_documentation": true,' +
                            +'"communicate_by": "whatsapp",' +
                            +'"selfie_enabled": false,'+
                            +'"handwritten_enabled": false,'+
                            +'"official_document_enabled": false,' +
                            +'"liveness_enabled": false,'+
                            +'"facial_biometrics_enabled": false'+
                            +'}'+
                            +'}';
                    }
                    
                    
                    HttpRequest reqAssin = new HttpRequest();
                    reqAssin.setMethod('POST');
                    reqAssin.setEndpoint('https://app.clicksign.com/api/v1/signers?access_token='+ token);
                    reqAssin.setHeader('Content-Type', 'application/json');
                    //req.setTimeout(120000);
                    reqAssin.setBody(bodyAssin);
                    HttpResponse respostAssin = new HttpResponse();
                    
                    respostAssin = new Http().send(reqAssin);
                    
                    l0g = l0g + ' resposta requisicao criar assinante 2: ' + respostAssin.getBody();
                    
                    idSignatarioAssinante2 = respostAssin.getBody().substringAfter('"key":"').substringBefore('",'); //salvar id do signatário novo
                    
                    l0g = l0g + '\n ID DO NOVO SIGNATARIO ADICIONADO:: ' + idSignatarioAssinante2;
                    
                    //Requisição para adicionar o assinante2 ao documento
                    string bodyAssin2 = '{"list": {"document_key": "'+ keyid +'",'+
                        +'"signer_key": "'+ idSignatarioAssinante2 +'",'+
                        +'"sign_as": "party",'+
                        +'"refusable": true,'+
                        +'"group": 1,'+
                        +'"message": "Prezado,\nPor favor assine o documento.\n\nQualquer dúvida estamos à disposição.\n\nAtenciosamente, \nHOSPCOM"}}';
                    
                    HttpRequest reqAssin2 = new HttpRequest();
                    reqAssin2.setMethod('POST');
                    reqAssin2.setEndpoint('https://app.clicksign.com/api/v1/lists?access_token=' + token);
                    reqAssin2.setHeader('Content-Type', 'application/json');
                    //req.setTimeout(120000);
                    reqAssin2.setBody(bodyAssin2);
                    HttpResponse respostAssin2 = new HttpResponse();
                    
                    respostAssin2 = new Http().send(reqAssin2);
                    
                    l0g = l0g + '\n resposta requisicao adicionar assinador: ' + respostAssin2.getBody();
                    
                    string idAssinatura2 = respostAssin2.getBody().substringAfter('request_signature_key":"').substringBefore('","document'); 
                    
                    //Requisição para enviar notificação para o assinante2
                    
                    string bodyAssin3 = '{'+
                        +'"request_signature_key": "'+ idAssinatura2 +'",'+
                        +'"message": "Prezado,\nPor favor assine o documento.\n\nQualquer dúvida estou à disposição.\n\nAtenciosamente,\nHOSPCOM"}';
                    
                    HttpRequest reqAssin4 = new HttpRequest();
                    reqAssin4.setMethod('POST');
                    reqAssin4.setEndpoint('https://app.clicksign.com/api/v1/' + endpoint +'?access_token=' + token);
                    reqAssin4.setHeader('Content-Type', 'application/json');
                    //req.setTimeout(120000);
                    reqAssin4.setBody(body4);
                    HttpResponse respostAssin4 = new HttpResponse();
                    
                    respostAssin4 = new Http().send(reqAssin4);
                    
                    l0g = l0g + '\n resposta requisicao notificar assinante 2: ' + respostAssin4.getStatus();
                }
                
                //Adicionar o Validador
                if(contrato.Validador__c != null){
                    string bodyValidador;
                    if(modoEnvio == 1){
                        bodyValidador = '{' +
                            +'"signer": { ' +
                            +'"email": "'+ contrato.Validador__r.Email +'", '+
                            +'"auths": [ ' +
                            +'"email" ' +
                            +'], '+
                            +'"name": "'+ contrato.Validador__r.Firstname + ' ' + contrato.Validador__r.LastName +'",' +
                            +'"documentation": "'+ contrato.Validador__r.CPF__c +'",' +
                            +'"has_documentation": true,' +
                            +'"selfie_enabled": false,'+
                            +'"handwritten_enabled": false,'+
                            +'"official_document_enabled": false,' +
                            +'"liveness_enabled": false,'+
                            +'"facial_biometrics_enabled": false'+
                            +'}'+
                            +'}';
                    }
                    else if(modoEnvio == 2){
                        bodyValidador = '{' +
                            +'"signer": { ' +
                            +'"phone_number": "'+ contrato.Validador__r.MobilePhone.replace('+55', '').replaceAll('[^0-9]', '') +'", '+
                            +'"auths": [ ' +
                            +'"whatsapp" ' +
                            +'], '+
                            +'"name": "'+ contrato.Validador__r.Firstname + ' ' + contrato.Validador__r.LastName +'",' +
                            +'"documentation": "'+ contrato.Validador__r.CPF__c +'",' +
                            +'"has_documentation": true,' +
                            +'"communicate_by": "whatsapp",' +
                            +'"selfie_enabled": false,'+
                            +'"handwritten_enabled": false,'+
                            +'"official_document_enabled": false,' +
                            +'"liveness_enabled": false,'+
                            +'"facial_biometrics_enabled": false'+
                            +'}'+
                            +'}';
                    }
                    
                    HttpRequest reqValidador = new HttpRequest();
                    reqValidador.setMethod('POST');
                    reqValidador.setEndpoint('https://app.clicksign.com/api/v1/signers?access_token='+ token);
                    reqValidador.setHeader('Content-Type', 'application/json');
                    //req.setTimeout(120000);
                    reqValidador.setBody(bodyValidador);
                    HttpResponse respostValidador = new HttpResponse();
                    
                    respostValidador = new Http().send(reqValidador);
                    
                    l0g = l0g + ' resposta requisicao criar validador: ' + respostValidador.getBody();
                    
                    idSignatarioValidador = respostValidador.getBody().substringAfter('"key":"').substringBefore('",'); //salvar id do signatário novo
                    
                    l0g = l0g + '\n ID DO NOVO VALIDADOR ADICIONADO:: ' + idSignatarioValidador;
                    
                    //Requisição para adicionar o validador ao documento
                    string bodyValidador_2 = '{"list": {"document_key": "'+ keyid +'",'+
                        +'"signer_key": "'+ idSignatarioValidador +'",'+
                        +'"sign_as": "validator",'+
                        +'"refusable": true,'+
                        +'"group": 1,'+
                        +'"message": "Prezado,\nPor favor assine o documento.\n\nQualquer dúvida estamos à disposição.\n\nAtenciosamente, \nHOSPCOM"}}';
                    
                    HttpRequest reqValidador_2 = new HttpRequest();
                    reqValidador_2.setMethod('POST');
                    reqValidador_2.setEndpoint('https://app.clicksign.com/api/v1/lists?access_token=' + token);
                    reqValidador_2.setHeader('Content-Type', 'application/json');
                    //req.setTimeout(120000);
                    reqValidador_2.setBody(bodyValidador_2);
                    HttpResponse respostValidador_2 = new HttpResponse();
                    
                    respostValidador_2 = new Http().send(reqValidador_2);
                    
                    l0g = l0g + '\n resposta requisicao adicionar assinador: ' + respostValidador_2.getBody();
                    
                    string idValidador = respostValidador_2.getBody().substringAfter('request_signature_key":"').substringBefore('","document'); 
                    
                    //Requisição para enviar notificação para o validador
                    
                    string bodyValidador_3 = '{'+
                        +'"request_signature_key": "'+ idValidador +'",'+
                        +'"message": "Prezado,\nPor favor assine o documento.\n\nQualquer dúvida estou à disposição.\n\nAtenciosamente,\nHOSPCOM"}';
                    
                    HttpRequest reqValidador_3 = new HttpRequest();
                    reqValidador_3.setMethod('POST');
                    reqValidador_3.setEndpoint('https://app.clicksign.com/api/v1/' + endpoint +'?access_token=' + token);
                    reqValidador_3.setHeader('Content-Type', 'application/json');
                    //req.setTimeout(120000);
                    reqValidador_3.setBody(bodyValidador_3);
                    HttpResponse respostValidador_3 = new HttpResponse();
                    
                    respostValidador_3 = new Http().send(reqValidador_3);
                    
                    l0g = l0g + '\n resposta requisicao notificar validador: ' + respostValidador_3.getStatus();
                }
                //Adicionar o Validador 2
                if(contrato.Validador2__c != null){
                    string bodyValidador2;
                    if(modoEnvio == 1){
                        bodyValidador2 = '{' +
                            +'"signer": { ' +
                            +'"email": "'+ contrato.Validador2__r.Email +'", '+
                            +'"auths": [ ' +
                            +'"email" ' +
                            +'], '+
                            +'"name": "'+ contrato.Validador2__r.Firstname + ' ' + contrato.Validador2__r.LastName +'",' +
                            +'"documentation": "'+ contrato.Validador2__r.CPF__c +'",' +
                            +'"has_documentation": true,' +
                            +'"selfie_enabled": false,'+
                            +'"handwritten_enabled": false,'+
                            +'"official_document_enabled": false,' +
                            +'"liveness_enabled": false,'+
                            +'"facial_biometrics_enabled": false'+
                            +'}'+
                            +'}';
                    }
                    else if(modoEnvio == 2){
                        bodyValidador2 = '{' +
                            +'"signer": { ' +
                            +'"phone_number": "'+ contrato.Validador2__r.MobilePhone.replace('+55', '').replaceAll('[^0-9]', '') +'", '+
                            +'"auths": [ ' +
                            +'"whatsapp" ' +
                            +'], '+
                            +'"name": "'+ contrato.Validador2__r.Firstname + ' ' + contrato.Validador2__r.LastName +'",' +
                            +'"documentation": "'+ contrato.Validador2__r.CPF__c +'",' +
                            +'"has_documentation": true,' +
                            +'"communicate_by": "whatsapp",' +
                            +'"selfie_enabled": false,'+
                            +'"handwritten_enabled": false,'+
                            +'"official_document_enabled": false,' +
                            +'"liveness_enabled": false,'+
                            +'"facial_biometrics_enabled": false'+
                            +'}'+
                            +'}';
                    }
                    
                    HttpRequest reqValidador2 = new HttpRequest();
                    reqValidador2.setMethod('POST');
                    reqValidador2.setEndpoint('https://app.clicksign.com/api/v1/signers?access_token='+ token);
                    reqValidador2.setHeader('Content-Type', 'application/json');
                    //req.setTimeout(120000);
                    reqValidador2.setBody(bodyValidador2);
                    HttpResponse respostValidador2 = new HttpResponse();
                    
                    respostValidador2 = new Http().send(reqValidador2);
                    
                    l0g = l0g + ' resposta requisicao criar validador 2: ' + respostValidador2.getBody();
                    
                    idSignatarioValidador2 = respostValidador2.getBody().substringAfter('"key":"').substringBefore('",'); //salvar id do signatário novo
                    
                    l0g = l0g + '\n ID DO NOVO VALIDADOR 2 ADICIONADO:: ' + idSignatarioValidador2;
                    
                    //Requisição para adicionar o validador 2 ao documento
                    string bodyValidador2_2 = '{"list": {"document_key": "'+ keyid +'",'+
                        +'"signer_key": "'+ idSignatarioValidador2 +'",'+
                        +'"sign_as": "validator",'+
                        +'"refusable": true,'+
                        +'"group": 1,'+
                        +'"message": "Prezado,\nPor favor assine o documento.\n\nQualquer dúvida estamos à disposição.\n\nAtenciosamente, \nHOSPCOM"}}';
                    
                    HttpRequest reqValidador2_2 = new HttpRequest();
                    reqValidador2_2.setMethod('POST');
                    reqValidador2_2.setEndpoint('https://app.clicksign.com/api/v1/lists?access_token=' + token);
                    reqValidador2_2.setHeader('Content-Type', 'application/json');
                    //req.setTimeout(120000);
                    reqValidador2_2.setBody(bodyValidador2_2);
                    HttpResponse respostValidador2_2 = new HttpResponse();
                    
                    respostValidador2_2 = new Http().send(reqValidador2_2);
                    
                    l0g = l0g + '\n resposta requisicao adicionar validador 2: ' + respostValidador2_2.getBody();
                    
                    string idValidador2 = respostValidador2_2.getBody().substringAfter('request_signature_key":"').substringBefore('","document'); 
                    
                    //Requisição para enviar notificação para o validador 2
                    
                    string bodyValidador2_3 = '{'+
                        +'"request_signature_key": "'+ idValidador2 +'",'+
                        +'"message": "Prezado,\nPor favor assine o documento.\n\nQualquer dúvida estou à disposição.\n\nAtenciosamente,\nHOSPCOM"}';
                    
                    HttpRequest reqValidador2_3 = new HttpRequest();
                    reqValidador2_3.setMethod('POST');
                    reqValidador2_3.setEndpoint('https://app.clicksign.com/api/v1/' + endpoint +'?access_token=' + token);
                    reqValidador2_3.setHeader('Content-Type', 'application/json');
                    //req.setTimeout(120000);
                    reqValidador2_3.setBody(bodyValidador2_3);
                    HttpResponse respostValidador2_3 = new HttpResponse();
                    
                    respostValidador2_3 = new Http().send(reqValidador2_3);
                    
                    l0g = l0g + '\n resposta requisicao notificar validador 2: ' + respostValidador2_3.getStatus();
                }
                
                //Adicionar o financeiro no processo de assinatura
                string bodyFinanceiro = '{"list": {"document_key": "'+ keyid +'",'+
                    +'"signer_key": "'+ idSignatarioFinanceiro +'",'+
                    +'"sign_as": "approve",'+
                    +'"refusable": true,'+
                    +'"group": 2,'+
                    +'"message": "Prezado,\nPor favor assine o documento.\n\nQualquer dúvida estamos à disposição.\n\nAtenciosamente, \nHOSPCOM"}}';
                
                HttpRequest reqFinanceiro = new HttpRequest();
                reqFinanceiro.setMethod('POST');
                reqFinanceiro.setEndpoint('https://app.clicksign.com/api/v1/lists?access_token=' + token);
                reqFinanceiro.setHeader('Content-Type', 'application/json');
                //req.setTimeout(120000);
                reqFinanceiro.setBody(bodyFinanceiro);
                HttpResponse resposFinanceiro = new HttpResponse();
                
                resposFinanceiro = new Http().send(reqFinanceiro);
                
                l0g = l0g + '\n resposta requisicao adicionar financeiro: ' + resposFinanceiro.getBody();
                
                string idAssinaturaFinanceiro = resposFinanceiro.getBody().substringAfter('request_signature_key":"').substringBefore('","document');
                
                //Adicionar o juridico no processo de assinatura
                string bodyJuridico = '{"list": {"document_key": "'+ keyid +'",'+
                    +'"signer_key": "'+ idSignatarioJuridico +'",'+
                    +'"sign_as": "witness",'+
                    +'"refusable": true,'+
                    +'"group": 3,'+
                    +'"message": "Prezado,\nPor favor assine o documento.\n\nQualquer dúvida estamos à disposição.\n\nAtenciosamente, \nHOSPCOM"}}';
                
                HttpRequest reqJuridico = new HttpRequest();
                reqJuridico.setMethod('POST');
                reqJuridico.setEndpoint('https://app.clicksign.com/api/v1/lists?access_token=' + token);
                reqJuridico.setHeader('Content-Type', 'application/json');
                //req.setTimeout(120000);
                reqJuridico.setBody(bodyJuridico);
                HttpResponse resposJuridico = new HttpResponse();
                
                resposJuridico = new Http().send(reqJuridico);
                
                l0g = l0g + '\n resposta requisicao adicionar juridico: ' + resposJuridico.getBody();
                
                string idAssinaturaJuridico = resposJuridico.getBody().substringAfter('request_signature_key":"').substringBefore('","document');
                
                //Adicionar o administrativo no processo de assinatura
                string bodyAdm = '{"list": {"document_key": "'+ keyid +'",'+
                    +'"signer_key": "'+ idSignatarioAdm +'",'+
                    +'"sign_as": "party",'+
                    +'"refusable": true,'+
                    +'"group": 3,'+
                    +'"message": "Prezado,\nPor favor assine o documento.\n\nQualquer dúvida estamos à disposição.\n\nAtenciosamente, \nHOSPCOM"}}';
                
                HttpRequest reqAdm = new HttpRequest();
                reqAdm.setMethod('POST');
                reqAdm.setEndpoint('https://app.clicksign.com/api/v1/lists?access_token=' + token);
                reqAdm.setHeader('Content-Type', 'application/json');
                //req.setTimeout(120000);
                reqAdm.setBody(bodyAdm);
                HttpResponse resposAdm = new HttpResponse();
                
                resposAdm = new Http().send(reqAdm);
                
                l0g = l0g + '\n resposta requisicao adicionar adm: ' + resposAdm.getBody();
                
                string idAssinaturaAdm = resposAdm.getBody().substringAfter('request_signature_key":"').substringBefore('","document');
                
                
                try{
                    update contrato;
                    signatario.idDoSignatario__c = idSignatario;
                    update signatario;
                    testemunha.idDoSignatario__c = idSignatarioTest;
                    update testemunha;
                    insert doc;
                }
                catch(DmlException e){
                    if(!Test.isRunningTest())
                        throw new AuraHandledException(e.getMessage());
                }
                
                
                //Cria e carrega um documento com as informações para o log
                Document logDoc = new Document(
                    Name = String.valueOf(System.Now().format('yyyy/MM/dd HH:mm:ss')) + ' - Contrato: ' + contrato.N_mero_da_Proposta_Contrato__c,
                    Body = Blob.valueOf(l0g),
                    ContentType = 'text/plain',
                    Type = 'txt',
                    IsPublic = false,
                    IsInternalUseOnly = true,
                    FolderId = '00l6e000002JcWd'        
                );
                insert logDoc;
            }
            else{
                throw new AuraHandledException('Erro de envio, forneça as seguintes informações para o suporte: ' + 'StatusCode: ' + resp.getStatusCode() + '; ResponseBody: ' + resp.getBody() + '');  
            }
        }  
        else{
            throw new AuraHandledException('Erro de envio, forneça as seguintes informações para o suporte: ' + 'StatusCode: ' + resp.getStatusCode() + '; ResponseBody: ' + resp.getBody() + '');  
        }
    }
    @AuraEnabled
    public static void cancelarLocacao(string idContrato){
        
        Tokens_Clicksign__mdt geral = [SELECT DeveloperName, Token__c FROM Tokens_Clicksign__mdt WHERE DeveloperName ='Geral'];
        
        string token = geral.Token__c;
        
        Contrato_de_Servi_o__c contrato = [SELECT ID, idDocAutentique__c
                                           FROM Contrato_de_Servi_o__c 
                                           WHERE ID =: idContrato];
        
        
        HttpRequest cancela = new HttpRequest();
        cancela.setMethod('PATCH');
        cancela.setEndpoint('https://app.clicksign.com/api/v1/documents/'+ contrato.idDocAutentique__c +'/cancel?access_token=' + token);
        cancela.setHeader('Content-Type', 'application/json');
        cancela.setHeader('Accept', 'application/json');
        
        HttpResponse rCancela = new HttpResponse();
        rCancela = new Http().send(cancela);
        
        
        system.debug(rCancela.getBody());
        Integer statusCode = rCancela.getStatusCode();
        
        contrato.Fase__c = 'Cancelado';
        contrato.idDocAutentique__c = '';
        update contrato;
        
    }
    @AuraEnabled
    public static string consultarLocacao(string idContrato){
        
        Tokens_Clicksign__mdt geral = [SELECT DeveloperName, Token__c FROM Tokens_Clicksign__mdt WHERE DeveloperName ='Geral'];
        
        string token = geral.Token__c;
        
        Contrato_de_Servi_o__c contrato = [SELECT ID, idDocAutentique__c
                                           FROM Contrato_de_Servi_o__c 
                                           WHERE ID =: idContrato];
        
        
        HttpRequest consulta = new HttpRequest();
        consulta.setMethod('GET');
        consulta.setEndpoint('https://app.clicksign.com/api/v1/documents/'+ contrato.idDocAutentique__c +'?access_token=' + token);
        consulta.setHeader('Content-Type', 'application/json');
        consulta.setHeader('Accept', 'application/json');
        //req.setTimeout(120000);
        HttpResponse rConsulta = new HttpResponse();
        rConsulta = new Http().send(consulta);
        
        return rConsulta.getBody();
        
        
    }
    
    
    //Parte do contrato de serviço (OT)
    @AuraEnabled
    public static void enviarOT(string idContrato, integer numero){
        
        WorkOrder contrato = [SELECT ID, OwnerId, WorkOrderNumber, Signatario__r.idDoSignatario__c, Signatario__r.CPF__c, Signatario__r.FirstName, Signatario__r.LastName, Signatario__r.Email, 
                              Testemunha__r.idDoSignatario__c, Testemunha__r.FirstName, Testemunha__r.LastName,Testemunha__r.Email, Testemunha__r.CPF__c, Testemunha__r.AccountId,
                              Assinante2__r.idDoSignatario__c, Assinante2__r.FirstName, Assinante2__r.LastName,Assinante2__r.Email, Assinante2__r.CPF__c,
                              Validador__r.idDoSignatario__c, Validador__r.FirstName, Validador__r.LastName,Validador__r.Email, Validador__r.CPF__c,
                              Validador2__r.idDoSignatario__c, Validador2__r.FirstName, Validador2__r.LastName,Validador2__r.Email, Validador2__r.CPF__c
                              FROM WorkOrder 
                              WHERE ID =: idContrato];
        
        List<WorkOrderLineItem> itens = [SELECT ID, TotalPrice FROM WorkOrderLineItem WHERE WorkOrderId =: contrato.ID AND (TotalPrice = 0 OR TotalPrice = null)];
        
        if(itens.size() == 0){
            
            contact signatario = [SELECT idDoSignatario__c FROM Contact WHERE ID =: contrato.Signatario__c];
            
            Contact testemunha = [SELECT idDoSignatario__c FROM Contact WHERE ID =: contrato.Testemunha__c];
            
            
            string idSignatario = signatario.idDoSignatario__c;
            string idSignatarioTest = contrato.Testemunha__r.idDoSignatario__c;
            string idSignatarioAssinante2;
            string idSignatarioValidador;
            string idSignatarioValidador2;
            string cpfTestemunha;
            
            Tokens_Clicksign__mdt juridico = [SELECT DeveloperName, Token__c FROM Tokens_Clicksign__mdt WHERE DeveloperName ='Juridico'];
            Tokens_Clicksign__mdt financeiro = [SELECT DeveloperName, Token__c FROM Tokens_Clicksign__mdt WHERE DeveloperName ='Financeiro'];
            Tokens_Clicksign__mdt adm = [SELECT DeveloperName, Token__c FROM Tokens_Clicksign__mdt WHERE DeveloperName ='Adm'];
            Tokens_Clicksign__mdt geral = [SELECT DeveloperName, Token__c FROM Tokens_Clicksign__mdt WHERE DeveloperName ='Geral'];
            
            string idSignatarioJuridico = juridico.Token__c;
            string idSignatarioFinanceiro = financeiro.Token__c;
            string idSignatarioAdm = adm.Token__c;
            string token = geral.Token__c;
            
            string l0g = '';
            
            HttpRequest req = new HttpRequest();
            PageReference pdf;
            
            if(numero == 1)
                pdf = Page.Contrato_de_Assistencia;
            else if(numero == 2)
                pdf = Page.ContratoVendaAssistencia;
            
            pdf.getParameters().put('id', idContrato);
            
            Blob pdfBody;
            String base64PDF;
            
            if (!Test.IsRunningTest()){
                pdfBody = pdf.getContentAsPDF();
                base64PDF = EncodingUtil.base64Encode(pdfBody);
            }
            else{
                pdfBody = Blob.valueOf('Teste');
                base64PDF = 'TESTE';
            }
            
            dateTime agora = system.now();
            
            String nomeDoDocumento = 'Contrato de Serviço ' + contrato.WorkOrderNumber;
            
            req.setMethod('POST');
            req.setEndpoint('http://oldsite.hospcom.net:21220/clickSign');
            req.setHeader('Content','{"document":{"path": "/' + nomeDoDocumento + '.pdf","content_base64": "data:application/pdf;base64,%","locale": "pt-BR","sequence_enabled": true}}');
            req.setTimeout(120000);
            req.setBody(base64PDF);
            
            //system.debug(req.getBody());
            
            //system.debug('base64:::::' + req.getBody());
            
            HttpResponse resp = new HttpResponse();
            
            resp = new Http().send(req);
            
            system.debug(resp.getBody());
            
            string keyid = resp.getBody();
            
            l0g = 'ID do Documento: ' + keyid +
                + '\n \n Requisição de envio para o Servidor' + req;
            
            if(contrato.Testemunha__r.AccountId == '001i00000085QYbAAM'){
                Dados_colaborador__c dados = [SELECT CPF__c FROM Dados_colaborador__c WHERE Contato__c =: contrato.Testemunha__c];
                cpfTestemunha = dados.CPF__c;
            }
            else{
                cpfTestemunha = contrato.Testemunha__r.CPF__c;
            }
            
            if(resp.getStatusCode() == 200){
                if(!keyId.contains('error')){
                    
                    Autentique__c doc = new Autentique__c(idDocAutentique__c = keyid, Nome_do_Documento__c = nomeDoDocumento);
                    
                    contrato.idDocAutentique__c = keyid;
                    contrato.Data_da_fase__c = SYSTEM.NOW();
                    contrato.Fase__c = '1';
                    //Requisição para criar o signatário no Clicksign caso ele ainda não tenha
                    if(idSignatario == null){
                        string body = '{' +
                            +'"signer": { ' +
                            +'"email": "'+ contrato.Signatario__r.Email +'", '+
                            +'"auths": [ ' +
                            +'"email" ' +
                            +'], '+
                            +'"name": "'+ contrato.Signatario__r.Firstname + ' ' + contrato.Signatario__r.LastName +'",' +
                            +'"documentation": "'+ contrato.Signatario__r.CPF__c +'",' +
                            +'"has_documentation": true,' +
                            +'"selfie_enabled": false,'+
                            +'"handwritten_enabled": false,'+
                            +'"official_document_enabled": false,' +
                            +'"liveness_enabled": false,'+
                            +'"facial_biometrics_enabled": false'+
                            +'}'+
                            +'}';
                        
                        HttpRequest req2 = new HttpRequest();
                        req2.setMethod('POST');
                        req2.setEndpoint('https://app.clicksign.com/api/v1/signers?access_token='+ token);
                        req2.setHeader('Content-Type', 'application/json');
                        //req.setTimeout(120000);
                        req2.setBody(body);
                        HttpResponse respost = new HttpResponse();
                        
                        respost = new Http().send(req2);
                        
                        l0g = l0g + ' resposta requisicao criar assinador: ' + respost.getBody();
                        
                        idSignatario = respost.getBody().substringAfter('"key":"').substringBefore('",'); //salvar id do signatário novo
                        
                        l0g = l0g + '\n ID DO NOVO SIGNATARIO ADICIONADO:: ' + idSignatario;
                        
                    }
                    
                    //Requisição para adicionar o signatário ao documento
                    string body3 = '{"list": {"document_key": "'+ keyid +'",'+
                        +'"signer_key": "'+ idSignatario +'",'+
                        +'"sign_as": "party",'+
                        +'"refusable": true,'+
                        +'"group": 1,'+
                        +'"message": "Prezado,\nPor favor assine o documento.\n\nQualquer dúvida estamos à disposição.\n\nAtenciosamente, \nHOSPCOM"}}';
                    
                    HttpRequest req3 = new HttpRequest();
                    req3.setMethod('POST');
                    req3.setEndpoint('https://app.clicksign.com/api/v1/lists?access_token=' + token);
                    req3.setHeader('Content-Type', 'application/json');
                    //req.setTimeout(120000);
                    req3.setBody(body3);
                    HttpResponse respost3 = new HttpResponse();
                    
                    respost3 = new Http().send(req3);
                    
                    l0g = l0g + '\n resposta requisicao adicionar assinador: ' + respost3.getBody();
                    
                    string idAssinatura = respost3.getBody().substringAfter('request_signature_key":"').substringBefore('","document'); 
                    
                    //Requisição para enviar notificação para o assinador
                    
                    string body4 = '{'+
                        +'"request_signature_key": "'+ idAssinatura +'",'+
                        +'"message": "Prezado,\nPor favor assine o documento.\n\nQualquer dúvida estou à disposição.\n\nAtenciosamente,\nHOSPCOM"}';
                    
                    HttpRequest req4 = new HttpRequest();
                    req4.setMethod('POST');
                    req4.setEndpoint('https://app.clicksign.com/api/v1/notifications?access_token=' + token);
                    req4.setHeader('Content-Type', 'application/json');
                    //req.setTimeout(120000);
                    req4.setBody(body4);
                    HttpResponse respost4 = new HttpResponse();
                    
                    respost4 = new Http().send(req4);
                    
                    l0g = l0g + '\n resposta requisicao notificar assinador: ' + respost4.getStatus();
                    
                    //Testemunha
                    
                    if(idSignatarioTest == null){
                        string bodyTest = '{' +
                            +'"signer": { ' +
                            +'"email": "'+ contrato.Testemunha__r.Email +'", '+
                            +'"auths": [ ' +
                            +'"email" ' +
                            +'], '+
                            +'"name": "'+ contrato.Testemunha__r.Firstname + ' ' + contrato.Testemunha__r.LastName +'",' +
                            +'"documentation": "'+ cpfTestemunha +'",' +
                            +'"has_documentation": true,' +
                            +'"selfie_enabled": false,'+
                            +'"handwritten_enabled": false,'+
                            +'"official_document_enabled": false,' +
                            +'"liveness_enabled": false,'+
                            +'"facial_biometrics_enabled": false'+
                            +'}'+
                            +'}';
                        
                        HttpRequest reqTest = new HttpRequest();
                        reqTest.setMethod('POST');
                        reqTest.setEndpoint('https://app.clicksign.com/api/v1/signers?access_token=' + token);
                        reqTest.setHeader('Content-Type', 'application/json');
                        //req.setTimeout(120000);
                        reqTest.setBody(bodyTest);
                        HttpResponse resposTest = new HttpResponse();
                        
                        resposTest = new Http().send(reqTest);
                        
                        l0g = l0g + '\n resposta requisicao criar testemunha: ' + resposTest.getBody();
                        
                        idSignatarioTest = resposTest.getBody().substringAfter('"key":"').substringBefore('",'); //salvar id do signatário novo
                        
                        
                        l0g = l0g + '\n ID DO NOVO TESTEMUNHA ADICIONADO:: ' + idSignatarioTest;                    
                        
                    }
                    
                    //Requisição para adicionar a testemunha ao documento
                    string bodyTest2 = '{"list": {"document_key": "'+ keyid +'",'+
                        +'"signer_key": "'+ idSignatarioTest +'",'+
                        +'"sign_as": "witness",'+
                        +'"refusable": true,'+
                        +'"group": 1,'+
                        +'"message": "Prezado,\nPor favor assine o documento.\n\nQualquer dúvida estamos à disposição.\n\nAtenciosamente, \nHOSPCOM"}}';
                    
                    HttpRequest reqTest2 = new HttpRequest();
                    reqTest2.setMethod('POST');
                    reqTest2.setEndpoint('https://app.clicksign.com/api/v1/lists?access_token=' + token);
                    reqTest2.setHeader('Content-Type', 'application/json');
                    //req.setTimeout(120000);
                    reqTest2.setBody(bodyTest2);
                    HttpResponse resposTest2 = new HttpResponse();
                    
                    resposTest2 = new Http().send(reqTest2);
                    
                    l0g = l0g + '\n resposta requisicao adicionar testemunha: ' + resposTest2.getBody();
                    
                    string idAssinaturaTest = resposTest2.getBody().substringAfter('request_signature_key":"').substringBefore('","document');                                       
                    
                    //Requisição para enviar notificação para a testemunha
                    
                    string bodyTest3 = '{'+
                        +'"request_signature_key": "'+ idAssinaturaTest +'",'+
                        +'"message": "Prezado,\nPor favor assine o documento.\n\nQualquer dúvida estou à disposição.\n\nAtenciosamente,\nHOSPCOM"}';
                    
                    HttpRequest reqTest3 = new HttpRequest();
                    reqTest3.setMethod('POST');
                    reqTest3.setEndpoint('https://app.clicksign.com/api/v1/notifications?access_token=' + token);
                    reqTest3.setHeader('Content-Type', 'application/json');
                    //req.setTimeout(120000);
                    reqTest3.setBody(bodyTest3);
                    HttpResponse resposTest3 = new HttpResponse();
                    
                    resposTest3 = new Http().send(reqTest3);
                    
                    l0g = l0g + '\n resposta requisicao notificar testemunha: ' + resposTest3.getStatus();
                    
                    //Adicionar o Assinante 2
                    if(contrato.Assinante2__c != null){
                        string bodyAssin;
                        bodyAssin = '{' +
                            +'"signer": { ' +
                            +'"email": "'+ contrato.Assinante2__r.Email +'", '+
                            +'"auths": [ ' +
                            +'"email" ' +
                            +'], '+
                            +'"name": "'+ contrato.Assinante2__r.Firstname + ' ' + contrato.Assinante2__r.LastName +'",' +
                            +'"documentation": "'+ contrato.Assinante2__r.CPF__c +'",' +
                            +'"has_documentation": true,' +
                            +'"selfie_enabled": false,'+
                            +'"handwritten_enabled": false,'+
                            +'"official_document_enabled": false,' +
                            +'"liveness_enabled": false,'+
                            +'"facial_biometrics_enabled": false'+
                            +'}'+
                            +'}';
                        
                        
                        HttpRequest reqAssin = new HttpRequest();
                        reqAssin.setMethod('POST');
                        reqAssin.setEndpoint('https://app.clicksign.com/api/v1/signers?access_token='+ token);
                        reqAssin.setHeader('Content-Type', 'application/json');
                        //req.setTimeout(120000);
                        reqAssin.setBody(bodyAssin);
                        HttpResponse respostAssin = new HttpResponse();
                        
                        respostAssin = new Http().send(reqAssin);
                        
                        l0g = l0g + ' resposta requisicao criar assinante 2: ' + respostAssin.getBody();
                        
                        idSignatarioAssinante2 = respostAssin.getBody().substringAfter('"key":"').substringBefore('",'); //salvar id do signatário novo
                        
                        l0g = l0g + '\n ID DO NOVO SIGNATARIO ADICIONADO:: ' + idSignatarioAssinante2;
                        
                        //Requisição para adicionar o assinante2 ao documento
                        string bodyAssin2 = '{"list": {"document_key": "'+ keyid +'",'+
                            +'"signer_key": "'+ idSignatarioAssinante2 +'",'+
                            +'"sign_as": "party",'+
                            +'"refusable": true,'+
                            +'"group": 1,'+
                            +'"message": "Prezado,\nPor favor assine o documento.\n\nQualquer dúvida estamos à disposição.\n\nAtenciosamente, \nHOSPCOM"}}';
                        
                        HttpRequest reqAssin2 = new HttpRequest();
                        reqAssin2.setMethod('POST');
                        reqAssin2.setEndpoint('https://app.clicksign.com/api/v1/lists?access_token=' + token);
                        reqAssin2.setHeader('Content-Type', 'application/json');
                        //req.setTimeout(120000);
                        reqAssin2.setBody(bodyAssin2);
                        HttpResponse respostAssin2 = new HttpResponse();
                        
                        respostAssin2 = new Http().send(reqAssin2);
                        
                        l0g = l0g + '\n resposta requisicao adicionar assinador: ' + respostAssin2.getBody();
                        
                        string idAssinatura2 = respostAssin2.getBody().substringAfter('request_signature_key":"').substringBefore('","document'); 
                        
                        //Requisição para enviar notificação para o assinante2
                        
                        string bodyAssin3 = '{'+
                            +'"request_signature_key": "'+ idAssinatura2 +'",'+
                            +'"message": "Prezado,\nPor favor assine o documento.\n\nQualquer dúvida estou à disposição.\n\nAtenciosamente,\nHOSPCOM"}';
                        
                        HttpRequest reqAssin4 = new HttpRequest();
                        reqAssin4.setMethod('POST');
                        reqAssin4.setEndpoint('https://app.clicksign.com/api/v1/notifications?access_token=' + token);
                        reqAssin4.setHeader('Content-Type', 'application/json');
                        //req.setTimeout(120000);
                        reqAssin4.setBody(body4);
                        HttpResponse respostAssin4 = new HttpResponse();
                        
                        respostAssin4 = new Http().send(reqAssin4);
                        
                        l0g = l0g + '\n resposta requisicao notificar assinante 2: ' + respostAssin4.getStatus();
                    }
                    
                    //Adicionar o Validador
                    if(contrato.Validador__c != null){
                        string bodyValidador;
                        bodyValidador = '{' +
                            +'"signer": { ' +
                            +'"email": "'+ contrato.Validador__r.Email +'", '+
                            +'"auths": [ ' +
                            +'"email" ' +
                            +'], '+
                            +'"name": "'+ contrato.Validador__r.Firstname + ' ' + contrato.Validador__r.LastName +'",' +
                            +'"documentation": "'+ contrato.Validador__r.CPF__c +'",' +
                            +'"has_documentation": true,' +
                            +'"selfie_enabled": false,'+
                            +'"handwritten_enabled": false,'+
                            +'"official_document_enabled": false,' +
                            +'"liveness_enabled": false,'+
                            +'"facial_biometrics_enabled": false'+
                            +'}'+
                            +'}';
                        
                        HttpRequest reqValidador = new HttpRequest();
                        reqValidador.setMethod('POST');
                        reqValidador.setEndpoint('https://app.clicksign.com/api/v1/signers?access_token='+ token);
                        reqValidador.setHeader('Content-Type', 'application/json');
                        //req.setTimeout(120000);
                        reqValidador.setBody(bodyValidador);
                        HttpResponse respostValidador = new HttpResponse();
                        
                        respostValidador = new Http().send(reqValidador);
                        
                        l0g = l0g + ' resposta requisicao criar validador: ' + respostValidador.getBody();
                        
                        idSignatarioValidador = respostValidador.getBody().substringAfter('"key":"').substringBefore('",'); //salvar id do signatário novo
                        
                        l0g = l0g + '\n ID DO NOVO VALIDADOR ADICIONADO:: ' + idSignatarioValidador;
                        
                        //Requisição para adicionar o validador ao documento
                        string bodyValidador_2 = '{"list": {"document_key": "'+ keyid +'",'+
                            +'"signer_key": "'+ idSignatarioValidador +'",'+
                            +'"sign_as": "validator",'+
                            +'"refusable": true,'+
                            +'"group": 1,'+
                            +'"message": "Prezado,\nPor favor assine o documento.\n\nQualquer dúvida estamos à disposição.\n\nAtenciosamente, \nHOSPCOM"}}';
                        
                        HttpRequest reqValidador_2 = new HttpRequest();
                        reqValidador_2.setMethod('POST');
                        reqValidador_2.setEndpoint('https://app.clicksign.com/api/v1/lists?access_token=' + token);
                        reqValidador_2.setHeader('Content-Type', 'application/json');
                        //req.setTimeout(120000);
                        reqValidador_2.setBody(bodyValidador_2);
                        HttpResponse respostValidador_2 = new HttpResponse();
                        
                        respostValidador_2 = new Http().send(reqValidador_2);
                        
                        l0g = l0g + '\n resposta requisicao adicionar assinador: ' + respostValidador_2.getBody();
                        
                        string idValidador = respostValidador_2.getBody().substringAfter('request_signature_key":"').substringBefore('","document'); 
                        
                        //Requisição para enviar notificação para o validador
                        
                        string bodyValidador_3 = '{'+
                            +'"request_signature_key": "'+ idValidador +'",'+
                            +'"message": "Prezado,\nPor favor assine o documento.\n\nQualquer dúvida estou à disposição.\n\nAtenciosamente,\nHOSPCOM"}';
                        
                        HttpRequest reqValidador_3 = new HttpRequest();
                        reqValidador_3.setMethod('POST');
                        reqValidador_3.setEndpoint('https://app.clicksign.com/api/v1/notifications?access_token=' + token);
                        reqValidador_3.setHeader('Content-Type', 'application/json');
                        //req.setTimeout(120000);
                        reqValidador_3.setBody(bodyValidador_3);
                        HttpResponse respostValidador_3 = new HttpResponse();
                        
                        respostValidador_3 = new Http().send(reqValidador_3);
                        
                        l0g = l0g + '\n resposta requisicao notificar validador: ' + respostValidador_3.getStatus();
                    }
                    //Adicionar o Validador 2
                    if(contrato.Validador2__c != null){
                        string bodyValidador2;
                        bodyValidador2 = '{' +
                            +'"signer": { ' +
                            +'"email": "'+ contrato.Validador2__r.Email +'", '+
                            +'"auths": [ ' +
                            +'"email" ' +
                            +'], '+
                            +'"name": "'+ contrato.Validador2__r.Firstname + ' ' + contrato.Validador2__r.LastName +'",' +
                            +'"documentation": "'+ contrato.Validador2__r.CPF__c +'",' +
                            +'"has_documentation": true,' +
                            +'"selfie_enabled": false,'+
                            +'"handwritten_enabled": false,'+
                            +'"official_document_enabled": false,' +
                            +'"liveness_enabled": false,'+
                            +'"facial_biometrics_enabled": false'+
                            +'}'+
                            +'}';
                        
                        HttpRequest reqValidador2 = new HttpRequest();
                        reqValidador2.setMethod('POST');
                        reqValidador2.setEndpoint('https://app.clicksign.com/api/v1/signers?access_token='+ token);
                        reqValidador2.setHeader('Content-Type', 'application/json');
                        //req.setTimeout(120000);
                        reqValidador2.setBody(bodyValidador2);
                        HttpResponse respostValidador2 = new HttpResponse();
                        
                        respostValidador2 = new Http().send(reqValidador2);
                        
                        l0g = l0g + ' resposta requisicao criar validador 2: ' + respostValidador2.getBody();
                        
                        idSignatarioValidador2 = respostValidador2.getBody().substringAfter('"key":"').substringBefore('",'); //salvar id do signatário novo
                        
                        l0g = l0g + '\n ID DO NOVO VALIDADOR 2 ADICIONADO:: ' + idSignatarioValidador2;
                        
                        //Requisição para adicionar o validador 2 ao documento
                        string bodyValidador2_2 = '{"list": {"document_key": "'+ keyid +'",'+
                            +'"signer_key": "'+ idSignatarioValidador2 +'",'+
                            +'"sign_as": "validator",'+
                            +'"refusable": true,'+
                            +'"group": 1,'+
                            +'"message": "Prezado,\nPor favor assine o documento.\n\nQualquer dúvida estamos à disposição.\n\nAtenciosamente, \nHOSPCOM"}}';
                        
                        HttpRequest reqValidador2_2 = new HttpRequest();
                        reqValidador2_2.setMethod('POST');
                        reqValidador2_2.setEndpoint('https://app.clicksign.com/api/v1/lists?access_token=' + token);
                        reqValidador2_2.setHeader('Content-Type', 'application/json');
                        //req.setTimeout(120000);
                        reqValidador2_2.setBody(bodyValidador2_2);
                        HttpResponse respostValidador2_2 = new HttpResponse();
                        
                        respostValidador2_2 = new Http().send(reqValidador2_2);
                        
                        l0g = l0g + '\n resposta requisicao adicionar validador 2: ' + respostValidador2_2.getBody();
                        
                        string idValidador2 = respostValidador2_2.getBody().substringAfter('request_signature_key":"').substringBefore('","document'); 
                        
                        //Requisição para enviar notificação para o validador 2
                        
                        string bodyValidador2_3 = '{'+
                            +'"request_signature_key": "'+ idValidador2 +'",'+
                            +'"message": "Prezado,\nPor favor assine o documento.\n\nQualquer dúvida estou à disposição.\n\nAtenciosamente,\nHOSPCOM"}';
                        
                        HttpRequest reqValidador2_3 = new HttpRequest();
                        reqValidador2_3.setMethod('POST');
                        reqValidador2_3.setEndpoint('https://app.clicksign.com/api/v1/notifications?access_token=' + token);
                        reqValidador2_3.setHeader('Content-Type', 'application/json');
                        //req.setTimeout(120000);
                        reqValidador2_3.setBody(bodyValidador2_3);
                        HttpResponse respostValidador2_3 = new HttpResponse();
                        
                        respostValidador2_3 = new Http().send(reqValidador2_3);
                        
                        l0g = l0g + '\n resposta requisicao notificar validador 2: ' + respostValidador2_3.getStatus();
                    }
                    
                    
                    //Adicionar o financeiro no processo de assinatura
                    string bodyFinanceiro = '{"list": {"document_key": "'+ keyid +'",'+
                        +'"signer_key": "'+ idSignatarioFinanceiro +'",'+
                        +'"sign_as": "approve",'+
                        +'"refusable": true,'+
                        +'"group": 2,'+
                        +'"message": "Prezado,\nPor favor assine o documento.\n\nQualquer dúvida estamos à disposição.\n\nAtenciosamente, \nHOSPCOM"}}';
                    
                    HttpRequest reqFinanceiro = new HttpRequest();
                    reqFinanceiro.setMethod('POST');
                    reqFinanceiro.setEndpoint('https://app.clicksign.com/api/v1/lists?access_token=' + token);
                    reqFinanceiro.setHeader('Content-Type', 'application/json');
                    //req.setTimeout(120000);
                    reqFinanceiro.setBody(bodyFinanceiro);
                    HttpResponse resposFinanceiro = new HttpResponse();
                    
                    resposFinanceiro = new Http().send(reqFinanceiro);
                    
                    l0g = l0g + '\n resposta requisicao adicionar financeiro: ' + resposFinanceiro.getBody();
                    
                    string idAssinaturaFinanceiro = resposFinanceiro.getBody().substringAfter('request_signature_key":"').substringBefore('","document');
                    
                    //Adicionar o juridico no processo de assinatura
                    string bodyJuridico = '{"list": {"document_key": "'+ keyid +'",'+
                        +'"signer_key": "'+ idSignatarioJuridico +'",'+
                        +'"sign_as": "witness",'+
                        +'"refusable": true,'+
                        +'"group": 3,'+
                        +'"message": "Prezado,\nPor favor assine o documento.\n\nQualquer dúvida estamos à disposição.\n\nAtenciosamente, \nHOSPCOM"}}';
                    
                    HttpRequest reqJuridico = new HttpRequest();
                    reqJuridico.setMethod('POST');
                    reqJuridico.setEndpoint('https://app.clicksign.com/api/v1/lists?access_token=' + token);
                    reqJuridico.setHeader('Content-Type', 'application/json');
                    //req.setTimeout(120000);
                    reqJuridico.setBody(bodyJuridico);
                    HttpResponse resposJuridico = new HttpResponse();
                    
                    resposJuridico = new Http().send(reqJuridico);
                    
                    l0g = l0g + '\n resposta requisicao adicionar juridico: ' + resposJuridico.getBody();
                    
                    string idAssinaturaJuridico = resposJuridico.getBody().substringAfter('request_signature_key":"').substringBefore('","document');
                    
                    //Adicionar o administrativo no processo de assinatura
                    string bodyAdm = '{"list": {"document_key": "'+ keyid +'",'+
                        +'"signer_key": "'+ idSignatarioAdm +'",'+
                        +'"sign_as": "party",'+
                        +'"refusable": true,'+
                        +'"group": 3,'+
                        +'"message": "Prezado,\nPor favor assine o documento.\n\nQualquer dúvida estamos à disposição.\n\nAtenciosamente, \nHOSPCOM"}}';
                    
                    HttpRequest reqAdm = new HttpRequest();
                    reqAdm.setMethod('POST');
                    reqAdm.setEndpoint('https://app.clicksign.com/api/v1/lists?access_token=' + token);
                    reqAdm.setHeader('Content-Type', 'application/json');
                    //req.setTimeout(120000);
                    reqAdm.setBody(bodyAdm);
                    HttpResponse resposAdm = new HttpResponse();
                    
                    resposAdm = new Http().send(reqAdm);
                    
                    l0g = l0g + '\n resposta requisicao adicionar adm: ' + resposAdm.getBody();
                    
                    string idAssinaturaAdm = resposAdm.getBody().substringAfter('request_signature_key":"').substringBefore('","document');
                    
                    
                    try{
                        update contrato;
                        signatario.idDoSignatario__c = idSignatario;
                        update signatario;
                        testemunha.idDoSignatario__c = idSignatarioTest;
                        update testemunha;
                        insert doc;
                    }
                    catch(DmlException e){
                        if(!Test.isRunningTest())
                            throw new AuraHandledException(e.getMessage());
                    }
                    
                    
                    //Cria e carrega um documento com as informações para o log
                    Document logDoc = new Document(
                        Name = String.valueOf(System.Now().format('yyyy/MM/dd HH:mm:ss')) + ' - Contrato de Serviço: ' + contrato.WorkOrderNumber,
                        Body = Blob.valueOf(l0g),
                        ContentType = 'text/plain',
                        Type = 'txt',
                        IsPublic = false,
                        IsInternalUseOnly = true,
                        FolderId = '00l6e000002JcWd'        
                    );
                    insert logDoc;
                }
                else{
                    throw new AuraHandledException('Erro de envio, forneça as seguintes informações para o suporte: ' + 'StatusCode: ' + resp.getStatusCode() + '; ResponseBody: ' + resp.getBody() + '');  
                }
            }  
            else{
                throw new AuraHandledException('Erro de envio, forneça as seguintes informações para o suporte: ' + 'StatusCode: ' + resp.getStatusCode() + '; ResponseBody: ' + resp.getBody() + '');  
            }
        }
        else{
            throw new AuraHandledException('Existe ao menos um item com valor zerado no contrato.');  
            
        }
    }
    @AuraEnabled
    public static void cancelarOT(string idContrato){
        
        Tokens_Clicksign__mdt geral = [SELECT DeveloperName, Token__c FROM Tokens_Clicksign__mdt WHERE DeveloperName ='Geral'];
        
        string token = geral.Token__c;
        
        WorkOrder contrato = [SELECT ID, idDocAutentique__c
                              FROM WorkOrder 
                              WHERE ID =: idContrato];
        
        
        HttpRequest cancela = new HttpRequest();
        cancela.setMethod('PATCH');
        cancela.setEndpoint('https://app.clicksign.com/api/v1/documents/'+ contrato.idDocAutentique__c +'/cancel?access_token=' + token);
        cancela.setHeader('Content-Type', 'application/json');
        cancela.setHeader('Accept', 'application/json');
        
        HttpResponse rCancela = new HttpResponse();
        rCancela = new Http().send(cancela);
        
        
        system.debug(rCancela.getBody());
        Integer statusCode = rCancela.getStatusCode();
        
        contrato.Fase__c = 'Cancelado';
        contrato.idDocAutentique__c = '';
        update contrato;
    }
    @AuraEnabled
    public static string consultarOT(string idContrato){
        
        Tokens_Clicksign__mdt geral = [SELECT DeveloperName, Token__c FROM Tokens_Clicksign__mdt WHERE DeveloperName ='Geral'];
        
        string token = geral.Token__c;
        
        WorkOrder contrato = [SELECT ID, idDocAutentique__c
                              FROM WorkOrder 
                              WHERE ID =: idContrato];
        
        
        HttpRequest consulta = new HttpRequest();
        consulta.setMethod('GET');
        consulta.setEndpoint('https://app.clicksign.com/api/v1/documents/'+ contrato.idDocAutentique__c +'?access_token=' + token);
        consulta.setHeader('Content-Type', 'application/json');
        consulta.setHeader('Accept', 'application/json');
        //req.setTimeout(120000);
        HttpResponse rConsulta = new HttpResponse();
        rConsulta = new Http().send(consulta);
        
        return rConsulta.getBody();
        
        
    }
    
    //Parte do contrato de demo/comodato 
    @AuraEnabled
    public static void enviarDemo(string idContrato){
        
        Order contrato = [SELECT ID, OwnerId, OrderNumber, ShipToContact.idDoSignatario__c, ShipToContact.CPF__c, ShipToContact.FirstName, ShipToContact.LastName, ShipToContact.Email, Natureza_de_opera_o__c,
                          Testemunha__r.idDoSignatario__c, Testemunha__r.FirstName, Testemunha__r.LastName,Testemunha__r.Email, Testemunha__r.CPF__c, Testemunha__r.AccountId,
                          Assinante2__r.idDoSignatario__c, Assinante2__r.FirstName, Assinante2__r.LastName,Assinante2__r.Email, Assinante2__r.CPF__c,
                          Validador__r.idDoSignatario__c, Validador__r.FirstName, Validador__r.LastName, Validador__r.Email, Validador__r.CPF__c,
                          Validador2__r.idDoSignatario__c, Validador2__r.FirstName, Validador2__r.LastName, Validador2__r.Email, Validador2__r.CPF__c
                          FROM Order 
                          WHERE ID =: idContrato];
        
        contact signatario = [SELECT idDoSignatario__c FROM Contact WHERE ID =: contrato.ShipToContactId];
        
        Contact testemunha = [SELECT idDoSignatario__c FROM Contact WHERE ID =: contrato.Testemunha__c];       
        
        string idSignatario = signatario.idDoSignatario__c;
        string idSignatarioTest = contrato.Testemunha__r.idDoSignatario__c;
        
        Tokens_Clicksign__mdt juridico = [SELECT DeveloperName, Token__c FROM Tokens_Clicksign__mdt WHERE DeveloperName ='Juridico'];
        Tokens_Clicksign__mdt adm = [SELECT DeveloperName, Token__c FROM Tokens_Clicksign__mdt WHERE DeveloperName ='Adm'];
        Tokens_Clicksign__mdt geral = [SELECT DeveloperName, Token__c FROM Tokens_Clicksign__mdt WHERE DeveloperName ='Geral'];
        
        string idSignatarioJuridico = juridico.Token__c;
        string idSignatarioAdm = adm.Token__c;
        string token = geral.Token__c;
        string idSignatarioAssinante2;
        string idSignatarioValidador;
        string idSignatarioValidador2;
        string cpfTestemunha;
        
        string l0g = '';
        
        HttpRequest req = new HttpRequest();
        PageReference pdf;
        
        pdf = Page.DemonstracaoContrato2;
        
        pdf.getParameters().put('id', idContrato);
        
        Blob pdfBody;
        String base64PDF;
        
        if (!Test.IsRunningTest()){
            pdfBody = pdf.getContentAsPDF();
            base64PDF = EncodingUtil.base64Encode(pdfBody);
        }
        else{
            pdfBody = Blob.valueOf('Teste');
            base64PDF = 'TESTE';
        }
        
        dateTime agora = system.now();
        
        String nomeDoDocumento;
        
        if(contrato.Natureza_de_opera_o__c == 'DEMONSTRAÇÃO')
            nomeDoDocumento = 'Contrato de Demonstração ' + contrato.OrderNumber;
        else if(contrato.Natureza_de_opera_o__c == 'REMESSA DE COMODATO')
            nomeDoDocumento = 'Contrato de Comodato ' + contrato.OrderNumber;
        
        req.setMethod('POST');
        req.setEndpoint('http://oldsite.hospcom.net:21220/clickSign');
        req.setHeader('Content','{"document":{"path": "/' + nomeDoDocumento + '.pdf","content_base64": "data:application/pdf;base64,%","locale": "pt-BR","sequence_enabled": true}}');
        req.setTimeout(120000);
        req.setBody(base64PDF);
        
        //system.debug(req.getBody());
        
        //system.debug('base64:::::' + req.getBody());
        
        HttpResponse resp = new HttpResponse();
        
        resp = new Http().send(req);
        
        system.debug(resp.getBody());
        
        string keyid = resp.getBody();
        
        l0g = 'ID do Documento: ' + keyid +
            + '\n \n Requisição de envio para o Servidor: ' + req;
        
        if(contrato.Testemunha__r.AccountId == '001i00000085QYbAAM'){
            Dados_colaborador__c dados = [SELECT CPF__c FROM Dados_colaborador__c WHERE Contato__c =: contrato.Testemunha__c];
            cpfTestemunha = dados.CPF__c;
        }
        else{
            cpfTestemunha = contrato.Testemunha__r.CPF__c;
        }
        
        if(resp.getStatusCode() == 200){
            if(!keyId.contains('error')){
                
                Autentique__c doc = new Autentique__c(idDocAutentique__c = keyid, Nome_do_Documento__c = nomeDoDocumento);
                
                contrato.idDocAutentique__c = keyid;
                contrato.Fase__c = '1';
                //Requisição para criar o signatário no Clicksign caso ele ainda não tenha
                if(idSignatario == null){
                    string body = '{' +
                        +'"signer": { ' +
                        +'"email": "'+ contrato.ShipToContact.Email +'", '+
                        +'"auths": [ ' +
                        +'"email" ' +
                        +'], '+
                        +'"name": "'+ contrato.ShipToContact.Firstname + ' ' + contrato.ShipToContact.LastName +'",' +
                        +'"documentation": "'+ contrato.ShipToContact.CPF__c +'",' +
                        +'"has_documentation": true,' +
                        +'"selfie_enabled": false,'+
                        +'"handwritten_enabled": false,'+
                        +'"official_document_enabled": false,' +
                        +'"liveness_enabled": false,'+
                        +'"facial_biometrics_enabled": false'+
                        +'}'+
                        +'}';
                    
                    HttpRequest req2 = new HttpRequest();
                    req2.setMethod('POST');
                    req2.setEndpoint('https://app.clicksign.com/api/v1/signers?access_token='+ token);
                    req2.setHeader('Content-Type', 'application/json');
                    //req.setTimeout(120000);
                    req2.setBody(body);
                    HttpResponse respost = new HttpResponse();
                    
                    respost = new Http().send(req2);
                    
                    l0g = l0g + ' resposta requisicao criar assinador: ' + respost.getBody();
                    
                    idSignatario = respost.getBody().substringAfter('"key":"').substringBefore('",'); //salvar id do signatário novo
                    
                    l0g = l0g + '\n ID DO NOVO SIGNATARIO ADICIONADO:: ' + idSignatario;
                    
                }
                
                //Requisição para adicionar o signatário ao documento
                string body3 = '{"list": {"document_key": "'+ keyid +'",'+
                    +'"signer_key": "'+ idSignatario +'",'+
                    +'"sign_as": "party",'+
                    +'"refusable": true,'+
                    +'"group": 1,'+
                    +'"message": "Prezado,\nPor favor assine o documento.\n\nQualquer dúvida estamos à disposição.\n\nAtenciosamente, \nHOSPCOM"}}';
                
                HttpRequest req3 = new HttpRequest();
                req3.setMethod('POST');
                req3.setEndpoint('https://app.clicksign.com/api/v1/lists?access_token=' + token);
                req3.setHeader('Content-Type', 'application/json');
                //req.setTimeout(120000);
                req3.setBody(body3);
                HttpResponse respost3 = new HttpResponse();
                
                respost3 = new Http().send(req3);
                
                l0g = l0g + '\n resposta requisicao adicionar assinador: ' + respost3.getBody();
                
                string idAssinatura = respost3.getBody().substringAfter('request_signature_key":"').substringBefore('","document'); 
                
                //Requisição para enviar notificação para o assinador
                
                string body4 = '{'+
                    +'"request_signature_key": "'+ idAssinatura +'",'+
                    +'"message": "Prezado,\nPor favor assine o documento.\n\nQualquer dúvida estou à disposição.\n\nAtenciosamente,\nHOSPCOM"}';
                
                HttpRequest req4 = new HttpRequest();
                req4.setMethod('POST');
                req4.setEndpoint('https://app.clicksign.com/api/v1/notifications?access_token=' + token);
                req4.setHeader('Content-Type', 'application/json');
                //req.setTimeout(120000);
                req4.setBody(body4);
                HttpResponse respost4 = new HttpResponse();
                
                respost4 = new Http().send(req4);
                
                l0g = l0g + '\n resposta requisicao notificar assinador: ' + respost4.getStatus();
                
                //Testemunha
                
                if(idSignatarioTest == null){
                    string bodyTest = '{' +
                        +'"signer": { ' +
                        +'"email": "'+ contrato.Testemunha__r.Email +'", '+
                        +'"auths": [ ' +
                        +'"email" ' +
                        +'], '+
                        +'"name": "'+ contrato.Testemunha__r.Firstname + ' ' + contrato.Testemunha__r.LastName +'",' +
                        +'"documentation": "'+ cpfTestemunha +'",' +
                        +'"has_documentation": true,' +
                        +'"selfie_enabled": false,'+
                        +'"handwritten_enabled": false,'+
                        +'"official_document_enabled": false,' +
                        +'"liveness_enabled": false,'+
                        +'"facial_biometrics_enabled": false'+
                        +'}'+
                        +'}';
                    
                    HttpRequest reqTest = new HttpRequest();
                    reqTest.setMethod('POST');
                    reqTest.setEndpoint('https://app.clicksign.com/api/v1/signers?access_token=' + token);
                    reqTest.setHeader('Content-Type', 'application/json');
                    //req.setTimeout(120000);
                    reqTest.setBody(bodyTest);
                    HttpResponse resposTest = new HttpResponse();
                    
                    resposTest = new Http().send(reqTest);
                    
                    l0g = l0g + '\n resposta requisicao criar testemunha: ' + resposTest.getBody();
                    
                    idSignatarioTest = resposTest.getBody().substringAfter('"key":"').substringBefore('",'); //salvar id do signatário novo
                    
                    
                    l0g = l0g + '\n ID DO NOVO TESTEMUNHA ADICIONADO:: ' + idSignatarioTest;                    
                    
                }
                
                //Requisição para adicionar a testemunha ao documento
                string bodyTest2 = '{"list": {"document_key": "'+ keyid +'",'+
                    +'"signer_key": "'+ idSignatarioTest +'",'+
                    +'"sign_as": "witness",'+
                    +'"refusable": true,'+
                    +'"group": 1,'+
                    +'"message": "Prezado,\nPor favor assine o documento.\n\nQualquer dúvida estamos à disposição.\n\nAtenciosamente, \nHOSPCOM"}}';
                
                HttpRequest reqTest2 = new HttpRequest();
                reqTest2.setMethod('POST');
                reqTest2.setEndpoint('https://app.clicksign.com/api/v1/lists?access_token=' + token);
                reqTest2.setHeader('Content-Type', 'application/json');
                //req.setTimeout(120000);
                reqTest2.setBody(bodyTest2);
                HttpResponse resposTest2 = new HttpResponse();
                
                resposTest2 = new Http().send(reqTest2);
                
                l0g = l0g + '\n resposta requisicao adicionar testemunha: ' + resposTest2.getBody();
                
                string idAssinaturaTest = resposTest2.getBody().substringAfter('request_signature_key":"').substringBefore('","document');                                       
                
                //Requisição para enviar notificação para a testemunha
                
                string bodyTest3 = '{'+
                    +'"request_signature_key": "'+ idAssinaturaTest +'",'+
                    +'"message": "Prezado,\nPor favor assine o documento.\n\nQualquer dúvida estou à disposição.\n\nAtenciosamente,\nHOSPCOM"}';
                
                HttpRequest reqTest3 = new HttpRequest();
                reqTest3.setMethod('POST');
                reqTest3.setEndpoint('https://app.clicksign.com/api/v1/notifications?access_token=' + token);
                reqTest3.setHeader('Content-Type', 'application/json');
                //req.setTimeout(120000);
                reqTest3.setBody(bodyTest3);
                HttpResponse resposTest3 = new HttpResponse();
                
                resposTest3 = new Http().send(reqTest3);
                
                l0g = l0g + '\n resposta requisicao notificar testemunha: ' + resposTest3.getStatus();
                
                
                //Adicionar o Assinante 2
                if(contrato.Assinante2__c != null){
                    string bodyAssin;
                    bodyAssin = '{' +
                        +'"signer": { ' +
                        +'"email": "'+ contrato.Assinante2__r.Email +'", '+
                        +'"auths": [ ' +
                        +'"email" ' +
                        +'], '+
                        +'"name": "'+ contrato.Assinante2__r.Firstname + ' ' + contrato.Assinante2__r.LastName +'",' +
                        +'"documentation": "'+ contrato.Assinante2__r.CPF__c +'",' +
                        +'"has_documentation": true,' +
                        +'"selfie_enabled": false,'+
                        +'"handwritten_enabled": false,'+
                        +'"official_document_enabled": false,' +
                        +'"liveness_enabled": false,'+
                        +'"facial_biometrics_enabled": false'+
                        +'}'+
                        +'}';
                    
                    
                    HttpRequest reqAssin = new HttpRequest();
                    reqAssin.setMethod('POST');
                    reqAssin.setEndpoint('https://app.clicksign.com/api/v1/signers?access_token='+ token);
                    reqAssin.setHeader('Content-Type', 'application/json');
                    //req.setTimeout(120000);
                    reqAssin.setBody(bodyAssin);
                    HttpResponse respostAssin = new HttpResponse();
                    
                    respostAssin = new Http().send(reqAssin);
                    
                    l0g = l0g + ' resposta requisicao criar assinante 2: ' + respostAssin.getBody();
                    
                    idSignatarioAssinante2 = respostAssin.getBody().substringAfter('"key":"').substringBefore('",'); //salvar id do signatário novo
                    
                    l0g = l0g + '\n ID DO NOVO SIGNATARIO ADICIONADO:: ' + idSignatarioAssinante2;
                    
                    //Requisição para adicionar o assinante2 ao documento
                    string bodyAssin2 = '{"list": {"document_key": "'+ keyid +'",'+
                        +'"signer_key": "'+ idSignatarioAssinante2 +'",'+
                        +'"sign_as": "party",'+
                        +'"refusable": true,'+
                        +'"group": 1,'+
                        +'"message": "Prezado,\nPor favor assine o documento.\n\nQualquer dúvida estamos à disposição.\n\nAtenciosamente, \nHOSPCOM"}}';
                    
                    HttpRequest reqAssin2 = new HttpRequest();
                    reqAssin2.setMethod('POST');
                    reqAssin2.setEndpoint('https://app.clicksign.com/api/v1/lists?access_token=' + token);
                    reqAssin2.setHeader('Content-Type', 'application/json');
                    //req.setTimeout(120000);
                    reqAssin2.setBody(bodyAssin2);
                    HttpResponse respostAssin2 = new HttpResponse();
                    
                    respostAssin2 = new Http().send(reqAssin2);
                    
                    l0g = l0g + '\n resposta requisicao adicionar assinador: ' + respostAssin2.getBody();
                    
                    string idAssinatura2 = respostAssin2.getBody().substringAfter('request_signature_key":"').substringBefore('","document'); 
                    
                    //Requisição para enviar notificação para o assinante2
                    
                    string bodyAssin3 = '{'+
                        +'"request_signature_key": "'+ idAssinatura2 +'",'+
                        +'"message": "Prezado,\nPor favor assine o documento.\n\nQualquer dúvida estou à disposição.\n\nAtenciosamente,\nHOSPCOM"}';
                    
                    HttpRequest reqAssin4 = new HttpRequest();
                    reqAssin4.setMethod('POST');
                    reqAssin4.setEndpoint('https://app.clicksign.com/api/v1/notifications?access_token=' + token);
                    reqAssin4.setHeader('Content-Type', 'application/json');
                    //req.setTimeout(120000);
                    reqAssin4.setBody(body4);
                    HttpResponse respostAssin4 = new HttpResponse();
                    
                    respostAssin4 = new Http().send(reqAssin4);
                    
                    l0g = l0g + '\n resposta requisicao notificar assinante 2: ' + respostAssin4.getStatus();
                }
                
                //Adicionar o Validador
                if(contrato.Validador__c != null){
                    string bodyValidador;
                    bodyValidador = '{' +
                        +'"signer": { ' +
                        +'"email": "'+ contrato.Validador__r.Email +'", '+
                        +'"auths": [ ' +
                        +'"email" ' +
                        +'], '+
                        +'"name": "'+ contrato.Validador__r.Firstname + ' ' + contrato.Validador__r.LastName +'",' +
                        +'"documentation": "'+ contrato.Validador__r.CPF__c +'",' +
                        +'"has_documentation": true,' +
                        +'"selfie_enabled": false,'+
                        +'"handwritten_enabled": false,'+
                        +'"official_document_enabled": false,' +
                        +'"liveness_enabled": false,'+
                        +'"facial_biometrics_enabled": false'+
                        +'}'+
                        +'}';
                    
                    HttpRequest reqValidador = new HttpRequest();
                    reqValidador.setMethod('POST');
                    reqValidador.setEndpoint('https://app.clicksign.com/api/v1/signers?access_token='+ token);
                    reqValidador.setHeader('Content-Type', 'application/json');
                    //req.setTimeout(120000);
                    reqValidador.setBody(bodyValidador);
                    HttpResponse respostValidador = new HttpResponse();
                    
                    respostValidador = new Http().send(reqValidador);
                    
                    l0g = l0g + ' resposta requisicao criar validador: ' + respostValidador.getBody();
                    
                    idSignatarioValidador = respostValidador.getBody().substringAfter('"key":"').substringBefore('",'); //salvar id do signatário novo
                    
                    l0g = l0g + '\n ID DO NOVO VALIDADOR ADICIONADO:: ' + idSignatarioValidador;
                    
                    //Requisição para adicionar o validador ao documento
                    string bodyValidador_2 = '{"list": {"document_key": "'+ keyid +'",'+
                        +'"signer_key": "'+ idSignatarioValidador +'",'+
                        +'"sign_as": "validator",'+
                        +'"refusable": true,'+
                        +'"group": 1,'+
                        +'"message": "Prezado,\nPor favor assine o documento.\n\nQualquer dúvida estamos à disposição.\n\nAtenciosamente, \nHOSPCOM"}}';
                    
                    HttpRequest reqValidador_2 = new HttpRequest();
                    reqValidador_2.setMethod('POST');
                    reqValidador_2.setEndpoint('https://app.clicksign.com/api/v1/lists?access_token=' + token);
                    reqValidador_2.setHeader('Content-Type', 'application/json');
                    //req.setTimeout(120000);
                    reqValidador_2.setBody(bodyValidador_2);
                    HttpResponse respostValidador_2 = new HttpResponse();
                    
                    respostValidador_2 = new Http().send(reqValidador_2);
                    
                    l0g = l0g + '\n resposta requisicao adicionar assinador: ' + respostValidador_2.getBody();
                    
                    string idValidador = respostValidador_2.getBody().substringAfter('request_signature_key":"').substringBefore('","document'); 
                    
                    //Requisição para enviar notificação para o validador
                    
                    string bodyValidador_3 = '{'+
                        +'"request_signature_key": "'+ idValidador +'",'+
                        +'"message": "Prezado,\nPor favor assine o documento.\n\nQualquer dúvida estou à disposição.\n\nAtenciosamente,\nHOSPCOM"}';
                    
                    HttpRequest reqValidador_3 = new HttpRequest();
                    reqValidador_3.setMethod('POST');
                    reqValidador_3.setEndpoint('https://app.clicksign.com/api/v1/notifications?access_token=' + token);
                    reqValidador_3.setHeader('Content-Type', 'application/json');
                    //req.setTimeout(120000);
                    reqValidador_3.setBody(bodyValidador_3);
                    HttpResponse respostValidador_3 = new HttpResponse();
                    
                    respostValidador_3 = new Http().send(reqValidador_3);
                    
                    l0g = l0g + '\n resposta requisicao notificar validador: ' + respostValidador_3.getStatus();
                }
                //Adicionar o Validador 2
                if(contrato.Validador2__c != null){
                    string bodyValidador2;
                    bodyValidador2 = '{' +
                        +'"signer": { ' +
                        +'"email": "'+ contrato.Validador2__r.Email +'", '+
                        +'"auths": [ ' +
                        +'"email" ' +
                        +'], '+
                        +'"name": "'+ contrato.Validador2__r.Firstname + ' ' + contrato.Validador2__r.LastName +'",' +
                        +'"documentation": "'+ contrato.Validador2__r.CPF__c +'",' +
                        +'"has_documentation": true,' +
                        +'"selfie_enabled": false,'+
                        +'"handwritten_enabled": false,'+
                        +'"official_document_enabled": false,' +
                        +'"liveness_enabled": false,'+
                        +'"facial_biometrics_enabled": false'+
                        +'}'+
                        +'}';
                    
                    HttpRequest reqValidador2 = new HttpRequest();
                    reqValidador2.setMethod('POST');
                    reqValidador2.setEndpoint('https://app.clicksign.com/api/v1/signers?access_token='+ token);
                    reqValidador2.setHeader('Content-Type', 'application/json');
                    //req.setTimeout(120000);
                    reqValidador2.setBody(bodyValidador2);
                    HttpResponse respostValidador2 = new HttpResponse();
                    
                    respostValidador2 = new Http().send(reqValidador2);
                    
                    l0g = l0g + ' resposta requisicao criar validador 2: ' + respostValidador2.getBody();
                    
                    idSignatarioValidador2 = respostValidador2.getBody().substringAfter('"key":"').substringBefore('",'); //salvar id do signatário novo
                    
                    l0g = l0g + '\n ID DO NOVO VALIDADOR 2 ADICIONADO:: ' + idSignatarioValidador2;
                    
                    //Requisição para adicionar o validador 2 ao documento
                    string bodyValidador2_2 = '{"list": {"document_key": "'+ keyid +'",'+
                        +'"signer_key": "'+ idSignatarioValidador2 +'",'+
                        +'"sign_as": "validator",'+
                        +'"refusable": true,'+
                        +'"group": 1,'+
                        +'"message": "Prezado,\nPor favor assine o documento.\n\nQualquer dúvida estamos à disposição.\n\nAtenciosamente, \nHOSPCOM"}}';
                    
                    HttpRequest reqValidador2_2 = new HttpRequest();
                    reqValidador2_2.setMethod('POST');
                    reqValidador2_2.setEndpoint('https://app.clicksign.com/api/v1/lists?access_token=' + token);
                    reqValidador2_2.setHeader('Content-Type', 'application/json');
                    //req.setTimeout(120000);
                    reqValidador2_2.setBody(bodyValidador2_2);
                    HttpResponse respostValidador2_2 = new HttpResponse();
                    
                    respostValidador2_2 = new Http().send(reqValidador2_2);
                    
                    l0g = l0g + '\n resposta requisicao adicionar validador 2: ' + respostValidador2_2.getBody();
                    
                    string idValidador2 = respostValidador2_2.getBody().substringAfter('request_signature_key":"').substringBefore('","document'); 
                    
                    //Requisição para enviar notificação para o validador 2
                    
                    string bodyValidador2_3 = '{'+
                        +'"request_signature_key": "'+ idValidador2 +'",'+
                        +'"message": "Prezado,\nPor favor assine o documento.\n\nQualquer dúvida estou à disposição.\n\nAtenciosamente,\nHOSPCOM"}';
                    
                    HttpRequest reqValidador2_3 = new HttpRequest();
                    reqValidador2_3.setMethod('POST');
                    reqValidador2_3.setEndpoint('https://app.clicksign.com/api/v1/notifications?access_token=' + token);
                    reqValidador2_3.setHeader('Content-Type', 'application/json');
                    //req.setTimeout(120000);
                    reqValidador2_3.setBody(bodyValidador2_3);
                    HttpResponse respostValidador2_3 = new HttpResponse();
                    
                    respostValidador2_3 = new Http().send(reqValidador2_3);
                    
                    l0g = l0g + '\n resposta requisicao notificar validador 2: ' + respostValidador2_3.getStatus();
                }
                
                
                
                //Adicionar o juridico no processo de assinatura
                string bodyJuridico = '{"list": {"document_key": "'+ keyid +'",'+
                    +'"signer_key": "'+ idSignatarioJuridico +'",'+
                    +'"sign_as": "witness",'+
                    +'"refusable": true,'+
                    +'"group": 2,'+
                    +'"message": "Prezado,\nPor favor assine o documento.\n\nQualquer dúvida estamos à disposição.\n\nAtenciosamente, \nHOSPCOM"}}';
                
                HttpRequest reqJuridico = new HttpRequest();
                reqJuridico.setMethod('POST');
                reqJuridico.setEndpoint('https://app.clicksign.com/api/v1/lists?access_token=' + token);
                reqJuridico.setHeader('Content-Type', 'application/json');
                //req.setTimeout(120000);
                reqJuridico.setBody(bodyJuridico);
                HttpResponse resposJuridico = new HttpResponse();
                
                resposJuridico = new Http().send(reqJuridico);
                
                l0g = l0g + '\n resposta requisicao adicionar juridico: ' + resposJuridico.getBody();
                
                string idAssinaturaJuridico = resposJuridico.getBody().substringAfter('request_signature_key":"').substringBefore('","document');
                
                //Adicionar o administrativo no processo de assinatura
                string bodyAdm = '{"list": {"document_key": "'+ keyid +'",'+
                    +'"signer_key": "'+ idSignatarioAdm +'",'+
                    +'"sign_as": "party",'+
                    +'"refusable": true,'+
                    +'"group": 3,'+
                    +'"message": "Prezado,\nPor favor assine o documento.\n\nQualquer dúvida estamos à disposição.\n\nAtenciosamente, \nHOSPCOM"}}';
                
                HttpRequest reqAdm = new HttpRequest();
                reqAdm.setMethod('POST');
                reqAdm.setEndpoint('https://app.clicksign.com/api/v1/lists?access_token=' + token);
                reqAdm.setHeader('Content-Type', 'application/json');
                //req.setTimeout(120000);
                reqAdm.setBody(bodyAdm);
                HttpResponse resposAdm = new HttpResponse();
                
                resposAdm = new Http().send(reqAdm);
                
                l0g = l0g + '\n resposta requisicao adicionar adm: ' + resposAdm.getBody();
                
                string idAssinaturaAdm = resposAdm.getBody().substringAfter('request_signature_key":"').substringBefore('","document');
                
                
                try{
                    update contrato;
                    signatario.idDoSignatario__c = idSignatario;
                    update signatario;
                    testemunha.idDoSignatario__c = idSignatarioTest;
                    update testemunha;
                    insert doc;
                }
                catch(DmlException e){
                    if(!Test.isRunningTest())
                        throw new AuraHandledException(e.getMessage());
                }
                
                
                //Cria e carrega um documento com as informações para o log
                Document logDoc = new Document(
                    Name = String.valueOf(System.Now().format('yyyy/MM/dd HH:mm:ss')) + ' - Contrato de Demo/Comodato: ' + contrato.OrderNumber,
                    Body = Blob.valueOf(l0g),
                    ContentType = 'text/plain',
                    Type = 'txt',
                    IsPublic = false,
                    IsInternalUseOnly = true,
                    FolderId = '00l6e000002JcWd'        
                );
                insert logDoc;
            }
            else{
                throw new AuraHandledException('Erro de envio, forneça as seguintes informações para o suporte: ' + 'StatusCode: ' + resp.getStatusCode() + '; ResponseBody: ' + resp.getBody() + '');  
            }
        }  
        else{
            throw new AuraHandledException('Erro de envio, forneça as seguintes informações para o suporte: ' + 'StatusCode: ' + resp.getStatusCode() + '; ResponseBody: ' + resp.getBody() + '');  
        }
    }
    @AuraEnabled
    public static void cancelarDemo(string idContrato){
        
        Tokens_Clicksign__mdt geral = [SELECT DeveloperName, Token__c FROM Tokens_Clicksign__mdt WHERE DeveloperName ='Geral'];
        
        string token = geral.Token__c;
        
        Order contrato = [SELECT ID, idDocAutentique__c
                          FROM Order 
                          WHERE ID =: idContrato];
        
        
        HttpRequest cancela = new HttpRequest();
        cancela.setMethod('PATCH');
        cancela.setEndpoint('https://app.clicksign.com/api/v1/documents/'+ contrato.idDocAutentique__c +'/cancel?access_token=' + token);
        cancela.setHeader('Content-Type', 'application/json');
        cancela.setHeader('Accept', 'application/json');
        
        HttpResponse rCancela = new HttpResponse();
        rCancela = new Http().send(cancela);
        
        
        system.debug(rCancela.getBody());
        Integer statusCode = rCancela.getStatusCode();
        
        if(statusCode == 200){
            contrato.Fase__c = 'Cancelado';
            contrato.idDocAutentique__c = '';
            update contrato;
        }
        else{
            throw new AuraHandledException('Erro de cancelamento, forneça as seguintes informações para o suporte: ' + 'StatusCode: ' + statusCode + '; ResponseBody: ' + rCancela.getBody() + '');  
        }
    }
    @AuraEnabled
    public static string consultarDemo(string idContrato){
        
        Tokens_Clicksign__mdt geral = [SELECT DeveloperName, Token__c FROM Tokens_Clicksign__mdt WHERE DeveloperName ='Geral'];
        
        string token = geral.Token__c;
        
        Order contrato = [SELECT ID, idDocAutentique__c
                          FROM Order 
                          WHERE ID =: idContrato];
        
        
        HttpRequest consulta = new HttpRequest();
        consulta.setMethod('GET');
        consulta.setEndpoint('https://app.clicksign.com/api/v1/documents/'+ contrato.idDocAutentique__c +'?access_token=' + token);
        consulta.setHeader('Content-Type', 'application/json');
        consulta.setHeader('Accept', 'application/json');
        //req.setTimeout(120000);
        HttpResponse rConsulta = new HttpResponse();
        rConsulta = new Http().send(consulta);
        
        return rConsulta.getBody();
        
        
    }    
    
    
    //Parte do aditivo (locação)
    @AuraEnabled
    public static void enviarAditivo(string idContrato){
        
        Aditivos_Contratuais__c contrato = [SELECT ID, Contrato_de_Servi_o_Relacionado__r.OwnerId, Contrato_de_Servi_o_Relacionado__r.N_mero_da_Proposta_Contrato__c, Contrato_de_Servi_o_Relacionado__r.Contato_do_Locat_rio__r.idDoSignatario__c, Contrato_de_Servi_o_Relacionado__r.Contato_do_Locat_rio__r.CPF__c, Contrato_de_Servi_o_Relacionado__r.Contato_do_Locat_rio__r.FirstName, Contrato_de_Servi_o_Relacionado__r.Contato_do_Locat_rio__r.LastName, Contrato_de_Servi_o_Relacionado__r.Contato_do_Locat_rio__r.Email, 
                                            Contrato_de_Servi_o_Relacionado__r.Testemunha__r.idDoSignatario__c, Contrato_de_Servi_o_Relacionado__r.Testemunha__r.FirstName, Contrato_de_Servi_o_Relacionado__r.Testemunha__r.LastName,Contrato_de_Servi_o_Relacionado__r.Testemunha__r.Email, Contrato_de_Servi_o_Relacionado__r.Testemunha__r.CPF__c, Contrato_de_Servi_o_Relacionado__r.Testemunha__r.AccountId,
                                            Contrato_de_Servi_o_Relacionado__r.Fiador__c, Contrato_de_Servi_o_Relacionado__r.Fiador__r.idDoSignatario__c, Contrato_de_Servi_o_Relacionado__r.Fiador__r.Name, Contrato_de_Servi_o_Relacionado__r.Fiador__r.CPF__pc, Contrato_de_Servi_o_Relacionado__r.Fiador__r.PersonEmail, Contrato_de_Servi_o_Relacionado__r.Vendedor_do_Contrato__c,
                                            Contrato_de_Servi_o_Relacionado__r.Conjuge_do_fiador__c, Contrato_de_Servi_o_Relacionado__r.Conjuge_do_fiador__r.idDoSignatario__c, Contrato_de_Servi_o_Relacionado__r.Conjuge_do_fiador__r.Name, Contrato_de_Servi_o_Relacionado__r.Conjuge_do_fiador__r.CPF__pc, Contrato_de_Servi_o_Relacionado__r.Conjuge_do_fiador__r.PersonEmail,  
                                            Contrato_de_Servi_o_Relacionado__r.Assinante2__c, Contrato_de_Servi_o_Relacionado__r.Assinante2__r.idDoSignatario__c, Contrato_de_Servi_o_Relacionado__r.Assinante2__r.FirstName, Contrato_de_Servi_o_Relacionado__r.Assinante2__r.LastName, Contrato_de_Servi_o_Relacionado__r.Assinante2__r.CPF__c, Contrato_de_Servi_o_Relacionado__r.Assinante2__r.Email,
                                            Contrato_de_Servi_o_Relacionado__r.Validador__c, Contrato_de_Servi_o_Relacionado__r.Validador__r.idDoSignatario__c, Contrato_de_Servi_o_Relacionado__r.Validador__r.FirstName,Contrato_de_Servi_o_Relacionado__r.Validador__r.LastName, Contrato_de_Servi_o_Relacionado__r.Validador__r.CPF__c, Contrato_de_Servi_o_Relacionado__r.Validador__r.Email, 
                                            Contrato_de_Servi_o_Relacionado__r.Validador2__c, Contrato_de_Servi_o_Relacionado__r.Validador2__r.idDoSignatario__c, Contrato_de_Servi_o_Relacionado__r.Validador2__r.FirstName,Contrato_de_Servi_o_Relacionado__r.Validador2__r.LastName, Contrato_de_Servi_o_Relacionado__r.Validador2__r.CPF__c, Contrato_de_Servi_o_Relacionado__r.Validador2__r.Email  
                                            FROM Aditivos_Contratuais__c 
                                            WHERE ID =: idContrato];
        
        contact signatario = [SELECT idDoSignatario__c FROM Contact WHERE ID =: contrato.Contrato_de_Servi_o_Relacionado__r.Contato_do_Locat_rio__c];
        
        Contact testemunha = [SELECT idDoSignatario__c FROM Contact WHERE ID =: contrato.Contrato_de_Servi_o_Relacionado__r.Testemunha__c];
        
        
        string idSignatario;
        string idSignatarioTest;
        string idSignatarioFiador;
        string idSignatarioConjugeFiador;
        string idSignatarioAssinante2;
        string idSignatarioValidador;
        string idSignatarioValidador2;
        string cpfTestemunha;
        
        Tokens_Clicksign__mdt juridico = [SELECT DeveloperName, Token__c FROM Tokens_Clicksign__mdt WHERE DeveloperName ='Juridico'];
        Tokens_Clicksign__mdt financeiro = [SELECT DeveloperName, Token__c FROM Tokens_Clicksign__mdt WHERE DeveloperName ='Financeiro'];
        Tokens_Clicksign__mdt adm = [SELECT DeveloperName, Token__c FROM Tokens_Clicksign__mdt WHERE DeveloperName ='Adm'];
        Tokens_Clicksign__mdt geral = [SELECT DeveloperName, Token__c FROM Tokens_Clicksign__mdt WHERE DeveloperName ='Geral'];
        
        string idSignatarioJuridico = juridico.Token__c;
        string idSignatarioFinanceiro = financeiro.Token__c;
        string idSignatarioAdm = adm.Token__c;
        string token = geral.Token__c;
        
        string l0g = '';
        
        HttpRequest req = new HttpRequest();
        
        PageReference pdf = Page.Aditivo_Contratual;
        pdf.getParameters().put('id', idContrato);
        
        Blob pdfBody;
        String base64PDF;
        
        if (!Test.IsRunningTest()){
            pdfBody = pdf.getContentAsPDF();
            base64PDF = EncodingUtil.base64Encode(pdfBody);
        }
        else{
            pdfBody = Blob.valueOf('Teste');
            base64PDF = 'TESTE';
        }
        
        dateTime agora = system.now();
        
        String nomeDoDocumento = 'Aditivo ao Contrato de Locação Nº ' + contrato.Contrato_de_Servi_o_Relacionado__r.N_mero_da_Proposta_Contrato__c;
        
        req.setMethod('POST');
        req.setEndpoint('http://oldsite.hospcom.net:21220/clickSign');
        req.setHeader('Content','{"document":{"path": "/' + nomeDoDocumento + '.pdf","content_base64": "data:application/pdf;base64,%","locale": "pt-BR","sequence_enabled": true}}');
        req.setTimeout(120000);
        req.setBody(base64PDF);
        
        //system.debug(req.getBody());
        
        //system.debug('base64:::::' + req.getBody());
        
        HttpResponse resp = new HttpResponse();
        
        resp = new Http().send(req);
        
        system.debug(resp.getBody());
        
        string keyid = resp.getBody();
        
        l0g = 'ID do Documento: ' + keyid +
            + '\n \n Requisição de envio para o Servidor' + req;
        
        if(contrato.Contrato_de_Servi_o_Relacionado__r.Testemunha__r.AccountId == '001i00000085QYbAAM'){
            Dados_colaborador__c dados = [SELECT CPF__c FROM Dados_colaborador__c WHERE Contato__c =: contrato.Contrato_de_Servi_o_Relacionado__r.Testemunha__c];
            cpfTestemunha = dados.CPF__c;
        }
        else{
            cpfTestemunha = contrato.Contrato_de_Servi_o_Relacionado__r.Testemunha__r.CPF__c;
        }
        
        if(resp.getStatusCode() == 200){
            if(!keyId.contains('error')){
                
                Autentique__c doc = new Autentique__c(idDocAutentique__c = keyid, Nome_do_Documento__c = nomeDoDocumento);
                
                contrato.idDocAutentique__c = keyid;
                contrato.Fase__c = '1';
                //Requisição para criar o signatário no Clicksign caso ele ainda não tenha
                string body = '{' +
                    +'"signer": { ' +
                    +'"email": "'+ contrato.Contrato_de_Servi_o_Relacionado__r.Contato_do_Locat_rio__r.Email +'", '+
                    +'"auths": [ ' +
                    +'"email" ' +
                    +'], '+
                    +'"name": "'+ contrato.Contrato_de_Servi_o_Relacionado__r.Contato_do_Locat_rio__r.Firstname + ' ' + contrato.Contrato_de_Servi_o_Relacionado__r.Contato_do_Locat_rio__r.LastName +'",' +
                    +'"documentation": "'+ contrato.Contrato_de_Servi_o_Relacionado__r.Contato_do_Locat_rio__r.CPF__c +'",' +
                    +'"has_documentation": true,' +
                    +'"selfie_enabled": false,'+
                    +'"handwritten_enabled": false,'+
                    +'"official_document_enabled": false,' +
                    +'"liveness_enabled": false,'+
                    +'"facial_biometrics_enabled": false'+
                    +'}'+
                    +'}';
                
                HttpRequest req2 = new HttpRequest();
                req2.setMethod('POST');
                req2.setEndpoint('https://app.clicksign.com/api/v1/signers?access_token='+ token);
                req2.setHeader('Content-Type', 'application/json');
                //req.setTimeout(120000);
                req2.setBody(body);
                HttpResponse respost = new HttpResponse();
                
                respost = new Http().send(req2);
                
                l0g = l0g + ' resposta requisicao criar assinador: ' + respost.getBody();
                
                idSignatario = respost.getBody().substringAfter('"key":"').substringBefore('",'); //salvar id do signatário novo
                
                l0g = l0g + '\n ID DO NOVO SIGNATARIO ADICIONADO:: ' + idSignatario;
                
                
                //Requisição para adicionar o signatário ao documento
                string body3 = '{"list": {"document_key": "'+ keyid +'",'+
                    +'"signer_key": "'+ idSignatario +'",'+
                    +'"sign_as": "party",'+
                    +'"refusable": true,'+
                    +'"group": 1,'+
                    +'"message": "Prezado,\nPor favor assine o documento.\n\nQualquer dúvida estamos à disposição.\n\nAtenciosamente, \nHOSPCOM"}}';
                
                HttpRequest req3 = new HttpRequest();
                req3.setMethod('POST');
                req3.setEndpoint('https://app.clicksign.com/api/v1/lists?access_token=' + token);
                req3.setHeader('Content-Type', 'application/json');
                //req.setTimeout(120000);
                req3.setBody(body3);
                HttpResponse respost3 = new HttpResponse();
                
                respost3 = new Http().send(req3);
                
                l0g = l0g + '\n resposta requisicao adicionar assinador: ' + respost3.getBody();
                
                string idAssinatura = respost3.getBody().substringAfter('request_signature_key":"').substringBefore('","document'); 
                
                //Requisição para enviar notificação para o assinador
                
                string body4 = '{'+
                    +'"request_signature_key": "'+ idAssinatura +'",'+
                    +'"message": "Prezado,\nPor favor assine o documento.\n\nQualquer dúvida estou à disposição.\n\nAtenciosamente,\nHOSPCOM"}';
                
                HttpRequest req4 = new HttpRequest();
                req4.setMethod('POST');
                req4.setEndpoint('https://app.clicksign.com/api/v1/notifications?access_token=' + token);
                req4.setHeader('Content-Type', 'application/json');
                //req.setTimeout(120000);
                req4.setBody(body4);
                HttpResponse respost4 = new HttpResponse();
                
                respost4 = new Http().send(req4);
                
                l0g = l0g + '\n resposta requisicao notificar assinador: ' + respost4.getStatus();
                
                //Testemunha
                string bodyTest = '{' +
                    +'"signer": { ' +
                    +'"email": "'+ contrato.Contrato_de_Servi_o_Relacionado__r.Testemunha__r.Email +'", '+
                    +'"auths": [ ' +
                    +'"email" ' +
                    +'], '+
                    +'"name": "'+ contrato.Contrato_de_Servi_o_Relacionado__r.Testemunha__r.Firstname + ' ' + contrato.Contrato_de_Servi_o_Relacionado__r.Testemunha__r.LastName +'",' +
                    +'"documentation": "'+ cpfTestemunha +'",' +
                    +'"has_documentation": true,' +
                    +'"selfie_enabled": false,'+
                    +'"handwritten_enabled": false,'+
                    +'"official_document_enabled": false,' +
                    +'"liveness_enabled": false,'+
                    +'"facial_biometrics_enabled": false'+
                    +'}'+
                    +'}';
                
                HttpRequest reqTest = new HttpRequest();
                reqTest.setMethod('POST');
                reqTest.setEndpoint('https://app.clicksign.com/api/v1/signers?access_token=' + token);
                reqTest.setHeader('Content-Type', 'application/json');
                //req.setTimeout(120000);
                reqTest.setBody(bodyTest);
                HttpResponse resposTest = new HttpResponse();
                
                resposTest = new Http().send(reqTest);
                
                l0g = l0g + '\n resposta requisicao criar testemunha: ' + resposTest.getBody();
                
                idSignatarioTest = resposTest.getBody().substringAfter('"key":"').substringBefore('",'); //salvar id do signatário novo
                
                
                l0g = l0g + '\n ID DO NOVO TESTEMUNHA ADICIONADO:: ' + idSignatarioTest;                    
                
                
                //Requisição para adicionar a testemunha ao documento
                string bodyTest2 = '{"list": {"document_key": "'+ keyid +'",'+
                    +'"signer_key": "'+ idSignatarioTest +'",'+
                    +'"sign_as": "witness",'+
                    +'"refusable": true,'+
                    +'"group": 1,'+
                    +'"message": "Prezado,\nPor favor assine o documento.\n\nQualquer dúvida estamos à disposição.\n\nAtenciosamente, \nHOSPCOM"}}';
                
                HttpRequest reqTest2 = new HttpRequest();
                reqTest2.setMethod('POST');
                reqTest2.setEndpoint('https://app.clicksign.com/api/v1/lists?access_token=' + token);
                reqTest2.setHeader('Content-Type', 'application/json');
                //req.setTimeout(120000);
                reqTest2.setBody(bodyTest2);
                HttpResponse resposTest2 = new HttpResponse();
                
                resposTest2 = new Http().send(reqTest2);
                
                l0g = l0g + '\n resposta requisicao adicionar testemunha: ' + resposTest2.getBody();
                
                string idAssinaturaTest = resposTest2.getBody().substringAfter('request_signature_key":"').substringBefore('","document');                                       
                
                //Requisição para enviar notificação para a testemunha
                
                string bodyTest3 = '{'+
                    +'"request_signature_key": "'+ idAssinaturaTest +'",'+
                    +'"message": "Prezado,\nPor favor assine o documento.\n\nQualquer dúvida estou à disposição.\n\nAtenciosamente,\nHOSPCOM"}';
                
                HttpRequest reqTest3 = new HttpRequest();
                reqTest3.setMethod('POST');
                reqTest3.setEndpoint('https://app.clicksign.com/api/v1/notifications?access_token=' + token);
                reqTest3.setHeader('Content-Type', 'application/json');
                //req.setTimeout(120000);
                reqTest3.setBody(bodyTest3);
                HttpResponse resposTest3 = new HttpResponse();
                
                resposTest3 = new Http().send(reqTest3);
                
                l0g = l0g + '\n resposta requisicao notificar testemunha: ' + resposTest3.getStatus();
                
                
                //Caso o contrato tenha fiador                        
                if(contrato.Contrato_de_Servi_o_Relacionado__r.Fiador__c != null){
                    string bodyFiador = '{' +
                        +'"signer": { ' +
                        +'"email": "'+ contrato.Contrato_de_Servi_o_Relacionado__r.Fiador__r.PersonEmail +'", '+
                        +'"auths": [ ' +
                        +'"email" ' +
                        +'], '+
                        +'"name": "'+ contrato.Contrato_de_Servi_o_Relacionado__r.Fiador__r.Name +'",' +
                        +'"documentation": "'+ contrato.Contrato_de_Servi_o_Relacionado__r.Fiador__r.CPF__pc +'",' +
                        +'"has_documentation": true,' +
                        +'"selfie_enabled": false,'+
                        +'"handwritten_enabled": false,'+
                        +'"official_document_enabled": false,' +
                        +'"liveness_enabled": false,'+
                        +'"facial_biometrics_enabled": false'+
                        +'}'+
                        +'}';
                    
                    HttpRequest reqFiador = new HttpRequest();
                    reqFiador.setMethod('POST');
                    reqFiador.setEndpoint('https://app.clicksign.com/api/v1/signers?access_token=' + token);
                    reqFiador.setHeader('Content-Type', 'application/json');
                    //req.setTimeout(120000);
                    reqFiador.setBody(bodyFiador);
                    HttpResponse resposFiador = new HttpResponse();
                    
                    resposFiador = new Http().send(reqFiador);
                    
                    l0g = l0g + '\n resposta requisicao criar fiador: ' + resposFiador.getBody();
                    
                    idSignatarioFiador = resposFiador.getBody().substringAfter('"key":"').substringBefore('",'); //salvar id do signatário novo
                    
                    l0g = l0g + '\n ID DO NOVO FIADOR ADICIONADO:: ' + idSignatarioFiador;
                    
                    
                    //Requisição para adicionar o fiador ao documento
                    string bodyFiador2 = '{"list": {"document_key": "'+ keyid +'",'+
                        +'"signer_key": "'+ idSignatarioFiador +'",'+
                        +'"sign_as": "surety",'+
                        +'"refusable": true,'+
                        +'"group": 1,'+
                        +'"message": "Prezado,\nPor favor assine o documento.\n\nQualquer dúvida estamos à disposição.\n\nAtenciosamente, \nHOSPCOM"}}';
                    
                    HttpRequest reqFiador2 = new HttpRequest();
                    reqFiador2.setMethod('POST');
                    reqFiador2.setEndpoint('https://app.clicksign.com/api/v1/lists?access_token=' + token);
                    reqFiador2.setHeader('Content-Type', 'application/json');
                    //req.setTimeout(120000);
                    reqFiador2.setBody(bodyFiador2);
                    HttpResponse resposFiador2 = new HttpResponse();
                    
                    resposFiador2 = new Http().send(reqFiador2);
                    
                    l0g = l0g + '\n resposta requisicao adicionar fiador: ' + resposFiador2.getBody();
                    
                    string idAssinaturaFiador = resposFiador2.getBody().substringAfter('request_signature_key":"').substringBefore('","document'); 
                    
                    //Requisição para enviar notificação para o fiador
                    
                    string bodyFiador3 = '{'+
                        +'"request_signature_key": "'+ idAssinaturaFiador +'",'+
                        +'"message": "Prezado,\nPor favor assine o documento.\n\nQualquer dúvida estou à disposição.\n\nAtenciosamente,\nHOSPCOM"}';
                    
                    HttpRequest reqFiador3 = new HttpRequest();
                    reqFiador3.setMethod('POST');
                    reqFiador3.setEndpoint('https://app.clicksign.com/api/v1/notifications?access_token=' + token);
                    reqFiador3.setHeader('Content-Type', 'application/json');
                    //req.setTimeout(120000);
                    reqFiador3.setBody(bodyFiador3);
                    HttpResponse resposFiador3 = new HttpResponse();
                    
                    resposFiador3 = new Http().send(reqFiador3);
                    
                    l0g = l0g + '\n resposta requisicao notificar fiador: ' + resposFiador3.getStatus();
                    
                }
                
                //Caso o contrato tenha conjuge do fiador                        
                if(contrato.Contrato_de_Servi_o_Relacionado__r.Conjuge_do_fiador__c != null){
                    string bodyConjFiador = '{' +
                        +'"signer": { ' +
                        +'"email": "'+ contrato.Contrato_de_Servi_o_Relacionado__r.Conjuge_do_fiador__r.PersonEmail +'", '+
                        +'"auths": [ ' +
                        +'"email" ' +
                        +'], '+
                        +'"name": "'+ contrato.Contrato_de_Servi_o_Relacionado__r.Conjuge_do_fiador__r.Name +'",' +
                        +'"documentation": "'+ contrato.Contrato_de_Servi_o_Relacionado__r.Conjuge_do_fiador__r.CPF__pc +'",' +
                        +'"has_documentation": true,' +
                        +'"selfie_enabled": false,'+
                        +'"handwritten_enabled": false,'+
                        +'"official_document_enabled": false,' +
                        +'"liveness_enabled": false,'+
                        +'"facial_biometrics_enabled": false'+
                        +'}'+
                        +'}';
                    
                    HttpRequest reqConjFiador = new HttpRequest();
                    reqConjFiador.setMethod('POST');
                    reqConjFiador.setEndpoint('https://app.clicksign.com/api/v1/signers?access_token=' + token);
                    reqConjFiador.setHeader('Content-Type', 'application/json');
                    //req.setTimeout(120000);
                    reqConjFiador.setBody(bodyConjFiador);
                    HttpResponse resposConjFiador = new HttpResponse();
                    
                    resposConjFiador = new Http().send(reqConjFiador);
                    
                    l0g = l0g + '\n resposta requisicao criar conjuge: ' + resposConjFiador.getBody();
                    
                    idSignatarioConjugeFiador = resposConjFiador.getBody().substringAfter('"key":"').substringBefore('",'); //salvar id do signatário novo
                    
                    
                    l0g = l0g + '\n ID DO NOVO CONJUGE ADICIONADO:: ' + idSignatarioConjugeFiador;
                    
                    
                    //Requisição para adicionar o conjuge do fiador ao documento
                    string bodyConjFiador2 = '{"list": {"document_key": "'+ keyid +'",'+
                        +'"signer_key": "'+ idSignatarioConjugeFiador +'",'+
                        +'"sign_as": "surety",'+
                        +'"refusable": true,'+
                        +'"group": 1,'+
                        +'"message": "Prezado,\nPor favor assine o documento.\n\nQualquer dúvida estamos à disposição.\n\nAtenciosamente, \nHOSPCOM"}}';
                    
                    HttpRequest reqConjFiador2 = new HttpRequest();
                    reqConjFiador2.setMethod('POST');
                    reqConjFiador2.setEndpoint('https://app.clicksign.com/api/v1/lists?access_token=' + token);
                    reqConjFiador2.setHeader('Content-Type', 'application/json');
                    //req.setTimeout(120000);
                    reqConjFiador2.setBody(bodyConjFiador2);
                    HttpResponse resposConjFiador2 = new HttpResponse();
                    
                    resposConjFiador2 = new Http().send(reqConjFiador2);
                    
                    l0g = l0g + '\n resposta requisicao adicionar conjuge fiador: ' + resposConjFiador2.getBody();
                    
                    string idAssinaturaConjFiador = resposConjFiador2.getBody().substringAfter('request_signature_key":"').substringBefore('","document'); 
                    
                    //Requisição para enviar notificação para o conjuge do fiador
                    
                    string bodyConjFiador3 = '{'+
                        +'"request_signature_key": "'+ idAssinaturaConjFiador +'",'+
                        +'"message": "Prezado,\nPor favor assine o documento.\n\nQualquer dúvida estou à disposição.\n\nAtenciosamente,\nHOSPCOM"}';
                    
                    HttpRequest reqConjFiador3 = new HttpRequest();
                    reqConjFiador3.setMethod('POST');
                    reqConjFiador3.setEndpoint('https://app.clicksign.com/api/v1/notifications?access_token=' + token);
                    reqConjFiador3.setHeader('Content-Type', 'application/json');
                    //req.setTimeout(120000);
                    reqConjFiador3.setBody(bodyConjFiador3);
                    HttpResponse resposConjFiador3 = new HttpResponse();
                    
                    resposConjFiador3 = new Http().send(reqConjFiador3);
                    
                    l0g = l0g + '\n resposta requisicao notificar conjuge do fiador: ' + resposConjFiador3.getStatus();
                    
                }
                
                //Adicionar o Validador
                if(contrato.Contrato_de_Servi_o_Relacionado__r.Validador__c != null){
                    string bodyValidador;
                    bodyValidador = '{' +
                        +'"signer": { ' +
                        +'"email": "'+ contrato.Contrato_de_Servi_o_Relacionado__r.Validador__r.Email +'", '+
                        +'"auths": [ ' +
                        +'"email" ' +
                        +'], '+
                        +'"name": "'+ contrato.Contrato_de_Servi_o_Relacionado__r.Validador__r.Firstname + ' ' + contrato.Contrato_de_Servi_o_Relacionado__r.Validador__r.LastName +'",' +
                        +'"documentation": "'+ contrato.Contrato_de_Servi_o_Relacionado__r.Validador__r.CPF__c +'",' +
                        +'"has_documentation": true,' +
                        +'"selfie_enabled": false,'+
                        +'"handwritten_enabled": false,'+
                        +'"official_document_enabled": false,' +
                        +'"liveness_enabled": false,'+
                        +'"facial_biometrics_enabled": false'+
                        +'}'+
                        +'}';
                    
                    HttpRequest reqValidador = new HttpRequest();
                    reqValidador.setMethod('POST');
                    reqValidador.setEndpoint('https://app.clicksign.com/api/v1/signers?access_token='+ token);
                    reqValidador.setHeader('Content-Type', 'application/json');
                    //req.setTimeout(120000);
                    reqValidador.setBody(bodyValidador);
                    HttpResponse respostValidador = new HttpResponse();
                    
                    respostValidador = new Http().send(reqValidador);
                    
                    l0g = l0g + ' resposta requisicao criar validador: ' + respostValidador.getBody();
                    
                    idSignatarioValidador = respostValidador.getBody().substringAfter('"key":"').substringBefore('",'); //salvar id do signatário novo
                    
                    l0g = l0g + '\n ID DO NOVO VALIDADOR ADICIONADO:: ' + idSignatarioValidador;
                    
                    //Requisição para adicionar o validador ao documento
                    string bodyValidador_2 = '{"list": {"document_key": "'+ keyid +'",'+
                        +'"signer_key": "'+ idSignatarioValidador +'",'+
                        +'"sign_as": "validator",'+
                        +'"refusable": true,'+
                        +'"group": 1,'+
                        +'"message": "Prezado,\nPor favor assine o documento.\n\nQualquer dúvida estamos à disposição.\n\nAtenciosamente, \nHOSPCOM"}}';
                    
                    HttpRequest reqValidador_2 = new HttpRequest();
                    reqValidador_2.setMethod('POST');
                    reqValidador_2.setEndpoint('https://app.clicksign.com/api/v1/lists?access_token=' + token);
                    reqValidador_2.setHeader('Content-Type', 'application/json');
                    //req.setTimeout(120000);
                    reqValidador_2.setBody(bodyValidador_2);
                    HttpResponse respostValidador_2 = new HttpResponse();
                    
                    respostValidador_2 = new Http().send(reqValidador_2);
                    
                    l0g = l0g + '\n resposta requisicao adicionar assinador: ' + respostValidador_2.getBody();
                    
                    string idValidador = respostValidador_2.getBody().substringAfter('request_signature_key":"').substringBefore('","document'); 
                    
                    //Requisição para enviar notificação para o validador
                    
                    string bodyValidador_3 = '{'+
                        +'"request_signature_key": "'+ idValidador +'",'+
                        +'"message": "Prezado,\nPor favor assine o documento.\n\nQualquer dúvida estou à disposição.\n\nAtenciosamente,\nHOSPCOM"}';
                    
                    HttpRequest reqValidador_3 = new HttpRequest();
                    reqValidador_3.setMethod('POST');
                    reqValidador_3.setEndpoint('https://app.clicksign.com/api/v1/notifications?access_token=' + token);
                    reqValidador_3.setHeader('Content-Type', 'application/json');
                    //req.setTimeout(120000);
                    reqValidador_3.setBody(bodyValidador_3);
                    HttpResponse respostValidador_3 = new HttpResponse();
                    
                    respostValidador_3 = new Http().send(reqValidador_3);
                    
                    l0g = l0g + '\n resposta requisicao notificar validador: ' + respostValidador_3.getStatus();
                }
                //Adicionar o Validador 2
                if(contrato.Contrato_de_Servi_o_Relacionado__r.Validador2__c != null){
                    string bodyValidador2;
                    bodyValidador2 = '{' +
                        +'"signer": { ' +
                        +'"email": "'+ contrato.Contrato_de_Servi_o_Relacionado__r.Validador2__r.Email +'", '+
                        +'"auths": [ ' +
                        +'"email" ' +
                        +'], '+
                        +'"name": "'+ contrato.Contrato_de_Servi_o_Relacionado__r.Validador2__r.Firstname + ' ' + contrato.Contrato_de_Servi_o_Relacionado__r.Validador2__r.LastName +'",' +
                        +'"documentation": "'+ contrato.Contrato_de_Servi_o_Relacionado__r.Validador2__r.CPF__c +'",' +
                        +'"has_documentation": true,' +
                        +'"selfie_enabled": false,'+
                        +'"handwritten_enabled": false,'+
                        +'"official_document_enabled": false,' +
                        +'"liveness_enabled": false,'+
                        +'"facial_biometrics_enabled": false'+
                        +'}'+
                        +'}';
                    
                    HttpRequest reqValidador2 = new HttpRequest();
                    reqValidador2.setMethod('POST');
                    reqValidador2.setEndpoint('https://app.clicksign.com/api/v1/signers?access_token='+ token);
                    reqValidador2.setHeader('Content-Type', 'application/json');
                    //req.setTimeout(120000);
                    reqValidador2.setBody(bodyValidador2);
                    HttpResponse respostValidador2 = new HttpResponse();
                    
                    respostValidador2 = new Http().send(reqValidador2);
                    
                    l0g = l0g + ' resposta requisicao criar validador 2: ' + respostValidador2.getBody();
                    
                    idSignatarioValidador2 = respostValidador2.getBody().substringAfter('"key":"').substringBefore('",'); //salvar id do signatário novo
                    
                    l0g = l0g + '\n ID DO NOVO VALIDADOR 2 ADICIONADO:: ' + idSignatarioValidador2;
                    
                    //Requisição para adicionar o validador 2 ao documento
                    string bodyValidador2_2 = '{"list": {"document_key": "'+ keyid +'",'+
                        +'"signer_key": "'+ idSignatarioValidador2 +'",'+
                        +'"sign_as": "validator",'+
                        +'"refusable": true,'+
                        +'"group": 1,'+
                        +'"message": "Prezado,\nPor favor assine o documento.\n\nQualquer dúvida estamos à disposição.\n\nAtenciosamente, \nHOSPCOM"}}';
                    
                    HttpRequest reqValidador2_2 = new HttpRequest();
                    reqValidador2_2.setMethod('POST');
                    reqValidador2_2.setEndpoint('https://app.clicksign.com/api/v1/lists?access_token=' + token);
                    reqValidador2_2.setHeader('Content-Type', 'application/json');
                    //req.setTimeout(120000);
                    reqValidador2_2.setBody(bodyValidador2_2);
                    HttpResponse respostValidador2_2 = new HttpResponse();
                    
                    respostValidador2_2 = new Http().send(reqValidador2_2);
                    
                    l0g = l0g + '\n resposta requisicao adicionar validador 2: ' + respostValidador2_2.getBody();
                    
                    string idValidador2 = respostValidador2_2.getBody().substringAfter('request_signature_key":"').substringBefore('","document'); 
                    
                    //Requisição para enviar notificação para o validador 2
                    
                    string bodyValidador2_3 = '{'+
                        +'"request_signature_key": "'+ idValidador2 +'",'+
                        +'"message": "Prezado,\nPor favor assine o documento.\n\nQualquer dúvida estou à disposição.\n\nAtenciosamente,\nHOSPCOM"}';
                    
                    HttpRequest reqValidador2_3 = new HttpRequest();
                    reqValidador2_3.setMethod('POST');
                    reqValidador2_3.setEndpoint('https://app.clicksign.com/api/v1/notifications?access_token=' + token);
                    reqValidador2_3.setHeader('Content-Type', 'application/json');
                    //req.setTimeout(120000);
                    reqValidador2_3.setBody(bodyValidador2_3);
                    HttpResponse respostValidador2_3 = new HttpResponse();
                    
                    respostValidador2_3 = new Http().send(reqValidador2_3);
                    
                    l0g = l0g + '\n resposta requisicao notificar validador 2: ' + respostValidador2_3.getStatus();
                }
                
                //Adicionar o financeiro no processo de assinatura
                string bodyFinanceiro = '{"list": {"document_key": "'+ keyid +'",'+
                    +'"signer_key": "'+ idSignatarioFinanceiro +'",'+
                    +'"sign_as": "approve",'+
                    +'"refusable": true,'+
                    +'"group": 2,'+
                    +'"message": "Prezado,\nPor favor assine o documento.\n\nQualquer dúvida estamos à disposição.\n\nAtenciosamente, \nHOSPCOM"}}';
                
                HttpRequest reqFinanceiro = new HttpRequest();
                reqFinanceiro.setMethod('POST');
                reqFinanceiro.setEndpoint('https://app.clicksign.com/api/v1/lists?access_token=' + token);
                reqFinanceiro.setHeader('Content-Type', 'application/json');
                //req.setTimeout(120000);
                reqFinanceiro.setBody(bodyFinanceiro);
                HttpResponse resposFinanceiro = new HttpResponse();
                
                resposFinanceiro = new Http().send(reqFinanceiro);
                
                l0g = l0g + '\n resposta requisicao adicionar financeiro: ' + resposFinanceiro.getBody();
                
                string idAssinaturaFinanceiro = resposFinanceiro.getBody().substringAfter('request_signature_key":"').substringBefore('","document');
                
                //Adicionar o juridico no processo de assinatura
                string bodyJuridico = '{"list": {"document_key": "'+ keyid +'",'+
                    +'"signer_key": "'+ idSignatarioJuridico +'",'+
                    +'"sign_as": "witness",'+
                    +'"refusable": true,'+
                    +'"group": 3,'+
                    +'"message": "Prezado,\nPor favor assine o documento.\n\nQualquer dúvida estamos à disposição.\n\nAtenciosamente, \nHOSPCOM"}}';
                
                HttpRequest reqJuridico = new HttpRequest();
                reqJuridico.setMethod('POST');
                reqJuridico.setEndpoint('https://app.clicksign.com/api/v1/lists?access_token=' + token);
                reqJuridico.setHeader('Content-Type', 'application/json');
                //req.setTimeout(120000);
                reqJuridico.setBody(bodyJuridico);
                HttpResponse resposJuridico = new HttpResponse();
                
                resposJuridico = new Http().send(reqJuridico);
                
                l0g = l0g + '\n resposta requisicao adicionar juridico: ' + resposJuridico.getBody();
                
                string idAssinaturaJuridico = resposJuridico.getBody().substringAfter('request_signature_key":"').substringBefore('","document');
                
                //Adicionar o administrativo no processo de assinatura
                string bodyAdm = '{"list": {"document_key": "'+ keyid +'",'+
                    +'"signer_key": "'+ idSignatarioAdm +'",'+
                    +'"sign_as": "party",'+
                    +'"refusable": true,'+
                    +'"group": 3,'+
                    +'"message": "Prezado,\nPor favor assine o documento.\n\nQualquer dúvida estamos à disposição.\n\nAtenciosamente, \nHOSPCOM"}}';
                
                HttpRequest reqAdm = new HttpRequest();
                reqAdm.setMethod('POST');
                reqAdm.setEndpoint('https://app.clicksign.com/api/v1/lists?access_token=' + token);
                reqAdm.setHeader('Content-Type', 'application/json');
                //req.setTimeout(120000);
                reqAdm.setBody(bodyAdm);
                HttpResponse resposAdm = new HttpResponse();
                
                resposAdm = new Http().send(reqAdm);
                
                l0g = l0g + '\n resposta requisicao adicionar adm: ' + resposAdm.getBody();
                
                string idAssinaturaAdm = resposAdm.getBody().substringAfter('request_signature_key":"').substringBefore('","document');
                
                
                try{
                    update contrato;
                    signatario.idDoSignatario__c = idSignatario;
                    update signatario;
                    testemunha.idDoSignatario__c = idSignatarioTest;
                    update testemunha;
                    insert doc;
                }
                catch(DmlException e){
                    if(!Test.isRunningTest())
                        throw new AuraHandledException(e.getMessage());
                }
                
                
                //Cria e carrega um documento com as informações para o log
                Document logDoc = new Document(
                    Name = String.valueOf(System.Now().format('yyyy/MM/dd HH:mm:ss')) + ' - Aditivo ao Contrato: ' + contrato.Contrato_de_Servi_o_Relacionado__r.N_mero_da_Proposta_Contrato__c,
                    Body = Blob.valueOf(l0g),
                    ContentType = 'text/plain',
                    Type = 'txt',
                    IsPublic = false,
                    IsInternalUseOnly = true,
                    FolderId = '00l6e000002JcWd'        
                );
                insert logDoc;
            }
            else{
                throw new AuraHandledException('Erro de envio, forneça as seguintes informações para o suporte: ' + 'StatusCode: ' + resp.getStatusCode() + '; ResponseBody: ' + resp.getBody() + '');  
            }
        }  
        else{
            throw new AuraHandledException('Erro de envio, forneça as seguintes informações para o suporte: ' + 'StatusCode: ' + resp.getStatusCode() + '; ResponseBody: ' + resp.getBody() + '');  
        }
    }
    @AuraEnabled
    public static void cancelarAditivo(string idContrato){
        
        Tokens_Clicksign__mdt geral = [SELECT DeveloperName, Token__c FROM Tokens_Clicksign__mdt WHERE DeveloperName ='Geral'];
        
        string token = geral.Token__c;
        
        Aditivos_Contratuais__c contrato = [SELECT ID, idDocAutentique__c
                                            FROM Aditivos_Contratuais__c 
                                            WHERE ID =: idContrato];
        
        
        HttpRequest cancela = new HttpRequest();
        cancela.setMethod('PATCH');
        cancela.setEndpoint('https://app.clicksign.com/api/v1/documents/'+ contrato.idDocAutentique__c +'/cancel?access_token=' + token);
        cancela.setHeader('Content-Type', 'application/json');
        cancela.setHeader('Accept', 'application/json');
        
        HttpResponse rCancela = new HttpResponse();
        rCancela = new Http().send(cancela);
        
        
        system.debug(rCancela.getBody());
        Integer statusCode = rCancela.getStatusCode();
        
        contrato.Fase__c = 'Cancelado';
        contrato.idDocAutentique__c = '';
        update contrato;
        
    }
    @AuraEnabled
    public static string consultarAditivo(string idContrato){
        
        Tokens_Clicksign__mdt geral = [SELECT DeveloperName, Token__c FROM Tokens_Clicksign__mdt WHERE DeveloperName ='Geral'];
        
        string token = geral.Token__c;
        
        Aditivos_Contratuais__c contrato = [SELECT ID, idDocAutentique__c
                                            FROM Aditivos_Contratuais__c 
                                            WHERE ID =: idContrato];
        
        string cancelamento = 'Documento consultado as ' ;
        string cancelamento2 = 'Documento consultado as ' ;
        string cancelamento3 = 'Documento consultado as ' ;
        
        HttpRequest consulta = new HttpRequest();
        consulta.setMethod('GET');
        consulta.setEndpoint('https://app.clicksign.com/api/v1/documents/'+ contrato.idDocAutentique__c +'?access_token=' + token);
        consulta.setHeader('Content-Type', 'application/json');
        consulta.setHeader('Accept', 'application/json');
        //req.setTimeout(120000);
        HttpResponse rConsulta = new HttpResponse();
        rConsulta = new Http().send(consulta);
        
        return rConsulta.getBody();
        
        
        
    }
    
    //Parte do aditivo (locação)
    @AuraEnabled
    public static void enviarTermo(string idContrato){
        
        Asset contrato = [SELECT ID, OwnerId, Name, usuarioResponsavel__c, usuarioResponsavel__r.ContactId, ContatoReponsavel__c, Fase__c   
                          FROM Asset 
                          WHERE ID =: idContrato];
        
        contact signatario;
        
        
        if(contrato.usuarioResponsavel__c != null){
            signatario = [SELECT Id, Email, FirstName, LastName, CPF__c FROM Contact WHERE ID =: contrato.usuarioResponsavel__r.ContactId];
        }
        else if(contrato.ContatoReponsavel__c != null){        
            signatario = [SELECT Id, Email, FirstName, LastName, CPF__c FROM Contact WHERE ID =: contrato.ContatoReponsavel__c];
        }
        
        string idSignatario;
        
        
        Tokens_Clicksign__mdt geral = [SELECT DeveloperName, Token__c FROM Tokens_Clicksign__mdt WHERE DeveloperName ='Geral'];
        
        string token = geral.Token__c;
        
        string l0g = '';
        
        HttpRequest req = new HttpRequest();
        
        PageReference pdf = Page.PDF_termo_de_responsabilidade;
        pdf.getParameters().put('id', idContrato);
        
        Blob pdfBody;
        String base64PDF;
        
        if (!Test.IsRunningTest()){
            pdfBody = pdf.getContentAsPDF();
            base64PDF = EncodingUtil.base64Encode(pdfBody);
        }
        else{
            pdfBody = Blob.valueOf('Teste');
            base64PDF = 'TESTE';
        }
        
        dateTime agora = system.now();
        
        String nomeDoDocumento = 'Termo de compromisso ' + signatario.FirstName + ' ' + signatario.LastName + ' ' + contrato.Name;
        
        req.setMethod('POST');
        req.setEndpoint('http://oldsite.hospcom.net:21220/clickSign');
        req.setHeader('Content','{"document":{"path": "/' + nomeDoDocumento + '.pdf","content_base64": "data:application/pdf;base64,%","locale": "pt-BR","sequence_enabled": true}}');
        req.setTimeout(120000);
        req.setBody(base64PDF);
        
        HttpResponse resp = new HttpResponse();
        
        resp = new Http().send(req);
        
        system.debug(resp.getBody());
        
        string keyid = resp.getBody();
        
        l0g = 'ID do Documento: ' + keyid +
            + '\n \n Requisição de envio para o Servidor' + req;
        
        
        if(resp.getStatusCode() == 200){
            if(!keyId.contains('error')){
                
                Autentique__c doc = new Autentique__c(idDocAutentique__c = keyid, Nome_do_Documento__c = nomeDoDocumento);
                
                contrato.idDocAutentique__c = keyid;
                contrato.Fase__c = '1';
                //Requisição para criar o signatário no Clicksign caso ele ainda não tenha
                if(idSignatario == null){
                    string body = '{' +
                        +'"signer": { ' +
                        +'"email": "'+ signatario.Email +'", '+
                        +'"auths": [ ' +
                        +'"email" ' +
                        +'], '+
                        +'"name": "'+ signatario.Firstname + ' ' + signatario.LastName +'",' +
                        +'"selfie_enabled": true,'+
                        +'"handwritten_enabled": false,'+
                        +'"official_document_enabled": false,' +
                        +'"liveness_enabled": false,'+
                        +'"facial_biometrics_enabled": false'+
                        +'}'+
                        +'}';
                    
                    HttpRequest req2 = new HttpRequest();
                    req2.setMethod('POST');
                    req2.setEndpoint('https://app.clicksign.com/api/v1/signers?access_token='+ token);
                    req2.setHeader('Content-Type', 'application/json');
                    //req.setTimeout(120000);
                    req2.setBody(body);
                    HttpResponse respost = new HttpResponse();
                    
                    respost = new Http().send(req2);
                    
                    l0g = l0g + ' resposta requisicao criar assinador: ' + respost.getBody();
                    
                    idSignatario = respost.getBody().substringAfter('"key":"').substringBefore('",'); //salvar id do signatário novo
                    
                    l0g = l0g + '\n ID DO NOVO SIGNATARIO ADICIONADO:: ' + idSignatario;
                    
                }
                
                //Requisição para adicionar o signatário ao documento
                string body3 = '{"list": {"document_key": "'+ keyid +'",'+
                    +'"signer_key": "'+ idSignatario +'",'+
                    +'"sign_as": "party",'+
                    +'"refusable": true,'+
                    +'"group": 1,'+
                    +'"message": "Prezado,\nPor favor assine o documento.\n\nQualquer dúvida estamos à disposição.\n\nAtenciosamente, \nHOSPCOM"}}';
                
                HttpRequest req3 = new HttpRequest();
                req3.setMethod('POST');
                req3.setEndpoint('https://app.clicksign.com/api/v1/lists?access_token=' + token);
                req3.setHeader('Content-Type', 'application/json');
                //req.setTimeout(120000);
                req3.setBody(body3);
                HttpResponse respost3 = new HttpResponse();
                
                respost3 = new Http().send(req3);
                
                l0g = l0g + '\n resposta requisicao adicionar assinador: ' + respost3.getBody();
                
                string idAssinatura = respost3.getBody().substringAfter('request_signature_key":"').substringBefore('","document'); 
                
                //Requisição para enviar notificação para o assinador
                
                string body4 = '{'+
                    +'"request_signature_key": "'+ idAssinatura +'",'+
                    +'"message": "Prezado,\nPor favor assine o documento.\n\nQualquer dúvida estou à disposição.\n\nAtenciosamente,\nHOSPCOM"}';
                
                HttpRequest req4 = new HttpRequest();
                req4.setMethod('POST');
                req4.setEndpoint('https://app.clicksign.com/api/v1/notifications?access_token=' + token);
                req4.setHeader('Content-Type', 'application/json');
                //req.setTimeout(120000);
                req4.setBody(body4);
                HttpResponse respost4 = new HttpResponse();
                
                respost4 = new Http().send(req4);
                
                l0g = l0g + '\n resposta requisicao notificar assinador: ' + respost4.getStatus();
                
                
                
                try{
                    update contrato;
                    insert doc;
                }
                catch(DmlException e){
                    if(!Test.isRunningTest())
                        throw new AuraHandledException(e.getMessage());
                }
                
                
                //Cria e carrega um documento com as informações para o log
                Document logDoc = new Document(
                    Name = String.valueOf(System.Now().format('yyyy/MM/dd HH:mm:ss')) + ' - Termo de compromisso ' + signatario.FirstName + ' ' + signatario.LastName + ' ' + contrato.Name,
                    Body = Blob.valueOf(l0g),
                    ContentType = 'text/plain',
                    Type = 'txt',
                    IsPublic = false,
                    IsInternalUseOnly = true,
                    FolderId = '00l6e000002JcWd'        
                );
                insert logDoc;
            }
            else{
                throw new AuraHandledException('Erro de envio, forneça as seguintes informações para o suporte: ' + 'StatusCode: ' + resp.getStatusCode() + '; ResponseBody: ' + resp.getBody() + '');  
            }
        }  
        else{
            throw new AuraHandledException('Erro de envio, forneça as seguintes informações para o suporte: ' + 'StatusCode: ' + resp.getStatusCode() + '; ResponseBody: ' + resp.getBody() + '');  
        }
    }
    @AuraEnabled
    public static void cancelarTermo(string idContrato){
        
        Tokens_Clicksign__mdt geral = [SELECT DeveloperName, Token__c FROM Tokens_Clicksign__mdt WHERE DeveloperName ='Geral'];
        
        string token = geral.Token__c;
        
        Asset contrato = [SELECT ID, idDocAutentique__c
                          FROM Asset 
                          WHERE ID =: idContrato];
        
        
        HttpRequest cancela = new HttpRequest();
        cancela.setMethod('PATCH');
        cancela.setEndpoint('https://app.clicksign.com/api/v1/documents/'+ contrato.idDocAutentique__c +'/cancel?access_token=' + token);
        cancela.setHeader('Content-Type', 'application/json');
        cancela.setHeader('Accept', 'application/json');
        
        HttpResponse rCancela = new HttpResponse();
        rCancela = new Http().send(cancela);
        
        
        system.debug(rCancela.getBody());
        Integer statusCode = rCancela.getStatusCode();
        
        contrato.Fase__c = 'Cancelado';
        contrato.idDocAutentique__c = '';
        update contrato;            
        
    }
    @AuraEnabled
    public static string consultarTermo(string idContrato){
        
        Tokens_Clicksign__mdt geral = [SELECT DeveloperName, Token__c FROM Tokens_Clicksign__mdt WHERE DeveloperName ='Geral'];
        
        string token = geral.Token__c;
        
        Asset contrato = [SELECT ID, idDocAutentique__c
                          FROM Asset 
                          WHERE ID =: idContrato];
        
        string cancelamento = 'Documento consultado as ' ;
        string cancelamento2 = 'Documento consultado as ' ;
        string cancelamento3 = 'Documento consultado as ' ;
        
        HttpRequest consulta = new HttpRequest();
        consulta.setMethod('GET');
        consulta.setEndpoint('https://app.clicksign.com/api/v1/documents/'+ contrato.idDocAutentique__c +'?access_token=' + token);
        consulta.setHeader('Content-Type', 'application/json');
        consulta.setHeader('Accept', 'application/json');
        //req.setTimeout(120000);
        HttpResponse rConsulta = new HttpResponse();
        rConsulta = new Http().send(consulta);
        
        return rConsulta.getBody();
        
        
        
    }
    @AuraEnabled
    public static void enviarComodato(string idContrato){
        
        Demonstracao__c contrato = [SELECT ID, OwnerId, Name, Contato__r.idDoSignatario__c, Contato__r.CPF__c, Contato__r.FirstName, Contato__r.LastName, Contato__r.Email, 
                                    Testemunha__r.idDoSignatario__c, Testemunha__r.FirstName, Testemunha__r.LastName,Testemunha__r.Email, Testemunha__r.CPF__c, Testemunha__r.AccountId,
                                    Assinante2__r.idDoSignatario__c, Assinante2__r.FirstName, Assinante2__r.LastName,Assinante2__r.Email, Assinante2__r.CPF__c,
                                    Validador__r.idDoSignatario__c, Validador__r.FirstName, Validador__r.LastName, Validador__r.Email, Validador__r.CPF__c,
                                    Validador2__r.idDoSignatario__c, Validador2__r.FirstName, Validador2__r.LastName, Validador2__r.Email, Validador2__r.CPF__c
                                    FROM Demonstracao__c 
                                    WHERE ID =: idContrato];
        
        contact signatario = [SELECT idDoSignatario__c FROM Contact WHERE ID =: contrato.Contato__c];
        
        Contact testemunha = [SELECT idDoSignatario__c FROM Contact WHERE ID =: contrato.Testemunha__c];       
        
        string idSignatario = signatario.idDoSignatario__c;
        string idSignatarioTest = contrato.Testemunha__r.idDoSignatario__c;
        
        Tokens_Clicksign__mdt financeiro = [SELECT DeveloperName, Token__c FROM Tokens_Clicksign__mdt WHERE DeveloperName ='Financeiro'];
        Tokens_Clicksign__mdt adm = [SELECT DeveloperName, Token__c FROM Tokens_Clicksign__mdt WHERE DeveloperName ='Adm'];
        Tokens_Clicksign__mdt geral = [SELECT DeveloperName, Token__c FROM Tokens_Clicksign__mdt WHERE DeveloperName ='Geral'];
        Tokens_Clicksign__mdt juridico = [SELECT DeveloperName, Token__c FROM Tokens_Clicksign__mdt WHERE DeveloperName ='Juridico'];
        
        string idSignatarioFinanceiro = financeiro.Token__c;
        string idSignatarioAdm = adm.Token__c;
        string idSignatarioJuridico = juridico.Token__c;
        string token = geral.Token__c;
        string idSignatarioAssinante2;
        string idSignatarioValidador;
        string idSignatarioValidador2;
        string cpfTestemunha;
        
        string l0g = '';
        
        HttpRequest req = new HttpRequest();
        PageReference pdf;
        
        pdf = Page.ContratoComodato;
        
        pdf.getParameters().put('id', idContrato);
        
        Blob pdfBody;
        String base64PDF;
        
        if (!Test.IsRunningTest()){
            pdfBody = pdf.getContentAsPDF();
            base64PDF = EncodingUtil.base64Encode(pdfBody);
        }
        else{
            pdfBody = Blob.valueOf('Teste');
            base64PDF = 'TESTE';
        }
        
        dateTime agora = system.now();
        
        String nomeDoDocumento  = 'Contrato de Comodato ' + contrato.Name;
        
        
        req.setMethod('POST');
        req.setEndpoint('http://oldsite.hospcom.net:21220/clickSign');
        req.setHeader('Content','{"document":{"path": "/' + nomeDoDocumento + '.pdf","content_base64": "data:application/pdf;base64,%","locale": "pt-BR","sequence_enabled": true}}');
        req.setTimeout(120000);
        req.setBody(base64PDF);
        
        //system.debug(req.getBody());
        
        //system.debug('base64:::::' + req.getBody());
        
        HttpResponse resp = new HttpResponse();
        
        resp = new Http().send(req);
        
        system.debug(resp.getBody());
        
        string keyid = resp.getBody();
        
        l0g = 'ID do Documento: ' + keyid +
            + '\n \n Requisição de envio para o Servidor: ' + req;
        
        if(contrato.Testemunha__r.AccountId == '001i00000085QYbAAM'){
            Dados_colaborador__c dados = [SELECT CPF__c FROM Dados_colaborador__c WHERE Contato__c =: contrato.Testemunha__c];
            cpfTestemunha = dados.CPF__c;
        }
        else{
            cpfTestemunha = contrato.Testemunha__r.CPF__c;
        }
        
        if(resp.getStatusCode() == 200){
            if(!keyId.contains('error')){
                
                Autentique__c doc = new Autentique__c(idDocAutentique__c = keyid, Nome_do_Documento__c = nomeDoDocumento);
                
                contrato.idDocAutentique__c = keyid;
                contrato.Fase__c = '1';
                //Requisição para criar o signatário no Clicksign caso ele ainda não tenha
                if(idSignatario == null){
                    string body = '{' +
                        +'"signer": { ' +
                        +'"email": "'+ contrato.Contato__r.Email +'", '+
                        +'"auths": [ ' +
                        +'"email" ' +
                        +'], '+
                        +'"name": "'+ contrato.Contato__r.Firstname + ' ' + contrato.Contato__r.LastName +'",' +
                        +'"documentation": "'+ contrato.Contato__r.CPF__c +'",' +
                        +'"has_documentation": true,' +
                        +'"selfie_enabled": false,'+
                        +'"handwritten_enabled": false,'+
                        +'"official_document_enabled": false,' +
                        +'"liveness_enabled": false,'+
                        +'"facial_biometrics_enabled": false'+
                        +'}'+
                        +'}';
                    
                    HttpRequest req2 = new HttpRequest();
                    req2.setMethod('POST');
                    req2.setEndpoint('https://app.clicksign.com/api/v1/signers?access_token='+ token);
                    req2.setHeader('Content-Type', 'application/json');
                    //req.setTimeout(120000);
                    req2.setBody(body);
                    HttpResponse respost = new HttpResponse();
                    
                    respost = new Http().send(req2);
                    
                    l0g = l0g + ' resposta requisicao criar assinador: ' + respost.getBody();
                    
                    idSignatario = respost.getBody().substringAfter('"key":"').substringBefore('",'); //salvar id do signatário novo
                    
                    l0g = l0g + '\n ID DO NOVO SIGNATARIO ADICIONADO:: ' + idSignatario;
                    
                }
                
                //Requisição para adicionar o signatário ao documento
                string body3 = '{"list": {"document_key": "'+ keyid +'",'+
                    +'"signer_key": "'+ idSignatario +'",'+
                    +'"sign_as": "party",'+
                    +'"refusable": true,'+
                    +'"group": 1,'+
                    +'"message": "Prezado,\nPor favor assine o documento.\n\nQualquer dúvida estamos à disposição.\n\nAtenciosamente, \nHOSPCOM"}}';
                
                HttpRequest req3 = new HttpRequest();
                req3.setMethod('POST');
                req3.setEndpoint('https://app.clicksign.com/api/v1/lists?access_token=' + token);
                req3.setHeader('Content-Type', 'application/json');
                //req.setTimeout(120000);
                req3.setBody(body3);
                HttpResponse respost3 = new HttpResponse();
                
                respost3 = new Http().send(req3);
                
                l0g = l0g + '\n resposta requisicao adicionar assinador: ' + respost3.getBody();
                
                string idAssinatura = respost3.getBody().substringAfter('request_signature_key":"').substringBefore('","document'); 
                
                //Requisição para enviar notificação para o assinador
                
                string body4 = '{'+
                    +'"request_signature_key": "'+ idAssinatura +'",'+
                    +'"message": "Prezado,\nPor favor assine o documento.\n\nQualquer dúvida estou à disposição.\n\nAtenciosamente,\nHOSPCOM"}';
                
                HttpRequest req4 = new HttpRequest();
                req4.setMethod('POST');
                req4.setEndpoint('https://app.clicksign.com/api/v1/notifications?access_token=' + token);
                req4.setHeader('Content-Type', 'application/json');
                //req.setTimeout(120000);
                req4.setBody(body4);
                HttpResponse respost4 = new HttpResponse();
                
                respost4 = new Http().send(req4);
                
                l0g = l0g + '\n resposta requisicao notificar assinador: ' + respost4.getStatus();
                
                //Testemunha
                
                if(idSignatarioTest == null){
                    string bodyTest = '{' +
                        +'"signer": { ' +
                        +'"email": "'+ contrato.Testemunha__r.Email +'", '+
                        +'"auths": [ ' +
                        +'"email" ' +
                        +'], '+
                        +'"name": "'+ contrato.Testemunha__r.Firstname + ' ' + contrato.Testemunha__r.LastName +'",' +
                        +'"documentation": "'+ cpfTestemunha +'",' +
                        +'"has_documentation": true,' +
                        +'"selfie_enabled": false,'+
                        +'"handwritten_enabled": false,'+
                        +'"official_document_enabled": false,' +
                        +'"liveness_enabled": false,'+
                        +'"facial_biometrics_enabled": false'+
                        +'}'+
                        +'}';
                    
                    HttpRequest reqTest = new HttpRequest();
                    reqTest.setMethod('POST');
                    reqTest.setEndpoint('https://app.clicksign.com/api/v1/signers?access_token=' + token);
                    reqTest.setHeader('Content-Type', 'application/json');
                    //req.setTimeout(120000);
                    reqTest.setBody(bodyTest);
                    HttpResponse resposTest = new HttpResponse();
                    
                    resposTest = new Http().send(reqTest);
                    
                    l0g = l0g + '\n resposta requisicao criar testemunha: ' + resposTest.getBody();
                    
                    idSignatarioTest = resposTest.getBody().substringAfter('"key":"').substringBefore('",'); //salvar id do signatário novo
                    
                    
                    l0g = l0g + '\n ID DO NOVO TESTEMUNHA ADICIONADO:: ' + idSignatarioTest;                    
                    
                }
                
                //Requisição para adicionar a testemunha ao documento
                string bodyTest2 = '{"list": {"document_key": "'+ keyid +'",'+
                    +'"signer_key": "'+ idSignatarioTest +'",'+
                    +'"sign_as": "witness",'+
                    +'"refusable": true,'+
                    +'"group": 1,'+
                    +'"message": "Prezado,\nPor favor assine o documento.\n\nQualquer dúvida estamos à disposição.\n\nAtenciosamente, \nHOSPCOM"}}';
                
                HttpRequest reqTest2 = new HttpRequest();
                reqTest2.setMethod('POST');
                reqTest2.setEndpoint('https://app.clicksign.com/api/v1/lists?access_token=' + token);
                reqTest2.setHeader('Content-Type', 'application/json');
                //req.setTimeout(120000);
                reqTest2.setBody(bodyTest2);
                HttpResponse resposTest2 = new HttpResponse();
                
                resposTest2 = new Http().send(reqTest2);
                
                l0g = l0g + '\n resposta requisicao adicionar testemunha: ' + resposTest2.getBody();
                
                string idAssinaturaTest = resposTest2.getBody().substringAfter('request_signature_key":"').substringBefore('","document');                                       
                
                //Requisição para enviar notificação para a testemunha
                
                string bodyTest3 = '{'+
                    +'"request_signature_key": "'+ idAssinaturaTest +'",'+
                    +'"message": "Prezado,\nPor favor assine o documento.\n\nQualquer dúvida estou à disposição.\n\nAtenciosamente,\nHOSPCOM"}';
                
                HttpRequest reqTest3 = new HttpRequest();
                reqTest3.setMethod('POST');
                reqTest3.setEndpoint('https://app.clicksign.com/api/v1/notifications?access_token=' + token);
                reqTest3.setHeader('Content-Type', 'application/json');
                //req.setTimeout(120000);
                reqTest3.setBody(bodyTest3);
                HttpResponse resposTest3 = new HttpResponse();
                
                resposTest3 = new Http().send(reqTest3);
                
                l0g = l0g + '\n resposta requisicao notificar testemunha: ' + resposTest3.getStatus();
                
                
                //Adicionar o Assinante 2
                if(contrato.Assinante2__c != null){
                    string bodyAssin;
                    bodyAssin = '{' +
                        +'"signer": { ' +
                        +'"email": "'+ contrato.Assinante2__r.Email +'", '+
                        +'"auths": [ ' +
                        +'"email" ' +
                        +'], '+
                        +'"name": "'+ contrato.Assinante2__r.Firstname + ' ' + contrato.Assinante2__r.LastName +'",' +
                        +'"documentation": "'+ contrato.Assinante2__r.CPF__c +'",' +
                        +'"has_documentation": true,' +
                        +'"selfie_enabled": false,'+
                        +'"handwritten_enabled": false,'+
                        +'"official_document_enabled": false,' +
                        +'"liveness_enabled": false,'+
                        +'"facial_biometrics_enabled": false'+
                        +'}'+
                        +'}';
                    
                    
                    HttpRequest reqAssin = new HttpRequest();
                    reqAssin.setMethod('POST');
                    reqAssin.setEndpoint('https://app.clicksign.com/api/v1/signers?access_token='+ token);
                    reqAssin.setHeader('Content-Type', 'application/json');
                    //req.setTimeout(120000);
                    reqAssin.setBody(bodyAssin);
                    HttpResponse respostAssin = new HttpResponse();
                    
                    respostAssin = new Http().send(reqAssin);
                    
                    l0g = l0g + ' resposta requisicao criar assinante 2: ' + respostAssin.getBody();
                    
                    idSignatarioAssinante2 = respostAssin.getBody().substringAfter('"key":"').substringBefore('",'); //salvar id do signatário novo
                    
                    l0g = l0g + '\n ID DO NOVO SIGNATARIO ADICIONADO:: ' + idSignatarioAssinante2;
                    
                    //Requisição para adicionar o assinante2 ao documento
                    string bodyAssin2 = '{"list": {"document_key": "'+ keyid +'",'+
                        +'"signer_key": "'+ idSignatarioAssinante2 +'",'+
                        +'"sign_as": "party",'+
                        +'"refusable": true,'+
                        +'"group": 1,'+
                        +'"message": "Prezado,\nPor favor assine o documento.\n\nQualquer dúvida estamos à disposição.\n\nAtenciosamente, \nHOSPCOM"}}';
                    
                    HttpRequest reqAssin2 = new HttpRequest();
                    reqAssin2.setMethod('POST');
                    reqAssin2.setEndpoint('https://app.clicksign.com/api/v1/lists?access_token=' + token);
                    reqAssin2.setHeader('Content-Type', 'application/json');
                    //req.setTimeout(120000);
                    reqAssin2.setBody(bodyAssin2);
                    HttpResponse respostAssin2 = new HttpResponse();
                    
                    respostAssin2 = new Http().send(reqAssin2);
                    
                    l0g = l0g + '\n resposta requisicao adicionar assinador: ' + respostAssin2.getBody();
                    
                    string idAssinatura2 = respostAssin2.getBody().substringAfter('request_signature_key":"').substringBefore('","document'); 
                    
                    //Requisição para enviar notificação para o assinante2
                    
                    string bodyAssin3 = '{'+
                        +'"request_signature_key": "'+ idAssinatura2 +'",'+
                        +'"message": "Prezado,\nPor favor assine o documento.\n\nQualquer dúvida estou à disposição.\n\nAtenciosamente,\nHOSPCOM"}';
                    
                    HttpRequest reqAssin4 = new HttpRequest();
                    reqAssin4.setMethod('POST');
                    reqAssin4.setEndpoint('https://app.clicksign.com/api/v1/notifications?access_token=' + token);
                    reqAssin4.setHeader('Content-Type', 'application/json');
                    //req.setTimeout(120000);
                    reqAssin4.setBody(body4);
                    HttpResponse respostAssin4 = new HttpResponse();
                    
                    respostAssin4 = new Http().send(reqAssin4);
                    
                    l0g = l0g + '\n resposta requisicao notificar assinante 2: ' + respostAssin4.getStatus();
                }
                
                //Adicionar o Validador
                if(contrato.Validador__c != null){
                    string bodyValidador;
                    bodyValidador = '{' +
                        +'"signer": { ' +
                        +'"email": "'+ contrato.Validador__r.Email +'", '+
                        +'"auths": [ ' +
                        +'"email" ' +
                        +'], '+
                        +'"name": "'+ contrato.Validador__r.Firstname + ' ' + contrato.Validador__r.LastName +'",' +
                        +'"documentation": "'+ contrato.Validador__r.CPF__c +'",' +
                        +'"has_documentation": true,' +
                        +'"selfie_enabled": false,'+
                        +'"handwritten_enabled": false,'+
                        +'"official_document_enabled": false,' +
                        +'"liveness_enabled": false,'+
                        +'"facial_biometrics_enabled": false'+
                        +'}'+
                        +'}';
                    
                    HttpRequest reqValidador = new HttpRequest();
                    reqValidador.setMethod('POST');
                    reqValidador.setEndpoint('https://app.clicksign.com/api/v1/signers?access_token='+ token);
                    reqValidador.setHeader('Content-Type', 'application/json');
                    //req.setTimeout(120000);
                    reqValidador.setBody(bodyValidador);
                    HttpResponse respostValidador = new HttpResponse();
                    
                    respostValidador = new Http().send(reqValidador);
                    
                    l0g = l0g + ' resposta requisicao criar validador: ' + respostValidador.getBody();
                    
                    idSignatarioValidador = respostValidador.getBody().substringAfter('"key":"').substringBefore('",'); //salvar id do signatário novo
                    
                    l0g = l0g + '\n ID DO NOVO VALIDADOR ADICIONADO:: ' + idSignatarioValidador;
                    
                    //Requisição para adicionar o validador ao documento
                    string bodyValidador_2 = '{"list": {"document_key": "'+ keyid +'",'+
                        +'"signer_key": "'+ idSignatarioValidador +'",'+
                        +'"sign_as": "validator",'+
                        +'"refusable": true,'+
                        +'"group": 1,'+
                        +'"message": "Prezado,\nPor favor assine o documento.\n\nQualquer dúvida estamos à disposição.\n\nAtenciosamente, \nHOSPCOM"}}';
                    
                    HttpRequest reqValidador_2 = new HttpRequest();
                    reqValidador_2.setMethod('POST');
                    reqValidador_2.setEndpoint('https://app.clicksign.com/api/v1/lists?access_token=' + token);
                    reqValidador_2.setHeader('Content-Type', 'application/json');
                    //req.setTimeout(120000);
                    reqValidador_2.setBody(bodyValidador_2);
                    HttpResponse respostValidador_2 = new HttpResponse();
                    
                    respostValidador_2 = new Http().send(reqValidador_2);
                    
                    l0g = l0g + '\n resposta requisicao adicionar assinador: ' + respostValidador_2.getBody();
                    
                    string idValidador = respostValidador_2.getBody().substringAfter('request_signature_key":"').substringBefore('","document'); 
                    
                    //Requisição para enviar notificação para o validador
                    
                    string bodyValidador_3 = '{'+
                        +'"request_signature_key": "'+ idValidador +'",'+
                        +'"message": "Prezado,\nPor favor assine o documento.\n\nQualquer dúvida estou à disposição.\n\nAtenciosamente,\nHOSPCOM"}';
                    
                    HttpRequest reqValidador_3 = new HttpRequest();
                    reqValidador_3.setMethod('POST');
                    reqValidador_3.setEndpoint('https://app.clicksign.com/api/v1/notifications?access_token=' + token);
                    reqValidador_3.setHeader('Content-Type', 'application/json');
                    //req.setTimeout(120000);
                    reqValidador_3.setBody(bodyValidador_3);
                    HttpResponse respostValidador_3 = new HttpResponse();
                    
                    respostValidador_3 = new Http().send(reqValidador_3);
                    
                    l0g = l0g + '\n resposta requisicao notificar validador: ' + respostValidador_3.getStatus();
                }
                //Adicionar o Validador 2
                if(contrato.Validador2__c != null){
                    string bodyValidador2;
                    bodyValidador2 = '{' +
                        +'"signer": { ' +
                        +'"email": "'+ contrato.Validador2__r.Email +'", '+
                        +'"auths": [ ' +
                        +'"email" ' +
                        +'], '+
                        +'"name": "'+ contrato.Validador2__r.Firstname + ' ' + contrato.Validador2__r.LastName +'",' +
                        +'"documentation": "'+ contrato.Validador2__r.CPF__c +'",' +
                        +'"has_documentation": true,' +
                        +'"selfie_enabled": false,'+
                        +'"handwritten_enabled": false,'+
                        +'"official_document_enabled": false,' +
                        +'"liveness_enabled": false,'+
                        +'"facial_biometrics_enabled": false'+
                        +'}'+
                        +'}';
                    
                    HttpRequest reqValidador2 = new HttpRequest();
                    reqValidador2.setMethod('POST');
                    reqValidador2.setEndpoint('https://app.clicksign.com/api/v1/signers?access_token='+ token);
                    reqValidador2.setHeader('Content-Type', 'application/json');
                    //req.setTimeout(120000);
                    reqValidador2.setBody(bodyValidador2);
                    HttpResponse respostValidador2 = new HttpResponse();
                    
                    respostValidador2 = new Http().send(reqValidador2);
                    
                    l0g = l0g + ' resposta requisicao criar validador 2: ' + respostValidador2.getBody();
                    
                    idSignatarioValidador2 = respostValidador2.getBody().substringAfter('"key":"').substringBefore('",'); //salvar id do signatário novo
                    
                    l0g = l0g + '\n ID DO NOVO VALIDADOR 2 ADICIONADO:: ' + idSignatarioValidador2;
                    
                    //Requisição para adicionar o validador 2 ao documento
                    string bodyValidador2_2 = '{"list": {"document_key": "'+ keyid +'",'+
                        +'"signer_key": "'+ idSignatarioValidador2 +'",'+
                        +'"sign_as": "validator",'+
                        +'"refusable": true,'+
                        +'"group": 1,'+
                        +'"message": "Prezado,\nPor favor assine o documento.\n\nQualquer dúvida estamos à disposição.\n\nAtenciosamente, \nHOSPCOM"}}';
                    
                    HttpRequest reqValidador2_2 = new HttpRequest();
                    reqValidador2_2.setMethod('POST');
                    reqValidador2_2.setEndpoint('https://app.clicksign.com/api/v1/lists?access_token=' + token);
                    reqValidador2_2.setHeader('Content-Type', 'application/json');
                    //req.setTimeout(120000);
                    reqValidador2_2.setBody(bodyValidador2_2);
                    HttpResponse respostValidador2_2 = new HttpResponse();
                    
                    respostValidador2_2 = new Http().send(reqValidador2_2);
                    
                    l0g = l0g + '\n resposta requisicao adicionar validador 2: ' + respostValidador2_2.getBody();
                    
                    string idValidador2 = respostValidador2_2.getBody().substringAfter('request_signature_key":"').substringBefore('","document'); 
                    
                    //Requisição para enviar notificação para o validador 2
                    
                    string bodyValidador2_3 = '{'+
                        +'"request_signature_key": "'+ idValidador2 +'",'+
                        +'"message": "Prezado,\nPor favor assine o documento.\n\nQualquer dúvida estou à disposição.\n\nAtenciosamente,\nHOSPCOM"}';
                    
                    HttpRequest reqValidador2_3 = new HttpRequest();
                    reqValidador2_3.setMethod('POST');
                    reqValidador2_3.setEndpoint('https://app.clicksign.com/api/v1/notifications?access_token=' + token);
                    reqValidador2_3.setHeader('Content-Type', 'application/json');
                    //req.setTimeout(120000);
                    reqValidador2_3.setBody(bodyValidador2_3);
                    HttpResponse respostValidador2_3 = new HttpResponse();
                    
                    respostValidador2_3 = new Http().send(reqValidador2_3);
                    
                    l0g = l0g + '\n resposta requisicao notificar validador 2: ' + respostValidador2_3.getStatus();
                }
                
                //Adicionar o financeiro no processo de assinatura
                string bodyFinanceiro = '{"list": {"document_key": "'+ keyid +'",'+
                    +'"signer_key": "'+ idSignatarioFinanceiro +'",'+
                    +'"sign_as": "witness",'+
                    +'"refusable": true,'+
                    +'"group": 2,'+
                    +'"message": "Prezado,\nPor favor assine o documento.\n\nQualquer dúvida estamos à disposição.\n\nAtenciosamente, \nHOSPCOM"}}';
                
                HttpRequest reqFinanceiro = new HttpRequest();
                reqFinanceiro.setMethod('POST');
                reqFinanceiro.setEndpoint('https://app.clicksign.com/api/v1/lists?access_token=' + token);
                reqFinanceiro.setHeader('Content-Type', 'application/json');
                //req.setTimeout(120000);
                reqFinanceiro.setBody(bodyFinanceiro);
                HttpResponse resposFinanceiro = new HttpResponse();
                
                resposFinanceiro = new Http().send(reqFinanceiro);
                
                l0g = l0g + '\n resposta requisicao adicionar Financeiro: ' + resposFinanceiro.getBody();
                
                string idAssinaturaFinanceiro = resposFinanceiro.getBody().substringAfter('request_signature_key":"').substringBefore('","document');
                
                //Adicionar o jurídico no processo de assinatura
                string bodyJuridico = '{"list": {"document_key": "'+ keyid +'",'+
                    +'"signer_key": "'+ idSignatarioJuridico +'",'+
                    +'"sign_as": "witness",'+
                    +'"refusable": true,'+
                    +'"group": 3,'+
                    +'"message": "Prezado,\nPor favor assine o documento.\n\nQualquer dúvida estamos à disposição.\n\nAtenciosamente, \nHOSPCOM"}}';
                
                HttpRequest reqJuridico = new HttpRequest();
                reqJuridico.setMethod('POST');
                reqJuridico.setEndpoint('https://app.clicksign.com/api/v1/lists?access_token=' + token);
                reqJuridico.setHeader('Content-Type', 'application/json');
                //req.setTimeout(120000);
                reqJuridico.setBody(bodyJuridico);
                HttpResponse resposJuridico = new HttpResponse();
                
                resposJuridico = new Http().send(reqJuridico);
                
                l0g = l0g + '\n resposta requisicao adicionar juridico: ' + resposJuridico.getBody();
                
                string idAssinaturaJuridico = resposJuridico.getBody().substringAfter('request_signature_key":"').substringBefore('","document');
                
                //Adicionar o administrativo no processo de assinatura
                string bodyAdm = '{"list": {"document_key": "'+ keyid +'",'+
                    +'"signer_key": "'+ idSignatarioAdm +'",'+
                    +'"sign_as": "party",'+
                    +'"refusable": true,'+
                    +'"group": 3,'+
                    +'"message": "Prezado,\nPor favor assine o documento.\n\nQualquer dúvida estamos à disposição.\n\nAtenciosamente, \nHOSPCOM"}}';
                
                HttpRequest reqAdm = new HttpRequest();
                reqAdm.setMethod('POST');
                reqAdm.setEndpoint('https://app.clicksign.com/api/v1/lists?access_token=' + token);
                reqAdm.setHeader('Content-Type', 'application/json');
                //req.setTimeout(120000);
                reqAdm.setBody(bodyAdm);
                HttpResponse resposAdm = new HttpResponse();
                
                resposAdm = new Http().send(reqAdm);
                
                l0g = l0g + '\n resposta requisicao adicionar adm: ' + resposAdm.getBody();
                
                string idAssinaturaAdm = resposAdm.getBody().substringAfter('request_signature_key":"').substringBefore('","document');
                
                
                try{
                    update contrato;
                    signatario.idDoSignatario__c = idSignatario;
                    update signatario;
                    testemunha.idDoSignatario__c = idSignatarioTest;
                    update testemunha;
                    insert doc;
                }
                catch(DmlException e){
                    if(!Test.isRunningTest())
                        throw new AuraHandledException(e.getMessage());
                }
                
                
                //Cria e carrega um documento com as informações para o log
                Document logDoc = new Document(
                    Name = String.valueOf(System.Now().format('yyyy/MM/dd HH:mm:ss')) + ' - Contrato de Demo/Comodato: ' + contrato.Name,
                    Body = Blob.valueOf(l0g),
                    ContentType = 'text/plain',
                    Type = 'txt',
                    IsPublic = false,
                    IsInternalUseOnly = true,
                    FolderId = '00l6e000002JcWd'        
                );
                insert logDoc;
            }
            else{
                throw new AuraHandledException('Erro de envio, forneça as seguintes informações para o suporte: ' + 'StatusCode: ' + resp.getStatusCode() + '; ResponseBody: ' + resp.getBody() + '');  
            }
        }  
        else{
            throw new AuraHandledException('Erro de envio, forneça as seguintes informações para o suporte: ' + 'StatusCode: ' + resp.getStatusCode() + '; ResponseBody: ' + resp.getBody() + '');  
        }
    }
    @AuraEnabled
    public static void cancelarComodato(string idContrato){
        
        Tokens_Clicksign__mdt geral = [SELECT DeveloperName, Token__c FROM Tokens_Clicksign__mdt WHERE DeveloperName ='Geral'];
        
        string token = geral.Token__c;
        
        Demonstracao__c contrato = [SELECT ID, idDocAutentique__c
                                    FROM Demonstracao__c 
                                    WHERE ID =: idContrato];
        
        
        HttpRequest cancela = new HttpRequest();
        cancela.setMethod('PATCH');
        cancela.setEndpoint('https://app.clicksign.com/api/v1/documents/'+ contrato.idDocAutentique__c +'/cancel?access_token=' + token);
        cancela.setHeader('Content-Type', 'application/json');
        cancela.setHeader('Accept', 'application/json');
        
        HttpResponse rCancela = new HttpResponse();
        rCancela = new Http().send(cancela);
        
        
        system.debug(rCancela.getBody());
        Integer statusCode = rCancela.getStatusCode();
        
        if(statusCode == 200){
            contrato.Fase__c = 'Cancelado';
            contrato.idDocAutentique__c = '';
            update contrato;
            
        }
        else{
            throw new AuraHandledException('Erro de cancelamento, forneça as seguintes informações para o suporte: ' + 'StatusCode: ' + statusCode + '; ResponseBody: ' + rCancela.getBody() + '');  
        }
    }
    @AuraEnabled
    public static string consultarComodato(string idContrato){
        
        Tokens_Clicksign__mdt geral = [SELECT DeveloperName, Token__c FROM Tokens_Clicksign__mdt WHERE DeveloperName ='Geral'];
        
        string token = geral.Token__c;
        
        Demonstracao__c contrato = [SELECT ID, idDocAutentique__c
                                    FROM Demonstracao__c 
                                    WHERE ID =: idContrato];
        
        string cancelamento = 'Documento consultado as ' ;
        string cancelamento2 = 'Documento consultado as ' ;
        string cancelamento3 = 'Documento consultado as ' ;
        
        HttpRequest consulta = new HttpRequest();
        consulta.setMethod('GET');
        consulta.setEndpoint('https://app.clicksign.com/api/v1/documents/'+ contrato.idDocAutentique__c +'?access_token=' + token);
        consulta.setHeader('Content-Type', 'application/json');
        consulta.setHeader('Accept', 'application/json');
        //req.setTimeout(120000);
        HttpResponse rConsulta = new HttpResponse();
        rConsulta = new Http().send(consulta);
        
        return rConsulta.getBody();  
    }   
    //Parte do contrato de compra
    @AuraEnabled
    public static void enviarCompra(string idContrato, boolean proprio){
        
        Contrato_de_compra__c contrato = [SELECT ID, Name, Assinante__c, Testemunha__c, Fase__c, Testemunha__r.FirstName, Testemunha__r.LastName, Testemunha__r.Email, Testemunha__r.CPF__c, Testemunha__r.AccountId,
                                          Fornecedor__r.Raz_o_Social__c, Tipo_de_contrato__c
                                          FROM Contrato_de_compra__c 
                                          WHERE ID =: idContrato];
        
        contact signatario = [SELECT Id, Email, FirstName, LastName, CPF__c FROM Contact WHERE ID =: contrato.Assinante__c];
        
        string idSignatario;
        string idSignatarioTest;
        string cpfTestemunha;
        
        Tokens_Clicksign__mdt geral = [SELECT DeveloperName, Token__c FROM Tokens_Clicksign__mdt WHERE DeveloperName ='Geral'];
        Tokens_Clicksign__mdt juridico = [SELECT DeveloperName, Token__c FROM Tokens_Clicksign__mdt WHERE DeveloperName ='Juridico_2'];
        Tokens_Clicksign__mdt adm = [SELECT DeveloperName, Token__c FROM Tokens_Clicksign__mdt WHERE DeveloperName ='Adm'];
        
        String idSignatarioJuridico = juridico.Token__c;
        String idSignatarioAdm = adm.Token__c;
        
        string token = geral.Token__c;
        
        string l0g = '';
        
        HttpRequest req = new HttpRequest();
        
        PageReference pdf = Page.Contrato_de_compra;
        pdf.getParameters().put('id', idContrato);
        
        Blob pdfBody;
        String base64PDF;
        
        if (!Test.IsRunningTest()){
            pdfBody = pdf.getContentAsPDF();
            if(proprio == false){
                base64PDF = FileUploadController.bs64ContratosExternos(idContrato);
            }
            else{
                base64PDF = EncodingUtil.base64Encode(pdfBody);                
            }
        }
        else{
            pdfBody = Blob.valueOf('Teste');
            base64PDF = 'TESTE';
        }
        
        
        dateTime agora = system.now();
        
        String nomeDoDocumento = 'Contrato de ' + contrato.Tipo_de_contrato__c + ' ' + contrato.Fornecedor__r.Raz_o_Social__c + ' ' + contrato.Name;
        
        req.setMethod('POST');
        req.setEndpoint('http://oldsite.hospcom.net:21220/clickSign');
        req.setHeader('Content','{"document":{"path": "/' + nomeDoDocumento + '.pdf","content_base64": "data:application/pdf;base64,%","locale": "pt-BR","sequence_enabled": true}}');
        req.setTimeout(120000);
        req.setBody(base64PDF);
        
        HttpResponse resp = new HttpResponse();
        
        resp = new Http().send(req);
        
        system.debug(resp.getBody());
        
        string keyid = resp.getBody();
        
        l0g = 'ID do Documento: ' + keyid +
            + '\n \n Requisição de envio para o Servidor' + req;
        
        if(contrato.Testemunha__r.AccountId == '001i00000085QYbAAM'){
            Dados_colaborador__c dados = [SELECT CPF__c FROM Dados_colaborador__c WHERE Contato__c =: contrato.Testemunha__c];
            cpfTestemunha = dados.CPF__c;
        }
        else{
            cpfTestemunha = contrato.Testemunha__r.CPF__c;
        }
        
        if(resp.getStatusCode() == 200){
            if(!keyId.contains('error')){
                
                Autentique__c doc = new Autentique__c(idDocAutentique__c = keyid, Nome_do_Documento__c = nomeDoDocumento);
                
                contrato.idDocAutentique__c = keyid;
                contrato.Fase__c = '1';
                
                //Adicionar o juridico no processo de assinatura
                string bodyJuridico = '{"list": {"document_key": "'+ keyid +'",'+
                    +'"signer_key": "'+ idSignatarioJuridico +'",'+
                    +'"sign_as": "witness",'+
                    +'"refusable": true,'+
                    +'"group": 1,'+
                    +'"message": "Prezado,\nPor favor assine o documento.\n\nQualquer dúvida estamos à disposição.\n\nAtenciosamente, \nHOSPCOM"}}';
                
                HttpRequest reqJuridico = new HttpRequest();
                reqJuridico.setMethod('POST');
                reqJuridico.setEndpoint('https://app.clicksign.com/api/v1/lists?access_token=' + token);
                reqJuridico.setHeader('Content-Type', 'application/json');
                //req.setTimeout(120000);
                reqJuridico.setBody(bodyJuridico);
                HttpResponse resposJuridico = new HttpResponse();
                
                resposJuridico = new Http().send(reqJuridico);
                
                l0g = l0g + '\n resposta requisicao adicionar juridico: ' + resposJuridico.getBody();
                
                string idAssinaturaJuridico = resposJuridico.getBody().substringAfter('request_signature_key":"').substringBefore('","document');
                
                
                //Requisição para criar o signatário no Clicksign caso ele ainda não tenha
                string body = '{' +
                    +'"signer": { ' +
                    +'"email": "'+ signatario.Email +'", '+
                    +'"auths": [ ' +
                    +'"email" ' +
                    +'], '+
                    +'"name": "'+ signatario.Firstname + ' ' + signatario.LastName +'",' +
                    +'"documentation": "'+ signatario.CPF__c +'",' +
                    +'"has_documentation": true,' +
                    +'"selfie_enabled": true,'+
                    +'"handwritten_enabled": false,'+
                    +'"official_document_enabled": false,' +
                    +'"liveness_enabled": false,'+
                    +'"facial_biometrics_enabled": false'+
                    +'}'+
                    +'}';
                
                HttpRequest req2 = new HttpRequest();
                req2.setMethod('POST');
                req2.setEndpoint('https://app.clicksign.com/api/v1/signers?access_token='+ token);
                req2.setHeader('Content-Type', 'application/json');
                //req.setTimeout(120000);
                req2.setBody(body);
                HttpResponse respost = new HttpResponse();
                
                respost = new Http().send(req2);
                
                l0g = l0g + ' resposta requisicao criar assinador: ' + respost.getBody();
                
                idSignatario = respost.getBody().substringAfter('"key":"').substringBefore('",'); //salvar id do signatário novo
                
                l0g = l0g + '\n ID DO NOVO SIGNATARIO ADICIONADO:: ' + idSignatario;
                
                //Requisição para adicionar o signatário ao documento
                string body3 = '{"list": {"document_key": "'+ keyid +'",'+
                    +'"signer_key": "'+ idSignatario +'",'+
                    +'"sign_as": "party",'+
                    +'"refusable": true,'+
                    +'"group": 2,'+
                    +'"message": "Prezado,\nPor favor assine o documento.\n\nQualquer dúvida estamos à disposição.\n\nAtenciosamente, \nHOSPCOM"}}';
                
                HttpRequest req3 = new HttpRequest();
                req3.setMethod('POST');
                req3.setEndpoint('https://app.clicksign.com/api/v1/lists?access_token=' + token);
                req3.setHeader('Content-Type', 'application/json');
                //req.setTimeout(120000);
                req3.setBody(body3);
                HttpResponse respost3 = new HttpResponse();
                
                respost3 = new Http().send(req3);
                
                l0g = l0g + '\n resposta requisicao adicionar assinador: ' + respost3.getBody();
                
                string idAssinatura = respost3.getBody().substringAfter('request_signature_key":"').substringBefore('","document'); 
                
                //Requisição para enviar notificação para o assinador
                
                string body4 = '{'+
                    +'"request_signature_key": "'+ idAssinatura +'",'+
                    +'"message": "Prezado,\nPor favor assine o documento.\n\nQualquer dúvida estou à disposição.\n\nAtenciosamente,\nHOSPCOM"}';
                
                HttpRequest req4 = new HttpRequest();
                req4.setMethod('POST');
                req4.setEndpoint('https://app.clicksign.com/api/v1/notifications?access_token=' + token);
                req4.setHeader('Content-Type', 'application/json');
                //req.setTimeout(120000);
                req4.setBody(body4);
                HttpResponse respost4 = new HttpResponse();
                
                respost4 = new Http().send(req4);
                
                l0g = l0g + '\n resposta requisicao notificar assinador: ' + respost4.getStatus();
                
                
                //Testemunha
                
                string bodyTest = '{' +
                    +'"signer": { ' +
                    +'"email": "'+ contrato.Testemunha__r.Email +'", '+
                    +'"auths": [ ' +
                    +'"email" ' +
                    +'], '+
                    +'"name": "'+ contrato.Testemunha__r.Firstname + ' ' + contrato.Testemunha__r.LastName +'",' +
                    +'"documentation": "'+ cpfTestemunha +'",' +
                    +'"has_documentation": true,' +
                    +'"selfie_enabled": false,'+
                    +'"handwritten_enabled": false,'+
                    +'"official_document_enabled": false,' +
                    +'"liveness_enabled": false,'+
                    +'"facial_biometrics_enabled": false'+
                    +'}'+
                    +'}';
                
                HttpRequest reqTest = new HttpRequest();
                reqTest.setMethod('POST');
                reqTest.setEndpoint('https://app.clicksign.com/api/v1/signers?access_token=' + token);
                reqTest.setHeader('Content-Type', 'application/json');
                //req.setTimeout(120000);
                reqTest.setBody(bodyTest);
                HttpResponse resposTest = new HttpResponse();
                
                resposTest = new Http().send(reqTest);
                
                l0g = l0g + '\n resposta requisicao criar testemunha: ' + resposTest.getBody();
                
                idSignatarioTest = resposTest.getBody().substringAfter('"key":"').substringBefore('",'); //salvar id do signatário novo
                
                
                l0g = l0g + '\n ID DO NOVO TESTEMUNHA ADICIONADO:: ' + idSignatarioTest;                    
                
                //Requisição para adicionar a testemunha ao documento
                string bodyTest2 = '{"list": {"document_key": "'+ keyid +'",'+
                    +'"signer_key": "'+ idSignatarioTest +'",'+
                    +'"sign_as": "witness",'+
                    +'"refusable": true,'+
                    +'"group": 2,'+
                    +'"message": "Prezado,\nPor favor assine o documento.\n\nQualquer dúvida estamos à disposição.\n\nAtenciosamente, \nHOSPCOM"}}';
                
                HttpRequest reqTest2 = new HttpRequest();
                reqTest2.setMethod('POST');
                reqTest2.setEndpoint('https://app.clicksign.com/api/v1/lists?access_token=' + token);
                reqTest2.setHeader('Content-Type', 'application/json');
                //req.setTimeout(120000);
                reqTest2.setBody(bodyTest2);
                HttpResponse resposTest2 = new HttpResponse();
                
                resposTest2 = new Http().send(reqTest2);
                
                l0g = l0g + '\n resposta requisicao adicionar testemunha: ' + resposTest2.getBody();
                
                string idAssinaturaTest = resposTest2.getBody().substringAfter('request_signature_key":"').substringBefore('","document');                                       
                
                //Requisição para enviar notificação para a testemunha
                
                string bodyTest3 = '{'+
                    +'"request_signature_key": "'+ idAssinaturaTest +'",'+
                    +'"message": "Prezado,\nPor favor assine o documento.\n\nQualquer dúvida estou à disposição.\n\nAtenciosamente,\nHOSPCOM"}';
                
                HttpRequest reqTest3 = new HttpRequest();
                reqTest3.setMethod('POST');
                reqTest3.setEndpoint('https://app.clicksign.com/api/v1/notifications?access_token=' + token);
                reqTest3.setHeader('Content-Type', 'application/json');
                //req.setTimeout(120000);
                reqTest3.setBody(bodyTest3);
                HttpResponse resposTest3 = new HttpResponse();
                
                resposTest3 = new Http().send(reqTest3);
                
                l0g = l0g + '\n resposta requisicao notificar testemunha: ' + resposTest3.getStatus();
                
                
                
                //Adicionar o administrativo no processo de assinatura
                string bodyAdm = '{"list": {"document_key": "'+ keyid +'",'+
                    +'"signer_key": "'+ idSignatarioAdm +'",'+
                    +'"sign_as": "party",'+
                    +'"refusable": true,'+
                    +'"group": 3,'+
                    +'"message": "Prezado,\nPor favor assine o documento.\n\nQualquer dúvida estamos à disposição.\n\nAtenciosamente, \nHOSPCOM"}}';
                
                HttpRequest reqAdm = new HttpRequest();
                reqAdm.setMethod('POST');
                reqAdm.setEndpoint('https://app.clicksign.com/api/v1/lists?access_token=' + token);
                reqAdm.setHeader('Content-Type', 'application/json');
                //req.setTimeout(120000);
                reqAdm.setBody(bodyAdm);
                HttpResponse resposAdm = new HttpResponse();
                
                resposAdm = new Http().send(reqAdm);
                
                l0g = l0g + '\n resposta requisicao adicionar adm: ' + resposAdm.getBody();
                
                string idAssinaturaAdm = resposAdm.getBody().substringAfter('request_signature_key":"').substringBefore('","document');
                
                
                try{
                    contrato.Status__c = 'Enviado para assinatura';
                    update contrato;
                    insert doc;
                }
                catch(DmlException e){
                    if(!Test.isRunningTest())
                        throw new AuraHandledException(e.getMessage());
                }
                
                
                
                //Cria e carrega um documento com as informações para o log
                Document logDoc = new Document(
                    Name = String.valueOf(System.Now().format('yyyy/MM/dd HH:mm:ss')) + ' - Contrato de compra ' + contrato.Name,
                    Body = Blob.valueOf(l0g),
                    ContentType = 'text/plain',
                    Type = 'txt',
                    IsPublic = false,
                    IsInternalUseOnly = true,
                    FolderId = '00l6e000002JcWd'        
                );
                insert logDoc;
            }
            else{
                throw new AuraHandledException('Erro de envio, forneça as seguintes informações para o suporte: ' + 'StatusCode: ' + resp.getStatusCode() + '; ResponseBody: ' + resp.getBody() + '');  
            }
        }  
        else{
            throw new AuraHandledException('Erro de envio, forneça as seguintes informações para o suporte: ' + 'StatusCode: ' + resp.getStatusCode() + '; ResponseBody: ' + resp.getBody() + '');  
        }
    }
    @AuraEnabled
    public static void cancelarCompra(string idContrato){
        
        Tokens_Clicksign__mdt geral = [SELECT DeveloperName, Token__c FROM Tokens_Clicksign__mdt WHERE DeveloperName ='Geral'];
        
        string token = geral.Token__c;
        
        Contrato_de_compra__c contrato = [SELECT ID, idDocAutentique__c
                                          FROM Contrato_de_compra__c 
                                          WHERE ID =: idContrato];
        
        
        HttpRequest cancela = new HttpRequest();
        cancela.setMethod('PATCH');
        cancela.setEndpoint('https://app.clicksign.com/api/v1/documents/'+ contrato.idDocAutentique__c +'/cancel?access_token=' + token);
        cancela.setHeader('Content-Type', 'application/json');
        cancela.setHeader('Accept', 'application/json');
        
        HttpResponse rCancela = new HttpResponse();
        rCancela = new Http().send(cancela);
        
        
        system.debug(rCancela.getBody());
        Integer statusCode = rCancela.getStatusCode();
        
        if(statusCode == 200){
            contrato.Fase__c = 'Cancelado';
            contrato.idDocAutentique__c = '';
            update contrato;
            
        }
        else{
            throw new AuraHandledException('Erro de cancelamento, forneça as seguintes informações para o suporte: ' + 'StatusCode: ' + statusCode + '; ResponseBody: ' + rCancela.getBody() + '');  
        }
    }
    @AuraEnabled
    public static string consultarCompra(string idContrato){
        
        Tokens_Clicksign__mdt geral = [SELECT DeveloperName, Token__c FROM Tokens_Clicksign__mdt WHERE DeveloperName ='Geral'];
        
        string token = geral.Token__c;
        
        Contrato_de_compra__c contrato = [SELECT ID, idDocAutentique__c
                                          FROM Contrato_de_compra__c 
                                          WHERE ID =: idContrato];
        
        string cancelamento = 'Documento consultado as ' ;
        string cancelamento2 = 'Documento consultado as ' ;
        string cancelamento3 = 'Documento consultado as ' ;
        
        HttpRequest consulta = new HttpRequest();
        consulta.setMethod('GET');
        consulta.setEndpoint('https://app.clicksign.com/api/v1/documents/'+ contrato.idDocAutentique__c +'?access_token=' + token);
        consulta.setHeader('Content-Type', 'application/json');
        consulta.setHeader('Accept', 'application/json');
        //req.setTimeout(120000);
        HttpResponse rConsulta = new HttpResponse();
        rConsulta = new Http().send(consulta);
        
        return rConsulta.getBody();
    }
    //Parte do aditivo do contrato de compra
    @AuraEnabled
    public static void enviarAditivoCompra(string idContrato){
        
        Aditivo_do_Contrato_de_Compra__c contrato = [SELECT ID, Contrato_de_compra__r.Name, Contrato_de_compra__r.Assinante__c, Contrato_de_compra__r.Testemunha__c, Contrato_de_compra__r.Fase__c, Contrato_de_compra__r.Testemunha__r.FirstName, Contrato_de_compra__r.Testemunha__r.LastName, Contrato_de_compra__r.Testemunha__r.Email, Contrato_de_compra__r.Testemunha__r.CPF__c,
                                                     Contrato_de_compra__r.Fornecedor__r.Raz_o_Social__c, Contrato_de_compra__r.Tipo_de_contrato__c, Contrato_de_compra__r.Testemunha__r.AccountId
                                                     FROM Aditivo_do_Contrato_de_Compra__c 
                                                     WHERE ID =: idContrato];
        
        contact signatario = [SELECT Id, Email, FirstName, LastName, CPF__c FROM Contact WHERE ID =: contrato.Contrato_de_compra__r.Assinante__c];
        
        string idSignatario;
        string idSignatarioTest;
        
        Tokens_Clicksign__mdt geral = [SELECT DeveloperName, Token__c FROM Tokens_Clicksign__mdt WHERE DeveloperName ='Geral'];
        Tokens_Clicksign__mdt juridico = [SELECT DeveloperName, Token__c FROM Tokens_Clicksign__mdt WHERE DeveloperName ='Juridico_2'];
        Tokens_Clicksign__mdt adm = [SELECT DeveloperName, Token__c FROM Tokens_Clicksign__mdt WHERE DeveloperName ='Adm'];
        
        String idSignatarioJuridico = juridico.Token__c;
        String idSignatarioAdm = adm.Token__c;
        String cpfTestemunha;
        
        string token = geral.Token__c;
        
        string l0g = '';
        
        HttpRequest req = new HttpRequest();
        
        PageReference pdf = Page.Aditivo_Contrato_Compra;
        pdf.getParameters().put('id', idContrato);
        
        Blob pdfBody;
        String base64PDF;
        
        if (!Test.IsRunningTest()){
            pdfBody = pdf.getContentAsPDF();
            base64PDF = EncodingUtil.base64Encode(pdfBody);
        }
        else{
            pdfBody = Blob.valueOf('Teste');
            base64PDF = 'TESTE';
        }
        
        dateTime agora = system.now();
        
        String nomeDoDocumento = 'Aditivo ao Contrato de ' + contrato.Contrato_de_compra__r.Tipo_de_contrato__c + ' ' + contrato.Contrato_de_compra__r.Fornecedor__r.Raz_o_Social__c + ' ' + contrato.Contrato_de_compra__r.Name;
        
        req.setMethod('POST');
        req.setEndpoint('http://oldsite.hospcom.net:21220/clickSign');
        req.setHeader('Content','{"document":{"path": "/' + nomeDoDocumento + '.pdf","content_base64": "data:application/pdf;base64,%","locale": "pt-BR","sequence_enabled": true}}');
        req.setTimeout(120000);
        req.setBody(base64PDF);
        
        HttpResponse resp = new HttpResponse();
        
        resp = new Http().send(req);
        
        system.debug(resp.getBody());
        
        string keyid = resp.getBody();
        
        l0g = 'ID do Documento: ' + keyid +
            + '\n \n Requisição de envio para o Servidor' + req;
        
        if(contrato.Contrato_de_compra__r.Testemunha__r.AccountId == '001i00000085QYbAAM'){
            Dados_colaborador__c dados = [SELECT CPF__c FROM Dados_colaborador__c WHERE Contato__c =: contrato.Contrato_de_compra__r.Testemunha__c];
            cpfTestemunha = dados.CPF__c;
        }
        else{
            cpfTestemunha = contrato.Contrato_de_compra__r.Testemunha__r.CPF__c;
        }
        
        if(resp.getStatusCode() == 200){
            if(!keyId.contains('error')){
                
                Autentique__c doc = new Autentique__c(idDocAutentique__c = keyid, Nome_do_Documento__c = nomeDoDocumento);
                
                contrato.idDocAutentique__c = keyid;
                contrato.Fase__c = '1';
                
                //Adicionar o juridico no processo de assinatura
                string bodyJuridico = '{"list": {"document_key": "'+ keyid +'",'+
                    +'"signer_key": "'+ idSignatarioJuridico +'",'+
                    +'"sign_as": "witness",'+
                    +'"refusable": true,'+
                    +'"group": 1,'+
                    +'"message": "Prezado,\nPor favor assine o documento.\n\nQualquer dúvida estamos à disposição.\n\nAtenciosamente, \nHOSPCOM"}}';
                
                HttpRequest reqJuridico = new HttpRequest();
                reqJuridico.setMethod('POST');
                reqJuridico.setEndpoint('https://app.clicksign.com/api/v1/lists?access_token=' + token);
                reqJuridico.setHeader('Content-Type', 'application/json');
                //req.setTimeout(120000);
                reqJuridico.setBody(bodyJuridico);
                HttpResponse resposJuridico = new HttpResponse();
                
                resposJuridico = new Http().send(reqJuridico);
                
                l0g = l0g + '\n resposta requisicao adicionar juridico: ' + resposJuridico.getBody();
                
                string idAssinaturaJuridico = resposJuridico.getBody().substringAfter('request_signature_key":"').substringBefore('","document');
                
                
                //Requisição para criar o signatário no Clicksign caso ele ainda não tenha
                string body = '{' +
                    +'"signer": { ' +
                    +'"email": "'+ signatario.Email +'", '+
                    +'"auths": [ ' +
                    +'"email" ' +
                    +'], '+
                    +'"name": "'+ signatario.Firstname + ' ' + signatario.LastName +'",' +
                    +'"documentation": "'+ signatario.CPF__c +'",' +
                    +'"has_documentation": true,' +
                    +'"selfie_enabled": true,'+
                    +'"handwritten_enabled": false,'+
                    +'"official_document_enabled": false,' +
                    +'"liveness_enabled": false,'+
                    +'"facial_biometrics_enabled": false'+
                    +'}'+
                    +'}';
                
                HttpRequest req2 = new HttpRequest();
                req2.setMethod('POST');
                req2.setEndpoint('https://app.clicksign.com/api/v1/signers?access_token='+ token);
                req2.setHeader('Content-Type', 'application/json');
                //req.setTimeout(120000);
                req2.setBody(body);
                HttpResponse respost = new HttpResponse();
                
                respost = new Http().send(req2);
                
                l0g = l0g + ' resposta requisicao criar assinador: ' + respost.getBody();
                
                idSignatario = respost.getBody().substringAfter('"key":"').substringBefore('",'); //salvar id do signatário novo
                
                l0g = l0g + '\n ID DO NOVO SIGNATARIO ADICIONADO:: ' + idSignatario;
                
                //Requisição para adicionar o signatário ao documento
                string body3 = '{"list": {"document_key": "'+ keyid +'",'+
                    +'"signer_key": "'+ idSignatario +'",'+
                    +'"sign_as": "party",'+
                    +'"refusable": true,'+
                    +'"group": 2,'+
                    +'"message": "Prezado,\nPor favor assine o documento.\n\nQualquer dúvida estamos à disposição.\n\nAtenciosamente, \nHOSPCOM"}}';
                
                HttpRequest req3 = new HttpRequest();
                req3.setMethod('POST');
                req3.setEndpoint('https://app.clicksign.com/api/v1/lists?access_token=' + token);
                req3.setHeader('Content-Type', 'application/json');
                //req.setTimeout(120000);
                req3.setBody(body3);
                HttpResponse respost3 = new HttpResponse();
                
                respost3 = new Http().send(req3);
                
                l0g = l0g + '\n resposta requisicao adicionar assinador: ' + respost3.getBody();
                
                string idAssinatura = respost3.getBody().substringAfter('request_signature_key":"').substringBefore('","document'); 
                
                //Requisição para enviar notificação para o assinador
                
                string body4 = '{'+
                    +'"request_signature_key": "'+ idAssinatura +'",'+
                    +'"message": "Prezado,\nPor favor assine o documento.\n\nQualquer dúvida estou à disposição.\n\nAtenciosamente,\nHOSPCOM"}';
                
                HttpRequest req4 = new HttpRequest();
                req4.setMethod('POST');
                req4.setEndpoint('https://app.clicksign.com/api/v1/notifications?access_token=' + token);
                req4.setHeader('Content-Type', 'application/json');
                //req.setTimeout(120000);
                req4.setBody(body4);
                HttpResponse respost4 = new HttpResponse();
                
                respost4 = new Http().send(req4);
                
                l0g = l0g + '\n resposta requisicao notificar assinador: ' + respost4.getStatus();
                
                
                //Testemunha
                
                string bodyTest = '{' +
                    +'"signer": { ' +
                    +'"email": "'+ contrato.Contrato_de_compra__r.Testemunha__r.Email +'", '+
                    +'"auths": [ ' +
                    +'"email" ' +
                    +'], '+
                    +'"name": "'+ contrato.Contrato_de_compra__r.Testemunha__r.Firstname + ' ' + contrato.Contrato_de_compra__r.Testemunha__r.LastName +'",' +
                    +'"documentation": "'+ cpfTestemunha +'",' +
                    +'"has_documentation": true,' +
                    +'"selfie_enabled": false,'+
                    +'"handwritten_enabled": false,'+
                    +'"official_document_enabled": false,' +
                    +'"liveness_enabled": false,'+
                    +'"facial_biometrics_enabled": false'+
                    +'}'+
                    +'}';
                
                HttpRequest reqTest = new HttpRequest();
                reqTest.setMethod('POST');
                reqTest.setEndpoint('https://app.clicksign.com/api/v1/signers?access_token=' + token);
                reqTest.setHeader('Content-Type', 'application/json');
                //req.setTimeout(120000);
                reqTest.setBody(bodyTest);
                HttpResponse resposTest = new HttpResponse();
                
                resposTest = new Http().send(reqTest);
                
                l0g = l0g + '\n resposta requisicao criar testemunha: ' + resposTest.getBody();
                
                idSignatarioTest = resposTest.getBody().substringAfter('"key":"').substringBefore('",'); //salvar id do signatário novo
                
                
                l0g = l0g + '\n ID DO NOVO TESTEMUNHA ADICIONADO:: ' + idSignatarioTest;                    
                
                //Requisição para adicionar a testemunha ao documento
                string bodyTest2 = '{"list": {"document_key": "'+ keyid +'",'+
                    +'"signer_key": "'+ idSignatarioTest +'",'+
                    +'"sign_as": "witness",'+
                    +'"refusable": true,'+
                    +'"group": 2,'+
                    +'"message": "Prezado,\nPor favor assine o documento.\n\nQualquer dúvida estamos à disposição.\n\nAtenciosamente, \nHOSPCOM"}}';
                
                HttpRequest reqTest2 = new HttpRequest();
                reqTest2.setMethod('POST');
                reqTest2.setEndpoint('https://app.clicksign.com/api/v1/lists?access_token=' + token);
                reqTest2.setHeader('Content-Type', 'application/json');
                //req.setTimeout(120000);
                reqTest2.setBody(bodyTest2);
                HttpResponse resposTest2 = new HttpResponse();
                
                resposTest2 = new Http().send(reqTest2);
                
                l0g = l0g + '\n resposta requisicao adicionar testemunha: ' + resposTest2.getBody();
                
                string idAssinaturaTest = resposTest2.getBody().substringAfter('request_signature_key":"').substringBefore('","document');                                       
                
                //Requisição para enviar notificação para a testemunha
                
                string bodyTest3 = '{'+
                    +'"request_signature_key": "'+ idAssinaturaTest +'",'+
                    +'"message": "Prezado,\nPor favor assine o documento.\n\nQualquer dúvida estou à disposição.\n\nAtenciosamente,\nHOSPCOM"}';
                
                HttpRequest reqTest3 = new HttpRequest();
                reqTest3.setMethod('POST');
                reqTest3.setEndpoint('https://app.clicksign.com/api/v1/notifications?access_token=' + token);
                reqTest3.setHeader('Content-Type', 'application/json');
                //req.setTimeout(120000);
                reqTest3.setBody(bodyTest3);
                HttpResponse resposTest3 = new HttpResponse();
                
                resposTest3 = new Http().send(reqTest3);
                
                l0g = l0g + '\n resposta requisicao notificar testemunha: ' + resposTest3.getStatus();
                
                
                //Adicionar o administrativo no processo de assinatura
                string bodyAdm = '{"list": {"document_key": "'+ keyid +'",'+
                    +'"signer_key": "'+ idSignatarioAdm +'",'+
                    +'"sign_as": "party",'+
                    +'"refusable": true,'+
                    +'"group": 3,'+
                    +'"message": "Prezado,\nPor favor assine o documento.\n\nQualquer dúvida estamos à disposição.\n\nAtenciosamente, \nHOSPCOM"}}';
                
                HttpRequest reqAdm = new HttpRequest();
                reqAdm.setMethod('POST');
                reqAdm.setEndpoint('https://app.clicksign.com/api/v1/lists?access_token=' + token);
                reqAdm.setHeader('Content-Type', 'application/json');
                //req.setTimeout(120000);
                reqAdm.setBody(bodyAdm);
                HttpResponse resposAdm = new HttpResponse();
                
                resposAdm = new Http().send(reqAdm);
                
                l0g = l0g + '\n resposta requisicao adicionar adm: ' + resposAdm.getBody();
                
                string idAssinaturaAdm = resposAdm.getBody().substringAfter('request_signature_key":"').substringBefore('","document');
                
                
                try{
                    update contrato;
                    insert doc;
                }
                catch(DmlException e){
                    if(!Test.isRunningTest())
                        throw new AuraHandledException(e.getMessage());
                }
                
                
                
                //Cria e carrega um documento com as informações para o log
                Document logDoc = new Document(
                    Name = String.valueOf(System.Now().format('yyyy/MM/dd HH:mm:ss')) + ' - Aditivo Contrato de compra ' + contrato.Contrato_de_compra__r.Name,
                    Body = Blob.valueOf(l0g),
                    ContentType = 'text/plain',
                    Type = 'txt',
                    IsPublic = false,
                    IsInternalUseOnly = true,
                    FolderId = '00l6e000002JcWd'        
                );
                insert logDoc;
            }
            else{
                throw new AuraHandledException('Erro de envio, forneça as seguintes informações para o suporte: ' + 'StatusCode: ' + resp.getStatusCode() + '; ResponseBody: ' + resp.getBody() + '');  
            }
        }  
        else{
            throw new AuraHandledException('Erro de envio, forneça as seguintes informações para o suporte: ' + 'StatusCode: ' + resp.getStatusCode() + '; ResponseBody: ' + resp.getBody() + '');  
        }
    }
    @AuraEnabled
    public static void cancelarAditivoCompra(string idContrato){
        
        Tokens_Clicksign__mdt geral = [SELECT DeveloperName, Token__c FROM Tokens_Clicksign__mdt WHERE DeveloperName ='Geral'];
        
        string token = geral.Token__c;
        
        Aditivo_do_Contrato_de_Compra__c contrato = [SELECT ID, idDocAutentique__c
                                                     FROM Aditivo_do_Contrato_de_Compra__c 
                                                     WHERE ID =: idContrato];
        
        
        HttpRequest cancela = new HttpRequest();
        cancela.setMethod('PATCH');
        cancela.setEndpoint('https://app.clicksign.com/api/v1/documents/'+ contrato.idDocAutentique__c +'/cancel?access_token=' + token);
        cancela.setHeader('Content-Type', 'application/json');
        cancela.setHeader('Accept', 'application/json');
        
        HttpResponse rCancela = new HttpResponse();
        rCancela = new Http().send(cancela);
        
        
        system.debug(rCancela.getBody());
        Integer statusCode = rCancela.getStatusCode();
        
        if(statusCode == 200){
            contrato.Fase__c = 'Cancelado';
            contrato.idDocAutentique__c = '';
            update contrato;
            
        }
        else{
            throw new AuraHandledException('Erro de cancelamento, forneça as seguintes informações para o suporte: ' + 'StatusCode: ' + statusCode + '; ResponseBody: ' + rCancela.getBody() + '');  
        }
    }
    @AuraEnabled
    public static string consultarAditivoCompra(string idContrato){
        
        Tokens_Clicksign__mdt geral = [SELECT DeveloperName, Token__c FROM Tokens_Clicksign__mdt WHERE DeveloperName ='Geral'];
        
        string token = geral.Token__c;
        
        Aditivo_do_Contrato_de_Compra__c contrato = [SELECT ID, idDocAutentique__c
                                                     FROM Aditivo_do_Contrato_de_Compra__c 
                                                     WHERE ID =: idContrato];
        
        string cancelamento = 'Documento consultado as ' ;
        string cancelamento2 = 'Documento consultado as ' ;
        string cancelamento3 = 'Documento consultado as ' ;
        
        HttpRequest consulta = new HttpRequest();
        consulta.setMethod('GET');
        consulta.setEndpoint('https://app.clicksign.com/api/v1/documents/'+ contrato.idDocAutentique__c +'?access_token=' + token);
        consulta.setHeader('Content-Type', 'application/json');
        consulta.setHeader('Accept', 'application/json');
        //req.setTimeout(120000);
        HttpResponse rConsulta = new HttpResponse();
        rConsulta = new Http().send(consulta);
        
        return rConsulta.getBody();
    }
    //Aditivo de Comodato
    @AuraEnabled
    public static void enviarAditivoComodato(string idContrato){
        
        Aditivo_de_Comodato__c contrato = [SELECT ID, Comodato__r.OwnerId, Name, Comodato__r.Name, Comodato__r.Contato__r.idDoSignatario__c, Comodato__r.Contato__r.CPF__c, Comodato__r.Contato__r.FirstName, Comodato__r.Contato__r.LastName, Comodato__r.Contato__r.Email, 
                                           Comodato__r.Testemunha__r.idDoSignatario__c, Comodato__r.Testemunha__r.FirstName, Comodato__r.Testemunha__r.LastName, Comodato__r.Testemunha__r.Email, Comodato__r.Testemunha__r.CPF__c, Comodato__r.Testemunha__r.AccountId,
                                           Comodato__r.Assinante2__r.idDoSignatario__c, Comodato__r.Assinante2__r.FirstName, Comodato__r.Assinante2__r.LastName, Comodato__r.Assinante2__r.Email, Comodato__r.Assinante2__r.CPF__c,
                                           Comodato__r.Validador__r.idDoSignatario__c, Comodato__r.Validador__r.FirstName, Comodato__r.Validador__r.LastName, Comodato__r.Validador__r.Email, Comodato__r.Validador__r.CPF__c,
                                           Comodato__r.Validador2__r.idDoSignatario__c, Comodato__r.Validador2__r.FirstName, Comodato__r.Validador2__r.LastName, Comodato__r.Validador2__r.Email, Comodato__r.Validador2__r.CPF__c
                                           FROM Aditivo_de_Comodato__c 
                                           WHERE ID =: idContrato];
        
        contact signatario = [SELECT idDoSignatario__c FROM Contact WHERE ID =: contrato.Comodato__r.Contato__c];
        
        Contact testemunha = [SELECT idDoSignatario__c FROM Contact WHERE ID =: contrato.Comodato__r.Testemunha__c];       
        
        string idSignatario = signatario.idDoSignatario__c;
        string idSignatarioTest;
        
        Tokens_Clicksign__mdt financeiro = [SELECT DeveloperName, Token__c FROM Tokens_Clicksign__mdt WHERE DeveloperName ='Financeiro'];
        Tokens_Clicksign__mdt adm = [SELECT DeveloperName, Token__c FROM Tokens_Clicksign__mdt WHERE DeveloperName ='Adm'];
        Tokens_Clicksign__mdt geral = [SELECT DeveloperName, Token__c FROM Tokens_Clicksign__mdt WHERE DeveloperName ='Geral'];
        Tokens_Clicksign__mdt juridico = [SELECT DeveloperName, Token__c FROM Tokens_Clicksign__mdt WHERE DeveloperName ='Juridico'];
        
        string idSignatarioFinanceiro = financeiro.Token__c;
        string idSignatarioAdm = adm.Token__c;
        string idSignatarioJuridico = juridico.Token__c;
        string token = geral.Token__c;
        string idSignatarioAssinante2;
        string idSignatarioValidador;
        string idSignatarioValidador2;
        string cpfTestemunha;
        
        string l0g = '';
        
        HttpRequest req = new HttpRequest();
        PageReference pdf;
        
        pdf = Page.Aditivo_Comodato;
        
        pdf.getParameters().put('id', idContrato);
        
        Blob pdfBody;
        String base64PDF;
        
        if (!Test.IsRunningTest()){
            pdfBody = pdf.getContentAsPDF();
            base64PDF = EncodingUtil.base64Encode(pdfBody);
        }
        else{
            pdfBody = Blob.valueOf('Teste');
            base64PDF = 'TESTE';
        }
        
        dateTime agora = system.now();
        
        String nomeDoDocumento  = 'Termo Aditivo ao Contrato de Comodato ' + contrato.Comodato__r.Name;
        
        
        req.setMethod('POST');
        req.setEndpoint('http://oldsite.hospcom.net:21220/clickSign');
        req.setHeader('Content','{"document":{"path": "/' + nomeDoDocumento + '.pdf","content_base64": "data:application/pdf;base64,%","locale": "pt-BR","sequence_enabled": true}}');
        req.setTimeout(120000);
        req.setBody(base64PDF);
        
        //system.debug(req.getBody());
        
        //system.debug('base64:::::' + req.getBody());
        
        HttpResponse resp = new HttpResponse();
        
        resp = new Http().send(req);
        
        system.debug(resp.getBody());
        
        string keyid = resp.getBody();
        
        l0g = 'ID do Documento: ' + keyid +
            + '\n \n Requisição de envio para o Servidor: ' + req;
        
        if(contrato.Comodato__r.Testemunha__r.AccountId == '001i00000085QYbAAM'){
            Dados_colaborador__c dados = [SELECT CPF__c FROM Dados_colaborador__c WHERE Contato__c =: contrato.Comodato__r.Testemunha__c];
            cpfTestemunha = dados.CPF__c;
        }
        else{
            cpfTestemunha = contrato.Comodato__r.Testemunha__r.CPF__c;
        }
        
        if(resp.getStatusCode() == 200){
            if(!keyId.contains('error')){
                
                Autentique__c doc = new Autentique__c(idDocAutentique__c = keyid, Nome_do_Documento__c = nomeDoDocumento);
                
                contrato.idDocAutentique__c = keyid;
                contrato.Fase__c = '1';
                //Requisição para criar o signatário no Clicksign caso ele ainda não tenha
                if(idSignatario == null){
                    string body = '{' +
                        +'"signer": { ' +
                        +'"email": "'+ contrato.Comodato__r.Contato__r.Email +'", '+
                        +'"auths": [ ' +
                        +'"email" ' +
                        +'], '+
                        +'"name": "'+ contrato.Comodato__r.Contato__r.Firstname + ' ' + contrato.Comodato__r.Contato__r.LastName +'",' +
                        +'"documentation": "'+ contrato.Comodato__r.Contato__r.CPF__c +'",' +
                        +'"has_documentation": true,' +
                        +'"selfie_enabled": false,'+
                        +'"handwritten_enabled": false,'+
                        +'"official_document_enabled": false,' +
                        +'"liveness_enabled": false,'+
                        +'"facial_biometrics_enabled": false'+
                        +'}'+
                        +'}';
                    
                    HttpRequest req2 = new HttpRequest();
                    req2.setMethod('POST');
                    req2.setEndpoint('https://app.clicksign.com/api/v1/signers?access_token='+ token);
                    req2.setHeader('Content-Type', 'application/json');
                    //req.setTimeout(120000);
                    req2.setBody(body);
                    HttpResponse respost = new HttpResponse();
                    
                    respost = new Http().send(req2);
                    
                    l0g = l0g + ' resposta requisicao criar assinador: ' + respost.getBody();
                    
                    idSignatario = respost.getBody().substringAfter('"key":"').substringBefore('",'); //salvar id do signatário novo
                    
                    l0g = l0g + '\n ID DO NOVO SIGNATARIO ADICIONADO:: ' + idSignatario;
                    
                }
                
                //Requisição para adicionar o signatário ao documento
                string body3 = '{"list": {"document_key": "'+ keyid +'",'+
                    +'"signer_key": "'+ idSignatario +'",'+
                    +'"sign_as": "party",'+
                    +'"refusable": true,'+
                    +'"group": 1,'+
                    +'"message": "Prezado,\nPor favor assine o documento.\n\nQualquer dúvida estamos à disposição.\n\nAtenciosamente, \nHOSPCOM"}}';
                
                HttpRequest req3 = new HttpRequest();
                req3.setMethod('POST');
                req3.setEndpoint('https://app.clicksign.com/api/v1/lists?access_token=' + token);
                req3.setHeader('Content-Type', 'application/json');
                //req.setTimeout(120000);
                req3.setBody(body3);
                HttpResponse respost3 = new HttpResponse();
                
                respost3 = new Http().send(req3);
                
                l0g = l0g + '\n resposta requisicao adicionar assinador: ' + respost3.getBody();
                
                string idAssinatura = respost3.getBody().substringAfter('request_signature_key":"').substringBefore('","document'); 
                
                //Requisição para enviar notificação para o assinador
                
                string body4 = '{'+
                    +'"request_signature_key": "'+ idAssinatura +'",'+
                    +'"message": "Prezado,\nPor favor assine o documento.\n\nQualquer dúvida estou à disposição.\n\nAtenciosamente,\nHOSPCOM"}';
                
                HttpRequest req4 = new HttpRequest();
                req4.setMethod('POST');
                req4.setEndpoint('https://app.clicksign.com/api/v1/notifications?access_token=' + token);
                req4.setHeader('Content-Type', 'application/json');
                //req.setTimeout(120000);
                req4.setBody(body4);
                HttpResponse respost4 = new HttpResponse();
                
                respost4 = new Http().send(req4);
                
                l0g = l0g + '\n resposta requisicao notificar assinador: ' + respost4.getStatus();
                
                //Testemunha
                
                if(idSignatarioTest == null){
                    string bodyTest = '{' +
                        +'"signer": { ' +
                        +'"email": "'+ contrato.Comodato__r.Testemunha__r.Email +'", '+
                        +'"auths": [ ' +
                        +'"email" ' +
                        +'], '+
                        +'"name": "'+ contrato.Comodato__r.Testemunha__r.Firstname + ' ' + contrato.Comodato__r.Testemunha__r.LastName +'",' +
                        +'"documentation": "'+ cpfTestemunha +'",' +
                        +'"has_documentation": true,' +
                        +'"selfie_enabled": false,'+
                        +'"handwritten_enabled": false,'+
                        +'"official_document_enabled": false,' +
                        +'"liveness_enabled": false,'+
                        +'"facial_biometrics_enabled": false'+
                        +'}'+
                        +'}';
                    
                    HttpRequest reqTest = new HttpRequest();
                    reqTest.setMethod('POST');
                    reqTest.setEndpoint('https://app.clicksign.com/api/v1/signers?access_token=' + token);
                    reqTest.setHeader('Content-Type', 'application/json');
                    //req.setTimeout(120000);
                    reqTest.setBody(bodyTest);
                    HttpResponse resposTest = new HttpResponse();
                    
                    resposTest = new Http().send(reqTest);
                    
                    l0g = l0g + '\n resposta requisicao criar testemunha: ' + resposTest.getBody();
                    
                    idSignatarioTest = resposTest.getBody().substringAfter('"key":"').substringBefore('",'); //salvar id do signatário novo
                    
                    
                    l0g = l0g + '\n ID DO NOVO TESTEMUNHA ADICIONADO:: ' + idSignatarioTest;                    
                    
                }
                
                //Requisição para adicionar a testemunha ao documento
                string bodyTest2 = '{"list": {"document_key": "'+ keyid +'",'+
                    +'"signer_key": "'+ idSignatarioTest +'",'+
                    +'"sign_as": "witness",'+
                    +'"refusable": true,'+
                    +'"group": 1,'+
                    +'"message": "Prezado,\nPor favor assine o documento.\n\nQualquer dúvida estamos à disposição.\n\nAtenciosamente, \nHOSPCOM"}}';
                
                HttpRequest reqTest2 = new HttpRequest();
                reqTest2.setMethod('POST');
                reqTest2.setEndpoint('https://app.clicksign.com/api/v1/lists?access_token=' + token);
                reqTest2.setHeader('Content-Type', 'application/json');
                //req.setTimeout(120000);
                reqTest2.setBody(bodyTest2);
                HttpResponse resposTest2 = new HttpResponse();
                
                resposTest2 = new Http().send(reqTest2);
                
                l0g = l0g + '\n resposta requisicao adicionar testemunha: ' + resposTest2.getBody();
                
                string idAssinaturaTest = resposTest2.getBody().substringAfter('request_signature_key":"').substringBefore('","document');                                       
                
                //Requisição para enviar notificação para a testemunha
                
                string bodyTest3 = '{'+
                    +'"request_signature_key": "'+ idAssinaturaTest +'",'+
                    +'"message": "Prezado,\nPor favor assine o documento.\n\nQualquer dúvida estou à disposição.\n\nAtenciosamente,\nHOSPCOM"}';
                
                HttpRequest reqTest3 = new HttpRequest();
                reqTest3.setMethod('POST');
                reqTest3.setEndpoint('https://app.clicksign.com/api/v1/notifications?access_token=' + token);
                reqTest3.setHeader('Content-Type', 'application/json');
                //req.setTimeout(120000);
                reqTest3.setBody(bodyTest3);
                HttpResponse resposTest3 = new HttpResponse();
                
                resposTest3 = new Http().send(reqTest3);
                
                l0g = l0g + '\n resposta requisicao notificar testemunha: ' + resposTest3.getStatus();
                
                
                //Adicionar o Assinante 2
                if(contrato.Comodato__r.Assinante2__c != null){
                    string bodyAssin;
                    bodyAssin = '{' +
                        +'"signer": { ' +
                        +'"email": "'+ contrato.Comodato__r.Assinante2__r.Email +'", '+
                        +'"auths": [ ' +
                        +'"email" ' +
                        +'], '+
                        +'"name": "'+ contrato.Comodato__r.Assinante2__r.Firstname + ' ' + contrato.Comodato__r.Assinante2__r.LastName +'",' +
                        +'"documentation": "'+ contrato.Comodato__r.Assinante2__r.CPF__c +'",' +
                        +'"has_documentation": true,' +
                        +'"selfie_enabled": false,'+
                        +'"handwritten_enabled": false,'+
                        +'"official_document_enabled": false,' +
                        +'"liveness_enabled": false,'+
                        +'"facial_biometrics_enabled": false'+
                        +'}'+
                        +'}';
                    
                    
                    HttpRequest reqAssin = new HttpRequest();
                    reqAssin.setMethod('POST');
                    reqAssin.setEndpoint('https://app.clicksign.com/api/v1/signers?access_token='+ token);
                    reqAssin.setHeader('Content-Type', 'application/json');
                    //req.setTimeout(120000);
                    reqAssin.setBody(bodyAssin);
                    HttpResponse respostAssin = new HttpResponse();
                    
                    respostAssin = new Http().send(reqAssin);
                    
                    l0g = l0g + ' resposta requisicao criar assinante 2: ' + respostAssin.getBody();
                    
                    idSignatarioAssinante2 = respostAssin.getBody().substringAfter('"key":"').substringBefore('",'); //salvar id do signatário novo
                    
                    l0g = l0g + '\n ID DO NOVO SIGNATARIO ADICIONADO:: ' + idSignatarioAssinante2;
                    
                    //Requisição para adicionar o assinante2 ao documento
                    string bodyAssin2 = '{"list": {"document_key": "'+ keyid +'",'+
                        +'"signer_key": "'+ idSignatarioAssinante2 +'",'+
                        +'"sign_as": "party",'+
                        +'"refusable": true,'+
                        +'"group": 1,'+
                        +'"message": "Prezado,\nPor favor assine o documento.\n\nQualquer dúvida estamos à disposição.\n\nAtenciosamente, \nHOSPCOM"}}';
                    
                    HttpRequest reqAssin2 = new HttpRequest();
                    reqAssin2.setMethod('POST');
                    reqAssin2.setEndpoint('https://app.clicksign.com/api/v1/lists?access_token=' + token);
                    reqAssin2.setHeader('Content-Type', 'application/json');
                    //req.setTimeout(120000);
                    reqAssin2.setBody(bodyAssin2);
                    HttpResponse respostAssin2 = new HttpResponse();
                    
                    respostAssin2 = new Http().send(reqAssin2);
                    
                    l0g = l0g + '\n resposta requisicao adicionar assinador: ' + respostAssin2.getBody();
                    
                    string idAssinatura2 = respostAssin2.getBody().substringAfter('request_signature_key":"').substringBefore('","document'); 
                    
                    //Requisição para enviar notificação para o assinante2
                    
                    string bodyAssin3 = '{'+
                        +'"request_signature_key": "'+ idAssinatura2 +'",'+
                        +'"message": "Prezado,\nPor favor assine o documento.\n\nQualquer dúvida estou à disposição.\n\nAtenciosamente,\nHOSPCOM"}';
                    
                    HttpRequest reqAssin4 = new HttpRequest();
                    reqAssin4.setMethod('POST');
                    reqAssin4.setEndpoint('https://app.clicksign.com/api/v1/notifications?access_token=' + token);
                    reqAssin4.setHeader('Content-Type', 'application/json');
                    //req.setTimeout(120000);
                    reqAssin4.setBody(body4);
                    HttpResponse respostAssin4 = new HttpResponse();
                    
                    respostAssin4 = new Http().send(reqAssin4);
                    
                    l0g = l0g + '\n resposta requisicao notificar assinante 2: ' + respostAssin4.getStatus();
                }
                
                //Adicionar o Validador
                if(contrato.Comodato__r.Validador__c != null){
                    string bodyValidador;
                    bodyValidador = '{' +
                        +'"signer": { ' +
                        +'"email": "'+ contrato.Comodato__r.Validador__r.Email +'", '+
                        +'"auths": [ ' +
                        +'"email" ' +
                        +'], '+
                        +'"name": "'+ contrato.Comodato__r.Validador__r.Firstname + ' ' + contrato.Comodato__r.Validador__r.LastName +'",' +
                        +'"documentation": "'+ contrato.Comodato__r.Validador__r.CPF__c +'",' +
                        +'"has_documentation": true,' +
                        +'"selfie_enabled": false,'+
                        +'"handwritten_enabled": false,'+
                        +'"official_document_enabled": false,' +
                        +'"liveness_enabled": false,'+
                        +'"facial_biometrics_enabled": false'+
                        +'}'+
                        +'}';
                    
                    HttpRequest reqValidador = new HttpRequest();
                    reqValidador.setMethod('POST');
                    reqValidador.setEndpoint('https://app.clicksign.com/api/v1/signers?access_token='+ token);
                    reqValidador.setHeader('Content-Type', 'application/json');
                    //req.setTimeout(120000);
                    reqValidador.setBody(bodyValidador);
                    HttpResponse respostValidador = new HttpResponse();
                    
                    respostValidador = new Http().send(reqValidador);
                    
                    l0g = l0g + ' resposta requisicao criar validador: ' + respostValidador.getBody();
                    
                    idSignatarioValidador = respostValidador.getBody().substringAfter('"key":"').substringBefore('",'); //salvar id do signatário novo
                    
                    l0g = l0g + '\n ID DO NOVO VALIDADOR ADICIONADO:: ' + idSignatarioValidador;
                    
                    //Requisição para adicionar o validador ao documento
                    string bodyValidador_2 = '{"list": {"document_key": "'+ keyid +'",'+
                        +'"signer_key": "'+ idSignatarioValidador +'",'+
                        +'"sign_as": "validator",'+
                        +'"refusable": true,'+
                        +'"group": 1,'+
                        +'"message": "Prezado,\nPor favor assine o documento.\n\nQualquer dúvida estamos à disposição.\n\nAtenciosamente, \nHOSPCOM"}}';
                    
                    HttpRequest reqValidador_2 = new HttpRequest();
                    reqValidador_2.setMethod('POST');
                    reqValidador_2.setEndpoint('https://app.clicksign.com/api/v1/lists?access_token=' + token);
                    reqValidador_2.setHeader('Content-Type', 'application/json');
                    //req.setTimeout(120000);
                    reqValidador_2.setBody(bodyValidador_2);
                    HttpResponse respostValidador_2 = new HttpResponse();
                    
                    respostValidador_2 = new Http().send(reqValidador_2);
                    
                    l0g = l0g + '\n resposta requisicao adicionar assinador: ' + respostValidador_2.getBody();
                    
                    string idValidador = respostValidador_2.getBody().substringAfter('request_signature_key":"').substringBefore('","document'); 
                    
                    //Requisição para enviar notificação para o validador
                    
                    string bodyValidador_3 = '{'+
                        +'"request_signature_key": "'+ idValidador +'",'+
                        +'"message": "Prezado,\nPor favor assine o documento.\n\nQualquer dúvida estou à disposição.\n\nAtenciosamente,\nHOSPCOM"}';
                    
                    HttpRequest reqValidador_3 = new HttpRequest();
                    reqValidador_3.setMethod('POST');
                    reqValidador_3.setEndpoint('https://app.clicksign.com/api/v1/notifications?access_token=' + token);
                    reqValidador_3.setHeader('Content-Type', 'application/json');
                    //req.setTimeout(120000);
                    reqValidador_3.setBody(bodyValidador_3);
                    HttpResponse respostValidador_3 = new HttpResponse();
                    
                    respostValidador_3 = new Http().send(reqValidador_3);
                    
                    l0g = l0g + '\n resposta requisicao notificar validador: ' + respostValidador_3.getStatus();
                }
                //Adicionar o Validador 2
                if(contrato.Comodato__r.Validador2__c != null){
                    string bodyValidador2;
                    bodyValidador2 = '{' +
                        +'"signer": { ' +
                        +'"email": "'+ contrato.Comodato__r.Validador2__r.Email +'", '+
                        +'"auths": [ ' +
                        +'"email" ' +
                        +'], '+
                        +'"name": "'+ contrato.Comodato__r.Validador2__r.Firstname + ' ' + contrato.Comodato__r.Validador2__r.LastName +'",' +
                        +'"documentation": "'+ contrato.Comodato__r.Validador2__r.CPF__c +'",' +
                        +'"has_documentation": true,' +
                        +'"selfie_enabled": false,'+
                        +'"handwritten_enabled": false,'+
                        +'"official_document_enabled": false,' +
                        +'"liveness_enabled": false,'+
                        +'"facial_biometrics_enabled": false'+
                        +'}'+
                        +'}';
                    
                    HttpRequest reqValidador2 = new HttpRequest();
                    reqValidador2.setMethod('POST');
                    reqValidador2.setEndpoint('https://app.clicksign.com/api/v1/signers?access_token='+ token);
                    reqValidador2.setHeader('Content-Type', 'application/json');
                    //req.setTimeout(120000);
                    reqValidador2.setBody(bodyValidador2);
                    HttpResponse respostValidador2 = new HttpResponse();
                    
                    respostValidador2 = new Http().send(reqValidador2);
                    
                    l0g = l0g + ' resposta requisicao criar validador 2: ' + respostValidador2.getBody();
                    
                    idSignatarioValidador2 = respostValidador2.getBody().substringAfter('"key":"').substringBefore('",'); //salvar id do signatário novo
                    
                    l0g = l0g + '\n ID DO NOVO VALIDADOR 2 ADICIONADO:: ' + idSignatarioValidador2;
                    
                    //Requisição para adicionar o validador 2 ao documento
                    string bodyValidador2_2 = '{"list": {"document_key": "'+ keyid +'",'+
                        +'"signer_key": "'+ idSignatarioValidador2 +'",'+
                        +'"sign_as": "validator",'+
                        +'"refusable": true,'+
                        +'"group": 1,'+
                        +'"message": "Prezado,\nPor favor assine o documento.\n\nQualquer dúvida estamos à disposição.\n\nAtenciosamente, \nHOSPCOM"}}';
                    
                    HttpRequest reqValidador2_2 = new HttpRequest();
                    reqValidador2_2.setMethod('POST');
                    reqValidador2_2.setEndpoint('https://app.clicksign.com/api/v1/lists?access_token=' + token);
                    reqValidador2_2.setHeader('Content-Type', 'application/json');
                    //req.setTimeout(120000);
                    reqValidador2_2.setBody(bodyValidador2_2);
                    HttpResponse respostValidador2_2 = new HttpResponse();
                    
                    respostValidador2_2 = new Http().send(reqValidador2_2);
                    
                    l0g = l0g + '\n resposta requisicao adicionar validador 2: ' + respostValidador2_2.getBody();
                    
                    string idValidador2 = respostValidador2_2.getBody().substringAfter('request_signature_key":"').substringBefore('","document'); 
                    
                    //Requisição para enviar notificação para o validador 2
                    
                    string bodyValidador2_3 = '{'+
                        +'"request_signature_key": "'+ idValidador2 +'",'+
                        +'"message": "Prezado,\nPor favor assine o documento.\n\nQualquer dúvida estou à disposição.\n\nAtenciosamente,\nHOSPCOM"}';
                    
                    HttpRequest reqValidador2_3 = new HttpRequest();
                    reqValidador2_3.setMethod('POST');
                    reqValidador2_3.setEndpoint('https://app.clicksign.com/api/v1/notifications?access_token=' + token);
                    reqValidador2_3.setHeader('Content-Type', 'application/json');
                    //req.setTimeout(120000);
                    reqValidador2_3.setBody(bodyValidador2_3);
                    HttpResponse respostValidador2_3 = new HttpResponse();
                    
                    respostValidador2_3 = new Http().send(reqValidador2_3);
                    
                    l0g = l0g + '\n resposta requisicao notificar validador 2: ' + respostValidador2_3.getStatus();
                }
                
                
                
                //Adicionar o financeiro no processo de assinatura
                string bodyFinanceiro = '{"list": {"document_key": "'+ keyid +'",'+
                    +'"signer_key": "'+ idSignatarioFinanceiro +'",'+
                    +'"sign_as": "witness",'+
                    +'"refusable": true,'+
                    +'"group": 2,'+
                    +'"message": "Prezado,\nPor favor assine o documento.\n\nQualquer dúvida estamos à disposição.\n\nAtenciosamente, \nHOSPCOM"}}';
                
                HttpRequest reqFinanceiro = new HttpRequest();
                reqFinanceiro.setMethod('POST');
                reqFinanceiro.setEndpoint('https://app.clicksign.com/api/v1/lists?access_token=' + token);
                reqFinanceiro.setHeader('Content-Type', 'application/json');
                //req.setTimeout(120000);
                reqFinanceiro.setBody(bodyFinanceiro);
                HttpResponse resposFinanceiro = new HttpResponse();
                
                resposFinanceiro = new Http().send(reqFinanceiro);
                
                l0g = l0g + '\n resposta requisicao adicionar Financeiro: ' + resposFinanceiro.getBody();
                
                string idAssinaturaFinanceiro = resposFinanceiro.getBody().substringAfter('request_signature_key":"').substringBefore('","document');                
                
                //Adicionar o jurídico no processo de assinatura
                string bodyJuridico = '{"list": {"document_key": "'+ keyid +'",'+
                    +'"signer_key": "'+ idSignatarioJuridico +'",'+
                    +'"sign_as": "witness",'+
                    +'"refusable": true,'+
                    +'"group": 3,'+
                    +'"message": "Prezado,\nPor favor assine o documento.\n\nQualquer dúvida estamos à disposição.\n\nAtenciosamente, \nHOSPCOM"}}';
                
                HttpRequest reqJuridico = new HttpRequest();
                reqJuridico.setMethod('POST');
                reqJuridico.setEndpoint('https://app.clicksign.com/api/v1/lists?access_token=' + token);
                reqJuridico.setHeader('Content-Type', 'application/json');
                //req.setTimeout(120000);
                reqJuridico.setBody(bodyJuridico);
                HttpResponse resposJuridico = new HttpResponse();
                
                resposJuridico = new Http().send(reqJuridico);
                
                l0g = l0g + '\n resposta requisicao adicionar juridico: ' + resposJuridico.getBody();
                
                string idAssinaturaJuridico = resposJuridico.getBody().substringAfter('request_signature_key":"').substringBefore('","document');
                
                
                //Adicionar o administrativo no processo de assinatura
                string bodyAdm = '{"list": {"document_key": "'+ keyid +'",'+
                    +'"signer_key": "'+ idSignatarioAdm +'",'+
                    +'"sign_as": "party",'+
                    +'"refusable": true,'+
                    +'"group": 3,'+
                    +'"message": "Prezado,\nPor favor assine o documento.\n\nQualquer dúvida estamos à disposição.\n\nAtenciosamente, \nHOSPCOM"}}';
                
                HttpRequest reqAdm = new HttpRequest();
                reqAdm.setMethod('POST');
                reqAdm.setEndpoint('https://app.clicksign.com/api/v1/lists?access_token=' + token);
                reqAdm.setHeader('Content-Type', 'application/json');
                //req.setTimeout(120000);
                reqAdm.setBody(bodyAdm);
                HttpResponse resposAdm = new HttpResponse();
                
                resposAdm = new Http().send(reqAdm);
                
                l0g = l0g + '\n resposta requisicao adicionar adm: ' + resposAdm.getBody();
                
                string idAssinaturaAdm = resposAdm.getBody().substringAfter('request_signature_key":"').substringBefore('","document');
                
                
                try{
                    insert doc;
                    update contrato;
                }
                catch(DmlException e){
                    if(!Test.isRunningTest())
                        throw new AuraHandledException(e.getMessage());
                }
                
                
                //Cria e carrega um documento com as informações para o log
                Document logDoc = new Document(
                    Name = String.valueOf(System.Now().format('yyyy/MM/dd HH:mm:ss')) + ' - Contrato de Demo/Comodato: ' + contrato.Name,
                    Body = Blob.valueOf(l0g),
                    ContentType = 'text/plain',
                    Type = 'txt',
                    IsPublic = false,
                    IsInternalUseOnly = true,
                    FolderId = '00l6e000002JcWd'        
                );
                insert logDoc;
            }
            else{
                throw new AuraHandledException('Erro de envio, forneça as seguintes informações para o suporte: ' + 'StatusCode: ' + resp.getStatusCode() + '; ResponseBody: ' + resp.getBody() + '');  
            }
        }  
        else{
            throw new AuraHandledException('Erro de envio, forneça as seguintes informações para o suporte: ' + 'StatusCode: ' + resp.getStatusCode() + '; ResponseBody: ' + resp.getBody() + '');  
        }
    }
    @AuraEnabled
    public static void cancelarAditivoComodato(string idContrato){
        
        Tokens_Clicksign__mdt geral = [SELECT DeveloperName, Token__c FROM Tokens_Clicksign__mdt WHERE DeveloperName ='Geral'];
        
        string token = geral.Token__c;
        
        Aditivo_de_Comodato__c contrato = [SELECT ID, idDocAutentique__c
                                           FROM Aditivo_de_Comodato__c 
                                           WHERE ID =: idContrato];
        
        
        HttpRequest cancela = new HttpRequest();
        cancela.setMethod('PATCH');
        cancela.setEndpoint('https://app.clicksign.com/api/v1/documents/'+ contrato.idDocAutentique__c +'/cancel?access_token=' + token);
        cancela.setHeader('Content-Type', 'application/json');
        cancela.setHeader('Accept', 'application/json');
        
        HttpResponse rCancela = new HttpResponse();
        rCancela = new Http().send(cancela);
        
        
        system.debug(rCancela.getBody());
        Integer statusCode = rCancela.getStatusCode();
        
        if(statusCode == 200){
            contrato.Fase__c = 'Cancelado';
            contrato.idDocAutentique__c = '';
            update contrato;
            
        }
        else{
            throw new AuraHandledException('Erro de cancelamento, forneça as seguintes informações para o suporte: ' + 'StatusCode: ' + statusCode + '; ResponseBody: ' + rCancela.getBody() + '');  
        }
    }
    @AuraEnabled
    public static string consultarAditivoComodato(string idContrato){
        
        Tokens_Clicksign__mdt geral = [SELECT DeveloperName, Token__c FROM Tokens_Clicksign__mdt WHERE DeveloperName ='Geral'];
        
        string token = geral.Token__c;
        
        Aditivo_de_Comodato__c contrato = [SELECT ID, idDocAutentique__c
                                           FROM Aditivo_de_Comodato__c 
                                           WHERE ID =: idContrato];
        
        string cancelamento = 'Documento consultado as ' ;
        string cancelamento2 = 'Documento consultado as ' ;
        string cancelamento3 = 'Documento consultado as ' ;
        
        HttpRequest consulta = new HttpRequest();
        consulta.setMethod('GET');
        consulta.setEndpoint('https://app.clicksign.com/api/v1/documents/'+ contrato.idDocAutentique__c +'?access_token=' + token);
        consulta.setHeader('Content-Type', 'application/json');
        consulta.setHeader('Accept', 'application/json');
        //req.setTimeout(120000);
        HttpResponse rConsulta = new HttpResponse();
        rConsulta = new Http().send(consulta);
        
        return rConsulta.getBody();  
    }
    //Contrato de Fornecimento de Insumos
    @AuraEnabled
    @future(callout=true)
    public static void enviarContratoFornecimento(string idContrato){
        
        Contrato_de_Fornecimento_de_Insumo__c contrato = [SELECT ID, OwnerId, Name, Assinante__r.idDoSignatario__c, Assinante__r.CPF__c, Assinante__r.FirstName, Assinante__r.LastName, Assinante__r.Email, 
                                                          Testemunha__r.idDoSignatario__c, Testemunha__r.FirstName, Testemunha__r.LastName, Testemunha__r.Email, Testemunha__r.CPF__c, Testemunha__r.AccountId,
                                                          Assinante2__r.idDoSignatario__c, Assinante2__r.FirstName, Assinante2__r.LastName, Assinante2__r.Email, Assinante2__r.CPF__c,
                                                          Validador__r.idDoSignatario__c, Validador__r.FirstName, Validador__r.LastName, Validador__r.Email, Validador__r.CPF__c,
                                                          Validador2__r.idDoSignatario__c, Validador2__r.FirstName, Validador2__r.LastName, Validador2__r.Email, Validador2__r.CPF__c
                                                          FROM Contrato_de_Fornecimento_de_Insumo__c 
                                                          WHERE ID =: idContrato];
        
        contact signatario = [SELECT idDoSignatario__c FROM Contact WHERE ID =: contrato.Assinante__c];
        
        Contact testemunha = [SELECT idDoSignatario__c FROM Contact WHERE ID =: contrato.Testemunha__c];       
        
        string idSignatario = signatario.idDoSignatario__c;
        string idSignatarioTest;
        
        Tokens_Clicksign__mdt financeiro = [SELECT DeveloperName, Token__c FROM Tokens_Clicksign__mdt WHERE DeveloperName ='Financeiro'];
        Tokens_Clicksign__mdt juridico = [SELECT DeveloperName, Token__c FROM Tokens_Clicksign__mdt WHERE DeveloperName ='Juridico'];
        Tokens_Clicksign__mdt adm = [SELECT DeveloperName, Token__c FROM Tokens_Clicksign__mdt WHERE DeveloperName ='Adm'];
        Tokens_Clicksign__mdt geral = [SELECT DeveloperName, Token__c FROM Tokens_Clicksign__mdt WHERE DeveloperName ='Geral'];
        
        string idSignatarioFinanceiro = financeiro.Token__c;
        string idSignatarioAdm = adm.Token__c;
        string idSignatarioJuridico = juridico.Token__c;
        string token = geral.Token__c;
        string idSignatarioAssinante2;
        string idSignatarioValidador;
        string idSignatarioValidador2;
        string cpfTestemunha;
        
        string l0g = '';
        
        HttpRequest req = new HttpRequest();
        PageReference pdf;
        
        pdf = Page.Contrato_de_Fornecimento_de_Insumo;
        
        pdf.getParameters().put('id', idContrato);
        
        Blob pdfBody;
        String base64PDF;
        
        if (!Test.IsRunningTest()){
            pdfBody = pdf.getContentAsPDF();
            base64PDF = EncodingUtil.base64Encode(pdfBody);
        }
        else{
            pdfBody = Blob.valueOf('Teste');
            base64PDF = 'TESTE';
        }
        
        dateTime agora = system.now();
        
        String nomeDoDocumento  = 'Contrato de Fornecimento de Insumos ' + contrato.Name;
        
        
        req.setMethod('POST');
        req.setEndpoint('http://oldsite.hospcom.net:21220/clickSign');
        req.setHeader('Content','{"document":{"path": "/' + nomeDoDocumento + '.pdf","content_base64": "data:application/pdf;base64,%","locale": "pt-BR","sequence_enabled": true}}');
        req.setTimeout(120000);
        req.setBody(base64PDF);
        
        //system.debug(req.getBody());
        
        //system.debug('base64:::::' + req.getBody());
        
        HttpResponse resp = new HttpResponse();
        
        resp = new Http().send(req);
        
        system.debug(resp.getBody());
        
        string keyid = resp.getBody();
        
        l0g = 'ID do Documento: ' + keyid +
            + '\n \n Requisição de envio para o Servidor: ' + req;
        
        if(contrato.Testemunha__r.AccountId == '001i00000085QYbAAM'){
            Dados_colaborador__c dados = [SELECT CPF__c FROM Dados_colaborador__c WHERE Contato__c =: contrato.Testemunha__c];
            cpfTestemunha = dados.CPF__c;
        }
        else{
            cpfTestemunha = contrato.Testemunha__r.CPF__c;
        }
        
        if(resp.getStatusCode() == 200){
            if(!keyId.contains('error')){
                
                Autentique__c doc = new Autentique__c(idDocAutentique__c = keyid, Nome_do_Documento__c = nomeDoDocumento);
                
                contrato.idDocAutentique__c = keyid;
                contrato.Fase__c = '1';
                contrato.Status__c = 'Em assinatura';
                
                //Adicionar o financeiro no processo de assinatura
                string bodyFinanceiro = '{"list": {"document_key": "'+ keyid +'",'+
                    +'"signer_key": "'+ idSignatarioFinanceiro +'",'+
                    +'"sign_as": "witness",'+
                    +'"refusable": true,'+
                    +'"group": 1,'+
                    +'"message": "Prezado,\nPor favor assine o documento.\n\nQualquer dúvida estamos à disposição.\n\nAtenciosamente, \nHOSPCOM"}}';
                
                HttpRequest reqFinanceiro = new HttpRequest();
                reqFinanceiro.setMethod('POST');
                reqFinanceiro.setEndpoint('https://app.clicksign.com/api/v1/lists?access_token=' + token);
                reqFinanceiro.setHeader('Content-Type', 'application/json');
                //req.setTimeout(120000);
                reqFinanceiro.setBody(bodyFinanceiro);
                HttpResponse resposFinanceiro = new HttpResponse();
                
                resposFinanceiro = new Http().send(reqFinanceiro);
                
                l0g = l0g + '\n resposta requisicao adicionar juridico: ' + resposFinanceiro.getBody();
                
                string idAssinaturaFinanceiro = resposFinanceiro.getBody().substringAfter('request_signature_key":"').substringBefore('","document');
                
                
                //Requisição para criar o signatário no Clicksign caso ele ainda não tenha
                if(idSignatario == null){
                    string body = '{' +
                        +'"signer": { ' +
                        +'"email": "'+ contrato.Assinante__r.Email +'", '+
                        +'"auths": [ ' +
                        +'"email" ' +
                        +'], '+
                        +'"name": "'+ contrato.Assinante__r.Firstname + ' ' + contrato.Assinante__r.LastName +'",' +
                        +'"documentation": "'+ contrato.Assinante__r.CPF__c +'",' +
                        +'"has_documentation": true,' +
                        +'"selfie_enabled": false,'+
                        +'"handwritten_enabled": false,'+
                        +'"official_document_enabled": false,' +
                        +'"liveness_enabled": false,'+
                        +'"facial_biometrics_enabled": false'+
                        +'}'+
                        +'}';
                    
                    HttpRequest req2 = new HttpRequest();
                    req2.setMethod('POST');
                    req2.setEndpoint('https://app.clicksign.com/api/v1/signers?access_token='+ token);
                    req2.setHeader('Content-Type', 'application/json');
                    //req.setTimeout(120000);
                    req2.setBody(body);
                    HttpResponse respost = new HttpResponse();
                    
                    respost = new Http().send(req2);
                    
                    l0g = l0g + ' resposta requisicao criar assinador: ' + respost.getBody();
                    
                    idSignatario = respost.getBody().substringAfter('"key":"').substringBefore('",'); //salvar id do signatário novo
                    
                    l0g = l0g + '\n ID DO NOVO SIGNATARIO ADICIONADO:: ' + idSignatario;
                    
                }
                
                //Requisição para adicionar o signatário ao documento
                string body3 = '{"list": {"document_key": "'+ keyid +'",'+
                    +'"signer_key": "'+ idSignatario +'",'+
                    +'"sign_as": "party",'+
                    +'"refusable": true,'+
                    +'"group": 2,'+
                    +'"message": "Prezado,\nPor favor assine o documento.\n\nQualquer dúvida estamos à disposição.\n\nAtenciosamente, \nHOSPCOM"}}';
                
                HttpRequest req3 = new HttpRequest();
                req3.setMethod('POST');
                req3.setEndpoint('https://app.clicksign.com/api/v1/lists?access_token=' + token);
                req3.setHeader('Content-Type', 'application/json');
                //req.setTimeout(120000);
                req3.setBody(body3);
                HttpResponse respost3 = new HttpResponse();
                
                respost3 = new Http().send(req3);
                
                l0g = l0g + '\n resposta requisicao adicionar assinador: ' + respost3.getBody();
                
                string idAssinatura = respost3.getBody().substringAfter('request_signature_key":"').substringBefore('","document'); 
                
                //Requisição para enviar notificação para o assinador
                
                string body4 = '{'+
                    +'"request_signature_key": "'+ idAssinatura +'",'+
                    +'"message": "Prezado,\nPor favor assine o documento.\n\nQualquer dúvida estou à disposição.\n\nAtenciosamente,\nHOSPCOM"}';
                
                HttpRequest req4 = new HttpRequest();
                req4.setMethod('POST');
                req4.setEndpoint('https://app.clicksign.com/api/v1/notifications?access_token=' + token);
                req4.setHeader('Content-Type', 'application/json');
                //req.setTimeout(120000);
                req4.setBody(body4);
                HttpResponse respost4 = new HttpResponse();
                
                respost4 = new Http().send(req4);
                
                l0g = l0g + '\n resposta requisicao notificar assinador: ' + respost4.getStatus();
                
                //Testemunha
                
                if(idSignatarioTest == null){
                    string bodyTest = '{' +
                        +'"signer": { ' +
                        +'"email": "'+ contrato.Testemunha__r.Email +'", '+
                        +'"auths": [ ' +
                        +'"email" ' +
                        +'], '+
                        +'"name": "'+ contrato.Testemunha__r.Firstname + ' ' + contrato.Testemunha__r.LastName +'",' +
                        +'"documentation": "'+ cpfTestemunha +'",' +
                        +'"has_documentation": true,' +
                        +'"selfie_enabled": false,'+
                        +'"handwritten_enabled": false,'+
                        +'"official_document_enabled": false,' +
                        +'"liveness_enabled": false,'+
                        +'"facial_biometrics_enabled": false'+
                        +'}'+
                        +'}';
                    
                    HttpRequest reqTest = new HttpRequest();
                    reqTest.setMethod('POST');
                    reqTest.setEndpoint('https://app.clicksign.com/api/v1/signers?access_token=' + token);
                    reqTest.setHeader('Content-Type', 'application/json');
                    //req.setTimeout(120000);
                    reqTest.setBody(bodyTest);
                    HttpResponse resposTest = new HttpResponse();
                    
                    resposTest = new Http().send(reqTest);
                    
                    l0g = l0g + '\n resposta requisicao criar testemunha: ' + resposTest.getBody();
                    
                    idSignatarioTest = resposTest.getBody().substringAfter('"key":"').substringBefore('",'); //salvar id do signatário novo
                    
                    
                    l0g = l0g + '\n ID DO NOVO TESTEMUNHA ADICIONADO:: ' + idSignatarioTest;                    
                    
                }
                
                //Requisição para adicionar a testemunha ao documento
                string bodyTest2 = '{"list": {"document_key": "'+ keyid +'",'+
                    +'"signer_key": "'+ idSignatarioTest +'",'+
                    +'"sign_as": "witness",'+
                    +'"refusable": true,'+
                    +'"group": 2,'+
                    +'"message": "Prezado,\nPor favor assine o documento.\n\nQualquer dúvida estamos à disposição.\n\nAtenciosamente, \nHOSPCOM"}}';
                
                HttpRequest reqTest2 = new HttpRequest();
                reqTest2.setMethod('POST');
                reqTest2.setEndpoint('https://app.clicksign.com/api/v1/lists?access_token=' + token);
                reqTest2.setHeader('Content-Type', 'application/json');
                //req.setTimeout(120000);
                reqTest2.setBody(bodyTest2);
                HttpResponse resposTest2 = new HttpResponse();
                
                resposTest2 = new Http().send(reqTest2);
                
                l0g = l0g + '\n resposta requisicao adicionar testemunha: ' + resposTest2.getBody();
                
                string idAssinaturaTest = resposTest2.getBody().substringAfter('request_signature_key":"').substringBefore('","document');                                       
                
                //Requisição para enviar notificação para a testemunha
                
                string bodyTest3 = '{'+
                    +'"request_signature_key": "'+ idAssinaturaTest +'",'+
                    +'"message": "Prezado,\nPor favor assine o documento.\n\nQualquer dúvida estou à disposição.\n\nAtenciosamente,\nHOSPCOM"}';
                
                HttpRequest reqTest3 = new HttpRequest();
                reqTest3.setMethod('POST');
                reqTest3.setEndpoint('https://app.clicksign.com/api/v1/notifications?access_token=' + token);
                reqTest3.setHeader('Content-Type', 'application/json');
                //req.setTimeout(120000);
                reqTest3.setBody(bodyTest3);
                HttpResponse resposTest3 = new HttpResponse();
                
                resposTest3 = new Http().send(reqTest3);
                
                l0g = l0g + '\n resposta requisicao notificar testemunha: ' + resposTest3.getStatus();
                
                
                //Adicionar o Assinante 2
                if(contrato.Assinante2__c != null){
                    string bodyAssin;
                    bodyAssin = '{' +
                        +'"signer": { ' +
                        +'"email": "'+ contrato.Assinante2__r.Email +'", '+
                        +'"auths": [ ' +
                        +'"email" ' +
                        +'], '+
                        +'"name": "'+ contrato.Assinante2__r.Firstname + ' ' + contrato.Assinante2__r.LastName +'",' +
                        +'"documentation": "'+ contrato.Assinante2__r.CPF__c +'",' +
                        +'"has_documentation": true,' +
                        +'"selfie_enabled": false,'+
                        +'"handwritten_enabled": false,'+
                        +'"official_document_enabled": false,' +
                        +'"liveness_enabled": false,'+
                        +'"facial_biometrics_enabled": false'+
                        +'}'+
                        +'}';
                    
                    
                    HttpRequest reqAssin = new HttpRequest();
                    reqAssin.setMethod('POST');
                    reqAssin.setEndpoint('https://app.clicksign.com/api/v1/signers?access_token='+ token);
                    reqAssin.setHeader('Content-Type', 'application/json');
                    //req.setTimeout(120000);
                    reqAssin.setBody(bodyAssin);
                    HttpResponse respostAssin = new HttpResponse();
                    
                    respostAssin = new Http().send(reqAssin);
                    
                    l0g = l0g + ' resposta requisicao criar assinante 2: ' + respostAssin.getBody();
                    
                    idSignatarioAssinante2 = respostAssin.getBody().substringAfter('"key":"').substringBefore('",'); //salvar id do signatário novo
                    
                    l0g = l0g + '\n ID DO NOVO SIGNATARIO ADICIONADO:: ' + idSignatarioAssinante2;
                    
                    //Requisição para adicionar o assinante2 ao documento
                    string bodyAssin2 = '{"list": {"document_key": "'+ keyid +'",'+
                        +'"signer_key": "'+ idSignatarioAssinante2 +'",'+
                        +'"sign_as": "party",'+
                        +'"refusable": true,'+
                        +'"group": 2,'+
                        +'"message": "Prezado,\nPor favor assine o documento.\n\nQualquer dúvida estamos à disposição.\n\nAtenciosamente, \nHOSPCOM"}}';
                    
                    HttpRequest reqAssin2 = new HttpRequest();
                    reqAssin2.setMethod('POST');
                    reqAssin2.setEndpoint('https://app.clicksign.com/api/v1/lists?access_token=' + token);
                    reqAssin2.setHeader('Content-Type', 'application/json');
                    //req.setTimeout(120000);
                    reqAssin2.setBody(bodyAssin2);
                    HttpResponse respostAssin2 = new HttpResponse();
                    
                    respostAssin2 = new Http().send(reqAssin2);
                    
                    l0g = l0g + '\n resposta requisicao adicionar assinador: ' + respostAssin2.getBody();
                    
                    string idAssinatura2 = respostAssin2.getBody().substringAfter('request_signature_key":"').substringBefore('","document'); 
                    
                    //Requisição para enviar notificação para o assinante2
                    
                    string bodyAssin3 = '{'+
                        +'"request_signature_key": "'+ idAssinatura2 +'",'+
                        +'"message": "Prezado,\nPor favor assine o documento.\n\nQualquer dúvida estou à disposição.\n\nAtenciosamente,\nHOSPCOM"}';
                    
                    HttpRequest reqAssin4 = new HttpRequest();
                    reqAssin4.setMethod('POST');
                    reqAssin4.setEndpoint('https://app.clicksign.com/api/v1/notifications?access_token=' + token);
                    reqAssin4.setHeader('Content-Type', 'application/json');
                    //req.setTimeout(120000);
                    reqAssin4.setBody(body4);
                    HttpResponse respostAssin4 = new HttpResponse();
                    
                    respostAssin4 = new Http().send(reqAssin4);
                    
                    l0g = l0g + '\n resposta requisicao notificar assinante 2: ' + respostAssin4.getStatus();
                }
                
                //Adicionar o Validador
                if(contrato.Validador__c != null){
                    string bodyValidador;
                    bodyValidador = '{' +
                        +'"signer": { ' +
                        +'"email": "'+ contrato.Validador__r.Email +'", '+
                        +'"auths": [ ' +
                        +'"email" ' +
                        +'], '+
                        +'"name": "'+ contrato.Validador__r.Firstname + ' ' + contrato.Validador__r.LastName +'",' +
                        +'"documentation": "'+ contrato.Validador__r.CPF__c +'",' +
                        +'"has_documentation": true,' +
                        +'"selfie_enabled": false,'+
                        +'"handwritten_enabled": false,'+
                        +'"official_document_enabled": false,' +
                        +'"liveness_enabled": false,'+
                        +'"facial_biometrics_enabled": false'+
                        +'}'+
                        +'}';
                    
                    HttpRequest reqValidador = new HttpRequest();
                    reqValidador.setMethod('POST');
                    reqValidador.setEndpoint('https://app.clicksign.com/api/v1/signers?access_token='+ token);
                    reqValidador.setHeader('Content-Type', 'application/json');
                    //req.setTimeout(120000);
                    reqValidador.setBody(bodyValidador);
                    HttpResponse respostValidador = new HttpResponse();
                    
                    respostValidador = new Http().send(reqValidador);
                    
                    l0g = l0g + ' resposta requisicao criar validador: ' + respostValidador.getBody();
                    
                    idSignatarioValidador = respostValidador.getBody().substringAfter('"key":"').substringBefore('",'); //salvar id do signatário novo
                    
                    l0g = l0g + '\n ID DO NOVO VALIDADOR ADICIONADO:: ' + idSignatarioValidador;
                    
                    //Requisição para adicionar o validador ao documento
                    string bodyValidador_2 = '{"list": {"document_key": "'+ keyid +'",'+
                        +'"signer_key": "'+ idSignatarioValidador +'",'+
                        +'"sign_as": "validator",'+
                        +'"refusable": true,'+
                        +'"group": 2,'+
                        +'"message": "Prezado,\nPor favor assine o documento.\n\nQualquer dúvida estamos à disposição.\n\nAtenciosamente, \nHOSPCOM"}}';
                    
                    HttpRequest reqValidador_2 = new HttpRequest();
                    reqValidador_2.setMethod('POST');
                    reqValidador_2.setEndpoint('https://app.clicksign.com/api/v1/lists?access_token=' + token);
                    reqValidador_2.setHeader('Content-Type', 'application/json');
                    //req.setTimeout(120000);
                    reqValidador_2.setBody(bodyValidador_2);
                    HttpResponse respostValidador_2 = new HttpResponse();
                    
                    respostValidador_2 = new Http().send(reqValidador_2);
                    
                    l0g = l0g + '\n resposta requisicao adicionar assinador: ' + respostValidador_2.getBody();
                    
                    string idValidador = respostValidador_2.getBody().substringAfter('request_signature_key":"').substringBefore('","document'); 
                    
                    //Requisição para enviar notificação para o validador
                    
                    string bodyValidador_3 = '{'+
                        +'"request_signature_key": "'+ idValidador +'",'+
                        +'"message": "Prezado,\nPor favor assine o documento.\n\nQualquer dúvida estou à disposição.\n\nAtenciosamente,\nHOSPCOM"}';
                    
                    HttpRequest reqValidador_3 = new HttpRequest();
                    reqValidador_3.setMethod('POST');
                    reqValidador_3.setEndpoint('https://app.clicksign.com/api/v1/notifications?access_token=' + token);
                    reqValidador_3.setHeader('Content-Type', 'application/json');
                    //req.setTimeout(120000);
                    reqValidador_3.setBody(bodyValidador_3);
                    HttpResponse respostValidador_3 = new HttpResponse();
                    
                    respostValidador_3 = new Http().send(reqValidador_3);
                    
                    l0g = l0g + '\n resposta requisicao notificar validador: ' + respostValidador_3.getStatus();
                }
                //Adicionar o Validador 2
                if(contrato.Validador2__c != null){
                    string bodyValidador2;
                    bodyValidador2 = '{' +
                        +'"signer": { ' +
                        +'"email": "'+ contrato.Validador2__r.Email +'", '+
                        +'"auths": [ ' +
                        +'"email" ' +
                        +'], '+
                        +'"name": "'+ contrato.Validador2__r.Firstname + ' ' + contrato.Validador2__r.LastName +'",' +
                        +'"documentation": "'+ contrato.Validador2__r.CPF__c +'",' +
                        +'"has_documentation": true,' +
                        +'"selfie_enabled": false,'+
                        +'"handwritten_enabled": false,'+
                        +'"official_document_enabled": false,' +
                        +'"liveness_enabled": false,'+
                        +'"facial_biometrics_enabled": false'+
                        +'}'+
                        +'}';
                    
                    HttpRequest reqValidador2 = new HttpRequest();
                    reqValidador2.setMethod('POST');
                    reqValidador2.setEndpoint('https://app.clicksign.com/api/v1/signers?access_token='+ token);
                    reqValidador2.setHeader('Content-Type', 'application/json');
                    //req.setTimeout(120000);
                    reqValidador2.setBody(bodyValidador2);
                    HttpResponse respostValidador2 = new HttpResponse();
                    
                    respostValidador2 = new Http().send(reqValidador2);
                    
                    l0g = l0g + ' resposta requisicao criar validador 2: ' + respostValidador2.getBody();
                    
                    idSignatarioValidador2 = respostValidador2.getBody().substringAfter('"key":"').substringBefore('",'); //salvar id do signatário novo
                    
                    l0g = l0g + '\n ID DO NOVO VALIDADOR 2 ADICIONADO:: ' + idSignatarioValidador2;
                    
                    //Requisição para adicionar o validador 2 ao documento
                    string bodyValidador2_2 = '{"list": {"document_key": "'+ keyid +'",'+
                        +'"signer_key": "'+ idSignatarioValidador2 +'",'+
                        +'"sign_as": "validator",'+
                        +'"refusable": true,'+
                        +'"group": 2,'+
                        +'"message": "Prezado,\nPor favor assine o documento.\n\nQualquer dúvida estamos à disposição.\n\nAtenciosamente, \nHOSPCOM"}}';
                    
                    HttpRequest reqValidador2_2 = new HttpRequest();
                    reqValidador2_2.setMethod('POST');
                    reqValidador2_2.setEndpoint('https://app.clicksign.com/api/v1/lists?access_token=' + token);
                    reqValidador2_2.setHeader('Content-Type', 'application/json');
                    //req.setTimeout(120000);
                    reqValidador2_2.setBody(bodyValidador2_2);
                    HttpResponse respostValidador2_2 = new HttpResponse();
                    
                    respostValidador2_2 = new Http().send(reqValidador2_2);
                    
                    l0g = l0g + '\n resposta requisicao adicionar validador 2: ' + respostValidador2_2.getBody();
                    
                    string idValidador2 = respostValidador2_2.getBody().substringAfter('request_signature_key":"').substringBefore('","document'); 
                    
                    //Requisição para enviar notificação para o validador 2
                    
                    string bodyValidador2_3 = '{'+
                        +'"request_signature_key": "'+ idValidador2 +'",'+
                        +'"message": "Prezado,\nPor favor assine o documento.\n\nQualquer dúvida estou à disposição.\n\nAtenciosamente,\nHOSPCOM"}';
                    
                    HttpRequest reqValidador2_3 = new HttpRequest();
                    reqValidador2_3.setMethod('POST');
                    reqValidador2_3.setEndpoint('https://app.clicksign.com/api/v1/notifications?access_token=' + token);
                    reqValidador2_3.setHeader('Content-Type', 'application/json');
                    //req.setTimeout(120000);
                    reqValidador2_3.setBody(bodyValidador2_3);
                    HttpResponse respostValidador2_3 = new HttpResponse();
                    
                    respostValidador2_3 = new Http().send(reqValidador2_3);
                    
                    l0g = l0g + '\n resposta requisicao notificar validador 2: ' + respostValidador2_3.getStatus();
                }
                
                //Adicionar o jurídico no processo de assinatura
                string bodyJuridico = '{"list": {"document_key": "'+ keyid +'",'+
                    +'"signer_key": "'+ idSignatarioJuridico +'",'+
                    +'"sign_as": "witness",'+
                    +'"refusable": true,'+
                    +'"group": 3,'+
                    +'"message": "Prezado,\nPor favor assine o documento.\n\nQualquer dúvida estamos à disposição.\n\nAtenciosamente, \nHOSPCOM"}}';
                
                HttpRequest reqJuridico = new HttpRequest();
                reqJuridico.setMethod('POST');
                reqJuridico.setEndpoint('https://app.clicksign.com/api/v1/lists?access_token=' + token);
                reqJuridico.setHeader('Content-Type', 'application/json');
                //req.setTimeout(120000);
                reqJuridico.setBody(bodyJuridico);
                HttpResponse resposJuridico = new HttpResponse();
                
                resposJuridico = new Http().send(reqJuridico);
                
                l0g = l0g + '\n resposta requisicao adicionar juridico: ' + resposJuridico.getBody();
                
                string idAssinaturaJuridico = resposJuridico.getBody().substringAfter('request_signature_key":"').substringBefore('","document');
                
                
                
                //Adicionar o administrativo no processo de assinatura
                string bodyAdm = '{"list": {"document_key": "'+ keyid +'",'+
                    +'"signer_key": "'+ idSignatarioAdm +'",'+
                    +'"sign_as": "party",'+
                    +'"refusable": true,'+
                    +'"group": 3,'+
                    +'"message": "Prezado,\nPor favor assine o documento.\n\nQualquer dúvida estamos à disposição.\n\nAtenciosamente, \nHOSPCOM"}}';
                
                HttpRequest reqAdm = new HttpRequest();
                reqAdm.setMethod('POST');
                reqAdm.setEndpoint('https://app.clicksign.com/api/v1/lists?access_token=' + token);
                reqAdm.setHeader('Content-Type', 'application/json');
                //req.setTimeout(120000);
                reqAdm.setBody(bodyAdm);
                HttpResponse resposAdm = new HttpResponse();
                
                resposAdm = new Http().send(reqAdm);
                
                l0g = l0g + '\n resposta requisicao adicionar adm: ' + resposAdm.getBody();
                
                string idAssinaturaAdm = resposAdm.getBody().substringAfter('request_signature_key":"').substringBefore('","document');
                
                
                try{
                    insert doc;
                }
                catch(DmlException e){
                    if(!Test.isRunningTest())
                        throw new AuraHandledException(e.getMessage());
                }
                
                
                //Cria e carrega um documento com as informações para o log
                Document logDoc = new Document(
                    Name = String.valueOf(System.Now().format('yyyy/MM/dd HH:mm:ss')) + ' - Contrato de Demo/Comodato: ' + contrato.Name,
                    Body = Blob.valueOf(l0g),
                    ContentType = 'text/plain',
                    Type = 'txt',
                    IsPublic = false,
                    IsInternalUseOnly = true,
                    FolderId = '00l6e000002JcWd'        
                );
                insert logDoc;
            }
            else{
                throw new AuraHandledException('Erro de envio, forneça as seguintes informações para o suporte: ' + 'StatusCode: ' + resp.getStatusCode() + '; ResponseBody: ' + resp.getBody() + '');  
            }
        }  
        else{
            throw new AuraHandledException('Erro de envio, forneça as seguintes informações para o suporte: ' + 'StatusCode: ' + resp.getStatusCode() + '; ResponseBody: ' + resp.getBody() + '');  
        }
    }
    @AuraEnabled
    public static void cancelarContratoFornecimento(string idContrato){
        
        Tokens_Clicksign__mdt geral = [SELECT DeveloperName, Token__c FROM Tokens_Clicksign__mdt WHERE DeveloperName ='Geral'];
        
        string token = geral.Token__c;
        
        Contrato_de_Fornecimento_de_Insumo__c contrato = [SELECT ID, idDocAutentique__c
                                                          FROM Contrato_de_Fornecimento_de_Insumo__c 
                                                          WHERE ID =: idContrato];
        
        
        HttpRequest cancela = new HttpRequest();
        cancela.setMethod('PATCH');
        cancela.setEndpoint('https://app.clicksign.com/api/v1/documents/'+ contrato.idDocAutentique__c +'/cancel?access_token=' + token);
        cancela.setHeader('Content-Type', 'application/json');
        cancela.setHeader('Accept', 'application/json');
        
        HttpResponse rCancela = new HttpResponse();
        rCancela = new Http().send(cancela);
        
        
        system.debug(rCancela.getBody());
        Integer statusCode = rCancela.getStatusCode();
        
        if(statusCode == 200){
            contrato.Fase__c = 'Cancelado';
            contrato.idDocAutentique__c = '';
            update contrato;
            
        }
        else{
            throw new AuraHandledException('Erro de cancelamento, forneça as seguintes informações para o suporte: ' + 'StatusCode: ' + statusCode + '; ResponseBody: ' + rCancela.getBody() + '');  
        }
    }
    @AuraEnabled
    public static string consultarContratoFornecimento(string idContrato){
        
        Tokens_Clicksign__mdt geral = [SELECT DeveloperName, Token__c FROM Tokens_Clicksign__mdt WHERE DeveloperName ='Geral'];
        
        string token = geral.Token__c;
        
        Contrato_de_Fornecimento_de_Insumo__c contrato = [SELECT ID, idDocAutentique__c
                                                          FROM Contrato_de_Fornecimento_de_Insumo__c 
                                                          WHERE ID =: idContrato];
        
        string cancelamento = 'Documento consultado as ' ;
        string cancelamento2 = 'Documento consultado as ' ;
        string cancelamento3 = 'Documento consultado as ' ;
        
        HttpRequest consulta = new HttpRequest();
        consulta.setMethod('GET');
        consulta.setEndpoint('https://app.clicksign.com/api/v1/documents/'+ contrato.idDocAutentique__c +'?access_token=' + token);
        consulta.setHeader('Content-Type', 'application/json');
        consulta.setHeader('Accept', 'application/json');
        //req.setTimeout(120000);
        HttpResponse rConsulta = new HttpResponse();
        rConsulta = new Http().send(consulta);
        
        return rConsulta.getBody();  
    }   
}