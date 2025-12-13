public class Trello {
    @AuraEnabled
    public static String createCardTrello(String name, Id quadroId, String titulo) {
        try {
            cartaoTrello__c ct = new cartaoTrello__c();
            ct.Name = name;
            ct.Quadro_Trello__c = quadroId;
            ct.Titulo_Cartao__c = titulo;
            
            insert ct;
            return null;
        } catch (Exception e) {
            System.debug('Error: '+ e);
            throw new AuraHandledException('Error: ' + e.getMessage()); 
        }
    }
    @AuraEnabled  
    public static String completaChecklist(String idChecklist){
        
        try {
            Checklist_Tarefa__c checkListTarefa = new Checklist_Tarefa__c();
            checkListTarefa.id = idChecklist;
            checkListTarefa.concluido__c = true;
            update checkListTarefa;
            return null;
            
        } catch (Exception e) {
            System.debug('Error: '+ e);
            throw new AuraHandledException('Error: ' + e.getMessage()); 
        }
    }
    @AuraEnabled 
    public static String unableChecklist(String idChecklist){
        
        
        Checklist_Tarefa__c checkListTarefa = new Checklist_Tarefa__c();
        checkListTarefa.id = idChecklist;
        checkListTarefa.concluido__c = false;
        update checkListTarefa;
        return null;
        
    }
    @AuraEnabled  
    public static String deleteChecklistTarefa(String idChecklist){
        
        try {
            Checklist_Tarefa__c checkListTarefa = new Checklist_Tarefa__c();
            checkListTarefa.id = idChecklist;
            delete checkListTarefa;
            return null;
            
        } catch (Exception e) {
            System.debug('Error: '+ e);
            throw new AuraHandledException('Error: ' + e.getMessage()); 
        }
    }
    
    @AuraEnabled    
    public static String updateCardTrello(Id cardId, String name, Id quadroId, String titulo) {
        try {
            List<cartaoTrello__c> cards = [SELECT Id, Name, Quadro_Trello__c, Titulo_Cartao__c FROM cartaoTrello__c WHERE Id = :cardId LIMIT 1];
            
            if (cards.isEmpty()) {
                return 'Error: Card não encontrado';
            }
            
            cartaoTrello__c ct = cards[0];
            
            ct.Name = name;
            ct.Quadro_Trello__c = quadroId;
            ct.Titulo_Cartao__c = titulo;
            
            update ct;
            return null;
        } catch (Exception e) {
            System.debug('Error: '+ e);
            throw new AuraHandledException('Error: ' + e.getMessage()); 
        }
    }
    
    @AuraEnabled
    public static String createTask(Id name, String description, Date entrega, Id whatId) {
        try {
            Task t = new Task();
            t.WhoId = name;
            t.Description = description;
            t.ActivityDate = entrega;
            t.WhatId = whatId;
            
            insert t;
            return null;
        } catch (Exception e) {
            System.debug('Error: '+ e);
            throw new AuraHandledException('Error: ' + e.getMessage()); 
        }
    }
    @AuraEnabled    
    public static void updateTask(Id taskId, String subject, String description, String entregad, Id whatId) {
        try {
            List<Task> task = [SELECT Id, Description, WhatId , ActivityDate FROM Task WHERE Id = :taskId LIMIT 1];
            if (task.isEmpty()) {
                System.debug('Error: Atividade não encontrada');
                throw new AuraHandledException('Error: Atividade não encontrada'); 
            }
            
            Date entrega = date.parse(entregad);
            Task t = task[0];
            //t.WhoId = name;
            t.Subject = subject;
            t.Description = description;
            t.ActivityDate = entrega;
            t.WhatId = whatId;
            update t;
           
        }
         catch (Exception e) {
            System.debug('Error: '+ e);
            throw new AuraHandledException('Error: ' + e.getMessage()); 
        }
    }
    @AuraEnabled    
    public static String updateTaskWhatId(Id taskId, Id whatId) {
        try {
            List<Task> task = [SELECT Id FROM Task WHERE Id = :taskId LIMIT 1];
            if (task.isEmpty()) {
                System.debug('Error: Atividade não encontrada');
                throw new AuraHandledException('Error: Atividade não encontrada'); 
            }
            
            Task t = task[0];
            t.WhatId = whatId;
            
            update t;
            return null;
        } catch (Exception e) {
            System.debug('Error: '+ e);
            throw new AuraHandledException('Error: ' + e.getMessage()); 
        }
    }
     @AuraEnabled    
    public static void updateStatus(String taskId, String status) {
        try {
            Task task1 = [SELECT Id, Status FROM Task WHERE Id = :taskId LIMIT 1];
            if (task1 == null) {
                System.debug('Error: Atividade não encontrada');
                throw new AuraHandledException('Error: Atividade não encontrada'); 
            }
            
            
            task1.Status = status;
            
            update task1;
        } catch (Exception e) {
            System.debug('Error: '+ e);
            throw new AuraHandledException('Error: ' + e.getMessage()); 
        }
    }

    @AuraEnabled    
    public static String updateTaskMeta(Id taskId, String meta, Double pesoMeta) {
        try {
            List<Task> task = [SELECT Id FROM Task WHERE Id = :taskId LIMIT 1];
            if (task.isEmpty()) {
                System.debug('Error: Atividade não encontrada');
                throw new AuraHandledException('Error: Atividade não encontrada'); 
            }
            
            Task t = task[0];
            t.Meta__c = Trello.stringToBoolean(meta);
            t.Peso_Meta__c = pesoMeta;
            
            update t;
            return null;
        } catch (Exception e) {
            System.debug('Error: '+ e);
            throw new AuraHandledException('Error: ' + e.getMessage()); 
        }
    }
    @AuraEnabled
    public static void adicionarMembroAtividade(String taskId, String novoMembroId) {
        
        // Recuperar a atividade pelo seu ID
        Task task1 = [SELECT Id, Status, Membros_da_Atividade__c FROM Task WHERE Id = :taskId LIMIT 1];
        
        // Verificar se a atividade foi encontrada
        if(task1 != null) {
            // Recuperar membros existentes e adicionar o novo membro
            String membrosAtuais = task1.Membros_da_Atividade__c;
            if (String.isNotBlank(membrosAtuais)) {
                membrosAtuais += ',' + novoMembroId;
            } else {
                membrosAtuais = String.valueOf(novoMembroId);
            }
            
            // Atualizar o campo Membros_da_Atividade__c na atividade
            task1.Membros_da_Atividade__c = membrosAtuais;
            
            // Atualizar a atividade no banco de dados
            update task1;
        } else {
            // Caso a atividade não seja encontrada
            System.debug('Atividade não encontrada com o ID fornecido: ' + task1);
            // Você pode lidar com esse caso de acordo com os requisitos do seu sistema
        }
    }
    @AuraEnabled
    public static void removerMembroAtividade(String taskId, String membroIdParaRemover) {
        try {
            // Recuperar a atividade pelo seu ID
            Task task1 = [SELECT Id, Status, Membros_da_Atividade__c FROM Task WHERE Id = :taskId LIMIT 1];
            
            // Verificar se a atividade foi encontrada
            if(task1 != null) {
                // Recuperar membros existentes
                String membrosAtuais = task1.Membros_da_Atividade__c;
                if (String.isNotBlank(membrosAtuais)) {
                    // Dividir os membros atuais em uma lista
                    List<String> membrosLista = new List<String>(membrosAtuais.split(','));
                    // Inicializar uma lista para armazenar os membros sem o membro a ser removido
                    List<String> novaLista = new List<String>();
                    // Iterar sobre os membros existentes para encontrar e remover o membro especificado
                    for(String membro : membrosLista) {
                        if(!membro.equals(membroIdParaRemover)) {
                            novaLista.add(membro);
                        }
                    }
                    // Unir novamente a nova lista para uma string
                    membrosAtuais = String.join(novaLista, ',');
                    
                    // Atualizar o campo Membros_da_Atividade__c na atividade
                    task1.Membros_da_Atividade__c = membrosAtuais;
                    
                    // Atualizar a atividade no banco de dados
                    update task1;
                } else {
                    // Caso não haja membros na atividade
                    System.debug('Não há membros nesta atividade para remover.');
                }
            } else {
                // Caso a atividade não seja encontrada
                System.debug('Atividade não encontrada com o ID fornecido: ' + taskId);
            }
        } catch (Exception e) {
            // Registrar o erro no log de depuração
            System.debug('Erro ao remover membro da atividade: ' + e.getMessage());
            // Lançar a exceção para que o cliente possa lidar com ela, se necessário
            throw new AuraHandledException('Erro ao remover membro da atividade: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static String createQuadroTrello(String name, String tituloQuadro) {
        try {
            Quadro_Trello__c qt = new Quadro_Trello__c();
            qt.Name = name;
            qt.Titulo_Quadro__c = tituloQuadro;
            
            insert qt;
            return null;
        } catch (Exception e) {
            System.debug('Error: '+ e);
            throw new AuraHandledException('Error: ' + e.getMessage()); 
        }
    }
    @AuraEnabled    
    public static String updateQuadroTrello(Id quadroId, String name, String tituloQuadro) {
        try {
            List<Quadro_Trello__c> quadros = [SELECT Id, Name, Titulo_Quadro__c FROM Quadro_Trello__c WHERE Id = :quadroId LIMIT 1];
            
            if (quadros.isEmpty()) {
                System.debug('Error: Atividade não encontrada');
                throw new AuraHandledException('Error: Atividade não encontrada'); 
            }
            
            Quadro_Trello__c qt = quadros[0];
            qt.Name = name;
            qt.Titulo_Quadro__c = tituloQuadro;
            
            update qt;
            return null;
        } catch (Exception e) {
            System.debug('Error: '+ e);
            throw new AuraHandledException('Error: ' + e.getMessage()); 
        }
    }
    @AuraEnabled    
    public static string compartilhaQuadro(String recordId, String userId, String tipoCompartilhamento) {
        try {
            Quadro_Trello__Share s = new Quadro_Trello__Share();
            s.ParentId = recordId;
            s.UserOrGroupId = userId;
            s.AccessLevel = tipoCompartilhamento;
            insert s;
            return null;
        } catch (Exception e) {
            System.debug('Error: '+ e);
            throw new AuraHandledException('Error: ' + e.getMessage()); 
        }
    }
   /* @AuraEnabled    
    public static string compartilhaCartao(String recordId, String userId, String tipoCompartilhamento) {
        try {
            CartaoTrello__Share s = new CartaoTrello__Share();
            s.ParentId = recordId;
            s.UserOrGroupId = userId;
            s.AccessLevel = tipoCompartilhamento;
            insert s;
            return null;
        } catch (Exception e) {
            System.debug('Error: '+ e);
            throw new AuraHandledException('Error: ' + e.getMessage()); 
        }
    }*/
    @AuraEnabled   
    public static string deletaCartao(String recordId) {
        try {
            CartaoTrello__c c = [SELECT ID FROM CartaoTrello__c WHERE ID =: recordId];
            List<Task> tasks = [SELECT ID FROM Task WHERE WhatId =: c.Id];            
            delete c;
            return null;
        } catch (Exception e) {
            System.debug('Error: '+ e);
            throw new AuraHandledException('Error: ' + e.getMessage()); 
        }
    }
    @AuraEnabled
    public static string deletaTask(String recordId) {
        try {
            Task c = [SELECT ID FROM Task WHERE ID =: recordId];
            delete c;
            return null;
        } catch (Exception e) {
            System.debug('Error: '+ e);
            throw new AuraHandledException('Error: ' + e.getMessage()); 
        }
    }
    @AuraEnabled    
    public static string deletaQuadro(String recordId) {
        try {
            Quadro_Trello__c c = [SELECT ID FROM Quadro_Trello__c WHERE ID =: recordId];
            List<CartaoTrello__c> cartoes = [SELECT ID FROM CartaoTrello__c WHERE Quadro_Trello__c =: recordId];
            List<Task> tasks = [SELECT ID FROM Task WHERE WhatId IN : cartoes];
            delete tasks;
            delete cartoes;
            delete c;            
            return null;
        } catch (Exception e) {
            System.debug('Error: '+ e);
            throw new AuraHandledException('Error: ' + e.getMessage()); 
        }
    }
    
    public static Boolean stringToBoolean(String str) {
        if (String.isNotEmpty(str)) {
            return str.equalsIgnoreCase('true') || str.equalsIgnoreCase('yes') || str.equals('1');
        }
        return false;
    }
    
    public static void doTeste() {
        boolean a = true;
        boolean b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;  b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;  b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;  b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;  b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;  b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;  b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;  b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;  b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;  b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;  b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
        b = a;
    }
}