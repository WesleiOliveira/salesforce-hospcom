({
    
    
    data : [],
    dataProcessed : [],
    anoSetado : 2023,
    selectAno : '',
    
    mainHelper : function(cmp, event, helper) {
        const itens = document.querySelectorAll(".item")
        
        helper.pesquisaVendedores(cmp, event, helper);
        
    },
    
    //POPULA O ARRAY COM OS VENDEDORES
    pesquisaVendedores : function(cmp, event, helper){
        
        var query = "SELECT Vendedor__r.Name, MAX(Vendedor__r.Id) FROM Goal__c WHERE vendedor__r.isactive = true and Vendedor__r.Name != null GROUP BY Vendedor__r.Name ORDER BY Vendedor__r.Name"
        
        //realiza a consulta
        helper.soql(cmp, query)
        
        //quando a solicitação for concluída, faça:
        .then(function (vendedores) {
            //console.log('asdfasdf', vendedores)
             
	        var departamento = [];
            vendedores.forEach(function(vendedor) {
                
                var idVendedor = vendedor.expr0
                var nomeVendedor = vendedor.Name
                var itemTemp = {'idVendedor': idVendedor, 'nomeVendedor': nomeVendedor, linha: [], familia: [], 'winRate':{}, 'metas': {'vendas': [], 'outros':[], 'pmls': [], 'surgical': [], 'ultrassom': [], 'ultrassomPoc':[], 'ultrassomFixo':[], 'eletrocirurgia': [], 'cmiImagemLaparo': [], 'cmiUroGineco':[], 'locacao': [], 'quantidadeVisitas':[], 'quantidadeOpp':[], 'quantidadeDemo':[]}}
                
                helper.soql(cmp,"SELECT Departamento_Premiacao__c FROM User WHERE Id = '" + vendedor.expr0 + "'").then(v => {
                    if(v[0].Departamento_Premiacao__c){
		            	itemTemp.departamento = v[0].Departamento_Premiacao__c;
                    	v[0].Departamento_Premiacao__c.split(';').forEach(value => {
				            if ( $("#selectDepartamento option[value='"+value+"']").length == 0 ){
            				    $("#selectDepartamento").append("<option  value='"+value+"' >"+value+"</option>")
            				}
                    
                		});
                	}                	
                });
            
                if ( $("#selectVendedor option[value='"+idVendedor+"']").length == 0 ){
                    $("#selectVendedor").append("<option  value='"+idVendedor+"' >"+nomeVendedor+"</option>")
                }
                
                
                helper.data.push(itemTemp)
            });
        
        	helper.soql(cmp, "SELECT vendedor__c, Linha__c FROM Goal__c WHERE Vendedor__r.Name <> null AND Linha__c <> null GROUP BY vendedor__c, Linha__c").then(linhas => {
                linhas.forEach(linha => {
                	const vendedor = helper.data.find(v => v.idVendedor == linha.Vendedor__c);
                	if(vendedor == undefined) return;
                	vendedor.linha.push(linha.Linha__c);
                	if(linha.Linha__c == 'CMI'){
                		helper.soql(cmp, "SELECT vendedor__c, Familia__c FROM Goal__c WHERE Vendedor__c = '" + linha.Vendedor__c + "' AND Linha__c = 'CMI' LIMIT 1").then(familia => {
                			vendedor.familia.push(familia[0].Familia__c);
            			});
            		} else if (linha.Linha__c == 'ULTRASSOM'){
                		helper.soql(cmp, "SELECT Familia__c FROM Goal__c WHERE Vendedor__c = '" + linha.Vendedor__c + "' AND Familia__c <> null AND LINHA__C = 'ULTRASSOM'").then(familia => {
                			familia = familia.map(v => v.Familia__c);
                			familia = [...new Set(familia)];
                			familia.forEach(v => vendedor.familia.push(v))
            			});
            		}
            	});
            });

            			
            console.log(helper.data);
            helper.pesquisaPedidos(cmp, event, helper);
            
        })
        //trata excessão de erro
        .catch(function (error) {
            console.log(error)
        });
        
    },
    
    //recebe um inteiro e retorna a string do mes
    retornaMes : function(cmp, event, helper, mes){
        switch(mes) {
            case 1:
                return 'JAN';
                break;
            case 2:
                return 'FEV';
                break;
            case 3:
                return 'MAR';
                break;
            case 4:
                return 'ABR';
                break;
            case 5:
                return 'MAI';
                break;
            case 6:
                return 'JUN';
                break;
            case 7:
                return 'JUL';
                break;
            case 8:
                return 'AGO';
                break;
            case 9:
                return 'SET';
                break;
            case 10:
                return 'OUT';
                break;
            case 11:
                return 'NOV';
                break;
            case 12:
                return 'DEZ';
                break;
            default:
                return undefined
        }
    },
    
    //FUNÇÃO QUE EXIBE O SPINNER DE CARREGAMENTO-
    showSpinner: function (cmp) {
        //console.log("exibindo spinner")
        var a = $('#spinnerDiv').css("display", "flex");
        //console.log($(a).html())
    },
    //-------------------------------------------

    //FUNÇÃO QUE OCULTA O SPINNER DE CARREGAMENTO-  
    hideSpinner: function (cmp) {
        //console.log("ocultando spinner")
        $('#spinnerDiv').css("display", "none");
    },
    //--------------------------------------------
    
    
    //POPULA O ARRAY DE VENDEDORES COM OS RESULTADOS DE VENDAS GERAL
    pesquisaPedidos : function(cmp, event, helper){
        
        helper.showSpinner(cmp)
        
        var query = "SELECT Order.Vendedor__c, calendar_year(OrderItem.Order.Data_de_ativacao__c), calendar_month(OrderItem.Order.Data_de_ativacao__c), sum(TotalPrice), Max(linha__c), Max(Order.Departamento3__c) FROM OrderItem where Order.Vendedor__c <> null and OrderItem.Order.Data_de_ativacao__c <> null group by Order.Vendedor__c, calendar_year(OrderItem.Order.Data_de_ativacao__c), calendar_month(OrderItem.Order.Data_de_ativacao__c)"
        
        //realiza a consulta
        helper.soql(cmp, query)
        
        //quando a solicitação for concluída, faça:
        .then(function (itens) {
            
            //CLICK NECESSÁRIO PARA DESBUGAR A CONSULTA
            $('#itemChart').click()
            //console.log(itens)
            
            itens.forEach(function(itemAtual){
                //console.log(helper.data)
                var idVendedorAtual = itemAtual.Vendedor__c
                var indiceDeEdicao = helper.data.findIndex(e => e.idVendedor == idVendedorAtual)
                var mesAtual = helper.retornaMes(cmp, event, helper, itemAtual.expr1)
                var numeroMes = itemAtual.expr1
                var total = itemAtual.expr2
                var ano = itemAtual.expr0
                var linha = itemAtual.expr3
                var departamento = itemAtual.expr4
                
                if(indiceDeEdicao != (-1)){
                    helper.data[indiceDeEdicao].metas.vendas.push({'ano': ano, 'numeroMes': numeroMes, 'mes': mesAtual, 'total': total})
                }
                
            })
            
            //CLICK NECESSÁRIO PARA DESBUGAR A CONSULTA
            $('#itemChart').click()
            
            helper.pesquisaPedidosPMLS(cmp, event, helper);
            
        })
        //trata excessão de erro
        .catch(function (error) {
            //console.log(error)
        })
    },
    
    //POPULA O ARRAY DE VENDEDORES COM OS RESULTADOS DE PMLS
    pesquisaPedidosPMLS : function(cmp, event, helper){
        
        var query = "SELECT Order.Vendedor__c, calendar_year(OrderItem.Order.Data_de_ativacao__c), calendar_month(OrderItem.Order.Data_de_ativacao__c), sum(TotalPrice), Max(linha__c), Max(Order.Departamento3__c) FROM OrderItem where Order.Vendedor__c <> null and OrderItem.Order.Data_de_ativacao__c <> null and linha__c = 'PMLS' group by Order.Vendedor__c, calendar_year(OrderItem.Order.Data_de_ativacao__c), calendar_month(OrderItem.Order.Data_de_ativacao__c)"
        
        //realiza a consulta
        helper.soql(cmp, query)
        
        //quando a solicitação for concluída, faça:
        .then(function (itens) {
            
            //CLICK NECESSÁRIO PARA DESBUGAR A CONSULTA
            $('#itemChart').click()
            //console.log(itens)
            //console.log(helper.data.metas)
            
            itens.forEach(function(itemAtual){
                //console.log(helper.data)
                var idVendedorAtual = itemAtual.Vendedor__c
                var indiceDeEdicao = helper.data.findIndex(e => e.idVendedor == idVendedorAtual)
                var mesAtual = helper.retornaMes(cmp, event, helper, itemAtual.expr1)
                var numeroMes = itemAtual.expr1
                var total = itemAtual.expr2
                var ano = itemAtual.expr0
                var linha = itemAtual.expr3
                var departamento = itemAtual.expr4
                
                if(indiceDeEdicao != (-1)){
                    helper.data[indiceDeEdicao].metas.pmls.push({'ano': ano, 'numeroMes': numeroMes, 'mes': mesAtual, 'total': total})
                }
                
            })
            
            //CLICK NECESSÁRIO PARA DESBUGAR A CONSULTA
            $('#itemChart').click()
            
            
            helper.pesquisaPedidosSURGICAL(cmp, event, helper);
            
        })
        //trata excessão de erro
        .catch(function (error) {
            console.log(error)
        })
    },
    
    //POPULA O ARRAY DE VENDEDORES COM OS RESULTADOS DE SURGICAL
    pesquisaPedidosSURGICAL : function(cmp, event, helper){
        
        var query = "SELECT Order.Vendedor__c, calendar_year(OrderItem.Order.Data_de_ativacao__c), calendar_month(OrderItem.Order.Data_de_ativacao__c), sum(TotalPrice), Max(linha__c), Max(Order.Departamento3__c) FROM OrderItem where Order.Vendedor__c <> null and OrderItem.Order.Data_de_ativacao__c <> null and linha__c = 'SURGICAL' group by Order.Vendedor__c, calendar_year(OrderItem.Order.Data_de_ativacao__c), calendar_month(OrderItem.Order.Data_de_ativacao__c)"
        
        //realiza a consulta
        helper.soql(cmp, query)
        
        //quando a solicitação for concluída, faça:
        .then(function (itens) {
            
            //CLICK NECESSÁRIO PARA DESBUGAR A CONSULTA
            $('#itemChart').click()
            //console.log(itens)
            //console.log(helper.data.metas)
            
            itens.forEach(function(itemAtual){
                //console.log(helper.data)
                var idVendedorAtual = itemAtual.Vendedor__c
                var indiceDeEdicao = helper.data.findIndex(e => e.idVendedor == idVendedorAtual)
                var mesAtual = helper.retornaMes(cmp, event, helper, itemAtual.expr1)
                var numeroMes = itemAtual.expr1
                var total = itemAtual.expr2
                var ano = itemAtual.expr0
                var linha = itemAtual.expr3
                var departamento = itemAtual.expr4
                
                if(indiceDeEdicao != (-1)){
                    helper.data[indiceDeEdicao].metas.surgical.push({'ano': ano, 'numeroMes': numeroMes, 'mes': mesAtual, 'total': total})
                }
                
            })
            
            //CLICK NECESSÁRIO PARA DESBUGAR A CONSULTA
            $('#itemChart').click()
            
            
            helper.pesquisaPedidosULTRASSOM(cmp, event, helper);
            
        })
        //trata excessão de erro
        .catch(function (error) {
            console.log(error)
        })
    },
    
    //POPULA O ARRAY DE VENDEDORES COM OS RESULTADOS DE ULTRASSOM
    pesquisaPedidosULTRASSOM : function(cmp, event, helper){
        
        var query = "SELECT Order.Vendedor__c, calendar_year(OrderItem.Order.Data_de_ativacao__c), calendar_month(OrderItem.Order.Data_de_ativacao__c), sum(TotalPrice), Max(linha__c), Max(Order.Departamento3__c) FROM OrderItem where Order.Vendedor__c <> null and OrderItem.Order.Data_de_ativacao__c <> null and linha__c = 'ULTRASSOM' group by Order.Vendedor__c, calendar_year(OrderItem.Order.Data_de_ativacao__c), calendar_month(OrderItem.Order.Data_de_ativacao__c)"
        
        //realiza a consulta
        helper.soql(cmp, query)
        
        //quando a solicitação for concluída, faça:
        .then(function (itens) {
            
            //CLICK NECESSÁRIO PARA DESBUGAR A CONSULTA
            $('#itemChart').click()
            //console.log(itens)
            //console.log(helper.data.metas)
            
            itens.forEach(function(itemAtual){
                //console.log(helper.data)
                var idVendedorAtual = itemAtual.Vendedor__c
                var indiceDeEdicao = helper.data.findIndex(e => e.idVendedor == idVendedorAtual)
                var mesAtual = helper.retornaMes(cmp, event, helper, itemAtual.expr1)
                var numeroMes = itemAtual.expr1
                var total = itemAtual.expr2
                var ano = itemAtual.expr0
                var linha = itemAtual.expr3
                var departamento = itemAtual.expr4
                
                if(indiceDeEdicao != (-1)){
                    helper.data[indiceDeEdicao].metas.ultrassom.push({'ano': ano, 'numeroMes': numeroMes, 'mes': mesAtual, 'total': total})
                }
                
            })
            
            //CLICK NECESSÁRIO PARA DESBUGAR A CONSULTA
            $('#itemChart').click()
            
            
            helper.pesquisaPedidosULTRASSOMPOC(cmp, event, helper);
            
        })
        //trata excessão de erro
        .catch(function (error) {
            console.log(error)
        })
    },
                
    //POPULA O ARRAY DE VENDEDORES COM OS RESULTADOS DE ULTRASSOM E POC
    pesquisaPedidosULTRASSOMPOC : function(cmp, event, helper){
        
        var query = "SELECT Order.Vendedor__c, calendar_year(OrderItem.Order.Data_de_ativacao__c), calendar_month(OrderItem.Order.Data_de_ativacao__c), sum(TotalPrice), Max(linha__c), Max(Order.Departamento3__c) FROM OrderItem where Order.Vendedor__c <> null and OrderItem.Order.Data_de_ativacao__c <> null and linha__c = 'ULTRASSOM' AND Fam_lia__c IN ('ULTRASSOM POC') group by Order.Vendedor__c, calendar_year(OrderItem.Order.Data_de_ativacao__c), calendar_month(OrderItem.Order.Data_de_ativacao__c)"
        
        //realiza a consulta
        helper.soql(cmp, query)
        
        //quando a solicitação for concluída, faça:
        .then(function (itens) {
            
            //CLICK NECESSÁRIO PARA DESBUGAR A CONSULTA
            $('#itemChart').click()
            //console.log(itens)
            //console.log(helper.data.metas)
            
            itens.forEach(function(itemAtual){
                //console.log(helper.data)
                var idVendedorAtual = itemAtual.Vendedor__c
                var indiceDeEdicao = helper.data.findIndex(e => e.idVendedor == idVendedorAtual)
                var mesAtual = helper.retornaMes(cmp, event, helper, itemAtual.expr1)
                var numeroMes = itemAtual.expr1
                var total = itemAtual.expr2
                var ano = itemAtual.expr0
                var linha = itemAtual.expr3
                var departamento = itemAtual.expr4
                
                if(indiceDeEdicao != (-1)){
                    helper.data[indiceDeEdicao].metas.ultrassomPoc.push({'ano': ano, 'numeroMes': numeroMes, 'mes': mesAtual, 'total': total})
                }
                
            })
            
            //CLICK NECESSÁRIO PARA DESBUGAR A CONSULTA
            $('#itemChart').click()
            
            
            helper.pesquisaPedidosULTRASSOMFIXO(cmp, event, helper);
            
        })
        //trata excessão de erro
        .catch(function (error) {
            console.log(error)
        })
    },
                
    //POPULA O ARRAY DE VENDEDORES COM OS RESULTADOS DE ULTRASSOM E POC
    pesquisaPedidosULTRASSOMFIXO : function(cmp, event, helper){
        
        var query = "SELECT Order.Vendedor__c, calendar_year(OrderItem.Order.Data_de_ativacao__c), calendar_month(OrderItem.Order.Data_de_ativacao__c), sum(TotalPrice), Max(linha__c), Max(Order.Departamento3__c) FROM OrderItem where Order.Vendedor__c <> null and OrderItem.Order.Data_de_ativacao__c <> null and linha__c = 'ULTRASSOM' AND Fam_lia__c IN ('ULTRASSOM FIXO') group by Order.Vendedor__c, calendar_year(OrderItem.Order.Data_de_ativacao__c), calendar_month(OrderItem.Order.Data_de_ativacao__c)"
        
        //realiza a consulta
        helper.soql(cmp, query)
        
        //quando a solicitação for concluída, faça:
        .then(function (itens) {
            
            //CLICK NECESSÁRIO PARA DESBUGAR A CONSULTA
            $('#itemChart').click()
            //console.log(itens)
            //console.log(helper.data.metas)
            
            itens.forEach(function(itemAtual){
                //console.log(helper.data)
                var idVendedorAtual = itemAtual.Vendedor__c
                var indiceDeEdicao = helper.data.findIndex(e => e.idVendedor == idVendedorAtual)
                var mesAtual = helper.retornaMes(cmp, event, helper, itemAtual.expr1)
                var numeroMes = itemAtual.expr1
                var total = itemAtual.expr2
                var ano = itemAtual.expr0
                var linha = itemAtual.expr3
                var departamento = itemAtual.expr4
                
                if(indiceDeEdicao != (-1)){
                    helper.data[indiceDeEdicao].metas.ultrassomFixo.push({'ano': ano, 'numeroMes': numeroMes, 'mes': mesAtual, 'total': total})
                }
                
            })
            
            //CLICK NECESSÁRIO PARA DESBUGAR A CONSULTA
            $('#itemChart').click()
            
            
            helper.pesquisaPedidosELETROCIRURGIA(cmp, event, helper);
            
        })
        //trata excessão de erro
        .catch(function (error) {
            console.log(error)
        })
    },
    
    //POPULA O ARRAY DE VENDEDORES COM OS RESULTADOS DE ELETROCIRURGIA
    pesquisaPedidosELETROCIRURGIA : function(cmp, event, helper){
        
        var query = "SELECT Order.Vendedor__c, calendar_year(OrderItem.Order.Data_de_ativacao__c), calendar_month(OrderItem.Order.Data_de_ativacao__c), sum(TotalPrice), Max(linha__c), Max(Order.Departamento3__c) FROM OrderItem where Order.Vendedor__c <> null and OrderItem.Order.Data_de_ativacao__c <> null and linha__c = 'ELETROCIRURGIA' group by Order.Vendedor__c, calendar_year(OrderItem.Order.Data_de_ativacao__c), calendar_month(OrderItem.Order.Data_de_ativacao__c)"
        
        //realiza a consulta
        helper.soql(cmp, query)
        
        //quando a solicitação for concluída, faça:
        .then(function (itens) {
            
            //CLICK NECESSÁRIO PARA DESBUGAR A CONSULTA
            $('#itemChart').click()
            //console.log(itens)
            //console.log(helper.data.metas)
            
            itens.forEach(function(itemAtual){
                //console.log(helper.data)
                var idVendedorAtual = itemAtual.Vendedor__c
                var indiceDeEdicao = helper.data.findIndex(e => e.idVendedor == idVendedorAtual)
                var mesAtual = helper.retornaMes(cmp, event, helper, itemAtual.expr1)
                var numeroMes = itemAtual.expr1
                var total = itemAtual.expr2
                var ano = itemAtual.expr0
                var linha = itemAtual.expr3
                var departamento = itemAtual.expr4
                
                if(indiceDeEdicao != (-1)){
                    helper.data[indiceDeEdicao].metas.eletrocirurgia.push({'ano': ano, 'numeroMes': numeroMes, 'mes': mesAtual, 'total': total})
                }
                
            })
            
            //CLICK NECESSÁRIO PARA DESBUGAR A CONSULTA
            $('#itemChart').click()
            
            
            helper.pesquisaPedidosCMI(cmp, event, helper);
            
        })
        //trata excessão de erro
        .catch(function (error) {
            console.log(error)
        })
    },
    
    //POPULA O ARRAY DE VENDEDORES COM OS RESULTADOS DE CMI
    pesquisaPedidosCMI : function(cmp, event, helper){
        
        var query = "SELECT Order.Vendedor__c, calendar_year(OrderItem.Order.Data_de_ativacao__c), calendar_month(OrderItem.Order.Data_de_ativacao__c), sum(TotalPrice), Max(linha__c), Max(Order.Departamento3__c) FROM OrderItem where Order.Vendedor__c <> null and OrderItem.Order.Data_de_ativacao__c <> null and linha__c = 'CMI' AND Fam_lia__c IN ('IMAGEM', 'LAPAROSCOPIA','CIRURGIA MINIMAMENTE INVASIVA') group by Order.Vendedor__c, calendar_year(OrderItem.Order.Data_de_ativacao__c), calendar_month(OrderItem.Order.Data_de_ativacao__c)"
        
        //realiza a consulta
        helper.soql(cmp, query)
        
        //quando a solicitação for concluída, faça:
        .then(function (itens) {
            
            //CLICK NECESSÁRIO PARA DESBUGAR A CONSULTA
            $('#itemChart').click()
            console.log(itens)
            //console.log(helper.data.metas)
            
            itens.forEach(function(itemAtual){
                //console.log(helper.data)
                var idVendedorAtual = itemAtual.Vendedor__c
                var indiceDeEdicao = helper.data.findIndex(e => e.idVendedor == idVendedorAtual)
                var mesAtual = helper.retornaMes(cmp, event, helper, itemAtual.expr1)
                var numeroMes = itemAtual.expr1
                var total = itemAtual.expr2
                var ano = itemAtual.expr0
                var linha = itemAtual.expr3
                var departamento = itemAtual.expr4
                
                if(indiceDeEdicao != (-1)){
                    helper.data[indiceDeEdicao].metas.cmiImagemLaparo.push({'ano': ano, 'numeroMes': numeroMes, 'mes': mesAtual, 'total': total})
                }
                
            })
            
            //CLICK NECESSÁRIO PARA DESBUGAR A CONSULTA
            $('#itemChart').click()
            
            helper.pesquisaPedidosCMIUroGineco(cmp, event, helper);
            
        })
        //trata excessão de erro
        .catch(function (error) {
            console.log(error)
        })
    },
    
    //POPULA O ARRAY DE VENDEDORES COM OS RESULTADOS DE CMI
    pesquisaPedidosCMIUroGineco : function(cmp, event, helper){
        
        var query = "SELECT Order.Vendedor__c, calendar_year(OrderItem.Order.Data_de_ativacao__c), calendar_month(OrderItem.Order.Data_de_ativacao__c), sum(TotalPrice), Max(linha__c), Max(Order.Departamento3__c) FROM OrderItem where Order.Vendedor__c <> null and OrderItem.Order.Data_de_ativacao__c <> null and linha__c = 'CMI' AND Fam_lia__c IN ('UROLOGIA', 'GINECOLOGIA') group by Order.Vendedor__c, calendar_year(OrderItem.Order.Data_de_ativacao__c), calendar_month(OrderItem.Order.Data_de_ativacao__c)"
        
        //realiza a consulta
        helper.soql(cmp, query)
        
        //quando a solicitação for concluída, faça:
        .then(function (itens) {
            
            //CLICK NECESSÁRIO PARA DESBUGAR A CONSULTA
            $('#itemChart').click()
            console.log(itens)
            //console.log(helper.data.metas)
            
            itens.forEach(function(itemAtual){
                //console.log(helper.data)
                var idVendedorAtual = itemAtual.Vendedor__c
                var indiceDeEdicao = helper.data.findIndex(e => e.idVendedor == idVendedorAtual)
                var mesAtual = helper.retornaMes(cmp, event, helper, itemAtual.expr1)
                var numeroMes = itemAtual.expr1
                var total = itemAtual.expr2
                var ano = itemAtual.expr0
                var linha = itemAtual.expr3
                var departamento = itemAtual.expr4
                
                if(indiceDeEdicao != (-1)){
                    helper.data[indiceDeEdicao].metas.cmiUroGineco.push({'ano': ano, 'numeroMes': numeroMes, 'mes': mesAtual, 'total': total})
                }
                
            })
            
            //CLICK NECESSÁRIO PARA DESBUGAR A CONSULTA
            $('#itemChart').click()
            
            helper.pesquisaPedidosLOCACAO(cmp, event, helper);
            
        })
        //trata excessão de erro
        .catch(function (error) {
            console.log(error)
        })
    },
    
    //POPULA O ARRAY DE VENDEDORES COM OS RESULTADOS DE CMI
    pesquisaPedidosLOCACAO : function(cmp, event, helper){
        
        var query = "SELECT Order.Vendedor__c, calendar_year(OrderItem.Order.Data_de_ativacao__c), calendar_month(OrderItem.Order.Data_de_ativacao__c), sum(TotalPrice), Max(linha__c), Max(Order.Departamento3__c) FROM OrderItem where Order.Vendedor__c <> null and OrderItem.Order.Data_de_ativacao__c <> null and Order.Departamento3__c = 'Locação' group by Order.Vendedor__c, calendar_year(OrderItem.Order.Data_de_ativacao__c), calendar_month(OrderItem.Order.Data_de_ativacao__c)"
        
        //realiza a consulta
        helper.soql(cmp, query)
        
        //quando a solicitação for concluída, faça:
        .then(function (itens) {
            
            //CLICK NECESSÁRIO PARA DESBUGAR A CONSULTA
            $('#itemChart').click()
            //console.log(itens)
            //console.log(helper.data.metas)
            
            itens.forEach(function(itemAtual){
                //console.log(helper.data)
                var idVendedorAtual = itemAtual.Vendedor__c
                var indiceDeEdicao = helper.data.findIndex(e => e.idVendedor == idVendedorAtual)
                var mesAtual = helper.retornaMes(cmp, event, helper, itemAtual.expr1)
                var numeroMes = itemAtual.expr1
                var total = itemAtual.expr2
                var ano = itemAtual.expr0
                var linha = itemAtual.expr3
                var departamento = itemAtual.expr4
                
                if(indiceDeEdicao != (-1)){
                    helper.data[indiceDeEdicao].metas.locacao.push({'ano': ano, 'numeroMes': numeroMes, 'mes': mesAtual, 'total': total})
                }
                
            })
            
            //CLICK NECESSÁRIO PARA DESBUGAR A CONSULTA
            $('#itemChart').click()
            
            helper.pesquisaQuantidadeVisitas(cmp, event, helper);
            
        })
        //trata excessão de erro
        .catch(function (error) {
            console.log(error)
        })
    },

	//POPULA O ARRAY DE VENDEDORES COM OS RESULTADOS DE CMI
    pesquisaQuantidadeVisitas : function(cmp, event, helper){
        
        var query = "SELECT count(id), ownerId, calendar_year(STARTDATETIME), calendar_month(STARTDATETIME) FROM EVENT WHERE SUBJECT = 'Visita' group by ownerId, calendar_year(STARTDATETIME), calendar_month(STARTDATETIME)"
        
        //realiza a consulta
        helper.soql(cmp, query)
        
        //quando a solicitação for concluída, faça:
        .then(function (itens) {
            
            //CLICK NECESSÁRIO PARA DESBUGAR A CONSULTA
            $('#itemChart').click()
  
            //console.log(helper.data.metas)
            
            itens.forEach(function(itemAtual){
                //console.log(helper.data)
                var idVendedorAtual = itemAtual.OwnerId
                var indiceDeEdicao = helper.data.findIndex(e => e.idVendedor == idVendedorAtual)
                var mesAtual = helper.retornaMes(cmp, event, helper, itemAtual.expr2)
                var numeroMes = itemAtual.expr2
                var total = itemAtual.expr0
                var ano = itemAtual.expr1
                //var linha = itemAtual.expr3
                //var departamento = itemAtual.expr4
                
                if(indiceDeEdicao != (-1)){
                    helper.data[indiceDeEdicao].metas.quantidadeVisitas.push({'ano': ano, 'numeroMes': numeroMes, 'mes': mesAtual, 'total': total})
                }
                
            })
            
            //CLICK NECESSÁRIO PARA DESBUGAR A CONSULTA
            $('#itemChart').click()
            

            
            helper.pesquisaQuantidadeOpp(cmp, event, helper);
            
        })
        //trata excessão de erro
        .catch(function (error) {
            console.log(error)
        })
    },	
    
    //POPULA O ARRAY DE VENDEDORES COM OS RESULTADOS DE OPP CRIADAS
    pesquisaQuantidadeOpp : function(cmp, event, helper){
        
        var query = "SELECT count(id), ownerId, calendar_year(CreatedDate), calendar_month(CreatedDate) FROM Opportunity group by ownerId, calendar_year(CreatedDate), calendar_month(CreatedDate)"
        
        //realiza a consulta
        helper.soql(cmp, query)
        
        //quando a solicitação for concluída, faça:
        .then(function (itens) {
            
            //CLICK NECESSÁRIO PARA DESBUGAR A CONSULTA
            $('#itemChart').click()
            
            itens.forEach(function(itemAtual){
                var idVendedorAtual = itemAtual.OwnerId
                var indiceDeEdicao = helper.data.findIndex(e => e.idVendedor == idVendedorAtual)
                var mesAtual = helper.retornaMes(cmp, event, helper, itemAtual.expr2)
                var numeroMes = itemAtual.expr2
                var total = itemAtual.expr0
                var ano = itemAtual.expr1
                //var linha = itemAtual.expr3
                //var departamento = itemAtual.expr4
                
                if(indiceDeEdicao != (-1)){
                    helper.data[indiceDeEdicao].metas.quantidadeOpp.push({'ano': ano, 'numeroMes': numeroMes, 'mes': mesAtual, 'total': total})
                }
                
            })
            
            //CLICK NECESSÁRIO PARA DESBUGAR A CONSULTA
            $('#itemChart').click()
            
            
            helper.pesquisaQuantidadeDemo(cmp, event, helper);
            
        })
        //trata excessão de erro
        .catch(function (error) {
            console.log(error)
        })
    },
    
    //POPULA O ARRAY DE VENDEDORES COM OS RESULTADOS DE OPP CRIADAS
    pesquisaQuantidadeDemo : function(cmp, event, helper){
        
        var query = "SELECT count(id), VENDEDOR__C, calendar_year(Data_da_demonstracao__c), calendar_month(Data_da_demonstracao__c) FROM ORDER WHERE Status != 'Cancelado' AND Inicio_Ativo__c != null AND RECORDTYPEID = '0126e000001pMEk' AND NATUREZA_DE_OPERA_O__C = 'DEMONSTRAÇÃO' group by VENDEDOR__C, calendar_year(Data_da_demonstracao__c), calendar_month(Data_da_demonstracao__c)"
        
        //realiza a consulta
        helper.soql(cmp, query)
        
        //quando a solicitação for concluída, faça:
        .then(function (itens) {
            
            //CLICK NECESSÁRIO PARA DESBUGAR A CONSULTA
            $('#itemChart').click()
            
            itens.forEach(function(itemAtual){
                
                var idVendedorAtual = itemAtual.Vendedor__c
                var indiceDeEdicao = helper.data.findIndex(e => e.idVendedor == idVendedorAtual)
                var mesAtual = helper.retornaMes(cmp, event, helper, itemAtual.expr2)
                var numeroMes = itemAtual.expr2
                var total = itemAtual.expr0
                var ano = itemAtual.expr1
                
                if(indiceDeEdicao != (-1)){
                    helper.data[indiceDeEdicao].metas.quantidadeDemo.push({'ano': ano, 'numeroMes': numeroMes, 'mes': mesAtual, 'total': total})
                }
                
            })
            
            //CLICK NECESSÁRIO PARA DESBUGAR A CONSULTA
            $('#itemChart').click()
            
            helper.pesquisaWinRate(cmp, event, helper);
            
        })
        //trata excessão de erro
        .catch(function (error) {
            console.log(error)
        })
    },	
    
    //POPULA O ARRAY DE VENDEDORES COM OS RESULTADOS DE OPP CRIADAS
    pesquisaWinRate : function(cmp, event, helper){
        setTimeout(function(){
        const query = "SELECT OwnerId, StageName, count(id), calendar_year(CloseDate), calendar_month(CloseDate) FROM Opportunity WHERE StageName IN ('LOSS', 'WIN') AND Sub_Fase__c NOT IN ('ABORTADO', 'DUPLICADO', 'SUSPENSO') and calendar_year(CloseDate) = 2023 GROUP BY calendar_year(CloseDate), calendar_month(CloseDate), OwnerId, StageName";
        
            helper.soql(cmp, query).then(item => {
                $('#itemChart').click()
                helper.data.forEach(value => {
                    value.winRate.total = [];
                    for(let ano = 2021 ; ano <= 2024 ; ano++){
                        for(let mes = 1 ; mes <= 12 ; mes++){
                            const win = item.find(v => v.expr1 == ano && v.expr2 == mes && v.OwnerId == value.idVendedor && v.StageName == 'WIN');
                            const loss = item.find(v => v.expr1 == ano && v.expr2 == mes && v.OwnerId == value.idVendedor && v.StageName == 'LOSS');
        
                            if(win == undefined && loss == undefined){
                                value.winRate.total.push({ano: ano, numeroMes: mes, winRate: 0, lossRate: 0});
                            } else if (win == undefined || loss == undefined) {
                                value.winRate.total.push({ano: ano, numeroMes: mes, winRate: win ? 100 : 0 , lossRate: loss ? 100 : 0 });                            
                            } else {
                                const total = win.expr0 + loss.expr0
                                value.winRate.total.push({ano: ano, numeroMes: mes, winRate: win.expr0/total * 100, lossRate: loss.expr0/total * 100});
                            }
                        }
                    }
                });
            });
            
    //        const linhas = [
    //            {linha: "total", querry: ""},
    //            {linha: "ELETROCIRURGIA", querry: "AND Product2.linha__c = 'ELETROCIRURGIA'"},
    //            {linha: "OUTROS", querry: "AND Product2.linha__c = 'OUTROS'"},
    //            {linha: "PMLS", querry: "AND Product2.linha__c = 'PMLS'"},
    //            {linha: "SURGICAL", querry: "AND Product2.linha__c = 'SURGICAL'"},
    //            {linha: "ULTRASSOM", querry: "AND Product2.linha__c = 'ULTRASSOM'"},
    //            {linha: "cmi_imagem_laparo", querry: "AND Product2.linha__c = 'CMI' AND Product2.Family IN ('IMAGEM', 'LAPAROSCOPIA', 'CIRURGIA MINIMAMENTE INVASIVA') "},
    //        ]
            
    //        helper.data.forEach(vendedor => {
    //            vendedor.winRate.total = [];
    //        	vendedor.linha.forEach(value => {
    //                const key = (value == "CMI") ? "cmi_imagem_laparo" : value.toLowerCase();
    //                vendedor.winRate[key] = []                    
    //        	});
    //        });
                    
    //        linhas.forEach(valueLinha => {
    //            const query = "SELECT Opportunity.OwnerId, " + (valueLinha.linha == "total" ? "" : "Product2.linha__c,") + " Opportunity.StageName, count(Opportunity.ID), calendar_year(Opportunity.CloseDate), calendar_month(Opportunity.CloseDate) FROM OpportunityLineItem WHERE Opportunity.StageName IN ('LOSS', 'WIN') AND Opportunity.Sub_Fase__c NOT IN ('ABORTADO', 'DUPLICADO', 'SUSPENSO') and calendar_year(Opportunity.CloseDate) >= 2021 " + valueLinha.querry + " GROUP BY calendar_year(Opportunity.CloseDate), calendar_month(Opportunity.CloseDate), Opportunity.OwnerId, " + (valueLinha.linha == 'total'? '' : 'Product2.linha__c,')  + " Opportunity.StageName limit 2000";	
    //            helper.soql(cmp, query).then(item => {
    //                $('#itemChart').click()
    //                helper.data.forEach(value => {
    //                	if(value.linha.find(v => (v == valueLinha.linha || (v == "CMI" && valueLinha.linha == "cmi_imagem_laparo") || valueLinha.linha == "total")) == undefined && !(valueLinha.linha == "total" && value.linha.length == 0)) return;		
    //                    for(let ano = 2021 ; ano <= 2024 ; ano++){
    //                        for(let mes = 1 ; mes <= 12 ; mes++){
    //                            const win = item.find(v => v.expr1 == ano && v.expr2 == mes && v.OwnerId == value.idVendedor && v.StageName == 'WIN');
    //                            const loss = item.find(v => v.expr1 == ano && v.expr2 == mes && v.OwnerId == value.idVendedor && v.StageName == 'LOSS');
        
    //                			const key = (value == "CMI") ? "cmi_imagem_laparo" : valueLinha.linha.toLowerCase();
    //                            if(win == undefined && loss == undefined){
    //                                value.winRate[key].push({ano: ano, numeroMes: mes, winRate: 0, lossRate: 0});
    //                            } else if (win == undefined || loss == undefined) {
    //                                value.winRate[key].push({ano: ano, numeroMes: mes, winRate: win ? 100 : 0 , lossRate: loss ? 100 : 0 });                            
    //                            } else {
    //                                const total = win.expr0 + loss.expr0
    //                                value.winRate[key].push({ano: ano, numeroMes: mes, winRate: win.expr0/total * 100, lossRate: loss.expr0/total * 100});
    //                            }
    //                        }
    //                    }
    //                });
    //	        });
    //        });
            
            console.log(helper.data)
    
            //helper.inter(cmp, event, helper);
    		helper.sumOthers(cmp, event, helper);
    
        }, 10000);
        

    },
          
    inter : function(cmp, event, helper){
        helper.data.forEach(v => {
            for(let  i = 2021 ; i <= 2024 ; i++){
                for(let j = 1 ; j <= 12 ; j ++){
            		if(v.metas.vendas.find(e => e.ano == i && e.numeroMes == j) == undefined) 
            			v.metas.vendas.push({ ano: i, numeroMes: j, total: 0 });
                    if(v.metas.pmls.find(e => e.ano == i && e.numeroMes == j) == undefined) 
                        v.metas.pmls.push({ ano: i, numeroMes: j, total: 0 });
                    if(v.metas.surgical.find(e => e.ano == i && e.numeroMes == j) == undefined) 
                        v.metas.surgical.push({ ano: i, numeroMes: j, total: 0 });
                    if(v.metas.ultrassom.find(e => e.ano == i && e.numeroMes == j) == undefined) 
                        v.metas.ultrassom.push({ ano: i, numeroMes: j, total: 0 });
                    if(v.metas.ultrassomPoc.find(e => e.ano == i && e.numeroMes == j) == undefined) 
                        v.metas.ultrassomPoc.push({ ano: i, numeroMes: j, total: 0 });
                    if(v.metas.ultrassomFixo.find(e => e.ano == i && e.numeroMes == j) == undefined) 
                        v.metas.ultrassomFixo.push({ ano: i, numeroMes: j, total: 0 });
                    if(v.metas.quantidadeVisitas.find(e => e.ano == i && e.numeroMes == j) == undefined) 
                        v.metas.quantidadeVisitas.push({ ano: i, numeroMes: j, total: 0 });
                    if(v.metas.eletrocirurgia.find(e => e.ano == i && e.numeroMes == j) == undefined) 
                        v.metas.eletrocirurgia.push({ ano: i, numeroMes: j, total: 0 });
                    if(v.metas.quantidadeOpp.find(e => e.ano == i && e.numeroMes == j) == undefined) 
                        v.metas.quantidadeOpp.push({ ano: i, numeroMes: j, total: 0 });
                    if(v.metas.quantidadeDemo.find(e => e.ano == i && e.numeroMes == j) == undefined) 
                        v.metas.quantidadeDemo.push({ ano: i, numeroMes: j, total: 0 });
                    if(v.metas.outros.find(e => e.ano == i && e.numeroMes == j) == undefined) 
                        v.metas.outros.push({ ano: i, numeroMes: j, total: 0 });
                    if(v.metas.cmiImagemLaparo.find(e => e.ano == i && e.numeroMes == j) == undefined) 
                        v.metas.cmiImagemLaparo.push({ ano: i, numeroMes: j, total: 0 });
                    if(v.metas.cmiUroGineco.find(e => e.ano == i && e.numeroMes == j) == undefined) 
                        v.metas.cmiUroGineco.push({ ano: i, numeroMes: j, total: 0 });
        			if(v.metas.locacao.find(e => e.ano == i && e.numeroMes == j) == undefined) 
                        v.metas.locacao.push({ ano: i, numeroMes: j, total: 0 });
                }
        	}
    	});

		helper.calcYear(cmp, event, helper);

    },
        
    sumOthers : function(cmp, event, helper){
        const fields = ['vendas', 'cmiImagemLaparo', 'cmiUroGineco', 'eletrocirurgia', 'locacao', 'ultrassomPoc', 'ultrassomFixo', 'pmls', 'surgical', 'ultrassom'];        
        
        helper.data.forEach(value => {
            value.metas.outros = [];
            for(let ano = 2021 ; ano <= 2024 ; ano++){
                for(let mes = 1 ; mes <= 12 ; mes++){
                    var values = [];
            		for(let i = 0;i < fields.length;i++){
	            		values[i] = value.metas[fields[i]].find(v => v.ano == ano && v.numeroMes == mes);
            			values[i] = (values[i] == undefined || value.metas[fields[i]].find(v => v.metaMes != undefined && v.ano == helper.anoSetado) == undefined) ? 0 : Math.round(values[i].total * 100);
        			}
                                
                    value.metas.outros.push({
                        ano: ano,
                        numeroMes: mes,
                        total: (values[0] - values[1] - values[2] - values[3] - values[4] - values[5] - values[6] - values[7] -  values[8] - values[9]) / 100
                    });
        			if(value.idVendedor == '0056e00000AgnpQAAR'){
            		    console.log(values, (values[0] - values[1] - values[2] - values[3] - values[4] - values[5] - values[6] - values[7] -  values[8] - values[9]) / 100)
        			}
                }
            }
        });

		helper.inter(cmp, event, helper);
		//helper.calculaSaldos(cmp, event, helper);
    },
        
    //=================SESSOES QUE BUSCAM E PREENCHEM AS METAS======================//
    //------------------------------------------------------------------------------//
    
    //INSERE AS METAS ATINGIDAS DE VENDA
    preencheMetaVendas : function(cmp, event, helper){
        
        
        //CLICK NECESSÁRIO PARA DESBUGAR A CONSULTA
        $('#itemChart').click()
        
        var query = "SELECT Meta__c, vendedor__c, Vendedor__r.Name, Vendedor__r.Title, Vendedor__r.MediumPhotoUrl, inicio__c, final__c, Name FROM Goal__c WHERE Vendedor__r.Name != null AND Estado__c = null AND Linha__c = null AND Departamento__c = null ORDER BY Vendedor__r.Name"
        
        //realiza a consulta
        helper.soql(cmp, query)
        
        //quando a solicitação for concluída, faça:
        .then(function (metasAtingidas) {
            //console.log("metas atingidas")
            //console.log(metasAtingidas)
            
            //CLICK NECESSÁRIO PARA DESBUGAR A CONSULTA
            $('#itemChart').click()
                        
            metasAtingidas.forEach(function (metaVendaAtual) {
                var mesAtualInicio = metaVendaAtual.Inicio__c.split('-')[1]
                var mesAtualFinal = metaVendaAtual.Final__c.split('-')[1]
                var idVendedor = metaVendaAtual.Vendedor__c
                var anoAtual = metaVendaAtual.Final__c.split('-')[0]
                var urlImagemVendedor = metaVendaAtual.Vendedor__r.MediumPhotoUrl
                var cargoVendedor = metaVendaAtual.Vendedor__r.Title
                
                //VERIFICA SE A META LIDA É UMA META MENSAL
                if(mesAtualInicio == mesAtualFinal){
                    var indiceDeEdicao = helper.data.findIndex(e => e.idVendedor == idVendedor)
                    
                    //VERIFICA SE PARA A META ATUAL, EXISTE UM REGISTRO COM VENDAS DO VENDEDOR
                    if(indiceDeEdicao != (-1)){
                        if(helper.data[indiceDeEdicao].metas.vendas.length > 0){
                            
                            helper.data[indiceDeEdicao].imagemVendedor = urlImagemVendedor
                            helper.data[indiceDeEdicao].cargoVendedor = cargoVendedor
                            
                            //VERIFICA SE PARA O VENDEDOR ENCONTRADO, EXISTE UM TOTAL VENDIDO DO MES
                            //CASO EXISTA, INSERE NESSE TOTAL VENDIDO DO MES, A META DO MES
                            var indiceEdicaoMes = helper.data[indiceDeEdicao].metas.vendas.findIndex(e => e.numeroMes == mesAtualInicio && e.ano == anoAtual)
                            if(indiceEdicaoMes != (-1)){
                                helper.data[indiceDeEdicao].metas.vendas[indiceEdicaoMes].metaMes = metaVendaAtual.Meta__c
                            }
                        }
                    } 
                }else{
                    
                    var indiceDeEdicao = helper.data.findIndex(e => e.idVendedor == idVendedor)
                    
                    //VERIFICA SE PARA A META ATUAL, EXISTE UM REGISTRO COM VENDAS DO VENDEDOR
                    if(indiceDeEdicao != (-1)){
                        if(anoAtual == helper.anoSetado){
                            
                            helper.data[indiceDeEdicao].imagemVendedor = urlImagemVendedor
                            helper.data[indiceDeEdicao].cargoVendedor = cargoVendedor
                            console.log("META ANUAL GERAL: " + idVendedor)
                            console.log(metaVendaAtual.Meta__c)
                            helper.data[indiceDeEdicao].metas.metaAnualGeral = metaVendaAtual.Meta__c
                        }
                    }
                    
                }
            })  
            
            //CLICK NECESSÁRIO PARA DESBUGAR A CONSULTA
            $('#itemChart').click()
            
            helper.preencheMetaPMLS(cmp, event, helper)
            
        })
        //trata excessão de erro
        .catch(function (error) {
            console.log(error)
        })
    },
    
    //INSERE AS METAS ATINGIDAS DE VENDA
    preencheMetaPMLS : function(cmp, event, helper){
        
        //CLICK NECESSÁRIO PARA DESBUGAR A CONSULTA
        $('#itemChart').click()
        
        var query = "SELECT Meta__c, vendedor__c, Vendedor__r.Name, Vendedor__r.Title, Vendedor__r.MediumPhotoUrl, inicio__c, final__c, Name FROM Goal__c WHERE Vendedor__r.Name != null AND Estado__c = null AND Linha__c = 'PMLS' AND Departamento__c = null ORDER BY Vendedor__r.Name"
        
        //realiza a consulta
        helper.soql(cmp, query)
        
        //quando a solicitação for concluída, faça:
        .then(function (metasAtingidas) {
            
            //CLICK NECESSÁRIO PARA DESBUGAR A CONSULTA
            $('#itemChart').click()
            
            metasAtingidas.forEach(function (metaVendaAtual) {
                var mesAtualInicio = metaVendaAtual.Inicio__c.split('-')[1]
                var mesAtualFinal = metaVendaAtual.Final__c.split('-')[1]
                var idVendedor = metaVendaAtual.Vendedor__c
                var anoAtual = metaVendaAtual.Final__c.split('-')[0]
                var urlImagemVendedor = metaVendaAtual.Vendedor__r.MediumPhotoUrl
                var cargoVendedor = metaVendaAtual.Vendedor__r.Title
                
                //VERIFICA SE A META LIDA É UMA META MENSAL
                if(mesAtualInicio == mesAtualFinal){
                    var indiceDeEdicao = helper.data.findIndex(e => e.idVendedor == idVendedor)
                    
                    //VERIFICA SE PARA A META ATUAL, EXISTE UM REGISTRO COM VENDAS DO VENDEDOR
                    if(indiceDeEdicao != (-1)){
                        if(helper.data[indiceDeEdicao].metas.pmls.length > 0){
                            
                            helper.data[indiceDeEdicao].imagemVendedor = urlImagemVendedor
                            helper.data[indiceDeEdicao].cargoVendedor = cargoVendedor
                            
                            //VERIFICA SE PARA O VENDEDOR ENCONTRADO, EXISTE UM TOTAL VENDIDO DO MES
                            //CASO EXISTA, INSERE NESSE TOTAL VENDIDO DO MES, A META DO MES
                            var indiceEdicaoMes = helper.data[indiceDeEdicao].metas.pmls.findIndex(e => e.numeroMes == mesAtualInicio && e.ano == anoAtual)
                            if(indiceEdicaoMes != (-1)){
                                //console.log(metaVendaAtual.Meta__c)
                                //console.log("id do vendedor inserindo" + idVendedor)
                                helper.data[indiceDeEdicao].metas.pmls[indiceEdicaoMes].metaMes = metaVendaAtual.Meta__c
                            }
                        }
                    }
                    
                }else{
                    
                    var indiceDeEdicao = helper.data.findIndex(e => e.idVendedor == idVendedor)
                    
                    //VERIFICA SE PARA A META ATUAL, EXISTE UM REGISTRO COM VENDAS DO VENDEDOR
                    if(indiceDeEdicao != (-1)){
                        if(anoAtual == helper.anoSetado){
                            
                            helper.data[indiceDeEdicao].imagemVendedor = urlImagemVendedor
                            helper.data[indiceDeEdicao].cargoVendedor = cargoVendedor
                            
                            helper.data[indiceDeEdicao].metas.metaAnualPMLS = metaVendaAtual.Meta__c
                        }
                    }
                    
                }
            })  
            
            //CLICK NECESSÁRIO PARA DESBUGAR A CONSULTA
            $('#itemChart').click()
            
            helper.preencheMetaSURGICAL(cmp, event, helper)
            
        })
        //trata excessão de erro
        .catch(function (error) {
            console.log(error)
        })
    },
    
    //INSERE AS METAS ATINGIDAS DE VENDA
    preencheMetaSURGICAL : function(cmp, event, helper){
        
        //CLICK NECESSÁRIO PARA DESBUGAR A CONSULTA
        $('#itemChart').click()
        
        var query = "SELECT Meta__c, vendedor__c, Vendedor__r.Name, Vendedor__r.Title, Vendedor__r.MediumPhotoUrl, inicio__c, final__c, Name FROM Goal__c WHERE Vendedor__r.Name != null AND Estado__c = null AND Linha__c = 'SURGICAL' AND Departamento__c = null ORDER BY Vendedor__r.Name"
        
        //realiza a consulta
        helper.soql(cmp, query)
        
        //quando a solicitação for concluída, faça:
        .then(function (metasAtingidas) {

            //CLICK NECESSÁRIO PARA DESBUGAR A CONSULTA
            $('#itemChart').click()
                        
            metasAtingidas.forEach(function (metaVendaAtual) {
                var mesAtualInicio = metaVendaAtual.Inicio__c.split('-')[1]
                var mesAtualFinal = metaVendaAtual.Final__c.split('-')[1]
                var idVendedor = metaVendaAtual.Vendedor__c
                var anoAtual = metaVendaAtual.Final__c.split('-')[0]
                var urlImagemVendedor = metaVendaAtual.Vendedor__r.MediumPhotoUrl
                var cargoVendedor = metaVendaAtual.Vendedor__r.Title
                
                //VERIFICA SE A META LIDA É UMA META MENSAL
                if(mesAtualInicio == mesAtualFinal){
                    var indiceDeEdicao = helper.data.findIndex(e => e.idVendedor == idVendedor)
                    
                    //VERIFICA SE PARA A META ATUAL, EXISTE UM REGISTRO COM VENDAS DO VENDEDOR
                    if(indiceDeEdicao != (-1)){
                        if(helper.data[indiceDeEdicao].metas.surgical.length > 0){
                            
                            helper.data[indiceDeEdicao].imagemVendedor = urlImagemVendedor
                            helper.data[indiceDeEdicao].cargoVendedor = cargoVendedor
                            
                            //VERIFICA SE PARA O VENDEDOR ENCONTRADO, EXISTE UM TOTAL VENDIDO DO MES
                            //CASO EXISTA, INSERE NESSE TOTAL VENDIDO DO MES, A META DO MES
                            var indiceEdicaoMes = helper.data[indiceDeEdicao].metas.surgical.findIndex(e => e.numeroMes == mesAtualInicio && e.ano == anoAtual)
                            if(indiceEdicaoMes != (-1)){
                                //console.log(metaVendaAtual.Meta__c)
                                //console.log("id do vendedor inserindo" + idVendedor)
                                helper.data[indiceDeEdicao].metas.surgical[indiceEdicaoMes].metaMes = metaVendaAtual.Meta__c
                            }
                        }
                    }
                }else{
                    
                    var indiceDeEdicao = helper.data.findIndex(e => e.idVendedor == idVendedor)
                    
                    //VERIFICA SE PARA A META ATUAL, EXISTE UM REGISTRO COM VENDAS DO VENDEDOR
                    if(indiceDeEdicao != (-1)){
                        if(helper.data[indiceDeEdicao].metas.locacao.length > 0){
                            
                            helper.data[indiceDeEdicao].imagemVendedor = urlImagemVendedor
                            helper.data[indiceDeEdicao].cargoVendedor = cargoVendedor
                            
                            helper.data[indiceDeEdicao].metas.metaAnualSurgical = metaVendaAtual.Meta__c
                        }
                    }
                    
                }
            })  
            
            //CLICK NECESSÁRIO PARA DESBUGAR A CONSULTA
            $('#itemChart').click()
            
            helper.preencheMetaULTRASSOM(cmp, event, helper)
            
        })
        //trata excessão de erro
        .catch(function (error) {
            console.log(error)
        })
    },
    
    //INSERE AS METAS ATINGIDAS DE VENDA
    preencheMetaULTRASSOM : function(cmp, event, helper){
        
        //CLICK NECESSÁRIO PARA DESBUGAR A CONSULTA
        $('#itemChart').click()
        
        var query = "SELECT Meta__c, vendedor__c, Vendedor__r.Name, Vendedor__r.Title, Vendedor__r.MediumPhotoUrl, inicio__c, final__c, Name FROM Goal__c WHERE Vendedor__r.Name != null AND Estado__c = null AND Linha__c = 'ULTRASSOM' AND Departamento__c = null ORDER BY Vendedor__r.Name"
        
        //realiza a consulta
        helper.soql(cmp, query)
        
        //quando a solicitação for concluída, faça:
        .then(function (metasAtingidas) {

            //CLICK NECESSÁRIO PARA DESBUGAR A CONSULTA
            $('#itemChart').click()
                        
            metasAtingidas.forEach(function (metaVendaAtual) {
                var mesAtualInicio = metaVendaAtual.Inicio__c.split('-')[1]
                var mesAtualFinal = metaVendaAtual.Final__c.split('-')[1]
                var idVendedor = metaVendaAtual.Vendedor__c
                var anoAtual = metaVendaAtual.Final__c.split('-')[0]
                var urlImagemVendedor = metaVendaAtual.Vendedor__r.MediumPhotoUrl
                var cargoVendedor = metaVendaAtual.Vendedor__r.Title
                
                //VERIFICA SE A META LIDA É UMA META MENSAL
                if(mesAtualInicio == mesAtualFinal){
                    var indiceDeEdicao = helper.data.findIndex(e => e.idVendedor == idVendedor)
                    
                    //VERIFICA SE PARA A META ATUAL, EXISTE UM REGISTRO COM VENDAS DO VENDEDOR
                    if(indiceDeEdicao != (-1)){
                        if(helper.data[indiceDeEdicao].metas.ultrassom.length > 0){
                            
                            helper.data[indiceDeEdicao].imagemVendedor = urlImagemVendedor
                            helper.data[indiceDeEdicao].cargoVendedor = cargoVendedor
                            
                            //VERIFICA SE PARA O VENDEDOR ENCONTRADO, EXISTE UM TOTAL VENDIDO DO MES
                            //CASO EXISTA, INSERE NESSE TOTAL VENDIDO DO MES, A META DO MES
                            var indiceEdicaoMes = helper.data[indiceDeEdicao].metas.ultrassom.findIndex(e => e.numeroMes == mesAtualInicio && e.ano == anoAtual)
                            if(indiceEdicaoMes != (-1)){
                                //console.log(metaVendaAtual.Meta__c)
                                //console.log("id do vendedor inserindo" + idVendedor)
                                helper.data[indiceDeEdicao].metas.ultrassom[indiceEdicaoMes].metaMes = metaVendaAtual.Meta__c
                            }else{
                                //CASO NAO EXISTA REGISTRO DE VENDAS PARA O MES ESPECIFICO, INSERE O VALOR ZERO NO METAMES
                                //helper.data[indiceDeEdicao].metas.ultrassom[indiceEdicaoMes].metaMes = metaVendaAtual.Meta__c
                                //console.log("nao encontrado pedidos de venda pra este mes")
                                //console.log("vendedor: " + idVendedor)
                                //console.log("mes: " + mesAtualInicio)
                                //console.log("meta: " + metaVendaAtual.Meta__c)
                            }
                        }
                    }                    
                }else{
                    
                    var indiceDeEdicao = helper.data.findIndex(e => e.idVendedor == idVendedor)
                    
                    //VERIFICA SE PARA A META ATUAL, EXISTE UM REGISTRO COM VENDAS DO VENDEDOR
                    if(indiceDeEdicao != (-1)){
                        if(helper.data[indiceDeEdicao].metas.locacao.length > 0){
                            
                            helper.data[indiceDeEdicao].imagemVendedor = urlImagemVendedor
                            helper.data[indiceDeEdicao].cargoVendedor = cargoVendedor
                            
                            helper.data[indiceDeEdicao].metas.metaAnualUltrassom = metaVendaAtual.Meta__c
                        }
                    }
                    
                }
            })  
            
            //CLICK NECESSÁRIO PARA DESBUGAR A CONSULTA
            $('#itemChart').click()
            
            helper.preencheMetaULTRASSOMPOC(cmp, event, helper)
            
        })
        //trata excessão de erro
        .catch(function (error) {
            console.log(error)
        })
    },
        
    //INSERE AS METAS ATINGIDAS DE VENDA
    preencheMetaULTRASSOMPOC : function(cmp, event, helper){
        
        //CLICK NECESSÁRIO PARA DESBUGAR A CONSULTA
        $('#itemChart').click()
        
        var query = "SELECT Meta__c, vendedor__c, Familia__c, Vendedor__r.Name, Vendedor__r.Title, Vendedor__r.MediumPhotoUrl, inicio__c, final__c, Name FROM Goal__c WHERE Vendedor__r.Name != null AND Estado__c = null AND Linha__c = 'ULTRASSOM' AND Familia__c includes ('ULTRASSOM POC') AND Departamento__c = null ORDER BY Vendedor__r.Name"
        
        //realiza a consulta
        helper.soql(cmp, query)
        
        //quando a solicitação for concluída, faça:
        .then(function (metasAtingidas) {

            //CLICK NECESSÁRIO PARA DESBUGAR A CONSULTA
            $('#itemChart').click()
                        
            metasAtingidas.forEach(function (metaVendaAtual) {
                var mesAtualInicio = metaVendaAtual.Inicio__c.split('-')[1]
                var mesAtualFinal = metaVendaAtual.Final__c.split('-')[1]
                var idVendedor = metaVendaAtual.Vendedor__c
                var anoAtual = metaVendaAtual.Final__c.split('-')[0]
                var urlImagemVendedor = metaVendaAtual.Vendedor__r.MediumPhotoUrl
                var cargoVendedor = metaVendaAtual.Vendedor__r.Title
                
                //VERIFICA SE A META LIDA É UMA META MENSAL
                if(mesAtualInicio == mesAtualFinal){
                    var indiceDeEdicao = helper.data.findIndex(e => e.idVendedor == idVendedor)
                    
                    //VERIFICA SE PARA A META ATUAL, EXISTE UM REGISTRO COM VENDAS DO VENDEDOR
                    if(indiceDeEdicao != (-1)){
                        if(helper.data[indiceDeEdicao].metas.ultrassomPoc.length > 0){
                            
                            helper.data[indiceDeEdicao].imagemVendedor = urlImagemVendedor
                            helper.data[indiceDeEdicao].cargoVendedor = cargoVendedor
                            
                            //VERIFICA SE PARA O VENDEDOR ENCONTRADO, EXISTE UM TOTAL VENDIDO DO MES
                            //CASO EXISTA, INSERE NESSE TOTAL VENDIDO DO MES, A META DO MES
                            var indiceEdicaoMes = helper.data[indiceDeEdicao].metas.ultrassomPoc.findIndex(e => e.numeroMes == mesAtualInicio && e.ano == anoAtual)
                            if(indiceEdicaoMes != (-1)){
                                //console.log(metaVendaAtual.Meta__c)
                                //console.log("id do vendedor inserindo" + idVendedor)
                                helper.data[indiceDeEdicao].metas.ultrassomPoc[indiceEdicaoMes].metaMes = metaVendaAtual.Meta__c
                            }else{
                                //CASO NAO EXISTA REGISTRO DE VENDAS PARA O MES ESPECIFICO, INSERE O VALOR ZERO NO METAMES
                                //helper.data[indiceDeEdicao].metas.ultrassom[indiceEdicaoMes].metaMes = metaVendaAtual.Meta__c
                                //console.log("nao encontrado pedidos de venda pra este mes")
                                //console.log("vendedor: " + idVendedor)
                                //console.log("mes: " + mesAtualInicio)
                                //console.log("meta: " + metaVendaAtual.Meta__c)
                            }
                        }
                    }                    
                }else{
                    
                    var indiceDeEdicao = helper.data.findIndex(e => e.idVendedor == idVendedor)
                    
                    //VERIFICA SE PARA A META ATUAL, EXISTE UM REGISTRO COM VENDAS DO VENDEDOR
                    if(indiceDeEdicao != (-1)){
                        if(helper.data[indiceDeEdicao].metas.ultrassomPoc.length > 0){
                            
                            helper.data[indiceDeEdicao].imagemVendedor = urlImagemVendedor
                            helper.data[indiceDeEdicao].cargoVendedor = cargoVendedor
                            
                            helper.data[indiceDeEdicao].metas.metaAnualUltrassomPOC = metaVendaAtual.Meta__c
                        }
                    }
                    
                }
            })  
            
            //CLICK NECESSÁRIO PARA DESBUGAR A CONSULTA
            $('#itemChart').click()
            
            helper.preencheMetaULTRASSOMFIXO(cmp, event, helper)
            
        })
        //trata excessão de erro
        .catch(function (error) {
            console.log(error)
        })
    },
        
    //INSERE AS METAS ATINGIDAS DE VENDA
    preencheMetaULTRASSOMFIXO : function(cmp, event, helper){
        
        //CLICK NECESSÁRIO PARA DESBUGAR A CONSULTA
        $('#itemChart').click()
        
        var query = "SELECT Meta__c, vendedor__c, Familia__c, Vendedor__r.Name, Vendedor__r.Title, Vendedor__r.MediumPhotoUrl, inicio__c, final__c, Name FROM Goal__c WHERE Vendedor__r.Name != null AND Estado__c = null AND Linha__c = 'ULTRASSOM' AND Familia__c includes ('ULTRASSOM FIXO') AND Departamento__c = null ORDER BY Vendedor__r.Name"
        
        //realiza a consulta
        helper.soql(cmp, query)
        
        //quando a solicitação for concluída, faça:
        .then(function (metasAtingidas) {

            //CLICK NECESSÁRIO PARA DESBUGAR A CONSULTA
            $('#itemChart').click()
                        
            metasAtingidas.forEach(function (metaVendaAtual) {
                var mesAtualInicio = metaVendaAtual.Inicio__c.split('-')[1]
                var mesAtualFinal = metaVendaAtual.Final__c.split('-')[1]
                var idVendedor = metaVendaAtual.Vendedor__c
                var anoAtual = metaVendaAtual.Final__c.split('-')[0]
                var urlImagemVendedor = metaVendaAtual.Vendedor__r.MediumPhotoUrl
                var cargoVendedor = metaVendaAtual.Vendedor__r.Title
                
                //VERIFICA SE A META LIDA É UMA META MENSAL
                if(mesAtualInicio == mesAtualFinal){
                    var indiceDeEdicao = helper.data.findIndex(e => e.idVendedor == idVendedor)
                    
                    //VERIFICA SE PARA A META ATUAL, EXISTE UM REGISTRO COM VENDAS DO VENDEDOR
                    if(indiceDeEdicao != (-1)){
                        if(helper.data[indiceDeEdicao].metas.ultrassomFixo.length > 0){
                            
                            helper.data[indiceDeEdicao].imagemVendedor = urlImagemVendedor
                            helper.data[indiceDeEdicao].cargoVendedor = cargoVendedor
                            
                            //VERIFICA SE PARA O VENDEDOR ENCONTRADO, EXISTE UM TOTAL VENDIDO DO MES
                            //CASO EXISTA, INSERE NESSE TOTAL VENDIDO DO MES, A META DO MES
                            var indiceEdicaoMes = helper.data[indiceDeEdicao].metas.ultrassomFixo.findIndex(e => e.numeroMes == mesAtualInicio && e.ano == anoAtual)
                            if(indiceEdicaoMes != (-1)){
                                //console.log(metaVendaAtual.Meta__c)
                                //console.log("id do vendedor inserindo" + idVendedor)
                                helper.data[indiceDeEdicao].metas.ultrassomFixo[indiceEdicaoMes].metaMes = metaVendaAtual.Meta__c
                            }else{
                                //CASO NAO EXISTA REGISTRO DE VENDAS PARA O MES ESPECIFICO, INSERE O VALOR ZERO NO METAMES
                                //helper.data[indiceDeEdicao].metas.ultrassom[indiceEdicaoMes].metaMes = metaVendaAtual.Meta__c
                                //console.log("nao encontrado pedidos de venda pra este mes")
                                //console.log("vendedor: " + idVendedor)
                                //console.log("mes: " + mesAtualInicio)
                                //console.log("meta: " + metaVendaAtual.Meta__c)
                            }
                        }
                    }                    
                }else{
                    
                    var indiceDeEdicao = helper.data.findIndex(e => e.idVendedor == idVendedor)
                    
                    //VERIFICA SE PARA A META ATUAL, EXISTE UM REGISTRO COM VENDAS DO VENDEDOR
                    if(indiceDeEdicao != (-1)){
                        if(true){
                            //console.log("ADICIONADO META ANUAL DE ULTRASSOM FIXO")
                            helper.data[indiceDeEdicao].imagemVendedor = urlImagemVendedor
                            helper.data[indiceDeEdicao].cargoVendedor = cargoVendedor
                            
                            helper.data[indiceDeEdicao].metas.metaAnualUltrassomFixo = metaVendaAtual.Meta__c
                        }
                    }
                    
                }
            })  
            
            //CLICK NECESSÁRIO PARA DESBUGAR A CONSULTA
            $('#itemChart').click()
            
            helper.preencheMetaELETROCIRURGIA(cmp, event, helper)
            
        })
        //trata excessão de erro
        .catch(function (error) {
            console.log(error)
        })
    },
    
    //INSERE AS METAS ATINGIDAS DE VENDA
    preencheMetaELETROCIRURGIA : function(cmp, event, helper){
        
        //CLICK NECESSÁRIO PARA DESBUGAR A CONSULTA
        $('#itemChart').click()
        
        var query = "SELECT Meta__c, vendedor__c, Vendedor__r.Name, Vendedor__r.Title, Vendedor__r.MediumPhotoUrl, inicio__c, final__c, Name FROM Goal__c WHERE Vendedor__r.Name != null AND Estado__c = null AND Linha__c = 'ELETROCIRURGIA' AND Departamento__c = null ORDER BY Vendedor__r.Name"
        
        //realiza a consulta
        helper.soql(cmp, query)
        
        //quando a solicitação for concluída, faça:
        .then(function (metasAtingidas) {

            //CLICK NECESSÁRIO PARA DESBUGAR A CONSULTA
            $('#itemChart').click()
                        
            metasAtingidas.forEach(function (metaVendaAtual) {
                var mesAtualInicio = metaVendaAtual.Inicio__c.split('-')[1]
                var mesAtualFinal = metaVendaAtual.Final__c.split('-')[1]
                var idVendedor = metaVendaAtual.Vendedor__c
                var anoAtual = metaVendaAtual.Final__c.split('-')[0]
                var urlImagemVendedor = metaVendaAtual.Vendedor__r.MediumPhotoUrl
                var cargoVendedor = metaVendaAtual.Vendedor__r.Title
                
                //VERIFICA SE A META LIDA É UMA META MENSAL
                if(mesAtualInicio == mesAtualFinal){
                    var indiceDeEdicao = helper.data.findIndex(e => e.idVendedor == idVendedor)
                    
                    //VERIFICA SE PARA A META ATUAL, EXISTE UM REGISTRO COM VENDAS DO VENDEDOR
                    if(indiceDeEdicao != (-1)){
                        if(helper.data[indiceDeEdicao].metas.eletrocirurgia.length > 0){
                            
                            helper.data[indiceDeEdicao].imagemVendedor = urlImagemVendedor
                            helper.data[indiceDeEdicao].cargoVendedor = cargoVendedor
                            
                            //VERIFICA SE PARA O VENDEDOR ENCONTRADO, EXISTE UM TOTAL VENDIDO DO MES
                            //CASO EXISTA, INSERE NESSE TOTAL VENDIDO DO MES, A META DO MES
                            var indiceEdicaoMes = helper.data[indiceDeEdicao].metas.eletrocirurgia.findIndex(e => e.numeroMes == mesAtualInicio && e.ano == anoAtual)
                            if(indiceEdicaoMes != (-1)){
                                //console.log(metaVendaAtual.Meta__c)
                                //console.log("id do vendedor inserindo" + idVendedor)
                                helper.data[indiceDeEdicao].metas.eletrocirurgia[indiceEdicaoMes].metaMes = metaVendaAtual.Meta__c
                            }
                        }
                    }  
                }else{
                    
                    var indiceDeEdicao = helper.data.findIndex(e => e.idVendedor == idVendedor)
                    
                    //VERIFICA SE PARA A META ATUAL, EXISTE UM REGISTRO COM VENDAS DO VENDEDOR
                    if(indiceDeEdicao != (-1)){
                        if(helper.data[indiceDeEdicao].metas.locacao.length > 0){
                            
                            helper.data[indiceDeEdicao].imagemVendedor = urlImagemVendedor
                            helper.data[indiceDeEdicao].cargoVendedor = cargoVendedor
                            
                            helper.data[indiceDeEdicao].metas.metaAnualEletrocirurgia = metaVendaAtual.Meta__c
                        }
                    }
                    
                }
            })  
            
            //CLICK NECESSÁRIO PARA DESBUGAR A CONSULTA
            $('#itemChart').click()
            
            helper.preencheMetaCMI(cmp, event, helper)
            
        })
        //trata excessão de erro
        .catch(function (error) {
            console.log(error)
        })
    },
    
    //INSERE AS METAS ATINGIDAS DE VENDA
    preencheMetaCMI : function(cmp, event, helper){
        
        //CLICK NECESSÁRIO PARA DESBUGAR A CONSULTA
        $('#itemChart').click()
        
        var query = "SELECT Meta__c, vendedor__c, Familia__c, Vendedor__r.Name, Vendedor__r.Title, Vendedor__r.MediumPhotoUrl, inicio__c, final__c, Name FROM Goal__c WHERE Vendedor__r.Name != null AND Estado__c = null AND Linha__c = 'CMI' AND Familia__c includes ('IMAGEM', 'LAPAROSCOPIA', 'CIRURGIA MINIMAMENTE INVASIVA') AND Departamento__c = null ORDER BY Vendedor__r.Name"
        
        //realiza a consulta
        helper.soql(cmp, query)
        
        //quando a solicitação for concluída, faça:
        .then(function (metasAtingidas) {

            //CLICK NECESSÁRIO PARA DESBUGAR A CONSULTA
            $('#itemChart').click()
                        
            metasAtingidas.forEach(function (metaVendaAtual) {
                var mesAtualInicio = metaVendaAtual.Inicio__c.split('-')[1]
                var mesAtualFinal = metaVendaAtual.Final__c.split('-')[1]
                var idVendedor = metaVendaAtual.Vendedor__c
                var anoAtual = metaVendaAtual.Final__c.split('-')[0]
                var urlImagemVendedor = metaVendaAtual.Vendedor__r.MediumPhotoUrl
                var cargoVendedor = metaVendaAtual.Vendedor__r.Title
                
                //VERIFICA SE A META LIDA É UMA META MENSAL
                if(mesAtualInicio == mesAtualFinal){
                    var indiceDeEdicao = helper.data.findIndex(e => e.idVendedor == idVendedor)
                    
                    //VERIFICA SE PARA A META ATUAL, EXISTE UM REGISTRO COM VENDAS DO VENDEDOR
                    if(indiceDeEdicao != (-1)){
                        if(helper.data[indiceDeEdicao].metas.cmiImagemLaparo.length > 0){
                            
                            helper.data[indiceDeEdicao].imagemVendedor = urlImagemVendedor
                            helper.data[indiceDeEdicao].cargoVendedor = cargoVendedor
                            
                            //VERIFICA SE PARA O VENDEDOR ENCONTRADO, EXISTE UM TOTAL VENDIDO DO MES
                            //CASO EXISTA, INSERE NESSE TOTAL VENDIDO DO MES, A META DO MES
                            var indiceEdicaoMes = helper.data[indiceDeEdicao].metas.cmiImagemLaparo.findIndex(e => e.numeroMes == mesAtualInicio && e.ano == anoAtual)
                            if(indiceEdicaoMes != (-1)){
                                //console.log(metaVendaAtual.Meta__c)
                                //console.log("id do vendedor inserindo" + idVendedor)
                                helper.data[indiceDeEdicao].metas.cmiImagemLaparo[indiceEdicaoMes].metaMes = metaVendaAtual.Meta__c
                            }
                        }
                    }
                }else{
                    
                    var indiceDeEdicao = helper.data.findIndex(e => e.idVendedor == idVendedor)
                    
                    //VERIFICA SE PARA A META ATUAL, EXISTE UM REGISTRO COM VENDAS DO VENDEDOR
                    if(indiceDeEdicao != (-1)){
                        if(helper.data[indiceDeEdicao].metas.locacao.length > 0){
                            
                            helper.data[indiceDeEdicao].imagemVendedor = urlImagemVendedor
                            helper.data[indiceDeEdicao].cargoVendedor = cargoVendedor
                            
                            helper.data[indiceDeEdicao].metas.metaAnualCmiImagemLaparo = metaVendaAtual.Meta__c
                        }
                    }
                    
                }
            })  
            
            //CLICK NECESSÁRIO PARA DESBUGAR A CONSULTA
            $('#itemChart').click()
            
            helper.preencheMetaCMIUroGineco(cmp, event, helper)
            
        })
        //trata excessão de erro
        .catch(function (error) {
            console.log(error)
        })
    },
        
    //INSERE AS METAS ATINGIDAS DE VENDA
    preencheMetaCMIUroGineco : function(cmp, event, helper){
        
        //CLICK NECESSÁRIO PARA DESBUGAR A CONSULTA
        $('#itemChart').click()
        
        var query = "SELECT Meta__c, vendedor__c, Familia__c, Vendedor__r.Name, Vendedor__r.Title, Vendedor__r.MediumPhotoUrl, inicio__c, final__c, Name FROM Goal__c WHERE Vendedor__r.Name != null AND Estado__c = null AND Linha__c = 'CMI' AND Familia__c includes ('UROLOGIA', 'GINECOLOGIA') AND Departamento__c = null ORDER BY Vendedor__r.Name"
        
        //realiza a consulta
        helper.soql(cmp, query)
        
        //quando a solicitação for concluída, faça:
        .then(function (metasAtingidas) {

            //CLICK NECESSÁRIO PARA DESBUGAR A CONSULTA
            $('#itemChart').click()
                        
            metasAtingidas.forEach(function (metaVendaAtual) {
                var mesAtualInicio = metaVendaAtual.Inicio__c.split('-')[1]
                var mesAtualFinal = metaVendaAtual.Final__c.split('-')[1]
                var idVendedor = metaVendaAtual.Vendedor__c
                var anoAtual = metaVendaAtual.Final__c.split('-')[0]
                var urlImagemVendedor = metaVendaAtual.Vendedor__r.MediumPhotoUrl
                var cargoVendedor = metaVendaAtual.Vendedor__r.Title
                
                //VERIFICA SE A META LIDA É UMA META MENSAL
                if(mesAtualInicio == mesAtualFinal){
                    var indiceDeEdicao = helper.data.findIndex(e => e.idVendedor == idVendedor)
                    
                    //VERIFICA SE PARA A META ATUAL, EXISTE UM REGISTRO COM VENDAS DO VENDEDOR
                    if(indiceDeEdicao != (-1)){
                        if(helper.data[indiceDeEdicao].metas.cmiUroGineco.length > 0){
                            
                            helper.data[indiceDeEdicao].imagemVendedor = urlImagemVendedor
                            helper.data[indiceDeEdicao].cargoVendedor = cargoVendedor
                            
                            //VERIFICA SE PARA O VENDEDOR ENCONTRADO, EXISTE UM TOTAL VENDIDO DO MES
                            //CASO EXISTA, INSERE NESSE TOTAL VENDIDO DO MES, A META DO MES
                            var indiceEdicaoMes = helper.data[indiceDeEdicao].metas.cmiUroGineco.findIndex(e => e.numeroMes == mesAtualInicio && e.ano == anoAtual)
                            if(indiceEdicaoMes != (-1)){
                                //console.log(metaVendaAtual.Meta__c)
                                //console.log("id do vendedor inserindo" + idVendedor)
                                helper.data[indiceDeEdicao].metas.cmiUroGineco[indiceEdicaoMes].metaMes = metaVendaAtual.Meta__c
                            }
                        }
                    }
                }else{
                    
                    var indiceDeEdicao = helper.data.findIndex(e => e.idVendedor == idVendedor)
                    
                    //VERIFICA SE PARA A META ATUAL, EXISTE UM REGISTRO COM VENDAS DO VENDEDOR
                    if(indiceDeEdicao != (-1)){
                        if(true){
                            
                            helper.data[indiceDeEdicao].imagemVendedor = urlImagemVendedor
                            helper.data[indiceDeEdicao].cargoVendedor = cargoVendedor
                            
                            helper.data[indiceDeEdicao].metas.metaAnualCmiUroGineco = metaVendaAtual.Meta__c
                        }
                    }
                    
                }
            })  
            
            //CLICK NECESSÁRIO PARA DESBUGAR A CONSULTA
            $('#itemChart').click()
            
            helper.preencheMetaOUTROS(cmp, event, helper)
            
        })
        //trata excessão de erro
        .catch(function (error) {
            console.log(error)
        })
    },
        
    //INSERE AS METAS ATINGIDAS DE VENDA
    preencheMetaOUTROS : function(cmp, event, helper){
        
        //CLICK NECESSÁRIO PARA DESBUGAR A CONSULTA
        $('#itemChart').click()
        
        var query = "SELECT Meta__c, vendedor__c, Vendedor__r.Name, Vendedor__r.Title, Vendedor__r.MediumPhotoUrl, inicio__c, final__c, Name FROM Goal__c WHERE Vendedor__r.Name != null AND Estado__c = null AND Linha__c = 'OUTROS' AND Departamento__c = null ORDER BY Vendedor__r.Name"
        
        //realiza a consulta
        helper.soql(cmp, query)
        
        //quando a solicitação for concluída, faça:
        .then(function (metasAtingidas) {

            //CLICK NECESSÁRIO PARA DESBUGAR A CONSULTA
            $('#itemChart').click()
                        
            metasAtingidas.forEach(function (metaVendaAtual) {
                var mesAtualInicio = metaVendaAtual.Inicio__c.split('-')[1]
                var mesAtualFinal = metaVendaAtual.Final__c.split('-')[1]
                var idVendedor = metaVendaAtual.Vendedor__c
                var anoAtual = metaVendaAtual.Final__c.split('-')[0]
                var urlImagemVendedor = metaVendaAtual.Vendedor__r.MediumPhotoUrl
                var cargoVendedor = metaVendaAtual.Vendedor__r.Title
                
                //VERIFICA SE A META LIDA É UMA META MENSAL
                if(mesAtualInicio == mesAtualFinal){
                    var indiceDeEdicao = helper.data.findIndex(e => e.idVendedor == idVendedor)
                    
                    //VERIFICA SE PARA A META ATUAL, EXISTE UM REGISTRO COM VENDAS DO VENDEDOR
                    if(indiceDeEdicao != (-1)){
                        if(helper.data[indiceDeEdicao].metas.outros.length > 0){
                            
                            helper.data[indiceDeEdicao].imagemVendedor = urlImagemVendedor
                            helper.data[indiceDeEdicao].cargoVendedor = cargoVendedor
                            
                            //VERIFICA SE PARA O VENDEDOR ENCONTRADO, EXISTE UM TOTAL VENDIDO DO MES
                            //CASO EXISTA, INSERE NESSE TOTAL VENDIDO DO MES, A META DO MES
                            var indiceEdicaoMes = helper.data[indiceDeEdicao].metas.outros.findIndex(e => e.numeroMes == mesAtualInicio && e.ano == anoAtual)
                            if(indiceEdicaoMes != (-1)){
                                //console.log(metaVendaAtual.Meta__c)
                                //console.log("id do vendedor inserindo" + idVendedor)
                                helper.data[indiceDeEdicao].metas.outros[indiceEdicaoMes].metaMes = metaVendaAtual.Meta__c
                            }
                        }
                    }
                }else{
                    
                    var indiceDeEdicao = helper.data.findIndex(e => e.idVendedor == idVendedor)
                    
                    //VERIFICA SE PARA A META ATUAL, EXISTE UM REGISTRO COM VENDAS DO VENDEDOR
                    if(indiceDeEdicao != (-1)){
                        if(helper.data[indiceDeEdicao].metas.locacao.length > 0){
                            
                            helper.data[indiceDeEdicao].imagemVendedor = urlImagemVendedor
                            helper.data[indiceDeEdicao].cargoVendedor = cargoVendedor
                            
                            helper.data[indiceDeEdicao].metas.metaAnualOutros = metaVendaAtual.Meta__c
                        }
                    }
                    
                }
            })  
            
            //CLICK NECESSÁRIO PARA DESBUGAR A CONSULTA
            $('#itemChart').click()
            
            helper.preencheMetaLOCACAO(cmp, event, helper)
            
        })
        //trata excessão de erro
        .catch(function (error) {
            console.log(error)
        })
    },
    
    //INSERE AS METAS ATINGIDAS DE VENDA
    preencheMetaLOCACAO : function(cmp, event, helper){
        
        //CLICK NECESSÁRIO PARA DESBUGAR A CONSULTA
        $('#itemChart').click()
        
        var query = "SELECT Meta__c, vendedor__c, Vendedor__r.Name, Vendedor__r.Title, Vendedor__r.MediumPhotoUrl, inicio__c, final__c, Name FROM Goal__c WHERE Vendedor__r.Name != null AND Estado__c = null AND Linha__c = null AND Departamento__c = 'Locação' ORDER BY Vendedor__r.Name"
        
        //realiza a consulta
        helper.soql(cmp, query)
        
        //quando a solicitação for concluída, faça:
        .then(function (metasAtingidas) {

            //CLICK NECESSÁRIO PARA DESBUGAR A CONSULTA
            $('#itemChart').click()
                        
            metasAtingidas.forEach(function (metaVendaAtual) {
                var mesAtualInicio = metaVendaAtual.Inicio__c.split('-')[1]
                var mesAtualFinal = metaVendaAtual.Final__c.split('-')[1]
                var idVendedor = metaVendaAtual.Vendedor__c
                var anoAtual = metaVendaAtual.Final__c.split('-')[0]
                var urlImagemVendedor = metaVendaAtual.Vendedor__r.MediumPhotoUrl
                var cargoVendedor = metaVendaAtual.Vendedor__r.Title
                
                //VERIFICA SE A META LIDA É UMA META MENSAL
                if(mesAtualInicio == mesAtualFinal){
                    var indiceDeEdicao = helper.data.findIndex(e => e.idVendedor == idVendedor)
                    
                    //VERIFICA SE PARA A META ATUAL, EXISTE UM REGISTRO COM VENDAS DO VENDEDOR
                    if(indiceDeEdicao != (-1)){
                        if(helper.data[indiceDeEdicao].metas.locacao.length > 0){
                            
                            helper.data[indiceDeEdicao].imagemVendedor = urlImagemVendedor
                            helper.data[indiceDeEdicao].cargoVendedor = cargoVendedor
                            
                            //VERIFICA SE PARA O VENDEDOR ENCONTRADO, EXISTE UM TOTAL VENDIDO DO MES
                            //CASO EXISTA, INSERE NESSE TOTAL VENDIDO DO MES, A META DO MES
                            var indiceEdicaoMes = helper.data[indiceDeEdicao].metas.locacao.findIndex(e => e.numeroMes == mesAtualInicio && e.ano == anoAtual)
                            if(indiceEdicaoMes != (-1)){
                                helper.data[indiceDeEdicao].metas.locacao[indiceEdicaoMes].metaMes = metaVendaAtual.Meta__c
                            }
                        }
                    }
                }else{
                    
                    var indiceDeEdicao = helper.data.findIndex(e => e.idVendedor == idVendedor)
                    
                    //VERIFICA SE PARA A META ATUAL, EXISTE UM REGISTRO COM VENDAS DO VENDEDOR
                    if(indiceDeEdicao != (-1)){
                        if(helper.data[indiceDeEdicao].metas.locacao.length > 0){
                            
                            helper.data[indiceDeEdicao].imagemVendedor = urlImagemVendedor
                            helper.data[indiceDeEdicao].cargoVendedor = cargoVendedor
                            
                            helper.data[indiceDeEdicao].metas.metaAnualLocacao = metaVendaAtual.Meta__c
                        }
                    }
                    
                }
            })  
            
            //CLICK NECESSÁRIO PARA DESBUGAR A CONSULTA
            $('#itemChart').click()
            
            helper.preencheMetaVISITAS(cmp, event, helper)
            
        })
        //trata excessão de erro
        .catch(function (error) {
            console.log(error)
        })
    },
        
    //INSERE AS METAS ATINGIDAS DE VENDA
    preencheMetaVISITAS : function(cmp, event, helper){
        
        //CLICK NECESSÁRIO PARA DESBUGAR A CONSULTA
        $('#itemChart').click()
        
        var query = "SELECT METAS_DE_VISITAS__c, vendedor__c, Vendedor__r.Name, Vendedor__r.Title, Vendedor__r.MediumPhotoUrl, inicio__c, final__c, Name FROM Goal__c WHERE Vendedor__r.Name != null AND Estado__c = null AND Linha__c = null AND Departamento__c = null ORDER BY Vendedor__r.Name"
        
        //realiza a consulta
        helper.soql(cmp, query)
        
        //quando a solicitação for concluída, faça:
        .then(function (metasAtingidas) {
            
            //CLICK NECESSÁRIO PARA DESBUGAR A CONSULTA
            $('#itemChart').click()
            
            //console.log("METAS ATINGIDAS VISITAS")
            //console.log(metasAtingidas)
             
            metasAtingidas.forEach(function (metaVendaAtual) {
                var mesAtualInicio = metaVendaAtual.Inicio__c.split('-')[1]
                var mesAtualFinal = metaVendaAtual.Final__c.split('-')[1]
                var idVendedor = metaVendaAtual.Vendedor__c
                var anoAtual = metaVendaAtual.Final__c.split('-')[0]
                var urlImagemVendedor = metaVendaAtual.Vendedor__r.MediumPhotoUrl
                var cargoVendedor = metaVendaAtual.Vendedor__r.Title
                
                //VERIFICA SE A META LIDA É UMA META MENSAL
                if(mesAtualInicio == mesAtualFinal){
                    var indiceDeEdicao = helper.data.findIndex(e => e.idVendedor == idVendedor)
                    
                    //VERIFICA SE PARA A META ATUAL, EXISTE UM REGISTRO COM VENDAS DO VENDEDOR
                    if(indiceDeEdicao != (-1)){
                        if(helper.data[indiceDeEdicao].metas.quantidadeVisitas.length > 0){
                            
                            helper.data[indiceDeEdicao].imagemVendedor = urlImagemVendedor
                            helper.data[indiceDeEdicao].cargoVendedor = cargoVendedor
                            
                            //VERIFICA SE PARA O VENDEDOR ENCONTRADO, EXISTE UM TOTAL VENDIDO DO MES
                            //CASO EXISTA, INSERE NESSE TOTAL VENDIDO DO MES, A META DO MES
                            var indiceEdicaoMes = helper.data[indiceDeEdicao].metas.quantidadeVisitas.findIndex(e => e.numeroMes == mesAtualInicio && e.ano == anoAtual)
                            if(indiceEdicaoMes != (-1)){
                                if(metaVendaAtual.METAS_DE_VISITAS__c != undefined){
                                    helper.data[indiceDeEdicao].metas.quantidadeVisitas[indiceEdicaoMes].metaMes = metaVendaAtual.METAS_DE_VISITAS__c
                                }
                            }
                        }
                    }
                }else{
                    
                    var indiceDeEdicao = helper.data.findIndex(e => e.idVendedor == idVendedor)
                    
                    //VERIFICA SE PARA A META ATUAL, EXISTE UM REGISTRO COM VENDAS DO VENDEDOR
                    if(indiceDeEdicao != (-1)){
                        //VERIFICA SE A META ANUAL LIDA NESSA ITERACAO É CORRESPONDE AO ANO SETADO
                        if(anoAtual == helper.anoSetado){
                            
                            helper.data[indiceDeEdicao].imagemVendedor = urlImagemVendedor
                            helper.data[indiceDeEdicao].cargoVendedor = cargoVendedor
                            
                            helper.data[indiceDeEdicao].metas.metaAnualVisitas = metaVendaAtual.METAS_DE_VISITAS__c
                        }
                    }
                    
                }
            })  
            
            //CLICK NECESSÁRIO PARA DESBUGAR A CONSULTA
            $('#itemChart').click()
            
            helper.preencheMetaOpps(cmp, event, helper)
            
        })
        //trata excessão de erro
        .catch(function (error) {
            console.log(error)
        })
    },
        
    //INSERE AS METAS ATINGIDAS DE VENDA
    preencheMetaOpps : function(cmp, event, helper){
        
        //CLICK NECESSÁRIO PARA DESBUGAR A CONSULTA
        $('#itemChart').click()
        
        var query = "SELECT META_DE_OPPS_CRIADAS__c, vendedor__c, Vendedor__r.Name, Vendedor__r.Title, Vendedor__r.MediumPhotoUrl, inicio__c, final__c, Name FROM Goal__c WHERE Vendedor__r.Name != null AND Estado__c = null AND Linha__c = null AND Departamento__c = null ORDER BY Vendedor__r.Name"
        
        //realiza a consulta
        helper.soql(cmp, query)
        
        //quando a solicitação for concluída, faça:
        .then(function (metasAtingidas) {
            
            //CLICK NECESSÁRIO PARA DESBUGAR A CONSULTA
            $('#itemChart').click()
            
            //console.log("METAS ATINGIDAS VISITAS")
            //console.log(metasAtingidas)
             
            metasAtingidas.forEach(function (metaVendaAtual) {
                var mesAtualInicio = metaVendaAtual.Inicio__c.split('-')[1]
                var mesAtualFinal = metaVendaAtual.Final__c.split('-')[1]
                var idVendedor = metaVendaAtual.Vendedor__c
                var anoAtual = metaVendaAtual.Final__c.split('-')[0]
                var urlImagemVendedor = metaVendaAtual.Vendedor__r.MediumPhotoUrl
                var cargoVendedor = metaVendaAtual.Vendedor__r.Title
                
                //VERIFICA SE A META LIDA É UMA META MENSAL
                if(mesAtualInicio == mesAtualFinal){
                    var indiceDeEdicao = helper.data.findIndex(e => e.idVendedor == idVendedor)
                    
                    //VERIFICA SE PARA A META ATUAL, EXISTE UM REGISTRO COM VENDAS DO VENDEDOR
                    if(indiceDeEdicao != (-1)){
                        if(helper.data[indiceDeEdicao].metas.quantidadeOpp.length > 0){
                            
                            helper.data[indiceDeEdicao].imagemVendedor = urlImagemVendedor
                            helper.data[indiceDeEdicao].cargoVendedor = cargoVendedor
                            
                            //VERIFICA SE PARA O VENDEDOR ENCONTRADO, EXISTE UM TOTAL VENDIDO DO MES
                            //CASO EXISTA, INSERE NESSE TOTAL VENDIDO DO MES, A META DO MES
                            var indiceEdicaoMes = helper.data[indiceDeEdicao].metas.quantidadeOpp.findIndex(e => e.numeroMes == mesAtualInicio && e.ano == anoAtual)
                            if(indiceEdicaoMes != (-1)){
                                if(metaVendaAtual.META_DE_OPPS_CRIADAS__c != undefined){
                                    helper.data[indiceDeEdicao].metas.quantidadeOpp[indiceEdicaoMes].metaMes = metaVendaAtual.META_DE_OPPS_CRIADAS__c
                                }
                            }
                        }
                    }
                }else{
                    
                    var indiceDeEdicao = helper.data.findIndex(e => e.idVendedor == idVendedor)
                    
                    //VERIFICA SE PARA A META ATUAL, EXISTE UM REGISTRO COM VENDAS DO VENDEDOR
                    if(indiceDeEdicao != (-1)){
                        //VERIFICA SE A META ANUAL LIDA NESSA ITERACAO É CORRESPONDE AO ANO SETADO
                        if(anoAtual == helper.anoSetado){
                            
                            helper.data[indiceDeEdicao].imagemVendedor = urlImagemVendedor
                            helper.data[indiceDeEdicao].cargoVendedor = cargoVendedor
                            helper.data[indiceDeEdicao].metas.metaAnualOpps = metaVendaAtual.META_DE_OPPS_CRIADAS__c
                        }
                    }
                    
                }
            })  
            
            //CLICK NECESSÁRIO PARA DESBUGAR A CONSULTA
            $('#itemChart').click()
            
            helper.preencheMetaDemo(cmp, event, helper)
            
        })
        //trata excessão de erro
        .catch(function (error) {
            console.log(error)
        })
    },
        
    //INSERE AS METAS ATINGIDAS DE VENDA
    preencheMetaDemo : function(cmp, event, helper){
        
        //CLICK NECESSÁRIO PARA DESBUGAR A CONSULTA
        $('#itemChart').click()
        
        var query = "SELECT METAS_DE_DEMONSTRA_O__c, vendedor__c, Vendedor__r.Name, Vendedor__r.Title, Vendedor__r.MediumPhotoUrl, inicio__c, final__c, Name FROM Goal__c WHERE Vendedor__r.Name != null AND Estado__c = null AND Linha__c = null AND Departamento__c = null ORDER BY Vendedor__r.Name"
        
        //realiza a consulta
        helper.soql(cmp, query)
        
        //quando a solicitação for concluída, faça:
        .then(function (metasAtingidas) {
            
            //CLICK NECESSÁRIO PARA DESBUGAR A CONSULTA
            $('#itemChart').click()
             
            metasAtingidas.forEach(function (metaVendaAtual) {
                var mesAtualInicio = metaVendaAtual.Inicio__c.split('-')[1]
                var mesAtualFinal = metaVendaAtual.Final__c.split('-')[1]
                var idVendedor = metaVendaAtual.Vendedor__c
                var anoAtual = metaVendaAtual.Final__c.split('-')[0]
                var urlImagemVendedor = metaVendaAtual.Vendedor__r.MediumPhotoUrl
                var cargoVendedor = metaVendaAtual.Vendedor__r.Title
                
                //VERIFICA SE A META LIDA É UMA META MENSAL
                if(mesAtualInicio == mesAtualFinal){
                    var indiceDeEdicao = helper.data.findIndex(e => e.idVendedor == idVendedor)
                    
                    //VERIFICA SE PARA A META ATUAL, EXISTE UM REGISTRO COM VENDAS DO VENDEDOR
                    if(indiceDeEdicao != (-1)){
                        if(helper.data[indiceDeEdicao].metas.quantidadeDemo.length > 0){
                            
                            helper.data[indiceDeEdicao].imagemVendedor = urlImagemVendedor
                            helper.data[indiceDeEdicao].cargoVendedor = cargoVendedor
                            
                            //VERIFICA SE PARA O VENDEDOR ENCONTRADO, EXISTE UM TOTAL VENDIDO DO MES
                            //CASO EXISTA, INSERE NESSE TOTAL VENDIDO DO MES, A META DO MES
                            var indiceEdicaoMes = helper.data[indiceDeEdicao].metas.quantidadeDemo.findIndex(e => e.numeroMes == mesAtualInicio && e.ano == anoAtual)
                            if(indiceEdicaoMes != (-1)){
                                if(metaVendaAtual.METAS_DE_DEMONSTRA_O__c != undefined){
                                    helper.data[indiceDeEdicao].metas.quantidadeDemo[indiceEdicaoMes].metaMes = metaVendaAtual.METAS_DE_DEMONSTRA_O__c
                                }
                            }
                        }
                    }
                }else{
                    
                    var indiceDeEdicao = helper.data.findIndex(e => e.idVendedor == idVendedor)
                    
                    //VERIFICA SE PARA A META ATUAL, EXISTE UM REGISTRO COM VENDAS DO VENDEDOR
                    if(indiceDeEdicao != (-1)){
                        //VERIFICA SE A META ANUAL LIDA NESSA ITERACAO É CORRESPONDE AO ANO SETADO
                        if(anoAtual == helper.anoSetado){
                            helper.data[indiceDeEdicao].imagemVendedor = urlImagemVendedor
                            helper.data[indiceDeEdicao].cargoVendedor = cargoVendedor
                            
                            helper.data[indiceDeEdicao].metas.metaAnualDemo = metaVendaAtual.METAS_DE_DEMONSTRA_O__c
                        }
                    }
                    
                }
            })  
            
            //CLICK NECESSÁRIO PARA DESBUGAR A CONSULTA
            $('#itemChart').click()
            
            helper.calculaSaldos(cmp, event, helper)
            
        })
        //trata excessão de erro
        .catch(function (error) {
            console.log(error)
        })
    },
        
    //=========================SESSOES QUE CALCULAM OS SALDOS DAS METAS==============================//
    //-----------------------------------------------------------------------------------------------//
    
    //CALCULA OS SALDOS DAS VENDAS GERAL
    calculaSaldos : function(cmp, event, helper){
        //CLICK NECESSÁRIO PARA DESBUGAR A CONSULTA
        $('#itemChart').click()
        
        helper.data.forEach(function (itemAtual){
            if(itemAtual.metas.vendas.length > 0){
                itemAtual.metas.vendas.forEach(function (itemInternoAtual){
                    
                    if(itemInternoAtual.hasOwnProperty('metaMes')){
                        var total = itemInternoAtual.total
                        var metaMes = itemInternoAtual.metaMes
                        var saldo = (total - metaMes).toFixed(1);
                        var porcentagem = (total/metaMes * 100).toFixed(1);
                       
                        itemInternoAtual.percentualRealizado = porcentagem
                        itemInternoAtual.saldo = saldo
                    }
                    
                })
            }
            
            itemAtual.metas.vendasTrimestre = [];
        	itemAtual.metas.vendas.forEach(v => {
            	const vendasTriObj = itemAtual.metas.vendasTrimestre.find(value => value.ano == v.ano && Math.floor((v.numeroMes - 1)/3) + 1 == value.numeroTrimestre)
            	if(vendasTriObj == undefined){
            		const newTriObj = {ano: v.ano, numeroTrimestre: Math.floor((v.numeroMes - 1)/3) + 1, saldo: Number((v.saldo ? v.saldo : 0))}
                    itemAtual.metas.vendasTrimestre.push(newTriObj)
            	} else {
            		vendasTriObj.saldo = (vendasTriObj.saldo * 100 + Number(v.saldo ? v.saldo : 0) * 100)/100;
        		}
         	});

        })
        
        //CLICK NECESSÁRIO PARA DESBUGAR A CONSULTA
        $('#itemChart').click()
        
        helper.calculaSaldosLOCACAO(cmp, event, helper)
    },
    
    //CALCULA OS DALDOS DAS VENDAS DE LOCACAO
    calculaSaldosLOCACAO : function(cmp, event, helper){
        //CLICK NECESSÁRIO PARA DESBUGAR A CONSULTA
        $('#itemChart').click()
        
        helper.data.forEach(function (itemAtual){
            if(itemAtual.metas.locacao.length > 0){
                itemAtual.metas.locacao.forEach(function (itemInternoAtual){
                    
                    if(itemInternoAtual.hasOwnProperty('metaMes')){
                        var total = itemInternoAtual.total
                        var metaMes = itemInternoAtual.metaMes
                        var saldo = (total - metaMes).toFixed(1);
                        var porcentagem = (total/metaMes * 100).toFixed(1);
                       
                        itemInternoAtual.percentualRealizado = porcentagem
                        itemInternoAtual.saldo = saldo
                    }
                    
                })
            }
            
            itemAtual.metas.vendasTrimestreLOCACAO = [];
        	itemAtual.metas.locacao.forEach(v => {
            	const vendasTriObj = itemAtual.metas.vendasTrimestreLOCACAO.find(value => value.ano == v.ano && Math.floor((v.numeroMes - 1)/3) + 1 == value.numeroTrimestre)
            	if(vendasTriObj == undefined){
            		const newTriObj = {ano: v.ano, numeroTrimestre: Math.floor((v.numeroMes - 1)/3) + 1, saldo: Number((v.saldo ? v.saldo : 0))}
                    itemAtual.metas.vendasTrimestreLOCACAO.push(newTriObj)
            	} else {
            		vendasTriObj.saldo = (vendasTriObj.saldo * 100 + Number(v.saldo ? v.saldo : 0) * 100)/100;
        		}
         	});

        })
        
        //CLICK NECESSÁRIO PARA DESBUGAR A CONSULTA
        $('#itemChart').click()
        
        helper.calculaSaldosPMLS(cmp, event, helper)
    },
        
    //CALCULA OS DALDOS DAS VENDAS DE PMLS
    calculaSaldosPMLS : function(cmp, event, helper){
        //CLICK NECESSÁRIO PARA DESBUGAR A CONSULTA
        $('#itemChart').click()
        
        helper.data.forEach(function (itemAtual){
            if(itemAtual.metas.pmls.length > 0){
                itemAtual.metas.pmls.forEach(function (itemInternoAtual){
                    
                    if(itemInternoAtual.hasOwnProperty('metaMes')){
                        var total = itemInternoAtual.total
                        var metaMes = itemInternoAtual.metaMes
                        var saldo = (total - metaMes).toFixed(1);
                        var porcentagem = (total/metaMes * 100).toFixed(1);
                       
                        itemInternoAtual.percentualRealizado = porcentagem
                        itemInternoAtual.saldo = saldo
                    }
                    
                })
            }
            
            itemAtual.metas.vendasTrimestrePMLS = [];
        	itemAtual.metas.pmls.forEach(v => {
            	const vendasTriObj = itemAtual.metas.vendasTrimestrePMLS.find(value => value.ano == v.ano && Math.floor((v.numeroMes - 1)/3) + 1 == value.numeroTrimestre)
            	if(vendasTriObj == undefined){
            		const newTriObj = {ano: v.ano, numeroTrimestre: Math.floor((v.numeroMes - 1)/3) + 1, saldo: Number((v.saldo ? v.saldo : 0))}
                    itemAtual.metas.vendasTrimestrePMLS.push(newTriObj)
            	} else {
            		vendasTriObj.saldo = (vendasTriObj.saldo * 100 + Number(v.saldo ? v.saldo : 0) * 100)/100;
        		}
         	});

        })
        
        //CLICK NECESSÁRIO PARA DESBUGAR A CONSULTA
        $('#itemChart').click()
        
        helper.calculaSaldosSURGICAL(cmp, event, helper)
    },
        
    //CALCULA OS DALDOS DAS VENDAS DE PMLS
    calculaSaldosSURGICAL : function(cmp, event, helper){
        //CLICK NECESSÁRIO PARA DESBUGAR A CONSULTA
        $('#itemChart').click()
        
        helper.data.forEach(function (itemAtual){
            if(itemAtual.metas.surgical.length > 0){
                itemAtual.metas.surgical.forEach(function (itemInternoAtual){
                    
                    if(itemInternoAtual.hasOwnProperty('metaMes')){
                        var total = itemInternoAtual.total
                        var metaMes = itemInternoAtual.metaMes
                        var saldo = (total - metaMes).toFixed(1);
                        var porcentagem = (total/metaMes * 100).toFixed(1);
                       
                        itemInternoAtual.percentualRealizado = porcentagem
                        itemInternoAtual.saldo = saldo
                    }
                    
                })
            }
            
            itemAtual.metas.vendasTrimestreSURGICAL = [];
        	itemAtual.metas.surgical.forEach(v => {
            	const vendasTriObj = itemAtual.metas.vendasTrimestreSURGICAL.find(value => value.ano == v.ano && Math.floor((v.numeroMes - 1)/3) + 1 == value.numeroTrimestre)
            	if(vendasTriObj == undefined){
            		const newTriObj = {ano: v.ano, numeroTrimestre: Math.floor((v.numeroMes - 1)/3) + 1, saldo: Number((v.saldo ? v.saldo : 0))}
                    itemAtual.metas.vendasTrimestreSURGICAL.push(newTriObj)
            	} else {
            		vendasTriObj.saldo = (vendasTriObj.saldo * 100 + Number(v.saldo ? v.saldo : 0) * 100)/100;
        		}
         	});

        })
        
        //CLICK NECESSÁRIO PARA DESBUGAR A CONSULTA
        $('#itemChart').click()
        
        helper.calculaSaldosCMI(cmp, event, helper)
    },
        
    //CALCULA OS DALDOS DAS VENDAS DE PMLS
    calculaSaldosCMI : function(cmp, event, helper){
        //CLICK NECESSÁRIO PARA DESBUGAR A CONSULTA
        $('#itemChart').click()
        
        helper.data.forEach(function (itemAtual){
            if(itemAtual.metas.cmiImagemLaparo.length > 0){
                itemAtual.metas.cmiImagemLaparo.forEach(function (itemInternoAtual){
                    
                    if(itemInternoAtual.hasOwnProperty('metaMes')){
                        var total = itemInternoAtual.total
                        var metaMes = itemInternoAtual.metaMes
                        var saldo = (total - metaMes).toFixed(1);
                        var porcentagem = (total/metaMes * 100).toFixed(1);
                       
                        itemInternoAtual.percentualRealizado = porcentagem
                        itemInternoAtual.saldo = saldo
                    }
                    
                })
            }
            
            itemAtual.metas.vendasTrimestreCMIImagemLaparo = [];
        	itemAtual.metas.cmiImagemLaparo.forEach(v => {
            	const vendasTriObj = itemAtual.metas.vendasTrimestreCMIImagemLaparo.find(value => value.ano == v.ano && Math.floor((v.numeroMes - 1)/3) + 1 == value.numeroTrimestre)
            	if(vendasTriObj == undefined){
            		const newTriObj = {ano: v.ano, numeroTrimestre: Math.floor((v.numeroMes - 1)/3) + 1, saldo: Number((v.saldo ? v.saldo : 0))}
                    itemAtual.metas.vendasTrimestreCMIImagemLaparo.push(newTriObj)
            	} else {
            		vendasTriObj.saldo = (vendasTriObj.saldo * 100 + Number(v.saldo ? v.saldo : 0) * 100)/100;
        		}
         	});

        })
        
        //CLICK NECESSÁRIO PARA DESBUGAR A CONSULTA
        $('#itemChart').click()
        
        helper.calculaSaldosCMIUroGineco(cmp, event, helper)
    },
        
    //CALCULA OS DALDOS DAS VENDAS DE PMLS
    calculaSaldosCMIUroGineco : function(cmp, event, helper){
        //CLICK NECESSÁRIO PARA DESBUGAR A CONSULTA
        $('#itemChart').click()
        
        helper.data.forEach(function (itemAtual){
            if(itemAtual.metas.cmiUroGineco.length > 0){
                itemAtual.metas.cmiUroGineco.forEach(function (itemInternoAtual){
                    
                    if(itemInternoAtual.hasOwnProperty('metaMes')){
                        var total = itemInternoAtual.total
                        var metaMes = itemInternoAtual.metaMes
                        var saldo = (total - metaMes).toFixed(1);
                        var porcentagem = (total/metaMes * 100).toFixed(1);
                       
                        itemInternoAtual.percentualRealizado = porcentagem
                        itemInternoAtual.saldo = saldo
                    }
                    
                })
            }
            
            itemAtual.metas.vendasTrimestreCMIUroGineco = [];
        	itemAtual.metas.cmiUroGineco.forEach(v => {
            	const vendasTriObj = itemAtual.metas.vendasTrimestreCMIUroGineco.find(value => value.ano == v.ano && Math.floor((v.numeroMes - 1)/3) + 1 == value.numeroTrimestre)
            	if(vendasTriObj == undefined){
            		const newTriObj = {ano: v.ano, numeroTrimestre: Math.floor((v.numeroMes - 1)/3) + 1, saldo: Number((v.saldo ? v.saldo : 0))}
                    itemAtual.metas.vendasTrimestreCMIUroGineco.push(newTriObj)
            	} else {
            		vendasTriObj.saldo = (vendasTriObj.saldo * 100 + Number(v.saldo ? v.saldo : 0) * 100)/100;
        		}
         	});

        })
        
        //CLICK NECESSÁRIO PARA DESBUGAR A CONSULTA
        $('#itemChart').click()
        
        helper.calculaSaldosELETROCIRURGIA(cmp, event, helper)
    },
        
    //CALCULA OS DALDOS DAS VENDAS DE PMLS
    calculaSaldosELETROCIRURGIA : function(cmp, event, helper){
        //CLICK NECESSÁRIO PARA DESBUGAR A CONSULTA
        $('#itemChart').click()
        
        helper.data.forEach(function (itemAtual){
            if(itemAtual.metas.eletrocirurgia.length > 0){
                itemAtual.metas.eletrocirurgia.forEach(function (itemInternoAtual){
                    
                    if(itemInternoAtual.hasOwnProperty('metaMes')){
                        var total = itemInternoAtual.total
                        var metaMes = itemInternoAtual.metaMes
                        var saldo = (total - metaMes).toFixed(1);
                        var porcentagem = (total/metaMes * 100).toFixed(1);
                       
                        itemInternoAtual.percentualRealizado = porcentagem
                        itemInternoAtual.saldo = saldo
                    }
                    
                })
            }
            
            itemAtual.metas.vendasTrimestreELETROCIRURGIA = [];
        	itemAtual.metas.eletrocirurgia.forEach(v => {
            	const vendasTriObj = itemAtual.metas.vendasTrimestreELETROCIRURGIA.find(value => value.ano == v.ano && Math.floor((v.numeroMes - 1)/3) + 1 == value.numeroTrimestre)
            	if(vendasTriObj == undefined){
            		const newTriObj = {ano: v.ano, numeroTrimestre: Math.floor((v.numeroMes - 1)/3) + 1, saldo: Number((v.saldo ? v.saldo : 0))}
                    itemAtual.metas.vendasTrimestreELETROCIRURGIA.push(newTriObj)
            	} else {
            		vendasTriObj.saldo = (vendasTriObj.saldo * 100 + Number(v.saldo ? v.saldo : 0) * 100)/100;
        		}
         	});

        })
        
        //CLICK NECESSÁRIO PARA DESBUGAR A CONSULTA
        $('#itemChart').click()
        
        helper.calculaSaldosULTRASSOM(cmp, event, helper)
    },
        
    //CALCULA OS DALDOS DAS VENDAS DE ULTRASSOM
    calculaSaldosULTRASSOM : function(cmp, event, helper){
        //CLICK NECESSÁRIO PARA DESBUGAR A CONSULTA
        $('#itemChart').click()
        
        helper.data.forEach(function (itemAtual){
            if(itemAtual.metas.ultrassom.length > 0){
                itemAtual.metas.ultrassom.forEach(function (itemInternoAtual){
                    
                    if(itemInternoAtual.hasOwnProperty('metaMes')){
                        var total = itemInternoAtual.total
                        var metaMes = itemInternoAtual.metaMes
                        var saldo = (total - metaMes).toFixed(1);
                        var porcentagem = (total/metaMes * 100).toFixed(1);
                       
                        itemInternoAtual.percentualRealizado = porcentagem
                        itemInternoAtual.saldo = saldo
                    }
                    
                })
            }
            
            itemAtual.metas.vendasTrimestreULTRASSOM = [];
        	itemAtual.metas.ultrassom.forEach(v => {
            	const vendasTriObj = itemAtual.metas.vendasTrimestreULTRASSOM.find(value => value.ano == v.ano && Math.floor((v.numeroMes - 1)/3) + 1 == value.numeroTrimestre)
            	if(vendasTriObj == undefined){
            		const newTriObj = {ano: v.ano, numeroTrimestre: Math.floor((v.numeroMes - 1)/3) + 1, saldo: Number((v.saldo ? v.saldo : 0))}
                    itemAtual.metas.vendasTrimestreULTRASSOM.push(newTriObj)
            	} else {
            		vendasTriObj.saldo = (vendasTriObj.saldo * 100 + Number(v.saldo ? v.saldo : 0) * 100)/100;
        		}
         	});

        })
        
        //CLICK NECESSÁRIO PARA DESBUGAR A CONSULTA
        $('#itemChart').click()
        
        //helper.dataProcessed = helper.data
        helper.calculaSaldosULTRASSOMPOC(cmp, event, helper)
    },
    
    //CALCULA OS DALDOS DAS VENDAS DE ULTRASSOM
    calculaSaldosULTRASSOMPOC : function(cmp, event, helper){
        //CLICK NECESSÁRIO PARA DESBUGAR A CONSULTA
        $('#itemChart').click()
        
        helper.data.forEach(function (itemAtual){
            if(itemAtual.metas.ultrassomPoc.length > 0){
                itemAtual.metas.ultrassomPoc.forEach(function (itemInternoAtual){
                    
                    if(itemInternoAtual.hasOwnProperty('metaMes')){
                        var total = itemInternoAtual.total
                        var metaMes = itemInternoAtual.metaMes
                        var saldo = (total - metaMes).toFixed(1);
                        var porcentagem = (total/metaMes * 100).toFixed(1);
                       
                        itemInternoAtual.percentualRealizado = porcentagem
                        itemInternoAtual.saldo = saldo
                    }
                    
                })
            }
            
            itemAtual.metas.vendasTrimestreULTRASSOMPOC = [];
        	itemAtual.metas.ultrassomPoc.forEach(v => {
            	const vendasTriObj = itemAtual.metas.vendasTrimestreULTRASSOMPOC.find(value => value.ano == v.ano && Math.floor((v.numeroMes - 1)/3) + 1 == value.numeroTrimestre)
            	if(vendasTriObj == undefined){
            		const newTriObj = {ano: v.ano, numeroTrimestre: Math.floor((v.numeroMes - 1)/3) + 1, saldo: Number((v.saldo ? v.saldo : 0))}
                    itemAtual.metas.vendasTrimestreULTRASSOMPOC.push(newTriObj)
            	} else {
            		vendasTriObj.saldo = (vendasTriObj.saldo * 100 + Number(v.saldo ? v.saldo : 0) * 100)/100;
        		}
         	});

        })
        
        //CLICK NECESSÁRIO PARA DESBUGAR A CONSULTA
        $('#itemChart').click()
        
        //helper.dataProcessed = helper.data
        helper.calculaSaldosULTRASSOMFIXO(cmp, event, helper)
    },
        
    //CALCULA OS DALDOS DAS VENDAS DE ULTRASSOM
    calculaSaldosULTRASSOMFIXO : function(cmp, event, helper){
        //CLICK NECESSÁRIO PARA DESBUGAR A CONSULTA
        $('#itemChart').click()
        
        helper.data.forEach(function (itemAtual){
            if(itemAtual.metas.ultrassomFixo.length > 0){
                itemAtual.metas.ultrassomFixo.forEach(function (itemInternoAtual){
                    
                    if(itemInternoAtual.hasOwnProperty('metaMes')){
                        var total = itemInternoAtual.total
                        var metaMes = itemInternoAtual.metaMes
                        var saldo = (total - metaMes).toFixed(1);
                        var porcentagem = (total/metaMes * 100).toFixed(1);
                       
                        itemInternoAtual.percentualRealizado = porcentagem
                        itemInternoAtual.saldo = saldo
                    }
                    
                })
            }
            
            itemAtual.metas.vendasTrimestreULTRASSOMFIXO = [];
        	itemAtual.metas.ultrassomPoc.forEach(v => {
            	const vendasTriObj = itemAtual.metas.vendasTrimestreULTRASSOMFIXO.find(value => value.ano == v.ano && Math.floor((v.numeroMes - 1)/3) + 1 == value.numeroTrimestre)
            	if(vendasTriObj == undefined){
            		const newTriObj = {ano: v.ano, numeroTrimestre: Math.floor((v.numeroMes - 1)/3) + 1, saldo: Number((v.saldo ? v.saldo : 0))}
                    itemAtual.metas.vendasTrimestreULTRASSOMFIXO.push(newTriObj)
            	} else {
            		vendasTriObj.saldo = (vendasTriObj.saldo * 100 + Number(v.saldo ? v.saldo : 0) * 100)/100;
        		}
         	});

        })
        
        //CLICK NECESSÁRIO PARA DESBUGAR A CONSULTA
        $('#itemChart').click()
        
        //helper.dataProcessed = helper.data
        helper.calculaSaldosOUTROS(cmp, event, helper)
    },
        
    //CALCULA OS DALDOS DAS VENDAS DE OUTROS
    calculaSaldosOUTROS : function(cmp, event, helper){
        //CLICK NECESSÁRIO PARA DESBUGAR A CONSULTA
        $('#itemChart').click()
        
        helper.data.forEach(function (itemAtual){
            if(itemAtual.metas.outros.length > 0){
                itemAtual.metas.outros.forEach(function (itemInternoAtual){
                    
                    if(itemInternoAtual.hasOwnProperty('metaMes')){
                        var total = itemInternoAtual.total
                        var metaMes = itemInternoAtual.metaMes
                        var saldo = (total - metaMes).toFixed(1);
                        var porcentagem = (total/metaMes * 100).toFixed(1);
                       
                        itemInternoAtual.percentualRealizado = porcentagem
                        itemInternoAtual.saldo = saldo
                    }
                    
                })
            }
            
            itemAtual.metas.vendasTrimestreOUTROS = [];
        	itemAtual.metas.outros.forEach(v => {
            	const vendasTriObj = itemAtual.metas.vendasTrimestreOUTROS.find(value => value.ano == v.ano && Math.floor((v.numeroMes - 1)/3) + 1 == value.numeroTrimestre)
            	if(vendasTriObj == undefined){
            		const newTriObj = {ano: v.ano, numeroTrimestre: Math.floor((v.numeroMes - 1)/3) + 1, saldo: Number((v.saldo ? v.saldo : 0))}
                    itemAtual.metas.vendasTrimestreOUTROS.push(newTriObj)
            	} else {
            		vendasTriObj.saldo = (vendasTriObj.saldo * 100 + Number(v.saldo ? v.saldo : 0) * 100)/100;
        		}
         	});

        })
        
        //CLICK NECESSÁRIO PARA DESBUGAR A CONSULTA
        $('#itemChart').click()
        
        //helper.dataProcessed = helper.data
        helper.calculaSaldosVISITAS(cmp, event, helper)
    },
        
    //CALCULA OS DALDOS DAS VENDAS DE ULTRASSOM
    calculaSaldosVISITAS : function(cmp, event, helper){
        //CLICK NECESSÁRIO PARA DESBUGAR A CONSULTA
        $('#itemChart').click()
        
        helper.data.forEach(function (itemAtual){
            if(itemAtual.metas.quantidadeVisitas.length > 0){
                itemAtual.metas.quantidadeVisitas.forEach(function (itemInternoAtual){
                    
                    if(itemInternoAtual.hasOwnProperty('metaMes')){
                        var total = itemInternoAtual.total
                        var metaMes = itemInternoAtual.metaMes
                        var saldo = (total - metaMes).toFixed(1);
                        var porcentagem = (total/metaMes * 100).toFixed(1);
                       
                        itemInternoAtual.percentualRealizado = porcentagem
                        itemInternoAtual.saldo = saldo
                    }
                    
                })
            }
            
            itemAtual.metas.vendasTrimestreVISITAS = [];
        	itemAtual.metas.quantidadeVisitas.forEach(v => {
            	const vendasTriObj = itemAtual.metas.vendasTrimestreVISITAS.find(value => value.ano == v.ano && Math.floor((v.numeroMes - 1)/3) + 1 == value.numeroTrimestre)
            	if(vendasTriObj == undefined){
            		const newTriObj = {ano: v.ano, numeroTrimestre: Math.floor((v.numeroMes - 1)/3) + 1, saldo: Number((v.saldo ? v.saldo : 0))}
                    itemAtual.metas.vendasTrimestreVISITAS.push(newTriObj)
            	} else {
            		vendasTriObj.saldo = (vendasTriObj.saldo * 100 + Number(v.saldo ? v.saldo : 0) * 100)/100;
        		}
         	});

        })
        
        //CLICK NECESSÁRIO PARA DESBUGAR A CONSULTA
        $('#itemChart').click()
        
        helper.dataProcessed = helper.data
        helper.calculaSaldosOPPS(cmp, event, helper)
    },
        
    //CALCULA OS DALDOS DAS VENDAS DE ULTRASSOM
    calculaSaldosOPPS : function(cmp, event, helper){
        //CLICK NECESSÁRIO PARA DESBUGAR A CONSULTA
        $('#itemChart').click()
        
        helper.data.forEach(function (itemAtual){
            if(itemAtual.metas.quantidadeOpp.length > 0){
                itemAtual.metas.quantidadeOpp.forEach(function (itemInternoAtual){
                    
                    if(itemInternoAtual.hasOwnProperty('metaMes')){
                        var total = itemInternoAtual.total
                        var metaMes = itemInternoAtual.metaMes
                        var saldo = (total - metaMes).toFixed(1);
                        var porcentagem = (total/metaMes * 100).toFixed(1);
                       
                        itemInternoAtual.percentualRealizado = porcentagem
                        itemInternoAtual.saldo = saldo
                    }
                    
                })
            }
            
            itemAtual.metas.vendasTrimestreOPPS = [];
        	itemAtual.metas.quantidadeOpp.forEach(v => {
            	const vendasTriObj = itemAtual.metas.vendasTrimestreOPPS.find(value => value.ano == v.ano && Math.floor((v.numeroMes - 1)/3) + 1 == value.numeroTrimestre)
            	if(vendasTriObj == undefined){
            		const newTriObj = {ano: v.ano, numeroTrimestre: Math.floor((v.numeroMes - 1)/3) + 1, saldo: Number((v.saldo ? v.saldo : 0))}
                    itemAtual.metas.vendasTrimestreOPPS.push(newTriObj)
            	} else {
            		vendasTriObj.saldo = (vendasTriObj.saldo * 100 + Number(v.saldo ? v.saldo : 0) * 100)/100;
        		}
         	});

        })
        
        //CLICK NECESSÁRIO PARA DESBUGAR A CONSULTA
        $('#itemChart').click()
        
        helper.dataProcessed = helper.data
        helper.calculaSaldosDEMO(cmp, event, helper)
    },
    
    //CALCULA OS DALDOS DAS VENDAS DE ULTRASSOM
    calculaSaldosDEMO : function(cmp, event, helper){
            //CLICK NECESSÁRIO PARA DESBUGAR A CONSULTA
            $('#itemChart').click()
            
            helper.data.forEach(function (itemAtual){
                if(itemAtual.metas.quantidadeDemo.length > 0){
                    itemAtual.metas.quantidadeDemo.forEach(function (itemInternoAtual){
                        
                        if(itemInternoAtual.hasOwnProperty('metaMes')){
                            var total = itemInternoAtual.total
                            var metaMes = itemInternoAtual.metaMes
                            var saldo = (total - metaMes).toFixed(1);
                            var porcentagem = (total/metaMes * 100).toFixed(1);
                            
                            itemInternoAtual.percentualRealizado = porcentagem
                            itemInternoAtual.saldo = saldo
                        }
                        
                    })
                }
                
                itemAtual.metas.vendasTrimestreDEMO = [];
                itemAtual.metas.quantidadeDemo.forEach(v => {
                    const vendasTriObj = itemAtual.metas.vendasTrimestreDEMO.find(value => value.ano == v.ano && Math.floor((v.numeroMes - 1)/3) + 1 == value.numeroTrimestre)
                    if(vendasTriObj == undefined){
                    const newTriObj = {ano: v.ano, numeroTrimestre: Math.floor((v.numeroMes - 1)/3) + 1, saldo: Number((v.saldo ? v.saldo : 0))}
                                                       itemAtual.metas.vendasTrimestreDEMO.push(newTriObj)
            } else {
                                vendasTriObj.saldo = (vendasTriObj.saldo * 100 + Number(v.saldo ? v.saldo : 0) * 100)/100;
        }
});

})

//CLICK NECESSÁRIO PARA DESBUGAR A CONSULTA
$('#itemChart').click()

helper.dataProcessed = helper.data
helper.preencheVisualização(cmp, event, helper)
},
    
    //===============================================================================================//
    //-----------------------------------------------------------------------------------------------//
   
    preencheVisualização : function(cmp, event, helper){ 
        //helper.showSpinner(cmp)
        
        //CLICK NECESSÁRIO PARA DESBUGAR A CONSULTA
        $('#itemChart').click()
        
        $("#itemChart").empty()
        
        helper.dataProcessed.forEach(function (itemData){
			
            var nomeVendedor = itemData.nomeVendedor
            var imagemVendedor = itemData.imagemVendedor == undefined ? "/Sales/profilephoto/005/M" : itemData.imagemVendedor
            var cargo = itemData.cargoVendedor == undefined ? "Cargo não cadastrado" : itemData.cargoVendedor
            
            //CLICK NECESSÁRIO PARA DESBUGAR A CONSULTA
            $('#itemChart').click()
            
            var item = "<div class='container-item' id='container-item'>\
<div class='item'>\
<div class='containerEsquerda'>\
<div class='containerImage'>\
<div class='divImagem'>\
<div style='color: #301344;; font-size: 150px; display: flex; justify-content: center; align-items: center; width: 100%; height: 100%; border-bottom-left-radius: 10px; border-top-left-radius: 10px; ' id='divImagem' data-aura-rendered-by='86:6777;a'>\
<img class='imgUserClass' src='"+imagemVendedor+"'/></div></div>\
<div class='containerNomes'>\
<div style='' id='nomePrincipal' class='valorMeta'>"+nomeVendedor+"</div>\
<div id='nomeSecundario' class='tituloMeta'>"+cargo+"</div>\
</div>\
</div>\
</div>\
<div class='containerGraficos' id='containerGraficos'>\
<div>\
<table class='table table-bordered' style='width: 1282px'>\
<thead>\
<tr>\
<th></th>\
<th></th>\
<th></th>\
<th class='tituloTabela' colspan='13'>1 TRIMESTRE</th>\
<th class='tituloTabela' colspan='13'>2 TRIMESTRE</th>\
<th class='tituloTabela' colspan='13'>3 TRIMESTRE</th>\
<th class='tituloTabela' colspan='13'>4 TRIMESTRE</th>\
</tr>\
</thead>\
<tbody id='BodyTable' class='BodyTable'>\
<tr>\
<td></td>\
<td></td>\
<td></td>\
<td class='tituloTabela' colspan='4'>JANEIRO</td>\
<td class='tituloTabela' colspan='4'>FEVEREIRO</td>\
<td class='tituloTabela' colspan='4'>MARÇO</td>\
<td class='tituloTabela' rowspan='2'>SALDO DO TRIMESTRE</td>\
<td class='tituloTabela' colspan='4'>ABRIL</td>\
<td class='tituloTabela' colspan='4'>MAIO</td>\
<td class='tituloTabela' colspan='4'>JUNHO</td>\
<td class='tituloTabela' rowspan='2'>SALDO TRIMESTRE</td>\
<td class='tituloTabela' colspan='4'>JULHO</td>\
<td class='tituloTabela' colspan='4'>AGOSTO</td>\
<td class='tituloTabela' colspan='4'>SETEMBRO</td>\
<td class='tituloTabela' rowspan='2'>SALDO TRIMESTRE</td>\
<td class='tituloTabela' colspan='4'>OUTUBRO</td>\
<td class='tituloTabela' colspan='4'>NOVEMBRO</td>\
<td class='tituloTabela' colspan='4'>DEZEMBRO</td>\
<td class='tituloTabela' rowspan='2'>SALDO TRIMESTRE</td>\
</tr>\
<tr class='topoTabela'>\
<th class='fiexedTopo'>TIPO DE META</th>\
<th class='fiexedTopo'>META ANUAL</th>\
<th class='fiexedTopo'>ATINGIDO ANUAL</th>\
<th class='fiexedTopo'>META MENSAL</th>\
<th class='fiexedTopo'>REALIZADO MENSAL</th>\
<th class='fiexedTopo'>% REALIZADO</th>\
<th class='fiexedTopo'>SALDO MENSAL</th>\
<th class='fiexedTopo'>META MENSAL</th>\
<th class='fiexedTopo'>REALIZADO MENSAL</th>\
<th class='fiexedTopo'>% REALIZADO</th>\
<th class='fiexedTopo'>SALDO MENSAL</th>\
<th class='fiexedTopo'>META MENSAL</th>\
<th class='fiexedTopo'>REALIZADO MENSAL</th>\
<th class='fiexedTopo'>% REALIZADO</th>\
<th class='fiexedTopo'>SALDO MENSAL</th>\
<th class='fiexedTopo'>META MENSAL</th>\
<th class='fiexedTopo'>REALIZADO MENSAL</th>\
<th class='fiexedTopo'>% REALIZADO</th>\
<th class='fiexedTopo'>SALDO MENSAL</th>\
<th class='fiexedTopo'>META MENSAL</th>\
<th class='fiexedTopo'>REALIZADO MENSAL</th>\
<th class='fiexedTopo'>% REALIZADO</th>\
<th class='fiexedTopo'>SALDO MENSAL</th>\
<th class='fiexedTopo'>META MENSAL</th>\
<th class='fiexedTopo'>REALIZADO MENSAL</th>\
<th class='fiexedTopo'>% REALIZADO</th>\
<th class='fiexedTopo'>SALDO MENSAL</th>\
<th class='fiexedTopo'>META MENSAL</th>\
<th class='fiexedTopo'>REALIZADO MENSAL</th>\
<th class='fiexedTopo'>% REALIZADO</th>\
<th class='fiexedTopo'>SALDO MENSAL</th>\
<th class='fiexedTopo'>META MENSAL</th>\
<th class='fiexedTopo'>REALIZADO MENSAL</th>\
<th class='fiexedTopo'>% REALIZADO</th>\
<th class='fiexedTopo'>SALDO MENSAL</th>\
<th class='fiexedTopo'>META MENSAL</th>\
<th class='fiexedTopo'>REALIZADO MENSAL</th>\
<th class='fiexedTopo'>% REALIZADO</th>\
<th class='fiexedTopo'>SALDO MENSAL</th>\
<th class='fiexedTopo'>META MENSAL</th>\
<th class='fiexedTopo'>REALIZADO MENSAL</th>\
<th class='fiexedTopo'>% REALIZADO</th>\
<th class='fiexedTopo'>SALDO MENSAL</th>\
<th class='fiexedTopo'>META MENSAL</th>\
<th class='fiexedTopo'>REALIZADO MENSAL</th>\
<th class='fiexedTopo'>% REALIZADO</th>\
<th class='fiexedTopo'>SALDO MENSAL</th>\
<th class='fiexedTopo'>META MENSAL</th>\
<th class='fiexedTopo'>REALIZADO MENSAL</th>\
<th class='fiexedTopo'>% REALIZADO</th>\
<th class='fiexedTopo'>SALDO MENSAL</th>\
</tr>\
</tbody>\
</table>\
</div>\
</div>\
</div>\
<div class='container-graficos' id='container-graficos' >\
<div>g1</div>\
<div>g2</div>\
<div>g3</div>\
<div>g4</div>\
<div>g5</div>\
</div>\
</div>";
        	
            //ESSE IF VERIFICA SE PARA O VENDEDOR ATUAL POSSUI METAS CADASTRADAS
            //SE POSSUIR, O ARRAY DE LINHA ESTARA PREENCHIDO
            if(itemData.linha.length > 0){
                
                $('#itemChart').append(item)
                
                //ADICIONA A META DE VENDAS GERAL
                if(itemData.metas.vendas != undefined && itemData.metas.vendas.length > 0 && itemData.metas.vendas.filter(v => v.metaMes != undefined && v.ano == helper.anoSetado).length != 0){
                    
                    var metaAnual = Number(itemData.metas.metaAnualGeral).toLocaleString('pt-br',{style: 'currency', currency: 'BRL'})
                    var atingidoAnual = itemData.metas.vendasAno.find(v => v.ano == helper.anoSetado).atingido
                    var atingidoAnualFormatado = Number(atingidoAnual).toLocaleString('pt-br',{style: 'currency', currency: 'BRL'})
                    
                    var linhatabela = "\
    <tr class='linhaTabela'>\
    <td id='tipoMeta'>VENDA GERAL</td>\
    <td id='metaAnual'>"+metaAnual+"</td>\
    <td id='atingidoAnual'>"+atingidoAnualFormatado+"</td>\
    <td id='metaMensal' data-mes='1'></td>\
    <td id='realizadoMensal' data-mes='1'></td>\
    <td id='porcentagem' data-mes='1'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='1'></td>\
    <td id='metaMensal' data-mes='2'></td>\
    <td id='realizadoMensal' data-mes='2'></td>\
    <td id='porcentagem' data-mes='2'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='2'></td>\
    <td id='metaMensal' data-mes='3'></td>\
    <td id='realizadoMensal' data-mes='3'></td>\
    <td id='porcentagem' data-mes='3'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='3'></td>\
    <td id='saldoPrimeiroTrimestre'></td>\
    <td id='metaMensal' data-mes='4'></td>\
    <td id='realizadoMensal' data-mes='4'></td>\
    <td id='porcentagem' data-mes='4'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='4'></td>\
    <td id='metaMensal' data-mes='5'></td>\
    <td id='realizadoMensal' data-mes='5'></td>\
    <td id='porcentagem' data-mes='5'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='5'></td>\
    <td id='metaMensal' data-mes='6'></td>\
    <td id='realizadoMensal' data-mes='6'></td>\
    <td id='porcentagem' data-mes='6'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='6'></td>\
    <td id='saldoSegundoTrimestre'></td>\
    <td id='metaMensal' data-mes='7'></td>\
    <td id='realizadoMensal' data-mes='7'></td>\
    <td id='porcentagem' data-mes='7'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='7'></td>\
    <td id='metaMensal' data-mes='8'></td>\
    <td id='realizadoMensal' data-mes='8'></td>\
    <td id='porcentagem' data-mes='8'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='8'></td>\
    <td id='metaMensal' data-mes='9'></td>\
    <td id='realizadoMensal' data-mes='9'></td>\
    <td id='porcentagem' data-mes='9'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='9'></td>\
    <td id='saldoTerceiroTrimestre'></td>\
    <td id='metaMensal' data-mes='10'></td>\
    <td id='realizadoMensal' data-mes='10'></td>\
    <td id='porcentagem' data-mes='10'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='10'></td>\
    <td id='metaMensal' data-mes='11'></td>\
    <td id='realizadoMensal' data-mes='11'></td>\
    <td id='porcentagem' data-mes='11'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='11'></td>\
    <td id='metaMensal' data-mes='12'></td>\
    <td id='realizadoMensal' data-mes='12'></td>\
    <td id='porcentagem' data-mes='12'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='12'></td>\
    <td id='saldoQuartoTrimestre'></td>\
    </tr>\
    ";
                    //ADICIONA LINHA A TABELA
                    var itemAdicionado = $(".BodyTable:last").append(linhatabela)
                                    
                    //PREENCHE VALORES NA LINHA ADICIONADO
                    itemData.metas.vendas.forEach(function(metaInternaAtual){
                        
                        //VERIFICA SE EXISTE META PRO VENDEDOR ATUAL
                        if(metaInternaAtual.hasOwnProperty('metaMes')){
                            
                            var anoSetado = helper.anoSetado
                            
                            if(metaInternaAtual.ano == anoSetado){
                                var mesMeta = metaInternaAtual.numeroMes
                                var meslocalizado = $(itemAdicionado).find("[data-mes='" + mesMeta + "']")
                                var metaMensal = Number(metaInternaAtual.metaMes).toLocaleString('pt-br',{style: 'currency', currency: 'BRL'})
                                var realizadoMensal = Number(metaInternaAtual.total).toLocaleString('pt-br',{style: 'currency', currency: 'BRL'})
                                var percentual = metaInternaAtual.percentualRealizado
                                var saldoMensal = Number(metaInternaAtual.saldo).toLocaleString('pt-br',{style: 'currency', currency: 'BRL'})
                                
                                var corDestacada = metaInternaAtual.saldo < 0 ? "red" : (metaInternaAtual.saldo > 0 ? "green" : "white")
                                var corDestacadaTexto = metaInternaAtual.saldo < 0 ? "white" : metaInternaAtual.saldo > 0 ? "white" : "black"
                                
                                
                                //SETA A META MENSAL
                                $(meslocalizado[0]).html(metaMensal)
                                
                                //SETA A META MENSAL
                                $(meslocalizado[1]).html(realizadoMensal)
                                
                                //SETA A META MENSAL
                                $(meslocalizado[2]).html(percentual + "%")
                                
                                //SETA A META MENSAL
                                $(meslocalizado[3]).html(saldoMensal)
                                $(meslocalizado[3]).attr('data-saldoMensal', metaInternaAtual.saldo)
                                
                                $(meslocalizado[3]).css('background-color', corDestacada)
                                $(meslocalizado[3]).css('color', corDestacadaTexto)
                            }
                            
                            
                        }
                        
                        
                    })
                    
                    //PREENCHE AS METAS DO TRIMESTRE PARA VENDAS
                    itemData.metas.vendasTrimestre.forEach(function(atingidoTrimestre){
                        var anoSetado = helper.anoSetado
                        
                        if(atingidoTrimestre.ano == anoSetado){
                            //se for igual ao ano setado, entao adiciona na visualizacao da linha
                            
                            if(atingidoTrimestre.numeroTrimestre == 1){
                                
                                var saldoPrimeiroTrimestre = atingidoTrimestre.saldo
                                $(itemAdicionado).find('#saldoPrimeiroTrimestre').html(Number(saldoPrimeiroTrimestre).toLocaleString('pt-br',{style: 'currency', currency: 'BRL'}))
                                
                            }else if(atingidoTrimestre.numeroTrimestre == 2){
                                
                                var saldoSegundoTrimestre = atingidoTrimestre.saldo
                                $(itemAdicionado).find('#saldoSegundoTrimestre').html(Number(saldoSegundoTrimestre).toLocaleString('pt-br',{style: 'currency', currency: 'BRL'}))
                                
                            }else if(atingidoTrimestre.numeroTrimestre == 3){
                                
                                var saldoTerceiroTrimestre = atingidoTrimestre.saldo
                                $(itemAdicionado).find('#saldoTerceiroTrimestre').html(Number(saldoTerceiroTrimestre).toLocaleString('pt-br',{style: 'currency', currency: 'BRL'}))
                                
                            }else{
                                
                                var saldoQuartoTrimestre = atingidoTrimestre.saldo
                                $(itemAdicionado).find('#saldoQuartoTrimestre').html(Number(saldoQuartoTrimestre).toLocaleString('pt-br',{style: 'currency', currency: 'BRL'}))
                            }
                        }
                    })
                    
                    //=====================================================================//
                    
                    
                    
                    
                    
                }
                
                //ADICIONA A META DE PMLS
                if(itemData.metas.pmls != undefined && itemData.metas.pmls.length > 0 && itemData.metas.pmls.filter(v => v.metaMes != undefined && v.ano == helper.anoSetado).length != 0){
                    
                    var metaAnual = Number(itemData.metas.metaAnualPMLS).toLocaleString('pt-br',{style: 'currency', currency: 'BRL'})
                    var identificadorLinha = "linhaTabelaPMLS"
                    var atingidoAnual = itemData.metas.pmlsAno.find(v => v.ano == helper.anoSetado).atingido
                    var atingidoAnualFormatado = Number(atingidoAnual).toLocaleString('pt-br',{style: 'currency', currency: 'BRL'})
                    
                    var linhatabela = "\
    <tr class='linhaTabela' id='"+identificadorLinha+"'>\
    <td id='tipoMeta'>PMLS</td>\
    <td id='metaAnual'>"+metaAnual+"</td>\
    <td id='atingidoAnual'>"+atingidoAnualFormatado+"</td>\
    <td id='metaMensal' data-mes='1'></td>\
    <td id='realizadoMensal' data-mes='1'></td>\
    <td id='porcentagem' data-mes='1'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='1'></td>\
    <td id='metaMensal' data-mes='2'></td>\
    <td id='realizadoMensal' data-mes='2'></td>\
    <td id='porcentagem' data-mes='2'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='2'></td>\
    <td id='metaMensal' data-mes='3'></td>\
    <td id='realizadoMensal' data-mes='3'></td>\
    <td id='porcentagem' data-mes='3'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='3'></td>\
    <td id='saldoPrimeiroTrimestre'></td>\
    <td id='metaMensal' data-mes='4'></td>\
    <td id='realizadoMensal' data-mes='4'></td>\
    <td id='porcentagem' data-mes='4'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='4'></td>\
    <td id='metaMensal' data-mes='5'></td>\
    <td id='realizadoMensal' data-mes='5'></td>\
    <td id='porcentagem' data-mes='5'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='5'></td>\
    <td id='metaMensal' data-mes='6'></td>\
    <td id='realizadoMensal' data-mes='6'></td>\
    <td id='porcentagem' data-mes='6'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='6'></td>\
    <td id='saldoSegundoTrimestre'></td>\
    <td id='metaMensal' data-mes='7'></td>\
    <td id='realizadoMensal' data-mes='7'></td>\
    <td id='porcentagem' data-mes='7'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='7'></td>\
    <td id='metaMensal' data-mes='8'></td>\
    <td id='realizadoMensal' data-mes='8'></td>\
    <td id='porcentagem' data-mes='8'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='8'></td>\
    <td id='metaMensal' data-mes='9'></td>\
    <td id='realizadoMensal' data-mes='9'></td>\
    <td id='porcentagem' data-mes='9'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='9'></td>\
    <td id='saldoTerceiroTrimestre'></td>\
    <td id='metaMensal' data-mes='10'></td>\
    <td id='realizadoMensal' data-mes='10'></td>\
    <td id='porcentagem' data-mes='10'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='10'></td>\
    <td id='metaMensal' data-mes='11'></td>\
    <td id='realizadoMensal' data-mes='11'></td>\
    <td id='porcentagem' data-mes='11'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='11'></td>\
    <td id='metaMensal' data-mes='12'></td>\
    <td id='realizadoMensal' data-mes='12'></td>\
    <td id='porcentagem' data-mes='12'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='12'></td>\
    <td id='saldoQuartoTrimestre'></td>\
    </tr>\
    ";
                    //ADICIONA LINHA A TABELA
                    var itemAdicionado = $(".BodyTable:last").append(linhatabela)
                    //POR ALGUM MOTIVO A VARIAVEL ANTERIOR NAO RECEBE O VALOR QUE DEVERIA, PORTANTO, CONTORNA O ERRO
                    var itemAdicionadoReal = $(itemAdicionado).find("#"+identificadorLinha+"") 
                                    
                    //PREENCHE VALORES NA LINHA ADICIONADO
                    itemData.metas.pmls.forEach(function(metaInternaAtual){
                        
                        //VERIFICA SE EXISTE META PRO VENDEDOR ATUAL
                        if(metaInternaAtual.hasOwnProperty('metaMes')){
                            
                            //RECUPERA O ANO SETADO
                            var anoSetado = helper.anoSetado
                            
                            //VERIFICA SE A META DA ITERACAO ATUAL PERTENCE AO ANO SETADO
                            if(metaInternaAtual.ano == anoSetado){
                                
                                //RECUPERA O MES DA META ATUAL
                                var mesMeta = metaInternaAtual.numeroMes 
                                //ACESSA A LINHA A SER INSERIDO OS DADOS
                                var meslocalizado = $(itemAdicionadoReal).find("[data-mes='" + mesMeta + "']")
                                //RECUPERA O VALOR DA META MENSAL
                                var metaMensal = Number(metaInternaAtual.metaMes).toLocaleString('pt-br',{style: 'currency', currency: 'BRL'})
                                //RECUPERA O VALOR REALIZADO PARA O MES ATUAL
                                var realizadoMensal = Number(metaInternaAtual.total).toLocaleString('pt-br',{style: 'currency', currency: 'BRL'})
                                //RECUPERA O PERCENTUAL REALIZADO PARA O MES ATUAL
                                var percentual = metaInternaAtual.percentualRealizado
                                //RECUPERA O SALDO DA META ATUAL PARA O MES ATUAL
                                var saldoMensal = Number(metaInternaAtual.saldo).toLocaleString('pt-br',{style: 'currency', currency: 'BRL'})
                                //DEFINE A COR DE DESTAQUE DA CELULA
                                var corDestacada = metaInternaAtual.saldo < 0 ? "red" : (metaInternaAtual.saldo > 0 ? "green" : "white")
                                var corDestacadaTexto = metaInternaAtual.saldo < 0 ? "white" : metaInternaAtual.saldo > 0 ? "white" : "black"
                                
    
                                //SETA A META MENSAL
                                $(meslocalizado[0]).html(metaMensal)
                                
                                //SETA A META MENSAL
                                $(meslocalizado[1]).html(realizadoMensal)
                                
                                //SETA A META MENSAL
                                $(meslocalizado[2]).html(percentual + "%")
                                
                                //SETA A META MENSAL
                                $(meslocalizado[3]).html(saldoMensal)
                                $(meslocalizado[3]).attr('data-saldoMensal', metaInternaAtual.saldo)
                                
                                $(meslocalizado[3]).css('background-color', corDestacada)
                                $(meslocalizado[3]).css('color', corDestacadaTexto)
                            }
                            
                            
                        }
                        
                        
                    })
                    
                    //PREENCHE AS METAS DO TRIMESTRE PARA VENDAS
                    itemData.metas.vendasTrimestrePMLS.forEach(function(atingidoTrimestre){
                        var anoSetado = helper.anoSetado
                        
                        if(atingidoTrimestre.ano == anoSetado){
                            //se for igual ao ano setado, entao adiciona na visualizacao da linha
                            
                            if(atingidoTrimestre.numeroTrimestre == 1){
                                
                                var saldoPrimeiroTrimestre = atingidoTrimestre.saldo
                                $(itemAdicionadoReal).find('#saldoPrimeiroTrimestre').html(Number(saldoPrimeiroTrimestre).toLocaleString('pt-br',{style: 'currency', currency: 'BRL'}))
                                
                            }else if(atingidoTrimestre.numeroTrimestre == 2){
                                
                                var saldoSegundoTrimestre = atingidoTrimestre.saldo
                                $(itemAdicionadoReal).find('#saldoSegundoTrimestre').html(Number(saldoSegundoTrimestre).toLocaleString('pt-br',{style: 'currency', currency: 'BRL'}))
                                
                            }else if(atingidoTrimestre.numeroTrimestre == 3){
                                
                                var saldoTerceiroTrimestre = atingidoTrimestre.saldo
                                $(itemAdicionadoReal).find('#saldoTerceiroTrimestre').html(Number(saldoTerceiroTrimestre).toLocaleString('pt-br',{style: 'currency', currency: 'BRL'}))
                                
                            }else{
                                
                                var saldoQuartoTrimestre = atingidoTrimestre.saldo
                                $(itemAdicionadoReal).find('#saldoQuartoTrimestre').html(Number(saldoQuartoTrimestre).toLocaleString('pt-br',{style: 'currency', currency: 'BRL'}))
                            }
                        }
                    })
                    
                    //=====================================================================//
                    
                    
                    
                    
                    
                }
                
                //ADICIONA A META DE CMI
                if(itemData.metas.cmiImagemLaparo != undefined && itemData.metas.cmiImagemLaparo.length > 0 && itemData.metas.cmiImagemLaparo.filter(v => v.metaMes != undefined && v.ano == helper.anoSetado).length != 0){
                    
                    var metaAnual = Number(itemData.metas.metaAnualCmiImagemLaparo).toLocaleString('pt-br',{style: 'currency', currency: 'BRL'})
                    var identificadorLinha = "linhaTabelaCMI"
                    
                    var atingidoAnual = itemData.metas.cmiImagemLaparoAno.find(v => v.ano == helper.anoSetado).atingido
                    var atingidoAnualFormatado = Number(atingidoAnual).toLocaleString('pt-br',{style: 'currency', currency: 'BRL'})
                    
                    var linhatabela = "\
    <tr class='linhaTabela' id='"+identificadorLinha+"'>\
    <td id='tipoMeta'>CMI (IMG + LAPARO)</td>\
    <td id='metaAnual'>"+metaAnual+"</td>\
    <td id='atingidoAnual'>"+atingidoAnualFormatado+"</td>\
    <td id='metaMensal' data-mes='1'></td>\
    <td id='realizadoMensal' data-mes='1'></td>\
    <td id='porcentagem' data-mes='1'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='1'></td>\
    <td id='metaMensal' data-mes='2'></td>\
    <td id='realizadoMensal' data-mes='2'></td>\
    <td id='porcentagem' data-mes='2'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='2'></td>\
    <td id='metaMensal' data-mes='3'></td>\
    <td id='realizadoMensal' data-mes='3'></td>\
    <td id='porcentagem' data-mes='3'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='3'></td>\
    <td id='saldoPrimeiroTrimestre'></td>\
    <td id='metaMensal' data-mes='4'></td>\
    <td id='realizadoMensal' data-mes='4'></td>\
    <td id='porcentagem' data-mes='4'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='4'></td>\
    <td id='metaMensal' data-mes='5'></td>\
    <td id='realizadoMensal' data-mes='5'></td>\
    <td id='porcentagem' data-mes='5'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='5'></td>\
    <td id='metaMensal' data-mes='6'></td>\
    <td id='realizadoMensal' data-mes='6'></td>\
    <td id='porcentagem' data-mes='6'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='6'></td>\
    <td id='saldoSegundoTrimestre'></td>\
    <td id='metaMensal' data-mes='7'></td>\
    <td id='realizadoMensal' data-mes='7'></td>\
    <td id='porcentagem' data-mes='7'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='7'></td>\
    <td id='metaMensal' data-mes='8'></td>\
    <td id='realizadoMensal' data-mes='8'></td>\
    <td id='porcentagem' data-mes='8'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='8'></td>\
    <td id='metaMensal' data-mes='9'></td>\
    <td id='realizadoMensal' data-mes='9'></td>\
    <td id='porcentagem' data-mes='9'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='9'></td>\
    <td id='saldoTerceiroTrimestre'></td>\
    <td id='metaMensal' data-mes='10'></td>\
    <td id='realizadoMensal' data-mes='10'></td>\
    <td id='porcentagem' data-mes='10'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='10'></td>\
    <td id='metaMensal' data-mes='11'></td>\
    <td id='realizadoMensal' data-mes='11'></td>\
    <td id='porcentagem' data-mes='11'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='11'></td>\
    <td id='metaMensal' data-mes='12'></td>\
    <td id='realizadoMensal' data-mes='12'></td>\
    <td id='porcentagem' data-mes='12'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='12'></td>\
    <td id='saldoQuartoTrimestre'></td>\
    </tr>\
    ";
                    //ADICIONA LINHA A TABELA
                    var itemAdicionado = $(".BodyTable:last").append(linhatabela)
                    //POR ALGUM MOTIVO A VARIAVEL ANTERIOR NAO RECEBE O VALOR QUE DEVERIA, PORTANTO, CONTORNA O ERRO
                    var itemAdicionadoReal = $(itemAdicionado).find("#"+identificadorLinha+"") 
                                    
                    //PREENCHE VALORES NA LINHA ADICIONADO
                    itemData.metas.cmiImagemLaparo.forEach(function(metaInternaAtual){
                        
                        //VERIFICA SE EXISTE META PRO VENDEDOR ATUAL
                        if(metaInternaAtual.hasOwnProperty('metaMes')){
                            
                            //RECUPERA O ANO SETADO
                            var anoSetado = helper.anoSetado
                            
                            //VERIFICA SE A META DA ITERACAO ATUAL PERTENCE AO ANO SETADO
                            if(metaInternaAtual.ano == anoSetado){
                                
                                //RECUPERA O MES DA META ATUAL
                                var mesMeta = metaInternaAtual.numeroMes 
                                //ACESSA A LINHA A SER INSERIDO OS DADOS
                                var meslocalizado = $(itemAdicionadoReal).find("[data-mes='" + mesMeta + "']")
                                //RECUPERA O VALOR DA META MENSAL
                                var metaMensal = Number(metaInternaAtual.metaMes).toLocaleString('pt-br',{style: 'currency', currency: 'BRL'})
                                //RECUPERA O VALOR REALIZADO PARA O MES ATUAL
                                var realizadoMensal = Number(metaInternaAtual.total).toLocaleString('pt-br',{style: 'currency', currency: 'BRL'})
                                //RECUPERA O PERCENTUAL REALIZADO PARA O MES ATUAL
                                var percentual = metaInternaAtual.percentualRealizado
                                //RECUPERA O SALDO DA META ATUAL PARA O MES ATUAL
                                var saldoMensal = Number(metaInternaAtual.saldo).toLocaleString('pt-br',{style: 'currency', currency: 'BRL'})
                                //DEFINE A COR DE DESTAQUE DA CELULA
                                var corDestacada = metaInternaAtual.saldo < 0 ? "red" : (metaInternaAtual.saldo > 0 ? "green" : "white")
                                var corDestacadaTexto = metaInternaAtual.saldo < 0 ? "white" : metaInternaAtual.saldo > 0 ? "white" : "black"
                                
    
                                //SETA A META MENSAL
                                $(meslocalizado[0]).html(metaMensal)
                                
                                //SETA A META MENSAL
                                $(meslocalizado[1]).html(realizadoMensal)
                                
                                //SETA A META MENSAL
                                $(meslocalizado[2]).html(percentual + "%")
                                
                                //SETA A META MENSAL
                                $(meslocalizado[3]).html(saldoMensal)
                                $(meslocalizado[3]).attr('data-saldoMensal', metaInternaAtual.saldo)
                                
                                $(meslocalizado[3]).css('background-color', corDestacada)
                                $(meslocalizado[3]).css('color', corDestacadaTexto)
                            }
                            
                            
                        }
                        
                        
                    })
                    
                    //PREENCHE AS METAS DO TRIMESTRE PARA VENDAS
                    itemData.metas.vendasTrimestreCMIImagemLaparo.forEach(function(atingidoTrimestre){
                        var anoSetado = helper.anoSetado
                        
                        if(atingidoTrimestre.ano == anoSetado){
                            //se for igual ao ano setado, entao adiciona na visualizacao da linha
                            
                            if(atingidoTrimestre.numeroTrimestre == 1){
                                
                                var saldoPrimeiroTrimestre = atingidoTrimestre.saldo
                                $(itemAdicionadoReal).find('#saldoPrimeiroTrimestre').html(Number(saldoPrimeiroTrimestre).toLocaleString('pt-br',{style: 'currency', currency: 'BRL'}))
                                
                            }else if(atingidoTrimestre.numeroTrimestre == 2){
                                
                                var saldoSegundoTrimestre = atingidoTrimestre.saldo
                                $(itemAdicionadoReal).find('#saldoSegundoTrimestre').html(Number(saldoSegundoTrimestre).toLocaleString('pt-br',{style: 'currency', currency: 'BRL'}))
                                
                            }else if(atingidoTrimestre.numeroTrimestre == 3){
                                
                                var saldoTerceiroTrimestre = atingidoTrimestre.saldo
                                $(itemAdicionadoReal).find('#saldoTerceiroTrimestre').html(Number(saldoTerceiroTrimestre).toLocaleString('pt-br',{style: 'currency', currency: 'BRL'}))
                                
                            }else{
                                
                                var saldoQuartoTrimestre = atingidoTrimestre.saldo
                                $(itemAdicionadoReal).find('#saldoQuartoTrimestre').html(Number(saldoQuartoTrimestre).toLocaleString('pt-br',{style: 'currency', currency: 'BRL'}))
                            }
                        }
                    })
                    
                    //=====================================================================//
                    
                    
                    
                    
                    
                }
                
                //ADICIONA A META DE CMI
                if(itemData.metas.cmiUroGineco != undefined && itemData.metas.cmiUroGineco.length > 0 && itemData.metas.cmiUroGineco.filter(v => v.metaMes != undefined && v.ano == helper.anoSetado).length != 0){
                    
                    var metaAnual = Number(itemData.metas.metaAnualCmiUroGineco).toLocaleString('pt-br',{style: 'currency', currency: 'BRL'})
                    var identificadorLinha = "linhaTabelaCMIUroGineco"
                    
                    var atingidoAnual = itemData.metas.cmiUroGinecoAno.find(v => v.ano == helper.anoSetado).atingido
                    var atingidoAnualFormatado = Number(atingidoAnual).toLocaleString('pt-br',{style: 'currency', currency: 'BRL'})
                    
                    var linhatabela = "\
    <tr class='linhaTabela' id='"+identificadorLinha+"'>\
    <td id='tipoMeta'>CMI (URO + GINECO)</td>\
    <td id='metaAnual'>"+metaAnual+"</td>\
    <td id='atingidoAnual'>"+atingidoAnualFormatado+"</td>\
    <td id='metaMensal' data-mes='1'></td>\
    <td id='realizadoMensal' data-mes='1'></td>\
    <td id='porcentagem' data-mes='1'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='1'></td>\
    <td id='metaMensal' data-mes='2'></td>\
    <td id='realizadoMensal' data-mes='2'></td>\
    <td id='porcentagem' data-mes='2'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='2'></td>\
    <td id='metaMensal' data-mes='3'></td>\
    <td id='realizadoMensal' data-mes='3'></td>\
    <td id='porcentagem' data-mes='3'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='3'></td>\
    <td id='saldoPrimeiroTrimestre'></td>\
    <td id='metaMensal' data-mes='4'></td>\
    <td id='realizadoMensal' data-mes='4'></td>\
    <td id='porcentagem' data-mes='4'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='4'></td>\
    <td id='metaMensal' data-mes='5'></td>\
    <td id='realizadoMensal' data-mes='5'></td>\
    <td id='porcentagem' data-mes='5'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='5'></td>\
    <td id='metaMensal' data-mes='6'></td>\
    <td id='realizadoMensal' data-mes='6'></td>\
    <td id='porcentagem' data-mes='6'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='6'></td>\
    <td id='saldoSegundoTrimestre'></td>\
    <td id='metaMensal' data-mes='7'></td>\
    <td id='realizadoMensal' data-mes='7'></td>\
    <td id='porcentagem' data-mes='7'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='7'></td>\
    <td id='metaMensal' data-mes='8'></td>\
    <td id='realizadoMensal' data-mes='8'></td>\
    <td id='porcentagem' data-mes='8'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='8'></td>\
    <td id='metaMensal' data-mes='9'></td>\
    <td id='realizadoMensal' data-mes='9'></td>\
    <td id='porcentagem' data-mes='9'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='9'></td>\
    <td id='saldoTerceiroTrimestre'></td>\
    <td id='metaMensal' data-mes='10'></td>\
    <td id='realizadoMensal' data-mes='10'></td>\
    <td id='porcentagem' data-mes='10'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='10'></td>\
    <td id='metaMensal' data-mes='11'></td>\
    <td id='realizadoMensal' data-mes='11'></td>\
    <td id='porcentagem' data-mes='11'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='11'></td>\
    <td id='metaMensal' data-mes='12'></td>\
    <td id='realizadoMensal' data-mes='12'></td>\
    <td id='porcentagem' data-mes='12'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='12'></td>\
    <td id='saldoQuartoTrimestre'></td>\
    </tr>\
    ";
                    //ADICIONA LINHA A TABELA
                    var itemAdicionado = $(".BodyTable:last").append(linhatabela)
                    //POR ALGUM MOTIVO A VARIAVEL ANTERIOR NAO RECEBE O VALOR QUE DEVERIA, PORTANTO, CONTORNA O ERRO
                    var itemAdicionadoReal = $(itemAdicionado).find("#"+identificadorLinha+"") 
                                    
                    //PREENCHE VALORES NA LINHA ADICIONADO
                    itemData.metas.cmiUroGineco.forEach(function(metaInternaAtual){
                        
                        //VERIFICA SE EXISTE META PRO VENDEDOR ATUAL
                        if(metaInternaAtual.hasOwnProperty('metaMes')){
                            
                            //RECUPERA O ANO SETADO
                            var anoSetado = helper.anoSetado
                            
                            //VERIFICA SE A META DA ITERACAO ATUAL PERTENCE AO ANO SETADO
                            if(metaInternaAtual.ano == anoSetado){
                                
                                //RECUPERA O MES DA META ATUAL
                                var mesMeta = metaInternaAtual.numeroMes 
                                //ACESSA A LINHA A SER INSERIDO OS DADOS
                                var meslocalizado = $(itemAdicionadoReal).find("[data-mes='" + mesMeta + "']")
                                //RECUPERA O VALOR DA META MENSAL
                                var metaMensal = Number(metaInternaAtual.metaMes).toLocaleString('pt-br',{style: 'currency', currency: 'BRL'})
                                //RECUPERA O VALOR REALIZADO PARA O MES ATUAL
                                var realizadoMensal = Number(metaInternaAtual.total).toLocaleString('pt-br',{style: 'currency', currency: 'BRL'})
                                //RECUPERA O PERCENTUAL REALIZADO PARA O MES ATUAL
                                var percentual = metaInternaAtual.percentualRealizado
                                //RECUPERA O SALDO DA META ATUAL PARA O MES ATUAL
                                var saldoMensal = Number(metaInternaAtual.saldo).toLocaleString('pt-br',{style: 'currency', currency: 'BRL'})
                                //DEFINE A COR DE DESTAQUE DA CELULA
                                var corDestacada = metaInternaAtual.saldo < 0 ? "red" : (metaInternaAtual.saldo > 0 ? "green" : "white")
                                var corDestacadaTexto = metaInternaAtual.saldo < 0 ? "white" : metaInternaAtual.saldo > 0 ? "white" : "black"
                                
    
                                //SETA A META MENSAL
                                $(meslocalizado[0]).html(metaMensal)
                                
                                //SETA A META MENSAL
                                $(meslocalizado[1]).html(realizadoMensal)
                                
                                //SETA A META MENSAL
                                $(meslocalizado[2]).html(percentual + "%")
                                
                                //SETA A META MENSAL
                                $(meslocalizado[3]).html(saldoMensal)
                                $(meslocalizado[3]).attr('data-saldoMensal', metaInternaAtual.saldo)
                                
                                $(meslocalizado[3]).css('background-color', corDestacada)
                                $(meslocalizado[3]).css('color', corDestacadaTexto)
                            }
                            
                            
                        }
                        
                        
                    })
                    
                    //PREENCHE AS METAS DO TRIMESTRE PARA VENDAS
                    itemData.metas.vendasTrimestreCMIImagemLaparo.forEach(function(atingidoTrimestre){
                        var anoSetado = helper.anoSetado
                        
                        if(atingidoTrimestre.ano == anoSetado){
                            //se for igual ao ano setado, entao adiciona na visualizacao da linha
                            
                            if(atingidoTrimestre.numeroTrimestre == 1){
                                
                                var saldoPrimeiroTrimestre = atingidoTrimestre.saldo
                                $(itemAdicionadoReal).find('#saldoPrimeiroTrimestre').html(Number(saldoPrimeiroTrimestre).toLocaleString('pt-br',{style: 'currency', currency: 'BRL'}))
                                
                            }else if(atingidoTrimestre.numeroTrimestre == 2){
                                
                                var saldoSegundoTrimestre = atingidoTrimestre.saldo
                                $(itemAdicionadoReal).find('#saldoSegundoTrimestre').html(Number(saldoSegundoTrimestre).toLocaleString('pt-br',{style: 'currency', currency: 'BRL'}))
                                
                            }else if(atingidoTrimestre.numeroTrimestre == 3){
                                
                                var saldoTerceiroTrimestre = atingidoTrimestre.saldo
                                $(itemAdicionadoReal).find('#saldoTerceiroTrimestre').html(Number(saldoTerceiroTrimestre).toLocaleString('pt-br',{style: 'currency', currency: 'BRL'}))
                                
                            }else{
                                
                                var saldoQuartoTrimestre = atingidoTrimestre.saldo
                                $(itemAdicionadoReal).find('#saldoQuartoTrimestre').html(Number(saldoQuartoTrimestre).toLocaleString('pt-br',{style: 'currency', currency: 'BRL'}))
                            }
                        }
                    })
                    
                    //=====================================================================//
                    
                    
                    
                    
                    
                }
                
                //ADICIONA A META DE SURGICAL
                if(itemData.metas.surgical != undefined && itemData.metas.surgical.length > 0 && itemData.metas.surgical.filter(v => v.metaMes != undefined && v.ano == helper.anoSetado).length != 0){
                    
                    var metaAnual = Number(itemData.metas.metaAnualSurgical).toLocaleString('pt-br',{style: 'currency', currency: 'BRL'})
                    var identificadorLinha = "linhaTabelaSURGICAL"
                    
                    var atingidoAnual = itemData.metas.surgicalAno.find(v => v.ano == helper.anoSetado).atingido
                    var atingidoAnualFormatado = Number(atingidoAnual).toLocaleString('pt-br',{style: 'currency', currency: 'BRL'})
                    
                    var linhatabela = "\
    <tr class='linhaTabela' id='"+identificadorLinha+"'>\
    <td id='tipoMeta'>SURGICAL</td>\
    <td id='metaAnual'>"+metaAnual+"</td>\
    <td id='atingidoAnual'>"+atingidoAnualFormatado+"</td>\
    <td id='metaMensal' data-mes='1'></td>\
    <td id='realizadoMensal' data-mes='1'></td>\
    <td id='porcentagem' data-mes='1'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='1'></td>\
    <td id='metaMensal' data-mes='2'></td>\
    <td id='realizadoMensal' data-mes='2'></td>\
    <td id='porcentagem' data-mes='2'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='2'></td>\
    <td id='metaMensal' data-mes='3'></td>\
    <td id='realizadoMensal' data-mes='3'></td>\
    <td id='porcentagem' data-mes='3'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='3'></td>\
    <td id='saldoPrimeiroTrimestre'></td>\
    <td id='metaMensal' data-mes='4'></td>\
    <td id='realizadoMensal' data-mes='4'></td>\
    <td id='porcentagem' data-mes='4'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='4'></td>\
    <td id='metaMensal' data-mes='5'></td>\
    <td id='realizadoMensal' data-mes='5'></td>\
    <td id='porcentagem' data-mes='5'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='5'></td>\
    <td id='metaMensal' data-mes='6'></td>\
    <td id='realizadoMensal' data-mes='6'></td>\
    <td id='porcentagem' data-mes='6'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='6'></td>\
    <td id='saldoSegundoTrimestre'></td>\
    <td id='metaMensal' data-mes='7'></td>\
    <td id='realizadoMensal' data-mes='7'></td>\
    <td id='porcentagem' data-mes='7'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='7'></td>\
    <td id='metaMensal' data-mes='8'></td>\
    <td id='realizadoMensal' data-mes='8'></td>\
    <td id='porcentagem' data-mes='8'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='8'></td>\
    <td id='metaMensal' data-mes='9'></td>\
    <td id='realizadoMensal' data-mes='9'></td>\
    <td id='porcentagem' data-mes='9'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='9'></td>\
    <td id='saldoTerceiroTrimestre'></td>\
    <td id='metaMensal' data-mes='10'></td>\
    <td id='realizadoMensal' data-mes='10'></td>\
    <td id='porcentagem' data-mes='10'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='10'></td>\
    <td id='metaMensal' data-mes='11'></td>\
    <td id='realizadoMensal' data-mes='11'></td>\
    <td id='porcentagem' data-mes='11'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='11'></td>\
    <td id='metaMensal' data-mes='12'></td>\
    <td id='realizadoMensal' data-mes='12'></td>\
    <td id='porcentagem' data-mes='12'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='12'></td>\
    <td id='saldoQuartoTrimestre'></td>\
    </tr>\
    ";
                    //ADICIONA LINHA A TABELA
                    var itemAdicionado = $(".BodyTable:last").append(linhatabela)
                    //POR ALGUM MOTIVO A VARIAVEL ANTERIOR NAO RECEBE O VALOR QUE DEVERIA, PORTANTO, CONTORNA O ERRO
                    var itemAdicionadoReal = $(itemAdicionado).find("#"+identificadorLinha+"") 
                                    
                    //PREENCHE VALORES NA LINHA ADICIONADO
                    itemData.metas.surgical.forEach(function(metaInternaAtual){
                        
                        //VERIFICA SE EXISTE META PRO VENDEDOR ATUAL
                        if(metaInternaAtual.hasOwnProperty('metaMes')){
                            
                            //RECUPERA O ANO SETADO
                            var anoSetado = helper.anoSetado
                            
                            //VERIFICA SE A META DA ITERACAO ATUAL PERTENCE AO ANO SETADO
                            if(metaInternaAtual.ano == anoSetado){
                                
                                //RECUPERA O MES DA META ATUAL
                                var mesMeta = metaInternaAtual.numeroMes 
                                //ACESSA A LINHA A SER INSERIDO OS DADOS
                                var meslocalizado = $(itemAdicionadoReal).find("[data-mes='" + mesMeta + "']")
                                //RECUPERA O VALOR DA META MENSAL
                                var metaMensal = Number(metaInternaAtual.metaMes).toLocaleString('pt-br',{style: 'currency', currency: 'BRL'})
                                //RECUPERA O VALOR REALIZADO PARA O MES ATUAL
                                var realizadoMensal = Number(metaInternaAtual.total).toLocaleString('pt-br',{style: 'currency', currency: 'BRL'})
                                //RECUPERA O PERCENTUAL REALIZADO PARA O MES ATUAL
                                var percentual = metaInternaAtual.percentualRealizado
                                //RECUPERA O SALDO DA META ATUAL PARA O MES ATUAL
                                var saldoMensal = Number(metaInternaAtual.saldo).toLocaleString('pt-br',{style: 'currency', currency: 'BRL'})
                                //DEFINE A COR DE DESTAQUE DA CELULA
                                var corDestacada = metaInternaAtual.saldo < 0 ? "red" : (metaInternaAtual.saldo > 0 ? "green" : "white")
                                var corDestacadaTexto = metaInternaAtual.saldo < 0 ? "white" : metaInternaAtual.saldo > 0 ? "white" : "black"
                                
    
                                //SETA A META MENSAL
                                $(meslocalizado[0]).html(metaMensal)
                                
                                //SETA A META MENSAL
                                $(meslocalizado[1]).html(realizadoMensal)
                                
                                //SETA A META MENSAL
                                $(meslocalizado[2]).html(percentual + "%")
                                
                                //SETA A META MENSAL
                                $(meslocalizado[3]).html(saldoMensal)
                                $(meslocalizado[3]).attr('data-saldoMensal', metaInternaAtual.saldo)
                                
                                $(meslocalizado[3]).css('background-color', corDestacada)
                                $(meslocalizado[3]).css('color', corDestacadaTexto)
                            }
                            
                            
                        }
                        
                        
                    })
                    
                    //PREENCHE AS METAS DO TRIMESTRE PARA VENDAS
                    itemData.metas.vendasTrimestreSURGICAL.forEach(function(atingidoTrimestre){
                        var anoSetado = helper.anoSetado
                        
                        if(atingidoTrimestre.ano == anoSetado){
                            //se for igual ao ano setado, entao adiciona na visualizacao da linha
                            
                            if(atingidoTrimestre.numeroTrimestre == 1){
                                
                                var saldoPrimeiroTrimestre = atingidoTrimestre.saldo
                                $(itemAdicionadoReal).find('#saldoPrimeiroTrimestre').html(Number(saldoPrimeiroTrimestre).toLocaleString('pt-br',{style: 'currency', currency: 'BRL'}))
                                
                            }else if(atingidoTrimestre.numeroTrimestre == 2){
                                
                                var saldoSegundoTrimestre = atingidoTrimestre.saldo
                                $(itemAdicionadoReal).find('#saldoSegundoTrimestre').html(Number(saldoSegundoTrimestre).toLocaleString('pt-br',{style: 'currency', currency: 'BRL'}))
                                
                            }else if(atingidoTrimestre.numeroTrimestre == 3){
                                
                                var saldoTerceiroTrimestre = atingidoTrimestre.saldo
                                $(itemAdicionadoReal).find('#saldoTerceiroTrimestre').html(Number(saldoTerceiroTrimestre).toLocaleString('pt-br',{style: 'currency', currency: 'BRL'}))
                                
                            }else{
                                
                                var saldoQuartoTrimestre = atingidoTrimestre.saldo
                                $(itemAdicionadoReal).find('#saldoQuartoTrimestre').html(Number(saldoQuartoTrimestre).toLocaleString('pt-br',{style: 'currency', currency: 'BRL'}))
                            }
                        }
                    })
                    
                    //=====================================================================//
                    
                    
                    
                    
                    
                }
                
                //ADICIONA A META DE SURGICAL
                if(itemData.metas.eletrocirurgia != undefined && itemData.metas.eletrocirurgia.length > 0 && itemData.metas.eletrocirurgia.filter(v => v.metaMes != undefined && v.ano == helper.anoSetado).length != 0){
                    
                    var metaAnual = Number(itemData.metas.metaAnualEletrocirurgia).toLocaleString('pt-br',{style: 'currency', currency: 'BRL'})
                    var identificadorLinha = "linhaTabelaELETROCIRURGIA"
                    
                    var atingidoAnual = itemData.metas.eletrocirurgiaAno.find(v => v.ano == helper.anoSetado).atingido
                    var atingidoAnualFormatado = Number(atingidoAnual).toLocaleString('pt-br',{style: 'currency', currency: 'BRL'})
                    
                    var linhatabela = "\
    <tr class='linhaTabela' id='"+identificadorLinha+"'>\
    <td id='tipoMeta'>ELETROCIRURGIA</td>\
    <td id='metaAnual'>"+metaAnual+"</td>\
    <td id='atingidoAnual'>"+atingidoAnualFormatado+"</td>\
    <td id='metaMensal' data-mes='1'></td>\
    <td id='realizadoMensal' data-mes='1'></td>\
    <td id='porcentagem' data-mes='1'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='1'></td>\
    <td id='metaMensal' data-mes='2'></td>\
    <td id='realizadoMensal' data-mes='2'></td>\
    <td id='porcentagem' data-mes='2'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='2'></td>\
    <td id='metaMensal' data-mes='3'></td>\
    <td id='realizadoMensal' data-mes='3'></td>\
    <td id='porcentagem' data-mes='3'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='3'></td>\
    <td id='saldoPrimeiroTrimestre'></td>\
    <td id='metaMensal' data-mes='4'></td>\
    <td id='realizadoMensal' data-mes='4'></td>\
    <td id='porcentagem' data-mes='4'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='4'></td>\
    <td id='metaMensal' data-mes='5'></td>\
    <td id='realizadoMensal' data-mes='5'></td>\
    <td id='porcentagem' data-mes='5'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='5'></td>\
    <td id='metaMensal' data-mes='6'></td>\
    <td id='realizadoMensal' data-mes='6'></td>\
    <td id='porcentagem' data-mes='6'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='6'></td>\
    <td id='saldoSegundoTrimestre'></td>\
    <td id='metaMensal' data-mes='7'></td>\
    <td id='realizadoMensal' data-mes='7'></td>\
    <td id='porcentagem' data-mes='7'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='7'></td>\
    <td id='metaMensal' data-mes='8'></td>\
    <td id='realizadoMensal' data-mes='8'></td>\
    <td id='porcentagem' data-mes='8'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='8'></td>\
    <td id='metaMensal' data-mes='9'></td>\
    <td id='realizadoMensal' data-mes='9'></td>\
    <td id='porcentagem' data-mes='9'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='9'></td>\
    <td id='saldoTerceiroTrimestre'></td>\
    <td id='metaMensal' data-mes='10'></td>\
    <td id='realizadoMensal' data-mes='10'></td>\
    <td id='porcentagem' data-mes='10'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='10'></td>\
    <td id='metaMensal' data-mes='11'></td>\
    <td id='realizadoMensal' data-mes='11'></td>\
    <td id='porcentagem' data-mes='11'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='11'></td>\
    <td id='metaMensal' data-mes='12'></td>\
    <td id='realizadoMensal' data-mes='12'></td>\
    <td id='porcentagem' data-mes='12'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='12'></td>\
    <td id='saldoQuartoTrimestre'></td>\
    </tr>\
    ";
                    //ADICIONA LINHA A TABELA
                    var itemAdicionado = $(".BodyTable:last").append(linhatabela)
                    //POR ALGUM MOTIVO A VARIAVEL ANTERIOR NAO RECEBE O VALOR QUE DEVERIA, PORTANTO, CONTORNA O ERRO
                    var itemAdicionadoReal = $(itemAdicionado).find("#"+identificadorLinha+"") 
                                    
                    //PREENCHE VALORES NA LINHA ADICIONADO
                    itemData.metas.eletrocirurgia.forEach(function(metaInternaAtual){
                        
                        //VERIFICA SE EXISTE META PRO VENDEDOR ATUAL
                        if(metaInternaAtual.hasOwnProperty('metaMes')){
                            
                            //RECUPERA O ANO SETADO
                            var anoSetado = helper.anoSetado
                            
                            //VERIFICA SE A META DA ITERACAO ATUAL PERTENCE AO ANO SETADO
                            if(metaInternaAtual.ano == anoSetado){
                                
                                //RECUPERA O MES DA META ATUAL
                                var mesMeta = metaInternaAtual.numeroMes 
                                //ACESSA A LINHA A SER INSERIDO OS DADOS
                                var meslocalizado = $(itemAdicionadoReal).find("[data-mes='" + mesMeta + "']")
                                //RECUPERA O VALOR DA META MENSAL
                                var metaMensal = Number(metaInternaAtual.metaMes).toLocaleString('pt-br',{style: 'currency', currency: 'BRL'})
                                //RECUPERA O VALOR REALIZADO PARA O MES ATUAL
                                var realizadoMensal = Number(metaInternaAtual.total).toLocaleString('pt-br',{style: 'currency', currency: 'BRL'})
                                //RECUPERA O PERCENTUAL REALIZADO PARA O MES ATUAL
                                var percentual = metaInternaAtual.percentualRealizado
                                //RECUPERA O SALDO DA META ATUAL PARA O MES ATUAL
                                var saldoMensal = Number(metaInternaAtual.saldo).toLocaleString('pt-br',{style: 'currency', currency: 'BRL'})
                                //DEFINE A COR DE DESTAQUE DA CELULA
                                var corDestacada = metaInternaAtual.saldo < 0 ? "red" : (metaInternaAtual.saldo > 0 ? "green" : "white")
                                var corDestacadaTexto = metaInternaAtual.saldo < 0 ? "white" : metaInternaAtual.saldo > 0 ? "white" : "black"
                                
    
                                //SETA A META MENSAL
                                $(meslocalizado[0]).html(metaMensal)
                                
                                //SETA A META MENSAL
                                $(meslocalizado[1]).html(realizadoMensal)
                                
                                //SETA A META MENSAL
                                $(meslocalizado[2]).html(percentual + "%")
                                
                                //SETA A META MENSAL
                                $(meslocalizado[3]).html(saldoMensal)
                                $(meslocalizado[3]).attr('data-saldoMensal', metaInternaAtual.saldo)
                                
                                $(meslocalizado[3]).css('background-color', corDestacada)
                                $(meslocalizado[3]).css('color', corDestacadaTexto)
                            }
                            
                            
                        }
                        
                        
                    })
                    
                    //PREENCHE AS METAS DO TRIMESTRE PARA VENDAS
                    itemData.metas.vendasTrimestreELETROCIRURGIA.forEach(function(atingidoTrimestre){
                        var anoSetado = helper.anoSetado
                        
                        if(atingidoTrimestre.ano == anoSetado){
                            //se for igual ao ano setado, entao adiciona na visualizacao da linha
                            
                            if(atingidoTrimestre.numeroTrimestre == 1){
                                
                                var saldoPrimeiroTrimestre = atingidoTrimestre.saldo
                                $(itemAdicionadoReal).find('#saldoPrimeiroTrimestre').html(Number(saldoPrimeiroTrimestre).toLocaleString('pt-br',{style: 'currency', currency: 'BRL'}))
                                
                            }else if(atingidoTrimestre.numeroTrimestre == 2){
                                
                                var saldoSegundoTrimestre = atingidoTrimestre.saldo
                                $(itemAdicionadoReal).find('#saldoSegundoTrimestre').html(Number(saldoSegundoTrimestre).toLocaleString('pt-br',{style: 'currency', currency: 'BRL'}))
                                
                            }else if(atingidoTrimestre.numeroTrimestre == 3){
                                
                                var saldoTerceiroTrimestre = atingidoTrimestre.saldo
                                $(itemAdicionadoReal).find('#saldoTerceiroTrimestre').html(Number(saldoTerceiroTrimestre).toLocaleString('pt-br',{style: 'currency', currency: 'BRL'}))
                                
                            }else{
                                
                                var saldoQuartoTrimestre = atingidoTrimestre.saldo
                                $(itemAdicionadoReal).find('#saldoQuartoTrimestre').html(Number(saldoQuartoTrimestre).toLocaleString('pt-br',{style: 'currency', currency: 'BRL'}))
                            }
                        }
                    })
                    
                    //=====================================================================//
                    
                    
                    
                    
                    
                }
                
                //ADICIONA A META DE ULTRASSOM
                if(itemData.metas.ultrassom != undefined && itemData.metas.ultrassom.length > 0 && itemData.metas.ultrassom.filter(v => v.metaMes != undefined && v.ano == helper.anoSetado).length != 0){
                    
                    var metaAnual = Number(itemData.metas.metaAnualUltrassom).toLocaleString('pt-br',{style: 'currency', currency: 'BRL'})
                    var identificadorLinha = "linhaTabelaULTRASSOM"
                    
                    var atingidoAnual = itemData.metas.ultrassomAno.find(v => v.ano == helper.anoSetado).atingido
                    var atingidoAnualFormatado = Number(atingidoAnual).toLocaleString('pt-br',{style: 'currency', currency: 'BRL'})
                    
                    var linhatabela = "\
    <tr class='linhaTabela' id='"+identificadorLinha+"'>\
    <td id='tipoMeta'>ULTRASSOM</td>\
    <td id='metaAnual'>"+metaAnual+"</td>\
    <td id='atingidoAnual'>"+atingidoAnualFormatado+"</td>\
    <td id='metaMensal' data-mes='1'></td>\
    <td id='realizadoMensal' data-mes='1'></td>\
    <td id='porcentagem' data-mes='1'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='1'></td>\
    <td id='metaMensal' data-mes='2'></td>\
    <td id='realizadoMensal' data-mes='2'></td>\
    <td id='porcentagem' data-mes='2'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='2'></td>\
    <td id='metaMensal' data-mes='3'></td>\
    <td id='realizadoMensal' data-mes='3'></td>\
    <td id='porcentagem' data-mes='3'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='3'></td>\
    <td id='saldoPrimeiroTrimestre'></td>\
    <td id='metaMensal' data-mes='4'></td>\
    <td id='realizadoMensal' data-mes='4'></td>\
    <td id='porcentagem' data-mes='4'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='4'></td>\
    <td id='metaMensal' data-mes='5'></td>\
    <td id='realizadoMensal' data-mes='5'></td>\
    <td id='porcentagem' data-mes='5'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='5'></td>\
    <td id='metaMensal' data-mes='6'></td>\
    <td id='realizadoMensal' data-mes='6'></td>\
    <td id='porcentagem' data-mes='6'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='6'></td>\
    <td id='saldoSegundoTrimestre'></td>\
    <td id='metaMensal' data-mes='7'></td>\
    <td id='realizadoMensal' data-mes='7'></td>\
    <td id='porcentagem' data-mes='7'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='7'></td>\
    <td id='metaMensal' data-mes='8'></td>\
    <td id='realizadoMensal' data-mes='8'></td>\
    <td id='porcentagem' data-mes='8'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='8'></td>\
    <td id='metaMensal' data-mes='9'></td>\
    <td id='realizadoMensal' data-mes='9'></td>\
    <td id='porcentagem' data-mes='9'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='9'></td>\
    <td id='saldoTerceiroTrimestre'></td>\
    <td id='metaMensal' data-mes='10'></td>\
    <td id='realizadoMensal' data-mes='10'></td>\
    <td id='porcentagem' data-mes='10'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='10'></td>\
    <td id='metaMensal' data-mes='11'></td>\
    <td id='realizadoMensal' data-mes='11'></td>\
    <td id='porcentagem' data-mes='11'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='11'></td>\
    <td id='metaMensal' data-mes='12'></td>\
    <td id='realizadoMensal' data-mes='12'></td>\
    <td id='porcentagem' data-mes='12'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='12'></td>\
    <td id='saldoQuartoTrimestre'></td>\
    </tr>\
    ";
                    //ADICIONA LINHA A TABELA
                    var itemAdicionado = $(".BodyTable:last").append(linhatabela)
                    //POR ALGUM MOTIVO A VARIAVEL ANTERIOR NAO RECEBE O VALOR QUE DEVERIA, PORTANTO, CONTORNA O ERRO
                    var itemAdicionadoReal = $(itemAdicionado).find("#"+identificadorLinha+"") 
                                    
                    //PREENCHE VALORES NA LINHA ADICIONADO
                    itemData.metas.ultrassom.forEach(function(metaInternaAtual){
                        
                        //VERIFICA SE EXISTE META PRO VENDEDOR ATUAL
                        if(metaInternaAtual.hasOwnProperty('metaMes')){
                            
                            //RECUPERA O ANO SETADO
                            var anoSetado = helper.anoSetado
                            
                            //VERIFICA SE A META DA ITERACAO ATUAL PERTENCE AO ANO SETADO
                            if(metaInternaAtual.ano == anoSetado){
                                
                                //RECUPERA O MES DA META ATUAL
                                var mesMeta = metaInternaAtual.numeroMes 
                                //ACESSA A LINHA A SER INSERIDO OS DADOS
                                var meslocalizado = $(itemAdicionadoReal).find("[data-mes='" + mesMeta + "']")
                                //RECUPERA O VALOR DA META MENSAL
                                var metaMensal = Number(metaInternaAtual.metaMes).toLocaleString('pt-br',{style: 'currency', currency: 'BRL'})
                                //RECUPERA O VALOR REALIZADO PARA O MES ATUAL
                                var realizadoMensal = Number(metaInternaAtual.total).toLocaleString('pt-br',{style: 'currency', currency: 'BRL'})
                                //RECUPERA O PERCENTUAL REALIZADO PARA O MES ATUAL
                                var percentual = metaInternaAtual.percentualRealizado
                                //RECUPERA O SALDO DA META ATUAL PARA O MES ATUAL
                                var saldoMensal = Number(metaInternaAtual.saldo).toLocaleString('pt-br',{style: 'currency', currency: 'BRL'})
                                //DEFINE A COR DE DESTAQUE DA CELULA
                                var corDestacada = metaInternaAtual.saldo < 0 ? "red" : (metaInternaAtual.saldo > 0 ? "green" : "white")
                                var corDestacadaTexto = metaInternaAtual.saldo < 0 ? "white" : metaInternaAtual.saldo > 0 ? "white" : "black"
                                
    
                                //SETA A META MENSAL
                                $(meslocalizado[0]).html(metaMensal)
                                
                                //SETA A META MENSAL
                                $(meslocalizado[1]).html(realizadoMensal)
                                
                                //SETA A META MENSAL
                                $(meslocalizado[2]).html(percentual + "%")
                                
                                //SETA A META MENSAL
                                $(meslocalizado[3]).html(saldoMensal)
                                $(meslocalizado[3]).attr('data-saldoMensal', metaInternaAtual.saldo)
                                
                                $(meslocalizado[3]).css('background-color', corDestacada)
                                $(meslocalizado[3]).css('color', corDestacadaTexto)
                            }
                        }else{
                            //NAO EXISTE META ATINGIDA
                            
                        }
                    })
                    
                    //PREENCHE AS METAS DO TRIMESTRE PARA VENDAS
                    itemData.metas.vendasTrimestreULTRASSOM.forEach(function(atingidoTrimestre){
                        var anoSetado = helper.anoSetado
                        
                        if(atingidoTrimestre.ano == anoSetado){
                            //se for igual ao ano setado, entao adiciona na visualizacao da linha
                            
                            if(atingidoTrimestre.numeroTrimestre == 1){
                                
                                var saldoPrimeiroTrimestre = atingidoTrimestre.saldo
                                $(itemAdicionadoReal).find('#saldoPrimeiroTrimestre').html(Number(saldoPrimeiroTrimestre).toLocaleString('pt-br',{style: 'currency', currency: 'BRL'}))
                                
                            }else if(atingidoTrimestre.numeroTrimestre == 2){
                                
                                var saldoSegundoTrimestre = atingidoTrimestre.saldo
                                $(itemAdicionadoReal).find('#saldoSegundoTrimestre').html(Number(saldoSegundoTrimestre).toLocaleString('pt-br',{style: 'currency', currency: 'BRL'}))
                                
                            }else if(atingidoTrimestre.numeroTrimestre == 3){
                                
                                var saldoTerceiroTrimestre = atingidoTrimestre.saldo
                                $(itemAdicionadoReal).find('#saldoTerceiroTrimestre').html(Number(saldoTerceiroTrimestre).toLocaleString('pt-br',{style: 'currency', currency: 'BRL'}))
                                
                            }else{
                                
                                var saldoQuartoTrimestre = atingidoTrimestre.saldo
                                $(itemAdicionadoReal).find('#saldoQuartoTrimestre').html(Number(saldoQuartoTrimestre).toLocaleString('pt-br',{style: 'currency', currency: 'BRL'}))
                            }
                        }
                    })
                    
                    //=====================================================================//
                    
                    
                    
                    
                    
                }
                
                //ADICIONA A META DE ULTRASSOM
                if(itemData.metas.ultrassomPoc != undefined && itemData.metas.ultrassomPoc.length > 0 && itemData.metas.ultrassomPoc.filter(v => v.metaMes != undefined && v.ano == helper.anoSetado).length != 0){
                    
                    var metaAnual = Number(itemData.metas.metaAnualUltrassomPOC).toLocaleString('pt-br',{style: 'currency', currency: 'BRL'})
                    var identificadorLinha = "linhaTabelaULTRASSOMPOC"
                    
                    var atingidoAnual = itemData.metas.ultrassomPOCAno.find(v => v.ano == helper.anoSetado).atingido
                    var atingidoAnualFormatado = Number(atingidoAnual).toLocaleString('pt-br',{style: 'currency', currency: 'BRL'})
                    
                    var linhatabela = "\
    <tr class='linhaTabela' id='"+identificadorLinha+"'>\
    <td id='tipoMeta'>ULTRASSOM POC</td>\
    <td id='metaAnual'>"+metaAnual+"</td>\
    <td id='atingidoAnual'>"+atingidoAnualFormatado+"</td>\
    <td id='metaMensal' data-mes='1'></td>\
    <td id='realizadoMensal' data-mes='1'></td>\
    <td id='porcentagem' data-mes='1'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='1'></td>\
    <td id='metaMensal' data-mes='2'></td>\
    <td id='realizadoMensal' data-mes='2'></td>\
    <td id='porcentagem' data-mes='2'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='2'></td>\
    <td id='metaMensal' data-mes='3'></td>\
    <td id='realizadoMensal' data-mes='3'></td>\
    <td id='porcentagem' data-mes='3'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='3'></td>\
    <td id='saldoPrimeiroTrimestre'></td>\
    <td id='metaMensal' data-mes='4'></td>\
    <td id='realizadoMensal' data-mes='4'></td>\
    <td id='porcentagem' data-mes='4'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='4'></td>\
    <td id='metaMensal' data-mes='5'></td>\
    <td id='realizadoMensal' data-mes='5'></td>\
    <td id='porcentagem' data-mes='5'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='5'></td>\
    <td id='metaMensal' data-mes='6'></td>\
    <td id='realizadoMensal' data-mes='6'></td>\
    <td id='porcentagem' data-mes='6'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='6'></td>\
    <td id='saldoSegundoTrimestre'></td>\
    <td id='metaMensal' data-mes='7'></td>\
    <td id='realizadoMensal' data-mes='7'></td>\
    <td id='porcentagem' data-mes='7'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='7'></td>\
    <td id='metaMensal' data-mes='8'></td>\
    <td id='realizadoMensal' data-mes='8'></td>\
    <td id='porcentagem' data-mes='8'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='8'></td>\
    <td id='metaMensal' data-mes='9'></td>\
    <td id='realizadoMensal' data-mes='9'></td>\
    <td id='porcentagem' data-mes='9'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='9'></td>\
    <td id='saldoTerceiroTrimestre'></td>\
    <td id='metaMensal' data-mes='10'></td>\
    <td id='realizadoMensal' data-mes='10'></td>\
    <td id='porcentagem' data-mes='10'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='10'></td>\
    <td id='metaMensal' data-mes='11'></td>\
    <td id='realizadoMensal' data-mes='11'></td>\
    <td id='porcentagem' data-mes='11'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='11'></td>\
    <td id='metaMensal' data-mes='12'></td>\
    <td id='realizadoMensal' data-mes='12'></td>\
    <td id='porcentagem' data-mes='12'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='12'></td>\
    <td id='saldoQuartoTrimestre'></td>\
    </tr>\
    ";
                    //ADICIONA LINHA A TABELA
                    var itemAdicionado = $(".BodyTable:last").append(linhatabela)
                    //POR ALGUM MOTIVO A VARIAVEL ANTERIOR NAO RECEBE O VALOR QUE DEVERIA, PORTANTO, CONTORNA O ERRO
                    var itemAdicionadoReal = $(itemAdicionado).find("#"+identificadorLinha+"") 
                                    
                    //PREENCHE VALORES NA LINHA ADICIONADO
                    itemData.metas.ultrassomPoc.forEach(function(metaInternaAtual){
                        
                        //VERIFICA SE EXISTE META PRO VENDEDOR ATUAL
                        if(metaInternaAtual.hasOwnProperty('metaMes')){
                            
                            //RECUPERA O ANO SETADO
                            var anoSetado = helper.anoSetado
                            
                            //VERIFICA SE A META DA ITERACAO ATUAL PERTENCE AO ANO SETADO
                            if(metaInternaAtual.ano == anoSetado){
                                
                                //RECUPERA O MES DA META ATUAL
                                var mesMeta = metaInternaAtual.numeroMes 
                                //ACESSA A LINHA A SER INSERIDO OS DADOS
                                var meslocalizado = $(itemAdicionadoReal).find("[data-mes='" + mesMeta + "']")
                                //RECUPERA O VALOR DA META MENSAL
                                var metaMensal = Number(metaInternaAtual.metaMes).toLocaleString('pt-br',{style: 'currency', currency: 'BRL'})
                                //RECUPERA O VALOR REALIZADO PARA O MES ATUAL
                                var realizadoMensal = Number(metaInternaAtual.total).toLocaleString('pt-br',{style: 'currency', currency: 'BRL'})
                                //RECUPERA O PERCENTUAL REALIZADO PARA O MES ATUAL
                                var percentual = metaInternaAtual.percentualRealizado
                                //RECUPERA O SALDO DA META ATUAL PARA O MES ATUAL
                                var saldoMensal = Number(metaInternaAtual.saldo).toLocaleString('pt-br',{style: 'currency', currency: 'BRL'})
                                //DEFINE A COR DE DESTAQUE DA CELULA
                                var corDestacada = metaInternaAtual.saldo < 0 ? "red" : (metaInternaAtual.saldo > 0 ? "green" : "white")
                                var corDestacadaTexto = metaInternaAtual.saldo < 0 ? "white" : metaInternaAtual.saldo > 0 ? "white" : "black"
                                
    
                                //SETA A META MENSAL
                                $(meslocalizado[0]).html(metaMensal)
                                
                                //SETA A META MENSAL
                                $(meslocalizado[1]).html(realizadoMensal)
                                
                                //SETA A META MENSAL
                                $(meslocalizado[2]).html(percentual + "%")
                                
                                //SETA A META MENSAL
                                $(meslocalizado[3]).html(saldoMensal)
                                $(meslocalizado[3]).attr('data-saldoMensal', metaInternaAtual.saldo)
                                
                                $(meslocalizado[3]).css('background-color', corDestacada)
                                $(meslocalizado[3]).css('color', corDestacadaTexto)
                            }
                        }else{
                            //NAO EXISTE META ATINGIDA
                            
                        }
                    })
                    
                    //PREENCHE AS METAS DO TRIMESTRE PARA VENDAS
                    itemData.metas.vendasTrimestreULTRASSOMPOC.forEach(function(atingidoTrimestre){
                        var anoSetado = helper.anoSetado
                        
                        if(atingidoTrimestre.ano == anoSetado){
                            //se for igual ao ano setado, entao adiciona na visualizacao da linha
                            
                            if(atingidoTrimestre.numeroTrimestre == 1){
                                
                                var saldoPrimeiroTrimestre = atingidoTrimestre.saldo
                                $(itemAdicionadoReal).find('#saldoPrimeiroTrimestre').html(Number(saldoPrimeiroTrimestre).toLocaleString('pt-br',{style: 'currency', currency: 'BRL'}))
                                
                            }else if(atingidoTrimestre.numeroTrimestre == 2){
                                
                                var saldoSegundoTrimestre = atingidoTrimestre.saldo
                                $(itemAdicionadoReal).find('#saldoSegundoTrimestre').html(Number(saldoSegundoTrimestre).toLocaleString('pt-br',{style: 'currency', currency: 'BRL'}))
                                
                            }else if(atingidoTrimestre.numeroTrimestre == 3){
                                
                                var saldoTerceiroTrimestre = atingidoTrimestre.saldo
                                $(itemAdicionadoReal).find('#saldoTerceiroTrimestre').html(Number(saldoTerceiroTrimestre).toLocaleString('pt-br',{style: 'currency', currency: 'BRL'}))
                                
                            }else{
                                
                                var saldoQuartoTrimestre = atingidoTrimestre.saldo
                                $(itemAdicionadoReal).find('#saldoQuartoTrimestre').html(Number(saldoQuartoTrimestre).toLocaleString('pt-br',{style: 'currency', currency: 'BRL'}))
                            }
                        }
                    })
                    
                    //=====================================================================//
                    
                    
                    
                    
                    
                }
                
                 //ADICIONA A META DE ULTRASSOM
                if(itemData.metas.ultrassomFixo != undefined && itemData.metas.ultrassomFixo.length > 0 && itemData.metas.ultrassomFixo.filter(v => v.metaMes != undefined && v.ano == helper.anoSetado).length != 0){
                    
                    console.log("printando uiltrasom fixo")
                    var metaAnual = Number(itemData.metas.metaAnualUltrassomFixo).toLocaleString('pt-br',{style: 'currency', currency: 'BRL'})
                    var identificadorLinha = "linhaTabelaULTRASSOMFIXO"
                    
                    var atingidoAnual = itemData.metas.ultrassomFIXOAno.find(v => v.ano == helper.anoSetado).atingido
                    var atingidoAnualFormatado = Number(atingidoAnual).toLocaleString('pt-br',{style: 'currency', currency: 'BRL'})
                    
                    var linhatabela = "\
    <tr class='linhaTabela' id='"+identificadorLinha+"'>\
    <td id='tipoMeta'>ULTRASSOM FIXO</td>\
    <td id='metaAnual'>"+metaAnual+"</td>\
    <td id='atingidoAnual'>"+atingidoAnualFormatado+"</td>\
    <td id='metaMensal' data-mes='1'></td>\
    <td id='realizadoMensal' data-mes='1'></td>\
    <td id='porcentagem' data-mes='1'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='1'></td>\
    <td id='metaMensal' data-mes='2'></td>\
    <td id='realizadoMensal' data-mes='2'></td>\
    <td id='porcentagem' data-mes='2'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='2'></td>\
    <td id='metaMensal' data-mes='3'></td>\
    <td id='realizadoMensal' data-mes='3'></td>\
    <td id='porcentagem' data-mes='3'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='3'></td>\
    <td id='saldoPrimeiroTrimestre'></td>\
    <td id='metaMensal' data-mes='4'></td>\
    <td id='realizadoMensal' data-mes='4'></td>\
    <td id='porcentagem' data-mes='4'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='4'></td>\
    <td id='metaMensal' data-mes='5'></td>\
    <td id='realizadoMensal' data-mes='5'></td>\
    <td id='porcentagem' data-mes='5'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='5'></td>\
    <td id='metaMensal' data-mes='6'></td>\
    <td id='realizadoMensal' data-mes='6'></td>\
    <td id='porcentagem' data-mes='6'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='6'></td>\
    <td id='saldoSegundoTrimestre'></td>\
    <td id='metaMensal' data-mes='7'></td>\
    <td id='realizadoMensal' data-mes='7'></td>\
    <td id='porcentagem' data-mes='7'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='7'></td>\
    <td id='metaMensal' data-mes='8'></td>\
    <td id='realizadoMensal' data-mes='8'></td>\
    <td id='porcentagem' data-mes='8'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='8'></td>\
    <td id='metaMensal' data-mes='9'></td>\
    <td id='realizadoMensal' data-mes='9'></td>\
    <td id='porcentagem' data-mes='9'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='9'></td>\
    <td id='saldoTerceiroTrimestre'></td>\
    <td id='metaMensal' data-mes='10'></td>\
    <td id='realizadoMensal' data-mes='10'></td>\
    <td id='porcentagem' data-mes='10'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='10'></td>\
    <td id='metaMensal' data-mes='11'></td>\
    <td id='realizadoMensal' data-mes='11'></td>\
    <td id='porcentagem' data-mes='11'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='11'></td>\
    <td id='metaMensal' data-mes='12'></td>\
    <td id='realizadoMensal' data-mes='12'></td>\
    <td id='porcentagem' data-mes='12'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='12'></td>\
    <td id='saldoQuartoTrimestre'></td>\
    </tr>\
    ";
                    //ADICIONA LINHA A TABELA
                    var itemAdicionado = $(".BodyTable:last").append(linhatabela)
                    //POR ALGUM MOTIVO A VARIAVEL ANTERIOR NAO RECEBE O VALOR QUE DEVERIA, PORTANTO, CONTORNA O ERRO
                    var itemAdicionadoReal = $(itemAdicionado).find("#"+identificadorLinha+"") 
                                    
                    //PREENCHE VALORES NA LINHA ADICIONADO
                    itemData.metas.ultrassomFixo.forEach(function(metaInternaAtual){
                        
                        //VERIFICA SE EXISTE META PRO VENDEDOR ATUAL
                        if(metaInternaAtual.hasOwnProperty('metaMes')){
                            
                            //RECUPERA O ANO SETADO
                            var anoSetado = helper.anoSetado
                            
                            //VERIFICA SE A META DA ITERACAO ATUAL PERTENCE AO ANO SETADO
                            if(metaInternaAtual.ano == anoSetado){
                                
                                //RECUPERA O MES DA META ATUAL
                                var mesMeta = metaInternaAtual.numeroMes 
                                //ACESSA A LINHA A SER INSERIDO OS DADOS
                                var meslocalizado = $(itemAdicionadoReal).find("[data-mes='" + mesMeta + "']")
                                //RECUPERA O VALOR DA META MENSAL
                                var metaMensal = Number(metaInternaAtual.metaMes).toLocaleString('pt-br',{style: 'currency', currency: 'BRL'})
                                //RECUPERA O VALOR REALIZADO PARA O MES ATUAL
                                var realizadoMensal = Number(metaInternaAtual.total).toLocaleString('pt-br',{style: 'currency', currency: 'BRL'})
                                //RECUPERA O PERCENTUAL REALIZADO PARA O MES ATUAL
                                var percentual = metaInternaAtual.percentualRealizado
                                //RECUPERA O SALDO DA META ATUAL PARA O MES ATUAL
                                var saldoMensal = Number(metaInternaAtual.saldo).toLocaleString('pt-br',{style: 'currency', currency: 'BRL'})
                                //DEFINE A COR DE DESTAQUE DA CELULA
                                var corDestacada = metaInternaAtual.saldo < 0 ? "red" : (metaInternaAtual.saldo > 0 ? "green" : "white")
                                var corDestacadaTexto = metaInternaAtual.saldo < 0 ? "white" : metaInternaAtual.saldo > 0 ? "white" : "black"
                                
    
                                //SETA A META MENSAL
                                $(meslocalizado[0]).html(metaMensal)
                                
                                //SETA A META MENSAL
                                $(meslocalizado[1]).html(realizadoMensal)
                                
                                //SETA A META MENSAL
                                $(meslocalizado[2]).html(percentual + "%")
                                
                                //SETA A META MENSAL
                                $(meslocalizado[3]).html(saldoMensal)
                                $(meslocalizado[3]).attr('data-saldoMensal', metaInternaAtual.saldo)
                                
                                $(meslocalizado[3]).css('background-color', corDestacada)
                                $(meslocalizado[3]).css('color', corDestacadaTexto)
                            }
                        }else{
                            //NAO EXISTE META ATINGIDA
                            
                        }
                    })
                    
                    //PREENCHE AS METAS DO TRIMESTRE PARA VENDAS
                    itemData.metas.vendasTrimestreULTRASSOMFIXO.forEach(function(atingidoTrimestre){
                        var anoSetado = helper.anoSetado
                        
                        if(atingidoTrimestre.ano == anoSetado){
                            //se for igual ao ano setado, entao adiciona na visualizacao da linha
                            
                            if(atingidoTrimestre.numeroTrimestre == 1){
                                
                                var saldoPrimeiroTrimestre = atingidoTrimestre.saldo
                                $(itemAdicionadoReal).find('#saldoPrimeiroTrimestre').html(Number(saldoPrimeiroTrimestre).toLocaleString('pt-br',{style: 'currency', currency: 'BRL'}))
                                
                            }else if(atingidoTrimestre.numeroTrimestre == 2){
                                
                                var saldoSegundoTrimestre = atingidoTrimestre.saldo
                                $(itemAdicionadoReal).find('#saldoSegundoTrimestre').html(Number(saldoSegundoTrimestre).toLocaleString('pt-br',{style: 'currency', currency: 'BRL'}))
                                
                            }else if(atingidoTrimestre.numeroTrimestre == 3){
                                
                                var saldoTerceiroTrimestre = atingidoTrimestre.saldo
                                $(itemAdicionadoReal).find('#saldoTerceiroTrimestre').html(Number(saldoTerceiroTrimestre).toLocaleString('pt-br',{style: 'currency', currency: 'BRL'}))
                                
                            }else{
                                
                                var saldoQuartoTrimestre = atingidoTrimestre.saldo
                                $(itemAdicionadoReal).find('#saldoQuartoTrimestre').html(Number(saldoQuartoTrimestre).toLocaleString('pt-br',{style: 'currency', currency: 'BRL'}))
                            }
                        }
                    })
                    
                    //=====================================================================//
                    
                    
                    
                    
                    
                }
                
                //ADICIONA A META DE LOCACAO
                if(itemData.metas.locacao != undefined && itemData.metas.locacao.length > 0 && itemData.metas.locacao.filter(v => v.metaMes != undefined && v.ano == helper.anoSetado).length != 0){
                    
                    var identificadorLinha = "linhaTabelaLOCACAO"
                    var metaAnual = Number(itemData.metas.metaAnualLocacao).toLocaleString('pt-br',{style: 'currency', currency: 'BRL'})
                    
                    var atingidoAnual = itemData.metas.locacaoAno.find(v => v.ano == helper.anoSetado).atingido
                    var atingidoAnualFormatado = Number(atingidoAnual).toLocaleString('pt-br',{style: 'currency', currency: 'BRL'})
                    
                    var linhatabela = "\
    <tr class='linhaTabela' id='"+identificadorLinha+"'>\
        <td id='tipoMeta'>LOCACAO</td>\
    <td id='metaAnual'>"+metaAnual+"</td>\
    <td id='atingidoAnual'>"+atingidoAnualFormatado+"</td>\
    <td id='metaMensal' data-mes='1'></td>\
    <td id='realizadoMensal' data-mes='1'></td>\
    <td id='porcentagem' data-mes='1'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='1'></td>\
    <td id='metaMensal' data-mes='2'></td>\
    <td id='realizadoMensal' data-mes='2'></td>\
    <td id='porcentagem' data-mes='2'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='2'></td>\
    <td id='metaMensal' data-mes='3'></td>\
    <td id='realizadoMensal' data-mes='3'></td>\
    <td id='porcentagem' data-mes='3'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='3'></td>\
    <td id='saldoPrimeiroTrimestre'></td>\
    <td id='metaMensal' data-mes='4'></td>\
    <td id='realizadoMensal' data-mes='4'></td>\
    <td id='porcentagem' data-mes='4'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='4'></td>\
    <td id='metaMensal' data-mes='5'></td>\
    <td id='realizadoMensal' data-mes='5'></td>\
    <td id='porcentagem' data-mes='5'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='5'></td>\
    <td id='metaMensal' data-mes='6'></td>\
    <td id='realizadoMensal' data-mes='6'></td>\
    <td id='porcentagem' data-mes='6'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='6'></td>\
    <td id='saldoSegundoTrimestre'></td>\
    <td id='metaMensal' data-mes='7'></td>\
    <td id='realizadoMensal' data-mes='7'></td>\
    <td id='porcentagem' data-mes='7'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='7'></td>\
    <td id='metaMensal' data-mes='8'></td>\
    <td id='realizadoMensal' data-mes='8'></td>\
    <td id='porcentagem' data-mes='8'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='8'></td>\
    <td id='metaMensal' data-mes='9'></td>\
    <td id='realizadoMensal' data-mes='9'></td>\
    <td id='porcentagem' data-mes='9'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='9'></td>\
    <td id='saldoTerceiroTrimestre'></td>\
    <td id='metaMensal' data-mes='10'></td>\
    <td id='realizadoMensal' data-mes='10'></td>\
    <td id='porcentagem' data-mes='10'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='10'></td>\
    <td id='metaMensal' data-mes='11'></td>\
    <td id='realizadoMensal' data-mes='11'></td>\
    <td id='porcentagem' data-mes='11'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='11'></td>\
    <td id='metaMensal' data-mes='12'></td>\
    <td id='realizadoMensal' data-mes='12'></td>\
    <td id='porcentagem' data-mes='12'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='12'></td>\
    <td id='saldoQuartoTrimestre'></td>\
    </tr>\
    ";
                    //ADICIONA LINHA A TABELA
                    var itemAdicionado = $(".BodyTable:last").append(linhatabela)
                    //POR ALGUM MOTIVO A VARIAVEL ANTERIOR NAO RECEBE O VALOR QUE DEVERIA, PORTANTO, CONTORNA O ERRO
                    var itemAdicionadoReal = $(itemAdicionado).find("#"+identificadorLinha+"") 
                                    
                    //PREENCHE VALORES NA LINHA ADICIONADO
                    itemData.metas.locacao.forEach(function(metaInternaAtual){
                        
                        //VERIFICA SE EXISTE META PRO VENDEDOR ATUAL
                        if(metaInternaAtual.hasOwnProperty('metaMes')){
                            
                            //RECUPERA O ANO SETADO
                            var anoSetado = helper.anoSetado
                            
                            //VERIFICA SE A META DA ITERACAO ATUAL PERTENCE AO ANO SETADO
                            if(metaInternaAtual.ano == anoSetado){
                                
                                //RECUPERA O MES DA META ATUAL
                                var mesMeta = metaInternaAtual.numeroMes 
                                //ACESSA A LINHA A SER INSERIDO OS DADOS
                                var meslocalizado = $(itemAdicionadoReal).find("[data-mes='" + mesMeta + "']")
                                //RECUPERA O VALOR DA META MENSAL
                                var metaMensal = Number(metaInternaAtual.metaMes).toLocaleString('pt-br',{style: 'currency', currency: 'BRL'})
                                //RECUPERA O VALOR REALIZADO PARA O MES ATUAL
                                var realizadoMensal = Number(metaInternaAtual.total).toLocaleString('pt-br',{style: 'currency', currency: 'BRL'})
                                //RECUPERA O PERCENTUAL REALIZADO PARA O MES ATUAL
                                var percentual = metaInternaAtual.percentualRealizado
                                //RECUPERA O SALDO DA META ATUAL PARA O MES ATUAL
                                var saldoMensal = Number(metaInternaAtual.saldo).toLocaleString('pt-br',{style: 'currency', currency: 'BRL'})
                                //DEFINE A COR DE DESTAQUE DA CELULA
                                var corDestacada = metaInternaAtual.saldo < 0 ? "red" : (metaInternaAtual.saldo > 0 ? "green" : "white")
                                var corDestacadaTexto = metaInternaAtual.saldo < 0 ? "white" : metaInternaAtual.saldo > 0 ? "white" : "black"
                                
    
                                //SETA A META MENSAL
                                $(meslocalizado[0]).html(metaMensal)
                                
                                //SETA A META MENSAL
                                $(meslocalizado[1]).html(realizadoMensal)
                                
                                //SETA A META MENSAL
                                $(meslocalizado[2]).html(percentual + "%")
                                
                                //SETA A META MENSAL
                                $(meslocalizado[3]).html(saldoMensal)
                                $(meslocalizado[3]).attr('data-saldoMensal', metaInternaAtual.saldo)
                                
                                $(meslocalizado[3]).css('background-color', corDestacada)
                                $(meslocalizado[3]).css('color', corDestacadaTexto)
                            }
                            
                            
                        }
                        
                        
                    })
                    
                    //PREENCHE AS METAS DO TRIMESTRE PARA VENDAS
                    itemData.metas.vendasTrimestreLOCACAO.forEach(function(atingidoTrimestre){
                        var anoSetado = helper.anoSetado
                        
                        if(atingidoTrimestre.ano == anoSetado){
                            //se for igual ao ano setado, entao adiciona na visualizacao da linha
                            
                            if(atingidoTrimestre.numeroTrimestre == 1){
                                
                                var saldoPrimeiroTrimestre = atingidoTrimestre.saldo
                                $(itemAdicionadoReal).find('#saldoPrimeiroTrimestre').html(Number(saldoPrimeiroTrimestre).toLocaleString('pt-br',{style: 'currency', currency: 'BRL'}))
                                
                            }else if(atingidoTrimestre.numeroTrimestre == 2){
                                
                                var saldoSegundoTrimestre = atingidoTrimestre.saldo
                                $(itemAdicionadoReal).find('#saldoSegundoTrimestre').html(Number(saldoSegundoTrimestre).toLocaleString('pt-br',{style: 'currency', currency: 'BRL'}))
                                
                            }else if(atingidoTrimestre.numeroTrimestre == 3){
                                
                                var saldoTerceiroTrimestre = atingidoTrimestre.saldo
                                $(itemAdicionadoReal).find('#saldoTerceiroTrimestre').html(Number(saldoTerceiroTrimestre).toLocaleString('pt-br',{style: 'currency', currency: 'BRL'}))
                                
                            }else{
                                
                                var saldoQuartoTrimestre = atingidoTrimestre.saldo
                                $(itemAdicionadoReal).find('#saldoQuartoTrimestre').html(Number(saldoQuartoTrimestre).toLocaleString('pt-br',{style: 'currency', currency: 'BRL'}))
                            }
                        }
                    })
                    
                    //=====================================================================//
                    
                    
                    
                    
                    
                }
                
                //ADICIONA A META DE OUTROS
                if(itemData.metas.outros != undefined && itemData.metas.outros.length > 0 && itemData.metas.outros.filter(v => v.metaMes != undefined && v.ano == helper.anoSetado).length != 0){
                    
                    var metaAnual = Number(itemData.metas.metaAnualOutros).toLocaleString('pt-br',{style: 'currency', currency: 'BRL'})
                    var identificadorLinha = "linhaTabelaOUTROS"
                    
                    var atingidoAnual = itemData.metas.outrosAno.find(v => v.ano == helper.anoSetado).atingido
                    var atingidoAnualFormatado = Number(atingidoAnual).toLocaleString('pt-br',{style: 'currency', currency: 'BRL'})
                    
                    var linhatabela = "\
    <tr class='linhaTabela' id='"+identificadorLinha+"'>\
        <td id='tipoMeta'>OUTROS</td>\
    <td id='metaAnual'>"+metaAnual+"</td>\
    <td id='atingidoAnual'>"+atingidoAnualFormatado+"</td>\
    <td id='metaMensal' data-mes='1'></td>\
    <td id='realizadoMensal' data-mes='1'></td>\
    <td id='porcentagem' data-mes='1'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='1'></td>\
    <td id='metaMensal' data-mes='2'></td>\
    <td id='realizadoMensal' data-mes='2'></td>\
    <td id='porcentagem' data-mes='2'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='2'></td>\
    <td id='metaMensal' data-mes='3'></td>\
    <td id='realizadoMensal' data-mes='3'></td>\
    <td id='porcentagem' data-mes='3'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='3'></td>\
    <td id='saldoPrimeiroTrimestre'></td>\
    <td id='metaMensal' data-mes='4'></td>\
    <td id='realizadoMensal' data-mes='4'></td>\
    <td id='porcentagem' data-mes='4'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='4'></td>\
    <td id='metaMensal' data-mes='5'></td>\
    <td id='realizadoMensal' data-mes='5'></td>\
    <td id='porcentagem' data-mes='5'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='5'></td>\
    <td id='metaMensal' data-mes='6'></td>\
    <td id='realizadoMensal' data-mes='6'></td>\
    <td id='porcentagem' data-mes='6'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='6'></td>\
    <td id='saldoSegundoTrimestre'></td>\
    <td id='metaMensal' data-mes='7'></td>\
    <td id='realizadoMensal' data-mes='7'></td>\
    <td id='porcentagem' data-mes='7'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='7'></td>\
    <td id='metaMensal' data-mes='8'></td>\
    <td id='realizadoMensal' data-mes='8'></td>\
    <td id='porcentagem' data-mes='8'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='8'></td>\
    <td id='metaMensal' data-mes='9'></td>\
    <td id='realizadoMensal' data-mes='9'></td>\
    <td id='porcentagem' data-mes='9'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='9'></td>\
    <td id='saldoTerceiroTrimestre'></td>\
    <td id='metaMensal' data-mes='10'></td>\
    <td id='realizadoMensal' data-mes='10'></td>\
    <td id='porcentagem' data-mes='10'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='10'></td>\
    <td id='metaMensal' data-mes='11'></td>\
    <td id='realizadoMensal' data-mes='11'></td>\
    <td id='porcentagem' data-mes='11'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='11'></td>\
    <td id='metaMensal' data-mes='12'></td>\
    <td id='realizadoMensal' data-mes='12'></td>\
    <td id='porcentagem' data-mes='12'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='12'></td>\
    <td id='saldoQuartoTrimestre'></td>\
    </tr>\
    ";
                    //ADICIONA LINHA A TABELA
                    var itemAdicionado = $(".BodyTable:last").append(linhatabela)
                    //POR ALGUM MOTIVO A VARIAVEL ANTERIOR NAO RECEBE O VALOR QUE DEVERIA, PORTANTO, CONTORNA O ERRO
                    var itemAdicionadoReal = $(itemAdicionado).find("#"+identificadorLinha+"") 
                                    
                    //PREENCHE VALORES NA LINHA ADICIONADO
                    itemData.metas.outros.forEach(function(metaInternaAtual){
                        
                        //VERIFICA SE EXISTE META PRO VENDEDOR ATUAL
                        if(metaInternaAtual.hasOwnProperty('metaMes')){
                            
                            //RECUPERA O ANO SETADO
                            var anoSetado = helper.anoSetado
                            
                            //VERIFICA SE A META DA ITERACAO ATUAL PERTENCE AO ANO SETADO
                            if(metaInternaAtual.ano == anoSetado){
                                
                                //RECUPERA O MES DA META ATUAL
                                var mesMeta = metaInternaAtual.numeroMes 
                                //ACESSA A LINHA A SER INSERIDO OS DADOS
                                var meslocalizado = $(itemAdicionadoReal).find("[data-mes='" + mesMeta + "']")
                                //RECUPERA O VALOR DA META MENSAL
                                var metaMensal = Number(metaInternaAtual.metaMes).toLocaleString('pt-br',{style: 'currency', currency: 'BRL'})
                                //RECUPERA O VALOR REALIZADO PARA O MES ATUAL
                                var realizadoMensal = Number(metaInternaAtual.total).toLocaleString('pt-br',{style: 'currency', currency: 'BRL'})
                                //RECUPERA O PERCENTUAL REALIZADO PARA O MES ATUAL
                                var percentual = metaInternaAtual.percentualRealizado
                                //RECUPERA O SALDO DA META ATUAL PARA O MES ATUAL
                                var saldoMensal = Number(metaInternaAtual.saldo).toLocaleString('pt-br',{style: 'currency', currency: 'BRL'})
                                //DEFINE A COR DE DESTAQUE DA CELULA
                                var corDestacada = metaInternaAtual.saldo < 0 ? "red" : (metaInternaAtual.saldo > 0 ? "green" : "white")
                                var corDestacadaTexto = metaInternaAtual.saldo < 0 ? "white" : metaInternaAtual.saldo > 0 ? "white" : "black"
                                
    
                                //SETA A META MENSAL
                                $(meslocalizado[0]).html(metaMensal)
                                
                                //SETA A META MENSAL
                                $(meslocalizado[1]).html(realizadoMensal)
                                
                                //SETA A META MENSAL
                                $(meslocalizado[2]).html(percentual + "%")
                                
                                //SETA A META MENSAL
                                $(meslocalizado[3]).html(saldoMensal)
                                $(meslocalizado[3]).attr('data-saldoMensal', metaInternaAtual.saldo)
                                
                                $(meslocalizado[3]).css('background-color', corDestacada)
                                $(meslocalizado[3]).css('color', corDestacadaTexto)
                            }
                            
                            
                        }
                        
                        
                    })
                    
                    //PREENCHE AS METAS DO TRIMESTRE PARA VENDAS
                    itemData.metas.vendasTrimestreOUTROS.forEach(function(atingidoTrimestre){
                        var anoSetado = helper.anoSetado
                        
                        if(atingidoTrimestre.ano == anoSetado){
                            //se for igual ao ano setado, entao adiciona na visualizacao da linha
                            
                            if(atingidoTrimestre.numeroTrimestre == 1){
                                
                                var saldoPrimeiroTrimestre = atingidoTrimestre.saldo
                                $(itemAdicionadoReal).find('#saldoPrimeiroTrimestre').html(Number(saldoPrimeiroTrimestre).toLocaleString('pt-br',{style: 'currency', currency: 'BRL'}))
                                
                            }else if(atingidoTrimestre.numeroTrimestre == 2){
                                
                                var saldoSegundoTrimestre = atingidoTrimestre.saldo
                                $(itemAdicionadoReal).find('#saldoSegundoTrimestre').html(Number(saldoSegundoTrimestre).toLocaleString('pt-br',{style: 'currency', currency: 'BRL'}))
                                
                            }else if(atingidoTrimestre.numeroTrimestre == 3){
                                
                                var saldoTerceiroTrimestre = atingidoTrimestre.saldo
                                $(itemAdicionadoReal).find('#saldoTerceiroTrimestre').html(Number(saldoTerceiroTrimestre).toLocaleString('pt-br',{style: 'currency', currency: 'BRL'}))
                                
                            }else{
                                
                                var saldoQuartoTrimestre = atingidoTrimestre.saldo
                                $(itemAdicionadoReal).find('#saldoQuartoTrimestre').html(Number(saldoQuartoTrimestre).toLocaleString('pt-br',{style: 'currency', currency: 'BRL'}))
                            }
                        }
                    })
                    
                    //=====================================================================//
                    
                    
                    
                    
                    
                }
                
                //ADICIONA A META DE VISITAS
                if(itemData.metas.quantidadeVisitas != undefined && itemData.metas.quantidadeVisitas.length > 0 && itemData.metas.quantidadeVisitas.filter(v => v.metaMes != undefined && v.ano == helper.anoSetado).length != 0){
                    
                    var metaAnual = itemData.metas.metaAnualVisitas
                    var identificadorLinha = "linhaTabelaVISITAS"
                    
                    var atingidoAnual = itemData.metas.quantidadeVisitasAno.find(v => v.ano == helper.anoSetado).atingido
                    var atingidoAnualFormatado = Number(atingidoAnual)
                    
                    var linhatabela = "\
    <tr class='linhaTabela' id='"+identificadorLinha+"'>\
        <td id='tipoMeta'>VISITAS</td>\
    <td id='metaAnual'>"+metaAnual+"</td>\
    <td id='atingidoAnual'>"+atingidoAnualFormatado+"</td>\
    <td id='metaMensal' data-mes='1'></td>\
    <td id='realizadoMensal' data-mes='1'></td>\
    <td id='porcentagem' data-mes='1'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='1'></td>\
    <td id='metaMensal' data-mes='2'></td>\
    <td id='realizadoMensal' data-mes='2'></td>\
    <td id='porcentagem' data-mes='2'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='2'></td>\
    <td id='metaMensal' data-mes='3'></td>\
    <td id='realizadoMensal' data-mes='3'></td>\
    <td id='porcentagem' data-mes='3'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='3'></td>\
    <td id='saldoPrimeiroTrimestre'></td>\
    <td id='metaMensal' data-mes='4'></td>\
    <td id='realizadoMensal' data-mes='4'></td>\
    <td id='porcentagem' data-mes='4'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='4'></td>\
    <td id='metaMensal' data-mes='5'></td>\
    <td id='realizadoMensal' data-mes='5'></td>\
    <td id='porcentagem' data-mes='5'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='5'></td>\
    <td id='metaMensal' data-mes='6'></td>\
    <td id='realizadoMensal' data-mes='6'></td>\
    <td id='porcentagem' data-mes='6'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='6'></td>\
    <td id='saldoSegundoTrimestre'></td>\
    <td id='metaMensal' data-mes='7'></td>\
    <td id='realizadoMensal' data-mes='7'></td>\
    <td id='porcentagem' data-mes='7'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='7'></td>\
    <td id='metaMensal' data-mes='8'></td>\
    <td id='realizadoMensal' data-mes='8'></td>\
    <td id='porcentagem' data-mes='8'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='8'></td>\
    <td id='metaMensal' data-mes='9'></td>\
    <td id='realizadoMensal' data-mes='9'></td>\
    <td id='porcentagem' data-mes='9'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='9'></td>\
    <td id='saldoTerceiroTrimestre'></td>\
    <td id='metaMensal' data-mes='10'></td>\
    <td id='realizadoMensal' data-mes='10'></td>\
    <td id='porcentagem' data-mes='10'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='10'></td>\
    <td id='metaMensal' data-mes='11'></td>\
    <td id='realizadoMensal' data-mes='11'></td>\
    <td id='porcentagem' data-mes='11'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='11'></td>\
    <td id='metaMensal' data-mes='12'></td>\
    <td id='realizadoMensal' data-mes='12'></td>\
    <td id='porcentagem' data-mes='12'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='12'></td>\
    <td id='saldoQuartoTrimestre'></td>\
    </tr>\
    ";
                    //ADICIONA LINHA A TABELA
                    var itemAdicionado = $(".BodyTable:last").append(linhatabela)
                    //POR ALGUM MOTIVO A VARIAVEL ANTERIOR NAO RECEBE O VALOR QUE DEVERIA, PORTANTO, CONTORNA O ERRO
                    var itemAdicionadoReal = $(itemAdicionado).find("#"+identificadorLinha+"") 
                                    
                    //PREENCHE VALORES NA LINHA ADICIONADO
                    itemData.metas.quantidadeVisitas.forEach(function(metaInternaAtual){
                        
                        //VERIFICA SE EXISTE META PRO VENDEDOR ATUAL
                        if(metaInternaAtual.hasOwnProperty('metaMes')){
                            
                            //RECUPERA O ANO SETADO
                            var anoSetado = helper.anoSetado
                            
                            //VERIFICA SE A META DA ITERACAO ATUAL PERTENCE AO ANO SETADO
                            if(metaInternaAtual.ano == anoSetado){
                                
                                //RECUPERA O MES DA META ATUAL
                                var mesMeta = metaInternaAtual.numeroMes 
                                //ACESSA A LINHA A SER INSERIDO OS DADOS
                                var meslocalizado = $(itemAdicionadoReal).find("[data-mes='" + mesMeta + "']")
                                //RECUPERA O VALOR DA META MENSAL
                                var metaMensal = Number(metaInternaAtual.metaMes)
                                //RECUPERA O VALOR REALIZADO PARA O MES ATUAL
                                var realizadoMensal = Number(metaInternaAtual.total)
                                //RECUPERA O PERCENTUAL REALIZADO PARA O MES ATUAL
                                var percentual = metaInternaAtual.percentualRealizado
                                //RECUPERA O SALDO DA META ATUAL PARA O MES ATUAL
                                var saldoMensal = Number(metaInternaAtual.saldo)
                                //DEFINE A COR DE DESTAQUE DA CELULA
                                var corDestacada = metaInternaAtual.saldo < 0 ? "red" : (metaInternaAtual.saldo > 0 ? "green" : "white")
                                var corDestacadaTexto = metaInternaAtual.saldo < 0 ? "white" : metaInternaAtual.saldo > 0 ? "white" : "black"
                                
    
                                //SETA A META MENSAL
                                $(meslocalizado[0]).html(metaMensal)
                                
                                //SETA A META MENSAL
                                $(meslocalizado[1]).html(realizadoMensal)
                                
                                //SETA A META MENSAL
                                $(meslocalizado[2]).html(percentual + "%")
                                
                                //SETA A META MENSAL
                                $(meslocalizado[3]).html(saldoMensal)
                                $(meslocalizado[3]).attr('data-saldoMensal', metaInternaAtual.saldo)
                                
                                $(meslocalizado[3]).css('background-color', corDestacada)
                                $(meslocalizado[3]).css('color', corDestacadaTexto)
                            }
                            
                            
                        }
                        
                        
                    })
                    
                    //PREENCHE AS METAS DO TRIMESTRE PARA VENDAS
                    itemData.metas.vendasTrimestreVISITAS.forEach(function(atingidoTrimestre){
                        var anoSetado = helper.anoSetado
                        
                        if(atingidoTrimestre.ano == anoSetado){
                            //se for igual ao ano setado, entao adiciona na visualizacao da linha
                            
                            if(atingidoTrimestre.numeroTrimestre == 1){
                                
                                var saldoPrimeiroTrimestre = atingidoTrimestre.saldo
                                $(itemAdicionadoReal).find('#saldoPrimeiroTrimestre').html(Number(saldoPrimeiroTrimestre).toLocaleString('pt-br',{style: 'currency', currency: 'BRL'}))
                                
                            }else if(atingidoTrimestre.numeroTrimestre == 2){
                                
                                var saldoSegundoTrimestre = atingidoTrimestre.saldo
                                $(itemAdicionadoReal).find('#saldoSegundoTrimestre').html(Number(saldoSegundoTrimestre).toLocaleString('pt-br',{style: 'currency', currency: 'BRL'}))
                                
                            }else if(atingidoTrimestre.numeroTrimestre == 3){
                                
                                var saldoTerceiroTrimestre = atingidoTrimestre.saldo
                                $(itemAdicionadoReal).find('#saldoTerceiroTrimestre').html(Number(saldoTerceiroTrimestre).toLocaleString('pt-br',{style: 'currency', currency: 'BRL'}))
                                
                            }else{
                                
                                var saldoQuartoTrimestre = atingidoTrimestre.saldo
                                $(itemAdicionadoReal).find('#saldoQuartoTrimestre').html(Number(saldoQuartoTrimestre).toLocaleString('pt-br',{style: 'currency', currency: 'BRL'}))
                            }
                        }
                    })
                    
                    //=====================================================================//
                    
                    
                    
                    
                    
                }
            
                //ADICIONA A META DE opps
                if(itemData.metas.quantidadeOpp != undefined && itemData.metas.quantidadeOpp.length > 0 && itemData.metas.quantidadeOpp.filter(v => v.metaMes != undefined && v.ano == helper.anoSetado).length != 0){
                    
                    var metaAnual = itemData.metas.metaAnualOpps
                    var identificadorLinha = "linhaTabelaOPPS"
                    
                    var atingidoAnual = itemData.metas.quantidadeOppAno.find(v => v.ano == helper.anoSetado).atingido
                    var atingidoAnualFormatado = Number(atingidoAnual)
                    
                    var linhatabela = "\
    <tr class='linhaTabela' id='"+identificadorLinha+"'>\
        <td id='tipoMeta'>OPPS CRIADAS</td>\
    <td id='metaAnual'>"+metaAnual+"</td>\
    <td id='atingidoAnual'>"+atingidoAnual+"</td>\
    <td id='metaMensal' data-mes='1'></td>\
    <td id='realizadoMensal' data-mes='1'></td>\
    <td id='porcentagem' data-mes='1'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='1'></td>\
    <td id='metaMensal' data-mes='2'></td>\
    <td id='realizadoMensal' data-mes='2'></td>\
    <td id='porcentagem' data-mes='2'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='2'></td>\
    <td id='metaMensal' data-mes='3'></td>\
    <td id='realizadoMensal' data-mes='3'></td>\
    <td id='porcentagem' data-mes='3'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='3'></td>\
    <td id='saldoPrimeiroTrimestre'></td>\
    <td id='metaMensal' data-mes='4'></td>\
    <td id='realizadoMensal' data-mes='4'></td>\
    <td id='porcentagem' data-mes='4'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='4'></td>\
    <td id='metaMensal' data-mes='5'></td>\
    <td id='realizadoMensal' data-mes='5'></td>\
    <td id='porcentagem' data-mes='5'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='5'></td>\
    <td id='metaMensal' data-mes='6'></td>\
    <td id='realizadoMensal' data-mes='6'></td>\
    <td id='porcentagem' data-mes='6'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='6'></td>\
    <td id='saldoSegundoTrimestre'></td>\
    <td id='metaMensal' data-mes='7'></td>\
    <td id='realizadoMensal' data-mes='7'></td>\
    <td id='porcentagem' data-mes='7'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='7'></td>\
    <td id='metaMensal' data-mes='8'></td>\
    <td id='realizadoMensal' data-mes='8'></td>\
    <td id='porcentagem' data-mes='8'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='8'></td>\
    <td id='metaMensal' data-mes='9'></td>\
    <td id='realizadoMensal' data-mes='9'></td>\
    <td id='porcentagem' data-mes='9'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='9'></td>\
    <td id='saldoTerceiroTrimestre'></td>\
    <td id='metaMensal' data-mes='10'></td>\
    <td id='realizadoMensal' data-mes='10'></td>\
    <td id='porcentagem' data-mes='10'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='10'></td>\
    <td id='metaMensal' data-mes='11'></td>\
    <td id='realizadoMensal' data-mes='11'></td>\
    <td id='porcentagem' data-mes='11'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='11'></td>\
    <td id='metaMensal' data-mes='12'></td>\
    <td id='realizadoMensal' data-mes='12'></td>\
    <td id='porcentagem' data-mes='12'></td>\
    <td class='saldoMensal' id='saldoMensal' data-mes='12'></td>\
    <td id='saldoQuartoTrimestre'></td>\
    </tr>\
    ";
                    //ADICIONA LINHA A TABELA
                    var itemAdicionado = $(".BodyTable:last").append(linhatabela)
                    //POR ALGUM MOTIVO A VARIAVEL ANTERIOR NAO RECEBE O VALOR QUE DEVERIA, PORTANTO, CONTORNA O ERRO
                    var itemAdicionadoReal = $(itemAdicionado).find("#"+identificadorLinha+"") 
                                    
                    //PREENCHE VALORES NA LINHA ADICIONADO
                    itemData.metas.quantidadeOpp.forEach(function(metaInternaAtual){
                        
                        //VERIFICA SE EXISTE META PRO VENDEDOR ATUAL
                        if(metaInternaAtual.hasOwnProperty('metaMes')){
                            
                            //RECUPERA O ANO SETADO
                            var anoSetado = helper.anoSetado
                            
                            //VERIFICA SE A META DA ITERACAO ATUAL PERTENCE AO ANO SETADO
                            if(metaInternaAtual.ano == anoSetado){
                                
                                //RECUPERA O MES DA META ATUAL
                                var mesMeta = metaInternaAtual.numeroMes 
                                //ACESSA A LINHA A SER INSERIDO OS DADOS
                                var meslocalizado = $(itemAdicionadoReal).find("[data-mes='" + mesMeta + "']")
                                //RECUPERA O VALOR DA META MENSAL
                                var metaMensal = Number(metaInternaAtual.metaMes)
                                //RECUPERA O VALOR REALIZADO PARA O MES ATUAL
                                var realizadoMensal = Number(metaInternaAtual.total)
                                //RECUPERA O PERCENTUAL REALIZADO PARA O MES ATUAL
                                var percentual = metaInternaAtual.percentualRealizado
                                //RECUPERA O SALDO DA META ATUAL PARA O MES ATUAL
                                var saldoMensal = Number(metaInternaAtual.saldo)
                                //DEFINE A COR DE DESTAQUE DA CELULA
                                var corDestacada = metaInternaAtual.saldo < 0 ? "red" : (metaInternaAtual.saldo > 0 ? "green" : "white")
                                var corDestacadaTexto = metaInternaAtual.saldo < 0 ? "white" : metaInternaAtual.saldo > 0 ? "white" : "black"
                                
    
                                //SETA A META MENSAL
                                $(meslocalizado[0]).html(metaMensal)
                                
                                //SETA A META MENSAL
                                $(meslocalizado[1]).html(realizadoMensal)
                                
                                //SETA A META MENSAL
                                $(meslocalizado[2]).html(percentual + "%")
                                
                                //SETA A META MENSAL
                                $(meslocalizado[3]).html(saldoMensal)
                                $(meslocalizado[3]).attr('data-saldoMensal', metaInternaAtual.saldo)
                                
                                $(meslocalizado[3]).css('background-color', corDestacada)
                                $(meslocalizado[3]).css('color', corDestacadaTexto)
                            }
                            
                            
                        }
                        
                        
                    })
                    
                    //PREENCHE AS METAS DO TRIMESTRE PARA VENDAS
                    itemData.metas.vendasTrimestreOPPS.forEach(function(atingidoTrimestre){
                        var anoSetado = helper.anoSetado
                        
                        if(atingidoTrimestre.ano == anoSetado){
                            //se for igual ao ano setado, entao adiciona na visualizacao da linha
                            
                            if(atingidoTrimestre.numeroTrimestre == 1){
                                
                                var saldoPrimeiroTrimestre = atingidoTrimestre.saldo
                                $(itemAdicionadoReal).find('#saldoPrimeiroTrimestre').html(Number(saldoPrimeiroTrimestre).toLocaleString('pt-br',{style: 'currency', currency: 'BRL'}))
                                
                            }else if(atingidoTrimestre.numeroTrimestre == 2){
                                
                                var saldoSegundoTrimestre = atingidoTrimestre.saldo
                                $(itemAdicionadoReal).find('#saldoSegundoTrimestre').html(Number(saldoSegundoTrimestre).toLocaleString('pt-br',{style: 'currency', currency: 'BRL'}))
                                
                            }else if(atingidoTrimestre.numeroTrimestre == 3){
                                
                                var saldoTerceiroTrimestre = atingidoTrimestre.saldo
                                $(itemAdicionadoReal).find('#saldoTerceiroTrimestre').html(Number(saldoTerceiroTrimestre).toLocaleString('pt-br',{style: 'currency', currency: 'BRL'}))
                                
                            }else{
                                
                                var saldoQuartoTrimestre = atingidoTrimestre.saldo
                                $(itemAdicionadoReal).find('#saldoQuartoTrimestre').html(Number(saldoQuartoTrimestre).toLocaleString('pt-br',{style: 'currency', currency: 'BRL'}))
                            }
                        }
                    })
                    
                    //=====================================================================//
                    
                    
                    
                    
                    
                }
                
                //ADICIONA A META DE DEMO
                if(itemData.metas.quantidadeDemo != undefined && itemData.metas.quantidadeDemo.length > 0 && itemData.metas.quantidadeDemo.filter(v => v.metaMes != undefined && v.ano == helper.anoSetado).length != 0){
                    
                    var metaAnual = itemData.metas.metaAnualDemo
                    var identificadorLinha = "linhaTabelaDEMO"
                    
                    var atingidoAnual = itemData.metas.quantidadeDemoAno.find(v => v.ano == helper.anoSetado).atingido
                    var atingidoAnualFormatado = Number(atingidoAnual)
                    
                    var linhatabela = "\
                    <tr class='linhaTabela' id='"+identificadorLinha+"' style='border-bottom-width: 2px; border-bottom-color: black;'>\
                        <td id='tipoMeta'>DEMOS</td>\
                    <td id='metaAnual'>"+metaAnual+"</td>\
                    <td id='atingidoAnual'>"+atingidoAnualFormatado+"</td>\
                    <td id='metaMensal' data-mes='1'></td>\
                    <td id='realizadoMensal' data-mes='1'></td>\
                    <td id='porcentagem' data-mes='1'></td>\
                    <td class='saldoMensal' id='saldoMensal' data-mes='1'></td>\
                    <td id='metaMensal' data-mes='2'></td>\
                    <td id='realizadoMensal' data-mes='2'></td>\
                    <td id='porcentagem' data-mes='2'></td>\
                    <td class='saldoMensal' id='saldoMensal' data-mes='2'></td>\
                    <td id='metaMensal' data-mes='3'></td>\
                    <td id='realizadoMensal' data-mes='3'></td>\
                    <td id='porcentagem' data-mes='3'></td>\
                    <td class='saldoMensal' id='saldoMensal' data-mes='3'></td>\
                    <td id='saldoPrimeiroTrimestre'></td>\
                    <td id='metaMensal' data-mes='4'></td>\
                    <td id='realizadoMensal' data-mes='4'></td>\
                    <td id='porcentagem' data-mes='4'></td>\
                    <td class='saldoMensal' id='saldoMensal' data-mes='4'></td>\
                    <td id='metaMensal' data-mes='5'></td>\
                    <td id='realizadoMensal' data-mes='5'></td>\
                    <td id='porcentagem' data-mes='5'></td>\
                    <td class='saldoMensal' id='saldoMensal' data-mes='5'></td>\
                    <td id='metaMensal' data-mes='6'></td>\
                    <td id='realizadoMensal' data-mes='6'></td>\
                    <td id='porcentagem' data-mes='6'></td>\
                    <td class='saldoMensal' id='saldoMensal' data-mes='6'></td>\
                    <td id='saldoSegundoTrimestre'></td>\
                    <td id='metaMensal' data-mes='7'></td>\
                    <td id='realizadoMensal' data-mes='7'></td>\
                    <td id='porcentagem' data-mes='7'></td>\
                    <td class='saldoMensal' id='saldoMensal' data-mes='7'></td>\
                    <td id='metaMensal' data-mes='8'></td>\
                    <td id='realizadoMensal' data-mes='8'></td>\
                    <td id='porcentagem' data-mes='8'></td>\
                    <td class='saldoMensal' id='saldoMensal' data-mes='8'></td>\
                    <td id='metaMensal' data-mes='9'></td>\
                    <td id='realizadoMensal' data-mes='9'></td>\
                    <td id='porcentagem' data-mes='9'></td>\
                    <td class='saldoMensal' id='saldoMensal' data-mes='9'></td>\
                    <td id='saldoTerceiroTrimestre'></td>\
                    <td id='metaMensal' data-mes='10'></td>\
                    <td id='realizadoMensal' data-mes='10'></td>\
                    <td id='porcentagem' data-mes='10'></td>\
                    <td class='saldoMensal' id='saldoMensal' data-mes='10'></td>\
                    <td id='metaMensal' data-mes='11'></td>\
                    <td id='realizadoMensal' data-mes='11'></td>\
                    <td id='porcentagem' data-mes='11'></td>\
                    <td class='saldoMensal' id='saldoMensal' data-mes='11'></td>\
                    <td id='metaMensal' data-mes='12'></td>\
                    <td id='realizadoMensal' data-mes='12'></td>\
                    <td id='porcentagem' data-mes='12'></td>\
                    <td class='saldoMensal' id='saldoMensal' data-mes='12'></td>\
                    <td id='saldoQuartoTrimestre'></td>\
                    </tr>\
                    ";
                    
                    //ADICIONA LINHA A TABELA
                    var itemAdicionado = $(".BodyTable:last").append(linhatabela)
                    //POR ALGUM MOTIVO A VARIAVEL ANTERIOR NAO RECEBE O VALOR QUE DEVERIA, PORTANTO, CONTORNA O ERRO
                    var itemAdicionadoReal = $(itemAdicionado).find("#"+identificadorLinha+"") 
                                    
                    //PREENCHE VALORES NA LINHA ADICIONADO
                    itemData.metas.quantidadeDemo.forEach(function(metaInternaAtual){
                        
                        //VERIFICA SE EXISTE META PRO VENDEDOR ATUAL
                        if(metaInternaAtual.hasOwnProperty('metaMes')){
                            
                            //RECUPERA O ANO SETADO
                            var anoSetado = helper.anoSetado
                            
                            //VERIFICA SE A META DA ITERACAO ATUAL PERTENCE AO ANO SETADO
                            if(metaInternaAtual.ano == anoSetado){
                                
                                //RECUPERA O MES DA META ATUAL
                                var mesMeta = metaInternaAtual.numeroMes 
                                //ACESSA A LINHA A SER INSERIDO OS DADOS
                                var meslocalizado = $(itemAdicionadoReal).find("[data-mes='" + mesMeta + "']")
                                //RECUPERA O VALOR DA META MENSAL
                                var metaMensal = Number(metaInternaAtual.metaMes)
                                //RECUPERA O VALOR REALIZADO PARA O MES ATUAL
                                var realizadoMensal = Number(metaInternaAtual.total)
                                //RECUPERA O PERCENTUAL REALIZADO PARA O MES ATUAL
                                var percentual = metaInternaAtual.percentualRealizado
                                //RECUPERA O SALDO DA META ATUAL PARA O MES ATUAL
                                var saldoMensal = Number(metaInternaAtual.saldo)
                                //DEFINE A COR DE DESTAQUE DA CELULA
                                var corDestacada = metaInternaAtual.saldo < 0 ? "red" : (metaInternaAtual.saldo > 0 ? "green" : "white")
                                var corDestacadaTexto = metaInternaAtual.saldo < 0 ? "white" : metaInternaAtual.saldo > 0 ? "white" : "black"
                                
    
                                //SETA A META MENSAL
                                $(meslocalizado[0]).html(metaMensal)
                                
                                //SETA A META MENSAL
                                $(meslocalizado[1]).html(realizadoMensal)
                                
                                //SETA A META MENSAL
                                $(meslocalizado[2]).html(percentual + "%")
                                
                                //SETA A META MENSAL
                                $(meslocalizado[3]).html(saldoMensal)
                                $(meslocalizado[3]).attr('data-saldoMensal', metaInternaAtual.saldo)
                                
                                $(meslocalizado[3]).css('background-color', corDestacada)
                                $(meslocalizado[3]).css('color', corDestacadaTexto)
                            }
                            
                            
                        }
                        
                        
                    })
                    
                    //PREENCHE AS METAS DO TRIMESTRE PARA VENDAS
                    itemData.metas.vendasTrimestreDEMO.forEach(function(atingidoTrimestre){
                        var anoSetado = helper.anoSetado
                        
                        if(atingidoTrimestre.ano == anoSetado){
                            //se for igual ao ano setado, entao adiciona na visualizacao da linha
                            
                            if(atingidoTrimestre.numeroTrimestre == 1){
                                
                                var saldoPrimeiroTrimestre = atingidoTrimestre.saldo
                                $(itemAdicionadoReal).find('#saldoPrimeiroTrimestre').html(Number(saldoPrimeiroTrimestre).toLocaleString('pt-br',{style: 'currency', currency: 'BRL'}))
                                
                            }else if(atingidoTrimestre.numeroTrimestre == 2){
                                
                                var saldoSegundoTrimestre = atingidoTrimestre.saldo
                                $(itemAdicionadoReal).find('#saldoSegundoTrimestre').html(Number(saldoSegundoTrimestre).toLocaleString('pt-br',{style: 'currency', currency: 'BRL'}))
                                
                            }else if(atingidoTrimestre.numeroTrimestre == 3){
                                
                                var saldoTerceiroTrimestre = atingidoTrimestre.saldo
                                $(itemAdicionadoReal).find('#saldoTerceiroTrimestre').html(Number(saldoTerceiroTrimestre).toLocaleString('pt-br',{style: 'currency', currency: 'BRL'}))
                                
                            }else{
                                
                                var saldoQuartoTrimestre = atingidoTrimestre.saldo
                                $(itemAdicionadoReal).find('#saldoQuartoTrimestre').html(Number(saldoQuartoTrimestre).toLocaleString('pt-br',{style: 'currency', currency: 'BRL'}))
                            }
                        }
                    })
                    
                    //=====================================================================//
                    
                    
                    
                    
                    
                }
                
                //ADICIONA A TAXAS DE WIN E LOSS
                if(true){
                    for (var k in itemData.winRate){
                        
                        var identificadorLinha = "linhaTabelaWINRATE" + k
                        var tituloLinha = k.replaceAll("_"," ")
                        
                        var linhatabela = "\
                            <tr class='linhaTabela' id='"+identificadorLinha+"'>\
                            <td colspan='3'>Win Rate "+tituloLinha+"</td>\
                            <td colspan='4' data-mes='1'>WIN JAN</td>\
                            <td colspan='4' data-mes='2'></td>\
                            <td colspan='4' data-mes='3'></td>\
                            <td></td>\
                            <td colspan='4' data-mes='4'></td>\
                            <td colspan='4' data-mes='5'></td>\
                            <td colspan='4' data-mes='6'></td>\
                            <td></td>\
                            <td colspan='4' data-mes='7'></td>\
                            <td colspan='4' data-mes='8'></td>\
                            <td colspan='4' data-mes='9'></td>\
                            <td></td>\
                            <td colspan='4' data-mes='10'></td>\
                            <td colspan='4' data-mes='11'></td>\
                            <td colspan='4' data-mes='12'></td>\
                            <td></td>\
                            </tr>\
                            ";
                        
                        //ADICIONA LINHA A TABELA
                        var itemAdicionado = $(".BodyTable:last").append(linhatabela)
                        
                        //POR ALGUM MOTIVO A VARIAVEL ANTERIOR NAO RECEBE O VALOR QUE DEVERIA, PORTANTO, CONTORNA O ERRO
                        var itemAdicionadoReal = $(itemAdicionado).find("#"+identificadorLinha+"")
                        
                        //PREENCHE VALORES NA LINHA ADICIONADO
                        itemData.winRate[k].forEach(function(metaInternaAtual){
                            
                            //RECUPERA O ANO SETADO
                            var anoSetado = helper.anoSetado
                            
                            
                            //VERIFICA SE A META DA ITERACAO ATUAL PERTENCE AO ANO SETADO
                            if(metaInternaAtual.ano == anoSetado){
                                
                                //RECUPERA O MES DA META ATUAL
                                var mesMeta = metaInternaAtual.numeroMes
                                
                                //ACESSA A LINHA A SER INSERIDO OS DADOS
                                var meslocalizado = $(itemAdicionadoReal).find("[data-mes='" + mesMeta + "']")
                                
                                var winMensal = Number(metaInternaAtual.winRate).toFixed(2)
                                
                                //DEFINE A COR DE DESTAQUE DA CELULA
                                var corDestacada = metaInternaAtual.saldo < 0 ? "red" : "green"
                                
                                //DEFINE A COR DE DESTAQUE DO TEXTO DA CELULA
                                var corDestacadaTexto = metaInternaAtual.saldo < 0 ? "white" : "black"
                                
                                
                                //SETA A META MENSAL
                                $(meslocalizado).html(winMensal + "%")
                                
                            }
                            
                            
                        })
                    }
                }
                //FIM DA TAXA DE WIN/LOSS
            }
        })
        
        helper.eventsAfterAdd(cmp, event, helper);
        
    },  
        
    //EVENTOS AFTER ADICAO
    eventsAfterAdd : function(cmp, event, helper){
        //CLIQUE NO POPUP
        $(".item").off("click");
        $(".item").on('click',function(){
            helper.popupOpen(cmp, event, helper, this)
        })
        
        //APLICA ESTILO EM TODAS OS SELECTS
        $('.selectpicker').selectpicker({
            dropupAuto: false            
        });
        
        //EVENTO DO CHANGE DOS FILTROS DO ANO
        $('#selectAno').on('changed.bs.select', function (e) {   
            helper.anoSetado = $('#selectAno').val();
            helper.preencheVisualização(cmp, event, helper);
        });
        
        $('#selectTipo').on('changed.bs.select', function (e) {
            switch($('#selectTipo').val()){
                case 'vendedor':
                    $('div:has(> #selectVendedor)').show();
					$('div:has(> #selectLinha)').hide();
					$('div:has(> #selectDepartamento)').hide();
                    break;
                case 'linha':
                    $('div:has(> #selectVendedor)').hide();
					$('div:has(> #selectLinha)').show();
					$('div:has(> #selectDepartamento)').hide();
                    break;
                case 'departamento':
                    $('div:has(> #selectVendedor)').hide();
					$('div:has(> #selectLinha)').hide();
					$('div:has(> #selectDepartamento)').show();
                    break;
                default:
                    $('div:has(> #selectVendedor)').hide();
					$('div:has(> #selectLinha)').hide();
					$('div:has(> #selectDepartamento)').hide();
                    
            }
           
        });
        
        //CHANGE DO FILTRO DO VENDEDOR
        $('#selectVendedor').on('changed.bs.select', function (e) {
            
            if($('#selectVendedor').val() == ''){
                helper.dataProcessed = JSON.parse(JSON.stringify(helper.data));
	            helper.preencheVisualização(cmp, event, helper);
                return;
            }
            
            $("#selectVendedor").selectpicker('close')
            
            $("#selectLinha").val("default");
            $("#selectLinha").selectpicker('destroy')
            $("#selectLinha").selectpicker()

            $("#selectDepartamento").val("default");
            $("#selectDepartamento").selectpicker('destroy')
            $("#selectDepartamento").selectpicker()
            
            helper.dataProcessed = JSON.parse(JSON.stringify(helper.data)).filter(e => e.idVendedor == $('#selectVendedor').val());
            helper.preencheVisualização(cmp, event, helper);
        });
        
        //CHANGE DO FILTRO DA LINHA
        $('#selectLinha').on('changed.bs.select', function (e) {
            if($('#selectLinha').val() == ''){
                helper.dataProcessed = JSON.parse(JSON.stringify(helper.data));
	            helper.preencheVisualização(cmp, event, helper);
                return;
            }
            
            $("#selectVendedor").val("default");
            $("#selectVendedor").selectpicker('destroy')
            $("#selectVendedor").selectpicker()

            $("#selectDepartamento").val("default");
            $("#selectDepartamento").selectpicker('destroy')
            $("#selectDepartamento").selectpicker()

			helper.dataProcessed = JSON.parse(JSON.stringify(helper.data));
			helper.dataProcessed.forEach(v => {
	            helper.deleteFromObject($('#selectLinha').val(), v.metas);
            });
            
            if($('#selectLinha').val() == 'cmiImagemLaparo' || $('#selectLinha').val() == 'cmiUroGineco'){
                helper.dataProcessed = helper.dataProcessed.map(v => (($('#selectLinha').val() == 'cmiImagemLaparo' && v.familia.find(v => v == 'CIRURGIA MINIMAMENTE INVASIVA;IMAGEM;LAPAROSCOPIA') != undefined) || ($('#selectLinha').val() == 'cmiUroGineco' && v.familia.find(v => v == 'GINECOLOGIA;UROLOGIA') != undefined) ? v : undefined)).filter(v => v != undefined);
            } else if($('#selectLinha').val() == 'ultrassomPoc' || $('#selectLinha').val() == 'ultrassomFixo') {
                helper.dataProcessed = helper.dataProcessed.map(v => (($('#selectLinha').val() == 'ultrassomPoc' && v.familia.find(v => v == 'ULTRASSOM POC' ) != undefined) || ($('#selectLinha').val() == 'ultrassomFixo' && v.familia.find(v => v == 'ULTRASSOM FIXO') != undefined)) ? v : undefined).filter(v => v != undefined);                
            } else {
	            helper.dataProcessed = helper.dataProcessed.map(v => (v.linha.find(v => v.toLowerCase().includes($('#selectLinha').val().toLowerCase())) != undefined) ? v : undefined).filter(v => v != undefined);                                                         
            }
                 
            console.log(helper.dataProcessed)
            helper.preencheVisualização(cmp, event, helper);
        });
                
        //CHANGE DO FILTRO DO DEPARTAMENTO
        $('#selectDepartamento').on('changed.bs.select', function (e) {
            if($('#selectDepartamento').val() == ''){
                helper.dataProcessed = JSON.parse(JSON.stringify(helper.data));
	            helper.preencheVisualização(cmp, event, helper);
                return;
            }
                
            $("#selectVendedor").val("default");
            $("#selectVendedor").selectpicker('destroy')
            $("#selectVendedor").selectpicker()

            $("#selectLinha").val("default");
            $("#selectLinha").selectpicker('destroy')
            $("#selectLinha").selectpicker()

            helper.dataProcessed = JSON.parse(JSON.stringify(helper.data)).map(v => {
                if(v.departamento != undefined && v.departamento.includes($('#selectDepartamento').val())) return v;
            }).filter(v => v != undefined);
            helper.preencheVisualização(cmp, event, helper);
        });                
        helper.hideSpinner(cmp)
        
    },
    
    //popup container de graficos
    popupOpen : function(cmp, event, helper, elemento){
        
        var tamanhoAberto = '500'
        var tamanhoFechado = '0'
        
        const tamanhoAtual = $(elemento).parent().find('#container-graficos').height()
        
        if(tamanhoAtual == tamanhoFechado){
            $(elemento).parent().find('#container-graficos').css("height", (tamanhoAberto + 'px'));
            $(elemento).parent().css("padding-bottom", "260px")
        }else{
            $(elemento).parent().find('#container-graficos').css("height", (tamanhoFechado + 'px'));
            $(elemento).parent().css("padding-bottom", "0px")
        }
        
    },
        
    deleteFromObject: function(keyPart, obj){
    	for (var k in obj){
        	//if(!(~k.indexOf(keyPart)) && !(~k.indexOf(keyPart.toUpperCase()))){ 
            if(!(k.toLowerCase().includes(keyPart.toLowerCase()))){
            	delete obj[k];
        	}
    	}
	},
                
    calcYear : function(cmp, event, helper){
        helper.data.map(value => {
    
            value.metas.vendasAno = [];
            value.metas.cmiImagemLaparoAno = [];
            value.metas.cmiUroGinecoAno = [];
            value.metas.eletrocirurgiaAno = [];
            value.metas.locacaoAno = [];
            value.metas.pmlsAno = [];
            value.metas.surgicalAno = [];
            value.metas.ultrassomAno = [];
            value.metas.ultrassomPOCAno = [];
            value.metas.ultrassomFIXOAno = [];
            value.metas.outrosAno = [];
            value.metas.quantidadeDemoAno = [];
            value.metas.quantidadeOppAno = [];
            value.metas.quantidadeVisitasAno = [];
    
            for(let ano = 2021 ; ano <= 2024 ; ano++){
    
                value.metas.vendasAno.push({ano, meta: 0, atingido: 0});
                value.metas.cmiImagemLaparoAno.push({ano, meta: 0, atingido: 0});
        		value.metas.cmiUroGinecoAno.push({ano, meta: 0, atingido: 0});
                value.metas.eletrocirurgiaAno.push({ano, meta: 0, atingido: 0});
                value.metas.locacaoAno.push({ano, meta: 0, atingido: 0});
                value.metas.pmlsAno.push({ano, meta: 0, atingido: 0});
                value.metas.surgicalAno.push({ano, meta: 0, atingido: 0});
                value.metas.ultrassomAno.push({ano, meta: 0, atingido: 0});
        		value.metas.ultrassomPOCAno.push({ano, meta: 0, atingido: 0});
        		value.metas.ultrassomFIXOAno.push({ano, meta: 0, atingido: 0});
        		value.metas.outrosAno.push({ano, meta: 0, atingido: 0});
                value.metas.quantidadeDemoAno.push({ano, meta: 0, atingido: 0});
                value.metas.quantidadeOppAno.push({ano, meta: 0, atingido: 0});
                value.metas.quantidadeVisitasAno.push({ano, meta: 0, atingido: 0});
    
                value.metas.vendas.filter(v => v.ano == ano).map(v => {
                    const meta = v.metaMes == undefined ? 0 : v.metaMes;
                    const total = v.total == undefined ? 0 : v.total;
                    const vendasAno = value.metas.vendasAno.find(v => v.ano == ano)
                    vendasAno.meta += meta;
                    vendasAno.atingido += total;
                });
    
                value.metas.cmiImagemLaparo.filter(v => v.ano == ano).map(v => {
                    const meta = v.metaMes == undefined ? 0 : v.metaMes;
                    const total = v.total == undefined ? 0 : v.total;
                    const cmiImagemLaparoAno = value.metas.cmiImagemLaparoAno.find(v => v.ano == ano)
                    cmiImagemLaparoAno.meta += meta;
                    cmiImagemLaparoAno.atingido += total;
                });
                
                value.metas.cmiUroGineco.filter(v => v.ano == ano).map(v => {
                    const meta = v.metaMes == undefined ? 0 : v.metaMes;
                    const total = v.total == undefined ? 0 : v.total;
                    const cmiUroGinecoAno = value.metas.cmiUroGinecoAno.find(v => v.ano == ano)
                    cmiUroGinecoAno.meta += meta;
                    cmiUroGinecoAno.atingido += total;
                });
    
                value.metas.eletrocirurgia.filter(v => v.ano == ano).map(v => {
                    const meta = v.metaMes == undefined ? 0 : v.metaMes;
                    const total = v.total == undefined ? 0 : v.total;
                    const eletrocirurgiaAno = value.metas.eletrocirurgiaAno.find(v => v.ano == ano)
                    eletrocirurgiaAno.meta += meta;
                    eletrocirurgiaAno.atingido += total;
                });

        		value.metas.locacao.filter(v => v.ano == ano).map(v => {
                    const meta = v.metaMes == undefined ? 0 : v.metaMes;
                    const total = v.total == undefined ? 0 : v.total;
                    const locacaoAno = value.metas.locacaoAno.find(v => v.ano == ano)
                    locacaoAno.meta += meta;
                    locacaoAno.atingido += total;
                });
        
                value.metas.pmls.filter(v => v.ano == ano).map(v => {
                    const meta = v.metaMes == undefined ? 0 : v.metaMes;
                    const total = v.total == undefined ? 0 : v.total;
                    const pmlsAno = value.metas.pmlsAno.find(v => v.ano == ano)
                    pmlsAno.meta += meta;
                    pmlsAno.atingido += total;
                });
    
                value.metas.surgical.filter(v => v.ano == ano).map(v => {
                    const meta = v.metaMes == undefined ? 0 : v.metaMes;
                    const total = v.total == undefined ? 0 : v.total;
                    const surgicalAno = value.metas.surgicalAno.find(v => v.ano == ano)
                    surgicalAno.meta += meta;
                    surgicalAno.atingido += total;
                });
    
                value.metas.ultrassom.filter(v => v.ano == ano).map(v => {
                    const meta = v.metaMes == undefined ? 0 : v.metaMes;
                    const total = v.total == undefined ? 0 : v.total;
                    const ultrassomAno = value.metas.ultrassomAno.find(v => v.ano == ano)
                    ultrassomAno.meta += meta;
                    ultrassomAno.atingido += total;
                });
        
                value.metas.ultrassomPoc.filter(v => v.ano == ano).map(v => {
                    const meta = v.metaMes == undefined ? 0 : v.metaMes;
                    const total = v.total == undefined ? 0 : v.total;
                    const ultrassomPOCAno = value.metas.ultrassomPOCAno.find(v => v.ano == ano)
                    ultrassomPOCAno.meta += meta;
                    ultrassomPOCAno.atingido += total;
                });
        		
                value.metas.ultrassomFixo.filter(v => v.ano == ano).map(v => {
                    const meta = v.metaMes == undefined ? 0 : v.metaMes;
                    const total = v.total == undefined ? 0 : v.total;
                    const ultrassomFIXOAno = value.metas.ultrassomFIXOAno.find(v => v.ano == ano)
                    ultrassomFIXOAno.meta += meta;
                    ultrassomFIXOAno.atingido += total;
                });
        
                value.metas.outros.filter(v => v.ano == ano).map(v => {
                    const meta = v.metaMes == undefined ? 0 : v.metaMes;
                    const total = v.total == undefined ? 0 : v.total;
                    const outrosAno = value.metas.outrosAno.find(v => v.ano == ano)
                    outrosAno.meta += meta;
                    outrosAno.atingido += total;
                });
    
                value.metas.quantidadeDemo.filter(v => v.ano == ano).map(v => {
                    const meta = v.metaMes == undefined ? 0 : v.metaMes;
                    const total = v.total == undefined ? 0 : v.total;
                    const quantidadeDemoAno = value.metas.quantidadeDemoAno.find(v => v.ano == ano)
                    quantidadeDemoAno.meta += meta;
                    quantidadeDemoAno.atingido += total;
                });
    
                value.metas.quantidadeOpp.filter(v => v.ano == ano).map(v => {
                    const meta = v.metaMes == undefined ? 0 : v.metaMes;
                    const total = v.total == undefined ? 0 : v.total;
                    const quantidadeOppAno = value.metas.quantidadeOppAno.find(v => v.ano == ano)
                    quantidadeOppAno.meta += meta;
                    quantidadeOppAno.atingido += total;
                });
    
                value.metas.quantidadeVisitas.filter(v => v.ano == ano).map(v => {
                    const meta = v.metaMes == undefined ? 0 : v.metaMes;
                    const total = v.total == undefined ? 0 : v.total;
                    const quantidadeVisitasAno = value.metas.quantidadeVisitasAno.find(v => v.ano == ano)
                    quantidadeVisitasAno.meta += meta;
                    quantidadeVisitasAno.atingido += total;
                });
            }
        });
        helper.preencheMetaVendas(cmp, event, helper);
    },

    
})