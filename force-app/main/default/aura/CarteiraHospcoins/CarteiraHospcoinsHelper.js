({
    userId: null,
    carteiraId: null,
    saldo: null,
    contactId: 'q',
    
    
    helperMethod : function(component, event, helper) {
        this.showToast(component, "Aguarde", "Carregando...", "Carregando");
        
        this.userId = component.get("v.recordId");
        
        console.log("Início método principal");
        console.log("userId:", this.userId);
        
        this.getContatoFromUser(component, event, helper, this.userId)
        .then(() => {
            console.log("contactId: ", helper.contactId);
            return this.getCarteiraId(component, event, helper, helper.contactId);
        })
            .then(() => {
            if (this.carteiraId && this.carteiraId.trim() !== '') {
            return this.getTransferencias(component, event, helper, this.carteiraId);
        } else {
            console.warn("CarteiraId vazio, não foi possível buscar transferências.");
            return []; 
        }
        })
            .then((transferencias) => {
            if (transferencias && transferencias.length > 0) {
            component.set("v.transferencias", transferencias);
        } else {
            component.set("v.transferencias", []);
        }
            
            // Carrega valores
            this.loadValues(component);
            this.animarSaldo(component);
        })
            .catch(error => {
            console.error("Erro no fluxo principal:", error);
            this.loadValues(component); 
        });
        },
            
            getContatoFromUser: function(component, event, helper, userId) {
                console.log("Início getContatoFromUser()");
                
                const query = `
                SELECT ContactId
                FROM User
                WHERE Id = '${userId}'
                LIMIT 1
                `;
                
                return helper.soql(component, query)
                .then(result => {
                    if (result && result.length > 0 && result[0].ContactId) {
                    const contatoId = result[0].ContactId;
                    console.log("Contato relacionado encontrado:", contatoId);
                    this.contactId = contatoId;
                } else {
                      console.warn("Usuário não possui ContactId.");
                return null;
            }
        })
        .catch(error => {
            console.error("Erro na query de contato:", error);
            throw error;
        });
        },
            
            //Busca id da carteira se a mesma estiver ativa
            getCarteiraId: function(component, event, helper, userId) {
                console.log("Inicio getCarteiraId()");
                
                const query = `
                SELECT Id, Carteira_Ativa__c, Colaborador__c, Hospcoins__c, Saldo__c
                FROM Carteira__c
                WHERE Colaborador__c = '${userId}' AND Carteira_Ativa__c = true
                LIMIT 1
                `;
                
                return helper.soql(component, query)
                .then(result => {
                    if (result && result.length > 0) {
                    console.log("Carteira encontrada");
                    const carteira = result[0];
                    const saldoFormatado = parseFloat(carteira.Saldo__c || 0).toFixed(2);               
                    this.carteiraId = carteira.Id;
                    this.saldo = saldoFormatado;
                    console.log("saldo: ", saldoFormatado);
                    console.log("carteiraId: ", this.carteiraId);
                } else {
                      component.set("v.saldo", '0.00');
                console.log("Carteira não encontrada");
                this.carteiraId = null;
            }
        })
        .catch(error => {
            console.error('Erro ao executar SOQL:', error);
            component.set("v.saldo", 'Erro');
            
        });
        },
            
            getTransferencias: function(component, event, helper, carteiraId){
                console.log("Início getTransferencias()");
                
                const query = `
                SELECT Programa__c, Quantidade_de_Hospcoins__c, CreatedDate, Justificativa__c
                FROM Transfer_ncia_Hospcoin__c
                WHERE Carteira_Destinataria__c = '${carteiraId}'
                ORDER BY CreatedDate DESC
                `;
                return helper.soql(component, query) 
                .then(result => {
                    const transferenciasFormatadas = result.map(item => {
                    const date = new Date(item.CreatedDate);
                    const mes = ('0' + (date.getMonth() + 1)).slice(-2);
                    const ano = date.getFullYear();
                    
                    const valorNumerico = parseFloat(item.Quantidade_de_Hospcoins__c || 0);
                    const valorFormatado = (valorNumerico >= 0 ? '+ ' : '- ') + 'H$' + Math.abs(valorNumerico).toFixed(2);
                    
                    return {
                    Id: item.Id,
                    Programa__c: item.Programa__c,
                    Quantidade_de_Hospcoins__c: valorNumerico,
                    valorFormatado: valorFormatado,
                    CreatedDate: item.CreatedDate,
                    justificativa: item.Justificativa__c,
                    dataFormatada: `${mes}/${ano}`
                      };
                      });
                
                return transferenciasFormatadas;
            })
            .catch(error => {
            console.error("Erro ao buscar transferências:", error);
            return [];
        });
    },
    
    animarSaldo: function(component) {
        let saldoFinal = parseFloat(component.get("v.saldo")) || 0;
        let duracao = 3000; // duração total da animação em ms
        let inicio = null;
        
        function easeOutQuad(t) {
            return t === 1 ? 1 : 1 - Math.pow(2, -20 * t);
        }
        
        function animar(timestamp) {
            if (!inicio) inicio = timestamp;
            let progresso = timestamp - inicio;
            let percentual = Math.min(progresso / duracao, 1);
            let valorInterpolado = easeOutQuad(percentual) * saldoFinal;
            
            component.set("v.saldoAnimado", valorInterpolado.toFixed(2));
            
            if (percentual < 1) {
                window.requestAnimationFrame(animar);
            }
        }
        
        window.requestAnimationFrame(animar);
        
    },
    
    loadValues: function(component){
        console.log("loadValues() iniciado")
        if(this.carteiraId){
            component.set("v.isCarteiraAtiva", true);
            component.set("v.saldo", this.saldo);
            console.log("Carteira carregada");
            $(".containerElementos9482").css("display", "flex");
            
        } else{
            component.set("v.isCarteiraAtiva", false);
            $(".carteiraNaoEncontrda351").css("display", "flex");
            console.log("Carteira não carregada");
        }
        
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