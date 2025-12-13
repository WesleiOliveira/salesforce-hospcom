public with sharing class ListagemFornecedoresDeUmComprador {

    public Account conta {get; set;}
    public List<Fornecedor> fornecedores {get; set;} 
    public List<Cliente> clientes {get; set;}   
    public List<ReferenciaBancaria> referencias {get; set;}
    
    public class Fornecedor {
        public String idFornecedor {get; set;}
        public String fornecedorName {get; set;}
        public String telefoneFornecedor {get; set;}
        public Integer anosDesdeCriacao {get; set;} 
        public Integer numCompradores {get; set;}
        public String nomeContato {get;set;}
    }

    public class Cliente {
        public String idCliente {get; set;}
        public String clienteName {get; set;}
        public String telefoneCliente {get; set;}
        public Integer anosDesdeCriacao {get; set;} 
        public Integer numCompradores {get; set;}
        public String nomeContato {get;set;}
        public String tipoConta {get;set;}
    }

    public class ReferenciaBancaria {
        public String idReferencia {get; set;}
        public String nome {get; set;}
        public String agencia {get; set;}
        public String banco {get; set;}
        public String telefoneGerente {get; set;}
        public String telefoneContato {get; set;}
        public String teleConta {get; set;}
        public String gerente {get; set;}
        public String nomeContato {get; set;}
        public String conta_bancaria {get; set;}
    }

    public static String trataId(String idEmpresa){
        if (idEmpresa.length() > 15) {
            return idEmpresa.substring(0, 15);
        } else {
            return idEmpresa;
        }        
    }

    public ListagemFornecedoresDeUmComprador(ApexPages.StandardController controller) {
        Id objetoPai = ((SObject)controller.getRecord()).Id;

        if (objetoPai.getSObjectType().getDescribe().getName() == 'Account') {
            try {
                // Recuperar a Account com o campo Matriz__c
                Account conta = [
                    SELECT Id, Matriz__c
                    FROM Account
                    WHERE Id = :objetoPai
                    LIMIT 1
                ];

                listagemFornecedores(conta);
                listagemClientes(conta);
                listagemReferencia(conta); // Chamando o método para listar referências bancárias
            } catch (Exception e) {
                System.debug('Error: ' + e);
            }
        }
    }

    public void listagemFornecedores(Account conta) {
        this.conta = conta;
        Id contaIdRef = (conta.Matriz__c != null) ? conta.Matriz__c : conta.Id;
        fornecedores = new List<Fornecedor>();

        List<AggregateResult> resultados = [
            SELECT Fornecedor__r.Id idFornecedor, Fornecedor__r.Name fornecedorName, Fornecedor__r.Phone telefoneFornecedor, Fornecedor__r.Data_de_cria_o_da_conta__c dataEmpresa, COUNT(Id) numCompradores
            FROM Fornecedor__c
            WHERE Comprador__c = :contaIdRef AND Fornecedor__r.Area_da_Saude__c = 'Sim'
            GROUP BY Fornecedor__r.Id, Fornecedor__r.Name, Fornecedor__r.Phone, Fornecedor__r.Data_de_cria_o_da_conta__c 
            ORDER BY COUNT(Id) DESC
            LIMIT 5
        ];
        
        for(AggregateResult resultado : resultados) {
            Fornecedor fornecedor = new Fornecedor();
            fornecedor.idFornecedor = (String)resultado.get('idFornecedor');
            fornecedor.fornecedorName = (String)resultado.get('fornecedorName');
            fornecedor.telefoneFornecedor = (String)resultado.get('telefoneFornecedor');
            
            // Calculando a diferença em anos
            Date dataEmpresa = (Date)resultado.get('dataEmpresa');
            fornecedor.anosDesdeCriacao = Date.today().year() - dataEmpresa.year();
            if (Date.today().month() < dataEmpresa.month() || (Date.today().month() == dataEmpresa.month() && Date.today().day() < dataEmpresa.day())) {
                fornecedor.anosDesdeCriacao--;
            }
            
            fornecedor.numCompradores = (Integer)resultado.get('numCompradores');
            
            try {
                String nome = nomeContatoFunction((String)resultado.get('idFornecedor')); 
                fornecedor.nomeContato = nome;
            } catch(Exception e) {
                System.debug('ERRO ao consultar');
            }
            
            fornecedores.add(fornecedor);
        }
    }

    public void listagemClientes(Account conta) {
        Id contaIdRef = (conta.Matriz__c != null) ? conta.Matriz__c : conta.Id;

        List<AggregateResult> resultadosCliente = [            
            SELECT AccountId idCliente, Account.Name clienteName, Account.Type tipoConta, Account.Phone telefoneCliente, Account.Data_de_cria_o_da_conta__c dataEmpresa, COUNT(Id) numCompradores
            FROM Order  
            WHERE Faturamento_Feito__c = :contaIdRef AND Account.Type = 'CLIENTE' 
            GROUP BY AccountId, Account.Name, Account.Type, Account.Phone, Account.Data_de_cria_o_da_conta__c 
            ORDER BY COUNT(Id) DESC 
            LIMIT 5
        ];

        clientes = new List<Cliente>();
        
        if(resultadosCliente.size() > 0) {        
            for(AggregateResult resultadoCliente : resultadosCliente) {
                Cliente cliente = new Cliente();
                cliente.idCliente = (String)resultadoCliente.get('idCliente');
                cliente.clienteName = (String)resultadoCliente.get('clienteName');
                cliente.telefoneCliente = (String)resultadoCliente.get('telefoneCliente');
                cliente.tipoConta = (String)resultadoCliente.get('tipoConta');

                Date dataEmpresaCliente = (Date)resultadoCliente.get('dataEmpresa');
                cliente.anosDesdeCriacao = Date.today().year() - dataEmpresaCliente.year();
                if (Date.today().month() < dataEmpresaCliente.month() || (Date.today().month() == dataEmpresaCliente.month() && Date.today().day() < dataEmpresaCliente.day())) {
                    cliente.anosDesdeCriacao--;
                }

                cliente.numCompradores = (Integer)resultadoCliente.get('numCompradores');

                try {
                    String nomeCliente = nomeContatoFunction((String)resultadoCliente.get('idCliente')); 
                    cliente.nomeContato = nomeCliente;
                } catch(Exception e) {
                    System.debug('ERRO ao consultar cliente: ' + e);
                }

                clientes.add(cliente);
            }
        } else {
            clientes = null;
        }
    }

    public void listagemReferencia(Account conta) {
    Id contaIdRef = (conta.Matriz__c != null) ? conta.Matriz__c : conta.Id;

    List<Referencia_bancaria__c> referenciasBancarias = [
        SELECT Id, Name, Banco__c, Agencia__c, Telefone_Gerente__c, Telefone_Contato__c, Conta_bancaria__c, Tele_conta__c, Gerente__c, Conta__c, Contato__r.Name
        FROM Referencia_bancaria__c  
        WHERE Conta__c = :contaIdRef
        LIMIT 5
    ];

        
    referencias = new List<ReferenciaBancaria>();

    for (Referencia_bancaria__c referencia : referenciasBancarias) {
        ReferenciaBancaria ref = new ReferenciaBancaria();
        ref.idReferencia = referencia.Id;
        ref.nome = referencia.Name;
        ref.conta_bancaria = referencia.Conta_bancaria__c;
        ref.agencia = referencia.Agencia__c;
        ref.banco = referencia.Banco__c;
        ref.telefoneGerente = referencia.Telefone_Gerente__c;
        ref.telefoneContato = referencia.Telefone_Contato__c;
        ref.teleConta = referencia.Tele_conta__c;
        ref.gerente = referencia.Gerente__c;
        ref.nomeContato = referencia.Contato__r.Name;

        referencias.add(ref);
    }

    if (referencias.isEmpty()) {
        referencias = null;
    }
}


    public static String nomeContatoFunction(String idDoContato) {
        Contact contato = [
            SELECT Id, Name, AccountId
            FROM Contact
            WHERE AccountId = :idDoContato 
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];

        if (contato != null) {
            return contato.Name;
        } else {
            return null;
        }
    }
}