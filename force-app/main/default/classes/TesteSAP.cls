@isTest(seeAllData=true)
private class TesteSAP {
	
    @isTest
    static void TesteEnvio(){
		ApexPages.StandardController controller = new ApexPages.StandardController([SELECT Id FROM Order WHERE Id = '8016e00000803mx']);
		EnviaSAP envio = new EnviaSAP(controller);
	

		envio.conta_sap_resp_reg = (ContaJSON2ApexSAP.RespRegistro)JSON.deserialize('{"CodigoSap":"C000045","CodigoIntegracao":"","RazaoSocial":"INSTITUTO DE GESTAO E HUMANIZACAO IGH-HUAPA","Fantasia":"HUAPA","FornecedorCliente":"C","CodigoGrupo":102,"DescricaoGrupo":"Hospitais e Clínicas","Vendedor":-1,"VendedorNome":"-Nenhum vendedor-","CondicaoPagamento":0,"Territorio":0,"Cnpj":"11.858.570/0004-86","Cpf":"","InscricaoEstadual":"","InscricaoMunicipal":"","Telefone":"39562998","Telefone2":"62","Fax":null,"Celular":"71-32770854","Site":"renata.guedes@igh.com.br","Comentario":"","TextoLivre":null,"Email":"neocare.engclin@gmail.com","SetorCodigo":0,"SetorNome":null,"Valid":true,"Enderecos":[{"TipoEndereco":"Cobrança","NomeEndereco":"COBRANÇA","TipoLogradouro":"RUA","Logradouro":"RUA DONA NEQUITA C/ DAO BARBOSA","Rua":"DONA NEQUITA C/ DAO BARBOSA","Bairro":"JARDIM IPIRANGA","Cidade":"APARECIDA DE GOIANIA","Uf":"GO","Cep":"74.968-121","CodigoIbge":"5201405","Pais":"BR","Numero":"SN","Complemento":"QUADRA08 LOTE 18 E 19 C-10"},{"TipoEndereco":"Entrega","NomeEndereco":"DESTINATARIO","TipoLogradouro":"RUA","Logradouro":"RUA DONA NEQUITA C/ DAO BARBOSA","Rua":"DONA NEQUITA C/ DAO BARBOSA","Bairro":"JARDIM IPIRANGA","Cidade":"APARECIDA DE GOIANIA","Uf":"GO","Cep":"74.968-121","CodigoIbge":"5201405","Pais":"BR","Numero":"SN","Complemento":"QUADRA08 LOTE 18 E 19 C-10"},{"TipoEndereco":"Entrega","NomeEndereco":"DESTINATARIO II","TipoLogradouro":"AVENIDA","Logradouro":"AVENIDA DIAMANTE","Rua":"DIAMANTE","Bairro":"JARDIM CONDE DOS ARCOS","Cidade":"APARECIDA DE GOIANIA","Uf":"GO","Cep":"74.969-210","CodigoIbge":"5201405","Pais":"BR","Numero":"SN","Complemento":"ESQUINA C/ A RUA MUCURI"}],"Notifications":[],"Invalid":false}', ContaJSON2ApexSAP.RespRegistro.class);
		envio.vendedor_sap_resp_list = (ConsultaJSON2ApexSap.RespLista)JSON.deserialize('{"retorno":[{"CodigoSap":"13","Descricao":"Simone Mariano"}]}', ConsultaJSON2ApexSap.RespLista.class);
		envio.condpgto_sap_resp_list = (ConsultaJSON2ApexSap.RespLista)JSON.deserialize('{"retorno":[{"CodigoSap":"6","Descricao":"30 Dias"}]}', ConsultaJSON2ApexSap.RespLista.class);
		envio.formpgto_sap_resp_list = (ConsultaJSON2ApexSap.RespLista)JSON.deserialize('{"retorno":[{"CodigoSap":"Transf.Banc CR","Descricao":"Recebimento via Transferência Bancária"}]}', ConsultaJSON2ApexSap.RespLista.class);
		envio.filial_sap_resp_list = (ConsultaJSON2ApexSap.RespLista)JSON.deserialize('{"retorno":[{"CodigoSap":"1","Descricao":"05.743.288/0001-08"}]}', ConsultaJSON2ApexSap.RespLista.class);
		envio.prods_sap_resp_list = (ConsultaJSON2ApexSap.RespLista)JSON.deserialize('{"retorno":[{"CodigoSap":"177.00441","Descricao":"177.00441"},{"CodigoSap":"177.00405","Descricao":"177.00405"},{"CodigoSap":"177.00404","Descricao":"177.00404"},{"CodigoSap":"177.00403","Descricao":"177.00403"}]}', ConsultaJSON2ApexSap.RespLista.class);
		envio.prods_sap_resp_list_temp = (ConsultaJSON2ApexSap.RespLista)JSON.deserialize('{"retorno":[{"CodigoSap":"Y","Descricao":"177.00441"},{"CodigoSap":"Y","Descricao":"177.00405"},{"CodigoSap":"Y","Descricao":"177.00404"},{"CodigoSap":"Y","Descricao":"177.00403"}]}', ConsultaJSON2ApexSap.RespLista.class);

		envio.ValidarPedido();

		envio.ValidarPreenchimento();
		envio.ValidarContaSAP();
		envio.ValidarEnderecosSAP();
		envio.ValidarVendedorSAP();
		envio.ValidarCondPgtoSAP();
		envio.ValidarFormPgtoSAP();
		envio.ValidarFilialSAP();
		envio.ValidarItensCadastroSAP();
		envio.ValidarItensAtivoSAP();
		envio.AtivarPedido();
		envio.SalvarLog('OK');

		envio.tela.end_tipo='Cobrança';
		envio.tela.end_valor= 'COBRANÇA';
		envio.SetarEndereco();

		envio.tela.end_tipo='Entrega';
		envio.tela.end_valor= 'DESTINATARIO'; 
		envio.SetarEndereco();

	}	

	@isTest
	static void TesteEnvio2(){
		ApexPages.StandardController controller = new ApexPages.StandardController([SELECT Id FROM Order WHERE Id = '8016e00000803mx']);
		EnviaSAP envio = new EnviaSAP(controller);
	

		envio.conta_sap_resp_reg = (ContaJSON2ApexSAP.RespRegistro)JSON.deserialize('{"Retorno":0,"Mensagem":"Parceiro não encontrato pelo CPF/CNPJ [03480539000180]."}', ContaJSON2ApexSAP.RespRegistro.class);
		envio.vendedor_sap_resp_list = (ConsultaJSON2ApexSap.RespLista)JSON.deserialize('{"retorno":[{"CodigoSap":"","Descricao":"Simone Mariano"}]}', ConsultaJSON2ApexSap.RespLista.class);
		envio.condpgto_sap_resp_list = (ConsultaJSON2ApexSap.RespLista)JSON.deserialize('{"retorno":[{"CodigoSap":"","Descricao":"30 Dias"}]}', ConsultaJSON2ApexSap.RespLista.class);
		envio.formpgto_sap_resp_list = (ConsultaJSON2ApexSap.RespLista)JSON.deserialize('{"retorno":[{"CodigoSap":"","Descricao":"Recebimento via Transferência Bancária"}]}', ConsultaJSON2ApexSap.RespLista.class);
		envio.filial_sap_resp_list = (ConsultaJSON2ApexSap.RespLista)JSON.deserialize('{"retorno":[{"CodigoSap":"","Descricao":"05.743.288/0001-08"}]}', ConsultaJSON2ApexSap.RespLista.class);
		envio.prods_sap_resp_list = (ConsultaJSON2ApexSap.RespLista)JSON.deserialize('{"retorno":[{"CodigoSap":"","Descricao":"177.00441"},{"CodigoSap":"","Descricao":"177.00405"},{"CodigoSap":"","Descricao":"177.00404"},{"CodigoSap":"","Descricao":"177.00403"}]}', ConsultaJSON2ApexSap.RespLista.class);
		envio.prods_sap_resp_list_temp = (ConsultaJSON2ApexSap.RespLista)JSON.deserialize('{"retorno":[{"CodigoSap":"","Descricao":"177.00441"},{"CodigoSap":"","Descricao":"177.00405"},{"CodigoSap":"","Descricao":"177.00404"},{"CodigoSap":"","Descricao":"177.00403"}]}', ConsultaJSON2ApexSap.RespLista.class);

		envio.ValidarPedido();

		envio.ValidarPreenchimento();
		envio.ValidarContaSAP();
		envio.ValidarEnderecosSAP();
		envio.ValidarVendedorSAP();
		envio.ValidarCondPgtoSAP();
		envio.ValidarFormPgtoSAP();
		envio.ValidarFilialSAP();
		envio.ValidarItensCadastroSAP();
		envio.ValidarItensAtivoSAP();
		//envio.AtivarPedido();
		envio.SalvarLog('OK');

		envio.EnviarEmail();
		envio.VoltarAoPedido();

	}
    @isTest
	static void TesteEnvio3(){
		ApexPages.StandardController controller = new ApexPages.StandardController([SELECT Id FROM Order WHERE Id = '8016e0000075hnxAAA']);
		EnviaSAP envio = new EnviaSAP(controller);
	

		envio.conta_sap_resp_reg = (ContaJSON2ApexSAP.RespRegistro)JSON.deserialize('{"Retorno":0,"Mensagem":"Parceiro não encontrato pelo CPF/CNPJ [03480539000180]."}', ContaJSON2ApexSAP.RespRegistro.class);
		envio.vendedor_sap_resp_list = (ConsultaJSON2ApexSap.RespLista)JSON.deserialize('{"retorno":[{"CodigoSap":"","Descricao":"Simone Mariano"}]}', ConsultaJSON2ApexSap.RespLista.class);
		envio.condpgto_sap_resp_list = (ConsultaJSON2ApexSap.RespLista)JSON.deserialize('{"retorno":[{"CodigoSap":"","Descricao":"30 Dias"}]}', ConsultaJSON2ApexSap.RespLista.class);
		envio.formpgto_sap_resp_list = (ConsultaJSON2ApexSap.RespLista)JSON.deserialize('{"retorno":[{"CodigoSap":"","Descricao":"Recebimento via Transferência Bancária"}]}', ConsultaJSON2ApexSap.RespLista.class);
		envio.filial_sap_resp_list = (ConsultaJSON2ApexSap.RespLista)JSON.deserialize('{"retorno":[{"CodigoSap":"","Descricao":"05.743.288/0001-08"}]}', ConsultaJSON2ApexSap.RespLista.class);
		envio.prods_sap_resp_list = (ConsultaJSON2ApexSap.RespLista)JSON.deserialize('{"retorno":[{"CodigoSap":"","Descricao":"177.00441"},{"CodigoSap":"","Descricao":"177.00405"},{"CodigoSap":"","Descricao":"177.00404"},{"CodigoSap":"","Descricao":"177.00403"}]}', ConsultaJSON2ApexSap.RespLista.class);
		envio.prods_sap_resp_list_temp = (ConsultaJSON2ApexSap.RespLista)JSON.deserialize('{"retorno":[{"CodigoSap":"","Descricao":"177.00441"},{"CodigoSap":"","Descricao":"177.00405"},{"CodigoSap":"","Descricao":"177.00404"},{"CodigoSap":"","Descricao":"177.00403"}]}', ConsultaJSON2ApexSap.RespLista.class);

		envio.ValidarPedido();

		envio.ValidarPreenchimento();
		envio.ValidarContaSAP();
		envio.ValidarEnderecosSAP();
		envio.ValidarVendedorSAP();
		envio.ValidarCondPgtoSAP();
		envio.ValidarFormPgtoSAP();
		envio.ValidarFilialSAP();
		envio.ValidarItensCadastroSAP();
		envio.ValidarItensAtivoSAP();
		//envio.AtivarPedido();
		envio.SalvarLog('OK');

		envio.EnviarEmail();
		envio.VoltarAoPedido();

	}
}