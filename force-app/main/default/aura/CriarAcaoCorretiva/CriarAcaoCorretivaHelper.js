({
       queryUserAndOc: function(cmp, userId, recordId) {
        if (!recordId || !userId) {
            console.error("RecordId ou UserId vazio");
            cmp.set("v.ocReady", false);
            return Promise.resolve(null);
        }

        // Lista de usuários bypass
        const USER_BYPASS_IDS = ["00531000006UzZsAAK"];
        const PROFILE_BYPASS_IDS = ["00e31000001dwIYAAY"]; //Analista qualidade

        // 1️⃣ Consulta User
        const userQuery = `
            SELECT Id, Name, E_gerente__c,
            ProfileId
            FROM User
            WHERE IsActive = true
            AND Id = '${userId}'
        `;

        return this.soql(cmp, userQuery)
            .then(userResult => {
                if (!userResult || userResult.length === 0) {
                    console.warn("Nenhum usuário encontrado para o Id:", userId);
                    cmp.set("v.ocReady", false);
                    return null;
                }

                const user = userResult[0];
                const profileOk = PROFILE_BYPASS_IDS.includes(user.ProfileId)
                const isGerente = user.E_gerente__c === true;
                const isBypass = USER_BYPASS_IDS.includes(user.Id);

                // 2️⃣ Consulta Ocorrência
                const ocQuery = `
                    SELECT 
                        Id,
                        Name,
                        Status__c,
                        Responsavel_pela_ocorrencia__r.Id,
                        Responsavel_pela_ocorrencia__r.FirstName,
                        Responsavel_pela_ocorrencia__r.LastName,
                        Responsavel_pela_ocorrencia__r.Gestor__c,
                        CreatedDate,
                        Descri_o_Detalhada_da_Ocorr_ncia__c,
                        Possiveis_causas__c,
                        Sugest_o_para_Resolu_o__c,
                        Departamento__c,
                        Observacoes__c,
                        datahora_abertura__c
                    FROM Ocorrencia__c
                    WHERE Id = '${recordId}'
                `;

                return this.soql(cmp, ocQuery)
                    .then(ocResult => {
                        if (!ocResult || ocResult.length === 0) {
                            console.warn("Nenhuma ocorrência encontrada para o Id:", recordId);
                            cmp.set("v.ocReady", false);
                            cmp.set("v.oc", null);
                            return { user, oc: null, ocReady: false, isGerente, isBypass };
                        }

                        const oc = ocResult[0];
                        cmp.set("v.oc", oc);
       

                        const responsavel = oc.Responsavel_pela_ocorrencia__r;
                        const statusOk = oc.Status__c === 'Em Análise';
                        const responsavelPreenchido = responsavel && responsavel.Id;
                        const userIsGestor = responsavelPreenchido && responsavel.Gestor__c === userId;

                        // Oc ready se usuário for gerente, bypass ou gestor do responsável
                        const ocReady = statusOk && responsavelPreenchido && (isGerente || isBypass || userIsGestor || profileOk);
                        cmp.set("v.ocReady", ocReady);

                        return { user, oc, ocReady, isGerente, isBypass, userIsGestor };
                    });
            })
            .catch(error => {
                console.error("Erro ao consultar User ou Ocorrência:", error);
                cmp.set("v.ocReady", false);
                return null;
            });
    },
       

    criarAc : function(cmp, oc, event) {
        if (!oc) {
            console.error("Ocorrência inválida");
            return;
        }
           console.log("OC: ", JSON.stringify(oc));
         // Garante que os campos relacionados existem
    const resp = oc.Responsavel_pela_ocorrencia__r ? oc.Responsavel_pela_ocorrencia__r : {};
          const contactId = oc.ContactId || '';
    const createdBy = oc.CreatedBy ? oc.CreatedBy : {};

        // Monta o HTML do resumo
    const resumoHtml = `
<h2 style="text-align: center;"><span style="color: rgb(1, 8, 118);">Resumo da Ocorrência</span></h2>
<table style="width: 100%; border-collapse: collapse; margin-bottom: 20px; white-space: pre;">
<tbody>
<tr>
<td style="padding: 6px 10px; width: 30%; font-weight: bold;">Ocorrência:</td>
<td style="padding: 6px 10px;">${oc.Name || ''}</td>
</tr>
<tr style="background-color: #f9f9f9;">
<td style="padding: 6px 10px; font-weight: bold;">Departamento:</td>
<td style="padding: 6px 10px;">${oc.Departamento__c || ''}</td>
</tr>
<tr>
<td style="padding: 6px 10px; font-weight: bold; vertical-align: top;">Descrição:</td>
<td style="padding: 6px 10px;">${oc.Descri_o_Detalhada_da_Ocorr_ncia__c || ''}</td>
</tr>
<tr style="background-color: #f9f9f9;">
<td style="padding: 6px 10px; font-weight: bold;">Possíveis causas:</td>
<td style="padding: 6px 10px;">${oc.Possiveis_causas__c || ''}</td>
</tr>
<tr>
<td style="padding: 6px 10px; font-weight: bold;">Sugestão para resolução:</td>
<td style="padding: 6px 10px;">${oc.Sugest_o_para_Resolu_o__c || ''}</td>
</tr>
<tr style="background-color: #f9f9f9;">
<td style="padding: 6px 10px; font-weight: bold;">Responsável:</td>
<td style="padding: 6px 10px;">${resp.FirstName || ''} ${resp.LastName || ''}</td>
</tr>
<tr>
<td style="padding: 6px 10px; font-weight: bold;">Observações:</td>
<td style="padding: 6px 10px;">${oc.Observacoes__c || ''}</td>
</tr>
</tbody>
</table>
<p><br></p>
<p>
<em style="font-size: 11px;">Criado por</em> 
<strong style="font-size: 11px;">${createdBy.FirstName || ''} ${createdBy.LastName || ''}</strong>
<em style="font-size: 11px;"> em </em> 
<strong style="font-size: 11px;">${oc.datahora_abertura__c || ''}</strong>
</p>
`;
        
        var createRecordEvent = $A.get("e.force:createRecord");
        
        createRecordEvent.setParams({
            entityApiName: "Acao_corretiva__c",
            defaultFieldValues: {
                Causas__c: oc.Possiveis_causas__c || '',
                Data_da_abertura_do_RCA__c: oc.CreatedDate,
                Descri_o_da_Ocorr_ncia__c: oc.Descri_o_Detalhada_da_Ocorr_ncia__c || '',
                Entregue_por__c: oc.ContactId || '',
                Ocorrencia__c: oc.Id,
                Origem__c: 'OCORRÊNCIA',
                Resumo_da_Ocorr_ncia__c: resumoHtml,
                Status__c: 'Pendente',
                Sugest_o_para_Resolu_o__c: oc.Sugest_o_para_Resolu_o__c || '',
                Responsevel__c: oc.Responsavel_pela_ocorrencia__c,
            }
        });
        createRecordEvent.fire();
    }
                                

})