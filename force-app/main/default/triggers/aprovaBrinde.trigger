trigger aprovaBrinde on Brinde__c (before insert, after insert) {

    for(Brinde__c b : Trigger.new) {
        if (Trigger.isBefore) {
            Account a = [SELECT BillingState FROM Account WHERE Id = :b.Conta__c];

            switch on a.BillingState {
                when 'Acre', 'Amapá', 'Amazonas', 'Pará', 'Rondônia', 'Roraima' {
                    b.Gestor__c = '0056e00000CqadRAAR'; // Luckas '00531000006UzZsAAK'; //
                } 
                when 'Alagoas', 'Bahia', 'Ceará', 'Espírito Santo', 'Goiás','Maranhão', 'Mato Grosso', 'Minas Gerais', 'Paraíba', 'Paraná', 'Pernambuco', 
                     'Piauí', 'Rio de Janeiro', 'Rio Grande do Norte', 'Rio Grande do Sul', 'Santa Catarina', 'Sergipe', 'Tocantins' {
                    b.Gestor__c = '0055A000008puvcQAA'; // Jackeline '00531000006UzZsAAK'; //
                } 
                when 'Distrito Federal' {
                    b.Gestor__c = '005U4000000hRcrIAE'; // Manuel
                } 
                when 'Mato Grosso do Sul', 'São Paulo' {
                    b.Gestor__c = '005U4000002p3Ni'; // Odair '00531000006UzZsAAK'; //
                } 
                when else {
                    b.addError('Erro: Conta com estado de endereço de cobrança não encontrado ou preenchido incorretamente.');
                }
            }

        } else if (Trigger.isAfter) {
            Brinde__Share bs = new Brinde__Share();
            bs.AccessLevel = 'Edit';
            bs.ParentId = b.Id;
            bs.UserOrGroupId = b.Gestor__c;
            insert bs;
        }
    }
}