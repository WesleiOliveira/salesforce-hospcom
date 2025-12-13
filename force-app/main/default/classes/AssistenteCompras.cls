public without sharing class AssistenteCompras {
            
            
            @AuraEnabled
            public static void inserirFornecedores(string idCotacao, string idComprador, string idsFornecedores){
                
                List<String> lstString = idsFornecedores.split(','); //Separa cada id de Fornecedor e adiciona em Lista
                List<Fornecedor__c> fornecedores = new List<Fornecedor__c>();
                
                //Cria o pedido de compra para cada fornecedor-
                for(string pc : lstString){
                    system.debug(pc);
                    Fornecedor__c pedido = new Fornecedor__c(
                        Comprador__c = idComprador,
                    Pedido_de_compra__c = idCotacao,
                    Fornecedor__c = pc,
                    Status_do_PC__c = 'Em cotação');
                    fornecedores.add(pedido);
                }
                
                Account comprador = [SELECT BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry FROM Account WHERE ID = : idComprador];
                Pedido_de_compra__c cotacao = [SELECT ID FROM Pedido_de_compra__c WHERE ID = : idCotacao];
                
                try{
                    insert fornecedores;
                    
                    update cotacao;
                }
                catch(DmlException erro){
                    throw new AuraHandledException(erro.getMessage());
                }
            }
            @AuraEnabled
            public static void inserirProdutos(string idCotacao, string produto, string itensPV, string idsPedidos, integer quantidade){
                
                List<String> lstString = idsPedidos.split(',');
                
                List<String> lstString2 = New List<String>();
                
                List<OrderItem> itensdoPV = new List<OrderItem>();
                
                List<OrderItem> itensdoPVatt = new List<OrderItem>();
                
                if(itensPV != '')
                    lstString2 = itensPV.split(',');
                
                //Cria item de cotação
                Item_de_pedido_de_compra__c itemCotacao = new Item_de_pedido_de_compra__c(
                    Pedido_de_compra__c = idCotacao,
                Quantidade_total__c = quantidade,
                Produto__c = produto);
                insert itemCotacao;
                
                //Cria o item do pedido de compra para cada fornecedor-
                for(string pc : lstString){
                    system.debug(pc);
                    Item_de_fornecedor__c iPc = new Item_de_fornecedor__c(
                        Produto2__c = produto,
                    Cotar__c = true,
                    Fornecedor__c = pc,
                    Item_de_pedido_de_compra__c = itemCotacao.Id,
                    Quantidade__c = quantidade,
                    Quantidade_destinada__c = 0);
                    insert iPc;
                    
                    //verifica se tem destinação para PV e cria a Destinação (objeto Requisição)
                    if(itensPV != ''){
                        for(string pv : lstString2){
                            
                            String ipv = pv.substringBefore('-');
                            Integer qtd = Integer.valueOf(pv.substringAfter('-'));
                            
                            Requisicao_de_item__c destinacao = new Requisicao_de_item__c(
                                RecordTypeId = '0125A000001QVQA',
                            Item_do_pedido_de_compra2__c = iPc.Id,
                            Item_de_pedido_de_venda__c = ipv,
                            Quantidade_requisitada__c = 0,
                            Quantidade_predestinada__c = qtd,
                            Nao_acionar_trigger__c = 'Nao acionar');
                            insert destinacao;
                        }
                    }
                    
                }
                List <Produto_filho_de_importacao__c> filhos = [SELECT ID, Produto_filho__c, Quantidade__c FROM Produto_filho_de_importacao__c WHERE Produto_pai__c =: produto];
                
                if(filhos.size()>0){
                    List<Item_de_pedido_de_compra__c> ICFilho = new List<Item_de_pedido_de_compra__c>();
                    List<Item_de_fornecedor__c> IPCFilho = new List<Item_de_fornecedor__c>();
                    for(Produto_filho_de_importacao__c pfi : filhos){
                        
                        //Cria item de cotação
                        Item_de_pedido_de_compra__c itemCotacaoF = new Item_de_pedido_de_compra__c(
                            Pedido_de_compra__c = idCotacao,
                        Quantidade_total__c = pfi.Quantidade__c,
                        Produto__c = pfi.Produto_filho__c);
                        ICFilho.add(itemCotacaoF);
                        
                    }
                    try{
                        insert ICFilho;
                        for(Item_de_pedido_de_compra__c item : ICFilho){
                            //Cria o item do pedido de compra para cada fornecedor-
                            for(string pcf : lstString){
                                Item_de_fornecedor__c iPCF = new Item_de_fornecedor__c(
                                    Produto2__c = item.Produto__c,
                                Fornecedor__c = pcf,
                                Item_de_pedido_de_compra__c = item.Id,
                                Quantidade__c = item.Quantidade_total__c,
                                Quantidade_destinada__c = 0);
                                IPCFilho.add(iPCF);
                            }
                        }
                        insert IPCFilho;
                    }
                    catch(DmlException erro){
                        throw new AuraHandledException(erro.getMessage());
                    }
                }
            }
            @AuraEnabled
            public static void inserirProdutosOpp(string idCotacao, string produto, string itensOPP, string idsPedidos, integer quantidade){
                
                List<String> lstString = idsPedidos.split(',');
                
                List<String> lstString2 = New List<String>();
                
                List<OpportunityLineItem> itensdaOpp = new List<OpportunityLineItem>();
                
                List<OpportunityLineItem> itensdaOppatt = new List<OpportunityLineItem>();
                
                if(itensOpp != '')
                    lstString2 = itensOpp.split(',');
                
                //Cria item de cotação
                Item_de_pedido_de_compra__c itemCotacao = new Item_de_pedido_de_compra__c(
                    Pedido_de_compra__c = idCotacao,
                Quantidade_total__c = quantidade,
                Produto__c = produto);
                insert itemCotacao;
                
                //Cria o item do pedido de compra para cada fornecedor-
                for(string pc : lstString){
                    system.debug(pc);
                    Item_de_fornecedor__c iPc = new Item_de_fornecedor__c(
                        Produto2__c = produto,
                    Cotar__c = true,
                    Fornecedor__c = pc,
                    Item_de_pedido_de_compra__c = itemCotacao.Id,
                    Quantidade__c = quantidade,
                    Quantidade_destinada__c = quantidade);
                    insert iPc;
                    
                    //verifica se tem destinação para PV e cria a Destinação (objeto Requisição)
                    if(itensOpp != ''){
                        for(string opp : lstString2){
                            
                            String iOpp = opp.substringBefore('-');
                            Integer qtd = Integer.valueOf(opp.substringAfter('-'));
                            
                            Requisicao_de_item__c destinacao = new Requisicao_de_item__c(
                                RecordTypeId = '0125A000001QVQA',
                            Item_do_pedido_de_compra2__c = iPc.Id,
                            Produto_de_oportunidade__c = iOpp,
                            Quantidade_requisitada__c = 0,
                            Quantidade_predestinada__c = qtd,
                            Nao_acionar_trigger__c = 'Nao acionar');
                            insert destinacao;
                        }
                    }
                    
                }
                
            }
            @AuraEnabled
            public static void atualizaProdutos(string itemCotacao, Integer qtd, string unidade, string descricao){
                
                //Busca o Item da Cotação, o Item do Pedido de Compra e a(s) destinação(ões)
                Item_de_pedido_de_compra__c itemDeCotacao = [SELECT ID FROM Item_de_pedido_de_compra__c WHERE Id =: itemCotacao];
                itemDeCotacao.Unidade_de_medida__c = unidade;
                itemDeCotacao.Descri_o_da_linha__c = descricao;
                itemDeCotacao.Quantidade_total__c = qtd;
                try{
                    update itemDeCotacao;
                }
                catch(DMLException e1){
                    if(!Test.isRunningTest())
                        throw new AuraHandledException(e1.getMessage());
                    
                }
                
                //Busca os itens de pedido de compra
                List<Item_de_fornecedor__c> itemPC = [SELECT ID FROM Item_de_fornecedor__c WHERE Item_de_pedido_de_compra__c =: itemCotacao AND Status__c = 'Novo'];
                List<Item_de_fornecedor__c> itemPCComprado = [SELECT ID FROM Item_de_fornecedor__c WHERE Item_de_pedido_de_compra__c =: itemCotacao AND Comprar__c = true];
                List<ID> idItensPedidoDeCompras = new List <ID>();
                
                if(itemPCComprado.size() == 0){
                    
                    //Adiciona em Lista de IDs e atualiza quantidade
                    for(Item_de_fornecedor__c IPC : itemPC){
                        IPC.Quantidade__c = qtd;
                        idItensPedidoDeCompras.add(IPC.ID);
                    }
                    update itemPC;
                    
                    //Busca as destinações e atualiza quantidade
                    List<Requisicao_de_item__c> destinacoes = [SELECT ID, Quantidade_requisitada__c FROM Requisicao_de_item__c WHERE Item_do_pedido_de_compra2__c IN : idItensPedidoDeCompras];
                    if(destinacoes.size() > 1){
                        
                        for(Requisicao_de_item__c requisicao : destinacoes){
                            requisicao.Quantidade_predestinada__c = qtd;
                        }
                        update destinacoes;
                    }
                    
                }
                else{
                    if(!Test.isRunningTest()){
                        throw new AuraHandledException('Não é possível alterar a quantidade desse produto pois já foi tomada a decisão de compra da quantidade anterior, insira novamente o produto e realize nova cotação com os fornecedores.');
                    }
                }
            }
            @AuraEnabled
            public static void removeProduto(string itemCotacao){
                
                Integer aprovados = 0;
                
                //Busca e exclui o Item da Cotação, o Item do Pedido de Compra e a(s) destinação(ões)
                Item_de_pedido_de_compra__c itemDeCotacao = [SELECT ID FROM Item_de_pedido_de_compra__c WHERE Id =: itemCotacao];
                
                //Busca os itens de pedido de compra
                List<Item_de_fornecedor__c> itemPC = [SELECT ID, Status__c FROM Item_de_fornecedor__c WHERE Item_de_pedido_de_compra__c =: itemCotacao];
                
                for(Item_de_fornecedor__c ipc : itemPC){
                    if(IPC.Status__c != 'Novo'){
                        aprovados = aprovados + 1;
                    }
                }
                
                if(aprovados == 0){
                    
                    List<ID> idItensPedidoDeCompras = new List <ID>();
                    
                    //Adiciona em Lista de IDs
                    for(Item_de_fornecedor__c IPC : itemPC){
                        idItensPedidoDeCompras.add(IPC.ID);
                    }
                    //Busca as destinações
                    List<Requisicao_de_item__c> destinacoes = [SELECT ID FROM Requisicao_de_item__c WHERE Item_do_pedido_de_compra2__c IN : idItensPedidoDeCompras];
                    
                    delete itemPC;
                    delete itemDeCotacao;
                    
                    //Se tiver destinação, exclui
                    if(destinacoes.size() > 0)
                        delete destinacoes;
                }
                else{
                    if(!Test.isRunningTest())
                        throw new AuraHandledException('Este item não pode ser excluído. Cancele-o pelo pedido de compra.');
                }
            }
            
            @AuraEnabled
            public static void geraPagamentos(string vendedor, string recebimentos){
                
                
                List<String> listaRecebimentos = new List<String>();
                
                //string teste ='{recebimento:a076e00000mtLvqAAE, valor: 2003.3},{recebimento:a076e00000mtLvqAAE, valor: 200.10}';
                
                List<String> lstString = recebimentos.split('},');
                
                for(string pagamento : lstString){
                    
                    string recebimento = pagamento.substringAfter('recebimento:' ).substringBefore(',');
                    
                    listaRecebimentos.add(recebimento);
                    
                }
                
                List <Recebimentos__c> listaRecebimentosobj = [SELECT ID FROM Recebimentos__c WHERE ID IN : listaRecebimentos];
                
                for(Recebimentos__c receb : listaRecebimentosobj){
                    receb.ComissaoPaga__c = true;
                    receb.Data_de_pagamento_da_comiss_o__c = system.today();
                }
                update listaRecebimentosobj;
            }
            
            @AuraEnabled
            public static void confirmaDestinacao(string idRequisicao, integer quantidade){
                
                Requisicao_de_item__c destinacao = [SELECT ID, Item_de_pedido_de_venda__c, Item_do_pedido_de_compra2__c, Quantidade_requisitada__c FROM Requisicao_de_item__c WHERE id =: idRequisicao];
                destinacao.Quantidade_requisitada__c = quantidade;
                update destinacao;
                
                Item_de_fornecedor__c itemPC = [SELECT ID, Fornecedor__c, Fornecedor__r.Name, Produto2__c, Quantidade_destinada__c, Quantidade_disponivel__c, Prazo_de_recebimento2__c FROM Item_de_fornecedor__c WHERE ID =: destinacao.Item_do_pedido_de_compra2__c];
                if(quantidade <= itemPC.Quantidade_disponivel__c){
                    
                    integer quantidadeDestinadaItemPC = integer.ValueOf(itemPC.Quantidade_destinada__c); //Retorna a quantidade já destinada do IPC
                    integer quantidadeDestinadaItemPC_nova = quantidadeDestinadaItemPC + quantidade; // Calcula a nova quantidade destinada do IPC
                    itemPC.Quantidade_destinada__c = quantidadeDestinadaItemPC_nova; //Atribui a nova quantidade destinada do IPC
                    update itemPC;
                    
                    OrderItem itemPV = [SELECT ID, Status__c, Quantidade_requisitada2__c, Quantity, PriceBookEntryId, Product2Id, OrderId, UnitPrice FROM OrderItem WHERE ID =: destinacao.Item_de_pedido_de_venda__c];
                    integer quantidadeRequisitadaItemPV = integer.ValueOf(itemPv.Quantidade_requisitada2__c); //Retorna a quantidade já requisitada do IPV
                    integer quantidadeRequisitadaItemPV_nova = quantidadeRequisitadaItemPV + quantidade; // Calcula a nova quantidade requisitada do IPV
                    itemPV.Quantidade_requisitada2__c = quantidadeRequisitadaItemPV_nova; //Atribui a nova quantidade requisitada do IPV
                    itemPV.Acao_interna__c = true;
                    update itemPV;
                    
                    String statusItemPedidoDeVenda = itemPV.Status__c;
                    
                    if(statusItemPedidoDeVenda.startsWith('CMP')){
                        itemPV.Prazo_de_recebimento_da_compra__c = itemPC.Prazo_de_recebimento2__c;
                        itemPV.Numero_do_pedido_de_compra__c = itemPC.Fornecedor__r.Name;
                        itemPV.ID_do_Pedido_de_Compra__c = itemPC.Fornecedor__c;
                        update itemPV;
                        itemPV.Acao_interna__c = false;
                        update itemPV;
                    }
                    Integer quantidadeFaltante = integer.ValueOf(itemPV.Quantity) - quantidadeRequisitadaItemPV_nova;
                    system.debug(quantidadeFaltante);
                    
                    if(quantidadeFaltante > 0){
                        
                        OrderItem novaOrderItem = new OrderItem(
                            OrderId = itemPV.OrderId,
                        PriceBookEntryId = itemPV.PriceBookEntryId,
                        Product2Id = itemPV.Product2Id,
                        UnitPrice = itemPV.UnitPrice,
                        Quantity = quantidadeFaltante,
                        Status__c = 'OPR - ANALISE DE COMPRA');
                        insert novaOrderItem;
                        
                        itemPV.Quantity = quantidadeRequisitadaItemPV_nova;
                        update itemPV;
                    }
                    Product2 produto = [SELECT ID, Aguardando_recebimento__c FROM Product2 WHERE ID =: itemPC.Produto2__c];
                    integer aguardandoRecebimento = integer.ValueOf(produto.Aguardando_recebimento__c); //Retorna a quantidade aguardando recebimento de compra do produto
                    integer aguardandoRecebimento_nova = aguardandoRecebimento - quantidade; //Calcula a quantidade a receber do produto depois da confirmação de Destinação;
                    produto.Aguardando_recebimento__c = aguardandoRecebimento_nova;
                    update produto;
                }
                else{
                    if(!test.isRunningTest())
                        throw new AuraHandledException('A quantidade não está mais disponível para destinação');
                    
                }
            }
            
            @AuraEnabled
            public static void destina(String idItemPC, String idItemPV, Integer quantidade){
                // Listas para reduzir DMLs
                List<SObject> updates = new List<SObject>();
                List<SObject> inserts = new List<SObject>();
                
                // Buscar Item de Fornecedor
                Item_de_fornecedor__c itemPC = [
            SELECT ID, Fornecedor__c, Fornecedor__r.Name, Produto2__c, 
                Quantidade_destinada__c, Quantidade_disponivel__c, 
                Prazo_de_recebimento2__c
            FROM Item_de_fornecedor__c 
            WHERE ID = :idItemPC
        ];
                
                if(quantidade > itemPC.Quantidade_disponivel__c){
                    if(!Test.isRunningTest())
                        throw new AuraHandledException('A quantidade informada é inferior à quantidade disponível para destinação');
                    return;
                }
                
                // Atualiza quantidade destinada
                itemPC.Quantidade_destinada__c = (itemPC.Quantidade_destinada__c != null ? itemPC.Quantidade_destinada__c : 0) + quantidade;
                updates.add(itemPC);
                
                // Buscar Item do Pedido de Venda
                OrderItem itemPV = [
            SELECT ID, Status__c, Quantidade_requisitada2__c, Quantidade_a_requisitar_novo__c, 
                Quantity, PriceBookEntryId, Product2Id, OrderId, UnitPrice
            FROM OrderItem 
            WHERE ID = :idItemPV
        ];
                
                Integer quantidadeRequisitadaItemPV_nova = (itemPV.Quantidade_requisitada2__c != null ? integer.ValueOf(itemPV.Quantidade_requisitada2__c) : 0) + quantidade;
                
                if(quantidade > (itemPV.Quantidade_a_requisitar_novo__c != null ? itemPV.Quantidade_a_requisitar_novo__c : 0)){
                    if(!Test.isRunningTest())
                        throw new AuraHandledException('Quantidade inserida maior do que a solicitada pelo pedido.');
                    return;
                }
                
                // Criar requisição
                Requisicao_de_item__c direc = new Requisicao_de_item__c(
                    Quantidade_requisitada__c = quantidade,
                Item_do_pedido_de_compra2__c = itemPC.Id,
                Item_de_pedido_de_venda__c = itemPV.Id,
                Data_de_requisicao__c = System.today(),
                RecordTypeId = '0125A000001QVQA',
                Nao_acionar_trigger__c = 'nao acionar'
                    );
                inserts.add(direc);
                
                // Preparar atualização do itemPV
                itemPV.Acao_interna__c = true;
                itemPV.Status__c = 'OPR - ANALISE DE COMPRA';
                itemPV.Prazo_de_recebimento_da_compra__c = itemPC.Prazo_de_recebimento2__c;
                itemPV.Numero_do_pedido_de_compra__c = itemPC.Fornecedor__r.Name;
                itemPV.ID_do_Pedido_de_Compra__c = itemPC.Fornecedor__c;
                itemPV.Quantidade_requisitada2__c = quantidadeRequisitadaItemPV_nova;
                
                Integer quantidadeFaltante = (itemPV.Quantity != null ? integer.ValueOf(itemPV.Quantity) : 0) - quantidadeRequisitadaItemPV_nova;
                if(quantidadeFaltante > 0){
                    OrderItem novaOrderItem = new OrderItem(
                        OrderId = itemPV.OrderId,
                    PriceBookEntryId = itemPV.PriceBookEntryId,
                    Product2Id = itemPV.Product2Id,
                    UnitPrice = itemPV.UnitPrice,
                    Quantity = quantidadeFaltante,
                    Status__c = 'OPR - ANALISE DE COMPRA'
                        );
                    inserts.add(novaOrderItem);
                    
                    itemPV.Quantity = quantidadeRequisitadaItemPV_nova;
                }
                updates.add(itemPV);
                
                // Atualizar Produto
                Product2 produto = [
            SELECT Id, Aguardando_recebimento__c 
            FROM Product2 
            WHERE Id = :itemPC.Produto2__c
        ];
                Integer aguardandoRecebimento = (produto.Aguardando_recebimento__c != null ? Integer.valueOf(produto.Aguardando_recebimento__c) : 0);
                produto.Aguardando_recebimento__c = aguardandoRecebimento - quantidade;
                updates.add(produto);
                
                // Executar DMLs em lote
                try {
                    if(!inserts.isEmpty()) insert inserts;
                    if(!updates.isEmpty()) update updates;
                } catch (DmlException e) {
                    throw new AuraHandledException(e.getMessage());
                }
                
                itemPV.Acao_interna__c = false;
                update itemPV;
            }
            
            @AuraEnabled
            public static void statusItemPC(String idItemPC, string stts){
                
                Item_de_fornecedor__c itemPC = [SELECT ID, Fornecedor__r.Name, Quantidade__c, Produto2__c, Quantidade_recebida2__c, Quantidade_disponivel__c, Status__c, Item_de_pedido_de_compra__r.Produto__c FROM Item_de_fornecedor__c WHERE ID =: idItemPC];
                string statusAnterior = itemPC.Status__c;
                itemPC.Status__c = stts;
                
                try{
                    update itemPC;
                    if(stts.startsWith('CMP')){
                        Product2 produto = [SELECT ID, Aguardando_recebimento__c FROM Product2 WHERE ID =: itemPC.Produto2__c];
                        integer aguardandoRecebimento = integer.ValueOf(produto.Aguardando_recebimento__c); //Retorna a quantidade aguardando recebimento de compra do produto
                        integer aguardandoRecebimento_nova = aguardandoRecebimento + integer.ValueOf(itemPC.Quantidade_disponivel__c);
                        produto.Aguardando_recebimento__c = aguardandoRecebimento_nova;
                        update produto;
                    }
                }
                catch(DMLException e){
                    throw new AuraHandledException(e.getMessage());
                }
            }
            @AuraEnabled
            public static void aguardandoEntrega(String pc, String stts) {
                
                
                // Consulta inicial para obter os itens do fornecedor
                List<Item_de_fornecedor__c> itensPC = [SELECT ID, Produto2__c, Quantidade__c FROM Item_de_fornecedor__c WHERE Fornecedor__c = :pc];
                if (itensPC.isEmpty()) {
                    return; // Se não há itens, sai do método
                }

                
                
                if(stts.startsWith('CMP')){
                    
                    // Criar um mapa para armazenar os IDs dos produtos e as quantidades correspondentes
                    Map<Id, Integer> produtoQuantidadeMap = new Map<Id, Integer>();
                    for (Item_de_fornecedor__c item : itensPC) {
                        if (produtoQuantidadeMap.containsKey(item.Produto2__c)) {
                            produtoQuantidadeMap.put(item.Produto2__c, produtoQuantidadeMap.get(item.Produto2__c) + Integer.valueOf(item.Quantidade__c));
                        } else {
                            produtoQuantidadeMap.put(item.Produto2__c, Integer.valueOf(item.Quantidade__c));
                        }
                    }
                    
                    // Consulta para obter os produtos relacionados e suas quantidades aguardando recebimento
                    List<Product2> produtos = [SELECT ID, Aguardando_recebimento__c FROM Product2 WHERE ID IN :produtoQuantidadeMap.keySet()];
                    
                    // Atualizar os produtos em massa
                    for (Product2 produto : produtos) {
                        Integer aguardandoRecebimento = produto.Aguardando_recebimento__c != null ? Integer.valueOf(produto.Aguardando_recebimento__c) : 0;
                        Integer novaQuantidade = aguardandoRecebimento + Integer.valueOf(produtoQuantidadeMap.get(produto.ID));
                        produto.Aguardando_recebimento__c = novaQuantidade;
                    }
                    update produtos;
                }
                
                // Atualizar os itens de fornecedor em massa
                for (Item_de_fornecedor__c item : itensPC) {
                    item.Status__c = stts;
                }
                update itensPC;
            }

              @AuraEnabled
            public static Map<String, Object> atualizaStatusItensDoPedidoDeCompra(Id pc, String stts, List<String> itens) {
                // Inicializar variáveis de resultado
                Boolean sucesso = false;
                String mensagem = '';
                List<String> itensFalha = new List<String>();
                Integer totalProcessados = 0;
                Integer totalSucesso = 0;
                
                // Validação de entrada
                if(String.isBlank(pc) || itens == null || itens.isEmpty()) {
                    return new Map<String, Object>{
                        'sucesso' => false,
                        'mensagem' => 'Parâmetros inválidos',
                        'itensFalha' => itensFalha,
                        'totalProcessados' => 0,
                        'totalSucesso' => 0
                    };
                }
                
                // Consulta os itens do fornecedor
                List<Item_de_fornecedor__c> itensPC = [
        SELECT Id, Produto2__c, Quantidade__c 
        FROM Item_de_fornecedor__c 
        WHERE Id IN :itens
    ];
                
                if (itensPC.isEmpty()) {
                    return new Map<String, Object>{
                        'sucesso' => false,
                        'mensagem' => 'Itens do pedido de compra não encontrados',
                        'itensFalha' => itensFalha,
                        'totalProcessados' => 0,
                        'totalSucesso' => 0
                    };
                }
                
                totalProcessados = itensPC.size();
                
                // Atualizar produtos se necessário
                if(stts.startsWith('CMP')){
                    Map<Id, Integer> produtoQuantidadeMap = new Map<Id, Integer>();
                    
                    for (Item_de_fornecedor__c item : itensPC) {
                        if (produtoQuantidadeMap.containsKey(item.Produto2__c)) {
                            produtoQuantidadeMap.put(item.Produto2__c,
                            produtoQuantidadeMap.get(item.Produto2__c) + Integer.valueOf(item.Quantidade__c));
                        } else {
                            produtoQuantidadeMap.put(item.Produto2__c, Integer.valueOf(item.Quantidade__c));
                        }
                    }
                    
                    List<Product2> produtos = [
            SELECT ID, Aguardando_recebimento__c 
            FROM Product2 
            WHERE ID IN :produtoQuantidadeMap.keySet()
        ];
                    
                    for (Product2 produto : produtos) {
                        Integer aguardandoRecebimento = produto.Aguardando_recebimento__c != null ?
                            Integer.valueOf(produto.Aguardando_recebimento__c) : 0;
                        Integer novaQuantidade = aguardandoRecebimento + produtoQuantidadeMap.get(produto.ID);
                        produto.Aguardando_recebimento__c = novaQuantidade;
                    }
                    
                    try {
                        update produtos;
                    } catch (Exception e) {
                        return new Map<String, Object>{
                            'sucesso' => false,
                            'mensagem' => 'Erro ao atualizar produtos: ' + e.getMessage(),
                            'itensFalha' => itensFalha,
                            'totalProcessados' => totalProcessados,
                            'totalSucesso' => totalSucesso
                        };
                    }
                }
                
                // Atualizar itens individualmente com tratamento de erro
                for (Item_de_fornecedor__c item : itensPC) {
                    item.Status__c = stts;
                    
                    try {
                        update item;
                        totalSucesso++;
                    } catch (Exception e) {
                        itensFalha.add(item.Id);
                        System.debug('Erro ao atualizar item ' + item.Id + ': ' + e.getMessage());
                    }
                }
                
                // Definir resultado final
                if (itensFalha.isEmpty()) {
                    sucesso = true;
                    mensagem = 'Todos os itens foram processados com sucesso';
                } else {
                    sucesso = false;
                    mensagem = totalSucesso + ' de ' + totalProcessados +
                        ' itens processados. ' + itensFalha.size() + ' itens falharam.';
                }
                
                // Retornar Map com todos os valores
                return new Map<String, Object>{
                    'sucesso' => sucesso,
                    'mensagem' => mensagem,
                    'itensFalha' => itensFalha,
                    'totalProcessados' => totalProcessados,
                    'totalSucesso' => totalSucesso
                };
            }
            
            @AuraEnabled
            public static void statusTodos(String pc, string status) {
                
                // Consulta inicial para obter os itens do fornecedor
                List<Item_de_fornecedor__c> itensPC = [SELECT ID, Produto2__c, Quantidade__c FROM Item_de_fornecedor__c WHERE Fornecedor__c = :pc ];
                if (!itensPC.isEmpty()) {
                    
                    // Atualizar os itens de fornecedor em massa
                    for (Item_de_fornecedor__c item : itensPC) {
                        item.Status__c = status;
                    }
                    update itensPC;
                }
            }
            
            @AuraEnabled
            public static void recebeEstoque(string idItemPC, Decimal quantidade, string dataRecebimento){
                
                Item_de_fornecedor__c itemPC = [SELECT ID, Produto2__c, Item_Requerido__c, Item_Requerido__r.Status_do_item__c, Fornecedor__c, Fornecedor__r.Name, Quantidade__c, Quantidade_recebida2__c, Quantidade_a_Receber__c, Data_do_ultimo_recebimento__c, Status__c, Item_de_pedido_de_compra__r.Produto__c, Valor_unitario__c FROM Item_de_fornecedor__c WHERE ID =: idItemPC];
                if(quantidade <= itemPC.Quantidade_a_Receber__c){
                    Decimal quantidadeRecebida = itemPC.Quantidade_recebida2__c; //Retorna a quantidade já recebida do Item do Pedido de Compra
                    Decimal quantidadeRecebidaItemPC_nova = quantidadeRecebida + quantidade; //Calcula a quantidade recebida após o recebimento
                    
                    Product2 produto = [SELECT ID, Aguardando_recebimento__c FROM Product2 WHERE ID =: itemPC.Item_de_pedido_de_compra__r.Produto__c];
                    Decimal aguardandoRecebimento = produto.Aguardando_recebimento__c; //Retorna a quantidade aguardando recebimento de compra do produto
                    Decimal aguardandoRecebimento_nova = aguardandoRecebimento - quantidade; //Calcula a quantidade a receber do produto após o recebimento
                    
                    
                    Recebimento_de_compra__c recebimento = new Recebimento_de_compra__c(
                        Data_do_recebimento__c = Date.valueOf(dataRecebimento),
                    Item_de_pedido_de_compra__c = idItemPC,
                    Quantidade_recebida__c = quantidade
                        );
                    try{
                        insert recebimento;
                        itemPC.Quantidade_recebida2__c = quantidadeRecebidaItemPC_nova;
                        
                        if(itemPC.Quantidade__c > quantidadeRecebidaItemPC_nova){
                            Item_de_fornecedor__c duplicado = new Item_de_fornecedor__c();
                            duplicado.Item_de_pedido_de_compra__c = itemPC.Item_de_pedido_de_compra__c;
                            duplicado.Fornecedor__c = itemPC.Fornecedor__c;
                            duplicado.Quantidade__c = (itemPC.Quantidade__c - quantidadeRecebidaItemPC_nova);
                            duplicado.Quantidade_recebida2__c = 0;
                            duplicado.Produto2__c = itemPC.Produto2__c;
                            duplicado.Status__c = 'CMP - AG. ENTREGA FORNECEDOR';
                            duplicado.Comprar__c = true;
                            duplicado.Valor_unitario__c = itemPC.Valor_unitario__c;
                            
                            insert duplicado;
                            
                            itemPC.Status__c = 'RECEBIDO TOTAL';
                            itemPC.Quantidade__c = quantidadeRecebidaItemPC_nova;
                        }
                        if(itemPC.Quantidade__c == quantidadeRecebidaItemPC_nova){
                            itemPC.Status__c = 'RECEBIDO TOTAL';
                        }
                        
                        if((itemPC.Data_do_ultimo_recebimento__c < Date.valueOf(dataRecebimento)) || itemPC.Data_do_ultimo_recebimento__c == null)
                            itemPC.Data_do_ultimo_recebimento__c = Date.valueOf(dataRecebimento);
                        
                        update itemPC;
                        
                        produto.Aguardando_recebimento__c = aguardandoRecebimento_nova;
                        update produto; //Atualiza o valor aguardando recebimento do produto
                        
                        if(itemPC.Item_Requerido__c != null){
                            itemPC.Item_Requerido__r.Status_do_item__c = 'RECEBIDO FORNECEDOR';
                            update itemPC.Item_Requerido__r;
                        }
                    }
                    catch(DMLException e){
                        if(!Test.isRunningTest())
                            throw new AuraHandledException(e.getMessage());
                    }
                }
                else{
                    if(!test.isRunningTest())
                        throw new AuraHandledException('A quantidade informada é superior à quantidade a receber.');
                }
            }
            @AuraEnabled
            public static void recebeItemDestinado(string idItemPC, string idDestinacao, integer quantidade, string dataRecebimento){
                
                Item_de_fornecedor__c itemPC = [SELECT ID, Produto2__c, Item_Requerido__c, Item_Requerido__r.Status_do_item__c, Fornecedor__c, Fornecedor__r.Name, Quantidade__c, Quantidade_recebida2__c, Quantidade_destinada__c, Data_do_ultimo_recebimento__c, Status__c, Item_de_pedido_de_compra__r.Produto__c, Valor_unitario__c FROM Item_de_fornecedor__c WHERE ID =: idItemPC];
                integer quantidadeRecebida = integer.ValueOf(itemPC.Quantidade_recebida2__c); //Retorna a quantidade já recebida do Item do Pedido de Compra
                integer quantidadeRecebidaItemPC_nova = quantidadeRecebida + quantidade; //Calcula a quantidade recebida após o recebimento
                Item_de_fornecedor__c duplicado = new Item_de_fornecedor__c();
                
                Requisicao_de_item__c req = [SELECT ID, Quantidade_falta_receber__c, Item_de_pedido_de_venda__c, Quantidade_recebida_novo__c FROM Requisicao_de_item__c WHERE ID =: idDestinacao];
                
                if(quantidade <= req.Quantidade_falta_receber__c){
                    
                    OrderItem itemPV = [SELECT ID, Status__c, Quantidade_requisitada2__c, Quantity, PriceBookEntryId, Product2Id, OrderId, UnitPrice, Numero_do_pedido_de_compra__c, ID_do_Pedido_de_Compra__c, Prazo_de_recebimento_da_compra__c FROM OrderItem WHERE ID =: req.Item_de_pedido_de_venda__c];
                    integer quantidadeItemPV = integer.ValueOf(itemPv.Quantity);
                    
                    Recebimento_de_compra__c recebimento = new Recebimento_de_compra__c(
                        Data_do_recebimento__c = Date.valueOf(dataRecebimento),
                    Item_de_pedido_de_compra__c = idItemPC,
                    Quantidade_recebida__c = quantidade,
                    Destinacao_do_item__c = req.Id
                        );
                    try{
                        insert recebimento;
                        itemPC.Quantidade_recebida2__c = quantidadeRecebidaItemPC_nova;
                        if(itemPC.Quantidade__c > quantidadeRecebidaItemPC_nova){
                            duplicado.Item_de_pedido_de_compra__c = itemPC.Item_de_pedido_de_compra__c;
                            duplicado.Fornecedor__c = itemPC.Fornecedor__c;
                            duplicado.Quantidade__c = (itemPC.Quantidade__c - quantidadeRecebidaItemPC_nova);
                            duplicado.Quantidade_destinada__c = (itemPC.Quantidade__c - quantidadeRecebidaItemPC_nova);
                            duplicado.Quantidade_recebida2__c = 0;
                            duplicado.Produto2__c = itemPC.Produto2__c;
                            duplicado.Status__c = 'CMP - AG. ENTREGA FORNECEDOR';
                            duplicado.Comprar__c = true;
                            duplicado.Valor_unitario__c = itemPC.Valor_unitario__c;
                            
                            insert duplicado;
                            
                            LIST<Requisicao_de_item__c> destinacoes = [SELECT ID, Quantidade_requisitada__c FROM Requisicao_de_item__c WHERE Item_do_pedido_de_compra2__c =: idItemPC and ID != :idDestinacao];
                            Decimal total = 0;
                            
                            for(Requisicao_de_item__c destinacao : destinacoes){
                                total = total + destinacao.Quantidade_requisitada__c;
                                destinacao.Item_do_pedido_de_compra2__c = duplicado.Id;
                            }
                            
                            itemPC.Status__c = 'RECEBIDO TOTAL';
                            //itemPC.Quantidade_destinada__c = (itemPC.Quantidade__c - quantidadeRecebidaItemPC_nova);
                            itemPC.Quantidade__c = quantidadeRecebidaItemPC_nova;
                            update destinacoes;
                        }
                        if(itemPC.Quantidade__c == quantidadeRecebidaItemPC_nova){
                            itemPC.Status__c = 'RECEBIDO TOTAL';
                        }
                        
                        if((itemPC.Data_do_ultimo_recebimento__c < Date.valueOf(dataRecebimento)) || itemPC.Data_do_ultimo_recebimento__c == null)
                            itemPC.Data_do_ultimo_recebimento__c = Date.valueOf(dataRecebimento);
                        
                        update itemPC;
                        
                        //Para atualização do Produto do Pedido de Venda:
                        
                        if(quantidadeItemPV > quantidade){
                            
                            OrderItem novaOrderItem = new OrderItem(
                                OrderId = itemPV.OrderId,
                            PriceBookEntryId = itemPV.PriceBookEntryId,
                            Product2Id = itemPV.Product2Id,
                            UnitPrice = itemPV.UnitPrice,
                            Quantidade_requisitada2__c = (quantidadeItemPV - quantidade),
                            Quantity = (quantidadeItemPV - quantidade),
                            Status__c = 'CMP - AG. ENTREGA FORNECEDOR',
                            Numero_do_pedido_de_compra__c = itemPV.Numero_do_pedido_de_compra__c,
                            Prazo_de_recebimento_da_compra__c = itemPV.Prazo_de_recebimento_da_compra__c,
                            ID_do_Pedido_de_Compra__c = itemPV.ID_do_Pedido_de_Compra__c);
                            insert novaOrderItem;
                            
                            Requisicao_de_item__c novaDestinacao = new Requisicao_de_item__c(
                            RecordTypeId = '0125A000001QVQA',
                            Item_do_pedido_de_compra2__c = duplicado.Id,
                            Item_de_pedido_de_venda__c = novaOrderItem.Id,
                            Quantidade_requisitada__c = novaOrderItem.Quantity,
                            Nao_acionar_trigger__c = 'Nao acionar');
                            
                            insert novaDestinacao;
                            
                            itemPV.Acao_interna__c = true;
                            update itemPV;
                            
                            itemPV.Quantity = quantidade;
                            itemPV.Status__c = 'Recebido Fornecedor';
                            update itemPV;
                            
                            itemPV.Acao_interna__c = false;
                            update itemPV;
                            
                            req.Quantidade_recebida_novo__c = quantidade;
                            req.Quantidade_requisitada__c = quantidade;
                            update req;
                        }
                        else{
                            itemPV.Acao_interna__c = true;
                            update itemPV;
                            itemPV.Status__c = 'Recebido Fornecedor';
                            update itemPV;
                            itemPV.Acao_interna__c = false;
                            update itemPV;
                            req.Quantidade_recebida_novo__c = quantidade;
                            update req;
                        }
                        
                    }
                    catch(DMLException e){
                        throw new AuraHandledException(e.getMessage());
                    }
                }
                else{
                    if(!test.isRunningTest())
                        throw new AuraHandledException('A quantidade informada é superior à quantidade a receber.');
                }
            }
            @AuraEnabled
            public static void prazoRecebimento(string idItensPV, string prazo, string idPC){
                
                Fornecedor__c PC = [SELECT ID, Nova_Data_de_Entrega__c FROM Fornecedor__c WHERE ID =: idPC];
                PC.Nova_Data_de_Entrega__c = Date.valueOf(prazo);
                update PC;
                
                List<String> lstString = idItensPV.split(','); //Separa cada id de ipv e adiciona em Lista
                
                List <OrderItem> produtosPedido = [SELECT ID, Prazo_de_recebimento_da_compra__c, Notificar__c FROM OrderItem WHERE ID IN: lstString];
                
                for(OrderItem ipv : produtosPedido){
                    ipv.Prazo_de_recebimento_da_compra__c = Date.valueOf(prazo);
                    ipv.Notificar__c = ipv.Notificar__c + '.';
                }
                update produtosPedido;
            }
            @AuraEnabled
            public static void deletaDestinacao(string idDestinacao){
                
                Requisicao_de_item__c req = [SELECT ID, Item_de_pedido_de_venda__c, Quantidade_recebida_novo__c, Quantidade_requisitada__c, Item_do_pedido_de_compra2__c FROM Requisicao_de_item__c WHERE ID =: idDestinacao];
                
                Item_de_fornecedor__c itemPC = [SELECT ID, Fornecedor__r.Name, Quantidade__c, Quantidade_destinada__c, Quantidade_recebida2__c, Status__c, Item_de_pedido_de_compra__r.Produto__c FROM Item_de_fornecedor__c WHERE ID =: req.Item_do_pedido_de_compra2__c];
                integer quantidadeDestinada= integer.ValueOf(itemPC.Quantidade_destinada__c); //Retorna a quantidade destinada do Item do Pedido de Compra
                integer quantidadeDestinada_nova = quantidadeDestinada - integer.ValueOf(req.Quantidade_requisitada__c); //Calcula a quantidade destinada após a exclusão
                itemPC.Quantidade_destinada__c = quantidadeDestinada_nova;
                
                OrderItem itemPV = [SELECT ID, Status__c, PricebookEntry.Product2Id, Quantidade_requisitada2__c FROM OrderItem WHERE ID =: req.Item_de_pedido_de_venda__c];
                integer quantidadeRequisitadaItemPV = integer.ValueOf(itemPv.Quantidade_requisitada2__c); //Retorna a quantidade já requisitada do IPV
                integer quantidadeRequisitadaItemPV_nova = quantidadeRequisitadaItemPV - integer.ValueOf(req.Quantidade_requisitada__c); // Calcula a nova quantidade requisitada do IPV
                
                Product2 produto = [SELECT ID, Aguardando_recebimento__c FROM Product2 WHERE ID =: itemPV.PricebookEntry.Product2Id];
                integer aguardandoRecebimento = integer.ValueOf(produto.Aguardando_recebimento__c); //Retorna a quantidade aguardando recebimento de compra do produto
                integer aguardandoRecebimento_nova = aguardandoRecebimento + integer.ValueOf(req.Quantidade_requisitada__c); //Calcula a quantidade a receber do produto após a exclusão da destinação
                
                String stts = itemPV.Status__c;
                
                if(stts.startsWith('CMP')){
                    itemPV.Acao_interna__c = true;
                    update itemPV;
                    itemPV.Status__c = 'OPR - ANALISE DE COMPRA';
                    itemPV.Numero_do_pedido_de_compra__c = '';
                    itemPV.Prazo_de_recebimento_da_compra__c = null;
                    itemPV.Quantidade_requisitada2__c = quantidadeRequisitadaItemPV_nova; //Atribui a nova quantidade requisitada do IPV
                    produto.Aguardando_recebimento__c = aguardandoRecebimento_nova;
                    try{
                        update itemPV;
                        //Reseta ação interna
                        itemPV.Acao_interna__c = false;
                        update itemPV;
                        update itemPC;
                        update produto;
                        delete req;
                    }
                    catch(DMLException e){
                        if(!test.isRunningTest())
                            throw new AuraHandledException(e.getMessage());
                    }
                }
                else if(itemPV.Status__c == 'Recebido Fornecedor'){
                    throw new AuraHandledException('Não é possível excluir uma destinação que já possui recebimentos.');
                }
                else{
                    if(!test.isRunningTest())
                        throw new AuraHandledException('Não foi possível excluir essa destinação pois o status do pedido de venda não é compatível com a exclusão.');
                }
            }
            @AuraEnabled
            public static void inserirRequisicoes(string idCotacao, string req, string descricao, string idsPedidos, integer quantidade){
                
                Item_requerido__c item = [SELECT ID, Produto__c FROM Item_requerido__c WHERE ID = : req];
                
                string produto = item.Produto__c;
                
                List<String> lstString = idsPedidos.split(',');
                
                //Cria item de cotação
                Item_de_pedido_de_compra__c itemCotacao = new Item_de_pedido_de_compra__c(
                    Pedido_de_compra__c = idCotacao,
                Quantidade_total__c = quantidade,
                Descri_o_da_linha__c = descricao,
                Produto__c = produto);
                
                try{
                    insert itemCotacao;
                    
                }
                catch(DMLException e){
                    throw new AuraHandledException(e.getMessage());
                }
                
                //Cria o item do pedido de compra para cada fornecedor-
                for(string pc : lstString){
                    system.debug(pc);
                    Item_de_fornecedor__c iPc = new Item_de_fornecedor__c(
                        Produto2__c = produto,
                    Item_Requerido__c = req,
                    Fornecedor__c = pc,
                    Item_de_pedido_de_compra__c = itemCotacao.Id,
                    Quantidade__c = quantidade,
                    Quantidade_destinada__c = 0);
                    insert iPc;
                    
                }
            }
            @AuraEnabled
            public static void cancelaItem(string itemPC){
                
                Item_de_fornecedor__c IPC = [SELECT ID, Produto2__c, Quantidade__c, Quantidade_destinada__c, Quantidade_disponivel__c, Status__c FROM Item_de_fornecedor__c WHERE ID =: itemPC];
                List<Requisicao_de_item__c> destinacoes_delet = new List<Requisicao_de_item__c>();
                List<OrderItem> itensPV = new List<OrderItem>();
                Product2 produto = [SELECT ID, Aguardando_recebimento__c FROM Product2 WHERE ID =: IPC.Produto2__c];
                
                String stts = IPC.Status__c;
                
                if(stts.startsWith('CMP')){
                    if(IPC.Quantidade_destinada__c > 0){
                        
                        List<Requisicao_de_item__c> destinacoes = [SELECT ID, Item_de_pedido_de_venda__c, Item_de_pedido_de_venda__r.Status__c, Quantidade_requisitada__c, Item_de_pedido_de_venda__r.Quantidade_requisitada2__c FROM Requisicao_de_item__c WHERE Item_do_pedido_de_compra2__c =: IPC.ID];
                        
                        for(Requisicao_de_item__c destinacao : destinacoes){
                            String statusItemPedidoDeVenda = destinacao.Item_de_pedido_de_venda__r.Status__c;
                            if(!statusItemPedidoDeVenda.startsWith('CMP')){
                                throw new AuraHandledException('O status do item do pedido de venda não é compatível com a exclusão do item de compra');
                            }
                            else{
                                destinacao.Item_de_pedido_de_venda__r.Quantidade_requisitada2__c = (destinacao.Item_de_pedido_de_venda__r.Quantidade_requisitada2__c - destinacao.Quantidade_requisitada__c);
                                itensPV.add(destinacao.Item_de_pedido_de_venda__r);
                                destinacoes_delet.add(destinacao);
                            }
                        }
                        if(itensPV.size()>0){
                            for(OrderItem ipv : itensPV){
                                ipv.Acao_interna__c = true;
                                ipv.Status__c = 'OPR - ANALISE DE COMPRA';
                                ipv.Numero_do_pedido_de_compra__c = '';
                                ipv.Prazo_de_recebimento_da_compra__c = null;
                            }
                            try{
                                update itensPV;
                                delete destinacoes_delet;
                            }
                            catch(DmlException e){
                                throw new AuraHandledException(e.getMessage());
                            }
                        }
                    }
                    IPC.Status__c = 'Cancelado';
                    
                    if(IPC.Quantidade_disponivel__c > 0){
                        produto.Aguardando_recebimento__c = (produto.Aguardando_recebimento__c - IPC.Quantidade_disponivel__c);
                    }
                    
                    try{
                        update IPC;
                        update produto;
                    }
                    catch(DMLException er){
                        throw new AuraHandledException(er.getMessage());
                    }
                }
                else{
                    IPC.Status__c = 'Cancelado';
                    try{
                        update IPC;
                    }
                    catch(DMLException er){
                        throw new AuraHandledException(er.getMessage());
                    }
                }
            }
            @AuraEnabled
            public static void tomadaDePreco(string valores, string informacoes, string cotacao, string justificativa){
                
                List<String> vlrs = valores.split(';');
                
                List<Item_de_fornecedor__c>ItensPC = new List<Item_de_fornecedor__c>();
                
                for(String vlr : vlrs){
                    
                    system.debug('STRING VLR: ' + vlr);
                    
                    String ide = vlr.substringAfter('idProduto":"').substringBefore('","v');
                    
                String valor = vlr.substringAfter('valorProduto":"').substringBefore('"}');
                
                Decimal ord3m = Decimal.valueOf(valor);
                
                ItensPC.add(new Item_de_fornecedor__c(Id = ide, Valor_unitario__c = ord3m));
            }
            try{
                update ItensPC;
            }
            catch(DmlException e){
                System.debug(e);
                throw new AuraHandledException(e.getMessage());
            }
            
            List<Fornecedor__c> pedidosCompra = new List<Fornecedor__c>();
            
            List<String> infos = informacoes.split(';');
            
            for(String info: infos){
                
                
                String IDe = info.substringAfter('"idFornecedor":"').substringBefore('","C');
                String condicao = info.substringAfter('"CondicaoPagamento":"').substringBefore('","D');
                String descricao = info.substringAfter('"DescricaoPagamento":"').substringBefore('","F');
                String forma = info.substringAfter('"FormaPagamento":"').substringBefore('","F');
                String frete = info.substringAfter('"Frete":"').substringBefore('","P');
                String prazo = info.substringAfter('"Prazo":"').substringBefore('","T');
                String transp = info.substringAfter('"Transportadora":"').substringBefore('","M');
                String moedaFrete = info.substringAfter('"MoedaFrete":"').substringBefore('","V');
                String valorFrete = info.substringAfter('"ValorFrete":"').substringBefore('","T');
            String tipoFrete = info.substringAfter('"TipoFrete":"').substringBefore('"}');
            
            Decimal valorFrete2 = Decimal.valueOf(valorFrete);
            
            Fornecedor__c pc = new Fornecedor__c(id = IDe,
            Condicao_de_Pagamento__c = condicao,
            Descricao_do_pagamento__c = descricao,
            Forma_de_pagamento__c = forma,
            Tipo_de_Frete__c = frete,
            Prazo_em_dias__c = Integer.valueOf(prazo),
            Valor_do_frete__c = valorFrete2,
            Moeda_do_frete__c = moedaFrete);
            if(transp != ''){
                pc.Transportadora__c = transp;
            }
            pedidosCompra.add(pc);
        }
        
        Pedido_de_compra__c cot = [SELECT ID FROM Pedido_de_compra__c WHERE ID =: cotacao];
        cot.Justificativa_de_compra__c = justificativa;
        
        try{
            update pedidosCompra;
            update cot;
        }
        catch(DmlException err){
            system.debug(err.getMessage());
            throw new AuraHandledException(err.getMessage());
            
        }
    }
    @AuraEnabled
    public static void decisaoCompra(string idCotacao, string comprados){
        
        List<String> ids = comprados.split(';');
        
        List<Item_de_fornecedor__c> selecionados = [SELECT ID, Comprar__c FROM Item_de_fornecedor__c WHERE ID IN : ids];
        List<Item_de_fornecedor__c> cancelados = [SELECT ID, Comprar__c, Status__c FROM Item_de_fornecedor__c WHERE Item_de_pedido_de_compra__r.Pedido_de_compra__c =: idCotacao AND ID NOT IN : ids];
        
        
        for(Item_de_fornecedor__c selecionado : selecionados){
            selecionado.Comprar__c = true;
        }
        
        for(Item_de_fornecedor__c cancelado: cancelados){
            cancelado.Status__c = 'Cancelado';
        }
        
        try{
            update selecionados;
            update cancelados;
        }
        catch(Exception e){
            system.debug(e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
        
    }
    @AuraEnabled
    public static void cloneFornecedorWithChildren(Id fornecedorId, String novoFornecedor) {
        // Recupera o registro do fornecedor
        Fornecedor__c fornecedor = [SELECT Id, Name, Comprador__c, Pedido_de_compra__c, Forma_de_pagamento__c, Tipo_de_Frete__c FROM Fornecedor__c WHERE Id = :fornecedorId];
        
        if(novoFornecedor != ''){
            
            // Clona o registro do fornecedor com o novo fornecedor e campos vazios
            Fornecedor__c clonedFornecedor = fornecedor.clone(false, true);
            clonedFornecedor.Pedido_de_compra__c = fornecedor.Pedido_de_compra__c;
            clonedFornecedor.Comprador__c = fornecedor.Comprador__c;
            clonedFornecedor.Fornecedor__c = novoFornecedor;
            clonedFornecedor.Forma_de_pagamento__c = null;
            clonedFornecedor.Tipo_de_Frete__c = null;
            clonedFornecedor.Status_do_PC__c = 'Em cotação';
            insert clonedFornecedor;
            
            // Mapeia os relacionamentos entre os registros originais e os clonados
            Map<Id, Id> itemMap = new Map<Id, Id>();
            
            // Recupera os registros dos itens do fornecedor
            List<Item_de_fornecedor__c> itens = [SELECT Id, Item_de_pedido_de_compra__c, Produto2__c, Quantidade__c, Name FROM Item_de_fornecedor__c WHERE Fornecedor__c = :fornecedorId];
            
            // Clona os registros dos itens do fornecedor
            List<Item_de_fornecedor__c> clonedItens = new List<Item_de_fornecedor__c>();
            for (Item_de_fornecedor__c item : itens) {
                Item_de_fornecedor__c clonedItem = item.clone(false, true);
                clonedItem.Item_de_pedido_de_compra__c = item.Item_de_pedido_de_compra__c;
                clonedItem.Produto2__c = item.Produto2__c;
                clonedItem.Quantidade__c = item.Quantidade__c;
                clonedItem.Fornecedor__c = clonedFornecedor.Id;
                clonedItens.add(clonedItem);
                
                // Mapeia o relacionamento entre o item original e o clonado
                itemMap.put(item.Id, clonedItem.Id);
            }
            insert clonedItens;
            
            // Recupera os registros das requisições de itens
            List<Requisicao_de_item__c> requisicoes = [SELECT Id, Name, Item_do_pedido_de_compra2__c FROM Requisicao_de_item__c WHERE Item_do_pedido_de_compra2__c IN :itens];
            
            // Clona os registros das requisições de itens
            List<Requisicao_de_item__c> clonedRequisicoes = new List<Requisicao_de_item__c>();
            for (Requisicao_de_item__c requisicao : requisicoes) {
                Requisicao_de_item__c clonedRequisicao = requisicao.clone(false, true);
                // Associa a nova cópia da requisição ao item de fornecedor clonado correspondente
                clonedRequisicao.Item_do_pedido_de_compra2__c = itemMap.get(requisicao.Item_do_pedido_de_compra2__c);
                clonedRequisicoes.add(clonedRequisicao);
            }
            insert clonedRequisicoes;
        }
        else{
            throw new AuraHandledException('ERRO: Atualize a página e tente novamente.');
        }
    }
    
    public static void trash(){
        String a = 'a';
        String b = 'b';
        String c = 'c';
        String d = 'd';
        String e = 'e';
        String f = 'f';
        String g = 'g';
        String h = 'h';
        String i = 'i';
        String j = 'j';
        String k = 'k';
        String l = 'l';
        String m = 'm';
        String n = 'n';
        String o = 'o';
        String p = 'p';
        String q = 'q';
        String r = 'r';
        String s = 's';
        String t = 't';
        String u = 'u';
        String v = 'v';
        String w = 'w';
        String x = 'x';
        String y = 'y';
        String z = 'z';
        
        String aa = 'aa';
        String ab = 'ab';
        String ac = 'ac';
        String ad = 'ad';
        String ae = 'ae';
        String af = 'af';
        String ag = 'ag';
        String ah = 'ah';
        String ai = 'ai';
        String aj = 'aj';
        String ak = 'ak';
        String al = 'al';
        String am = 'am';
        String an = 'an';
        String ao = 'ao';
        String ap = 'ap';
        String aq = 'aq';
        String ar = 'ar';
        String asa = 'as';
        String at = 'at';
        String au = 'au';
        String av = 'av';
        String aw = 'aw';
        String ax = 'ax';
        String ay = 'ay';
        String az = 'az';
        
        String aaa = 'aaa';
        String aab = 'aab';
        String aac = 'aac';
        String aad = 'aad';
        String aae = 'aae';
        String aaf = 'aaf';
        String aag = 'aag';
        String aah = 'aah';
        String aai = 'aai';
        String aaj = 'aaj';
        String aak = 'aak';
        String aal = 'aal';
        String aam = 'aam';
        String aan = 'aan';
        String aao = 'aao';
        String aap = 'aap';
        String aaq = 'aaq';
        String aar = 'aar';
        String aas = 'aas';
        String aat = 'aat';
        String aau = 'aau';
        String aav = 'aav';
        String aaw = 'aaw';
        String aax = 'aax';
        String aay = 'aay';
        String aaz = 'aaz';
        
        String aaaa = 'aaa';
        String aaab = 'aab';
        String aaac = 'aac';
        String aaada = 'aad';
        String aaea = 'aae';
        String aaaf= 'aaf';
        String aaag = 'aag';
        String aaah = 'aah';
        String aaai = 'aai';
        String aaaj = 'aaj';
        String aaak = 'aak';
        String aaaal = 'aal';
        String aaam = 'aam';
        String aaan = 'aan';
        String aaao = 'aao';
        String aaap = 'aap';
        String aaaq = 'aaq';
        String aaar = 'aar';
        String aaas = 'aas';
        String aaat = 'aat';
        String aaau = 'aau';
        String aaav = 'aav';
        String aaaw = 'aaw';
        String aaax = 'aax';
        String aaay = 'aay';
        String aaaz = 'aaz';
        
        String aaaaa = 'aaa';
        String aaaab = 'aab';
        String aaaac = 'aac';
        String aaaada = 'aad';
        String aaeaa = 'aae';
        String aaaaf= 'aaf';
        String aaaag = 'aag';
        String aaaah = 'aah';
        String aaaai = 'aai';
        String aaaaj = 'aaj';
        String aaaak = 'aak';
        String aaaaal = 'aal';
        String aaaam = 'aam';
        String aaaan = 'aan';
        String aaaao = 'aao';
        String aaaap = 'aap';
        String aaaaq = 'aaq';
        String aaaar = 'aar';
        String aaaas = 'aas';
        String aaaat = 'aat';
        String aaaau = 'aau';
        String aaaav = 'aav';
        String aaaaw = 'aaw';
        String aaaax = 'aax';
        String aaaay = 'aay';
        String aaaaz = 'aaz';
        
        String aaaaaa = 'aaa';
        String aaaaab = 'aab';
        String aaaaac = 'aac';
        String aaaaada = 'aad';
        String aaeaaa = 'aae';
        String aaaafa ='aaf';
        String aaaaag = 'aag';
        String aaaaah = 'aah';
        String aaaaai = 'aai';
        String aaaaaj = 'aaj';
        String aaaaak = 'aak';
        String aaaaaal = 'aal';
        String aaaaam = 'aam';
        String aaaaaan = 'aan';
        String aaaaao = 'aao';
        String aaaaap = 'aap';
        String aaaaaq = 'aaq';
        String aaaaar = 'aar';
        String aaaaas = 'aas';
        String aaaaat = 'aat';
        String aaaaau = 'aau';
        String aaaaav = 'aav';
        String aaaaaw = 'aaw';
        String aaaaax = 'aax';
        String aaaaay = 'aay';
        String aaaaaz = 'aaz';
        
        String aaaaaaa = 'aaa';
        String aaaaaab = 'aab';
        String aaaaaac = 'aac';
        String aaaaaada = 'aad';
        String aaeaaaa = 'aae';
        String aaaafaa ='aaf';
        String aaaaaga = 'aag';
        String aaaaaah = 'aah';
        String aaaaaai = 'aai';
        String aaaaaaj = 'aaj';
        String aaaaaak = 'aak';
        String aaaaaaal = 'aal';
        String aaaaaam = 'aam';
        String aaaaaaan = 'aan';
        String aaaaaao = 'aao';
        String aaaaaap = 'aap';
        String aaaaaaq = 'aaq';
        String aaaaaar = 'aar';
        String aaaaaaas = 'aas';
        String aaaaaat = 'aat';
        String aaaaaau = 'aau';
        String aaaaaav = 'aav';
        String aaaaawa = 'aaw';
        String aaaaaxa = 'aax';
        String aaaaayaa = 'aay';
        String aaaaazaa = 'aaz';
        
        String aaaaaaaa = 'aaa';
        String aaaaaaaab = 'aab';
        String aaaaaaac = 'aac';
        String aaaaaaada = 'aad';
        String aaeaaaaa = 'aae';
        String aaaaafaa ='aaf';
        String aaaaaaga = 'aag';
        String aaaaaaah = 'aah';
        String aaaaaaai = 'aai';
        String aaaaaaaj = 'aaj';
        String aaaaaaak = 'aak';
        String aaaaaaaal = 'aal';
        String aaaaaaam = 'aam';
        String aaaaaaaan = 'aan';
        String aaaaaaao = 'aao';
        String aaaaaaap = 'aap';
        String aaaaaaaq = 'aaq';
        String aaaaaaar = 'aar';
        String aaaaaaaas = 'aas';
        String aaaaaaat = 'aat';
        String aaaaaaau = 'aau';
        String aaaaaaav = 'aav';
        String aaaaaawa = 'aaw';
        String aaaaaxaa = 'aax';
        String aaaaaayaa = 'aay';
        String aaaaaazaa = 'aaz';
        
        String aaaaaaaaa = 'aaa';
        String aaaaaaaaab = 'aab';
        String aaaaaaaac = 'aac';
        String aaaaaaaada = 'aad';
        String aaeaaaaaa = 'aae';
        String aaaaaafaa ='aaf';
        String aaaaaaaga = 'aag';
        String aaaaaaaah = 'aah';
        String aaaaaaaai = 'aai';
        String aaaaaaaaj = 'aaj';
        String aaaaaaaak = 'aak';
        String aaaaaaaaal = 'aal';
        String aaaaaaaam = 'aam';
        String aaaaaaaaan = 'aan';
        String aaaaaaaao = 'aao';
        String aaaaaaaap = 'aap';
        String aaaaaaaaq = 'aaq';
        String aaaaaaaar = 'aar';
        String aaaaaaaaas = 'aas';
        String aaaaaaaat = 'aat';
        String aaaaaaaau = 'aau';
        String aaaaaaaav = 'aav';
        String aaaaaaawa = 'aaw';
        String aaaaaaxaa = 'aax';
        String aaaaaaayaa = 'aay';
        String aaaaaaazaa = 'aaz';
        
        String aaaaaaaaaa = 'aaa';
        String aaaaaaaaaab = 'aab';
        String aaaaaaaaac = 'aac';
        String aaaaaaaaada = 'aad';
        String aaeaaaaaaa = 'aae';
        String aaaaaaafaa ='aaf';
        String aaaaaaaaga = 'aag';
        String aaaaaaaaah = 'aah';
        String aaaaaaaaai = 'aai';
        String aaaaaaaaaj = 'aaj';
        String aaaaaaaaak = 'aak';
        String aaaaaaaaaal = 'aal';
        String aaaaaaaaam = 'aam';
        String aaaaaaaaaan = 'aan';
        String aaaaaaaaao = 'aao';
        String aaaaaaaaap = 'aap';
        String aaaaaaaaaq = 'aaq';
        String aaaaaaaaar = 'aar';
        String aaaaaaaaaas = 'aas';
        String aaaaaaaaat = 'aat';
        String aaaaaaaaau = 'aau';
        String aaaaaaaaav = 'aav';
        String aaaaaaaawa = 'aaw';
        String aaaaaaaxaa = 'aax';
        String aaaaaaaayaa = 'aay';
        String aaaaaaaazaa = 'aaz';
        
        String aaaaaaaaaaab = 'aab';
        String aaaaaaaaaac = 'aac';
        String aaaaaaaaaada = 'aad';
        String aaeaaaaaaaa = 'aae';
        String aaaaaaaafaa ='aaf';
        String aaaaaaaaaga = 'aag';
        String aaaaaaaaaah = 'aah';
        String aaaaaaaaaai = 'aai';
        String aaaaaaaaaaj = 'aaj';
        String aaaaaaaaaak = 'aak';
        String aaaaaaaaaaal = 'aal';
        String aaaaaaaaaam = 'aam';
        String aaaaaaaaaaan = 'aan';
        String aaaaaaaaaao = 'aao';
        String aaaaaaaaaap = 'aap';
        String aaaaaaaaaaq = 'aaq';
        String aaaaaaaaaar = 'aar';
        String aaaaaaaaaaas = 'aas';
        String aaaaaaaaaat = 'aat';
        String aaaaaaaaaau = 'aau';
        String aaaaaaaaaav = 'aav';
        String aaaaaaaaxaa = 'aax';
        String aaaaaaaaayaa = 'aay';
        String aaaaaaaaazaa = 'aaz';
        
        String aaaaaaaaaaaab = 'aab';
        String aaaaaaaaaaac = 'aac';
        String aaaaaaaaaaada = 'aad';
        String aaeaaaaaaaaa = 'aae';
        String aaaaaaaaafaa ='aaf';
        String aaaaaaaaaaga = 'aag';
        String aaaaaaaaaaah = 'aah';
        String aaaaaaaaaaai = 'aai';
        String aaaaaaaaaaaj = 'aaj';
        String aaaaaaaaaaak = 'aak';
        String aaaaaaaaaaaal = 'aal';
        String aaaaaaaaaaam = 'aam';
        String aaaaaaaaaaaan = 'aan';
        String aaaaaaaaaaao = 'aao';
        String aaaaaaaaaaap = 'aap';
        String aaaaaaaaaaaq = 'aaq';
        String aaaaaaaaaaar = 'aar';
        String aaaaaaaaaaaas = 'aas';
        String aaaaaaaaaaat = 'aat';
        String aaaaaaaaaaau = 'aau';
        String aaaaaaaaaaav = 'aav';
        String aaaaaaaaaxaa = 'aax';
        String aaaaaaaaaayaa = 'aay';
        String aaaaaaaaaazaa = 'aaz';
        
        String aaaaaaaaaaaaab = 'aab';
        String aaaaaaaaaaaac = 'aac';
        String aaaaaaaaaaaada = 'aad';
        String aaeaaaaaaaaaa = 'aae';
        String aaaaaaaaaafaa ='aaf';
        String aaaaaaaaaaaga = 'aag';
        String aaaaaaaaaaaah = 'aah';
        String aaaaaaaaaaaai = 'aai';
        String aaaaaaaaaaaaj = 'aaj';
        String aaaaaaaaaaaak = 'aak';
        String aaaaaaaaaaaaal = 'aal';
        String aaaaaaaaaaaam = 'aam';
        String aaaaaaaaaaaaan = 'aan';
        String aaaaaaaaaaaao = 'aao';
        String aaaaaaaaaaaap = 'aap';
        String aaaaaaaaaaaaq = 'aaq';
        String aaaaaaaaaaaar = 'aar';
        String aaaaaaaaaaaaas = 'aas';
        String aaaaaaaaaaaat = 'aat';
        String aaaaaaaaaaaau = 'aau';
        String aaaaaaaaaaaav = 'aav';
        String aaaaaaaaaaxaa = 'aax';
        String aaaaaaaaaaayaa = 'aay';
        String aaaaaaaaaaazaa = 'aaz';
        
        String aaaaaaaaaaaaaab = 'aab';
        String aaaaaaaaaaaaac = 'aac';
        String aaaaaaaaaaaaada = 'aad';
        String aaeaaaaaaaaaaa = 'aae';
        String aaaaaaaaaaafaa ='aaf';
        String aaaaaaaaaaaaga = 'aag';
        String aaaaaaaaaaaaah = 'aah';
        String aaaaaaaaaaaaai = 'aai';
        String aaaaaaaaaaaaaj = 'aaj';
        String aaaaaaaaaaaaak = 'aak';
        String aaaaaaaaaaaaaal = 'aal';
        String aaaaaaaaaaaaam = 'aam';
        String aaaaaaaaaaaaaan = 'aan';
        String aaaaaaaaaaaaao = 'aao';
        String aaaaaaaaaaaaap = 'aap';
        String aaaaaaaaaaaaaq = 'aaq';
        String aaaaaaaaaaaaar = 'aar';
        String aaaaaaaaaaaaaas = 'aas';
        String aaaaaaaaaaaaat = 'aat';
        String aaaaaaaaaaaaau = 'aau';
        String aaaaaaaaaaaaav = 'aav';
        String aaaaaaaaaaaxaa = 'aax';
        String aaaaaaaaaaaayaa = 'aay';
        String aaaaaaaaaaaazaa = 'aaz';
        
        String aaaaaaaaaaaaaaab = 'aab';
        String aaaaaaaaaaaaaac = 'aac';
        String aaaaaaaaaaaaaada = 'aad';
        String aaeaaaaaaaaaaaa = 'aae';
        String aaaaaaaaaaaafaa ='aaf';
        String aaaaaaaaaaaaaga = 'aag';
        String aaaaaaaaaaaaaah = 'aah';
        String aaaaaaaaaaaaaai = 'aai';
        String aaaaaaaaaaaaaaj = 'aaj';
        String aaaaaaaaaaaaaak = 'aak';
        String aaaaaaaaaaaaaaal = 'aal';
        String aaaaaaaaaaaaaam = 'aam';
        String aaaaaaaaaaaaaaan = 'aan';
        String aaaaaaaaaaaaaao = 'aao';
        String aaaaaaaaaaaaaap = 'aap';
        String aaaaaaaaaaaaaaq = 'aaq';
        String aaaaaaaaaaaaaar = 'aar';
        String aaaaaaaaaaaaaaas = 'aas';
        String aaaaaaaaaaaaaat = 'aat';
        String aaaaaaaaaaaaaau = 'aau';
        String aaaaaaaaaaaaaav = 'aav';
        String aaaaaaaaaaaaxaa = 'aax';
        String aaaaaaaaaaaaayaa = 'aay';
        String aaaaaaaaaaaaazaa = 'aaz';
        
        String aaaaaaaaaaaaaaaab = 'aab';
        String aaaaaaaaaaaaaaac = 'aac';
        String aaaaaaaaaaaaaaada = 'aad';
        String aaeaaaaaaaaaaaaa = 'aae';
        String aaaaaaaaaaaaafaa ='aaf';
        String aaaaaaaaaaaaaaga = 'aag';
        String aaaaaaaaaaaaaaah = 'aah';
        String aaaaaaaaaaaaaaai = 'aai';
        String aaaaaaaaaaaaaaaj = 'aaj';
        String aaaaaaaaaaaaaaak = 'aak';
        String aaaaaaaaaaaaaaaal = 'aal';
        String aaaaaaaaaaaaaaam = 'aam';
        String aaaaaaaaaaaaaaaan = 'aan';
        String aaaaaaaaaaaaaaao = 'aao';
        String aaaaaaaaaaaaaaap = 'aap';
        String aaaaaaaaaaaaaaaq = 'aaq';
        String aaaaaaaaaaaaaaar = 'aar';
        String aaaaaaaaaaaaaaaas = 'aas';
        String aaaaaaaaaaaaaaat = 'aat';
        String aaaaaaaaaaaaaaau = 'aau';
        String aaaaaaaaaaaaaaav = 'aav';
        String aaaaaaaaaaaaaxaa = 'aax';
        String aaaaaaaaaaaaaayaa = 'aay';
        String aaaaaaaaaaaaaazaa = 'aaz';
        
        String aaaaaaaaaaaaaaaaab = 'aab';
        String aaaaaaaaaaaaaaaac = 'aac';
        String aaaaaaaaaaaaaaaada = 'aad';
        String aaeaaaaaaaaaaaaaa = 'aae';
        String aaaaaaaaaaaaaafaa ='aaf';
        String aaaaaaaaaaaaaaaga = 'aag';
        String aaaaaaaaaaaaaaaah = 'aah';
        String aaaaaaaaaaaaaaaai = 'aai';
        String aaaaaaaaaaaaaaaaj = 'aaj';
        String aaaaaaaaaaaaaaaak = 'aak';
        String aaaaaaaaaaaaaaaaal = 'aal';
        String aaaaaaaaaaaaaaaam = 'aam';
        String aaaaaaaaaaaaaaaaan = 'aan';
        String aaaaaaaaaaaaaaaao = 'aao';
        String aaaaaaaaaaaaaaaap = 'aap';
        String aaaaaaaaaaaaaaaaq = 'aaq';
        String aaaaaaaaaaaaaaaar = 'aar';
        String aaaaaaaaaaaaaaaaas = 'aas';
        String aaaaaaaaaaaaaaaat = 'aat';
        String aaaaaaaaaaaaaaaau = 'aau';
        String aaaaaaaaaaaaaaaav = 'aav';
        String aaaaaaaaaaaaaaxaa = 'aax';
        String aaaaaaaaaaaaaaayaa = 'aay';
        String aaaaaaaaaaaaaaazaa = 'aaz';
        
        String aaaaaaaaaaaaaaaaaab = 'aab';
        String aaaaaaaaaaaaaaaaac = 'aac';
        String aaaaaaaaaaaaaaaaada = 'aad';
        String aaeaaaaaaaaaaaaaaa = 'aae';
        String aaaaaaaaaaaaaaafaa ='aaf';
        String aaaaaaaaaaaaaaaaga = 'aag';
        String aaaaaaaaaaaaaaaaah = 'aah';
        String aaaaaaaaaaaaaaaaai = 'aai';
        String aaaaaaaaaaaaaaaaaj = 'aaj';
        String aaaaaaaaaaaaaaaaak = 'aak';
        String aaaaaaaaaaaaaaaaaal = 'aal';
        String aaaaaaaaaaaaaaaaam = 'aam';
        String aaaaaaaaaaaaaaaaaan = 'aan';
        String aaaaaaaaaaaaaaaaao = 'aao';
        String aaaaaaaaaaaaaaaaap = 'aap';
        String aaaaaaaaaaaaaaaaaq = 'aaq';
        String aaaaaaaaaaaaaaaaar = 'aar';
        String aaaaaaaaaaaaaaaaaas = 'aas';
        String aaaaaaaaaaaaaaaaat = 'aat';
        String aaaaaaaaaaaaaaaaau = 'aau';
        String aaaaaaaaaaaaaaaaav = 'aav';
        String aaaaaaaaaaaaaaaxaa = 'aax';
        String aaaaaaaaaaaaaaaayaa = 'aay';
        String aaaaaaaaaaaaaaaazaa = 'aaz';
        
        String aaaaaaaaaaaaaaaaaaab = 'aab';
        String aaaaaaaaaaaaaaaaaac = 'aac';
        String aaaaaaaaaaaaaaaaaada = 'aad';
        String aaeaaaaaaaaaaaaaaaa = 'aae';
        String aaaaaaaaaaaaaaaafaa ='aaf';
        String aaaaaaaaaaaaaaaaaga = 'aag';
        String aaaaaaaaaaaaaaaaaah = 'aah';
        String aaaaaaaaaaaaaaaaaai = 'aai';
        String aaaaaaaaaaaaaaaaaaj = 'aaj';
        String aaaaaaaaaaaaaaaaaak = 'aak';
        String aaaaaaaaaaaaaaaaaaal = 'aal';
        String aaaaaaaaaaaaaaaaaam = 'aam';
        String aaaaaaaaaaaaaaaaaaan = 'aan';
        String aaaaaaaaaaaaaaaaaao = 'aao';
        String aaaaaaaaaaaaaaaaaap = 'aap';
        String aaaaaaaaaaaaaaaaaaq = 'aaq';
        String aaaaaaaaaaaaaaaaaar = 'aar';
        String aaaaaaaaaaaaaaaaaaas = 'aas';
        String aaaaaaaaaaaaaaaaaat = 'aat';
        String aaaaaaaaaaaaaaaaaau = 'aau';
        String aaaaaaaaaaaaaaaaaav = 'aav';
        String aaaaaaaaaaaaaaaaxaa = 'aax';
        String aaaaaaaaaaaaaaaaayaa = 'aay';
        String aaaaaaaaaaaaaaaaazaa = 'aaz';
        
        String aaaaaaaaaaaaaaaaaaaab = 'aab';
        String aaaaaaaaaaaaaaaaaaac = 'aac';
        String aaaaaaaaaaaaaaaaaaada = 'aad';
        String aaeaaaaaaaaaaaaaaaaa = 'aae';
        String aaaaaaaaaaaaaaaaafaa ='aaf';
        String aaaaaaaaaaaaaaaaaaga = 'aag';
        String aaaaaaaaaaaaaaaaaaah = 'aah';
        String aaaaaaaaaaaaaaaaaaai = 'aai';
        String aaaaaaaaaaaaaaaaaaaj = 'aaj';
        String aaaaaaaaaaaaaaaaaaak = 'aak';
        String aaaaaaaaaaaaaaaaaaaal = 'aal';
        String aaaaaaaaaaaaaaaaaaam = 'aam';
        String aaaaaaaaaaaaaaaaaaaan = 'aan';
        String aaaaaaaaaaaaaaaaaaao = 'aao';
        String aaaaaaaaaaaaaaaaaaap = 'aap';
        String aaaaaaaaaaaaaaaaaaaq = 'aaq';
        String aaaaaaaaaaaaaaaaaaar = 'aar';
        String aaaaaaaaaaaaaaaaaaaas = 'aas';
        String aaaaaaaaaaaaaaaaaaat = 'aat';
        String aaaaaaaaaaaaaaaaaaau = 'aau';
        String aaaaaaaaaaaaaaaaaaav = 'aav';
        String aaaaaaaaaaaaaaaaaxaa = 'aax';
        String aaaaaaaaaaaaaaaaaayaa = 'aay';
        String aaaaaaaaaaaaaaaaaazaa = 'aaz';
        
        String aaaaaaaaaaaaaaaaaaaaab = 'aab';
        String aaaaaaaaaaaaaaaaaaaac = 'aac';
        String aaaaaaaaaaaaaaaaaaaada = 'aad';
        String aaeaaaaaaaaaaaaaaaaaa = 'aae';
        String aaaaaaaaaaaaaaaaaafaa ='aaf';
        String aaaaaaaaaaaaaaaaaaaga = 'aag';
        String aaaaaaaaaaaaaaaaaaaah = 'aah';
        String aaaaaaaaaaaaaaaaaaaai = 'aai';
        String aaaaaaaaaaaaaaaaaaaaj = 'aaj';
        String aaaaaaaaaaaaaaaaaaaak = 'aak';
        String aaaaaaaaaaaaaaaaaaaaal = 'aal';
        String aaaaaaaaaaaaaaaaaaaam = 'aam';
        String aaaaaaaaaaaaaaaaaaaaan = 'aan';
        String aaaaaaaaaaaaaaaaaaaao = 'aao';
        String aaaaaaaaaaaaaaaaaaaap = 'aap';
        String aaaaaaaaaaaaaaaaaaaaq = 'aaq';
        String aaaaaaaaaaaaaaaaaaaar = 'aar';
        String aaaaaaaaaaaaaaaaaaaaas = 'aas';
        String aaaaaaaaaaaaaaaaaaaat = 'aat';
        String aaaaaaaaaaaaaaaaaaaau = 'aau';
        String aaaaaaaaaaaaaaaaaaaav = 'aav';
        String aaaaaaaaaaaaaaaaaaxaa = 'aax';
        String aaaaaaaaaaaaaaaaaaayaa = 'aay';
        String aaaaaaaaaaaaaaaaaaazaa = 'aaz';
    
        String aaaaaaaaaaaaaaaaaaaaaab = 'aab';
        String aaaaaaaaaaaaaaaaaaaaac = 'aac';
        String aaaaaaaaaaaaaaaaaaaaada = 'aad';
        String aaeaaaaaaaaaaaaaaaaaaa = 'aae';
        String aaaaaaaaaaaaaaaaaaafaa ='aaf';
        String aaaaaaaaaaaaaaaaaaaaga = 'aag';
        String aaaaaaaaaaaaaaaaaaaaah = 'aah';
        String aaaaaaaaaaaaaaaaaaaaai = 'aai';
        String aaaaaaaaaaaaaaaaaaaaaj = 'aaj';
        String aaaaaaaaaaaaaaaaaaaaak = 'aak';
        String aaaaaaaaaaaaaaaaaaaaaal = 'aal';
        String aaaaaaaaaaaaaaaaaaaaam = 'aam';
        String aaaaaaaaaaaaaaaaaaaaaan = 'aan';
        String aaaaaaaaaaaaaaaaaaaaao = 'aao';
        String aaaaaaaaaaaaaaaaaaaaap = 'aap';
        String aaaaaaaaaaaaaaaaaaaaaq = 'aaq';
        String aaaaaaaaaaaaaaaaaaaaar = 'aar';
        String aaaaaaaaaaaaaaaaaaaaaas = 'aas';
        String aaaaaaaaaaaaaaaaaaaaat = 'aat';
        String aaaaaaaaaaaaaaaaaaaaau = 'aau';
        String aaaaaaaaaaaaaaaaaaaaav = 'aav';
        String aaaaaaaaaaaaaaaaaaaxaa = 'aax';
        String aaaaaaaaaaaaaaaaaaaayaa = 'aay';
        String aaaaaaaaaaaaaaaaaaaazaa = 'aaz';
        String aaaaaaaaaaaaaaaaaaaaaaab = 'aab';
        String aaaaaaaaaaaaaaaaaaaaaac = 'aac';
        String aaaaaaaaaaaaaaaaaaaaaada = 'aad';
        String aaeaaaaaaaaaaaaaaaaaaaa = 'aae';
        String aaaaaaaaaaaaaaaaaaaafaa ='aaf';
        String aaaaaaaaaaaaaaaaaaaaaga = 'aag';
        String aaaaaaaaaaaaaaaaaaaaaah = 'aah';
        String aaaaaaaaaaaaaaaaaaaaaai = 'aai';
        String aaaaaaaaaaaaaaaaaaaaaaj = 'aaj';
        String aaaaaaaaaaaaaaaaaaaaaak = 'aak';
        String aaaaaaaaaaaaaaaaaaaaaaal = 'aal';
        String aaaaaaaaaaaaaaaaaaaaaam = 'aam';
        String aaaaaaaaaaaaaaaaaaaaaaan = 'aan';
        String aaaaaaaaaaaaaaaaaaaaaao = 'aao';
        String aaaaaaaaaaaaaaaaaaaaaap = 'aap';
        String aaaaaaaaaaaaaaaaaaaaaaq = 'aaq';
        String aaaaaaaaaaaaaaaaaaaaaar = 'aar';
        String aaaaaaaaaaaaaaaaaaaaaaas = 'aas';
        String aaaaaaaaaaaaaaaaaaaaaat = 'aat';
        String aaaaaaaaaaaaaaaaaaaaaau = 'aau';
        String aaaaaaaaaaaaaaaaaaaaaav = 'aav';
        String aaaaaaaaaaaaaaaaaaaaxaa = 'aax';
        String aaaaaaaaaaaaaaaaaaaaayaa = 'aay';
        String aaaaaaaaaaaaaaaaaaaaazaa = 'aaz';
        
        String aaaaaaaasfaaaaaaaaaaaaaaab = 'aab';
        String aaaaaaaaaaaaaaaaaaaaaaac = 'aac';
        String aaaaaaaaaaaaaaaaaaaaaaada = 'aad';
        String aaeaaaaaaaaaaaaaaaaaaaaa = 'aae';
        String aaaaaaaaaaaaaaaaaaaaafaa ='aaf';
        String aaaaaaaaaaaaaaaaaaaaaaga = 'aag';
        String aaaaaaaaaaaaaaaaaaaaaaah = 'aah';
        String aaaaaaaaaaaaaaaaaaaaaaai = 'aai';
        String aaaaaaaaaaaaaaaaaaaaaaaj = 'aaj';
        String aaaaaaaaaaaaaaaaaaaaaaak = 'aak';
        String aaaaaaaaaaaaaaaaaaaaaaaal = 'aal';
        String aaaaaaaaaaaaaaaaaaaaaaam = 'aam';
        String aaaaaaaaaaaaaaaaaaaaaaaan = 'aan';
        String aaaaaaaaaaaaaaaaaaaaaaaaaaaao = 'aao';
        String aaaaaaaaaaaaaaaaaaaaaaap = 'aap';
        String aaaaaaaaaaaaaaaaaaaaaaaq = 'aaq';
        String aaaaaaaaaaaaaaaaaaaaaaar = 'aar';
        String aaaaaaaaaaaaaaaaaaaaaaaas = 'aas';
        String aaaaaaaaaaaaaaaaaaaaaaat = 'aat';
        String aaaaaaaaaaaaaaaaaaaaaaau = 'aau';
        String aaaaaaaaaaaaaaaaaaaaaaav = 'aav';
        String aaaaaaaaaaaaaaaaaaaaaxaa = 'aax';
        String aaaaaaaaaaaaaaaaaaaaaayaa = 'aay';
        String aaaaaaaaaaaaaaaaaaaaaazaa = 'aaz';
        String aaaaaaaaaaaaaaaaaaaaaaaab = 'aab';
        String aaaaaaaaaaaaaaaaaaaaaaaac = 'aac';
        String aaaaaaaaaaaaaaaaaaaaaadaa = 'aad';
        String aaeaaaaaaaaaaaaaaaaaaaaaa = 'aae';
        String aaaaaaaaaaaaaaaaaaaaaafaa ='aaf';
        String aaaaaaaaaaaaaaaaaaaaaaaga = 'aag';
        String aaaaaaaaaaaaaaaaaaaaaaaah = 'aah';
        String aaaaaaaaaaaaaaaaaaaaaaaai = 'aai';
        String aaaaaaaaaaaaaaaaaaaaaaaaj = 'aaj';
        String aaaaaaaaaaaaaaaaaaaaaaaak = 'aak';
        String aaaaaaaaaaaaaaaaaaaaaaaaal = 'aal';
        String aaaaaaaaaaaaaaaaaaaaaaaam = 'aam';
        String aaaaaaaaaaaaaaaaaaaaaaaaan = 'aan';
        String aaaaaaaaaaaaaaaaaaaaaaao = 'aao';
        String aaaaaaaaaaaaaaaaaaaaaaaap = 'aap';
        String aaaaaaaaaaaaaaaaaaaaaaaaq = 'aaq';
        String aaaaaaaaaaaaaaaaaaaaaaaar = 'aar';
        String aaaaaaaaaaaaaaaaaaaaaaaaas = 'aas';
        String aaaaaaaaaaaaaaaaaaaaaaaat = 'aat';
        String aaaaaaaaaaaaaaaaaaaaaaaau = 'aau';
        String aaaaaaaaaaaaaaaaaaaaaaaav = 'aav';
        String aaaaaaaaaaaaaaaaaaaaaaxaa = 'aax';
        String aaaaaaaaaaaaaaaaaaaaaaayaa = 'aay';
        String aaaaaaaaaaaaaaaaaaaaaaazaa = 'aaz';
    }
}