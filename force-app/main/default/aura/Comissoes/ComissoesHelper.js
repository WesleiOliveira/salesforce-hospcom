({
    comissoes: [],
    currentComissoes: [],
    gerentes: ['ULTRASSOM','ANIMALCARE'],
    showUltrassom: 'none',
    showAnimalcare: 'none',
    vendedores: [],
    gerenteSelecionado: '',
    perfilUsuario: '',
    dataAdmissaoUltrassom : '01/12/2022',
    dataAdmissaoAnimalCare : '08/05/2023',
    idGerenteUltrassom: '0056e00000Crbl9AAB',
    idGerenteAnimalCare: '0056e00000CekWUAAZ',
    
    //sort: {"orderColumn": null,"tituloColumn": null,"nomeColumn": null,"valorVendidoColumn": null,"valorRecebidoColumn": null,"dataRecebimentoColumn": null,"comissaoColumn"},
    
    //FUNÇÃO QUE EXIBE ERROS AO USUÁRIO-------------------------------------------------------------
    alertaErro: function (cmp, event, helper, error, title, type, tipoMensagem, mode) {
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
    
    
    consultaVendedores : function(cmp, event, helper){
		        
        let currentUser = $A.get("$SObjectType.CurrentUser.Id");
        const perfilUsuarioAtual = helper.perfilUsuario;
				
        var query = "SELECT Vendedor2__c, Vendedor2__r.Name, Vendedor2__r.Gestor__c FROM Recebimentos__c WHERE (Vendedor2__r.Gestor__c = '"+currentUser+"' OR Vendedor2__c = '"+currentUser+"') AND cancelado__c = false GROUP BY Vendedor2__c, Vendedor2__r.Name, Vendedor2__r.Gestor__c";
        
        console.log("USUARIO ATUAL E PERFIL", currentUser, perfilUsuarioAtual)
        
        if(perfilUsuarioAtual == "Administrador do sistema" || perfilUsuarioAtual == "Controladoria"){
            var query = "SELECT Vendedor2__c, Vendedor2__r.Name, Vendedor2__r.Gestor__c FROM Recebimentos__c WHERE cancelado__c = false GROUP BY Vendedor2__c, Vendedor2__r.Name, Vendedor2__r.Gestor__c";
        }
        
        console.log("QUERY VENDEDOR", query)
        
        helper.soql(cmp, query)
        .then(function (vendedores) {
            
            console.log("VENDEDORESssss", vendedores)
            
            var blacklist = ['Mayara Rafaela Vieira Rodrigues','Letícia Donato', 'Alberth de Oliveira','Alberth Oliveira','Allef Cavalcante Moura','Amália Moreira','Ana Carolina','Ana Clara','Ana Fagundes','André Luiz Silva','André Simão','Andressa de Moraes','Aparecida Passos','Barbara','Barbara Coelho','Caio Augusto','Camila Pereira','Carla Brevigliero','Caroline Gordiano','Celia Mara de Jesus','celso.herrera','Claudia Lettícia','Cleiton Ribeiro','Cyll Rodrigues','Danielly Braga','Daninet-Engenharia hospitalar','Deny Reyner','Edna Licorina Faria','Eduardo Silva','Eloara Borges','Erivelton Ferreira','Ernandes Martins','Felipe Brito','Felipe Cajuca','felipe.cajuca','Francielly Xavier Ferraz','Gabriel Alencar','Gabriel Coelho','Gabriel Teles Moletta','Gean Carlos','Gean Feitosa','Gerardo Marroffino','Giorge Portela','Giovanna Lima','Hospcom','Hugo Barbosa','Hugo Jr','Hugo Rocha','Jackeline Coelho','João Ferreira','João Paulo','João Pedro','Josivam Souza','Julieth Menino','Karlla Roberta Cunha Barbosa','Kassio Alves','Kauê','Klever Anderson Lima','Kleyton Farias de Souza','Leo Junio Sousa','leojuniosousa','Leticia Donato','Leticia Pereira','Leticia.donato','leticia.donato','Luanna Santos','luanna.santos','Lucas Moreira','Luciene Alencar','marcosdias','Maria Patricia','Mário Umberto Filho','Mayara','Natalia Ramos Lira liberato','Nayara Fonseca','Nayara Martins Pereira','Neiva Orchi','Odair Faccioli','Pedro Tavares','Rafael Goncalo','Railson Paz','Raniel Silva','ranniere.soares','Renan Carlos Pereira da Conceição','Renato dos Santos','Rodrigo Fonseca','Romildo José','Rosane','ROSANE SILVA','Rosivania Marinho','Simone Mariano','Tariany de Castro','Tatiane Oliveira','Tatyana Abreu','Thalyta', 'Thalyta Maciel', 'Tiago Aniceto','Venda Online','Volner Vieira','Weverton Coelho (desativado) 2'];
            
            // Filtrando e mapeando os vendedores
            var vendedoresFiltrados = vendedores
            .filter(e => e.Name != null && !blacklist.includes(e.Name))
            .sort((a, b) => a.Name.localeCompare(b.Name));
            
            // Removendo duplicatas
            vendedoresFiltrados = vendedoresFiltrados.filter((v, i, self) => 
                                                             i === self.findIndex((t) => (
                                                                 t.Name === v.Name
                                                             ))
                                                            );
            
            // Adicionando opções ao select
            vendedoresFiltrados.forEach(function(vendedor) {
                $('#vendedorFilter').append("<option value='" + vendedor.Vendedor2__c + "'>" + vendedor.Name + "</option>");
            });
            
            $("#vendedorFilter").change(function() {
                
                var vendedorId = $(this).val();
                var vendedorNome = $(this).find("option:selected").text();
                $("#periodoPagamentoFilter, #periodoMesFilter, #periodoAnoFilter, #operacaoFilter").val("default")

                helper.consultaComissoes(cmp,event, helper, vendedorId);
                helper.consultaReceber(cmp,event, helper, vendedorId);
            });
            
            //EVENTOS DE CHANGE DOS FILTROS
            $("#periodoPagamentoFilter, #vendedorFilter, #periodoMesFilter, #periodoAnoFilter, #operacaoFilter").change({cmp, event, helper}, helper.onChangeFilter);
                                                                                                            
            $("#buttonPedidoCompra").click(function(){
                                                                                                                
                helper.showSpinner(cmp)                                                                                      
                var response = [];
                var idVendedor = ""
                                                                                                                
                $('.checkBoxComissoesBody:checked:enabled').each(function() {
                    response.push({
                        recebimento: $(this).data("recebimentoid"),
                        valor: $(this).data("comissaovendedor"),
                    });
                    idVendedor = $(this).data("vendedorid");
                });

        
                console.log(response);
        		var recebimentosString = JSON.stringify(response).replaceAll("[", "").replaceAll("]", "").replaceAll("\"", "");
        
        		var action = cmp.get("c.geraPagamentos"); //DEFINE A CHAMADA DO MÉTODO APEX QUE IRÁ INSERIR O ITEM FILHO
        		console.log("ID VENDEDOR", idVendedor)
                console.log("ID recebimentos", recebimentosString)
                
                //DEFINE OS PARÂMETROS PASSADOS PARA CLASSE APEX----
                action.setParams({
                    vendedor: idVendedor,
                    recebimentos: recebimentosString,
                });        
                //--------------------------------------------------
    
                //CALLBACK DA REQUISIÇÃO---------------------------
                action.setCallback(this, function (response) {
                    var state = response.getState(); //VARIÁVEL QUE ARMAZENA O ESTADO DA REQUISIÇÃO AO MÉTODO APEX
    
                    //CASO O MÉTODO SEJA EXECUTADO COM SUCESSO
                    if (state === "SUCCESS") {
                        console.log("sucesso")
                        helper.alertaErro(cmp, event, helper, "OS RECEBIMENTOS SELECIONADOS FORAM MARCADOS COMO PAGOS!", "SUCESSO!", "success", "", "dismissable")
                        helper.hideSpinner(cmp);
                        location.reload();
                    }
                    //CASO O MÉTODO SEJA EXECUTADO DE FORMA INCOMPLETA
                    else if (state === "INCOMPLETE") {
                        //helper.alertaErro(cmp, event, helper, "ERRO DURANTE A INSERÇÃO", "INSERÇÃO IMCOMPLETA", "error", "Erro: ", "sticky") //EXIBE UM ALERTA DE INSERÇÃO INCOMPLETA AO USUÁRIO
                    } else if (state === "ERROR") {
                        var errors = response.getError();
                        if (errors && errors[0] && errors[0].message) {
                            console.log("error", errors[0].message)
                            //helper.alertaErro(cmp, event, helper, errors[0].message, "ERRO AO INSERIR PRODUTO FILHO", "error", "Erro: ", "sticky")
                            reject(errors[0].message);
                        } else {
                            console.log("Erro desconhecido");
                            //helper.alertaErro(cmp, event, helper, "ERRO DESCONHECIDO", "OCORREU UM ERRO DESCONHECIDO, VERIFIQUE OS DADOS DA CONTA DO CLIENTE", "error", "Erro: ", "sticky")
                            reject("Erro desconhecido");
                        }
                    }
                });
            	$A.enqueueAction(action);
            });
			
            helper.sortTable(helper);
            
        }).catch(function (error) {
            console.log(error)
        })
    },
    
    mainHelper : function(cmp, event, helper) {
        
        //OBTEM O ID DO USUARIO
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        //CRIA A QUERY PARA OBTER O PERFIL DO USUARIO
        var query = "SELECT id, name, Profile.name, Contact.Admissao__c FROM user where id = '"+userId+"'"
        //REALIZA A CONSULTA
        this.soql(cmp, query)
        .then(function (usuario) {
            //OBTEM O NOME DO PERFIL DO USUARIO E SETA NA VARIÁVEL GLOBAL
            helper.perfilUsuario = usuario[0].Profile.Name;
            
            //helper.dataAdmissao = usuario[0].Contact.Admissao__c;
            //CHAMA A FUNCAO PARA CONSULTAR AS COMISSOES (RECEBIMENTOS)
            //helper.consultaComissoes(cmp,event, helper);
        	//EVENTOS DE CHANGE DOS FILTROS
        	$("#periodoPagamentoFilter, #vendedorFilter, #periodoMesFilter, #periodoAnoFilter, #operacaoFilter").change({cmp, event, helper}, helper.onChangeFilter);
                                                                                                            
            $("#buttonPedidoCompra").click(function(){
                                                                                                                
                helper.showSpinner(cmp)                                                                                      
                var response = [];
                var idVendedor = ""
                                                                                                                
                $('.checkBoxComissoesBody:checked').each(function(){
                    response.push({
                        //OrderNumber: $(this).data("ordernumber"),
                        //TituloId: $(this).data("tituloid"),
                        recebimento: $(this).data("recebimentoid"),
                        valor: $(this).data("comissaovendedor"),
                    });
            		idVendedor = $(this).data("vendedorid")
                });
        
                console.log(response);
        		var recebimentosString = JSON.stringify(response).replaceAll("[", "").replaceAll("]", "").replaceAll("\"", "");
        
        		var action = cmp.get("c.geraPagamentos"); //DEFINE A CHAMADA DO MÉTODO APEX QUE IRÁ INSERIR O ITEM FILHO
        		console.log("ID VENDEDOR", idVendedor)
                console.log("ID recebimentos", recebimentosString)
                
                //DEFINE OS PARÂMETROS PASSADOS PARA CLASSE APEX----
                action.setParams({
                    vendedor: idVendedor,
                    recebimentos: recebimentosString,
                });        
                //--------------------------------------------------
    
                //CALLBACK DA REQUISIÇÃO---------------------------
                action.setCallback(this, function (response) {
                    var state = response.getState(); //VARIÁVEL QUE ARMAZENA O ESTADO DA REQUISIÇÃO AO MÉTODO APEX
    
                    //CASO O MÉTODO SEJA EXECUTADO COM SUCESSO
                    if (state === "SUCCESS") {
                        console.log("sucesso")
                        helper.alertaErro(cmp, event, helper, "OS RECEBIMENTOS SELECIONADOS FORAM MARCADOS COMO PAGOS!", "SUCESSO!", "success", "", "dismissable")
                        helper.hideSpinner(cmp);
                        location.reload();
                    }
                    //CASO O MÉTODO SEJA EXECUTADO DE FORMA INCOMPLETA
                    else if (state === "INCOMPLETE") {
                        //helper.alertaErro(cmp, event, helper, "ERRO DURANTE A INSERÇÃO", "INSERÇÃO IMCOMPLETA", "error", "Erro: ", "sticky") //EXIBE UM ALERTA DE INSERÇÃO INCOMPLETA AO USUÁRIO
                    } else if (state === "ERROR") {
                        var errors = response.getError();
                        if (errors && errors[0] && errors[0].message) {
                            console.log("error", errors[0].message)
                            //helper.alertaErro(cmp, event, helper, errors[0].message, "ERRO AO INSERIR PRODUTO FILHO", "error", "Erro: ", "sticky")
                            reject(errors[0].message);
                        } else {
                            console.log("Erro desconhecido");
                            //helper.alertaErro(cmp, event, helper, "ERRO DESCONHECIDO", "OCORREU UM ERRO DESCONHECIDO, VERIFIQUE OS DADOS DA CONTA DO CLIENTE", "error", "Erro: ", "sticky")
                            reject("Erro desconhecido");
                        }
                    }
                });
            	$A.enqueueAction(action);
            });
			
            helper.sortTable(helper);
            
        }).catch(function (error) {
            console.log(error)
        })        
	},
        
        aReceber : [],
    
    consultaReceber : function(cmp, event, helper, vendedorId){
        helper.showSpinner(cmp)                                                                                      
        
        const emptyString = " - ";
        const emptyNumber = Number.MIN_VALUE;
        const emptyDate = new Date(Date.UTC(0));
        
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        console.log("ID DO USUARIO", userId)
        
        var query = "select id, ComissaoVendedor__c, Pedido__r.OrderNumber, Pedido__c, Pedido__r.Natureza_de_Opera_o__c, Pedido__r.Nome_da_conta__c, Valor_do_recebimento__c, Valor_pago__c, numero_pedido__c, Vencimento__c, Name, Parcela__c, Vendedor_do_Pedido__c, Pedido__r.Vendedor__c from Cobranca__c where Titulo_Cancelado__c = false AND Cobranca_paga__c = false AND Pedido__r.Vendedor__c = '"+vendedorId+"'"

        console.log("query CONSULTA A RECEBER", query)
        
        this.soql(cmp, query)
        .then(function (contasAReceber) {  
            //console.log("comissoes query: ", contasAReceber)
            
            
            contasAReceber.forEach(function(comissao){
                const dateParts = comissao.Vencimento__c.split('-');
                const year = parseInt(dateParts[0]);
                const month = parseInt(dateParts[1]) - 1; // Month is zero-based
                const day = parseInt(dateParts[2]);
                
                //console.log("COMISSAO", comissao)
                
                helper.aReceber.push({
                    orderNumber: comissao.Pedido__c ? comissao.Pedido__r.OrderNumber : emptyString,
                    orderId: comissao.Pedido__c ? comissao.Pedido__c : emptyString,
                    nomeConta: (comissao.Pedido__r.Nome_da_conta__c ? comissao.Pedido__r.Nome_da_conta__c : emptyString), 
                    valorVendido: (comissao.Valor_do_recebimento__c ? comissao.Valor_do_recebimento__c : emptyNumber),
                    valorRecebido: (comissao.Valor_do_recebimento__c ? comissao.Valor_do_recebimento__c : emptyNumber),
                    dataRecebido: emptyString,
                    dataVencimento: (comissao.Vencimento__c ? new Date(comissao.Vencimento__c) : emptyString),
                    vencimentoData: comissao.Vencimento__c,
                    dataPagamento: emptyString,
                    comissaoVendedor: comissao.ComissaoVendedor__c,
                    comissaoVendedorPaga: false,
                    aliquotaVendedor: emptyNumber,
                    recebimentoId: (comissao.Id ? comissao.Id : emptyString),
                    recebimentoNumero: (comissao.Name ? comissao.Name : emptyString),
                    parcela: (comissao.Parcela__c ? comissao.Parcela__c : emptyString),
                    vendedor: (comissao.Vendedor_do_Pedido__c ? comissao.Vendedor_do_Pedido__c : emptyString),
                    vendedorId: (comissao.Pedido__r.Vendedor__c ? comissao.Pedido__r.Vendedor__c : emptyString),
                    naturezaOperacao: (comissao.Pedido__r.Natureza_de_Opera_o__c ? comissao.Pedido__r.Natureza_de_Opera_o__c : emptyString)
                });
            });
            
            //var blacklist = ['Mayara Rafaela Vieira Rodrigues','Letícia Donato', 'Leandro Mello','Alberth de Oliveira','Alberth Oliveira','Allef Cavalcante Moura','Amália Moreira','Ana Carolina','Ana Clara','Ana Fagundes','André Luiz Silva','André Simão','Andressa de Moraes','Aparecida Passos','Barbara','Barbara Coelho','Caio Augusto','Camila Pereira','Carla Brevigliero','Caroline Gordiano','Celia Mara de Jesus','celso.herrera','Claudia Lettícia','Cleiton Ribeiro','Cyll Rodrigues','Danielly Braga','Daninet-Engenharia hospitalar','Deny Reyner','Edna Licorina Faria','Eduardo Silva','Eloara Borges','Erivelton Ferreira','Ernandes Martins','Felipe Brito','Felipe Cajuca','felipe.cajuca','Francielly Xavier Ferraz','Gabriel Alencar','Gabriel Coelho','Gabriel Teles Moletta','Gean Carlos','Gean Feitosa','Gerardo Marroffino','Giorge Portela','Giovanna Lima','Hospcom','Hugo Barbosa','Hugo Jr','Hugo Rocha','Jackeline Coelho','João Ferreira','João Paulo','João Pedro','Josivam Souza','Julieth Menino','Karlla Roberta Cunha Barbosa','Kassio Alves','Kauê','Klever Anderson Lima','Kleyton Farias de Souza','Leo Junio Sousa','leojuniosousa','Leticia Donato','Leticia Pereira','Leticia.donato','leticia.donato','Luanna Santos','luanna.santos','Lucas Moreira','Luciene Alencar','marcosdias','Maria Patricia','Mário Umberto Filho','Mayara','Natalia Ramos Lira liberato','Nayara Fonseca','Nayara Martins Pereira','Neiva Orchi','Odair Faccioli','Pedro Tavares','Rafael Goncalo','Railson Paz','Raniel Silva','ranniere.soares','Renan Carlos Pereira da Conceição','Renato dos Santos','Rodrigo Fonseca','Romildo José','Rosane','ROSANE SILVA','Rosivania Marinho','Simone Mariano','Tariany de Castro','Tatiane Oliveira','Tatyana Abreu','Thales Dantas','Thalyta', 'Thalyta Maciel', 'Tiago Aniceto','Venda Online','Volner Vieira','Weverton Coelho (desativado) 2'];
            
            //helper.vendedores = helper.comissoes.filter(e => e.vendedor != null && !blacklist.includes(e.vendedor)).map(e => e.vendedor).sort((a, b) => a.localeCompare(b));
            //helper.vendedores = [...new Set(helper.vendedores)];
            
            //console.log("VENDEDORES", helper.vendedores)
            console.log("A RECEBER AQUI", helper.aReceber)
            
            //helper.vendedores.forEach((e, i) => $('#vendedorFilter').append("<option value='" + e + "'>" + e + "</option>"));
            helper.preencheAReceber(helper, helper.aReceber); 
            
        }).catch(function (error) {
            console.log(error)
        })
    },
        
    consultaComissoes : function(cmp, event, helper, vendedorId){
        helper.showSpinner(cmp)                                                                                      

        const emptyString = " - ";
        const emptyNumber = Number.MIN_VALUE;
        const emptyDate = new Date(Date.UTC(0));
        
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        console.log("ID DO USUARIO", userId)
        
        var query = "SELECT Pedido__r.Natureza_de_Opera_o__c, Valor_Documento__c, Data_de_pagamento_da_comiss_o__c, Data_do_vencimento__c, Titulo_SAP__c, Conta_Contabil__c, Data_Emissao__c, Departamento__c, Pedido__c, Pedido__r.OrderNumber, Animalcare_Comissao__c, Ultrassom_Comissao__c, Utiliza_o__c, Data_formula__c, Name, Vendedor2__r.Name, Nome_Cliente__c, Banco__c, Titulo__r.Faturamento__r.Pedido__r.OrderNumber, Titulo__r.Faturamento__r.Nome_da_conta2__r.raz_o_social__c,  Titulo__c, Titulo__r.Name, Titulo__r.Faturamento__r.Pedido__r.TotalAmount, Titulo__r.Faturamento__r.Pedido__r.Data_de_ativacao__c, Titulo__r.Faturamento__r.Pedido__r.natureza_de_opera_o__c, Valor_Pago__c, ComissaoPaga__c, Parcela__c, Gerente__c, Vendedor__c, Data_Recebimento__c, AliquotaVendedor__c, ComissaoVendedor__c FROM Recebimentos__c WHERE Vendedor2__c = '"+vendedorId+"' AND cancelado__c = false"
        console.log("query", query)

        this.soql(cmp, query)
        .then(function (comissoes) {  
            //console.log("comissoes query: ", comissoes)
            
            comissoes.forEach(function(comissao){
                const dateParts = comissao.Data_formula__c.split('-');
                const year = parseInt(dateParts[0]);
                const month = parseInt(dateParts[1]) - 1; // Month is zero-based
                const day = parseInt(dateParts[2]);
                                           
                //console.log("COMISSAO", comissao)
                
                helper.comissoes.push({
                    orderNumber: comissao.Pedido__c ? comissao.Pedido__r.OrderNumber : (comissao.Titulo__r ? (comissao.Titulo__r.Faturamento__r ? (comissao.Titulo__r.Faturamento__r.Pedido__r ? (comissao.Titulo__r.Faturamento__r.Pedido__r.OrderNumber ? comissao.Titulo__r.Faturamento__r.Pedido__r.OrderNumber : emptyString) : emptyString) : emptyString) : emptyString),
                    orderId: comissao.Pedido__c ? comissao.Pedido__c : (comissao.Titulo__r ? (comissao.Titulo__r.Faturamento__r ? (comissao.Titulo__r.Faturamento__r.Pedido__r ? (comissao.Titulo__r.Faturamento__r.Pedido__r.Id ? comissao.Titulo__r.Faturamento__r.Pedido__r.Id : emptyString) : emptyString) : emptyString) : emptyString),
                    tituloId: (comissao.Titulo__r ? (comissao.Titulo__r.Id ? comissao.Titulo__r.Id : emptyString) : emptyString),
                    tituloName: (comissao.Titulo_SAP__c ? comissao.Titulo_SAP__c : emptyString),
                    nomeConta: (comissao.Nome_Cliente__c ? comissao.Nome_Cliente__c : emptyString), //? (comissao.Titulo__r.Faturamento__r ? (comissao.Titulo__r.Faturamento__r.Nome_da_Conta2__r ? (comissao.Titulo__r.Faturamento__r.Nome_da_Conta2__r.Raz_o_Social__c ? comissao.Titulo__r.Faturamento__r.Nome_da_Conta2__r.Raz_o_Social__c : emptyString) : emptyString) : emptyString) : emptyString),
                    valorVendido: (comissao.Valor_Documento__c ? comissao.Valor_Documento__c : emptyNumber),
                    valorRecebido: (comissao.Valor_Pago__c ? comissao.Valor_Pago__c : emptyNumber),
                    contaContabil : (comissao.Conta_Contabil__c ? comissao.Conta_Contabil__c : emptyString),
                    dataRecebido: (comissao.Data_formula__c ? new Date(year, month, day) : emptyString),
                    dataVencimento: (comissao.Data_do_vencimento__c ? new Date(comissao.Data_do_vencimento__c) : emptyString),
                    dataPagamento: (comissao.Data_de_pagamento_da_comiss_o__c ? comissao.Data_de_pagamento_da_comiss_o__c : emptyString),
                    departamento: (comissao.Departamento__c ? comissao.Departamento__c : emptyString),
                    comissaoVendedor: (comissao.ComissaoVendedor__c ? comissao.ComissaoVendedor__c : emptyNumber),
                    comissaoVendedorPaga: (comissao.ComissaoPaga__c ? comissao.ComissaoPaga__c : false),
					aliquotaVendedor: comissao.AliquotaVendedor__c != null ? parseFloat(comissao.AliquotaVendedor__c).toFixed(2) : emptyNumber.toFixed(2),
                    recebimentoId: (comissao.Id ? comissao.Id : emptyString),
                    recebimentoNumero: (comissao.Name ? comissao.Name : emptyString),
                    parcela: (comissao.Parcela__c ? comissao.Parcela__c : emptyString),
                    vendedor: (comissao.Vendedor2__r ? comissao.Vendedor2__r.Name : emptyString),
                    vendedorId: (comissao.Vendedor2__r ? comissao.Vendedor2__r.Id : emptyString),
                    gerente: (comissao.Gerente__c ? comissao.Gerente__c : emptyString),
                    utilizacao: (comissao.Utiliza_o__c ? comissao.Utiliza_o__c : emptyString),
                    banco: (comissao.Banco__c ? comissao.Banco__c : emptyString),
                    naturezaOperacao: (comissao.Pedido__r.Natureza_de_Opera_o__c ? comissao.Pedido__r.Natureza_de_Opera_o__c : emptyString)
                });
            });
            
            //var blacklist = ['Mayara Rafaela Vieira Rodrigues','Letícia Donato', 'Leandro Mello','Alberth de Oliveira','Alberth Oliveira','Allef Cavalcante Moura','Amália Moreira','Ana Carolina','Ana Clara','Ana Fagundes','André Luiz Silva','André Simão','Andressa de Moraes','Aparecida Passos','Barbara','Barbara Coelho','Caio Augusto','Camila Pereira','Carla Brevigliero','Caroline Gordiano','Celia Mara de Jesus','celso.herrera','Claudia Lettícia','Cleiton Ribeiro','Cyll Rodrigues','Danielly Braga','Daninet-Engenharia hospitalar','Deny Reyner','Edna Licorina Faria','Eduardo Silva','Eloara Borges','Erivelton Ferreira','Ernandes Martins','Felipe Brito','Felipe Cajuca','felipe.cajuca','Francielly Xavier Ferraz','Gabriel Alencar','Gabriel Coelho','Gabriel Teles Moletta','Gean Carlos','Gean Feitosa','Gerardo Marroffino','Giorge Portela','Giovanna Lima','Hospcom','Hugo Barbosa','Hugo Jr','Hugo Rocha','Jackeline Coelho','João Ferreira','João Paulo','João Pedro','Josivam Souza','Julieth Menino','Karlla Roberta Cunha Barbosa','Kassio Alves','Kauê','Klever Anderson Lima','Kleyton Farias de Souza','Leo Junio Sousa','leojuniosousa','Leticia Donato','Leticia Pereira','Leticia.donato','leticia.donato','Luanna Santos','luanna.santos','Lucas Moreira','Luciene Alencar','marcosdias','Maria Patricia','Mário Umberto Filho','Mayara','Natalia Ramos Lira liberato','Nayara Fonseca','Nayara Martins Pereira','Neiva Orchi','Odair Faccioli','Pedro Tavares','Rafael Goncalo','Railson Paz','Raniel Silva','ranniere.soares','Renan Carlos Pereira da Conceição','Renato dos Santos','Rodrigo Fonseca','Romildo José','Rosane','ROSANE SILVA','Rosivania Marinho','Simone Mariano','Tariany de Castro','Tatiane Oliveira','Tatyana Abreu','Thales Dantas','Thalyta', 'Thalyta Maciel', 'Tiago Aniceto','Venda Online','Volner Vieira','Weverton Coelho (desativado) 2'];
            
            //helper.vendedores = helper.comissoes.filter(e => e.vendedor != null && !blacklist.includes(e.vendedor)).map(e => e.vendedor).sort((a, b) => a.localeCompare(b));
            //helper.vendedores = [...new Set(helper.vendedores)];
			
            //console.log("VENDEDORES", helper.vendedores)
            //console.log("COMISSOES", helper.comissoes)
            
            //helper.vendedores.forEach((e, i) => $('#vendedorFilter').append("<option value='" + e + "'>" + e + "</option>"));
            helper.preencheComissoes(helper, helper.comissoes);

        }).catch(function (error) {
            console.log(error)
        })
    },
        
        preencheAReceber : function(helper, comissoes){
            
            console.log("PREENCHE A RECEBER", comissoes)
            
            const formatReal = new Intl.NumberFormat('pt-BR', {style: 'currency', currency: 'BRL'});
            const formatDate = {day: 'numeric', month: 'numeric', year: 'numeric'};
            const salesUrl = "https://hospcomhospitalar.force.com/Sales/";
            var html = ''
            
            comissoes.forEach(function(comissao){
                //console.log("comissao preenchendo", comissao)
                
                var numeroPedido = comissao.orderNumber;
                var parcela = comissao.parcela;
                var valor = formatReal.format(comissao.valorRecebido);
                var idPedido = comissao.orderId;
                var valorComissao = formatReal.format(comissao.comissaoVendedor); // <- nome diferente
                var vencimento = new Date(comissao.dataVencimento).toLocaleDateString("pt-BR", formatDate);
                var pedidoUrl = salesUrl + idPedido;
                
                //new Date(comissao.dataVencimento).toLocaleDateString("pt-BR", formatDate)
                
                var tempHtml = "<div class='itemPendente'>\
                <div class='textItemPendente43'><a href='"+pedidoUrl+"'>"+numeroPedido+"</a></div>\
                <div class='textItemPendente43'>"+parcela+"</div>\
                <div class='textItemPendente43'>"+valor+"</div>\
                <div class='textItemPendente43'>"+valorComissao+"</div>\
                <div class='textItemPendente43'>"+vencimento+"</div>\
                </div>";
                
                html += tempHtml;              
            });
            
            $("#containerPendentes").empty().append(html)
            
            //$("#totalView").html("TOTAL: " + formatReal.format(totalComissoesView))
            //console.log(totalComissoesView)
            //$('#spinnerDiv').css("display", "none");
            
            helper.onClickCheckBox(); 
        },
	    
    preencheComissoes : function(helper, comissoes){
        $("#tbodyComissoes tr").remove();
		helper.currentComissoes = comissoes;
        const emptyString = " - ";
        const emptyNumber = Number.MIN_VALUE;
        const emptyDate = new Date(Date.UTC(0));
        const salesUrl = "https://hospcomhospitalar.force.com/Sales/";
        const formatReal = new Intl.NumberFormat('pt-BR', {style: 'currency', currency: 'BRL'});
        const formatDate = {day: 'numeric', month: 'numeric', year: 'numeric'};
        var totalComissoesView = 0
        
        comissoes.forEach(function(comissao){
            
            totalComissoesView = totalComissoesView + comissao.comissaoVendedor;
                        
            var orderAnchor = "<a target='_blank' href='" + salesUrl + comissao.orderId + "'>" + comissao.orderNumber + "</a>";
            var recebimentoAnchor = "<a target='_blank' href='" + salesUrl + comissao.recebimentoId + "'>" + comissao.recebimentoNumero + "</a>";
            //var tituloAnchor = "<a href='" + salesUrl + comissao.tituloId + "'>" + comissao.tituloNome + "</a>";
            
            var element =  "<tr id='valorComissao' data-comissao = '"+(comissao.comissaoVendedor === emptyNumber ? emptyString : comissao.comissaoVendedor)+"'>";
            element += "<th scope='row'><input " + (comissao.comissaoVendedorPaga ? 'checked disabled="true" title="Pago"' : '') + "data-vendedorId='"+comissao.vendedorId+"' data-comissaoVendedor='"+comissao.comissaoVendedor+"' data-recebimentoid='" + comissao.recebimentoId  + "' data-tituloid='" + (comissao.tituloId ?  'null' : comissoes.tituloId) + "' data-ordernumber='" + (comissoes.orderNumber ? 'null' : comissoes.orderNumber) + "' class='form-check-input checkBoxComissoesBody' type='checkbox'></input></th>";
            element += "<td>" + (comissao.orderId === emptyString ? emptyString : orderAnchor) + "</td>";
            element += "<td>" + (comissao.recebimentoId === emptyString ? emptyString : recebimentoAnchor) + "</td>";
            //element += "<td>" + (comissao.tituloName === emptyString ? emptyString : comissao.tituloName) + "</td>";
            element += "<td>" + (comissao.parcela === emptyString ? emptyString : comissao.parcela) + "</td>";
            //element += "<td>" + (comissao.contaContabil === emptyString ? emptyString : comissao.contaContabil) + "</td>";
            element += "<td>" + (comissao.naturezaOperacao === emptyString ? emptyString : comissao.naturezaOperacao) + "</td>";
            //element += "<td>" + (comissao.utilizacao === emptyString ? emptyString : comissao.utilizacao) + "</td>";
            element += "<td>" + (comissao.nomeConta === emptyString ? emptyString : comissao.nomeConta) + "</td>";
            element += "<td>" + (comissao.valorVendido === emptyNumber ? emptyString : formatReal.format(comissao.valorVendido)) + "</td>";
            element += "<td>" + (comissao.valorRecebido === emptyNumber ? emptyString : formatReal.format(comissao.valorRecebido)) + "</td>";
            element += "<td>" + (comissao.dataRecebido.getTime() === emptyDate.getTime() ? emptyString : new Date(comissao.dataRecebido).toLocaleDateString("pt-BR", formatDate)) + "</td>";
            element += "<td>" + (comissao.dataVencimento === emptyString ? emptyString : new Date(comissao.dataVencimento).toLocaleDateString("pt-BR", formatDate)) + "</td>";
            element += "<td>" + (comissao.aliquotaVendedor === emptyNumber ? emptyString : comissao.aliquotaVendedor + '%') + "</td>";
            element += "<td>" + (comissao.comissaoVendedor === emptyNumber ? emptyString : formatReal.format(comissao.comissaoVendedor)) + "</td>";
            //element += "<td>" + (comissao.banco === emptyString ? emptyString : comissao.banco) + "</td>";
            element += "</tr>";
            
			$("#tbodyComissoes").append(element);
        });
		
        $("#totalView").html("TOTAL: " + formatReal.format(totalComissoesView))
        //console.log(totalComissoesView)
        $('#spinnerDiv').css("display", "none");

        helper.onClickCheckBox();      
    },
    
    onChangeFilter : function(event){
        //Exibe Spinner de carregamento
        //$('#spinnerDiv').css("display", "flex");
        
        console.log("entrou change")
        
        const vendedorSelected = $("#vendedorFilter option:selected").text();
        const periodoMesSelected = $("#periodoMesFilter").val();
        const periodoAnoSelected = $("#periodoAnoFilter").val();
        const operacaoSelected = $("#operacaoFilter").val();
        const periodoMesPagamentoSelected = $("#periodoPagamentoFilter").val();
        var comissoes = event.data.helper.comissoes;
        var aReceber = event.data.helper.aReceber;
        
        console.log("periodo ano", periodoAnoSelected)
          
        //FILTRO VENDEDOR SELECIONADO
        if(vendedorSelected) comissoes = comissoes.filter( e => e.vendedor === vendedorSelected);
        
        //FILTRO OPERAÇÃO SELECIONADA
        if(operacaoSelected) comissoes = comissoes.filter( e => e.naturezaOperacao === operacaoSelected);
        
        //FILTRO ANO E MES SELECIONADO
        if(periodoMesSelected && periodoAnoSelected && periodoMesSelected != 'default'){
            //alert("Exibindo recebimentos de 26/" + (periodoMesSelected - 1) + "/" + periodoAnoSelected + " a 25/" + (periodoMesSelected) + "/" + periodoAnoSelected)
            comissoes = comissoes.filter( e => new Date(e.dataRecebido.getTime()) >= new Date(periodoAnoSelected, periodoMesSelected - 2, 26).getTime() && new Date(e.dataRecebido.getTime()) <= new Date(periodoAnoSelected, periodoMesSelected - 1, 25).getTime());
            aReceber = aReceber.filter( e => new Date(e.dataVencimento.getTime()) >= new Date(periodoAnoSelected, periodoMesSelected - 2, 26).getTime() && new Date(e.dataVencimento.getTime()) <= new Date(periodoAnoSelected, periodoMesSelected - 1, 25).getTime());
        }
        
        //FILTRO PERIODO DE PAGAMENTO
        if(periodoMesPagamentoSelected && periodoAnoSelected && periodoMesPagamentoSelected != 'default'){
            console.log("filtro periodo pagamento")
            comissoes = comissoes.filter(e => e.dataPagamento.split("-")[1] == periodoMesPagamentoSelected);
        }
        
        console.log("comissoes change filter", comissoes)
        event.data.helper.preencheComissoes(event.data.helper, comissoes);
        event.data.helper.preencheAReceber(event.data.helper, aReceber);
	},
        
    onClickCheckBox : function(){
        $("#checkBoxComissoesHead").prop('checked', false);
        $("#divButtonsComissao").css("display", 'none');
        
        $("#checkBoxComissoesHead").change(function() {
            $(".checkBoxComissoesBody:enabled").prop("checked",this.checked);
            $("#divButtonsComissao").css("display", $('.checkBoxComissoesBody:checked').length > 0 ? 'flex' : 'none');
        });
        $('.checkBoxComissoesBody').change(function() {
            $('#checkBoxComissoesHead').prop('checked',$('.checkBoxComissoesBody:checked:enabled').length == $('.checkBoxComissoesBody:enabled').length);
            $("#divButtonsComissao").css("display", $('.checkBoxComissoesBody:checked').length > 0 ? 'flex' : 'none');
        });
    },
        
    sortTable : function(helper){
        $("#orderColumn").click(function(){
            var isOrder = true;
            var data = helper.currentComissoes;
            data.sort(function(a, b){
                var compare = a.orderNumber.localeCompare(b.orderNumber);
                if(isOrder && compare == -1) isOrder = false;
                return compare;
            });
            if(isOrder) data.sort((a,b) => b.orderNumber.localeCompare(a.orderNumber));
            helper.preencheComissoes(helper, data, '');
        });
        $("#tituloColumn").click(function(){
            var isOrder = true;
            var data = helper.currentComissoes;
            data.sort(function(a, b){
                var compare = a.tituloNome - b.tituloNome;
                if(isOrder && compare == -1) isOrder = false;
                return compare;
            });
            if(isOrder) data.sort((a,b) => b.tituloNome - a.tituloNome);
            helper.preencheComissoes(helper, data, '');
        });
        $("#parcelaColumn").click(function(){
            var isOrder = true;
            var data = helper.currentComissoes;
            data.sort(function(a, b){
                var compare = a.parcela.localeCompare(b.parcela)
                if(isOrder && compare == -1) isOrder = false;
                return compare;
            });
            if(isOrder) data.sort((a,b) => b.parcela.localeCompare(a.parcela));
            helper.preencheComissoes(helper, data, '');
        });        
        $("#nomeColumn").click(function(){
            var isOrder = true;
            var data = helper.currentComissoes;
            data.sort(function(a, b){
                var compare = a.nomeConta.localeCompare(b.nomeConta);
                if(isOrder && compare == -1) isOrder = false;
                return compare;
            });
            if(isOrder) data.sort((a,b) => b.nomeConta.localeCompare(a.nomeConta));
            helper.preencheComissoes(helper, data, '');
        });
        $("#valorVendidoColumn").click(function(){
            var isOrder = true;
            var data = helper.currentComissoes;
            data.sort(function(a, b){
                var compare = a.valorVendido - b.valorVendido;
                if(isOrder && compare < 0) isOrder = false;
                return compare;
            });
            if(isOrder) data.sort((a,b) => b.valorVendido - a.valorVendido);
            helper.preencheComissoes(helper, data, '');
        });
        $("#valorRecebidoColumn").click(function(){
            var isOrder = true;
            var data = helper.currentComissoes;
            data.sort(function(a, b){
                var compare = a.valorRecebido - b.valorRecebido;
                if(isOrder && compare < 0) isOrder = false;
                return compare;
            });
            if(isOrder) data.sort((a,b) => b.valorRecebido - a.valorRecebido);
            helper.preencheComissoes(helper, data, '');
        });
        $("#dataRecebimentoColumn").click(function(){
            var isOrder = true;
            var data = helper.currentComissoes;
            data.sort(function(a, b){
                var compare = a.dataRecebido.getTime() - b.dataRecebido.getTime();
                if(isOrder && compare < 0) isOrder = false;
                return compare;
            });
            if(isOrder) data.sort((a,b) => b.dataRecebido.getTime() - a.dataRecebido.getTime());
            helper.preencheComissoes(helper, data, '');
        });
        $("#comissaoColumn").click(function(){
            var isOrder = true;
            var data = helper.currentComissoes;
            data.sort(function(a, b){
                var compare = a.comissaoVendedor - b.comissaoVendedor;
                if(isOrder && compare < 0) isOrder = false;
                return compare;
            });
            if(isOrder) data.sort((a,b) => b.comissaoVendedor - a.comissaoVendedor);
            helper.preencheComissoes(helper, data, '');
        });
    },
})