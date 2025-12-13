trigger LeadValidacao on Lead (before insert, before update) {

	// ignora erros
	if(!Util.IgnorarErros()){
		
		String resultado = null;
		
		for(Lead lead : Trigger.new){
			
			// primeiro nome
			if((resultado = Util.ValidarValor(lead.FirstName, 'primeiro nome', 'texto')) != null)
				lead.FirstName.addError(resultado);
			
			// nome do meio
			if((resultado = Util.ValidarValor(lead.MiddleName, 'nome do meio', 'texto')) != null)
				lead.MiddleName.addError(resultado);
			
			// ultimo nome
			if((resultado = Util.ValidarValor(lead.LastName, 'ultimo nome', 'texto')) != null)
				lead.LastName.addError(resultado);

			// cpf
			if((resultado = Util.ValidarCPF(lead.CPF__c)) != null)
				lead.CPF__c.addError(resultado);

			// cnpj
			if((resultado = Util.ValidarCNPJ(lead.CNPJ__c)) != null)
				lead.CNPJ__c.addError(resultado);

			// cargo
			if((resultado = Util.ValidarValor(lead.Title, 'cargo', 'texto')) != null)
				lead.Title.addError(resultado);

			// telefone
			if((resultado = Util.ValidarTelefone(lead.Phone, lead.CNPJ__c)) != null)
				lead.Phone.addError(resultado);
			
			// celular
			//if((resultado = Util.ValidarTelefone(lead.MobilePhone, lead.CNPJ__c)) != null)
			//	lead.MobilePhone.addError(resultado);

			// fax
			//if((resultado = Util.ValidarTelefone(lead.Fax, lead.CNPJ__c)) != null)
			//	lead.Fax.addError(resultado);
			
			// email
			if((resultado = Util.ValidarValor(lead.Email, 'email', 'email')) != null)
				lead.Email.addError(resultado);
			
			// website
			if((resultado = Util.ValidarValor(lead.Website, 'website', 'website')) != null)
				lead.Website.addError(resultado);
			
		}
	}
}