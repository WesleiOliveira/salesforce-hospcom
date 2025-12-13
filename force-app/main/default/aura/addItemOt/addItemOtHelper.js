({
	helperMethod : function(cmp, event, helper) {
		
        $("#button234234234").on( "click", function() {
            $("#principalDiv324234234").css("display", "flex")
        });
    },
    
    
    buscaItems : function(cmp, event, helper) {
        console.log("BUSCA ITEM")
        var termo = cmp.get("v.searchTerm")
        
        var query = "SELECT Id, Name, UnitPrice, Product2Id, ProductCode, Modelo__c " +
            "FROM PricebookEntry " +
            "WHERE CurrencyIsoCode = 'BRL' " +
            "AND Pricebook2Id = '01s31000003wrkA' " +
            "AND (ProductCode LIKE '%" + termo + "%' OR Name LIKE '%" + termo + "%' OR Modelo__c LIKE '%" + termo + "%') " +
            "LIMIT 10";
        
        console.log(query)
        
        //REALIZA A CONSULTA
        helper.soql(cmp, query)
        
        //QUANDO A SOLICITAÇÃO FOR CONCLUÍDA, FAÇA:
        .then(function (menus) {
            
            var maxLength = 30;
            
            menus.forEach(function (item) {
                if (item.Modelo__c && item.Modelo__c.length > maxLength) {
                    item.Modelo__c = item.Modelo__c.substring(0, maxLength) + "...";
                }
                
                if (item.UnitPrice) {
                    item.UnitPrice = new Intl.NumberFormat("pt-BR", {
                        style: "currency",
                        currency: "BRL"
                    }).format(item.UnitPrice);
                }
            });
            
            $("#resultados4239584").css("display", "flex")
            cmp.set("v.workOrderLineItems", menus);
            
            $(".item48359345").on( "click", function() {
                var id = $(this).attr("data-id")
                var recordId = cmp.get("v.recordId");

                console.log("CLIQUE ADD", id)
                
                var createRecordEvent = $A.get("e.force:createRecord");
                createRecordEvent.setParams({
                    "entityApiName": "WorkOrderLineItem",
                    "defaultFieldValues": {
                        'PricebookEntryId' : id,
                        'WorkOrderId' : recordId
                    }
                });
                createRecordEvent.fire();
            });
        })
        
        //trata excessão de erro
        .catch(function (error) {
            console.log(error)
        })
        
    }
})