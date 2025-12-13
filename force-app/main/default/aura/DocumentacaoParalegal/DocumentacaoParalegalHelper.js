({
    accountType: null, 
    
    helperMethod : function(component, event, helper) {      
        
        this.checkAccountDates(component);
        this.checkAccountType(component, event, helper);
        
        
    },
    
    checkAccountDates: function(component) {        
        console.log("Checkinh account dates");
        var action = component.get("c.checkEmptyFields");
        action.setParams({
            accountId: component.get("v.recordId")
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                
                component.set("v.isVencCREAEmpty", result.isVencCREAEmpty);
                component.set("v.isCBEmpty", result.isCBEmpty);
                component.set("v.isSanitarioEmpty", result.isSanitarioEmpty);
                component.set("v.isLocalizacaoEmpty", result.isLocalizacaoEmpty);
                component.set("v.isLicencaEmpty", result.isLicencaEmpty);
                
                console.log("isVencCREAEmpty", result.isVencCREAEmpty);
                console.log("isCBEmpty", result.isCBEmpty);
                console.log("isLocalizacaoEmpty", result.isLocalizacaoEmpty);
                 console.log("isLicencaEmpty", result.isLicencaEmpty);
            } else {
                console.error("Erro ao buscar dados da conta:", response.getError());
            }
        });
        
        $A.enqueueAction(action);
    },
    
    checkAccountType: function(component) {
        
        var action = component.get("c.verificaAccount"); 
        var recordId = component.get("v.recordId");
        
        action.setParams({ recordId: recordId });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {          
                this.accountType = response.getReturnValue(); 
                component.set("v.accountType", this.accountType);
                
                if (this.accountType === 'NDA') {
                    $(".nonAcceptedAccountTypeContainer").css("display", "flex");
                    $(".mainCard").css("display", "none");
                } else {
                    $(".nonAcceptedAccountTypeContainer").css("display", "none");
                    $(".mainCard").css("display", "flex");
                    this.loadContainers(component);        
                    this.loadAllDocuments(component);
                }
                
                
                console.log("Tipo da Conta: " + this.accountType);
            } else {
                console.error("Erro ao verificar o tipo de conta: ", response.getError());
            }
        });
        
        $A.enqueueAction(action);
    },
    
    loadContainers: function(component) {
        console.log("Inicio loadContainers") 
        
        // Lista de IDs para exibição padrão
        let docsToShow = [
            "#contratoSocialContainer",
            "#cartaoContainer",
            "#corpoDeBombeirosContainer",
            "#alvaraLContainer"
        ];
        
        // Adiciona documentos adicionais conforme o tipo de conta
        if (this.accountType === 'IZU') {
            docsToShow.push("#alvaraSContainer");
        }
        
        if (this.accountType === 'Distribuidor') {
            docsToShow.push("#alvaraSContainer", "#afeContainer", "#creaContainer", "#relatorioContainer", "#licencaContainer");
        }
        
        // Exibe apenas os documentos necessários
        docsToShow.forEach(id => {
            $(id).css("display", "flex");
        });
        },
            
            
            
            loadAllDocuments: function(component) {
                var auraIds = ['Contrato Social', 'Cartão CNPJ', 'CREA', 'Corpo de Bombeiros', 'Alvará de Localização e Funcionamento', 'Relatório de Visita VISA Municipal', 'AFE ANVISA', 'Alvará Sanitário Municipal', 'Licenca Ambiental'];
                auraIds.forEach(function(auraId) {
                    this.loadDocument(component, auraId);
                }, this);
            },
            
            loadDocument: function(component, auraId) {
                var action = component.get("c.checkExistingFile");
                action.setParams({
                    fileName: auraId + '.pdf',
                    parentId: component.get("v.recordId")
                });     
                action.setCallback(this, function(response) {
                    if (response.getState() === "SUCCESS") {
                        var contentDocumentId = response.getReturnValue();
                        var url = contentDocumentId ? 'https://hospcom.my.site.com/Sales/sfc/servlet.shepherd/document/download/' + contentDocumentId + '?operationContext=S1': '';
                        
                        switch(auraId) {
                            case 'Contrato Social': 
                                component.set("v.contratoSocialDocUrl", url);
                                component.set("v.contratoSocialDocId", contentDocumentId);
                                break;
                            case 'Cartão CNPJ': 
                                component.set("v.cartaoCNPJDocUrl", url);
                                component.set("v.cartaoCNPJDocId", contentDocumentId);
                                break;
                            case 'CREA': 
                                component.set("v.creaDocUrl", url);
                                component.set("v.creaDocId", contentDocumentId);
                                break;
                            case 'Corpo de Bombeiros':
                                component.set("v.corpoDocUrl", url);
                                component.set("v.corpoDocId", contentDocumentId);
                                break;
                            case 'Alvará de Localização e Funcionamento':
                                component.set("v.alvaraLDocUrl", url);
                                component.set("v.alvaraLDocId", contentDocumentId);
                                break;
                            case 'Relatório de Visita VISA Municipal':
                                component.set("v.relatorioDocUrl", url);
                                component.set("v.relatorioDocId", contentDocumentId);
                                break;
                            case 'AFE ANVISA':
                                component.set("v.afeDocUrl", url);
                                component.set("v.afeDocId", contentDocumentId);
                                break;
                            case 'Alvará Sanitário Municipal':
                                component.set("v.alvaraSDocUrl", url);
                                component.set("v.alvaraSDocId", contentDocumentId);
                                break;
                            case 'Licenca Ambiental':
                                component.set("v.licencaDocUrl", url);
                                component.set("v.licencaDocId", contentDocumentId);
                                break;
                                
                        }
                    }
                });
                $A.enqueueAction(action);
                
                setTimeout(function () {
                    component.set("v.isProcessing", false);
                }, 2000);
            },
            
            
            /**
    
     * - Pega o arquivo enviado
     * - Extrai o aura:id do componente
     * - Define o novo nome do arquivo
     * - Chama o método para renomear via Apex
     */
            handleUploadFinished: function(component, event, helper) {
                var uploadedFiles = event.getParam("files");
                var recordId = component.get("v.recordId");
                
                if (!uploadedFiles || uploadedFiles.length === 0) {
                    helper.showToast(component, "Aviso", "Nenhum arquivo foi enviado.", "warning");
                    return;
                }
                
                var file = uploadedFiles[0];
                var fileContentId = file.contentVersionId;
                var fileUploader = event.getSource();
                var auraId = fileUploader.getLocalId(); // This will be the new filename
                
                // Get file extension from original filename
                var originalFileName = file.name;
                var fileExtension = originalFileName.split('.').pop(); // Gets "pdf" from "test.pdf"
                
                // New filename will be JUST the auraId + original extension
                var newFileName = auraId + "." + fileExtension;
                console.log("Renaming file from", originalFileName, "to", newFileName);
                
                helper.renameUploadedFile(component, event, helper, fileContentId, newFileName);
                
                /*
        var action = component.get("c.checkExistingFile");
        action.setParams({
            fileName: newFileName,
            parentId: recordId
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var existingFileId = response.getReturnValue();
                
                if (existingFileId) {
                    console.log("Deleting existing file:", newFileName);
                    
                    var deleteAction = component.get("c.deleteExistingFile");
                    deleteAction.setParams({ fileId: existingFileId });
                    
                    deleteAction.setCallback(this, function(deleteResponse) {
                        if (deleteResponse.getState() === "SUCCESS") {
                            
                        } else {
                            var errorMsg = deleteResponse.getError()[0].message;
                            helper.showToast(component, "Erro", "Falha ao excluir arquivo: " + errorMsg, "error");
                        }
                    });
                    $A.enqueueAction(deleteAction);
                } else {
                    helper.renameUploadedFile(component, fileContentId, newFileName);
                }
            } else {
                var errorMsg = response.getError()[0].message;
                helper.showToast(component, "Erro", "Falha ao verificar arquivos: " + errorMsg, "error");
            }
        });
        $A.enqueueAction(action);
        */
            },
            
            // Helper method to determine new file name based on type
            getFileNameByType: function(auraId, originalName) {
                if (auraId === "documentType1") {
                    return "Contract_" + originalName;
                } else if (auraId === "documentType2") {
                    return "Invoice_" + originalName;
                }
                // Default: keep original name
                return originalName;
            },
            
            // Helper method to extract error message
            getErrorMessage: function(response) {
                var errors = response.getError();
                return (errors && errors[0] && errors[0].message) ? 
                    errors[0].message : "Erro desconhecido";
            },
            
            /** 
     * Método para renomear o arquivo no Salesforce via Apex
     * @param {*} component - O componente Lightning
     * @param {String} contentVersionId - ID do ContentVersion a ser renomeado
     * @param {String} newFileName - Novo nome do arquivo
     */
            renameUploadedFile: function(component, event, helper, contentVersionId, newFileName) {
                
                console.log("Id do elemento: ", contentVersionId);
                // Verifica se o ID do arquivo é válido
                if (!contentVersionId) {
                    this.showToast(component, "Erro", "ID do arquivo inválido.", "error");
                    return;
                }
                
                // Chama a Apex para renomear o arquivo      
                var action = component.get("c.renameContentVersionApex");
                action.setParams({
                    "contentVersionId": contentVersionId,
                    "newFileName": newFileName
                });
                
                // Configura o callback
                action.setCallback(this, function(response){
                    component.set("v.isProcessing", true);
                    var state = response.getState();
                    if (state === "SUCCESS")   {
                        
                        var accountField = this.getAccountField(component, newFileName);
                        console.log("account field: ", accountField);
                        this.updateAccountField(component, accountField, true);
                        this.showToast(component, "Sucesso!", "Arquivo criado: " + newFileName, "success");
                        this.checkAccountDates(component);
                        this.loadContainers(component);        
                        this.loadAllDocuments(component);
                        
                        
                        
                        
                    } else if (state === "ERROR") {
                        
                        
                        
                        var errors = response.getError();
                        var errorMessage = errors && errors[0] ? errors[0].message : "Erro desconhecido.";
                        this.showToast(component, "Erro", "Falha ao criar: " + errorMessage, "error");
                        
                    }
                    component.set("v.isProcessing", false);
                }.bind(this));
                
                
                // Envia a requisição
                $A.enqueueAction(action);
            },
            
            deleteDocument: function(component, auraId) {
                // Mapeamento dos tipos de documento com os campos correspondentes
                const docMap = {
                    'Contrato Social': { urlAttr: 'contratoSocialDocUrl', idAttr: 'contratoSocialDocId' },
                    'Cartão CNPJ': { urlAttr: 'cartaoCNPJDocUrl', idAttr: 'cartaoCNPJDocId' },
                    'CREA': { urlAttr: 'creaDocUrl', idAttr: 'creaDocId', dateField: 'venc_CREA__c' },
                    'Corpo de Bombeiros': { urlAttr: 'corpoDocUrl', idAttr: 'corpoDocId', dateField: 'venc_C_Bombeiros__c' },
                    'Alvará de Localização e Funcionamento': { urlAttr: 'alvaraLDocUrl', idAttr: 'alvaraLDocId', dateField: 'venc_Alv_Localizacao__c' },
                    'Relatório de Visita VISA Municipal': { urlAttr: 'relatorioDocUrl', idAttr: 'relatorioDocId' },
                    'AFE ANVISA': { urlAttr: 'afeDocUrl', idAttr: 'afeDocId' },
                    'Alvará Sanitário Municipal': { urlAttr: 'alvaraSDocUrl', idAttr: 'alvaraSDocId', dateField: 'venc_Alv_Sanitario__c' },
                    'Licenca Ambiental': { urlAttr: 'licencaDocUrl', idAttr: 'licencaDocId', dateField: 'venc_Licenca_Ambiental__c' }
                };
                
                // Verificação do tipo de documento
                if (!docMap[auraId]) {
                    this.showToast(component, "Erro", "Tipo de documento não configurado", "error");
                    return;
                }
                
                const docInfo = docMap[auraId];
                const docId = component.get("v." + docInfo.idAttr);
                
                if (!docId) {
                    this.showToast(component, "Aviso", "Nenhum documento encontrado", "warning");
                    return;
                }
                
                // Confirmação antes de excluir
                const isConfirmed = confirm("Tem certeza que deseja excluir este documento?");
                if (!isConfirmed) {
                    return;
                }
                
                // Feedback visual de processo
                component.set("v.isProcessing", true);
                
                // Chamada Apex para excluir o arquivo e resetar o campo de data
                const action = component.get("c.deleteExistingFile");
                action.setParams({
                    fileId: docId,
                    accountId: component.get("v.recordId"),
                    docType: auraId
                });
                
                action.setCallback(this, function(response) {
                    component.set("v.isProcessing", false);
                    
                    if (component.isValid() && response.getState() === "SUCCESS") {
                        // Atualizar os atributos do componente
                        component.set("v." + docInfo.urlAttr, null);
                        component.set("v." + docInfo.idAttr, null);
                        
                        
                        console.log("Passou aqui ao deletar documento");
                      
                        // Atualizar o estado da conta no frontend (opcional)
                        var accountField = this.getAccountField(component, auraId);
                         console.log("Campo deletado: ", accountField);
                        this.updateAccountField(component, accountField, false);
                        
                        this.showToast(component, "Sucesso", "Documento removido e data zerada", "success");
                    } else {
                        const error = response.getError()[0] || { message: "Erro desconhecido" };
                        console.error("Falha na exclusão:", error.message);
                        this.showToast(component, "Erro", error.message, "error");
                    }
                });
                
                $A.enqueueAction(action);
                
            },
            getAccountField : function(component, newFileName){
                var accountField = newFileName
                .normalize('NFD')
                .replace(/[\u0300-\u036f]/g, '') 
                .replace(/[^\w\s]/gi, '') 
                .replace(/\s+/g, '')
                .replace(/\pdf$/i, '')
                .concat('__c')
                .toLowerCase();
                return accountField;
            },
            
            updateAccountField : function(component, accountField, value){
                
                var action = component.get("c.updateAccountField");
                action.setParams({
                    "accountId": component.get("v.recordId"),
                    "fieldName": accountField,
                    "fieldValue": value
                });
                
                
                action.setCallback(this, function(response) {
                    if (response.getState() === "SUCCESS") {           
                        this.showToast(component, "Campo Atualizado");
                        
                        // Recarrega a visualização para atualizar os dados
                        $A.get('e.force:refreshView').fire();
                        
                    } else {
                        // Tratamento de erros
                        var errors = response.getError();
                        var errorMessage = "Erro ao atualizar verificação do documento";
                        
                        if (errors && errors[0] && errors[0].message) {
                            errorMessage += ": " + errors[0].message;
                        }
                        
                        this.showToast(component, "Erro", errorMessage, "error");
                    }
                }.bind(this));
                
                $A.enqueueAction(action);
            },
            handleSubmit: function(component, event, helper){
                
                var form = event.getSource(); // Obtém o form específico que foi submetido
                var fields = event.getParam("fields");                
                var clicked = component.get("v.clickedButton")
                var vencCREA = fields["venc_CREA__c"];
                var vencCorpo = fields["venc_C_Bombeiros__c"];
                var vencLoc = fields["venc_Alv_Localizacao__c"];
				var vencSani = fields["venc_Alv_Sanitario__c"];
                var venclicenca = fields["venc_Licenca_Ambiental__c"];
                
                console.log("Valor de venc_CREA:", vencCREA);;
                console.log("Valor de venc_C_Bombeiros__c:", vencCorpo);;
                 console.log("Valor de venc_Alv_Localizacao__c:", vencLoc);;
                 console.log("venc_Licenca_Ambiental__c", venclicenca);;
                
                console.log("Botão clicado:", clicked);
                
                console.log("Enviando formulário com os campos:", fields);
                
                
                
                if(clicked === 'venc_CREA') {
                    // Validação do campo vazio
                    if(vencCREA === null || vencCREA === '') {
                        event.preventDefault(); // Impede o submit
                        console.error("Erro: O campo venc_CREA__c está vazio.");
                        
                        // Você pode usar isso para exibir um toast ou mensagem de erro
                        alert("Por favor, preencha a data de vencimento do CREA.");
                        
                        
                        return; // Encerra aqui pra não continuar
                    } else {
                        component.set("v.isVencCREAEmpty", false);  
                        component.set("v.creaOnChanging", false);  
                    }
                }
                
                if(clicked === 'venc_C_Bombeiros') {
                    // Validação do campo vazio
                    if(vencCorpo === null || vencCorpo === '') {
                        event.preventDefault(); // Impede o submit
                        console.error("Erro: O campo venc_C_Bombeiros está vazio.");
                        
                        // Você pode usar isso para exibir um toast ou mensagem de erro
                        alert("Por favor, preencha a data de vencimento do Corpo de Bombeiros.");
                        
                        
                        return; // Encerra aqui pra não continuar
                    } else {
                        component.set("v.isCBEmpty", false);  
                        component.set("v.bombeirosOnChanging", false);  
                    }
                }
                  if(clicked === 'venc_Alv_Localizacao') {
                    // Validação do campo vazio
                    if(vencLoc === null || vencLoc === '') {
                        event.preventDefault(); // Impede o submit
                        console.error("Erro: O campo vencLoc está vazio.");
                        
                        // Você pode usar isso para exibir um toast ou mensagem de erro
                        alert("Por favor, preencha a data de vencimento do Alvará de Localização e Funcionamento.");
                        
                        
                        return; // Encerra aqui pra não continuar
                    } else {
                        component.set("v.isLocalizacaoEmpty", false);  
                        component.set("v.localizacaoOnChanging", false);  
                    }
                }
                
                if(clicked === 'venc_Alv_Sanitario') {
                    // Validação do campo vazio
                    if(vencSani === null || vencSani === '') {
                        event.preventDefault(); // Impede o submit
                        console.error("Erro: O campo vencSani está vazio.");
                        
                        // Você pode usar isso para exibir um toast ou mensagem de erro
                        alert("Por favor, preencha a data de vencimento do Alvará Sanitário Municipal.");
                        
                        
                        return; // Encerra aqui pra não continuar
                    } else {
                        component.set("v.isSanitarioEmpty", false);  
                        component.set("v.sanitarioOnChanging", false);  
                    }
                }
                  if(clicked === 'venc_Licenca_Ambiental') {
                    // Validação do campo vazio
                    if(venclicenca === null || venclicenca === '') {
                        event.preventDefault(); // Impede o submit
                        console.error("Erro: O campo vencLicenca está vazio.");
                        
                        // Você pode usar isso para exibir um toast ou mensagem de erro
                        alert("Por favor, preencha a data de vencimento da Licença Municipal.");
                        
                        
                        return; // Encerra aqui pra não continuar
                    } else {
                        component.set("v.isLicencaEmpty", false);  
                        component.set("v.licencaChanging", false);  
                    }
                }

                
                
                                  
                console.log("Passou aqui");
                // Submete apenas este formulário
                form.submit(fields);
                
            },
            
            handleSuccess: function(component, event){
                
                this.showToast(component, "Sucesso", "Data salva com sucesso!", "success");
                console.log("Registro atualizado:", updatedRecordId, "Campo atualizado:", fieldName);
            },
            handleError: function(component, event){
                var errors = event.getParams();
                this.showToast(component, "Erro", "Erro ao salvar o formulário.", "error");
                console.error("Erro ao salvar:", errors);
                
            },
            
            showToast: function(component, title, message, type) {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": title,
                    "message": message,
                    "type": type
                });
                toastEvent.fire();
            }
        })