public class DemonstracaoContrato {
    
    public Documento documento {get;set;}
    public Demonstracao__c demonstracao {get;set;}
    public List<Produto> produtos {get;set;}
    public string cpfTestemunha {get;set;}
    
    public DemonstracaoContrato(ApexPages.StandardController controlador){
        
        
        // demonstração
        demonstracao = [
            SELECT  Conta__r.RecordType.Name, Conta__r.Raz_o_Social__c, Conta__r.Name, Conta__r.CNPJ__c, Conta__r.CPF__pc, 
            Data_prevista__c, Tempo_de_demonstracao__c, Fornecedor__r.Raz_o_Social__c, Testemunha__r.CPF__c, Testemunha__r.AccountId, Testemunha__c,
            Fornecedor__r.CNPJ__c, Fornecedor__r.BillingCity, Valor_total__c, Rua__c, Cidade__c, Estado__c, CEP__c, 
            CurrencyISOCode
            FROM    Demonstracao__c
            WHERE   Id = :((SObject)controlador.getRecord()).Id
        ];
        demonstracao.Fornecedor__r.BillingCity = demonstracao.Fornecedor__r.BillingCity.toLowerCase().Capitalize();
        demonstracao.Estado__c = Util.ConverterEstado(demonstracao.Estado__c, 'sigla');
        
        if(demonstracao.Testemunha__r.CPF__c != ''){
            cpfTestemunha = demonstracao.Testemunha__r.CPF__c;
        }
        else{
            Dados_colaborador__c dados = [SELECT ID, CPF__c FROM Dados_colaborador__c WHERE Contato__c = :demonstracao.Testemunha__c LIMIT 1];
            cpfTestemunha = dados.CPF__c;
        }
        
        
        // itens
        List<Produto_da_demonstracao__c> itens = [
            SELECT  Ativo__r.Product2.URL_da_Imagem__c, Ativo__r.Product2.StockKeepingUnit, Ativo__r.Product2.Name, Ativo__r.Product2.Modelo__c, Ativo__r.Product2.Valor_de_venda__c,
            Ativo__r.Product2.Marca__c, Ativo__r.SerialNumber, Valor__c, Item__c, Item_Pai__c, Descricao__c
            FROM    Produto_da_Demonstracao__c
            WHERE   Demonstracao__c = :((SObject)controlador.getRecord()).Id
            ORDER BY Item__c ASC NULLS LAST
        ];
        
        List<Produto_da_demonstracao__c> itens_ordem = new List<Produto_da_Demonstracao__c>();
        for(Produto_da_Demonstracao__c item_equip : itens)
            if(item_equip.Item__c!=null && item_equip.Item_Pai__c==null){
                itens_ordem.add(item_equip);
                for(Produto_da_Demonstracao__c item_acess : itens)
                    if(item_acess.Item_Pai__c==item_equip.Item__c)
                    itens_ordem.add(item_acess);
            }
        for(Produto_da_Demonstracao__c item_vazio : itens)
            if(item_vazio.Item__c==null && item_vazio.Item_Pai__c==null)
            itens_ordem.add(item_vazio);
        
        produtos = new List<Produto>();
        Decimal subtotal = 0;
        for(Integer cont=0; cont<itens_ordem.size(); cont++){
            Produto produto = new Produto(itens_ordem[cont]);
            subtotal += itens_ordem[cont].Valor__c;
            
            String anterior = (cont==0?null:(itens_ordem[cont-1].Item_Pai__c==null?'equipamento':'acessorio'));
            String atual = (itens_ordem[cont].Item_Pai__c==null?'equipamento':'acessorio');
            String proximo = (cont==itens_ordem.size()-1?null:(itens_ordem[cont+1].Item_Pai__c==null?'equipamento':'acessorio'));
            
            if((atual=='equipamento'&& proximo=='acessorio') || ((anterior==null||anterior=='acessorio') && (atual=='equipamento' && (proximo=='equipamento'||proximo==null))))
                produto.cabecalho = true;
            if((anterior=='equipamento'||anterior=='acessorio') && atual=='acessorio' && (proximo=='equipamento'||proximo==null)){
                produto.subtotal = demonstracao.CurrencyISOCode+' '+String.valueOf(subtotal.format());
                if(!produto.subtotal.contains(',')) produto.subtotal += ',00';
                else if(produto.subtotal.substringAfter(',').length()==1) produto.subtotal += '0';
                subtotal = 0;
            }
            
            produtos.add(produto);
        }
        
        // documento
        documento = new Documento();
        if(demonstracao.Fornecedor__r.CNPJ__c == '27.476.124/0001-02')
            documento.timbrado = PageReference.forResource('TimbradoHealth').getUrl();
        else if(demonstracao.Fornecedor__r.CNPJ__c == '23.813.386/0001-56')
            documento.timbrado = PageReference.forResource('TimbradoGDB').getUrl();
        else
            documento.timbrado = PageReference.forResource('TimbradoHospcom').getUrl();     
        
        
    }
    
    public class Produto{
        public Boolean cabecalho{get;set;}
        public Produto_da_demonstracao__c item{get;set;}
        public String subtotal{get;set;}
        
        public Produto(Produto_da_demonstracao__c item){
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