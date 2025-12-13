public class XMLtoPDF {
    @AuraEnabled
    public static String salvaDANFE(string idNota) {
        
        Nota_buscada__c nota = [SELECT ID, XML__c, Natureza_de_operacao__c FROM Nota_buscada__c WHERE ID =: idNota];
        
        string xml = nota.XML__c;
        
        if(nota.Natureza_de_Operacao__c != 'Serviço'){
            
            // Realiza a chamada para a API que retorna o PDF em base64
            HttpRequest req = new HttpRequest();
            req.setEndpoint('https://ws.meudanfe.com/api/v1/get/nfe/xmltodanfepdf/API'); 
            req.setHeader('Content-Type','text/plain'); 
            req.setBody(xml);
            req.setMethod('POST');
            
            Http http = new Http();
            HttpResponse res = http.send(req);
            
            if (res.getStatusCode() == 200) {
                // Limpa a string base64 de possíveis caracteres inválidos
                String base64Pdf = res.getBody().replace('"', '').replace('\n', '').replace('\r', '');
                
                // Decodifica o base64 em um blob
                Blob pdfBlob = EncodingUtil.base64Decode(base64Pdf);
                
                // Cria um novo documento no Salesforce
                Document doc = new Document();
                doc.Name = 'Arquivo PDF NF ' + xml.substringAfter('<nNF>').substringBefore('</nNF>');
                doc.Body = pdfBlob;
                doc.FolderId = '00lU4000007jOzr'; // Salva na pasta
                doc.IsPublic = true; // Deixe público para gerar o link
                doc.ContentType = 'application/pdf';
                insert doc;
                
                
                // Construindo a URL do documento manualmente
                String baseUrl = 'https://' + System.Url.getOrgDomainUrl().getHost();
                String documentUrl = baseUrl + '/servlet/servlet.FileDownload?file=' + doc.Id;
                system.debug('URL: ' + documentUrl);
                nota.Link_PDF__c =  documentUrl;
                update nota;            
                return documentUrl;
                
                
            } else {
                throw new CalloutException('Erro ao buscar o PDF: ' + res.getStatus());
            }
        }
        else{
            string base64Convertido = gerarPDFBase64(xml);
            String base64Pdf = base64Convertido.replace('"', '').replace('\n', '').replace('\r', '');
            
            // Decodifica o base64 em um blob
            Blob pdfBlob = EncodingUtil.base64Decode(base64Pdf);
            // Cria um novo documento no Salesforce
            Document doc = new Document();
            doc.Name = 'Arquivo PDF NFS ' + xml.substringAfter('<Numero>').substringBefore('</Numero>');
            doc.Body = pdfBlob;
            doc.FolderId = '00lU4000007jOzr'; // Salva na pasta
            doc.IsPublic = true; // Deixe público para gerar o link
            doc.ContentType = 'application/pdf';
            insert doc;
            
            // Construindo a URL do documento manualmente
            String baseUrl = 'https://' + System.Url.getOrgDomainUrl().getHost();
            String documentUrl = baseUrl + '/servlet/servlet.FileDownload?file=' + doc.Id;
            system.debug('URL: ' + documentUrl);
            nota.Link_PDF__c =  documentUrl;
            update nota;            
            return documentUrl;
        }
    }
    @AuraEnabled
    public static void lancaNota(string idNota, string idPedido){
        
        Nota_buscada__c nota = [SELECT ID, Name, Chave_de_Acesso__c, Data_de_emissao__c, Valor_da_nota__c, Link_PDF__c, Data_de_vencimento__c FROM Nota_buscada__c WHERE ID =: idNota];
        
        Nota_fiscal_de_pedido_de_compra__c nfpc = new Nota_fiscal_de_pedido_de_compra__c();
        
        nfpc.Name = nota.Name;
        nfpc.Chave_de_Acesso__c = nota.Chave_de_Acesso__c;
        nfpc.Data_de_emissao__c = nota.Data_de_emissao__c;
        nfpc.Data_de_vencimento__c = nota.Data_de_vencimento__c;
        nfpc.Valor_da_nota__c = nota.Valor_da_nota__c;
        nfpc.Pedido_de_Compra__c = idPedido;
        nfpc.URL_Anexo__c = nota.Link_PDF__c;
        
        nota.Lancada__c = true;
        
        try{
            insert nfpc;
            update nota;
        }
        catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static void lancaNotaContrato(string idNota, string idContrato){
        
        Nota_buscada__c nota = [SELECT ID, Name, Chave_de_Acesso__c, Data_de_emissao__c, Valor_da_nota__c, Link_PDF__c, Data_de_vencimento__c FROM Nota_buscada__c WHERE ID =: idNota];
        
        Nota_fiscal_de_compra__c nfpc = new Nota_fiscal_de_compra__c();
        
        nfpc.Name = nota.Name;
        nfpc.Chave_de_Acesso__c = nota.Chave_de_Acesso__c;
        nfpc.Data_de_emissao__c = nota.Data_de_emissao__c;
        nfpc.Data_de_vencimento__c = nota.Data_de_vencimento__c;
        nfpc.Valor_da_nota_fiscal__c = nota.Valor_da_nota__c;
        nfpc.Contrato_de_compra__c = idContrato;
        nfpc.URL_Anexo__c = nota.Link_PDF__c;
        
        nota.Lancada__c = true;
        
        try{
            insert nfpc;
            update nota;
        }
        catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    public static String gerarPDFBase64(String xmlString) {
        
        
        
        String nomePrestador = xmlString.substringAfter('</IdentificacaoPrestador><RazaoSocial>').substringBefore('</RazaoSocial>');
        String cnpjPrestador = xmlString.substringAfter('<IdentificacaoPrestador><CpfCnpj><Cnpj>').substringBefore('</Cnpj>');
        String cnpjPrestadorFormat =  cnpjPrestador.substring(0, 2) + '.' +
            cnpjPrestador.substring(2, 5) + '.' +
            cnpjPrestador.substring(5, 8) + '/' +
            cnpjPrestador.substring(8, 12) + '-' +
            cnpjPrestador.substring(12, 14);
        String enderecoPrestador =  xmlString.substringAfter('<Cep>').substringBefore('</Cep>')  + '/' + xmlString.substringAfter('<Uf>').substringBefore('</Uf>');
        String nomeTomador = xmlString.substringAfter('</IdentificacaoTomador><RazaoSocial>').substringBefore('</RazaoSocial>');
        String cnpjTomador = xmlString.substringAfter('<IdentificacaoTomador><CpfCnpj><Cnpj>').substringBefore('</Cnpj>');
        String cnpjTomadorFormat =  cnpjTomador.substring(0, 2) + '.' +
            cnpjTomador.substring(2, 5) + '.' +
            cnpjTomador.substring(5, 8) + '/' +
            cnpjTomador.substring(8, 12) + '-' +
            cnpjTomador.substring(12, 14);
        String enderecoTomador = '';
        String servico = xmlString.substringAfter('<Discriminacao>').substringBefore('</Discriminacao>');
        String valor = xmlString.substringAfter('<ValorServicos>').substringBefore('</ValorServicos>');
        String nNFSe = xmlString.substringAfter('<Numero>').substringBefore('</Numero>');
        String dataEmissao = xmlString.substringAfter('<DataEmissao>').substringBefore('</DataEmissao>');
        String codigoVerificacao = xmlString.substringAfter('<CodigoVerificacao>').substringBefore('</CodigoVerificacao>');
        
        
        Datetime dt = Date.valueOf(dataEmissao.substringBefore('T'));
        
        // Extrair a data no formato DD/MM/AAAA
        String formattedDate = dt.format('dd/MM/yyyy');
        
        
        // Passando os valores para a página Visualforce
        PageReference pdfPage = Page.GerarPDFXML;
        pdfPage.getParameters().put('prestador', nomePrestador);
        pdfPage.getParameters().put('cnpjPrestador', cnpjPrestadorFormat);
        pdfPage.getParameters().put('enderecoPrestador', enderecoPrestador);
        pdfPage.getParameters().put('tomador', nomeTomador);
        pdfPage.getParameters().put('cnpjTomador', cnpjTomadorFormat);
        pdfPage.getParameters().put('enderecoTomador', enderecoTomador);
        pdfPage.getParameters().put('servico', servico);
        pdfPage.getParameters().put('valor', valor);
        pdfPage.getParameters().put('nNFSe', nNFSe);
        pdfPage.getParameters().put('dataEmissao', formattedDate);
        pdfPage.getParameters().put('codigoVerificacao', codigoVerificacao);
        
        // Geração do PDF
        Blob pdfBlob;
        
        if(!test.isRunningTest()){
           pdfBlob = pdfPage.getContentAsPDF();
        }
        else{
            pdfBlob = Blob.valueOf('Teste');
        }
        
        // Conversão para Base64
        String base64String = EncodingUtil.base64Encode(pdfBlob);
        
        system.debug(base64String);
        return base64String;
    }
}