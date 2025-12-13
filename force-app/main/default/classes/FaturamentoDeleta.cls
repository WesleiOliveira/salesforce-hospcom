public class FaturamentoDeleta{
    public String			url_prefixo {get;set;}
    public Faturamento__c	faturamento {get;set;}

    public FaturamentoDeleta(ApexPages.StandardController controller) {
        url_prefixo = Site.getPathPrefix();
        
        faturamento = (Faturamento__c)controller.getRecord();
	}
    
    public PageReference Exterminar(){
        delete faturamento;
        return new PageReference('/');
    }
}