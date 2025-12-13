({
    data : [
        { "nome": "ENDOSCOPIA FLEXÍVEL SONOSCAPE", "verba": 214500, "totalUsado": 0 },
        { "nome": "SURGICAL SUPORTE CIRURGICO", "verba": 94250, "totalUsado": 0 },
        { "nome": "SURGICAL-CMI", "verba": 149500, "totalUsado": 0},
        { "nome": "SURGICAL-ELETROCIRURGIA", "verba": 61100, "totalUsado": 0 },
        { "nome": "PMLS", "verba": 562500, "totalUsado": 0 },
        { "nome": "PM-MEDTRONIC", "verba": 36139, "totalUsado": 0 },
        { "nome": "VIAS AEREAS DIFICEIS", "verba": 120000, "totalUsado": 0 },
        { "nome": "ORTOPEDIA ZIMMER", "verba": 100000, "totalUsado": 0 },
        { "nome": "ORTOPEDIA BAUMER", "verba": 55000, "totalUsado": 0 },
        { "nome": "ORTOPEDIA MINDRAY", "verba": 250000, "totalUsado": 0 },
        { "nome": "OPME OUTROS", "verba": 11000, "totalUsado": 0 },
        { "nome": "HUAWEI", "verba": 250000, "totalUsado": 0 },
        { "nome": "NEONATOLOGIA", "verba": 30000, "totalUsado": 0 },
        { "nome": "VETERINÁRIA MIS (US+RX)", "verba": 152000, "totalUsado": 0 },
        { "nome": "VETERINÁRIA PMLS", "verba": 85000, "totalUsado": 0 },
        { "nome": "VETERINÁRIA IVD", "verba": 61100, "totalUsado": 0 },
        { "nome": "CAMAS HOSPITALARES", "verba": 104000, "totalUsado": 0 },
        { "nome": "IMAGEM ULTRASSOM", "verba": 450000, "totalUsado": 0 },
        { "nome": "IMAGEM RAIO-X", "verba": 52000, "totalUsado": 0 },
        { "nome": "SERVIÇO", "verba": 55000, "totalUsado": 0 },
        { "nome": "LOCAÇÃO", "verba": 318500, "totalUsado": 0 }
        
    ],
    
	mainFunction : function(cmp, event, helper) {
		helper.consultaEspesas(cmp, event, helper)
    },
    
    preencheView : function(cmp, event, helper){
        
        var htmlTotal = ""
        
        helper.data.forEach(item => {
            
            var linha = item.nome
            var percentual = ((item.totalUsado / item.verba) * 100).toFixed();
            var verba = item.verba.toLocaleString('pt-BR', {style: 'currency',currency: 'BRL'});
            var totalUsado = item.totalUsado.toLocaleString('pt-BR', {style: 'currency',currency: 'BRL'});
            
            console.log("percentual", percentual)
            
            var html = "<div class='item-metrica'>\
                <div class='coluna-Esq fullWidht'>\
                    <div class='title-col-esq'>\
                        "+linha+"\
                    </div>\
                    <div class='value-col-esq'>\
                        <div class='container'>\
                            <div style='width: "+percentual+"%' class='skill' id='divWinRate' data-id='divWinRate'>"+percentual+"%</div>\
                        </div>\
                    </div>\
					<div class='title-col-esq'>\
                        "+totalUsado+"/"+verba+"\
                    </div>\
                </div>\
            </div>";
            
            htmlTotal = htmlTotal + html
            
        });
        $("#divPrincipal32847y2374784").append(htmlTotal)
        
        $('#divPrincipal32847y2374784').on('wheel', function(event) {
            event.preventDefault(); // Previne a rolagem vertical padrão
            this.scrollLeft += event.originalEvent.deltaY; // Ajusta o scroll horizontalmente
        });
    },
        
    consultaEspesas : function(cmp, event, helper) {
        var query = "SELECT Linha_da_Despesa__c, SUM(Valor__c) FROM Despesa__c WHERE Linha_da_Despesa__c != null AND Departamento__c != 'locacao' GROUP BY Linha_da_Despesa__c";
        
        //REALIZA A CONSULTA
        this.soql(cmp, query)
        
        //QUANDO A SOLICITAÇÃO FOR CONCLUÍDA, FAÇA:
        .then(function (despesas) {
            
            console.log("DESPESAS", despesas)
            console.log("DATA", helper.data)

            const despesasPorLinha = Object.fromEntries(
                despesas.map(item => [item.Linha_da_Despesa__c, item.expr0])
            );
            
            helper.data.forEach(item => {
                if (despesasPorLinha[item.nome]) {
                item.totalUsado = despesasPorLinha[item.nome];
            }
                                });
            
            console.log(helper.data);
            
            helper.preencheView(cmp, event, helper)
        })
        
        //trata excessão de erro
        .catch(function (error) {
            console.log(error)
        })
    },

    data2 : [
        { "nome": "ENDOSCOPIA FLEXÍVEL SONOSCAPE", "verba": 6000, "totalUsado": 0 },
        { "nome": "SURGICAL SUPORTE CIRURGICO", "verba": 1000, "totalUsado": 0 },
        { "nome": "SURGICAL-CMI", "verba": 14000, "totalUsado": 0},
        { "nome": "SURGICAL-ELETROCIRURGIA", "verba": 2000, "totalUsado": 0 },
        { "nome": "PMLS", "verba": 40000, "totalUsado": 0 },
        { "nome": "ORTOPEDIA MINDRAY", "verba": 8000, "totalUsado": 0 },
        { "nome": "NEONATOLOGIA", "verba": 5000, "totalUsado": 0 },
        { "nome": "VETERINÁRIA MIS (US+RX)", "verba": 4000, "totalUsado": 0 },
        { "nome": "VETERINÁRIA IVD", "verba": 8000, "totalUsado": 0 },
        { "nome": "CAMAS HOSPITALARES", "verba": 8000, "totalUsado": 0 },
        { "nome": "IMAGEM ULTRASSOM", "verba": 8000, "totalUsado": 0 },
        { "nome": "IMAGEM RAIO-X", "verba": 4000, "totalUsado": 0 }
    ],
    
	secondaryFunction : function(cmp, event, helper) {
		helper.consultaEspesas2(cmp, event, helper)
    },
    
    preencheView2 : function(cmp, event, helper){
        
        var htmlTotal = ""
        
        helper.data2.forEach(item => {
            
            var linha = item.nome
            var percentual = ((item.totalUsado / item.verba) * 100).toFixed();
            var verba = item.verba.toLocaleString('pt-BR', {style: 'currency',currency: 'BRL'});
            var totalUsado = item.totalUsado.toLocaleString('pt-BR', {style: 'currency',currency: 'BRL'});
            
            console.log("percentual", percentual)
            
            var html = "<div class='item-metrica'>\
                <div class='coluna-Esq fullWidht'>\
                    <div class='title-col-esq'>\
                        "+linha+"\
                    </div>\
                    <div class='value-col-esq'>\
                        <div class='container'>\
                            <div style='width: "+percentual+"%' class='skill' id='divWinRate' data-id='divWinRate'>"+percentual+"%</div>\
                        </div>\
                    </div>\
					<div class='title-col-esq'>\
                        "+totalUsado+"/"+verba+"\
                    </div>\
                </div>\
            </div>";
            
            htmlTotal = htmlTotal + html
            
        });
        $("#divSecundaria32847y2374784").append(htmlTotal)
        
        $('#divSecundaria32847y2374784').on('wheel', function(event) {
            event.preventDefault(); // Previne a rolagem vertical padrão
            this.scrollLeft += event.originalEvent.deltaY; // Ajusta o scroll horizontalmente
        });
    },
        
    consultaEspesas2 : function(cmp, event, helper) {
        var query = "SELECT Linha_da_Despesa__c, SUM(Valor__c) FROM Despesa__c WHERE Linha_da_Despesa__c != null AND Departamento__c = 'Locacao' GROUP BY Linha_da_Despesa__c";
        
        //REALIZA A CONSULTA
        this.soql(cmp, query)
        
        //QUANDO A SOLICITAÇÃO FOR CONCLUÍDA, FAÇA:
        .then(function (despesas) {
            
            console.log("DESPESAS", despesas)
            console.log("DATA", helper.data)

            const despesasPorLinha = Object.fromEntries(
                despesas.map(item => [item.Linha_da_Despesa__c, item.expr0])
            );
            
            helper.data2.forEach(item => {
                if (despesasPorLinha[item.nome]) {
                item.totalUsado = despesasPorLinha[item.nome];
            }
                                });
            
            console.log(helper.data);
            
            helper.preencheView2(cmp, event, helper)
        })
        
        //trata excessão de erro
        .catch(function (error) {
            console.log(error)
        })
    },
        
})