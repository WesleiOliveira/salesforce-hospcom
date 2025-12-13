public class CotacaoProposta {
        
        public Documento documento {get;set;}
        public Quote cotacao {get;set;}
        public List<Produto> produtos {get;set;}
        
        public CotacaoProposta(ApexPages.StandardController controlador){
                
                // cotação
                cotacao = [
                        SELECT  QuoteNumber, ShippingHandling, GrandTotal, Condicao_de_pagamento__c, Forma_de_pagamento__c, Numero_de_prestacoes__c, 
                                        Frete__c, Prazo_de_Entrega__c,  Prazo_de_garantia__c, Data_de_emissao__c, ExpirationDate, CurrencyISOCode,
                                        BillingName, BillingStreet, BillingCity, BillingStateCode, BillingCountry, BillingPostalCode,
                                        ShippingName, ShippingStreet, ShippingCity, ShippingStateCode, ShippingCountry, ShippingPostalCode,
                                        Account.RecordType.Name, Account.Name, Account.CNPJ__c, Contact.Name, Contact.CPF__c, Prazo_de_garantia_acessorios__c, Prazo_de_garantia_dos_equipamentos__c,
                                        Opportunity.Owner.Name, Opportunity.Owner.Title, Opportunity.Owner.Email, Opportunity.Owner.Phone,
                                        Opportunity.Faturamento_Feito2__r.CNPJ__c, Opportunity.Faturamento_Feito2__r.Raz_o_Social__c,
                                        Opportunity.RecordType.Name,Opportunity.RecordType.DeveloperName, Opportunity.Name, Opportunity.Processo__c, Opportunity.Modalidade__c,
                                        Opportunity.Declara_es__c, Opportunity.Data_da_Abertura__c, OpportunityId, Opportunity.Account.NIT__c
                        FROM    Quote
                        WHERE   Id = :((SObject)controlador.getRecord()).Id
                ];
                
                List<String> garantias = new List<String>();
                Pattern mypattern = Pattern.compile('^([^0-9]+) ([0-9]+) (mês|meses)$');
                for(String garantia : cotacao.Prazo_de_garantia__c.toLowerCase().split('\\,')){
                        Matcher mymatcher = mypattern.matcher(garantia.normalizeSpace());
                        mymatcher.find();
                        if(mymatcher.matches()){
                                String obs = '';
                                if(mymatcher.group(1).contains('peça') || mymatcher.group(1).contains('peca'))
                                        obs = ' (caso a mesma seja substituida via assistência autorizada Hospcom)';
                                garantias.add(mymatcher.group(2) +' '+mymatcher.group(3)+' para '+mymatcher.group(1)+obs);
                        }
                }
                if(garantias.size()>0)
                        cotacao.Prazo_de_garantia__c = String.join(garantias, ', ');
                
                // itens
                List<QuoteLineItem> itens = [
                        SELECT  Product2.URL_da_Imagem__c, Product2.StockKeepingUnit, Product2.Name, Product2.Modelo__c, 
                                        Product2.Marca__c, UnitPrice, Quantity, Subtotal, Discount, TotalPrice, Item__c, Item_Pai__c,
                                        Lote__c, Descricao_da_linha__c, Product2.Numero_Anvisa__c, Valor_Unit_C_Desconto__c, Ordem__c
                        FROM    QuoteLineItem
                        WHERE   QuoteId = :((SObject)controlador.getRecord()).Id
                        ORDER BY ordem__c ASC NULLS LAST
                ];
                
                List<QuoteLineItem> itens_ordem = new List<QuoteLineItem>();
                for(QuoteLineItem item_equip : itens)
                        if(item_equip.Item__c!=null && item_equip.Item_Pai__c==null){
                                itens_ordem.add(item_equip);
                                for(QuoteLineItem item_acess : itens)
                                        if(item_acess.Item_Pai__c==item_equip.Item__c)
                                                itens_ordem.add(item_acess);
                        }
                for(QuoteLineItem item_sobra : itens)
                        if(!itens_ordem.contains(item_sobra)){
                                item_sobra.Item__c = null;
                                item_sobra.item_pai__c = null;
                                itens_ordem.add(item_sobra);
                        }
                
                produtos = new List<Produto>();
                Decimal subtotal = 0;
                for(Integer cont=0; cont<itens_ordem.size(); cont++){
                        Produto produto = new Produto(itens_ordem[cont]);
                        subtotal += itens_ordem[cont].TotalPrice;
                        
                        String anterior = (cont==0?null:(itens_ordem[cont-1].Item_Pai__c==null || (itens_ordem[cont-1].Item__c==null && itens_ordem[cont-1].Item_Pai__c==null)?'equipamento':'acessorio'));
                        String atual = (itens_ordem[cont].Item_Pai__c==null || (itens_ordem[cont].Item__c==null && itens_ordem[cont].Item_Pai__c==null)?'equipamento':'acessorio');
                        String proximo = (cont==itens_ordem.size()-1?null:(itens_ordem[cont+1].Item_Pai__c==null || (itens_ordem[cont+1].Item__c==null && itens_ordem[cont+1].Item_Pai__c==null)?'equipamento':'acessorio'));
                        
                        if((atual=='equipamento'&& proximo=='acessorio') || ((anterior==null||anterior=='acessorio') && (atual=='equipamento' && (proximo=='equipamento'||proximo==null))))
                                produto.cabecalho = true;
                        if(proximo=='equipamento'||proximo==null){
                                produto.subtotal = cotacao.CurrencyISOCode+' '+String.valueOf(subtotal.format());
                                if(!produto.subtotal.contains(',')) produto.subtotal += ',00';
                                else if(produto.subtotal.substringAfter(',').length()==1) produto.subtotal += '0';
                                subtotal = 0;
                        }
                        
                        produtos.add(produto);
                }
                
                // documento
                documento = new Documento();
                if(cotacao.Opportunity.Faturamento_Feito2__r.CNPJ__c == '27.476.124/0001-02'){
                        documento.timbrado = PageReference.forResource('TimbradoHealth').getUrl();
                        documento.sobre = PageReference.forResource('SobreHealth').getUrl();
                        documento.empresa_nome = 'HEALTH SOLUTION COMERCIO E SERIVÇOS - EIRELE - ME';
                        documento.empresa_dados = 'inscrita no CNPJ sob N° 27.476.124/0001-02, sediada na Rua 89, N° 717, Qd. F45A, Lt. 81/83, Setor Sul, Goiânia - GO, CEP 74093-140';
                        documento.empresa_bancario = 'Banco do Brasil - Agência 1242-4 - Conta Corrente 47391-X';                       
                }
                else if(cotacao.Opportunity.Faturamento_Feito2__r.CNPJ__c == '23.813.386/0001-56'){
                        documento.timbrado = PageReference.forResource('TimbradoGDB').getUrl();
                        documento.sobre = PageReference.forResource('SobreGDB').getUrl();
                        documento.empresa_nome = 'GDB COMÉRCIO E SERVIÇOS - EIRELI - EPP';
                        documento.empresa_dados = 'inscrita no CNPJ sob N° 23.813.386/0001-56, sediada na Rua Antônio Viera, N° 76, Jardim Bela Vista, Campo Grande - MS, CEP 79003-071';    
                        documento.empresa_bancario = 'Banco do Brasil - Agência 1610-1 - Conta Corrente 128.057-0';
                }
                else if(cotacao.Opportunity.Faturamento_Feito2__r.CNPJ__c == '05.743.288/0001-08'){
                        documento.timbrado = PageReference.forResource('TimbradoHospcom').getUrl();
                        documento.sobre = PageReference.forResource('SobreHospcom').getUrl();
                        documento.empresa_nome = 'HOSPCOM EQUIPAMENTOS HOSPITALARES - EIRELI';
                        documento.empresa_dados = 'inscrita no CNPJ sob N° 05.743.288/0001-08, sediada na Rua 104, N° 74, Setor Sul, Goiânia - GO, CEP 74083-300';
                        documento.empresa_bancario = 'Banco do Brasil - Agência 1242-4 - Conta Corrente 69869-5';
                }
            	else if(cotacao.Opportunity.Faturamento_Feito2__r.CNPJ__c == '40.014.621/0001-49'){
                        documento.timbrado = PageReference.forResource('TimbradoABC').getUrl();
                        documento.sobre = PageReference.forResource('SobreABC').getUrl();
                        documento.empresa_nome = 'ABC EQUIPAMENTOS HOSPITALARES EIRELI';
                        documento.empresa_dados = 'inscrita no CNPJ sob N° 40.014.621/0001-49, sediada na Rua SO 11, N° 47, Sala 02 Conj 03, Plano Diretor SU';
                        documento.empresa_bancario = 'Banco do Brasil - Agência 1242-4 - Conta Corrente 48068-1';
                }
            
            	else{
                        documento.timbrado = PageReference.forResource('TimbradoHospcom').getUrl();
                        documento.sobre = PageReference.forResource('SobreHospcom').getUrl();
                        documento.empresa_nome = 'HOSPCOM EQUIPAMENTOS HOSPITALARES - EIRELI';
                        documento.empresa_dados = 'inscrita no CNPJ sob N° 05.743.288/0001-08, sediada na Rua 104, N° 74, Setor Sul, Goiânia - GO, CEP 74083-300';
                }
                
                
                if(cotacao.Opportunity.RecordType.Name == 'Comercial')
                        documento.titulo = 'P  r  o  p  o  s  t  a     C  o  m  e  r  c  i  a  l';
                else if(cotacao.Opportunity.RecordType.Name == 'Licitação')
                        documento.titulo = 'P  r  o  p  o  s  t  a       d  e       G  o  v  e  r  n  o';
                
                List<OpportunityContactRole> signatario = [
                        SELECT  Contact.Name, Contact.RG__c, Contact.CPF__c
                        FROM    OpportunityContactRole
                        WHERE   Role = 'Signatário da proposta (Hospcom)' AND
                                        OpportunityId = :cotacao.OpportunityId
                        ORDER BY LastModifiedDate DESC
                        LIMIT   1
                ];
                if(signatario.size()==1){
                        documento.ass_nome = signatario[0].Contact.Name;
                        documento.ass_rg = signatario[0].Contact.RG__c;
                        documento.ass_cpf = signatario[0].Contact.CPF__c;
                }
                
        }
        
        public class Produto{
                public Boolean cabecalho{get;set;}
                public QuoteLineItem item{get;set;}
                public String subtotal{get;set;}
                
                public Produto(QuoteLineItem item){
                        this.cabecalho = false;
                        this.item = item;
                        this.subtotal = null;
                }
        }
    
        public class Documento{
                public String timbrado{get;set;}
                public String sobre{get;set;}
                public String titulo{get;set;}
                public String empresa_nome {get;set;}
                public String empresa_dados {get;set;}
                public String empresa_bancario {get;set;}
                public String ass_nome {get;set;}
                public String ass_rg {get;set;}
                public String ass_cpf {get;set;}
                
                public Documento(){}
        }
    
}