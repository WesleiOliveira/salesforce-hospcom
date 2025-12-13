public class RecebimentoCascata {
	
	public static Faturamento__c		faturamento_new;
	public static List<Recebimentos__c>	recebimentos_new;
	public static Faturamento__c		faturamento_old;
	public static List<Recebimentos__c>	recebimentos_old;
    
	// métodos externos -------------------------------------------------------------------
	
	public static Void ValorRecebido(Recebimentos__c recebimento, String registro){
		if(registro == 'new'){
			if(faturamento_new==null)
				ObtemFaturamentoNew(recebimento.NF_Representacao__c);
			if(recebimentos_new==null)
				ObtemRecebimentosNew(recebimento.NF_Representacao__c);
			faturamento_new.Total_recebido_parceiro__c = 0;
			for(Recebimentos__c recebimento_temp : recebimentos_new)
				faturamento_new.Total_recebido_parceiro__c += recebimento_temp.Valor_Recebido__c;			
		}
		else if(registro == 'old'){
			if(faturamento_old==null)
				ObtemFaturamentoOld(recebimento.NF_Representacao__c);
			if(recebimentos_old==null)
				ObtemRecebimentosOld(recebimento.NF_Representacao__c);
			faturamento_old.Total_recebido_parceiro__c = 0;
			for(Recebimentos__c recebimento_temp : recebimentos_old)
				faturamento_old.Total_recebido_parceiro__c += recebimento_temp.Valor_Recebido__c;			
		}
	}

	public static Void ValorComissao(Recebimentos__c recebimento, String registro){
		if(registro == 'new'){
			if(faturamento_new==null)
				ObtemFaturamentoNew(recebimento.NF_Representacao__c);
			if(recebimentos_new==null)
				ObtemRecebimentosNew(recebimento.NF_Representacao__c);
			faturamento_new.Total_comiss_o__c = 0;
			for(Recebimentos__c recebimento_temp : recebimentos_new)
				faturamento_new.Total_comiss_o__c += recebimento_temp.Valor_Comissao__c;			
		}
		else if(registro == 'old'){
			if(faturamento_old==null)
				ObtemFaturamentoOld(recebimento.NF_Representacao__c);
			if(recebimentos_old==null)
				ObtemRecebimentosOld(recebimento.NF_Representacao__c);
			faturamento_old.Total_comiss_o__c = 0;
			for(Recebimentos__c recebimento_temp : recebimentos_old)
				if(recebimento_temp.Valor_Comissao__c != null)
                	faturamento_old.Total_comiss_o__c += recebimento_temp.Valor_Comissao__c;			
		}
	}

	public static Void Efetivar(){
		if(faturamento_new!=null)
			update faturamento_new;
		if(faturamento_old!=null)
			update faturamento_old;
	}
	
	// métodos internos -------------------------------------------------------------------
	
    static Void ObtemFaturamentoNew(Id faturamento_id){
		faturamento_new = new Faturamento__c();
        faturamento_new = [
            SELECT	Id, Total_recebido_parceiro__c, Total_comiss_o__c
            FROM 	Faturamento__c
            WHERE	Id = :faturamento_id
        ][0];
	}
    
    static Void ObtemRecebimentosNew(Id faturamento_id){
		recebimentos_new = new List<Recebimentos__c>();
        recebimentos_new = [
            SELECT	Valor_Recebido__c, Valor_Comissao__c
            FROM 	Recebimentos__c
            WHERE	NF_Representacao__c = :faturamento_id
        ];
	}
    
    static Void ObtemFaturamentoOld(Id faturamento_id){
		faturamento_old = new Faturamento__c();
        faturamento_old = [
            SELECT	Id, Total_recebido_parceiro__c, Total_comiss_o__c
            FROM 	Faturamento__c
            WHERE	Id = :faturamento_id
        ][0];
	}
    
    static Void ObtemRecebimentosOld(Id faturamento_id){
		recebimentos_old = new List<Recebimentos__c>();
        recebimentos_old = [
            SELECT	Valor_Recebido__c, Valor_Comissao__c
            FROM 	Recebimentos__c
            WHERE	NF_Representacao__c = :faturamento_id
        ];
	}
    
}