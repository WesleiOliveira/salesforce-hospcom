@isTest(seeAllData=true)
private class ForecastSalvoSchedulerTest {

    @isTest 
    static void executaScheduler() {
        // Instancia diretamente a classe e chama o método execute
        ForecastSalvoScheduler scheduler = new ForecastSalvoScheduler();

        Test.startTest();
        scheduler.execute(null);
        Test.stopTest();

        // Verifica se registros Forecast_Salvo__c foram criados
        List<Forecast_Salvo__c> resultados = [
            SELECT Id, Linha__c, Valor__c, Regiao__c
            FROM Forecast_Salvo__c 
            WHERE CreatedDate = TODAY
        ];

        System.assert(resultados.size() > 0, 'Deveria ter criado pelo menos um registro de Forecast_Salvo__c');
    }
}