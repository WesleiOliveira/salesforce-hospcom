trigger LinkProposta on Quote (after update) {
    List<Quote> quotesToUpdate = new List<Quote>();  // Lista para armazenar as cotações a serem atualizadas

    // Percorre as cotações que foram atualizadas
    for (Quote q : Trigger.new) {
        Quote oldQuote = Trigger.oldMap.get(q.Id);

        // Verifica se a 'Forma_de_Pagamento__c' foi alterada
        if (q.Forma_de_Pagamento__c != oldQuote.Forma_de_Pagamento__c) {
            try {
                // Obtém a página Visualforce associada à cotação                
                PageReference pdf = Page.CotacaoProposta;  // Certifique-se de que "CotacaoProposta" é a sua página Visualforce
                pdf.getParameters().put('id', q.Id);

                Blob pdfBody;
                String base64PDF;

                if (!Test.isRunningTest()) {
                    pdfBody = pdf.getContentAsPDF();
                    base64PDF = EncodingUtil.base64Encode(pdfBody);
                } else {
                    // Durante os testes, simula o conteúdo PDF
                    pdfBody = Blob.valueOf('Teste');
                    base64PDF = 'TESTE';
                }

                // Cria o ContentVersion para salvar o PDF
                ContentVersion contentVersion = new ContentVersion();
                contentVersion.Title = 'Cotação PDF';
                contentVersion.PathOnClient = 'cotacao.pdf';
                contentVersion.VersionData = pdfBody;
                insert contentVersion;

                // Gera o link público
                ContentDocument contentDocument = [SELECT Id FROM ContentDocument WHERE LatestPublishedVersionId = :contentVersion.Id LIMIT 1];
                String publicLink = '/sfc/servlet.shepherd/document/download/' + contentDocument.Id;

                // Cria um novo registro Quote para atualização
                Quote qClone = new Quote(Id = q.Id);
                qClone.Link_Cotacao__c = publicLink;  // Atualiza o campo Link_Cotacao__c

                quotesToUpdate.add(qClone);  // Adiciona à lista de cotações a serem atualizadas

            } catch (Exception e) {
                // Registra o erro caso haja algum problema
                System.debug('Erro ao gerar PDF para a cotação: ' + e.getMessage());
            }
        }
    }

    // Atualiza as cotações em um único comando após o trigger
    if (!quotesToUpdate.isEmpty()) {
        update quotesToUpdate;  // Atualiza as cotações com o novo link gerado
    }
}