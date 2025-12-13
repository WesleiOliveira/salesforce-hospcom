@isTest(SeeAllData=true)
public class TrelloTEST {
	@isTest
    public static void TESTTrello(){
        Trello.doTeste();
        Quadro_Trello__c qt = new Quadro_Trello__c();
        qt.Name = 'name';
        qt.Titulo_Quadro__c = 'tituloQuadro';        
        insert qt;
        
		cartaoTrello__c ct = new cartaoTrello__c();
        ct.Name = 'name';
        ct.Quadro_Trello__c = qt.Id;
        ct.Titulo_Cartao__c = 'titulo';                
        insert ct;        
        
        Task t = new Task();
		t.Description = 'description';
        t.WhatId = ct.Id;
		insert t;
                
        //User u = new User();
        //u.Username = '3e9100ffb8461f574a998f849d86dd7d@t.com';
        //u.LastName = 'Teste';
        //u.Email = 'e4e36da98f5950735b5e89c708544947@t.com';
        //u.Alias = 'Teste';
        //u.TimeZoneSidKey = 'GMT';
        //u.LocaleSidKey = 'pt_BR';
        //u.EmailEncodingKey = 'UTF-8';
        //u.ProfileId = '00ei0000000nKA9AAM'; 
        //u.LanguageLocaleKey = 'pt_BR';
        //u.Ignorar_erros__c = true;
        //insert u;
        
        Trello.stringToBoolean('true');
        Trello.stringToBoolean('true1');
        
        Trello.createCardTrello('name', qt.Id, 'titulo');
        Trello.createTask(null, 'description', Date.today(), ct.Id);
        Trello.createQuadroTrello('name', 'tituloQuadro');
        
        Trello.updateCardTrello(ct.Id, 'name', qt.Id, 'titulo');
        Trello.updateTask(t.Id, 'Assunto','description', '29/11/2023', ct.Id);
        Trello.updateTaskWhatId(T.Id, ct.Id);
        Trello.updateTaskMeta(T.Id, 'false', 1);
        Trello.updateQuadroTrello(qt.Id, 'name', 'tituloQuadro');

        // Trello.compartilhaQuadro(qt.Id, u.Id, 'All');
        // Trello.compartilhaCartao(ct.Id, u.Id, 'All');
        // sandbox a2IHZ0000003Lfp
        // producao a2IU4000000GkDNMA0
        Trello.completaChecklist('a2IU4000000GkDNMA0');
        Trello.unableChecklist('a2IU4000000GkDNMA0');
        Trello.deleteChecklistTarefa('a2IU4000000GkDNMA0');
        Trello.adicionarMembroAtividade('00TU4000000QUFNMA4', '0056e00000Co1I0');
        Trello.adicionarMembroAtividade('00TU4000000QUFNMA4', '0056e00000Co1I0');
        
        
        Trello.deletaTask(t.id);
        Trello.deletaCartao(ct.id);
        Trello.deletaQuadro(qt.id);
        //Trello.updateStatus(t.id, 'Concluído');
        Trello.doTeste();
    }
    
}