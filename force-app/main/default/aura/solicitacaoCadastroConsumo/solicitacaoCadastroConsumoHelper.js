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
        $("#solicitaCadastro").on( "click", function() {
            console.log("CLICANDO SOLICITA")
            helper.solicitaCadastro(cmp, event, helper)
        });
    },
    
    solicitaCadastro:function(cmp, event, helper){
        
        helper.showSpinner(cmp);
        
        var codigoProduto = "CON-" + Math.random().toString(36).substring(2, 15); 
        var familia = "OUTROS"
        var linha = "OUTROS"
        var marca = "OUTROS"
        var unidadeMedida = $("#unidadeMedida").val()
        var nome = $("#nome").val()
        var categoriaCompra = $("#categoriaCompra").val()
        var descricao = $("#descricao").val()
        var modelo = $("#modelo").val()
                
        console.log("====DADOS====")
        console.log("codigoProduto", codigoProduto)
        console.log("familia", familia)
        console.log("linha", linha)
        console.log("marca", marca)
        console.log("unidadeMedida", unidadeMedida)
        console.log("nome", nome)
        console.log("categoriaCompra", categoriaCompra)
        console.log("descricao", descricao)
        console.log("modelo", modelo)
        
        var action = cmp.get("c.createSolicitacaoDeCadastro"); //DEFINE A CHAMADA DO MÉTODO APEX QUE IRÁ INSERIR O ITEM FILHO
        $("#boxMasterOts").click();
        //DEFINE OS PARÂMETROS PASSADOS PARA CLASSE APEX----
        action.setParams({
            categoriaCompra: categoriaCompra,
            nome: nome,
            descricao: descricao,
            modelo: modelo,
            marca: marca,
            c_d_Fabricante: codigoProduto,
            unidadeDeMedida: unidadeMedida
        });
        //--------------------------------------------------
        
        //CALLBACK DA REQUISIÇÃO---------------------------
        action.setCallback(this, function (response) {
            var state = response.getState(); //VARIÁVEL QUE ARMAZENA O ESTADO DA REQUISIÇÃO AO MÉTODO APEX
            
            //CASO O MÉTODO SEJA EXECUTADO COM SUCESSO
            if (state === "SUCCESS") {
                console.log("sucesso")
                var retorno = "Solicitação criada com sucesso."
                helper.alertaErro(cmp, event, helper, retorno, "Tudo certo,", "Success", "dismissable")
            	helper.hideSpinner(cmp)
            }
            //CASO O MÉTODO SEJA EXECUTADO DE FORMA INCOMPLETA
            else if (state === "INCOMPLETE") {
                //helper.alertaErro(cmp, event, helper, "ERRO DURANTE A INSERÇÃO", "INSERÇÃO IMCOMPLETA", "error", "Erro: ", "sticky") //EXIBE UM ALERTA DE INSERÇÃO INCOMPLETA AO USUÁRIO
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors && errors[0] && errors[0].message) {
                    helper.alertaErro(cmp, event, helper, errors[0].message, "Erro ao criar OTs", "Error", "dismissable")
                    reject(errors[0].message);
                    helper.hideSpinner(cmp)
                } else {
                    console.log("Erro desconhecido");
                    helper.alertaErro(cmp, event, helper, "ERRO DESCONHECIDO", "OCORREU UM ERRO DESCONHECIDO", "Error", "dismissable")
                    reject("Erro desconhecido");
                    helper.hideSpinner(cmp)
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    //FUNÇÃO QUE EXIBE O SPINNER DE CARREGAMENTO
    showSpinner: function (cmp) {
        $('#spinnerDiv').css("display", "flex");
    },
    
    //FUNÇÃO QUE EXIBE O SPINNER DE CARREGAMENTO
    hideSpinner: function (cmp) {
        $('#spinnerDiv').css("display", "none");
    }
    
})