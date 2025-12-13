@isTest(seeAllData=true)
public class AnaliseItensEditalTest {

    @isTest
    static void testOpportunityLineItemsController() {
        // O ID da oportunidade fornecida
        Id opportunityId = '0066e00001fwWaYAAU';
        
        // Instanciar o controlador com o ID da oportunidade
        AnaliseItensEdital controller = new AnaliseItensEdital();
        controller.opportunityId = opportunityId;
        
        // Recuperar os OpportunityLineItems através do controlador
        List<AnaliseItensEdital.OpportunityLineItemWrapper> lineItemWrappers = controller.getOpportunityLineItems();
        
        Opportunity oport = controller.getOpp();

        // Assegurar que os dados foram recuperados
        System.assertNotEquals(lineItemWrappers, null, 'A lista de OpportunityLineItemWrapper não pode ser nula');
        
        // Verificar que os grupos de OpportunityLineItems foram corretamente agrupados
        for (AnaliseItensEdital.OpportunityLineItemWrapper wrapper : lineItemWrappers) {
            // Verificar se o item pai não está nulo
            if (wrapper.parentItem != null) {
                System.assertNotEquals(wrapper.parentItem.Name, null, 'O nome do item pai não pode ser nulo');
            }
            
        }
    }
    @isTest
    private static void test(){
        AnaliseItensEdital.dummy('0036e00004Hl2lk'); 
    }
}