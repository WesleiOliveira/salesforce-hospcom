@isTest(SeeAllData=true)
public class FaturamentoCompartilhaTEST {

    @isTest
    private static void test() {
        
        //Faturamento__c f = new Faturamento__c();
        //f.Pedido__c = OrderId;
        //f.Tipo__c = fj.Tipo;
        //f.Name = '5775';
        //f.Status__c = 'RECEBIMENTO TOTAL';
        //f.Data__c = '2018';
        //f.Chave_de_acesso__c = fj.ChaveNF;
        //f.Nome_da_Conta2__c = AccountClientId;
        //f.Valor_Faturado__c = 639.5;
        //f.Faturamento_Feito2__c = AccountFilialId;
        //f.Departamento3__c = Departamento;
        //f.RecordTypeId = '01231000001AjhtAAC';

        //Account acc = new Account();
        //acc.Name = 'Teste';
        //acc.CNPJ__c = '51.461.458/0001-89';
        //insert acc;
        
        //Asset ativo = new Asset();
        //ativo.Faturamento__c = fat.Id;
	    //ativo.IsCompetitorProduct = false;
    	//ativo.Name = 'APARELHO DE ANESTESIA';
    	//ativo.SerialNumber = 'M1198447';
	    //ativo.Price = 141000;
    	//ativo.OwnerId = '005i0000000ImClAAK';
	    //ativo.Marca__c = 'GE HEALTHECARE';
    	//ativo.Numero_NF__c = '6656';
	    //ativo.Especialidade__c = 'ANESTESIA';
    	//ativo.Modelo__c = '9100C';
    	//ativo.Nome_do_Ativo__c = 'APARELHO DE ANESTESIA';
	    //ativo.Disponivel_p_contratos__c = 'Nenhum';
    	//ativo.Dispon_vel_em_Contratos__c = false;
		//ativo.Necessario_manutencao_preventiva__c = false;
        //ativo.AccountId = acc.Id;
        //ativo.ContactId = 'asdf';
        //insert ativo;

        //User u = new User();
        //u.Username = '3e9100ffb8461f574a998f849d86dd7d@t.com';
        //u.LastName = 'Teste';
        //u.Email = 'e4e36da98f5950735b5e89c708544947@t.com';
        //u.Alias = 'Teste';
        //u.TimeZoneSidKey = 'GMT';
        //u.LocaleSidKey = 'pt_BR';
        //u.EmailEncodingKey = 'UTF-8';
        //u.ProfileId = '00e6e000002JPriAAG'; 
        //u.LanguageLocaleKey = 'pt_BR';
        //u.Ignorar_erros__c = true;
        //insert u;             
        
		//Order o = new Order();
		//o.RecordTypeId = '0126e000001YbEaAAK';
        //o.Status = 'Aprovado';
        //o.Name = 'Teste';
        //o.AccountId = acc.Id;
        //o.Faturamento_Feito__c = acc.Id;
        //o.Condicao_de_pagamento__c = 'À vista - Paga e Retira';
        //o.Forma_de_pagamento2__c = 'Recebimento via Transferência Bancária';
        //o.Frete__c = 'Contratação do Frete por conta do Remetente (CIF)';
        //o.Natureza_de_Opera_o__c = 'SERVIÇO';
        //o.Vendedor__c = u.Id;
        //o.EffectiveDate = Date.newInstance(2023,09,10);
        //o.OwnerId = u.Id;
		//insert o;
        
        //OrderShare os = new OrderShare();
        //os.OrderId = o.Id;
        //os.UserOrGroupId = u.Id;
        //os.OrderAccessLevel = 'Read';
        //insert os;
        
        //Contrato_de_servico__c c = new Contrato_de_servico__c();
        //c.Name = '23452345';
		//insert c;
        
        Faturamento__c fat = new Faturamento__c();
        fat.Name = '5775';
        fat.Valor_Faturado__c = 639.5;
        fat.Status__c = 'Aberto';
        fat.Qtd_Ativos__c = 0;
        fat.Contrato_de_Servi_o__c = null;
        fat.Procedencia__c = 'Serviço Avulso';
        fat.Canhoto_assinado__c = false;
        fat.Pedido__c = '8016e000008V3gaAAC';
        insert fat;

        Faturamento__c fat2 = new Faturamento__c();
        fat2.Name = '5775';
        fat2.Valor_Faturado__c = 639.5;
        fat2.Status__c = 'Aberto';
        fat2.Qtd_Ativos__c = 0;
        fat2.Contrato_de_servico__c = 'a1Y6e00000EOLewEAH';
        fat2.Procedencia__c = 'Serviço Avulso';
        fat2.Canhoto_assinado__c = false;
        insert fat2;


        //fat.Pedido__c = o.Id;
        //fat.Contrato_de_Servi_o__c = c.Id;
        //update fat;
        
    }
    
    
}