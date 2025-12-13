public with sharing class ListagemPedidosVenda {

    public List<CPedido> c_pedidos {get;set;}
    public CValor c_valor {get;set;}
    public CFiltro c_filtro {get;set;}
    public CPaginacao c_paginacao {get;set;}
    public CMensagem c_mensagem {get;set;}

    public ListagemPedidosVenda() {
        Inicializa();
        NovaPesquisa();
    }

    public void Inicializa(){
        c_pedidos = new List<CPedido>();

        c_valor = new CValor();
        c_valor.pedido_tipo_pais.add(new SelectOption('', '-- Nenhum --'));
        c_valor.pedido_tipo_pais.add(new SelectOption('OPP', 'OPP'));
        c_valor.pedido_tipo_pais.add(new SelectOption('OT', 'OT'));
        c_valor.pedido_tipos.add(new SelectOption('', '-- Nenhum --'));
        c_valor.pedido_tipos.add(new SelectOption('Comercial', 'Comercial'));
        c_valor.pedido_tipos.add(new SelectOption('Governo', 'Governo'));
        c_valor.pedido_tipos.add(new SelectOption('Serviço', 'Serviço'));
        
        c_valor.pedido_estados.add(new SelectOption('', '-- Nenhum --'));
        Schema.DescribeFieldResult estados = Account.BillingStateCode.getDescribe();
        for(Schema.PicklistEntry estado : estados.getPicklistValues())
            c_valor.pedido_estados.add(new SelectOption(estado.getLabel(),estado.getLabel()));
        
        c_valor.pedido_status.add(new SelectOption('', '-- Nenhum --'));
        for(Schema.PicklistEntry status : Order.Status.getDescribe().getPicklistValues())
            c_valor.pedido_status.add(new SelectOption(status.getLabel(),status.getLabel()));
        c_valor.pedido_fretes.add(new SelectOption('', '-- Nenhum --'));
        for(Schema.PicklistEntry frete : Order.Tipo_de_frete__c.getDescribe().getPicklistValues())
            c_valor.pedido_fretes.add(new SelectOption(frete.getLabel(),frete.getLabel()));
        c_valor.pedido_entregas.add(new SelectOption('', '-- Nenhum --'));
        for(Schema.PicklistEntry entrega : Order.Entrega_parcial__c.getDescribe().getPicklistValues())
            c_valor.pedido_entregas.add(new SelectOption(entrega.getLabel(),entrega.getLabel()));
        c_valor.pedido_proprietarios.add(new SelectOption('', '-- Nenhum --'));
        for(User usuario : [SELECT Id, Name FROM User WHERE (IsActive = true) AND (UserType IN ('PowerPartner','Standard')) AND (NOT Name LIKE '%(desativado)%') ORDER BY Name])
            c_valor.pedido_proprietarios.add(new SelectOption(usuario.Id, usuario.Name));
        c_valor.item_status.add(new SelectOption('', '-- Nenhum --'));
        for(Schema.PicklistEntry status : OrderItem.Status__c.getDescribe().getPicklistValues())
            c_valor.item_status.add(new SelectOption(status.getLabel(),status.getLabel()));
        c_valor.item_marcas.add(new SelectOption('', '-- Nenhum --'));
        for(Schema.PicklistEntry marca : Product2.Marca__c.getDescribe().getPicklistValues())
            c_valor.item_marcas.add(new SelectOption(marca.getLabel(),marca.getLabel()));
        c_valor.item_familias.add(new SelectOption('', '-- Nenhum --'));
        for(Schema.PicklistEntry familia : Product2.Family.getDescribe().getPicklistValues())
            c_valor.item_familias.add(new SelectOption(familia.getLabel(),familia.getLabel()));
        c_valor.item_tipos.add(new SelectOption('', '-- Nenhum --'));
        for(Schema.PicklistEntry tipo : Product2.Tipo_do_Produto__c.getDescribe().getPicklistValues())
            c_valor.item_tipos.add(new SelectOption(tipo.getLabel(),tipo.getLabel()));

        c_filtro = new CFiltro();
        c_paginacao = new CPaginacao();
        c_mensagem = new CMensagem();
    }

    public void Pesquisa(){
        Integer sql_offset = (c_paginacao.pagina_atual-1)*(c_paginacao.registro_pagina);
        String sql_where_global, sql_where_local;
        List<String> sql_where_pedidos = new List<String>();
        List<String> sql_where_itens = new List<String>();
        String sql_where_pedidos_global = '';

        String sql_query =
            'SELECT     Id, OrderNumber, EffectiveDate, Prazo_de_entrega__c, EndDate, Status, TotalAmount, Faturado__c, OpportunityId,      ' +
            '           Faturamento_feito__r.Raz_o_Social__c, AccountId, Account.BillingState, Account.BillingCity, Owner.Name,             ' +
            '           Opportunity.Owner.Name, Opportunity.Numero_OP__c, Ordem_de_trabalho__c, Ordem_de_trabalho__r.Owner.Name,            ' +
            '           Ordem_de_trabalho__r.WorkOrderNumber, Account.Name,                                                                 ' +
            '           (                                                                                                                   ' +
            '               SELECT      Id, Status__c, Descricao_da_linha__c, Quantity, UnitPrice, TotalPrice, Item__c, Item_pai__c,        ' +
            '                           PriceBookEntry.Product2.Name,  PriceBookEntry.Product2.Marca__c, PriceBookEntry.Product2.Modelo__c, ' +
            '                           PriceBookEntry.Product2.URL_da_Imagem__c, Quantidade_entregue__c, PriceBookEntry.Product2.Id,       ' +
            '                           PricebookEntry.ProductCode                                                                          ' +
            '               FROM        Order.OrderItems                                                                                    ' +
            '               [sql_where_local]                                                                                               ' +
            '               ORDER BY    Item__c ASC, Item_pai__c ASC                                                                        ' +
            '           )                                                                                                                   ' +
            'FROM       Order                                                                                                               ' +
            '[sql_where_global]                                                                                                             ' +
            'ORDER BY   Order.Ordernumber                                                                                                   ' +
            'LIMIT      '+c_paginacao.registro_pagina+'                                                                                     ' +
            'OFFSET     '+sql_offset+'                                                                                                      ';

        if(c_filtro.pedido_numero != null && c_filtro.pedido_numero != '')
            sql_where_pedidos.add('OrderNumber = \''+ c_filtro.pedido_numero.leftPad(8,'0')+'\'');
        if(c_filtro.pedido_cliente != null && c_filtro.pedido_cliente != ''){
            sql_where_pedidos.add(
                '( ' +
                    'Account.Name LIKE \'%'+c_filtro.pedido_cliente+'%\' OR '+
                    'Account.Raz_o_Social__c LIKE \'%'+c_filtro.pedido_cliente+'%\' OR '+
                    'Account.CNPJ__c LIKE \'%'+c_filtro.pedido_cliente+'%\' '+
                ' )'
            );
        }
        if(c_filtro.pedido_numero_pai != null && c_filtro.pedido_numero_pai != ''){
            if(c_filtro.pedido_tipo_pai == 'OPP'){
                sql_where_pedidos.add('Opportunity.Numero_OP__c = \''+c_filtro.pedido_numero_pai+'\'');
            }else if (c_filtro.pedido_tipo_pai == 'OT'){
                sql_where_pedidos.add('Ordem_de_trabalho__r.WorkOrderNumber = \''+c_filtro.pedido_numero_pai.leftPad(8,'0')+'\'');
            }
        }
        
        for(Integer cont = c_filtro.pedido_estado.size()-1; cont >= 0; cont--)
            if(c_filtro.pedido_estado[cont] == '' || c_filtro.pedido_estado[cont] == null)
                c_filtro.pedido_estado.remove(cont);
            else
                c_filtro.pedido_estado[cont] = '\''+c_filtro.pedido_estado[cont]+'\'';
        if(c_filtro.pedido_estado.size()>0)
            sql_where_pedidos.add('Account.BillingState IN ('+String.join(c_filtro.pedido_estado, ',')+')');
        
        for(Integer cont = c_filtro.pedido_tipo.size()-1; cont >= 0; cont--)
            if(c_filtro.pedido_tipo[cont] == '' || c_filtro.pedido_tipo[cont] == null)
                c_filtro.pedido_tipo.remove(cont);
            else
                c_filtro.pedido_tipo[cont] = '\''+c_filtro.pedido_tipo[cont]+'\'';
        if(c_filtro.pedido_tipo.size()>0)
            sql_where_pedidos.add('Tipo__c IN ('+String.join(c_filtro.pedido_tipo, ',')+')');
        for(Integer cont = c_filtro.pedido_status.size()-1; cont >= 0; cont--)
            if(c_filtro.pedido_status[cont] == '' || c_filtro.pedido_status[cont] == null)
                c_filtro.pedido_status.remove(cont);
            else
                c_filtro.pedido_status[cont] = '\''+c_filtro.pedido_status[cont]+'\'';
        if(c_filtro.pedido_status.size()>0)
            sql_where_pedidos.add('Status IN ('+String.join(c_filtro.pedido_status, ',')+')');
        if(c_filtro.pedido_frete != null && c_filtro.pedido_frete != '')
            sql_where_pedidos.add('Tipo_de_frete__c = \''+c_filtro.pedido_frete+'\'');
        if(c_filtro.pedido_entrega != null && c_filtro.pedido_entrega != '')
            sql_where_pedidos.add('Entrega_parcial__c = \''+c_filtro.pedido_entrega+'\'');
        for(Integer cont = c_filtro.pedido_proprietario.size()-1; cont >= 0; cont--)
            if(c_filtro.pedido_proprietario[cont] == '' || c_filtro.pedido_proprietario[cont] == null)
                c_filtro.pedido_proprietario.remove(cont);
            else
                c_filtro.pedido_proprietario[cont] = '\''+c_filtro.pedido_proprietario[cont]+'\'';
        if(c_filtro.pedido_proprietario.size()>0)
            sql_where_pedidos.add('OwnerId IN ('+String.join(c_filtro.pedido_proprietario, ',')+')');
        if(c_filtro.pedido_global != null && c_filtro.pedido_global != ''){
            sql_where_pedidos_global = 
                'OrderNumber                            =       \'' +c_filtro.pedido_global.leftPad(8,'0')+'\'  OR '+
                'Account.Name                           LIKE    \'%'+c_filtro.pedido_global+'%\'                OR '+
                'Account.Raz_o_Social__c                LIKE    \'%'+c_filtro.pedido_global+'%\'                OR '+
                'Account.CNPJ__c                        LIKE    \'%'+c_filtro.pedido_global+'%\'                OR '+
                'Opportunity.Numero_OP__c               =       \'' +c_filtro.pedido_global+'\'                 OR '+
                'Ordem_de_trabalho__r.WorkOrderNumber   =       \'' +c_filtro.pedido_global.leftPad(8,'0')+'\'  OR '+
                'Tipo__c                                LIKE    \'%'+c_filtro.pedido_global+'%\'                OR '+
                'Status                                 LIKE    \'%'+c_filtro.pedido_global+'%\'                OR '+
                'Tipo_de_frete__c                       LIKE    \'%'+c_filtro.pedido_global+'%\'                OR '+
                'Entrega_parcial__c                     LIKE    \'%'+c_filtro.pedido_global+'%\'                OR '+
                'Owner.Name                             LIKE    \'%'+c_filtro.pedido_global+'%\' ';
        }

        if(c_filtro.item_codigo != null && c_filtro.item_codigo != '')
            sql_where_itens.add('PriceBookEntry.Product2.ProductCode LIKE \'%'+c_filtro.item_codigo+'%\'');
        if(c_filtro.item_nome != null && c_filtro.item_nome != '')
            sql_where_itens.add('PriceBookEntry.Product2.Name LIKE \'%'+c_filtro.item_nome+'%\'');
        if(c_filtro.item_modelo != null && c_filtro.item_modelo != '')
            sql_where_itens.add('PriceBookEntry.Product2.Modelo__c LIKE \'%'+c_filtro.item_modelo+'%\'');
        for(Integer cont = c_filtro.item_status.size()-1; cont >= 0; cont--)
            if(c_filtro.item_status[cont] == '' || c_filtro.item_status[cont] == null)
                c_filtro.item_status.remove(cont);
            else
                c_filtro.item_status[cont] = '\''+c_filtro.item_status[cont]+'\'';
        if(c_filtro.item_status.size()>0)
            sql_where_itens.add('Status__c IN ('+String.join(c_filtro.item_status, ',')+')');
        for(Integer cont = c_filtro.item_marca.size()-1; cont >= 0; cont--)
            if(c_filtro.item_marca[cont] == '' || c_filtro.item_marca[cont] == null)
                c_filtro.item_marca.remove(cont);
            else
                c_filtro.item_marca[cont] = '\''+c_filtro.item_marca[cont]+'\'';
        if(c_filtro.item_marca.size()>0)
            sql_where_itens.add('PriceBookEntry.Product2.Marca__c IN ('+String.join(c_filtro.item_marca, ',')+')');
        for(Integer cont = c_filtro.item_familia.size()-1; cont >= 0; cont--)
            if(c_filtro.item_familia[cont] == '' || c_filtro.item_familia[cont] == null)
                c_filtro.item_familia.remove(cont);
            else
                c_filtro.item_familia[cont] = '\''+c_filtro.item_familia[cont]+'\'';
        if(c_filtro.item_familia.size()>0)
            sql_where_itens.add('PriceBookEntry.Product2.Family IN ('+String.join(c_filtro.item_familia, ',')+')');
        for(Integer cont = c_filtro.item_tipo.size()-1; cont >= 0; cont--)
            if(c_filtro.item_tipo[cont] == '' || c_filtro.item_tipo[cont] == null)
                c_filtro.item_tipo.remove(cont);
            else
                c_filtro.item_tipo[cont] = '\''+c_filtro.item_tipo[cont]+'\'';
        if(c_filtro.item_tipo.size()>0)
            sql_where_itens.add('PriceBookEntry.Product2.Tipo_do_Produto__c IN ('+String.join(c_filtro.item_tipo, ',')+')');

        // monta where item
        if(sql_where_itens.size() > 0){
            sql_where_local = String.join(sql_where_itens, ' AND ');
            sql_where_pedidos.add('Order.Id IN (SELECT OrderId FROM OrderItem WHERE '+sql_where_local+')');
        }

        // monta where pedido
        List<String> sql_where_pedidos_temp = new List<String>();
        if(sql_where_pedidos.size() > 0)
            sql_where_pedidos_temp.add('('+String.join(sql_where_pedidos, ' AND ')+')');
        if(c_filtro.pedido_global != null && c_filtro.pedido_global != '')
            sql_where_pedidos_temp.add('('+sql_where_pedidos_global+')');
        if(sql_where_pedidos_temp.size()>0)
            sql_where_global = String.join(sql_where_pedidos_temp, ' AND ');

        sql_query = sql_query.replace('[sql_where_local]',((sql_where_local!=null && c_filtro.filtrar_itens==true)?' WHERE '+sql_where_local:''));
        sql_query = sql_query.replace('[sql_where_global]',((sql_where_global!=null)?' WHERE '+sql_where_global:''));

        List<Order> pedidos = Database.query(sql_query);

        Set<Id> proprietarios_id = new Set<Id>();
        c_pedidos.clear();


        // trata "descrição" e "estado", "agrupa" itens, "ordena" itens, add na lista GUI

        for(Order pedido : pedidos){
            for(Orderitem item : pedido.Orderitems)
                if(item.Descricao_da_linha__c != null && item.Descricao_da_linha__c.length() > 250)
                    item.Descricao_da_linha__c = item.Descricao_da_linha__c.substring(0, 249) + '...';
            pedido.Account.BillingState = ConverteEstado(pedido.Account.BillingState);


            // AGRUPA ITENS ---------------------------------------------------
            List<OrderItem> itens_new = new List<OrderItem>();

            // percorre lista original
            for(Integer cont = pedido.OrderItems.size()-1; cont >= 0; cont--){
                Boolean inclui = true;
                pedido.OrderItems[cont].Quantidade_entregue__c = 0;
                pedido.OrderItems[cont].Total_acumulado__c = pedido.OrderItems[cont].TotalPrice;

                // percorre lista nova
                for(OrderItem item_new : itens_new){

                    // se achou mesmo item na lista nova: soma/inclui na nova
                    if(pedido.OrderItems[cont].PriceBookEntry.Product2Id == item_new.PriceBookEntry.Product2Id){
                        inclui = false;
                        if((item_new.Item__c!=null || item_new.Item_pai__c!=null) && 
                           (pedido.OrderItems[cont].Item__c!=null || pedido.OrderItems[cont].Item_pai__c!=null)){
                            if(pedido.OrderItems[cont].Status__c == 'Entregue' || pedido.OrderItems[cont].Status__c == 'Atendido' )
                                pedido.OrderItems[cont].Quantidade_entregue__c = pedido.OrderItems[cont].Quantity;
                            else
                                pedido.OrderItems[cont].Quantidade_entregue__c = 0;
                            itens_new.add(pedido.OrderItems[cont]);
                        }
                        else if((item_new.Item__c==null && item_new.Item_pai__c==null) && 
                                (pedido.OrderItems[cont].Item__c!=null || pedido.OrderItems[cont].Item_pai__c!=null)){
                            item_new.Total_acumulado__c += pedido.OrderItems[cont].Total_acumulado__c;
                            item_new.Quantity += pedido.OrderItems[cont].Quantity;
                            if(pedido.OrderItems[cont].Status__c == 'Entregue' || pedido.OrderItems[cont].Status__c == 'Atendido' ){
                                item_new.Quantidade_entregue__c += pedido.OrderItems[cont].Quantity;
                            }else{
                                if(item_new.Status__c == 'Entregue' || item_new.Status__c == 'Atendido' )
                                    item_new.Status__c = pedido.OrderItems[cont].Status__c;
                            }
                            item_new.Item__c =     pedido.OrderItems[cont].Item__c;
                            item_new.Item_pai__c = pedido.OrderItems[cont].Item_pai__c;
                        }
                        else if(pedido.OrderItems[cont].Item__c==null && pedido.OrderItems[cont].Item_pai__c==null){
                            item_new.Total_acumulado__c += pedido.OrderItems[cont].Total_acumulado__c;
                            item_new.Quantity += pedido.OrderItems[cont].Quantity;
                            if(pedido.OrderItems[cont].Status__c == 'Entregue' || pedido.OrderItems[cont].Status__c == 'Atendido' ){
                                item_new.Quantidade_entregue__c += pedido.OrderItems[cont].Quantity;
                            }else{
                                if(item_new.Status__c == 'Entregue' || item_new.Status__c == 'Atendido' )
                                    item_new.Status__c = pedido.OrderItems[cont].Status__c;
                            }
                        }
                        break;
                    }
                }
                if(inclui){
                    if(pedido.OrderItems[cont].Status__c == 'Entregue' || pedido.OrderItems[cont].Status__c == 'Atendido' )
                        pedido.OrderItems[cont].Quantidade_entregue__c = pedido.OrderItems[cont].Quantity;
                    else
                        pedido.OrderItems[cont].Quantidade_entregue__c = 0;
                    itens_new.add(pedido.OrderItems[cont]);
                }
            }
            for(OrderItem item_old : pedido.OrderItems){
                Boolean ignora = true;
                for(OrderItem item_new : itens_new){
                    if(item_old.Id == item_new.Id){
                        ignora = false;
                        item_old = item_new;
                    }
                }
                if(ignora){
                    item_old.Id = null;
                }
            }


            // ORDENA ITENS ---------------------------------------------------
            itens_new.clear();
            List<Id> itens_add = new List<Id>();

            for(OrderItem item : pedido.OrderItems){

                // é item pai
                if(item.Item__c != null && item.Item_pai__c == null && item.id!=null){
                    // add pai na lista
                    itens_new.add(item);
                    itens_add.add(item.id);

                    // procura por filho
                    for(OrderItem item2 : pedido.OrderItems){
                        // é item filho
                        if(item.Item__c == item2.Item_pai__c && item2.id!=null){
                            // add filho na lista
                            itens_new.add(item2);
                            itens_add.add(item2.id);
                        }
                    }
                }
            }
            // adiciona os demais
            
            System.Debug(LoggingLevel.INFO, itens_add);
            
            for(OrderItem item : pedido.OrderItems){
                if(item.id!=null && itens_add.contains(item.Id)==false){
                    itens_new.add(item);
                }
            }

            // numera a ordem na lista original
            Integer ordem = 1;
            for(OrderItem item : itens_new){
                for(OrderItem item2 : pedido.OrderItems){
                    if(item.id == item2.id){
                        item2.ordem__c = ordem;
                    }
                }
                ordem++;
            }


            // ----------------------------------------------------------------

            c_pedidos.add(new CPedido(pedido));

            proprietarios_id.add(pedido.OwnerId);
            if(pedido.Opportunity.OwnerId != null)
                proprietarios_id.add(pedido.Opportunity.OwnerId);
            else if(pedido.Ordem_de_trabalho__r.OwnerId != null)
                proprietarios_id.add(pedido.Ordem_de_trabalho__r.OwnerId);
        }

        List<User> proprietarios = [
            SELECT  Id, SmallPhotoUrl
            FROM    User
            WHERE   Id IN :proprietarios_id
        ];

        // add "proprietários"
        for(CPedido c_pedido : c_pedidos)
            for(User proprietario : proprietarios){
                if(c_pedido.pedido.OwnerId == proprietario.Id){
                    c_pedido.proprietario_foto = proprietario.SmallPhotoUrl;
                }
                if(c_pedido.pedido.Opportunity.OwnerId == proprietario.Id){
                    c_pedido.proprietario_pai_foto = proprietario.SmallPhotoUrl;
                }else if(c_pedido.pedido.Ordem_de_trabalho__r.OwnerId == proprietario.Id){
                    c_pedido.proprietario_pai_foto = proprietario.SmallPhotoUrl;
                }
            }

        // contagem de registros
        String sql_query_count = 'SELECT COUNT() FROM Order [sql_where_global]';
        sql_query_count = sql_query_count.replace('[sql_where_global]',((sql_where_global!=null)?' WHERE '+sql_where_global:''));
        c_paginacao.registro_total = database.countQuery(sql_query_count);
        c_paginacao.pagina_final = (Integer)((c_paginacao.registro_total/(Decimal)c_paginacao.registro_pagina).round(System.RoundingMode.UP));
    }

    public String ConverteEstado(String estado){
        if     (estado == 'Acre')                estado = 'AC';
        else if(estado == 'Alagoas')             estado = 'AL';
        else if(estado == 'Amapá')               estado = 'AP';
        else if(estado == 'Amazonas')            estado = 'AM';
        else if(estado == 'Bahia')               estado = 'BA';
        else if(estado == 'Ceará')               estado = 'CE';
        else if(estado == 'Distrito Federal')    estado = 'DF';
        else if(estado == 'Espírito Santo')      estado = 'ES';
        else if(estado == 'Goiás')               estado = 'GO';
        else if(estado == 'Maranhão')            estado = 'MA';
        else if(estado == 'Mato Grosso')         estado = 'MT';
        else if(estado == 'Mato Grosso do Sul')  estado = 'MS';
        else if(estado == 'Minas Gerais')        estado = 'MG';
        else if(estado == 'Pará')                estado = 'PA';
        else if(estado == 'Paraíba')             estado = 'PB';
        else if(estado == 'Paraná')              estado = 'PR';
        else if(estado == 'Pernambuco')          estado = 'PE';
        else if(estado == 'Piauí')               estado = 'PI';
        else if(estado == 'Rio de Janeiro')      estado = 'RJ';
        else if(estado == 'Rio Grande do Norte') estado = 'RN';
        else if(estado == 'Rio Grande do Sul')   estado = 'RS';
        else if(estado == 'Rondônia')            estado = 'RO';
        else if(estado == 'Roraima')             estado = 'RR';
        else if(estado == 'Santa Catarina')      estado = 'SC';
        else if(estado == 'São Paulo')           estado = 'SP';
        else if(estado == 'Sergipe')             estado = 'SE';
        else if(estado == 'Tocantins')           estado = 'TO';

        return estado;
    }

    public void Mensagens(){
        c_mensagem.tem_mensagem = ((ApexPages.getMessages().size()>0)?true:false);
        if(c_mensagem.tem_mensagem)
            for(Apexpages.Message mensagem: ApexPages.getMessages())
                c_mensagem.mensagens.add(mensagem.getDetail());
    }


    public void NovaPesquisa(){
        c_paginacao.pagina_atual = 1;
        Pesquisa();
        Mensagens();
    }

    public void PaginaAnterior(){
        c_paginacao.pagina_atual = c_paginacao.pagina_atual-1;
        Pesquisa();
    }

    public void PaginaSeguinte(){
        c_paginacao.pagina_atual = c_paginacao.pagina_atual+1;
        Pesquisa();
    }

    public class CPedido {
        public Order pedido {get;set;}
        public String proprietario_foto {get;set;}
        public String proprietario_pai_foto {get;set;}

        public CPedido(Order pedido_parm) {
            pedido = pedido_parm;
            proprietario_foto = null;
            proprietario_pai_foto = null;
        }
    }

    public class CValor {
        public List<SelectOption> pedido_tipo_pais {get;set;}
        public List<SelectOption> pedido_tipos {get;set;}
        public List<SelectOption> pedido_estados {get;set;}
        public List<SelectOption> pedido_status {get;set;}
        public List<SelectOption> pedido_fretes {get;set;}
        public List<SelectOption> pedido_entregas {get;set;}
        public List<SelectOption> pedido_proprietarios {get;set;}

        public List<SelectOption> item_status {get;set;}
        public List<SelectOption> item_marcas {get;set;}
        public List<SelectOption> item_familias {get;set;}
        public List<SelectOption> item_tipos {get;set;}

        public Date               hoje {get;set;}

        public CValor() {
            pedido_tipo_pais = new List<SelectOption>();
            pedido_tipos = new List<SelectOption>();
            pedido_estados = new List<SelectOption>();
            pedido_status = new List<SelectOption>();
            pedido_fretes = new List<SelectOption>();
            pedido_entregas = new List<SelectOption>();
            pedido_proprietarios = new List<SelectOption>();
            item_status = new List<SelectOption>();
            item_marcas = new List<SelectOption>();
            item_familias = new List<SelectOption>();
            item_tipos = new List<SelectOption>();
            hoje = System.Today();
        }
    }

    public class CFiltro {
        public String pedido_global {get;set;}
        public String pedido_numero {get;set;}
        public String pedido_cliente {get;set;}
        public String pedido_tipo_pai {get;set;}
        public String pedido_numero_pai {get;set;}
        public String[] pedido_tipo {get;set;} 
        public String[] pedido_estado {get;set;} 
        public String[] pedido_status {get;set;}
        public String pedido_frete {get;set;}
        public String pedido_entrega {get;set;}
        public String[] pedido_proprietario {get;set;}  

        public String item_codigo {get;set;}
        public String item_nome {get;set;}
        public String item_modelo {get;set;}
        public String[] item_status {get;set;}
        public String[] item_marca {get;set;}
        public String[] item_familia {get;set;}
        public String[] item_tipo {get;set;}

        public Boolean manter_itens {get;set;}
        public Boolean filtrar_itens {get;set;}

        public CFiltro() {
            pedido_tipo = new String[]{};
            pedido_estado = new String[]{};
            pedido_status = new String[]{};
            pedido_proprietario = new String[]{};
            item_status = new String[]{};
            item_marca = new String[]{};
            item_familia = new String[]{};
            item_tipo = new String[]{};
            manter_itens = true;
            filtrar_itens = false;
        }
    }

    public class CPaginacao {
        public Integer pagina_atual {get;set;}
        public Integer pagina_final {get;set;}
        public Integer registro_total {get;set;}
        public Integer registro_pagina {get;set;}

        public CPaginacao() {
            pagina_atual = 0;
            pagina_final = 0;
            registro_total = 0;
            registro_pagina = 7;
        }
    }

    public class CMensagem {
        public Boolean tem_mensagem {get;set;}
        public List<String> mensagens {get;set;}

        public CMensagem() {
            tem_mensagem = false;
            mensagens = new List<String>();
        }
    }


}