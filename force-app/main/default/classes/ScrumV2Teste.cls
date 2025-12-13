@isTest(seeAllData=true)
private class ScrumV2Teste {
	
    @isTest static void Teste1(){    
	
		ScrumV2 scrum = new ScrumV2();
		scrum.filtro.usuario = null;
		scrum.filtro_anterior.usuario = '00531000006UzZs';
		scrum.Pesquisa();
		
		scrum.view.coluna = 'Concluído';
		scrum.Avanca();
		scrum.view.coluna = 'Concluído';
		scrum.Volta();
		
		scrum.view.atividade.Id = 'a1a5A00000LPxtZ';
		scrum.view.coluna = 'Concluído';
		scrum.Arrastar();
		
		scrum.view.atividade.Id = 'a1a5A00000LPxtZ';
		scrum.buscar();
		scrum.alterar();
		
		scrum.Limpar();
		scrum.view.coluna= 'Concluído';
		scrum.view.usuario= '00531000006UzZs';
		scrum.view.pessoas = '0055A000008puvc';
		scrum.Inserir();
		
    }
 	
}