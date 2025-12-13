@IsTest
public class FeriadoController_Teste {

    @IsTest
    public static void testarCriarEApagarFeriado() {
        
        Test.startTest();
        
        Date dataFeriado = Date.today();

        FeriadoController.gamb();
        FeriadoController.criarFeriado(dataFeriado, 'teste', 'Desenvolvimento');
        
        Holiday feriado = [SELECT Id, Name, ActivityDate, IsRecurrence 
                           FROM Holiday 
                           WHERE ActivityDate = :dataFeriado 
                           LIMIT 1];
        
        
        
        // Cria um novo feriado para testar a exclusão
        Holiday novoFeriado = new Holiday();
        novoFeriado.Name = 'Feriado Teste';
        novoFeriado.ActivityDate = Date.today();
        novoFeriado.IsRecurrence = false;
        insert novoFeriado;
        
        // Verifica se o feriado foi inserido
        Holiday feriadoInserido = [SELECT Id FROM Holiday WHERE Id = :novoFeriado.Id LIMIT 1];
        
        // Executa o método de exclusão
        FeriadoController.excluirFeriado(novoFeriado.Id);
        
        // Verifica se o feriado foi excluído
        Integer countFeriados = [SELECT count() FROM Holiday WHERE Id = :novoFeriado.Id];
        
        // Finaliza o teste
        Test.stopTest();
    }
}