({
    mainHelper : function(cmp, event, helper) {
        console.log("RUN HELPER")
        
        var query = "SELECT Quantidade_destinada_Exibir__c, QuantidadeExibir__c, Quantidade_destinada__c,  Item_de_pedido_de_compra__r.Produto__c, Quantidade_disponivel__c, Item_de_pedido_de_compra__r.Quantidade_disponivel_a_receber__c, Item_de_pedido_de_compra__r.Quantidade_Destinada__c, Item_de_pedido_de_compra__r.Quantidade_requisitada__c, Name, id, Fornecedor__c, Fornecedor__r.Name, Fornecedor__r.Prazo_de_recebimento__c, Fornecedor__r.Nova_Data_de_Entrega__c, Quantidade__c, Produto__c FROM Item_de_fornecedor__c WHERE  (Fornecedor__r.Status_do_PC__c != 'Cancelado') AND (status__c NOT IN ('Novo', 'Cancelado', 'Recebido Total') OR status__c = 'CMP - AG. ENTREGA FORNECEDOR') AND Quantidade_disponivel__c > 0 AND  status__c != '' LIMIT 10"
        
        console.log(query)
        //REALIZA A CONSULTA
        this.soql(cmp, query)
        
        //QUANDO A SOLICITAÇÃO FOR CONCLUÍDA, FAÇA:
        .then(function (itens) {
            console.log("ITENS 1", itens)
            
            var query = "SELECT StockKeepingUnit, Name, ID_do_Produto__c, URL_da_Imagem__c, Modelo__c, Total_aguardando_entrega_transicional__c	, Valor_Total__c, Description, ProductCode, Marca__c, Estoque_disponivel__c  FROM Product2 WHERE IsActive = true ORDER BY Estoque_disponivel__c DESC NULLS LAST, LastModifiedDate DESC LIMIT 10"
            
            console.log(query)
            //REALIZA A CONSULTA
            helper.soql(cmp, query)
            
            //QUANDO A SOLICITAÇÃO FOR CONCLUÍDA, FAÇA:
            .then(function (itens2) {
                console.log("ITENS 2", itens2)
            })
            
            //trata excessão de erro
            .catch(function (error) {
                console.log(error)
            })
        })
        
        //trata excessão de erro
        .catch(function (error) {
            console.log(error)
        })
    }
})