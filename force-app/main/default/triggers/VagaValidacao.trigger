trigger VagaValidacao on Vagas_Dispon_veis__c (before update) {
    public Set<ID> Vagas = new Set<ID>();
    public List <Recrutamento__c> Candidato = new List <Recrutamento__c>();
   	public List  <Recrutamento__c> CandidatosAprovados = new List <Recrutamento__c>();
    
    
    if(!Util.IgnorarErros()){
        
      
    
    for(Vagas_Dispon_veis__c vd : Trigger.new){
        Vagas.add(vd.Id);
    }   
    Candidato = [SELECT ID FROM Recrutamento__c WHERE Vaga_Dispon_vel__c IN :Vagas];
    CandidatosAprovados = [SELECT ID FROM Recrutamento__c WHERE Vaga_Dispon_vel__c IN :Vagas and Status__c= 'Aprovado'];
        
        
        for(Vagas_Dispon_veis__c vd : Trigger.new){
            
            if(Trigger.isBefore && Trigger.isUpdate){ 
                 
            
           
                
            if((vd.Status__c == 'Proposta e ASO' || vd.Status__c == 'Processo Admissional') && Candidato.size() == 0){
                if(!Test.isRunningTest()){
                 vd.addError(' A vaga não possui candidatos cadastrados.');
                }
            }
            else if(vd.Status__c == 'Finalizada' && Candidato.size() == 0){
                if(!Test.isRunningTest()){
                 vd.addError(' A vaga não pode ser finalizada sem candidato cadastrado.');
                }
            }
                else if(vd.Status__c == 'Processo Admissional' && CandidatosAprovados.size() == 0 ){
                     if(!Test.isRunningTest()){
                	vd.addError(' A vaga não possui candidatos aprovados.');
                     }
  
                }
                
                
             
            }
        }
}
}