public class NovaPropostaGoverno {
    
    public Documento documento {get;set;}
    public Opportunity oportunidade {get;set;}
    public List<Produto> produtos {get;set;}
    public List<OpportunityLineItem> itens_Filhos {get;set;}
    
    public NovaPropostaGoverno(ApexPages.StandardController controlador){
        
        // cotação
        oportunidade = [
            SELECT  Numero_OP__c, Amount, Condicao_de_pagamento__c, Forma_de_pagamento2__c, Numero_de_prestacoes__c, 
            Frete__c, Prazo_de_Entrega__c,  Prazo_de_garantia__c, Data_de_emissao__c, Data_de_Validade__c, CurrencyISOCode,
            Nome_da_Referencia_de_Faturamento__c, Account.BillingStreet, Account.BillingCity, Account.BillingStateCode, Account.BillingCountry, Account.BillingPostalCode,
            Nome_de_destino__c, Account.ShippingStreet, Account.ShippingCity, Account.ShippingStateCode, Account.ShippingCountry, Account.ShippingPostalCode,
            Account.RecordType.Name, Account.Name, Account.CNPJ__c, Contato__r.Name, Contato__r.CPF__c, Prazo_de_garantia_acessorios__c, Prazo_de_garantia_dos_equipamentos__c,
            Owner.Name, Owner.Title, Owner.Email, Owner.Phone,
            Faturamento_Feito2__r.CNPJ__c, Faturamento_Feito2__r.Raz_o_Social__c,
            RecordType.Name, RecordType.DeveloperName, Name, Processo__c, Modalidade__c,
            Declara_es__c, Data_da_Abertura__c
            FROM    Opportunity
            WHERE   Id = :((SObject)controlador.getRecord()).Id
        ];
        
        
        List<String> garantias = new List<String>();
        Pattern mypattern = Pattern.compile('^([^0-9]+) ([0-9]+) (mês|meses)$');
        for(String garantia : oportunidade.Prazo_de_garantia__c.toLowerCase().split('\\,')){
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
            oportunidade.Prazo_de_garantia__c = String.join(garantias, ', ');
        
        // itens
        List<OpportunityLineItem> itens = [
            SELECT  Product2.URL_da_Imagem__c, Product2.StockKeepingUnit, Product2.Name, Product2.Modelo__c, Subtotal__c, Subtotal_Unit__c,
            Product2.Marca__c, UnitPrice, Quantity, Subtotal, Discount, TotalPrice, Item__c, Item_Pai__c,
            Lote__c, Descricao_do_Especialista__c, Product2.Numero_Anvisa__c, Valor_Unit_C_Desconto__c, Ordem__c, Item_do_edital__c, Perdido__c
            FROM    OpportunityLineItem
            WHERE   OpportunityId = :((SObject)controlador.getRecord()).Id
            ORDER BY ordem__c ASC NULLS LAST
        ];
        
        itens_Filhos = [
            SELECT  Product2.URL_da_Imagem__c, Product2.StockKeepingUnit, Product2.Name, Product2.Modelo__c, Subtotal__c, Subtotal_Unit__c,
            Product2.Marca__c, UnitPrice, Quantity, Subtotal, Discount, TotalPrice, Item__c, Item_Pai__c,
            Lote__c, Descricao_do_Especialista__c, Product2.Numero_Anvisa__c, Valor_Unit_C_Desconto__c, Ordem__c, Item_do_edital__c, Perdido__c
            FROM    OpportunityLineItem
            WHERE   OpportunityId = :((SObject)controlador.getRecord()).Id AND Item_pai__c != null AND Item_pai__c != 0
            ORDER BY ordem__c ASC NULLS LAST
        ];
        
        List<OpportunityLineItem> itens_ordem = new List<OpportunityLineItem>();
        for(OpportunityLineItem item_equip : itens)
            if(item_equip.Item__c!=null && item_equip.Item_Pai__c==null){
                itens_ordem.add(item_equip);
                for(OpportunityLineItem item_acess : itens)
                    if(item_acess.Item_Pai__c==item_equip.Item__c)
                    itens_ordem.add(item_acess);
            }
        for(OpportunityLineItem item_sobra : itens)
            if(!itens_ordem.contains(item_sobra)){
                item_sobra.Item__c = null;
                item_sobra.item_pai__c = null;
                itens_ordem.add(item_sobra);
            }
        
        for(OpportunityLineItem pai : itens){
            Decimal sub = 0;
            for(OpportunityLineItem filho : itens_Filhos){
                if(filho.Item_Pai__c == pai.Item__c){
                    sub = sub + filho.TotalPrice;
                }
            }
            pai.Subtotal_Unit__c = (sub + pai.TotalPrice)/pai.Quantity;
            pai.Subtotal__c = (sub + pai.TotalPrice);
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
                produto.subtotal = oportunidade.CurrencyISOCode+' '+String.valueOf(subtotal.format());
                if(!produto.subtotal.contains(',')) produto.subtotal += ',00';
                else if(produto.subtotal.substringAfter(',').length()==1) produto.subtotal += '0';
                subtotal = 0;
            }
            
            produtos.add(produto);
        }
        
        // documento
        documento = new Documento();
        documento.titulo = 'P  r  o  p  o  s  t  a       d  e       G  o  v  e  r  n  o';
        
        if(oportunidade.Faturamento_Feito2__r.CNPJ__c == '27.476.124/0001-02'){
            documento.timbrado = PageReference.forResource('TimbradoHealth').getUrl();
            documento.sobre = PageReference.forResource('SobreHealth').getUrl();
            documento.empresa_bancario = 'Banco do Brasil - Agência 1242-4 - Conta Corrente 47391-X';                       
        }
        else if(oportunidade.Faturamento_Feito2__r.CNPJ__c == '23.813.386/0001-56'){
            documento.timbrado = PageReference.forResource('TimbradoGDB').getUrl();
            documento.sobre = PageReference.forResource('SobreGDB').getUrl();
            documento.empresa_bancario = 'Banco do Brasil - Agência 1610-1 - Conta Corrente 128.057-0';
        }
        else if(oportunidade.Faturamento_Feito2__r.CNPJ__c == '05.743.288/0001-08'){
            documento.timbrado = PageReference.forResource('TimbradoHospcom').getUrl();
            documento.sobre = PageReference.forResource('SobreHospcom').getUrl();
            documento.empresa_bancario = 'Banco do Brasil - Agência 1242-4 - Conta Corrente 69869-5';
        }
        else if(oportunidade.Faturamento_Feito2__r.CNPJ__c == '40.014.621/0001-49'){
            documento.timbrado = PageReference.forResource('TimbradoABC').getUrl();
            documento.sobre = PageReference.forResource('SobreABC').getUrl();
            documento.empresa_bancario = 'Banco do Brasil - Agência 1242-4 - Conta Corrente 48068-1';
        }       
        else{
            documento.timbrado = PageReference.forResource('TimbradoHospcom').getUrl();
            documento.sobre = PageReference.forResource('SobreHospcom').getUrl();
        }
        
        
        List<OpportunityContactRole> signatario = [
            SELECT  Contact.Name, Contact.RG__c, Contact.CPF__c
            FROM    OpportunityContactRole
            WHERE   Role = 'Signatário da proposta (Hospcom)' AND
            OpportunityId = :oportunidade.Id
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
        public OpportunityLineItem item{get;set;}
        public String subtotal{get;set;}
        
        public Produto(OpportunityLineItem item){
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
    public String formatarNumero(Decimal valor) {
        return String.valueOf(valor).replace(',', '.');
    }
    
}