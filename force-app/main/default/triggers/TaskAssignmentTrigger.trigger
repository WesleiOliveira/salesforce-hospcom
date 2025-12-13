trigger TaskAssignmentTrigger on Task (before insert, before update) {
    if (Trigger.size == 0) return;
    TaskAssignmentService.validateHolidays(Trigger.new);
}