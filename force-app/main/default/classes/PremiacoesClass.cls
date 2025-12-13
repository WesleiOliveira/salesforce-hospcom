public class PremiacoesClass {
    public list <Recebimentos__c> Records{get;set;}
    public String departamento {get;set;}
    public date startDate {get;set;}
	public date endDate {get;set;}
    public Boolean showfiltros {get;set;}
    public Boolean show {get;set;}
    public Boolean showA {get;set;}
    public list <Meta__mdt> Metas{get;set;}
    public list <User> Users{get;set;}
    public PremiacoesClass(){
        show=false;
        showA=false;
        showfiltros=true;
        Metas = [SELECT Valor__c, Premiacao__c, MasterLabel FROM Meta__mdt];
    }
    public void search() {
        string MetasQ = 'SELECT MasterLabel, Valor__c, Premiacao__c FROM Meta__mdt WHERE MasterLabel like \'%'+departamento+'%\'  Order By Valor__c';
		Metas = Database.query(MetasQ);
        String Premiados = 'SELECT Name, Peso_Premiacao__c, Departamento_Premiacao__c FROM USER WHERE Departamento_Premiacao__c includes (:departamento) ORDER BY Name';	
       	Users = Database.query(Premiados);
        show=true;
          string searchquery= 'SELECT Name, Id, Vendedor__c, Valor_Recebido__c, ComissaoVendedor__c, ComissaoPaga__c, ' + 
              + 'Data_do_Recebimento__c, Departamento__c, Titulo__r.Faturamento__r.Pedido__c, Titulo__r.Faturamento__r.Pedido__r.Natureza_de_Opera_o__c '+
              + 'FROM Recebimentos__c WHERE Departamento__c like \'%'+departamento+'%\' and (Data_do_Recebimento__c >=: startDate and Data_do_Recebimento__c <=: endDate) ORDER BY Data_do_Recebimento__c';
        Records = Database.query(searchquery);
    }
    public void clear(){
        if (Records != null){
            Records.clear();
            show=false;
            departamento = ' ';
            startDate = null;
            endDate = null;
        }
    }
    public void fechar(){
        showfiltros=false;
        showA=true;
    }
    public void abrir(){
        showfiltros=true;
        showA=false;
    }
      public PageReference passValue() {
          return null;
      }
}