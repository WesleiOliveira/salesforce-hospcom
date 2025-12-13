@isTest(SeeAllData=true)
public class TaskAssignmentTest {

    @isTest
    static void testTaskAssignmentGlobalHoliday() {
        // Usando o ID fixo de usuário para o teste
        Id testUserId = '005i0000000ImUn';

        // Criando tarefa com data de término no dia do feriado global (02/10/2024)
        Task task = new Task();
        task.Subject = 'Teste de Feriado Global';
        task.OwnerId = testUserId;
        task.ActivityDate = Date.newInstance(2024, 10, 2); // Data do feriado global
        task.Status = 'Não iniciado';
        task.Priority = 'Normal';
        
        Test.startTest();
        try {
            insert task;
        }catch(Exception e){
            System.debug('Error: ' + e);
        }
        Test.stopTest();
    }

    @isTest
    static void testTaskAssignmentDepartmentHoliday() {
        // Usando o ID fixo de usuário para o teste
        Id testUserId = '005i0000000ImUn';

        // Criando tarefa com data de término no dia do feriado departamental (03/10/2024)
        Task task = new Task();
        task.Subject = 'Teste de Feriado Departamental';
        task.OwnerId = testUserId;
        task.ActivityDate = Date.newInstance(2024, 10, 3); // Data do feriado departamental

        task.Status = 'Não iniciado';
        task.Priority = 'Normal';
        
        Test.startTest();
        try {   
            
            insert task;
         
        }catch(Exception e){
            System.debug('Error: ' + e);
        }
        Test.stopTest();
    }

    @isTest
    static void testTaskAssignmentNoHoliday() {
        // Usando o ID fixo de usuário para o teste
        Id testUserId = '005i0000000ImUn';

        // Criando tarefa em uma data sem feriado (04/10/2024)
        Task task = new Task();
        task.Subject = 'Teste sem Feriado';
        task.OwnerId = testUserId;
        task.ActivityDate = Date.newInstance(2024, 10, 4); // Data sem feriado
        task.Status = 'Não iniciado';
        task.Priority = 'Normal';
        
        Test.startTest();
        insert task;
        Test.stopTest();

    }
}