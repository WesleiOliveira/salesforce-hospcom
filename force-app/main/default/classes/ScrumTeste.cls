@isTest(seeAllData=true)
private class ScrumTeste {
	
	// OrdemDeTrabalho
    @isTest static void Teste1(){         
		Scrum quadro = new Scrum();
        
        quadro.string_list = 'a1a5A00000JyIAi';
        quadro.string_spri = 'a1a5A00000JyI96';
        quadro.string_exec = 'a1a5A00000FkGaw'; 
        quadro.string_para = 'a1a5A00000JyI9B'; 
        quadro.string_conc = 'a1a5A00000JyI9G'; 
        quadro.AtualizaCartaoColuna();
        
        quadro.atividade_id = 'a1a5A00000JyIOp';
        quadro.BuscaCartao();
        quadro.atividade_id = 'a1a5A00000JyIOp';
        quadro.AtualizaCartao();
		
        quadro.atividade_id = 'a1a5A00000JyIOp';
        quadro.ExibirPessoas();
		
        quadro.atividade_id = 'a1a5A00000JyIOp';
        quadro.string_in = '00531000007hy0G';
        quadro.AtualizaPessoas();
		
        quadro.atividade_id = 'a1a5A00000JyIOp';
        quadro.BuscaCartao();
        quadro.DeletaCartao();
        
		quadro.atividade.Name = 'teste';
		quadro.atividade.Coluna__c = 'Sprint';
		quadro.InsereCartao();
		
		
		
        quadro.departamento_f = 'Governo';
        quadro.BuscaCartoes();
		
		
    }
 	
}