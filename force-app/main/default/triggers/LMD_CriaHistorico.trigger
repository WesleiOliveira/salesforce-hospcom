trigger LMD_CriaHistorico on L_M_D__c (after update) {
    List<HISTORICO_DE_REVISAO__c> historicoList = new List<HISTORICO_DE_REVISAO__c>();

    for (L_M_D__c lmd : Trigger.new) {
        L_M_D__c oldLmd = Trigger.oldMap.get(lmd.Id);

        HISTORICO_DE_REVISAO__c historico = new HISTORICO_DE_REVISAO__c();
        historico.L_M_D__c = lmd.Id;
        historico.Procedimento_do_Sistema_de_Qualidade__c = lmd.Id_PSQ__c;
        historico.Item__c = '';
        historico.Natureza_da_Alteracao__c = lmd.Natureza_da_Altera_o__c;
        historico.Data__c = System.today();

        
        for (Schema.SObjectField field : L_M_D__c.SObjectType.getDescribe().fields.getMap().values()) {
            if (lmd.get(field) != oldLmd.get(field)) {
                String fieldLabel = field.getDescribe().getLabel();
                Pattern pattern = Pattern.compile('^\\d+\\..*');
                Matcher matcher = pattern.matcher(fieldLabel);
                if (matcher.matches()) {
                    if (!String.isEmpty(historico.Item__c)) {
                        historico.Item__c += ', ';
                    }
                    historico.Item__c += fieldLabel.substringBefore('.');
                }
            }
        }

        if (!String.isEmpty(historico.Item__c)) {
            historicoList.add(historico);
        }
    }

    if (!historicoList.isEmpty()) {
        insert historicoList;
    }
}