public class ContaReceitaJSON2Apex {

	public List<Atividade_principal> atividade_principal;
	public String data_situacao;
	public String nome;
	public String uf;
	public String telefone;
	public List<Atividade_principal> atividades_secundarias;
	public List<Qsa> qsa;
	public String situacao;
	public String bairro;
	public String logradouro;
	public String numero;
	public String cep;
	public String municipio;
	public String abertura;
	public String natureza_juridica;
	public String fantasia;
	public String cnpj;
	public String ultima_atualizacao;
	public String status;
	public String message;
	public String tipo;
	public String complemento;
	public String email;
	public String efr;
	public String motivo_situacao;
	public String situacao_especial;
	public String data_situacao_especial;
	public String capital_social;
	public Extra extra;

	public class Extra {
	}

	public class Atividade_principal {
		public String text;
		public String code;
	}

	public class Qsa {
		public String qual;
		public String nome;
	}

	public static ContaReceitaJSON2Apex parse(String json) {
		return (ContaReceitaJSON2Apex) System.JSON.deserialize(json, ContaReceitaJSON2Apex.class);
	}
}