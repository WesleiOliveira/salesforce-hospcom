public with sharing class CotacaoBotoes {
    
    
    @AuraEnabled
    public static Boolean validaStatus(String cot_id){
        Quote cotacao = [
        SELECT Status
        FROM Quote 
        WHERE Id = :cot_id
    ];
        
        return cotacao.Status != 'Rascunho' &&
            cotacao.Status != 'Aguardando Aprovação' &&
            cotacao.Status != 'Reprovado';
    }
    
    @AuraEnabled
    public static String ValidarPreenchimento(String cot_id){
        String retorno='';
        List<String> erros = new List<String>();
        
        // campos
        Quote cotacao = [
            SELECT  Forma_de_pagamento__c, Tem_entrada__c, Condicao_de_pagamento__c, Frete__c, Prazo_de_Entrega__c, Prazo_de_garantia__c, ContactId, Prazo_de_garantia_dos_equipamentos__c, Prazo_de_garantia_acessorios__c,
                    ExpirationDate, Contact.CPF__c, Account.NIT__c, Account.CNPJ__c, Account.RG__pc, OpportunityId, Opportunity.RecordType.Name,(
                        SELECT  Id
                        FROM    QuoteLineItems
                    )
            FROM    Quote 
            WHERE   Id = :cot_id
        ];
        if(cotacao.Condicao_de_pagamento__c==null)
            erros.add('Condição de pagamento');
        if(cotacao.Frete__c==null)
            erros.add('Tipo de envio');
        if(cotacao.Tem_entrada__c==null)
            erros.add('Tem entrada');
        if(cotacao.Prazo_de_garantia__c==null)
            erros.add('Prazo de garantia');
        if(cotacao.ContactId==null)
            erros.add('Nome do contato');
        if(cotacao.Prazo_de_garantia_dos_equipamentos__c==null)
            erros.add('Prazo de garantia dos equipamentos');
        if(cotacao.Prazo_de_garantia_acessorios__c==null)
            erros.add('Prazo de garantia dos acessórios');
        if(cotacao.Account.CNPJ__c==null && cotacao.Account.RG__pc==null && cotacao.Account.NIT__c ==null)
            erros.add('RG do cliente');
        //if(cotacao.Account.NIT__c == null && cotacao.Contact.CPF__c == null)
        //erros.add('CPF do cliente');
        if(erros.size()>0)
            retorno += '<br/> - Preencha os campos: ' + String.join(erros, ', ') + '.';
        
        // produtos
        if(cotacao.QuoteLineItems.size()==0)
            retorno += '<br/> - Adicione produtos na Cotação.';
        
        if(cotacao.ExpirationDate < system.today())
            retorno += '<br/> A data de validade não pode ser inferior à data de hoje.';
        
        // signatario
        if(cotacao.Opportunity.RecordType.Name=='Licitação'){
            List<OpportunityContactRole> signatario = [
                SELECT  Id
                FROM    OpportunityContactRole
                WHERE   Role = 'Signatário da proposta (Hospcom)' AND
                        OpportunityId = :cotacao.OpportunityId
                ORDER BY LastModifiedDate DESC
                LIMIT   1
            ];
            if(signatario.size()!=1)
                retorno += '<br/> - Atribua um signatário à oportunidade.';
        }
        
        // mensagem
        if(retorno!='')
            retorno = 'Revise os seguintes pontos para gerar a proposta: ' + retorno;
        
        return retorno;
    }
    
    @AuraEnabled
    public static Boolean VerificarLicitacao(String cot_id){
        return ([SELECT Opportunity.RecordType.Name FROM Quote WHERE Id = :cot_id].Opportunity.RecordType.Name=='Licitação')?true:false;
    }
    
    @AuraEnabled
    public static void SalvarPdfProposta(String cot_id){
        
        PageReference prop_pag = new PageReference('/apex/CotacaoProposta');
        prop_pag.getParameters().put('Id', cot_id);
        
        Blob prop_blob = (!Test.isRunningTest() ? prop_pag.getContent() : Blob.valueOf('teste'));
        
        String prop_nome = [SELECT Name FROM Quote WHERE Id = :cot_id].Name;
        
        ContentVersion prop_ver = new ContentVersion(
            PathOnClient = prop_nome+' ('+System.Now().format('yyyy-MM-dd\' \'hh:mm:ss')+').pdf',
        Title = prop_nome+' ('+System.Now().format('yyyy-MM-dd\' \'hh:mm:ss')+')',
        VersionData = prop_blob
            );
        insert prop_ver;
        
        prop_ver = [SELECT contentDocumentId FROM ContentVersion WHERE Id = :prop_ver.Id];
        ContentDocumentLink prop_link = new ContentDocumentLink(
            ContentDocumentId = prop_ver.ContentDocumentId,
        LinkedEntityId = cot_id,
        ShareType = 'I',
        Visibility = 'AllUsers'
            );
        insert prop_link;
    }
    
    @AuraEnabled
    public static void SalvarPdfCotacao(String cot_id){
        
        PageReference prop_pag = new PageReference('/apex/CotacaoContrato');
        prop_pag.getParameters().put('Id', cot_id);
        
        Blob prop_blob = (!Test.isRunningTest() ? prop_pag.getContent() : Blob.valueOf('teste'));
        
        String prop_nome = [SELECT Name FROM Quote WHERE Id = :cot_id].Name;
        
        ContentVersion prop_ver = new ContentVersion(
            PathOnClient = prop_nome+' ('+System.Now().format('yyyy-MM-dd\' \'hh:mm:ss')+').pdf',
        Title = prop_nome+' ('+System.Now().format('yyyy-MM-dd\' \'hh:mm:ss')+')',
        VersionData = prop_blob
            );
        insert prop_ver;
        
        prop_ver = [SELECT contentDocumentId FROM ContentVersion WHERE Id = :prop_ver.Id];
        ContentDocumentLink prop_link = new ContentDocumentLink(
            ContentDocumentId = prop_ver.ContentDocumentId,
        LinkedEntityId = cot_id,
        ShareType = 'I',
        Visibility = 'AllUsers'
            );
        insert prop_link;
    }
}