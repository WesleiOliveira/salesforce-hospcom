trigger PedidoPreenchimento on Order (before insert, before update, after insert) {
    
    Set<Id> cotacoes_id = new Set<Id>();
    Set<Id> ordens_de_trabalho_id = new Set<Id>();
    Set<Id> demonstracoes_id = new Set<Id>();
    Set<Id> opme = new Set<Id>();
    
    public Set<integer> bool = new set<integer>();
    
    for(Order pedido : Trigger.new){
        
        if(pedido.QuoteId!=null)
            cotacoes_id.add(pedido.QuoteId);
        else if(pedido.Ordem_de_trabalho__c!=null)
            ordens_de_trabalho_id.add(pedido.Ordem_de_trabalho__c);
        else if(pedido.Demonstracao__c!=null)
            demonstracoes_id.add(pedido.Demonstracao__c);
        
        if((pedido.Pedido_da_Linha_de_OPME__c == 'SIM' || pedido.Departamento3__c == 'Governo') && pedido.QuoteId == null)
            opme.add(pedido.OpportunityId);
        
        if(pedido.Ignora_validacao__c == true)
            bool.add(1);
    }
    if(bool.size() == 0){
        if(Trigger.isBefore && Trigger.IsInsert){
            if(cotacoes_id.size()>0){
                List<Quote> cotacoes = [
                    SELECT  Id, PriceBook2Id, Forma_de_pagamento__c, Condicao_de_pagamento__c, Frete__c, 
                    OpportunityId, Opportunity.Faturamento_Feito2__c
                    FROM    Quote
                    WHERE   Id IN :cotacoes_id
                ];
                List<Id> oportunidades_id = new List<Id>();
                for(Quote cotacao : cotacoes)
                    oportunidades_id.add(cotacao.OpportunityId);
                List<Opportunity> oportunidades = [
                    SELECT  Id, (
                        SELECT   UserId
                        FROM     OpportunityTeamMembers
                        WHERE    TeamMemberRole LIKE 'Vendedor%'
                        ORDER BY CreatedDate ASC
                        LIMIT    1
                    )
                    FROM    Opportunity
                    WHERE   Id IN :oportunidades_id
                ];
                String RecordTypeHospcomId = [SELECT Id FROM RecordType WHERE SObjectType='Order' AND DeveloperName='Hospcom'].Id;
                for(Order pedido : Trigger.new){
                    for(Quote cotacao : cotacoes){
                        if(pedido.QuoteId == cotacao.Id){
                            pedido.OpportunityId = cotacao.OpportunityId;
                            pedido.PriceBook2Id = cotacao.PriceBook2Id;
                            pedido.Status = 'Rascunho';
                            if(pedido.RecordTypeId == RecordTypeHospcomId){
                                if(cotacao.Forma_de_pagamento__c != null)
                                    pedido.Forma_de_pagamento2__c = cotacao.Forma_de_pagamento__c;
                                if(cotacao.Condicao_de_pagamento__c != null)
                                    pedido.Condicao_de_pagamento__c = cotacao.Condicao_de_pagamento__c;
                                if(cotacao.Frete__c != null)
                                    pedido.Frete__c = cotacao.Frete__c;
                                if(cotacao.Opportunity.Faturamento_Feito2__c != null)
                                    pedido.Faturamento_Feito__c = cotacao.Opportunity.Faturamento_Feito2__c;
                            }else{
                                pedido.Pedido_da_Linha_de_OPME__c = 'NÃO';
                            }
                            for(Opportunity oportunidade : oportunidades){
                                if(cotacao.OpportunityId == oportunidade.Id){
                                    if(oportunidade.OpportunityTeamMembers.size()==1)
                                        pedido.Vendedor__c = oportunidade.OpportunityTeamMembers[0].UserId;
                                }
                            }
                        }
                    }
                }
            }
            if(ordens_de_trabalho_id.size()>0){
                List<WorkOrder> ordens_de_trabalho = [
                    SELECT  Id, PriceBook2Id, Forma_de_pagamento2__c, Condicao_de_pagamento__c, Frete2__c, Faturamento_Feito2__c,
                    AccountId, Account.BillingAddress, Account.ShippingAddress
                    FROM    WorkOrder
                    WHERE   Id IN :ordens_de_trabalho_id
                ];
                for(Order pedido : Trigger.new){
                    for(WorkOrder ordem_de_trabalho : ordens_de_trabalho){
                        if(pedido.Ordem_de_trabalho__c == ordem_de_trabalho.Id){
                            pedido.AccountId = ordem_de_trabalho.AccountId;
                            pedido.PriceBook2Id = ordem_de_trabalho.PriceBook2Id;
                            pedido.Status = 'Rascunho';
                            if(ordem_de_trabalho.Forma_de_pagamento2__c != null)
                                pedido.Forma_de_pagamento2__c = ordem_de_trabalho.Forma_de_pagamento2__c;
                            if(ordem_de_trabalho.Condicao_de_pagamento__c != null)
                                pedido.Condicao_de_pagamento__c = ordem_de_trabalho.Condicao_de_pagamento__c;
                            if(ordem_de_trabalho.Frete2__c != null)
                                pedido.Frete__c = ordem_de_trabalho.Frete2__c;
                            if(ordem_de_trabalho.Faturamento_Feito2__c != null)
                                pedido.Faturamento_Feito__c = ordem_de_trabalho.Faturamento_Feito2__c;
                            if(ordem_de_trabalho.Account.BillingAddress!=null)
                                if(ordem_de_trabalho.Account.BillingAddress.getStreet()!=null && ordem_de_trabalho.Account.BillingAddress.getCity()!=null &&
                                   ordem_de_trabalho.Account.BillingAddress.getStateCode()!=null && ordem_de_trabalho.Account.BillingAddress.getPostalCode()!=null){
                                       pedido.BillingStreet = ordem_de_trabalho.Account.BillingAddress.getStreet();
                                       pedido.BillingCity = ordem_de_trabalho.Account.BillingAddress.getCity();
                                       pedido.BillingStateCode = ordem_de_trabalho.Account.BillingAddress.getStateCode();
                                       pedido.BillingPostalCode = ordem_de_trabalho.Account.BillingAddress.getPostalCode();
                                   }
                            if(ordem_de_trabalho.Account.ShippingAddress!=null)
                                if(ordem_de_trabalho.Account.ShippingAddress.getStreet()!=null && ordem_de_trabalho.Account.ShippingAddress.getCity()!=null &&
                                   ordem_de_trabalho.Account.ShippingAddress.getStateCode()!=null && ordem_de_trabalho.Account.ShippingAddress.getPostalCode()!=null){
                                       pedido.ShippingStreet = ordem_de_trabalho.Account.ShippingAddress.getStreet();
                                       pedido.ShippingCity = ordem_de_trabalho.Account.ShippingAddress.getCity();
                                       pedido.ShippingStateCode = ordem_de_trabalho.Account.ShippingAddress.getStateCode();
                                       pedido.ShippingPostalCode = ordem_de_trabalho.Account.ShippingAddress.getPostalCode();
                                   }
                        }
                    }
                }
            }
            if(demonstracoes_id.size()>0){
                List<Demonstracao__c> demonstracoes = [
                    SELECT  Id, Data_prevista__c, Conta__c, Fornecedor__c, Solicitante__c, Rua__c, Cidade__c, Estado__c, CEP__c
                    FROM    Demonstracao__c
                    WHERE   Id IN :demonstracoes_id
                ];
                Id catalogo_padrao_id = [SELECT Id FROM Pricebook2 WHERE IsStandard = true LIMIT 1][0].Id;
                String RecordTypeHospcomId = [SELECT Id FROM RecordType WHERE SObjectType='Order' AND DeveloperName='Hospcom'].Id;
                for(Order pedido : Trigger.new){
                    for(Demonstracao__c demonstracao : demonstracoes){
                        if(pedido.Demonstracao__c == demonstracao.Id){
                            pedido.PriceBook2Id = catalogo_padrao_id;
                            pedido.Status = 'Rascunho';
                            
                            pedido.AccountId = demonstracao.Conta__c;
                            pedido.Vendedor__c = demonstracao.Solicitante__c;
                            
                            if(pedido.RecordTypeId == RecordTypeHospcomId){
                                pedido.Prazo_de_entrega__c = demonstracao.Data_prevista__c;
                                pedido.Faturamento_Feito__c = demonstracao.Fornecedor__c;
                                
                                pedido.BillingStreet = demonstracao.Rua__c;
                                pedido.BillingCity = demonstracao.Cidade__c;
                                pedido.BillingState = demonstracao.Estado__c;
                                pedido.BillingPostalCode = demonstracao.CEP__c;
                                pedido.ShippingStreet = demonstracao.Rua__c;
                                pedido.ShippingCity = demonstracao.Cidade__c;
                                pedido.ShippingState = demonstracao.Estado__c;
                                pedido.ShippingPostalCode = demonstracao.CEP__c;    
                            }                       
                        }
                    }
                }
            }
        }
        
        else if(Trigger.isAfter && Trigger.IsInsert){
            List<OrderItem> itens_ped = new List<OrderItem>();
            if(cotacoes_id.size()>0){
                List<Quote> cotacoes = [
                    SELECT  Id, (
                        SELECT  PricebookEntryId, Quantity, TotalPrice, Item__c, Item_Pai__c, Lote__c, Descricao_da_linha__c
                        FROM    QuoteLineItems
                    )
                    FROM    Quote
                    WHERE   Id IN :cotacoes_id
                ];
                for(Order pedido : Trigger.new){
                    for(Quote cotacao : cotacoes){
                        if(pedido.QuoteId == cotacao.Id){
                            for(QuoteLineItem item_cot : cotacao.QuoteLineItems){
                                itens_ped.add(new OrderItem(
                                    OrderId = pedido.Id,
                                    Status__c = 'Novo',
                                    PricebookEntryId = item_cot.PricebookEntryId,
                                    UnitPrice = item_cot.TotalPrice/item_cot.Quantity,
                                    Quantity = item_cot.Quantity,
                                    Item__c = item_cot.Item__c,
                                    Item_Pai__c = item_cot.Item_Pai__c,
                                    Lote__c = item_cot.Lote__c,
                                    Descricao_da_linha__c = item_cot.Descricao_da_linha__c
                                ));
                            }
                        }
                    }
                }
            }
            //Copia produtos da opp
            if(opme.size()>0){
                List<OpportunityLineItem> produtos = [
                    SELECT PricebookEntryId, Quantity, TotalPrice, Item__c, Item_Pai__c, Lote__c, Descricao_a_linha__c
                    FROM    OpportunityLineItem
                    WHERE   OpportunityId IN : opme
                ];
                for(Order pedido : Trigger.new){
                    for(OpportunityLineItem item_cot : produtos){
                        itens_ped.add(new OrderItem(
                            OrderId = pedido.Id,
                            Status__c = 'Novo',
                            PricebookEntryId = item_cot.PricebookEntryId,
                            UnitPrice = item_cot.TotalPrice/item_cot.Quantity,
                            Quantity = item_cot.Quantity,
                            Item__c = item_cot.Item__c,
                            Item_Pai__c = item_cot.Item_Pai__c,
                            Lote__c = item_cot.Lote__c,
                            Descricao_da_linha__c = item_cot.Descricao_a_linha__c
                        ));
                    }
                }
            }
            
            if(ordens_de_trabalho_id.size()>0){
                List<WorkOrder> ordens_de_trabalho = [
                    SELECT  Id, (
                        SELECT  PricebookEntryId, Quantity, TotalPrice, Item__c, Item_Pai__c, Description
                        FROM    WorkOrderLineItems
                    )
                    FROM    WorkOrder
                    WHERE   Id IN :ordens_de_trabalho_id
                ];
                for(Order pedido : Trigger.new){
                    for(WorkOrder ordem_de_trabalho : ordens_de_trabalho){
                        if(pedido.Ordem_de_trabalho__c == ordem_de_trabalho.Id){
                            for(WorkOrderLineItem item_ot : ordem_de_trabalho.WorkOrderLineItems){
                                itens_ped.add(new OrderItem(
                                    OrderId = pedido.Id,
                                    Status__c = 'Novo',
                                    PricebookEntryId = item_ot.PricebookEntryId,
                                    UnitPrice = item_ot.TotalPrice/item_ot.Quantity,
                                    Quantity = item_ot.Quantity,
                                    Item__c = item_ot.Item__c,
                                    Item_Pai__c = item_ot.Item_Pai__c,
                                    Descricao_da_linha__c = item_ot.Description
                                ));
                            }
                        }
                    }
                }
            }
            if(demonstracoes_id.size()>0){
                Id catalogo_padrao_id = [SELECT Id FROM Pricebook2 WHERE IsStandard = true LIMIT 1][0].Id;
                List<Demonstracao__c> demonstracoes = [
                    SELECT  Id, CurrencyIsoCode, (
                        SELECT  Ativo__r.Product2Id, Valor__c, Item__c, Item_Pai__c, Descricao__c, Ativo__r.SerialNumber
                        FROM    Produtos_da_demonstracao__r
                    )
                    FROM    Demonstracao__c
                    WHERE   Id IN :demonstracoes_id
                ];
                Set<Id> produtos_id = new Set<Id>();
                for(Demonstracao__c demonstracao : demonstracoes)
                    for(Produto_da_Demonstracao__c item_demo : demonstracao.Produtos_da_demonstracao__r)
                    produtos_id.add(item_demo.Ativo__r.Product2Id);
                List<PricebookEntry> entradas = [
                    SELECT  Id, Product2Id, CurrencyIsoCode
                    FROM    PricebookEntry
                    WHERE   Product2Id IN :produtos_id AND Pricebook2Id = :catalogo_padrao_id
                ];
                
                for(Order pedido : Trigger.new){
                    for(Demonstracao__c demonstracao : demonstracoes){
                        if(pedido.Demonstracao__c == demonstracao.Id){
                            for(Produto_da_Demonstracao__c item_demo : demonstracao.Produtos_da_demonstracao__r){
                                for(PricebookEntry entrada : entradas){
                                    if(item_demo.Ativo__r.Product2Id == entrada.Product2Id && demonstracao.CurrencyIsoCode == entrada.CurrencyIsoCode){
                                        itens_ped.add(new OrderItem(
                                            OrderId = pedido.Id,
                                            Status__c = 'Novo',
                                            PricebookEntryId = entrada.Id,
                                            UnitPrice = item_demo.Valor__c,
                                            Quantity = 1,
                                            Item__c = item_demo.Item__c,
                                            Item_Pai__c = item_demo.Item_Pai__c,
                                            Descricao_da_linha__c = item_demo.Descricao__c,
                                            Description = item_demo.Ativo__r.SerialNumber
                                        ));
                                    }
                                }
                            }
                        }
                    }
                }
            }
            Util.AcaoInterna(true);
            if(itens_ped.size()>0)
                insert itens_ped;
            Util.AcaoInterna(false);
        }
    }
}