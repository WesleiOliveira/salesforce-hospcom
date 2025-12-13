public class DocsAutentique {
 
@future(callout=true)
    public static void busca(){
        
        List<Autentique__c> Docs = [SELECT idDocAutentique__c FROM Autentique__c];
        
        Set<String> ids = New Set<String>();
        Set<Id> idNovo = New Set<Id>();
        List<String> idAtt = New List<String>();
        List<String> fases = New List<String>();
        
        for(Autentique__c Aut : Docs){
                ids.add(Aut.idDocAutentique__c);
        }
        
        HttpRequest requ = new HttpRequest();
        requ.setMethod('POST');
        requ.setEndpoint('http://apphospcom.kinghost.net:21220/autentique/status/all');
        requ.setHeader('Content-Type','application/x-www-form-urlencoded;charset=UTF-8');
        requ.setBody('&token=hospcomApiDev!#');
        requ.setTimeout(120000);
        
        HttpResponse respons = new HttpResponse();
        respons = new Http().send(requ);
            
        System.Debug('RESPOSTA' + respons.getBody());
        
        List<Object> deserialized = (List<Object>)JSON.deserializeUntyped(respons.getBody());
            for(Object o: deserialized){
                Map<String, Object> obMap = (Map<String, Object>)o;
              
            String st = obMap.toString();
            String idDoc = st.substringAfter(', id=').substringBefore(', juridico=');
            String fase = st.substringAfter(', fase=').substringBefore(', financeiro');
            String doc = st.substringAfter(', docName=').substringBefore(', fase=');
                            
            system.debug(st);
                
                if(ids.contains(idDoc)){
                    idAtt.add(idDoc);
                    fases.add(fase);
                    //system.debug('true');
                    idAtt.sort();
                }
                else{
                   //system.debug('false');
					Autentique__c novo = new Autentique__c();
                    novo.idDocAutentique__c = idDoc;
                    novo.Nome_do_Documento__c = doc;
                    novo.Fase__c = fase;
                    insert novo;
                }
                
            }            
        
				       
        //idAtt.sort();
        
        system.debug('idatt:' + idAtt);
        
                List<Autentique__c> DocsAtt = [SELECT idDocAutentique__c FROM Autentique__c WHERE idDocAutentique__c IN : idAtt ORDER BY Name];
        //system.debug('docsAtt' + DocsAtt);
        
                integer index = 0;

        for(Autentique__c att : DocsAtt){
            att.Fase__c = fases[index];
            index++;
            update att;
        }

                   //system.debug(DocsAtt);

            }
}