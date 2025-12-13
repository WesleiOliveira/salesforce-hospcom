@isTest(seeAllData=true)
public class CotacaoValidacaoTest {
    
	@isTest private static void run(){
        Quote cotacao = new Quote();
        cotacao.OpportunityId = '0065A00001YANlPQAX';
        cotacao.Name = 'Teste';
        cotacao.Data_de_emissao__c = system.today();
        cotacao.Prazo_de_garantia__c = 'Equipamentos 12 meses, acessórios 3 meses';
        cotacao.Prazo_de_Entrega__c = '12 dias';
        cotacao.Prazo_de_garantia_dos_equipamentos__c = '12 meses';
        cotacao.Prazo_de_garantia_acessorios__c = '3 meses';
        insert cotacao;
        
        delete cotacao;
    }
}