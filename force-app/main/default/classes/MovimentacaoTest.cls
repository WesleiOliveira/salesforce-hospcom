@isTest
public class MovimentacaoTest {

    // Método de teste
    @isTest
    static void nomeDoMetodoDeTeste() {
       
        // Atualize os registros com o status 'Registrado'
        Movimentacao_de_Pessoas__c movsToUpdate = new Movimentacao_de_Pessoas__c(id = 'a1E6e00000G23gQEAR');
        movsToUpdate.Status__c = 'Registrado';

        update movsToUpdate;
    }
}