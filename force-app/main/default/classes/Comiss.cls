public class Comiss {
    public list <Recebimentos__c> Records{get;set;}
    public String colaborador {get;set;}
    public String gerente {get;set;}
    public String operacao {get;set;}
    public date startDate {get;set;}
	public date endDate {get;set;}
    public Boolean teste {get;set;}
    public Boolean teste2 {get;set;}
    public Boolean teste3 {get;set;}    
    public String pago {get;set;}
    public Boolean print {get;set;}

    public Boolean mostrarprem {get;set;}
    public Comiss(){
        teste =true;
        teste2 =false;
        teste3 =false;        
        mostrarprem = false;
        print=false;
    }
    public void show(){
        teste = true;
        pago = 'todas';
        teste3=false;
    }
    public void page(){
        mostrarprem=true;
    }
        public void print(){
        print=true;
            teste=false;
    }
	public void pageclose(){
        mostrarprem=false;
    }    
    public void close(){
        teste = false;
        teste3 = true;        
    }
    public void search() {
        if (pago == 'true'){
            string searchquery= 'SELECT Name, Id, Vendedor__c, Valor_Recebido__c, ComissaoVendedor__c, ComissaoPaga__c, Titulo__c,' + 
              + 'Data_do_Recebimento__c, Comissao_Gerente_Paga__c, Gerente__c, ComissaoGerente__c, Titulo__r.Faturamento__r.Pedido__r.OrderNumber, Titulo__r.Faturamento__r.Pedido__r.Natureza_de_Opera_o__c '+
              + 'FROM Recebimentos__c WHERE (Gerente__c =:gerente or Gerente__c like \'%'+gerente+'%\') and (Vendedor__c =:colaborador or Vendedor__c like \'%'+colaborador+'%\') and (ComissaoPaga__c = true) and (Titulo__r.Faturamento__r.Pedido__r.Natureza_de_Opera_o__c =:operacao or Titulo__r.Faturamento__r.Pedido__r.Natureza_de_Opera_o__c like \'%'+operacao+'%\') and (Data_do_Recebimento__c >=: startDate and Data_do_Recebimento__c <=: endDate) ' +
              + 'ORDER BY Data_do_Recebimento__c';       
        Records = Database.query(searchquery); 
        teste2 = true;
        }
        else if (pago == 'false'){
            string searchquery= 'SELECT Name, Id, Vendedor__c, Valor_Recebido__c, ComissaoVendedor__c, ComissaoPaga__c, Titulo__c, ' + 
              + 'Data_do_Recebimento__c, Comissao_Gerente_Paga__c, Gerente__c, ComissaoGerente__c, Titulo__r.Faturamento__r.Pedido__r.OrderNumber, Titulo__r.Faturamento__r.Pedido__r.Natureza_de_Opera_o__c '+
              + 'FROM Recebimentos__c WHERE (Gerente__c =:gerente or Gerente__c like \'%'+gerente+'%\') and (Vendedor__c =:colaborador or Vendedor__c like \'%'+colaborador+'%\') and (ComissaoPaga__c = false) and (Titulo__r.Faturamento__r.Pedido__r.Natureza_de_Opera_o__c =:operacao or Titulo__r.Faturamento__r.Pedido__r.Natureza_de_Opera_o__c like \'%'+operacao+'%\') and (Data_do_Recebimento__c >=: startDate and Data_do_Recebimento__c <=: endDate) ' +
              + 'ORDER BY Data_do_Recebimento__c';       
        Records = Database.query(searchquery); 
        teste2 = true;
        }       
        else{
         string searchquery= 'SELECT Name, Id, Vendedor__c, Valor_Recebido__c, ComissaoVendedor__c, ComissaoPaga__c, Titulo__c, ' + 
              + 'Data_do_Recebimento__c, Gerente__c, Comissao_Gerente_Paga__c, ComissaoGerente__c, Titulo__r.Faturamento__r.Pedido__r.OrderNumber, Titulo__r.Faturamento__r.Pedido__r.Natureza_de_Opera_o__c '+
              + 'FROM Recebimentos__c WHERE (Gerente__c =:gerente or Gerente__c like \'%'+gerente+'%\') and (Vendedor__c =:colaborador or Vendedor__c like \'%'+colaborador+'%\') and (Titulo__r.Faturamento__r.Pedido__r.Natureza_de_Opera_o__c =:operacao or Titulo__r.Faturamento__r.Pedido__r.Natureza_de_Opera_o__c like \'%'+operacao+'%\') and (Data_do_Recebimento__c >=: startDate and Data_do_Recebimento__c <=: endDate) ' +
              + 'ORDER BY Data_do_Recebimento__c';       
        Records = Database.query(searchquery); 
        teste2 = true;   
        }

    }
    public void clear(){
        if (Records != null){
            Records.clear();
            colaborador = null;
            operacao = null;
            gerente = null;
            teste2 = false;
            pago = 'todas';
        }
    }
    public void save() {
		update Records;
    }
     public PageReference cancel() {
   // System.Debug('GETURL ::: '+ApexPages.currentPage().getUrl());
        return null;
    }
    }