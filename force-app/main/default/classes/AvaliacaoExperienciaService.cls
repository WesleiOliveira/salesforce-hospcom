public with sharing class AvaliacaoExperienciaService {

    public static void enviarNotificacoesColaborador(List<Avaliacao_de_Experiencia__c> novasAvaliacoes, Map<Id, Avaliacao_de_Experiencia__c> avaliacoesAntigas){
     
        List<Avaliacao_de_Experiencia__c> avaliacoes = new List<Avaliacao_de_Experiencia__c>();
        for(Avaliacao_de_Experiencia__c avaliacao : novasAvaliacoes){
            if(avaliacao.Avaliacao_Finalizada__c == true &&
                avaliacoesAntigas.get(avaliacao.Id).Avaliacao_Finalizada__c != true){
                avaliacoes.add(avaliacao);
            }
        }

        // Obter todos os ContactIds dos gestores
        Set<Id> contatoIds = new Set<Id>();
        for (Avaliacao_de_Experiencia__c av : avaliacoes) {
            contatoIds.add(av.Nome_do_Colaborador__c);
        }

        // Buscar os usuários associados aos contatos
        Map<Id, User> contatoToUserMap = new Map<Id, User>();

        List<User> usuarios = [SELECT Id, ContactId FROM User WHERE ContactId IN :contatoIds];
        for(User usuario : usuarios) {
            contatoToUserMap.put(usuario.ContactId, usuario);
        }
        

        // Template de e-mail
        EmailTemplate template = [
            SELECT Id FROM EmailTemplate
            WHERE DeveloperName = 'NotificaColaboradorAvaliacaoExperiencia'
            LIMIT 1
        ];

        // Tipo de notificação personalizada (sino)
        String developerName = 'Notificao_Avaliacao_de_Experiencia';
        CustomNotificationType tipoNotificacao = [
            SELECT Id FROM CustomNotificationType
            WHERE DeveloperName = :developerName
            LIMIT 1
        ];

        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        List<notificaoDTO> notificacoes = new List<notificaoDTO>();

        for (Avaliacao_de_Experiencia__c av : avaliacoes) {
            User user = contatoToUserMap.get(av.Nome_do_Colaborador__c);

            // E-mail
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setTemplateId(template.Id);
            email.setTargetObjectId(av.Nome_do_Colaborador__c);
            email.setWhatId(av.Id);
            email.setSaveAsActivity(false);
            emails.add(email);

            if (user == null) continue; 

            notificaoDTO dto = new notificaoDTO();
            dto.targetId = av.Id;
            dto.title = 'Feedback Avaliação de experiência';
            dto.body = 'Por favor, confirme se você está ciente da avalição';
            dto.notificationTypeId = tipoNotificacao.Id;
            dto.userId = user.Id;
            notificacoes.add(dto);
        }

        // Enviar e-mails
        if (!emails.isEmpty()) {
            Messaging.sendEmail(emails);
        }

        // Enviar notificações
        for (notificaoDTO dto : notificacoes) {
            // Notificação personalizada (sino)
            Messaging.CustomNotification notificacao = new Messaging.CustomNotification();
            notificacao.setTitle(dto.title);
            notificacao.setBody(dto.body);
            notificacao.setNotificationTypeId(dto.notificationTypeId);
            notificacao.setTargetId(dto.targetId); // UserId
            notificacao.send(new Set<String>{dto.userId});
        }  
    }

    public static void enviarNotificacoesGestor() {
        Date hoje = Date.today();
        Set<Date> datasAlvo = new Set<Date>{
            hoje.addDays(10),
            hoje.addDays(5),
            hoje.addDays(1)
        };

        // Buscar avaliações com contatos de gestor
        List<Avaliacao_de_Experiencia__c> avaliacoes = [
            SELECT Id, Name, Data_Fim__c, Status__c,
                Gestor2__c, NotificacaoNomeGestor__c, NotificacaoNomeColaborador__c,
                NotificacaoDiasParaVencimento__c
            FROM Avaliacao_de_Experiencia__c
            WHERE Data_Fim__c IN :datasAlvo
            AND Avaliacao_Finalizada__c = false
            AND Gestor2__c != null
        ];

        System.debug('Avaliacoes: ' + avaliacoes.size());

        if (avaliacoes.isEmpty()) return;

        // Obter todos os ContactIds dos gestores
        Set<Id> contatoIds = new Set<Id>();
        for (Avaliacao_de_Experiencia__c av : avaliacoes) {
            contatoIds.add(av.Gestor2__c);
        }

        // Buscar os usuários associados aos contatos
        Map<Id, User> contatoToUserMap = new Map<Id, User>();

        List<User> usuarios = [SELECT Id, ContactId FROM User WHERE ContactId IN :contatoIds];
        for(User usuario : usuarios) {
            contatoToUserMap.put(usuario.ContactId, usuario);
        }
        

        // Template de e-mail
        EmailTemplate template = [
            SELECT Id FROM EmailTemplate
            WHERE DeveloperName = 'NotificaVencimentoAvalicaoExperiencia'
            LIMIT 1
        ];

        // Tipo de notificação personalizada (sino)
        String developerName = 'Notificao_Avaliacao_de_Experiencia';
        CustomNotificationType tipoNotificacao = [
            SELECT Id FROM CustomNotificationType
            WHERE DeveloperName = :developerName
            LIMIT 1
        ];

        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        List<notificaoDTO> notificacoes = new List<notificaoDTO>();

        for (Avaliacao_de_Experiencia__c av : avaliacoes) {
            User user = contatoToUserMap.get(av.Gestor2__c);

            // E-mail
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setTemplateId(template.Id);
            email.setTargetObjectId(av.Gestor2__c);
            email.setWhatId(av.Id);
            email.setSaveAsActivity(false);
            emails.add(email);

            if (user == null) continue; 

            notificaoDTO dto = new notificaoDTO();
            dto.targetId = av.Id;
            dto.title = 'Avaliação de experiência prestes a vencer';
            dto.body = 'Faltam ' + av.NotificacaoDiasParaVencimento__c + ' dia(s) para o fim da avaliação do colaborador(a) "' + av.NotificacaoNomeColaborador__c + '".';
            dto.notificationTypeId = tipoNotificacao.Id;
            dto.userId = user.Id;
            notificacoes.add(dto);
        }

        if (!emails.isEmpty()) {
            Messaging.sendEmail(emails, false);
        }

        // Enviar notificações
        for (notificaoDTO dto : notificacoes) {
            // Notificação personalizada (sino)
            Messaging.CustomNotification notificacao = new Messaging.CustomNotification();
            notificacao.setTitle(dto.title);
            notificacao.setBody(dto.body);
            notificacao.setNotificationTypeId(dto.notificationTypeId);
            notificacao.setTargetId(dto.targetId); // UserId
            notificacao.send(new Set<String>{dto.userId});
        }    
    }

    public static void enviarNotificacaoDP(List<Avaliacao_de_Experiencia__c> novasAvaliacoes, Map<Id, Avaliacao_de_Experiencia__c> avaliacoesAntigas){
        List<String> ccList = new List<String>{
            'departamentopessoal@gestcombpo.com.br',
            'assistente.contabil@gestcombpo.com.br',
            'rh@gestcombpo.com.br',
            'analistarh@gestcombpo.com.br',
            'recrutamento@gestcombpo.com.br',
            'assistente.rh@gestcombpo.com.br'
        };

        EmailTemplate template = [
            SELECT Id FROM EmailTemplate
            WHERE DeveloperName = 'NotificaFinalizacaoAvalicaoExperiencia'
            LIMIT 1
        ];

        String developerName = 'Notificao_Avaliacao_de_Experiencia';
        CustomNotificationType tipoNotificacao = [
            SELECT Id FROM CustomNotificationType
            WHERE DeveloperName = :developerName
            LIMIT 1
        ];
       
        List<Avaliacao_de_Experiencia__c> avaliacoesFinalizadas = new List<Avaliacao_de_Experiencia__c>();
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        List<notificaoDTO> notificacoes = new List<notificaoDTO>();
        
        for (Avaliacao_de_Experiencia__c avaliacao : novasAvaliacoes) {
            if(avaliacao.Avaliacao_Finalizada__c == true && 
               avaliacoesAntigas.get(avaliacao.Id).Ciente__c == false &&
               avaliacao.Ciente__c){
               avaliacoesFinalizadas.add(avaliacao);
            }
        }
        
        // Obter todos os ContactIds dos gestores
        Set<Id> contatoIds = new Set<Id>();
        for (Avaliacao_de_Experiencia__c av : avaliacoesFinalizadas) {
            contatoIds.add(av.Gestor2__c);
        }

        // Buscar os usuários associados aos contatos
        Map<Id, User> contatoToUserMap = new Map<Id, User>();

        List<User> usuarios = [SELECT Id, ContactId FROM User WHERE ContactId IN :contatoIds];
        for(User usuario : usuarios) {
            contatoToUserMap.put(usuario.ContactId, usuario);
        }



        for (Avaliacao_de_Experiencia__c av : avaliacoesFinalizadas) {
            User user = contatoToUserMap.get(av.Gestor2__c);
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setTemplateId(template.Id);
            email.setTargetObjectId(av.Gestor2__c);
            email.setCcAddresses(ccList);
            email.setWhatId(av.Id);
            email.setSaveAsActivity(false);
            emails.add(email);

            System.debug('User: ' + user);
            if (user == null) continue; 

            notificaoDTO dto = new notificaoDTO();
            dto.targetId = av.Id;
            dto.title = 'Avaliação de experiência finalizada';
            dto.body = 'A avaliação do colaborador ' + av.NotificacaoNomeColaborador__c + ' foi finalizada.';
            dto.notificationTypeId = tipoNotificacao.Id;
            dto.userId = user.Id;
            notificacoes.add(dto);
        } 

        if (!emails.isEmpty()) {
            Messaging.sendEmail(emails);
        }

         // Enviar notificações
        for (notificaoDTO dto : notificacoes) {
            // Notificação personalizada (sino)
            Messaging.CustomNotification notificacao = new Messaging.CustomNotification();
            notificacao.setTitle(dto.title);
            notificacao.setBody(dto.body);
            notificacao.setNotificationTypeId(dto.notificationTypeId);
            notificacao.setTargetId(dto.targetId); // UserId
            notificacao.send(new Set<String>{dto.userId});
        }  
    }

    public static void enviarNotificacaoAtraso(){
      // Buscar avaliações com contatos de gestor
        List<Avaliacao_de_Experiencia__c> avaliacoes = [
            SELECT Id, Name, Data_Fim__c, Status__c,
                Gestor2__c, NotificacaoNomeGestor__c, NotificacaoNomeColaborador__c,
                NotificacaoDiasParaVencimento__c
            FROM Avaliacao_de_Experiencia__c
            WHERE Data_Fim__c < TODAY
            AND Avaliacao_Finalizada__c = false
            AND Gestor2__c != null
        ];

        System.debug('Avaliacoes: ' + avaliacoes.size());

        if (avaliacoes.isEmpty()) return;

        // Obter todos os ContactIds dos gestores
        Set<Id> contatoIds = new Set<Id>();
        for (Avaliacao_de_Experiencia__c av : avaliacoes) {
            contatoIds.add(av.Gestor2__c);
        }

        // Buscar os usuários associados aos contatos
        Map<Id, User> contatoToUserMap = new Map<Id, User>();

        List<User> usuarios = [SELECT Id, ContactId FROM User WHERE ContactId IN :contatoIds];
        for(User usuario : usuarios) {
            contatoToUserMap.put(usuario.ContactId, usuario);
        }
        

        // Template de e-mail
        EmailTemplate template = [
            SELECT Id FROM EmailTemplate
            WHERE DeveloperName = 'NotificaVencimentoAtrasoExperiencia'
            LIMIT 1
        ];

        // Tipo de notificação personalizada (sino)
        String developerName = 'Notificao_Avaliacao_de_Experiencia';
        CustomNotificationType tipoNotificacao = [
            SELECT Id FROM CustomNotificationType
            WHERE DeveloperName = :developerName
            LIMIT 1
        ];

        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        List<notificaoDTO> notificacoes = new List<notificaoDTO>();

        for (Avaliacao_de_Experiencia__c av : avaliacoes) {
            User user = contatoToUserMap.get(av.Gestor2__c);

            // E-mail
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setTemplateId(template.Id);
            email.setTargetObjectId(av.Gestor2__c);
            email.setWhatId(av.Id);
            email.setSaveAsActivity(false);
            emails.add(email);

            if (user == null) continue; 

            notificaoDTO dto = new notificaoDTO();
            dto.targetId = av.Id;
            dto.title = 'Avaliação de experiência Atrasada';
            dto.body = 'Avaliação de ' + av.NotificacaoNomeColaborador__c + ' está vencida há '  + Math.abs(av.NotificacaoDiasParaVencimento__c) + ' dia(s) "';
            dto.notificationTypeId = tipoNotificacao.Id;
            dto.userId = user.Id;
            notificacoes.add(dto);
        }

        if (!emails.isEmpty()) {
            Messaging.sendEmail(emails, false);
        }
        // Enviar notificações
        for (notificaoDTO dto : notificacoes) {
            // Notificação personalizada (sino)
            Messaging.CustomNotification notificacao = new Messaging.CustomNotification();
            notificacao.setTitle(dto.title);
            notificacao.setBody(dto.body);
            notificacao.setNotificationTypeId(dto.notificationTypeId);
            notificacao.setTargetId(dto.targetId); // UserId
            notificacao.send(new Set<String>{dto.userId});
        }    
    }

    public class notificaoDTO{
        public string targetId;
        public string title;
        public string body;
        public string notificationTypeId;
        public String userId;
    }
}