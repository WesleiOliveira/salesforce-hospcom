@isTest(seeAllData=true)
private class Treinamento_ImpedeCriacaoDeDuplicadas_T {
	
    @isTest 
    static void Teste1(){         
	
		Membro_Interno_do_Evento__c novoMembro = new Membro_Interno_do_Evento__c();
        
        novoMembro.Evento__c = '701U4000000Vy81IAC';
        novoMembro.Contato__c = '0036e00004FczvvAAB';
        novoMembro.Empresa__c = '001i00000085QYbAAM';
	
        try{
        	insert novoMembro;
        }catch(Exception e){
            System.debug('Error: '+ e);
        }
        Membro_Interno_do_Evento__c novoMembro2 = new Membro_Interno_do_Evento__c();
        
        novoMembro2.Evento__c = '701U4000000Vy81IAC';
        novoMembro2.Contato__c = '0036e00004FczvvAAB';
        novoMembro2.Empresa__c = '001i00000085QYbAAM';

        try{
            insert novoMembro2;
        }catch(Exception e){
            System.debug('Error: '+ e);
        }
        
    }
 	
}