public with sharing class Scrum {

	public List<SelectOption>	departamentos_l		{get;set;}
	public List<SelectOption>	pessoas_l			{get;set;}
	public List<String>			legendas			{get;set;}
	public List<String>			colunas				{get;set;}
	public String 				departamento_f		{get;set;}
	public String 				pessoa_f			{get;set;}

	public Atividade__c 		atividade			{get;set;}
	public String 				atividade_coluna	{get;set;}
	public String				atividade_id		{get;set;}
	public Date					hoje				{get;set;}
	public string				pessoa_atual		{get;set;}
	
    public List<Atividade__c> 	atividades 			{get;set;}
	public List<Task>			tarefas 			{get;set;}
	public List<User>			usuarios 			{get;set;}
	public List<User>			pessoas				{get;set;}
	public List<User>			pessoas_in			{get;set;}
	public List<User>			pessoas_out			{get;set;}
	
	public String 				string_list			{get;set;}
	public String 				string_spri			{get;set;}
	public String 				string_exec			{get;set;}
	public String 				string_para			{get;set;}
	public String 				string_conc 		{get;set;}
	public String 				string_in 			{get;set;}
	public String 				string_out 		 	{get;set;}
	
	public List<String> 		mensagens			{get;set;}
	public Boolean 				tem_mensagem		{get;set;}
	public string				add_pessoas			{get;set;}

	
	// inicialização)
    public Scrum(){
		if(add_pessoas==null)
			add_pessoas	= (System.currentPageReference().getParameters().containsKey('Continua') && 
						   System.currentPageReference().getParameters().get('Continua') != '') 
						   ? System.currentPageReference().getParameters().get('Continua') : null;
					   
		PageReference currentPage = ApexPages.currentPage();
		Map<String, String> params  =  currentPage.getParameters(); 
		params.remove('Continua');
		currentPage.getParameters().putAll(params);
	
		Inicializa();
        BuscaCartoes();
    }
    
    public void Inicializa(){
		LimpaCartao();
		
		departamentos_l = new List<SelectOption>();
		pessoas_l = new List<SelectOption>();
		legendas = new List<String>();
		colunas = new List<String>();
		
		atividade = new Atividade__c();
		atividade_coluna = null;
		atividade_id = null;
		hoje = System.Today();
		pessoa_atual = UserInfo.getUserId();
		
		atividades = new List<Atividade__c>();
		tarefas = new List<Task>();
		usuarios = new list<User>();
		pessoas = new List<User>();
		string_list = '';
		string_spri = '';
		string_exec = '';
		string_para = '';
		string_conc = '';
		string_in = '';
		string_out = '';
		
		tem_mensagem = false;
		
		Schema.DescribeFieldResult campo;
		List<Schema.PicklistEntry> entradas;

		campo = Atividade__c.Departamento__c.getDescribe();
		entradas = campo.getPicklistValues();
		departamentos_l.add(new SelectOption('','Todos'));
		for(Schema.PicklistEntry entrada : entradas){
			departamentos_l.add(new SelectOption(entrada.getLabel(),entrada.getLabel()));
			legendas.add(entrada.getLabel());
		}
		
		List<User> pessoas_sql = [
			SELECT 	Id, Name, SmallPhotoUrl
			FROM 	User
			WHERE 	(IsActive = true) AND 
					(UserType IN ('PowerPartner','Standard')) AND
					(NOT Name LIKE '%(desativado)%')
		];
		pessoas_l.add(new SelectOption('','Todas'));
		for(User pessoa_temp : pessoas_sql){
			pessoas_l.add(new SelectOption(pessoa_temp.Id,pessoa_temp.Name));
			pessoas.add(pessoa_temp);
		}
		
		campo = Atividade__c.Coluna__c.getDescribe();
		entradas = campo.getPicklistValues();
		for(Schema.PicklistEntry entrada : entradas)
			colunas.add(entrada.getLabel());
    }
    
    public void BuscaCartoes(){
		
		// atividades
		List<String> filtros = new List<String>();
		String filtro;
		if(departamento_f != null)
			filtros.add('Departamento__c = \''+departamento_f+'\'');
		if(filtros.size()>0)
			filtro = String.join(filtros, ' AND ');
		String sql = 
			'SELECT 	Id, Name, Descricao__c, Departamento__c, Inicio__c, Prazo__c, Prioridade__c, Coluna__c, OwnerId ' +
			'FROM 		Atividade__c ' +
			'WHERE 		Coluna__c != \'Concluído\' ' +
			(filtro!=null?'AND '+filtro+' ':'')+
			'ORDER BY 	LastModifiedDate DESC'
		;
		atividades = Database.query(sql);
		
		if(atividades.size()>0){
			list<String> atividades_id = new List<String>();
			String atividades_id_str;
			for(Integer cont=0; cont<atividades.size(); cont++)
				atividades_id.Add('\''+atividades[cont].Id+'\'');
			atividades_id_str = String.join(atividades_id, ',');
			
			// tarefas
			filtros = new List<String>();
			filtro = null;
			if(pessoa_f != null)
				filtros.add('Owner.Id = \''+pessoa_f+'\'');
			if(filtros.size()>0)
				filtro = String.join(filtros, ' AND ');
			sql =
				'SELECT Id, WhatId, Owner.name ' +
				'FROM 	Task ' +
				'WHERE 	WhatId IN ('+ atividades_id_str +')'+
				(filtro!=null?' AND '+filtro+' ':'')
			;
			tarefas = Database.query(sql);
			if(filtro!=null){
				Boolean remove;
				for(Integer cont_atv=0; cont_atv<atividades.size();){
					remove = true;
					for(Integer cont_tar=0; cont_tar<tarefas.size();cont_tar++){
						if(atividades[cont_atv].Id == tarefas[cont_tar].WhatId)
							remove = false;
					}
					if(remove)
						atividades.remove(cont_atv);
					else
						cont_atv++;
				}
			}			
			Set<id> usuarios_id_s = new Set<Id>();
			List<id> usuarios_id_l = new List<Id>();
			for(Integer cont=0; cont<tarefas.size(); cont++)
				usuarios_id_s.Add(tarefas[cont].OwnerId);
			usuarios_id_l.addAll(usuarios_id_s);
			
			// usuários
			usuarios = [
				SELECT	Id, SmallPhotoUrl
				FROM	User
				WHERE 	Id IN :usuarios_id_l
			];		
		}
    }
	
	// atualização
	public PageReference AtualizaCartaoColuna(){
		String[] lista_list = (string_list!=''?string_list.split('\\,'):null);
		String[] lista_spri = (string_spri!=''?string_spri.split('\\,'):null);
		String[] lista_exec = (string_exec!=''?string_exec.split('\\,'):null);
		String[] lista_para = (string_para!=''?string_para.split('\\,'):null);
		String[] lista_conc = (string_conc!=''?string_conc.split('\\,'):null);
		
		List<Atividade__c> atividades_update = new List<Atividade__c>();
		List<Atividade__c> atividades_reabrir = new List<Atividade__c>();
		List<Atividade__c> atividades_fechar = new List<Atividade__c>();
		
		for(Integer cont1=0; cont1<atividades.size(); cont1++){
			if(lista_list != null)
				for(Integer cont2=0; cont2<lista_list.size(); cont2++)
					if(atividades[cont1].Id == lista_list[cont2] && atividades[cont1].Coluna__c != 'Lista de Entrega'){
						if(atividades[cont1].Coluna__c=='Concluído')
							atividades_reabrir.add(atividades[cont1]);
						atividades[cont1].Coluna__c = 'Lista de Entrega';
						atividades_update.add(atividades[cont1]);
					}
			if(lista_spri != null)
				for(Integer cont2=0; cont2<lista_spri.size(); cont2++)
					if(atividades[cont1].Id == lista_spri[cont2] && atividades[cont1].Coluna__c != 'Sprint'){
						if(atividades[cont1].Coluna__c=='Concluído')
							atividades_reabrir.add(atividades[cont1]);
						atividades[cont1].Coluna__c = 'Sprint';
						atividades_update.add(atividades[cont1]);
					}
			if(lista_exec != null)
				for(Integer cont2=0; cont2<lista_exec.size(); cont2++)
					if(atividades[cont1].Id == lista_exec[cont2] && atividades[cont1].Coluna__c != 'Executando'){
						if(atividades[cont1].Coluna__c=='Concluído')
							atividades_reabrir.add(atividades[cont1]);
						atividades[cont1].Coluna__c = 'Executando';
						atividades_update.add(atividades[cont1]);
					}
			if(lista_para != null)		
				for(Integer cont2=0; cont2<lista_para.size(); cont2++)
					if(atividades[cont1].Id == lista_para[cont2] && atividades[cont1].Coluna__c != 'Paralisado'){
						if(atividades[cont1].Coluna__c=='Concluído')
							atividades_reabrir.add(atividades[cont1]);
						atividades[cont1].Coluna__c = 'Paralisado';
						atividades_update.add(atividades[cont1]);
					}
			if(lista_conc != null)		
				for(Integer cont2=0; cont2<lista_conc.size(); cont2++)
					if(atividades[cont1].Id == lista_conc[cont2] && atividades[cont1].Coluna__c != 'Concluído'){
						if(atividades[cont1].Coluna__c!='Concluído')
							atividades_fechar.add(atividades[cont1]);
						atividades[cont1].Coluna__c = 'Concluído';
						atividades_update.add(atividades[cont1]);
					}
		}
		ApexPages.getMessages().clear();
		try {
			update atividades_update;
		}
		catch (System.DMLException e){
			ApexPages.addMessages(e);
		}
		
		if(ApexPages.getMessages().size()==0){
			List<Task> tarefas_reabrir = new List<Task>();
			List<Task> tarefas_fechar = new List<Task>();
			
			for(Task tarefa : tarefas){
				for(Atividade__c atividade_reabrir : atividades_reabrir)
					if(tarefa.WhatId == atividade_reabrir.Id){
						tarefa.Data_da_Conclusao__c = null;
						tarefa.Status = 'Em andamento';
						tarefas_reabrir.add(tarefa);
					}
				for(Atividade__c atividade_fechar : atividades_fechar)
					if(tarefa.WhatId == atividade_fechar.Id){
						tarefa.Status = 'Concluído';
						tarefas_fechar.add(tarefa);
					}
			}
			
			update tarefas_reabrir;
			update tarefas_fechar;
		}
		
        Inicializa();
        BuscaCartoes();
		PreparaMensagens();
		
		pageReference pg;
		if(!Test.isRunningTest()){
			pg = ApexPages.currentPage();
			pg.setRedirect(TRUE);
			Map<String, String> params = pg.getParameters(); 
			params.remove('Continua');
			pg.getParameters().putAll(params);
		}
		else
			pg = null;
		return pg;
	}
	
	public void BuscaCartao(){
		LimpaCartao();
		for(Atividade__c atividade_temp : atividades)
			if(atividade_temp.Id == atividade_id)
				atividade = atividade_temp;		
	}
	
	public PageReference AtualizaCartao(){
		try {
			update atividade;
		}
		catch (System.DMLException e){
			ApexPages.addMessages(e);
		}
		
        Inicializa();
        BuscaCartoes();
		PreparaMensagens();
		
		pageReference pg;
		if(!Test.isRunningTest()){
			pg = ApexPages.currentPage();
			pg.setRedirect(TRUE);
			Map<String, String> params = pg.getParameters(); 
			params.remove('Continua');
			pg.getParameters().putAll(params);
		}
		else
			pg = null;
		return pg;
	}
	// inserção
	public void LimpaCartao(){
		if(atividade!=null)
			atividade= new Atividade__c();
	}
	
	public PageReference InsereCartao(){
		atividade.Coluna__c = atividade_coluna;
		
		try {
			insert atividade;
		}
		catch (System.DMLException e){
			ApexPages.addMessages(e);
		}
		String temp = atividade.Id;
        
		Inicializa();
        BuscaCartoes();
		PreparaMensagens();
		
		add_pessoas = temp;
		
		pageReference pg;
		if(!Test.isRunningTest()){
			pg = new pageReference(ApexPages.currentPage().getURL());
			pg.setRedirect(TRUE);
			pg.getParameters().put('Continua',add_pessoas);
		}
		else
			pg = null;
		return pg;
	}
	
	// deleção
	public PageReference DeletaCartao(){
		Atividade__c atv_del = new Atividade__c();
		atv_del = [SELECT Id FROM Atividade__c WHERE Id = :atividade.id];

		try {
			delete atv_del;
		}
		catch (System.DMLException e){
			ApexPages.addMessages(e);
		}
		
        Inicializa();
        BuscaCartoes();
		PreparaMensagens();
		
		pageReference pg;
		if(!Test.isRunningTest()){
			pg = ApexPages.currentPage();
			pg.setRedirect(TRUE);
			Map<String, String> params = pg.getParameters(); 
			params.remove('Continua');
			pg.getParameters().putAll(params);
		}
		else
			pg = null;
		return pg;
	}
	
	// pessoas(busca)
	public void ExibirPessoas(){
		pessoas_in = new List<User>();
		pessoas_out = new List<User>();
		
		for(Task tarefa_temp : tarefas){
			if(tarefa_temp.WhatId == atividade_id)
				for(User pessoa_temp : pessoas)
					if(pessoa_temp.Id == tarefa_temp.OwnerId)
						pessoas_in.add(pessoa_temp);
		}
		
		for(Integer cont_all=0; cont_all<pessoas.size(); cont_all++){
			Boolean add_out=true;
			for(Integer cont_in=0; cont_in<pessoas_in.size(); cont_in++)
				if(pessoas[cont_all].Id == pessoas_in[cont_in].Id)
					add_out=false;
			if(add_out)
				pessoas_out.add(pessoas[cont_all]);
		}
		
		
		if(add_pessoas != null && add_pessoas != ''){
			for(User pessoa_temp : pessoas){
				if(pessoa_temp.Id == pessoa_atual){
					pessoas_in.add(pessoa_temp);
				}
			}
			
			for(Integer cont=0; cont<pessoas_out.size(); cont++){
				if(pessoas_out[cont].Id == pessoa_atual){
					pessoas_out.remove(cont);
					break;
				}
			}
			
			string_in = pessoa_atual;
			add_pessoas = '';
		}
	}

    public PageReference AtualizaPessoas(){	
		if(!(string_in=='' && string_out=='')){
			// teste de permissão ---
			for(Atividade__c atividade_perm : atividades){
				if(atividade_perm.Id == atividade_id)
					try {
						update atividade_perm;
					}
					catch (System.DMLException e){
						ApexPages.addMessages(e);
					}
			}
			// fim do teste ---
			
			if(ApexPages.getMessages().size()==0){
				String[] lista_in = (string_in!=''?string_in.split('\\,'):null);
				String[] lista_out = (string_out!=''?string_out.split('\\,'):null);
				Boolean remove=true, cria=true;
				List<Task> tarefas_remover = new List<Task>();
				List<Task> tarefas_adicionar = new List<Task>();
				
				// remove atividades q não pertencem mais a IN
				for(Integer cont_tar=0; cont_tar<tarefas.size();cont_tar++){
					if(tarefas[cont_tar].WhatId == atividade_id){
						remove = true;
						if(lista_in!=null){
							for(Integer cont_pes=0; cont_pes<lista_in.size(); cont_pes++)
								if(tarefas[cont_tar].OwnerId == lista_in[cont_pes])
									remove = false;
						}
						if(remove)
							tarefas_remover.add(tarefas[cont_tar]);
					}
				}
				try {
					delete tarefas_remover;
				}
				catch (System.DMLException e){
					ApexPages.addMessages(e);
				}
				
				// adiciona atividades q ainda nao tem em IN
				BuscaCartao();
				System.Debug(LoggingLevel.INFO,'(primeiro)atividade.id: '+atividade.id);
				String status='', prioridade='';
				
				if(atividade.Coluna__c=='Lista de Entrega' || atividade.Coluna__c=='Sprint')
					status = 'Em andamento';
				else if(atividade.Coluna__c=='Executando' || atividade.Coluna__c=='Paralisado')
					status = 'Em andamento';
				else if(atividade.Coluna__c=='Concluído')
					status = 'Concluído';
				
				if(atividade.Prioridade__c!='Alta')
					prioridade = 'Alto';
				else if(atividade.Prioridade__c!='Média')
					prioridade = 'Normal';
				else if(atividade.Prioridade__c!='Baixa')
					prioridade = 'Baixo';
				if(lista_in!=null){
					for(Integer cont_pes=0; cont_pes<lista_in.size(); cont_pes++){
						cria = true;
						for(Integer cont_tar=0; cont_tar<tarefas.size();cont_tar++){
							if(tarefas[cont_tar].WhatId == atividade.Id){
								if(tarefas[cont_tar].OwnerId == lista_in[cont_pes]){
									cria = false;
								}
							}
						}
						if(cria){
							tarefas_adicionar.add(new Task(
								WhatId = atividade.Id,
								OwnerId = lista_in[cont_pes],
								ActivityDate = atividade.Prazo__c,
								Status = status,
								Priority = prioridade,
								Subject = atividade.Name,
								Description = atividade.Descricao__c,
								IsVisibleInSelfService = true
							));
						}
					}
					try {
						insert tarefas_adicionar;
					}
					catch (System.DMLException e){
						ApexPages.addMessages(e);
					}
					
				}
				AtualizaCompartilhamento(lista_in);
			}
			
		}
		Inicializa();
		BuscaCartoes();
		PreparaMensagens();
		
		pageReference pg;
		if(!Test.isRunningTest()){
			pg = ApexPages.currentPage();
			pg.setRedirect(TRUE);
			Map<String, String> params = pg.getParameters(); 
			params.remove('Continua');
			pg.getParameters().putAll(params);
		}
		else
			pg = null;
		return pg;
	}
	
	public void AtualizaCompartilhamento(List<String> lista_nova){
		BuscaCartao();
		System.Debug(LoggingLevel.INFO,'(segundo)atividade.id: '+atividade.id);
		List<Atividade__Share> comp_atu = [
			SELECT 	Id, UserOrGroupId 
			FROM 	Atividade__Share
			WHERE	RowCause = 'Manual' AND 
			        ParentId = :atividade.id AND
					UserOrGroupId != :atividade.OwnerId
		];
		
		List<Atividade__Share> comp_add = new List<Atividade__Share>();
		List<Atividade__Share> comp_del = new List<Atividade__Share>();
		Boolean deleta, adiciona;
		
		// remove antigos
		for(Atividade__Share atual : comp_atu){
			deleta = true;
			if(lista_nova!=null)
				for(String novo : lista_nova)
					if(atual.UserOrGroupId == novo)
						deleta=false;
			if(deleta)
				comp_del.add(atual);
		}
		delete comp_del;
		
		// adiciona novos
		if(lista_nova!=null){
			for(String novo : lista_nova){
				adiciona = true;
				if(novo == atividade.OwnerId)
					adiciona=false;
				else{
					for(Atividade__Share atual : comp_atu)
						if(novo == atual.UserOrGroupId)
							adiciona=false;				
				}
				if(adiciona){
					System.Debug(LoggingLevel.INFO,'(no erro)atividade.id: '+atividade.id);
					comp_add.add(new Atividade__Share(
						ParentId = atividade.id,
						UserOrGroupId = novo,
						AccessLevel = 'Edit'
					));
				}
			}
			insert comp_add;
		}
	}
	
	public void PreparaMensagens(){
		tem_mensagem = ((ApexPages.getMessages().size()>0)?true:false);
        if(tem_mensagem){
            mensagens = new List<String>();
            for(Apexpages.Message mensagem: ApexPages.getMessages())
                mensagens.add(mensagem.getDetail());
        }
	}
	
	public void AtualizaQuadro(){
		tem_mensagem = ((ApexPages.getMessages().size()>0)?true:false);
        if(tem_mensagem){
            mensagens = new List<String>();
            for(Apexpages.Message mensagem: ApexPages.getMessages())
                mensagens.add(mensagem.getDetail());
        }
	}
}