public with sharing class HomeBotoes {
    
    @AuraEnabled
    public static String PrepararPainel(){
		ValoresPrepararPainel valores = new ValoresPrepararPainel();

		User usuario = [SELECT Variacoes__c, Variacao__c FROM User WHERE Id = :UserInfo.GetUserId()];
		valores.paineis = usuario.Variacoes__c.split('\\;');
		valores.painel = usuario.Variacao__c;
		
		return JSON.serialize(valores);
	}public class ValoresPrepararPainel{
		List<String> paineis;
		String painel;

		public ValoresPrepararPainel(){}
	}
	
	@AuraEnabled
	public static String AlterarPainel(String config){
		RetornoAlterarPainel retorno = new RetornoAlterarPainel();
		
		User usuario = [SELECT Variacao__c FROM User WHERE Id = :UserInfo.GetUserId()];
		
		Savepoint checkpoint = Database.setSavepoint();
		usuario.Variacao__c = config;
		try {
			update usuario;
		}
		catch (System.DMLException e){
			for(Integer i=0; i<e.getNumDml(); i++)
				retorno.mensagem += e.getDmlMessage(i);
			Database.rollback(checkpoint);
			return JSON.serialize(retorno);
		}
		
		return JSON.serialize(retorno);
	}public class RetornoAlterarPainel{
		String mensagem;
		
		public RetornoAlterarPainel(){
			mensagem = '';
		}
	}
}