@isTest(seeAllData=true)
public class CotacaoBotoesTest {
    
@isTest private static void run(){
        CotacaoBotoes.ValidarPreenchimento('0Q05A000002K66i');
    	CotacaoBotoes.SalvarPdfProposta('0Q05A000002K66i');
    	CotacaoBotoes.SalvarPdfCotacao('0Q05A000002K66i');
    	CotacaoBotoes.VerificarLicitacao('0Q05A000002Kfjh');
    }
}