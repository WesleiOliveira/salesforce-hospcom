trigger AccountTrigger on Account (before insert, before update, after insert, after update) {

    if(Trigger.isBefore){
        if(Trigger.isInsert){
            AccountTriggerHandler.validacoesConta(Trigger.new);
            AccountTriggerHandler.preencheCampoLead(Trigger.new);
        } else if(Trigger.isUpdate){
            //AccountTriggerHandler.validacoesConta(Trigger.new);
            AccountTriggerHandler.preencheCampoLead(Trigger.new);
        }
    }

    if(Trigger.isAfter){
        if(Trigger.isInsert){
             AccountTriggerHandler.validaDadosReceita(Trigger.new, Trigger.oldMap);
        }else if(Trigger.isUpdate){
            AccountTriggerHandler.validaDadosReceita(Trigger.new, Trigger.oldMap);
        }
    }
}