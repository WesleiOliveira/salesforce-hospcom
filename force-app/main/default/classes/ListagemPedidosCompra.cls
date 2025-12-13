public class ListagemPedidosCompra {

    public List<Cotacao> cotacoes {get;set;}
    public Valor valor {get;set;}
    public Filtro filtro {get;set;}
    public Paginacao paginacao {get;set;}
    public Mensagem mensagem {get;set;}

    public ListagemPedidosCompra() {
        Inicializa();
        NovaPesquisa();
    }

    public void Inicializa(){
        cotacoes = new List<Cotacao>();

        valor = new Valor();
        valor.usuarios = [SELECT Id, Name, SmallPhotoUrl FROM User WHERE (IsActive = true) AND (UserType IN ('PowerPartner','Standard')) AND (NOT Name LIKE '%(desativado)%') ORDER BY Name];
        valor.proprietarios.add(new SelectOption('', '-- Nenhum --'));
        for(User usuario : valor.usuarios)
            valor.proprietarios.add(new SelectOption(usuario.Id, usuario.Name));
        valor.cotacao_status.add(new SelectOption('', '-- Nenhum --'));
        for(Schema.PicklistEntry status : Pedido_de_compra__c.Status__c.getDescribe().getPicklistValues())
            valor.cotacao_status.add(new SelectOption(status.getLabel(),status.getLabel()));
        valor.pedido_fretes.add(new SelectOption('', '-- Nenhum --'));
        for(Schema.PicklistEntry frete : Fornecedor__c.Tipo_de_Frete__c.getDescribe().getPicklistValues())
            valor.pedido_fretes.add(new SelectOption(frete.getLabel(),frete.getLabel()));
        valor.pedido_pagamentos.add(new SelectOption('', '-- Nenhum --'));
        for(Schema.PicklistEntry pagamento : Fornecedor__c.Forma_de_pagamento__c.getDescribe().getPicklistValues())
            valor.pedido_pagamentos.add(new SelectOption(pagamento.getLabel(),pagamento.getLabel()));
        valor.item_marcas.add(new SelectOption('', '-- Nenhum --'));
        for(Schema.PicklistEntry marca : Product2.Marca__c.getDescribe().getPicklistValues())
            valor.item_marcas.add(new SelectOption(marca.getLabel(),marca.getLabel()));
        valor.item_familias.add(new SelectOption('', '-- Nenhum --'));
        for(Schema.PicklistEntry familia : Product2.Family.getDescribe().getPicklistValues())
            valor.item_familias.add(new SelectOption(familia.getLabel(),familia.getLabel()));
        valor.item_tipos.add(new SelectOption('', '-- Nenhum --'));
        for(Schema.PicklistEntry tipo : Product2.Tipo_do_Produto__c.getDescribe().getPicklistValues())
            valor.item_tipos.add(new SelectOption(tipo.getLabel(),tipo.getLabel()));
        valor.venda_item_status.add(new SelectOption('', '-- Nenhum --'));
        for(Schema.PicklistEntry status : OrderItem.Status__c.getDescribe().getPicklistValues())
            valor.venda_item_status.add(new SelectOption(status.getLabel(),status.getLabel()));
        valor.venda_pedido_status.add(new SelectOption('', '-- Nenhum --'));
        for(Schema.PicklistEntry status : Order.Status.getDescribe().getPicklistValues())
            valor.venda_pedido_status.add(new SelectOption(status.getLabel(),status.getLabel()));
        valor.venda_pedido_pai_tipos.add(new SelectOption('', '-- Nenhum --'));
        valor.venda_pedido_pai_tipos.add(new SelectOption('OPP', 'OPP'));
        valor.venda_pedido_pai_tipos.add(new SelectOption('OT', 'OT'));     
        valor.venda_pedido_estados.add(new SelectOption('', '-- Nenhum --'));
        Schema.DescribeFieldResult estados = Account.BillingStateCode.getDescribe();
        for(Schema.PicklistEntry estado : estados.getPicklistValues())
            valor.venda_pedido_estados.add(new SelectOption(estado.getLabel(),estado.getLabel()));
        valor.venda_pedido_tipos.add(new SelectOption('', '-- Nenhum --'));
        valor.venda_pedido_tipos.add(new SelectOption('Comercial', 'Comercial'));
        valor.venda_pedido_tipos.add(new SelectOption('Governo', 'Governo'));
        valor.venda_pedido_tipos.add(new SelectOption('Serviço', 'Serviço'));
        valor.venda_pedido_entregas.add(new SelectOption('', '-- Nenhum --'));
        for(Schema.PicklistEntry entrega : Order.Entrega_parcial__c.getDescribe().getPicklistValues())
            valor.venda_pedido_entregas.add(new SelectOption(entrega.getLabel(),entrega.getLabel()));
        
        filtro = new Filtro();
        paginacao = new Paginacao();
        mensagem = new Mensagem();
    }

    public void Pesquisa(){
        List<String> filtro_cotacao = new List<String>(); // item cotação + cotação
        List<String> filtro_pedido = new List<String>();  // item pedido compra + pedido compra
        List<String> filtro_venda = new List<String>();   // requisicao + item venda + pedido venda
        String where_cotacao = '';  
        String where_pedido = '';  
        String where_venda = '';   
        String sql_paginado = '';
        String sql_compra = '';
        Integer sql_offset = (paginacao.pagina_atual-1)*(paginacao.registro_pagina);

        // monta filtros ==========================================================================

        // filtros categoria "cotação" ------------------------------------------------------------

        // filtros de "cotação"
        if(filtro.cotacao_numero != null && filtro.cotacao_numero != '')
            filtro_cotacao.add('Pedido_de_compra__r.Name = \''+filtro.cotacao_numero.leftPad(8,'0')+'\'');
        if(filtro.cotacao_descricao != null && filtro.cotacao_descricao != '')
            filtro_cotacao.add('Pedido_de_compra__r.Descricao__c LIKE \'%'+filtro.cotacao_descricao+'%\'');
        for(Integer cont = filtro.cotacao_status.size()-1; cont >= 0; cont--)
            if(filtro.cotacao_status[cont] == '' || filtro.cotacao_status[cont] == null)
                filtro.cotacao_status.remove(cont);
            else
                filtro.cotacao_status[cont] = '\''+filtro.cotacao_status[cont]+'\'';
        if(filtro.cotacao_status.size()>0)
            filtro_cotacao.add('Pedido_de_compra__r.Status__c IN ('+String.join(filtro.cotacao_status, ',')+')');
        for(Integer cont = filtro.cotacao_proprietario.size()-1; cont >= 0; cont--)
            if(filtro.cotacao_proprietario[cont] == '' || filtro.cotacao_proprietario[cont] == null)
                filtro.cotacao_proprietario.remove(cont);
            else
                filtro.cotacao_proprietario[cont] = '\''+filtro.cotacao_proprietario[cont]+'\'';
        if(filtro.cotacao_proprietario.size()>0)
            filtro_cotacao.add('Pedido_de_compra__r.OwnerId IN ('+String.join(filtro.cotacao_proprietario, ',')+')');

        // filtros de "item de cotação"
        if(filtro.item_codigo != null && filtro.item_codigo != '')
            filtro_cotacao.add('Codigo_do_produto__c LIKE \'%'+filtro.item_codigo+'%\'');
        if(filtro.item_nome != null && filtro.item_nome != '')
            filtro_cotacao.add('Produto__r.Name LIKE \'%'+filtro.item_nome+'%\'');
        if(filtro.item_modelo != null && filtro.item_modelo != '')
            filtro_cotacao.add('Modelo__c LIKE \'%'+filtro.item_modelo+'%\'');
        for(Integer cont = filtro.item_marca.size()-1; cont >= 0; cont--)
            if(filtro.item_marca[cont] == '' || filtro.item_marca[cont] == null)
                filtro.item_marca.remove(cont);
            else
                filtro.item_marca[cont] = '\''+filtro.item_marca[cont]+'\'';
        if(filtro.item_marca.size()>0)
            filtro_cotacao.add('Marca__c IN ('+String.join(filtro.item_marca, ',')+')');
        for(Integer cont = filtro.item_familia.size()-1; cont >= 0; cont--)
            if(filtro.item_familia[cont] == '' || filtro.item_familia[cont] == null)
                filtro.item_familia.remove(cont);
            else
                filtro.item_familia[cont] = '\''+filtro.item_familia[cont]+'\'';
        if(filtro.item_familia.size()>0)
            filtro_cotacao.add('Familia__c IN ('+String.join(filtro.item_familia, ',')+')');
        for(Integer cont = filtro.item_tipo.size()-1; cont >= 0; cont--)
            if(filtro.item_tipo[cont] == '' || filtro.item_tipo[cont] == null)
                filtro.item_tipo.remove(cont);
            else
                filtro.item_tipo[cont] = '\''+filtro.item_tipo[cont]+'\'';
        if(filtro.item_tipo.size()>0)
            filtro_cotacao.add('Tipo__c IN ('+String.join(filtro.item_tipo, ',')+')');

        // filtros categoria "pedido" -------------------------------------------------------------

        // filtros de "pedido de compra"
        if(filtro.pedido_numero != null && filtro.pedido_numero != '')
            filtro_pedido.add('Fornecedor__r.Name = \''+filtro.pedido_numero.leftPad(8,'0')+'\'');
        if(filtro.pedido_fornecedor != null && filtro.pedido_fornecedor != '')
            filtro_pedido.add(
                '( ' +
                    'Fornecedor__r.Fornecedor__r.Name LIKE \'%'+filtro.pedido_fornecedor+'%\' OR '+
                    'Fornecedor__r.Fornecedor__r.Raz_o_Social__c LIKE \'%'+filtro.pedido_fornecedor+'%\' OR '+
                    'Fornecedor__r.Fornecedor__r.CNPJ__c LIKE \'%'+filtro.pedido_fornecedor+'%\' '+
                ' )'
            );
        if(filtro.pedido_comprador != null && filtro.pedido_comprador != '')
            filtro_pedido.add(
                '( ' +
                    'Fornecedor__r.Comprador__r.Name LIKE \'%'+filtro.pedido_comprador+'%\' OR '+
                    'Fornecedor__r.Comprador__r.Raz_o_Social__c LIKE \'%'+filtro.pedido_comprador+'%\' OR '+
                    'Fornecedor__r.Comprador__r.CNPJ__c LIKE \'%'+filtro.pedido_comprador+'%\' '+
                ' )'
            );
        if(filtro.pedido_transportadora != null && filtro.pedido_transportadora != '')
            filtro_pedido.add(
                '( ' +
                    'Fornecedor__r.Transportadora__r.Name LIKE \'%'+filtro.pedido_transportadora+'%\' OR '+
                    'Fornecedor__r.Transportadora__r.Raz_o_Social__c LIKE \'%'+filtro.pedido_transportadora+'%\' OR '+
                    'Fornecedor__r.Transportadora__r.CNPJ__c LIKE \'%'+filtro.pedido_transportadora+'%\' '+
                ' )'
            );
        if(filtro.pedido_frete != null && filtro.pedido_frete != '')
            filtro_pedido.add('Fornecedor__r.Tipo_de_Frete__c = \''+filtro.pedido_frete+'\'');
        for(Integer cont = filtro.pedido_pagamento.size()-1; cont >= 0; cont--)
            if(filtro.pedido_pagamento[cont] == '' || filtro.pedido_pagamento[cont] == null)
                filtro.pedido_pagamento.remove(cont);
            else
                filtro.pedido_pagamento[cont] = '\''+filtro.pedido_pagamento[cont]+'\'';
        if(filtro.pedido_pagamento.size()>0)
            filtro_pedido.add('Fornecedor__r.Forma_de_pagamento__c IN ('+String.join(filtro.pedido_pagamento, ',')+')');

        // filtros de "item de compra"
        // < vazio >

        // filtros categoria "venda" --------------------------------------------------------------

        // filtros de "requisicao"
        // < vazio >

        // filtros de "item de venda"
        for(Integer cont = filtro.venda_item_status.size()-1; cont >= 0; cont--)
            if(filtro.venda_item_status[cont] == '' || filtro.venda_item_status[cont] == null)
                filtro.venda_item_status.remove(cont);
            else
                filtro.venda_item_status[cont] = '\''+filtro.venda_item_status[cont]+'\'';
        if(filtro.venda_item_status.size()>0)
            filtro_venda.add('Item_de_pedido_de_venda__r.Status__c IN ('+String.join(filtro.venda_item_status, ',')+')');

        // filtros de "pedido de venda"
        for(Integer cont = filtro.venda_pedido_status.size()-1; cont >= 0; cont--)
            if(filtro.venda_pedido_status[cont] == '' || filtro.venda_pedido_status[cont] == null)
                filtro.venda_pedido_status.remove(cont);
            else
                filtro.venda_pedido_status[cont] = '\''+filtro.venda_pedido_status[cont]+'\'';
        if(filtro.venda_pedido_status.size()>0)
            filtro_venda.add('Item_de_pedido_de_venda__r.Order.Status IN ('+String.join(filtro.venda_pedido_status, ',')+')');
        if(filtro.venda_pedido_numero != null && filtro.venda_pedido_numero != '')
            filtro_venda.add('Item_de_pedido_de_venda__r.Order.OrderNumber = \''+filtro.venda_pedido_numero.leftPad(8,'0')+'\'');
        if(filtro.venda_pedido_cliente != null && filtro.venda_pedido_cliente != '')
            filtro_venda.add(
                '( ' +
                    'Item_de_pedido_de_venda__r.Order.Account.Name LIKE \'%'+filtro.venda_pedido_cliente+'%\' OR '+
                    'Item_de_pedido_de_venda__r.Order.Account.Raz_o_Social__c LIKE \'%'+filtro.venda_pedido_cliente+'%\' OR '+
                    'Item_de_pedido_de_venda__r.Order.Account.CNPJ__c LIKE \'%'+filtro.venda_pedido_cliente+'%\' '+
                ' )'
            );
        if(filtro.venda_pedido_pai_tipo != null && filtro.venda_pedido_pai_tipo != ''){
            if(filtro.venda_pedido_pai_numero != null && filtro.venda_pedido_pai_numero != ''){
                if(filtro.venda_pedido_pai_tipo == 'OT')
                    filtro_venda.add('Item_de_pedido_de_venda__r.Order.Ordem_de_trabalho__r.WorkOrderNumber = \''+filtro.venda_pedido_pai_numero.leftPad(8,'0')+'\'');
                else if (filtro.venda_pedido_pai_tipo == 'OPP')
                    filtro_venda.add('Item_de_pedido_de_venda__r.Order.Opportunity.Numero_OP__c = \''+filtro.venda_pedido_pai_numero+'\'');
            }else{
                if(filtro.venda_pedido_pai_tipo == 'OT')
                    filtro_venda.add('Item_de_pedido_de_venda__r.Order.Ordem_de_trabalho__r.WorkOrderNumber != null');
                else if (filtro.venda_pedido_pai_tipo == 'OPP')
                    filtro_venda.add('Item_de_pedido_de_venda__r.Order.Opportunity.Numero_OP__c != null');
            }
        }
        for(Integer cont = filtro.venda_pedido_estado.size()-1; cont >= 0; cont--)
            if(filtro.venda_pedido_estado[cont] == '' || filtro.venda_pedido_estado[cont] == null)
                filtro.venda_pedido_estado.remove(cont);
            else
                filtro.venda_pedido_estado[cont] = '\''+filtro.venda_pedido_estado[cont]+'\'';
        if(filtro.venda_pedido_estado.size()>0)
            filtro_venda.add('Item_de_pedido_de_venda__r.Order.Account.BillingState IN ('+String.join(filtro.venda_pedido_estado, ',')+')');
        
        for(Integer cont = filtro.venda_pedido_tipo.size()-1; cont >= 0; cont--)
            if(filtro.venda_pedido_tipo[cont] == '' || filtro.venda_pedido_tipo[cont] == null)
                filtro.venda_pedido_tipo.remove(cont);
            else
                filtro.venda_pedido_tipo[cont] = '\''+filtro.venda_pedido_tipo[cont]+'\'';
        if(filtro.venda_pedido_tipo.size()>0)
            filtro_venda.add('Item_de_pedido_de_venda__r.Order.Tipo__c IN ('+String.join(filtro.venda_pedido_tipo, ',')+')');
        if(filtro.venda_pedido_entrega != null && filtro.venda_pedido_entrega != '')
            filtro_venda.add('Item_de_pedido_de_venda__r.Order.Entrega_Parcial_Autorizada__c = \''+filtro.venda_pedido_entrega+'\'');
        for(Integer cont = filtro.venda_pedido_proprietario.size()-1; cont >= 0; cont--)
            if(filtro.venda_pedido_proprietario[cont] == '' || filtro.venda_pedido_proprietario[cont] == null)
                filtro.venda_pedido_proprietario.remove(cont);
            else
                filtro.venda_pedido_proprietario[cont] = '\''+filtro.venda_pedido_proprietario[cont]+'\'';
        if(filtro.venda_pedido_proprietario.size()>0)
            filtro_venda.add('Item_de_pedido_de_venda__r.Order.OwnerId IN ('+String.join(filtro.venda_pedido_proprietario, ',')+')');

        /* filtro "global" ------------------------------------------------------------------------
        if(filtro.globalf != null && filtro.globalf != '')
            filtro_pedido.add('(' +
                'Pedido_de_compra__r.Name               = \''+filtro.globalf.leftPad(8,'0')+'\'     OR ' +
                'Pedido_de_compra__r.Descricao__c       LIKE \'%'+filtro.globalf+'%\'               OR ' +
                'Name                                   = \''+filtro.globalf.leftPad(8,'0')+'\'     OR ' +
                'Fornecedor__c.Name                     LIKE \'%'+filtro.globalf+'%\'               OR ' +
                'Fornecedor__c.Raz_o_Social__c          LIKE \'%'+filtro.globalf+'%\'               OR ' +
                'Fornecedor__c.CNPJ__c                  LIKE \'%'+filtro.globalf+'%\'               OR ' +
                'Comprador__c.Name                      LIKE \'%'+filtro.globalf+'%\'               OR ' +
                'Comprador__c.Raz_o_Social__c           LIKE \'%'+filtro.globalf+'%\'               OR ' +
                'Comprador__c.CNPJ__c                   LIKE \'%'+filtro.globalf+'%\'               OR ' +
                'Forma_de_pagamento__c                  LIKE \'%'+filtro.globalf+'%\'               OR ' +
                'Owner.Name                             LIKE \'%'+filtro.globalf+'%\'                  ' +
            ')');       
        */

        // monta WHERE ============================================================================

        // where categoria "pedido"
        if(filtro_pedido.size() > 0){
            where_pedido = 'WHERE ' + String.join(filtro_pedido, ' AND ');
            filtro_cotacao.add('Id IN (SELECT Item_de_pedido_de_compra__c FROM Item_de_fornecedor__c ' + where_pedido + ')');
        }

        // where categoria "venda"
        if(filtro_venda.size() > 0){
            where_venda = 'WHERE ' + String.join(filtro_venda, ' AND ');
            filtro_cotacao.add('Id IN (SELECT Item_de_pedido_de_compra__c FROM Requisicao_de_item__c ' + where_venda + ')');
        }

        // where categoria "cotação"
        if(filtro_cotacao.size() > 0){
            where_cotacao = 'WHERE ' + String.join(filtro_cotacao, ' AND ');
        }

        // executa SQL ============================================================================

        // aplica offset --------------------------------------------------------------------------
        sql_paginado = 
            'SELECT     Pedido_de_compra__c           ' +
            'FROM       Item_de_pedido_de_compra__c   ' + 
             where_cotacao + '                        ' + 
            'GROUP BY   Pedido_de_compra__c           ' + 
            'ORDER BY   Pedido_de_compra__c ASC       ' + 
            'LIMIT      '+paginacao.registro_pagina+' ' + 
            'OFFSET     '+sql_offset+'                '
        ;
        List<String> cotacoes_id = new List<String>();
        for(AggregateResult item_cotacao : (List<AggregateResult>)Database.query(sql_paginado))
            cotacoes_id.add('\'' + (String)item_cotacao.get('Pedido_de_compra__c') + '\'');
        
        // contagem de registros para paginação
        String sql_query_count = 'SELECT Pedido_de_compra__c FROM Item_de_pedido_de_compra__c ' + where_cotacao + ' GROUP BY Pedido_de_compra__c' ;
        System.Debug(LoggingLevel.INFO,'sql_query_count:'+sql_query_count);
        List<AggregateResult> itens = Database.query(sql_query_count);
        paginacao.registro_total = itens.size();
        paginacao.pagina_final = (Integer)((paginacao.registro_total/(Decimal)paginacao.registro_pagina).round(System.RoundingMode.UP));
        
        // add filtro do offset no where global
        if(cotacoes_id.size()>0){
            filtro_cotacao.add('Pedido_de_compra__c IN ('+String.join(cotacoes_id, ',')+')');
            where_cotacao = 'WHERE ' + String.join(filtro_cotacao, ' AND ');
        }

        // retorna estrutura filtrada -------------------------------------------------------------
        sql_compra = 
            'SELECT     Id, Pedido_de_compra__c, Pedido_de_compra__r.Name, Pedido_de_compra__r.Descricao__c, Pedido_de_compra__r.Data_de_inicio__c,                   ' +
            '           Pedido_de_compra__r.Status__c, Pedido_de_compra__r.OwnerId, Pedido_de_compra__r.Valor_total_comprado__c, Pedido_de_compra__r.CurrencyIsoCode,(' +
            '               SELECT      Id, Name, Comprar__c, Valor_total__c, Valor_unitario__c, Quantidade__c, Item_de_pedido_de_compra__c,                          ' +
            '                           Item_de_pedido_de_compra__r.Produto__r.URL_da_Imagem__c, Item_de_pedido_de_compra__r.Codigo_do_produto__c,                    ' +
            '                           Item_de_pedido_de_compra__r.Nome__c, Item_de_pedido_de_compra__r.Modelo__c, Item_de_pedido_de_compra__r.Marca__c,             ' +
            '                           Item_de_pedido_de_compra__r.Descri_o_da_linha__c, Fornecedor__c, Fornecedor__r.Name,                                          ' +
            '                           Fornecedor__r.Fornecedor__c, Fornecedor__r.Fornecedor__r.Raz_o_Social__c, Fornecedor__r.Pedido_de_compra__c,Fornecedor__r.Status_do_PC__c,                  ' +
            '                           Fornecedor__r.Comprador__c, Fornecedor__r.Comprador__r.Raz_o_Social__c, Item_de_pedido_de_compra__r.Quantidade_recebida__c,   ' +
            '                           Fornecedor__r.Tipo_de_Frete__c, Fornecedor__r.Forma_de_pagamento__c, Fornecedor__r.Descricao_do_pagamento__c,                 ' +
            '                           Fornecedor__r.Prazo_de_recebimento__c, Fornecedor__r.Valor_total_comprado__c, Fornecedor__r.CurrencyIsoCode                   ' +
            '               FROM        Itens_de_fornecedor__r                                                                                                        ' +
            '               ORDER BY    Fornecedor__r.Name ASC, Name ASC                                                                                              ' +
            '           ),(                                                                                                                                           ' +
            '               SELECT      Id, RecordType.DeveloperName, Comprar__c, Arquivar__c, Quantidade_recebida__c, Item_de_pedido_de_compra__c,                   ' +
            '                           Item_de_pedido_de_venda__r.Id, Item_de_pedido_de_venda__r.OrderItemNumber, Item_de_pedido_de_venda__r.Status__c,              ' +
            '                           Item_de_pedido_de_venda__r.TotalPrice, Item_de_pedido_de_venda__r.UnitPrice,                                                  ' +
            '                           Quantidade_requisitada__c, Item_de_pedido_de_venda__r.Quantity,                                                               ' +
            '                           item_de_pedido_de_venda__r.Order.Id, Item_de_pedido_de_venda__r.Order.OrderNumber,                                            ' +
            '                           Item_de_pedido_de_venda__r.Order.Status, Item_de_pedido_de_venda__r.Order.OwnerId,                                            ' +
            '                           Item_de_pedido_de_venda__r.Order.AccountId, Item_de_pedido_de_venda__r.Order.Account.Raz_o_Social__c,                         ' +
            '                           Item_de_pedido_de_venda__r.Order.Faturamento_Feito__c, Item_de_pedido_de_venda__r.Order.Faturamento_Feito__r.Raz_o_Social__c, ' +
            '                           Item_de_pedido_de_venda__r.Order.Tipo__c,                                                                                     ' +
            '                           Item_de_pedido_de_venda__r.Order.OpportunityId, Item_de_pedido_de_venda__r.Order.Opportunity.Numero_OP__c,                    ' +
            '                           Item_de_pedido_de_venda__r.Order.Opportunity.Name, Item_de_pedido_de_venda__r.Order.Opportunity.OwnerId,                      ' +
            '                           Item_de_pedido_de_venda__r.Order.Ordem_de_trabalho__c, Item_de_pedido_de_venda__r.Order.Ordem_de_trabalho__r.WorkOrderNumber, ' +
            '                           Item_de_pedido_de_venda__r.Order.Ordem_de_trabalho__r.Subject, Item_de_pedido_de_venda__r.Order.Ordem_de_trabalho__r.OwnerId  ' +
            '               FROM        Requisicoes_de_itens__r                                                                                                       ' +
            '               ORDER BY    Item_de_pedido_de_venda__r.Order.OrderNumber ASC, Item_de_pedido_de_venda__r.OrderItemNumber ASC                              ' +
            '           )                                                                                                                                             ' +
            'FROM       Item_de_pedido_de_compra__c                                                                                                                   ' +
            + where_cotacao + '                                                                                                                                       ' +
            'ORDER BY   Pedido_de_compra__r.Name ASC, Name ASC                                                                                                        '
        ;
        List<Item_de_pedido_de_compra__c> sql_resultado = (List<Item_de_pedido_de_compra__c>)Database.query(sql_compra);

        // monta nova estrutura identada ----------------------------------------------------------
        cotacoes = new List<Cotacao>();
        
        // adiciona "cotações"
        cotacoes_id.clear();
        for(Item_de_pedido_de_compra__c sql_item_cotacao : sql_resultado){
            if(!cotacoes_id.contains((String)sql_item_cotacao.Pedido_de_compra__c)){
                cotacoes.add(new Cotacao(sql_item_cotacao.Pedido_de_compra__r));
                cotacoes_id.add(sql_item_cotacao.Pedido_de_compra__c);
            }
        }

        // adiciona "pedidos compra" (nas "cotações")
        List<String> pedidos_id = new List<String>();
        for(Cotacao cotacao : cotacoes){

            for(Item_de_pedido_de_compra__c sql_item_cotacao : sql_resultado){
                if(cotacao.id == sql_item_cotacao.Pedido_de_compra__c){
                    for(Item_de_fornecedor__c sql_item_compra : sql_item_cotacao.Itens_de_fornecedor__r){
                        if(!pedidos_id.contains((String)sql_item_compra.Fornecedor__c)){
                            cotacao.pedidos_compra.add(new PedidoCompra(sql_item_compra.Fornecedor__r));                            
                            pedidos_id.add(sql_item_compra.Fornecedor__c);
                        }
                    }
                }
            }

        }


        
        // adiciona "itens compra" (nos "pedidos compra")
        for(Cotacao cotacao : cotacoes){
            for(PedidoCompra pedido_compra : cotacao.pedidos_compra){

                for(Item_de_pedido_de_compra__c sql_item_cotacao : sql_resultado){  
                    if(cotacao.id == sql_item_cotacao.Pedido_de_compra__c){
                        for(Item_de_fornecedor__c sql_item_compra : sql_item_cotacao.Itens_de_fornecedor__r){
                            if(pedido_compra.id == sql_item_compra.Fornecedor__c){
                                pedido_compra.itens_compra.add(new ItemCompra(sql_item_compra));
                            }
                        }
                    }
                }

            }
        }

        
        // adiciona "vínculos" (nos "itens compra")
        for(Cotacao cotacao : cotacoes){
            for(PedidoCompra pedido_compra : cotacao.pedidos_compra){
                for(ItemCompra item_compra : pedido_compra.itens_compra){

                    for(Item_de_pedido_de_compra__c sql_item_cotacao : sql_resultado){
                        if(cotacao.id == sql_item_cotacao.Pedido_de_compra__c){
                            for(Requisicao_de_item__c sql_requisicao_item : sql_item_cotacao.Requisicoes_de_itens__r){
                                if(item_compra.id_item_cotacao == sql_requisicao_item.Item_de_pedido_de_compra__c){
                                    item_compra.vinculos.add(new Vinculo(cotacao.pedidos_venda_id, cotacao.pedidos_venda_nome, sql_requisicao_item));
                                }
                            }
                        }
                    }

                }
            }
        }
        
    }

    public void Mensagens(){
        mensagem.tem_mensagem = ((ApexPages.getMessages().size()>0)?true:false);
        if(mensagem.tem_mensagem)
            for(Apexpages.Message mensagem_temp: ApexPages.getMessages())
                mensagem.mensagens.add(mensagem_temp.getDetail());
    }

    public void NovaPesquisa(){
        paginacao.pagina_atual = 1;
        Pesquisa();
        Mensagens();
    }

    public void PaginaAnterior(){
        paginacao.pagina_atual = paginacao.pagina_atual-1;
        Pesquisa();
    }

    public void PaginaSeguinte(){
        paginacao.pagina_atual = paginacao.pagina_atual+1;
        Pesquisa();
    }

    public static String FormataMoeda(String moeda, Decimal valor){
        String valor_formatado = '';
        if(valor==null)
            valor_formatado = '-';
        else{
            List<String> formato = new String[]{'###,###,#00.00'};
            valor_formatado = String.format(valor.format(), formato);
            if(!valor_formatado.contains(','))
                valor_formatado += ',00';
            else if (valor_formatado.substring(valor_formatado.length()-2, valor_formatado.length()-1)==',')
                valor_formatado += '0';         
        }
        return moeda + ' ' + valor_formatado;
    }

    
    public class Valor {
        public String url_base {get;set;}
        public String url_prefixo {get;set;}
        public List<User>         usuarios {get;set;}
        public List<SelectOption> proprietarios {get;set;}
        public List<SelectOption> cotacao_status {get;set;}
        public List<SelectOption> pedido_fretes {get;set;}
        public List<SelectOption> pedido_pagamentos {get;set;}
        public List<SelectOption> item_marcas {get;set;}
        public List<SelectOption> item_familias {get;set;}
        public List<SelectOption> item_tipos {get;set;}
        public List<SelectOption> venda_item_status {get;set;}
        public List<SelectOption> venda_pedido_status {get;set;}
        public List<SelectOption> venda_pedido_pai_tipos {get;set;}
        public List<SelectOption> venda_pedido_estados {get;set;}
        public List<SelectOption> venda_pedido_tipos {get;set;}
        public List<SelectOption> venda_pedido_entregas {get;set;}
        public Date               hoje {get;set;}

        public Valor() {
            url_base = URL.getSalesforceBaseUrl().toExternalForm() + Site.getPathPrefix();
            url_prefixo = Site.getPathPrefix();
            if (url_base != '') url_base += '/';
            if (url_prefixo != '') url_prefixo += '/';
            usuarios = new List<User>();
            proprietarios = new List<SelectOption>();
            cotacao_status = new List<SelectOption>();
            pedido_fretes = new List<SelectOption>();
            pedido_pagamentos = new List<SelectOption>();
            item_marcas = new List<SelectOption>();
            item_familias = new List<SelectOption>();
            item_tipos = new List<SelectOption>();
            venda_item_status = new List<SelectOption>();
            venda_pedido_status = new List<SelectOption>();
            venda_pedido_pai_tipos = new List<SelectOption>();
            venda_pedido_estados = new List<SelectOption>();
            venda_pedido_tipos = new List<SelectOption>();
            venda_pedido_entregas = new List<SelectOption>();
            hoje = System.Today();
        }
    }

    public class Filtro {
        public String globalf {get;set;}
        public String   cotacao_numero {get;set;}
        public String   cotacao_descricao {get;set;}
        public String[] cotacao_status {get;set;}
        public String[] cotacao_proprietario {get;set;}
        public String   pedido_numero {get;set;}
        public String   pedido_fornecedor {get;set;}
        public String   pedido_comprador {get;set;}
        public String   pedido_transportadora {get;set;}
        public String   pedido_frete {get;set;}
        public String[] pedido_pagamento {get;set;}
        public String   item_codigo {get;set;}
        public String   item_nome {get;set;}
        public String   item_modelo {get;set;}
        public String[] item_marca {get;set;}
        public String[] item_familia {get;set;}
        public String[] item_tipo {get;set;}
        public String[] venda_item_status {get;set;}
        public String[] venda_pedido_status {get;set;}
        public String   venda_pedido_numero {get;set;}
        public String   venda_pedido_cliente {get;set;}
        public String   venda_pedido_pai_tipo {get;set;}
        public String   venda_pedido_pai_numero {get;set;}
        public String[] venda_pedido_estado {get;set;}
        public String[] venda_pedido_tipo {get;set;}
        public String   venda_pedido_entrega {get;set;}
        public String[] venda_pedido_proprietario {get;set;}
        public Boolean  manter_itens {get;set;}
        public Boolean  fxiltrar_itens {get;set;}

        public Filtro() {
            cotacao_status = new String[]{};
            cotacao_proprietario = new String[]{};
            pedido_pagamento = new String[]{};
            item_marca = new String[]{};
            item_familia = new String[]{};
            item_tipo = new String[]{};
            venda_item_status = new String[]{};
            venda_pedido_status = new String[]{};
            venda_pedido_estado = new String[]{};
            venda_pedido_tipo = new String[]{};
            venda_pedido_proprietario = new String[]{};
            manter_itens = true;
        }
    }

    public class Paginacao {
        public Integer pagina_atual {get;set;}
        public Integer pagina_final {get;set;}
        public Integer registro_total {get;set;}
        public Integer registro_pagina {get;set;}

        public Paginacao() {
            pagina_atual = 0;
            pagina_final = 0;
            registro_total = 0;
            registro_pagina = 15;
        }
    }

    public class Mensagem {
        public Boolean tem_mensagem {get;set;}
        public List<String> mensagens {get;set;}

        public Mensagem() {
            tem_mensagem = false;
            mensagens = new List<String>();
        }
    }   


    public class Cotacao {
        public Id                       id {get;set;}
        public String                   numero {get;set;}
        public String                   descricao {get;set;}
        public Date                     data_inicio {get;set;}
        public String                   status {get;set;}
        public Id                       proprietario_id {get;set;}
        public String                   valor_total {get;set;}
        public List<PedidoCompra>       pedidos_compra {get;set;}
        public Set<id>                  pedidos_venda_id {get;set;}
        public List<PedidoVendaNome>    pedidos_venda_nome {get;set;}

        public Cotacao(Pedido_de_compra__c cotacao_parm) {
            id                          = cotacao_parm.id;
            numero                      = cotacao_parm.Name;
            descricao                   = cotacao_parm.Descricao__c;
            data_inicio                 = cotacao_parm.Data_de_inicio__c;
            status                      = cotacao_parm.Status__c;
            proprietario_id             = cotacao_parm.OwnerId;
            valor_total                 = ListagemPedidosCompra.FormataMoeda((String)cotacao_parm.CurrencyIsoCode, (Decimal)cotacao_parm.Valor_total_comprado__c);
            pedidos_compra              = new List<PedidoCompra>();
            pedidos_venda_id            = new Set<Id>();
            pedidos_venda_nome          = new List<PedidoVendaNome>();
        }

    }
    
    public class PedidoCompra {
        public Id                       id {get;set;}
        public String                   numero {get;set;}
        public Id                       fornecedor_id {get;set;}
        public String                   fornecedor_nome {get;set;}
        public Id                       comprador_id {get;set;}
        public String                   comprador_nome {get;set;}
        public String                   frete {get;set;}
        public String                   forma_pagamento {get;set;}
        public String                   descricao_pagamento {get;set;}
        public String                   status {get;set;}
        public Date                     prazo_recebimento {get;set;}
        public String                   valor_total {get;set;}
        public List<ItemCompra>         itens_compra {get;set;}

        public PedidoCompra(Fornecedor__c pedido_compra_parm) {
            id                          = pedido_compra_parm.id;
            numero                      = pedido_compra_parm.Name;
            fornecedor_id               = pedido_compra_parm.Fornecedor__c;
            fornecedor_nome             = pedido_compra_parm.Fornecedor__r.Raz_o_Social__c;
            comprador_id                = pedido_compra_parm.Comprador__c;
            comprador_nome              = pedido_compra_parm.Comprador__r.Raz_o_Social__c;
            frete                       = pedido_compra_parm.Tipo_de_Frete__c;
            status                      = pedido_compra_parm.Status_do_PC__c;
            forma_pagamento             = pedido_compra_parm.Forma_de_pagamento__c;
            descricao_pagamento         = (pedido_compra_parm.Descricao_do_pagamento__c==null?'-':pedido_compra_parm.Descricao_do_pagamento__c);
            prazo_recebimento           = pedido_compra_parm.Prazo_de_recebimento__c;
            valor_total                 = ListagemPedidosCompra.FormataMoeda('BRL', pedido_compra_parm.Valor_total_comprado__c);
            itens_compra                = new List<ItemCompra>();
        }
    }

    public class ItemCompra {
        public Id                       id_item_cotacao {get;set;}
        public String                   imagem {get;set;}
        public String                   codigo {get;set;}
        public String                   nome {get;set;}
        public String                   modelo {get;set;}
        public String                   marca {get;set;}
        public String                   descricao {get;set;}
        public Id                       id {get;set;}
        public String                   numero {get;set;}
        public Boolean                  comprar {get;set;}
        public String                   valor_unitario {get;set;}
        public String                   valor_total {get;set;}
        public Integer                  quantidade_comprada {get;set;}
        public Integer                  quantidade_recebida {get;set;}
        public List<Vinculo>            vinculos {get;set;}

        public ItemCompra(Item_de_fornecedor__c item_compra_parm) {
            id_item_cotacao             = item_compra_parm.Item_de_pedido_de_compra__c;
            imagem                      = item_compra_parm.Item_de_pedido_de_compra__r.Produto__r.URL_da_Imagem__c;
            codigo                      = (item_compra_parm.Item_de_pedido_de_compra__r.Codigo_do_produto__c==null?'-':item_compra_parm.Item_de_pedido_de_compra__r.Codigo_do_produto__c);
            nome                        = item_compra_parm.Item_de_pedido_de_compra__r.Nome__c;
            modelo                      = (item_compra_parm.Item_de_pedido_de_compra__r.Modelo__c==null?'-':item_compra_parm.Item_de_pedido_de_compra__r.Modelo__c);
            marca                       = item_compra_parm.Item_de_pedido_de_compra__r.Marca__c;
            descricao                   = (item_compra_parm.Item_de_pedido_de_compra__r.Descri_o_da_linha__c==null?'-':item_compra_parm.Item_de_pedido_de_compra__r.Descri_o_da_linha__c);
            id                          = item_compra_parm.Id;
            numero                      = item_compra_parm.Name;
            comprar                     = item_compra_parm.Comprar__c;
            valor_unitario              = ListagemPedidosCompra.FormataMoeda('BRL', item_compra_parm.Valor_unitario__c);
            valor_total                 = ListagemPedidosCompra.FormataMoeda('BRL', item_compra_parm.Valor_total__c);
            quantidade_comprada         = (Integer)item_compra_parm.Quantidade__c;
            if(comprar)
                quantidade_recebida     = (Integer)item_compra_parm.Item_de_pedido_de_compra__r.Quantidade_recebida__c;
            else
                quantidade_recebida     = 0;

            vinculos                    = new List<Vinculo>();
        }
    }

    public class Vinculo {
        public String                   tipo {get;set;}
        public Boolean                  arquivar {get;set;}
        public Integer                  quantidade_recebida {get;set;}
        public Integer                  quantidade_requisitada {get;set;}
        public ItemVenda                item_venda{get;set;} 
        public PedidoVenda              pedido_venda{get;set;} 

        public Vinculo(Set<Id> pedidos_venda_id, List<PedidoVendaNome> pedidos_venda_nome, Requisicao_de_item__c item_vinculo_parm){
            tipo                        = item_vinculo_parm.RecordType.DeveloperName;
            arquivar                    = item_vinculo_parm.Arquivar__c;
            quantidade_recebida         = (Integer)item_vinculo_parm.Quantidade_recebida__c;
            quantidade_requisitada      = (Integer)item_vinculo_parm.Quantidade_requisitada__c;
            if(tipo == 'Atender_venda_com_compra'){
                item_venda                  = new ItemVenda(item_vinculo_parm.Item_de_pedido_de_venda__r);
                pedido_venda                = new PedidoVenda(pedidos_venda_id, pedidos_venda_nome, item_vinculo_parm.Item_de_pedido_de_venda__r.Order);                
            }else{
                if(!pedidos_venda_id.contains(null)){
                    pedidos_venda_id.add(null);
                    List<PedidoVendaNome> pedidos_venda_nome_temp = new List<PedidoVendaNome>();
                    pedidos_venda_nome_temp.add(New PedidoVendaNome(new Order()));
                    pedidos_venda_nome_temp.addAll(pedidos_venda_nome);
                    pedidos_venda_nome.clear();
                    pedidos_venda_nome.addAll(pedidos_venda_nome_temp);
                }
            }
        }
    }

    public class ItemVenda {
        public String                   id {get;set;}
        public String                   numero {get;set;}
        public String                   status {get;set;}
        public String                   valor_total {get;set;}
        public String                   valor_unitario {get;set;}
        public Integer                  quantidade_vendida {get;set;}

        public ItemVenda(OrderItem item_venda_parm) {
            id                          = item_venda_parm.Id;
            numero                      = item_venda_parm.OrderItemNumber.right(8);
            status                      = item_venda_parm.Status__c;
            valor_total                 = ListagemPedidosCompra.FormataMoeda('BRL', item_venda_parm.TotalPrice);
            valor_unitario              = ListagemPedidosCompra.FormataMoeda('BRL', item_venda_parm.UnitPrice);
            quantidade_vendida          = (Integer)item_venda_parm.Quantity;
        }
    }

    public class PedidoVenda {
        public String                   id {get;set;}
        public String                   numero {get;set;}
        public String                   status {get;set;}
        public Id                       proprietario_id {get;set;}
        public Id                       cliente_id {get;set;}
        public String                   cliente_nome {get;set;}
        public Id                       faturamento_id {get;set;}
        public String                   faturamento_nome {get;set;}
        public String                   tipo {get;set;}
        public Id                       opp_id {get;set;}
        public String                   opp_numero {get;set;}
        public String                   opp_nome {get;set;}
        public String                   opp_proprietario_id {get;set;}
        public Id                       ot_id {get;set;}
        public String                   ot_numero {get;set;}
        public String                   ot_assunto {get;set;}
        public String                   ot_proprietario_id {get;set;}

        public PedidoVenda(Set<Id> pedidos_venda_id, List<PedidoVendaNome> pedidos_venda_nome, Order pedido_venda_parm) {
            id                          = pedido_venda_parm.Id;
            numero                      = pedido_venda_parm.OrderNumber;
            status                      = pedido_venda_parm.Status;
            proprietario_id             = pedido_venda_parm.OwnerId;
            cliente_id                  = pedido_venda_parm.AccountId;
            cliente_nome                = pedido_venda_parm.Account.Raz_o_Social__c;
            faturamento_id              = pedido_venda_parm.Faturamento_Feito__c;
            faturamento_nome            = pedido_venda_parm.Faturamento_Feito__r.Raz_o_Social__c;
            tipo                        = pedido_venda_parm.Tipo__c;
            opp_id                      = pedido_venda_parm.OpportunityId;
            if(opp_id!=null)
                opp_numero              = pedido_venda_parm.Opportunity.Numero_OP__c.leftPad(8,'0');
            opp_nome                    = pedido_venda_parm.Opportunity.Name;
            opp_proprietario_id         = pedido_venda_parm.Opportunity.OwnerId;
            ot_id                       = pedido_venda_parm.Ordem_de_trabalho__c;
            ot_numero                   = pedido_venda_parm.Ordem_de_trabalho__r.WorkOrderNumber;
            ot_assunto                  = pedido_venda_parm.Ordem_de_trabalho__r.Subject;
            ot_proprietario_id          = pedido_venda_parm.Ordem_de_trabalho__r.OwnerId;
            
            if(!pedidos_venda_id.contains(id)){
                pedidos_venda_id.add(id);
                pedidos_venda_nome.add(New PedidoVendaNome(pedido_venda_parm));
            }
        }
    }
    
    public class PedidoVendaNome {
        public String                   id {get;set;}
        public String                   numero {get;set;}

        public PedidoVendaNome(Order pedido_venda_parm) {
            id                          = pedido_venda_parm.Id;
            numero                      = pedido_venda_parm.OrderNumber;
        }
    }

}