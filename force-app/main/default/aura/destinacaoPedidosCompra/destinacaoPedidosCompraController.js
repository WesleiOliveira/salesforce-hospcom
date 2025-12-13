({
    
    //FUNÇÃO EXECUTADA APÓS O TÉRMINO DA RENDERIZAÇAO DO COMPONENTE-----------------------------------------------------------
    onRender : function(cmp,event, helper){
                        
        //CHAMA A FUNÇÃO QUE PREENCHE A COLUNA DA ESQUERDA COM OS PEDIDOS DE VENDA E ITENS DISPONÍVEIS PARA COMPRA
        helper.auxiliarPreenchePedidos(cmp, event, helper)
        //-------------------------------------------------------------------------
        
        helper.exibePlataformaMkt(cmp, event, helper)
        
    },
})