@isTest
public class AlternarBuscarStatusTest {
    
    @isTest
    static void testAlternarBuscarStatus() {
        // Criar registros de teste para Processo_Judicial__c
        List<Processo_Judicial__c> registros = new List<Processo_Judicial__c>();
        for (Integer i = 0; i < 5; i++) {
            registros.add(new Processo_Judicial__c(
                Name = 'Registro ' + i
            ));
        }
        insert registros;
        
        // Marcar o primeiro registro para começar o teste
        registros[0].Buscar__c = true;
        update registros[0];
        
        // Executar o método de agendamento
        Test.startTest();
        
        // Agendar a classe AlternarBuscarStatus
        String cronExp = '0 0 0 17 9 ? 2024';
        AlternarBuscarStatus job = new AlternarBuscarStatus();
        System.schedule('AlternarBuscarStatusJobTest', cronExp, job);
        
        // Executar os jobs agendados (neste caso, simulando a execução de um job agendado)
        // Note: Não é necessário chamar um método específico, o job será executado no contexto do teste
        Test.stopTest();
        
        // Verificar o resultado
        List<Processo_Judicial__c> processosAtualizados = [SELECT Id, Buscar__c, LastModifiedDate FROM Processo_Judicial__c];
        
        // Contar quantos registros têm Buscar__c = true
        Integer contarTrue = 0;
        for (Processo_Judicial__c processo : processosAtualizados) {
            if (processo.Buscar__c == true) {
                contarTrue++;
            }
        }
        
        // Deve haver exatamente 1 registro com Buscar__c = true
        System.assertEquals(1, contarTrue, 'Deve haver exatamente um registro com Buscar__c = true.');
        
        // Verificar se o registro com o campo Buscar__c = true é o que foi atualizado por último
        Processo_Judicial__c processoAtual = [SELECT Id, LastModifiedDate FROM Processo_Judicial__c WHERE Buscar__c = true LIMIT 1];
        
        // Verificar se o registro com Buscar__c = true tem a maior data de Última Atualização
        Processo_Judicial__c processoMaisRecente = [SELECT Id, LastModifiedDate FROM Processo_Judicial__c ORDER BY LastModifiedDate DESC LIMIT 1];
        
        System.assertEquals(processoMaisRecente.Id, processoAtual.Id, 'O registro com Buscar__c = true deve ser o mais recentemente atualizado.');
    }
}