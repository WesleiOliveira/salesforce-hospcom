@isTest
public class AuditoriaPDFControllerTest {
    
    @testSetup
    static void setup() {
        // Criar dados de teste
        
        // 1. Criar Empresa Auditada (se necessário)
        Account empresaAuditada = new Account(
            Name = 'Empresa Teste',
            CNPJ__c = '27.476.124/0001-02'
        );
        insert empresaAuditada;
        
        // 2. Criar Seções
        List<Secao__c> secoes = new List<Secao__c>();
        
        Secao__c secao1 = new Secao__c(
            Name = 'Política da Qualidade',
            Posicao__c = 1
        );
        secoes.add(secao1);
        
        Secao__c secao2 = new Secao__c(
            Name = 'Organização',
            Posicao__c = 2
        );
        secoes.add(secao2);
        
        insert secoes;
        
        // 3. Criar Auditoria
        Auditoria__c auditoria = new Auditoria__c(
            Empresa_Auditada__c = empresaAuditada.Id,
            Data_da_Auditoria__c = Date.today()
        );
        insert auditoria;
        
        // 4. Criar Perguntas de Auditoria
        List<Pergunta_de_Auditoria__c> perguntas = new List<Pergunta_de_Auditoria__c>();
        
        // Seção 1 - Política da Qualidade
        perguntas.add(new Pergunta_de_Auditoria__c(
            Pergunta__c = 'Existe um manual da qualidade na empresa?',
            Posicao__c = 1,
            Secao__c = secao1.Id,
            Status__c = 'Ativo',
            Tipo__c = 'ESTRUTURAL'
        ));
        
        perguntas.add(new Pergunta_de_Auditoria__c(
            Pergunta__c = 'Existe uma política da qualidade na empresa?',
            Posicao__c = 2,
            Secao__c = secao1.Id,
            Status__c = 'Ativo'
        ));
        
        // Seção 2 - Organização
        perguntas.add(new Pergunta_de_Auditoria__c(
            Pergunta__c = 'A empresa possui um organograma estabelecido?',
            Posicao__c = 1,
            Secao__c = secao2.Id,
            Status__c = 'Ativo',
            Tipo__c = 'ESTRUTURAL'
        ));
        
        perguntas.add(new Pergunta_de_Auditoria__c(
            Pergunta__c = 'Há pessoal suficiente na organização?',
            Posicao__c = 2,
            Secao__c = secao2.Id,
            Status__c = 'Ativo',
            Tipo__c = 'ESTRUTURAL'
        ));
        
        insert perguntas;
        
        // 5. Criar Respostas
        List<Resposta__c> respostas = new List<Resposta__c>();
        
        respostas.add(new Resposta__c(
            Auditoria__c = auditoria.Id,
            Pergunta__c = perguntas[0].Id,
            Resposta__c = 'C',
            Tipo_da_Pergunta__c = 'ESTRUTURAL'
        ));
        
        respostas.add(new Resposta__c(
            Auditoria__c = auditoria.Id,
            Pergunta__c = perguntas[1].Id,
            Resposta__c = 'C'
        ));
        
        respostas.add(new Resposta__c(
            Auditoria__c = auditoria.Id,
            Pergunta__c = perguntas[2].Id,
            Resposta__c = 'NC',
            Tipo_da_Pergunta__c = 'ESTRUTURAL'
        ));
        
        respostas.add(new Resposta__c(
            Auditoria__c = auditoria.Id,
            Pergunta__c = perguntas[3].Id,
            Resposta__c = 'C',
            Tipo_da_Pergunta__c = 'ESTRUTURAL'
        ));
        
        insert respostas;
    }
    
   @isTest
    static void testControllerInitialization() {
        // Buscar auditoria criada no setup
        Auditoria__c auditoria = [SELECT Id FROM Auditoria__c LIMIT 1];
        
        // Criar StandardController
        ApexPages.StandardController stdController = new ApexPages.StandardController(auditoria);
        
        Test.startTest();
        // Instanciar o controller de extensão
        AuditoriaPDFController controller = new AuditoriaPDFController(stdController);
        Test.stopTest();
        
        // Verificações
        System.assertNotEquals(null, controller.recordId, 'Record ID deve estar preenchido');
        System.assertEquals(auditoria.Id, controller.recordId, 'Record ID deve ser o da auditoria');
        System.assertNotEquals(null, controller.perguntasOrganizadas, 'Lista de perguntas não deve ser nula');
        System.assertEquals(4, controller.perguntasOrganizadas.size(), 'Devem existir 4 perguntas');
    }
    
    @isTest
    static void testPerguntasOrdenadas() {
        // Buscar auditoria criada no setup
        Auditoria__c auditoria = [SELECT Id FROM Auditoria__c LIMIT 1];
        
        // Criar StandardController
        ApexPages.StandardController stdController = new ApexPages.StandardController(auditoria);
        
        Test.startTest();
        // Instanciar o controller de extensão
        AuditoriaPDFController controller = new AuditoriaPDFController(stdController);
        Test.stopTest();
        
        // Verificar ordenação
        List<AuditoriaPDFController.PerguntaWrapper> perguntas = controller.perguntasOrganizadas;
        
        // Primeira pergunta deve ser da Seção 1 (Política da Qualidade)
        System.assertEquals('Política da Qualidade', perguntas[0].secao, 
            'Primeira pergunta deve ser da seção Política da Qualidade');
        System.assertEquals(1, perguntas[0].posicaoSecao, 
            'Posição da seção deve ser 1');
        System.assertEquals(1, perguntas[0].posicaoPergunta, 
            'Posição da pergunta deve ser 1');
        
        // Segunda pergunta deve ser da mesma seção
        System.assertEquals('Política da Qualidade', perguntas[1].secao, 
            'Segunda pergunta deve ser da seção Política da Qualidade');
        System.assertEquals(2, perguntas[1].posicaoPergunta, 
            'Posição da pergunta deve ser 2');
        
        // Terceira pergunta deve ser da Seção 2 (Organização)
        System.assertEquals('Organização', perguntas[2].secao, 
            'Terceira pergunta deve ser da seção Organização');
        System.assertEquals(2, perguntas[2].posicaoSecao, 
            'Posição da seção deve ser 2');
    }
    
    @isTest
    static void testPerguntaWrapper() {
        // Buscar auditoria criada no setup
        Auditoria__c auditoria = [SELECT Id FROM Auditoria__c LIMIT 1];
        
        // Criar StandardController
        ApexPages.StandardController stdController = new ApexPages.StandardController(auditoria);
        
        Test.startTest();
        // Instanciar o controller de extensão
        AuditoriaPDFController controller = new AuditoriaPDFController(stdController);
        Test.stopTest();
        
        // Verificar conteúdo do wrapper
        AuditoriaPDFController.PerguntaWrapper primeira = controller.perguntasOrganizadas[0];
        
        System.assertNotEquals(null, primeira.perguntaId, 'Pergunta ID não deve ser nulo');
        System.assertNotEquals(null, primeira.perguntaTexto, 'Texto da pergunta não deve ser nulo');
        System.assertNotEquals(null, primeira.resposta, 'Resposta não deve ser nula');
        System.assertNotEquals(null, primeira.tipoPergunta, 'Tipo da pergunta não deve ser nulo');
        System.assertNotEquals(null, primeira.secao, 'Seção não deve ser nula');
        System.assert(primeira.resposta == 'C' || primeira.resposta == 'NC', 
            'Resposta deve ser C ou NC');
    }
    
    @isTest
    static void testAuditoriaVazia() {
        // Criar auditoria sem respostas
        Account empresa = new Account(Name = 'Empresa Vazia', CNPJ__c = '00.000.000/0001-00');
        insert empresa;
        
        Auditoria__c auditoriaVazia = new Auditoria__c(
            Empresa_Auditada__c = empresa.Id,
            Data_da_Auditoria__c = Date.today()
        );
        insert auditoriaVazia;
        
        // Criar StandardController
        ApexPages.StandardController stdController = new ApexPages.StandardController(auditoriaVazia);
        
        Test.startTest();
        // Instanciar o controller de extensão
        AuditoriaPDFController controller = new AuditoriaPDFController(stdController);
        Test.stopTest();
        
        // Verificações
        System.assertNotEquals(null, controller.perguntasOrganizadas, 
            'Lista de perguntas não deve ser nula mesmo vazia');
        System.assertEquals(0, controller.perguntasOrganizadas.size(), 
            'Lista deve estar vazia para auditoria sem respostas');
    }
    
    @isTest
    static void testMultiplasRespostas() {
        // Buscar auditoria criada no setup
        Auditoria__c auditoria = [SELECT Id FROM Auditoria__c LIMIT 1];
        
        // Criar StandardController
        ApexPages.StandardController stdController = new ApexPages.StandardController(auditoria);
        
        Test.startTest();
        // Instanciar o controller de extensão
        AuditoriaPDFController controller = new AuditoriaPDFController(stdController);
        Test.stopTest();
        
        // Verificações
        System.assertNotEquals(null, controller.perguntasOrganizadas, 
            'Perguntas devem estar carregadas');
        System.assertEquals(4, controller.perguntasOrganizadas.size(), 
            'Deve haver 4 perguntas');
        
        // Contar respostas C e NC
        Integer respostasC = 0;
        Integer respostasNC = 0;
        
        for (AuditoriaPDFController.PerguntaWrapper pw : controller.perguntasOrganizadas) {
            if (pw.resposta == 'C') {
                respostasC++;
            } else if (pw.resposta == 'NC') {
                respostasNC++;
            }
        }
        
        System.assertEquals(3, respostasC, 'Devem haver 3 respostas conformes');
        System.assertEquals(1, respostasNC, 'Deve haver 1 resposta não conforme');
    }
}