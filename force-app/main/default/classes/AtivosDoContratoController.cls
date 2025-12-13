public with sharing class AtivosDoContratoController {
    @AuraEnabled(cacheable=true)
    public static List<Ativos_do_Contrato__c> getAtivosByContratoId(Id contratoId) {
        return [
            SELECT Id, Ativo_Locado__r.Product2.ProductCode, Ativo_Locado__r.Product2.Name, N_de_S_rie__c, URL_da_Imagem__c, Equipamento_no_Cliente__c, Data_de_Entrega__c, Data_de_retorno__c, Ativo_Locado__r.Product2.URL_da_Imagem__c, Data_de_Entrega_formatada__c, Valor_Total_Mensal_Atual__c, Data_de_retorno_formatada__c, Nome_do_ativo__c
            FROM Ativos_do_Contrato__c
            WHERE Contrato_de_Servico__c = :contratoId
            ORDER BY Ativo_Locado__r.Product2.Name
        ];
    }
    
    @AuraEnabled
    public static void updateEquipamentoStatus(List<Id> ativoIds, Boolean status, Date dataEntregaOuRetorno) {
        // Fetch ativos to update
        List<Ativos_do_Contrato__c> ativosToUpdate = [
            SELECT Id, Equipamento_no_Cliente__c, Data_de_entrega__c, Data_de_retorno__c, Ativo_Locado__r.Product2Id, Contrato_de_Servico__c, N_de_S_rie__c, Nome_do_ativo__c
            FROM Ativos_do_Contrato__c
            WHERE Id IN :ativoIds
        ];
        
        // Fetch related Contrato_de_Servico__c record
        Contrato_de_Servi_o__c contratoRel = [SELECT ID, Locat_rio_a__c, Locat_rio_a__r.BillingCity, Locat_rio_a__r.BillingCountry, Locat_rio_a__r.BillingPostalCode, Locat_rio_a__r.BillingState, Locat_rio_a__r.BillingStreet, Locat_rio_a__r.ShippingCity, Locat_rio_a__r.ShippingCountry, Locat_rio_a__r.ShippingPostalCode, Locat_rio_a__r.ShippingState, Locat_rio_a__r.ShippingStreet, Unidade_Hospitalar__c, Vendedor_do_Contrato__c FROM Contrato_de_Servi_o__c WHERE ID = :ativosToUpdate[0].Contrato_de_Servico__c];
        
        // Create the Order object
        Order pedidoRetorno = new Order(
            AccountId = contratoRel.Locat_rio_a__c,
            Contrato_de_Servi_o__c = contratoRel.ID,
            EffectiveDate = system.today(),
            Status = 'Rascunho',
            BillingCity = contratoRel.Locat_rio_a__r.BillingCity,
            BillingCountry = contratoRel.Locat_rio_a__r.BillingCountry,
            BillingPostalCode = contratoRel.Locat_rio_a__r.BillingPostalCode,
            BillingState = contratoRel.Locat_rio_a__r.BillingState,
            BillingStreet = contratoRel.Locat_rio_a__r.BillingStreet,
            Condicao_de_pagamento__c = 'Sem Mov. Financeiro',
            Departamento3__c = 'Locação',
            Entrega_parcial__c = 'Não Autorizada',
            Forma_de_pagamento2__c = 'Sem Mov. Financeiro',
            Frete__c = 'Transporte Próprio por conta do Destinatário',
            Ignora_validacao__c = true,
            Locado_em__c = '-',
            Natureza_de_Opera_o__c = 'REMESSA DE LOCAÇÃO',
            Necess_rio_Treinamento__c = 'NÃO',
            Pricebook2Id = '01s5A000004fbcR', // Use the correct Pricebook2Id
            ShippingCity = contratoRel.Locat_rio_a__r.ShippingCity,
            ShippingCountry = contratoRel.Locat_rio_a__r.ShippingCountry,
            ShippingPostalCode = contratoRel.Locat_rio_a__r.ShippingPostalCode,
            ShippingState = contratoRel.Locat_rio_a__r.ShippingState,
            ShippingStreet = contratoRel.Locat_rio_a__r.ShippingStreet,
            Unidade_Hospitalar__c = contratoRel.Unidade_Hospitalar__c,
            Vendedor__c = contratoRel.Vendedor_do_Contrato__c,
            Prioridade__c = 'NORMAL',
            Entrega_liberada_pelo_financeiro__c = 'SIM'
        );
        
        insert pedidoRetorno; // Insert the order before creating order items
        
        // Collect Product2Ids from ativosToUpdate
        Set<Id> productIds = new Set<Id>();
        for (Ativos_do_Contrato__c ativo : ativosToUpdate) {
            productIds.add(ativo.Ativo_Locado__r.Product2Id);
        }
        
        // Fetch PricebookEntries
        Map<Id, PricebookEntry> pricebookEntriesMap = new Map<Id, PricebookEntry>([
            SELECT Id, Product2Id, UnitPrice
            FROM PricebookEntry
            WHERE Pricebook2Id = '01s5A000004fbcR' AND Product2Id IN :productIds
        ]);
        
        // List to store OrderItems
        List<OrderItem> orderItems = new List<OrderItem>();
        
        // Iterate over the ativos to update and create order items
        for (Ativos_do_Contrato__c ativo : ativosToUpdate) {
            ativo.Equipamento_no_Cliente__c = status;
            if (status) {
                DateTime dataEntregaFormt = DateTime.newInstance(dataEntregaOuRetorno.year(), dataEntregaOuRetorno.month(), dataEntregaOuRetorno.day(), 12, 0, 0);
                ativo.Data_de_entrega__c = dataEntregaFormt;
            } else {
                ativo.Data_de_retorno__c = dataEntregaOuRetorno;
                
                // Create OrderItem
                PricebookEntry pbe = pricebookEntriesMap.get(ativo.Ativo_Locado__r.Product2Id);
                if (pbe != null) {
                    OrderItem itemPedido = new OrderItem(
                        OrderId = pedidoRetorno.Id,
                        PricebookEntryId = pbe.Id,
                        Quantity = 1, 
                        UnitPrice = pbe.UnitPrice,
                        Description = ativo.N_de_S_rie__c
                    );
                    orderItems.add(itemPedido);
                }
            }
        }
        update ativosToUpdate;
        if (!orderItems.isEmpty()) {
            insert orderItems;
        }
    }
    
    
    @AuraEnabled
    public static void substituirAtivo(Id ativoId, String novoNumeroDeSerie, Date dataSubstituicao) {
        Ativos_do_Contrato__c ativoSubstituido = [
            SELECT Id, N_de_S_rie__c, Contrato_de_Servico__c, Quantidade__c, Valor_Unitario_Mensal__c, Valor_Total_Mensal_Atual__c
            FROM Ativos_do_Contrato__c
            WHERE Id = :ativoId
            LIMIT 1
        ];
        ativoSubstituido.Equipamento_no_Cliente__c = false;
        ativoSubstituido.Data_de_Retorno__c = dataSubstituicao;
        ativoSubstituido.Substituido_por__c = novoNumeroDeSerie;
        update ativoSubstituido;
        
        DateTime dataSubstituicaoDatetime = DateTime.newInstance(dataSubstituicao.year(), dataSubstituicao.month(), dataSubstituicao.day(), 12, 0, 0);
        
        Asset novoAtivo = [
            SELECT Id
            FROM Asset
            WHERE SerialNumber = :novoNumeroDeSerie
            LIMIT 1
        ];
        
        Ativos_do_Contrato__c novoAtivoLocado = new Ativos_do_Contrato__c(Ativo_Locado__c = novoAtivo.Id, 
                                                                          Contrato_de_Servico__c = ativoSubstituido.Contrato_de_Servico__c, 
                                                                          Quantidade__c = ativoSubstituido.Quantidade__c, 
                                                                          Valor_Unitario_Mensal__c = ativoSubstituido.Valor_Unitario_Mensal__c, 
                                                                          Valor_Total_Mensal_Atual__c = ativoSubstituido.Valor_Total_Mensal_Atual__c,
                                                                          Data_de_Entrega__c = dataSubstituicaoDatetime
                                                                         );
        try{
            insert novoAtivoLocado;
        }
        catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
}