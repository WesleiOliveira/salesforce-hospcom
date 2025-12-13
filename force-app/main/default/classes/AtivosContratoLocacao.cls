public class AtivosContratoLocacao {
    @AuraEnabled
    public static string gerar(string SN, string contrato, decimal valor, integer quantidadeAtivo, string data, string local){
        
        List<String> lstString = SN.split(','); //Separa cada SN e adiciona em Lista
        List<Asset> ativos = [SELECT ID, Product2.Valor_de_venda__c FROM Asset WHERE SerialNumber in : lstString AND SerialNumber != ''];
        
        // Consultar o valor máximo de Item_do_Contrato__c
        AggregateResult result = [SELECT MAX(Item_do_Contrato__c) maxItem FROM Ativos_do_Contrato__c WHERE Contrato_de_Servico__c = :contrato];
        
        Integer maxItemContrato;
        if (result != null && result.get('maxItem') != null) {
            maxItemContrato = ((Decimal)result.get('maxItem')).intValue();
        }
        else{
            maxItemContrato = 0;
        }
        
        // Agora maxItemContrato contém o valor máximo de Item_do_Contrato__c
        System.debug('Máximo Item do Contrato: ' + maxItemContrato);        
        LIST<Ativos_do_Contrato__c> pds = new List<Ativos_do_Contrato__c>();
        
        Integer quantidade = 0;
        
        date dataEntrega;
        
        if(data != '')
            dataEntrega = Date.valueOf(data);
        else
            dataEntrega = null;
        
        //Cria a OT para cada número de série
        for(Asset ativo : ativos){
            Ativos_do_Contrato__c pContrato = new Ativos_do_Contrato__c(Contrato_de_Servico__c = contrato, Ativo_Locado__c = ativo.Id, Valor_Unitario_Mensal__c = valor, 
                                                                        Item_do_Contrato__c = maxItemContrato, Quantidade__c = 1, Data_de_entrega__c = dataEntrega, Local_de_Entrega__c = local);
            pds.add(pContrato);
            quantidade ++;
            maxItemContrato++;
        }
        try{
			insert pds;            
            return('Foram inseridos ' + quantidade + ' ativos com sucesso.');
        }
        catch(Exception e){
            return(e.getMessage());
        }
    }
}