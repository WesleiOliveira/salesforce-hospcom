@isTest
public class VagaValidacaoTest {
	@isTest
    public static void teste(){
        Vagas_Dispon_veis__c vaga = new Vagas_Dispon_veis__c();
        vaga.Cargo_Ofertado__c = 'Cargo Teste';
        vaga.Empresa__c = 'HOSPCOM';
        vaga.V_nculo__c = 'CLT';
        insert vaga;
        vaga.Status__c = 'Proposta e ASO';
        update vaga;
        vaga.Status__c = 'Processo Admissional';
        update vaga;
 		vaga.Status__c = 'Assinatura de Documentos';
        update vaga;
        vaga.Status__c = 'Finalizada';
        update vaga;
        
    }
}