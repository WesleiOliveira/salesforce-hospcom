trigger CloneCL on Asset (after insert) {
        Set<ID> prodIdSet = Trigger.newMap.keySet();
		List <Checklist_do_Ativo__c> checkList  = new List <Checklist_do_Ativo__c>();
    
        for (Asset a : Trigger.new) {        
            if(a.isClone()){
          	List <Checklist_do_Ativo__c> px = [select Ativo_Relacionado__c, Nome_do_Item__c, Quantidade__c FROM Checklist_do_Ativo__c WHERE Ativo_Relacionado__c =: a.getCloneSourceId()];
               integer count = [select count() FROM Checklist_do_Ativo__c WHERE Ativo_Relacionado__c =: a.getCloneSourceId()]; 
                               
                if (count >= 1){
                    
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[0].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[0].Quantidade__c));
                               
                if (count == 2){
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[1].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[1].Quantidade__c));
                }
                else if(count == 3){
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[1].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[1].Quantidade__c));
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[2].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[2].Quantidade__c));
                }
				else if(count == 4){
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[1].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[1].Quantidade__c));
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[2].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[2].Quantidade__c));
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[3].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[3].Quantidade__c));
                }
                    else if(count == 5){
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[1].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[1].Quantidade__c));
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[2].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[2].Quantidade__c));
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[3].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[3].Quantidade__c));
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[4].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[4].Quantidade__c));
                    }
                    else if(count == 6){
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[1].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[1].Quantidade__c));
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[2].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[2].Quantidade__c));
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[3].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[3].Quantidade__c));
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[4].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[4].Quantidade__c));
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[5].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[5].Quantidade__c));
                    }
                    else if(count == 7){
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[1].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[1].Quantidade__c));
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[2].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[2].Quantidade__c));
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[3].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[3].Quantidade__c));
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[4].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[4].Quantidade__c));
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[5].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[5].Quantidade__c));
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[6].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[6].Quantidade__c)); 
                    }
                    else if(count == 8){
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[1].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[1].Quantidade__c));
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[2].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[2].Quantidade__c));
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[3].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[3].Quantidade__c));
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[4].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[4].Quantidade__c));
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[5].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[5].Quantidade__c));
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[6].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[6].Quantidade__c));
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[7].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[7].Quantidade__c));               
                    
                    }
                    else if(count == 9){
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[1].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[1].Quantidade__c));
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[2].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[2].Quantidade__c));
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[3].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[3].Quantidade__c));
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[4].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[4].Quantidade__c));
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[5].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[5].Quantidade__c));
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[6].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[6].Quantidade__c));
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[7].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[7].Quantidade__c));
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[8].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[8].Quantidade__c));            
                    }
                    else if(count == 10){
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[1].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[1].Quantidade__c));
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[2].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[2].Quantidade__c));
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[3].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[3].Quantidade__c));
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[4].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[4].Quantidade__c));
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[5].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[5].Quantidade__c));
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[6].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[6].Quantidade__c));
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[7].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[7].Quantidade__c));
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[8].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[8].Quantidade__c));            
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[9].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[9].Quantidade__c));            
                    }
                    else if(count == 11){
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[1].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[1].Quantidade__c));
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[2].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[2].Quantidade__c));
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[3].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[3].Quantidade__c));
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[4].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[4].Quantidade__c));
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[5].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[5].Quantidade__c));
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[6].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[6].Quantidade__c));
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[7].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[7].Quantidade__c));
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[8].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[8].Quantidade__c));            
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[9].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[9].Quantidade__c));            
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[10].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[10].Quantidade__c));            
                    }
                    else if(count == 12){
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[1].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[1].Quantidade__c));
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[2].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[2].Quantidade__c));
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[3].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[3].Quantidade__c));
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[4].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[4].Quantidade__c));
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[5].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[5].Quantidade__c));
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[6].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[6].Quantidade__c));
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[7].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[7].Quantidade__c));
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[8].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[8].Quantidade__c));            
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[9].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[9].Quantidade__c));            
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[10].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[10].Quantidade__c));            
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[11].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[11].Quantidade__c));            
                    }
                    else if(count == 13){
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[1].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[1].Quantidade__c));
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[2].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[2].Quantidade__c));
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[3].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[3].Quantidade__c));
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[4].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[4].Quantidade__c));
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[5].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[5].Quantidade__c));
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[6].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[6].Quantidade__c));
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[7].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[7].Quantidade__c));
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[8].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[8].Quantidade__c));            
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[9].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[9].Quantidade__c));            
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[10].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[10].Quantidade__c));            
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[11].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[11].Quantidade__c));            
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[12].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[12].Quantidade__c));            
                    }
                    else if(count == 14){
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[1].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[1].Quantidade__c));
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[2].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[2].Quantidade__c));
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[3].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[3].Quantidade__c));
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[4].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[4].Quantidade__c));
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[5].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[5].Quantidade__c));
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[6].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[6].Quantidade__c));
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[7].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[7].Quantidade__c));
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[8].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[8].Quantidade__c));            
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[9].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[9].Quantidade__c));            
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[10].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[10].Quantidade__c));            
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[11].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[11].Quantidade__c));            
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[12].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[12].Quantidade__c));            
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[13].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[13].Quantidade__c));            
                    }
                    else if(count == 15){
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[1].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[1].Quantidade__c));
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[2].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[2].Quantidade__c));
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[3].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[3].Quantidade__c));
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[4].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[4].Quantidade__c));
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[5].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[5].Quantidade__c));
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[6].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[6].Quantidade__c));
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[7].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[7].Quantidade__c));
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[8].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[8].Quantidade__c));            
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[9].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[9].Quantidade__c));            
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[10].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[10].Quantidade__c));            
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[11].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[11].Quantidade__c));            
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[12].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[12].Quantidade__c));            
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[13].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[13].Quantidade__c));            
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[14].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[14].Quantidade__c));                                
                    }
                    else if(count == 16){
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[1].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[1].Quantidade__c));
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[2].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[2].Quantidade__c));
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[3].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[3].Quantidade__c));
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[4].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[4].Quantidade__c));
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[5].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[5].Quantidade__c));
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[6].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[6].Quantidade__c));
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[7].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[7].Quantidade__c));
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[8].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[8].Quantidade__c));            
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[9].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[9].Quantidade__c));            
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[10].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[10].Quantidade__c));            
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[11].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[11].Quantidade__c));            
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[12].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[12].Quantidade__c));            
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[13].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[13].Quantidade__c));            
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[14].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[14].Quantidade__c));                                
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[15].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[15].Quantidade__c));                                
                    }
                    else if(count == 17){
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[1].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[1].Quantidade__c));
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[2].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[2].Quantidade__c));
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[3].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[3].Quantidade__c));
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[4].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[4].Quantidade__c));
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[5].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[5].Quantidade__c));
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[6].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[6].Quantidade__c));
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[7].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[7].Quantidade__c));
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[8].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[8].Quantidade__c));            
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[9].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[9].Quantidade__c));            
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[10].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[10].Quantidade__c));            
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[11].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[11].Quantidade__c));            
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[12].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[12].Quantidade__c));            
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[13].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[13].Quantidade__c));            
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[14].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[14].Quantidade__c));                                
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[15].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[15].Quantidade__c));                                
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[16].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[16].Quantidade__c));                                
                    }
                    else if(count == 18){
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[1].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[1].Quantidade__c));
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[2].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[2].Quantidade__c));
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[3].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[3].Quantidade__c));
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[4].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[4].Quantidade__c));
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[5].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[5].Quantidade__c));
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[6].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[6].Quantidade__c));
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[7].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[7].Quantidade__c));
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[8].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[8].Quantidade__c));            
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[9].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[9].Quantidade__c));            
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[10].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[10].Quantidade__c));            
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[11].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[11].Quantidade__c));            
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[12].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[12].Quantidade__c));            
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[13].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[13].Quantidade__c));            
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[14].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[14].Quantidade__c));                                
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[15].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[15].Quantidade__c));                                
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[16].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[16].Quantidade__c));                                
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[17].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[17].Quantidade__c));                                                    
                    }
                    else if(count == 19){
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[1].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[1].Quantidade__c));
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[2].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[2].Quantidade__c));
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[3].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[3].Quantidade__c));
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[4].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[4].Quantidade__c));
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[5].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[5].Quantidade__c));
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[6].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[6].Quantidade__c));
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[7].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[7].Quantidade__c));
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[8].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[8].Quantidade__c));            
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[9].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[9].Quantidade__c));            
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[10].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[10].Quantidade__c));            
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[11].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[11].Quantidade__c));            
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[12].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[12].Quantidade__c));            
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[13].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[13].Quantidade__c));            
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[14].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[14].Quantidade__c));                                
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[15].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[15].Quantidade__c));                                
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[16].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[16].Quantidade__c));                                
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[17].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[17].Quantidade__c));                                                    
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[18].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[18].Quantidade__c));                                                    
                    }
                    else if(count == 20){
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[1].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[1].Quantidade__c));
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[2].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[2].Quantidade__c));
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[3].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[3].Quantidade__c));
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[4].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[4].Quantidade__c));
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[5].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[5].Quantidade__c));
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[6].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[6].Quantidade__c));
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[7].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[7].Quantidade__c));
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[8].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[8].Quantidade__c));            
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[9].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[9].Quantidade__c));            
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[10].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[10].Quantidade__c));            
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[11].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[11].Quantidade__c));            
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[12].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[12].Quantidade__c));            
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[13].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[13].Quantidade__c));            
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[14].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[14].Quantidade__c));                                
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[15].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[15].Quantidade__c));                                
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[16].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[16].Quantidade__c));                                
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[17].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[17].Quantidade__c));                                                    
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[18].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[18].Quantidade__c));                                                    
                    checkList.add(new Checklist_do_Ativo__c(Ativo_Relacionado__c=a.ID, Nome_do_Item__c =px[19].Nome_do_Item__c, Ativo__c = true, Quantidade__c=px[19].Quantidade__c));                                                    
                    }
                insert checkList;
                             
        }          
        }
        }
}