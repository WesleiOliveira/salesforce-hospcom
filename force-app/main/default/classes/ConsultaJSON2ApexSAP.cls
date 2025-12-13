public class ConsultaJSON2ApexSAP {

	public class ReqLista{
		public String token;
		public String BaseSAP;
		
		public String tabela;
		public String campoDescricao;	// campo de pesquisa (ex: nome)
		public String campoCodigo; 		// campo de retorno  (ex: cod integração)
		public List<String> lista;
		
		public ReqLista(){
			lista = new List<String>();
		}
		public ReqLista parse(String json) {
			return (ConsultaJSON2ApexSAP.ReqLista) System.JSON.deserialize(json, ConsultaJSON2ApexSAP.ReqLista.class);
		}
	}
	
	public class RespLista{
		public List<Retorno> retorno;

		public RespLista parse(String json) {
			return (ConsultaJSON2ApexSAP.RespLista) System.JSON.deserialize(json, ConsultaJSON2ApexSAP.RespLista.class);
		}
	}
	public class Retorno {
		public String Descricao;
		public String CodigoSap;
	}
	
}