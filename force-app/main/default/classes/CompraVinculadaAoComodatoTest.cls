@isTest(seeAllData=true)
public class CompraVinculadaAoComodatoTest {
    @isTest
    public static void testarAgendamentoConsulta() {
        Test.startTest();
        String cronExpression = '0 0 0 1 1 ?'; // Agendar para o primeiro dia de cada ano às 00:00:00
        CompraVinculadaAoComodato agendamento = new CompraVinculadaAoComodato();

        // Agendar a execução
        String jobID = System.schedule('Consulta Agendada', cronExpression, agendamento);

        // Verificar se o agendamento foi criado corretamente
        System.assertNotEquals(null, jobID);
        Test.stopTest();


    }
}