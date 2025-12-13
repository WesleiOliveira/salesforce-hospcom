trigger OportunidadeValidacao on Opportunity (before insert) {
    public datetime horasmais4;
    public datetime horasmenos4;
    // ignorar erros
    if(!Util.IgnorarErros()){
        
        for(Opportunity oportunidade : Trigger.new){
          if(oportunidade.RecordTypeId == '0126e000001lAu7'){
           horasmais4 = oportunidade.Data_e_hora_do_procedimento__c.addHours(4);
           horasmenos4 = oportunidade.Data_e_hora_do_procedimento__c.addHours(-4);
            
                if(oportunidade.Instrumentador__c != null){
                       List <Event> compromissos = [SELECT ID, OwnerID, StartDateTime FROM Event WHERE OwnerID =: oportunidade.Instrumentador__c AND StartDateTime >= : oportunidade.Data_e_hora_do_procedimento__c AND StartDateTime <= : horasmais4];
                            if(compromissos.size() > 0)
                                oportunidade.Instrumentador__c.addError('Este usuário já possui compromissos para o horário informado ou para um período próximo em 4 horas');
                    }
                if(oportunidade.Instrumentador_2__c != null){
                       List <Event> compromissos = [SELECT ID, OwnerID, StartDateTime FROM Event WHERE OwnerID =: oportunidade.Instrumentador_2__c AND StartDateTime >= : oportunidade.Data_e_hora_do_procedimento__c AND StartDateTime <= : horasmais4];
                            if(compromissos.size() > 0)
                                oportunidade.Instrumentador_2__c.addError('Este usuário já possui compromissos para o horário informado ou para um período próximo em 4 horas');
                    }
                if(oportunidade.Instrumentador_3__c != null){
                       List <Event> compromissos = [SELECT ID, OwnerID, StartDateTime FROM Event WHERE OwnerID =: oportunidade.Instrumentador_3__c AND StartDateTime >= : oportunidade.Data_e_hora_do_procedimento__c AND StartDateTime <= : horasmais4];
                            if(compromissos.size() > 0)
                                oportunidade.Instrumentador_3__c.addError('Este usuário já possui compromissos para o horário informado ou para um período próximo em 4 horas');
                    }
            }
        }
    }
    
}