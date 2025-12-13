({
    contaSelecionada: '',
    contatoSelecionado: '',
    responsavelSelecionado: '',
    proprietarioSelecionado: '',
    statusSelecionado: '',
    tipoDeRegistroSelecionado: '',
    categoriaSelecionado: '',
    assuntoSelecionado: '',
    equipamentoPertenceSelecionado: '',
    numerosSelecionados: '',
    selectEmpresaFaturada: '',
    localAtendimento: '',
    contaClicada: '',
    contratoSelecionado: '',
    problemaRelatado: '',
    itensAcompanham: '',
    dataAgendada: null,
    dataPrevista: null,
    tecnicoResponsavel: '',
    
    //FUNÇÃO QUE EXIBE ERROS AO USUÁRIO-------------------------------------------------------------
    alertaErro: function (cmp, event, helper, error, title, type, mode) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": error,
            "type": type,
            "mode": mode
        });
        toastEvent.fire();
    },
    //----------------------------------------------------------------------------------------------
    
    helperMethod : function(cmp, event, helper) {
        $("#criaOtsMassa").on( "click", function() {
            $("#criaOtsMassa").css("display", "none")
            $("#boxMasterOts").css("display", "flex")
        });
        
        $("#closeSharePopup").on( "click", function() {
            $("#criaOtsMassa").css("display", "flex")
            $("#boxMasterOts").css("display", "none")
        });
        
        $("#criarSubmit").on( "click", function() {
            helper.assuntoSelecionado = $('#assunto').val()
            helper.selectEmpresaFaturada = $('#selectEmpresaFaturada').val()
            helper.equipamentoPertenceSelecionado = $('#eqPertence').val()
            helper.itensAcompanham = $('#textItensAcompanham').val()
            helper.problemaRelatado = $('#textProblemaRelatado').val()
            helper.dataAgendada = new Date($('#dataAgendamento').val()).toISOString();
            helper.dataPrevista = new Date($('#dataFim').val()).toISOString();
            helper.numerosSelecionados = $('#textAreaNumerosSerie').val().replaceAll(/\n/g, ',').replaceAll(/\s+/g, '')
            helper.criaOts(cmp, event, helper)
        });
        
        helper.consultaProprietarios(cmp, event, helper)
        helper.consultaTecnicosResponsavel(cmp, event, helper)
        helper.consultaStatus(cmp, event, helper)
        helper.consultaTipoDeRegistro(cmp, event, helper)
        helper.consultaCategorias(cmp, event, helper)
        helper.consultaLocalAtendimento(cmp, event, helper)
    },
    
    criaOts:function(cmp, event, helper){
        
        console.log("====DADOS====")
        console.log("CONTA", helper.contaSelecionada)
        console.log("CONTATO", helper.contatoSelecionado)
        console.log("RESPONSAVEL TEC ID", helper.tecnicoResponsavel)
        console.log("PROPRIETARIO", helper.proprietarioSelecionado)
        console.log("STATUS", helper.statusSelecionado)
        console.log("TIPO DE REGISTRO", helper.tipoDeRegistroSelecionado)
        console.log("CATEGORIA", helper.categoriaSelecionado)
        console.log("ASSUNTO", helper.assuntoSelecionado)
        console.log("EQ PERTENCE", helper.equipamentoPertenceSelecionado)
        console.log("NUMEROS", helper.numerosSelecionados)
        console.log("EMPRESA FATURADA", helper.selectEmpresaFaturada)
        console.log("LOCAL DE ATENDIMENTO", helper.localAtendimento)
        console.log("ID CONTRATO", helper.contratoSelecionado)
        console.log("DATA AGENDADO", helper.dataAgendada)
        console.log("DATA PREVISTA", helper.dataPrevista)
        console.log("PROBLEMA RELATADO", helper.problemaRelatado)
        console.log("ITENS QUE ACOMPANHA", helper.itensAcompanham)
        
        var action = cmp.get("c.gerar"); //DEFINE A CHAMADA DO MÉTODO APEX QUE IRÁ INSERIR O ITEM FILHO
        
        //DEFINE OS PARÂMETROS PASSADOS PARA CLASSE APEX----
        action.setParams({
            
            local: helper.localAtendimento,
            faturamento: helper.selectEmpresaFaturada,
            categoria: helper.categoriaSelecionado,
            conta: helper.contaSelecionada,
            contato: helper.contatoSelecionado,
            
            tecnico: "",
            responsavel: helper.tecnicoResponsavel,
            
            status: helper.statusSelecionado,
            tipoRegistro: helper.tipoDeRegistroSelecionado,
            assunto: helper.assuntoSelecionado,
            pertence: helper.equipamentoPertenceSelecionado,
            SN: helper.numerosSelecionados,
            contrato: helper.contratoSelecionado,
            itensAcompanham: helper.itensAcompanham,
            problemaRelatado: helper.problemaRelatado,
            dataPrevista: helper.dataPrevista,
            dataAgendada: helper.dataAgendada

        });
        //--------------------------------------------------
        
        //CALLBACK DA REQUISIÇÃO---------------------------
        action.setCallback(this, function (response) {
            var state = response.getState(); //VARIÁVEL QUE ARMAZENA O ESTADO DA REQUISIÇÃO AO MÉTODO APEX
            
            //CASO O MÉTODO SEJA EXECUTADO COM SUCESSO
            if (state === "SUCCESS") {
                console.log("sucesso")
                var retorno = response.getReturnValue();
                helper.alertaErro(cmp, event, helper, retorno, "Tudo certo,", "Success", "dismissable")
            }
            //CASO O MÉTODO SEJA EXECUTADO DE FORMA INCOMPLETA
            else if (state === "INCOMPLETE") {
                //helper.alertaErro(cmp, event, helper, "ERRO DURANTE A INSERÇÃO", "INSERÇÃO IMCOMPLETA", "error", "Erro: ", "sticky") //EXIBE UM ALERTA DE INSERÇÃO INCOMPLETA AO USUÁRIO
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors && errors[0] && errors[0].message) {
                    helper.alertaErro(cmp, event, helper, errors[0].message, "Erro ao criar OTs", "Error", "dismissable")
                    reject(errors[0].message);
                } else {
                    console.log("Erro desconhecido");
                    helper.alertaErro(cmp, event, helper, "ERRO DESCONHECIDO", "OCORREU UM ERRO DESCONHECIDO", "Error", "dismissable")
                    reject("Erro desconhecido");
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    consultaLocalAtendimento: function(cmp, event, helper){
        //REALIZA A CONSULTA
        this.getPicklist(cmp, "WorkOrder", "Local_de_Atendimento__c")
        
        //QUANDO A SOLICITAÇÃO FOR CONCLUÍDA, FAÇA:
        .then(function (locais) {
            locais.forEach((e, i) => $('#localAtendimento').append("<option value='" + e + "'>" + e + "</option>")); 
            
            $('#localAtendimento').on('change', function() {
                helper.localAtendimento = this.value
            });
        })
        
        //trata excessão de erro
        .catch(function (error) {
            console.log(error)
        })
    },
    
    consultaContatos: function(cmp, event, helper){
        var query = "SELECT id, name from contact where AccountId = '"+helper.contaSelecionada+"' ORDER BY name";
        
        //REALIZA A CONSULTA
        this.soql(cmp, query)
        
        //QUANDO A SOLICITAÇÃO FOR CONCLUÍDA, FAÇA:
        .then(function (contatos) {
            
            $('#selectContatos').empty()
            
            if (contatos.length == 0) {
                alert("Nenhum contato encontrado na conta selecionada!")
            }
             if (!contatos) {
                alert("Nenhum contato encontrado na conta selecionada!")
            }
       if (contatos == '' || contatos == null) {
                alert("Nenhum contato encontrado na conta selecionada!")
            }            
            console.log("contatos***", contatos)
            contatos.forEach((e, i) => $('#selectContatos').append("<option value='" + e.Id + "'>" + e.Name + "</option>")); 
            
            $('#selectContatos').on('change', function() {
                helper.contatoSelecionado = this.value
            });
        })
        
        //trata excessão de erro
        .catch(function (error) {
            console.log(error)
        })
    },
    
    consultaTipoDeRegistro: function(cmp, event, helper){
        //REALIZA A CONSULTA
        this.getRecordsTypes(cmp, "WorkOrder")
        
        //QUANDO A SOLICITAÇÃO FOR CONCLUÍDA, FAÇA:
        .then(function (recordTypes) {
            console.log("TIPOS DE REGISTRO", recordTypes)
            
            Object.entries(recordTypes).forEach(([key, value]) => {
                $('#tiposRegistro').append("<option value='" + value + "'>" + key + "</option>");
            });
                
           $('#tiposRegistro').on('change', function() {
                helper.tipoDeRegistroSelecionado = this.value
            });
        })
        
        //trata excessão de erro
        .catch(function (error) {
            console.log(error)
        })
    },
	    
    consultaCategorias: function(cmp, event, helper){
        //REALIZA A CONSULTA
        this.getPicklist(cmp, "WorkOrder", "Categoria__c")
        
        //QUANDO A SOLICITAÇÃO FOR CONCLUÍDA, FAÇA:
        .then(function (categorias) {
            categorias.forEach((e, i) => $('#categorias').append("<option value='" + e + "'>" + e + "</option>")); 
            $('#categorias').on('change', function() {
                helper.categoriaSelecionado = this.value
            });
            
            $('#categorias').on('change', function() {
                helper.categoriaSelecionado = this.value
            });
        })
        
        //trata excessão de erro
        .catch(function (error) {
            console.log(error)
        })
    },
    
    consultaStatus: function(cmp, event, helper){
        //REALIZA A CONSULTA
        this.getPicklist(cmp, "WorkOrder", "Status")
        
        //QUANDO A SOLICITAÇÃO FOR CONCLUÍDA, FAÇA:
        .then(function (tecnicos) {
            tecnicos.forEach((e, i) => $('#status').append("<option value='" + e + "'>" + e + "</option>")); 
            
            $('#status').on('change', function() {
                helper.statusSelecionado = this.value
            });
            
        })
        
        //trata excessão de erro
        .catch(function (error) {
            console.log(error)
        })
    },
    
    consultaTecnicosResponsavel:function(cmp, event, helper){
        //REALIZA A CONSULTA
        this.getPicklist(cmp, "WorkOrder", "T_cnico_Respons_vel__c")
        
        //QUANDO A SOLICITAÇÃO FOR CONCLUÍDA, FAÇA:
        .then(function (tecnicos) {
            tecnicos.forEach((e, i) => $('#tecnicos').append("<option value='" + e + "'>" + e + "</option>")); 
        	
        	$('#tecnicos').on('change', function() {
                helper.responsavelSelecionado = this.value
            });
        })
        
        //trata excessão de erro
        .catch(function (error) {
            console.log(error)
        })
    },
                
    consultaProprietarios:function(cmp, event, helper){
        var query = "SELECT id, name from user WHERE IsActive = true";
        
        //REALIZA A CONSULTA
        this.soql(cmp, query)
        
        //QUANDO A SOLICITAÇÃO FOR CONCLUÍDA, FAÇA:
        .then(function (usuarios) {
            console.log("usuarios", usuarios)
            usuarios.forEach((e, i) => $('#proprietario').append("<option value='" + e.Id + "'>" + e.Name + "</option>")); 
        	
            $('#proprietario').on('change', function() {
                helper.proprietarioSelecionado = this.value
            });
        })
        
        //trata excessão de erro
        .catch(function (error) {
            console.log(error)
        })
    },
    
    //FUNÇÃO QUE EXIBE O SPINNER DE CARREGAMENTO
    showSpinner: function (cmp) {
        $('#spinnerDiv').css("display", "flex");
    },
    
    //FUNÇÃO QUE EXIBE O SPINNER DE CARREGAMENTO
    hideSpinner: function (cmp) {
        $('#spinnerDiv').css("display", "none");
    },
    
    //FUNÇÃO QUE EXIBE ERROS AO USUÁRIO
    alertaErro: function (cmp, event, helper, error, title, type, mode) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": error,
            "type": type,
            "mode": mode
        });
        toastEvent.fire();
    },
})