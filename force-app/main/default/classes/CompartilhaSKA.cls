global class CompartilhaSKA implements Schedulable {
    global void execute(SchedulableContext sc) {
        compartilha	();
    }

    public void compartilha() {
        // Define the ID do grupo que receberá os compartilhamentos
        Id groupId = '00GU4000000mRIr'; 

        // Buscar todas as contas com SKA__c = true
        List<Account> skaAccounts = [SELECT Id FROM Account WHERE Key_Account__c = true];

        if (skaAccounts.isEmpty()) {
            System.debug('Nenhuma conta com Key Account = true encontrada.');
            return;
        }

        Set<Id> accountIds = new Set<Id>();
        for (Account acc : skaAccounts) {
            accountIds.add(acc.Id);
        }

        // Buscar Oportunidades, Cotações e Pedidos relacionados às contas encontradas
        List<Opportunity> opportunities = [SELECT Id FROM Opportunity WHERE AccountId IN :accountIds AND ID NOT IN (SELECT OpportunityId FROM OpportunityShare WHERE UserOrGroupId =: groupId)];
        List<Order> orders = [SELECT Id FROM Order WHERE AccountId IN :accountIds AND ID NOT IN (SELECT OrderId FROM OrderShare WHERE UserOrGroupId =: groupId)];
        List<Contrato_de_Servi_o__c> contratos = [SELECT Id FROM Contrato_de_Servi_o__c WHERE Locat_rio_a__c IN :accountIds AND ID NOT IN (SELECT ParentId FROM Contrato_de_Servi_o__Share WHERE UserOrGroupId =: groupId)];

        // Compartilhar os registros com o grupo
        List<OpportunityShare> oppShares = new List<OpportunityShare>();
        List<OrderShare> orderShares = new List<OrderShare>();
        List<Contrato_de_Servi_o__Share> contratoShares = new List<Contrato_de_Servi_o__Share>();

        for (Opportunity opp : opportunities) {
            OpportunityShare oppShare = new OpportunityShare();
            oppShare.OpportunityId = opp.Id;
            oppShare.UserOrGroupId = groupId;
            oppShare.OpportunityAccessLevel = 'Edit'; // Ajuste o nível de acesso conforme necessário
            oppShares.add(oppShare);
        }

        for (Order order : orders) {
            OrderShare orderShare = new OrderShare();
            orderShare.OrderId = order.Id;
            orderShare.UserOrGroupId = groupId;
            orderShare.OrderAccessLevel = 'Edit'; // Ajuste o nível de acesso conforme necessário
            orderShares.add(orderShare);
        }
        
        for (Contrato_de_Servi_o__c contrato : contratos) {
            Contrato_de_Servi_o__Share contratoShare = new Contrato_de_Servi_o__Share();
            contratoShare.ParentId = contrato.Id;
            contratoShare.UserOrGroupId = groupId;
            contratoShare.AccessLevel = 'Edit'; // Ajuste o nível de acesso conforme necessário
            contratoShares.add(contratoShare);
        }

        if (!oppShares.isEmpty()) {
            insert oppShares;
        }

        if (!contratoShares.isEmpty()) {
            insert contratoShares;
        }

        if (!orderShares.isEmpty()) {
            insert orderShares;
        }

        System.debug('Compartilhamento concluído com sucesso.');
    }
}