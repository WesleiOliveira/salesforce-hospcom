export async function load(soql) {
    //console.log("Loading Registro de Sync");

    const query = `select CreatedDate, Qtd_registro_criados_atualizados__c 
                   from Registro_de_Sincronizacao__c 
                   where Objeto__c = 'Conta a Receber' 
                   and Third_Party__c = 'SAP' 
                   Order by CreatedDate DESC limit 1`;

    try {
        const result = await soql({ soql: query });

        const now = new Date();

        if (result && result.length > 0) {
            const item = result[0];
            const date = new Date(item.CreatedDate);
            const day = String(date.getDate()).padStart(2, '0');
            const month = String(date.getMonth() + 1).padStart(2, '0');
            const year = date.getFullYear();
            const hours = String(date.getHours()).padStart(2, '0');
            const minutes = String(date.getMinutes()).padStart(2, '0');
            const seconds = String(date.getSeconds()).padStart(2, '0');
          
            const createdDateLabel = `${day}/${month}/${year} ${hours}:${minutes}:${seconds}`;
            
            // Calcula a diferença em minutos
            const diffInMs = now - date;
            const diffInMinutes = Math.floor(diffInMs / (1000 * 60));
            
            const qtd = item.Qtd_registro_criados_atualizados__c || 0;
            const isRecent = diffInMinutes < 60;

            return {
                createdDateLabel: createdDateLabel,
                aOuEm: isRecent ? 'à' : 'em',
                updatedAt: isRecent ? diffInMinutes : createdDateLabel,
                qtdRegistros: qtd,
                jaPodeSincronizar: diffInMinutes >= 3,
                title: `Síncronizado ${isRecent ? 'à' : 'em'} ${isRecent ? `${diffInMinutes} minuto${diffInMinutes > 0 ? '' : 's'}` : createdDateLabel} ${qtd} notas atualizadas/criadas`
            };
        }
        else {
            console.warn("Nenhum registro encontrado");
            return null;
        }
    } catch(e) {
        console.error('Erro ao carregar Registro de Sync', e);
        return null;
    }
}