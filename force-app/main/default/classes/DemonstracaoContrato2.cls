public class DemonstracaoContrato2 {
        
        public Documento documento {get;set;}
        public Order pedido {get;set;}
        public List<Produto> produtos {get;set;}
    	public Decimal valorDeVenda {get;set;}
    	public List<Gest_o_de_Documentos__c> documentos { get; set; }
    	
    
        public DemonstracaoContrato2(ApexPages.StandardController controlador){

            
            
		documentos = GestaoDocumentos.obterDocumentosVigentes();
        	// demonstração
                pedido = [
                        SELECT  Account.RecordType.Name, Account.Raz_o_Social__c, Account.Name, Account.CNPJ__c, Account.CPF__pc, Data_da_demonstracao__c,
                    			Tempo_de_demonstracao__c, Faturamento_feito__r.Raz_o_Social__c, Faturamento_feito__r.CNPJ__c, Faturamento_feito__r.BillingCity, 
                    			TotalAmount, BillingStreet, BillingCity, BillingState, BillingPostalCode, Numero_do_Pedido__c, CurrencyISOCode,
                    			Vendedor__r.Contact.cpf__c, Vendedor__r.name, Data_de_termino__c, Natureza_de_Opera_o__c
                        FROM    Order
                        WHERE   Id = :((SObject)controlador.getRecord()).Id
                ];
           
                pedido.Faturamento_feito__r.BillingCity = pedido.Faturamento_feito__r.BillingCity.toLowerCase().Capitalize();
                pedido.BillingState = Util.ConverterEstado(pedido.BillingState, 'sigla');

            	// itens
                List<OrderItem> itens = [
                        SELECT  Product2.URL_da_Imagem__c, Product2.StockKeepingUnit, Product2.Name, Product2.Modelo__c, Quantity, UnitPrice, 
                                Product2.Marca__c, Description, TotalPrice, Item__c, Item_Pai__c, Descricao_da_linha__c, Product2.Valor_de_Venda__c
                        FROM    OrderItem
                        WHERE   OrderId = :((SObject)controlador.getRecord()).Id
                        ORDER BY Item__c ASC NULLS LAST
                ];
            
            AggregateResult[] groupedResults = [SELECT SUM(Product2.Valor_de_Venda__c) sum FROM OrderItem WHERE OrderId = :((SObject)controlador.getRecord()).Id];
            
			valorDeVenda = (Decimal) groupedResults[0].get('sum');
            
                   
                List<OrderItem> itens_ordem = new List<OrderItem>();
                for(OrderItem item_equip : itens)
                        if(item_equip.Item__c!=null && item_equip.Item_Pai__c==null){
                                itens_ordem.add(item_equip);
                                for(OrderItem item_acess : itens)
                                        if(item_acess.Item_Pai__c==item_equip.Item__c)
                                                itens_ordem.add(item_acess);
                        }
                for(OrderItem item_vazio : itens)
                        if(item_vazio.Item__c==null && item_vazio.Item_Pai__c==null)
                                itens_ordem.add(item_vazio);
                
                produtos = new List<Produto>();
                Decimal subtotal = 0;
                for(Integer cont=0; cont<itens_ordem.size(); cont++){
                        Produto produto = new Produto(itens_ordem[cont]);
                        subtotal += itens_ordem[cont].Product2.Valor_de_Venda__c;
                        
                        String anterior = (cont==0?null:(itens_ordem[cont-1].Item_Pai__c==null?'equipamento':'acessorio'));
                        String atual = (itens_ordem[cont].Item_Pai__c==null?'equipamento':'acessorio');
                        String proximo = (cont==itens_ordem.size()-1?null:(itens_ordem[cont+1].Item_Pai__c==null?'equipamento':'acessorio'));
                        
                        if((atual=='equipamento'&& proximo=='acessorio') || ((anterior==null||anterior=='acessorio') && (atual=='equipamento' && (proximo=='equipamento'||proximo==null))))
                                produto.cabecalho = true;
                        if((anterior=='equipamento'||anterior=='acessorio') && atual=='acessorio' && (proximo=='equipamento'||proximo==null)){
                                produto.subtotal = pedido.CurrencyISOCode+' '+String.valueOf(subtotal.format());
                                if(!produto.subtotal.contains(',')) produto.subtotal += ',00';
                                else if(produto.subtotal.substringAfter(',').length()==1) produto.subtotal += '0';
                                subtotal = 0;
                        }
                        
                        produtos.add(produto);
                }
                system.debug(produtos);
                // documento
                documento = new Documento();
                if(pedido.Faturamento_feito__r.CNPJ__c == '27.476.124/0001-02')
                        documento.timbrado = PageReference.forResource('TimbradoHealth').getUrl();
                else if(pedido.Faturamento_feito__r.CNPJ__c == '23.813.386/0001-56')
                        documento.timbrado = PageReference.forResource('TimbradoGDB').getUrl();
                else
                        documento.timbrado = PageReference.forResource('TimbradoHospcom').getUrl();     
                
                /*if(pedido.Tempo_de_demonstracao__c != null){
                    Pattern mypattern = Pattern.compile('^([0-9]+) (dia|dias)$');
                    Matcher mymatcher = mypattern.matcher(pedido.Tempo_de_demonstracao__c);
                    mymatcher.find();
                    if(mymatcher.matches())
                        documento.data_termino = order.Data_da_demonstracao__c.addDays(Integer.valueOf(mymatcher.group(1)));
                }*/
        }
        
        public class Produto{
                public Boolean cabecalho{get;set;}
                public OrderItem item{get;set;}
                public String subtotal{get;set;}
                
                public Produto(OrderItem item){
                        this.cabecalho = false;
                        this.item = item;
                        this.subtotal = null;
                }
        }
    
        public class Documento{
                public String timbrado{get;set;}
                public String data_atual{get;set;}
                public Date data_termino{get;set;}
                
                public Documento(){
                        String  dia = String.valueOf((System.Now()).Day()), 
                                        mes = String.valueOf((System.Now()).Month()), 
                                        ano = String.valueOf((System.Now()).Year());
                        if(mes == '1') mes = 'Janeiro';
                        else if(mes == '2') mes = 'Fevereiro';
                        else if(mes == '3') mes = 'Março';
                        else if(mes == '4') mes = 'Abril';
                        else if(mes == '5') mes = 'Maio';
                        else if(mes == '6') mes = 'Junho';
                        else if(mes == '7') mes = 'Julho';
                        else if(mes == '8') mes = 'Agosto';
                        else if(mes == '9') mes = 'Setembro';
                        else if(mes == '10') mes = 'Outubro';
                        else if(mes == '11') mes = 'Novembro';
                        else if(mes == '12') mes = 'Dezembro';
                        
                        this.data_atual = dia + ' de ' + mes + ' de ' + ano;
                }
        }
 }