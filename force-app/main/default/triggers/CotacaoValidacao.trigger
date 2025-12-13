trigger CotacaoValidacao on Quote (before insert, before update, before delete) {
  
  // ignorar erros
  if(!Util.IgnorarErros()){
    
    if(Trigger.isInsert || Trigger.isUpdate){
      List<Opportunity> oportunidades;
      if(Trigger.isInsert){
        List<id> oportunidades_id = new List<Id>();
        for(Quote cotacao : Trigger.new)
          oportunidades_id.add(cotacao.OpportunityId);
        oportunidades = [
          SELECT   Id,(
                SELECT  Id, Product2.StockKeepingUnit
                FROM  OpportunityLineItems
                WHERE  PriceBookEntry.isActive = false OR Product2.isActive = false
              )
          FROM  Opportunity
          WHERE  Id IN :oportunidades_id
        ];
      }
      
      for(Quote cotacao : Trigger.new){
        
        // prazo de garantia
        if(cotacao.Prazo_de_garantia__c != null){
          Pattern mypattern = Pattern.compile('^([^0-9]+) ([0-9]+) (mês|meses)$');
          for(String garantia : cotacao.Prazo_de_garantia__c.toLowerCase().split('\\,')){
            Matcher mymatcher = mypattern.matcher(garantia.normalizeSpace());
            mymatcher.find();
            if(!mymatcher.matches())
              cotacao.Prazo_de_garantia__c.addError('O prazo de garantia deve ter o formato TIPO_DO_ITEM XX MÊS(ES)');
            //else if(Integer.valueOf(mymatcher.group(2)) < 0 || Integer.valueOf(mymatcher.group(2)) > 36)
            //  cotacao.Prazo_de_garantia__c.addError('O prazo de garantia deve ser no máximo 36 meses');
          }
        }       
          if(cotacao.Prazo_de_garantia_dos_equipamentos__c != null){
					Matcher correspondencia = Pattern.compile('^([0-9]+) (mês|meses)$')
						.matcher(cotacao.Prazo_de_garantia_dos_equipamentos__c.toLowerCase());
					if(!correspondencia.matches())
						cotacao.Prazo_de_garantia_dos_equipamentos__c.addError('O tempo de garantia deve ter o formato XX mês(es)');
				}
          if(cotacao.Prazo_de_garantia_acessorios__c != null){
					Matcher correspondencia = Pattern.compile('^([0-9]+) (mês|meses)$')
						.matcher(cotacao.Prazo_de_garantia_acessorios__c.toLowerCase());
					if(!correspondencia.matches())
						cotacao.Prazo_de_garantia_acessorios__c.addError('O tempo de garantia deve ter o formato XX mês(es)');
				}	
        
        // prazo de entrega (pedido)
        if(cotacao.Prazo_de_Entrega__c != null){
          Matcher correspondencia = Pattern.compile('^([0-9]+) (dia|dias|mês|meses)$')
            .matcher(cotacao.Prazo_de_Entrega__c.toLowerCase());
            
          if(!correspondencia.matches())
            cotacao.Prazo_de_Entrega__c.addError('O prazo de entrega deve ter o formato XX DIA(S)/MÊS(ES)');
          else if(Integer.valueOf(correspondencia.group(1)) < 1)
            cotacao.Prazo_de_Entrega__c.addError('O prazo de entrega deve ter valor positivo');
          else if((new List<String>{'dia','dias'}).contains(correspondencia.group(2)) && Integer.valueOf(correspondencia.group(1)) > 180)
            cotacao.Prazo_de_Entrega__c.addError('O prazo de entrega em dias deve ser no máximo 180');
          else if((new List<String>{'mês','meses'}).contains(correspondencia.group(2)) && Integer.valueOf(correspondencia.group(1)) > 6)
            cotacao.Prazo_de_Entrega__c.addError('O prazo de entrega em meses deve ser no máximo 6');
        }
          
        
        // produto inativo
        if(Trigger.isInsert){
          for(Opportunity oportunidade : oportunidades){
            if(cotacao.OpportunityId == oportunidade.Id && oportunidade.OpportunityLineItems.size()>0){
              List<String> desativados = new List<String>();
              for(OpportunityLineItem item_opp : oportunidade.OpportunityLineItems)
                desativados.add(item_opp.Product2.StockKeepingUnit);
              cotacao.addError('A oportunidade possui produtos desativados, substitua-os antes de criar a cotação: ' + String.join(desativados, ', ') +'.');
            }
          }
        }
        
      }
    }else if(Trigger.isDelete){
      List<Id> cotacoes_id = new List<Id>();
      for(Quote cotacao : Trigger.old){
        cotacoes_id.add(cotacao.Id);
      }
      List<Quote> cotacoes = [
        SELECT   Id, (
              SELECT  Id
              FROM  Orders
            )
        FROM   Quote 
        WHERE   Id IN :cotacoes_id
      ];
      for(Quote cotacao_trg : Trigger.old){
        for(Quote cotacao_sql : cotacoes){
          if((cotacao_trg.Id == cotacao_sql.Id) && (cotacao_sql.Orders.size() > 0)){
            cotacao_trg.addError('Não é possível excluir uma cotação com pedidos vinculados.');
          }
        }
      }      
    }
  }
}