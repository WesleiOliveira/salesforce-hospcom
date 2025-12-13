@isTest(seeAllData=true)
private class ListagemFiltradaTeste {
	
    @isTest static void ListagemFiltradaTeste1(){
		
		ListagemPedidosVenda listagem_venda = new ListagemPedidosVenda();
		listagem_venda.PaginaSeguinte();
		listagem_venda.c_paginacao.registro_pagina = 25;
		listagem_venda.PaginaAnterior();
	}	
	
}