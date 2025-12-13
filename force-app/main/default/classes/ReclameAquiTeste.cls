@isTest
public class ReclameAquiTeste { 
	
    static testMethod void ReclameAquiTesteGeral(){ 
        test.startTest(); 
        
		PageReference pagina = Page.ReclameAqui;
        Test.setCurrentPage(pagina);

        ReclameAqui controlador = new ReclameAqui();
        controlador.Nome = 'Douglas';
        controlador.Empresa = 'hospcom';
        controlador.Email = 'doug@doug.com';
        controlador.Telefone = '(14) 3322-5656';
        controlador.Assunto = 'Teste';
        controlador.Categoria = 'Produto';
        
        controlador.Salvar();
        
		test.stopTest();
    }
}