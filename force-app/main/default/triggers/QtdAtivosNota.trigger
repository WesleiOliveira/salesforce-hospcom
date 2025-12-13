trigger QtdAtivosNota on Asset (after insert, after update, after delete) {
    Id FaturamentoId = null;
    
    if((Trigger.isInsert)&&(Trigger.new[0].Faturamento__c != null))
        FaturamentoId = Trigger.new[0].Faturamento__c;
    else if((Trigger.isDelete)&&(Trigger.old[0].Faturamento__c != null))
        FaturamentoId = Trigger.old[0].Faturamento__c;
    else if((Trigger.isUpdate)&&(Trigger.old[0].Faturamento__c == null) && (Trigger.new[0].Faturamento__c != null))
        FaturamentoId = Trigger.new[0].Faturamento__c;
    else if((Trigger.isUpdate)&&(Trigger.old[0].Faturamento__c != null) && (Trigger.new[0].Faturamento__c == null))
        FaturamentoId = Trigger.old[0].Faturamento__c;        
        
    if(FaturamentoId != null){
        Faturamento__c faturamento = new Faturamento__c();
        faturamento = [
            SELECT 	Id, Qtd_Ativos__c
            FROM 	Faturamento__c
            WHERE	Id = :FaturamentoId
        ];
        
		List<Asset> ativos = new List<Asset>();
        ativos = [
            SELECT	Id
            FROM	Asset
            WHERE	Faturamento__c = :FaturamentoId
        ];
        
        faturamento.Qtd_Ativos__c = ativos.size();
        update faturamento;

    }    
}