public class ObjetoSAP {

	public class Requisicao {
		public String token;
		public String BaseSAP;
		public List<String> lista;

		public Requisicao parse(String json) {
			return (ObjetoSAP.Requisicao) System.JSON.deserialize(json, ObjetoSAP.Requisicao.class);
		}
	}

	public class RequisicaoGenerica {
		public String token;
		public String BaseSAP;
		public String tabela;
		public String campoDescricao;
		public String campoCodigo;
		public List<String> lista;
		
		public RequisicaoGenerica(){
			lista = new List<String>();
		}
		
		public RequisicaoGenerica parse(String json) {
			return (ObjetoSAP.RequisicaoGenerica) System.JSON.deserialize(json, ObjetoSAP.RequisicaoGenerica.class);
		}
	}
	
	public class RespostaGenerica{		
		public List<RetornoGenerico> retorno;

		public RespostaGenerica parse(String json) {
			return (ObjetoSAP.RespostaGenerica) System.JSON.deserialize(json, ObjetoSAP.RespostaGenerica.class);
		}
	}
	public class RetornoGenerico {
		public String Descricao;
		public String CodigoSap;
	}
	
	public class Retorno {
		public Integer Id;
		public String ObjetoDesc;
		public String ComandoDesc;
		public String CodigoAuxiliar;
		public String ObjetoRef;
		public String ObjetoCodigoRef;

		public Retorno parse(String json) {
			return (ObjetoSAP.Retorno) System.JSON.deserialize(json, ObjetoSAP.Retorno.class);
		}
	}
	
	public class Conclusao {
		public String token;
		public List<Integer> lista;

		public Requisicao parse(String json) {
			return (ObjetoSAP.Requisicao) System.JSON.deserialize(json, ObjetoSAP.Requisicao.class);
		}
	}

	public class Parceiro {
		public String Cnpj;
		public String Cpf;
		public String Fantasia;
		public String RazaoSocial;
		public String DescricaoGrupo;
		public String InscricaoEstadual;
		public String InscricaoMunicipal;
		public String SetorNome;
		public String TextoLivre;
		public String Telefone2;
		public String Telefone;
		public String Fax;
		public String Celular;
		public String Site;
		public String Email;
		public List<Endereco> Enderecos;
		public Boolean Valid;

		public Parceiro parse(String json) {
			return (ObjetoSAP.Parceiro) System.JSON.deserialize(json, ObjetoSAP.Parceiro.class);
		}
	}

	public class Endereco {
		public String TipoEndereco;
		public String Logradouro;
		public String Numero;
		public String Complemento;
		public String Bairro;
		public String Cidade;
		public String Uf;
		public String Cep;
		public String Pais;

		public Endereco parse(String json) {
			return (ObjetoSAP.Endereco) System.JSON.deserialize(json, ObjetoSAP.Endereco.class);
		}
	}

	public class Item {
		public String CodigoSap;
		public Boolean Valid;
		public String NomeItem;
		public String Observacoes;
		public String DescricaoFabricante;
		public String DescricaoGrupo;
		public Boolean Caracteristica1; // item salesforce
		public Boolean Caracteristica2; // peça
		public Boolean Caracteristica3; // acessório
		public Boolean Caracteristica4; // equipamento
		public Boolean Caracteristica5; // consumivel
		public List<Estoque> Estoque;

		public Item parse(String json) {
			return (ObjetoSAP.Item) System.JSON.deserialize(json, ObjetoSAP.Item.class);
		}
	}

	public class Estoque {
		public String Deposito;
		public Decimal EmEstoque;
		public Decimal Confirmado;
		public Decimal EmPedido;

		public Estoque parse(String json) {
			return (ObjetoSAP.Estoque) System.JSON.deserialize(json, ObjetoSAP.Estoque.class);
		}
	}

	public class Documento {
		public Integer IdDocumentoCriado;
		public String CodigoIntegracao;
		public String Observacoes;
		public Parceiro ParceiroNegocio;
		public String VendedorNome;
		public String DataLancamento;
		public String Status;
		public String Cancelado;
		public String FormaPagto;
		public String CondicaoPagto;
		public Integer Incoterms;
		public Boolean EntregaParcial;
		public String DataVencimento;
		public String CnpjFilial;
		public List<Linha> Linhas;
		public List<Faturamento> Faturamento;

		public Documento parse(String json){
			return (ObjetoSAP.Documento) System.JSON.deserialize(json, ObjetoSAP.Documento.class);
		}
	}

	public class Linha {
		public String TextoLivre;
		public Integer NumLinha;
		public String CodigoItem;
		public String StatusPedLinha;
		public String InfEspecificas;
		public Decimal Preco;
		public Decimal Quantidade;

		public Linha parse(String json){
			return (ObjetoSAP.Linha) System.JSON.deserialize(json, ObjetoSAP.Linha.class);
		}
	}

	public class Faturamento {
		public Integer DocEntry;
		public Integer TipoDocBase;
		public Integer DocEntryBase;
		public String Tipo;
		public String Status;
		public Boolean Cancelado;
		public String Modelo;
		public String NumNF;
		public String NumNFSe;
		public String Data;
		public Decimal ValorNFe;
		public String CnpjFilial;
		public String ChaveAcesso;
		public String LinkNFSe;

		public Faturamento parse(String json){
			return (ObjetoSAP.Faturamento) System.JSON.deserialize(json, ObjetoSAP.Faturamento.class);
		}
	}

	public class Anexo {
		public String ChaveAcesso;
		public String Base64;

		public Anexo parse(String json){
			return (ObjetoSAP.Anexo) System.JSON.deserialize(json, ObjetoSAP.Anexo.class);
		}
	}

}