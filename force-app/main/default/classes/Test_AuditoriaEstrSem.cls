@isTest
    private class Test_AuditoriaEstrSem {
        @isTest static void testAfterInsertWithNC() {

            Auditoria_Estrutural_Semanal__c auditRec = new Auditoria_Estrutural_Semanal__c(
                pergunta1__c = 'NC',
                d1__c = 'Descrição para NC'
            );

            insert auditRec;

            // Verifica se foi criada a Não Conformidade no AFTER INSERT
            List<Nao_Conformidade__c> ncs = [
                SELECT Id, Descricao__c 
                FROM Nao_Conformidade__c 
                WHERE Auditoria_Estrutural_Semanal__c = :auditRec.Id
            ];
            
            System.assertEquals(1, ncs.size(), 'Deve ser criada 1 Não Conformidade no after insert.');
            System.assertEquals('Descrição para NC', ncs[0].Descricao__c, 
                'A descrição da NC deve ser a informada no registro inserido.');
        }

        @isTest static void testAfterUpdateWithAttachment() {
        

            // Criando a Auditoria inicialmente sem NC
            Auditoria_Estrutural_Semanal__c auditRec = new Auditoria_Estrutural_Semanal__c(

                pergunta1__c = 'C',
                d1__c = null
            );
            insert auditRec;
            
            // Criando um arquivo (ContentVersion) para simular o anexo
            ContentVersion cv = new ContentVersion(
                Title = 'Test File',
                PathOnClient = 'TestFile.jpg',
                VersionData = Blob.valueOf('Test Content')
            );
            insert cv;
            
            // Consulta o ContentDocumentId criado automaticamente
            cv = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1];
            
            // Criando o ContentDocumentLink para vincular o anexo ao registro de auditoria
            ContentDocumentLink cdl = new ContentDocumentLink(
                ContentDocumentId = cv.ContentDocumentId,
                LinkedEntityId = auditRec.Id,
                ShareType = 'V',
                Visibility = 'AllUsers'
            );
            insert cdl;
            
            // Atualiza o registro para marcar a pergunta como "NC" e preenche a descrição correspondente
            auditRec.pergunta1__c = 'NC';
            auditRec.d1__c = 'Descrição informada para NC';
            
            Test.startTest();
            update auditRec;
            Test.stopTest();
            
            // Verifica se foi criada uma Não Conformidade com a descrição correta
            List<Nao_Conformidade__c> ncs = [
                SELECT Id, Descricao__c 
                FROM Nao_Conformidade__c 
                WHERE Auditoria_Estrutural_Semanal__c = :auditRec.Id
            ];
            System.assertEquals(1, ncs.size(), 'Deve ser criada 1 Não Conformidade.');
            System.assertEquals('Descrição informada para NC', ncs[0].Descricao__c, 
                'A descrição da NC deve ser a informada.');
        }

        @isTest static void testUpdateFailsWithoutAttachment() {

            // Criando a Auditoria inicialmente sem NC
            Auditoria_Estrutural_Semanal__c auditRec = new Auditoria_Estrutural_Semanal__c(
                pergunta1__c = 'C',
                d1__c = null
            );
            insert auditRec;
            
            // Atualiza o registro para marcar a pergunta como "NC" e preenche a descrição, mas não insere anexo
            auditRec.pergunta1__c = 'NC';
            auditRec.d1__c = 'Descrição para NC';
            
            Boolean exceptionThrown = false;
            try {
                update auditRec;
            } catch (DmlException e) {
                exceptionThrown = true;
                System.assert(e.getMessage().contains('É obrigatório anexar uma imagem'), 
                    'Deveria retornar erro por falta de anexo.');
            }
            System.assert(exceptionThrown, 'Erro esperado para update sem anexo não foi lançado.');
        }
    }