public class FaturamentoAdicionarRecebimento {

	public List<cRecebimento> 	c_recebimentos {get; set;}
	public Integer 				qtd_recebimentos {get;set;}
	public String 				pesquisa {get; set;}
	public String 				mensagem {get; set;}
	public Id 					filtro_conta_id, faturamento_id;

	public FaturamentoAdicionarRecebimento(ApexPages.StandardController controller) {
		c_recebimentos = new List<cRecebimento>();
		pesquisa = '';
		mensagem = '';
		faturamento_id = ((SObject)controller.getRecord()).Id;
		filtro_conta_id = ObtemFaturamento(faturamento_id);
		
		Pesquisar();
	}
	
	public Id ObtemFaturamento(Id faturamento_id){
		return [
			SELECT 	Nome_da_Conta2__c
			FROM	Faturamento__c
			WHERE	Id = :faturamento_id
		][0].Nome_da_Conta2__c;		
	}
	
	public void Pesquisar(){
		List<Recebimentos__c> recebimentos = new List<Recebimentos__c>();
        String pesquisa_sql = '%'+pesquisa+'%';
		recebimentos = [
			SELECT 	Id, Name, Data_do_Recebimento__c, Valor_Recebido__c, Valor_Desconto__c, Valor_Acrescimo__c, Valor_Total__c, RecordType.Name, Procedencia__c,
					Nota_Fiscal1__r.Name, Nota_Fiscal1__r.Faturamento_Feito2__r.Name, Nota_Fiscal1__r.Nome_da_Conta2__r.Name
			FROM  	Recebimentos__c 
			WHERE	RecordType.Name = 'Parceiro'	AND
					NF_Representacao__c = null		AND
					Nota_Fiscal1__r.Faturamento_Feito2__c = :filtro_conta_id	AND
					Name LIKE :pesquisa_sql
		];
		
        c_recebimentos.clear();
		for(Recebimentos__c recebimento : recebimentos)
			c_recebimentos.add(new cRecebimento(recebimento));
		
		qtd_recebimentos = c_recebimentos.size();
	}
	
	public void Adicionar() {
		List<Recebimentos__c> recebimentos = new List<Recebimentos__c>();
        for(cRecebimento c_recebimento : c_recebimentos){
			if(c_recebimento.caixa == true){
				c_recebimento.corpo.NF_Representacao__c = faturamento_id;
				recebimentos.add(c_recebimento.corpo);
			}
		}
		if(recebimentos.size()>0)
			update recebimentos;
		mensagem = recebimentos.size() + ' item(s) adicionado(s)';
		
		Pesquisar();
	}
	
	public class cRecebimento {
		public Recebimentos__c 	corpo 	{get; set;}
		public Boolean 			caixa 	{get; set;}

		public cRecebimento(Recebimentos__c recebimento) {
			corpo 	= recebimento;
			caixa 	= false;
		}
	}
}