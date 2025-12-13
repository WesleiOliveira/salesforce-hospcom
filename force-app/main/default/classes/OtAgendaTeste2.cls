@isTest(SeeAllData=true)
public class OtAgendaTeste2 {

    static testMethod void OtAgendaTesteGeral3(){ 
		test.startTest();
        
            WorkOrder ordem = new WorkOrder(
                RECORDTYPEID =                                '01231000000tb6AAAQ',
                ACCOUNTID =                                   '0015A00001uB5OMQA0', 		// prod=0015A00001uB5OMQA0 dev=0010q000002LDCd
                CONTACTID =                                   '0035A00003DHWrGQAX',			// prod=0035A00003DHWrGQAX dev=0030q000001x1YN
                //SERVICECONTRACTID =                         '8105A0000032oYdQAI',
                ASSETID =                                     '02i5A000007zqPoQAI',			// prod=02i5A000007zqPoQAI dev=02i0q000000Dqa1
                COUNTRY =                                     'Brasil',
                COUNTRYCODE =                                 'BR',
                DESCRIPTION =                                 'nali liga (testeee)',
                SUBJECT =                                     '### teste insert ###',
                STATUS =                                      'AGUARDANDO ATENDIMENTO',
                PRIORITY =                                    'MÉDIA',
                DURATIONTYPE =                                'Hours',
                TIPO_DE_SERVI_O__C =                          'MANUTENÇÃO CORRETIVA',
                T_CNICO_RESPONS_VEL__C =                      'CLEITON RIBEIRO',
                OR_AMENTO_RE__C =                             false,
                X4_MANUTEN_O_REALIZADA__C =                   false,
                ACESS_RIOS_QUE_ACOMPANHAM_O_EQUIPAMENTO__C =  'nenhum',
                LOCAL_DE_ATENDIMENTO__C =                     'EXTERNO',
                CATEGORIA__C =                                'AVULSO',
                STARTDATE =                                   System.now(),
                DATA_AGENDADA_PARA_SERVI_O__C =               System.now(),
                DATA_PREVISTA_PARA_O_FIM_DO_SERVI_O__C =      System.now()+2
            );
        
               
            insert ordem;
        
        test.stopTest();
    }
    
    
}