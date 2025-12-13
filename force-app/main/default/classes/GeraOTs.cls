public class GeraOTs {
    @AuraEnabled 
    public static string gerar(string conta, string faturamento, string local, string contato, string tecnico, string responsavel, string status, string tipoRegistro, string categoria, string assunto, string pertence, string SN, string contrato, string itensAcompanham, string problemaRelatado, dateTime dataPrevista, dateTime dataAgendada){
        
        List<String> lstString = SN.split(','); //Separa cada SN e adiciona em Lista
        List<Asset> ativos = [SELECT ID FROM Asset WHERE SerialNumber in : lstString];

        // User usuario = [SELECT ID, ContactId FROM USER WHERE ID = : responsavel];
        // Contact contatoOwner = [SELECT ID FROM Contact WHERE ID =: usuario.ContactId];
        
        List<WorkOrder> OTS = new List<WorkOrder>();
        
        Integer quantidade = 0;

        //Cria a OT para cada número de série
        for(Asset ativo : ativos){
            WorkOrder ot = new WorkOrder();
            ot.AssetId = ativo.Id;
            ot.Ignorar_fluxos__c = true;
            ot.AccountId = conta;
            // ot.Tecnico_executor__c = contatoOwner.Id;
            ot.Tecnico_executor__c = responsavel; //ADICIONADA
            ot.ContactId = contato;
            // ot.T_cnico_Respons_vel__c = tecnico;
            // ot.OwnerId = responsavel;
            ot.Status = status;
            ot.RecordTypeId = tipoRegistro;
            ot.Categoria__c = categoria;
            ot.Subject = assunto;
            ot.Equipamento_Pertence_ao__c = pertence;
            ot.Faturamento_feito2__c = faturamento;
            ot.Local_de_Atendimento__c = local;
            ot.Data_Agendada_para_Servi_o__c = dataAgendada;
            ot.Data_Prevista_para_o_Fim_do_Servi_o__c = dataPrevista;
            ot.Acess_rios_que_Acompanham_o_Equipamento__c = itensAcompanham;
            ot.Description = problemaRelatado;
            if(contrato != ''){
            ot.Contrato_de_Servi_o_Relacionado_v2__c = contrato;
            }
            OTS.add(ot);
            quantidade ++;
        }
        try{
            insert OTS;
            return('Foram criadas ' + quantidade + ' OTs com sucesso.');
        }
        catch(Exception e){
            return(e.getMessage());
        }
    }
}