({
    recordId: '',
    elaborador: '',
    revisor: '',
    ListaEMpresas: [],
    status: false,

    helperMethod: function (cmp, event, helper) {

        helper.recordId = cmp.get("v.recordId");
        helper.consleLog(cmp, event, helper);
        helper.next(cmp, event, helper);
        var recordId = cmp.get("v.recordId");

        var query = "SELECT Id, Name FROM User WHERE IsActive = true"
        console.log(query)
        //REALIZA A CONSULTA
        this.soql(cmp, query)

            //QUANDO A SOLICITAÇÃO FOR CONCLUÍDA, FAÇA:
            .then(function (ids) {
                var nomes = ids.sort((a, b) => a.Name.localeCompare(b.Name));

                nomes.forEach(function (resultado) {
                    $("#revisor").append("<option data-id='" + resultado.Id + "' value='" + resultado.Id + "'>" + resultado.Name + "</option>")
                });

                nomes.forEach(function (resultado) {
                    $("#elaborador").append("<option data-id='" + resultado.Id + "' value='" + resultado.Id + "' >" + resultado.Name + "</option>")
                });
            })
            //trata excessão de erro
            .catch(function (error) {
                console.log(error)
            })

        helper.insersaoiInicial(cmp, event, helper);



        var a = helper.verificaEnvio(cmp, event, helper);
        cosnsole.log(a)

        $('.revisor').selectpicker({
            dropupAuto: false
        });

        $('.elaborador').selectpicker({
            dropupAuto: false
        });


    },

    insersaoiInicial: function (cmp, event, helper) {

        //DEFINE A QUERY DE CONSULTA NO SALESFORCE
        var query = "SELECT Id, Objetivo__c, Aplicao__c,T_tulo_do_Documento__c, Natureza_da_Altera_o__c, Responsabilidade_e_Autoridade__c, Defini_es__c, Equipamentos_e_Softwares__c,  Formul_rios_Anexos_e_Documentos__c, Condi_es_Gerais__c, Refer_ncia__c, Registros__c, Aprovado_por__c, C_digo_do_Documento__c, Aprovador__r.Name,Aprovador__c, Data_da_Ultima_Revis_o__c	, Data_de_Cria_o__c, Departamentos_que_Possuem_C_pias__c, Direitos_de_reprodu_o__c, Elaborador__r.Name, Elaborador__c, Empresas__c, Ger_ncia_Administrativa__c, LastModifiedById ,CurrencyIsoCode, N_da_Revis_o__c, N_o_aplic_vel__c, Observa_o_Revis_o__c, Procedimento_do_Sistema_de_Qualidade__c, Qualidade__c, Recursos_Humanos__c, Revisor__c, Revisor__r.Name, Solicita_o_reprovada__c, Status__c, Name, Usu_rio__c ,Vigencia__c   FROM PSQ__c WHERE id='" + helper.recordId + "'";



        //REALIZA A CONSULTA
        this.soql(cmp, query)

            //QUANDO A SOLICITAÇÃO FOR CONCLUÍDA, FAÇA:
            .then(function (psq) {
                console.log('PSQ: ', psq);
                psq.forEach(psqAtual => {

                    helper.revisor = psqAtual.Revisor__c;
                    helper.elaborador = psqAtual.Elaborador__c;

                    console.log("ELABORADOR: ", helper.elaborador);
                    $("#elaborador").val(helper.elaborador);
                    console.log("REVISOR: ", helper.revisor);
                    $("#revisor").val(helper.revisor);

                    $("#Setor_do_Procedimento__c").val(psqAtual.Setor_do_Procedimento__c);
                    $("#rea_do_Procedimento__c").val(psqAtual.T_tulo_do_Documento__c);
                    $("#Setor_do_Procedimento__c").val(psqAtual.Setor_do_Procedimento__c);
                    $("#C_digo_do_Documento__c").val(psqAtual.C_digo_do_Documento__c);
                    $("#Condi_es_especificas__c").val(psqAtual.Condi_es_especificas__c);
                    $("#N_da_Revis_o__c").val(psqAtual.N_da_Revis_o__c);
                    $("#Objetivo__c").val(psqAtual.Objetivo__c);
                    $("#Aplicao__c").val(psqAtual.Aplicao__c);
                    $("#Defini_es__c").val(psqAtual.Defini_es__c);
                    $("#Equipamentos_e_Softwares__c").val(psqAtual.Equipamentos_e_Softwares__c);
                    $("#Condi_es_Gerais__c").val(psqAtual.Condi_es_Gerais__c);
                    $("#Responsabilidade_e_Autoridade__c").val(psqAtual.Responsabilidade_e_Autoridade__c);
                    $("#Refer_ncia__c").val(psqAtual.Refer_ncia__c);
                    $("#Formul_rios_Anexos_e_Documentos__c").val(psqAtual.Formul_rios_Anexos_e_Documentos__c);
                    $("#Registros__c").val(psqAtual.Registros__c);

                    helper.ListaEMpresas = psqAtual.Empresas__c.split(";");

                    console.log("Empresa: ", helper.ListaEMpresas);
                    helper.ListaEMpresas.forEach(function (empresaNome) {
                        var empresaAtual = "#" + empresaNome.trim();
                        console.log("Empresa: ", empresaAtual);
                        $(empresaAtual).click();


                    });

                    if (psqAtual.Status__c != "Em vigência") {
                        $("#delite").css('display', 'none');
                    }
                });

                helper.listaDeOpcoes(cmp, event, helper);

                //console.log("FINAL", helper.empresas)
            })
            //trata excessão de erro
            .catch(function (error) {

            })






    },
    consleLog: function (cmp, event, helper) {
        $(".empresa").on("change", function () {
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
        });
    },
    next: function (cmp, event, helper) {
        var semRepetidos = [];
        var empresas = [];
        var empresa = {}
        var psq = {};
        var arquivos = []; // Array de objetos


        if (window.FileReader) {
            // Quando o valor do input file é alterado
            $('#documento').on('change', function (e) {
                var files = e.target.files; // Obtém os arquivos selecionados

                for (var i = 0; i < files.length; i++) {
                    var filea = files[i]; // Obtém um arquivo

                    // Cria uma instância do objeto FileReader
                    var reader = new FileReader();

                    // Função que será chamada quando o arquivo for lido
                    reader.onload = function (event) {
                        // base64File.push( event.target.result.split(',')[1]) // Obtém a string em base64
                        //fileExtension.push(file.name.split('.').pop()) // Obtém a extensão do 

                        var arquivoIndividual = {};

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

        $("#next").click(function () {
            var codigoDoc = $("#C_digo_do_Documento__c").val();
            var tituloDoc = $("#T_tulo_do_Documento__c").val();
            var natureza = $("#Natureza_da_Altera_o__c").val();

            console.log($("#T_tulo_do_Documento__c").val());
            console.log($("#C_digo_do_Documento__c").val());
            if (!codigoDoc || !tituloDoc || !natureza) {

                $("#revisor__c").val($("#revisor").val());
                $("#elaborador__c").val($("#elaborador").val());
                //console.log($("").html())//console.log($("").html())// console.log($("").html()) // $(".load").css("display", "flex");

                try {
                    $(".i").each(function () {
                        if ($(this).is(":checked")) {



                            empresa = {};
                            empresa.id = this.value;
                            empresa.nome = $(this).attr('id');


                            empresas.push(empresa);
                        }
                    });
                    semRepetidos = empresas;
                    empresas = [];

                    $(".texto").each(function () {
                        if (this.value != "" && this.value != undefined && this.value != null) {
                            var campoS = $(this).siblings("p").data('campos');
                            var campo = campoS;
                            var valor = $(this).val();
                            psq[campo] = valor;
                        }
                    });

                    psq['Status__c'] = "Em aprovação";
                    psq['Id'] = helper.recordId;
                    console.log(psq);
                    //var bs64 = base64File.join();
                    //var file = fileExtension.join();
                    //console.log(typeof(bs64));
                    //console.log(file);

                    console.log("SEM REPETIDOS: ", semRepetidos);
                    console.log("PSQ: ", psq);
                    //console.log("BS64: ", base64File);
                    //console.log("ARQUIVO: ", fileExtension);

                    console.log("ARQUIVO ARRAY COMPLETO: ", arquivos);
                    // semRepetidos, psq, bs64, file                
                    var action = cmp.get("c.criaPSQ");

                    action.setParams({
                        empresasR: semRepetidos,
                        psq: psq,
                        documentos: arquivos,
                        lmdID: 'a0g6e00000J4FLSAA3',
                    });

                    action.setCallback(this, function (response) {
                        var state = response.getState();
                        if (state === "SUCCESS") {
                            helper.exibirAlerta(cmp, event, helper, "success", "Sucesso", "Documento atualizado com sucesso!")
                            console.log("Sucessos");
                            location.reload();
                        } else if (state === "ERROR") {
                            helper.exibirAlerta(cmp, event, helper, "error", "Error", "Falha ao tentar atualizar:" + errors)
                            console.log("Erro: " + errors[i].message);
                            var errors = response.getError();
                            if (errors) {
                                $(".load").css("display", "none");
                                console.log("Erro: " + errors[i].message);
                                helper.exibirAlerta(cmp, event, helper, "error", "Error", "Falha ao tentar atualizar:" + errors)
                                for (var i = 0; i < errors.length; i++) {
                                    console.log("Erro: " + errors[i].message);
                                }
                            } else {
                                $(".load").css("display", "none");
                                helper.exibirAlerta(cmp, event, helper, "error", "Error", "Falha ao tentar atualizar:" + errors)
                                console.log("Erro desconhecido.");
                                console.log("Erro: " + errors[i].message);
                            }
                        }
                    });

                    $A.enqueueAction(action);
                } catch (ex) {

                    $(".load").css("display", "none");
                    console.log("Erro ao executar ação: " + ex.message);

                }

            }
            else {
                console.log('Error!!!!! ');
                helper.exibirAlerta(cmp, event, helper, "error", "Error", "Falha ao tentar atualizar: Os campos de 'Título do Documento', 'Código do Documento' e 'Natureza da Alteração'");
            }
        });
    },
    verificaEnvio: function (cmp, event, helper) {

    },
    exibirAlerta: function (component, event, helper, type, title, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type": type,
            "title": title,
            "message": message
        });
        toastEvent.fire();
    }
})