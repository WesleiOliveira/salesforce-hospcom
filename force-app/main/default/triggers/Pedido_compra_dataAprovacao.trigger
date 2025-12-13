trigger Pedido_compra_dataAprovacao on Pedido_de_compra__c (before update) {

    List<Pedido_de_compra__c> pedidosAtualizar = new List<Pedido_de_compra__c>();

    // Consulta para obter o ID do processo de aprovação "Aprovacao_de_compra_estoque"
    ProcessDefinition approvalProcessDefinition = [
        SELECT Id
        FROM ProcessDefinition
        WHERE DeveloperName = 'Aprovacao_Financeira2'
        LIMIT 1
    ];

    try{
        if (approvalProcessDefinition != null) {
            for (Pedido_de_compra__c pedido : Trigger.new) {
                // Verifica se houve alteração no registro
                
                if (pedido.Status__c == '5 - Concluído') {
                    
                    String a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';
                    
                    
                    Id processInstanceId = [SELECT Id
                                            FROM ProcessInstance
                                            WHERE TargetObjectId = :pedido.Id
                                            AND ProcessDefinitionId = :approvalProcessDefinition.Id
                                            ORDER BY CreatedDate DESC
                                            LIMIT 1].Id;
                    
                    
                    // Consulta para obter informações sobre as etapas do processo de aprovação
                    ProcessInstanceStep approvalStep = [
                        SELECT Id, StepStatus, CreatedDate,ProcessInstanceId
                        FROM ProcessInstanceStep
                      	WHERE ProcessInstanceId = :processInstanceId AND StepStatus ='Approved'
                        ORDER BY CreatedDate DESC
                        LIMIT 1
                    ];
                    
                    
                    System.debug('approvalStep: ' + approvalStep);
                    System.debug('approvalStep: ' + approvalStep);
                    // Atualiza a data de aprovação se a etapa estiver aprovada
                    if (approvalStep != null && approvalStep.StepStatus == 'Approved') {
                        Integer ano = approvalStep.CreatedDate.date().year();
                        Integer mes = approvalStep.CreatedDate.date().month();
                        Integer dia = approvalStep.CreatedDate.date().day();
                        
                        // Formate o dia e o mês para incluir um zero à frente para valores abaixo de 10
                        String diaFormatted = String.valueOf(dia).leftPad(2, '0');
                        String mesFormatted = String.valueOf(mes).leftPad(2, '0');
                        
                        String dataNow =  ano + '-' + mesFormatted + '-' + diaFormatted;
                        System.debug('data: ' + dataNow);
                        
                        pedido.Data_de_aprova_o__c =  Date.valueOf(dataNow);
                        
                        System.debug('Pedido: ' + pedido);
                        update pedido;
                    }
                }
            }
        }
        
          System.debug('Antes de atualizar : ' + pedidosAtualizar);
        //update pedidosAtualizar;
        
          System.debug('Atualizou : ' );
    }catch(Exception e){
        System.debug('Error: ' + e);
    }
}