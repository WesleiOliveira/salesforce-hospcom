@isTest(seeAllData=true)
public class SAPOrderIntegrationTEST {
	@isTest(seeAllData=true)
    private static void SAPOrderIntegration_TEST(){
        Test.startTest();

        Account a = new Account();
        a.Name = 'Teste';
        a.CNPJ__c = '51.461.458/0001-89';
        insert a;
       
        User u = new User();
        u.Username = '3e9100ffb8461f574a998f849d86dd7d@t.com';
        u.LastName = 'Teste';
        u.Email = 'e4e36da98f5950735b5e89c708544947@t.com';
        u.Alias = 'Teste';
        u.TimeZoneSidKey = 'GMT';
        u.LocaleSidKey = 'pt_BR';
        u.EmailEncodingKey = 'UTF-8';
        u.ProfileId = '00e6e000002JPriAAG'; 
        u.LanguageLocaleKey = 'pt_BR';
        u.Ignorar_erros__c = true;
        insert u;

		Contact c = new Contact();
        c.FirstName = 'TESTE';
        c.LastName = 'TESTE';
		insert c;        

        //Demonstracao__c d = new Demonstracao__c();
        //d.Conta__c = a.Id;
        //d.CEP__c = '77000-000';
        //d.Cidade__c = 'TESTE';
        //d.Contato__c = c.Id;
        //d.Departamento__c = 'Comercial';
        //insert d;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'TESTE';
        opp.StageName = 'WIN';
        opp.CloseDate = Date.newInstance(2022,10,17);
        //opp.OwnerId = u.Id;
        insert opp;
        
		WorkOrder wo = new WorkOrder();
        wo.AccountId = a.Id;
		insert wo;
                
		//Order o = new Order();
		//o.RecordTypeId = '0126e000001YbEaAAK';
        //o.Status = 'Aprovado';
        //o.Name = 'Teste';
        //o.AccountId = a.Id;
        //o.Faturamento_Feito__c = a.Id;
        //o.Condicao_de_pagamento__c = 'À vista - Paga e Retira';
        //o.Forma_de_pagamento2__c = 'Recebimento via Transferência Bancária';
        //o.Frete__c = 'Contratação do Frete por conta do Remetente (CIF)';
        //o.Vendedor__c = u.Id;
        //o.Demonstracao__c = d.Id;
        //o.EffectiveDate = Date.newInstance(2022,08,17);
        //o.OwnerId = u.Id;
		//insert o;
        
        //Faturamento__c f = new Faturamento__c();
        //f.Pedido__c = o.Id;
        //insert f;

		Order o2 = new Order();
		o2.RecordTypeId = '0126e000001YbEaAAK';
        o2.Status = 'Aprovado';
        o2.Name = 'Teste';
        o2.AccountId = a.Id;
        o2.Faturamento_Feito__c = a.Id;
        o2.Condicao_de_pagamento__c = 'À vista - Paga e Retira';
        o2.Forma_de_pagamento2__c = 'Recebimento via Transferência Bancária';
        o2.Frete__c = 'Contratação do Frete por conta do Remetente (CIF)';
        o2.Vendedor__c = u.Id;
        o2.OpportunityId = opp.Id;
        o2.EffectiveDate = Date.newInstance(2023,08,17);
		insert o2;
        
		Order o3 = new Order();
		o3.RecordTypeId = '0126e000001YbEaAAK';
        o3.Status = 'Aprovado';
        o3.Name = 'Teste';
        o3.AccountId = a.Id;
        o3.Faturamento_Feito__c = a.Id;
        o3.Condicao_de_pagamento__c = 'À vista - Paga e Retira';
        o3.Forma_de_pagamento2__c = 'Recebimento via Transferência Bancária';
        o3.Frete__c = 'Contratação do Frete por conta do Remetente (CIF)';
        o3.Vendedor__c = u.Id;
        o3.Ordem_de_trabalho__c = wo.Id;
        o3.EffectiveDate = Date.newInstance(2023,08,17);
		//o3.OrderNumber = '00014857';
        insert o3;
        
        o3.Acao_interna__c = true;
        update o3;

        System.debug(o3.Name);
        
        Test.stopTest();
        

//        o.Name = 'Teste1';
//        update o;

//        Order o = new Order();
//        o.AccountId = '00175000007dYHKAA2';
//        o.Status_Permissao__c = false;
//        o.Al_quota_Vendedor__c = 1;
//        o.Acao_interna__c = false;
//        o.Pricebook2Id = '01si0000000I7SxAAK';
//        o.Condicao_de_pagamento__c = 'À Vista - Antecipado';
//        o.EffectiveDate = Date.newInstance(2022,03,19);
//        o.Data_do_Pagamento__c = Date.newInstance(2022,03,22);
//        o.Departamento3__c = 'Comercial';
//        o.Entrega_parcial__c = 'Autorizada';
//        o.Faturamento_Feito__c = '00175000007dYHKAA2';
//        o.Forma_de_pagamento2__c = 'Recebimento em Dinheiro';
//        o.CurrencyIsoCode = 'BRL';
//        o.Natureza_de_Opera_o__c = 'VENDA';
//        o.Necess_rio_Treinamento__c = 'NÃO';
//        o.AccountId = '00175000007dYHKAA2';
//        o.Nome_do_Pagador__c = 'Alvares Al';
//        o.Observacoes_Gerais__c = 'teste';
//        o.IsReductionOrder = false;
//        o.Per_odo_do_contrato_Fim__c = Date.newInstance(2022,03,31);
//        o.Periodo_do_contrato_inicio__c = Date.newInstance(2022,03,31);
//        o.Pesq_Satisfacao_Enviada__c = false;
//        o.Prazo_de_entrega__c = Date.newInstance(2022,03,17);
//        o.OwnerId = '00531000006UzZsAAK';
//        o.Status = 'Rascunho';
//        o.Frete__c = 'Contratação do Frete por conta do Remetente (CIF)';
//        o.RecordTypeId = '0126e000001YbEaAAK';
//        o.Total_Faturado__c = 0;
//        o.Valor_Recebido__c = 54.6;
//        o.Vendedor__c = '00531000006UzZsAAK';
//        insert o;

//        Product2 p = new Product2(Name='Teste',ProductCode='234234');
//        insert p;
        
//		OrderItem oi = new OrderItem(UnitPrice=5,Quantity=10, Status__c='Novo',	OrderId=o.Id);
//		insert oi;
        
//        o.Observacoes_Gerais__c = 'não teste';
//        update o;
        
    }    
}