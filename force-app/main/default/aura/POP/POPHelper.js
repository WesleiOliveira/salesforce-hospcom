({
    recordId: '',
    elaborador: '',
    revisor: '',
    ListaEMpresas: [],
    status: false,
    selectedInstrucoesIds: [],
    
    helperMethod : function(cmp, event, helper) {
        $("#button12312321").on( "click", function() {
            $("#principalDiv342344").css("display", "flex")
            $("#button12312321").css("display", "none");
        });
        
        
        helper.recordId = cmp.get("v.recordId");
        
        helper.consoleLog(cmp, event, helper);
        helper.next(cmp, event, helper);
        var recordId = cmp.get("v.recordId");
        
        
        var query = "SELECT Id, Name FROM User WHERE IsActive = true"
        console.log(query);
        //REALIZA A CONSULTA
        this.soql(cmp, query)
        
        
        //QUANDO A SOLICITAÇÃO FOR CONCLUÍDA, FAÇA:
        .then(function (ids) {
            var nomes = ids.sort((a, b) => a.Name.localeCompare(b.Name));
            
            nomes.forEach(function(resultado){
                $("#revisorPop").append("<option data-id='"+ resultado.Id+"' value='"+ resultado.Id+"'>"+ resultado.Name +"</option>")
            });
            
            nomes.forEach(function(resultado){
                $("#elaboradorPop").append("<option data-id='"+ resultado.Id+"' value='"+ resultado.Id+"' >"+ resultado.Name +"</option>")
            });
        })
        //trata excessão de erro
        .catch(function (error) {
            console.log(error);
        });
        
        helper.insersaoiInicial(cmp, event, helper);
        
        var a = helper.verificaEnvio(cmp, event, helper);
        console.log(a);
        
        $('.revisorPop').selectpicker({
            dropupAuto: false  
        });
        
        $('.elaboradorPop').selectpicker({
            dropupAuto: false  
        });
        
        
    },
    
    insersaoiInicial: function(cmp, event, helper){
        
        //DEFINE A QUERY DE CONSULTA NO SALESFORCE
        var query = "SELECT Id, Instru_o_de_Servi_oText__c, Nome_do_Procedimento__c, Setor_do_Procedimento__c, rea_do_Procedimento__c, Objetivo__c, Aplica_o__c,T_tulo_do_Documento__c, Natureza_da_Altera_o__c, Responsabilidade_e_Autoridade__c, Defini_es__c, Equipamentos_e_Softwares__c,  Formul_rios_Anexos_e_Documentos__c, Condi_es_Gerais__c, Condi_es_Espec_ficas__c, Aprovado_por__c, C_digo_do_Documento__c, Aprovador__r.Name,Aprovador__c, Data_da_Ultima_Revis_o__c	, Data_de_Cria_o__c, Departamentos_que_possuem_c_pias__c, Direitos_de_reprodu_o__c, Elaborador__r.Name, Elaborador__c, Empresas__c, Ger_ncia_Administrativa__c, LastModifiedById,CurrencyIsoCode, N_da_Revis_o__c, N_o_aplic_vel__c, Observa_o_Revis_o__c, Procedimento_em_vigencia__c, Qualidade__c, Recursos_Humanos__c, Revisor__c, Revisor__r.Name, Solicita_o_reprovada__c, Status__c, Name, Usu_rio__c  FROM POP__c WHERE id='"+helper.recordId +"'";
        
        //REALIZA A CONSULTA
        this.soql(cmp, query)
        
        //QUANDO A SOLICITAÇÃO FOR CONCLUÍDA, FAÇA:
        .then(function (pop) {             
            console.log('POP: ',pop);
            pop.forEach(popAtual => {
                
                helper.revisor =  popAtual.Revisor__c;
                helper.elaborador = popAtual.Elaborador__c;
                console.log("Status pop atual: " , popAtual.Status__c);                   
                console.log("ELABORADOR: ", helper.elaborador);
                $("#elaboradorPop").val(helper.elaborador);
                console.log("REVISOR: ", helper.revisor);
                $("#revisorPop").val(helper.revisor);        
                $("#T_tulo_do_Documento__cPop").val(popAtual.T_tulo_do_Documento__c);
                $("#Natureza_da_Altera_o__cPop").val(popAtual.Natureza_da_Altera_o__c);
                $("#C_digo_do_Documento__cPop").val(popAtual.C_digo_do_Documento__c);
                $("#N_da_Revis_o__cPop").val(popAtual.N_da_Revis_o__c);
                $("#Objetivo__cPop").val(popAtual.Objetivo__c);
                $("#Aplica_o__cPop").val(popAtual.Aplica_o__c);
                $("#Defini_es__cPop").val(popAtual.Defini_es__c);
                $("#Condi_es_Gerais__cPop").val(popAtual.Condi_es_Gerais__c);
                $("#Condi_es_Espec_ficas__cPop").val(popAtual.Condi_es_Espec_ficas__c);
                $("#Equipamentos_e_Softwares__cPop").val(popAtual.Equipamentos_e_Softwares__c);
                $("#Responsabilidade_e_Autoridade__cPop").val(popAtual.Responsabilidade_e_Autoridade__c);
                $("#Formul_rios_Anexos_e_Documentos__cPop").val(popAtual.Formul_rios_Anexos_e_Documentos__c);         
                cmp.set("v.instrucaoText", popAtual.Instru_o_de_Servi_oText__c);
                
                
                helper.ListaEMpresas = popAtual.Empresas__c.split(";");
                
                console.log("Empresa: ", helper.ListaEMpresas);
                helper.ListaEMpresas.forEach(function(empresaNome){
                var empresaAtual = "#" + empresaNome.trim(); 
                console.log("Empresa: ", empresaAtual);
                $(empresaAtual).click();
                
            });
                
                if (popAtual.Status__c !== "Em vigência") {
                $("#delitePop").css('display', 'none');
            }
                if(popAtual.Status__c !== "Elaboração"){
                $("#principalDiv12345").css('display', 'none');
            }
                
            });
                
                //helper.listaDeOpcoes(cmp, event, helper);
                
                //console.log("FINAL", helper.empresas)
            })
                //trata excessão de erro
                .catch(function (error) {
                console.log("Erro: ", error);        
            })
            },                 
                consoleLog : function(cmp, event, helper){
                    console.log("Inicio Função consoleLog");
                    $(".empresa").on("change", function() {
                        if ($(this).is(":checked")) {
                            // checkbox foi marcada
                            $(this).siblings("label").css("width", "130px");
                            $(this).siblings("label").css("margin-top", "-40px");
                            $(this).siblings("label").css("background", "#f2f2f2");
                            $(this).siblings("label").css("border-radius", "20px");
                        } else {
                            // checkbox foi desmarcada
                            $(this).siblings("label").css("width", "130px");
                            $(this).siblings("label").css("margin-top", "0px");
                            $(this).siblings("label").css("background", "none");
                        }
                        console.log("Fim Função consoleLog");
                    });
                },
                adicionarTag: function(cmp, event, helper) {
                    helper.recordId = cmp.get("v.recordId");
                    console.log("Id: ", helper.recordId);
                    
                    var selected = cmp.get("v.selectedInstrucoes");
                    var itemId = event.currentTarget.getAttribute("data-id");
                    var items = cmp.get("v.instrucoesDeServico");
                    
                    var selectedItem = items.find(function(item) {
                        return item.Id === itemId;
                    });
                    
                    if(!selected.some(item => item.Id === itemId)) {
                        selected.push(selectedItem);
                        cmp.set("v.selectedInstrucoes", selected);
                        helper.selectedInstrucoesIds.push(itemId); // Armazena o ID
                    }
                    $("#resultados12312312").css("display", "none");
                    cmp.set("v.searchTerm", "");
                },
                
                removerTag: function(cmp, event, helper) {
                    var tagId = event.currentTarget.getAttribute("data-tagid");
                    var selected = cmp.get("v.selectedInstrucoes");
                    
                    var newSelected = selected.filter(function(item) {
                        return item.Id !== tagId;
                    });
                    
                    cmp.set("v.selectedInstrucoes", newSelected);
                    helper.selectedInstrucoesIds = helper.selectedInstrucoesIds.filter(id => id !== tagId); // Remove o ID
                },
                // função para buscar instruções de serviço
                buscaIs : function(cmp, event, helper) {
                    
                    console.log("BUSCA IS")
                    var termo = cmp.get("v.searchTerm")
                    
                    var query = "SELECT Id, Name, Departamento__c " +
                        "FROM Instrucao_de_Servico__c " +
                        "WHERE Name LIKE '%" + termo + "%' " +
                        "LIMIT 5";
                    
                    console.log(query)
                    
                    //REALIZA A CONSULTA
                    helper.soql(cmp, query)
                    
                    
                    //QUANDO A SOLICITAÇÃO FOR CONCLUÍDA, FAÇA:
                    .then(function (menus) {
                        
                        var maxLength = 30;
                        
                        menus.forEach(function (is) {
                            if (is.Name && is.Name.length > maxLength) {
                                console.log("Passou aqui");
                                is.Name = is.Name.substring(0, maxLength) + "...";
                            }
                            
                        });
                        
                        
                        $("#resultados12312312").css("display", "flex")
                        cmp.set("v.instrucoesDeServico", menus);
                        
                        $(".is12312312").on( "click", function() {
                            var id = $(this).attr("data-id")
                            var recordId = cmp.get("v.recordId");
                            
                            console.log("CLIQUE ADD", id);
                            
                            
                            
                        });
                    })
                    
                    //trata excessão de erro
                    .catch(function (error) {
                        console.log(error)
                    })
                    
                },
                next: function(cmp, event, helper) {
                    console.log("Inicio Função next");
                    var semRepetidos = [];
                    var empresas = [];
                    var empresa = {}
                    var pop = {};
                    var selectedIds = helper.selectedInstrucoesIds;
                    var arquivos = []; // Array de objetos
                    
                    if (window.FileReader) {
                        // Quando o valor do input file é alterado
                        $('#documentoPop').on('change', function(e) {
                            var files = e.target.files; // Obtém os arquivos selecionados
                            
                            for (var i = 0; i < files.length; i++) {
                                var filea = files[i]; // Obtém um arquivo
                                
                                // Cria uma instância do objeto FileReader
                                var reader = new FileReader();
                                
                                // Função que será chamada quando o arquivo for lido
                                reader.onload = function(event) {
                                    // base64File.push( event.target.result.split(',')[1]) // Obtém a string em base64
                                    //fileExtension.push(file.name.split('.').pop()) // Obtém a extensão do 
                                    
                                    var arquivoIndividual={};
                                    
                                    console.log(event.target.result.split(','));
                                    
                                    arquivoIndividual.file = event.target.result.split(',')[1];
                                    arquivoIndividual.ex = filea.name.split('.').pop();
                                    
                                    
                                    arquivos.push(arquivoIndividual); // Adiciona o objeto ao array de 
                                    // Faça o que desejar com a string em base64
                                };
                                
                                reader.readAsDataURL(filea);
                            }
                            
                        });
                    }
                    
                    const textAreas = document.querySelectorAll('.texto textarea');
                    const characterCounts = document.querySelectorAll('.character-count');
                    
                    function updateCharacterCount() {
                        textAreas.forEach((textarea, index) => {
                            characterCounts[index].textContent = textarea.value.length;
                        });
                        }
                            function checkInputLength(textarea, maxLength) {
                            if (textarea.value.length > maxLength) {
                            alert(`O texto excedeu o limite de ${maxLength} caracteres.`);
                        }
                        }    
                            textAreas.forEach((textarea) => {
                            textarea.addEventListener('input', updateCharacterCount);
                        });
                            
                            $("#nextPop").click(function() {
                            var codigoDoc = $("#C_digo_do_Documento__cPop").val();
                            var tituloDoc = $("#T_tulo_do_Documento__cPop").val();
                            
                            console.log($("#T_tulo_do_Documento__cPop").val());
                            console.log($("#C_digo_do_Documento__cPop").val());
                            
                            if (codigoDoc != null && tituloDoc != '') {
                            $("#Revisor__cPop").val($("#revisorPop").val());
                            $("#Elaborador__cPop").val($("#elaboradorPop").val());
                            
                            try {
                            // Coletar empresas selecionadas
                            $(".i").each(function() {
                            if ($(this).is(":checked")) {
                            empresa = {
                            id: this.value, // ID da empresa
                            nome: $(this).attr('id') // Nome da empresa (ID do checkbox)
                        };
                                          empresas.push(empresa);
                    }
                });
                
                semRepetidos = empresas;
                empresas = [];
                
                // Coletar valores dos campos de texto
                $(".Texto").each(function() {
                if (this.value != "" && this.value != undefined && this.value != null) {
                var campoS = $(this).siblings("p").data('campos');
                var campo = campoS;
                var valor = $(this).val();
                pop[campo] = valor;
                console.log("Campo preenchido: ", campo, valor);
            }
                        });
            
            pop['Nome_do_Procedimento__c'] = "area";
            pop['Status__c'] = "Em aprovação";
            pop['Id'] = helper.recordId;
            console.log("Dados do POP: ", pop);
            
            console.log("Empresas selecionadas: ", semRepetidos);
            console.log("Arquivos: ", arquivos);
            console.log("Instrução de serviço: ", selectedIds);
            
            // Chamar o método Apex
            var action = cmp.get("c.criaPOP");
            action.setParams({
                empresasR: semRepetidos,
                pop: pop,
                documentos: arquivos,
                lmdID: 'a0gU4000003SL1OIAW',
                instrucoesIds: selectedIds
            });
            
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    helper.exibirAlerta(cmp, event, helper, "success", "Sucesso", "Documento atualizado com sucesso!");
                    console.log("Sucesso");
                    location.reload();
                    
                } else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        $(".load").css("display", "none");
                        helper.exibirAlerta(cmp, event, helper, "error", "Error", "Falha ao tentar atualizar: " + errors[0].message);
                        console.log("Erro: " + errors[0].message);
                    } else {
                        $(".load").css("display", "none");
                        helper.exibirAlerta(cmp, event, helper, "error", "Error", "Falha ao tentar atualizar: Erro desconhecido.");
                        console.log("Erro desconhecido.");
                    }
                }
            });
            
            $A.enqueueAction(action);
        } catch (ex) {
            $(".load").css("display", "none");
            console.log("Erro ao executar ação: " + ex.message);
        }
    } else {
    console.log('Error!!!!! ');
    helper.exibirAlerta(cmp, event, helper, "error", "Error", "Falha ao tentar atualizar: Os campos de 'Título do Documento' e 'Código do Documento' são obrigatórios.");
}
 });                            
console.log("Fim da função next");
},
    verificaEnvio: function(cmp, event, helper){
        
    },
        exibirAlerta : function(component, event, helper, type, title, message) {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "type" : type,
                "title": title,
                "message": message
            });
            toastEvent.fire();
        }

})