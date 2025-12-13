public with sharing class TaskAssignmentService {

    private static final String GLOBAL_DESC = 'TODOS';

    public static void validateHolidays(List<Task> tasks){
        if (tasks == null || tasks.isEmpty()) return;

        // Coletar OwnerIds que são usuários (evita tentar buscar Queue)
        Set<Id> ownerUserIds = new Set<Id>();
        for (Task t : tasks) {
            if (t.OwnerId != null && String.valueOf(t.OwnerId).startsWith('005')) {
                ownerUserIds.add(t.OwnerId);
            }
        }

        // Mapear usuário -> departamento
        Map<Id, String> userDeptById = new Map<Id, String>();
        if (!ownerUserIds.isEmpty()) {
            for (User u : [
                SELECT Id, Departamento3__c
                FROM User
                WHERE Id IN :ownerUserIds
            ]) {
                userDeptById.put(u.Id, u.Departamento3__c);
            }
        }

        // Conjunto de descrições de feriado que precisamos: 'TODOS' + departamentos envolvidos
        Set<String> holidayDescriptions = new Set<String>{ GLOBAL_DESC };
        for (String dept : userDeptById.values()) {
            if (dept != null) holidayDescriptions.add(dept);
        }

        // Se não houver nada para procurar, encerra
        if (holidayDescriptions.isEmpty()) return;

        // Buscar feriados relevantes em uma única query
        Set<Date> globalHolidayDates = new Set<Date>();
        Map<String, Set<Date>> deptHolidayDates = new Map<String, Set<Date>>();

        for (Holiday h : [
            SELECT ActivityDate, Description
            FROM Holiday
            WHERE Description IN :holidayDescriptions
        ]) {
            if (h.Description == GLOBAL_DESC) {
                globalHolidayDates.add(h.ActivityDate);
            } else {
                if (!deptHolidayDates.containsKey(h.Description)) {
                    deptHolidayDates.put(h.Description, new Set<Date>());
                }
                deptHolidayDates.get(h.Description).add(h.ActivityDate);
            }
        }

        // Validação por tarefa (sem DML, apenas addError)
        for (Task t : tasks) {
            // Se não há data, não há o que checar
            if (t.ActivityDate == null) continue;

            // Feriado global
            if (globalHolidayDates.contains(t.ActivityDate)) {
                t.addError('Não é possível atribuir esta tarefa para ninguém, pois coincide com um feriado global.');
                continue; // já bloqueou, não precisa checar depto
            }

            // Feriado departamental (somente se o owner é usuário e tem depto)
            String dept = userDeptById.get(t.OwnerId);
            if (dept != null) {
                Set<Date> deptDates = deptHolidayDates.get(dept);
                if (deptDates != null && deptDates.contains(t.ActivityDate)) {
                    t.addError('O departamento do usuário atribuído tem um feriado neste dia. Atribuição não permitida.');
                }
            }
        }
    }
}