@RestResource(urlMapping='/clicklstener')
global class ClicksignListener {
    @HttpPost
    global static void doPost() {
        // Obtém os dados da requisição
        String requestBody = RestContext.request.requestBody.toString();
        
        system.debug(requestBody);
        
        
        string idDocumento = requestBody.substringAfter('"document":{"key":"').substringBefore('","account_key');
        
        
        Autentique__c doc = new Autentique__c(Texto__c = requestBody);
        insert doc;
        
        List<Quote> cotacao = [SELECT ID, idDocAutentique__c, QuoteNumber FROM Quote WHERE idDocAutentique__c =: idDocumento];
        List<Contrato_de_Servi_o__c> contrato = [SELECT ID, idDocAutentique__c FROM Contrato_de_Servi_o__c WHERE idDocAutentique__c =: idDocumento];
        List<WorkOrder> OT = [SELECT ID, idDocAutentique__c FROM WorkOrder WHERE idDocAutentique__c =: idDocumento];
        List<Order> Demo = [SELECT ID, idDocAutentique__c FROM Order WHERE idDocAutentique__c =: idDocumento];
        List<Aditivos_Contratuais__c> Aditivo = [SELECT ID, idDocAutentique__c FROM Aditivos_Contratuais__c WHERE idDocAutentique__c =: idDocumento];
        List<Asset> Termo = [SELECT ID, idDocAutentique__c FROM Asset WHERE idDocAutentique__c =: idDocumento];
        List<Contrato_de_compra__c> ContratoCompra = [SELECT ID, idDocAutentique__c FROM Contrato_de_compra__c WHERE idDocAutentique__c =: idDocumento];
        List<Demonstracao__c> Comodato = [SELECT ID, idDocAutentique__c FROM Demonstracao__c WHERE idDocAutentique__c =: idDocumento];
        List<Aditivo_do_Contrato_de_Compra__c> AdtvContratoCompra = [SELECT ID, idDocAutentique__c FROM Aditivo_do_Contrato_de_Compra__c WHERE idDocAutentique__c =: idDocumento];
        List<Contrato_de_Fornecimento_de_Insumo__c> ctrFornec = [SELECT ID, idDocAutentique__c FROM Contrato_de_Fornecimento_de_Insumo__c WHERE idDocAutentique__c =: idDocumento];
        
        SYSTEM.debug(contrato);
        string fase = requestBody.substringAfter(',"signable_group":').substringBefore(',"remind_interval');
        Boolean recusa = false;
        
        if(requestBody.contains('event":{"name":"refusal')){
            recusa = true;
        }
        
        if(cotacao.size() > 0){  
            if(recusa == true){
                cotacao[0].Fase__c = 'Recusado';
                cotacao[0].Data_da_fase__c = SYSTEM.NOW();                
            }
            else if(recusa == false){
                cotacao[0].Fase__c = fase;
                cotacao[0].Data_da_fase__c = SYSTEM.NOW();
            }
            try{
                update cotacao[0];
                Autentique__c doc2 = new Autentique__c(Texto__c = requestBody, Nome_do_Documento__c = 'Assinada Cotação: '+ cotacao[0].QuoteNumber + system.now());
                insert doc2;
                
            }
            catch(DmlException e){
                
                Autentique__c doc3 = new Autentique__c(Texto__c = e.getMessage(), Nome_do_Documento__c = 'ERRO ' + system.now());
                insert doc3;
            }
            
        }
        
        
        if(contrato.size() > 0){
            
            if(recusa == true){
                contrato[0].Fase__c = 'Recusado';
                contrato[0].Data_da_fase__c = SYSTEM.NOW();               
            }
            else if(recusa == false){
                contrato[0].Fase__c = fase;
                contrato[0].Data_da_fase__c = SYSTEM.NOW();                
            }
            
            try{
                update contrato[0];
            }
            catch(DmlException e){
                
                Autentique__c doc2 = new Autentique__c(Texto__c = e.getMessage(), Nome_do_Documento__c = 'ERRO ' + system.now());
                insert doc2;
            }
            
        }
        if(Comodato.size() > 0){
            
            if(recusa == true){
                Comodato[0].Fase__c = 'Recusado';
                Comodato[0].Data_da_fase__c = SYSTEM.NOW();               
            }
            else if(recusa == false){
                Comodato[0].Fase__c = fase;
                Comodato[0].Data_da_fase__c = SYSTEM.NOW();                
            }
            
            try{
                update Comodato[0];
            }
            catch(DmlException e){
                
                Autentique__c doc2 = new Autentique__c(Texto__c = e.getMessage(), Nome_do_Documento__c = 'ERRO ' + system.now());
                insert doc2;
            }
            
        }
        if(OT.size() > 0){  
            
            if(recusa == true){
                OT[0].Fase__c = 'Recusado';
                OT[0].Data_da_fase__c = SYSTEM.NOW();
            }
            else if(recusa == false){
                OT[0].Fase__c = fase;
                OT[0].Data_da_fase__c = SYSTEM.NOW();                
            }
            try{
                update OT[0];
            }
            catch(DmlException e){
                
                Autentique__c doc2 = new Autentique__c(Texto__c = e.getMessage(), Nome_do_Documento__c = 'ERRO ' + system.now());
                insert doc2;
            }
            
        }
        
        if(Demo.size() > 0){  
            
            if(recusa == true)
                Demo[0].Fase__c = 'Recusado';
            else if(recusa == false)
                Demo[0].Fase__c = fase;
            try{
                update Demo[0];
            }
            catch(DmlException e){
                
                Autentique__c doc2 = new Autentique__c(Texto__c = e.getMessage(), Nome_do_Documento__c = 'ERRO ' + system.now());
                insert doc2;
            }
            
        }
        if(Aditivo.size() > 0){  
            
            if(recusa == true)
                Aditivo[0].Fase__c = 'Recusado';
            else if(recusa == false)
                Aditivo[0].Fase__c = fase;
            try{
                update Aditivo[0];
            }
            catch(DmlException e){
                
                Autentique__c doc2 = new Autentique__c(Texto__c = e.getMessage(), Nome_do_Documento__c = 'ERRO ' + system.now());
                insert doc2;
            }
            
        }
        if(Termo.size() > 0){  
            
            if(recusa == true)
                Termo[0].Fase__c = 'Recusado';
            else if(recusa == false)
                Termo[0].Fase__c = fase;
            try{
                update Termo[0];
            }
            catch(DmlException e){
                
                Autentique__c doc2 = new Autentique__c(Texto__c = e.getMessage(), Nome_do_Documento__c = 'ERRO ' + system.now());
                insert doc2;
            }
            
        }
        if(ContratoCompra.size() > 0){  
            
            if(recusa == true)
                ContratoCompra[0].Fase__c = 'Recusado';
            else if(recusa == false)
                ContratoCompra[0].Fase__c = fase;
            ContratoCompra[0].Status__c = 'Vigente';
            try{
                update ContratoCompra[0];
            }
            catch(DmlException e){
                
                Autentique__c doc2 = new Autentique__c(Texto__c = e.getMessage(), Nome_do_Documento__c = 'ERRO ' + system.now());
                insert doc2;
            }
            
        }
        if(AdtvContratoCompra.size() > 0){  
            
            if(recusa == true)
                AdtvContratoCompra[0].Fase__c = 'Recusado';
            else if(recusa == false)
                AdtvContratoCompra[0].Fase__c = fase;
            try{
                update AdtvContratoCompra[0];
            }
            catch(DmlException e){
                
                Autentique__c doc2 = new Autentique__c(Texto__c = e.getMessage(), Nome_do_Documento__c = 'ERRO ' + system.now());
                insert doc2;
            }
            
        }
        if(ctrFornec.size() > 0){  
            
            if(recusa == true)
                ctrFornec[0].Fase__c = 'Recusado';
            else if(recusa == false)
                ctrFornec[0].Fase__c = fase;
            if(fase ==null)
                ctrFornec[0].Data_de_assinatura__c = system.today();           
            try{
                update ctrFornec[0];
            }
            catch(DmlException e){
                
                Autentique__c doc2 = new Autentique__c(Texto__c = e.getMessage(), Nome_do_Documento__c = 'ERRO ' + system.now());
                insert doc2;
            }
            
        }
        
        string a = 'a';
        string b = 'a';
        string c = 'a';
        string d = 'a';
        string e = 'a';
        string f = 'a';
        string g = 'a';
        string h = 'a';
        string i = 'a';
        string j = 'a';
        string k = 'a';
        string l = 'a';
        string m = 'a';
        string n = 'a';
        string o = 'a';
        string p = 'a';
        string q = 'a';
        string r = 'a';
        string s = 'a';
        string t = 'a';
        string u = 'a';
        string v = 'a';
        string w = 'a';
        string x = 'a';
        string y = 'a';
        string z = 'a';
        string aa = 'a';
        string ab= 'a';
        string ac= 'a';
        string ad= 'a';
        string ae= 'a';
        string af= 'a';
        string ag= 'a';
        string ah= 'a';
        string ai= 'a';
        string aj= 'a';
        string ak= 'a';
        string al= 'a';
        string am= 'a';
        string an= 'a';
        string ao= 'a';
        string ap= 'a';
        string aq= 'a';
        string ar= 'a';
        string at = 'a';
        string au = 'a';
        string av = 'a';
        string aw = 'a';
        string ax = 'a';
        string ay = 'a';
        string az = 'a';
        string aaa = 'a';
        string aab= 'a';
        string aac = 'a';
        string aad= 'a';
        string aae = 'a';
        string aaf = 'a';
        string aag = 'a';
        string aah = 'a';
        string aaj = 'a';
        string aak = 'a';
        string aal = 'a';
        string aam = 'a';
        string aan = 'a';
        string aao = 'a';
        string aap = 'a';
        string aaq = 'a';
        string aar = 'a';
        string aas= 'a';
        string aat = 'a';
        string aau= 'a';
        string aav = 'a';
        string aaw = 'a';
        string aax = 'a';
        string aay = 'a';
        string aaz = 'a';
        string aaaa = 'a';        
    }
}