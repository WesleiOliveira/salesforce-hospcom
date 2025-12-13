public class RecebeSAP implements Schedulable{
	
	public Boolean eh_teste = [SELECT IsSandbox FROM Organization WHERE Id =:UserInfo.getOrganizationId()].IsSandbox;
	public String base_sap = (eh_teste==true ? 'TSTHOSPCOM02' : 'SBOHOSPCOM');
	public String url_sap = 'http://201.7.211.65:8889';
	public String token_sap = '/XZ9qjPSDYF938+7rN5SAw==';
	public String parametro_obj = null;
	public List<ObjetoSAP.Retorno> retornos_sap = new List<ObjetoSAP.Retorno>();
	public ObjetoSAP.Conclusao conclusao_sap = new ObjetoSAP.Conclusao();
	public Boolean tem_erro = false;
	public List<Folder> pasta_log = [SELECT id FROM Folder WHERE Name = 'Logs Integração SAP'];
	public List<String> logs = new List<String>();
	
	public Set<String> contas_cod = new Set<String>();
	public Set<String> produtos_cod = new Set<String>();
	public Set<String> estoques_cod = new Set<String>();
	public Set<String> pedidos_cod = new Set<String>();
	public Set<String> notas_pvs_cod = new Set<String>();
	public Set<String> anexos_cod = new Set<String>();
	public Set<String> notas_cod = new Set<String>();
	public List<ObjetoSAP.Parceiro> contas_sap;
	public List<ObjetoSAP.Item> produtos_sap;
	public ObjetoSAP.RespostaGenerica estoques_sap;
	public List<ObjetoSAP.Documento> pedidos_sap;
	public List<ObjetoSAP.Documento> notas_pvs_sap;
	public List<ObjetoSAP.Anexo> anexos_sap;

	public RecebeSAP(String parametro_obj){
		this.parametro_obj = parametro_obj;
		conclusao_sap.token = token_sap;
		conclusao_sap.lista = new List<Integer>();
	}
	
	public void execute(SchedulableContext contexto){
		parametro_obj = (parametro_obj!=null && parametro_obj!='' ? parametro_obj : 'produto,conta,pedido,faturamento,anexo');
		
		if(!Test.isRunningTest())
			System.enqueueJob(new Processamento(this));

		System.abortJob(contexto.getTriggerID());
		DateTime agenda = System.Now().addMinutes(1);
		if(!Test.isRunningTest())
			System.schedule('Integração SAP', agenda.second()+' '+agenda.minute()+' '+agenda.hour()+' * * ?', new RecebeSAP(parametro_obj));
	}

	public class Processamento implements Queueable, Database.AllowsCallouts {
		public RecebeSAP rs;

		public Processamento(RecebeSAP recebe_sap){
			rs = recebe_sap;
		}

		public void execute(QueueableContext contexto) {
			Util.AcaoInterna(true);
			rs.logs.add('parametros de entrada: '+rs.parametro_obj);
			
			try{
				ConsultarPendencias();
				ProcessarPedidos('buscar');
				ProcessarContas('buscar');
				ProcessarProdutos('buscar');
				ProcessarFaturamentos('buscar');
				ProcessarAnexos('buscar');
			}catch(Exception error) {
				rs.tem_erro = true;
				rs.logs.add('-- erro --');	
				rs.logs.add('tipo: ' + error.getTypeName());	
				rs.logs.add('mensagem: ' + error.getMessage());   
				rs.logs.add('causa: ' + error.getCause());
				rs.logs.add('linha: ' + error.getLineNumber());   
				rs.logs.add('rastreio: ' + error.getStackTraceString());   
			}
			
			if(!rs.tem_erro){
				Savepoint checkpoint = Database.setSavepoint();
				try{
					update new User(Id=UserInfo.getUserId(), Ignorar_erros__c=true);
					ProcessarContas('salvar');
					ProcessarProdutos('salvar');
					ProcessarPedidos('salvar');
					ProcessarFaturamentos('salvar');
					ProcessarAnexos('salvar');					
					update new User(Id=UserInfo.getUserId(), Ignorar_erros__c=false);
				}catch(Exception error) {
					rs.tem_erro = true;
					rs.logs.add('-- erro --');	
					rs.logs.add('tipo: ' + error.getTypeName());	
					rs.logs.add('mensagem: ' + error.getMessage());   
					rs.logs.add('causa: ' + error.getCause());
					rs.logs.add('linha: ' + error.getLineNumber());   
					rs.logs.add('rastreio: ' + error.getStackTraceString());   
					Database.rollback(checkpoint);
				}
			}
			
			if(!Test.isRunningTest())
				System.enqueueJob(new Conclusao(rs));
		}

		public void ConsultarPendencias(){
			HttpRequest requisicao = new HttpRequest();
			requisicao.setMethod('GET');
			requisicao.setEndPoint(rs.url_sap+'/integrationone/api/Pendentes/' + rs.base_sap);
			rs.logs.add('listar retornos sap (requisicao): ' + requisicao+requisicao.getBody());
			Http protocolo = new Http();
			if(!Test.isRunningTest()){
				HttpResponse resposta = protocolo.send(requisicao);
				rs.logs.add('listar retornos sap (resposta): ' + resposta+resposta.getBody());
				rs.retornos_sap = (List<ObjetoSAP.Retorno>) JSON.deserialize(resposta.getBody(), List<ObjetoSAP.Retorno>.class);
			}
			
			if(rs.retornos_sap.size()>0){
				if((rs.parametro_obj.split(','))[0].isNumeric()){
					rs.logs.add('processar retornos em lotes de: ' + (rs.parametro_obj.split(','))[0]);
					if(integer.valueOf((rs.parametro_obj.split(','))[0]) < rs.retornos_sap.size()){
						List<ObjetoSAP.Retorno> new_retornos_sap = new List<ObjetoSAP.Retorno>();
						for(Integer cont=0; cont<integer.valueOf((rs.parametro_obj.split(','))[0]); cont++)
							new_retornos_sap.add(rs.retornos_sap[cont]);
						rs.retornos_sap.clear();
						rs.retornos_sap.addAll(new_retornos_sap);						
					}
				}				
				rs.logs.add('limpar retornos sap (antes): ' + JSON.serialize(rs.retornos_sap));
				for(Integer cont_fin=rs.retornos_sap.size()-1; cont_fin>=0; cont_fin--){
					Map<String,Object> retorno_fin = (Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(rs.retornos_sap[cont_fin]));
					retorno_fin.put('Id', null);
					for(Integer cont_ini=0; cont_ini<rs.retornos_sap.size(); cont_ini++){
						if(rs.retornos_sap[cont_fin].Id != rs.retornos_sap[cont_ini].Id){
							Map<String,Object> retorno_ini = (Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(rs.retornos_sap[cont_ini]));
							retorno_ini.put('Id', null);
							if(retorno_fin == retorno_ini){
								rs.conclusao_sap.lista.add(rs.retornos_sap[cont_fin].Id);
								rs.retornos_sap.remove(cont_fin);
								break;
							}
						}
					}
				}
				rs.logs.add('limpar retornos sap (depois): ' + JSON.serialize(rs.retornos_sap));
			}
		}

		public void ProcessarContas(String acao){
			if(acao=='buscar'){
				for(ObjetoSAP.Retorno retorno : rs.retornos_sap){
					if(retorno.ObjetoDesc == 'Parceiro de Negócios'){
						if(retorno.ComandoDesc == 'Adicionar' || retorno.ComandoDesc == 'Atualizar'){
							rs.conclusao_sap.lista.add(retorno.Id);
							if(rs.parametro_obj.contains('conta'))
								rs.contas_cod.add(retorno.CodigoAuxiliar);
						}
					}
				}
				if(rs.pedidos_sap!=null)
					for(ObjetoSAP.Documento pedido_sap : rs.pedidos_sap)
						rs.contas_cod.add(pedido_sap.ParceiroNegocio.Cnpj!=null ? pedido_sap.ParceiroNegocio.Cnpj : pedido_sap.ParceiroNegocio.Cpf);
				
				if(rs.contas_cod.size()>0){
					rs.logs.add('códigos das contas: ' + JSON.serialize(rs.contas_cod));

					HttpRequest requisicao = new HttpRequest();
					requisicao.setMethod('POST');
					requisicao.setEndPoint(rs.url_sap+'/integrationone/api/Parceiros/CpfCnpj');
					requisicao.setHeader('Content-Type','application/json');
					ObjetoSAP.Requisicao requisicao_contas_sap = new ObjetoSAP.Requisicao();
					requisicao_contas_sap.token = rs.token_sap;
					requisicao_contas_sap.BaseSAP = rs.base_sap;
					requisicao_contas_sap.lista = new List<String>(rs.contas_cod);
					requisicao.setBody(JSON.serialize(requisicao_contas_sap, true));
					rs.logs.add('listar contas sap (requisicao): ' + requisicao+requisicao.getBody());
					Http protocolo = new Http();
					if(!Test.isRunningTest()){
						HttpResponse resposta = protocolo.send(requisicao);
						rs.logs.add('listar contas sap (resposta): ' + resposta+resposta.getBody());
						rs.contas_sap = (List<ObjetoSAP.Parceiro>) JSON.deserialize(resposta.getBody(), List<ObjetoSAP.Parceiro>.class);
					}
				}
			}
			else if(acao=='salvar'){
				if(rs.contas_cod.size()>0){
					List<Account> contas_sf_atu_cnpj = [
						SELECT 	Id, CNPJ__c, CPF__pc, Status_receita__c, Type, Name, Raz_o_Social__c, Ownership,
								Inscri_o_Estadual__c, Inscri_o_Municipal__c, Industry, Description, Phone, Fax, PersonMobilePhone,
								Website, PersonEmail, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry,
								ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry
						FROM	Account
						WHERE 	CNPJ__c IN :rs.contas_cod
					];
					List<Account> contas_sf_atu_cpf = [
						SELECT 	Id, CNPJ__c, CPF__pc, Status_receita__c, Type, FirstName, LastName, Raz_o_Social__c, Ownership,
								Inscri_o_Estadual__c, Inscri_o_Municipal__c, Industry, Description, Phone, Fax, PersonMobilePhone,
								Website, PersonEmail, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry,
								ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry
						FROM	Account
						WHERE 	CPF__pc IN :rs.contas_cod
					];
					List<Contact> contatos_sf = [
						SELECT CPF__c
						FROM Contact
						WHERE CPF__c IN :rs.contas_cod
					];
					List<Account> contas_sf_atu = new List<Account>();
					contas_sf_atu.addAll(contas_sf_atu_cnpj);
					contas_sf_atu.addAll(contas_sf_atu_cpf);
					rs.logs.add('listar contas sales: ' + JSON.serialize(contas_sf_atu));
					List<Account> contas_sf_ins = new List<Account>();

					Id conta_comercial_id=null, conta_pessoal_id=null;
					for(RecordType tipo_registro : [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Account']){
						if(tipo_registro.Name == 'Conta comercial')
							conta_comercial_id = tipo_registro.Id;
						else
							conta_pessoal_id = tipo_registro.Id;
					}

					for(ObjetoSAP.Parceiro conta_sap : rs.contas_sap){
						if(conta_sap.Fantasia!=null || conta_sap.RazaoSocial!=null){
							
							
							
							Boolean econtato = false;
							for(Contact contatosf : contatos_sf) {
								if (contatosf.CPF__c == conta_sap.Cpf){
									econtato = true;
								}
							}
							
							if (!econtato){
								Boolean existente = false;
								String tipo = (conta_sap.Cnpj!=null && conta_sap.Cnpj!='' ? 'CNPJ' : 'CPF');
								for(Account conta_sf_atu : contas_sf_atu){
									if(conta_sap.Cnpj == conta_sf_atu.CNPJ__c || conta_sap.Cpf == conta_sf_atu.CPF__pc){
										existente = true;
										conta_sf_atu.Status_receita__c = 'SUCESSO';
										conta_sf_atu.Type = 'CLIENTE';
										if(tipo=='CNPJ')
											conta_sf_atu.Name = (conta_sap.Fantasia!=null && conta_sap.Fantasia!='' ? conta_sap.Fantasia : conta_sf_atu.Name);
										else{
											conta_sf_atu.FirstName = '';
											List<String> nomes = conta_sap.RazaoSocial.split(' ');
											for(Integer cont=0; cont<nomes.size(); cont++)
												if(cont == nomes.size()-1)
													conta_sf_atu.LastName = nomes[cont];
												else
													conta_sf_atu.FirstName += ' ' + nomes[cont];
										}
										conta_sf_atu.Raz_o_Social__c = (tipo=='CNPJ' ? conta_sap.RazaoSocial : null );
										conta_sf_atu.Ownership = (tipo=='CNPJ' ? null : 'PRIVADO' ); // sap:DescricaoGrupo
										conta_sf_atu.Inscri_o_Estadual__c = (tipo=='CNPJ' ? conta_sap.InscricaoEstadual : null);
										conta_sf_atu.Inscri_o_Municipal__c = (tipo=='CNPJ' ? conta_sap.InscricaoMunicipal : null);
										conta_sf_atu.Industry = (tipo=='CNPJ' ? 'OUTROS' : null); // sap:SetorNome
										conta_sf_atu.Description = conta_sap.TextoLivre;
										conta_sf_atu.Phone = '('+conta_sap.Telefone2+') '+conta_sap.Telefone;
										conta_sf_atu.Fax = (tipo=='CNPJ' ? conta_sap.Fax : null);
										conta_sf_atu.PersonMobilePhone = (tipo=='CNPJ' ? null : conta_sap.Celular);
										conta_sf_atu.Website = (tipo=='CNPJ' ? conta_sap.Site : null);
										conta_sf_atu.PersonEmail = (tipo=='CNPJ' || !conta_sap.Email.contains('@') ? null : conta_sap.Email);
										if(conta_sap.Enderecos != null){
											for(ObjetoSAP.Endereco endereco : conta_sap.Enderecos)
												if(endereco.TipoEndereco == 'Cobrança'){
													conta_sf_atu.BillingStreet = '';
													if(endereco.Logradouro!=null && endereco.Logradouro!='')
														conta_sf_atu.BillingStreet += (conta_sf_atu.BillingStreet!='' ? ', ' : '') + endereco.Logradouro;
													if(endereco.Numero!=null && endereco.Numero!='')
														conta_sf_atu.BillingStreet += (conta_sf_atu.BillingStreet!='' ? ', ' : '') + endereco.Numero;
													if(endereco.Complemento!=null && endereco.Complemento!='')
														conta_sf_atu.BillingStreet += (conta_sf_atu.BillingStreet!='' ? ', ' : '') + endereco.Complemento;
													if(endereco.Bairro!=null && endereco.Bairro!='')
														conta_sf_atu.BillingStreet += (conta_sf_atu.BillingStreet!='' ? ', ' : '') + endereco.Bairro;
													conta_sf_atu.BillingCity = endereco.Cidade;
													conta_sf_atu.BillingState = Util.ConverterEstado(endereco.Uf,'nome');
													conta_sf_atu.BillingPostalCode = endereco.Cep;
													conta_sf_atu.BillingCountry = (endereco.Pais=='BR' ? 'Brasil' : null);
													break;
												}
											for(ObjetoSAP.Endereco endereco : conta_sap.Enderecos)
												if(endereco.TipoEndereco == 'Entrega'){
													conta_sf_atu.ShippingStreet = '';
													if(endereco.Logradouro!=null && endereco.Logradouro!='')
														conta_sf_atu.ShippingStreet += (conta_sf_atu.ShippingStreet!='' ? ', ' : '') + endereco.Logradouro;
													if(endereco.Numero!=null && endereco.Numero!='')
														conta_sf_atu.ShippingStreet += (conta_sf_atu.ShippingStreet!='' ? ', ' : '') + endereco.Numero;
													if(endereco.Complemento!=null && endereco.Complemento!='')
														conta_sf_atu.ShippingStreet += (conta_sf_atu.ShippingStreet!='' ? ', ' : '') + endereco.Complemento;
													if(endereco.Bairro!=null && endereco.Bairro!='')
														conta_sf_atu.ShippingStreet += (conta_sf_atu.ShippingStreet!='' ? ', ' : '') + endereco.Bairro;
													conta_sf_atu.ShippingCity = endereco.Cidade;
													conta_sf_atu.ShippingState = Util.ConverterEstado(endereco.Uf,'nome');
													conta_sf_atu.ShippingPostalCode = endereco.Cep;
													conta_sf_atu.ShippingCountry = (endereco.Pais=='BR' ? 'Brasil' : null);
													break;
												}
										}
									}
								}
								if(!existente){
									Account conta_sf_ins = new Account();
									conta_sf_ins.RecordTypeId = (tipo=='CNPJ' ? conta_comercial_id : conta_pessoal_id);
									conta_sf_ins.CNPJ__c = (tipo=='CNPJ' ? conta_sap.Cnpj : null );
									if(tipo!='CNPJ')
										conta_sf_ins.CPF__pc = conta_sap.Cpf;
									conta_sf_ins.Status_receita__c = 'SUCESSO';
									conta_sf_ins.Type = 'CLIENTE';
									if(tipo=='CNPJ')
										conta_sf_ins.Name = (tipo=='CNPJ' ? (!string.isblank(conta_sap.Fantasia) ? conta_sap.Fantasia : conta_sap.RazaoSocial) : null);
									else{
										conta_sf_ins.FirstName = '';
										List<String> nomes = conta_sap.RazaoSocial.split(' ');
										for(Integer cont=0; cont<nomes.size(); cont++)
											if(cont == nomes.size()-1)
												conta_sf_ins.LastName = nomes[cont];
											else
												conta_sf_ins.FirstName += ' ' + nomes[cont];
									}
									conta_sf_ins.Raz_o_Social__c = (tipo=='CNPJ' ? conta_sap.RazaoSocial : null );
									conta_sf_ins.Ownership = (tipo=='CNPJ' ? null : 'PRIVADO' ); // sap:DescricaoGrupo
									conta_sf_ins.Inscri_o_Estadual__c = (tipo=='CNPJ' ? conta_sap.InscricaoEstadual : null);
									conta_sf_ins.Inscri_o_Municipal__c = (tipo=='CNPJ' ? conta_sap.InscricaoMunicipal : null);
									conta_sf_ins.Industry = (tipo=='CNPJ' ? 'OUTROS' : null); // sap:SetorNome
									conta_sf_ins.Description = conta_sap.TextoLivre;
									conta_sf_ins.Phone = '('+conta_sap.Telefone2+') '+conta_sap.Telefone;
									conta_sf_ins.Fax = (tipo=='CNPJ' ? conta_sap.Fax : null);
									conta_sf_ins.PersonMobilePhone = (tipo=='CNPJ' ? null : conta_sap.Celular);
									conta_sf_ins.Website = (tipo=='CNPJ' ? conta_sap.Site : null);
									conta_sf_ins.PersonEmail = (tipo=='CNPJ' || !conta_sap.Email.contains('@') ? null : conta_sap.Email);
									if(conta_sap.Enderecos != null){
										for(ObjetoSAP.Endereco endereco : conta_sap.Enderecos)
											if(endereco.TipoEndereco == 'Cobrança'){
												conta_sf_ins.BillingStreet = '';
												if(endereco.Logradouro!=null && endereco.Logradouro!='')
													conta_sf_ins.BillingStreet += (conta_sf_ins.BillingStreet!='' ? ', ' : '') + endereco.Logradouro;
												if(endereco.Numero!=null && endereco.Numero!='')
													conta_sf_ins.BillingStreet += (conta_sf_ins.BillingStreet!='' ? ', ' : '') + endereco.Numero;
												if(endereco.Complemento!=null && endereco.Complemento!='')
													conta_sf_ins.BillingStreet += (conta_sf_ins.BillingStreet!='' ? ', ' : '') + endereco.Complemento;
												if(endereco.Bairro!=null && endereco.Bairro!='')
													conta_sf_ins.BillingStreet += (conta_sf_ins.BillingStreet!='' ? ', ' : '') + endereco.Bairro;
												conta_sf_ins.BillingCity = endereco.Cidade;
												conta_sf_ins.BillingState = Util.ConverterEstado(endereco.Uf,'nome');
												conta_sf_ins.BillingPostalCode = endereco.Cep;
												conta_sf_ins.BillingCountry = (endereco.Pais=='BR' ? 'Brasil' : null);
												break;
											}
										for(ObjetoSAP.Endereco endereco : conta_sap.Enderecos)
											if(endereco.TipoEndereco == 'Entrega'){
												conta_sf_ins.ShippingStreet = '';
												if(endereco.Logradouro!=null && endereco.Logradouro!='')
													conta_sf_ins.ShippingStreet += (conta_sf_ins.ShippingStreet!='' ? ', ' : '') + endereco.Logradouro;
												if(endereco.Numero!=null && endereco.Numero!='')
													conta_sf_ins.ShippingStreet += (conta_sf_ins.ShippingStreet!='' ? ', ' : '') + endereco.Numero;
												if(endereco.Complemento!=null && endereco.Complemento!='')
													conta_sf_ins.ShippingStreet += (conta_sf_ins.ShippingStreet!='' ? ', ' : '') + endereco.Complemento;
												if(endereco.Bairro!=null && endereco.Bairro!='')
													conta_sf_ins.ShippingStreet += (conta_sf_ins.ShippingStreet!='' ? ', ' : '') + endereco.Bairro;
												conta_sf_ins.ShippingCity = endereco.Cidade;
												conta_sf_ins.ShippingState = Util.ConverterEstado(endereco.Uf,'nome');
												conta_sf_ins.ShippingPostalCode = endereco.Cep;
												conta_sf_ins.ShippingCountry = (endereco.Pais=='BR' ? 'Brasil' : null);
												break;
											}
									}
									contas_sf_ins.add(conta_sf_ins);
								}
							}
							
							
						}
					}

					if(contas_sf_atu.size()>0){
						rs.logs.add('atualizar contas sales: ' + JSON.serialize(contas_sf_atu));
						update contas_sf_atu;
					}
					if(contas_sf_ins.size()>0){
						rs.logs.add('inserir contas sales: ' + JSON.serialize(contas_sf_ins));
						insert contas_sf_ins;
					}
				}
			}
		}

		public void ProcessarProdutos(String acao){
			if(acao=='buscar'){
					List<String> produtos_del_cod = new List<String>();
					for(ObjetoSAP.Retorno retorno : rs.retornos_sap)
						if(retorno.ObjetoDesc == 'Item' && retorno.ComandoDesc == 'Remover'){
							rs.conclusao_sap.lista.add(retorno.Id);
							if(rs.parametro_obj.contains('produto'))
								produtos_del_cod.add(retorno.CodigoAuxiliar);
						}
					for(ObjetoSAP.Retorno retorno : rs.retornos_sap)
						if((retorno.ObjetoDesc == 'Item' && (retorno.ComandoDesc == 'Adicionar' || retorno.ComandoDesc == 'Atualizar')) ||
						    retorno.ObjetoDesc == 'Alteração de Estoque'
						){						
							rs.conclusao_sap.lista.add(retorno.Id);
							if(!produtos_del_cod.contains(retorno.CodigoAuxiliar))
								if(rs.parametro_obj.contains('produto'))
									rs.produtos_cod.add(retorno.CodigoAuxiliar);
						}
				if(rs.pedidos_sap!=null)
					for(ObjetoSAP.Documento pedido_sap : rs.pedidos_sap)
						for(ObjetoSAP.Linha linha_sap : pedido_sap.Linhas)
							rs.produtos_cod.add(linha_sap.CodigoItem);

				if(rs.produtos_cod.size()>0){
					rs.logs.add('códigos dos produtos: ' + JSON.serialize(rs.produtos_cod));

					HttpRequest requisicao = new HttpRequest();
					requisicao.setMethod('POST');
					requisicao.setEndPoint(rs.url_sap+'/integrationone/api/Itens/Lista');
					requisicao.setHeader('Content-Type','application/json');
					ObjetoSAP.Requisicao requisicao_produtos_sap = new ObjetoSAP.Requisicao();
					requisicao_produtos_sap.token = rs.token_sap;
					requisicao_produtos_sap.BaseSAP = rs.base_sap;
					requisicao_produtos_sap.lista = new List<String>(rs.produtos_cod);
					requisicao.setBody(JSON.serialize(requisicao_produtos_sap, true));
					rs.logs.add('listar produtos sap (requisicao): ' + requisicao+requisicao.getBody());
					Http protocolo = new Http();
					if(!Test.isRunningTest()){
						HttpResponse resposta = protocolo.send(requisicao);
						rs.logs.add('listar produtos sap (resposta): ' + resposta+resposta.getBody());
						rs.produtos_sap = (List<ObjetoSAP.Item>) JSON.deserialize(resposta.getBody(), List<ObjetoSAP.Item>.class);
					}
					
					for(ObjetoSAP.Item produto_sap : rs.produtos_sap)
						for(ObjetoSAP.Estoque ent_est_sap : produto_sap.Estoque)
							rs.estoques_cod.add(ent_est_sap.Deposito);
					
					if(rs.estoques_cod.size()>0){
						rs.logs.add('códigos dos estoques: ' + JSON.serialize(rs.estoques_cod));
						
						requisicao = new HttpRequest();
						requisicao.setMethod('POST');
						requisicao.setEndPoint(rs.url_sap+'/integrationone/api/Consulta');
						requisicao.setHeader('Content-Type','application/json');
						ObjetoSAP.RequisicaoGenerica requisicao_estoques_sap = new ObjetoSAP.RequisicaoGenerica();
						requisicao_estoques_sap.token = rs.token_sap;
						requisicao_estoques_sap.BaseSAP = rs.base_sap;
						requisicao_estoques_sap.tabela = 'OWHS';
						requisicao_estoques_sap.campoDescricao = 'WhsCode';
						requisicao_estoques_sap.campoCodigo = 'WhsName';
						requisicao_estoques_sap.lista = new List<String>(rs.estoques_cod);
						requisicao.setBody(JSON.serialize(requisicao_estoques_sap, true));
						rs.logs.add('listar estoques sap (requisicao): ' + requisicao+requisicao.getBody());
						protocolo = new Http();
						if(!Test.isRunningTest()){
							HttpResponse resposta = protocolo.send(requisicao);
							rs.logs.add('listar estoques sap (resposta): ' + resposta+resposta.getBody());
							rs.estoques_sap = (ObjetoSAP.RespostaGenerica) JSON.deserialize(resposta.getBody(), ObjetoSAP.RespostaGenerica.class);
						}
					}
				}
			}
			else if(acao=='salvar'){
				if(rs.produtos_cod.size()>0){
					List<Product2> produtos_sf_atu = [
						SELECT 	Id, ProductCode, IsActive, Name, Description, Marca__c, Family, Tipo_do_Produto__c, Quantidade__c, 
								CurrencyIsoCode, (
									SELECT	Id, Pricebook2Id, CurrencyIsoCode, UnitPrice, IsActive, UseStandardPrice
									FROM	PricebookEntries
								), (
									SELECT	Id, Estoque__r.Codigo__c, Em_estoque__c, Confirmado__c, Pedido__c
									FROM	Entradas_de_Estoque__r
								)
						FROM	Product2
						WHERE 	ProductCode IN :rs.produtos_cod
					];
					rs.logs.add('listar produtos sales: ' + JSON.serialize(produtos_sf_atu));
					List<Product2> produtos_sf_ins = new List<Product2>();
					List<Product2> produtos_sf_all = new List<Product2>();
					List<PricebookEntry> entradas_pad_sf_ins = new List<PricebookEntry>();
					List<PricebookEntry> entradas_div_sf_ins = new List<PricebookEntry>();
					
					List<Pricebook2> catalogos = [
						SELECT	Id, IsStandard, CurrencyIsoCode
						FROM	Pricebook2
					];
					List<CurrencyType> moedas = [
						SELECT	Id, IsoCode
						FROM	CurrencyType
					];
					
					List<String> marcas = new List<String>();
					List<String> familias = new List<String>();
					for(Schema.PicklistEntry marca : Product2.Marca__c.getDescribe().getPicklistValues())
						marcas.add(marca.getLabel());
					for(Schema.PicklistEntry familia : Product2.Family.getDescribe().getPicklistValues())
						familias.add(familia.getLabel());

					for(ObjetoSAP.Item produto_sap : rs.produtos_sap){
						Boolean existente = false;
						for(Product2 produto_sf_atu : produtos_sf_atu){
							if(produto_sap.CodigoSap == produto_sf_atu.ProductCode){
								existente = true;
								produto_sf_atu.IsActive = produto_sap.Valid;
								for(CurrencyType moeda : moedas){
									for(Pricebook2 catalogo : catalogos){
										Boolean existente_entrada = false;
										for(PricebookEntry entrada_sf : produto_sf_atu.PricebookEntries)
											if(moeda.IsoCode == entrada_sf.CurrencyIsoCode && catalogo.Id == entrada_sf.Pricebook2Id)
												existente_entrada = true;
										if(!existente_entrada){
											PricebookEntry entrada_sf_ins = new PricebookEntry(
												Product2Id = produto_sf_atu.Id,
												Pricebook2Id = catalogo.Id,
												CurrencyIsoCode = moeda.IsoCode, 
												UnitPrice = 0, 
												IsActive = true, 
												UseStandardPrice = false
											);
											if(catalogo.IsStandard)
												entradas_pad_sf_ins.add(entrada_sf_ins);
											else
												entradas_div_sf_ins.add(entrada_sf_ins);
										}
									}
								}
							}
						}
						if(!existente){
							Product2 produto_sf_ins = new Product2();
							produto_sf_ins.ProductCode = produto_sap.CodigoSap;
							produto_sf_ins.IsActive = produto_sap.Valid;
							produto_sf_ins.Name = (produto_sap.NomeItem!=null ? produto_sap.NomeItem : 'PRODUTO SEM NOME NO SAP');
							produto_sf_ins.Description = produto_sap.Observacoes;
							if(marcas.contains(produto_sap.DescricaoFabricante))
								produto_sf_ins.Marca__c = produto_sap.DescricaoFabricante;
							else
								produto_sf_ins.Marca__c = 'OUTROS';
							if(familias.contains(produto_sap.DescricaoGrupo))
								produto_sf_ins.Family = produto_sap.DescricaoGrupo;
							else
								produto_sf_ins.Family = 'OUTROS';
							if(produto_sap.Caracteristica2)
								produto_sf_ins.Tipo_do_Produto__c = 'PEÇA';
							else if(produto_sap.Caracteristica3)
								produto_sf_ins.Tipo_do_Produto__c = 'ACESSÓRIO';
							else if(produto_sap.Caracteristica4)
								produto_sf_ins.Tipo_do_Produto__c = 'EQUIPAMENTO';
							else if(produto_sap.Caracteristica5)
								produto_sf_ins.Tipo_do_Produto__c = 'CONSUMÍVEL';
							produto_sf_ins.Quantidade__c = 0;
							produtos_sf_ins.add(produto_sf_ins);
						}
					}

					if(produtos_sf_atu.size()>0){
						rs.logs.add('atualizar produtos sales: ' + JSON.serialize(produtos_sf_atu));
						update produtos_sf_atu;
					}
					
					if(produtos_sf_ins.size()>0){
						rs.logs.add('inserir produtos sales: ' + JSON.serialize(produtos_sf_ins));
						insert produtos_sf_ins;
						
						for(Product2 produto_sf_ins : produtos_sf_ins)
							for(CurrencyType moeda : moedas)
								for(Pricebook2 catalogo : catalogos){
									PricebookEntry entrada_sf_ins = new PricebookEntry(
										Product2Id = produto_sf_ins.Id,
										Pricebook2Id = catalogo.Id,
										CurrencyIsoCode = moeda.IsoCode, 
										UnitPrice = 0, 
										IsActive = true, 
										UseStandardPrice = false
									);
									if(catalogo.IsStandard)
										entradas_pad_sf_ins.add(entrada_sf_ins);
									else
										entradas_div_sf_ins.add(entrada_sf_ins);
								}
					}
					produtos_sf_all.addAll(produtos_sf_atu);
					produtos_sf_all.addAll(produtos_sf_ins);
					
					if(entradas_pad_sf_ins.size()>0){
						rs.logs.add('inserir entradas padrão sales: ' + JSON.serialize(entradas_pad_sf_ins));
						insert entradas_pad_sf_ins;
					}
					
					if(entradas_div_sf_ins.size()>0){
						rs.logs.add('inserir entradas diversas sales: ' + JSON.serialize(entradas_div_sf_ins));
						insert entradas_div_sf_ins;
					}
					
					List<Estoque__c> estoques_sf_ins = new List<Estoque__c>();
					List<Estoque__c> estoques_sf_all = new List<Estoque__c>();
					List<Estoque__c> estoques_sf = [
						SELECT	Id, Name, Codigo__c
						FROM	Estoque__c
					];
					rs.logs.add('listar estoques sales: ' + JSON.serialize(produtos_sf_atu));
					
					for(ObjetoSAP.RetornoGenerico estoque_sap : rs.estoques_sap.retorno){
						Boolean existente_estoque = false; 
						for(Estoque__c estoque_sf : estoques_sf)
							if(estoque_sap.Descricao == estoque_sf.Codigo__c)
								existente_estoque = true;
						if(!existente_estoque)
							estoques_sf_ins.add(new Estoque__c(
								Name = estoque_sap.CodigoSap,
								Codigo__c = estoque_sap.Descricao
							));
					}
					if(estoques_sf_ins.size()>0){
						rs.logs.add('inserir estoques sales: ' + JSON.serialize(estoques_sf_ins));
						insert estoques_sf_ins;
					}
					estoques_sf_all.addAll(estoques_sf);
					estoques_sf_all.addAll(estoques_sf_ins);
					
					List<Entrada_de_estoque__c> ents_est_sf_atu = new List<Entrada_de_estoque__c>();
					List<Entrada_de_estoque__c> ents_est_sf_ins = new List<Entrada_de_estoque__c>();
					List<Entrada_de_estoque__c> ents_est_sf_del = new List<Entrada_de_estoque__c>();
					
					for(ObjetoSAP.Item produto_sap : rs.produtos_sap){
						for(Product2 produto_sf : produtos_sf_all){
							if(produto_sap.CodigoSap == produto_sf.ProductCode){
								for (Entrada_de_Estoque__c ent_est_sf : produto_sf.Entradas_de_Estoque__r){
									ent_est_sf.Em_estoque__c = 0;
									ent_est_sf.Confirmado__c = 0;
									ent_est_sf.Pedido__c = 0;
									
								}
								for(ObjetoSAP.Estoque ent_est_sap : produto_sap.Estoque){
									if(ent_est_sap.EmEstoque+ent_est_sap.Confirmado+ent_est_sap.EmPedido > 0){
										Boolean existente_ent_est = false;
										if(produto_sf.Entradas_de_Estoque__r!=null)
											for(Entrada_de_Estoque__c ent_est_sf : produto_sf.Entradas_de_Estoque__r){
												if(ent_est_sap.Deposito == ent_est_sf.Estoque__r.Codigo__c){
													existente_ent_est = true;
													ent_est_sf.Em_estoque__c = ent_est_sap.EmEstoque;
													ent_est_sf.Confirmado__c = ent_est_sap.Confirmado;
													ent_est_sf.Pedido__c = ent_est_sap.EmPedido;
													ents_est_sf_atu.add(ent_est_sf);
												}
											}
										if(!existente_ent_est){
											Id estoque_id;
											for(Estoque__c estoque_sf : estoques_sf_all)
												if(estoque_sf.Codigo__c == ent_est_sap.Deposito)
													estoque_id = estoque_sf.Id;
											ents_est_sf_ins.add(new Entrada_de_Estoque__c(
												Estoque__c = estoque_id,
												Produto__c = produto_sf.Id,
												Em_estoque__c = ent_est_sap.EmEstoque,
												Confirmado__c = ent_est_sap.Confirmado,
												Pedido__c = ent_est_sap.EmPedido
											));
										}
									}
								}
								for(Entrada_de_Estoque__c ent_est_sf : produto_sf.Entradas_de_Estoque__r)
									if(ent_est_sf.Em_estoque__c+ent_est_sf.Confirmado__c+ent_est_sf.Pedido__c == 0)
										ents_est_sf_del.add(ent_est_sf);
							}
						}
					}
					
					if(ents_est_sf_atu.size()>0){
						rs.logs.add('atualizar entradas de estoque sales: ' + JSON.serialize(ents_est_sf_atu));
						update ents_est_sf_atu;
					}
					
					if(ents_est_sf_ins.size()>0){
						rs.logs.add('inserir entradas de estoque sales: ' + JSON.serialize(ents_est_sf_ins));
						insert ents_est_sf_ins;
					}
					
					if(ents_est_sf_del.size()>0){
						rs.logs.add('deletar entradas de estoque sales: ' + JSON.serialize(ents_est_sf_del));
						delete ents_est_sf_del;
					}
				}
			}
		}

		public void ProcessarPedidos(String acao){
			if(acao=='buscar'){
				for(ObjetoSAP.Retorno retorno : rs.retornos_sap){
					if(retorno.ObjetoDesc == 'Pedido de Venda'){
						if(retorno.ComandoDesc == 'Adicionar')
							rs.conclusao_sap.lista.add(retorno.Id);
						else if(retorno.ComandoDesc == 'Atualizar' || retorno.ComandoDesc ==  'Cancelar' || retorno.ComandoDesc ==  'Fechar'){
							rs.conclusao_sap.lista.add(retorno.Id);
							if(rs.parametro_obj.contains('pedido'))
								rs.pedidos_cod.add(retorno.CodigoAuxiliar);
						}
					}
				}

				if(rs.pedidos_cod.size()>0){
				
					rs.logs.add('códigos dos pedidos: ' + JSON.serialize(rs.pedidos_cod));

					HttpRequest requisicao = new HttpRequest();
					requisicao.setMethod('POST');
					requisicao.setEndPoint(rs.url_sap+'/integrationone/api/Documentos/Lista');
					requisicao.setHeader('Content-Type','application/json');
					ObjetoSAP.Requisicao requisicao_pedidos_sap = new ObjetoSAP.Requisicao();
					requisicao_pedidos_sap.token = rs.token_sap;
					requisicao_pedidos_sap.BaseSAP = rs.base_sap;
					requisicao_pedidos_sap.lista = new List<String>(rs.pedidos_cod);
					requisicao.setBody(JSON.serialize(requisicao_pedidos_sap, true));
					rs.logs.add('listar pedidos sap (requisicao): ' + requisicao+requisicao.getBody());
					Http protocolo = new Http();
					if(!Test.isRunningTest()){
						HttpResponse resposta = protocolo.send(requisicao);
						rs.logs.add('listar pedidos sap (resposta): ' + resposta+resposta.getBody());
						rs.pedidos_sap = (List<ObjetoSAP.Documento>) JSON.deserialize(resposta.getBody(), List<ObjetoSAP.Documento>.class);
					}
					
				}
			}
			else if(acao=='salvar'){
				if(rs.pedidos_cod.size()>0){
				
					List<Order> pedidos_sf_atu = [
						SELECT 	Id, OrderNumber, Observacoes_Gerais__c, AccountId, Account.CNPJ__c, Account.CPF__pc, Vendedor__c, Pricebook2Id, 
								Vendedor__r.CommunityNickname, EffectiveDate, Status, Forma_de_pagamento2__c, Condicao_de_pagamento__c,
								Frete__c, Entrega_parcial__c, Prazo_de_entrega__c, Faturamento_Feito__c, Faturamento_Feito__r.CNPJ__c,
								BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, ShippingStreet, ShippingCity,
								ShippingState, ShippingPostalCode, ShippingCountry, CurrencyIsoCode, (
									SELECT	Id, OrderItemNumber, Numero_do_Item_SAP__c, Product2.ProductCode, Status__c, Description, 
											UnitPrice, Quantity, CurrencyIsoCode
									FROM	Orderitems
								)
						FROM	Order
						WHERE 	OrderNumber IN :rs.pedidos_cod
					];
					rs.logs.add('listar pedidos sales: ' + JSON.serialize(pedidos_sf_atu));
					List<OrderItem> linhas_sf_atu = new List<OrderItem>();
					List<OrderItem> linhas_sf_ins = new List<OrderItem>();
					List<OrderItem> linhas_sf_del = new List<OrderItem>();
					List<Entrega_de_item__c> entregas_sf_del = [
						SELECT	Id
						FROM	Entrega_de_item__c
						WHERE	Item_de_pedido_de_venda__r.Order.OrderNumber IN :rs.pedidos_cod
					];
					List<Requisicao_de_item__c> requisicoes_sf_del = [
						SELECT	Id
						FROM	Requisicao_de_item__c
						WHERE	Item_de_pedido_de_venda__r.Order.OrderNumber IN :rs.pedidos_cod
					];

					Set<String> contas_cod_aux = new Set<String>();
					Set<String> usuarios_cod_aux = new Set<String>();
					Set<String> produtos_cod_aux = new Set<String>();
					for(ObjetoSAP.Documento pedido_sap : rs.pedidos_sap){
						contas_cod_aux.add(pedido_sap.ParceiroNegocio.Cnpj!=null ? pedido_sap.ParceiroNegocio.Cnpj : pedido_sap.ParceiroNegocio.Cpf);
						contas_cod_aux.add(pedido_sap.CnpjFilial);
						usuarios_cod_aux.add(pedido_sap.VendedorNome);
						for(ObjetoSAP.Linha linha_sap : pedido_sap.Linhas)
							produtos_cod_aux.add(linha_sap.CodigoItem);
					}
					List<Account> contas = [
						SELECT 	Id, CNPJ__c, CPF__pc
						FROM	Account
						WHERE 	CNPJ__c IN :contas_cod_aux OR
								CPF__pc IN :contas_cod_aux
					];
					List<User> usuarios = [
						SELECT	Id, CommunityNickname
						FROM	User
						WHERE	CommunityNickname IN :usuarios_cod_aux
					];
					List<PricebookEntry> entradas = [
						SELECT	Id, Pricebook2Id, CurrencyIsoCode, ProductCode
						FROM	PricebookEntry
						WHERE	ProductCode IN :produtos_cod_aux
					];
					
					List<String> formas_pgto = new List<String>();
					List<String> condicoes_pgto = new List<String>();
					List<String> tipos_frete = new List<String>();
					List<String> status_linha = new List<String>();
					for(Schema.PicklistEntry forma_pgto : Order.Forma_de_pagamento2__c.getDescribe().getPicklistValues())
						formas_pgto.add(forma_pgto.getLabel());
					for(Schema.PicklistEntry condicao_pgto : Order.Condicao_de_pagamento__c.getDescribe().getPicklistValues())
						condicoes_pgto.add(condicao_pgto.getLabel());
					for(Schema.PicklistEntry tipo_frete : Order.Frete__c.getDescribe().getPicklistValues())
						tipos_frete.add(tipo_frete.getLabel());
					for(Schema.PicklistEntry status_linha_temp : OrderItem.Status__c.getDescribe().getPicklistValues())
						status_linha.add(status_linha_temp.getLabel());

					for(Order pedido_sf_atu : pedidos_sf_atu){
						for(ObjetoSAP.Documento pedido_sap : rs.pedidos_sap){
							if(pedido_sf_atu.OrderNumber == pedido_sap.CodigoIntegracao){
								pedido_sf_atu.Observacoes_Gerais__c = pedido_sap.Observacoes;
								for(Account conta : contas)
									if(conta.CNPJ__c == pedido_sap.ParceiroNegocio.Cnpj || conta.CPF__pc == pedido_sap.ParceiroNegocio.Cpf)
										pedido_sf_atu.AccountId = conta.Id;
								for(User usuario : usuarios)
									if(usuario.CommunityNickname == pedido_sap.VendedorNome)
										pedido_sf_atu.Vendedor__c = usuario.Id;
								pedido_sf_atu.EffectiveDate = date.valueof(pedido_sap.DataLancamento);
								if(formas_pgto.contains(pedido_sap.FormaPagto))
									pedido_sf_atu.Forma_de_pagamento2__c = pedido_sap.FormaPagto;
								if(condicoes_pgto.contains(pedido_sap.CondicaoPagto))
									pedido_sf_atu.Condicao_de_pagamento__c = pedido_sap.CondicaoPagto;
								String frete = '';
								if(pedido_sap.Incoterms == 0) frete = 'Contratação do Frete por conta do Remetente (CIF)';
								if(pedido_sap.Incoterms == 1) frete = 'Contratação do Frete por conta do Destinatário (FOB)';
								if(pedido_sap.Incoterms == 2) frete = 'Contratação do Frete por conta de Terceiros';
								if(pedido_sap.Incoterms == 3) frete = 'Transporte Próprio por conta do Remetente';
								if(pedido_sap.Incoterms == 4) frete = 'Transporte Próprio por conta do Destinatário';
								if(pedido_sap.Incoterms == 9) frete = 'Sem Ocorrência de Transporte.';
								if(!tipos_frete.contains(frete))
									pedido_sf_atu.Frete__c = frete;
								pedido_sf_atu.Entrega_parcial__c = (pedido_sap.EntregaParcial ? 'Autorizada' : 'Não Autorizada' );
								pedido_sf_atu.Prazo_de_entrega__c = date.valueof(pedido_sap.DataVencimento);
								for(Account conta : contas)
									if(conta.CNPJ__c == pedido_sap.CnpjFilial)
										pedido_sf_atu.Faturamento_Feito__c = conta.Id;
								if(pedido_sap.ParceiroNegocio.Enderecos != null){
									for(ObjetoSAP.Endereco endereco : pedido_sap.ParceiroNegocio.Enderecos)
										if(endereco.TipoEndereco == 'Cobrança'){
											pedido_sf_atu.BillingStreet = '';
											if(endereco.Logradouro!=null && endereco.Logradouro!='')
												pedido_sf_atu.BillingStreet += (pedido_sf_atu.BillingStreet!='' ? ', ' : '') + endereco.Logradouro;
											if(endereco.Numero!=null && endereco.Numero!='')
												pedido_sf_atu.BillingStreet += (pedido_sf_atu.BillingStreet!='' ? ', ' : '') + endereco.Numero;
											if(endereco.Complemento!=null && endereco.Complemento!='')
												pedido_sf_atu.BillingStreet += (pedido_sf_atu.BillingStreet!='' ? ', ' : '') + endereco.Complemento;
											if(endereco.Bairro!=null && endereco.Bairro!='')
												pedido_sf_atu.BillingStreet += (pedido_sf_atu.BillingStreet!='' ? ', ' : '') + endereco.Bairro;
											pedido_sf_atu.BillingCity = endereco.Cidade;
											pedido_sf_atu.BillingState = Util.ConverterEstado(endereco.Uf,'nome');
											pedido_sf_atu.BillingPostalCode = endereco.Cep;
											pedido_sf_atu.BillingCountry = (endereco.Pais=='BR' ? 'Brasil' : null);
											break;
										}
									for(ObjetoSAP.Endereco endereco : pedido_sap.ParceiroNegocio.Enderecos)
										if(endereco.TipoEndereco == 'Entrega'){
											pedido_sf_atu.ShippingStreet = '';
											if(endereco.Logradouro!=null && endereco.Logradouro!='')
												pedido_sf_atu.ShippingStreet += (pedido_sf_atu.ShippingStreet!='' ? ', ' : '') + endereco.Logradouro;
											if(endereco.Numero!=null && endereco.Numero!='')
												pedido_sf_atu.ShippingStreet += (pedido_sf_atu.ShippingStreet!='' ? ', ' : '') + endereco.Numero;
											if(endereco.Complemento!=null && endereco.Complemento!='')
												pedido_sf_atu.ShippingStreet += (pedido_sf_atu.ShippingStreet!='' ? ', ' : '') + endereco.Complemento;
											if(endereco.Bairro!=null && endereco.Bairro!='')
												pedido_sf_atu.ShippingStreet += (pedido_sf_atu.ShippingStreet!='' ? ', ' : '') + endereco.Bairro;
											pedido_sf_atu.ShippingCity = endereco.Cidade;
											pedido_sf_atu.ShippingState = Util.ConverterEstado(endereco.Uf,'nome');
											pedido_sf_atu.ShippingPostalCode = endereco.Cep;
											pedido_sf_atu.ShippingCountry = (endereco.Pais=='BR' ? 'Brasil' : null);
											break;
										}
								}
								for(ObjetoSAP.Linha linha_sap : pedido_sap.Linhas){
									Boolean existente = false;
									for(OrderItem linha_sf_atu : pedido_sf_atu.OrderItems){
										if((linha_sap.TextoLivre == linha_sf_atu.OrderItemNumber || String.valueOf(linha_sap.NumLinha) == linha_sf_atu.Numero_do_Item_SAP__c) &&
											linha_sap.CodigoItem == linha_sf_atu.Product2.ProductCode){
											existente = true;
											linha_sf_atu.Numero_do_Item_SAP__c = String.valueOf(linha_sap.NumLinha);
											if(status_linha.contains(linha_sap.StatusPedLinha))
												linha_sf_atu.Status__c = linha_sap.StatusPedLinha;
											linha_sf_atu.Description = linha_sap.InfEspecificas;
											linha_sf_atu.UnitPrice = linha_sap.Preco; 
											linha_sf_atu.Quantity = linha_sap.Quantidade;
											linhas_sf_atu.add(linha_sf_atu);
										}
									}
									if(!existente){
										OrderItem linha_sf_ins = new OrderItem();
										linha_sf_ins.OrderId = pedido_sf_atu.Id;
										linha_sf_ins.Numero_do_Item_SAP__c = String.valueOf(linha_sap.NumLinha);
										for(PricebookEntry entrada : entradas)
											if(entrada.Pricebook2Id == pedido_sf_atu.Pricebook2Id && entrada.CurrencyIsoCode == pedido_sf_atu.CurrencyIsoCode && 
											   entrada.ProductCode == linha_sap.CodigoItem)
												linha_sf_ins.PricebookEntryId = entrada.Id;
										if(status_linha.contains(linha_sap.StatusPedLinha))
											linha_sf_ins.Status__c = linha_sap.StatusPedLinha;
										linha_sf_ins.Description = linha_sap.InfEspecificas;
										linha_sf_ins.UnitPrice = linha_sap.Preco; 
										linha_sf_ins.Quantity = linha_sap.Quantidade;
										linhas_sf_ins.add(linha_sf_ins);
									}
								}
								for(OrderItem linha_sf_del : pedido_sf_atu.OrderItems){
									Boolean existente = false;
									for(ObjetoSAP.Linha linha_sap : pedido_sap.Linhas){
										if((linha_sap.TextoLivre == linha_sf_del.OrderItemNumber || String.valueOf(linha_sap.NumLinha) == linha_sf_del.Numero_do_Item_SAP__c) &&
											linha_sap.CodigoItem == linha_sf_del.Product2.ProductCode){
											existente = true;
										}
									}
									if(!existente)
										linhas_sf_del.add(linha_sf_del);
								}
							}
						}
					}
					
					if(entregas_sf_del.size()>0){
						rs.logs.add('deletar entregas sales: ' + JSON.serialize(entregas_sf_del));
						delete entregas_sf_del;
					}
					if(requisicoes_sf_del.size()>0){
						rs.logs.add('deletar requisições sales: ' + JSON.serialize(requisicoes_sf_del));
						delete requisicoes_sf_del;
					}
					if(pedidos_sf_atu.size()>0){
						rs.logs.add('atualizar pedidos sales: ' + JSON.serialize(pedidos_sf_atu));
						update pedidos_sf_atu;
					}
					if(linhas_sf_atu.size()>0){
						rs.logs.add('atualizar linhas sales: ' + JSON.serialize(linhas_sf_atu));
						update linhas_sf_atu;
					}
					if(linhas_sf_ins.size()>0){
						rs.logs.add('inserir linhas sales: ' + JSON.serialize(linhas_sf_ins));
						insert linhas_sf_ins;
					}
					if(linhas_sf_del.size()>0){
						rs.logs.add('deletar linhas sales: ' + JSON.serialize(linhas_sf_del));
						delete linhas_sf_del;
					}
					
				}
			}
		}

		public void ProcessarFaturamentos(String acao){
			if(acao=='buscar'){
				for(ObjetoSAP.Retorno retorno : rs.retornos_sap){
					if(retorno.ObjetoDesc == 'Nota Fiscal'){
						if(retorno.ComandoDesc == 'Adicionar' || retorno.ComandoDesc == 'Atualizar' || retorno.ComandoDesc ==  'Cancelar' || retorno.ComandoDesc == 'Fechar'){
							rs.conclusao_sap.lista.add(retorno.Id);
							if(retorno.CodigoAuxiliar!=null){
								if(retorno.CodigoAuxiliar.length()==8){
									if(rs.parametro_obj.contains('faturamento'))
										rs.notas_pvs_cod.add(retorno.CodigoAuxiliar);
								}									
							}
						}
					}
				}

				if(rs.notas_pvs_cod.size()>0){
					rs.logs.add('códigos das notas/pvs: ' + JSON.serialize(rs.notas_pvs_cod));

					HttpRequest requisicao = new HttpRequest();
					requisicao.setMethod('POST');
					requisicao.setEndPoint(rs.url_sap+'/integrationone/api/Documentos/Lista');
					requisicao.setHeader('Content-Type','application/json');
					ObjetoSAP.Requisicao requisicao_pedidos_sap = new ObjetoSAP.Requisicao();
					requisicao_pedidos_sap.token = rs.token_sap;
					requisicao_pedidos_sap.BaseSAP = rs.base_sap;
					requisicao_pedidos_sap.lista = new List<String>(rs.notas_pvs_cod);
					requisicao.setBody(JSON.serialize(requisicao_pedidos_sap, true));
					rs.logs.add('listar notas/pvs sap (requisicao): ' + requisicao+requisicao.getBody());
					Http protocolo = new Http();
					if(!Test.isRunningTest()){
						HttpResponse resposta = protocolo.send(requisicao);
						rs.logs.add('listar notas/pvs sap (resposta): ' + resposta+resposta.getBody());
						rs.notas_pvs_sap = (List<ObjetoSAP.Documento>) JSON.deserialize(resposta.getBody(), List<ObjetoSAP.Documento>.class);
					}
				}
			}
			else if(acao=='salvar'){
				if(rs.notas_pvs_cod.size()>0){
					List<Order> notas_pvs_sf = [
						SELECT 	Id, OrderNumber, AccountId, OwnerId, Departamento3__c, (
									SELECT	Id, Tipo__c, Status__c, RecordTypeId, Name, Data__c, Valor_Faturado__c, 
												Faturamento_Feito2__c, Chave_de_acesso__c, Numero_do_Documento_SAP__c, 
												OwnerId, Departamento3__c
									FROM	Faturamentos__r
								)
						FROM	Order
						WHERE 	OrderNumber IN :rs.notas_pvs_cod
					];
					rs.logs.add('listar notas/pvs sales: ' + JSON.serialize(notas_pvs_sf));
					List<Faturamento__c> notas_sf_atu = new List<Faturamento__c>();
					List<Faturamento__c> notas_sf_ins = new List<Faturamento__c>();
					List<Faturamento__c> notas_sf_del = new List<Faturamento__c>();

					Set<String> contas_cod_aux = new Set<String>();
					for(ObjetoSAP.Documento nota_pv_sap : rs.notas_pvs_sap){
						if(nota_pv_sap.Faturamento!=null)
							for(ObjetoSAP.Faturamento nota_sap : nota_pv_sap.Faturamento)
								contas_cod_aux.add(nota_sap.CnpjFilial);
					}
					List<Account> contas = [
						SELECT 	Id, CNPJ__c
						FROM	Account
						WHERE 	CNPJ__c IN :contas_cod_aux
					];
					
					Id nota_produto_id=null, nota_servico_id=null;
					for(RecordType tipo_registro : [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Faturamento__c']){
						if(tipo_registro.Name == 'Vendas (Hospcom)')
							nota_produto_id = tipo_registro.Id;
						else if(tipo_registro.Name == 'Serviços (Mão de Obra)')
							nota_servico_id = tipo_registro.Id;
					}
					
					List<String> tipos_nf = new List<String>();
					for(Schema.PicklistEntry tipo_nf : Faturamento__c.Tipo__c.getDescribe().getPicklistValues())
						tipos_nf.add(tipo_nf.getLabel());
					
					for(Order nota_pv_sf : notas_pvs_sf){
						for(ObjetoSAP.Documento nota_pv_sap : rs.notas_pvs_sap){
							if(nota_pv_sf.OrderNumber == nota_pv_sap.CodigoIntegracao && nota_pv_sap.Faturamento!=null){
								
								Set<String> notas_doc_num = new Set<String>();
								for(ObjetoSAP.Faturamento nota_sap : nota_pv_sap.Faturamento){
									if(!notas_doc_num.contains(String.valueOf(nota_sap.DocEntry))){
										notas_doc_num.add(String.valueOf(nota_sap.DocEntry));
										Boolean existente = false;
										for(Faturamento__c nota_sf_atu : nota_pv_sf.Faturamentos__r){
											if((nota_sap.NumNF == nota_sf_atu.Name || nota_sap.NumNFSe == nota_sf_atu.Name) && 
												String.valueOf(nota_sap.DocEntry) == nota_sf_atu.Numero_do_Documento_SAP__c
											){
												existente = true;
												Map<String, Object> nota_old = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(nota_sf_atu));
												nota_sf_atu.OwnerId = nota_pv_sf.OwnerId;
												nota_sf_atu.Departamento3__c = nota_pv_sf.Departamento3__c;
												nota_sf_atu.RecordTypeId = (nota_sap.Modelo=='NFS-e' ? nota_servico_id : nota_produto_id);
												nota_sf_atu.Name = (nota_sap.Modelo=='NFS-e' ? nota_sap.NumNFSe : nota_sap.NumNF);
												nota_sf_atu.Chave_de_acesso__c = nota_sap.ChaveAcesso;
												if(tipos_nf.contains(nota_sap.Tipo))
													nota_sf_atu.Tipo__c = nota_sap.Tipo;
												nota_sf_atu.Status__c = (nota_sap.Cancelado==true ? 'Cancelado' : (nota_sap.Status=='C' ? 'Fechado' : 'Aberto'));
												nota_sf_atu.Data__c = DateTime.newInstance(
													Integer.valueOf(nota_sap.Data.substring(0, 4)), 
													Integer.valueOf(nota_sap.Data.substring(5, 7)), 
													Integer.valueOf(nota_sap.Data.substring(8, 10)),
													Integer.valueOf(nota_sap.Data.substring(11, 13)), 
													Integer.valueOf(nota_sap.Data.substring(14, 16)), 
													Integer.valueOf(nota_sap.Data.substring(17, 19))
												);
												for(Account conta : contas)
													if(conta.CNPJ__c == nota_sap.CnpjFilial)
														nota_sf_atu.Faturamento_Feito2__c = conta.Id;
												nota_sf_atu.Valor_Faturado__c = nota_sap.ValorNFe;
												Map<String, Object> nota_new = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(nota_sf_atu));
												if(nota_old != nota_new)
													notas_sf_atu.add(nota_sf_atu);
											}
										}
										if(!existente){
											Faturamento__c nota_sf_ins = new Faturamento__c();
											nota_sf_ins.Pedido__c = nota_pv_sf.Id;
											nota_sf_ins.OwnerId = nota_pv_sf.OwnerId;
											nota_sf_ins.Departamento3__c = nota_pv_sf.Departamento3__c;
											nota_sf_ins.RecordTypeId = (nota_sap.Modelo=='NFS-e' ? nota_servico_id : nota_produto_id);
											nota_sf_ins.Name = (nota_sap.Modelo=='NFS-e' ? nota_sap.NumNFSe : nota_sap.NumNF);
											nota_sf_ins.Numero_do_Documento_SAP__c = String.valueOf(nota_sap.DocEntry);
											nota_sf_ins.Chave_de_acesso__c = nota_sap.ChaveAcesso;
											if(tipos_nf.contains(nota_sap.Tipo))
												nota_sf_ins.Tipo__c = nota_sap.Tipo;
											nota_sf_ins.Status__c = (nota_sap.Cancelado==true ? 'Cancelado' : (nota_sap.Status=='C' ? 'Fechado' : 'Aberto'));
											nota_sf_ins.Data__c = DateTime.newInstance(
												Integer.valueOf(nota_sap.Data.substring(0, 4)), 
												Integer.valueOf(nota_sap.Data.substring(5, 7)), 
												Integer.valueOf(nota_sap.Data.substring(8, 10)),
												Integer.valueOf(nota_sap.Data.substring(11, 13)), 
												Integer.valueOf(nota_sap.Data.substring(14, 16)), 
												Integer.valueOf(nota_sap.Data.substring(17, 19))
											);
											nota_sf_ins.Nome_da_Conta2__c = nota_pv_sf.AccountId;
											for(Account conta : contas)
												if(conta.CNPJ__c == nota_sap.CnpjFilial)
													nota_sf_ins.Faturamento_Feito2__c = conta.Id;
											nota_sf_ins.Valor_Faturado__c = nota_sap.ValorNFe;
											notas_sf_ins.add(nota_sf_ins);
										}
									}
								}
								for(Faturamento__c nota_sf_del : nota_pv_sf.Faturamentos__r){
									Boolean existente = false;
									for(ObjetoSAP.Faturamento nota_sap : nota_pv_sap.Faturamento){
										if((nota_sap.NumNF == nota_sf_del.Name || nota_sap.NumNFSe == nota_sf_del.Name) && 
										    String.valueOf(nota_sap.DocEntry) == nota_sf_del.Numero_do_Documento_SAP__c
										){
											existente = true;
										}
									}
									if(!existente)
										notas_sf_del.add(nota_sf_del);
								}
							}
						}
					}
					
					if(notas_sf_atu.size()>0){
						rs.logs.add('atualizar notas sales: ' + JSON.serialize(notas_sf_atu));
						update notas_sf_atu;
					}
					if(notas_sf_ins.size()>0){
						rs.logs.add('inserir notas sales: ' + JSON.serialize(notas_sf_ins));
						insert notas_sf_ins;
					}
					if(notas_sf_del.size()>0){
						rs.logs.add('deletar notas sales: ' + JSON.serialize(notas_sf_del));
						delete notas_sf_del;
					}
					
					notas_pvs_sf = [
						SELECT 	Id, OrderNumber, (
									SELECT	Id, Name, Numero_do_Documento_SAP__c
									FROM	Faturamentos__r
								)
						FROM	Order
						WHERE 	OrderNumber IN :rs.notas_pvs_cod
					];
					
					List<Faturamento__c> notas_sf_vinc = new List<Faturamento__c>();
					for(Order nota_pv_sf : notas_pvs_sf){
						for(ObjetoSAP.Documento nota_pv_sap : rs.notas_pvs_sap){
							if(nota_pv_sf.OrderNumber == nota_pv_sap.CodigoIntegracao){
								
								if(nota_pv_sap.Faturamento!=null){
									for(ObjetoSAP.Faturamento nota_sap : nota_pv_sap.Faturamento){
										if(nota_sap.TipoDocBase == 13 && nota_sap.DocEntryBase!=null){
											for(Faturamento__c nota_sf_vinc : nota_pv_sf.Faturamentos__r){
												if((nota_sap.NumNF == nota_sf_vinc.Name || nota_sap.NumNFSe == nota_sf_vinc.Name) && 
													String.valueOf(nota_sap.DocEntry) == nota_sf_vinc.Numero_do_Documento_SAP__c
												){
													for(Faturamento__c nota_sf_pai : nota_pv_sf.Faturamentos__r)
														if(String.valueOf(nota_sap.DocEntryBase) == nota_sf_pai.Numero_do_Documento_SAP__c){
															nota_sf_vinc.Faturamento_pai__c = nota_sf_pai.Id;
															notas_sf_vinc.add(nota_sf_vinc);
														}
												}
											}
										}
									}
								}
								
							}
						}
					}
					
					if(notas_sf_vinc.size()>0){
						rs.logs.add('atualizar vínculos notas sales: ' + JSON.serialize(notas_sf_vinc));
						update notas_sf_vinc;
					}					
				}
			}
		}
		
		public void ProcessarAnexos(String acao){
			if(acao=='buscar'){
				if(rs.parametro_obj.contains('anexo'))
					if(rs.notas_pvs_sap!=null)
						for(ObjetoSAP.Documento nota_pv_sap : rs.notas_pvs_sap)
							if(nota_pv_sap.Faturamento!=null){
								for(ObjetoSAP.Faturamento nota_sap : nota_pv_sap.Faturamento){
									if(nota_sap.ChaveAcesso!=null && nota_sap.ChaveAcesso!='')
										rs.anexos_cod.add(nota_sap.ChaveAcesso);
									if(nota_sap.LinkNFSe!=null && nota_sap.LinkNFSe!='')
										rs.notas_cod.add(nota_sap.LinkNFSe);
								}
							}
				
				if(rs.anexos_cod.size()>0){
					rs.logs.add('códigos dos anexos: ' + JSON.serialize(rs.anexos_cod));

					HttpRequest requisicao = new HttpRequest();
					requisicao.setMethod('POST');
					requisicao.setEndPoint(rs.url_sap+'/integrationone/api/Arquivo/PDF');
					requisicao.setHeader('Content-Type','application/json');
					ObjetoSAP.Requisicao requisicao_pedidos_sap = new ObjetoSAP.Requisicao();
					requisicao_pedidos_sap.token = rs.token_sap;
					requisicao_pedidos_sap.BaseSAP = rs.base_sap;
					requisicao_pedidos_sap.lista = new List<String>(rs.anexos_cod);
					requisicao.setBody(JSON.serialize(requisicao_pedidos_sap, true));
					rs.logs.add('listar anexos sap (requisicao): ' + requisicao+requisicao.getBody());
					Http protocolo = new Http();
					if(!Test.isRunningTest()){
						HttpResponse resposta = protocolo.send(requisicao);
						rs.logs.add('listar anexos sap (resposta): ' + resposta + ' -- conteúdo omitido -- '); // + resposta.getBody()
						rs.anexos_sap = (List<ObjetoSAP.Anexo>) JSON.deserialize(resposta.getBody(), List<ObjetoSAP.Anexo>.class);
					}
				}
			}
			else if(acao=='salvar'){
				if(rs.anexos_cod.size()>0 || rs.notas_cod.size()>0){
					List<Faturamento__c> anexos_notas_sf = [
						SELECT 	Id, Name, Pedido__r.OrderNumber, Numero_do_Documento_SAP__c, (
									SELECT	Id, ContentDocument.Description
									FROM   	ContentDocumentLinks
								), (
									SELECT	Id, Title, Body
									FROM   	Notes
								)
						FROM 	Faturamento__c
						WHERE 	Pedido__r.OrderNumber IN :rs.notas_pvs_cod
					];
					rs.logs.add('listar anexos/notas sales: ' + JSON.serialize(anexos_notas_sf));
					List<ContentVersion> versoes_sf_ins = new List<ContentVersion>();
					List<Note> notas_sf_ins = new List<Note>();
					Set<String> anexos_cod_ins = new Set<String>();
					
					for(ObjetoSAP.Documento notas_pedido_sap : rs.notas_pvs_sap){
						if(notas_pedido_sap.Faturamento!=null){
							for(ObjetoSAP.Faturamento nota_sap : notas_pedido_sap.Faturamento){
								if(nota_sap.ChaveAcesso!=null && nota_sap.ChaveAcesso!='' && !anexos_cod_ins.contains(nota_sap.ChaveAcesso)){
									for(Faturamento__c anexos_nota_sf : anexos_notas_sf){
										if(anexos_nota_sf.Pedido__r.OrderNumber == notas_pedido_sap.CodigoIntegracao && 
										   anexos_nota_sf.Numero_do_Documento_SAP__c == String.valueOf(nota_sap.DocEntry)){
											Set<String> chaves_sf = new Set<String>();
											for(ContentDocumentLink link_sf : anexos_nota_sf.ContentDocumentLinks)
												if(link_sf.ContentDocument.Description!=null && link_sf.ContentDocument.Description!='')
													chaves_sf.add(link_sf.ContentDocument.Description);
											if(!chaves_sf.contains(nota_sap.ChaveAcesso)){
												anexos_cod_ins.add(nota_sap.ChaveAcesso);
												for(ObjetoSAP.Anexo anexo_sap : rs.anexos_sap){
													if(anexo_sap.ChaveAcesso == nota_sap.ChaveAcesso && anexo_sap.Base64!=null && 
													   anexo_sap.Base64!='' && !anexo_sap.Base64.startsWith('Arquivo [')){
														versoes_sf_ins.add(new ContentVersion(
															PathOnClient = 'NF-e - ' + anexos_nota_sf.Name + '.pdf',
															ContentLocation = 'S',
															Title = 'NF-e - ' + anexos_nota_sf.Name,
															Description = anexo_sap.ChaveAcesso,
															VersionData = EncodingUtil.base64Decode(anexo_sap.Base64)
														));
													}
												}
											}
										}
									}
								}
								if(nota_sap.LinkNFSe!=null && nota_sap.LinkNFSe!='' && !anexos_cod_ins.contains(nota_sap.LinkNFSe)){
									for(Faturamento__c anexos_nota_sf : anexos_notas_sf){
										if(anexos_nota_sf.Pedido__r.OrderNumber == notas_pedido_sap.CodigoIntegracao && 
										   anexos_nota_sf.Numero_do_Documento_SAP__c == String.valueOf(nota_sap.DocEntry)){
											Set<String> chaves_sf = new Set<String>();
											for(Note anexo_sf : anexos_nota_sf.Notes)
												if(anexo_sf.Body!=null && anexo_sf.Body!='')
													chaves_sf.add(anexo_sf.Body);
											if(!chaves_sf.contains(nota_sap.LinkNFSe)){
												anexos_cod_ins.add(nota_sap.LinkNFSe);
												notas_sf_ins.add(new Note(
													ParentId = anexos_nota_sf.Id,
													Title = 'NFs-e - ' + anexos_nota_sf.Name,
													Body = nota_sap.LinkNFSe
												));
											}
										}
									}
								}
							}
						}
					}
					
					if(versoes_sf_ins.size()>0){
						rs.logs.add('inserir versões sales: ' + ' -- conteúdo omitido -- '); // JSON.serialize(versoes_sf_ins)
						insert versoes_sf_ins;
						
						List<ContentDocumentLink> links_sf_ins = new List<ContentDocumentLink>();
						List<Id> versoes_sf_id = new List<Id>();
						for(ContentVersion versao_sf_ins : versoes_sf_ins)
							versoes_sf_id.add(versao_sf_ins.Id);
						versoes_sf_ins = [
							SELECT 	Id, ContentDocumentId, Description
							FROM	ContentVersion
							WHERE	Id IN :versoes_sf_id
						];
						
						for(ContentVersion versao_sf_ins : versoes_sf_ins){
							for(ObjetoSAP.Documento notas_pedido_sap : rs.notas_pvs_sap){
								if(notas_pedido_sap.Faturamento!=null){
									anexos_cod_ins = new Set<String>();
									for(ObjetoSAP.Faturamento nota_sap : notas_pedido_sap.Faturamento){
										if(!anexos_cod_ins.contains(nota_sap.ChaveAcesso)){
											anexos_cod_ins.add(nota_sap.ChaveAcesso);
											if(nota_sap.ChaveAcesso == versao_sf_ins.Description){
												for(Faturamento__c anexos_nota_sf : anexos_notas_sf){
													if(anexos_nota_sf.Pedido__r.OrderNumber == notas_pedido_sap.CodigoIntegracao && 
													   anexos_nota_sf.Numero_do_Documento_SAP__c == String.valueOf(nota_sap.DocEntry)){
														links_sf_ins.add(new ContentDocumentLink(
															ContentDocumentId = versao_sf_ins.ContentDocumentId,
															LinkedEntityId = anexos_nota_sf.Id,
															ShareType = 'I',
															Visibility = 'AllUsers'
														));
													}
												}
											}
										}
									}
								}
							}
						}

						if(links_sf_ins.size()>0){
							rs.logs.add('inserir links sales: ' + JSON.serialize(links_sf_ins));
							insert links_sf_ins;
						}
					}
					if(notas_sf_ins.size()>0){
						rs.logs.add('inserir notas sales: ' + JSON.serialize(notas_sf_ins));
						insert notas_sf_ins;
					}
					
				}
			}
		}
		
	}

	public class Conclusao implements Queueable, Database.AllowsCallouts {
		public RecebeSAP rs;

		public Conclusao(RecebeSAP recebe_sap){
			rs = recebe_sap;
		}

		public void execute(QueueableContext context) {
			if(!rs.tem_erro){
				try{
					Util.AcaoInterna(true);
					ConcluirPendencias();
				}
				catch(Exception error) {
					rs.tem_erro = true;
					rs.logs.add('-- erro --');	
					rs.logs.add('tipo: ' + error.getTypeName());	
					rs.logs.add('mensagem: ' + error.getMessage());   
					rs.logs.add('causa: ' + error.getCause());
					rs.logs.add('linha: ' + error.getLineNumber());   
					rs.logs.add('rastreio: ' + error.getStackTraceString());   
				}
			}
			
			try{
				SalvarLog(rs.tem_erro ? 'ERRO' : 'OK');
				ExcluirLogs();				
			}
			catch(Exception error) {}

			Util.AcaoInterna(false);
		}

		public void ConcluirPendencias (){
			if(rs.conclusao_sap.lista.size()>0){
				HttpRequest requisicao = new HttpRequest();
				requisicao.setMethod('POST');
				requisicao.setEndPoint(rs.url_sap+'/integrationone/api/Pendentes/Lista');
				requisicao.setHeader('Content-Type','application/json');
				requisicao.setBody(JSON.serialize(rs.conclusao_sap, true));
				rs.logs.add('concluir listagem retorno sap (requisicao): ' + requisicao+requisicao.getBody());
				Http protocolo = new Http();
				if(!Test.isRunningTest()){
					HttpResponse resposta = protocolo.send(requisicao);
					rs.logs.add('concluir listagem retorno sap (resposta): ' + resposta+resposta.getBody());
				}
			}
		}

		public void SalvarLog(String obs){
			if(rs.pasta_log.size()==1 && rs.conclusao_sap.lista.size()>0){
				for(Integer cont=0; cont<rs.logs.size(); cont++)
					rs.logs[cont] = rs.logs[cont].replace('\r\n', ' ').replace('\n', ' ').replace('\r', ' ').replace('\\x0D', ' ');
				Document log_retorno = new Document(
					Name = String.valueOf(System.Now().format('yyyy/MM/dd hh:mm:ss')) + ' - Recebe' + ' - ' + obs,
					Body = Blob.valueOf(String.join(rs.logs, '\n')),
					ContentType = 'text/plain',
					Type = 'txt',
					IsPublic = false,
					IsInternalUseOnly = true,
					FolderId = rs.pasta_log[0].Id
				);
				insert log_retorno;
			}
		}

		public void ExcluirLogs(){
			if(rs.pasta_log.size()==1){
				List<Document> logs_retorno = [
					SELECT	Id
					FROM	Document
					WHERE	FolderId = :rs.pasta_log[0].Id AND
							CreatedDate < :System.Now().addDays(-365)
				];
				delete logs_retorno;
			}
		}

	}

}