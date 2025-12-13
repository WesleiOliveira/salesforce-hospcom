trigger TarefaStatusMap on Task (before update) {
    DateTime now = System.now();

    for (Task t : Trigger.new) {
        Task oldT = Trigger.oldMap.get(t.Id);

        if (t.Status != oldT.Status) {
            // Calcula o tempo decorrido desde o início do andamento
            if (oldT.Inicio_andamento__c != null) {
                Long diffMillis = now.getTime() - oldT.Inicio_andamento__c.getTime();
                Integer minutos = Integer.valueOf(diffMillis / (1000 * 60));

                // Se saiu de "Em andamento", acumula tempo de execução
                if (oldT.Status == 'Em andamento') {
                    Integer tempoAnterior = oldT.Tempo_de_execu_o__c != null ? Integer.valueOf(oldT.Tempo_de_execu_o__c) : 0;
                    t.Tempo_de_execu_o__c = tempoAnterior + minutos;
                }

                // Se saiu de "Aguardando outra pessoa", acumula tempo parado
                if (oldT.Status == 'Aguardando outra pessoa') {
                    Integer tempoAnterior = oldT.Tempo_parado__c != null ? Integer.valueOf(oldT.Tempo_parado__c) : 0;
                    t.Tempo_parado__c = tempoAnterior + minutos;
                }
            }

            // Se entrou em "Em andamento" ou "Aguardando outra pessoa", marca novo início
            if (t.Status == 'Em andamento' || t.Status == 'Aguardando outra pessoa') {
                t.Inicio_andamento__c = now;
            }

            // Se foi concluído, calcula o tempo de conclusão com base no início real e tempo parado
            //if (t.Status == 'Concluído' && t.Data_da_Conclusao__c != null && t.Inicio_andamento__c != null) {
                // Usa hora atual para combinar com o campo de data (caso Data_da_Conclusao__c seja Date)
              //  DateTime dataConclusaoDT = DateTime.newInstance(t.Data_da_Conclusao__c, now.time());

            //    Long diffMillis = dataConclusaoDT.getTime() - t.Inicio_andamento__c.getTime();
             //   Integer minutosTotais = Integer.valueOf(diffMillis / (1000 * 60));
                
               // Integer minutosParado = t.Tempo_parado__c != null ? Integer.valueOf(t.Tempo_parado__c) : 0;
                //
             //   Integer tempoFinal = minutosTotais - minutosParado;
            //    t.Tempo_de_Conclus_o__c = tempoFinal >= 0 ? tempoFinal : 0;
            
            
            // Sempre atualiza o último status anterior
            t.Ultimo_Status__c = oldT.Status;
        

        // Preenche Data de Início se ainda não estiver preenchida
        if (t.Data_e_Hora_de_In_cio__c == null) {
            t.Data_e_Hora_de_In_cio__c = t.CreatedDate;
        }
    }
}
}