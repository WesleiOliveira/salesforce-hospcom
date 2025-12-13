@isTest(seeAllData=true)
public class ATIVIDADE_ENVIAE_teste {
    @isTest 
    static void Teste1(){
        Atividade__c atividade = new Atividade__c();
        atividade.name = 'class de test';
        atividade.Descricao__c = 'descrição do email';
        atividade.Id_Tarefa__c = '00TU400000Du40WMAR';
    
        
        insert atividade;
    }
}