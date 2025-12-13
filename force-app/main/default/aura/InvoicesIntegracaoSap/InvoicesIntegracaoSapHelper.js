({
    mainFunction: function (cmp, event, helper) {     
                               
        
        
        
        
        /*
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        
        if(userId === '00531000006UzZsAAK'){
            $('.main-container').css('display', 'flex');
            
        }else{
            $('.imagem').css('display', 'flex');
        }
        console.log(userId);
        */
        
        const dataFaturamentoInput = document.getElementById("dataFaturamento");
        const filtrarDataButton = document.getElementById("filtrarDataButton");
        
        function buscarPedidos(numeroPedido = null, dataFaturamento = null) {
            let query = "SELECT Id, OrderNumber, Agendado__c, Status, Contrato_de_Servi_o__r.N_mero_da_Proposta_Contrato__c, Faturamento_Feito__r.Raz_o_Social__c, Contrato_de_Servi_o__r.Status_do_Contrato__c, Account.Name, TotalAmount, Prazo_de_entrega__c, Vendedor__r.FirstName, Contrato_de_Servi_o__r.Regiao_Nome__c, Natureza_de_Opera_o__c FROM Order WHERE Status = 'Ativo' AND Natureza_de_Opera_o__c = 'LOCAÇÃO' AND FaturadoSap__c = false";
            if (numeroPedido) {
                query += ` AND OrderNumber = '${numeroPedido}'`;
            }
            if (dataFaturamento) {
                query += ` AND Contrato_de_Servi_o__r.Data_de_In_cio_do_Contrato__c = ${dataFaturamento}`;
            }
            
            helper.soql(cmp, query)
            .then(function (resultados) {
                const listaPedidos = document.getElementById("listaPedidos") 
                listaPedidos.id = "listaPedidos";
                listaPedidos.innerHTML = "";  
                console.log("lista de pedidos para faturar", listaPedidos)
                resultados.forEach(pedido => {
                    const row = document.createElement("tr");
                    const checkboxCell = document.createElement("td");
                    const checkbox = document.createElement("input");
                    checkbox.type = "checkbox";
                    checkbox.classList.add("pedido-checkbox");
                    checkbox.value = pedido.Id;
                    checkbox.style.width = "20px";
                    checkbox.style.height = "20px";
                    
                    
                    if(pedido.Agendado__c){
                    checkbox.checked = true;
                    checkbox.disabled = true;
                }
                                   
                                   checkbox.onclick = event => event.stopPropagation();
                checkboxCell.appendChild(checkbox);
                
                
                
                
                if (pedido.Status === 'Agendado') {
                    row.classList.add('agendado');
                    checkbox.disabled = true;
                }
                function formatarData(data) {
                    const dataObj = new Date(data);
                    const dia = String(dataObj.getDate()).padStart(2, '0');
                    const mes = String(dataObj.getMonth() + 1).padStart(2, '0'); 
                    const ano = String(dataObj.getFullYear()); 
                    return `${dia}-${mes}-${ano}`;
                }
                //////////////////////////////
                // Função para buscar os pedidos faturados
                function buscarPedidosFaturados() {
                    let query = "SELECT Id, OrderNumber, FaturadoSap__c FROM Order WHERE FaturadoSap__c = true LIMIT 1";
                    console.log("let query pedidos faturados", query);
                    helper.soql(cmp, query)
                    .then(function (resultados) {
                        const listaPedidos = document.getElementById("pedidos-faturados");
                        const quantidadePedidos = document.getElementById("quantidade-pedidos");
                        listaPedidos.innerHTML = "";
                        quantidadePedidos.textContent = resultados.length;
                        
                        if (resultados.length === 0) {
                            listaPedidos.innerHTML = "<p>Nenhum pedido faturado encontrado.</p>";
                            return;
                        }
                        
                        resultados.forEach((pedido) => {
                            const divPedido = document.createElement("div");
                            divPedido.classList.add("pedido");
                            divPedido.dataset.numero = pedido.OrderNumber.toLowerCase();
                            divPedido.innerHTML = `
                            <p>Nº PV: 
                            <a href="https://hospcom.my.site.com/Sales/s/order/${pedido.Id}/detail" target="_blank"> 
                            ${pedido.OrderNumber}
                                           </a>
                                           </p>
                                           `;
                                           
                                           listaPedidos.appendChild(divPedido);
                    });
                })
                .catch(function (erro) {
                    console.error("Erro ao buscar pedidos: ", erro);
                });
            }
                  
                  function filtrarPedidos() { 
                const termo = document.getElementById("buscar-pedido").value.toLowerCase().trim();
                const pedidos = document.querySelectorAll("#pedidos-faturados .pedido"); // Pegando os pedidos reais
                const listaFiltrada = document.getElementById("pedidos-filtrados"); 
                const listaPedidos = document.getElementById("pedidos-faturados");
                
                listaFiltrada.innerHTML = ""; // Limpa os resultados anteriores
                
                if (termo === "") {
                    // Se o campo estiver vazio, mostra a lista original e esconde a filtrada
                    listaPedidos.style.display = "flex";
                    listaFiltrada.style.display = "none";
                    return;
                }
                
                let count = 0;
                
                pedidos.forEach(pedido => {
                    if (pedido.dataset.numero.includes(termo)) {
                    const divClone = pedido.cloneNode(true); // Clonar o pedido
                    listaFiltrada.appendChild(divClone); // Adicionar na lista filtrada
                    count++;
                }
                                });
                
                if (count > 0) {
                    listaPedidos.style.display = "none";  // Esconder lista original
                    listaFiltrada.style.display = "flex"; // Mostrar lista filtrada
                } else {
                    listaFiltrada.innerHTML = "<p>Nenhum pedido encontrado.</p>";
                    listaPedidos.style.display = "none"; 
                    listaFiltrada.style.display = "flex";
                }
            }
            
            // Evento para detectar mudanças no input e atualizar a lista dinamicamente
            document.getElementById("buscar-pedido").addEventListener("input", filtrarPedidos);
            
            // Ouvinte para Enter no campo de busca
            document.getElementById("buscar-pedido").addEventListener("keydown", function(event) {
                if (event.key === "Enter") {
                    filtrarPedidos();
                }
            });
            
            // Ouvinte para clique no botão de pesquisa
            document.getElementById("btn-pesquisar").addEventListener("click", filtrarPedidos);
            
            
            // Carregar os pedidos faturados ao iniciar
            buscarPedidosFaturados();
            
            
            
            
            
            
            
            
            /////////////////////////////
            
            function formatarValor(valor) {
                return valor.toLocaleString('pt-BR', { style: 'currency', currency: 'BRL' });
            }
           const numeroProposta =  pedido.Contrato_de_Servi_o_r ? pedido.Contrato_de_Servi_or.N_mero_da_Proposta_Contrato_c : ""
           const empresaHosp = pedido.Faturamento_Feito__r.Raz_o_Social__c.slice(0,5);

            const servico =  '';
            const firstname =  '';
            const contrato =  '';
            
            row.innerHTML = `
            <td>${numeroProposta}</td>
            <td>${pedido.Account.Name}</td>
            <td><a href="https://hospcom.my.site.com/Sales/s/order/${pedido.Id}/detail" target="_blank">${pedido.OrderNumber}</a></td>
                <td>${formatarValor(pedido.TotalAmount)}</td>
                <td>${empresaHosp}...</td>
                <td>${servico}</td>
                <td>${firstname}</td>
                <td>${contrato}</td>
                <td>${formatarData(pedido.Prazo_de_entrega__c)}</td>
                `;
            
            
            row.insertBefore(checkboxCell, row.firstChild);
            
            
            row.addEventListener('mouseover', function() {
                row.classList.add('selected-row');
            });
            
            row.addEventListener('mouseout', function() {
                row.classList.remove('selected-row');
            });
            
            row.addEventListener('click', function() {
                if (!row.classList.contains('agendado')) {
                    checkbox.checked = !checkbox.checked; 
                    row.classList.toggle('row-checked', checkbox.checked); 
                }
            });
            
            
            listaPedidos.appendChild(row);
        });
    })
    .catch(function (error) {
    console.log(error);
});
}    
buscarPedidos();    
const pesquisarButtons = document.getElementById("pesquisarButton");
const filtrarDataButtons = document.getElementById("filtrarDataButton");
const integrarButton = document.getElementById("integrarPedidos");
const numeroPedidoInputs = document.getElementById("numeroPedido");
const dataFaturamentoInputs = document.getElementById("dataFaturamento");

pesquisarButtons.addEventListener("click", function () {
    const numeroPedido = numeroPedidoInputs.value.trim(); 
    const dataFaturamento = dataFaturamentoInputs.value;
    
    if (!numeroPedido && !dataFaturamento) {
        
        buscarPedidos(null, null);
    } else {
        console.log("Data de Faturamento:", dataFaturamento);
        buscarPedidos(numeroPedido || null, dataFaturamento || null);
    }
});


filtrarDataButtons.addEventListener("click", function () {
    const dataFaturamento = dataFaturamentoInputs.value
    ? new Date(dataFaturamentoInputs.value).toISOString().split('T')[0]
    : null; 
    
    if (!dataFaturamento) {
        
        buscarPedidos(null, null);
    } else {
        console.log("Data de Faturamento:", dataFaturamento);
        buscarPedidos(null, dataFaturamento);
    }
});


numeroPedidoInputs.addEventListener("input", verificarCampos);
dataFaturamentoInputs.addEventListener("input", verificarCampos);

function verificarCampos() {
    const numeroPedido = numeroPedidoInputs.value.trim();
    const dataFaturamento = dataFaturamentoInputs.value;
    
    
    if (!numeroPedido && !dataFaturamento) {
        
        buscarPedidos(null, null);
    }
}



integrarButton.addEventListener("click", function () {
    
     helper.alertaErro(cmp, event, helper, "Aguarde", "Carregando01...", "Carregando01");
    
    const pedidosSelecionados = Array.from(document.querySelectorAll(".pedido-checkbox:checked")).map(cb => cb.value);
    console.log("Pedidos selecionados: ", pedidosSelecionados);
    var isDocumentUploaded = cmp.get("v.isDocumentUploaded");
    
    if (pedidosSelecionados.length === 0) {
        helper.alertaErro(cmp, event, helper, 'Erro', 'Nenhum pedido selecionado.', 'error');
        return;
    }
    
   // if(!isDocumentUploaded){
    //    helper.alertaErro(cmp, event, helper, 'Erro', 'Anexe um documento para faturar.', 'error');
    //    return;
   // }
    
    $("#spinnerPopupDiv").show();
    
    var obj = cmp.get("v.DocumentoComPedidoId");
    helper.gerarLinks(cmp, event, helper, pedidosSelecionados, obj);       
    
});

function atualizarLocalStorage() {
    const checkboxes = document.querySelectorAll(".pedido-checkbox:not(:disabled)");
    const idsSelecionados = Array.from(checkboxes)
    .filter(checkbox => checkbox.checked)
    .map(checkbox => checkbox.value);
    localStorage.setItem('pedidosSelecionados', JSON.stringify(idsSelecionados));
}


// Ao clicar em um checkbox, atualize o localStorage
document.addEventListener('change', function (event) {
    if (event.target.matches('.pedido-checkbox')) {
        atualizarLocalStorage();
    }
});

// Restaura o estado dos checkboxes ao carregar a página
window.addEventListener('load', function () {
    const pedidosSelecionados = JSON.parse(localStorage.getItem('pedidosSelecionados')) || [];
    pedidosSelecionados.forEach(id => {
        const checkbox = document.querySelector(`.pedido-checkbox[value="${id}"]`);
        if (checkbox) {
        checkbox.checked = true;
        if (checkbox.closest('tr').classList.contains('agendado')) {
        checkbox.disabled = true; // Mantenha o estado desativado
    }
                                }
                                });
});

const agendarButton = document.getElementById("agendarPedidos");
const modal = document.getElementById("calendarModal");
const closeModal = document.querySelector(".close");
const confirmDateButton = document.getElementById("confirmDateButton");

agendarButton.addEventListener("click", function () {
    
    modal.style.display = "block";
});


closeModal.addEventListener("click", function () {
    modal.style.display = "none";
});


window.addEventListener("click", function (event) {
    if (event.target == modal) {
        modal.style.display = "none";
    }
});


confirmDateButton.addEventListener("click", function () {
    const selectedDate = document.getElementById("agendarDate").value;
    
    if (!selectedDate) {
        alert("Por favor, selecione uma data.");
        return;
    }
    
    modal.style.display = "none"; 
    
    // const pedidosSelecionados = Array.from(document.querySelectorAll(".pedido-checkbox:checked")).map(cb => cb.value);
    const pedidosSelecionados = Array.from(document.querySelectorAll(".pedido-checkbox:checked"))
    .filter(cb => !cb.disabled) // Filtra os que não estão desabilitados
    .map(cb => cb.value);
    if (pedidosSelecionados.length === 0) {
        helper.alertaErro(cmp, event, helper, 'Erro', 'Nenhum pedido selecionado para agendar.', 'error');
        return;
    }
    
    $("#spinnerDiv").show();
    fetch('https://integracao.hospcom.net/fauras/agendadas', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({ 
            pedidoIds: pedidosSelecionados, 
            dataAgendamento: selectedDate 
        })
    })
    .then(response => response.json())
    .then(result => {
        helper.alertaErro(cmp, event, helper, 'Sucesso!', 'Pedidos agendados para faturamento.', 'success');
        
        // Desabilita e marca o checkbox como fixado
        pedidosSelecionados.forEach(id => {
        const checkbox = document.querySelector(`.pedido-checkbox[value="${id}"]`);
        if (checkbox) {
        checkbox.disabled = true;
        checkbox.checked = true;
        const row = checkbox.closest('tr');
        row.classList.add('agendado');
    }
    });
        
        $("#spinnerDiv").hide();
    })
        .catch(error => {
       helper.alertaErro(cmp, event, helper, 'Erro ao agendar', 'Ocorreu um erro ao agendar pedidos.', 'error');
        $("#spinnerDiv").hide();
    });
    });
        
        /////////
        
        
    },
        
        //Cria registro de DocumentoEPedido__c e relaciona os pedidos.       
        criaRegistroRelacionemnto: function(cmp, event, helper, pedidosSelecionados) {
            // Chama o método Apex "DocumentoEPedido"
            var action = cmp.get("c.DocumentoEPedido");
            
            // Passa o array de pedidos selecionados como parâmetro
            action.setParams({
                pedidosIds: pedidosSelecionados
            });
            
            action.setCallback(this, function(response) {
                var state = response.getState();
                console.log("state", state)
                if (state === "SUCCESS") {
                    var docId = response.getReturnValue();                    
                    cmp.set("v.DocumentoComPedidoId", docId);
                    console.log('DocumentoEPedido criado com sucesso. ID:', docId);
                    
                } else {
                    var errors = response.getError();
                    console.log("errors????????????????/?????????????", errors)
                    console.error('Erro ao criar DocumentoEPedido:', errors);
                    helper.alertaErro(cmp, event, helper, 'Erro Relacionar pedidos', 'Ocorreu um erro ao relacionar pedidos.', 'error');
                }
            });
            
            // Executa a ação
            $A.enqueueAction(action);
        },
        
      excluiDocumentosERegistro: function(cmp, event, helper){
            //exclui documentos enviado
            var action = cmp.get("c.excluirDocumentoComArquivos");
            
            action.setParams({
                documentosEnviados: cmp.get("v.documentosEnviados"),
                documentoComPedidoId: cmp.get("v.DocumentoComPedidoId")
            });
            
            action.setCallback(this, function(response) {
                if (response.getState() === "SUCCESS") {
                    console.log("Registro e documentos excluídos com sucesso.");
                    cmp.set("v.isDocumentUploaded", false);
                    cmp.set("v.documentosEnviados", null);
                    cmp.set("v.DocumentoComPedidoId", null);
                    cmp.set("v.urlsGeradas", null);
                    cmp.set("v.documentsCount", 0);
                } else {
                    console.error("Erro ao excluir:", response.getError());
                }
            });
            
            $A.enqueueAction(action);
        },
        
        handleUploadFinished: function(cmp, event, helper){
            var uploadedFiles = event.getParam("files");
            var documentosEnviados = cmp.get("v.documentosEnviados"); // lista atual
            
            
            uploadedFiles.forEach(file => {
                documentosEnviados.push(file.documentId); // adiciona o novo ID
            });
                
                cmp.set("v.documentosEnviados", documentosEnviados); // salva de volta no componente
                cmp.set("v.isDocumentUploaded", true);
                
                console.log('Lista de documentos enviados:', documentosEnviados);
                
                cmp.set("v.documentsCount", documentosEnviados.length);
               
                
            },
              
    gerarLinks: function(cmp, event, helper, pedidosSelecionados, obj) {
                    console.log("gerarLinks() iniciado");
                    const documentos = cmp.get("v.documentosEnviados");
                    console.log("DocumentosId: ", documentos);
                    
                    const urlsGeradas = [];
                    
                    
                    const promises = documentos.map(docId => {
                        const url = "https://workflowwebhook.hospcom.net/webhook/8f0df25f-0177-4dc3-97d8-43f59b1fdf20";
                        const formData = new URLSearchParams();
                        formData.append("contentId", docId);
                       // helper.alertaErro(cmp, event, helper, "Aguarde11", "Carregando11...", "Carregando11");
                        return fetch(url, {
                        method: 'POST',
                        headers: {
                        'Content-Type': 'application/x-www-form-urlencoded'
                    },
                                                    body: formData.toString()
                    })
                .then(response => {
               
                if (!response.ok) {
                throw new Error('Erro na resposta');
            }
                                  return response.json();
        })
        .then(data => {
         // helper.alertaErro(cmp, event, helper, "Aguarde", "Carregando22...", "Carregando22");
        console.log("Link público:", data.ContentDownloadUrl);
        urlsGeradas.push(data.ContentDownloadUrl);
    })
    .catch(error => {
        console.error("Erro ao gerar o link ", error);
    });
    });
        
        Promise.all(promises).then(() => {
        console.log("Todos os links gerados:", urlsGeradas);
        
        // Salva no componente
        cmp.set("v.urlsGeradas", urlsGeradas);
        const listaEmails = cmp.get("v.emailList");
        console.log("emailList", listaEmails);
        
        //helper.alertaErro(cmp, event, helper, "Aguarde", "Carregando33...", "Carregando33");
        const action = cmp.get("c.atualizarCampoUrlComLista");
        console.log("Passou aqui");
        
        console.log("[DEBUG] Params para Apex:", {
        documentoEPedidoId: obj,
        urls: urlsGeradas,
        listaDeEmails: listaEmails
        });
        action.setParams({
       
        documentoEPedidoId: obj,
        urls: urlsGeradas,
        listaDeEmails: listaEmails 
        
    });
    console.log("rquerindo dados");
    
    action.setCallback(this, function(response) {
    

        console.log("response call back", response);
         // helper.alertaErro(cmp, event, helper, "Aguarde", "Carregando44...", "Carregando44");
        console.log("Iniciando promise para item:");
        const state = response.getState();
        console.log("state", state);
        if (state === "SUCCESS") {
            console.log("Campo atualizado com sucesso com lista de URLs");
           helper.faturarPedidos(cmp, event, helper, pedidosSelecionados);
            
        } else {
            console.error("Erro ao atualizar o campo url:", response.getError());
        }        
    });
   $A.enqueueAction(action);
});
},
    
    
    
    faturarPedidos : function(cmp, event, helper, pedidosSelecionados){
	//	helper.alertaErro(cmp, event, helper, "Aguarde", "Carregando...", "Carregando");
        fetch('https://integracao.hospcom.net/faturas/', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ pedidoIds: pedidosSelecionados })
        })
        .then(response => response.json())
        .then(result => {     
            console.log("Resultado SAP:", result);
            $("#spinnerPopupDiv").hide();                     
            console.log("Resultado SAP result:", result.data);
            const data11 = result.data.map(v => v.data);
            console.log("Resultado data data11:", data11);
            console.log("Resultado data data11:", data11[0]);
            if (result.status === 'error') {
            // Exibe a mensagem de erro na tela, considerando o erro no SAP
            const errorMessage = result.data || 'Erro desconhecido ao processar a fatura no SAP.';
            helper.alertaErro(cmp, event, helper, 'Erro', data11[0], 'error');
        } else if (result.status === 'não encontrado') {
            // Exibe a mensagem caso a fatura não tenha sido encontrada
            helper.alertaErro(cmp, event, helper, 'Erro', data11[0] || 'Fatura não encontrada', 'error');
        } else if (result.status === 'success') {
            // Exibe o sucesso se a integração for bem-sucedida
            helper.alertaErro(cmp, event, helper, 'Sucesso!', 'Faturas integradas com sucesso.', 'success');
            setTimeout(() => {
            window.location.reload();
        }, 2000); // Atualiza após 1,5 segundos
        } else {
            // Mensagem genérica para respostas inesperadas
            helper.alertaErro(cmp, event, helper, 'Erro', 'Resposta inesperada do servidor.', 'error');
        }
        })
            .catch(error => {        
            const errorMessage = error.message || 'Ocorreu um erro ao integrar pedidos.'; // A mensagem de erro pode ser do próprio objeto de erro
            console.log("error mensagem", errorMessage)
            helper.excluiDocumentosERegistro(cmp, event, helper);
            helper.alertaErro(cmp, event, helper, 'Erro ao integrar', errorMessage, 'error');
            $("#spinnerPopupDiv").hide();
        });
            
            
        },            
            renderPopUp: function(cmp, event, helper, pedidosSelecionados){
                const idsFormatados = pedidosSelecionados.map(id => `'${id}'`).join(',');
                const query = `SELECT Id, Numero_do_Pedido__c, Status, TotalAmount, Faturamento_Feito__r.Raz_o_Social__c, Account.Name FROM Order WHERE Id IN (${idsFormatados})`;
                
                helper.soql(cmp, query)
                .then(function(resultados) {
                    const tabela = document.querySelector(".tabelaPeidosEscolhidos table");
                    console.log("resultado dos pedidos selecionados#################", resultados);
                   
                    tabela.innerHTML = `
                    <tr>                    
                        <th>Pedido</th>
                    <th>Valor</th>
                    <th>Empresa</th>
                     <th>Status</th>
                    
                    
                    </tr>
                    `;                    
                    resultados.forEach(pedido => {
                        const linha = document.createElement("tr");
                        
                        const status = pedido.Status ? pedido.Status : "-";
                        const numeroPedido = pedido.Numero_do_Pedido__c || "-";
                        const empres = pedido.Faturamento_Feito__r.Raz_o_Social__c.slice(0,5) || "-";
                        const valor = pedido.TotalAmount != null
                        ? `R$ ${pedido.TotalAmount.toFixed(2).replace('.', ',')}`
                                       : "R$ 0,00";
                                       
                                       linha.innerHTML = `
                                       <td>${numeroPedido}</td>
                                       <td>${valor}</td>
                                       <td>${empres}...</td>
                                       <td>${status}</td>
                                       `;
                                       
                                       tabela.appendChild(linha);
                });
                $("#spinnerPopupDiv").hide();
            })
            .catch(function(erro) {
            console.error("Erro ao buscar pedidos selecionados: ", erro);
            $("#spinnerPopupDiv").hide();
        });
        
    },
        
        
        alertaErro: function (cmp, event, helper, title, tipoMensagem, type) {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": title,
                "message": tipoMensagem,
                "type": type,
                "mode": 'pester'//  "mode": 'sticky'
            });
            toastEvent.fire();
        }

})