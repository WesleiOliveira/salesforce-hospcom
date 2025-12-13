public with sharing class DemonstracaoBotoes {
    
    @AuraEnabled
    public static String ValidarPreenchimento(String demo_id){
		ValoresValidarPreenchimento valores = new ValoresValidarPreenchimento();
		
		Demonstracao__c demonstracao = [
			SELECT 	Conta__r.RecordType.Name, Conta__r.Raz_o_Social__c, Conta__r.Name, Conta__r.CNPJ__c, Conta__r.CPF__pc, (
						SELECT	Id
						FROM	Pedidos__r
					)
			FROM 	Demonstracao__c
			WHERE 	Id = :demo_id
		];
		
		// sem pedido (status ativo + data valida + demo sem item)
		if(demonstracao.Pedidos__r.size()==0)
			valores.retorno += '<br/> - Deve haver pelo menos um pedido, para a geração dos documentos.';
		
		// conta sem cnpj
		if(demonstracao.Conta__r.RecordType.Name == 'Conta comercial' && demonstracao.Conta__r.CNPJ__c == null)
			valores.retorno += '<br/> - O CNPJ do cliente deve ser preenchido.';
		
		// conta sem razão social
		if(demonstracao.Conta__r.RecordType.Name == 'Conta comercial' && demonstracao.Conta__r.Raz_o_Social__c == null)
			valores.retorno += '<br/> - A razão social do cliente deve ser preenchida.';
		
		// conta sem cnpj
		if(demonstracao.Conta__r.RecordType.Name != 'Conta comercial' && demonstracao.Conta__r.CPF__pc == null)
			valores.retorno += '<br/> - O CPF do cliente deve ser preenchido.';
		
		// conta sem razão social
		if(demonstracao.Conta__r.RecordType.Name != 'Conta comercial' && demonstracao.Conta__r.Name == null)
			valores.retorno += '<br/> - O nome do cliente deve ser preenchido.';
		
		// mensagem
		if(valores.retorno!='')
			valores.retorno = 'Revise os seguintes pontos para gerar a proposta: ' + valores.retorno;

		valores.tipos.add(new Map<String, String>{'value' => 'entrega', 'label' => 'Entrega'});
		valores.tipos.add(new Map<String, String>{'value' => 'recebimento', 'label' => 'Recebimento'});
		valores.tipo = 'entrega';
		
		return JSON.serialize(valores);
	}public class ValoresValidarPreenchimento{
		String retorno;
		List<Map<String, String>> tipos;
		String tipo;

		public ValoresValidarPreenchimento(){
			retorno = '';
			tipos = new List<Map<String, String>>();
			tipo = '';
		}
	}
	
	
	
    @AuraEnabled
    public static void SalvarPdfContrato(String demo_id){
		PageReference contr_pag = new PageReference('/apex/DemonstracaoContrato');
		contr_pag.getParameters().put('Id', demo_id);
		Blob contr_blob = (!Test.isRunningTest() ? contr_pag.getContent() : Blob.valueOf('teste'));
		
		String contr_nome = [SELECT Name FROM Demonstracao__c WHERE Id = :demo_id].Name;
		
		ContentVersion contr_ver = new ContentVersion(
			PathOnClient = 'Contrato Demonstração - '+contr_nome+' ('+System.Now().format('yyyy-MM-dd\' \'hh:mm:ss')+').pdf',
			Title = 'Contrato Demonstração - '+contr_nome+' ('+System.Now().format('yyyy-MM-dd\' \'hh:mm:ss')+')',
			VersionData = contr_blob
		);
		insert contr_ver;
		
		contr_ver = [SELECT contentDocumentId FROM ContentVersion WHERE Id = :contr_ver.Id];
		ContentDocumentLink prop_link = new ContentDocumentLink(
			ContentDocumentId = contr_ver.ContentDocumentId,
			LinkedEntityId = demo_id,
			ShareType = 'I',
			Visibility = 'AllUsers'
		);
		insert prop_link;		
	}
    
    @AuraEnabled
    public static void SalvarPdfChecklist(String demo_id, String tipo){
		PageReference check_pag = new PageReference('/apex/DemonstracaoChecklist');
		check_pag.getParameters().put('Id', demo_id);
		check_pag.getParameters().put('tipo', tipo);
		Blob check_blob = (!Test.isRunningTest() ? check_pag.getContent() : Blob.valueOf('teste'));
		
		String check_nome = [SELECT Name FROM Demonstracao__c WHERE Id = :demo_id].Name;
		
		ContentVersion check_ver = new ContentVersion(
			PathOnClient = 'Checklist Demonstração - '+check_nome+' ('+System.Now().format('yyyy-MM-dd\' \'hh:mm:ss')+').pdf',
			Title = 'Checklist Demonstração - '+check_nome+' ('+System.Now().format('yyyy-MM-dd\' \'hh:mm:ss')+')',
			VersionData = check_blob
		);
		insert check_ver;
		
		check_ver = [SELECT contentDocumentId FROM ContentVersion WHERE Id = :check_ver.Id];
		ContentDocumentLink prop_link = new ContentDocumentLink(
			ContentDocumentId = check_ver.ContentDocumentId,
			LinkedEntityId = demo_id,
			ShareType = 'I',
			Visibility = 'AllUsers'
		);
		insert prop_link;		
	}
	
}