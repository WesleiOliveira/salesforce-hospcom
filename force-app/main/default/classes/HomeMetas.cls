public class HomeMetas {
    
    @AuraEnabled
    public static String Inicializar(){
		Retorno retorno = new Retorno();
		List<GroupMember> membros_grupos = new List<GroupMember>();
		membros_grupos = [
			SELECT 	Group.Name
			FROM 	GroupMember 
			WHERE 	UserOrGroupId = :UserInfo.getUserId() AND
					Group.Name IN ('Diretoria', 'Governo (gestor)', 'Governo (equipe)', 'Governo (auxiliar)', 'Comercial (gestor)', 'Comercial (equipe)')
		];	
		Boolean diretoria=false, goveno=false, gestor_comercial=false, equipe_comercial=false;
		for(GroupMember membro_grupo : membros_grupos){
			if(membro_grupo.Group.Name == 'Diretoria')
				diretoria = true;
			else if(membro_grupo.Group.Name.contains('Governo'))
				goveno = true;
			else if(membro_grupo.Group.Name == 'Comercial (gestor)')
				gestor_comercial = true;
			else if(membro_grupo.Group.Name == 'Comercial (equipe)')
				equipe_comercial = true;
		}
		if(diretoria){
			retorno.tipo_usuario = 'diretoria';
			retorno.opcoes.add(new Map<String, String>{'value' => 'governo', 'label' => 'Dpto. Governo'});
			retorno.opcao = 'governo';
			retorno = MetaDptoGoverno(retorno);
			retorno = MetaEquipeComercial(retorno,true,false);
		}
		else if(goveno){
			retorno.tipo_usuario = 'governo';
			retorno.opcoes.add(new Map<String, String>{'value' => 'governo', 'label' => 'Dpto. Governo'});
			retorno.opcao = 'governo';
			retorno = MetaDptoGoverno(retorno);
		}
		else if(gestor_comercial){
			retorno.tipo_usuario = 'gestor comercial';
			retorno = MetaEquipeComercial(retorno,true,false);
			retorno.opcao = retorno.opcoes[0].get('value');
			retorno = MetaEquipeComercial(retorno,false,true);
		}
		else if(equipe_comercial){
			retorno.tipo_usuario = 'equipe comercial';
			retorno.opcao = UserInfo.getUserId();
			retorno = MetaEquipeComercial(retorno,false,true);
		}
		return JSON.serialize(retorno);
	}
	
	@AuraEnabled
	public static String BuscarMeta(String retorno_json){
		Retorno retorno = (Retorno) JSON.deserialize(retorno_json, Retorno.class);
		
		retorno = LimparMeta(retorno);
		
		if(retorno.opcao == 'governo')
			retorno = MetaDptoGoverno(retorno);
		else
			retorno = MetaEquipeComercial(retorno,false,true);
		
		return JSON.serialize(retorno);
	}
	
	public static Retorno LimparMeta(Retorno retorno){
		retorno.meta_t1 = 0;
		retorno.meta_t2 = 0;
		retorno.meta_t3 = 0;
		retorno.meta_t4 = 0;
		retorno.valor_t1 = 0;
		retorno.valor_t2 = 0;
		retorno.valor_t3 = 0;
		retorno.valor_t4 = 0;
		return retorno;
	}
	
	public static Retorno MetaDptoGoverno(Retorno retorno){
		List<Meta__mdt> metas = [
			SELECT 	Label, Valor__c 
			FROM 	Meta__mdt
			WHERE 	Label LIKE 'Governo%'
		];
		for(Meta__mdt meta : metas){
			if(meta.Label.contains('T1'))      	retorno.meta_t1 = meta.Valor__c;
			else if(meta.Label.contains('T2'))  retorno.meta_t2 = meta.Valor__c;
			else if(meta.Label.contains('T3'))  retorno.meta_t3 = meta.Valor__c;
			else if(meta.Label.contains('T4'))  retorno.meta_t4 = meta.Valor__c;
		}
		List<AggregateResult> valores = [
			SELECT  	CALENDAR_QUARTER(Data_do_Recebimento__c) trimestre, SUM(Valor_Total__c) valor
			FROM    	Recebimentos__c
			WHERE		Data_do_Recebimento__c = THIS_YEAR AND 
						Nota_Fiscal1__r.Departamento3__c = 'Governo'
			GROUP BY	CALENDAR_QUARTER(Data_do_Recebimento__c)
		];
		for(AggregateResult valor : valores){
			if(valor.get('trimestre')==1)      retorno.valor_t1 = (Decimal)valor.get('valor');
			else if(valor.get('trimestre')==2) retorno.valor_t2 = (Decimal)valor.get('valor');
			else if(valor.get('trimestre')==3) retorno.valor_t3 = (Decimal)valor.get('valor');
			else if(valor.get('trimestre')==4) retorno.valor_t4 = (Decimal)valor.get('valor');
		}
		return retorno;
	}
	
	public static Retorno MetaEquipeComercial(Retorno retorno, Boolean lista, Boolean meta){
		if(lista){
			List<GroupMember> membros = [
				SELECT 	UserOrGroupId
				FROM 	GroupMember 
				WHERE 	Group.Name IN ('Comercial (equipe)')
			];
			Set<String> usuarios_id = new Set<String>();
			for(GroupMember membro : membros)
				if(String.valueOf(membro.UserOrGroupId).startsWith('005'))
					usuarios_id.add(membro.UserOrGroupId);
			List<User> usuarios = [
				SELECT	Id, Name
				FROM	User
				WHERE	Id IN :usuarios_id AND IsActive = true
			];
			for(User usuario : usuarios)
				retorno.opcoes.add(new Map<String, String>{'value' => usuario.Id, 'label' => '-'+usuario.Name});			
		}
		if(meta){
			List<User> metas = [
				SELECT		id, Meta_T1__c, Meta_T2__c, Meta_T3__c, Meta_T4__c
				FROM		User
				WHERE		Id = :retorno.opcao
			];
			retorno.meta_t1 = metas[0].Meta_T1__c;
			retorno.meta_t2 = metas[0].Meta_T2__c;
			retorno.meta_t3 = metas[0].Meta_T3__c;
			retorno.meta_t4 = metas[0].Meta_T4__c;
			List<AggregateResult> valores = [
				SELECT  	CALENDAR_QUARTER(Data_do_Recebimento__c) trimestre, SUM(Valor_Total__c) valor
				FROM    	Recebimentos__c
				WHERE		Data_do_Recebimento__c = THIS_YEAR AND 
							Nota_Fiscal1__r.Departamento3__c = 'Comercial' AND
							Nota_Fiscal1__r.OwnerId = :retorno.opcao
				GROUP BY	CALENDAR_QUARTER(Data_do_Recebimento__c)
			];
			for(AggregateResult valor : valores){
				if(valor.get('trimestre')==1)      retorno.valor_t1 = (Decimal)valor.get('valor');
				else if(valor.get('trimestre')==2) retorno.valor_t2 = (Decimal)valor.get('valor');
				else if(valor.get('trimestre')==3) retorno.valor_t3 = (Decimal)valor.get('valor');
				else if(valor.get('trimestre')==4) retorno.valor_t4 = (Decimal)valor.get('valor');
			}
		}
		return retorno;
	}
	
	public class Retorno{
		public List<Map<String, String>> opcoes = new List<Map<String, String>>();
		public String opcao = '';
		public String tipo_usuario = '';
		public Decimal meta_t1 = 0;
		public Decimal meta_t2 = 0;
		public Decimal meta_t3 = 0;
		public Decimal meta_t4 = 0;
		public Decimal valor_t1 = 0;
		public Decimal valor_t2 = 0;
		public Decimal valor_t3 = 0;
		public Decimal valor_t4 = 0;
	}
	
}