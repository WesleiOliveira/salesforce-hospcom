@IsTest
public class TaskControllerTest {

    private static Task createTask(Id ownerId) {
        Task task = new Task(
            OwnerId = ownerId,
            Subject = 'Test Task',
            Data_interna__c = Date.today()
        );
        insert task;
        return task;
    }

    @IsTest
    static void testGetTaskDetails() {
        
        Task task = createTask('005i0000000ImUn');

            Map<String, Object> result = TaskController.getTaskDetails(task.Id);
            
            Task returnedTask = (Task)result.get('task');
            Boolean canEdit = (Boolean)result.get('canEdit');
    }

    @IsTest
    static void testUpdateTaskInternalDate() {
        
        Task task = createTask('005i0000000ImUn');

        Date newDate = Date.today().addDays(5);

            TaskController.updateTaskInternalDate(task.Id, newDate);
            
            Task updatedTask = [SELECT Id, Data_interna__c FROM Task WHERE Id = :task.Id];
          
        }
    }