public without sharing class ProcessosProjuris {    
    @future(callout=true)
    public static void callApiAndProcessResponse() {
        
        //Primeiro, requisição que gera o Token de autenticação, necessária porque ele expira em 90 minutos
        Token_Projuris__mdt clientId = [SELECT DeveloperName, Token__c FROM Token_Projuris__mdt WHERE DeveloperName ='Client_ID'];
        Token_Projuris__mdt clientSecret = [SELECT DeveloperName, Token__c FROM Token_Projuris__mdt WHERE DeveloperName ='Client_secret'];
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(System.Label.Endpoint_POST_ProcessosProjuris);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        
        string body = '{'+
            +'"username": "'+ clientId.Token__c + '",'+
            +'"password": "' + clientSecret.Token__c + '"'+
            '}';
        request.setBody(body);
        system.debug(body);
        HttpResponse response1 = http.send(request);
        
        string token;
        
        if (response1.getStatusCode() == 200) {
            string resposta = response1.getBody();
            token = resposta.substringAfter('{"access_token":"').substringBefore('",');
            system.debug('token: ' +token);
        }
        
        Http http2 = new Http();
        HttpRequest request2 = new HttpRequest();
        request2.setEndpoint(System.Label.Endpoint_GET_ProcessosProjuris);
        request2.setMethod('GET');
        request2.setHeader('Content-Type', 'application/json');
        request2.setHeader('Authorization', 'Bearer ' + token); 
        
        HttpResponse response = http2.send(request2);
        
        if (response.getStatusCode() == 200) {
            ApiResponseWrapper apiResponse = (ApiResponseWrapper) JSON.deserialize(response.getBody(), ApiResponseWrapper.class);
            
            // Coletar todos os números de processos para uma consulta em massa
            Set<String> numeroDocumentos = new Set<String>();
            for (ApiContent content : apiResponse.content) {
                numeroDocumentos.add(content.numeroProcessoAtual.trim());
            }
            
            // Consultar processos já existentes no Salesforce
            Map<String, Processo_Judicial__c> processosExistentes = new Map<String, Processo_Judicial__c>();
            for (Processo_Judicial__c processo : [SELECT Id, Name FROM Processo_Judicial__c WHERE Name IN :numeroDocumentos]) {
                processosExistentes.put(processo.Name, processo);
            }
            
            // Listas para inserção e atualização em massa
            List<Processo_Judicial__c> processosParaInserir = new List<Processo_Judicial__c>();
            List<Processo_Judicial__c> processosParaAtualizar = new List<Processo_Judicial__c>();
            
            // Processa cada item do conteúdo
            for (ApiContent content : apiResponse.content) {
                Processo_Judicial__c processo = new Processo_Judicial__c();
                if (processosExistentes.containsKey(content.numeroProcessoAtual.trim())) {
                    // Atualiza os dados se o processo já existir
                    processo = processosExistentes.get(content.numeroProcessoAtual.trim());
                    processo = atualizarDados(processo, content);
                    processosParaAtualizar.add(processo);
                } else {
                    // Cria um novo processo se não existir
                    processo = mapearDados(content);
                    processosParaInserir.add(processo);
                }
            }
            
            // Inserção e atualização em massa
            if (!processosParaInserir.isEmpty()) {
                insert processosParaInserir;
            }
            if (!processosParaAtualizar.isEmpty()) {
                update processosParaAtualizar;
            }
            
        } else {
            // Log error or take appropriate actions
            System.debug('Failed to get a valid response. Status code: ' + response.getStatusCode());
        }
    }
    
    public static Processo_Judicial__c mapearDados(ApiContent content) {
        Processo_Judicial__c PJ = new Processo_Judicial__c();
        PJ.Name = content.numeroProcessoAtual;
        PJ.Cliente_Principal__c = content.clientePrincipal != null ? content.clientePrincipal.nome : null;
        PJ.Adverso_Principal__c = content.adversoPrincipal != null ? content.adversoPrincipal.nome : null;
        PJ.Natureza__c = content.natureza != null ? content.natureza.nome : null;
        PJ.ID_Processo__c = content.id;
        PJ.Procedimento__c = content.procedimento != null ? content.procedimento.nome : null;
        PJ.Causa_raiz_1__c = content.causaRaizUm != null ? content.causaRaizUm.nome : null;
        PJ.Tipo_de_Processo__c = content.tipoProcesso;
		PJ.Pedido_de_liminar__c = (content.pedidoLiminar == true);
        PJ.Natureza_financeira__c = content.naturezaFinanceira;
        PJ.Jurisdicao_atual__c = content.jurisdicaoAtual;
        PJ.Data_de_inicio__c = content.dataInicio != null ? date.valueOf(content.dataInicio) : null;
        PJ.Tipo_da_acao__c = content.TipoDaAcao != null ? content.TipoDaAcao.nome : null;
        PJ.Status__c = content.status;
        PJ.Valor_da_causa__c = content.valorCausa;
        
        return PJ;
    }
    
    public static Processo_Judicial__c atualizarDados(Processo_Judicial__c processo, ApiContent content) {
        processo.Cliente_Principal__c = content.clientePrincipal != null ? content.clientePrincipal.nome : null;
        processo.Adverso_Principal__c = content.adversoPrincipal != null ? content.adversoPrincipal.nome : null;
        processo.Natureza__c = content.natureza != null ? content.natureza.nome : null;
        processo.ID_Processo__c = content.id;
        processo.Procedimento__c = content.procedimento != null ? content.procedimento.nome : null;
        processo.Causa_raiz_1__c = content.causaRaizUm != null ? content.causaRaizUm.nome : null;
        processo.Tipo_de_Processo__c = content.tipoProcesso;
        processo.Pedido_de_liminar__c = content.pedidoLiminar;
        processo.Natureza_financeira__c = content.naturezaFinanceira;
        processo.Jurisdicao_atual__c = content.jurisdicaoAtual;
        processo.Data_de_inicio__c = content.dataInicio != null ? date.valueOf(content.dataInicio) : null;
        processo.Tipo_da_acao__c = content.TipoDaAcao != null ? content.TipoDaAcao.nome : null;       
        processo.Status__c = content.status;
        processo.Valor_da_causa__c = content.valorCausa;        
        return processo;
    }
    
    // Classes wrapper para desserializar a resposta da API
    public class ApiResponseWrapper {
        public List<ApiContent> content;
    }
    
    public class ApiContent {
        public CreatedBy createdBy;
        public String createdDate;
        public LastModifiedBy lastModifiedBy;
        public String lastModifiedDate;
        public String id;
        public Map<String, Object> customFields;
        public String status;
        public Integer pasta;
        public String numeroProcessoAtual;
        public Natureza natureza;
        public ClientePrincipal clientePrincipal;
        public AdversoPrincipal adversoPrincipal;
        public AdvogadoPrincipalCliente advogadoPrincipalCliente;
        public AdvogadoPrincipalAdverso advogadoPrincipalAdverso;
        public List<AdvogadosCliente> advogadosCliente;
        public List<AdvogadosAdverso> advogadosAdverso;
        public Decimal beneficioAuferido;
        public Contrato contrato;
        public String dataCancelamentoBaixaProvisoria;
        public String dataEncerramento;
        public String dataInicio;
        public String dataReabertura;
        public String estrategia;
        public TipoDaAcao tipoDaAcao;
        public Procedimento procedimento;
        public UnidadeOrganizacional unidadeOrganizacional;
        public UnidadeOrganizacionalCentralizadora unidadeOrganizacionalCentralizadora;
        public CausaRaizUm causaRaizUm;
        public CausaRaizDois causaRaizDois;
        public CausaRaizTres causaRaizTres;
        public String tipoProcesso;
        public Boolean pedidoLiminar;
        public String nota;
        public String naturezaFinanceira;
        public Decimal valorCausa;
        public Boolean provisionar;
        public String notaReabertura;
        public MotivoReabertura motivoReabertura;
        public String notaBaixaProvisoria;
        public String dataBaixaProvisoria;
        public MotivoBaixaProvisoria motivoBaixaProvisoria;
        public String notaCancelamentoBaixaProvisoria;
        public MotivoCancelamentoBaixaProvisoria motivoCancelamentoBaixaProvisoria;
        public MotivoEncerramento motivoEncerramento;
        public String jurisdicaoAtual;
    }
    
    public class CreatedBy {
        public Integer id;
        public String name;
        public String login;
        public String status;
    }
    
    public class LastModifiedBy {
        public Integer id;
        public String name;
        public String login;
        public String status;
    }
    
    public class Natureza {
        public CreatedBy createdBy;
        public String createdDate;
        public LastModifiedBy lastModifiedBy;
        public String lastModifiedDate;
        public String id;
        public String nome;
        public Map<String, Object> customFields;
    }
    
    public class ClientePrincipal {
        public CreatedBy createdBy;
        public String createdDate;
        public LastModifiedBy lastModifiedBy;
        public String lastModifiedDate;
        public String id;
        public String nome;
        public Map<String, Object> customFields;
    }
    
    public class AdversoPrincipal {
        public CreatedBy createdBy;
        public String createdDate;
        public LastModifiedBy lastModifiedBy;
        public String lastModifiedDate;
        public String id;
        public String nome;
        public Map<String, Object> customFields;
    }
    
    public class AdvogadoPrincipalCliente {
        public CreatedBy createdBy;
        public String createdDate;
        public LastModifiedBy lastModifiedBy;
        public String lastModifiedDate;
        public String id;
        public String nome;
        public Map<String, Object> customFields;
    }
    
    public class AdvogadoPrincipalAdverso {
        public CreatedBy createdBy;
        public String createdDate;
        public LastModifiedBy lastModifiedBy;
        public String lastModifiedDate;
        public String id;
        public String nome;
        public Map<String, Object> customFields;
    }
    
    public class AdvogadosCliente {
        public CreatedBy createdBy;
        public String createdDate;
        public LastModifiedBy lastModifiedBy;
        public String lastModifiedDate;
        public String id;
        public String nome;
        public Map<String, Object> customFields;
    }
    
    public class AdvogadosAdverso {
        public CreatedBy createdBy;
        public String createdDate;
        public LastModifiedBy lastModifiedBy;
        public String lastModifiedDate;
        public String id;
        public String nome;
        public Map<String, Object> customFields;
    }
    
    public class Contrato {
        public CreatedBy createdBy;
        public String createdDate;
        public LastModifiedBy lastModifiedBy;
        public String lastModifiedDate;
        public String id;
        public String nome;
        public Map<String, Object> customFields;
    }
    
    public class TipoDaAcao {
        public CreatedBy createdBy;
        public String createdDate;
        public LastModifiedBy lastModifiedBy;
        public String lastModifiedDate;
        public String id;
        public String nome;
        public Map<String, Object> customFields;
    }
    
    public class Procedimento {
        public CreatedBy createdBy;
        public String createdDate;
        public LastModifiedBy lastModifiedBy;
        public String lastModifiedDate;
        public String id;
        public String nome;
        public Map<String, Object> customFields;
    }
    
    public class UnidadeOrganizacional {
        public CreatedBy createdBy;
        public String createdDate;
        public LastModifiedBy lastModifiedBy;
        public String lastModifiedDate;
        public String id;
        public String nome;
        public Map<String, Object> customFields;
    }
    
    public class UnidadeOrganizacionalCentralizadora {
        public CreatedBy createdBy;
        public String createdDate;
        public LastModifiedBy lastModifiedBy;
        public String lastModifiedDate;
        public String id;
        public String nome;
        public Map<String, Object> customFields;
    }
    
    public class CausaRaizUm {
        public CreatedBy createdBy;
        public String createdDate;
        public LastModifiedBy lastModifiedBy;
        public String lastModifiedDate;
        public String id;
        public String nome;
        public Map<String, Object> customFields;
    }
    
    public class CausaRaizDois {
        public CreatedBy createdBy;
        public String createdDate;
        public LastModifiedBy lastModifiedBy;
        public String lastModifiedDate;
        public String id;
        public String nome;
        public Map<String, Object> customFields;
    }
    
    public class CausaRaizTres {
        public CreatedBy createdBy;
        public String createdDate;
        public LastModifiedBy lastModifiedBy;
        public String lastModifiedDate;
        public String id;
        public String nome;
        public Map<String, Object> customFields;
    }
    
    public class MotivoReabertura {
        public CreatedBy createdBy;
        public String createdDate;
        public LastModifiedBy lastModifiedBy;
        public String lastModifiedDate;
        public String id;
        public String nome;
        public Map<String, Object> customFields;
    }
    
    public class MotivoBaixaProvisoria {
        public CreatedBy createdBy;
        public String createdDate;
        public LastModifiedBy lastModifiedBy;
        public String lastModifiedDate;
        public String id;
        public String nome;
        public Map<String, Object> customFields;
    }
    
    public class MotivoCancelamentoBaixaProvisoria {
        public CreatedBy createdBy;
        public String createdDate;
        public LastModifiedBy lastModifiedBy;
        public String lastModifiedDate;
        public String id;
        public String nome;
        public Map<String, Object> customFields;
    }
    
    public class MotivoEncerramento {
        public CreatedBy createdBy;
        public String createdDate;
        public LastModifiedBy lastModifiedBy;
        public String lastModifiedDate;
        public String id;
        public String nome;
        public Map<String, Object> customFields;
    }
}