public class SalvaPDFdoPedido {
    @AuraEnabled
    public static void SalvarPdf(String ped_id){
        
        PageReference prop_pag = new PageReference('/apex/Nova_ListagemDeItens');
        prop_pag.getParameters().put('Id', ped_id);
        
        Blob prop_blob = (!Test.isRunningTest() ? prop_pag.getContent() : Blob.valueOf('teste'));
        
        String prop_nome = [SELECT OrderNumber FROM Order WHERE Id = :ped_id].OrderNumber;
        
        ContentVersion prop_ver = new ContentVersion(
            PathOnClient = 'Pedido ' + prop_nome+' ('+System.Now().format('yyyy-MM-dd\' \'hh:mm:ss')+').pdf',
            Title = prop_nome+' ('+System.Now().format('yyyy-MM-dd\' \'hh:mm:ss')+')',
            VersionData = prop_blob
        );
        try{
            insert prop_ver;
        }
        catch(DmlException e){
            throw new AuraHandledException(e.getMessage());
        }
        
        prop_ver = [SELECT contentDocumentId FROM ContentVersion WHERE Id = :prop_ver.Id];
        ContentDocumentLink prop_link = new ContentDocumentLink(
            ContentDocumentId = prop_ver.ContentDocumentId,
            LinkedEntityId = ped_id,
            ShareType = 'I',
            Visibility = 'AllUsers'
        );
        try{
            insert prop_link;		
        }
        catch(DmlException e2){
            throw new AuraHandledException(e2.getMessage());
        }
    }
}