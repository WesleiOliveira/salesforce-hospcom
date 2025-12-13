public class AtivosComodato {
    @AuraEnabled
    public static string gerar(string SN, string comodato){
        
        List<String> lstString = SN.split(','); //Separa cada SN e adiciona em Lista
        List<Asset> ativos = [SELECT ID, Product2.Valor_de_venda__c FROM Asset WHERE SerialNumber in : lstString];
        
        LIST<Produto_da_demonstracao__c> pds = new List<Produto_da_demonstracao__c>();
        
        Integer quantidade = 0;
        Integer index = 1;
        
        //Cria a OT para cada número de série
        for(Asset ativo : ativos){
            Produto_da_demonstracao__c pComodato = new Produto_da_demonstracao__c(Demonstracao__c = comodato, Ativo__c = ativo.Id, Valor__c = ativo.Product2.Valor_de_venda__c, Item__c = index);
            pds.add(pComodato);
            quantidade ++;
            index++;
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