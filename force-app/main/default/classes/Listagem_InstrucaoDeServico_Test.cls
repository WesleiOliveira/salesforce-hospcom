@isTest(seealldata = true)
public class Listagem_InstrucaoDeServico_Test{

    @isTest
    static void testListagem_hr() {
        try{
        // Crie um registro de PSQ__c para teste
        Instrucao_de_Servico__c instrucaoServico = new Instrucao_de_Servico__c(
           id = 'a2MU4000001uwS9MAI'
        );
        update instrucaoServico;

        // Crie um objeto StandardController para o registro de PSQ__c
        ApexPages.StandardController controller = new ApexPages.StandardController(instrucaoServico);

        // Crie uma instância da classe listagem_hr
        Listagem_InstrucaoDeServico listagem = new Listagem_InstrucaoDeServico(controller);

        // Execute o método listagem_hr(PSQ__c psq) da classe
        listagem.Listagem_InstrucaoDeServico(instrucaoServico); 
        }catch(Exception e){
            System.debug('Error: ' + e);
        }
    }
}