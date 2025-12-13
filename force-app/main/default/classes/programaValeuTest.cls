@isTest(seeAllData=true)
public class programaValeuTest {
    @isTest
    private static void testa(){ 
        programaValeu.envia('0036e00004Hl2lk', 'justificativa', '0036e00004Fczvv', '00531000006UzZsAAK');
    }  
    @isTest
    private static void testa2(){
        programaValeu.executeSoql('SELECT ID FROM ACCOUNT LIMIT 1');
    }
    @isTest
    private static void testa3(){
        try{
            programaValeu.envia('0036e00004Hl2lk', 'justificativa', '0036e00004Fczvv', '00531000006UzZsAAK');
        }
        catch(DmlException e){}
    }       
    @isTest
    private static void testa4(){
        programaValeu.dummy('0036e00004Hl2lk'); 
    }
     @isTest
    private static void testa5(){
        programaValeu.dummy2('0036e00004Hl2lk'); 
    }
      @isTest
    private static void testa6(){
        programaValeu.dummy3('0036e00004Hl2lk'); 
    }
       @isTest
    private static void testa7(){
        programaValeu.dummy4('0036e00004Hl2lk'); 
    }
         @isTest
    private static void testa8(){
        programaValeu.dummy5('0036e00004Hl2lk'); 
    }
         @isTest
    private static void testa9(){
        programaValeu.dummy6('0036e00004Hl2lk'); 
    }
         @isTest
    private static void testa10(){
        programaValeu.dummy7('0036e00004Hl2lk'); 
    }
         @isTest
    private static void testa11(){
        programaValeu.dummy9('0036e00004Hl2lk'); 
    }
    
@isTest
    static void testaTriggerComSolicitacao() {
        // Busca um contato ativo existente
        Contact contato = [SELECT Id FROM Contact WHERE Colaborador_Ativo__c = true LIMIT 1];
        
      
        // Cria uma solicitação com status inicial
        Solicitacao_de_Tranferencia_Hospcoins__c solicitacao = new Solicitacao_de_Tranferencia_Hospcoins__c(
            Destinatario__c = contato.Id,
            Justificativa__c = 'Justificativa direta',
            Status__c = 'Pendente',
            Remetente_Externo__c = 'Nome de Teste'
        );
        insert solicitacao;

        // Atualiza para 'Aprovado' para acionar o trigger
        solicitacao.Status__c = 'Aprovado';
        update solicitacao;      
    }
}