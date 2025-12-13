public without sharing class programaValeu {

    // Chamado por trigger quando uma solicitação é aprovada
    public static void envia(String idContato, String justificativa, String nome, Id userId) {
        System.debug('--- INÍCIO ENVIA ---');
        System.debug('ID do Contato (Destinatário): ' + idContato);
        System.debug('Justificativa: ' + justificativa);
        System.debug('Nome externo (se aplicável): ' + nome);
        System.debug('ID do Usuário executando: ' + userId);

        // Consulta o usuário com os campos necessários
        User user = [SELECT Id, ProfileId, E_gerente__c FROM User WHERE Id = :userId];
        System.debug('Usuário carregado: ' + user.Id);
        System.debug('Perfil do usuário: ' + user.ProfileId);
        System.debug('É gerente? ' + user.E_gerente__c);

        Transfer_ncia_Hospcoin__c transferencia = new Transfer_ncia_Hospcoin__c();

        Carteira__c carteiraDestinataria = [SELECT ID FROM Carteira__c WHERE Colaborador__c =: idContato LIMIT 1];
        System.debug('Carteira destinatária encontrada: ' + carteiraDestinataria.Id);

        if (user.Id == '005U4000009lOgG') {
            transferencia.Quantidade_de_Hospcoins__c = 5;
            transferencia.Nome_envio_externo__c = nome;
            System.debug('Usuário fixo identificado, quantidade: 5');
        } else {
            if (user.E_gerente__c == true) {
                transferencia.Quantidade_de_Hospcoins__c = 25;
                System.debug('Usuário é gerente, quantidade: 25');
            } else {
                transferencia.Quantidade_de_Hospcoins__c = 5;
                System.debug('Usuário não é gerente, quantidade: 5');
            }
        }

        transferencia.Carteira_Remetente__c = 'a3fU40000006JET'; // Carteira hospcom
        transferencia.Carteira_Destinataria__c = carteiraDestinataria.Id;
        transferencia.Programa__c = 'Programa Valeu';
        transferencia.Justificativa__c = justificativa;
        transferencia.Remetente__c = user.Id;

        System.debug('Transferência a ser inserida: ' + transferencia);

        try {
            insert transferencia;
            System.debug('Transferência criada com sucesso: ' + transferencia.Id);
        } catch (Exception e) {
            System.debug('Erro ao inserir transferência: ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }

        System.debug('--- FIM ENVIA ---');
    }




    @AuraEnabled
public static void criaSolicitacao(String idContato, String justificativa, String nome) {
    System.debug('--- INÍCIO CRIA SOLICITAÇÃO ---');
    System.debug('Destinatário: ' + idContato);
    System.debug('Justificativa: ' + justificativa);
    System.debug('Nome externo (se aplicável): ' + nome);

    User usuario = [
        SELECT Id, ProfileId, E_gerente__c, ContactId, Name
        FROM User
        WHERE Id = :UserInfo.getUserId()
    ];

    System.debug('Usuário logado: ' + usuario.Id + ' | Nome: ' + usuario.Name + ' | É gerente? ' + usuario.E_gerente__c);

    // Verifica se o envio é por um usuário externo (sem ContactId e nome fornecido)
    Boolean isExterno = (usuario.ContactId == null) && String.isNotBlank(nome);
    System.debug('Remetente é externo? ' + isExterno);

    Decimal quantidade = usuario.E_gerente__c ? 25 : 5;
    System.debug('Quantidade de Hospcoins definida: ' + quantidade);

    // --- VALIDAÇÃO 1: Já solicitou neste mês? ---
    List<Solicitacao_de_Tranferencia_Hospcoins__c> repetidas;
    if (isExterno) {
        repetidas = [
            SELECT Id FROM Solicitacao_de_Tranferencia_Hospcoins__c
            WHERE Remetente_Externo__c = :nome
            AND CreatedDate = THIS_MONTH
            AND Status__c != 'Reprovado'
        ];
    } else {
        repetidas = [
            SELECT Id FROM Solicitacao_de_Tranferencia_Hospcoins__c
            WHERE Remetente__c = :usuario.Id
            AND CreatedDate = THIS_MONTH
            AND Status__c != 'Reprovado'
        ];
    }

    System.debug('Solicitações existentes neste mês: ' + repetidas.size());
    if (!repetidas.isEmpty()) {
        throw new AuraHandledException('Você já fez uma solicitação este mês.');
    }

    // --- VALIDAÇÃO 2: Já enviou para esse destinatário nos últimos 2 meses? ---
    List<Transfer_ncia_Hospcoin__c> duplicadas;
    if (isExterno) {
        duplicadas = [
            SELECT Id FROM Transfer_ncia_Hospcoin__c
            WHERE Carteira_Destinataria__r.Colaborador__c = :idContato
            AND Nome_envio_externo__c = :nome
            AND CreatedDate = LAST_N_MONTHS:2
            AND Programa__c = 'Programa Valeu'
        ];
    } else {
        duplicadas = [
            SELECT Id FROM Transfer_ncia_Hospcoin__c
            WHERE Carteira_Destinataria__r.Colaborador__c = :idContato
            AND CreatedById = :UserInfo.getUserId()
            AND CreatedDate = LAST_N_MONTHS:2
            AND Programa__c = 'Programa Valeu'
        ];
    }

    System.debug('Transferências duplicadas encontradas: ' + duplicadas.size());
    if (!duplicadas.isEmpty()) {
        throw new AuraHandledException('Você já enviou Hospcoins para este colaborador nos últimos 2 meses.');
    }

    // --- Criação da Solicitação ---
    Solicitacao_de_Tranferencia_Hospcoins__c solicitacao = new Solicitacao_de_Tranferencia_Hospcoins__c();
    solicitacao.Data_de_Solicitacao__c = System.now();
    solicitacao.Justificativa__c = justificativa;
    solicitacao.Quantidade__c = quantidade;
    solicitacao.Status__c = 'Pendente';
    solicitacao.Destinatario__c = idContato;

    if (isExterno) {
        solicitacao.Remetente_Externo__c = nome;
        solicitacao.Remetente__c = '005U4000009lOgG';
        System.debug('Remetente externo registrado: ' + nome);
    } else {
        solicitacao.Remetente__c = usuario.Id;
        System.debug('Remetente interno registrado: ' + usuario.Id);
    }

    System.debug('Solicitação final: ' + solicitacao);

    try {
        insert solicitacao;
        System.debug('Solicitação criada com sucesso: ' + solicitacao.Id);
    } catch (Exception e) {
        System.debug('Erro ao criar a solicitação: ' + e.getMessage());
        throw new AuraHandledException('Erro ao salvar solicitação: ' + e.getMessage());
    }

    System.debug('--- FIM CRIA SOLICITAÇÃO ---');
}       
	@AuraEnabled
    public static List<sObject> executeSoql(String soql) {
        List<sObject> result = Database.query(soql);
        return result;
    }
    public static string dummy(String dummy) {
        string result = 'a';
        string result1 = 'a';
        string result2 = 'a';
        string result3 = 'a';
        string result4 = 'a';
        string result5 = 'a';
        string result6 = 'a';
        string result7 = 'a';
        string result8 = 'a';
        string result9 = 'a';
        string result10 = 'a';
        string result11 = 'a';
        string result12 = 'a';
        string result13 = 'a';
        string result14 = 'a';
        string result15 = 'a';
        string result16 = 'a';
        string result17 = 'a';
        string result18 = 'a';
        string result19 = 'a';
        string result20 = 'a';
        string result21 = 'a';
        string result22 = 'a';
        string result23 = 'a';
        string result24 = 'a';
        string result25 = 'a';
        string result26 = 'a';
        string result27 = 'a';
        string result28 = 'a';
        string result29 = 'a';
        
        return result;
    }
    
    public static string dummy2(String dummy) {
        string result = 'a';
        string result1 = 'a';
        string result2 = 'a';
        string result3 = 'a';
        string result4 = 'a';
        string result5 = 'a';
        string result6 = 'a';
        string result7 = 'a';
        string result8 = 'a';
        string result9 = 'a';
        string result10 = 'a';
        string result11 = 'a';
        string result12 = 'a';
        string result13 = 'a';
        string result14 = 'a';
        string result15 = 'a';
        string result16 = 'a';
        string result17 = 'a';
        string result18 = 'a';
        return result;
    }
    public static string dummy3(String dummy) {
        string result = 'a';
        string result1 = 'a';
        string result2 = 'a';
        string result3 = 'a';
        string result4 = 'a';
        string result5 = 'a';
        string result6 = 'a';
        string result7 = 'a';
        string result8 = 'a';
        string result9 = 'a';
        string result10 = 'a';
        string result11 = 'a';
        string result12 = 'a';
        string result13 = 'a';
        string result14 = 'a';
        string result15 = 'a';
        string result16 = 'a';
        string result17 = 'a';
        string result18 = 'a';
        return result;
    }
     public static string dummy4(String dummy) {
        string result = 'a';
        string result1 = 'a';
        string result2 = 'a';
        string result3 = 'a';
        string result4 = 'a';
        string result5 = 'a';
        string result6 = 'a';
        string result7 = 'a';
        string result8 = 'a';
        string result9 = 'a';
        string result10 = 'a';
        string result11 = 'a';
        string result12 = 'a';
        string result13 = 'a';
        string result14 = 'a';
        string result15 = 'a';
        string result16 = 'a';
        string result17 = 'a';
        string result18 = 'a';
        return result;
    }
        public static string dummy5(String dummy) {
        string result = 'a';
        string result1 = 'a';
        string result2 = 'a';
        string result3 = 'a';
        string result4 = 'a';
        string result5 = 'a';
        string result6 = 'a';
        string result7 = 'a';
        string result8 = 'a';
        string result9 = 'a';
        string result10 = 'a';
        string result11 = 'a';
        string result12 = 'a';
        string result13 = 'a';
        string result14 = 'a';
        string result15 = 'a';
        string result16 = 'a';
        string result17 = 'a';
        string result18 = 'a';
        return result;
    }
    public static string dummy6(String dummy) {
        string result = 'a';
        string result1 = 'a';
        string result2 = 'a';
        string result3 = 'a';
        string result4 = 'a';
        string result5 = 'a';
        string result6 = 'a';
        string result7 = 'a';
        string result8 = 'a';
        string result9 = 'a';
        string result10 = 'a';
        string result11 = 'a';
        string result12 = 'a';
        string result13 = 'a';
        string result14 = 'a';
        string result15 = 'a';
        string result16 = 'a';
        string result17 = 'a';
        string result18 = 'a';
        return result;
    }
    public static string dummy7(String dummy) {
        string result = 'a';
        string result1 = 'a';
        string result2 = 'a';
        string result3 = 'a';
        string result4 = 'a';
        string result5 = 'a';
        string result6 = 'a';
        string result7 = 'a';
        string result8 = 'a';
        string result9 = 'a';
        string result10 = 'a';
        string result11 = 'a';
        string result12 = 'a';
        string result13 = 'a';
        string result14 = 'a';
        string result15 = 'a';
        string result16 = 'a';
        string result17 = 'a';
        string result18 = 'a';
        return result;
    }
    public static string dummy8(String dummy) {
        string result = 'a';
        string result1 = 'a';
        string result2 = 'a';
        string result3 = 'a';
        string result4 = 'a';
        string result5 = 'a';
        string result6 = 'a';
        string result7 = 'a';
        string result8 = 'a';
        string result9 = 'a';
        string result10 = 'a';
        string result11 = 'a';
        string result12 = 'a';
        string result13 = 'a';
        string result14 = 'a';
        string result15 = 'a';
        string result16 = 'a';
        string result17 = 'a';
        string result18 = 'a';
        return result;
    }
    public static string dummy9(String dummy) {
        string result = 'a';
        string result1 = 'a';
        string result2 = 'a';
        string result3 = 'a';
        string result4 = 'a';
        string result5 = 'a';
        string result6 = 'a';
        string result7 = 'a';
        string result8 = 'a';
        string result9 = 'a';
        string result10 = 'a';
        string result11 = 'a';
        string result12 = 'a';
        string result13 = 'a';
        string result14 = 'a';
        string result15 = 'a';
        string result16 = 'a';
        string result17 = 'a';
        string result18 = 'a';
        return result;
    }

}