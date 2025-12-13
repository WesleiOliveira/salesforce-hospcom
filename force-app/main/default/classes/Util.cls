public class Util {
	
	// ação interna
	static Boolean acao_interna = false;
	public static Void AcaoInterna(Boolean opcao){
		acao_interna = opcao;
	}
	public static Boolean AcaoInterna(){
		return acao_interna;
	}
	
	// ignorar erros
	static String ignorar_erros = null;
	public static Boolean IgnorarErros(){
		if (ignorar_erros == null)
			ignorar_erros = [SELECT Ignorar_erros__c FROM User WHERE Id = :System.UserInfo.getUserId()].Ignorar_erros__c == true ? 'sim':'não';
		return ignorar_erros == 'sim' ? true : false;
	}
	
	// obter todos campos de objeto
	public static String ObterCamposObjeto(String objeto){
		List<String> campos = new List<String>();
		for(String campo : Schema.getGlobalDescribe().get(objeto).getDescribe().fields.getMap().keySet())
		   campos.add(campo);
		return String.join(campos, ',' );
	}
	
	// obter tipo regigstro
	static List<RecordType> tipos_registros = null;
	public static String ObterTipoRegistro(Id tipo_registro_id){
		if (tipos_registros == null)
			tipos_registros = [SELECT Id, Name FROM	RecordType];
		for(RecordType tipo_registro : tipos_registros)
			if (tipo_registro_id == tipo_registro.id)
				return tipo_registro.Name;
		
		return null;
	}
	
	// obter dados hospcom
	static List<Account> hospcom_contas = null;
	static List<String> hospcom_cnpjs = new List<String>{
		'27.476.124/0001-02', '23.813.386/0001-56', '05.743.288/0001-08', 
		'23.770.455/0001-91', '26.588.557/0001-88'
	};
	static List<Id> hospcom_ids = new List<Id>();
	public static List<Account> ObterContasHospcom(List<String> campos_conta){
		if(hospcom_contas == null){
			List<String> filtro_cnpjs = new List<String>();
			for(String hospcom_cnpj : hospcom_cnpjs)
				filtro_cnpjs.add('\''+hospcom_cnpj+'\'');
			System.Debug(LoggingLevel.INFO,
				'SELECT	' + String.join(campos_conta, ', ' ) + ' ' + 
				'FROM	Account ' +
				'WHERE	CNPJ__c IN (' + String.join(filtro_cnpjs, ', ') + ') ' 
			);
			hospcom_contas = Database.query(
				'SELECT	' + String.join(campos_conta, ', ' ) + ' ' + 
				'FROM	Account ' +
				'WHERE	CNPJ__c IN (' + String.join(filtro_cnpjs, ', ') + ') ' 
			);
		}
		
		return hospcom_contas;
	}
	public static List<Id> ObterIdsHospcom(){
		if(hospcom_contas == null){
			ObterContasHospcom(new List<String>{'Id'});
			for(Account conta_hospcom : hospcom_contas)
				hospcom_ids.add(conta_hospcom.Id);
		}
		
		return hospcom_ids;
	}
	public static List<String> ObterCnpjsHospcom(){
		return hospcom_cnpjs;
	}
	
	// converter estado
	static List<Estado> estados = null;
	public static String ConverterEstado(String entrada, String retorno){
		if(estados == null){
			estados = new List<Estado>();
			estados.add(new Estado('AC', 'Acre'));
			estados.add(new Estado('AP', 'Amapá'));
			estados.add(new Estado('BA', 'Bahia'));
			estados.add(new Estado('DF', 'Distrito Federal'));
			estados.add(new Estado('GO', 'Goiás'));
			estados.add(new Estado('MT', 'Mato Grosso'));
			estados.add(new Estado('MG', 'Minas Gerais'));
			estados.add(new Estado('PB', 'Paraíba'));
			estados.add(new Estado('PE', 'Pernambuco'));
			estados.add(new Estado('RJ', 'Rio de Janeiro'));
			estados.add(new Estado('RS', 'Rio Grande do Sul'));
			estados.add(new Estado('RR', 'Roraima'));
			estados.add(new Estado('SP', 'São Paulo'));
			estados.add(new Estado('TO', 'Tocantins'));
			estados.add(new Estado('AL', 'Alagoas'));
			estados.add(new Estado('AM', 'Amazonas'));
			estados.add(new Estado('CE', 'Ceará'));
			estados.add(new Estado('ES', 'Espírito Santo'));
			estados.add(new Estado('MA', 'Maranhão'));
			estados.add(new Estado('MS', 'Mato Grosso do Sul'));
			estados.add(new Estado('PA', 'Pará'));
			estados.add(new Estado('PR', 'Paraná'));
			estados.add(new Estado('PI', 'Piauí'));
			estados.add(new Estado('RN', 'Rio Grande do Norte'));
			estados.add(new Estado('RO', 'Rondônia'));
			estados.add(new Estado('SC', 'Santa Catarina'));
			estados.add(new Estado('SE', 'Sergipe'));
		}
		
		if(entrada != null)
			for(Estado estado : estados)
				if(retorno == 'nome' && entrada.toLowerCase() == estado.sigla.toLowerCase())
					return estado.nome;
				else if(retorno == 'sigla' && entrada.toLowerCase() == estado.nome.toLowerCase())
					return estado.sigla;
		
		return null;
	}
	class Estado{
		String sigla {get;set;}
		String nome {get;set;}
		
		Estado(String sigla, String nome){
			this.sigla = sigla;
			this.nome = nome;
		}
	}

	// validar telefone
	static Set<String> telefones_invalidos = new Set<String>{
		'0000-0000', '1111-1111', '2222-2222', '3333-3333',  '4444-4444', 
		'5555-5555', '6666-6666', '7777-7777', '8888-8888',  '9999-9999', 
		'99999-9999'
	};
	static Set<String> telefones_reservados = new Set<String>{
		'(62) 3637-9427', '(67) 3028-6928', '(62) 3241-5555', '(62) 3524-1795'
	};
	static Set<String> cnpj_reservados = new Set<String>{
		'27.476.124/0001-02', '23.813.386/0001-56', '05.743.288/0001-08', '23.770.455/0001-91', '26.588.557/0001-88'
	};
	public static String ValidarTelefone(String telefone, String cnpj){
		if(telefone != null){
			
			// telefone desformatado
			if(!Pattern.compile('^[(][0-9]{2}[)] [9]?[0-9]{4}-[0-9]{4}( Ramal: [0-9]{4})?(, [(][0-9]{2}[)] [9]?[0-9]{4}-[0-9]{4}){0,1}$').matcher(telefone).matches())
				return 'O número deve ter o formato (XX) xXXXX-XXXX Ramal: XXXX. O ramal é opcional, máximo 2 números (sem ramal) ou 1 (com ramal) separados por vírgula';
				
			// telefone invalido
			for(String telefone_invalido : telefones_invalidos)
				if(telefone.Contains(telefone_invalido))
					return 'O número deve conter apenas sequências válidas';
				
			// telefone reservado
			if(!cnpj_reservados.Contains(cnpj))
				for(String telefone_reservado : telefones_reservados)
					if(telefone.Contains(telefone_reservado))
						return'O número deve ser diferente de números internos/reservados';
		}
		
		return null;
    }
	
	// validar cnpj
	static Set<String> cnpj_invalidos = new Set<String>{
		'00.000.000/0000-00', '11.111.111/1111-11', '22.222.222/2222-22', '33.333.333/3333-33', '44.444.444/4444-44', 
		'55.555.555/5555-55', '66.666.666/6666-66', '77.777.777/7777-77', '88.888.888/8888-88', '99.999.999/9999-99'
	};
	public static String ValidarCNPJ(String cnpj){
		if(cnpj != null){
			
			// cnpj desformatado
			if(!Pattern.compile('^[0-9]{2}.[0-9]{3}.[0-9]{3}/[0-9]{4}-[0-9]{2}$').matcher(cnpj).matches())
				return 'O CNPJ deve seguir o formato NN.NNN.NNN/NNNN-NN';
			
			// cnpj invalido
			if(cnpj_invalidos.Contains(cnpj))
				return 'O CNPJ deve conter apenas sequências válidas';
			
			// cnpj inconsistente
			Integer cnpj_dig1 = integer.valueOf(cnpj.substring(0,1))*5 +
				integer.valueOf(cnpj.substring(1,2))*4 + integer.valueOf(cnpj.substring(3,4))*3 +
				integer.valueOf(cnpj.substring(4,5))*2 + integer.valueOf(cnpj.substring(5,6))*9 +
				integer.valueOf(cnpj.substring(7,8))*8 + integer.valueOf(cnpj.substring(8,9))*7 +
				integer.valueOf(cnpj.substring(9,10))*6 + integer.valueOf(cnpj.substring(11,12))*5 +
				integer.valueOf(cnpj.substring(12,13))*4 + integer.valueOf(cnpj.substring(13,14))*3 +
				integer.valueOf(cnpj.substring(14,15))*2;
			cnpj_dig1 = math.mod(cnpj_dig1, 11)<2 ?0 :11-math.mod(cnpj_dig1, 11);
			Integer cnpj_dig2 = integer.valueOf(cnpj.substring(0,1))*6 +
				integer.valueOf(cnpj.substring(1,2))*5 + integer.valueOf(cnpj.substring(3,4))*4 +
				integer.valueOf(cnpj.substring(4,5))*3 + integer.valueOf(cnpj.substring(5,6))*2 +
				integer.valueOf(cnpj.substring(7,8))*9 + integer.valueOf(cnpj.substring(8,9))*8 +
				integer.valueOf(cnpj.substring(9,10))*7 + integer.valueOf(cnpj.substring(11,12))*6 +
				integer.valueOf(cnpj.substring(12,13))*5 + integer.valueOf(cnpj.substring(13,14))*4 +
				integer.valueOf(cnpj.substring(14,15))*3 + cnpj_dig1*2;
			cnpj_dig2 = math.mod(cnpj_dig2, 11)<2 ?0 :11-math.mod(cnpj_dig2, 11);
			if(integer.valueOf(cnpj.substring(16,17)) != cnpj_dig1 || integer.valueOf(cnpj.substring(17,18)) != cnpj_dig2)
				return 'O CNPJ é inconsistente';
			
		}
		
		return null;
    }
	
	// validar cpf
	static Set<String> cpf_invalidos = new Set<String>{
		'000.000.000-00', '111.111.111-11', '222.222.222-22', '333.333.333-33', '444.444.444-44', 
		'555.555.555-55', '666.666.666-66', '777.777.777-77', '888.888.888-88', '999.999.999-99'
	};
	public static String ValidarCPF(String cpf){
		if(cpf != null){
			
			// cpf desformatado
			if(!Pattern.compile('^[0-9]{3}.[0-9]{3}.[0-9]{3}-[0-9]{2}$').matcher(cpf).matches())
				return 'O CPF deve seguir o formato NNN.NNN.NNN-NN';
			
			// cpf invalido
			if(cpf_invalidos.Contains(cpf))
				return 'O CPF deve conter apenas sequências válidas';
			
			// cpf inconsistente
			Integer cpf_dig1 = integer.valueOf(cpf.substring(0,1))*10 +
				integer.valueOf(cpf.substring(1,2))*9 + integer.valueOf(cpf.substring(2,3))*8 +
				integer.valueOf(cpf.substring(4,5))*7 + integer.valueOf(cpf.substring(5,6))*6 +
				integer.valueOf(cpf.substring(6,7))*5 + integer.valueOf(cpf.substring(8,9))*4 +
				integer.valueOf(cpf.substring(9,10))*3 + integer.valueOf(cpf.substring(10,11))*2;
			cpf_dig1 = math.mod(cpf_dig1, 11)<2 ?0 :11-math.mod(cpf_dig1, 11);
			Integer cpf_dig2 = integer.valueOf(cpf.substring(0,1))*11 +
				integer.valueOf(cpf.substring(1,2))*10 + integer.valueOf(cpf.substring(2,3))*9 +
				integer.valueOf(cpf.substring(4,5))*8 + integer.valueOf(cpf.substring(5,6))*7 +
				integer.valueOf(cpf.substring(6,7))*6 + integer.valueOf(cpf.substring(8,9))*5 +
				integer.valueOf(cpf.substring(9,10))*4 + integer.valueOf(cpf.substring(10,11))*3 +
				cpf_dig1*2;
			cpf_dig2 = math.mod(cpf_dig2, 11)<2 ?0 :11-math.mod(cpf_dig2, 11);
			if(integer.valueOf(cpf.substring(12,13)) != cpf_dig1 || integer.valueOf(cpf.substring(13,14)) != cpf_dig2)
				return 'O CPF é inconsistente';
			
		}
		
		return null;
    }

	// validar textos manuais
	static Set<String> valores_invalidos = new Set<String>{
		'não', 'nao', 'n/', 'informad', 'especificad', 'consta', ' tem', 'indisponível', 'indisponivel',
		'outr', 'nome', 'cargo', 'função', 'funçao', 'funcão', 'funcao', 'indefinid'
	};
	static Set<String> valores_tratamentos = new Set<String>{
		'seu', 'seo', 's', 
		'dona', 'd.a', 'd.ª', 'da', 'dª', 
		'você', 'voce', 'v', 
		'senhor', 'sr', 's.r', 
		'senhora', 'sra', 'srª', 's.ra', 's.rª', 
		'senhorita', 'sr.ta', 'sr.tª', 'srta', 'srtª', 
		'excelência', 'excelencia', 'exa', 'exª', 'ex.a', 'ex.ª', 
		'meritíssimo', 'meritissimo', 'mm', 
		'ilustríssimo', 'ilustrissimo', 'il.mo', 'il.mº', 'ilmo', 'ilmº', 
		'ilustríssima', 'ilustrissima', 'il.ma', 'il.mª', 'ilma', 'ilmª', 

		'marechal', 'mar', 'm.al', 'mal', 
		'major', 'maj', 
		'brigadeiro', 'brig', 'brigº', 
		'almirante', 'alte', 
		'tenente', 'ten', 't.te', 'tte', 
		'sargento', 'sarg', 'sgto', 'sgtº', 
		'ajudante', 'aj.te', 'ajte', 
		'general', 'gen', 'g.al', 'gal', 
		'cabo', 'cb', 
		'cadete', 'cad', 
		'capitão', 'cap', 
		'comandante', 'com', 'com.te', 'comte', 'cmt', 
		'coronel', 'c.el', 'cel', 

		'comendador', 'coma', 'comª', 'com.a', 'com.ª', 
		'comendadora', 'com', 
		'tesoureiro', 'tes', 
		'tesoureira', 'tesa', 'tesª', 'tes.a', 'tes.ª', 
		'senador', 'sen', 
		'senador', 'sen.a', 'sena', 'sen.ª', 'senª', 
		'secretário', 'sec', 'secr', 'secº', 'secr.º seco', 'secr.o', 
		'secretária', 'secª', 'secr.ª seca', 'secr.a', 
		'vereador', 'ver', 
		'vereadora', 'ver', 'verª', 'ver.ª', 
		'prefeito', 'pref', 
		'prefeito', 'prefª', 'pref.ª', 
		'promotor', 'prom', 
		'promotor', 'promª', 'prom.ª', 
		'deputado', 'dep', 
		'deputado', 'depª', 'dep.ª', 

		'padre', 'p.', 'p.e', 'pe', 
		'pastor', 'pr', 
		'pastora', 'pra', 'prª', 'pr.a', 'pr.ª', 
		'bispo', 'b.po', 'bpo.', 'bp', 

		'médico', 'medico', 'méd', 'med', 
		'médica', 'medica', 'médª', 'méd.ª', 'méd.a', 'medª', 'med.ª', 'med.a', 
		'enfermeiro', 'enf', 
		'enfermeira', 'enf.ª', 'enf.a', 'enfª', 'enfa', 
		'veterinário', 'veterinario', 'vet', 
		'veterinária', 'veterinaria', 'vetª', 'vet.ª', 'vet.a', 
		'cirurgião', 'cirurgiao', 'cd', 'cirug', 
		'cirurgiã', 'cirurgia', 'cd', 'cirug', 
		'doutor', 'd.r', 'dr', 
		'doutora', 'd.ra', 'dra', 'd.rª', 'drª', 

		'bacharel', 'b.el', 'bel', 
		'bacharela', 'b.ela', 'bela', 'b.elª', 'belª', 
		'arquiteto', 'arq', 'arq.o', 'arq.º', 
		'arquiteta', 'arq.a', 'arq.ª', 
		'engenheiro', 'eng', 'engo', 'engº', 'eng.o', 'eng.º', 
		'engenheira', 'engª', 'eng.a', 'eng.ª', 
		'bibliotecário', 'bibliotecario', 'bib', 'bib.o', 'bib.º', 
		'bibliotecária', 'bibliotecaria', 'bib.a', 'bib.ª', 
		'mestre', 'me', 
		'mestra', ' v', 'mª', 
		'procurador', 'proc', 
		'procuradora', 'proc.a', 'proc.ª', 
		'professor', 'prof', 
		'professora', 'prof.a', 'prof.ª', 'profa', 'profª', 
		'administrador', 'adm', 
		'administradora', 'adma', 'adm.a', 'admª', 'adm.ª', 
		'advogado', 'adv', 'advo', 'advº', 'adv.o', 'adv.º', 
		'advogada', 'adva', 'advª', 'adv.a', 'adv.ª', 
		'aluno', 'al', 
		'aluna', 'al.a', 'al.ª', 
		'contador', 'cont.dor', 'contdor.', 'cont.or', 'contor', 
		'contadora', 'cont.dora', 'contdora', 'cont.ora', 'contora', 
		'desembargador', 'des', 
		'desembargadora', 'desa', 'desª', 'des.ª', 'des.a'
	};
	public static String ValidarValor(String valor, String campo, String opcao){
		if(valor != null){

			// valor curto
			if(valor.length() < 3)
				return 'O '+ campo +' deve ter no mínimo 3 caracteres';
			
			// valor repetido
			if(opcao=='texto')
				for(Integer cont=0; cont<=valor.length()-3; cont++)
					if(valor.substring(cont,cont+1).toLowerCase() == valor.substring(cont+1,cont+2).toLowerCase() && 
					   valor.substring(cont,cont+1).toLowerCase() == valor.substring(cont+2,cont+3).toLowerCase())
						return 'O '+ campo +' deve conter apenas sequências válidas';
			
			// valor invalido (genérico)
			for(String valor_invalido : valores_invalidos)
				if(valor.toLowerCase().Contains(valor_invalido))
					return 'O '+ campo +' deve conter apenas valores válidos';
				
			// valor invalido (nomes)
			if(campo.toLowercase().Contains('nome'))
				for(String valor_tratamento : valores_tratamentos)
					if(valor.toLowerCase().startsWith(valor_tratamento+' ') || valor.toLowerCase().startsWith(valor_tratamento+'.') ||
					   valor.toLowerCase() == valor_tratamento
					)
						return 'O '+ campo +' não deve incluir tratamentos, títulos ou funções';
					
		}
		
		return null;
    }

}