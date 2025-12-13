public without sharing class ScrumV2 {

    public List<Atividade__c> atividades {get;set;}
    public List<User> usuarios {get;set;}
    public List<Coluna> colunas {get;set;}

    public Valor valor {get;set;}
    public Filtro filtro {get;set;}
    public Filtro filtro_anterior {get;set;}
    public Mensagem mensagem {get;set;}
    public View view {get;set;}

    public ScrumV2(){
        Inicializa();
        Pesquisa();
                Mensagens();
    }

    public void Inicializa(){
        atividades = new List<Atividade__c>();
        usuarios = new List<User>();
        colunas = new List<Coluna>();

        valor = new Valor();
        filtro = new Filtro();
        filtro_anterior = new Filtro();
        mensagem = new Mensagem();
        view = new View();

        usuarios = [SELECT Id, Name, SmallPhotoUrl FROM User WHERE (IsActive = true) AND (UserType IN ('PowerPartner','Standard')) AND (NOT Name LIKE '%(desativado)%') ORDER BY Name];
        valor.usuarios.add(new SelectOption('', '-- Todas --'));
        for(User usuario : usuarios)
            valor.usuarios.add(new SelectOption(usuario.Id, usuario.Name));
        valor.departamentos.add(new SelectOption('', '-- Todos --'));
        for(Schema.PicklistEntry departamento : Atividade__c.Departamento__c.getDescribe().getPicklistValues())
            valor.departamentos.add(new SelectOption(departamento.getLabel(),departamento.getLabel()));
        valor.prioridades.add(new SelectOption('', '-- Todas --'));
        for(Schema.PicklistEntry prioridade : Atividade__c.Prioridade__c.getDescribe().getPicklistValues())
            valor.prioridades.add(new SelectOption(prioridade.getLabel(),prioridade.getLabel()));
        for(Schema.PicklistEntry coluna : Atividade__c.Coluna__c.getDescribe().getPicklistValues()){
            valor.colunas.add(coluna.getLabel());
            colunas.add(new Coluna(coluna.getLabel()));
        }
    }

    public void Pesquisa(){
        List<String> filtro_atividade = new List<String>();
        List<String> filtro_tarefa = new List<String>();
        String where_atividade = '';
        String where_tarefa = '';
        String sql_atividade = '';
        String sql_tarefa = '';
                PesquisaInterna pesquisa_interna = new PesquisaInterna();

        // adiciona "filtro atividade"
        if(filtro.assunto != null && filtro.assunto != '')
            filtro_atividade.add('Name LIKE \'%'+filtro.assunto+'%\'');
        if(filtro.departamento != null && filtro.departamento != '')
            filtro_atividade.add('Departamento__c = \''+filtro.departamento+'\'');
        if(filtro.prioridade != null && filtro.prioridade != '')
            filtro_atividade.add('Prioridade__c = \''+filtro.prioridade+'\'');

        // adiciona "filtro tarefa"
        if(filtro.usuario != null && filtro.usuario != '')
            filtro_tarefa.add('OwnerId = \''+filtro.usuario+'\'');

        // filtra "tarefas"
        if(filtro_tarefa.size() > 0){
            filtro_tarefa.add('Prefixo_do_referente__c = \''+Atividade__c.SObjectType.getDescribe().getKeyPrefix()+'\'');
            where_tarefa = String.join(filtro_tarefa, ' AND ');
            sql_tarefa = 'SELECT WhatId FROM Task WHERE '+where_tarefa;
            List<Task> tarefas = pesquisa_interna.Tarefas(sql_tarefa);
            if(tarefas.size()>0){
                List<String> atividades_id = new List<String>();
                for(Task tarefa : tarefas)
                    atividades_id.add('\''+tarefa.WhatId+'\'');
                filtro_atividade.add('Id IN ('+String.join(atividades_id, ',')+')');
            }else{
                filtro_atividade.add('Id IN (\'\')');
            }
        }
                
        // filtra "atividades" (busca), para cada coluna
        if(filtro_atividade.size() > 0)
            where_atividade = 'AND ' + String.join(filtro_atividade, ' AND ');

        // limpa lista anterior
                if(view.coluna=='' || !filtro.Igual(filtro_anterior)){
            atividades.clear();
            for(Coluna coluna : colunas)
                coluna.pagina = 1;
        }
        else
            for(Integer cont=atividades.size()-1; cont >=0; cont--)
                if(atividades[cont].Coluna__c == view.coluna)
                    atividades.remove(cont);

        for(Coluna coluna : colunas){
            if(coluna.nome==view.coluna || view.coluna=='' || !filtro.Igual(filtro_anterior)){
                sql_atividade =
                    'SELECT     Id, Name, Descricao__c, Coluna__c, Departamento__c, Prioridade__c, Inicio__c, Prazo__c,  ' +
                    '           OwnerId,                                                                                 ' +
                    '           (                                                                                        ' +
                    '               SELECT      OwnerId                                                                  ' +
                    '               FROM        Tasks                                                                    ' +
                    '               ORDER BY    Owner.Name                                                               ' +
                    '           )                                                                                        ' +
                    'FROM       Atividade__c                                                                             ' +
                    'WHERE      Coluna__c = \''+coluna.nome+'\' '+where_atividade+'                                      ' +
                    'ORDER BY   LastModifiedDate DESC                                                                    ' +
                    'LIMIT      '+(view.registros+1)+'                                                                   ' +
                    'OFFSET     '+((coluna.pagina-1)*view.registros)+'                                                   ';
                List<Atividade__c> atividades_retorno = pesquisa_interna.Atividades(sql_atividade);
                if(atividades_retorno.size() == view.registros+1){
                    coluna.tem_mais = true;
                    atividades_retorno.remove(view.registros);
                }
                else
                    coluna.tem_mais = false;

                atividades.addAll(atividades_retorno);
            }
        }

        filtro.Clone(filtro_anterior);
        view = new View();
    }

    public void Volta(){
        for(Coluna coluna : colunas)
            if(coluna.nome == view.coluna)
                coluna.pagina -= 1;
        Pesquisa();
                Mensagens();
    }

    public void Avanca(){
        for(Coluna coluna : colunas)
            if(coluna.nome == view.coluna)
                coluna.pagina += 1;
        Pesquisa();
                Mensagens();
    }


    public void Arrastar(){
                view.atividade = [SELECT Id, Coluna__c, (SELECT Id, Status FROM Tasks) FROM Atividade__c WHERE Id = :view.atividade.Id];
                view.atividade.Coluna__c = view.coluna;
                
                if(view.atividade.Tasks.size()>0){   
                        String status=null;
                        
                        if(view.atividade.Coluna__c=='Lista de Entrega' || view.atividade.Coluna__c=='Sprint')
                                status = 'Não iniciado';
                        else if(view.atividade.Coluna__c=='Executando')
                                status = 'Em andamento';
                        else if(view.atividade.Coluna__c=='Paralisado')
                                status = 'Adiado';
                        else if(view.atividade.Coluna__c=='Concluído')
                                status = 'Concluído';
                        
                        for(Task tarefa : view.atividade.Tasks)
                                tarefa.Status = status;
                        
                        update view.atividade.Tasks;
                }
                update view.atividade;
                
                view = new View();
        Mensagens();
    }
        
    public void Limpar(){
        view.atividade = new Atividade__c();
        view.pessoas = '';
    }
        
    public void Inserir(){
                // insere atividade
                view.atividade.Id = null;
                view.atividade.OwnerId = view.usuario;
                view.atividade.Coluna__c = view.coluna;
                insert view.atividade;
                
                if(view.pessoas!=''){
                        
                        // insere tarefas e compartilhamentos
                        List<Task> tarefas = new List<Task>();
                        List<Atividade__Share> compartilhamentos = new List<Atividade__Share>();
                        String status = null, prioridade = null;
                        
                        if(view.atividade.Coluna__c=='Lista de Entrega' || view.atividade.Coluna__c=='Sprint')
                                status = 'Não iniciado';
                        else if(view.atividade.Coluna__c=='Executando')
                                status = 'Em andamento';
                        else if(view.atividade.Coluna__c=='Paralisado')
                                status = 'Adiado';
                        else if(view.atividade.Coluna__c=='Concluído')
                                status = 'Concluído';
                        
                        if(view.atividade.Prioridade__c!='Alta')
                                prioridade = 'Alto';
                        else if(view.atividade.Prioridade__c!='Média')
                                prioridade = 'Normal';
                        else if(view.atividade.Prioridade__c!='Baixa')
                                prioridade = 'Baixo';
                        
                        for(String pessoa : view.pessoas.split('\\,')){
                                tarefas.add(new Task(
                                        WhatId = view.atividade.Id,
                                        OwnerId = pessoa,
                                        ActivityDate = view.atividade.Prazo__c,
                                        Status = status,
                                        Priority = prioridade,
                                        Subject = view.atividade.Name,
                                        Description = view.atividade.Descricao__c,
                                        IsVisibleInSelfService = true
                                ));
                                
                                if(pessoa != (String)view.atividade.OwnerId){
                                        compartilhamentos.add(new Atividade__Share(
                                                ParentId = view.atividade.id,
                                                UserOrGroupId = pessoa,
                                                AccessLevel = 'Edit'
                                        ));
                                }
                        }
                        
                        insert tarefas;
                        insert compartilhamentos;
                }
                
                view = new View();
        Pesquisa();
        Mensagens();
    }

    public void Buscar(){
        view.atividade = [
            SELECT      Id, Name, Descricao__c, Coluna__c, Departamento__c, Prioridade__c, Inicio__c, Prazo__c,
                                                OwnerId,
                        (
                            SELECT      Id, OwnerId
                            FROM        Tasks
                            ORDER BY    Owner.Name
                        ),
                        (
                            SELECT              Id, UserOrGroupId 
                            FROM                Shares
                            WHERE               RowCause = 'Manual' 
                        )
            FROM        Atividade__c
            WHERE       Id = :view.atividade.Id
        ];
        Mensagens();
    }

    public void Alterar(){
                
                // altera atividade
        List<Task> tarefas_excluir = new List<Task>();
        List<Task> tarefas_incluir = new List<Task>();
        List<Task> tarefas_atualizar = new List<Task>();
        List<Atividade__Share> compartilhamentos_excluir = new List<Atividade__Share>();
        List<Atividade__Share> compartilhamentos_incluir = new List<Atividade__Share>();
                String status = null, prioridade = null;
                
        update view.atividade;
                
                // altera tarefas e compartilhamentos
                if(view.atividade.Coluna__c=='Lista de Entrega' || view.atividade.Coluna__c=='Sprint')
                        status = 'Não iniciado';
                else if(view.atividade.Coluna__c=='Executando')
                        status = 'Em andamento';
                else if(view.atividade.Coluna__c=='Paralisado')
                        status = 'Adiado';
                else if(view.atividade.Coluna__c=='Concluído')
                        status = 'Concluído';
                
                if(view.atividade.Prioridade__c!='Alta')
                        prioridade = 'Alto';
                else if(view.atividade.Prioridade__c!='Média')
                        prioridade = 'Normal';
                else if(view.atividade.Prioridade__c!='Baixa')
                        prioridade = 'Baixo';
                
                if(view.pessoas != ''){
                        
                        // tarefas 
                        for(Task tarefa : view.atividade.Tasks){
                                Boolean exclui = true;
                                for(String pessoa : view.pessoas.split('\\,')){
                                        if(tarefa.OwnerId == pessoa){
                                                exclui = false;
                                        }
                                }
                                if(exclui){
                                        tarefas_excluir.add(tarefa);
                                }else{
                                        tarefa.ActivityDate = view.atividade.Prazo__c;
                                        tarefa.Status = status;
                                        tarefa.Priority = prioridade;
                                        tarefa.Subject = view.atividade.Name;
                                        tarefa.Description = view.atividade.Descricao__c;
                                        tarefas_atualizar.add(tarefa);
                                }
                        }
                        for(String pessoa : view.pessoas.split('\\,')){
                                Boolean inclui = true;
                                for(Task tarefa : view.atividade.Tasks){
                                        if(tarefa.OwnerId == pessoa){
                                                inclui = false;
                                        }
                                }
                                if(inclui){
                                        tarefas_incluir.add(new Task(
                                                WhatId = view.atividade.Id,
                                                OwnerId = pessoa,
                                                ActivityDate = view.atividade.Prazo__c,
                                                Status = status,
                                                Priority = prioridade,
                                                Subject = view.atividade.Name,
                                                Description = view.atividade.Descricao__c,
                                                IsVisibleInSelfService = true
                                        ));
                                }
                        }
                        
                        // compartilhamentos 
                        for(Atividade__Share compartilhamento : view.atividade.Shares){
                                Boolean exclui = true;
                                for(String pessoa : view.pessoas.split('\\,')){
                                        if(compartilhamento.UserOrGroupId == pessoa){
                                                exclui = false;
                                        }
                                }
                                if(exclui){
                                        compartilhamentos_excluir.add(compartilhamento);
                                }
                        }
                        for(String pessoa : view.pessoas.split('\\,')){
                                if(pessoa != view.atividade.OwnerId){
                                        Boolean inclui = true;
                                        for(Atividade__Share compartilhamento : view.atividade.Shares){
                                                if(compartilhamento.UserOrGroupId == pessoa){
                                                        inclui = false;
                                                }
                                        }
                                        if(inclui){
                                                compartilhamentos_incluir.add(new Atividade__Share(
                                                        ParentId = view.atividade.id,
                                                        UserOrGroupId = pessoa,
                                                        AccessLevel = 'Edit'
                                                ));
                                        }
                                }
                        }
                }
                else{
                        tarefas_excluir.addAll(view.atividade.Tasks);
                        compartilhamentos_excluir.addAll(view.atividade.Shares);
                }
                
                if(tarefas_excluir.size()>0)
                        delete tarefas_excluir;
                if(tarefas_incluir.size()>0)
                        insert tarefas_incluir;
                if(tarefas_atualizar.size()>0)
                        update tarefas_atualizar;
                
                if(compartilhamentos_excluir.size()>0)
                        delete compartilhamentos_excluir;
                if(compartilhamentos_incluir.size()>0)
                        insert compartilhamentos_incluir;
                
                view = new View();
        Pesquisa();
        Mensagens();
        }

    public void Excluir(){
                view.ExcluirInterno();
                
                view = new View();
        Pesquisa();
        Mensagens();
        }

    public void Mensagens(){
        mensagem.tem_mensagem = ((ApexPages.getMessages().size()>0)?true:false);
        // if(mensagem.tem_mensagem)
            // for(Apexpages.Message mensagem: ApexPages.getMessages())
                // mensagem.mensagens.add(mensagem.getDetail());
    }

        
        public with sharing class PesquisaInterna {
                public List<Task> Tarefas(String query){
                        return (List<Task>) Database.query(query);
                }
                public List<Atividade__c> Atividades(String query){
                        return (List<Atividade__c>) Database.query(query);
                }
        }
        
    public class Valor {
        public List<SelectOption> departamentos {get;set;}
        public List<String> colunas {get;set;}
        public List<SelectOption> prioridades {get;set;}
        public List<SelectOption> usuarios {get;set;}

        public Valor() {
            departamentos = new List<SelectOption>();
            colunas = new List<String>();
            prioridades = new List<SelectOption>();
            usuarios = new List<SelectOption>();
        }
    }

    public class Filtro {
        public String assunto {get;set;}
        public String departamento {get;set;}
        public String prioridade {get;set;}
        public String usuario {get;set;}

        public Filtro() {
            assunto = '';
            departamento = null;
            prioridade = null;
            usuario = UserInfo.getUserId();
        }

        public void Clone(Filtro filtro_parm){
            filtro_parm.assunto = assunto;
            filtro_parm.departamento = departamento;
            filtro_parm.prioridade = prioridade;
            filtro_parm.usuario = usuario;
        }

        public Boolean Igual(Filtro filtro_parm){
            if (
                filtro_parm.assunto == assunto &&
                filtro_parm.departamento == departamento &&
                filtro_parm.prioridade == prioridade &&
                filtro_parm.usuario == usuario
            )
                return true;
            else
                return false;
        }
    }

    public class Mensagem {
        public Boolean tem_mensagem {get;set;}
        public List<String> mensagens {get;set;}

        public Mensagem() {
            tem_mensagem = false;
            mensagens = new List<String>();
        }
    }

    public class Coluna {
        public String  nome {get;set;}
        public Integer pagina {get;set;}
        public Boolean tem_mais {get;set;}

        public Coluna(String nome_parm) {
            nome = nome_parm;
            pagina = 1;
            tem_mais = false;
        }
    }

    public class View {
        public Integer registros {get;set;}
                public Date hoje {get;set;}
                public Id usuario {get;set;}
        public String coluna {get;set;}
        public Atividade__c atividade {get;set;}
        public String pessoas {get;set;}

        public View() {
            registros = 25;
                        hoje = System.Today();
                        usuario = UserInfo.getUserId();
            coluna = '';
            atividade = new Atividade__c();
            pessoas = '';
        }
                
                public void ExcluirInterno(){
                        delete this.atividade;
                }
    }

}