public with sharing class AccountTriggerHandler {

    /*Author:Everton Nascimento
      Data: 16/07/2021
      Motivo: Validações para campos de conta
      Ajuste: 
    */
    public static void validacoesConta(List<Account> newConta){
        
        String resultado = null;
		
		for(Account conta : newConta){
			
			// cnpj
			if((resultado = Util.ValidarCNPJ(conta.CNPJ__c)) != null) conta.CNPJ__c.addError(resultado);

            // cpf
			if((resultado = Util.ValidarCPF(conta.CPF__pc)) != null) conta.CPF__pc.addError(resultado);
			
			// inscrição estadual
			if((resultado = Util.ValidarValor(conta.Inscri_o_Estadual__c, 'inscrição estadual', 'codigo')) != null) conta.Inscri_o_Estadual__c.addError(resultado);
			
			// inscrição municipal
			if((resultado = Util.ValidarValor(conta.Inscri_o_Municipal__c, 'inscrição municipal', 'codigo')) != null) conta.Inscri_o_Municipal__c.addError(resultado);
			
			// telefone
			if((resultado = Util.ValidarTelefone(conta.Phone, conta.CNPJ__c)) != null) conta.Phone.addError(resultado);
			
			// fax
			if((resultado = Util.ValidarTelefone(conta.Fax, conta.CNPJ__c)) != null) conta.Fax.addError(resultado);
			
			// website
			if((resultado = Util.ValidarValor(conta.Website, 'website', 'website')) != null) conta.Website.addError(resultado);
			
			// primeiro nome
			if((resultado = Util.ValidarValor(conta.FirstName, 'primeiro nome', 'texto')) != null) conta.FirstName.addError(resultado);
			
			// nome do meio
			if((resultado = Util.ValidarValor(conta.MiddleName, 'nome do meio', 'texto')) != null) conta.MiddleName.addError(resultado);
			
			// ultimo nome			
			if((resultado = Util.ValidarValor(conta.LastName, 'ultimo nome', 'texto')) != null) conta.LastName.addError(resultado);
			
			// celular
			if((resultado = Util.ValidarTelefone(conta.PersonMobilePhone, null)) != null) conta.PersonMobilePhone.addError(resultado);
		}
    }
    
    /*Author:Everton Nascimento
      Data: 16/07/2021
      Motivo: Preenche um campo da conta com informações do lead
      Ajuste: Talvez o campo pudesse ser mapeado no lead para preencher a conta caso necessário
    */
    public static void preencheCampoLead(List<Account> newConta){
        
        Set<String> idLead = new Set<String>();
		
        for(Account conta : newConta){
			if(conta.Lead__c != null){
				idLead.add(conta.Lead__c);
            }
		}

		if(idLead.size() > 0){
			Util.AcaoInterna(true);
			for(Lead lead : [SELECT Numero__c, Tipo__c FROM Lead WHERE Numero__c IN:idLead]){
				for(Account conta : newConta){
                    // descrição <= lead.interesse
                    if(lead.Numero__c == conta.Lead__c){
                        conta.Type = lead.Tipo__c;
                        conta.Lead__c = null;
                    }
                }
            }	
		}
	}

    /*Author:Everton Nascimento
      Data: 16/07/2021
      Motivo: Valida a conta na base da receita
      Ajuste: 
    */
    public static void validaDadosReceita(List<Account> newConta, Map<Id,Account> oldConta){

        Id RTContaComercial = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Conta_comercial').getRecordTypeId(); 

        for(Account conta : newConta){
            if(conta != null && oldConta.get(conta.Id).CNPJ__c != conta.CNPJ__c && conta.Status_receita__c == null 
              && conta.RecordTypeId == RTContaComercial){
                ContaPreenchimento.ChamarReceita(conta.Id, conta.CNPJ__c);
            }
        }
    }
}