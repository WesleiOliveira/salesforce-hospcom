({
    objetoAtual: '',
    endpointObjeto: '',
    
    mainFunction: function(cmp, event, helper){
        helper.verificaTipoObjeto(cmp, event, helper);
        //helper.preencheVisualizacao(cmp, event, helper, 'Requisição Interna');
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
    
    verificaTipoObjeto: function (cmp, event, helper){
        var recordId = cmp.get("v.recordId")
        var caracteresObjeto = recordId.substring(0, 3);
        
        switch(caracteresObjeto) {
            case "a21":
                helper.objetoAtual = "Requisição Interna"
                helper.endpointObjeto = "https://hospcom.my.site.com/Sales/s/requisi-o-interna/"
                break;
            case "a1e":
                helper.objetoAtual = "Cotação de Compra"
                helper.endpointObjeto = "https://hospcom.my.site.com/Sales/s/pedido-de-compra/"
                break;
            case "a1b":
                helper.objetoAtual = "Pedido de Compra"
                helper.endpointObjeto = "https://hospcom.my.site.com/Sales/s/fornecedor/"
                break;
            default:
                helper.objetoAtual = "Erro ao verificar"
                break;
        }
        helper.consulta(cmp, event, helper);
        
    },
    
    consulta: function(cmp, event, helper){
        
        var recordId = cmp.get("v.recordId")
        var nomeReq = "REQ. INTERNA"
        
        // Dados do grafo
        var graphData = {
            "nodes": [
                { "id": recordId, "name": nomeReq, "url": "https://hospcom.my.site.com/Sales/s/requisi-o-interna/" + recordId},
            ],
            "links": [

            ]
        };
                
                //console.log(graphData.nodes)
               
                
        //SELECT Name, ID, (SELECT Item_Requerido__c FROM Itens_de_pedido_de_compra__r where status__c NOT IN ('cancelado', 'novo')) FROM Item_Requerido__c WHERE Requisi_o_Interna_Relacionada__c = 'a216e000006SBNyAAO' 
    	
        var query = "SELECT Name, ID, (SELECT id, Name, Fornecedor__c, Fornecedor__r.Name, Item_de_pedido_de_compra__c FROM Itens_de_pedido_de_compra__r where status__c NOT IN ('cancelado', 'novo')) FROM Item_Requerido__c WHERE Requisi_o_Interna_Relacionada__c = '"+recordId+"' "
        
        
        //console.log(query)
        //REALIZA A CONSULTA
        this.soql(cmp, query)
        
        //QUANDO A SOLICITAÇÃO FOR CONCLUÍDA, FAÇA:
        .then(function (relacoes) {
                
                
                relacoes.forEach(function(itemAtual){
                	console.log(itemAtual)
                	var idItemRequerido = itemAtual.Id
                    var nomeItemRequerido = "Item REQ.: " + itemAtual.Name.substring(0, 15) + "..."
                
                	var newNode = { "id": idItemRequerido, "name": nomeItemRequerido, "url": "https://hospcom.my.site.com/Sales/s/detail/"+idItemRequerido+""};
					var newLink = { "source": recordId, "target": idItemRequerido }
                    
	                graphData.nodes.push(newNode)
                    graphData.links.push(newLink)
                    
                    //VERIFICA SE EXISTE ITENS DE PEDIDO DE COMPRA PARA ESSA REQUISIÇÃO
                    if("Itens_de_pedido_de_compra__r" in itemAtual){
                        //console.log("existe")
                        //CASO EXISTA, PERCORRE O ARRAY COM OS ITENS
                        itemAtual.Itens_de_pedido_de_compra__r.forEach(function(itemPedidoCompraAtual){
                            console.log("ITENS COMPRA: ", itemPedidoCompraAtual)
                            
                            //RECUPERA O ID DO PEDIDO DE COMPRA
                            var idPedidoDeCompra = itemPedidoCompraAtual.Fornecedor__r.Id
                            //RECUPERA O NUMERO DO PEDIDO DE COMPRA
                            var numeroPedidoCompra = "PC: " + itemPedidoCompraAtual.Fornecedor__r.Name
                            //CRIA UM SET COM OS IDS JÁ EXISTENTES NOS NÓS
                            var idSetNos = new Set(graphData.nodes.map(node => node.id))
                            
                            //VERIFICA SE O PEDIDO DE COMPRA JÁ ESTÁ ADICIONADO AOS NÓS
                            if (!idSetNos.has(idPedidoDeCompra)) {
                                var newNodePc = { "id": idPedidoDeCompra, "name": numeroPedidoCompra, "url": "https://hospcom.my.site.com/Sales/s/fornecedor/"+idPedidoDeCompra+""};
                                graphData.nodes.push(newNodePc)
                            }
                            //CRIA OS LINKS DOS ITENS COM O PEDIDO DE COMPRA
                            var newLinkPc = { "source": idItemRequerido, "target": idPedidoDeCompra}
                            graphData.links.push(newLinkPc)
                            
                            
                            var idItemPc = itemPedidoCompraAtual.Id
                            var nomeItemPc = "ITEM PC: " + itemPedidoCompraAtual.Name
                            
                            var newNodeItemPc = { "id": idItemPc, "name": nomeItemPc, "url": "https://hospcom.my.site.com/Sales/s/fornecedor/"+idPedidoDeCompra+""};
                            graphData.nodes.push(newNodeItemPc)
                            
                            var newLinkItemPc = { "source": idPedidoDeCompra, "target": idItemPc}
                            graphData.links.push(newLinkItemPc)
                            
                            
                            
                        })
                        
                    }
                    
                	//console.log(graphData.nodes)
                })
                
                
                
                
                
                
            //console.log(relacoes)
            console.log(graphData)
            helper.generateChart(cmp, event, helper, graphData, recordId)
            
        })
        
        //trata excessão de erro
        .catch(function (error) {
            console.log(error)
        })
    
    },
    
    //RECEBE O STATUS DA ASSINATURA, E GERA A PROGRESSBAR
    preencheVisualizacao: function(cmp, event, helper){
        
        var statusAtual = helper.objetoAtual
        
        var steps = ['Requisição Interna', 'Cotação de Compra', 'Pedido de Compra']
        var indiceEdicaoSteps = steps.findIndex(v => v == statusAtual)
        
        steps[indiceEdicaoSteps] = '@' + steps[indiceEdicaoSteps]
        
        //INSTANCIA A BARRA DE PROGRESSO
        $('#steps').progressbar({
            steps: steps
        });
        
        if(statusAtual == "Assinaturas finalizadas"){
            $("#buttonDownload").removeAttr("disabled");
        }
        
        helper.eventsAfterPreenche(cmp, event, helper);
        
    },
    
    eventsAfterPreenche: function(cmp, event, helper){
        
        //EVENTO DE CLIQUE NO BOTAO DOWNLOAD
        $("#buttonDownload").click(function(){
            helper.downloadDocumento(cmp, event, helper);
        });
        
        //EVENTO DE CLIQUE NO BOTAO DOWNLOAD
        $("#buttonCancela").click(function(){
            helper.cancelaDocumento(cmp, event, helper);
        });
        
        $(".current").on("click", function(){
            var fase = $(this).html()
            //helper.consultaSignatarios(cmp, event, helper, fase);
        });
    },
    
    generateChart: function(component, event, helper, graphData, noInicio) {

        // Dimensões do gráfico
        var width = 1200;
        var height = 300;
        
        // Obter limites dos nós
        var minX = d3.min(graphData.nodes, function(d) { return d.x; });
        var maxX = d3.max(graphData.nodes, function(d) { return d.x; });
        var minY = d3.min(graphData.nodes, function(d) { return d.y; });
        var maxY = d3.max(graphData.nodes, function(d) { return d.y; });
        
        // Calcular o centro do gráfico
        var centerX = (minX + maxX) / 2;
        var centerY = (minY + maxY) / 2;
        
        // Calcular a escala inicial
        var scaleX = width / (maxX - minX);
        var scaleY = height / (maxY - minY);
        var scale = Math.min(scaleX, scaleY);
        
        // Criar elemento SVG
        var svg = d3.select(component.find("graphContainer").getElement())
            .append("svg")
            .attr("width", width)
            .attr("height", height)
        	.attr("transform", "translate(" + width / 2 + "," + height / 2 + ") scale(" + scale + ") translate(" + (-centerX) + "," + (-centerY) + ")");

        // Criar a simulação do gráfico de força direcionada
        var simulation = d3.forceSimulation(graphData.nodes)
            .force("link", d3.forceLink(graphData.links).id(function(d) { return d.id; }).distance(150))
            .force("charge", d3.forceManyBody().strength(-200)) // Defina a força de repulsão entre os nós (ajuste conforme necessário)
            .force("center", d3.forceCenter(width / 2, height / 2))
            .force("collide", d3.forceCollide(100)) // Defina o raio de colisão dos nós (ajuste conforme necessário)
            .force("horizontal", d3.forceX().strength(-0.06)) // Força de separação horizontal (ajuste conforme necessário)
            .on("tick", ticked);

        // Criar links do gráfico
        var links = svg.selectAll("line")
            .data(graphData.links)
            .enter()
            .append("line")
            .style("stroke", "gray")
            .style("stroke-width", 1);

                // Criar nós do gráfico
        var nodes = svg.selectAll("g")
            .data(graphData.nodes)
            .enter()
            .append("g")
            .call(d3.drag()
                .on("start", dragStarted)
                .on("drag", dragged)
                .on("end", dragEnded));

        // Adicionar links clicáveis aos nós
        nodes.append("a")
            .attr("href", function(d) { return d.url; }) // Defina a propriedade "url" do nó como o link desejado
            .append("circle")
            .attr("r", 10)
            .style("fill", "#10385d");

        nodes.append("text")
            .attr("dx", 15)
            .attr("dy", 4)
            .text(function(d) { return d.name; });

        function ticked() {
            links
                .attr("x1", function(d) { return d.source.x; })
                .attr("y1", function(d) { return d.source.y; })
                .attr("x2", function(d) { return d.target.x; })
                .attr("y2", function(d) { return d.target.y; });

            nodes.attr("transform", function(d) {
                return "translate(" + d.x + "," + d.y + ")";
            });
        }

        function dragStarted(d) {
            if (!d3.event.active) simulation.alphaTarget(0.3).restart();
            d.fx = d.x;
            d.fy = d.y;
        }

        function dragged(d) {
            d.fx = d3.event.x;
            d.fy = d3.event.y;
        }

        function dragEnded(d) {
            if (!d3.event.active) simulation.alphaTarget(0);
            d.fx = null;
            d.fy = null;
        }
    },
    
    consultaSignatarios: function(cmp, event, helper, fase){
        
        //Exibe Spinner de carregamento
        helper.showSpinner(cmp);
        
        //CHAMA A FUNÇÃO
        var action = cmp.get("c.consultar");
        var recordId = cmp.get("v.recordId")
        
        //DEFINE OS PARÂMETROS PASSADOS PARA CLASSE APEX-----
        action.setParams({
            idContrato: recordId
        });
        //----------------------------------------------------
        
        //CALLBACK DA REQUISIÇÃO---------------------------
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var respostaJson = JSON.parse(response.getReturnValue());
                var signatarios = respostaJson.document.signers;
                
                console.log(signatarios);
                
                switch(fase) {
                    case "Assinatura do cliente":
                        var faseNum = 1;
                        break;
                    case "Aprovação financeira":
                        var faseNum = 2;
                        break;
                    case "Assinatura do administrador":
                        var faseNum = 3;
                        break;
                    default:
                        var faseNum = 0;
                        console.log("ERROR SWITCH CASE")
                        break;
                };
                
                const agrupadoPorGrupo = signatarios.reduce((agrupado, elemento) => {
                    if (!agrupado[elemento.group]) {
                    agrupado[elemento.group] = [];
                };
                                                            agrupado[elemento.group].push(elemento);
                return agrupado;
            }, {});
            
            
            console.log(agrupadoPorGrupo);
            console.log(agrupadoPorGrupo[faseNum]);
            
            //LIMPA OS DADOS DO MODAL E ADICIONA NOVAMENTE
            $("#bodyModalFase").empty()
            
            for (key in agrupadoPorGrupo[faseNum]) {
                if(agrupadoPorGrupo[faseNum][key].hasOwnProperty("signature")){var status = " -> ASSINADO"}else{var status = " -> NÃO ASSINADO"}
                
                $("#bodyModalFase").append(agrupadoPorGrupo[faseNum][key].name + status + "<br>")
            }
            
            //EXIBE O MODAL
            $("#modalStatusFase").css("display", "flex");
            
            //EVENTO DE CLIQUE NO BOTAO FECHAR
            $("#closeModalFase").click(function(){
                $("#modalStatusFase").css("display", "none");
            });
            

            
            
            
            helper.hideSpinner(cmp);
                //helper.alertaErro(cmp, event, helper, "DOCUMENTO CANCELADO!", "SUCESSO", "success", "Operação concluída!", "dismissable")
            }
            else if (state === "INCOMPLETE") {
                helper.alertaErro(cmp, event, helper, "ERRO DURANTE O CANCELAMENTO", "CANCELAMENTO INCOMPLETO", "error", "Erro: ", "sticky")
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors && errors[0] && errors[0].message) {
                    helper.alertaErro(cmp, event, helper, errors[0].message, "ERRO AO CANCELAR DOCUMENTO", "error", "Erro: ", "sticky")
                    reject(errors[0].message);
                } else {
                    helper.alertaErro(cmp, event, helper, "ERRO DESCONHECIDO", "OCORREU UM ERRO DESCONHECIDO", "error", "Erro: ", "sticky")
                    reject("Erro desconhecido");
                }
            }
        });
        
        $A.enqueueAction(action);
    },
    
    alertaErro: function (cmp, event, helper, title, tipoMensagem, type) {
        console.log("exibindo erro")
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": tipoMensagem,
            "type": type,
            "mode": 'sticky'
        });
        toastEvent.fire();
    },
    
})