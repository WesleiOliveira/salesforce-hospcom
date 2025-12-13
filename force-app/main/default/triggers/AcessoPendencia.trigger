trigger AcessoPendencia on Pendencia__c (after insert) {
	
    for(Pendencia__c pendencia: Trigger.new){
            Pendencia__Share ps = new Pendencia__Share();
                    ps.ParentId = pendencia.id;
                    ps.AccessLevel = 'Edit';
                    ps.UserOrGroupId = pendencia.Responsavel__r.id;
                try{
                    insert ps;
                    }
                catch(DmlException e){}
      }
}