({
	anosFiscais: ["2022", "2023", "2024"],
	tipos: ["Vendedor", "Estado", "Linha", "Departamento", "Geral"],

	anoSelecionado: '',
	tipoSelecionado: '',
	subTipoSelecionado: '',
	metaSelecionada: '',
	metaMesSelecionado: '',
	textSubTipoSelecionado: '',
	metaAnual: '',


	helperMethod: function (cmp, event, helper) {

		helper.preencheAnos(cmp, event, helper)
	},

	//FUNÇÃO QUE EXIBE O SPINNER DE CARREGAMENTO-
	showSpinner: function (cmp) {
		$('#spinnerDiv').css("display", "flex");
	},
	//-------------------------------------------

	//FUNÇÃO QUE OCULTA O SPINNER DE CARREGAMENTO-  
	hideSpinner: function (cmp) {
		$('#spinnerDiv').css("display", "none");
	},
	//--------------------------------------------

	preencheAnos: function (cmp, event, helper) {
		console.log("entrou preenche anos")

		$('#selectAnos').empty()
		$('#selectAnos').append("<option id='optionSelect' value='Ano Fiscal'>Ano Fiscal</option>")

		helper.anosFiscais.forEach(function (anoAtual) {
			$('#selectAnos').append("<option id='optionSelect' value='" + anoAtual + "'>" + anoAtual + "</option>")
		})

		$("#selectAnos").dropzie();

		$("#divSelectAnos").find(".dropzieOption").click(function () {
			helper.anoSelecionado = parseInt($(this).attr('data-value'))
			helper.preencheTipos(cmp, event, helper)
		})
	},

	preencheTipos: function (cmp, event, helper) {
		$('#divSelectTipos').empty()																	//LIMPA A DIV DO SELECT DE TIPOS
		$('#divSelectTipos').append("<select id='selectTipos' class='selectDataFin'></select>")			//ADICIONA À DIV DOS TIPOS O SELECT
		$("#divSelectTipos").css('display', 'flex');													//TORNA A DIV DO SELECT COM TIPOS VISÍVEL

		$('#selectTipos').append("<option id='optionSelect' value='Tipos'>Tipos</option>")				//ADICIONA UM PRIMEIRO OPTION AO SELECT

		$('#divSelectMetas').css('display', 'none');													//OCULTA O SELECT DE METAS
		$('#divSelectSubtipos').css('display', 'none');													//OCULTA O SELECT DE SUBTIPOS

		helper.tipos.forEach(function (tipoAtual) {
			$('#selectTipos').append("<option id='optionSelect' value='" + tipoAtual + "'>" + tipoAtual + "</option>")
		})

		$("#selectTipos").dropzie();

		$("#divSelectTipos").find(".dropzieOption").click(function () {
			helper.tipoSelecionado = $(this).attr('data-value')
			helper.preencheSubtipos(cmp, event, helper, this)
		})

	},

	preencheSubtipos: function (cmp, event, helper, item) {
		console.log("entrou subtipo")

		var tipoSelecionado = helper.tipoSelecionado
		var anoSelecionado = helper.anoSelecionado
		var anoLimite = anoSelecionado + 1
		var stringAnoSelecionado = anoSelecionado + '-01-01'
		var stringAnoLimite = anoLimite + '-12-31'

		if (tipoSelecionado == 'Vendedor') {
			var query = "SELECT Vendedor__r.Name, Name FROM Goal__c WHERE Inicio__c >=" + stringAnoSelecionado + " AND Inicio__c <= " + stringAnoLimite + " AND Vendedor__r.Name != null AND Estado__c = null AND Linha__c = null AND Departamento__c = null ORDER BY Vendedor__r.Name"
		} else if (tipoSelecionado == 'Estado') {
			var query = "SELECT Name, Estado__c FROM Goal__c WHERE Inicio__c >=" + stringAnoSelecionado + " AND Inicio__c <= " + stringAnoLimite + " AND Vendedor__C = null AND Estado__c != null AND Linha__c = null AND Departamento__c = null"
		} else if (tipoSelecionado == 'Linha') {
			var query = "SELECT Name, Linha__c FROM Goal__c WHERE Inicio__c >=" + stringAnoSelecionado + " AND Inicio__c <= " + stringAnoLimite + " AND Vendedor__C = null AND Estado__c = null AND Linha__c != null AND Departamento__c = null"
		} else if (tipoSelecionado == 'Departamento') {
			var query = "SELECT Name, Linha__c, Departamento__c FROM Goal__c WHERE Inicio__c >=" + stringAnoSelecionado + " AND Inicio__c <= " + stringAnoLimite + " AND Vendedor__C = null AND Estado__c = null AND Linha__c = null AND Departamento__c != null AND Departamento__c != 'Locação'"
		} else {
			var query = "SELECT Name, Linha__c FROM Goal__c WHERE Inicio__c >=" + stringAnoSelecionado + " AND Inicio__c <= " + stringAnoLimite + " AND Vendedor__C = null AND Estado__c = null AND Linha__c = null AND Departamento__c = null"
		}

		//console.log(query)

		//REALIZA A CONSULTA
		this.soql(cmp, query)

			//QUANDO A SOLICITAÇÃO FOR CONCLUÍDA, FAÇA:
			.then(function (subtipos) {

				if (tipoSelecionado == 'Vendedor') {
					var subtiposFiltrados = subtipos.reduce((unique, o) => {
						if (!unique.some(obj => obj.label === o.label && obj.Vendedor__c === o.Vendedor__c)) {
							unique.push(o);
						}
						return unique;
					}, []);
				} else if (tipoSelecionado == 'Estado') {
					var subtiposFiltrados = subtipos.reduce((unique, o) => {
						if (!unique.some(obj => obj.label === o.label && obj.Estado__c === o.Estado__c)) {
							unique.push(o);
						}
						return unique;
					}, []);
				} else if (tipoSelecionado == 'Linha') {
					var subtiposFiltrados = subtipos.reduce((unique, o) => {
						if (!unique.some(obj => obj.label === o.label && obj.Linha__c === o.Linha__c)) {
							unique.push(o);
						}
						return unique;
					}, []);
				} else if (tipoSelecionado == 'Departamento') {
					var subtiposFiltrados = subtipos.reduce((unique, o) => {
						if (!unique.some(obj => obj.label === o.label && obj.Departamento__c === o.Departamento__c)) {
							unique.push(o);
						}
						return unique;
					}, []);
				} else {
				}

				//console.log(subtiposFiltrados)

				//subtipos.filter(({ Departamento__c }, index) => !ids.includes(Departamento__c, index + 1))

				//LIMPA SELECT DE SUBTIPOS
				$('#divSelectSubtipos').empty()
				$('#divSelectSubtipos').append("<select id='selectSubtipos' class='selectEstado'></select>")

				//OCULTA O SELECT DE METAS
				$('#divSelectMetas').css('display', 'none');

				//SE O TIPO SELECIONADO FOR VENDEDOR
				if (tipoSelecionado == 'Vendedor') {

					//ADICIONA O PRIMEIRO OPTION COM O  TÍTULO
					$('#selectSubtipos').append("<option id='optionSelect' value='selecioneOVendedor'>Selecione o Vendedor</option>")

					//HABILITA A VISUALIZAÇÃO DA DIV COM O SELECT
					$("#divSelectSubtipos").css('display', 'flex');

					//PERCORRE OS SUBTIPOS
					subtiposFiltrados.forEach(function (subtipoAtual) {
						//ADICIONA O SUBTIPO NO SELECT DE SUBTIPOS
						$('#selectSubtipos').append("<option id='optionSelect' value='" + subtipoAtual.Vendedor__c + "'>" + subtipoAtual.Vendedor__r.Name + "</option>")
					})

					//INTANCIA O PLUGIN DE SELECT CUSTOMIZADO
					$("#selectSubtipos").dropzie();



					$("#divSelectSubtipos").find(".dropzieOption").click(function () {
						helper.subTipoSelecionado = $(this).attr('data-value')
						helper.textSubTipoSelecionado = $(this).text()
						helper.preencheMetas(cmp, event, helper, this)
					})
				} else if (tipoSelecionado == 'Estado') {
					$('#selectSubtipos').append("<option id='optionSelect' value='selecioneOTipo'>Selecione o Estado</option>")
					$("#divSelectSubtipos").css('display', 'flex');
					subtiposFiltrados.forEach(function (subtipoAtual) {
						$('#selectSubtipos').append("<option id='optionSelect' value='" + subtipoAtual.Estado__c + "'>" + subtipoAtual.Estado__c + "</option>")
					})
					$("#selectSubtipos").dropzie();

					$("#divSelectSubtipos").find(".dropzieOption").click(function () {
						helper.subTipoSelecionado = $(this).attr('data-value')
						helper.textSubTipoSelecionado = $(this).text()
						helper.preencheMetas(cmp, event, helper, this)
					})
				} else if (tipoSelecionado == 'Linha') {
					$('#selectSubtipos').append("<option id='optionSelect' value='selecioneOTipo'>Selecione a Linha</option>")
					$("#divSelectSubtipos").css('display', 'flex');
					subtiposFiltrados.forEach(function (subtipoAtual) {
						$('#selectSubtipos').append("<option id='optionSelect' value='" + subtipoAtual.Linha__c + "'>" + subtipoAtual.Linha__c + "</option>")
					})
					$("#selectSubtipos").dropzie();

					$("#divSelectSubtipos").find(".dropzieOption").click(function () {
						helper.subTipoSelecionado = $(this).attr('data-value')
						helper.textSubTipoSelecionado = $(this).text()
						helper.preencheMetas(cmp, event, helper, this)
					})
				} else if (tipoSelecionado == 'Departamento') {
					$('#selectSubtipos').append("<option id='optionSelect' value='selecioneOTipo'>Selecione o departamento</option>")
					$("#divSelectSubtipos").css('display', 'flex');
					subtiposFiltrados.forEach(function (subtipoAtual) {
						$('#selectSubtipos').append("<option id='optionSelect' value='" + subtipoAtual.Departamento__c + "'>" + subtipoAtual.Departamento__c + "</option>")
					})
					$("#selectSubtipos").dropzie();

					$("#divSelectSubtipos").find(".dropzieOption").click(function () {
						helper.subTipoSelecionado = $(this).attr('data-value')
						helper.textSubTipoSelecionado = $(this).text()
						helper.preencheMetas(cmp, event, helper, this)
					})

				} else if (tipoSelecionado == 'Geral') {
					$('#divSelectSubtipos').css('display', 'none');													//OCULTA O SELECT DE SUBTIPOS
					helper.textSubTipoSelecionado = $(this).text()
					helper.preencheMetas(cmp, event, helper, this)
				}
			})

			//trata excessão de erro
			.catch(function (error) {
				console.log(error)
			})
	},

	//FUNÇÃO QUE EXIBE ALERTAS AO USUÁRIO-------------------------------------------------------------
	exibeAlerta: function (cmp, event, helper, error, title, type, tipoMensagem, mode) {
		var toastEvent = $A.get("e.force:showToast");
		toastEvent.setParams({
			"title": title,
			"message": tipoMensagem + " " + error,
			"type": type,
			"mode": mode
		});
		toastEvent.fire();
	},
	//----------------------------------------------------------------------------------------------

	preencheMetas: function (cmp, event, helper, item) {
		//EXIBE SPINNER DE CARREGAMENTO
		helper.showSpinner(cmp);

		var subTipoSelecionado = helper.subTipoSelecionado
		var tipoSelecionado = helper.tipoSelecionado
		var anoSelecionado = helper.anoSelecionado
		var stringAnoSelecionado = anoSelecionado + '-01-01'
		var stringAnoLimite = anoSelecionado + '-12-31'
		var idVendedor = ''
		var valorTotal = []

		if (tipoSelecionado == 'Vendedor') {
			//DEFINE A QUERY DE BUSCA QUE PESQUISARÁ PELO VENDEDOR JÁ DEFINIDO
			var query = "SELECT Inicio__c, Final__c, Name, Id, Meta__c, Vendedor__c, Vendedor__r.Name, Vendedor__r.MediumPhotoUrl, Vendedor__r.Title, Vendedor__r.Contact.MailingState FROM Goal__c WHERE Inicio__c >=" + stringAnoSelecionado + " AND Inicio__c <= " + stringAnoLimite + " AND Vendedor__c = '" + subTipoSelecionado + "' AND Estado__c = null AND Linha__c = null AND Departamento__c = null ORDER BY Inicio__c"

			//HABILITA A VISUALIZAÇÃO DA DIV COM AS INFORMAÇÕES DO VENDEDOR
			$('#divImagemDescricao').css('display', 'flex');

		} else if (tipoSelecionado == 'Estado') {
			var query = "SELECT Name, Id, Meta__c, Inicio__c, Final__c, Vendedor__c FROM Goal__c WHERE Inicio__c >=" + stringAnoSelecionado + " AND Inicio__c <= " + stringAnoLimite + " AND Departamento__c = null AND Vendedor__r.Name = null AND Periodo__c != 'Trimestral' AND Estado__c = '" + subTipoSelecionado + "' AND Linha__c = null ORDER BY Inicio__c"
		} else if (tipoSelecionado == 'Linha') {
			var query = "SELECT Name, Meta__c, Id, Vendedor__c, Inicio__c, Final__c FROM Goal__c WHERE Inicio__c >=" + stringAnoSelecionado + " AND Inicio__c <= " + stringAnoLimite + " AND Departamento__c = null AND Vendedor__r.Name = null AND Estado__c = null AND Familia__c = null AND Periodo__c != 'Trimestral' AND Linha__c = '" + subTipoSelecionado + "' ORDER BY Inicio__c"
		} else if (tipoSelecionado == 'Departamento') {
			var query = "SELECT Name, Meta__c, Id, Vendedor__c, Inicio__c, Final__c FROM Goal__c WHERE Inicio__c >=" + stringAnoSelecionado + " AND Inicio__c <= " + stringAnoLimite + " AND Vendedor__c = null AND Estado__c = null AND Linha__c = null AND Periodo__c != 'Trimestral' AND Departamento__c = '" + subTipoSelecionado + "' ORDER BY Inicio__c"
		} else if (tipoSelecionado == 'Geral') {
			var query = "SELECT Name, Meta__c, Id, Vendedor__c, Inicio__c, Final__c FROM Goal__c WHERE Inicio__c >=" + stringAnoSelecionado + " AND Inicio__c <= " + stringAnoLimite + " AND Departamento__c = null AND Vendedor__c = null AND Estado__c = null AND Linha__c = null ORDER BY Inicio__c"
		} else {
			console.log("nenhum tipo selecionado")
		}

		console.log(query) //REMOVER

		//CLICK NECESSÁRIO PARA DESBUGAR A CONSULTA
		$('#valorMeta').click()

		//REALIZA A CONSULTA
		this.soql(cmp, query)

			//QUANDO A SOLICITAÇÃO FOR CONCLUÍDA, FAÇA:
			.then(function (metas) {

				if (metas.length == 0) {
					//HABILITA A VISUALIZAÇÃO DA DIV COM AS INFORMAÇÕES DO VENDEDOR
					$('#divImagemDescricao').css('display', 'none');

					//NÃO HÁ METAS CADASTRADAS PARA ESTE PERÍODO
					//helper.exibeAlerta(cmp, event, helper, "MSG DE ERRO DO SISTEMA", "NÃO HÁ METAS CADASTRADAS PARA ESTE PERÍODO", "error", "", "dismissable")
					helper.exibeAlerta(cmp, event, helper, "", "NÃO HÁ METAS CADASTRADAS PARA ESTE TIPO E PERÍODO", "error", "", "dismissable")

					//OCULTA SPINNER DE CARREGAMENTO---
					helper.hideSpinner(cmp);
					//---------------------------------
				} else {
					//HABILITA DIV COM A TABLE DE METAS
					//DESCOMENTAR PARA HABILITAR A TABELA COM AS METAS $("#divTableMetas").css('display', 'flex');

					//LIMPA A TABLE COM AS METAS
					$('#bodyTableMetas').empty()

					//LIMPA A DIV COM O SELECT DAS METAS
					$('#divSelectMetas').empty()

					//ADICIONA O SELECT À DIV
					$('#divSelectMetas').append("<select id='selectMetas' class='selectMetas'></select>")

					//HABILITA A VISUALIZAÇÃO DA DIV COM O SELECT
					$("#divSelectMetas").css('display', 'flex');

					//ADICIONA O PRIMEIRO OPTION COM O  TÍTULO
					$('#selectMetas').append("<option id='optionSelect' value='selecioneAMeta'>Selecione a Meta</option>")

					//PRIMEIRO ADICIONA-SE AO SELECT A META ANUAL
					//PERCORRE AS METAS ENCONTRADAS
					metas.forEach(function (metaAtual) {
						//VERIFICA SE É ANUAL
						if (!(metaAtual.Inicio__c.split("-")[1] == metaAtual.Final__c.split("-")[1])) {
							//ADICIONA A META ATUAL NO SELECT DE METAS
							$('#selectMetas').append("<option id='optionSelect' value='" + metaAtual.Id + "'>" + metaAtual.Name + "</option>")
						}
						//DESCOMENTAR PARA HABILITAR A TABELA COM AS METAS $('#bodyTableMetas').append("<tr> <td>" + metaAtual.Name + "</td><td>" + metaAtual.Meta__c + "</td><td>" + helper.tipoSelecionado + "</td><td>" + helper.textSubTipoSelecionado + "</td><td> <button id='buttonVisualizaMeta' type='button' style='margin-right: 5px;' class='btn btn-primary'><i class='fa fa-eye'></i></button> <button type='button' class='btn btn-success'><i class='fa fa-edit'></i></button> </td></tr>")
					})

					//DEPOIS ADICIONA AS METAS RESTANTES
					//PERCORRE AS METAS ENCONTRADAS
					metas.forEach(function (metaAtual) {
						//VERIFICA SE A META É MENSAL
						if (metaAtual.Inicio__c.split("-")[1] == metaAtual.Final__c.split("-")[1]) {
							//ADICIONA A META ATUAL NO SELECT DE METAS
							$('#selectMetas').append("<option id='optionSelect' value='" + metaAtual.Id + "'>" + metaAtual.Name + "</option>")
						}
						//DESCOMENTAR PARA HABILITAR A TABELA COM AS METAS $('#bodyTableMetas').append("<tr> <td>" + metaAtual.Name + "</td><td>" + metaAtual.Meta__c + "</td><td>" + helper.tipoSelecionado + "</td><td>" + helper.textSubTipoSelecionado + "</td><td> <button id='buttonVisualizaMeta' type='button' style='margin-right: 5px;' class='btn btn-primary'><i class='fa fa-eye'></i></button> <button type='button' class='btn btn-success'><i class='fa fa-edit'></i></button> </td></tr>")
					})

					//INTANCIA O PLUGIN DE SELECT CUSTOMIZADO
					$("#selectMetas").dropzie();

					//HABILITA A VISUALIZAÇÃO DA DIV E BLOCO COM AS INFORMAÇÕES DO VENDEDOR, LINHA, ETC-----------
					if (tipoSelecionado == 'Vendedor') {

						//HABILITA A VISUALIZAÇÃO DA DIV COM AS INFORMAÇÕES DO VENDEDOR
						$('#divImagemDescricao').css('display', 'flex');

						//OBTÉM O NOME DO VENDEDOR
						var nomeVendedor = metas[0].Vendedor__r.Name

						//OBTÉM O CARGO DO VENDEDOR
						var cargoVendedor = metas[0].Vendedor__r.Title

						//OBTÉM A IMAGEM DO VENDEDOR
						var urlImagemVendedor = metas[0].Vendedor__r.MediumPhotoUrl

						//OBTÉM O ESTADO DO VENDEDOR
						var estado = '' //metas[0].Vendedor__r.Contact.MailingState

						$('#divImagem').empty()
						$('#divImagem').append("<img src='" + urlImagemVendedor + "' class='imgUserClass'/>")

						//SETA NA DIV O NOME DO VENDEDOR
						$('#nomePrincipal').text(nomeVendedor)

						//SETA NA DIV O CARGO DO VENDEDOR
						$('#nomeSecundario').text(cargoVendedor + "" + estado)

					} else if (tipoSelecionado == 'Estado') {
						//OCULTA A VISUALIZAÇÃO DA DIV COM AS INFORMAÇÕES DO VENDEDOR
						$('#divImagemDescricao').css('display', 'none');

					} else if (tipoSelecionado == 'Linha') {
						//OCULTA A VISUALIZAÇÃO DA DIV COM AS INFORMAÇÕES DO VENDEDOR
						$('#divImagemDescricao').css('display', 'none');

					} else if (tipoSelecionado == 'Geral') {
						//OCULTA A VISUALIZAÇÃO DA DIV COM AS INFORMAÇÕES DO VENDEDOR
						$('#divImagemDescricao').css('display', 'none');

					} else if (tipoSelecionado == 'Departamento') {
						//OCULTA A VISUALIZAÇÃO DA DIV COM AS INFORMAÇÕES DO VENDEDOR
						$('#divImagemDescricao').css('display', 'none');

					}
					else {
						console.log("nenhum tipo selecionado")
					}
					//---------------------------------------------------------------------------------------------

					//CLICK NECESSÁRIO PARA DESBUGAR A CONSULTA
					$('#valorMeta').click()

					//EVENTO DE CLIQUE NO SELECT COM AS METAS-----------------------------
					$("#divSelectMetas").find(".dropzieOption").click(function () {
						helper.metaSelecionada = $(this).attr('data-value')
						helper.preencheVisualizacao(cmp, event, helper, this)
					})
					//--------------------------------------------------------------------

					//OCULTA SPINNER DE CARREGAMENTO---
					helper.hideSpinner(cmp);
					//---------------------------------
				}
			})

			//trata excessão de erro
			.catch(function (error) {
				console.log(error)
			})
	},

	preencheVisualizacao: function (cmp, event, helper, item) {
		//Exibe Spinner de carregamento
		helper.showSpinner(cmp);

		var idDaMeta = helper.metaSelecionada							//DEFINE A VARIAVEL COM O ID DA META SELECIONADA
		//console.log("meta selecionado", idDaMeta)
        var idVendedor = ''												//DEFINE A VARIAVEL COM O ID DO VENDEDOR
		var subTipoSelecionado = helper.subTipoSelecionado				//DEFINE A VARIAVEL COM O SUBTIPO SELECIONADO
		var tipoSelecionado = helper.tipoSelecionado					//DEFINE O TIPO SELECIONADO	
		var anoSelecionado = helper.anoSelecionado						//DEFINE A VARIAVEL DO ANO SELECIONADO
		var stringAnoSelecionado = anoSelecionado + '-01-01'			//DEFINE VARIÁVEL QUE ARMAZENA O ANO SELECIONADO
		var stringAnoLimite = anoSelecionado + '-12-31'					//DEFINE VARIÁVEL QUE ARMAZENA O ANO SELECIONADO LIMITE
		var valorTotal = 0
		var valorTotalFormatado = ''									//DEFINE VARIÁVEL QUE ARMAZENA O VALOR TOTAL DA META
		var listaPedidos = []
		var listaMetas = []
		var verificadorMetaAnual = true
		var metaClicada = $(item).attr('data-value')
		var subtipoClicado = $("#divSelectSubtipos").find(".dropzieToggle").text()

		//REALIZA A CONSULTA RECUPERANDO OS DADOS DA META ATUAL
		this.soql(cmp, "SELECT Name, Meta__c, Inicio__c, Final__c, Linha__c, Vendedor__c FROM Goal__c WHERE Id = '" + idDaMeta + "'")

			//QUANDO A SOLICITAÇÃO FOR CONCLUÍDA, FAÇA:
			.then(function (metas) {
				metas.forEach(function (metaAtual) {
					//DEFINE O VALOR DA VARIÁVEL QUE ARMAZENA O VALOR TOTAL
					valorTotal = metaAtual.Meta__c

					//CONVERTE A STRING DO TOTAL EM DECIMAL COM 2 CASAS
					valorTotalFormatado = new Intl.NumberFormat('id', { minimumFractionDigits: 2 }).format(valorTotal);

					//SETA VALOR NA DIV TOTAL DA META
					$('#valorMeta').text(valorTotalFormatado)

					//SETA VARIÁVEL COM O ID DO VENDEDOR
					idVendedor = metaAtual.Vendedor__c
				})

				//VERIFICA O TIPO SELECIONADO
				if (tipoSelecionado == 'Vendedor') {
					var query = "SELECT SUM(totalprice) FROM OrderItem WHERE OrderItem.Order.natureza_de_opera_o__c IN ('VENDA', 'SERVIÇO', 'LOCAÇÃO') AND OrderItem.Order.status not in ('Rascunho', 'Aguardando Aprovação Comercial', 'Aguardando Aprovação Financeira', 'Reprovado', 'Aprovado', 'Cancelado', 'Desativado', 'Pendente') and OrderItem.Order.vendedor__c = '" + idVendedor + "' AND OrderItem.Order.Data_de_ativacao__c >= " + stringAnoSelecionado + " AND OrderItem.Order.Data_de_ativacao__c <= " + stringAnoLimite + ""
					var query2 = "SELECT OrderItem.Order.OrderNumber, OrderItem.Order.Data_de_ativacao__c, TotalPrice FROM OrderItem WHERE OrderItem.Order.natureza_de_opera_o__c not in ('demonstração', 'bonificação', 'remessa de comodato', 'remessa de locação') AND OrderItem.Order.status not in ('Rascunho', 'Aguardando Aprovação Comercial', 'Aguardando Aprovação Financeira', 'Reprovado', 'Aprovado', 'Cancelado', 'Desativado', 'Pendente') and OrderItem.Order.vendedor__c = '" + idVendedor + "' AND OrderItem.Order.Data_de_ativacao__c >= " + stringAnoSelecionado + " AND OrderItem.Order.Data_de_ativacao__c <= " + stringAnoLimite + ""
				} else if (tipoSelecionado == 'Estado') {
					var query = "SELECT SUM(totalprice) FROM OrderItem WHERE OrderItem.Order.natureza_de_opera_o__c IN ('VENDA', 'SERVIÇO', 'LOCAÇÃO') AND OrderItem.Order.status not in ('Rascunho', 'Aguardando Aprovação Comercial', 'Aguardando Aprovação Financeira', 'Reprovado', 'Aprovado', 'Cancelado', 'Desativado', 'Pendente') and OrderItem.Order.BillingState = '" + subTipoSelecionado + "' AND OrderItem.Order.Data_de_ativacao__c >= " + stringAnoSelecionado + " AND OrderItem.Order.Data_de_ativacao__c <= " + stringAnoLimite + ""
					var query2 = "SELECT OrderItem.Order.OrderNumber, OrderItem.Order.Data_de_ativacao__c, TotalPrice FROM OrderItem WHERE OrderItem.Order.natureza_de_opera_o__c not in ('demonstração', 'bonificação', 'remessa de comodato', 'remessa de locação') AND OrderItem.Order.status not in ('Rascunho', 'Aguardando Aprovação Comercial', 'Aguardando Aprovação Financeira', 'Reprovado', 'Aprovado', 'Cancelado', 'Desativado', 'Pendente') and OrderItem.Order.BillingState = '" + subTipoSelecionado + "' AND OrderItem.Order.Data_de_ativacao__c >= " + stringAnoSelecionado + " AND OrderItem.Order.Data_de_ativacao__c <= " + stringAnoLimite + ""
				} else if (tipoSelecionado == 'Linha') {
					var query = "SELECT SUM(totalprice) FROM OrderItem WHERE OrderItem.Order.natureza_de_opera_o__c IN ('VENDA', 'SERVIÇO', 'LOCAÇÃO') AND OrderItem.Order.status not in ('Rascunho', 'Aguardando Aprovação Comercial', 'Aguardando Aprovação Financeira', 'Reprovado', 'Aprovado', 'Cancelado', 'Desativado', 'Pendente') and OrderItem.Product2.Linha__c = '" + subTipoSelecionado + "' AND OrderItem.Order.Data_de_ativacao__c >= " + stringAnoSelecionado + " AND OrderItem.Order.Data_de_ativacao__c <= " + stringAnoLimite + ""
					var query2 = "SELECT OrderItem.Order.OrderNumber, OrderItem.Order.Data_de_ativacao__c, TotalPrice FROM OrderItem WHERE OrderItem.Order.natureza_de_opera_o__c not in ('demonstração', 'bonificação', 'remessa de comodato', 'remessa de locação') AND OrderItem.Order.status not in ('Rascunho', 'Aguardando Aprovação Comercial', 'Aguardando Aprovação Financeira', 'Reprovado', 'Aprovado', 'Cancelado', 'Desativado', 'Pendente') and OrderItem.Product2.Linha__c = '" + subTipoSelecionado + "' AND OrderItem.Order.Data_de_ativacao__c >= " + stringAnoSelecionado + " AND OrderItem.Order.Data_de_ativacao__c <= " + stringAnoLimite + ""
				} else if (tipoSelecionado == 'Departamento') {
					console.log(subtipoClicado)
					if(subtipoClicado == 'Vendas'){
						console.log("clicou em uma meta de venda")
						//PESQUISA
						var query = "SELECT SUM(totalprice) FROM OrderItem WHERE OrderItem.Order.natureza_de_opera_o__c IN ('VENDA', 'SERVIÇO', 'LOCAÇÃO') AND OrderItem.Order.status not in ('Rascunho', 'Aguardando Aprovação Comercial', 'Aguardando Aprovação Financeira', 'Reprovado', 'Aprovado', 'Cancelado', 'Desativado', 'Pendente') AND (OrderItem.Order.Departamento3__c = 'Comercial' OR OrderItem.Order.Departamento3__c = 'GOVERNO') AND OrderItem.Order.Data_de_ativacao__c >= " + stringAnoSelecionado + " AND OrderItem.Order.Data_de_ativacao__c <= " + stringAnoLimite + ""
						var query2 = "SELECT OrderItem.Order.OrderNumber, OrderItem.Order.Data_de_ativacao__c, TotalPrice FROM OrderItem WHERE OrderItem.Order.natureza_de_opera_o__c IN ('VENDA', 'SERVIÇO', 'LOCAÇÃO') AND OrderItem.Order.status not in ('Rascunho', 'Aguardando Aprovação Comercial', 'Aguardando Aprovação Financeira', 'Reprovado', 'Aprovado', 'Cancelado', 'Desativado', 'Pendente') AND (OrderItem.Order.Departamento3__c = 'Comercial' OR OrderItem.Order.Departamento3__c = 'GOVERNO') AND OrderItem.Order.Data_de_ativacao__c >= " + stringAnoSelecionado + " AND OrderItem.Order.Data_de_ativacao__c <= " + stringAnoLimite + ""

					}else{
						console.log("clicou em uma meta comum")
						var query = "SELECT SUM(totalprice) FROM OrderItem WHERE OrderItem.Order.natureza_de_opera_o__c IN ('VENDA', 'SERVIÇO', 'LOCAÇÃO') AND OrderItem.Order.status not in ('Rascunho', 'Aguardando Aprovação Comercial', 'Aguardando Aprovação Financeira', 'Reprovado', 'Aprovado', 'Cancelado', 'Desativado', 'Pendente') and OrderItem.Order.Departamento3__c = '"+subTipoSelecionado+"' AND OrderItem.Order.Data_de_ativacao__c >= " + stringAnoSelecionado + " AND OrderItem.Order.Data_de_ativacao__c <= " + stringAnoLimite + ""
						var query2 = "SELECT OrderItem.Order.OrderNumber, OrderItem.Order.Data_de_ativacao__c, TotalPrice FROM OrderItem WHERE OrderItem.Order.natureza_de_opera_o__c IN ('VENDA', 'SERVIÇO', 'LOCAÇÃO') AND OrderItem.Order.status not in ('Rascunho', 'Aguardando Aprovação Comercial', 'Aguardando Aprovação Financeira', 'Reprovado', 'Aprovado', 'Cancelado', 'Desativado', 'Pendente') and OrderItem.Order.Departamento3__c = '" + subTipoSelecionado + "' AND OrderItem.Order.Data_de_ativacao__c >= " + stringAnoSelecionado + " AND OrderItem.Order.Data_de_ativacao__c <= " + stringAnoLimite + ""
					}
					
				} else if (tipoSelecionado == 'Geral') {
					var query = "SELECT SUM(totalprice) FROM OrderItem WHERE OrderItem.Order.natureza_de_opera_o__c IN ('VENDA', 'SERVIÇO', 'LOCAÇÃO') AND OrderItem.Order.status not in ('Rascunho', 'Aguardando Aprovação Comercial', 'Aguardando Aprovação Financeira', 'Reprovado', 'Aprovado', 'Cancelado', 'Desativado', 'Pendente') AND OrderItem.Order.Data_de_ativacao__c >= " + stringAnoSelecionado + " AND OrderItem.Order.Data_de_ativacao__c <= " + stringAnoLimite + ""
					var query2 = "SELECT OrderItem.Order.OrderNumber, OrderItem.Order.Data_de_ativacao__c, TotalPrice FROM OrderItem WHERE OrderItem.Order.natureza_de_opera_o__c IN ('VENDA', 'SERVIÇO', 'LOCAÇÃO') AND OrderItem.Order.status not in ('Rascunho', 'Aguardando Aprovação Comercial', 'Aguardando Aprovação Financeira', 'Reprovado', 'Aprovado', 'Cancelado', 'Desativado', 'Pendente') AND OrderItem.Order.Data_de_ativacao__c >= " + stringAnoSelecionado + " AND OrderItem.Order.Data_de_ativacao__c <= " + stringAnoLimite + ""
				}

				console.log("QUERY DA SOMA",query)
				console.log("QUERY 2",query2)

				//CLICK NECESSÁRIO PARA DESBUGAR A CONSULTA
				$('#valorMeta').click()

				//REALIZA A CONSULTA 
				helper.soql(cmp, query)

					//QUANDO A SOLICITAÇÃO FOR CONCLUÍDA, FAÇA:
					.then(function (metas) {
						//CLICK NECESSÁRIO PARA DESBUGAR A CONSULTA
						$('#valorMeta').click()

						//PERCORRE AS METAS OBTIDAS
						metas.forEach(function (metaAtual) {
							//ARMAZENA O VALOR TOTAL 
							var valorTotalAtingido = metaAtual.expr0
                            
							var valorTotalAtingidoFormatado = Number(valorTotalAtingido).toLocaleString('pt-br',{style: 'currency', currency: 'BRL'}) //new Intl.NumberFormat('id', { minimumFractionDigits: 2 }).format(valorTotalAtingido);

							console.log("valor total atingido da meta: ", valorTotalAtingido)

							$('#valorAtingido').text(valorTotalAtingidoFormatado)

							var percentualAlcancado = (valorTotalAtingido / valorTotal) * 100

							//SETA VALOR NA DIV TOTAL DA META
							$('#percentualAlcancado').text(percentualAlcancado.toFixed(1) + '%')
						})

						//REALIZA A CONSULTA 
						helper.soql(cmp, query2)
							//QUANDO A SOLICITAÇÃO FOR CONCLUÍDA, FAÇA:
							.then(function (pedidos) {
								//CLICK NECESSÁRIO PARA DESBUGAR A CONSULTA
								$('#valorMeta').click()

								//console.log(pedidos)

								pedidos.forEach(function (pedidoAtual) {
									
									var mesAtual = pedidoAtual.Order.Data_de_ativacao__c.split("-")[1];
									var totalDoMes = pedidoAtual.TotalPrice

									//console.log(mesAtual + " " + totalDoMes)
									listaPedidos.push({ "mes": mesAtual, "totalDoMes": totalDoMes })
								})

								//O TRECHO ABAIXO É UM GROUP BY DO TOTAL VENDIDO EM CADA MÊS---
								var result = [];
								listaPedidos.reduce(function (res, value) {
									if (!res[value.mes]) {
										res[value.mes] = { mes: value.mes, totalDoMes: 0 };
										result.push(res[value.mes])
									}
									res[value.mes].totalDoMes += value.totalDoMes;
									return res;
								}, {});
								//---------------------------------------------------------------

								var dataTeste = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
								var dataMetaMes = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]

								stringAnoSelecionado = anoSelecionado + '-01-01'
								stringAnoLimite = anoSelecionado + '-12-31'

								if (tipoSelecionado == 'Vendedor') {
									//DEFINE A QUERY DE BUSCA QUE PESQUISARÁ PELO VENDEDOR JÁ DEFINIDO
									var query = "SELECT Meta__c, Periodo__c, Inicio__c, Final__c FROM Goal__c WHERE Inicio__c >=" + stringAnoSelecionado + " AND Inicio__c <= " + stringAnoLimite + " AND Departamento__c = null AND Vendedor__c = '" + subTipoSelecionado + "' AND Periodo__c != 'Trimestral' AND Estado__c = null AND Linha__c = null"
								} else if (tipoSelecionado == 'Estado') {
									var query = "SELECT Meta__c, Periodo__c, Inicio__c, Final__c FROM Goal__c WHERE Inicio__c >=" + stringAnoSelecionado + " AND Inicio__c <= " + stringAnoLimite + " AND Departamento__c = null AND Vendedor__r.Name = null AND Periodo__c != 'Trimestral' AND Estado__c = '" + subTipoSelecionado + "' AND Linha__c = null"
								} else if (tipoSelecionado == 'Linha') {
									var query = "SELECT Meta__c, Periodo__c, Inicio__c, Final__c FROM Goal__c WHERE Inicio__c >=" + stringAnoSelecionado + " AND Inicio__c <= " + stringAnoLimite + " AND Departamento__c = null AND Vendedor__r.Name = null AND Estado__c = null AND Periodo__c != 'Trimestral' AND Linha__c = '" + subTipoSelecionado + "'"
								} else if (tipoSelecionado == 'Departamento') {
									var query = "SELECT Meta__c, Periodo__c, Inicio__c, Final__c FROM Goal__c WHERE Inicio__c >=" + stringAnoSelecionado + " AND Inicio__c <= " + stringAnoLimite + " AND Vendedor__r.Name = null AND Estado__c = null AND Linha__c = null AND Periodo__c != 'Trimestral' AND Departamento__c = '" + subTipoSelecionado + "'"
								} else if (tipoSelecionado == 'Geral') {
									var query = "SELECT Meta__c, Periodo__c, Inicio__c, Final__c FROM Goal__c WHERE Inicio__c >=" + stringAnoSelecionado + " AND Inicio__c <= " + stringAnoLimite + " AND Departamento__c = null AND Vendedor__c = null AND Estado__c = null AND Periodo__c != 'Trimestral' AND Linha__c = null"
								} else {
									console.log("nenhum tipo selecionado")
								}


								//REALIZA A CONSULTA
								helper.soql(cmp, query)
									//QUANDO A SOLICITAÇÃO FOR CONCLUÍDA, FAÇA:
									.then(function (metas) {

                                        metas.forEach(function (metaAtual) {
                                            console.log(metaAtual)
                                            console.log("PERIODOO", metaAtual.Periodo__c)
                                            //VERIFICA SE A META ATUAL É MENSAL
                                            if (metaAtual.Periodo__c == 'Mensal') {
                                                
                                                if (helper.metaSelecionada == metaAtual.Id) {
                                                    helper.metaMesSelecionado = metaAtual.Inicio__c.split("-")[1]
                                                }
                                                
                                                var mesAtual = metaAtual.Inicio__c.split("-")[1]
                                                var totalDoMes = metaAtual.Meta__c
                                                
                                                listaMetas.push({ "mes": mesAtual, "totalDoMes": totalDoMes })
                                            }else{
                                                helper.metaAnual = metaAtual.Id
                                            }

                                        })
                                        
                                        
                                        
                                        console.log("vendido em cada mes", result)
                                        
                                        

										result.forEach(e => {
											dataTeste[parseInt(e.mes) - 1] = parseInt(e.totalDoMes);
										});
                                            
                                            console.log(dataTeste)

										listaMetas.forEach(e => {
											dataMetaMes[parseInt(e.mes) - 1] = parseInt(e.totalDoMes);
										});

										//CASO A META FOR MENSAL, ENTRARÁ NESTE IF SOBRESCREVENDO OS DADOS DE TOTAL DA META E TOTAL ATINGIDO-----------------------------
										if (metaClicada != helper.metaAnual) {
                                            
                                            console.log("META CLICADA OFICIAL", metaClicada)
                                            console.log("meta Anual", helper.metaAnual)
                                            
											var valorTotalAtingido = dataTeste[parseInt(helper.metaMesSelecionado) - 1]
											var valorTotalAtingidoFormatado = new Intl.NumberFormat('id', { minimumFractionDigits: 2 }).format(valorTotalAtingido);
                                        	console.log("clicado em meta mensal: " + valorTotalAtingido)
                                        	console.log("clicado em meta mensal: " + valorTotalAtingidoFormatado)
                                            console.log(helper.listaMetas)
                                        
											$('#valorAtingido').text(valorTotalAtingidoFormatado)
											var percentualAlcancado = (valorTotalAtingido / valorTotal) * 100

											//SETA VALOR NA DIV TOTAL DA META
											$('#percentualAlcancado').text(percentualAlcancado.toFixed(1) + '%')
										}else{
                                          console.log("META CLICADA É ANUAL")
                                          }
										//FIM META MENSAL-----------------------------------------------------------------------------------------------------------------

										//REMOVE GRAFICO DA DIV---------------------------------------------------------------------
										$('#idChart').empty()
										$('#idChart').append("<canvas id='myChart' width='600' class='chartClass'></canvas>")
										//------------------------------------------------------------------------------------------

										const labels = [
											'Janeiro',
											'Fevereiro',
											'Março',
											'Abril',
											'Maio',
											'Junho',
											'Julho',
											'Agosto',
											'Setembro',
											'Outubro',
											'Novembro',
											'Dezembro',
										];

										const data = {
											labels: labels,
											datasets: [{
												label: 'TOTAL ATINGIDO POR MÊS',
												backgroundColor: [
													'rgb(47, 82, 222)',
													'rgb(47, 82, 222)',
													'rgb(47, 82, 222)',
													'rgb(47, 82, 222)',
													'rgb(47, 82, 222)',
												],
												data: dataTeste,
											},

											{
												label: 'META DO MÊS',
												backgroundColor: [
													'rgb(190, 205, 248)',
													'rgb(190, 205, 248)',
													'rgb(190, 205, 248)',
													'rgb(190, 205, 248)',
													'rgb(190, 205, 248)',
												],
												data: dataMetaMes,
											},]
										};

										const option = {
											responsive: false,
											scales: {
												y: {
													beginAtZero: true
												}
											}
										}

										const config = {
											type: 'bar',
											data: data,
											options: option
										};

										//INSTANCIA O OBJETO DO GRAFICO-------------
										const myChart = new Chart(
											document.getElementById('myChart'),
											config
										);
										//------------------------------------------

										//OCULTA SPINNER DE CARREGAMENTO---
										helper.hideSpinner(cmp);
										//---------------------------------
									})

									//trata excessão de erro
									.catch(function (error) {
										console.log(error)
									})


								//OCULTA SPINNER DE CARREGAMENTO---
								helper.hideSpinner(cmp);
								//---------------------------------
							})

							//trata excessão de erro
							.catch(function (error) {
								console.log(error)
							})
					})

					//trata excessão de erro
					.catch(function (error) {
						console.log(error)
					})
			})

			//trata excessão de erro
			.catch(function (error) {
				console.log(error)
			})
	},

	preencheSubtipos2: function (cmp, event, helper, item) {
		//Exibe Spinner de carregamento
		helper.showSpinner(cmp);

		$("#divSelectSubtipos").css('display', 'flex');

		var anoSelecionado = helper.anoSelecionado
		var anoLimite = anoSelecionado + 1

		var stringAnoSelecionado = anoSelecionado + '-01-01'
		var stringAnoLimite = anoLimite + '-12-31'

		//REALIZA A CONSULTA
		this.soql(cmp, "SELECT Name FROM Goal__c WHERE Inicio__c >= " + stringAnoSelecionado + " AND Inicio__c <= " + stringAnoLimite + " LIMIT 100")

			//QUANDO A SOLICITAÇÃO FOR CONCLUÍDA, FAÇA:
			.then(function (metas) {
				console.log(metas)
				metas.forEach(function (metaAtual) {
					console.log(metaAtual)

				})

				//OCULTA SPINNER DE CARREGAMENTO---
				helper.hideSpinner(cmp);
				//---------------------------------
			})

			//trata excessão de erro
			.catch(function (error) {
				console.log(error)
			})

	},
})