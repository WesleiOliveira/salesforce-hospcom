({
	mainMethod : function(cmp, event, helper) {
        
		$("#button43884343").off().on("click", function() {
            $("#overlay438720").css("display", "flex")
            $("#popup483994").css("display", "flex")
            
        });
        
        $("#closeButton43980943").off().on("click", function() {
            $("#overlay438720").css("display", "none")
            $("#popup483994").css("display", "none") 
        });
        
        $("#buttonCriar34534").off().on("click", function() {
            var entrada = $(".cnpjInput3245234").val()
            helper.validaEntrada(cmp, event, helper, entrada)
        });
        
        $(document).on("input", ".cnpjInput3245234", function () {
            let valor = $(this).val().trim();
            
            if (valor.length > 0) {
                $("#buttonCriar34534").removeClass("hiddenBtn").addClass("showBtn");
            } else {
                $("#buttonCriar34534").removeClass("showBtn").addClass("hiddenBtn");
            }
        });
        
        $(document).on("input", ".cnpjInput3245234", function () {
            let valor = $(this).val().replace(/\D/g, ""); // só números
            
            if (valor.length <= 11) {
                // CPF -> 000.000.000-00
                valor = valor.replace(/(\d{3})(\d)/, "$1.$2");
                valor = valor.replace(/(\d{3})(\d)/, "$1.$2");
                valor = valor.replace(/(\d{3})(\d{1,2})$/, "$1-$2");
            } else {
                // CNPJ -> 00.000.000/0000-00
                valor = valor.replace(/^(\d{2})(\d)/, "$1.$2");
                valor = valor.replace(/^(\d{2})\.(\d{3})(\d)/, "$1.$2.$3");
                valor = valor.replace(/\.(\d{3})(\d)/, ".$1/$2");
                valor = valor.replace(/(\d{4})(\d)/, "$1-$2");
            }
            
            $(this).val(valor);
        });
	},
    
    validaEntrada : function(cmp, event, helper, entrada) {
        console.log("Entrada original:", entrada);
        
        let resultado = helper.validaCpfCnpj(cmp, entrada);
        console.log("Entrada limpa e processada:", entrada.replace(/\D/g, ""));
        
        if (!resultado.valido) {
            if (resultado.tipo === "CPF") {
                alert("CPF inválido. Verifique os números digitados.");
                console.log("CPF inválido");
            } else if (resultado.tipo === "CNPJ") {
                alert("CNPJ inválido. Verifique os números digitados.");
                console.log("CNPJ inválido");
            } else {
                alert("Entrada inválida. Digite um CPF ou CNPJ válido.");
                console.log("Entrada desconhecida ou incompleta");
            }
        } else {
            if (resultado.tipo === "CPF") {
                alert("CPF válido!");
                console.log("CPF válido");
            } else if (resultado.tipo === "CNPJ") {
                //alert("CNPJ válido!");
                console.log("CNPJ válido");
                helper.getDataCNPJ(cmp, entrada)
            }
        }
    },
    
    getDataCNPJ : function(cmp, cnpj) {
        // Exibe spinner
        $("#spinner").show();
        
        // remove tudo que não for número
        let cnpjLimpo = cnpj.replace(/\D/g, "");
        
        if (!cnpjLimpo || cnpjLimpo.length !== 14) {
            console.log("CNPJ inválido para consulta");
            return;
        }
        
        var url = "https://workflowwebhook.hospcom.net/webhook/f3a9bb48-d5f4-4f70-8101-4e6e07878a58/";
        
        fetch(url, {
            method: "POST",
            headers: {
                "Content-Type": "application/json"
            },
            body: JSON.stringify({
                cnpj: cnpjLimpo
            })
        })
        .then(response => {
            // Esconde spinner
            $("#spinner").hide();
            
            if (response.status === 200) {
            
            // Lê o corpo da resposta como JSON
            return response.json().then(data => {
                console.log("Resposta recebida:", data);
            	var dados = data[0]
                var createRecordEvent = $A.get("e.force:createRecord");
                
                createRecordEvent.setParams({
                    "entityApiName": "Account",
            		"recordTypeId" : "012i00000011qXaAAI",
                    "defaultFieldValues": {
                        "Raz_o_Social__c": dados.nome,
                        "Name": dados.nome,
                        "CNPJ__c": dados.cnpj,
                        "Status__c" : "Rascunho",
                        "Phone" : dados.telefone,
                        "Email_cliente__c" : dados.email,
                        "BillingPostalCode " : "78652000"
                    }
        		});
        		createRecordEvent.fire();  
            });
        } else {
            // Se não for 200, exibe erro
            return response.text().then(text => {
            alert("Erro: " + text);
        });
        }
        })
            .catch(error => {
            // Esconde spinner em caso de erro também
            $("#spinner").hide();
            console.error(error);
            alert("Erro: " + error.message);
        });
        },
            
            validaCpfCnpj : function(cmp, entrada) {
                // remove caracteres não numéricos
                let valor = (entrada || "").replace(/\D/g, "");
                
                let resultado = { tipo: "Desconhecido", valido: false, formatado: entrada };
                
                if (valor.length == 11) {
                    // CPF
                    resultado.tipo = "CPF";
                    resultado.valido = this.isValidCPF(valor);
                    resultado.formatado = this.formataCPF(valor);
                } else if (valor.length == 14) {
                    // CNPJ
                    resultado.tipo = "CNPJ";
                    resultado.valido = this.isValidCNPJ(valor);
                    resultado.formatado = this.formataCNPJ(valor);
                }
                
                return resultado;
            },
            
    /**
     * Validação de CPF
     */
    isValidCPF : function(cpf) {
        if (!cpf || cpf.length !== 11 || /^(\d)\1+$/.test(cpf)) return false;

        let soma = 0, resto;
        for (let i = 1; i <= 9; i++) soma += parseInt(cpf.substring(i-1, i)) * (11 - i);
        resto = (soma * 10) % 11;
        if ((resto === 10) || (resto === 11)) resto = 0;
        if (resto !== parseInt(cpf.substring(9, 10))) return false;

        soma = 0;
        for (let i = 1; i <= 10; i++) soma += parseInt(cpf.substring(i-1, i)) * (12 - i);
        resto = (soma * 10) % 11;
        if ((resto === 10) || (resto === 11)) resto = 0;
        return resto === parseInt(cpf.substring(10, 11));
    },

    /**
     * Validação de CNPJ
     */
    isValidCNPJ : function(cnpj) {
        if (!cnpj || cnpj.length !== 14 || /^(\d)\1+$/.test(cnpj)) return false;

        let tamanho = cnpj.length - 2;
        let numeros = cnpj.substring(0, tamanho);
        let digitos = cnpj.substring(tamanho);
        let soma = 0;
        let pos = tamanho - 7;
        for (let i = tamanho; i >= 1; i--) {
            soma += numeros.charAt(tamanho - i) * pos--;
            if (pos < 2) pos = 9;
        }
        let resultado = soma % 11 < 2 ? 0 : 11 - soma % 11;
        if (resultado != digitos.charAt(0)) return false;

        tamanho = tamanho + 1;
        numeros = cnpj.substring(0, tamanho);
        soma = 0;
        pos = tamanho - 7;
        for (let i = tamanho; i >= 1; i--) {
            soma += numeros.charAt(tamanho - i) * pos--;
            if (pos < 2) pos = 9;
        }
        resultado = soma % 11 < 2 ? 0 : 11 - soma % 11;
        return resultado == digitos.charAt(1);
    },

    /**
     * Formata CPF: 000.000.000-00
     */
    formataCPF : function(cpf) {
        return cpf.replace(/(\d{3})(\d{3})(\d{3})(\d{2})/, "$1.$2.$3-$4");
    },

    /**
     * Formata CNPJ: 00.000.000/0000-00
     */
    formataCNPJ : function(cnpj) {
        return cnpj.replace(/^(\d{2})(\d{3})(\d{3})(\d{4})(\d{2})$/, "$1.$2.$3/$4-$5");
    }
})