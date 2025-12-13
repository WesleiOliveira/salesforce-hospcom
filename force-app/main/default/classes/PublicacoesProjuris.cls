public class PublicacoesProjuris {
    
    @future(callout=true)
    public static void callApiAndProcessResponse() {
        
        // Primeiro, requisição que gera o Token de autenticação
        Token_Projuris__mdt clientId = [SELECT DeveloperName, Token__c FROM Token_Projuris__mdt WHERE DeveloperName ='Client_ID'];
        Token_Projuris__mdt clientSecret = [SELECT DeveloperName, Token__c FROM Token_Projuris__mdt WHERE DeveloperName ='Client_secret'];
        
        Http http1 = new Http();
        HttpRequest requestt = new HttpRequest();
        requestt.setEndpoint('http://hospcom.integracao.projuris.com.br/api/auth-service/authenticate');
        requestt.setMethod('POST');
        requestt.setHeader('Content-Type', 'application/json');
        
        String body = '{' +
            '"username": "'+ clientId.Token__c + '",' +
            '"password": "' + clientSecret.Token__c + '"' +
            '}';
        requestt.setBody(body);
        HttpResponse response1 = http1.send(requestt);
        
        String token;
        
        if (response1.getStatusCode() == 200) {
            String resposta = response1.getBody();
            token = resposta.substringAfter('{"access_token":"').substringBefore('",');
            System.debug('token: ' + token);
        } else {
            System.debug('Erro ao obter token. Status code: ' + response1.getStatusCode());
            return;
        }
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://hospcom.integracao.projuris.com.br/api/publicacao/pageable?query=%20lastModifiedDate%20%3D%20%23%7BCURRENT_DATE%7D&size=150');
        request.setMethod('GET');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', 'Bearer ' + token); 
        
        HttpResponse response = http.send(request);
        
        if (response.getStatusCode() == 200) {
            ApiResponseWrapper apiResponse = (ApiResponseWrapper) JSON.deserialize(response.getBody(), ApiResponseWrapper.class);
            
            // Coletar todos os números de publicações para uma consulta em massa
            Set<String> numeroDocumentos = new Set<String>();
            for (ApiContent content : apiResponse.content) {
                numeroDocumentos.add(content.codigo);
            }
            
            // Consultar publicações já existentes no Salesforce
            Map<String, Publicacao__c> pubExistentes = new Map<String, Publicacao__c>();
            for (Publicacao__c processo : [SELECT Id, Name, Comarca__c, Descricao__c, Data_da_publicacao__c, Diario__c, Estado__c, Forum__c, Relacionado__c, Vara__c, Status__c, Processo_Judicial__c FROM Publicacao__c WHERE Name IN :numeroDocumentos]) {
                pubExistentes.put(processo.Name, processo);
            }
            
            // Coletar todos os números de processo judicial
            Set<String> numerosProcessosJudiciais = new Set<String>();
            for (ApiContent content : apiResponse.content) {
                numerosProcessosJudiciais.add(content.numeroProcesso);
            }
            
            // Consultar IDs dos processos judiciais correspondentes
            Map<String, Id> processosJudiciaisMap = new Map<String, Id>();
            for (Processo_Judicial__c processoJudicial : [SELECT Id, Name FROM Processo_Judicial__c WHERE Name IN :numerosProcessosJudiciais]) {
                processosJudiciaisMap.put(processoJudicial.Name, processoJudicial.Id);
            }
            
            // Processa cada item do conteúdo
            List<Publicacao__c> publicacoesParaInserir = new List<Publicacao__c>();
            List<Publicacao__c> publicacoesParaAtualizar = new List<Publicacao__c>();
            for (ApiContent content : apiResponse.content) {
                if (pubExistentes.containsKey(content.codigo)) {
                    // Atualizar o registro existente
                    Publicacao__c pubExistente = pubExistentes.get(content.codigo);
                    if (atualizarDados(pubExistente, content, processosJudiciaisMap)) {
                        publicacoesParaAtualizar.add(pubExistente);
                    }
                } else {
                    // Inserir novo registro
                    Publicacao__c pub = salvarDados(content, processosJudiciaisMap);
                    publicacoesParaInserir.add(pub);
                }
            }
            
            // Inserir todas as publicações novas
            if (!publicacoesParaInserir.isEmpty()) {
                insert publicacoesParaInserir;
            }
            
            // Atualizar todas as publicações existentes
            if (!publicacoesParaAtualizar.isEmpty()) {
                update publicacoesParaAtualizar;
            }
            
        } else {
            // Log erro
            System.debug('Resposta inválida. Status code: ' + response.getStatusCode());
        }
    }
    
    public static Publicacao__c salvarDados(ApiContent content, Map<String, Id> processosJudiciaisMap) {
        Publicacao__c pub = new Publicacao__c();
        pub.Name = content.codigo;       
        pub.Comarca__c = content.comarca;
        // Verifica o tamanho da descrição e divide se necessário
        if (content.descricao.length() > 131032) {
            pub.Descricao__c = content.descricao.substring(0, 131032);
            
            // Verifica se o restante da descrição também ultrapassa 131031 caracteres
            String restante = content.descricao.substring(131032);
            if (restante.length() > 131031) {
                pub.Descricao2__c = restante.substring(0, 131031);
            } else {
                pub.Descricao2__c = restante;
            }
        } else {
            pub.Descricao__c = content.descricao;
        }
        pub.Data_da_publicacao__c = Date.valueOf(content.dataPublicacao);
        pub.Diario__c = content.diario;
        pub.Estado__c = content.estado;
        pub.Forum__c = content.forum;
        pub.Relacionado__c = content.nomeRelacionado;
        pub.Vara__c = content.vara;
        pub.Status__c = content.status;
        
        // Verifica se o número do processo está no mapa antes de definir o campo
        if (processosJudiciaisMap.containsKey(content.numeroProcesso)) {
            pub.Processo_Judicial__c = processosJudiciaisMap.get(content.numeroProcesso);
        } else {
            pub.Processo_Judicial__c = null;
        }
        
        return pub;
    }
    
    public static Boolean atualizarDados(Publicacao__c pubExistente, ApiContent content, Map<String, Id> processosJudiciaisMap) {
        Boolean isUpdated = false;
        
        if (pubExistente.Comarca__c != content.comarca) {
            pubExistente.Comarca__c = content.comarca;
            isUpdated = true;
        }
        if (pubExistente.Descricao__c != content.descricao) {
            pubExistente.Descricao__c = content.descricao;
            if (content.descricao.length() > 131032) {
                pubExistente.Descricao__c = content.descricao.substring(0, 131032);
                // Verifica se o restante da descrição também ultrapassa 131031 caracteres
                String restante = content.descricao.substring(131032);
                if (restante.length() > 131031) {
                    pubExistente.Descricao2__c = restante.substring(0, 131031);
                } else {
                    pubExistente.Descricao2__c = restante;
                }
            } else {
                pubExistente.Descricao__c = content.descricao;
            }
            isUpdated = true;
        }
        if (pubExistente.Data_da_publicacao__c != Date.valueOf(content.dataPublicacao)) {
            pubExistente.Data_da_publicacao__c = Date.valueOf(content.dataPublicacao);
            isUpdated = true;
        }
        if (pubExistente.Diario__c != content.diario) {
            pubExistente.Diario__c = content.diario;
            isUpdated = true;
        }
        if (pubExistente.Estado__c != content.estado) {
            pubExistente.Estado__c = content.estado;
            isUpdated = true;
        }
        if (pubExistente.Forum__c != content.forum) {
            pubExistente.Forum__c = content.forum;
            isUpdated = true;
        }
        if (pubExistente.Relacionado__c != content.nomeRelacionado) {
            pubExistente.Relacionado__c = content.nomeRelacionado;
            isUpdated = true;
        }
        if (pubExistente.Vara__c != content.vara) {
            pubExistente.Vara__c = content.vara;
            isUpdated = true;
        }
        if (pubExistente.Status__c != content.status) {
            pubExistente.Status__c = content.status;
            isUpdated = true;
        }
        
        // Verifica se o número do processo está no mapa antes de definir o campo
        if (processosJudiciaisMap.containsKey(content.numeroProcesso)) {
            if (pubExistente.Processo_Judicial__c != processosJudiciaisMap.get(content.numeroProcesso)) {
                pubExistente.Processo_Judicial__c = processosJudiciaisMap.get(content.numeroProcesso);
                isUpdated = true;
            }
        } else {
            if (pubExistente.Processo_Judicial__c != null) {
                pubExistente.Processo_Judicial__c = null;
                isUpdated = true;
            }
        }
        
        return isUpdated;
    }
    
    // Classe wrapper para desserializar a resposta da API
    public class ApiResponseWrapper {
        public List<ApiContent> content;
    }
    
    public class ApiContent {
        public CreatedBy createdBy;
        public String createdDate;
        public String lastModifiedBy;
        public String lastModifiedDate;
        public Integer id;
        public String message;
        public String status;
        public String numeroProcesso;
        public Processo processo;
        public String codigo;
        public String dataPublicacao;
        public String dataLeitura;
        public Boolean ignorado;
        public Boolean atribuido;
        public Boolean lido;
        public List<String> responsaveis;
        public String termoEncontrado;
        public String nomeRelacionado;
        public String comarca;
        public String estado;
        public String vara;
        public String forum;
        public String diario;
        public String oab;
        public String descricao;
        public String observacao;
        public String justificativa;
    }
    
    public class CreatedBy {
        public String id;
        public String name;
        public String login;
        public String status;
    }
    
    public class Processo {
        public String createdBy;
        public String createdDate;
        public String lastModifiedBy;
        public String lastModifiedDate;
        public Integer id;
        public String message;
        public Map<String, Object> customFields;
        public String unidadeOrganizacional;
        public String unidadeOrganizacionalCentralizadora;
        public String dataInicio;
        public String natureza;
        public String tipoDaAcao;
        public String procedimento;
        public String tipoProcesso;
        public String nota;
        public String advogadosAdverso;
        public String advogadoPrincipalAdverso;
        public String advogadosCliente;
        public String advogadoPrincipalCliente;
        public String clientePrincipal;
        public String condicaoCliente;
        public String estadoAtual;
        public String adversoPrincipal;
        public String condicaoAdverso;
        public Boolean arbitral;
        public Boolean confidencial;
        public Boolean pad;
        public Boolean pactoDeNaoConcorrencia;
        public Boolean sigiloso;
        public Boolean reunido;
        public Boolean reuniaoEmBrinde;
        public Boolean processoModelo;
        public String pastaFisica;
        public String origemDoProcesso;
        public String numeroProcessoPrincipal;
        public String numeroProcesso;
        public String numeroProcessoAdverso;
        public String unidadeOrganizacionalGestor;
        public String unidadeOrganizacionalCentralizadoraGestor;
        public String unidadeOrganizacionalColaboradoresGestor;
        public String dataDistribuicao;
        public Boolean arbitralAdverso;
        public Boolean confidencialAdverso;
        public Boolean padAdverso;
        public Boolean pactoDeNaoConcorrenciaAdverso;
        public Boolean sigilosoAdverso;
        public Boolean reunidoAdverso;
        public Boolean reuniaoEmBrindeAdverso;
        public Boolean processoModeloAdverso;
        public String pastaFisicaAdverso;
        public String origemDoProcessoAdverso;
        public String numeroProcessoPrincipalAdverso;
        public String numeroProcessoAdversoAdverso;
        public String numeroProcessoAdversoGestor;
        public String numeroProcessoAdversoCentralizadoraGestor;
        public String numeroProcessoAdversoColaboradoresGestor;
        public String numeroProcessoAdversoDistribuicao;
    }
}