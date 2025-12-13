@RestResource(urlMapping='/sensors')
global class Sensores{
@HttpPost
    global static void doPost() {
        // Obtém os dados da requisição
        String requestBody = RestContext.request.requestBody.toString();
        
        system.debug(requestBody);
       
        string temperatura = requestBody.substringAfter('"Temperatura__c":"').substringBefore('","Umidade__c"');
        
		Decimal temperatura2 = Decimal.valueOf(temperatura);

        string umidade = requestBody.substringAfter('"Umidade__c":"').substringBefore('","Endereco');
        
        Decimal umidade2 = Decimal.valueOf(umidade);
        
        string endereco = requestBody.substringAfter('"Endereco_Mac__c":"').substringBefore('"');
        
        Medida_de_Temperatura_e_Umidade__c medida = new Medida_de_Temperatura_e_Umidade__c(
            													Endereco_Mac__c = endereco,
        														Temperatura__c	= temperatura2,
            													Umidade__c = umidade2);
        try{
            insert medida;
        }
        catch(DMLException e){
            
        }
    }
}