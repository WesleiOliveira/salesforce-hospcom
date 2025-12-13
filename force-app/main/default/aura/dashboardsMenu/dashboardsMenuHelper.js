({
    departamentosAtivos : [],
    linhasAtivas : [],
    regioesAtivas: [],
    performanceAtivas : [],
    selectpickerIsClicked : false,
    todosDepartamentos : ['Comercial',  'Compras', 'Desenvolvimento', 'Diretoria','Financeiro', 'Governo', 'Jurídico' , 'Locação', 'Logística', 'Marketing', 'Qualidade', 'RH', 'Serviço', 'SKA', 'T.I'],
    todasLinhas : ['Camas Hospitalares', 'CMI', 'Eletrocirurgia', 'Endoscopia','Monitores de Grau Médico', 'OPME Zimmer', 'Ortopedia', 'PM' ,'PMLS', 'Raio X', 'Surgical', 'Ultrassom', 'Veterinária', 'Veterinária IVD', 'Veterinária MIS', 'Veterinária PMLS','Vias Aéreas Difíceis', 'Robótica'],
    todasPerformance : ['Performance'],
    todasRegioes : ['GO/TO', 'MT/MS', 'SP', 'DF', 'Norte', 'RJ/ES/SUL', 'COLÔMBIA'],
    variacaoSetada : "",
    
    //ARRAY COM A ORDENACAO DAS VARIACOES
    //CASO UMA VARIACAO NAO ESTEJA PREENCHIDA NESTE ARRAY, A MESMA É EXIBIDA NO FINAL DA LISTA
    ordens: [
        "Região GO/TO - Performance Geral",
        "Região GO/TO - Qualidade",
        "Região GO/TO - Base Instalada",
        "Região GO/TO - Vendedores",
        "Região GO/TO - Linhas",
        "Região GO/TO - Contas a receber",
        "Região Norte - Performance Geral",
        "Região Norte - Qualidade",
        "Região Norte - Base Instalada",
        "Região Norte - Vendedores",
        "Região Norte - Linhas",
        "Região Norte - Contas a receber",
        "Região SP - Performance Geral",
        "Região SP - Qualidade",
        "Região SP - Base Instalada",
        "Região SP - Vendedores",
        "Região SP - Linhas",
        "Região SP - Contas a receber",
        "Região DF - Performance Geral",
        "Região DF - Qualidade",
        "Região DF - Base Instalada",
        "Região DF - Vendedores",
        "Região DF - Linhas",
        "Região DF - Contas a receber",
        "Região RJ/ES/SUL - Performance Geral",
        "Região RJ/ES/SUL - Qualidade",
        "Região RJ/ES/SUL - Base Instalada",
        "Região RJ/ES/SUL - Vendedores",
        "Região RJ/ES/SUL - Linhas",
        "Região RJ/ES/SUL - Contas a receber",
        "Governo - Performance Geral",
        "Governo - Qualidade",
        "PMLS - Performance Geral",
        "PMLS - Monitorização - Performance",
        "PMLS - Anestesia - Performance",
        "PMLS - Ventilação - Performance",
        "PMLS - Desfibrilador - Performance",
        "PMLS - Eletrocardiógrafos - Performance",
        "PMLS - Infusão - Performance",
        "PMLS - Qualidade",
        "PMLS - Base Instalada",
        "PMLS - Vendedores",
        "PMLS - Locação",
        "Surgical - Performance Geral",
        "Surgical - CMI - Performance",
        "Surgical - Uro e Gineco - Performance",
        "Surgical - Eletrocirurgia - Performance",
        "Surgical - Suporte Cirúrgico - Performance",
        "Surgical - Qualidade",
        "Surgical - Base Instalada",
        "Surgical - Vendedores",
        "Surgical - Locação",
        "Logística - Performance",
        "Logística - Performance Itens",
        "Logística - Qualidade",
        "Logística - Lead Time",
		"Serviço - Performance Geral",        
		"Serviço - Performance Pedidos",        
		"Serviço - Performance OT",        
		"Serviço - Performance Técnicos",        
		"Ortopedia - Performance Geral (Zimmer)",        
		"Ortopedia - Qualidade (Zimmer)",        
		"Ortopedia - Performance Geral (Baumer)",        
		"Ortopedia - Qualidade (Baumer)",
		"Ortopedia - Performance Instrumentadores",
		"Ortopedia - Vendedores",
		"Ortopedia - Forecast",
		"Compras - Revenda - Performance",
		"Compras - Revenda - Qualidade",
		"Compras - Consumo - Performance",
		"Locação - Performance",
		"Locação - Qualidade",
		"Locação - Demo e Empréstimo",
		"Locação - Comodato",
		"Locação - DEA",
		"Locação - VET",		        
		"Ultrassom - Performance Geral",		        
		"Ultrassom - Qualidade",		        
		"Ultrassom - Base Instalada",		        
		"Ultrassom - Vendedores",		        
		"Ultrassom - Locação",
        "Qualidade - Documentação Paralegal"
    ],
    
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
    
    //FUNÇÃO QUE EXIBE ERROS AO USUÁRIO-------------------------------------------------------------
    alertaErro: function (cmp, event, helper, title, conteudoAlerta, type, mode) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": conteudoAlerta,
            "type": type,
            "mode": mode
        });
        toastEvent.fire();
    },
    //----------------------------------------------------------------------------------------------   
    
    mainFunction : function(cmp, event, helper) {
        //console.log("helper function")   
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        helper.consultaUsuario(cmp, event, helper, userId)
    },
    
    consultaUsuario : function(cmp, event, helper, userId) {
        
        //CONSULTA AS VARIAÇÕES DO USUARIO
        var query = "SELECT Variacoes__c, Variacao__c from user where id = '"+userId+"'"
        
        //REALIZA A CONSULTA
        this.soql(cmp, query)
        
        //QUANDO A SOLICITAÇÃO FOR CONCLUÍDA, FAÇA:
        .then(function (usuario) {
            
            //recupera todas as variacoes habilitadas do usuário
            var variacoes = usuario[0].Variacoes__c.split(";");
            
            //recupera a variacao atual do usuário
            helper.variacaoSetada = usuario[0].Variacao__c;
            
            if(!helper.variacaoSetada){
                helper.alertaErro(cmp, event, helper, "Atenção!", "Nenhuma variação padrão ainda foi definida no seu usuário. Navegue entre os itens do Menu de Dashboards abaixo.", "Alert", "Sticky")
            }
            
            //PERCORRE TODAS OS DEPARTAMENTOS
            helper.todosDepartamentos.forEach(function(variacaoAtual){
                var departamentosEncontrados = variacoes.filter(item => item.split(" - ")[0].includes(variacaoAtual));
                helper.departamentosAtivos.push(...departamentosEncontrados);                
            })
            if(helper.departamentosAtivos.length > 0){
                if(helper.departamentosAtivos.includes(helper.variacaoSetada)){
                    var selectedDepartamento = "selected = 'true'";
                    $("#tiposRelatorio").append("<option name='DEPARTAMENTO' "+selectedDepartamento+" value='DEPARTAMENTO'>DEPARTAMENTO</option>")
                	helper.preencheSubtipos(cmp, event, helper, "DEPARTAMENTO");
                }else{
                    var selectedDepartamento = "";
                    $("#tiposRelatorio").append("<option name='DEPARTAMENTO' "+selectedDepartamento+" value='DEPARTAMENTO'>DEPARTAMENTO</option>")
                }
                
            }
            //----------------------------------------
            
            
            //PERCORRE TODAS AS LINHAS
            helper.todasLinhas.forEach(function(variacaoAtual){
                var linhasEncontradas = variacoes.filter(item => item.split(" - ")[0].includes(variacaoAtual));
                helper.linhasAtivas.push(...linhasEncontradas);                
            })
            if(helper.linhasAtivas.length > 0){
                if(helper.linhasAtivas.includes(helper.variacaoSetada)){
                    //console.log("ENCONTRADO EM LINHA", variacaoSetada)
                    var selectedLinha = "selected = 'true'";
                    $("#tiposRelatorio").append("<option name='LINHA' "+selectedLinha+" value='LINHA'>LINHA</option>")
                    helper.preencheSubtipos(cmp, event, helper, "LINHA");
                }else{
                    //console.log("NAO ENCONTRADO EM LINHA", variacaoSetada)
                    var selectedLinha = "";
                    $("#tiposRelatorio").append("<option name='LINHA' "+selectedLinha+" value='LINHA'>LINHA</option>")
                }
                
            }
            //----------------------------------------
            
            //PERCORRE TODAS AS PERFORMANCE
            helper.todasPerformance.forEach(function(variacaoAtual){
                var performanceEncontradas = variacoes.filter(item => item.split(" - ")[0].includes(variacaoAtual));
                helper.performanceAtivas.push(...performanceEncontradas);                
            })
            if(helper.performanceAtivas.length > 0){
                if(helper.performanceAtivas.includes(helper.variacaoSetada)){
                    //console.log("ENCONTRADO EM LINHA", variacaoSetada)
                    var selectedPerformance = "selected = 'true'";
                    $("#tiposRelatorio").append("<option name='PERFORMANCE' "+selectedPerformance+" value='PERFORMANCE'>PERFORMANCE</option>")
                    helper.preencheSubtipos(cmp, event, helper, "PERFORMANCE");
                }else{
                    //console.log("NAO ENCONTRADO EM LINHA", variacaoSetada)
                    var selectedPerformance = "";
                    $("#tiposRelatorio").append("<option name='PERFORMANCE' "+selectedPerformance+" value='PERFORMANCE'>PERFORMANCE</option>")
                }
                
            }
            //----------------------------------------
            
            //PERCORRE TODAS AS LINHAS
            helper.todasRegioes.forEach(function(variacaoAtual){
                var regioesEncontradas = variacoes.filter(item => item.split(" - ")[0].includes(variacaoAtual));
                helper.regioesAtivas.push(...regioesEncontradas);                
            })
            if(helper.regioesAtivas.length > 0){
                if(helper.regioesAtivas.includes(helper.variacaoSetada)){
                    //console.log("ENCONTRADO EM LINHA", variacaoSetada)
                    var selectedRegiao = "selected = 'true'";
                    $("#tiposRelatorio").append("<option name='REGIÃO' "+selectedRegiao+" value='REGIÃO'>REGIÃO</option>")
                    helper.preencheSubtipos(cmp, event, helper, "REGIÃO");
                }else{
                    //console.log("NAO ENCONTRADO EM LINHA", variacaoSetada)
                    var selectedRegiao = "";
                    $("#tiposRelatorio").append("<option name='REGIÃO' "+selectedRegiao+" value='REGIÃO'>REGIÃO</option>")
                }
                
            }
            //-------------------------
            
            console.log("-------------------------------------LOG DE DEPURAÇÃO----------------------------------------------")
            console.log("DEPARTAMENTOS ATIVOS: ", helper.departamentosAtivos)
            console.log("LINHAS ATIVAS: ", helper.linhasAtivas)
            console.log("PERFORMANCE ATIVAS: ", helper.performanceAtivas)
            console.log("REGIOES ATIVAS: ", helper.regioesAtivas)
            console.log("TODAS VARIACOES: ", variacoes)
            
            helper.eventsAfterConsultaUser(cmp, event, helper);
            
        })
        
        //trata excessão de erro
        .catch(function (error) {
            console.log(error)
        })
    },
    
    eventsAfterConsultaUser : function(cmp, event, helper){
        
        $('.selectpickerTipo').selectpicker({
            dropupAuto: false  
        });
         
        //EVENTO DO CHANGE DOS FILTROS
        $('.selectpickerTipo').on('changed.bs.select', function (e) {
            var tipoSelecionado = $('#tiposRelatorio').val();
            helper.preencheSubtipos(cmp, event, helper, tipoSelecionado);
        });
        
        // when the dialog is closed....
        $('.selectpickerTipo').on('hide.bs.selectpickerTipo', function (e) {
            if (helper.selectpickerIsClicked) {
                e.preventDefault();
                selectpickerIsClicked = false;
            }
        });
    },
    
    preencheSubtipos : function(cmp, event, helper, tipoSelecionado){
        console.log("preenchendo subtipos", tipoSelecionado)
        
        //SWITCH CASE NO TIPO SELECIONADO
        switch(tipoSelecionado) {
            case "DEPARTAMENTO":
                var tipoAtivo = helper.departamentosAtivos;
                break;
            case "LINHA":
                var tipoAtivo = helper.linhasAtivas;
                break;
            case "REGIÃO":
                var tipoAtivo = helper.regioesAtivas;
                break;
            case "PERFORMANCE":
                var tipoAtivo = helper.performanceAtivas;
                break;
            default:
                console.log("default error switch case")
        }
        
        //variáveis do subtipo e de controle
        var subtipo = [];
        var uniqueMap = {};
        
        //cria um array com os subtipos
        //os subtipos aqui definidos sao a primeira parte das variacoes, delimitadas pelo divisor "-". Repetiçoes também sao excluidos
        tipoAtivo.forEach(function(element) {
            var key = element.split(" - ")[0];
            if (!uniqueMap[key]) {
                uniqueMap[key] = true;
                subtipo.push(key);
            }
        });
        
        //console.log("TIPO ATIVO AFTER UNIQUE", tipoAtivo);
        //limpa o select com os subtipos
        $("#subtipoRelatorio").empty()
        //adiciona um option com o titulo do select
        $("#subtipoRelatorio").append("<option selected='true' disabled='true'>SELECIONE O SUBTIPO</option>")
        
        var subtipoSelecionado = ""
        
        //percorre o arrays com subtipos adicionando cada um no select
        subtipo.forEach(function(subtipoAtual){
            console.log("SUBTIPOOOOO", subtipoAtual)
            console.log("VARIACAO SETADAAAAAA", helper.variacaoSetada)
            //verifica se a variacao setada é valida != undefined
            if(helper.variacaoSetada){
                //verifica se o subtipo atual inclui a variacao setada
                if(helper.variacaoSetada.split(' ')[0].includes(subtipoAtual)){
                    var selected = "selected = 'true'";
                    subtipoSelecionado = subtipoAtual
                    $("#subtipoRelatorio").append("<option name='"+subtipoAtual+"' "+selected+" value='"+subtipoAtual+"'>"+subtipoAtual+"</option>")
                }else{
                    var selected = ""
                    $("#subtipoRelatorio").append("<option name='"+subtipoAtual+"' "+selected+" value='"+subtipoAtual+"'>"+subtipoAtual+"</option>")
                }
            }else{
                var selected = ""
                $("#subtipoRelatorio").append("<option name='"+subtipoAtual+"' "+selected+" value='"+subtipoAtual+"'>"+subtipoAtual+"</option>")
            }
        })
        
        const arraySemDuplicados = tipoAtivo.filter((item, index) => {
            return tipoAtivo.indexOf(item) === index;
        });
        
        //exibe select
        $("#subtipoRelatorio").show()
        //destrói a instancia do selectpicker caso já esteja aplciada
        $('.subtipoRelatorio').selectpicker('destroy');
        //cria a instancia do select com selectpicker
        $('.subtipoRelatorio').selectpicker({
            dropupAuto: false  
        });
        
        //EVENTO DO CHANGE NO SELECT DE SUBTIPO
        $('.subtipoRelatorio').on('changed.bs.select', function (e) {
            //obtém valor do subtipo selecionado
            var subtipoSelecionado = $('#subtipoRelatorio').val();
            //chama a funcao para preencher as variacoes passando o subtipo e o tipo ativo
            helper.preencheVariacoes(cmp, event, helper, subtipoSelecionado, arraySemDuplicados);
        });
        
        //verifica se o subtipo já foi selecionado anteriormente
        //caso verdadeiro, preenche as variacoes com base no subtipo selecionado
        if(subtipoSelecionado){
            //console.log("TIPOS ATIVOS DENTRO IF SUBTIPO SELECIONADO", tipoAtivo)
            helper.preencheVariacoes(cmp, event, helper, subtipoSelecionado, arraySemDuplicados);
        }
    },
    
    // Função para ordenar o array original de acordo com a ordem definida, adicionando itens ausentes no final
    ordenarArray : function(arrayOriginal, ordens) {
        const ordenado = ordens.filter(item => arrayOriginal.includes(item));
        const ausentes = arrayOriginal.filter(item => !ordens.includes(item));
        return [...ordenado, ...ausentes];
    },
    
    //essa funcao filtra os tipos ativos utilizando o subtipo selecionado, e os preenche no select
    preencheVariacoes : function(cmp, event, helper, subtipoSelecionado, tipoAtivo){        
        //APLICA FILTRO
        var variacoesDisponiveis = tipoAtivo.filter(item => item.split(" - ")[0].includes(subtipoSelecionado));
        var arrayOrdenado = helper.ordenarArray(variacoesDisponiveis, helper.ordens);
        
        //limpa o select com os subtipos
        $("#variacaoRelatorio").empty()
        
        //adiciona um option com o titulo do select
        $("#variacaoRelatorio").append("<option selected='true' disabled='true'>SELECIONE UMA DASHBOARD</option>")
        
        //percorre o array com as variacoes disponíveis
        arrayOrdenado.forEach(function(variacaoDisponivelAtual){	
            
            //verifica se a variacao setada é valida != undefined
            if(helper.variacaoSetada){
                //verifica se a variacao atual é igual a setada
                if(helper.variacaoSetada == variacaoDisponivelAtual){
                    //adiciona o option com selected true
                    var selected = "selected = 'true'";
                    $("#variacaoRelatorio").append("<option "+selected+" name='"+variacaoDisponivelAtual+"' value='"+variacaoDisponivelAtual+"'>"+variacaoDisponivelAtual+"</option>")
                }else{
                    //adiciona o option sem o selected
                    var selected = ""
                    $("#variacaoRelatorio").append("<option "+selected+" name='"+variacaoDisponivelAtual+"' value='"+variacaoDisponivelAtual+"'>"+variacaoDisponivelAtual+"</option>")
                }
            }else{
                //adiciona o option sem o selected
                var selected = ""
                $("#variacaoRelatorio").append("<option "+selected+" name='"+variacaoDisponivelAtual+"' value='"+variacaoDisponivelAtual+"'>"+variacaoDisponivelAtual+"</option>")
            }
        })
        
        //exibe select
        $("#variacaoRelatorio").show()
        
        //destrói a instancia do selectpicker caso já esteja aplciada
        $('#variacaoRelatorio').selectpicker('destroy');
        
        //cria a instancia do select com selectpicker
        $('.variacaoRelatorio').selectpicker({
            dropupAuto: false  
        });
        
        //EVENTO DO CHANGE NO SELECT DE SUBTIPO
        $('.variacaoRelatorio').on('changed.bs.select', function (e) {
            helper.showSpinner(cmp);
            
            //obtém valor do subtipo selecionado
            var variacaoSelecionada = $('#variacaoRelatorio').val();
            
            //chama a funcao para preencher as variacoes passando o subtipo e o tipo ativo
            var acao = cmp.get("c.AlterarPainel");
            var retorno;
            acao.setParams({
                'config': variacaoSelecionada
            });
            
            acao.setCallback(this, function(response){
                if(response.getState() === "SUCCESS"){
                    retorno = JSON.parse(response.getReturnValue());
                    if(retorno.mensagem==''){
                        location.reload();
                    }
                }
            });
            $A.enqueueAction(acao);	
        });
        
    }
    
})