public class AssistenteRecebimentoProduto {

        public Id                                                       registro_pai_id {get;set;}
        public Fornecedor__c                            fornecedor{get;set;}
        public List<ItemCompra>                   itens{get;set;}
        
        public List<String>                               etapa {get;set;}
        public List<String>                                       etapas{get;set;}
        
        public Boolean                                          tem_erros {get;set;}
        public List<String>                               erros {get;set;}
        
        public Boolean                                          tem_requisicoes {get;set;}
        
        public List<RecordType>                           tipos_registro{get;set;}
        public Id                                                       record_estoque_compra;
        public Id                                                       record_venda_compra;
        public Id                                                       record_venda_estoque;
        
        public AssistenteRecebimentoProduto(ApexPages.StandardController controller) {
                Inicializa(controller);
                ObtemDados();
        }
        
        public void Inicializa(ApexPages.StandardController controller){
                registro_pai_id = ((SObject)controller.getRecord()).Id;
                fornecedor = new Fornecedor__c();
                itens = new List<ItemCompra>();
                
                etapa = new List<String>();
                etapas = new List<String>();
                etapas.add('Receber');
                SetaEtapa('receber', 'Insira a quantidade recebida nas requisições dos itens desejados');
                
                tem_erros = false;
                
                tipos_registro = [
                        SELECT  Id, DeveloperName
                        FROM    RecordType
                        WHERE   SObjectType = 'Requisicao_de_item__c'
                ];
                for(RecordType tipo_registro : tipos_registro){
                        if(tipo_registro.DeveloperName == 'Suprir_estoque_com_compra')
                                record_estoque_compra = tipo_registro.Id;
                        else if (tipo_registro.DeveloperName == 'Atender_venda_com_compra')
                                record_venda_compra = tipo_registro.Id;
                        else if (tipo_registro.DeveloperName == 'Atender_venda_com_estoque')
                                record_venda_estoque = tipo_registro.Id;
            else if (tipo_registro.DeveloperName == 'Compra_Total')
                                record_venda_estoque = tipo_registro.Id;
                }
        }
        
        public void SetaEtapa(String nome_etapa, String cabecalho){
                etapa.clear();
                etapa.add(nome_etapa);
                etapa.add(cabecalho);
        }
        
        public void ObtemDados(){
                tem_requisicoes = false;
                
                // fornecedor
                fornecedor = [
                        SELECT  Pedido_de_compra__c, Pedido_de_compra__r.Name, Pedido_de_compra__r.Descricao__c,
                                        Id, Name, Fornecedor__r.Raz_o_Social__c
                        FROM    Fornecedor__c
                        WHERE   Id = :registro_pai_id
                ];
                
                // nova ============================================================
                
                List<Item_de_pedido_de_compra__c> itens_compra = [
                        select      Id, Codigo_do_produto__c, Imagem__c, Nome__c, Modelo__c, Marca__c, 
                                                Quantidade_requisitada__c, Quantidade_recebida__c, (
                                                        SELECT  Id, Quantidade_requisitada__c, Quantidade_recebida__c, Quantidade_direcionada__c, Item_de_pedido_de_venda__c,
                                                                        Item_de_pedido_de_venda__r.OrderItemNumber, Item_de_pedido_de_venda__r.Status__c, 
                                                                        Item_de_pedido_de_venda__r.Order.OrderNumber, Item_de_pedido_de_venda__r.Order.Account.Raz_o_Social__c, 
                                                                        RecordType.DeveloperName, Prazo_de_recebimento__c
                                                        FROM    Requisicoes_de_Itens__r
                                                        WHERE   Quantidade_falta_receber__c > 0
                                                )
                        FROM            Item_de_pedido_de_compra__c
                        WHERE           Pedido_de_compra__c IN (
                                                        SELECT          Pedido_de_compra__c
                                                        FROM            Fornecedor__c
                                                        WHERE           Id = :registro_pai_id
                                                ) AND Id IN (
                                                        SELECT          Item_de_pedido_de_compra__c
                                                        FROM            Item_de_fornecedor__c
                                                        WHERE           Fornecedor__c = :registro_pai_id AND
                                                                                Comprar__c = true
                                                ) AND Quantidade_falta_receber__c > 0
                ];

                for(Item_de_pedido_de_compra__c item_compra : itens_compra){
                        ItemCompra item = new ItemCompra(item_compra);
                        for(Requisicao_de_item__c req_item : item_compra.Requisicoes_de_Itens__r){
                                item.reqs_item.add(new ReqItem(req_item));
                        }
                        itens.add(item);
                }
                
                tem_requisicoes = ((itens.size()>0)?true:false);
                
        }
        
        
        public pageReference Efetiva(){
                
                Savepoint                                       restorepoint            = Database.setSavepoint();
                
                List<CDivide>                             c_divides                       = new List<CDivide>();
                List<CDivide>                             c_divides2                      = new List<CDivide>();
                List<Id>                                  itens_upd_id2           = new List<Id>();
                List<OrderItem>                   itens_upd2                      = new List<OrderItem>();
                
                List<Id>                                          requisicoes_upd_id      = new List<Id>();
                List<Id>                                  itens_upd_id            = new List<Id>();
                List<Requisicao_de_item__c> requisicoes_upd       = new List<Requisicao_de_item__c>();
                List<OrderItem>                   itens_upd                       = new List<OrderItem>();
                
                List<OrderItem>                   itens_add                       = new List<OrderItem>();
                List<Requisicao_de_item__c> requisicoes_add       = new List<Requisicao_de_item__c>();
                
                List<Entrega_de_item__c>  entregas_item           = new List<Entrega_de_item__c>();
                
                // insere normalmente
                List<Recebimento_de_item__c> recebimentos_add     = new List<Recebimento_de_item__c>();
                
                for(ItemCompra item : itens){
                        for(ReqItem req_item : item.reqs_item){
                                if(req_item.receb_item.Quantidade_recebida__c != null || req_item.receb_item.Quantidade_recebida__c >= 1){
                                        if(req_item.receb_item.Data_de_recebimento__c == null)
                                                req_item.receb_item.Data_de_recebimento__c = System.Today();
                                        req_item.receb_item.Requisicao_de_produto__c = req_item.req_item.Id;
                                        recebimentos_add.add(req_item.receb_item);
                                        
                                        // separa itens a dividir...
                                        if(req_item.req_item.RecordType.DeveloperName == 'Atender_venda_com_compra'){
                                                if(req_item.receb_item.Quantidade_recebida__c < req_item.req_item.Quantidade_requisitada__c){
                                                        c_divides.add(new CDivide(
                                                                req_item.req_item.Id,
                                                                req_item.req_item.Item_de_pedido_de_venda__c,
                                                                item.item_compra.Id,
                                                                req_item.req_item.Quantidade_requisitada__c - req_item.receb_item.Quantidade_recebida__c,
                                                                req_item.req_item.Item_de_pedido_de_venda__r.Status__c,
                                                                req_item.req_item.Prazo_de_recebimento__c,
                                                                req_item.receb_item.Quantidade_recebida__c
                                                        ));
                                                }else{
                                                        c_divides2.add(new CDivide(
                                                                null, req_item.req_item.Item_de_pedido_de_venda__c,
                                                                null,null, req_item.req_item.Item_de_pedido_de_venda__r.Status__c, null, 
                                                                req_item.receb_item.Quantidade_recebida__c
                                                        ));
                                                }
                                        }
                                }
                        }
                }
                
                
                // adiciona os recebimentos normalmente -------------------------------
                try {
                        insert recebimentos_add;
                }
                catch (System.DMLException e){
                        ApexPages.addMessages(e);
                }
                
                // itens não divididos ------------------------------------------------
                if(ApexPages.getMessages().size()==0 && c_divides2.size()>0){
                        for(CDivide c_divide2 : c_divides2)
                                itens_upd_id2.add(c_divide2.Id_item);
                        itens_upd2 = [
                                SELECT  Id, Status__c
                                FROM    OrderItem
                                WHERE   Id IN :itens_upd_id2
                        ];
                        for(OrderItem item_upd2 : itens_upd2)
                                for(CDivide c_divide2 : c_divides2)
                                        if(item_upd2.Id == c_divide2.Id_item){
                                                // atualiza itens (status)
                                                item_upd2.Status__c = c_divide2.Sta_new;
                                                // cria entregas, se necesário
                                                if(item_upd2.Status__c == 'Entregue' || item_upd2.Status__c == 'Atendido')
                                                        entregas_item.add(new Entrega_de_item__c(
                                                                Quantidade_entregue__c = c_divide2.Qtd_rec,
                                                                Item_de_pedido_de_venda__c = item_upd2.Id,
                                                                Data_de_entrega__c = System.Today()
                                                        )); 
                                        }
                        try {
                                update itens_upd2;
                        }catch (System.DMLException e){
                                ApexPages.addMessages(e);
                        }
                        
                }
                
                
                // itens divididos ----------------------------------------------------
                for(CDivide c_divide : c_divides){
                        requisicoes_upd_id.add(c_divide.Id_req);
                        itens_upd_id.add(c_divide.Id_item);
                }
                requisicoes_upd = [
                        SELECT  Id, Quantidade_requisitada__c, Item_de_pedido_de_venda__c, Item_de_pedido_de_compra__c
                        FROM    Requisicao_de_item__c
                        WHERE   Id IN :requisicoes_upd_id
                ];
                for(Requisicao_de_item__c requisicao_upd : requisicoes_upd)
                        for(CDivide c_divide : c_divides)
                                if(requisicao_upd.Id == c_divide.Id_req)
                                        // atualiza requisições (qtd)
                                        requisicao_upd.Quantidade_requisitada__c = requisicao_upd.Quantidade_requisitada__c - c_divide.Qtd_dif;
                try {
                        update requisicoes_upd;
                }catch (System.DMLException e){
                        ApexPages.addMessages(e);
                }
                
                itens_upd = [
                        SELECT  Id, Quantity, Status__c, Descricao_da_linha__c, UnitPrice, PricebookEntryId, OrderId
                        FROM    OrderItem
                        WHERE   Id IN :itens_upd_id
                ];
                for(OrderItem item_upd : itens_upd)
                        for(CDivide c_divide : c_divides)
                                if(item_upd.Id == c_divide.Id_item){
                                        // atualiza itens (qtd + status)
                                        item_upd.Quantity = item_upd.Quantity - c_divide.Qtd_dif;
                                        item_upd.Status__c = c_divide.Sta_new;
                                        // cria entregas, se necesário
                                        if(item_upd.Status__c == 'Entregue' || item_upd.Status__c == 'Atendido')
                                                entregas_item.add(new Entrega_de_item__c(
                                                        Quantidade_entregue__c = c_divide.Qtd_rec,
                                                        Item_de_pedido_de_venda__c = item_upd.Id,
                                                        Data_de_entrega__c = System.Today()
                                                ));
                                        
                                        // clona itens (!= qtd + status)
                                        itens_add.add(new OrderItem(
                                                OrderId = item_upd.OrderId,
                                                PricebookEntryId = item_upd.PricebookEntryId,
                                                Status__c = 'Aguardando Entrega Fornecedor',
                                                Quantity = c_divide.Qtd_dif,
                                                UnitPrice = item_upd.UnitPrice,
                                                Descricao_da_linha__c = item_upd.Descricao_da_linha__c
                                        ));
                                }
                try {
                        update itens_upd;
                }catch (System.DMLException e){
                        ApexPages.addMessages(e);
                }
                
                try {
                        insert entregas_item;
                }catch (System.DMLException e){
                        ApexPages.addMessages(e);
                }
                
                try {
                        insert itens_add;
                }catch (System.DMLException e){
                        ApexPages.addMessages(e);
                }       
                
                Integer cont=0;
                for(CDivide c_divide : c_divides){
                        requisicoes_add.add(new Requisicao_de_item__c(
                                RecordTypeId = record_venda_compra,
                Nao_acionar_trigger__c = 'nao acionar',
                                Comprar__c = true,
                                Prazo_de_recebimento__c = c_divide.prazo,
                                Data_de_requisicao__c = System.Today(),
                                Item_de_pedido_de_venda__c = itens_add[cont].Id, // perigo
                                Item_de_pedido_de_compra__c = c_divide.Id_itemc,
                                Quantidade_requisitada__c = c_divide.Qtd_dif
                        ));
                        cont++;
                }
                try {
                        insert requisicoes_add;
                }
                catch (System.DMLException e){
                        ApexPages.addMessages(e);
                }
                
                PreparaErros();
                if(tem_erros){
                        Database.rollback(restorepoint);
                        return null;
                }
                else{
                        PageReference tempPage = ApexPages.currentPage();            
                        tempPage.setRedirect(true);
                        return tempPage;
                }
        }
        
        
        public pageReference RetornarRegistro(){
                return new PageReference('/' + String.valueOf(fornecedor.Id));
        }
        
        public void PreparaErros(){
                tem_erros = ((ApexPages.getMessages().size()>0)?true:false);
        if(tem_erros){
            erros = new List<String>();
            for(Apexpages.Message mensagem: ApexPages.getMessages())
                erros.add(mensagem.getDetail());
        }
        }
        
        public class CRecebimentoDeItem {
                public Requisicao_de_item__c            requisicao_item         {get;set;}
                public Recebimento_de_item__c           recebimento_item        {get;set;}
                
                public CRecebimentoDeItem(Requisicao_de_item__c requisicao_item_parm, Recebimento_de_item__c recebimento_item_parm) {
                        requisicao_item         = requisicao_item_parm;
                        recebimento_item        = recebimento_item_parm;
                }
        }
        
        public class ItemCompra{
                public Item_de_pedido_de_compra__c item_compra {get;set;}
                public List<ReqItem> reqs_item {get;set;}
                
                public ItemCompra(Item_de_pedido_de_compra__c item_compra) {
                        this.item_compra = item_compra;
                        reqs_item = new List<ReqItem>();
                }
        }
        
        public class ReqItem{
                public Requisicao_de_item__c req_item {get;set;}
                public Recebimento_de_item__c receb_item {get;set;}
                
                public ReqItem(Requisicao_de_item__c req_item) {
                        this.req_item = req_item;
                        receb_item      = new Recebimento_de_item__c();
                }
                
        }
        
        public class CDivide{
                public Id               Id_req  {get;set;}
                public Id               Id_item {get;set;}
                public Id               Id_itemc{get;set;}
                public Decimal  Qtd_dif {get;set;}
                public String   Sta_new {get;set;}
                public Date     prazo   {get;set;}
                public Decimal  Qtd_rec {get;set;}
                
                public CDivide(Id Id_req_parm, Id Id_item_parm, Id Id_itemc_parm, Decimal Qtd_dif_parm, String Sta_new_parm, Date prazo_parm, Decimal Qtd_rec_parm) {
                        Id_req  = Id_req_parm;
                        Id_item = Id_item_parm;
                        Id_itemc = Id_itemc_parm;
                        Qtd_dif = Qtd_dif_parm;
                        Sta_new = Sta_new_parm;
                        prazo = prazo_parm;
                        Qtd_rec = Qtd_rec_parm;
                }
        }
        
}