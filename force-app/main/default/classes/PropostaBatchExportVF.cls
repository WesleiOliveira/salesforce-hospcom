global class PropostaBatchExportVF implements Database.Batchable<SObject>, Database.Stateful {
    Id quoteId;
    public static Boolean isTestMode = false; // flag
    
    global PropostaBatchExportVF(Id qId){
        this.quoteId = qId;
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator([
            SELECT Id FROM Quote WHERE Id = :quoteId
        ]);
    }
    
    global void execute(Database.BatchableContext bc, List<SObject> scope){
        Blob pdfBlob;
        
        if(isTestMode){
            // Simulação no teste
            pdfBlob = Blob.valueOf('PDF simulado');
        } else {
            // Executa normalmente
            PageReference pdfPage = Page.CotacaoProposta;
            pdfPage.getParameters().put('id', quoteId);
            pdfBlob = pdfPage.getContentAsPDF();
        }
        
        // Salva PDF em Arquivos
        ContentVersion cv = new ContentVersion(
            Title = 'Proposta_' + quoteId,
            PathOnClient = 'Proposta_' + quoteId + '.pdf',
            VersionData = pdfBlob,
            IsMajorVersion = true
        );
        insert cv;
        
        Id docId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId;
        insert new ContentDocumentLink(
            ContentDocumentId = docId,
            LinkedEntityId = quoteId,
            ShareType = 'V'
        );
    }
    
    global void finish(Database.BatchableContext bc){
        System.debug('Exportação concluída para Quote: ' + quoteId);
    }
}