public class ContaJSON2ApexSAP {

	public class RespRegistro{		
		public Integer Retorno;
		public String Mensagem;
		
		public String CodigoSap;
		public String CodigoIntegracao;
		public List<Enderecos> enderecos;
		
		public RespRegistro parse(String json) {
			return (ContaJSON2ApexSAP.RespRegistro) System.JSON.deserialize(json, ContaJSON2ApexSAP.RespRegistro.class);
		}		
	}
	public class Enderecos {
		public String TipoEndereco;
		public String NomeEndereco;
		public String TipoLogradouro;
		public String Logradouro;
		public String Rua;
		public String Bairro;
		public String Cidade;
		public String Uf;
		public String Cep;
		public String CodigoIbge;
		public String Pais;
		public String Numero;
		public String Complemento;
	}

}