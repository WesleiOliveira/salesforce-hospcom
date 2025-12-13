public class OrdemDeTrabalhoProposta {
        
        public Documento documento {get;set;}
        public WorkOrder ordem_de_trabalho {get;set;}
        public List<Produto> produtos {get;set;}
        
        public OrdemDeTrabalhoProposta(ApexPages.StandardController controlador){
                
                // ordem de trabalho
                ordem_de_trabalho = [
                        SELECT  WorkOrderNumber, GrandTotal, Condicao_de_pagamento__c, Forma_de_pagamento2__c,
                                        Frete2__c, Prazo_de_Entrega__c,  Prazo_de_garantia__c, Data_de_emissao__c, Data_de_validade__c, CurrencyISOCode,
                                        Account.BillingStreet, Account.BillingCity, Account.BillingStateCode, Account.BillingCountry, Account.BillingPostalCode,
                                        Account.ShippingStreet, Account.ShippingCity, Account.ShippingStateCode, Account.ShippingCountry, Account.ShippingPostalCode,
                                        Account.Name, Account.CNPJ__c, Contact.Name, Contact.CPF__c,
                                        Asset.Name, Asset.Marca__c, Asset.Modelo__c, Asset.SerialNumber, Asset.patrimonio__c, 
                                        Faturamento_Feito2__r.CNPJ__c, Faturamento_Feito2__r.Raz_o_Social__c,
                                        Declara_es__c
                        FROM    WorkOrder
                        WHERE   Id = :((SObject)controlador.getRecord()).Id
                ];
                
                // itens
                List<WorkOrderLineItem> itens = [
                        SELECT  Product2.URL_da_Imagem__c, Product2.StockKeepingUnit, Product2.Name, Product2.Modelo__c, 
                                        Product2.Marca__c, UnitPrice, Quantity, Subtotal, Discount, TotalPrice, Item__c, Item_Pai__c,
                                        Description
                        FROM    WorkOrderLineItem
                        WHERE   WorkOrderId = :((SObject)controlador.getRecord()).Id
                        ORDER BY Item__c ASC NULLS LAST
                ];
                
                List<WorkOrderLineItem> itens_ordem = new List<WorkOrderLineItem>();
                for(WorkOrderLineItem item_equip : itens)
                        if(item_equip.Item__c!=null && item_equip.Item_Pai__c==null){
                                itens_ordem.add(item_equip);
                                for(WorkOrderLineItem item_acess : itens)
                                        if(item_acess.Item_Pai__c==item_equip.Item__c)
                                                itens_ordem.add(item_acess);
                        }
                for(WorkOrderLineItem item_vazio : itens)
                        if(item_vazio.Item__c==null && item_vazio.Item_Pai__c==null)
                                itens_ordem.add(item_vazio);
                
                produtos = new List<Produto>();
                Decimal subtotal = 0;
                for(Integer cont=0; cont<itens_ordem.size(); cont++){
                        Produto produto = new Produto(itens_ordem[cont]);
                        subtotal += itens_ordem[cont].TotalPrice;
                        
                        String anterior = (cont==0?null:(itens_ordem[cont-1].Item_Pai__c==null?'equipamento':'acessorio'));
                        String atual = (itens_ordem[cont].Item_Pai__c==null?'equipamento':'acessorio');
                        String proximo = (cont==itens_ordem.size()-1?null:(itens_ordem[cont+1].Item_Pai__c==null?'equipamento':'acessorio'));
                        
                        if((atual=='equipamento'&& proximo=='acessorio') || ((anterior==null||anterior=='acessorio') && (atual=='equipamento' && (proximo=='equipamento'||proximo==null))))
                                produto.cabecalho = true;
                        if((anterior=='equipamento'||anterior=='acessorio') && atual=='acessorio' && (proximo=='equipamento'||proximo==null)){
                                produto.subtotal = ordem_de_trabalho.CurrencyISOCode+' '+String.valueOf(subtotal.format());
                                if(!produto.subtotal.contains(',')) produto.subtotal += ',00';
                                else if(produto.subtotal.substringAfter(',').length()==1) produto.subtotal += '0';
                                subtotal = 0;
                        }
                        
                        produtos.add(produto);
                }
                
                // documento
                documento = new Documento();
                if(ordem_de_trabalho.Faturamento_Feito2__r.CNPJ__c == '27.476.124/0001-02'){
                        documento.timbrado = PageReference.forResource('TimbradoHealth').getUrl();
                        documento.sobre = PageReference.forResource('SobreHealth').getUrl();
                        documento.empresa_nome = 'HEALTH SOLUTION COMERCIO E SERIVÇOS - EIRELE - ME';
                        documento.empresa_dados = 'inscrita no CNPJ sob N° 27.476.124/0001-02, sediada na Rua 89, N° 717, Qd. F45A, Lt. 81/83, Setor Sul, Goiânia - GO, CEP 74093-140';
                        documento.empresa_bancario = 'Banco do Brasil - Agência 1610-1 - Conta Corrente 128.057-0';                       
                }
                else if(ordem_de_trabalho.Faturamento_Feito2__r.CNPJ__c == '23.813.386/0001-56'){
                        documento.timbrado = PageReference.forResource('TimbradoGDB').getUrl();
                        documento.sobre = PageReference.forResource('SobreGDB').getUrl();
                        documento.empresa_nome = 'GDB COMÉRCIO E SERVIÇOS - EIRELI - EPP';
                        documento.empresa_dados = 'inscrita no CNPJ sob N° 23.813.386/0001-56, sediada na Rua Antônio Viera, N° 76, Jardim Bela Vista, Campo Grande - MS, CEP 79003-071';
                        documento.empresa_bancario = 'Banco do Brasil - Agência 1242-4 - Conta Corrente 47391-X';
                }
                else if(ordem_de_trabalho.Faturamento_Feito2__r.CNPJ__c == '05.743.288/0001-08'){
                        documento.timbrado = PageReference.forResource('TimbradoHospcom').getUrl();
                        documento.sobre = PageReference.forResource('SobreHospcom').getUrl();
                        documento.empresa_nome = 'HOSPCOM EQUIPAMENTOS HOSPITALARES - EIRELI';
                        documento.empresa_dados = 'inscrita no CNPJ sob N° 05.743.288/0001-08, sediada na Rua 104, N° 74, Setor Sul, Goiânia - GO, CEP 74083-300';
                        documento.empresa_bancario = 'Banco do Brasil - Agência 1242-4 - Conta Corrente 69869-5';
                }else{
                        documento.timbrado = PageReference.forResource('TimbradoHospcom').getUrl();
                        documento.sobre = PageReference.forResource('SobreHospcom').getUrl();
                        documento.empresa_nome = 'HOSPCOM EQUIPAMENTOS HOSPITALARES - EIRELI';
                        documento.empresa_dados = 'inscrita no CNPJ sob N° 05.743.288/0001-08, sediada na Rua 104, N° 74, Setor Sul, Goiânia - GO, CEP 74083-300';
                }
                
                documento.titulo = 'P  r  o  p  o  s  t  a     d  e     S  e  r  v  i  ç  o';
                
        }
        
        public class Produto{
                public Boolean cabecalho{get;set;}
                public WorkOrderLineItem item{get;set;}
                public String subtotal{get;set;}
                
                public Produto(WorkOrderLineItem item){
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
                
                public Documento(){}
        }
    
}