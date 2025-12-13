({
	anosFiscais: ["2022", "2023"],
	tipos: ["Vendedor", "Estado", "Linha", "Departamento", "Geral"],

	anoSelecionado: '',
	tipoSelecionado: '',
	subTipoSelecionado: '',
	metaSelecionada: '',
	metaMesSelecionado: '',
	textSubTipoSelecionado: '',
    cargoVendedor: '',
    imagemVendedor: '',
	metaAnual: '',
    data: [],
    dataProcessada: [],
    result: {},


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
			var query = "SELECT Name, Linha__c, Departamento__c FROM Goal__c WHERE Inicio__c >=" + stringAnoSelecionado + " AND Inicio__c <= " + stringAnoLimite + " AND Vendedor__C = null AND Estado__c = null AND Linha__c = null AND Departamento__c != null"
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

	//FUNÇÃO QUE EXIBE ALERTAS AO USUÁRIO-----------------------------------------------------------
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
	
    groupBy: function(cmp, event, helper, xs, key){
        return xs.reduce(function(rv, x) {
            (rv[x[key]] = rv[x[key]] || []).push(x);
            return rv;
        }, []);
    },

    groupBy2: function(cmp, event, helper, xs, key, key2){
        return xs.reduce(function(rv, x) {
            (rv[x[key][key2]] = rv[x[key][key2]] || []).push(x);
            return rv;
        }, []);
    },

    
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
			var query = "SELECT Departamento__c, META_DE_OPPS_CRIADAS__c, METAS_DE_DEMONSTRA_O__c, METAS_DE_VISITAS__c, Linha__c, Familia__c, Tipo__c, Mes__c, Ano__c, Periodo__c, Name, Id, Meta__c, Vendedor__c, Vendedor__r.Name, Vendedor__r.MediumPhotoUrl, Vendedor__r.Title, Vendedor__r.Contact.MailingState FROM Goal__c WHERE Inicio__c >=" + stringAnoSelecionado + " AND Inicio__c <= " + stringAnoLimite + " AND Vendedor__c = '" + subTipoSelecionado + "' AND Estado__c = null ORDER BY Inicio__c"

			//HABILITA A VISUALIZAÇÃO DA DIV COM AS INFORMAÇÕES DO VENDEDOR
			//$('#divImagemDescricao').css('display', 'flex');

		} else if (tipoSelecionado == 'Estado') {
			var query = "SELECT Name, Departamento__c, Id, Meta__c, Inicio__c, Final__c Vendedor__c FROM Goal__c WHERE Inicio__c >=" + stringAnoSelecionado + " AND Inicio__c <= " + stringAnoLimite + " AND Departamento__c = null AND Vendedor__r.Name = null AND Estado__c = '" + subTipoSelecionado + "' AND Linha__c = null ORDER BY Inicio__c"
		} else if (tipoSelecionado == 'Linha') {
			var query = "SELECT Name, Meta__c, Id, Vendedor__c, Inicio__c, Final__c FROM Goal__c WHERE Inicio__c >=" + stringAnoSelecionado + " AND Inicio__c <= " + stringAnoLimite + " AND Departamento__c = null AND Vendedor__r.Name = null AND Estado__c = null AND Linha__c = '" + subTipoSelecionado + "' ORDER BY Inicio__c"
		} else if (tipoSelecionado == 'Departamento') {
			var query = "SELECT Name, Meta__c, Id, Vendedor__c, Inicio__c, Final__c FROM Goal__c WHERE Inicio__c >=" + stringAnoSelecionado + " AND Inicio__c <= " + stringAnoLimite + " AND Vendedor__c = null AND Estado__c = null AND Linha__c = null AND Departamento__c = '" + subTipoSelecionado + "' ORDER BY Inicio__c"
		} else if (tipoSelecionado == 'Geral') {
			var query = "SELECT Name, Meta__c, Id, Vendedor__c, Inicio__c, Final__c FROM Goal__c WHERE Inicio__c >=" + stringAnoSelecionado + " AND Inicio__c <= " + stringAnoLimite + " AND Departamento__c = null AND Vendedor__c = null AND Estado__c = null AND Linha__c = null ORDER BY Inicio__c"
		} else {
			console.log("nenhum tipo selecionado")
		}
        

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
                    //AGRUPA AS METAS PELA LINHA
                    var result = helper.groupBy(cmp, event, helper, metas, 'Linha__c')
                    
                    //OBTÉM O CARGO DO VENDEDOR
                    helper.cargoVendedor = metas[0].Vendedor__r.Title
                    
                    //OBTÉM A IMAGEM DO VENDEDOR
                    helper.imagemVendedor = metas[0].Vendedor__r.MediumPhotoUrl
                    
                    //DEFINE AS METAS DE VENDA GERAL E LOCACAO
                    result['VENDA_GERAL'] = result.undefined.filter(v => v.Tipo__c == 'POR VENDEDOR  GERAL');
                    result['LOCAÇÃO'] = result.undefined.filter(v => v.Departamento__c == 'Locação');
                    
                    //SETA O TIPO DAS METAS JA INSERIDAS
                    for (let key in result) {
                        result[key]['TipoSomador'] = 'Real'
                    }
                    
                    //DEFINE METAS AUXILIARES
                    result['VISITAS'] = result.VENDA_GERAL
                    result['VISITAS']['TipoSomador'] = 'Contadora'
                    
                    result['OPPS_CRIADAS'] = result.VENDA_GERAL
                    result['OPPS_CRIADAS']['TipoSomador'] = 'Contadora'
                    
                    result['DEMOS'] = result.VENDA_GERAL
                    result['DEMOS']['TipoSomador'] = 'Contadora'
                    
                    helper.result = result
                    
                    helper.preencheRealizado(cmp, event, helper);
                    
                    //console.log(helper.groupBy(cmp, event, helper, result['ULTRASSOM'], 'Mes__c'))
                    //console.log(result)
					

                    
                    //helper.data = metas
					//HABILITA DIV COM A TABLE DE METAS
					//DESCOMENTAR PARA HABILITAR A TABELA COM AS METAS $("#divTableMetas").css('display', 'flex');

					//LIMPA A TABLE COM AS METAS
					//$('#bodyTableMetas').empty()

					//LIMPA A DIV COM O SELECT DAS METAS
					//$('#divSelectMetas').empty()

					//ADICIONA O SELECT À DIV
					//$('#divSelectMetas').append("<select id='selectMetas' class='selectMetas'></select>")

					//HABILITA A VISUALIZAÇÃO DA DIV COM O SELECT
					//$("#divSelectMetas").css('display', 'flex');

					//ADICIONA O PRIMEIRO OPTION COM O  TÍTULO
					//$('#selectMetas').append("<option id='optionSelect' value='selecioneAMeta'>Selecione a Meta</option>")
 
                    
					//PRIMEIRO ADICIONA-SE AO SELECT A META ANUAL
					//PERCORRE AS METAS ENCONTRADAS
					//metas.forEach(function (metaAtual) {
						//VERIFICA SE É ANUAL
						//if (!(metaAtual.Inicio__c.split("-")[1] == metaAtual.Final__c.split("-")[1])) {
							//ADICIONA A META ATUAL NO SELECT DE METAS
							//$('#selectMetas').append("<option id='optionSelect' value='" + metaAtual.Id + "'>" + metaAtual.Name + "</option>")
						//}
						//DESCOMENTAR PARA HABILITAR A TABELA COM AS METAS $('#bodyTableMetas').append("<tr> <td>" + metaAtual.Name + "</td><td>" + metaAtual.Meta__c + "</td><td>" + helper.tipoSelecionado + "</td><td>" + helper.textSubTipoSelecionado + "</td><td> <button id='buttonVisualizaMeta' type='button' style='margin-right: 5px;' class='btn btn-primary'><i class='fa fa-eye'></i></button> <button type='button' class='btn btn-success'><i class='fa fa-edit'></i></button> </td></tr>")
					//})

					//DEPOIS ADICIONA AS METAS RESTANTES
					//PERCORRE AS METAS ENCONTRADAS
					//metas.forEach(function (metaAtual) {
						//VERIFICA SE A META É MENSAL
						//if (metaAtual.Inicio__c.split("-")[1] == metaAtual.Final__c.split("-")[1]) {
							//ADICIONA A META ATUAL NO SELECT DE METAS
							///$('#selectMetas').append("<option id='optionSelect' value='" + metaAtual.Id + "'>" + metaAtual.Name + "</option>")
						//}
						//DESCOMENTAR PARA HABILITAR A TABELA COM AS METAS $('#bodyTableMetas').append("<tr> <td>" + metaAtual.Name + "</td><td>" + metaAtual.Meta__c + "</td><td>" + helper.tipoSelecionado + "</td><td>" + helper.textSubTipoSelecionado + "</td><td> <button id='buttonVisualizaMeta' type='button' style='margin-right: 5px;' class='btn btn-primary'><i class='fa fa-eye'></i></button> <button type='button' class='btn btn-success'><i class='fa fa-edit'></i></button> </td></tr>")
					//})

					//INTANCIA O PLUGIN DE SELECT CUSTOMIZADO
					//$("#selectMetas").dropzie();
					/*

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
					//---------------------------------------------------------------------------------------------*/

					//CLICK NECESSÁRIO PARA DESBUGAR A CONSULTA
					$('#valorMeta').click()
                    /*

					//EVENTO DE CLIQUE NO SELECT COM AS METAS-----------------------------
					$("#divSelectMetas").find(".dropzieOption").click(function () {
						helper.metaSelecionada = $(this).attr('data-value')
						helper.preencheVisualizacao(cmp, event, helper, this)
					})
					//--------------------------------------------------------------------*/

					//OCULTA SPINNER DE CARREGAMENTO---
					helper.hideSpinner(cmp);
					//---------------------------------
					
					//helper.preencheView(cmp, event, helper)
				}
			})

			//trata excessão de erro
			.catch(function (error) {
				console.log(error)
			})
	},
    
    preencheRealizado: function(cmp, event, helper){
        
        var tipoSelecionado = helper.tipoSelecionado
        var idVendedor = helper.subTipoSelecionado
        //var subTipoSelecionado = helper.subTipoSelecionado			//DEFINE A VARIAVEL COM O SUBTIPO SELECIONADO
        //var tipoSelecionado = helper.tipoSelecionado					//DEFINE O TIPO SELECIONADO	
        
        var anoSelecionado = helper.anoSelecionado						//DEFINE A VARIAVEL DO ANO SELECIONADO
        var stringAnoSelecionado = anoSelecionado + '-01-01'			//DEFINE VARIÁVEL QUE ARMAZENA O ANO SELECIONADO
        var stringAnoLimite = anoSelecionado + '-12-31'					//DEFINE VARIÁVEL QUE ARMAZENA O ANO SELECIONADO LIMITE
        var listaPedidos = []
        
        
        if(tipoSelecionado == 'Vendedor'){
            
            
            //DEFINE A QUERY DE CONSULTA PARA METAS DO TIPO VENDEDOR
            var query = "SELECT OrderItem.Order.OrderNumber, OrderItem.Order.Mes_de_ativacao__c, OrderItem.Order.Data_de_ativacao__c, TotalPrice, Fam_lia__c, OrderItem.Order.Departamento__c, Linha__c FROM OrderItem WHERE OrderItem.Order.natureza_de_opera_o__c not in ('demonstração', 'bonificação', 'remessa de comodato', 'remessa de locação') AND OrderItem.Order.status not in ('Rascunho', 'Aguardando Aprovação Comercial', 'Aguardando Aprovação Financeira', 'Reprovado', 'Aprovado', 'Cancelado', 'Desativado', 'Pendente') and OrderItem.Order.vendedor__c = '" + idVendedor + "' AND OrderItem.Order.Data_de_ativacao__c >= " + stringAnoSelecionado + " AND OrderItem.Order.Data_de_ativacao__c <= " + stringAnoLimite + ""
            var linhas = [];
            //REALIZA A CONSULTA
            this.soql(cmp, query).then(function (pedidos) {
                //console.log(pedidos)
                var groupedPedidos = helper.groupBy(cmp, event, helper, pedidos, 'Linha__c');
                for (let key in helper.result) {
					linhas.push(key.replace('_',' '));
                }
                for (let key in groupedPedidos) {
                    if(linhas.find(v => v == key) != undefined) continue;
                    groupedPedidos['undefined'].push(...groupedPedidos[key]);
                    delete groupedPedidos[key];                    
                }
                for (let key in groupedPedidos) {
                    groupedPedidos[key] = helper.groupBy2(cmp, event, helper, groupedPedidos[key], 'Order', 'Mes_de_ativacao__c');
                    for(let key2 in groupedPedidos[key]) {
	                	groupedPedidos[key][key2] = groupedPedidos[key][key2].reduce((a,b) => a + b.TotalPrice, 0);
                        const value = helper.result[key].find(v => v.Mes__c == key2);
                        value.Realizado = groupedPedidos[key][key2];
                    }
                    groupedPedidos[key] = groupedPedidos[key].reduce((a,b) => a + b, 0);
                    const value = helper.result[key].find(v => v.Periodo__c == 'Anual');
                    value.Realizado = groupedPedidos[key];
                }
                 
                
            }).catch(function (error) {
                console.log(error)
            })
            
            query = "SELECT count(id), ownerId, calendar_year(STARTDATETIME), calendar_month(STARTDATETIME) FROM EVENT WHERE SUBJECT = 'Visita' AND OwnerId = '" + idVendedor + "' AND calendar_year(STARTDATETIME) = " + anoSelecionado + " group by ownerId, calendar_year(STARTDATETIME), calendar_month(STARTDATETIME)";
            this.soql(cmp, query).then(visita => {
                visita.forEach(value => {
                	helper.result['VISITAS'].find(v => value.expr2 == v.Mes__c).REALIZADO_VISITAS = value.expr0;                
            	});
                const value = helper.result['VISITAS'].find(v => v.Periodo__c == 'Anual');
                value.REALIZADO_VISITAS = visita.reduce((a,b) => a + b.expr0, 0)
            });
                
            query = "SELECT count(id), ownerId, calendar_year(CreatedDate), calendar_month(CreatedDate) FROM Opportunity WHERE OwnerId = '" + idVendedor + "' AND calendar_year(CreatedDate) = " + anoSelecionado + " group by ownerId, calendar_year(CreatedDate), calendar_month(CreatedDate)";
            this.soql(cmp, query).then(oportunidade => {
                oportunidade.forEach(value => {
                	helper.result['OPPS_CRIADAS'].find(v => value.expr2 == v.Mes__c).REALIZADO_OPPS_CRIADAS = value.expr0;
            	});
                const value = helper.result['OPPS_CRIADAS'].find(v => v.Periodo__c == 'Anual');
                value.REALIZADO_OPPS_CRIADAS = oportunidade.reduce((a,b) => a + b.expr0, 0)
            });
 			   
            query = "SELECT count(id), VENDEDOR__C, calendar_year(Data_da_demonstracao__c), calendar_month(Data_da_demonstracao__c) FROM ORDER WHERE Status != 'Cancelado' AND Inicio_Ativo__c != null AND RECORDTYPEID = '0126e000001pMEk' AND NATUREZA_DE_OPERA_O__C = 'DEMONSTRAÇÃO' AND Vendedor__c = '" + idVendedor + "' AND calendar_year(Data_da_demonstracao__c) = " + anoSelecionado + " group by VENDEDOR__C, calendar_year(Data_da_demonstracao__c), calendar_month(Data_da_demonstracao__c)";
            this.soql(cmp, query).then(demo => {
                demo.forEach(value => {
                	helper.result['DEMOS'].find(v => value.expr2 == v.Mes__c).REALIZADO_DEMOS = value.expr0;
            	});
                const value = helper.result['DEMOS'].find(v => v.Periodo__c == 'Anual');
                value.REALIZADO_DEMOS = demo.reduce((a,b) => a + b.expr0, 0)
            });

console.log(helper.result)            
            

            
        }
        
                        //const = 
                //console.log(helper.groupBy(cmp, event, helper, pedidos, pedidos.Linha__c))
                
//                for (let key in helper.result) {
                    
//                    helper.result[key].forEach(function(metaAtual){
//                        var tipoMeta = metaAtual.Tipo__c
                        
                        //
//                        if(tipoMeta == 'POR LINHA POR VENDEDOR'){
//                            var linha = tipoMeta.Linha__c
//                            var periodo = tipoMeta.Periodo__c
                            
//                            var pedidosPorLinhaEVendedor = pedidos.filter(v => v.hasOwnProperty("Linha__c"));
//                            var pedidosPorLinhaEVendedorAgrupado = helper.groupBy(cmp, event, helper, pedidosPorLinhaEVendedor, 'Linha__c')
                            
                            //console.log(pedidosPorLinhaEVendedorAgrupado)
                            
//                            for (let key in pedidosPorLinhaEVendedorAgrupado) {
                                
                                //console.log(pedidosPorLinhaEVendedorAgrupado[key])
                                
//                            }
                            
                            //console.log(pedidosPorLinhaEVendedorAgrupado)
                            
//                        }else{
                            
//                        }
                        //console.log(metaAtual.Tipo__c)
//                    })
                    
                      
//                }
                
                
                
                
                
                
                //PERCORRE OS PEDIDOS RESULTANTES
//                pedidos.forEach(function (pedidoAtual) {
                    
                    
                    //RECEBE O MES DO PEDIDO
//                    var mesAtual = pedidoAtual.Order.Data_de_ativacao__c.split("-")[1];
                    
                    //RECEBE O TOTAL DO MES PARA O PEDIDO
//                    var totalDoMes = pedidoAtual.TotalPrice
                    
                    //FAZ UM PUSH COM O MES ATUAL E O TOTAL DO MES
//                    listaPedidos.push({ "mes": mesAtual, "totalDoMes": totalDoMes })
//                })
                
                
                
                
                
                //O TRECHO ABAIXO É UM GROUP BY DO TOTAL VENDIDO EM CADA MÊS---
//                var result = [];
//                listaPedidos.reduce(function (res, value) {
//                    if (!res[value.mes]) {
//                        res[value.mes] = { mes: value.mes, totalDoMes: 0 };
//                        result.push(res[value.mes])
//                    }
//                    res[value.mes].totalDoMes += value.totalDoMes;
//                    return res;
//                }, {});
                //---------------------------------------------------------------
                
//                console.log(result)
                
//                for (let key in result) {
                    
//                    var tipoMeta = result[key]['TipoSomador']
//                    var tipoMetaExibido = key
                    
                    
                    
//                    console.log(tipoMeta)
//                }
                

        
        
        
        
        
        helper.preencheView(cmp, event, helper)
    },
    
    preencheView: function(cmp, event, helper){
        
        var tipoSelecionado = helper.tipoSelecionado
        
        if(tipoSelecionado == 'Vendedor'){
            
            var nomeVendedor = helper.textSubTipoSelecionado
            var imagemVendedor = helper.imagemVendedor == undefined ? "/Sales/profilephoto/005/M" : helper.imagemVendedor
            var cargo = helper.cargoVendedor == undefined ? "Cargo não cadastrado" : helper.cargoVendedor
            
            var item = "<div class='container-item' id='container-item'>\
<div class='item'>\
<div class='containerEsquerda'>\
<div class='containerImage'>\
<div class='divImagem'>\
<div style='color: #301344;; font-size: 150px; display: flex; justify-content: center; align-items: center; width: 100%; height: 100%; border-bottom-left-radius: 10px; border-top-left-radius: 10px; ' id='divImagem' data-aura-rendered-by='86:6777;a'>\
<img class='imgUserClass' src='"+imagemVendedor+"'/></div></div>\
<div class='containerNomes'>\
<div style='' id='nomePrincipal' class='valorMeta'>"+nomeVendedor+"</div>\
<div id='nomeSecundario' class='tituloMeta'>"+cargo+"</div>\
</div>\
</div>\
</div>\
<div class='containerGraficos' id='containerGraficos'>\
<div>\
<table class='table table-bordered' style='width: 1282px'>\
<thead>\
<tr>\
<th></th>\
<th></th>\
<th></th>\
<th class='tituloTabela' colspan='13'>1 TRIMESTRE</th>\
<th class='tituloTabela' colspan='13'>2 TRIMESTRE</th>\
<th class='tituloTabela' colspan='13'>3 TRIMESTRE</th>\
<th class='tituloTabela' colspan='13'>4 TRIMESTRE</th>\
</tr>\
</thead>\
<tbody id='BodyTable' class='BodyTable'>\
<tr>\
<td></td>\
<td></td>\
<td></td>\
<td class='tituloTabela' colspan='4'>JANEIRO</td>\
<td class='tituloTabela' colspan='4'>FEVEREIRO</td>\
<td class='tituloTabela' colspan='4'>MARÇO</td>\
<td class='tituloTabela' rowspan='2'>SALDO DO TRIMESTRE</td>\
<td class='tituloTabela' colspan='4'>ABRIL</td>\
<td class='tituloTabela' colspan='4'>MAIO</td>\
<td class='tituloTabela' colspan='4'>JUNHO</td>\
<td class='tituloTabela' rowspan='2'>SALDO TRIMESTRE</td>\
<td class='tituloTabela' colspan='4'>JULHO</td>\
<td class='tituloTabela' colspan='4'>AGOSTO</td>\
<td class='tituloTabela' colspan='4'>SETEMBRO</td>\
<td class='tituloTabela' rowspan='2'>SALDO TRIMESTRE</td>\
<td class='tituloTabela' colspan='4'>OUTUBRO</td>\
<td class='tituloTabela' colspan='4'>NOVEMBRO</td>\
<td class='tituloTabela' colspan='4'>DEZEMBRO</td>\
<td class='tituloTabela' rowspan='2'>SALDO TRIMESTRE</td>\
</tr>\
<tr class='topoTabela'>\
<th class='fiexedTopo'>TIPO DE META</th>\
<th class='fiexedTopo'>META ANUAL</th>\
<th class='fiexedTopo'>ATINGIDO ANUAL</th>\
<th class='fiexedTopo'>META MENSAL</th>\
<th class='fiexedTopo'>REALIZADO MENSAL</th>\
<th class='fiexedTopo'>% REALIZADO</th>\
<th class='fiexedTopo'>SALDO MENSAL</th>\
<th class='fiexedTopo'>META MENSAL</th>\
<th class='fiexedTopo'>REALIZADO MENSAL</th>\
<th class='fiexedTopo'>% REALIZADO</th>\
<th class='fiexedTopo'>SALDO MENSAL</th>\
<th class='fiexedTopo'>META MENSAL</th>\
<th class='fiexedTopo'>REALIZADO MENSAL</th>\
<th class='fiexedTopo'>% REALIZADO</th>\
<th class='fiexedTopo'>SALDO MENSAL</th>\
<th class='fiexedTopo'>META MENSAL</th>\
<th class='fiexedTopo'>REALIZADO MENSAL</th>\
<th class='fiexedTopo'>% REALIZADO</th>\
<th class='fiexedTopo'>SALDO MENSAL</th>\
<th class='fiexedTopo'>META MENSAL</th>\
<th class='fiexedTopo'>REALIZADO MENSAL</th>\
<th class='fiexedTopo'>% REALIZADO</th>\
<th class='fiexedTopo'>SALDO MENSAL</th>\
<th class='fiexedTopo'>META MENSAL</th>\
<th class='fiexedTopo'>REALIZADO MENSAL</th>\
<th class='fiexedTopo'>% REALIZADO</th>\
<th class='fiexedTopo'>SALDO MENSAL</th>\
<th class='fiexedTopo'>META MENSAL</th>\
<th class='fiexedTopo'>REALIZADO MENSAL</th>\
<th class='fiexedTopo'>% REALIZADO</th>\
<th class='fiexedTopo'>SALDO MENSAL</th>\
<th class='fiexedTopo'>META MENSAL</th>\
<th class='fiexedTopo'>REALIZADO MENSAL</th>\
<th class='fiexedTopo'>% REALIZADO</th>\
<th class='fiexedTopo'>SALDO MENSAL</th>\
<th class='fiexedTopo'>META MENSAL</th>\
<th class='fiexedTopo'>REALIZADO MENSAL</th>\
<th class='fiexedTopo'>% REALIZADO</th>\
<th class='fiexedTopo'>SALDO MENSAL</th>\
<th class='fiexedTopo'>META MENSAL</th>\
<th class='fiexedTopo'>REALIZADO MENSAL</th>\
<th class='fiexedTopo'>% REALIZADO</th>\
<th class='fiexedTopo'>SALDO MENSAL</th>\
<th class='fiexedTopo'>META MENSAL</th>\
<th class='fiexedTopo'>REALIZADO MENSAL</th>\
<th class='fiexedTopo'>% REALIZADO</th>\
<th class='fiexedTopo'>SALDO MENSAL</th>\
<th class='fiexedTopo'>META MENSAL</th>\
<th class='fiexedTopo'>REALIZADO MENSAL</th>\
<th class='fiexedTopo'>% REALIZADO</th>\
<th class='fiexedTopo'>SALDO MENSAL</th>\
</tr>\
</tbody>\
</table>\
</div>\
</div>\
</div>\
</div>";
            //LIMPA VISUALIZACAO
            $("#idChart").empty()
            $("#idChart").append(item)
            
            //PERCORRE OBJETO COM OS RESULTADOS
            for (let key in helper.result) {
                
                var metaAnual = ""//Number(itemData.metas.metaAnualGeral).toLocaleString('pt-br',{style: 'currency', currency: 'BRL'})
                //var atingidoAnual = ""//itemData.metas.vendasAno.find(v => v.ano == helper.anoSetado).atingido
                var atingidoAnualFormatado = ""// Number(atingidoAnual).toLocaleString('pt-br',{style: 'currency', currency: 'BRL'})
                
                console.log(helper.result[key])
                var tipoMeta = key
                var metaAnual = helper.result[key].find(v => v.Periodo__c == 'Anual').Meta__c;
                var atingidoAnual = helper.result[key].find(v => v.Periodo__c == 'Anual').Realizado;
                
                
                setTimeout(function() {
                    atingidoAnual = helper.result[key].find(v => v.Periodo__c == 'Anual').Realizado;
                }, 2000);
                
                
                
                //console.log(helper.result[key].find(v => v.Periodo__c == 'Anual'))
                
                var linhatabela = "\
<tr class='linhaTabela'>\
<td id='tipoMeta'>"+tipoMeta+"</td>\
<td id='metaAnual'>"+metaAnual+"</td>\
<td id='atingidoAnual'>"+atingidoAnual+"</td>\
<td id='metaMensal' data-mes='1'></td>\
<td id='realizadoMensal' data-mes='1'></td>\
<td id='porcentagem' data-mes='1'></td>\
<td class='saldoMensal' id='saldoMensal' data-mes='1'></td>\
<td id='metaMensal' data-mes='2'></td>\
<td id='realizadoMensal' data-mes='2'></td>\
<td id='porcentagem' data-mes='2'></td>\
<td class='saldoMensal' id='saldoMensal' data-mes='2'></td>\
<td id='metaMensal' data-mes='3'></td>\
<td id='realizadoMensal' data-mes='3'></td>\
<td id='porcentagem' data-mes='3'></td>\
<td class='saldoMensal' id='saldoMensal' data-mes='3'></td>\
<td id='saldoPrimeiroTrimestre'></td>\
<td id='metaMensal' data-mes='4'></td>\
<td id='realizadoMensal' data-mes='4'></td>\
<td id='porcentagem' data-mes='4'></td>\
<td class='saldoMensal' id='saldoMensal' data-mes='4'></td>\
<td id='metaMensal' data-mes='5'></td>\
<td id='realizadoMensal' data-mes='5'></td>\
<td id='porcentagem' data-mes='5'></td>\
<td class='saldoMensal' id='saldoMensal' data-mes='5'></td>\
<td id='metaMensal' data-mes='6'></td>\
<td id='realizadoMensal' data-mes='6'></td>\
<td id='porcentagem' data-mes='6'></td>\
<td class='saldoMensal' id='saldoMensal' data-mes='6'></td>\
<td id='saldoSegundoTrimestre'></td>\
<td id='metaMensal' data-mes='7'></td>\
<td id='realizadoMensal' data-mes='7'></td>\
<td id='porcentagem' data-mes='7'></td>\
<td class='saldoMensal' id='saldoMensal' data-mes='7'></td>\
<td id='metaMensal' data-mes='8'></td>\
<td id='realizadoMensal' data-mes='8'></td>\
<td id='porcentagem' data-mes='8'></td>\
<td class='saldoMensal' id='saldoMensal' data-mes='8'></td>\
<td id='metaMensal' data-mes='9'></td>\
<td id='realizadoMensal' data-mes='9'></td>\
<td id='porcentagem' data-mes='9'></td>\
<td class='saldoMensal' id='saldoMensal' data-mes='9'></td>\
<td id='saldoTerceiroTrimestre'></td>\
<td id='metaMensal' data-mes='10'></td>\
<td id='realizadoMensal' data-mes='10'></td>\
<td id='porcentagem' data-mes='10'></td>\
<td class='saldoMensal' id='saldoMensal' data-mes='10'></td>\
<td id='metaMensal' data-mes='11'></td>\
<td id='realizadoMensal' data-mes='11'></td>\
<td id='porcentagem' data-mes='11'></td>\
<td class='saldoMensal' id='saldoMensal' data-mes='11'></td>\
<td id='metaMensal' data-mes='12'></td>\
<td id='realizadoMensal' data-mes='12'></td>\
<td id='porcentagem' data-mes='12'></td>\
<td class='saldoMensal' id='saldoMensal' data-mes='12'></td>\
<td id='saldoQuartoTrimestre'></td>\
</tr>\
";
                
                $(".BodyTable").append(linhatabela)
            }
            
            
            
            
        }
    },

	preencheVisualizacao: function (cmp, event, helper, item) {
		//Exibe Spinner de carregamento
		helper.showSpinner(cmp);

		var idDaMeta = helper.metaSelecionada							//DEFINE A VARIAVEL COM O ID DA META SELECIONADA
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
					var query = "SELECT SUM(totalprice) FROM OrderItem WHERE OrderItem.Order.natureza_de_opera_o__c not in ('demonstração', 'bonificação', 'remessa de comodato', 'remessa de locação') AND OrderItem.Order.status not in ('Rascunho', 'Aguardando Aprovação Comercial', 'Aguardando Aprovação Financeira', 'Reprovado', 'Aprovado', 'Cancelado', 'Desativado', 'Pendente') and OrderItem.Order.vendedor__c = '" + idVendedor + "' AND OrderItem.Order.Data_de_ativacao__c >= " + stringAnoSelecionado + " AND OrderItem.Order.Data_de_ativacao__c <= " + stringAnoLimite + ""
					var query2 = "SELECT OrderItem.Order.OrderNumber, OrderItem.Order.Data_de_ativacao__c, TotalPrice FROM OrderItem WHERE OrderItem.Order.natureza_de_opera_o__c not in ('demonstração', 'bonificação', 'remessa de comodato', 'remessa de locação') AND OrderItem.Order.status not in ('Rascunho', 'Aguardando Aprovação Comercial', 'Aguardando Aprovação Financeira', 'Reprovado', 'Aprovado', 'Cancelado', 'Desativado', 'Pendente') and OrderItem.Order.vendedor__c = '" + idVendedor + "' AND OrderItem.Order.Data_de_ativacao__c >= " + stringAnoSelecionado + " AND OrderItem.Order.Data_de_ativacao__c <= " + stringAnoLimite + ""
				} else if (tipoSelecionado == 'Estado') {
					var query = "SELECT SUM(totalprice) FROM OrderItem WHERE OrderItem.Order.natureza_de_opera_o__c not in ('demonstração', 'bonificação', 'remessa de comodato', 'remessa de locação') AND OrderItem.Order.status not in ('Rascunho', 'Aguardando Aprovação Comercial', 'Aguardando Aprovação Financeira', 'Reprovado', 'Aprovado', 'Cancelado', 'Desativado', 'Pendente') and OrderItem.Order.BillingState = '" + subTipoSelecionado + "' AND OrderItem.Order.Data_de_ativacao__c >= " + stringAnoSelecionado + " AND OrderItem.Order.Data_de_ativacao__c <= " + stringAnoLimite + ""
					var query2 = "SELECT OrderItem.Order.OrderNumber, OrderItem.Order.Data_de_ativacao__c, TotalPrice FROM OrderItem WHERE OrderItem.Order.natureza_de_opera_o__c not in ('demonstração', 'bonificação', 'remessa de comodato', 'remessa de locação') AND OrderItem.Order.status not in ('Rascunho', 'Aguardando Aprovação Comercial', 'Aguardando Aprovação Financeira', 'Reprovado', 'Aprovado', 'Cancelado', 'Desativado', 'Pendente') and OrderItem.Order.BillingState = '" + subTipoSelecionado + "' AND OrderItem.Order.Data_de_ativacao__c >= " + stringAnoSelecionado + " AND OrderItem.Order.Data_de_ativacao__c <= " + stringAnoLimite + ""
				} else if (tipoSelecionado == 'Linha') {
					var query = "SELECT SUM(totalprice) FROM OrderItem WHERE OrderItem.Order.natureza_de_opera_o__c not in ('demonstração', 'bonificação', 'remessa de comodato', 'remessa de locação') AND OrderItem.Order.status not in ('Rascunho', 'Aguardando Aprovação Comercial', 'Aguardando Aprovação Financeira', 'Reprovado', 'Aprovado', 'Cancelado', 'Desativado', 'Pendente') and OrderItem.Product2.Linha__c = '" + subTipoSelecionado + "' AND OrderItem.Order.Data_de_ativacao__c >= " + stringAnoSelecionado + " AND OrderItem.Order.Data_de_ativacao__c <= " + stringAnoLimite + ""
					var query2 = "SELECT OrderItem.Order.OrderNumber, OrderItem.Order.Data_de_ativacao__c, TotalPrice FROM OrderItem WHERE OrderItem.Order.natureza_de_opera_o__c not in ('demonstração', 'bonificação', 'remessa de comodato', 'remessa de locação') AND OrderItem.Order.status not in ('Rascunho', 'Aguardando Aprovação Comercial', 'Aguardando Aprovação Financeira', 'Reprovado', 'Aprovado', 'Cancelado', 'Desativado', 'Pendente') and OrderItem.Product2.Linha__c = '" + subTipoSelecionado + "' AND OrderItem.Order.Data_de_ativacao__c >= " + stringAnoSelecionado + " AND OrderItem.Order.Data_de_ativacao__c <= " + stringAnoLimite + ""
				} else if (tipoSelecionado == 'Departamento') {
					console.log(subtipoClicado)
					if(subtipoClicado == 'Vendas'){
						console.log("clicou em uma meta de venda")
						//PESQUISA
						var query = "SELECT SUM(totalprice) FROM OrderItem WHERE OrderItem.Order.natureza_de_opera_o__c not in ('demonstração', 'bonificação', 'remessa de comodato', 'remessa de locação') AND OrderItem.Order.status not in ('Rascunho', 'Aguardando Aprovação Comercial', 'Aguardando Aprovação Financeira', 'Reprovado', 'Aprovado', 'Cancelado', 'Desativado', 'Pendente') AND (OrderItem.Order.Departamento3__c = 'Comercial' OR OrderItem.Order.Departamento3__c = 'GOVERNO') AND OrderItem.Order.Data_de_ativacao__c >= " + stringAnoSelecionado + " AND OrderItem.Order.Data_de_ativacao__c <= " + stringAnoLimite + ""
						var query2 = "SELECT OrderItem.Order.OrderNumber, OrderItem.Order.Data_de_ativacao__c, TotalPrice FROM OrderItem WHERE OrderItem.Order.natureza_de_opera_o__c not in ('demonstração', 'bonificação', 'remessa de comodato', 'remessa de locação') AND OrderItem.Order.status not in ('Rascunho', 'Aguardando Aprovação Comercial', 'Aguardando Aprovação Financeira', 'Reprovado', 'Aprovado', 'Cancelado', 'Desativado', 'Pendente') AND (OrderItem.Order.Departamento3__c = 'Comercial' OR OrderItem.Order.Departamento3__c = 'GOVERNO') AND OrderItem.Order.Data_de_ativacao__c >= " + stringAnoSelecionado + " AND OrderItem.Order.Data_de_ativacao__c <= " + stringAnoLimite + ""

					}else{
						console.log("clicou em uma meta comum")
						var query = "SELECT SUM(totalprice) FROM OrderItem WHERE OrderItem.Order.natureza_de_opera_o__c not in ('demonstração', 'bonificação', 'remessa de comodato', 'remessa de locação') AND OrderItem.Order.status not in ('Rascunho', 'Aguardando Aprovação Comercial', 'Aguardando Aprovação Financeira', 'Reprovado', 'Aprovado', 'Cancelado', 'Desativado', 'Pendente') and OrderItem.Order.Departamento3__c = '"+subTipoSelecionado+"' AND OrderItem.Order.Data_de_ativacao__c >= " + stringAnoSelecionado + " AND OrderItem.Order.Data_de_ativacao__c <= " + stringAnoLimite + ""
						var query2 = "SELECT OrderItem.Order.OrderNumber, OrderItem.Order.Data_de_ativacao__c, TotalPrice FROM OrderItem WHERE OrderItem.Order.natureza_de_opera_o__c not in ('demonstração', 'bonificação', 'remessa de comodato', 'remessa de locação') AND OrderItem.Order.status not in ('Rascunho', 'Aguardando Aprovação Comercial', 'Aguardando Aprovação Financeira', 'Reprovado', 'Aprovado', 'Cancelado', 'Desativado', 'Pendente') and OrderItem.Order.Departamento3__c = '" + subTipoSelecionado + "' AND OrderItem.Order.Data_de_ativacao__c >= " + stringAnoSelecionado + " AND OrderItem.Order.Data_de_ativacao__c <= " + stringAnoLimite + ""
					}
					
				} else if (tipoSelecionado == 'Geral') {
					var query = "SELECT SUM(totalprice) FROM OrderItem WHERE OrderItem.Order.natureza_de_opera_o__c not in ('demonstração', 'bonificação', 'remessa de comodato', 'remessa de locação') AND OrderItem.Order.status not in ('Rascunho', 'Aguardando Aprovação Comercial', 'Aguardando Aprovação Financeira', 'Reprovado', 'Aprovado', 'Cancelado', 'Desativado', 'Pendente') AND OrderItem.Order.Data_de_ativacao__c >= " + stringAnoSelecionado + " AND OrderItem.Order.Data_de_ativacao__c <= " + stringAnoLimite + ""
					var query2 = "SELECT OrderItem.Order.OrderNumber, OrderItem.Order.Data_de_ativacao__c, TotalPrice FROM OrderItem WHERE OrderItem.Order.natureza_de_opera_o__c not in ('demonstração', 'bonificação') AND OrderItem.Order.status not in ('Rascunho', 'Aguardando Aprovação Comercial', 'Aguardando Aprovação Financeira', 'Reprovado', 'Aprovado', 'Cancelado', 'Desativado', 'Pendente') AND OrderItem.Order.Data_de_ativacao__c >= " + stringAnoSelecionado + " AND OrderItem.Order.Data_de_ativacao__c <= " + stringAnoLimite + ""
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

								console.log(pedidos)

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
									var query = "SELECT Meta__c, Inicio__c, Final__c FROM Goal__c WHERE Inicio__c >=" + stringAnoSelecionado + " AND Inicio__c <= " + stringAnoLimite + " AND Departamento__c = null AND Vendedor__c = '" + subTipoSelecionado + "' AND Estado__c = null AND Linha__c = null"
								} else if (tipoSelecionado == 'Estado') {
									var query = "SELECT Meta__c, Inicio__c, Final__c FROM Goal__c WHERE Inicio__c >=" + stringAnoSelecionado + " AND Inicio__c <= " + stringAnoLimite + " AND Departamento__c = null AND Vendedor__r.Name = null AND Estado__c = '" + subTipoSelecionado + "' AND Linha__c = null"
								} else if (tipoSelecionado == 'Linha') {
									var query = "SELECT Meta__c, Inicio__c, Final__c FROM Goal__c WHERE Inicio__c >=" + stringAnoSelecionado + " AND Inicio__c <= " + stringAnoLimite + " AND Departamento__c = null AND Vendedor__r.Name = null AND Estado__c = null AND Linha__c = '" + subTipoSelecionado + "'"
								} else if (tipoSelecionado == 'Departamento') {
									var query = "SELECT Meta__c, Inicio__c, Final__c FROM Goal__c WHERE Inicio__c >=" + stringAnoSelecionado + " AND Inicio__c <= " + stringAnoLimite + " AND Vendedor__r.Name = null AND Estado__c = null AND Linha__c = null AND Departamento__c = '" + subTipoSelecionado + "'"
								} else if (tipoSelecionado == 'Geral') {
									var query = "SELECT Meta__c, Inicio__c, Final__c FROM Goal__c WHERE Inicio__c >=" + stringAnoSelecionado + " AND Inicio__c <= " + stringAnoLimite + " AND Departamento__c = null AND Vendedor__c = null AND Estado__c = null AND Linha__c = null"
								} else {
									console.log("nenhum tipo selecionado")
								}


								//REALIZA A CONSULTA
								helper.soql(cmp, query)

									//QUANDO A SOLICITAÇÃO FOR CONCLUÍDA, FAÇA:
									.then(function (metas) {

										metas.forEach(function (metaAtual) {
											//VERIFICA SE A META É MENSAL OU ANUAL
											if (metaAtual.Inicio__c.split("-")[1] == metaAtual.Final__c.split("-")[1]) {

												if (helper.metaSelecionada == metaAtual.Id) {
													helper.metaMesSelecionado = metaAtual.Inicio__c.split("-")[1]
												}
												var mesAtual = metaAtual.Inicio__c.split("-")[1]
												var totalDoMes = metaAtual.Meta__c
												listaMetas.push({ "mes": mesAtual, "totalDoMes": totalDoMes })
											} else {
												//SALVA A META ATUAL
												helper.metaAnual = metaAtual.Id
											}
										})

										result.forEach(e => {
											dataTeste[parseInt(e.mes) - 1] = parseInt(e.totalDoMes);
										});

										listaMetas.forEach(e => {
											dataMetaMes[parseInt(e.mes) - 1] = parseInt(e.totalDoMes);
										});

										//CASO A META FOR MENSAL, ENTRARÁ NESTE IF SOBRESCREVENDO OS DADOS DE TOTAL DA META E TOTAL ATINGIDO-----------------------------
										if (metaClicada != helper.metaAnual) {
											var valorTotalAtingido = dataTeste[parseInt(helper.metaMesSelecionado) - 1]
											var valorTotalAtingidoFormatado = new Intl.NumberFormat('id', { minimumFractionDigits: 2 }).format(valorTotalAtingido);
                                        	console.log("clicado em meta mensal: " + valorTotalAtingido)
                                        	console.log("clicado em meta mensal: " + valorTotalAtingidoFormatado)
                                            console.log(helper.listaMetas)
                                        
											$('#valorAtingido').text(valorTotalAtingidoFormatado)
											var percentualAlcancado = (valorTotalAtingido / valorTotal) * 100

											//SETA VALOR NA DIV TOTAL DA META
											$('#percentualAlcancado').text(percentualAlcancado.toFixed(1) + '%')
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