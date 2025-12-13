//System.schedule('SapCronIntegrationScheduler',  '0 17 * * * ?', new SapCronIntegrationScheduler());
global class SapCronIntegrationScheduler implements Schedulable{
	public void execute(SchedulableContext sc){
		DateTime dt = System.now().addMinutes(5);
        CompartilhaLinha.compartilha();
        //SapCronIntegration.SapFaturamentoIntegration();
        //SapInventoryIntegration.InventoryIntegration();
		System.AbortJob(sc.getTriggerId());
		System.schedule('SapCronIntegrationScheduler', dt.second() + ' ' + dt.minute() + ' ' + dt.hour() + ' * * ?', new SapCronIntegrationScheduler());
	}
}