public class FatuLinkContrClass {
    
    public static Void FluxoInicial(Faturamento__c faturamento){
        if(faturamento.Oportunidade__c != null){
            Opportunity oportunidade = new Opportunity();
            oportunidade = ObtemOpp(faturamento.Oportunidade__c);
            if(oportunidade.Contrato_de_Servico__c != null){
                faturamento.Contrato_de_Servi_o__c = oportunidade.Contrato_de_Servico__c;
            }
        }
        else{
            faturamento.Contrato_de_Servi_o__c = null;
        }
    }
    
    public static Opportunity ObtemOpp(Id oportunidade_id){
    	Opportunity oportunidade = new Opportunity();
        oportunidade = [
            SELECT	Id, Contrato_de_servico__c
            FROM 	Opportunity
            WHERE	Id = :oportunidade_id
        ];
        return oportunidade;
    }
    
}