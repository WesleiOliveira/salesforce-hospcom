@isTest(SeeAllData=true)
public class ListagemFornecedores_Test {
    @isTest
    static void testListagemFornecedores() {
        // Consulta a conta de teste
        try{
            Account contaTeste = [
                SELECT Id, Name 
                FROM Account
                WHERE Id = '001i00000085QYbAAM'
            ];
            
        System.debug('Conta: ' + contaTeste);
        ApexPages.StandardController controller = new ApexPages.StandardController(contaTeste);
        ListagemFornecedoresDeUmComprador controllerInstance = new ListagemFornecedoresDeUmComprador(controller);
        controllerInstance.listagemFornecedores(contaTeste);
            
        }catch(Exception e){
           System.debug('Error: ' + e );
        }
    }
}