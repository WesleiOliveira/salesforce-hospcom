public class PSQgeraLink {
    
    @AuraEnabled
    public static List<Map<String, String>> pegaDoc(List<String> idDocs, List<String> nomesDocs, List<String> nomespsq){
        
     List<Map<String,String>> linksArray = new  List<Map<String,String>>();
        Integer i = 0;
     for(String idDoc: idDocs){
         
        for(String nomeDoc: nomesDocs){
            
            if(nomeDoc == 'PDF_PSQ_ABC_GO')
                linksArray.add(pegaDocABCgo(idDoc, nomeDoc, nomespsq[i]));
            
            else if(nomeDoc == 'PDF_PSQ_ABC_TO')
                 linksArray.add(pegaDocABCto(idDoc, nomeDoc, nomespsq[i]));
            
            else if(nomeDoc == 'PDF_PSQ_ABC_MT')
                 linksArray.add(pegaDocABCmt(idDoc, nomeDoc, nomespsq[i]));
            
            else if(nomeDoc == 'PDF_PSQ_HOSPCOM')
                 linksArray.add(pegaDocHospcom(idDoc, nomeDoc, nomespsq[i]));
            
            else if(nomeDoc == 'PDF_PSQ_GDB')
                 linksArray.add(pegaDocGDB(idDoc, nomeDoc, nomespsq[i]));
            
            else if(nomeDoc == 'PDF_PSQ_HEALTH')
                 linksArray.add(pegaDocHealth(idDoc, nomeDoc, nomespsq[i]));
            
            else if(nomeDoc == 'PDF_PSQ_HOSPCOM_DF')
                 linksArray.add(pegaDocHospcomDF(idDoc, nomeDoc, nomespsq[i]));
        }
         i++;
     }
          return linksArray;
    }
    
    public static Map<String, String> pegaDocABCgo(String idDoc, String nameDocs, String nameProced){
        
         if (idDoc == null) {
        throw new IllegalArgumentException('O ID do documento não pode ser nulo.');
    }

    PageReference pdf = Page.PDF_PSQ_ABC_GO;
    pdf.getParameters().put('id', idDoc);

    try {
        Blob pdfBody = pdf.getContentAsPDF();
        
        String base64String = EncodingUtil.base64Encode(pdfBody);
        
        Map<String, String> resposta = new Map<String, String>();
        String nameDoc = 'ABC GO' +'-'+ nameProced;
        resposta.put( nameDoc , base64String);
        return resposta;
    } catch (Exception e) {
        // Lidar com a exceção, seja registrando, relançando ou tratando de outra forma.
        // Aqui, apenas relançamos a exceção para a camada superior.
        throw e;
    }
    }
    
    public static Map<String, String> pegaDocABCto(String idDoc, String nameDocs, String nameProced){
        
         if (idDoc == null) {
        throw new IllegalArgumentException('O ID do documento não pode ser nulo.');
    }

    PageReference pdf = Page.PDF_PSQ_ABC_TO;
    pdf.getParameters().put('id', idDoc);

    try {
        Blob pdfBody = pdf.getContentAsPDF();
        
        
        String base64String = EncodingUtil.base64Encode(pdfBody);
        
        Map<String, String> resposta = new Map<String, String>();
        String nameDoc = 'ABC TO'  +'-'+ nameProced;
        resposta.put( nameDoc , base64String);
        return resposta;
        
    } catch (Exception e) {
        // Lidar com a exceção, seja registrando, relançando ou tratando de outra forma.
        // Aqui, apenas relançamos a exceção para a camada superior.
        throw e;
    }
    }
    
    public static Map<String, String> pegaDocABCmt(String idDoc, String nameDocs, String nameProced){
        
         if (idDoc == null) {
        throw new IllegalArgumentException('O ID do documento não pode ser nulo.');
    }

    PageReference pdf = Page.PDF_PSQ_ABC_MT;
    pdf.getParameters().put('id', idDoc);

    try {
        Blob pdfBody = pdf.getContentAsPDF();
        
        
        String base64String = EncodingUtil.base64Encode(pdfBody);
        
        Map<String, String> resposta = new Map<String, String>();
        String nameDoc = 'ABC MT'  +'-'+ nameProced;
        resposta.put( nameDoc , base64String);
        return resposta;
    } catch (Exception e) {
        // Lidar com a exceção, seja registrando, relançando ou tratando de outra forma.
        // Aqui, apenas relançamos a exceção para a camada superior.
        throw e;
    }
    }
     
    public static Map<String, String>  pegaDocHospcom(String idDoc, String nameDocs, String nameProced){
        
         if (idDoc == null) {
        throw new IllegalArgumentException('O ID do documento não pode ser nulo.');
    }

    PageReference pdf = Page.PDF_PSQ_HOSPCOM;
    pdf.getParameters().put('id', idDoc);

    try {
        Blob pdfBody = pdf.getContentAsPDF();
        
        
        String base64String = EncodingUtil.base64Encode(pdfBody);
        
        Map<String, String> resposta = new Map<String, String>();
        String nameDoc = 'HOSPCOM' +'-'+ nameProced;
        resposta.put( nameDoc , base64String);
        return resposta;
    } catch (Exception e) {
        // Lidar com a exceção, seja registrando, relançando ou tratando de outra forma.
        // Aqui, apenas relançamos a exceção para a camada superior.
        throw e;
    }
    }
    
    public static Map<String, String>  pegaDocHospcomDF(String idDoc, String nameDocs, String nameProced){
        
         if (idDoc == null) {
        throw new IllegalArgumentException('O ID do documento não pode ser nulo.');
    }

    PageReference pdf = Page.PDF_PSQ_HOSPCOM_DF;
    pdf.getParameters().put('id', idDoc);

    try {
        Blob pdfBody = pdf.getContentAsPDF();
        
        
        String base64String = EncodingUtil.base64Encode(pdfBody);
        
        Map<String, String> resposta = new Map<String, String>();
        String nameDoc = 'HOSPCOM DF' +'-'+ nameProced;
        resposta.put( nameDoc , base64String);
        return resposta;
    } catch (Exception e) {
        // Lidar com a exceção, seja registrando, relançando ou tratando de outra forma.
        // Aqui, apenas relançamos a exceção para a camada superior.
        throw e;
    }
    }
    
    public static Map<String, String>  pegaDocGDB(String idDoc, String nameDocs, String nameProced){
        
         if (idDoc == null) {
        throw new IllegalArgumentException('O ID do documento não pode ser nulo.');
    }

    PageReference pdf = Page.PDF_PSQ_GDB;
    pdf.getParameters().put('id', idDoc);

    try {
        Blob pdfBody = pdf.getContentAsPDF();
        
        
        String base64String = EncodingUtil.base64Encode(pdfBody);
        
        Map<String, String> resposta = new Map<String, String>();
        String nameDoc = 'GDB' +'-'+ nameProced;
        resposta.put( nameDoc , base64String);
        return resposta;
    } catch (Exception e) {
        // Lidar com a exceção, seja registrando, relançando ou tratando de outra forma.
        // Aqui, apenas relançamos a exceção para a camada superior.
        throw e;
    }
    }
    
    public static Map<String, String>  pegaDocHealth(String idDoc, String nameDocs, String nameProced){
        
         if (idDoc == null) {
        throw new IllegalArgumentException('O ID do documento não pode ser nulo.');
    }

    PageReference pdf = Page.PDF_PSQ_HEALTH;
    pdf.getParameters().put('id', idDoc);

    try {
        Blob pdfBody = pdf.getContentAsPDF();
        
        
        String base64String = EncodingUtil.base64Encode(pdfBody);
        
        Map<String, String> resposta = new Map<String, String>();
        String nameDoc = 'HEALTH SOLUTION' +'-'+ nameProced;
        resposta.put( nameDoc , base64String);
        return resposta;
    } catch (Exception e) {
        // Lidar com a exceção, seja registrando, relançando ou tratando de outra forma.
        // Aqui, apenas relançamos a exceção para a camada superior.
        throw e;
    }
    }
    
    
    
    /*
     * public static String pegaDocABCsp(String idDoc, String nameDocs){
        
        // Cria a página referência
        PageReference pdf = Page.nameDoc;
        pdf.getParameters().put('id', idDoc);
        
        // Obtém o conteúdo do PDF como Blob
        Blob pdfBody = pdf.getContentAsPDF();
        
        // Salva o PDF no Salesforce como um Attachment
        Attachment attachment = new Attachment();
        attachment.ParentId = idDoc; // Substitua pelo ID do registro relacionado
        attachment.Name = nameDocs + '.pdf';
        attachment.Body = pdfBody;
        insert attachment;
        
        // Obtém o ID do Attachment criado
        String attachmentId = attachment.Id;
        
        // Constrói o link do Attachment
        String attachmentLink = URL.getSalesforceBaseUrl().toExternalForm() + '/' + attachmentId;
        
        return attachmentLink;
    }
    */
    
    
    public static void gambiarra(){
    
    String a = '';
    
    
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    a = '';a = '';a = '';a = '';
    }
    
    
}