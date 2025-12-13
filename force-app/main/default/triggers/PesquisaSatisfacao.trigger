trigger PesquisaSatisfacao on Order (after update) {

    if (!RecursiveHandler.IsNotRecursive2) {
        return;
    }
    RecursiveHandler.IsNotRecursive2 = false;

    // 🔹 Mapeamentos para consultas em massa
    Set<Id> quoteIds = new Set<Id>();
    Set<Id> contratoIds = new Set<Id>();
    Set<Id> woIds = new Set<Id>();

    for (Order o : Trigger.new) {
        Order oldOrder = Trigger.oldMap.get(o.Id);
        if (o.Status == 'Entregue Total' && oldOrder.Status != 'Entregue Total') {
            if (o.Natureza_de_Opera_o__c == 'VENDA' && o.QuoteId != null) {
                quoteIds.add(o.QuoteId);
            }
            if (o.Natureza_de_Opera_o__c == 'LOCAÇÃO' && o.Contrato_de_Servi_o__c != null) {
                contratoIds.add(o.Contrato_de_Servi_o__c);
            }
            if (o.Natureza_de_Opera_o__c == 'SERVIÇO' && o.Ordem_de_trabalho__c != null) {
                woIds.add(o.Ordem_de_trabalho__c);
            }
        }
    }

    // 🔹 Consultas em massa SEGURAS
    Map<Id, Quote> quotes = new Map<Id, Quote>([
        SELECT Id, Contact.MobilePhone
        FROM Quote
        WHERE Id IN :quoteIds
    ]);

    Map<Id, Contrato_de_Servi_o__c> contratos = new Map<Id, Contrato_de_Servi_o__c>([
        SELECT Id, Contato_do_Locat_rio__r.MobilePhone
        FROM Contrato_de_Servi_o__c
        WHERE Id IN :contratoIds
    ]);

    Map<Id, WorkOrder> workOrders = new Map<Id, WorkOrder>([
        SELECT Id, Contact.MobilePhone
        FROM WorkOrder
        WHERE Id IN :woIds
    ]);


    // 🔹 Processamento final
    for (Order o : Trigger.new) {

        Order oldOrder = Trigger.oldMap.get(o.Id);

        if (o.Status != 'Entregue Total' || oldOrder.Status == 'Entregue Total') {
            continue;
        }

        String phone;
        Integer form;

        if (o.Natureza_de_Opera_o__c == 'VENDA' && o.QuoteId != null) {

            Quote q = quotes.get(o.QuoteId);

            if (q != null && q.Contact != null && q.Contact.MobilePhone != null) {
                phone = q.Contact.MobilePhone;
                form = 1;
            }

        } else if (o.Natureza_de_Opera_o__c == 'LOCAÇÃO' && o.Contrato_de_Servi_o__c != null) {

            Contrato_de_Servi_o__c c = contratos.get(o.Contrato_de_Servi_o__c);

            if (c != null && c.Contato_do_Locat_rio__r != null &&
                c.Contato_do_Locat_rio__r.MobilePhone != null) {
                phone = c.Contato_do_Locat_rio__r.MobilePhone;
                form = 2;
            }

        } else if (o.Natureza_de_Opera_o__c == 'SERVIÇO' && o.Ordem_de_trabalho__c != null) {

            WorkOrder w = workOrders.get(o.Ordem_de_trabalho__c);

            if (w != null && w.Contact != null && w.Contact.MobilePhone != null) {
                phone = w.Contact.MobilePhone;
                form = 3;
            }
        }

        // 🔹 Se não encontrou telefone → não envia WhatsApp
        if (phone == null) continue;

        // 🔹 Evita execução em Test & Batch
        if (!System.Test.isRunningTest() && !System.isBatch()) {
            WhatsAppIntegration.isWhatsApp(form, phone, o.OrderNumber);
        }
    }
}