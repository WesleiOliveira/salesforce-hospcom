trigger CompromissoValidacao on Event (before insert) {
    public List<Event> compromissos   {get;set;}
    public ID proprietario         {get;set;}
    public DateTime datahora       {get;set;}
    
    for(event compromisso : Trigger.new){
        proprietario = compromisso.OwnerID;
        datahora = compromisso.StartDateTime;
    }
    
    compromissos = [SELECT ID, OwnerID, StartDateTime FROM Event WHERE OwnerID =: proprietario AND StartDateTime =: datahora];
    
      if(compromissos.size() > 0){
              for(event compromisso : Trigger.new){
                  //if(compromisso.ownerid != '0056e00000CpHcX');
                  if(compromisso.ownerid != '0055A000008onb4'){
          compromisso.StartDateTime.addError('Já existe um compromisso para este usuário neste horário');
                  }
          }
    }
    else{
        string doNothing = '';
    }
        
}