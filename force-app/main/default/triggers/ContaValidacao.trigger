trigger ContaValidacao on Account (before insert, before update) {
    
    // ignorar erros
    if(!Util.IgnorarErros()){
        
        String resultado = null;
        
        for(Account conta : Trigger.new){
            
            // cnpj
            if((resultado = Util.ValidarCNPJ(conta.CNPJ__c)) != null)
                conta.CNPJ__c.addError(resultado);
        
        }
    }
}