({
    setForecastValue: function (cmp, event, helper) {
    var recordId = cmp.get("v.recordId");

    // REALIZA A CONSULTA NO EVENTO__C PARA BUSCAR O CAMPO FORECAST__C
    helper.soql(cmp, "SELECT FORECAST__c FROM Campaign WHERE Id = '" + recordId + "'")
        .then(function (resultado) {
            console.log("Resultado da busca Forecast: ", resultado);

            if (resultado.length > 0) {
                var forecastValue = resultado[0].FORECAST__c;
                
                // Definir o valor no componente
                cmp.set("v.isForecast", forecastValue);

                if (forecastValue) {
                    console.log("Forecast é verdadeiro");
                } else {
                    console.log("Forecast é falso");
                }
            } else {
                console.log("Nenhum resultado encontrado.");
                cmp.set("v.isForecast", false);
            }
        })
        .catch(function (error) {
            console.log("Erro ao buscar var: ", error);
            cmp.set("v.isForecast", false);
        });
    },

    helperMethod : function(cmp, event, helper) {
    console.log('funcao');

    var recordId = cmp.get('v.recordId');
    var userId = $A.get("$SObjectType.CurrentUser.Id");
    var contactId;
    
    console.log('User ID: ' + userId);

    if(userId != '2F00531000006UzZsAAK' && userId != '005i0000005d2fFAAQ' && userId != '00531000007i4eWAAQ' && userId != '0055A000008onb4QAA' && userId != '005i0000000ImClAAK' && userId != '005i0000000J08eAAC' && userId != '005i0000000JFXuAAO' && userId != '005i0000000ImUnAAK ' && userId != '00531000006UzZsAAK'){

    //REALIZA A CONSULTA
    this.soql(cmp, "select Contato__c from Membro_Interno_do_Evento__c where Evento__c = '" + recordId + "'")

    //QUANDO A SOLICITAÇÃO FOR CONCLUÍDA, FAÇA:
    .then(function (contas) {
        console.log(contas);
        
        var query = "select ContactId from User where Id = '" + userId + "'";
        
        console.log(query);
        helper.soql(cmp, query)
        
        //QUANDO A SOLICITAÇÃO FOR CONCLUÍDA, FAÇA:
        .then(function (usuario) {
            console.log('busca de contato ' + usuario[0].ContactId);
            contactId = usuario[0].ContactId;
            
            // Verificar se o userId está contido nos resultados
            var userFound = contas.some(function(conta) {
                return conta.Contato__c == contactId;
            });
            
            if(userFound) {
                console.log('User ID found in contas');
            } else {
                console.log('User ID not found in contas');
            }
            
            // Definir o atributo booleano no componente
            cmp.set("v.isUserInContas", userFound);
        })
        .catch(function (error) {
            console.log(error);
            // Em caso de erro, defina o valor como false
            cmp.set("v.isUserInContas", false);
        });
    })

    //trata excessão de erro
    .catch(function (error) {
        console.log(error);
        // Em caso de erro, defina o valor como false
        cmp.set("v.isUserInContas", false);
    });
    }
    else{
    cmp.set("v.isUserInContas", true);
    }
    }
    })