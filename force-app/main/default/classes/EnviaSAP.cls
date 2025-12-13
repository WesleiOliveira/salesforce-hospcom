public class EnviaSAP {

	public Tela tela {get;set;}
	public Order pedido {get;set;}

	public ContaJSON2ApexSAP.RespRegistro conta_sap_resp_reg;
	public ConsultaJSON2ApexSap.RespLista vendedor_sap_resp_list;
	public ConsultaJSON2ApexSap.RespLista condpgto_sap_resp_list;
	public ConsultaJSON2ApexSap.RespLista formpgto_sap_resp_list;
	public ConsultaJSON2ApexSap.RespLista filial_sap_resp_list;
	public ConsultaJSON2ApexSap.RespLista prods_sap_resp_list;
	public ConsultaJSON2ApexSap.RespLista prods_sap_resp_list_temp;
	
	public List<Folder> pastas = [SELECT id FROM Folder WHERE Name = 'Logs Integração SAP'];
	public List<String> logs;

	public EnviaSAP(ApexPages.StandardController controlador){
		pedido = (Order)controlador.getRecord();
		tela = new Tela();
	}

	public Pagereference ValidarPedido(){
		try {
			logs = new List<String>();
			tela.mensagem = new Mensagem();
			pedido = Database.query(
				'SELECT	Id, OrderNumber, EffectiveDate, Prazo_de_entrega__c, Status, Faturamento_Feito__r.CNPJ__c, Faturamento_Feito__r.Raz_o_Social__c, ' +
				'		AccountId, Account.RecordType.Name, Account.Name, Account.Raz_o_Social__c, Account.CNPJ__c, Account.CPF__pc, Faturamento_Feito__r.Name, ' +
				'		Account.Phone, Account.PersonMobilePhone, Account.PersonEmail, BillingState, ShippingState, BillingCountry, ShippingCountry, ' + 
				'		Forma_de_pagamento2__c, Condicao_de_pagamento__c, Frete__c, Entrega_parcial__c, Ordem_de_trabalho__c, Ordem_de_trabalho__r.WorkOrderNumber, ' +
				'		BillingStreet, BillingCity, BillingPostalCode, ShippingStreet, ShippingCity, ShippingPostalCode, BillingAddress, ShippingAddress, Natureza_de_Opera_o__c, ' +
				'       Observacoes_Gerais__c, Vendedor__r.CommunityNickName, OpportunityId, Opportunity.Numero_OP__c, QuoteId, Quote.QuoteNumber, ' +
				'       Demonstracao__c, Demonstracao__r.Name, Contrato_de_Servi_o__c, Contrato_de_Servi_o__r.N_mero_da_Proposta_Contrato__c, ( ' +
				'			SELECT		PricebookEntry.Product2.ProductCode, PricebookEntry.Product2.StockKeepingUnit, PricebookEntry.Product2.Numero_Anvisa__c, ' +
				'						PricebookEntry.Product2.Name, PricebookEntry.Product2.Marca__c, PricebookEntry.Product2.Modelo__c, ' +
				'						PricebookEntry.Product2.Description, PricebookEntry.Product2.Family, PricebookEntry.Product2.Tipo_do_Produto__c, ' +
				'						OrderItemNumber, Quantity, UnitPrice, Item_pai__c, Description' +
				'			FROM		OrderItems ' +
				'			Order BY 	Item__c ' +
				'		) ' +
				'FROM	Order ' +
				'WHERE	Id = \''+ pedido.id +'\''
			);

			// já ativo
			List<String> status_nao_ativo = new List<String>{'Rascunho','Aguardando Aprovação Comercial','Aguardando Aprovação Financeira','Reprovado','Aprovado','Cancelado','Desativado'};
			if(!status_nao_ativo.contains(pedido.status)){
				HttpRequest  					requisicao 	= new HttpRequest();
				Http 		 					protocolo 	= new Http();
				HttpResponse 					resposta;
				PedidoJSON2ApexSAP.RespRegistro pedido_sap_resp_reg = new PedidoJSON2ApexSAP.RespRegistro();

				requisicao.setMethod('GET');
				requisicao.setEndPoint('http://201.7.211.65:8889/integrationone/api/Documentos/' +
					pedido.Ordernumber);
				if(!Test.isRunningTest()){
					logs.add('pesquisar pedido (requisiçao): '+requisicao+requisicao.getBody());
					resposta = protocolo.send(requisicao);
					logs.add('pesquisar pedido (resposta): '+resposta+resposta.getBody());
					pedido_sap_resp_reg = (PedidoJSON2ApexSAP.RespRegistro)JSON.deserialize(resposta.getBody(), PedidoJSON2ApexSAP.RespRegistro.class);
				}
				if(pedido_sap_resp_reg.retorno == 0)
					tela.mensagem.informacoes.add('Pedido já <b>ativo</b>, mas <b>não integrado</b> no SAP. Consultar administrador do sistema.');
				else
					tela.mensagem.informacoes.add('Pedido já <b>ativo</b> e <b>integrado</b> no SAP. Tudo OK :)');
			}

			// ainda não ativo
			else if(ValidarPreenchimento()){
				ValidarContaSAP();
				ValidarEnderecosSAP();
				ValidarVendedorSAP();
				ValidarCondPgtoSAP();
				ValidarFormPgtoSAP();
				ValidarFilialSAP();
				ValidarItensCadastroSAP();
				ValidarItensAtivoSAP();
				if(tela.mensagem.erros.size()==0)
					if(AtivarPedido()){
						tela.mensagem.sucessos.add('Pedido <b>ativado</b> com sucesso!');
						tela.mensagem.informacoes.add('Aguarde, em instantes estará disponível no SAP.');
						SalvarLog('OK');
					}
			}
		}
		catch(Exception error) {
			logs.add('-- erro --');	
			logs.add('tipo: ' + error.getTypeName());	
			logs.add('mensagem: ' + error.getMessage());   
			logs.add('causa: ' + error.getCause());
			logs.add('linha: ' + error.getLineNumber());   
			logs.add('rastreio: ' + error.getStackTraceString());   
			SalvarLog('ERRO');
			tela.mensagem.erros.add('Houve um erro não tratado: <b>'+error.getMessage()+'</b>. Consultar logs para mais detalhes');
		}
		
		return null;
	}

	public Boolean ValidarPreenchimento(){
		// pedido
		if(pedido.EffectiveDate==null)
			tela.mensagem.erros.add('A <b>Data de início</b> deve ser preenchida');
		if(pedido.Prazo_de_entrega__c==null)
			tela.mensagem.erros.add('O <b>Prazo de entrega</b> deve ser preenchido');
		if(pedido.Contrato_de_Servi_o__c==null && pedido.Status!='Aprovado')
			tela.mensagem.erros.add('O <b>Status atual</b> deve estar como <b>Aprovado</b>');
		else if(pedido.Contrato_de_Servi_o__c!=null && pedido.Status!='Aprovado')
			tela.mensagem.erros.add('O <b>Status atual</b> deve estar como <b>Aprovado</b>');
		if(pedido.Faturamento_Feito__r.CNPJ__c==null)
			tela.mensagem.erros.add('O <b>Faturamento feito (filial)</b> deve ser preenchido');
		if(pedido.Account.CNPJ__c == null && pedido.Account.CPF__pc ==  null)
			tela.mensagem.erros.add('O <b>CNPJ ou CPF</b> do cliente deve ser preenchido');
		if(pedido.Account.RecordType.Name != 'Conta comercial' && pedido.Account.Phone==null && pedido.Account.PersonMobilePhone==null)
			tela.mensagem.erros.add('O <b>Telefone e/ou Celular</b> do cliente deve ser preenchido');
		if(pedido.Account.RecordType.Name != 'Conta comercial' && pedido.Account.PersonEmail==null)
			tela.mensagem.erros.add('O <b>O Email</b> do cliente deve ser preenchido');
		if(pedido.Forma_de_pagamento2__c == null)
			tela.mensagem.erros.add('A <b>Forma de pagamento</b> deve ser preenchida');
		if(pedido.Condicao_de_pagamento__c == null)
			tela.mensagem.erros.add('A <b>Condicão de pagamento</b> deve ser preenchida');
		if(pedido.Frete__c == null)
			tela.mensagem.erros.add('O <b>Frete</b> deve ser preenchido');
		if(pedido.Entrega_parcial__c == null)
			tela.mensagem.erros.add('A opção <b>Entrega parcial</b> deve ser preenchida');
		if(pedido.BillingStreet==null || pedido.BillingCity==null ||
		   pedido.BillingAddress.getStateCode()==null || pedido.BillingPostalCode==null)
			tela.mensagem.erros.add('O <b>Endereço de cobrança</b> deve ser preenchido (rua + cidade + estado + cep)');
		if(pedido.ShippingStreet==null || pedido.ShippingCity==null ||
		   pedido.ShippingAddress.getStateCode()==null || pedido.ShippingPostalCode==null)
			tela.mensagem.erros.add('O <b>Endereço de entrega</b> deve ser preenchido (rua + cidade + estado + cep)');

		// itens do pedido
		if(pedido.OrderItems.size()==0)
			tela.mensagem.erros.add('O pedido deve conter <b>Produtos adicionados</b>');
		List<String> itens_sem_cod = new List<String>();
		List<String> itens_sem_cod_c_nomes = new List<String>();
		for(OrderItem item : pedido.OrderItems){
			if( item.PricebookEntry.Product2.ProductCode==null &&
				!ItemServico(item.PricebookEntry.Product2) &&
				!itens_sem_cod.contains(item.PricebookEntry.Product2.StockKeepingUnit)
			){
				itens_sem_cod.add(item.PricebookEntry.Product2.StockKeepingUnit);
				itens_sem_cod_c_nomes.add('<br/>&nbsp;&nbsp;&nbsp;&nbsp;' + item.PricebookEntry.Product2.StockKeepingUnit + ' - ' +
					item.PricebookEntry.Product2.Name + ' ('+(item.PricebookEntry.Product2.Modelo__c!=null ? item.PricebookEntry.Product2.Modelo__c : 'sem modelo')+')');
			}
		}
		if(itens_sem_cod.size()>0)
			tela.mensagem.erros.add('O(s) seguinte(s) <b>produto(s)</b> deve(m) possuir <b>Código do fabricante</b>: ' + String.join(itens_sem_cod_c_nomes, ', '));

		return (tela.mensagem.erros.size()==0?true:false);
	}

	public void ValidarContaSAP(){
		HttpRequest  					requisicao 	= new HttpRequest();
		Http 		 					protocolo 	= new Http();
		HttpResponse 					resposta;

		requisicao.setMethod('GET');
		requisicao.setEndPoint(
			'http://201.7.211.65:8889/integrationone/api/Parceiros/CpfCnpj/' + (
				pedido.Account.RecordType.Name=='Conta comercial' ?
				pedido.Account.cnpj__c.replace('/', '').replace('.', '').replace('-', '') :
				pedido.Account.cpf__pc.replace('/', '').replace('.', '').replace('-', '')
		)+','+tela.base_sap);
		if(!Test.isRunningTest()){
			logs.add('perquisar conta (requisiçao): '+requisicao+requisicao.getBody());
			resposta = protocolo.send(requisicao);
			logs.add('perquisar conta (resposta): '+resposta+resposta.getBody());
			conta_sap_resp_reg = (ContaJSON2ApexSAP.RespRegistro)JSON.deserialize(resposta.getBody(), ContaJSON2ApexSAP.RespRegistro.class);
		}

		if(conta_sap_resp_reg.retorno == 0){
			tela.mensagem.erros.add(
				'A <b>conta</b> não possui cadastro no SAP: '+pedido.Account.Name+' ('+
				(pedido.Account.RecordType.Name=='Conta comercial' ?
					'CNPJ: '+pedido.Account.cnpj__c :
					'CPF: '+pedido.Account.cpf__pc
				) + ')'
			);


			Account conta = new Account();
			String mensagem = '';
			if(pedido.Account.RecordType.Name=='Conta comercial'){
				conta = [
					SELECT	(
								SELECT	Name, Title, Phone, MobilePhone, Email
								FROM	Contacts
							)
					FROM	Account
					WHERE	Id = :pedido.AccountId
				];
				mensagem =
					'<b>CONTA</b>: ' + pedido.Account.Name +
					'<br/>RAZÃO SOCIAL: ' + pedido.Account.Raz_o_Social__c +
					'<br/>CNPJ: ' + pedido.Account.cnpj__c;
				if(pedido.Account.Phone!=null)
					mensagem += '<br/>TELEFONE: ' + pedido.Account.Phone;
				if(conta.Contacts.size()>0)
					mensagem += '<br/><br/><b>CONTATOS (P/ CONSULTA):</b> ';
				for(Contact contato : conta.Contacts)
					mensagem += '<br/> - ' + contato.Name.toUpperCase() +
						(contato.Title!=null ? ' ('+contato.Title.toUpperCase()+')' : '') +
						(contato.Phone!=null ? ', FONE: '+contato.Phone : '') +
						(contato.MobilePhone!=null ? ', CEL: '+contato.MobilePhone : '') +
						(contato.Email!=null ? ', EMAIL: '+contato.Email : '');
				mensagem +='<br/><br/>';
			}
			else{
				mensagem =
					'<b>CONTA</b>: ' + pedido.Account.Name +
					'<br/>CPF: ' + pedido.Account.cpf__pc;
				if(pedido.Account.Phone!=null)
					mensagem += '<br/>Telefone: ' + pedido.Account.Phone;
				if(pedido.Account.PersonMobilePhone!=null)
					mensagem += '<br/>Celular: ' + pedido.Account.PersonMobilePhone;
				if(pedido.Account.PersonEmail!=null)
					mensagem += '<br/>Email: ' + pedido.Account.PersonEmail;
				mensagem +='<br/><br/>';
			}
			tela.mensagem.emails.add(mensagem);
		}
	}

	public void ValidarEnderecosSAP(){
		if(conta_sap_resp_reg.retorno == 0){
			tela.mensagem.erros.add(
				'O <b>endereço de cobrança</b> não possui cadastro no SAP: ' +
				pedido.BillingStreet +', '+ pedido.BillingCity + '-'+
				pedido.BillingAddress.getStateCode() +', CEP: '+ pedido.BillingPostalCode
			);
			tela.mensagem.erros.add(
				'O <b>endereço de entrega</b> não possui cadastro no SAP: ' +
				pedido.ShippingStreet +', '+ pedido.ShippingCity + '-'+
				pedido.ShippingAddress.getStateCode() +', CEP: '+ pedido.ShippingPostalCode
			);

			tela.mensagem.emails.add(
				'<b>ENDEREÇO DE COBRANÇA</b>: '  +
				'<br/>' + pedido.BillingStreet +
				'<br/>CIDADE: ' + pedido.BillingCity + '-'+ pedido.BillingAddress.getStateCode() +
				'<br/>CEP: '+ pedido.BillingPostalCode +
				'<br/><br/>'
			);
			tela.mensagem.emails.add(
				'<b>ENDEREÇO DE ENTREGA</b>: '  +
				'<br/>' + pedido.ShippingStreet +
				'<br/>CIDADE: ' + pedido.ShippingCity + '-' + pedido.ShippingAddress.getStateCode() +
				'<br/>CEP: '+ pedido.ShippingPostalCode +
				'<br/><br/>'
			);
		}
		else{
			Order pedido_clone = pedido.clone(true, true, true, true);

			pedido_clone.BillingStreet = pedido_clone.BillingStreet.toLowerCase().deleteWhitespace();
			pedido_clone.BillingCity = pedido_clone.BillingCity.toLowerCase().deleteWhitespace();
			pedido_clone.BillingPostalCode = pedido_clone.BillingPostalCode.toLowerCase().deleteWhitespace();
			pedido_clone.ShippingStreet = pedido_clone.ShippingStreet.toLowerCase().deleteWhitespace();
			pedido_clone.ShippingCity = pedido_clone.ShippingCity.toLowerCase().deleteWhitespace();
			pedido_clone.ShippingPostalCode = pedido_clone.ShippingPostalCode.toLowerCase().deleteWhitespace();

			String numero_cobranca = '', numero_entrega = '', enderecos_cobranca_sap='', enderecos_entrega_sap='';

			Matcher correspondencia = Pattern.compile('.*,(sn|s\\/n|[0-9]+|n\\.-?[a-z]*[0-9]+-?[a-z]*)(,|$).*').matcher(pedido_clone.BillingStreet);
			if(correspondencia.matches())
				numero_cobranca = ((new List<String>{'sn','s/n'}).contains(correspondencia.group(1))?'':correspondencia.group(1).replace('n.', ''));
			correspondencia = Pattern.compile('.*,(sn|s\\/n|[0-9]+|n\\.-?[a-z]*[0-9]+-?[a-z]*)(,|$).*').matcher(pedido_clone.ShippingStreet);
			if(correspondencia.matches())
				numero_entrega = ((new List<String>{'sn','s/n'}).contains(correspondencia.group(1))?'':correspondencia.group(1).replace('n.', ''));

			for(ContaJSON2ApexSAP.Enderecos endereco : conta_sap_resp_reg.enderecos){

				endereco.Rua = (endereco.Rua!=null ? endereco.Rua : '');
				endereco.Numero = (endereco.Numero!=null ? endereco.Numero : '');
				endereco.Complemento = (endereco.Complemento!=null ? endereco.Complemento : '');
				endereco.Bairro = (endereco.Bairro!=null ? endereco.Bairro : '');
				endereco.Cidade = (endereco.Cidade!=null ? endereco.Cidade : '');
				endereco.Uf = (endereco.Uf!=null ? endereco.Uf : '');
				endereco.Cep = (endereco.Cep!=null ? endereco.Cep : '');
				endereco.Pais = (endereco.Pais!=null ? endereco.Pais : '');

				ContaJSON2ApexSAP.Enderecos endereco_clone = endereco.clone();

				endereco_clone.Numero = endereco_clone.Numero.toLowerCase().deleteWhitespace();
				endereco_clone.Cep = endereco_clone.Cep.toLowerCase().deleteWhitespace();
				endereco_clone.Rua = endereco_clone.Rua.toLowerCase().deleteWhitespace();
				endereco_clone.Complemento = endereco_clone.Complemento.toLowerCase().deleteWhitespace();
				endereco_clone.Bairro = endereco_clone.Bairro.toLowerCase().deleteWhitespace();
				endereco_clone.Numero = ((new List<String>{'sn','s/n'}).contains(endereco_clone.Numero)?'':endereco_clone.Numero);

				Boolean end_igual = true;
				if(endereco_clone.TipoEndereco == 'Cobrança'){

					enderecos_cobranca_sap += '<br/><span class=\'nor\'>';
					if(!pedido_clone.BillingStreet.containsIgnoreCase(endereco_clone.Rua)){
						end_igual = false;
						enderecos_cobranca_sap += (endereco.Rua!=''? '<span class=\'dif\'>'+endereco.Rua+'</span>' : '');
					}else
						enderecos_cobranca_sap += (endereco.Rua!=''? ' '+endereco.Rua:'');
					if(numero_cobranca != endereco_clone.Numero){
						end_igual = false;
						enderecos_cobranca_sap += (endereco.Numero!='' ? ', <span class=\'dif\'>'+endereco.Numero+'</span>' : '');
					}else
						enderecos_cobranca_sap += (endereco.Numero!='' ? ', '+endereco.Numero : '');
					if(!pedido_clone.BillingStreet.containsIgnoreCase(endereco_clone.Complemento)){
						end_igual = false;
						enderecos_cobranca_sap += (endereco.Complemento!=''? ', <span class=\'dif\'>'+endereco.Complemento+'</span>' : '');
					}else
						enderecos_cobranca_sap += (endereco.Complemento!=''? ', '+endereco.Complemento:'');
					if(!pedido_clone.BillingStreet.containsIgnoreCase(endereco_clone.Bairro)){
						end_igual = false;
						enderecos_cobranca_sap += (endereco.Bairro!=''? ', <span class=\'dif\'>'+endereco.Bairro+'</span>' : '');
					}else
						enderecos_cobranca_sap += (endereco.Bairro!=''? ', '+endereco.Bairro:'');
					enderecos_cobranca_sap += (endereco.Cidade!=''? ', '+endereco.Cidade:'');
					enderecos_cobranca_sap += (endereco.Uf!=''? '-'+endereco.Uf:'');
					if(pedido_clone.BillingPostalCode.replace('.', '').replace('-', '') != endereco_clone.Cep.replace('.', '').replace('-', '')){
						end_igual = false;
						enderecos_cobranca_sap += (endereco.Cep!=''? ', <span class=\'dif\'>CEP: '+endereco.Cep+'</span>' : '');
					}else
						enderecos_cobranca_sap += (endereco.Cep!=''? ', CEP: '+endereco.Cep:'');
					enderecos_cobranca_sap += (endereco.Pais!=''? ', '+endereco.Pais:'');
					enderecos_cobranca_sap += 
						' <button onclick="PrepararEndereco(\'Cobrança\',\''+endereco.NomeEndereco+'\')" type="button" class="btn btn-success btn-xs end">'+
						'Usar esse <i class="glyphicon glyphicon-ok"></i></button>';
					enderecos_cobranca_sap += '</span>';

					if(tela.endereco_cobranca==null && end_igual)
						tela.endereco_cobranca = endereco_clone.NomeEndereco;

				}else if(endereco_clone.TipoEndereco == 'Entrega'){

					enderecos_entrega_sap += '<br/><span class=\'nor\'>';
					if(!pedido_clone.ShippingStreet.containsIgnoreCase(endereco_clone.Rua)){
						end_igual = false;
						enderecos_entrega_sap += (endereco.Rua!='' ? ' <span class=\'dif\'>'+endereco.Rua+'</span>' : '');
					}else
						enderecos_entrega_sap += (endereco.Rua!=''? ' '+endereco.Rua:'');
					if(numero_entrega != endereco_clone.Numero){
						end_igual = false;
						enderecos_entrega_sap += (endereco.Numero!='' ? ', <span class=\'dif\'>'+endereco.Numero+'</span>' : '');
					}else
						enderecos_entrega_sap += (endereco.Numero!='' ? ', '+endereco.Numero : '');
					if(!pedido_clone.ShippingStreet.containsIgnoreCase(endereco_clone.Complemento)){
						end_igual = false;
						enderecos_entrega_sap += (endereco.Complemento!=''? ', <span class=\'dif\'>'+endereco.Complemento+'</span>' : '');
					}else
						enderecos_entrega_sap += (endereco.Complemento!=''? ', '+endereco.Complemento:'');
					if(!pedido_clone.ShippingStreet.containsIgnoreCase(endereco_clone.Bairro)){
						end_igual = false;
						enderecos_entrega_sap += (endereco.Bairro!=''? ', <span class=\'dif\'>'+endereco.Bairro+'</span>' : '');
					}else
						enderecos_entrega_sap += (endereco.Bairro!=''? ', '+endereco.Bairro:'');
					enderecos_entrega_sap += (endereco.Cidade!=''? ', '+endereco.Cidade:'');
					enderecos_entrega_sap += (endereco.Uf!=''? '-'+endereco.Uf:'');
					if(pedido_clone.ShippingPostalCode.replace('.', '').replace('-', '') != endereco_clone.Cep.replace('.', '').replace('-', '')){
						end_igual = false;
						enderecos_entrega_sap += (endereco.Cep!=''? ', <span class=\'dif\'>CEP: '+endereco.Cep+'</span>' : '');
					}else
						enderecos_entrega_sap += (endereco.Cep!=''? ', CEP: '+endereco.Cep:'');
					enderecos_entrega_sap += (endereco.Pais!=''? ', '+endereco.Pais:'');
					enderecos_entrega_sap += 
						' <button onclick="PrepararEndereco(\'Entrega\',\''+endereco.NomeEndereco+'\')" type="button" class="btn btn-success btn-xs">'+
						'Usar esse <i class="glyphicon glyphicon-ok"></i></button>';
					enderecos_entrega_sap += '</span>';

					if(tela.endereco_entrega==null && end_igual)
						tela.endereco_entrega = endereco_clone.NomeEndereco;
				}
			}

			if(tela.endereco_cobranca==null){
				tela.mensagem.erros.add(
					'O <b>endereço de cobrança</b> não possui cadastro no SAP: ' +
					pedido.BillingStreet +', '+ pedido.BillingCity + '-'+
					pedido.BillingAddress.getStateCode() +', CEP: '+ pedido.BillingPostalCode+
					(enderecos_cobranca_sap!=''?'<br/><small><b>Outros endereços de cobrança já cadastrados no SAP:</b>'+ enderecos_cobranca_sap +'</small>':'')
				);
				tela.mensagem.emails.add(
					'<b>ENDEREÇO DE COBRANÇA</b> ('+conta_sap_resp_reg.CodigoSap+'/'+pedido.Account.CNPJ__c+'): '  +
					'<br/>' + pedido.BillingStreet +
					'<br/>CIDADE: ' + pedido.BillingCity + '-'+ pedido.BillingAddress.getStateCode() +
					'<br/>CEP: '+ pedido.BillingPostalCode +
					'<br/><br/>'
				);
			}
			if(tela.endereco_entrega==null){
				tela.mensagem.erros.add(
					'O <b>endereço de entrega</b> não possui cadastro no SAP: ' +
					pedido.ShippingStreet +', '+ pedido.ShippingCity + '-'+
					pedido.ShippingAddress.getStateCode() +', CEP: '+ pedido.ShippingPostalCode +
					(enderecos_entrega_sap!=''?'<br/><small><b>Outros endereços de entrega já cadastrados no SAP:</b>'+ enderecos_entrega_sap +'</small>':'')
				);
				tela.mensagem.emails.add(
					'<b>ENDEREÇO DE ENTREGA</b>: ('+conta_sap_resp_reg.CodigoSap+'/'+pedido.Account.CNPJ__c+')'  +
					'<br/>' + pedido.ShippingStreet +
					'<br/>CIDADE: ' + pedido.ShippingCity + '-' + pedido.ShippingAddress.getStateCode() +
					'<br/>CEP: '+ pedido.ShippingPostalCode +
					'<br/><br/>'
				);
			}
		}
	}

	public void ValidarVendedorSAP(){
		HttpRequest  					requisicao 				= new HttpRequest();
		Http 		 					protocolo 				= new Http();
		HttpResponse 					resposta;
		ConsultaJSON2ApexSap.ReqLista 	vendedor_sap_req_list 	= new ConsultaJSON2ApexSap.ReqLista();

		requisicao.setMethod('POST');
		requisicao.setEndPoint('http://201.7.211.65:8889/integrationone/api/Consulta/');

		vendedor_sap_req_list.token = '/XZ9qjPSDYF938+7rN5SAw==';
		vendedor_sap_req_list.BaseSAP = tela.base_sap;
		vendedor_sap_req_list.tabela = 'OSLP';
		vendedor_sap_req_list.campoDescricao = 'SlpName';
		vendedor_sap_req_list.campoCodigo = 'SlpCode';
		vendedor_sap_req_list.lista.add(pedido.Vendedor__r.CommunityNickName);

		requisicao.setBody(JSON.serialize(vendedor_sap_req_list));
		requisicao.setHeader('Content-Type','application/json');
		if(!Test.isRunningTest()){
			logs.add('listar vendedores (requisiçao): '+requisicao+requisicao.getBody());
			resposta = protocolo.send(requisicao);
			logs.add('listar vendedores (resposta): '+resposta+resposta.getBody());
			vendedor_sap_resp_list = (ConsultaJSON2ApexSap.RespLista)JSON.deserialize(resposta.getBody(), ConsultaJSON2ApexSap.RespLista.class);
		}

		for(ConsultaJSON2ApexSap.Retorno vendedor_sap : vendedor_sap_resp_list.retorno)
			if(pedido.Vendedor__r.CommunityNickName == vendedor_sap.Descricao && vendedor_sap.CodigoSap == ''){
				tela.mensagem.erros.add('O <b>vendedor</b> não possui cadastro no SAP: '+pedido.Vendedor__r.CommunityNickName);
				tela.mensagem.emails.add(
					'<b>VENDEDOR</b>: '+ pedido.Vendedor__r.CommunityNickName +
					'<br/><br/>'
				);
			}
	}

	public void ValidarCondPgtoSAP(){
		HttpRequest  					requisicao 				= new HttpRequest();
		Http 		 					protocolo 				= new Http();
		HttpResponse 					resposta;
		ConsultaJSON2ApexSap.ReqLista 	condpgto_sap_req_list 	= new ConsultaJSON2ApexSap.ReqLista();

		requisicao.setMethod('POST');
		requisicao.setEndPoint('http://201.7.211.65:8889/integrationone/api/Consulta/');

		condpgto_sap_req_list.token = '/XZ9qjPSDYF938+7rN5SAw==';
		condpgto_sap_req_list.BaseSAP = tela.base_sap;
		condpgto_sap_req_list.tabela = 'OCTG';
		condpgto_sap_req_list.campoDescricao = 'PymntGroup';
		condpgto_sap_req_list.campoCodigo = 'GroupNum';
		condpgto_sap_req_list.lista.add(pedido.Condicao_de_pagamento__c);

		requisicao.setBody(JSON.serialize(condpgto_sap_req_list));
		requisicao.setHeader('Content-Type','application/json');
		if(!Test.isRunningTest()){
			logs.add('listar condiçoes pagamento (requisiçao): '+requisicao+requisicao.getBody());
			resposta = protocolo.send(requisicao);
			logs.add('listar condiçoes pagamento (resposta): '+resposta+resposta.getBody());
			condpgto_sap_resp_list = (ConsultaJSON2ApexSap.RespLista)JSON.deserialize(resposta.getBody(), ConsultaJSON2ApexSap.RespLista.class);
		}

		for(ConsultaJSON2ApexSap.Retorno condpgto_sap : condpgto_sap_resp_list.retorno)
			if(pedido.Condicao_de_pagamento__c == condpgto_sap.Descricao && condpgto_sap.CodigoSap == ''){
				tela.mensagem.erros.add('A <b>condição de pagamento</b> não possui cadastro no SAP: '+pedido.Condicao_de_pagamento__c);
				tela.mensagem.emails.add(
					'<b>CONDIÇÃO DE PGTO.</b>: '+ pedido.Condicao_de_pagamento__c +
					'<br/>OBS: Utilizar exatamente o mesmo nome.' +
					'<br/><br/>'
				);
			}
	}

	public void ValidarFormPgtoSAP(){
		HttpRequest  					requisicao 				= new HttpRequest();
		Http 		 					protocolo 				= new Http();
		HttpResponse 					resposta;
		ConsultaJSON2ApexSap.ReqLista 	formpgto_sap_req_list 	= new ConsultaJSON2ApexSap.ReqLista();

		requisicao.setMethod('POST');
		requisicao.setEndPoint('http://201.7.211.65:8889/integrationone/api/Consulta/');

		formpgto_sap_req_list.token = '/XZ9qjPSDYF938+7rN5SAw==';
		formpgto_sap_req_list.BaseSAP = tela.base_sap;
		formpgto_sap_req_list.tabela = 'OPYM';
		formpgto_sap_req_list.campoDescricao = 'Descript';
		formpgto_sap_req_list.campoCodigo = 'PayMethCod';
		formpgto_sap_req_list.lista.add(pedido.Forma_de_pagamento2__c);

		requisicao.setBody(JSON.serialize(formpgto_sap_req_list));
		requisicao.setHeader('Content-Type','application/json');
		if(!Test.isRunningTest()){
			logs.add('listar formas pagamento (requisiçao): '+requisicao+requisicao.getBody());
			resposta = protocolo.send(requisicao);
			logs.add('listar formas pagamento (resposta): '+resposta+resposta.getBody());
			formpgto_sap_resp_list = (ConsultaJSON2ApexSap.RespLista)JSON.deserialize(resposta.getBody(), ConsultaJSON2ApexSap.RespLista.class);
		}

		for(ConsultaJSON2ApexSap.Retorno formpgto_sap : formpgto_sap_resp_list.retorno)
			if(pedido.Forma_de_pagamento2__c == formpgto_sap.Descricao && formpgto_sap.CodigoSap == ''){
				tela.mensagem.erros.add('A <b>forma de pagamento</b> não possui cadastro no SAP: '+pedido.Forma_de_pagamento2__c);
				tela.mensagem.emails.add(
					'<b>FORMA DE PGTO.</b>: '+ pedido.Forma_de_pagamento2__c +
					'<br/>OBS: Utilizar exatamente o mesmo nome.' +
					'<br/><br/>'
				);
			}
	}

	public void ValidarFilialSAP(){
		HttpRequest  					requisicao 				= new HttpRequest();
		Http 		 					protocolo 				= new Http();
		HttpResponse 					resposta;
		ConsultaJSON2ApexSap.ReqLista 	filial_sap_req_list 	= new ConsultaJSON2ApexSap.ReqLista();

		requisicao.setMethod('POST');
		requisicao.setEndPoint('http://201.7.211.65:8889/integrationone/api/Consulta/');

		filial_sap_req_list.token = '/XZ9qjPSDYF938+7rN5SAw==';
		filial_sap_req_list.BaseSAP = tela.base_sap;
		filial_sap_req_list.tabela = 'OBPL';
		filial_sap_req_list.campoDescricao = 'TaxIdNum';
		filial_sap_req_list.campoCodigo = 'BPLId';
		filial_sap_req_list.lista.add(pedido.Faturamento_Feito__r.CNPJ__c);

		requisicao.setBody(JSON.serialize(filial_sap_req_list));
		requisicao.setHeader('Content-Type','application/json');
		if(!Test.isRunningTest()){
			logs.add('listar filiais (requisiçao): '+requisicao+requisicao.getBody());
			resposta = protocolo.send(requisicao);
			logs.add('listar filiais (resposta): '+resposta+resposta.getBody());
			filial_sap_resp_list = (ConsultaJSON2ApexSap.RespLista)JSON.deserialize(resposta.getBody(), ConsultaJSON2ApexSap.RespLista.class);
		}

		for(ConsultaJSON2ApexSap.Retorno filial_sap : filial_sap_resp_list.retorno)
			if(pedido.Faturamento_Feito__r.CNPJ__c == filial_sap.Descricao && filial_sap.CodigoSap == ''){
				tela.mensagem.erros.add('O <b>Faturamento feito (filial)</b> não possui cadastro no SAP: ' + pedido.Faturamento_Feito__r.Name +
					' (CNPJ: ' + pedido.Faturamento_Feito__r.CNPJ__c + ')'
				);
			}
	}

	public void ValidarItensCadastroSAP(){
		HttpRequest  					requisicao 				= new HttpRequest();
		Http 		 					protocolo 				= new Http();
		HttpResponse 					resposta;
		ConsultaJSON2ApexSap.ReqLista 	prods_sap_req_list 		= new ConsultaJSON2ApexSap.ReqLista();

		requisicao.setMethod('POST');
		requisicao.setEndPoint('http://201.7.211.65:8889/integrationone/api/Consulta/');

		prods_sap_req_list.token = '/XZ9qjPSDYF938+7rN5SAw==';
		prods_sap_req_list.BaseSAP = tela.base_sap;
		prods_sap_req_list.tabela = 'OITM';
		prods_sap_req_list.campoDescricao = 'ItemCode';
		prods_sap_req_list.campoCodigo = 'ItemCode';
		for(OrderItem item : pedido.OrderItems){
			if(	!ItemServico(item.PricebookEntry.Product2) &&
				!prods_sap_req_list.lista.contains(item.PricebookEntry.Product2.ProductCode)
			){
				prods_sap_req_list.lista.add(item.PricebookEntry.Product2.ProductCode);
			}
		}

		requisicao.setBody(JSON.serialize(prods_sap_req_list));
		requisicao.setHeader('Content-Type','application/json');
		if(!Test.isRunningTest()){
			if(prods_sap_req_list.lista.size()>0){
				logs.add('listar produtos/código (requisiçao): '+requisicao+requisicao.getBody());
				resposta = protocolo.send(requisicao);
				logs.add('listar produtos/código (resposta): '+resposta+resposta.getBody());				
				prods_sap_resp_list = (ConsultaJSON2ApexSap.RespLista)JSON.deserialize(resposta.getBody(), ConsultaJSON2ApexSap.RespLista.class);
			}else
				prods_sap_resp_list = new ConsultaJSON2ApexSap.RespLista();
		}

		if(prods_sap_req_list.lista.size()>0){
			List<String> itens_sem_cad = new List<String>();
			for(OrderItem item_ped : pedido.OrderItems){
				for(ConsultaJSON2ApexSap.Retorno prod_sap : prods_sap_resp_list.retorno)
					if(item_ped.PricebookEntry.Product2.ProductCode == prod_sap.Descricao && prod_sap.CodigoSap == '' &&
					  !itens_sem_cad.contains(item_ped.PricebookEntry.Product2.ProductCode)){
						itens_sem_cad.add(item_ped.PricebookEntry.Product2.ProductCode);
						tela.mensagem.emails.add(
							'<b>PRODUTO</b>: '+ item_ped.PricebookEntry.Product2.Name +
							'<br/>CÓDIGO FORNECEDOR: ' + item_ped.PricebookEntry.Product2.ProductCode +
							'<br/>CÓDIGO HOSPCOM: ' + item_ped.PricebookEntry.Product2.StockKeepingUnit +
							'<br/>MODELO: ' + (item_ped.PricebookEntry.Product2.Modelo__c==null?'-':item_ped.PricebookEntry.Product2.Modelo__c) +
							'<br/>MARCA: ' + item_ped.PricebookEntry.Product2.Marca__c +
							'<br/>FAMILIA: ' + item_ped.PricebookEntry.Product2.Family +
							'<br/>TIPO: ' + item_ped.PricebookEntry.Product2.Tipo_do_Produto__c +
							'<br/>DESCRIÇÃO: ' + (item_ped.PricebookEntry.Product2.Description==null?'-':item_ped.PricebookEntry.Product2.Description) +
							'<br/><br/>'
						);
					}
			}
			if(itens_sem_cad.size()>0)
				tela.mensagem.erros.add('Os <b>produtos</b> não possuem <b>cadastro</b> no SAP: ' + String.join(itens_sem_cad, ', '));
		}
	}

	public void ValidarItensAtivoSAP(){
		HttpRequest  					requisicao 				= new HttpRequest();
		Http 		 					protocolo 				= new Http();
		HttpResponse 					resposta;
		ConsultaJSON2ApexSap.ReqLista 	prods_sap_req_list 		= new ConsultaJSON2ApexSap.ReqLista();

		requisicao.setMethod('POST');
		requisicao.setEndPoint('http://201.7.211.65:8889/integrationone/api/Consulta/');

		prods_sap_req_list.token = '/XZ9qjPSDYF938+7rN5SAw==';
		prods_sap_req_list.BaseSAP = tela.base_sap;
		prods_sap_req_list.tabela = 'OITM';
		prods_sap_req_list.campoDescricao = 'ItemCode';
		prods_sap_req_list.campoCodigo = 'validFor';
		for(OrderItem item : pedido.OrderItems){
			if(	!ItemServico(item.PricebookEntry.Product2) &&
				!prods_sap_req_list.lista.contains(item.PricebookEntry.Product2.ProductCode)
			){
				prods_sap_req_list.lista.add(item.PricebookEntry.Product2.ProductCode);
			}
		}

		requisicao.setBody(JSON.serialize(prods_sap_req_list));
		requisicao.setHeader('Content-Type','application/json');
		if(!Test.isRunningTest()){
			if(prods_sap_req_list.lista.size()>0){
				logs.add('listar produtos/ativo (requisiçao): '+requisicao+requisicao.getBody());
				resposta = protocolo.send(requisicao);
				logs.add('listar produtos/ativo (resposta): '+resposta+resposta.getBody());				
				prods_sap_resp_list_temp = (ConsultaJSON2ApexSap.RespLista)JSON.deserialize(resposta.getBody(), ConsultaJSON2ApexSap.RespLista.class);
			}else
				prods_sap_resp_list_temp = new ConsultaJSON2ApexSap.RespLista();
		}

		if(prods_sap_req_list.lista.size()>0){
			List<String> itens_nao_ativo = new List<String>();
			for(OrderItem item_ped : pedido.OrderItems){
				for(ConsultaJSON2ApexSap.Retorno prod_sap : prods_sap_resp_list_temp.retorno)
					if(item_ped.PricebookEntry.Product2.ProductCode == prod_sap.Descricao && prod_sap.CodigoSap == 'N' &&
					  !itens_nao_ativo.contains(item_ped.PricebookEntry.Product2.ProductCode)){
						itens_nao_ativo.add(item_ped.PricebookEntry.Product2.ProductCode);
					}
			}
			if(itens_nao_ativo.size()>0)
				tela.mensagem.erros.add('Os <b>produtos</b> estão <b>desativados</b> no SAP: ' + String.join(itens_nao_ativo, ', '));
		}
	}

	public Boolean ItemServico(Product2 produto){
		List<String> servicos_comeca = new List<String>{
			'HORA TÉCNICA DE', 'SERVIÇO DE INSTALAÇÃO DE', 'SERVIÇO DE APLICAÇÃO DE',
			'CALIBRAÇÃO DE', 'QUALIFICAÇÃO DE', 'ENSAIO DE SEGURANÇA ELÉTRICA DE', 'MÃO DE OBRA'
		};
		for(String servico : servicos_comeca)
			if(produto.Name.startsWith(servico))
				return true;

		List<String> servicos_igual = new List<String>{
			'FRETE'
		};
		if(servicos_igual.contains(produto.Name))
			return true;

		return false;
	}

	public void EnviarEmail(){
		Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
		List<String> destinatarios = [SELECT Valor__c FROM Configuracao_SAP__mdt WHERE MasterLabel = 'Emails de cadastros'].Valor__c.replace(' ', '').split(',');

		email.setInReplyTo(UserInfo.getUserEmail());
		email.setBccAddresses(new List<String>{UserInfo.getUserEmail()});
		email.setToAddresses(destinatarios);
		email.setSubject('Cadastro(s) para Ativação do Pedido Nº' + pedido.OrderNumber);
		email.setHtmlBody(
			'Prezado(a),'+
			'<br/>Solicito o cadastro do(s) seguinte(s) registro(s) no SAP, para posterior ativação do pedido de venda Nº'
			+ pedido.OrderNumber + '.' + '<span style="font-size:12px;">' +
			'<br/><br/>' + String.join(tela.mensagem.emails, '') +
			'</span>' +
			'Por favor responder esse e-mail posicionando sobre o(s) cadastro(s).' +
			'<br/><br/>Atencionsamente<br/>'+UserInfo.GetName()+'.'
		);

		if(Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email})[0].isSuccess()){
			tela.mensagem.emails.clear();
			tela.mensagem.sucessos.add('Solicitação enviada com sucesso para o email <b>'+String.join(destinatarios, ', ')+'</b>!');
			tela.mensagem.informacoes.add('Eventuais respostas a essa mensagem serão encaminhadas para <b>'+UserInfo.getUserEmail()+'</b>');
		}else
			tela.mensagem.erros.add('Erro eo enviar email.');
	}

	public void SetarEndereco(){
		for(ContaJSON2ApexSAP.Enderecos endereco : conta_sap_resp_reg.enderecos){
			if(tela.end_tipo=='Cobrança' && endereco.TipoEndereco=='Cobrança' && tela.end_valor==endereco.NomeEndereco){
				List<String> endereco_composto = new List<String>();
				if(endereco.Rua!='') endereco_composto.add(endereco.Rua);
				if(endereco.Numero!='') endereco_composto.add(endereco.Numero);
				if(endereco.Complemento!='') endereco_composto.add(endereco.Complemento);
				if(endereco.Bairro!='') endereco_composto.add(endereco.Bairro);
				pedido.BillingStreet = (endereco_composto.size()>0 ? String.join(endereco_composto, ', ') : '');
				pedido.BillingCity = endereco.Cidade;
				pedido.BillingState = Util.ConverterEstado(endereco.Uf, 'nome');
				pedido.BillingPostalCode = endereco.Cep;
				tela.endereco_cobranca = endereco.NomeEndereco;
			}
			else if(tela.end_tipo=='Entrega' && endereco.TipoEndereco=='Entrega' && tela.end_valor==endereco.NomeEndereco){
				List<String> endereco_composto = new List<String>();
				if(endereco.Rua!='') endereco_composto.add(endereco.Rua);
				if(endereco.Numero!='') endereco_composto.add(endereco.Numero);
				if(endereco.Complemento!='') endereco_composto.add(endereco.Complemento);
				if(endereco.Bairro!='') endereco_composto.add(endereco.Bairro);
				pedido.ShippingStreet = (endereco_composto.size()>0 ? String.join(endereco_composto, ', ') : '');
				pedido.ShippingCity = endereco.Cidade;
				pedido.ShippingState = Util.ConverterEstado(endereco.Uf, 'nome');
				pedido.ShippingPostalCode = endereco.Cep;
				tela.endereco_entrega = endereco.NomeEndereco;
			}
		}
		tela.end_tipo = '';
		tela.end_valor = '';
		
		try{
			Util.AcaoInterna(true);
			update pedido;
			Util.AcaoInterna(false);
		}catch(System.DMLException e){
			tela.mensagem.erros.add(e.getMessage());
		}
	}
	
	public Boolean AtivarPedido(){
		// insere no SAP
		HttpRequest  						requisicao 				= new HttpRequest();
		Http 		 						protocolo 				= new Http();
		HttpResponse 						resposta;
		PedidoJSON2ApexSAP.ReqInsRegistro 	ped_sap_req_ins_reg		= new PedidoJSON2ApexSAP.ReqInsRegistro();
		PedidoJSON2ApexSAP.RespInsRegistro 	ped_sap_resp_ins_reg	= new PedidoJSON2ApexSAP.RespInsRegistro();

		requisicao.setMethod('POST');
		requisicao.setEndPoint('http://201.7.211.65:8889/integrationone/api/Documentos/');

		ped_sap_req_ins_reg.token = '/XZ9qjPSDYF938+7rN5SAw==';
		ped_sap_req_ins_reg.BaseSAP = tela.base_sap;
		ped_sap_req_ins_reg.tipoDocumento = 17;
		ped_sap_req_ins_reg.produtoServico = 'P';
		ped_sap_req_ins_reg.id = pedido.OrderNumber;
		String seriais = '';
		if(pedido.Demonstracao__c!=null)
			for(OrderItem item_ped : pedido.OrderItems)
				seriais += (seriais!='' ? '\n' : '') + 'Número SF: '+item_ped.OrderItemNumber+' => Número de Série: '+item_ped.Description;
		String obs_nota = '';
		if(pedido.Demonstracao__c==null && pedido.Contrato_de_Servi_o__c==null){
			for(OrderItem item_ped : pedido.OrderItems){
				String lote_anvisa = '';
				lote_anvisa += (item_ped.Description==null ? '' : ' => Lote: ' + item_ped.Description) + 
							   (item_ped.PricebookEntry.Product2.Numero_Anvisa__c==null ? '' : ' => Anvisa: ' + item_ped.PricebookEntry.Product2.Numero_Anvisa__c);
				obs_nota += (lote_anvisa=='' ? '' : (obs_nota=='' ? '' : '\n') + 'Número SF: ' + item_ped.OrderItemNumber + lote_anvisa);
			}
		}
		ped_sap_req_ins_reg.camposdeUsuario.add(new Map<String,String>{
			'U_Comments' => (pedido.Observacoes_Gerais__c!=null?pedido.Observacoes_Gerais__c+'\n\n':'') +
							(seriais!='' ? seriais+'\n\n':'') +
							(obs_nota!='' ? obs_nota+'\n\n':'') +
							(pedido.Ordem_de_trabalho__c!=null ? 'Ordem de trabalho: '+ pedido.Ordem_de_trabalho__r.WorkOrderNumber.leftPad(8,'0') + '\n' : '') +
							(pedido.OpportunityId!=null ? 'Oportunidade: '+ pedido.Opportunity.Numero_OP__c.leftPad(8,'0') + '\n' : '') +
							(pedido.QuoteId!=null ? 'Cotação: '+ pedido.Quote.QuoteNumber.leftPad(8,'0') + '\n' : '') +
							(pedido.Demonstracao__c!=null ? 'Demonstração: '+ pedido.Demonstracao__r.Name.leftPad(8,'0') + '\n' : '') + 
							(pedido.Contrato_de_Servi_o__c!=null ? 'Contrato de Serviço: '+ pedido.Contrato_de_Servi_o__r.N_mero_da_Proposta_Contrato__c.leftPad(8,'0') + '\n' : '')
		});
		ped_sap_req_ins_reg.dataLancamento = ((DateTime)pedido.EffectiveDate).formatGMT('yyyy-MM-dd\'T\'hh:mm:ss');
		ped_sap_req_ins_reg.dataVencimento = ((DateTime)pedido.Prazo_de_entrega__c).formatGMT('yyyy-MM-dd\'T\'hh:mm:ss');
		ped_sap_req_ins_reg.filial = Integer.valueOf(filial_sap_resp_list.retorno[0].CodigoSap);
		ped_sap_req_ins_reg.parceiroNegocio.codigoSap = conta_sap_resp_reg.codigoSap;
		ped_sap_req_ins_reg.parceiroNegocio.codigoIntegracao = conta_sap_resp_reg.codigoIntegracao;
		ped_sap_req_ins_reg.entregaParcial = (pedido.Entrega_parcial__c=='Autorizada'?'S':'N');
		ped_sap_req_ins_reg.enderecoCobranca = tela.endereco_cobranca;
		ped_sap_req_ins_reg.enderecoEntrega = tela.endereco_entrega;
		ped_sap_req_ins_reg.codigoVendedor = Integer.valueOf(vendedor_sap_resp_list.retorno[0].CodigoSap);
		if(pedido.Frete__c == 'Contratação do Frete por conta do Remetente (CIF)')
			ped_sap_req_ins_reg.modFrete = '0';
		else if(pedido.Frete__c == 'Contratação do Frete por conta do Destinatário (FOB)')
			ped_sap_req_ins_reg.modFrete = '1';
		else if(pedido.Frete__c == 'Contratação do Frete por conta de Terceiros')
			ped_sap_req_ins_reg.modFrete = '2';
		else if(pedido.Frete__c == 'Transporte Próprio por conta do Remetente')
			ped_sap_req_ins_reg.modFrete = '3';
		else if(pedido.Frete__c == 'Transporte Próprio por conta do Destinatário')
			ped_sap_req_ins_reg.modFrete = '4';
		else if(pedido.Frete__c == 'Sem Ocorrência de Transporte.')
			ped_sap_req_ins_reg.modFrete = '9';
		ped_sap_req_ins_reg.formaPagamento = formpgto_sap_resp_list.retorno[0].CodigoSap;
		ped_sap_req_ins_reg.condicaoPagamento = Integer.valueOf(condpgto_sap_resp_list.retorno[0].CodigoSap);
		for(OrderItem item_ped : pedido.OrderItems){
			PedidoJSON2ApexSAP.Item item = new PedidoJSON2ApexSAP.Item();
			if(ItemServico(item_ped.PricebookEntry.Product2)){
					item.codigoSap = '000054';
					item.NomeItem = item_ped.PricebookEntry.Product2.Name;
			}
			else{
				for(ConsultaJSON2ApexSap.Retorno prod_sap : prods_sap_resp_list.retorno)
					if(item_ped.PricebookEntry.Product2.ProductCode == prod_sap.Descricao)
							item.codigoSap = prod_sap.CodigoSap;
			}
						PedidoJSON2ApexSAP.Linhas linha = new PedidoJSON2ApexSAP.Linhas();
							linha.item = item;
							linha.TextoLivre = item_ped.OrderItemNumber;
							linha.preco = item_ped.UnitPrice;
							linha.quantidade = item_ped.Quantity;
							linha.PercDesconto = 0;
            
			if(pedido.Demonstracao__c!=null || (pedido.Contrato_de_Servi_o__c!=null && pedido.Faturamento_Feito__r.CNPJ__c=='05.743.288/0001-08')) // hospcom
								linha.deposito = '09';
			else if(pedido.Contrato_de_Servi_o__c!=null && pedido.Faturamento_Feito__r.CNPJ__c=='23.813.386/0001-56') // gdb
				linha.deposito = '19';
			else if(pedido.Contrato_de_Servi_o__c!=null && pedido.Faturamento_Feito__r.CNPJ__c=='27.476.124/0001-02') // health
				linha.deposito = '29';
			else if(pedido.Ordem_de_trabalho__c!=null && pedido.Faturamento_Feito__r.CNPJ__c=='05.743.288/0001-08')
				linha.deposito = '03';
            
            if(pedido.Natureza_de_opera_o__c == 'VENDA'){                
				linha.utilizacao = 10;
            	//linha.deposito = '301';
            }
            else if(pedido.Natureza_de_opera_o__c == 'DEMONSTRAÇÃO'){   
				linha.utilizacao = 11;
				//linha.deposito = '01';
            }
            else if(pedido.Natureza_de_opera_o__c == 'SERVIÇO'){   
				linha.utilizacao = 10;
                //if(item_ped.PricebookEntry.Product2.Tipo_do_Produto__c == 'SERVIÇO')
                  //  linha.deposito = '09';
               // else
                  //  linha.deposito = '301';
            }
            else if(pedido.Natureza_de_opera_o__c == 'LOCAÇÃO'){   
				linha.utilizacao = 41;
				//linha.deposito = '01';
            }
            else if(pedido.Natureza_de_opera_o__c == 'BONIFICAÇÃO'){   
				linha.utilizacao = 12;
            	//linha.deposito = '301';
            }
            else if(pedido.Natureza_de_opera_o__c == 'REMESSA DE LOCAÇÃO'){   
				linha.utilizacao = 1;
				//linha.deposito = '01';
            }
            else if(pedido.Natureza_de_opera_o__c == 'REMESSA DE COMODATO'){
				linha.utilizacao = 49;
				//linha.deposito = '01';
            }
            else if(pedido.Natureza_de_opera_o__c == 'REMESSA EM CONSIGNAÇÃO'){
				linha.utilizacao = 66;
				//linha.deposito = '01';
            }
            else if(pedido.Natureza_de_opera_o__c == 'REMESSA DE TROCA'){
				linha.utilizacao = 37;
				//linha.deposito = '01';
            }
			ped_sap_req_ins_reg.linhas.add(linha);
					}
		requisicao.setBody(JSON.serialize(ped_sap_req_ins_reg, true));
		requisicao.setHeader('Content-Type','application/json');

		// insere no sap
		if(!Test.isRunningTest()){
			logs.add('inserir pedido (requisiçao): '+requisicao+requisicao.getBody());
			resposta = protocolo.send(requisicao);
			logs.add('inserir pedido (resposta): '+resposta+resposta.getBody());
			ped_sap_resp_ins_reg = (PedidoJSON2ApexSAP.RespInsRegistro)JSON.deserialize(resposta.getBody(), PedidoJSON2ApexSAP.RespInsRegistro.class);
		}
		if(ped_sap_resp_ins_reg.retorno == 0)
			tela.mensagem.erros.add('Houve um erro ao inserir no SAP: <b>'+ped_sap_resp_ins_reg.mensagem+'</b>');

		// atualiza no sf
		else{
			pedido.Status = 'Ativo';
			try{
				Util.AcaoInterna(true);
				update pedido;
				Util.AcaoInterna(false);
			}catch(System.DMLException e){
				tela.mensagem.erros.add(e.getMessage());
			}
		}

		return (tela.mensagem.erros.size()==0?true:false);
	}

	public void SalvarLog(String obs){
		if(pastas.size()==1){
			for(Integer cont=0; cont<logs.size(); cont++)
				logs[cont] = logs[cont].replaceAll('\\r', ' ').replaceAll('\\n', ' ').replaceAll('\\x0D', ' ');
			Document log_retorno = new Document(
				Name = String.valueOf(System.Now().format('yyyy/MM/dd hh:mm:ss')) + ' - Envia ('+pedido.Ordernumber+')' + ' - ' + obs,
				Body = Blob.valueOf(String.join(logs, '\n')),
				ContentType = 'text/plain',
				Type = 'txt',
				IsPublic = false,
				IsInternalUseOnly = true,
				FolderId = pastas[0].Id
			);
			insert log_retorno;
		}
	}
	
	public Pagereference VoltarAoPedido(){
		return new PageReference('/' + String.valueOf(pedido.Id));
	}

	public class Tela{
		public String url_base {get;set;}
		public Mensagem mensagem {get;set;}
		public Boolean sandbox = false; //[SELECT IsSandbox FROM Organization WHERE Id =:UserInfo.getOrganizationId()].IsSandbox;
		public String base_sap = (sandbox==true ? 'TSTHOSPCOM02' : 'SBOHOSPCOM' );
		public String end_tipo {get;set;}
		public String end_valor {get;set;}
		public String endereco_cobranca {get;set;}
		public String endereco_entrega {get;set;}


		public Tela(){
			url_base = URL.getSalesforceBaseUrl().toExternalForm() + Site.getPathPrefix();
			mensagem = new Mensagem();
			end_tipo = '';
			end_valor = '';
			endereco_cobranca=null;
			endereco_entrega=null;
		}
	}

	public class Mensagem{
		public List<String> erros {get;set;}
		public List<String> sucessos {get;set;}
		public List<String> informacoes {get;set;}
		public List<String> emails {get;set;}

		public Mensagem(){
			erros = new List<String>();
			sucessos = new List<String>();
			informacoes = new List<String>();
			emails = new List<String>();
		}
	}

}