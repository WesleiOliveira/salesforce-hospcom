({
    createRecord : function (component, event, helper) {
        // Obter a data atual
        var today = new Date();
        var today = new Date();
        var currentMonth = today.getMonth(); // getMonth() retorna o mês de 0 a 11
        var lastMonth;
        
        // Se for janeiro (mês 0), definir mês passado como dezembro (mês 11) do ano anterior
        if (currentMonth === 0) {
            lastMonth = 11;
        } else {
            lastMonth = currentMonth - 1;
        }
        var currentYear = today.getFullYear();
        
        // Mapear o mês numérico para o nome do mês
        var monthNames = [
            "janeiro", "fevereiro", "março", "abril", "maio", "junho",
            "julho", "agosto", "setembro", "outubro", "novembro", "dezembro"
        ];
        var currentMonthName = monthNames[lastMonth]; // getMonth() retorna de 0 a 11
        
        // Preparar os valores padrão dos campos
        var defaultFieldValues = {
            'Name' : currentMonthName + '/' + currentYear,
            'Mes__c' : currentMonthName,
            'Ano__c' : currentYear
        };
        
        // Criar o evento de criação de registro
        var createRecordEvent = $A.get("e.force:createRecord");
        createRecordEvent.setParams({
            "entityApiName": "Indice_de_Atualizacao_Monetaria__c",
            "defaultFieldValues": defaultFieldValues
        });
        createRecordEvent.fire();
    }
})