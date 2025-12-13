({
    init : function(component, event, helper) {
        
        component.set('v.columns', [
            {label: 'Código do Produto', fieldName: 'ProductCode', type: 'text', sortable: false},
            {label: 'Nome', fieldName: 'Name', type: 'text',sortable: false},
            {label: 'Marca', fieldName: 'Marca__c', type: 'text',sortable: false},
            {label: 'Custo (Tabela)', fieldName: 'Custo_Tabela__c', type: 'text',sortable: false},
            {label: 'Estoque Mínimo', fieldName: 'Estoque_minimo__c', type: 'text'},
            {label: 'Qtd Estoque', fieldName: 'Estoque_disponivel__c', type: 'text'},
            {label: 'Em recebimento', fieldName: 'Aguardando_recebimento__c', type: 'text'},
            {label: 'Média de saídas em 6 meses', fieldName: 'Media_de_saida_em_6_meses__c', type: 'text'},
            {label: 'Média de saídas em 12 meses', fieldName: 'Media_de_saida_em_12_meses__c', type: 'text'},
            {label: 'Vendidos e não entregues', fieldName: 'Vendido_e_nao_entregue__c', type: 'text'},
            {label: 'Qtd bonificada', fieldName: 'Quantidade_bonificada__c', type: 'text'},
            {label: 'Qtd em negociação', fieldName: 'Quantidade_em_negocacao_OT__c', type: 'text'},
            {label: 'Sugestão de compra', fieldName: 'Compra_sugerida__c', type: 'text'}
        ]);
        
        var query = "SELECT Id, Name, Compra_sugerida__c, Marca__c, Custo_Tabela__c, Custo_Negociado__c, Quantidade_em_negocacao_OT__c, ProductCode, Quantidade_bonificada__c, Media_de_saida_em_6_meses__c, Media_de_saida_em_12_meses__c, Estoque_minimo__c, Estoque_disponivel__c, Aguardando_recebimento__c, Vendido_e_nao_entregue__c, Saidas_em_6_meses__c, Saidas_em_12_meses__c FROM Product2 WHERE Product2.Tipo_do_Produto__c = 'PEÇA' AND IsActive = true AND (Saidas_em_6_meses__c > 0 OR Saidas_em_12_meses__c > 0 OR Estoque_disponivel__c > 0 OR Aguardando_recebimento__c > 0 OR Quantidade_em_negocacao_OT__c > 0) ORDER BY Name"
        
        console.log("QUERY", query)
        
        //REALIZA A CONSULTA
        helper.soql(component, query)
        
        //QUANDO A SOLICITAÇÃO FOR CONCLUÍDA, FAÇA:
        .then(function (produtos) {
            var marcas = [];
            
            component.set("v.data", produtos);
            
            produtos.forEach(produto => {
                marcas.indexOf(produto.Marca__c) === -1 ? marcas.push(produto.Marca__c) : console.log("This item already exists");
                
            });
            marcas.sort();
            component.set("v.nomeMarcas", marcas);
            
        })
        
        
        //trata excessão de erro
        .catch(function (error) {
            console.log(error)
        })
    },
    
    handleSort : function(component, event, helper) {
        
        alert("Teste");
        
        var sortedBy = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');
        
        var cloneData = this.produtos.slice(0);
        cloneData.sort((this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1)));
        
        component.set('v.data', cloneData);
        
        component.set('v.sortDirection', sortDirection);
        component.set('v.sortedBy', sortedBy);
    },
    
    atualizaConsulta : function(component, event, helper) {
        var selectedItem = event.getSource().get("v.value");
        
        console.log('valor ' + selectedItem);
        
        var query = "SELECT Id, Name, Marca__c, Compra_sugerida__c, Custo_Tabela__c, Custo_Negociado__c, Quantidade_em_negocacao_OT__c, ProductCode, Quantidade_bonificada__c, Media_de_saida_em_6_meses__c, Media_de_saida_em_12_meses__c, Estoque_minimo__c, Estoque_disponivel__c, Aguardando_recebimento__c, Vendido_e_nao_entregue__c, Saidas_em_6_meses__c, Saidas_em_12_meses__c FROM Product2 WHERE Product2.Tipo_do_Produto__c = 'PEÇA' AND IsActive = true AND (Saidas_em_6_meses__c > 0 OR Saidas_em_12_meses__c > 0 OR Estoque_disponivel__c > 0 OR Aguardando_recebimento__c > 0) AND Marca__c = '"+ selectedItem +"' ORDER BY Name"
        
        console.log("QUERY", query)
        
        //REALIZA A CONSULTA
        helper.soql(component, query)
        
        //QUANDO A SOLICITAÇÃO FOR CONCLUÍDA, FAÇA:
        .then(function (produtos) {
            var marcas = [];
            
            component.set("v.data", produtos);
            
            
        })
        
        
        //trata excessão de erro
        .catch(function (error) {
            console.log(error)
        })
        
    }
    
})