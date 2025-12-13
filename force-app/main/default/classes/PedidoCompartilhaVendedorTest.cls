@isTest
public class PedidoCompartilhaVendedorTest {
    
    @isTest
    public static void testPedidoCompartilhaVendedor(){
        
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
        
		Order o = new Order();
		o.RecordTypeId = '0126e000001YbEaAAK';
        o.Status = 'Aprovado';
        o.Name = 'Teste';
        o.AccountId = a.Id;
        o.Faturamento_Feito__c = a.Id;
        o.Condicao_de_pagamento__c = 'À vista - Paga e Retira';
        o.Forma_de_pagamento2__c = 'Recebimento via Transferência Bancária';
        o.Frete__c = 'Contratação do Frete por conta do Remetente (CIF)';
        o.Vendedor__c = u.Id;
        o.EffectiveDate = Date.newInstance(2023,05,10);
        o.OwnerId = u.Id;
		insert o;
    }

}