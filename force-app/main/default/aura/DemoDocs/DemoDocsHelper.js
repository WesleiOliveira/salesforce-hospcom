({
    itensChecklist: [],
    statusEnvio: null,
    statusRetorno: null,
    nomeClienteEnvio: "",
    nomeHospcomEnvio: "",
    nomeClienteRetorno: "",
    nomeHospcomRetorno: "",
    assinaturaClienteEnvio: "",
    assinaturaClienteRetorno: "",
    assinaturaHospcomEnvio: "",
    assinaturaHospcomRetorno: "",
    signaturePad : null,
    signaturePad2 : null,
    signaturePad3 : null,
    signaturePad4 : null,
    
    //FUNÇÃO QUE OBTÉM E RETORNA O RECORDID DO REGISTRO--
    retornaRecorId: function (cmp, event, helper) {
        var recordId = cmp.get("v.recordId");
        return recordId
    },
    //---------------------------------------------------
    
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
    
    helperMethod : function(cmp, event, helper) {
        
        helper.consultaItens(cmp, event, helper);
                
        $("#finalizaChecklist").on( "click", function() {
            $("#popupAssinaturas").css("display", "flex")
            helper.configuraAssinaturas(cmp, event, helper)
        });
        
        $("#buttonDocsDemo").off().on( "click", function() {
            $('#checkList').css('display', 'flex')
            helper.preencheChecklist(cmp, event, helper)
        });	
        
        $("#fechaChecklist").off().on( "click", function() {
			$('#checkList').css('display', 'none')
        });

    },
    
    finalizaChecklist: function(cmp, event, helper, tipo){
        //tipo = 0 p envio
        //tipo = 1 p retorno
        console.log("FINALIZA CHECKLIST TIPO: ", tipo)
        
        var classe = tipo == 0 ? "envio" : "retorno"
        var nomeCliente = tipo == 0 ? $("#nomeClienteEnvio").val() : $("#nomeClienteRetorno").val()
        var nomeHospcom = tipo == 0 ? $("#nomeHospcomEnvio").val() : $("#nomeHospcomRetorno").val()
        var image = tipo == 0 ? helper.signaturePad.toDataURL().split(",")[1] : helper.signaturePad3.toDataURL().split(",")[1]
        var image2 = tipo == 0 ? helper.signaturePad2.toDataURL().split(",")[1] : helper.signaturePad4.toDataURL().split(",")[1]
        var idDemo = helper.retornaRecorId(cmp, event, helper)
        var itensMarcados = $('input[type="checkbox"].'+classe+':checked');        
        var arrayItensIds = []
        var funcaoAction = tipo == 0 ? "c.finalizaEnvio" : "c.finalizaRetorno"
        
        itensMarcados.each(function() {
            var id = $(this).data('id');
            arrayItensIds.push(id);
        });
        var itensString = arrayItensIds.toString();
        
        if(!nomeCliente){
            alert("Nome do cliente não preenchido!")
            return 0;
        }
        
        if(!nomeHospcom){
            alert("Nome do responsável da hospcom não preenchido!")
            return 0;
        }
        
        //CHAMA A FUNÇÃO DO APEX
        var action = cmp.get(funcaoAction);
        
        //DEFINE OS PARÂMETROS PASSADOS PARA CLASSE APEX----
        action.setParams({
            idsItems: itensString,
            assinaturaCliente: image,
            assinaturaHospcom: image2,
            nomeCliente: nomeCliente,
            nomeHospcom: nomeHospcom,
            orderId: idDemo
        });
        
        //CALLBACK DA REQUISIÇÃO---------------------------
        action.setCallback(this, function (response) {
            var state = response.getState();
            var result = response.getReturnValue();
            
            //TESTANDO O SUCESSO
            if (state === "SUCCESS") {
                console.log("sucesso")
                $("#popupAssinaturas").css("display", "none")
                $('#checkList').css('display', 'none')
                helper.alertaErro(cmp, event, helper, "Checklist de " + classe +" assinado", "Tudo Ok,", "Success", "dismissable")
                helper.consultaItens(cmp, event, helper);

                //console.log("RESULTADO", result)
                
            }else if (state === "INCOMPLETE") {
                console.log("incompleto")
                console.log(response)
                
            } else if (state === "ERROR") {
                console.log("erro")
                helper.alertaErro(cmp, event, helper, response.getError(), "Erro,", "Error", "dismissable")
                console.log(response.getError())
            }
        });
        $A.enqueueAction(action);
    },
                
    configuraAssinaturas: function(cmp, event, helper){
        
        //EVENTO NO BOTAO PARA FECHAR POPUP DE ASSINATURAS
        $("#buttonCancelaAssinaturas").off().on( "click", function() {
            $("#popupAssinaturas").css("display", "none")
        });
        
        //EVENTO PARA LIMPAR AS ASSINATURAS DE RETORNO
        $("#buttonLimpaRetorno").off().on( "click", function() {
            signaturePad3.clear();
            signaturePad4.clear();
        });
        
        //EVENTO PARA LIMPAR AS ASSINATURAS DE ENVIO
        $("#buttonLimpaEnvio").off().on( "click", function() {
            signaturePad.clear();
            signaturePad2.clear();
        });
		
		//DESABILITA O BOTAO DE FINALIZAR CASO TODAS ASSINATURAS TENHAM CONCLUIDAS        
        if(helper.statusRetorno == true && helper.statusEnvio == true){
            $("#buttonFinalizaAssinaturas").prop("disabled",true).prop('title', 'O envio e retorno já foram assinados').css("background-color","#c9c7c5");
        }
        
        //VERIFICA SE AS ASSINATURAS DE ENVIO NAO FORAM PREENCHIDAS
        if(helper.statusEnvio == false){
            
            //DESABILITA AS ASSINATURAS DE RETORNO, POIS SE O ENVIO AINDA NAO FOI PREENCHIDO, O RETORNO NAO PODE SER PREENCHIDO
            $("#divAssinaturaRetorno").css("display","none")
            $("#divTituloAssRetorno").css("display","none")
            
            //EVENTO DO BOTAO FINALIZAR, CHAMA FUNCAO QUE INSERE OS DADOS DE ENVIO
            $("#buttonFinalizaAssinaturas").off().on( "click", function() {
                console.log("FINALIZA CHECKLIST ENVIO")
                helper.finalizaChecklist(cmp, event, helper, 0) //usar 0 para envio, 1 para retorno
            });
            
            //CRIA OS CANVAS PARA ASSINATURAS DE ENVIO
            var canvas = cmp.find('signature-pad').getElement();
            var ratio = Math.max(window.devicePixelRatio || 1, 1);
            var container = document.getElementById('assinaturaClienteEnvio'); // Obter a referência da div pai
            var containerHeight = container.offsetHeight;
            var containerWidth = container.offsetWidth;
            canvas.width = containerWidth * ratio;
            canvas.height = containerHeight * ratio
            canvas.getContext("2d").scale(ratio, ratio);
            var signaturePad = new SignaturePad(canvas, {
                minWidth: .25,
                maxWidth: 2,
                throttle: 0
            });
            helper.signaturePad = signaturePad
            
            var canvas2 = cmp.find('signature-pad2').getElement();
            var ratio2 = Math.max(window.devicePixelRatio || 1, 1);
            var container2 = document.getElementById('assinaturaHospcomEnvio'); // Obter a referência da div pai
            var containerHeight2 = container.offsetHeight;
            var containerWidth2 = container.offsetWidth;
            canvas2.width = containerWidth2 * ratio2;
            canvas2.height = containerHeight2 * ratio2
            canvas2.getContext("2d").scale(ratio2, ratio2);
            var signaturePad2 = new SignaturePad(canvas2, {
                minWidth: .25,
                maxWidth: 2,
                throttle: 0
            });
            helper.signaturePad2 = signaturePad2
            //FIM CRIA CANVAS
        }else{
            //SE AS ASSINATURAS DE ENVIO JA FORAM FINALIZADAS:
            
            //EVENTO DO BOTAO FINALIZAR, CHAMA FUNCAO QUE INSERE OS DADOS DE RETORNO
            $("#buttonFinalizaAssinaturas").off().on( "click", function() {
                console.log("FINALIZA CHECKLIST RETORNO")
                helper.finalizaChecklist(cmp, event, helper, 1) //usar 0 para envio, 1 para retorno
            });
            
            //PREENCHE AS IMAGENS DAS ASSINATURAS JÁ SALVAS
            var canvas = cmp.find('signature-pad').getElement();
            var context = canvas.getContext('2d');
            var imageUrl = helper.assinaturaClienteEnvio
            var imagem = new Image();
            imagem.src = imageUrl;
            imagem.onload = function() {
                context.drawImage(imagem, 0, 0); // Desenha a imagem nas coordenadas (0, 0) do canvas
            };
            
            var canvas2 = cmp.find('signature-pad2').getElement();
            var context2 = canvas2.getContext('2d');
            var imageUrl2 = helper.assinaturaHospcomEnvio;
            var imagem2 = new Image();
            imagem2.src = imageUrl;
            imagem2.onload = function() {
                context2.drawImage(imagem2, 0, 0); // Desenha a imagem nas coordenadas (0, 0) do canvas
            };
            //FIM PREENCHE ASSINATURAS
            
            //PREENCHE O NOME DO CLIENTE ENVIO SALVO
            $("#nomeClienteEnvio").val(helper.nomeClienteEnvio).prop('disabled', true);
            //PREENCHE O NOME HOSPCOM ENVIO SALVO
            $("#nomeHospcomEnvio").val(helper.nomeHospcomEnvio).prop('disabled', true);
            //DESABILITA O BOTAO QUE LIMPA AS ASSINATURAS DE ENVIO
            $("#buttonLimpaEnvio").prop("disabled",true).prop('title', 'Envio ja assinado');
        }
        
        //VERIFICA SE AS ASSINATURAS DE RETORNO NAO FORAM PREENCHIDAS
        if(helper.statusRetorno == false){
            
            //CRIA OS CANVAS PARA ASSINATURAS DE ENVIO
            var canvas3 = cmp.find('signature-pad3').getElement();
            var ratio3 = Math.max(window.devicePixelRatio || 1, 1);
            var container3 = document.getElementById('assinaturaClienteRetorno');
            var containerHeight3 = container3.offsetHeight;
            var containerWidth3 = container3.offsetWidth;
            canvas3.width = containerWidth3 * ratio3;
            canvas3.height = containerHeight3 * ratio3
            canvas3.getContext("2d").scale(ratio3, ratio3);
            var signaturePad3 = new SignaturePad(canvas3, {
                minWidth: .25,
                maxWidth: 2,
                throttle: 0
            });
            helper.signaturePad3 = signaturePad3
            
            var canvas4 = cmp.find('signature-pad4').getElement();
            var ratio4 = Math.max(window.devicePixelRatio || 1, 1);
            var container4 = document.getElementById('assinaturaHospcomRetorno'); // Obter a referência da div pai
            var containerHeight4 = container4.offsetHeight;
            var containerWidth4 = container4.offsetWidth;
            canvas4.width = containerWidth4 * ratio4;
            canvas4.height = containerHeight4 * ratio4
            canvas4.getContext("2d").scale(ratio4, ratio4);
            var signaturePad4 = new SignaturePad(canvas4, {
                minWidth: .25,
                maxWidth: 2,
                throttle: 0
            });
            helper.signaturePad4 = signaturePad4
            //FIM CRIA CANVAS
        }else{
            //SE AS ASSINATURAS DE ENVIO JA FORAM FINALIZADAS:
            
            //PREENCHE AS IMAGENS DAS ASSINATURAS JÁ SALVAS
            var canvas3 = cmp.find('signature-pad3').getElement();
            var context3 = canvas3.getContext('2d');
            var imageUrl3 = helper.assinaturaClienteRetorno;
            var imagem3 = new Image();
            imagem3.src = imageUrl3;
            imagem3.onload = function() {
                context3.drawImage(imagem3, 0, 0); // Desenha a imagem nas coordenadas (0, 0) do canvas
            };
                        
            var canvas4 = cmp.find('signature-pad4').getElement();
            var context4 = canvas4.getContext('2d');
            var imageUrl4 = helper.assinaturaHospcomRetorno;
            var imagem4 = new Image();
            imagem4.src = imageUrl4;
            imagem4.onload = function() {
                context4.drawImage(imagem4, 0, 0); // Desenha a imagem nas coordenadas (0, 0) do canvas
            };
            //FIM PREENCHE ASSINATURAS
            
            //PREENCHE O NOME DO CLIENTE RETORNO SALVO
            $("#nomeClienteRetorno").val(helper.nomeClienteRetorno).prop('disabled', true);
            //PREENCHE O NOME HOSPCOM RETORNO SALVO
            $("#nomeHospcomRetorno").val(helper.nomeHospcomRetorno).prop('disabled', true);
            //DESABILITA O BOTAO QUE LIMPA AS ASSINATURAS DE ENVIO
            $("#buttonLimpaRetorno").prop("disabled",true).prop('title', 'Retorno ja assinado');;
        }
    },
    
    preencheChecklist: function(cmp, event, helper){
        $('#spinnerDiv').css("display", "flex");
        $("#itensChecklist").empty()
        console.log("ITENS", helper.itensChecklist)
        
        var produtosPai = helper.itensChecklist.filter(produto => !produto.hasOwnProperty('Item_Pai__c'));
        var statusEnvio = helper.itensChecklist[0].Order.Checklist_Envio_Assinado__c == true ? "disabled title='Envio já assinado'" : ""
        var statusRetorno = helper.itensChecklist[0].Order.Checklist_Retorno_Assinado__c == true ? "disabled title='Retorno já assinado'" : ""
        var nomeConta = helper.itensChecklist[0].Order.Nome_da_conta__c
        var cnpjConta = helper.itensChecklist[0].Order.Account.CNPJ__c
        var numeroPedido = helper.itensChecklist[0].Order.OrderNumber

        $("#docTitleChecklistMain").html("CHECKLIST DIGITAL DE ENVIO E RETORNO DE DEMONSTRAÇÃO/COMODATO: Nº." + numeroPedido)
        $("#nomeConta").html(nomeConta + " - " + cnpjConta)
        
        //VARIAVEIS GERAIS DO PEDIDO        
        helper.statusRetorno = helper.itensChecklist[0].Order.Checklist_Retorno_Assinado__c
        helper.statusEnvio = helper.itensChecklist[0].Order.Checklist_Envio_Assinado__c
        helper.nomeClienteEnvio = helper.itensChecklist[0].Order.Nome_Cliente_Envio__c ? helper.itensChecklist[0].Order.Nome_Cliente_Envio__c : ""
        helper.nomeHospcomEnvio = helper.itensChecklist[0].Order.Nome_Hospcom_Envio__c ? helper.itensChecklist[0].Order.Nome_Hospcom_Envio__c : ""
        helper.nomeClienteRetorno = helper.itensChecklist[0].Order.Nome_Cliente_Retorno__c ? helper.itensChecklist[0].Order.Nome_Cliente_Retorno__c : ""
        helper.nomeHospcomRetorno = helper.itensChecklist[0].Order.Nome_Hospcom_Retorno__c ? helper.itensChecklist[0].Order.Nome_Hospcom_Retorno__c : ""
        helper.assinaturaClienteEnvio = helper.itensChecklist[0].Order.Assinatura_Cliente_Envio__c ? helper.itensChecklist[0].Order.Assinatura_Cliente_Envio__c : ""
        helper.assinaturaClienteRetorno = helper.itensChecklist[0].Order.Assinatura_Cliente_Retorno__c ? helper.itensChecklist[0].Order.Assinatura_Cliente_Retorno__c : ""
        helper.assinaturaHospcomEnvio = helper.itensChecklist[0].Order.Assinatura_Hospcom_Envio__c ? helper.itensChecklist[0].Order.Assinatura_Hospcom_Envio__c : ""
        helper.assinaturaHospcomRetorno = helper.itensChecklist[0].Order.Assinatura_Hospcom_Retorno__c ? helper.itensChecklist[0].Order.Assinatura_Hospcom_Retorno__c : ""
        
        produtosPai.forEach(function(produtoPaiAtual){
            var id = produtoPaiAtual.Id
            var itemC = produtoPaiAtual.Item__c
            var urlImagem = produtoPaiAtual.Product2.URL_da_Imagem__c
            var checkEnvio = produtoPaiAtual.checklist_envio__c == true ? "checked" : ""
            var checkRetorno = produtoPaiAtual.checklist_retorno__c == true ? "checked" : "enabled"
            var numeroSerie = produtoPaiAtual.Description
            var nomeProduto = produtoPaiAtual.Product2.Name
            var marcaProduto = produtoPaiAtual.Product2.Marca__c
            var modeloProduto = produtoPaiAtual.Product2.Modelo__c
            var codigoProduto = produtoPaiAtual.Product2.StockKeepingUnit
            var produtosFilhos = helper.itensChecklist.filter(produto => produto.Item_Pai__c == itemC)
            
            var html = "\
			<div class='itemDemo'>\
            <div style='display: flex; width: 100%;justify-content: center;align-items: center'>\
                <div class='checkItem'>\
                    <div class='divCheckbox'>\
                        <p>Envio</p>\
                        <input type='checkbox' class='envio' "+checkEnvio+" "+statusEnvio+" data-id='"+id+"'></input>\
                    </div>\
                    <div class='divCheckbox'>\
                        <p>Retorno</p>\
                        <input type='checkbox' class='retorno' "+checkRetorno+" "+statusRetorno+" data-id='"+id+"'></></input>\
                    </div>\
                </div>\
                <div class='descItem'>\
                    <div class='imgItem'>\
                        <img class='imgItemClass' src='"+urlImagem+"'/>\
                    </div>\
                    <div class='column1Desc'>\
                        <p class='txtBold2342'>Produto</p>\
                        COD: "+codigoProduto+"<Br>\
                        "+nomeProduto+"\
                    </div>\
                    <div>\
                        <p class='txtBold2342'>Modelo</p>\
                        "+modeloProduto+"\
                    </div>\
                    <div>\
                        <p class='txtBold2342'>Marca</p>\
                        "+marcaProduto+"\
                    </div>\
                    <div>\
                        <p class='txtBold2342'>Nº de Série</p>\
                        "+numeroSerie+"\
                    </div>\
                </div>\
            </div>"
        
        if(produtosFilhos.length > 0){
            produtosFilhos.forEach(function(produtoFilhoAtual){
                
                var id = produtoFilhoAtual.Id
                var itemC = produtoFilhoAtual.Item__c
                var urlImagem = produtoFilhoAtual.Product2.URL_da_Imagem__c
                var checkEnvio = produtoFilhoAtual.checklist_envio__c == true ? "checked" : ""
                var checkRetorno = produtoFilhoAtual.checklist_retorno__c == true ? "checked" : "enabled"
                var numeroSerie = produtoFilhoAtual.Description
                var nomeProduto = produtoFilhoAtual.Product2.Name
                var marcaProduto = produtoFilhoAtual.Product2.Marca__c
                var modeloProduto = produtoFilhoAtual.Product2.Modelo__c ? produtoFilhoAtual.Product2.Modelo__c : "Não Cadastrado"
                var codigoProduto = produtoFilhoAtual.Product2.StockKeepingUnit            
            
                html += "<div class='itemDemo'>\
                <div style='display: flex; width: 100%;justify-content: center;align-items: center'>\
                    <div class='checkItem'>\
                        <Div class='divCheckbox'>\
                            <p>Envio</p>\
                            <input type='checkbox' class='envio' "+checkEnvio+" "+statusEnvio+" data-id='"+id+"'></input>\
                        </Div>\
                        <Div class='divCheckbox'>\
                            <p>Retorno</p>\
                            <input type='checkbox' class='retorno' "+checkRetorno+" "+statusRetorno+" data-id='"+id+"'></input>\
                        </Div>\
                    </div>\
                    <div class='descItem'>\
                        <div class='imgItem'>\
                            <img class='imgItemClass' src='"+urlImagem+"'/>\
                        </div>\
                        <div class='column1Desc'>\
                            <p class='txtBold2342'>Produto</p>\
                            COD: "+codigoProduto+"<Br>\
                            "+nomeProduto+"\
                        </div>\
                        <div>\
                            <p class='txtBold2342'>Modelo</p>\
                            "+modeloProduto+"\
                        </div>\
                        <div>\
                            <p class='txtBold2342'>Marca</p>\
                            "+marcaProduto+"\
                        </div>\
                    </div>\
                </div>\
            	</div>"
            })
            
            html+="</div>"
            
        }else{
            html+="</div>"
        }
            
            $("#itensChecklist").append(html)
            $('#spinnerDiv').css("display", "none");
        })
    },
    
    consultaItens: function(cmp, event, helper){
        $('#spinnerDiv').css("display", "flex");
        
        var recordId = helper.retornaRecorId(cmp, event, helper)        
        helper.alertaErro(cmp, event, helper, "Carregando...", "Aguarde,", "Info", "dismissable")

        //CONSULTA AS VARIAÇÕES DO USUARIO
        var query = "select id, Order.OrderNumber, Order.Account.CNPJ__c, Order.Nome_da_conta__c, Order.RecordTypeId, Order.Assinatura_Cliente_Envio__c, Order.Assinatura_Hospcom_Envio__c, Order.Assinatura_Cliente_Retorno__c,Order.Assinatura_Hospcom_Retorno__c, Order.Nome_Cliente_Envio__c, Order.Nome_Cliente_Retorno__c, Order.Nome_Hospcom_Envio__c, Order.Nome_Hospcom_Retorno__c, Item_Pai__c, Item__c, Order.Checklist_Retorno_Assinado__c, Order.Checklist_Envio_Assinado__c, Product2.URL_da_Imagem__c, checklist_envio__c, checklist_retorno__c, Description, Product2.Name, Product2.Marca__c, Product2.Modelo__c, Product2.StockKeepingUnit from orderItem where orderid = '"+recordId+"'"
        
        //REALIZA A CONSULTA
        this.soql(cmp, query)
        
        //QUANDO A SOLICITAÇÃO FOR CONCLUÍDA, FAÇA:
        .then(function (itensPv) {
            helper.itensChecklist = itensPv
            if(itensPv[0].Order.RecordTypeId == '0126e000001pMEkAAM'){$('#classDivMaster').css("display", "flex");}
            $('#spinnerDiv').css("display", "none");
        })
        
        //trata excessão de erro
        .catch(function (error) {
            console.log(error)
        })
    }
})