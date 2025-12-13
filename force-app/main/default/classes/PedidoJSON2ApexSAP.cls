public class PedidoJSON2ApexSAP {
	
	public class RespRegistro{
		public Integer Retorno;
		public String Mensagem;
		
		public String CodigoIntegracao;
		
		public RespRegistro parse(String json) {
			return (PedidoJSON2ApexSAP.RespRegistro) System.JSON.deserialize(json, PedidoJSON2ApexSAP.RespRegistro.class);
		}		
	}
	
	public class ReqInsRegistro{
		public String token;
		public String BaseSAP;
		
		public Integer tipoDocumento;
		public String produtoServico;
		public String id;
		// public String observacao;
		// public String obsInicial;
		public List<Map<String,String>> camposdeUsuario;
		public String obsFinal;
		public String dataLancamento;
		public String dataVencimento;
		public Integer filial;
			public ParceiroNegocio parceiroNegocio;
		public String enderecoCobranca;
		public String enderecoEntrega;
		public Integer condicaoPagamento;
		public String formaPagamento;
		public Integer codigoVendedor;
		public String entregaParcial;
		public String modFrete;
			public List<Linhas> linhas;
		
		public ReqInsRegistro(){
			camposdeUsuario = new List<Map<String,String>>();
			ParceiroNegocio = new ParceiroNegocio();
			linhas = new List<Linhas>();
		}
		
		public ReqInsRegistro parse(String json) {
			return (PedidoJSON2ApexSAP.ReqInsRegistro) System.JSON.deserialize(json, PedidoJSON2ApexSAP.ReqInsRegistro.class);
		}
	}
	public class ParceiroNegocio {
		public String codigoSap;
		public String codigoIntegracao;
	}
	public class Linhas {
			public Item item;
		public Double preco;
		public Decimal quantidade;
		public Double PercDesconto;
		public String deposito;
		public Decimal utilizacao;
		public String TextoLivre;
		
		public Linhas(){
			item = new Item();
		}
	}
	public class Item {
		public String codigoSap;
		public String NomeItem;
	}

	public class RespInsRegistro{
		public Integer Retorno;
		public String Mensagem;
	}
	
}