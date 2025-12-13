trigger AuditoriaEstrSem on Auditoria_Estrutural_Semanal__c (before insert, before update, after insert, after update) {
   /* 
    O trigger atua em duas fases: Before e After. Na fase Before (antes de inserir ou atualizar),
    ele percorre 26 pares de campos, onde cada par consiste em uma pergunta (ex.: pergunta1__c) e sua
    descrição correspondente (ex.: d1__c). Se uma pergunta for marcada como "NC", o trigger exige que
    o campo de descrição esteja preenchido. Caso contrário, adiciona um erro diretamente no campo da descrição,
    impedindo a gravação. Além disso, durante uma atualização, se existir alguma pergunta com "NC", o trigger
    verifica se o registro possui anexos e, se não houver, bloqueia a operação com uma mensagem de erro.
    Na fase After (após salvar), para cada par de pergunta/descrição, se o valor da pergunta mudou para "NC" (comparando com o registro antigo),
    o código cria um registro de Não Conformidade, utilizando a descrição informada, vinculando-o à auditoria,
    à empresa e ao owner do registro. Dessa forma, o trigger garante que as não conformidades sejam registradas
    corretamente e que os dados obrigatórios estejam preenchidos antes de salvar o registro.   
    Victor Gabriel
    */ 
    
    // Mapa dos campos do objeto para acesso dinâmico
    Map<String, Schema.SObjectField> fieldMap = Auditoria_Estrutural_Semanal__c.getSObjectType().getDescribe().fields.getMap();

    // Bloco Before: Validação de preenchimento da descrição quando a pergunta for "NC"
    // (Esta validação é aplicada tanto para insert quanto para update)
    if (Trigger.isBefore) {
        for (Auditoria_Estrutural_Semanal__c auditoria : Trigger.new) {
            Boolean hasNC = false;
            // Loop para verificar cada par pergunta/descrição
            for (Integer i = 1; i <= 26; i++) {
                String perguntaField = 'pergunta' + i + '__c';
                String descField = 'd' + i + '__c';
                
                if (fieldMap.containsKey(perguntaField) && fieldMap.containsKey(descField)) {
                    String perguntaValue = String.valueOf(auditoria.get(perguntaField));
                    
                    // Se a pergunta estiver marcada como "NC", verifica a descrição
                    if (perguntaValue == 'NC') {
                        hasNC = true;
                        String descValue = String.valueOf(auditoria.get(descField));
                        // Se a descrição estiver vazia ou nula, adiciona erro no campo de descrição
                        if (descValue == null || descValue.trim() == '') {
                            // Adiciona o erro apontando especificamente o campo de descrição
                            auditoria.addError(fieldMap.get(descField), 
                                'A descrição é obrigatória quando Não Conforme.');
                        }
                    }
                }
            }
            // Se estiver em update e houver pelo menos uma pergunta "NC", verifica se há anexos
            if (Trigger.isUpdate && hasNC) {
                Integer qtdAnexos = [SELECT COUNT() FROM ContentDocumentLink WHERE LinkedEntityId = :auditoria.Id];
                if (qtdAnexos == 0) {
                    auditoria.addError('É obrigatório anexar uma imagem para campos Não Conformes.');
                }
            }
        }
    }

    // Bloco After: Criação dos registros de Não Conformidade para perguntas que mudaram para "NC"
    if (Trigger.isAfter) {
        List<Nao_Conformidade__c> ncs = new List<Nao_Conformidade__c>();

        for (Auditoria_Estrutural_Semanal__c auditoria : Trigger.new) {
            Auditoria_Estrutural_Semanal__c oldAuditoria = Trigger.oldMap != null ? Trigger.oldMap.get(auditoria.Id) : null;
            for (Integer i = 1; i <= 26; i++) {
                String perguntaField = 'pergunta' + i + '__c';
                String descField = 'd' + i + '__c';
                
                if (fieldMap.containsKey(perguntaField) && fieldMap.containsKey(descField)) {
                    String perguntaValue = String.valueOf(auditoria.get(perguntaField));
                    String oldPerguntaValue = oldAuditoria != null ? String.valueOf(oldAuditoria.get(perguntaField)) : null;
                    String descricaoValue = String.valueOf(auditoria.get(descField));
                    
                    // Cria uma nova Não Conformidade se o valor da pergunta mudou para "NC"
                    if (perguntaValue == 'NC' && oldPerguntaValue != 'NC') {
                        Nao_Conformidade__c nc = new Nao_Conformidade__c();
                        nc.Auditoria_Estrutural_Semanal__c = auditoria.Id;
                        nc.Descricao__c = descricaoValue;
                        nc.Data_de_Abertura_do_RNC__c = System.today();
                        nc.OwnerId = auditoria.OwnerId;
                        ncs.add(nc);
                    }
                }
            }
        }
        if (!ncs.isEmpty()) {
            Database.insert(ncs, false);
        }
    }
}