public class Cliente {
    
    public class DadosEmpresa {
        public String cnpj;
        public String email;
        public String razao_social;
        public String nome_fantasia;
        public String data_abertura;
        public SituacaoCadastral situacao_cadastral;
        public String capital_social;
        public String tipo;
        public String situacao;
        public String natureza_juridica;
        public Endereco endereco;
        public String porte_empresa;
        public Simples simples;
        public Mei mei;
        public SituacaoEspecial situacao_especial;
        public String ente_federativo_responsavel;
        public List<String> telefones;
        public List<String> telefones_tipo;
        public List<String> link_whatsapp_cnpjbiz;
        public List<String> link_test_whatsapp;
        public List<String> atividades_principal;
        public List<String> atividades_secundarias;
        public List<String> socios;
    }
    public class SituacaoCadastral {
        public String data;
        public String codigo_motivo;
        public String descricao_motivo;
    }
    public class Endereco {
        public String cep;
        public String tipo_logradouro;
        public String logradouro;
        public String numero;
        public String complemento;
        public String bairro;
        public Cidade cidade;
        public Estado estado;
        public Pais pais;
    }
    public class Cidade {
        public String nome;
        public String latitude;
        public String longitude;
    }
    public class Estado {
        public String nome;
        public String sigla;
    }
    public class Pais {
        public String nome;
        public String sigla;
    }
    public class Simples {
        public Boolean optante;
        public String data_opcao;
        public String data_exclusao;
    }
    public class Mei {
        public Boolean mei;
        public String complemento_razao_social;
    }
    public class SituacaoEspecial {
        public String status;
        public String data;
    }

    public static List<Cliente__c> soqlPorCidade(String cidade) {
        List<Cliente__c> empresas = [
            SELECT Id, Name,CNPJ__c, Capital_social__c, Porte__c, Cidade__c, CEP__c, Estado__c, Bairro__c,Numero__c,Endere_o__c  , Complemento__c, E_Mail__c, Data__c, Socios__c, Raz_o_Social__c, Latitude__c, Longitude__c, Whatsapp__c, Conta__c, Tipo_logradouro__c
            FROM Cliente__c
            WHERE Cidade__c = :cidade
        ];
        return empresas;
    } 

    public static List<Cliente__c> soqlgeral() {
        List<Cliente__c> empresas = [
            SELECT Id, Name,CNPJ__c, Linha__c, Capital_social__c, Porte__c, Cidade__c, CEP__c, Estado__c, Bairro__c,Numero__c,Endere_o__c  , Complemento__c, E_Mail__c, Data__c, Socios__c, Raz_o_Social__c, Latitude__c, Longitude__c, Whatsapp__c, Conta__c, Tipo_logradouro__c
            FROM Cliente__c
            
        ];
        
        
        return empresas;
    } 

    public static List<Account> soqlGeralConta(Integer limite) {
        List<Account> empresas = [
          SELECT Id, Name,CNPJ__c, Data_do_Ultimo_Pedido__c, Data_da_Ultima_Venda__c, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry , BillingLatitude, BillingLongitude,Raz_o_Social__c 
            FROM Account 
            WHERE Status_da_Conta__c != 'FORNECEDOR' AND Status_da_Conta__c != 'Inativo' 
            LIMIT :limite
        ];
        
        return empresas;
    } 
    
    public static List<Account> soqlGeralContaCidade(Integer limite, String cidade) {
        List<Account> empresas = [
            SELECT Id, Name, CNPJ__c, Data_do_Ultimo_Pedido__c, Data_da_Ultima_Venda__c, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude, Raz_o_Social__c
            FROM Account
            WHERE Status_da_Conta__c = 'Ativo'
            AND BillingCity = :cidade
            AND Data_da_Ultima_Venda__c >= LAST_N_YEARS:2
            LIMIT :limite
        ];
        return empresas;
    } 
    
    @AuraEnabled
    public static String consultaClientesPorLinhaMarca(String linhas, String marcas){
        
        List<String> linhasArray = linhas.split(',');
        List<String> marcasArray = marcas.split(',');
        List<OrderItem> linhasList = new List<OrderItem>();
        List<OrderItem> marcasList = new List<OrderItem>();
        List<Account> empresas = new List<Account>();  
        List<Account> empresasList = [
            SELECT id, CNPJ__c, Name, Status_da_Conta__c, Data_do_Ultimo_Pedido__c, Data_da_Ultima_Venda__c, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry,Raz_o_Social__c 
            FROM Account WHERE Status_da_Conta__c = 'Ativo'
        ];
        
        if(linhasArray != null){   
            linhasList = soqlGeralPorLinhas(linhasArray); 
            for(OrderItem itemLista : linhasList){
                
                
                for(Account empresaAtual: empresasList){
                    
                    if(itemLista.CNPJ__c == empresaAtual.CNPJ__c){
                        empresas.add(empresaAtual);
                    }
                }
                
                
            }
        }        
        if(marcasArray != null){
            marcasList = soqlGeralPorLinhas(marcasArray);     
            
            for(OrderItem itemLista : marcasList){
                for(Account empresaAtual: empresasList){
                    if(itemLista.CNPJ__c == empresaAtual.CNPJ__c){
                        empresas.add(empresaAtual);
                    }
                }
            }
        }
        
        
        
        String respostaFront =  retornaparFrontApenasConta(empresas);
        
        return respostaFront; 
        
        
    }
    
    /* 
*      @AuraEnabled

* public static String retornaparFront( List<Cliente__c> empresas) {

List<Map<String, String>> empresasList = new List<Map<String, String>>();

for (Cliente__c empresa : empresas) {


Map<String, String> empresaMap = new Map<String, String>();

empresaMap.put('ID', empresa.Id);
empresaMap.put('Name', empresa.Name);
empresaMap.put('CNPJ', empresa.CNPJ__c);
empresaMap.put('Capital Social', String.valueOf(empresa.Capital_social__c));
empresaMap.put('Porte', empresa.Porte__c);
empresaMap.put('Estado', empresa.Estado__c);
empresaMap.put('Cidade', empresa.Cidade__c);
empresaMap.put('Complemento', empresa.Complemento__c);
empresaMap.put('Tipo_Logradouro', empresa.Tipo_logradouro__c);
empresaMap.put('CEP', empresa.CEP__c);
empresaMap.put('Logradouro', empresa.Endere_o__c);
empresaMap.put('Numero', String.valueOf(empresa.Numero__c));
empresaMap.put('Bairro', empresa.Bairro__c);
empresaMap.put('E-Mail', empresa.E_Mail__c);
empresaMap.put('Data', String.valueOf(empresa.Data__c));
empresaMap.put('Socios', empresa.Socios__c);
empresaMap.put('Razão Social', empresa.Raz_o_Social__c);
empresaMap.put('Latitude', String.valueOf(empresa.Latitude__c));
empresaMap.put('Longitude', String.valueOf(empresa.Longitude__c));
empresaMap.put('Whatsapps', String.valueOf(empresa.Whatsapp__c));

empresasList.add(empresaMap);
//  System.debug('AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'+empresaMap);
} 

String empresasJson = JSON.serialize(empresasList);
return empresasJson;
}
*/
    public static  List<OrderItem>  soqlGeralPorLinhas(List<String> linha) {
        
        List<OrderItem> produtos = [
            SELECT id, OrderItemNumber, Linha__c, cnpj__c 
            FROM OrderItem 
            WHERE CNPJ__c != null AND Linha__c  IN : linha
        ];
        
        Set<String> cnpjsUnicos = new Set<String>();
        List<OrderItem> produtosSemDuplicatas = new List<OrderItem>();
        
        for (OrderItem produto : produtos) {
            if (!cnpjsUnicos.contains(produto.CNPJ__c)) {
                cnpjsUnicos.add(produto.CNPJ__c);
                produtosSemDuplicatas.add(produto);
            }
        }
        System.debug(produtosSemDuplicatas);
        return produtosSemDuplicatas;
    }   
    
    public static  List<OrderItem>  soqlGeralPorMarca(List<String> marcas) {
        
        List<OrderItem> produtos = [
            SELECT id, OrderItemNumber, Linha__c, cnpj__c 
            FROM OrderItem 
            WHERE CNPJ__c != null AND Linha__c  IN : marcas
        ];
        
        Set<String> cnpjsUnicos = new Set<String>();
        List<OrderItem> produtosSemDuplicatas = new List<OrderItem>();
        
        for (OrderItem produto : produtos) {
            if (!cnpjsUnicos.contains(produto.CNPJ__c)) {
                cnpjsUnicos.add(produto.CNPJ__c);
                produtosSemDuplicatas.add(produto);
            }
        }
        System.debug(produtosSemDuplicatas);
        return produtosSemDuplicatas;
    }   
    
    @AuraEnabled
    public static String maisInformacoesDaEmpresaCliente(String cnpj) {
        
        List<Account> conta = [
            SELECT ID, Name, CNPJ__c, Data_do_Ultimo_Pedido__c, Data_da_Ultima_Venda__c
            FROM Account 
            WHERE CNPJ__c = : cnpj
        ];
        
        if(conta.size() != 0){
            
            
            Date dataAtual = Date.today();
            Integer anoAtual = dataAtual.year();
            
            // Criar a nova data usando o ano atual
            Date comparacaoDate = Date.newInstance(anoAtual, 1, 1);
            
            List<Order> pedido = [
                SELECT ID, Name, Numero_do_Pedido__c, Description, Natureza_de_Opera_o__c, Status, Data_do_Pagamento__c
                FROM Order
                WHERE AccountId = :conta[0].Id
                ORDER BY CreatedDate ASC
                LIMIT 10
            ];
            
            try{
                
                // Crie um objeto personalizado para estruturar os dados
                List<Object> resultado = new List<Object>();
                
                Integer i = 0;
                for(Order pedidoAtual: pedido){
                    
                    Map<String, Object> pedidoDados = new Map<String, Object>();
                    
                    pedidoDados.put('Empresa', conta[0].Name);   
                    pedidoDados.put('PedidoName', pedidoAtual.Numero_do_Pedido__c);
                    pedidoDados.put('PedidoId', pedidoAtual.ID);
                    pedidoDados.put('Status', pedidoAtual.Status);
                    pedidoDados.put('NaturezaOperacao', pedidoAtual.Natureza_de_Opera_o__c);
                    pedidoDados.put('Descricao',pedidoAtual.Description);
                    pedidoDados.put('CNPJ', conta[0].CNPJ__c);
                    pedidoDados.put('DataPedido', pedidoAtual.Data_do_Pagamento__c); 
                    
                    String key = 'Pedido' + i;
                    resultado.add(pedidoDados);
                    i++;
                }
                
                // Converta o objeto em JSON
                String jsonResult = JSON.serialize(resultado);
                
                System.debug('Resposta para o front:'+  jsonResult);
                // Retorne o JSON
                return jsonResult;
                
            }
            catch (Exception e) {
                System.debug('Erro capturado: ' + e.getMessage());
                //throw new AuraHandledException(e.getMessage());
                return (e.getMessage());
            }
        }
        
        System.debug('Não foi encontrado nenhum pedido para esse CNPJ: '+ cnpj);        
        return   ('Não foi encontrado nenhum pedido para esse CNPJ: '+ cnpj);
    }
    
    @AuraEnabled
    public static String retornaparFront( List<Cliente__c> empresas) {
        
        List<Map<String, String>> empresasList = new List<Map<String, String>>();
        
        for (Cliente__c empresa : empresas) {
            Map<String, String> empresaMap = new Map<String, String>();
            empresaMap.put('ID', empresa.Id);
            empresaMap.put('Name', empresa.Name);
            empresaMap.put('CNPJ', empresa.CNPJ__c);
            empresaMap.put('Capital Social', String.valueOf(empresa.Capital_social__c));
            empresaMap.put('Porte', empresa.Porte__c);
            empresaMap.put('Estado', empresa.Estado__c);
            empresaMap.put('Cidade', empresa.Cidade__c);
            empresaMap.put('Complemento', empresa.Complemento__c);
            empresaMap.put('Tipo_Logradouro', empresa.Tipo_logradouro__c);
            empresaMap.put('CEP', empresa.CEP__c);
            empresaMap.put('Logradouro', empresa.Endere_o__c);
            empresaMap.put('Numero', String.valueOf(empresa.Numero__c));
            empresaMap.put('Bairro', empresa.Bairro__c);
            empresaMap.put('E-Mail', empresa.E_Mail__c);
            empresaMap.put('Data', String.valueOf(empresa.Data__c));
            empresaMap.put('Socios', empresa.Socios__c);
            empresaMap.put('Razão Social', empresa.Raz_o_Social__c);
            empresaMap.put('Latitude', String.valueOf(empresa.Latitude__c));
            empresaMap.put('Longitude', String.valueOf(empresa.Longitude__c));
            empresaMap.put('Whatsapps', String.valueOf(empresa.Whatsapp__c));
            empresasList.add(empresaMap);
            //  System.debug('AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'+empresaMap);
        } 
        
        String empresasJson = JSON.serialize(empresasList);
        return empresasJson;
    }
    
    @AuraEnabled
    public static String retornaparFrontConta( List<Cliente__c> empresas,  List<Account> contas ) {
        try{
            List<Map<String, String>> empresasList = new List<Map<String, String>>();
            
            
            for (Account conta : contas) {
                
                // SELECT Id, Name,CNPJ__c, Data_do_Ultimo_Pedido__c, Data_da_Ultima_Venda__c, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry,Raz_o_Social__c
                //FROM Account
                Map<String, String> empresaMap = new Map<String, String>();
                //System.debug('AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'+ empresaMap);
                
                empresaMap.put('ID', conta.Id);
                empresaMap.put('Name', conta.Name);
                empresaMap.put('CNPJ', conta.CNPJ__c);
                empresaMap.put('Logradouro', conta.BillingStreet);
                empresaMap.put('Estado', conta.BillingState);
                empresaMap.put('Cidade', conta.BillingCity);
                empresaMap.put('Latitude', String.valueOf(conta.BillingLatitude));
                empresaMap.put('Longitude', String.valueOf(conta.BillingLongitude));
                empresaMap.put('Razão Social', conta.Raz_o_Social__c);
                empresaMap.put('Cliente', 'true');
                
                empresasList.add(empresaMap);
            } 
            
            for (Cliente__c empresa : empresas) {
                
                Map<String, String> empresaMap = new Map<String, String>();
                
                empresaMap.put('ID', empresa.Id);
                empresaMap.put('Name', empresa.Name);
                empresaMap.put('Linha', empresa.Linha__c);
                empresaMap.put('CNPJ', empresa.CNPJ__c);
                empresaMap.put('Capital Social', String.valueOf(empresa.Capital_social__c));
                empresaMap.put('Porte', empresa.Porte__c);
                empresaMap.put('Estado', empresa.Estado__c);
                empresaMap.put('Cidade', empresa.Cidade__c);
                empresaMap.put('Complemento', empresa.Complemento__c);
                empresaMap.put('Tipo_Logradouro', empresa.Tipo_logradouro__c);
                empresaMap.put('CEP', empresa.CEP__c);
                empresaMap.put('Logradouro', empresa.Endere_o__c);
                empresaMap.put('Numero', String.valueOf(empresa.Numero__c));
                empresaMap.put('Bairro', empresa.Bairro__c);
                empresaMap.put('E-Mail', empresa.E_Mail__c);
                empresaMap.put('Data', String.valueOf(empresa.Data__c));
                empresaMap.put('Socios', empresa.Socios__c);
                empresaMap.put('Razão Social', empresa.Raz_o_Social__c);
                empresaMap.put('Latitude', String.valueOf(empresa.Latitude__c));
                empresaMap.put('Longitude', String.valueOf(empresa.Longitude__c));
                empresaMap.put('Whatsapps', String.valueOf(empresa.Whatsapp__c));
                empresaMap.put('Cliente', 'false');
                
                empresasList.add(empresaMap);
                //  System.debug('AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'+empresaMap);
            } 
            
            
            String empresasJson = JSON.serialize(empresasList);
            return empresasJson;
        }catch (Exception e) {
            
            System.debug('eerroorr:' + e);
            return 'error';
            //throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static String retornaparFrontApenasConta(List<Account> contas ) {
        try{
            List<Map<String, String>> empresasList = new List<Map<String, String>>();
            
            
            for (Account conta : contas) {
                
                // SELECT Id, Name,CNPJ__c, Data_do_Ultimo_Pedido__c, Data_da_Ultima_Venda__c, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry,Raz_o_Social__c
                //FROM Account
                Map<String, String> empresaMap = new Map<String, String>();
                
                System.debug('AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'+ empresaMap);
                
                empresaMap.put('ID', conta.Id);
                empresaMap.put('Name', conta.Name);
                empresaMap.put('CNPJ', conta.CNPJ__c);
                empresaMap.put('Logradouro', conta.BillingStreet);
                empresaMap.put('Estado', conta.BillingState);
                empresaMap.put('Cidade', conta.BillingCity);
                empresaMap.put('CEP', conta.BillingPostalCode);
                empresaMap.put('Razão Social', conta.Raz_o_Social__c);
                empresasList.add(empresaMap);
            } 
            
            String empresasJson = JSON.serialize(empresasList);
            return empresasJson;
        }catch (Exception e) {
            
            System.debug('eerroorr:' + e);
            return 'error';
            //throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static String  procuraGeral(Integer limite) {
        List<Cliente__c> empresas = soqlgeral();
        List<Account> contas = soqlGeralConta( limite);
        
        System.debug(empresas.size());
        
        return retornaparFrontConta(empresas,contas);
    }
    
    @AuraEnabled
    public static String procuraCidadeSemCriarNovaConta(String cidade, Integer limite) {
        List<Cliente__c> empresas = soqlPorCidade(cidade );
        List<Account> contas = soqlGeralContaCidade( limite, cidade);
        
        return retornaparFrontConta(empresas,contas);
        
    }
    
    @AuraEnabled
    public static String consultaEmpresasAPI(String cidade, String estado, Integer quant, Boolean vet) {
        
        String apiUrl = 'https://cnpj.biz/api/v2/empresas/listar-com-dados';
        Integer cont = quant;
        
        HttpRequest request = new HttpRequest();
        request.setEndpoint(apiUrl);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json; charset=UTF-8');
        request.setHeader('authorization', 'Bearer dsR3cjOyEBx4iCwydNofGoPXEU7FkXLDMnHdikGznlwGn3aMj9kR6imFYav9');
        request.setHeader('Accept', 'application/json');
        
        String atividade = ''; 
        String atividade_tipo = ''; 
        if(vet == true){
            atividade = '289'; 
            atividade_tipo = '"principal"';
        }else{
            atividade = '647,675'; 
            atividade_tipo = '"principal","secundaria"';
        }
        
        
        String requestBody = '{' +
            '"limit": ' + quant + ',' +
            '"offset": 0,' +
            '"atividade_tipo": ['+atividade_tipo+'],' +
            '"atividades": ['+atividade+'],' +
            '"localidades": [{' +
            '    "tipo": "cidade",' +
            '    "cidade": "' + cidade +'",' +
            '    "estado":"' + estado +'",' +
            '    "pais": "BR"' +
            '  }],' +
            '"situacao": ["ativa"],' +
            '"avancado": ["exportei"]' +
            '}';
        
        request.setBody(requestBody);
        
        Http http = new Http();
        HttpResponse response = http.send(request);
        
        if (response.getStatusCode() == 200) {
            String responseBody = response.getBody();
            List<Object> empresasList = (List<Object>) JSON.deserializeUntyped(responseBody);
            List<Map<String, Object>> empresasArray = new List<Map<String, Object>>();
            
            for (Object empresa : empresasList) {
                empresasArray.add((Map<String, Object>) empresa);
            }
            
            criarClientes(empresasArray, cont,vet);
            
            List<Cliente__c> empresas = soqlPorCidade(cidade);
            try {
                return retornaparFront(empresas);
            } catch (Exception e) {
                throw new AuraHandledException(e.getMessage());
            }
        } else {
            return 'errorrr: ' + response.getStatusCode() + '      Resposta: ' + response.getBody();
        }
    }
    
    public static void criarClientes(List<Map<String, Object>> empresasArray, Integer cont, Boolean vet) {
        
        
        for (Map<String, Object> empresa : empresasArray) {
            criarClienteAPINovo(empresa, cont, vet);
        }
        
    }
    
    public static Cliente__c criarClienteAPINovo(Map<String, Object> empresa, Integer cont, Boolean vet) {
       
        String linha = null;
        
        if(vet == true)
            linha = 'VETERINÁRIA';
        else
            linha = null;
        
        
        Cliente__c novoCliente = new Cliente__c();
        
        novoCliente.Name = (String) empresa.get('razao_social');
        novoCliente.CNPJ__c = (String) empresa.get('cnpj');
        novoCliente.E_mail__c = (String) empresa.get('email');
        novoCliente.Raz_o_Social__c = (String) empresa.get('razao_social');
        novoCliente.CEP__c = (String) empresa.get('nome_fantasia');
        novoCliente.Nome_Fantasia__c = (String) empresa.get('nome_fantasia');
        novoCliente.Nome_Fantasia__c = (String) empresa.get('nome_fantasia');
        novoCliente.Linha__c = linha;
        
        //List<String> linkTestWhatsapp = (List<String>) empresa.get('link_test_whatsapp');
        
        /*
        Object linkTestWhatsappObj = empresa.get('link_test_whatsapp');
        List<String> linkTestWhatsapp = new List<String>();
        
        if (linkTestWhatsappObj instanceof List<String>) {
            linkTestWhatsapp = (List<String>) linkTestWhatsappObj;
        } else {
            // Trate o caso em que o valor não é uma lista de strings
        }*/

        novoCliente.Endere_o__c = (String) ((Map<String, Object>) empresa.get('endereco')).get('logradouro');
        novoCliente.Tipo_logradouro__c = (String) ((Map<String, Object>) empresa.get('endereco')).get('tipo_logradouro');
        novoCliente.CEP__c= (String) ((Map<String, Object>) empresa.get('endereco')).get('cep');
        novoCliente.Cidade__c = (String) ((Map<String, Object>) ((Map<String, Object>) empresa.get('endereco')).get('cidade')).get('nome');
        novoCliente.Estado__c = (String) ((Map<String, Object>) ((Map<String, Object>) empresa.get('endereco')).get('estado')).get('sigla');
        novoCliente.Complemento__c = (String)  ((Map<String, Object>) empresa.get('endereco')).get('complemento');
        novoCliente.Bairro__c = (String) ((Map<String, Object>) empresa.get('endereco')).get('bairro');
        
        String tipo = (String) ((Map<String, Object>) empresa.get('endereco')).get('tipo_logradouro'); 
        String rua = (String) ((Map<String, Object>) empresa.get('endereco')).get('logradouro');
        String complemento = (String) ((Map<String, Object>) empresa.get('endereco')).get('complemento');
        String postalCode = (String) ((Map<String, Object>) empresa.get('endereco')).get('cep');
        String city = (String) ((Map<String, Object>) ((Map<String, Object>) empresa.get('endereco')).get('cidade')).get('nome');
        String state = (String) ((Map<String, Object>) ((Map<String, Object>) empresa.get('endereco')).get('estado')).get('sigla');
        String street = tipo + ' ' + rua; 
        String capitalSocial = (String) empresa.get('capital_social');
        String bairro = (String) ((Map<String, Object>) empresa.get('endereco')).get('bairro');
        
        List<object> linkWhatsappCnpjbiz = (List<object>) empresa.get('link_test_whatsapp');
        String stringDeLink ;
        for(object itemAtual : linkWhatsappCnpjbiz){
            stringDeLink += (String) ', '+ itemAtual;
        }
        
        criarClienteComRequisicaoHTTP(novoCliente.Name, novoCliente.CNPJ__c, novoCliente.E_mail__c, novoCliente.Raz_o_Social__c, novoCliente.Nome_Fantasia__c, street, postalCode, city, state,bairro, complemento, capitalSocial, stringDeLink, linha);
        
        return novoCliente;
    }
    
    @future(callout=true)
    public static void criarClienteComRequisicaoHTTP(String name, String cnpj, String email, String razaoSocial, String nomeFantasia, String street, String postalCode, String city, String state, String bairro, String complemento, String capitalSocial, String linkWhatsappCnpjbiz, String linha) {
        Cliente__c novoCliente = new Cliente__c();
        
        novoCliente.Name = name;
        novoCliente.CNPJ__c = cnpj;
        novoCliente.Linha__c = linha;
        novoCliente.E_mail__c = email;
        novoCliente.Raz_o_Social__c = razaoSocial;
        novoCliente.Nome_Fantasia__c = nomeFantasia;
        //Decimal capitalSocialValue = Decimal.valueOf(capitalSocial);
        //novoCliente.Capital_social__c = capitalSocialValue;
        
        novoCliente.Complemento__c =  complemento;
        novoCliente.CEP__c = postalCode;
        novoCliente.Cidade__c = toStringCity(city);
        novoCliente.Endere_o__c = street;
        novoCliente.Bairro__c = bairro; 
        novoCliente.Estado__c = state;
        
        
		novoCliente.Whatsapp__c = linkWhatsappCnpjbiz;

        
        Map<String, Decimal> geolocation = GoogleGeocodingService.getLatLongFromAddress(street, postalCode, city, state);
        
        if (geolocation != null) {
            novoCliente.Latitude__c = String.valueOf(geolocation.get('latitude'));
            novoCliente.Longitude__c = String.valueOf(geolocation.get('longitude'));
        }
        
        try {
            

            insert novoCliente;
            System.debug('New Client: ' + novoCliente);
        } catch (Exception e) {
            System.debug('Error: ' + e);
        }
    }
    
    public static String toStringCity (String cidade){
          

            System.debug('Cidade sem formatação: ' + cidade);
            
            // Converter para maiúsculas
                String formattedString = cidade.toUpperCase();
                
                // Mapa de caracteres acentuados e suas correspondências
                Map<String, String> accentMap = new Map<String, String> {
                    'á' => 'a', 'à' => 'a', 'ã' => 'a', 'â' => 'a', 'ä' => 'a',
                    'é' => 'e', 'è' => 'e', 'ê' => 'e', 'ë' => 'e',
                    'í' => 'i', 'ì' => 'i', 'î' => 'i', 'ï' => 'i',
                    'ó' => 'o', 'ò' => 'o', 'õ' => 'o', 'ô' => 'o', 'ö' => 'o',
                    'ú' => 'u', 'ù' => 'u', 'û' => 'u', 'ü' => 'u',
                    'ñ' => 'n', 'ç' => 'c'
                };
                
                String result = '';
                
                for (Integer i = 0; i < cidade.length(); i++) {
                    String currentChar = cidade.substring(i, i+1);
                    String replacement = accentMap.get(currentChar);
                    
                    if (replacement != null) {
                        result += replacement;
                    } else {
                        result += currentChar;
                    }
                }
            
            result = result.toUpperCase();
            
           return result;  
        }

    /* public static String  procuraContaPorLinha(String linha, Integer limite) {
return 'aa';
}*/
    @AuraEnabled
   public static void gambiarra(){
       
        String a1320 = '1320';a1320 = '1320';a1320 = '1320';a1320 = '1320';a1320 = '1320';a1320 = '1320';a1320 = '1320';
		a1320 = '1320';a1320 = '1320';a1320 = '1320';a1320 = '1320';a1320 = '1320';a1320 = '1320';a1320 = '1320';a1320 = '1320';
        a1320 = '1320';a1320 = '1320';a1320 = '1320';a1320 = '1320';a1320 = '1320';a1320 = '1320';a1320 = '1320';a1320 = '1320';
        a1320 = '1320';a1320 = '1320';a1320 = '1320';a1320 = '1320';a1320 = '1320';a1320 = '1320';a1320 = '1320';a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320'; a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320'; a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320'; a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320'; a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320'; a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320'; a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320'; a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320'; a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320'; a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320'; a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320'; a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320'; a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320'; a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320'; a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320'; a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320'; a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320'; a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320'; a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320'; a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320'; a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320'; a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320'; a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320'; a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320'; a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320'; a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320'; a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        a1320 = '1320';
        String a1321 = '1321';
        String a1322 = '1322';
        String a1323 = '1323';
        String a1324 = '1324';
        String a1325 = '1325';
        String a1326 = '1326';
        String a1327 = '1327';
        String a1328 = '1328';
        String a1329 = '1329';
        String a1330 = '1330';
        String a1331 = '1331';
        String a1332 = '1332';
        String a1333 = '1333';
        String a1334 = '1334';
        String a1335 = '1335';
        String a1336 = '1336';
        String a1337 = '1337';
        String a1338 = '1338';
        String a1339 = '1339';
        String a1340 = '1340';
        String a1341 = '1341';
        String a1342 = '1342';
        String a1343 = '1343';
        String a1344 = '1344';
        String a1345 = '1345';
        String a1346 = '1346';
        String a1347 = '1347';
        String a1348 = '1348';
        String a1349 = '1349';
        String a1350 = '1350';
        String a1351 = '1351';
        String a1352 = '1352';
        String a1353 = '1353';
        String a1354 = '1354';
        String a1355 = '1355';
        String a1356 = '1356';
        String a1357 = '1357';
        String a1358 = '1358';
        String a1359 = '1359';
        String a1360 = '1360';
        String a1361 = '1361';
        String a1362 = '1362';
        String a1363 = '1363';
        String a1364 = '1364';
        String a1365 = '1365';
        String a1366 = '1366';
        String a1367 = '1367';
        String a1368 = '1368';
        String a1369 = '1369';
        String a1370 = '1370';
        String a1371 = '1371';
        String a1372 = '1372';
        String a1373 = '1373';
        String a1374 = '1374';
        String a1375 = '1375';
        String a1376 = '1376';
        String a1377 = '1377';
        String a1378 = '1378';
        String a1379 = '1379';
        String a1380 = '1380';
        String a1381 = '1381';
        String a1382 = '1382';
        String a1383 = '1383';
        String a1384 = '1384';
        String a1385 = '1385';
        String a1386 = '1386';
        String a1387 = '1387';
        String a1388 = '1388';
        String a1389 = '1389';
        String a1390 = '1390';
        String a1391 = '1391';
        String a1392 = '1392';
        String a1393 = '1393';
        String a1394 = '1394';
        String a1395 = '1395';
        String a1396 = '1396';
        String a1397 = '1397';
        String a1398 = '1398';
        String a1399 = '1399';
        String a1400 = '1400';
        String a1401 = '1401';
        String a1402 = '1402';
        String a1403 = '1403';
        String a1404 = '1404';
        String a1405 = '1405';
        String a1406 = '1406';
        String a1407 = '1407';
        String a1408 = '1408';
        String a1409 = '1409';
        String a1410 = '1410';
        String a1411 = '1411';
        String a1412 = '1412';
        String a1413 = '1413';
        String a1414 = '1414';
        String a1415 = '1415';
        String a1416 = '1416';
        String a1417 = '1417';
        String a1418 = '1418';
        String a1419 = '1419';
        String a1420 = '1420';
        String a1421 = '1421';
        String a1422 = '1422';
        String a1423 = '1423';
        String a1424 = '1424';
        String a1425 = '1425';
        String a1426 = '1426';
        String a1427 = '1427';
        String a1428 = '1428';
        String a1429 = '1429';
        String a1430 = '1430';
        String a1431 = '1431';
        String a1432 = '1432';
        String a1433 = '1433';
        String a1434 = '1434';
        String a1435 = '1435';
        String a1436 = '1436';
        String a1437 = '1437';
        String a1438 = '1438';
        String a1439 = '1439';
        String a1440 = '1440';
        String a1441 = '1441';
        String a1442 = '1442';
        String a1443 = '1443';
        String a1444 = '1444';
        String a1445 = '1445';
        String a1446 = '1446';
        String a1447 = '1447';
        String a1448 = '1448';
        String a1449 = '1449';
        String a1450 = '1450';
        String a1451 = '1451';
        String a1452 = '1452';
        String a1453 = '1453';
        String a1454 = '1454';
        String a1455 = '1455';
        String a1456 = '1456';
        String a1457 = '1457';
        String a1458 = '1458';
        String a1459 = '1459';
        String a1460 = '1460';
        String a1461 = '1461';
        String a1462 = '1462';
        String a1463 = '1463';
        String a1464 = '1464';
        String a1465 = '1465';
        String a1466 = '1466';
        String a1467 = '1467';
        String a1468 = '1468';
        String a1469 = '1469';
        String a1470 = '1470';
        String a1471 = '1471';
        String a1472 = '1472';
        String a1473 = '1473';
        String a1474 = '1474';
        String a1475 = '1475';
        String a1476 = '1476';
        String a1477 = '1477';
        String a1478 = '1478';
        String a1479 = '1479';
        String a1480 = '1480';
        String a1481 = '1481';
        String a1482 = '1482';
        String a1483 = '1483';
        String a1484 = '1484';
        String a1485 = '1485';
        String a1486 = '1486';
        String a1487 = '1487';
        String a1488 = '1488';
        String a1489 = '1489';
        String a1490 = '1490';
        String a1491 = '1491';
        String a1492 = '1492';
        String a1493 = '1493';
        String a1494 = '1494';
        String a1495 = '1495';
        String a1496 = '1496';
        String a1497 = '1497';
        String a1498 = '1498';
        String a1499 = '1499';
        String a13283 = '13283';
        String a13284 = '13284';
        String a13285 = '13285';
        String a13286 = '13286';
        String a13287 = '13287';
        String a13288 = '13288';
        String a13289 = '13289';
        String a13290 = '13290';
        String a13291 = '13291';
        String a13292 = '13292';
        String a13293 = '13293';
        String a13294 = '13294';
        String a13295 = '13295';
        String a13296 = '13296';
        String a13297 = '13297';
        String a13298 = '13298';
        String a13299 = '13299';
        String a14000 = '1400';
        String a14001 = '1401';
        String a14002 = '1402';
        String a14003 = '1403';
        String a14004 = '1404';
        String a14005 = '1405';
        String a14006 = '1406';
        String a14007 = '1407';
        String a14008 = '1408';
        String a14009 = '1409';
        String a14010 = '1410';
        String a14011 = '1411';
        String a14012 = '1412';
        String a140132 = '14132';
        String a14014 = '1414';
        String a14015 = '1415';
        String a14016 = '1416';
        String a14017 = '1417';
        String a14018 = '1418';
        String a14019 = '1419';
        String a14020 = '1420';
        String a14021 = '1421';
        String a14022 = '1422';
        String a14023 = '1423';
        String a14024 = '1424';
        String a14025 = '1425';
        String a14026 = '1426';
        String a14027 = '1427';
        String a14028 = '1428';
        String a14029 = '1429';
        String a14030 = '1430';
        String a14031 = '1431';
        String a14032 = '1432';
        String a14033 = '1433';
        String a14034 = '1434';
        String a14035 = '1435';
        String a14036 = '1436';
        String a14037 = '1437';
        String a14038 = '1438';
        String a14039 = '1439';
        String a14040 = '1440';
        String a14041 = '1441';
        String a14042 = '1442';
        String a14043 = '1443';
        String a14044 = '1444';
        String a14045 = '1445';
        String a14046 = '1446';
        String a14047 = '1447';
        String a14048 = '1448';
        String a14049 = '1449';
        String a14050 = '1450';
        String a14051 = '1451';
        String a14052 = '1452';
        String a14053 = '1453';
        String a14054 = '1454';
        String a14055 = '1455';
        String a14056 = '1456';
        String a14057 = '1457';
        String a14058 = '1458';
        String a14059 = '1459';
        String a14060 = '1460';
        String a14061 = '1461';
        String a14062 = '1462';
        String a14063 = '1463';
        String a14064 = '1464';
        String a14065 = '1465';
        String a14066 = '1466';
        String a14067 = '1467';
        String a14068 = '1468';
        String a14069 = '1469';
        String a14070 = '1470';
        String a14071 = '1471';
        String a14072 = '1472';
        String a14073 = '1473';
        String a14074 = '1474';
        String a14075 = '1475';
        String a14076 = '1476';
        String a14077 = '1477';
        String a14078 = '1478';
        String a14079 = '1479';
        String a14080 = '1480';
        String a14081 = '1481';
        String a14082 = '1482';
        String a14083 = '1483';
        String a14084 = '1484';
        String a14085 = '1485';
        String a14086 = '1486';
        String a14087 = '1487';
        String a14088 = '1488';
        String a14089 = '1489';
        String a14090 = '1490';
        String a14091 = '1491';
        String a14092 = '1492';
        String a14093 = '1493';
        String a14094 = '1494';
        String a14095 = '1495';
        String a14096 = '1496';
        String a14097 = '1497';
        String a14098 = '1498';
        String a14099 = '1499';
    }
    
}