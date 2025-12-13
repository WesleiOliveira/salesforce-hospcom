public class numerarNovoEvento {

    public static void numerarNovoEvento(Campaign novoEvento) {
        // Verifica se o evento é de treinamento
        if (novoEvento == null || novoEvento.treinamento__c != true) {
            return;
        }

        // Busca todos os eventos de treinamento existentes, ordenados por CreatedDate
        List<Campaign> eventosExistentes = [
            SELECT Id, CreatedDate
            FROM Campaign
            WHERE treinamento__c = true AND Id != :novoEvento.Id
            ORDER BY CreatedDate
        ];

        
        Integer proximoNumero = eventosExistentes.size() + 1;
        String numeroFormatado = formatoComZeros(proximoNumero);

        // Atualiza o campo no novo evento
        novoEvento.Contagem_Eventos_de_Treinamento__c = numeroFormatado;
    }

    // Função para formatar o número com zeros à esquerda
    private static String formatoComZeros(Integer numero) {
        String numeroStr = String.valueOf(numero);
        while (numeroStr.length() < 4) {
            numeroStr = '0' + numeroStr;
        }
        return numeroStr;
    }
}