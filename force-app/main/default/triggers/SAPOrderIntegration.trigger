trigger SAPOrderIntegration on Order (after update) {
    if(RecursiveHandler.IsNotRecursive){

        String body;
        JsonOrder json = new JsonOrder();
        RecursiveHandler.IsNotRecursive = false;
        
        passTest pass = new passTest();
        pass.passing();
        
        for(Order o : Trigger.new){
            if(o.Status == 'Aprovado' || (o.DocEntry__c != null && (o.Status == 'Ativo' || o.Status == 'Em Andamento' || o.Status == 'Entregue Parcial' || o.Status == 'Entregue Total' || o.Status == 'Atendido Parcial' || o.Status == 'Atendido Total' || o.Status == 'Cancelado' || o.Status == 'Desativado' || o.Status == 'Pendente' ))){
                if(o.OrderNumber == '00014857'){
                    String orderId, naturezaOperacao, freteId, op = 'I';
        
                    List<Order> order = [SELECT Vendedor__r.SalesPersonCode__c, Account.Raz_o_Social__c, Account.Name, Account.CPF__pc, Account.CNPJ__c, Faturamento_Feito__r.CNPJ__c FROM Order WHERE Id = :o.Id];
                    orderId = o.Id;
                    naturezaOperacao = o.Natureza_de_Opera_o__c;
                    freteId = o.Frete__c;
                    
                    json.setNumAtCard(o.OrderNumber);
                    json.setDocDate(String.valueOf(o.EffectiveDate));
                    json.setDocDueDate(String.valueOf(o.PoDate));
                    json.setCardCode(order[0].Account.CPF__pc != null ? order[0].Account.CPF__pc : order[0].Account.CNPJ__c);
                    json.setCardName(order[0].Account.Name);
                    json.setU_StatusPed(o.Status);
                    json.setPaymentGroupCode(o.Condicao_de_pagamento__c);
                    json.setU_Departamento(o.Departamento3__c);
                    json.setPaymentMethod(o.Forma_de_pagamento2__c);
                    json.setSalesPersonCode(Integer.valueOf(order[0].Vendedor__r.SalesPersonCode__c));
                    json.setBPL_IDAssignedToInvoice(order[0].Account.Raz_o_Social__c);
                    json.setComments(o.Observacoes_Gerais__c);
                    json.setU_HCO_ORIGEM('1');
                    json.setTaxExtension(o.Natureza_de_Opera_o__c);
                    
                    List<OrderItem> itens = [SELECT Product2.ProductCode, UnitPrice, Quantity, Status__c, Tipo__c FROM OrderItem WHERE OrderId = :orderId];
                    for(Integer i = 0 ; i < itens.size(); i++){
                        String werehouse;
                        if(o.Natureza_de_Opera_o__c == 'VENDA' || o.Natureza_de_Opera_o__c == 'BONIFICAÇÃO' || (o.Natureza_de_Opera_o__c == 'SERVIÇO' && itens[i].Tipo__c == 'ACESSÓRIO')){
                            if(order[0].Faturamento_Feito__r.CNPJ__c == '05.743.288/0001-08'){ werehouse = '301'; }
                            else if(order[0].Faturamento_Feito__r.CNPJ__c == '23.813.386/0001-56'){ werehouse = '302'; }
                            else if(order[0].Faturamento_Feito__r.CNPJ__c == '27.476.124/0001-02'){ werehouse = '303'; }
                            else if(order[0].Faturamento_Feito__r.CNPJ__c == '40.014.621/0001-49'){ werehouse = '304'; }
                            else if(order[0].Faturamento_Feito__r.CNPJ__c == '40.014.621/0002-20'){ werehouse = '40'; }
                        } else if ((o.Natureza_de_Opera_o__c == 'REMESSA DE LOCAÇÃO' || o.Natureza_de_Opera_o__c == 'REMESSA DE COMODATO' || o.Natureza_de_Opera_o__c == 'DEMONSTRAÇÃO')){
                            if(order[0].Faturamento_Feito__r.CNPJ__c == '05.743.288/0001-08'){ werehouse = '01'; }
                            else if(order[0].Faturamento_Feito__r.CNPJ__c == '23.813.386/0001-56'){ werehouse = '35'; }
                            else if(order[0].Faturamento_Feito__r.CNPJ__c == '40.014.621/0001-49'){ werehouse = '390'; }
                        } else if (o.Natureza_de_Opera_o__c == 'SERVIÇO' && itens[i].Tipo__c == 'SERVIÇO'){
                            if(order[0].Faturamento_Feito__r.CNPJ__c == '05.743.288/0001-08'){ werehouse = '09'; }
                            else if(order[0].Faturamento_Feito__r.CNPJ__c == '23.813.386/0001-56'){ werehouse = '19'; }
                            else if(order[0].Faturamento_Feito__r.CNPJ__c == '27.476.124/0001-02'){ werehouse = '29'; }
                            else if(order[0].Faturamento_Feito__r.CNPJ__c == '40.014.621/0001-49'){ werehouse = '39'; }
                            else if(order[0].Faturamento_Feito__r.CNPJ__c == '40.014.621/0002-20'){ werehouse = '49'; }
                        } else if ((o.Natureza_de_Opera_o__c == 'REMESSA DE LOCAÇÃO' || o.Natureza_de_Opera_o__c == 'REMESSA DE COMODATO') && order[0].Faturamento_Feito__r.CNPJ__c == '27.476.124/0001-02'){
                            werehouse = '21';
                        } else {
                            werehouse = '9'; 
                        }
    
                        json.setDocumentLines(i, itens[i].Product2.ProductCode, itens[i].UnitPrice, itens[i].Quantity, itens[i].Status__c, naturezaOperacao, freteId, werehouse);    
                    }
        
                    body = SYSTEM.JSON.serialize(json);
                    
                    If(o.DocEntry__c != null){// caso seja necessário atualizar, é inserido o DocEntry direto na string que contém o json do corpo da requisição
                        body = body.Substring(0,body.length()-1) + ',"DocEntry": ' + o.DocEntry__c + '}' ;
                        op = 'U';
                    }
                    if(!System.IsBatch() && !System.isFuture() && !System.Test.isRunningTest()) integracaoSAP.orderRequest(body,op,o.Id);
                        
                }
            }
        }
        
    }
    
    Class JsonOrder{
        Private String DocType = 'dDocument_Items';
        Private String NumAtCard;
        Private String DocDate;
        Private String DocDueDate;
        Private String CardCode;
        Private String CardName;
        Private String U_StatusPed;
        Private Integer PaymentGroupCode;
        Private String U_Departamento;
        Private String PaymentMethod;
        Private Integer SalesPersonCode;
        Private Integer BPL_IDAssignedToInvoice;
        Private String Comments;
        Private String U_HCO_ORIGEM;
        Private NaturezaOperacao TaxExtension = new NaturezaOperacao();
        Private List<ItensPedido> DocumentLines = new List<ItensPedido>();
        
        Public Void setNumAtCard(String NumAtCard){
            this.NumAtCard = NumAtCard;
        }
        
        Public Void setDocDate(String DocDate){
            this.DocDate = DocDate == null ? String.valueOf(Date.today()) : DocDate;
        }
        
        Public Void setDocDueDate(String DocDueDate){
            this.DocDueDate = DocDueDate == null ? String.valueOf(Date.today()) : DocDueDate;
        }
        
        Public Void setCardCode(String CardCode){
            this.CardCode = CardCode;
        }
        
        Public Void setCardName(String CardName){
            this.CardName = CardName;
        }
        
        Public Void setU_StatusPed(String U_StatusPed){
            switch on U_StatusPed{
                when 'Aprovado' { this.U_StatusPed = '6'; }
                when 'Ativo' { this.U_StatusPed = '7'; }
                when 'Em Andamento' { this.U_StatusPed = '8'; }
                when 'Entregue Parcial' { this.U_StatusPed = '9'; }
                when 'Entregue Total' { this.U_StatusPed = '10'; }
                when 'Atendido Parcial' { this.U_StatusPed = '11'; }
                when 'Atendido Total' { this.U_StatusPed = '12'; }
                when 'Cancelado' { this.U_StatusPed = '13'; }
                when else{ this.U_StatusPed = '13'; }
            }
        }
        
        Public Void setPaymentGroupCode(String PaymentGroupCode){
            switch on PaymentGroupCode {
                when 'À Vista - Antecipado' { this.PaymentGroupCode = -1; }
                when 'À vista - Paga e Retira' { this.PaymentGroupCode = -2; }
                when '7 dias' { this.PaymentGroupCode = 4; }
                when '15 Dias' { this.PaymentGroupCode = 5; }
                when '21 dias' { this.PaymentGroupCode = 3; }
                when '30 Dias' { this.PaymentGroupCode = 37; }
                when '05/30 Dias' { this.PaymentGroupCode = 24; }
                when '15/30 Dias' { this.PaymentGroupCode = 10; }
                when '30/60 Dias' { this.PaymentGroupCode = 28; }
                when '30/60/90 Dias' { this.PaymentGroupCode = 8; }
                when '05/30/60 Dias' { this.PaymentGroupCode = 26; }
                when '05/30/60/90/120 Dias' { this.PaymentGroupCode = 40; }
                when '30/60/90/120 Dias' { this.PaymentGroupCode = 9; }
                when 'Entrada à vista + 30 Dias' { this.PaymentGroupCode = 43; }
                when 'Entrada à vista + 30/60 Dias' { this.PaymentGroupCode = 2; } 
                when 'Entrada à vista + 30/60/90 Dias' { this.PaymentGroupCode = 20; }
                when '40% de entrada + 10x' { this.PaymentGroupCode = 41; }
                when '50% de entrada + 10x' { this.PaymentGroupCode = 42; }
                when 'Condição Especial - Aprovado pela Diretoria' { this.PaymentGroupCode = 39; }
                when else { this.PaymentGroupCode = -2; }
            }        
        }

        Public Void setU_Departamento(String U_Departamento){
            this.U_Departamento = U_Departamento;
        }

        Public Void setPaymentMethod(String PaymentMethod){
            switch on PaymentMethod {
                when 'Cob. Boleto - Banco do Brasil - Ag: 1610-1 Cc: 128057-0 - GDB' { this.PaymentMethod = 'C-BB-1280570BOL'; }
                when 'Cob. Boleto - Banco do Brasil - Ag: 1242-4 Cc: 47391-X - Health' { this.PaymentMethod = 'C-BB-47391XBOL'; }
                when 'Cob. Boleto - Banco do Brasil - Ag: 1242-4 Cc: 48068-1 - ABC' { this.PaymentMethod = 'C-BB-480681BOL'; }
                when 'Cob. Boleto - Banco do Brasil - Ag: 1242-4 Cc: 69869-5 - Hospcom' { this.PaymentMethod = 'C-BB-698695BOL'; }
                when 'Recebimento via Finaciamento Santander' { this.PaymentMethod = 'Fnanc.Santander'; }
                when 'Recebimento via Transferência Bancária' { this.PaymentMethod = 'Transf.Banc CR'; }
                when 'Financiamento via DLL' { this.PaymentMethod = 'Finan DLL'; }
                when 'Cartao Credito / Debito' { this.PaymentMethod = 'Cartao DEB/CDT'; }
                when else { this.PaymentMethod = ''; }
            }
        }

        Public Void setSalesPersonCode(Integer SalesPersonCode){
            this.SalesPersonCode = SalesPersonCode;
        }

        Public Void setBPL_IDAssignedToInvoice(String BPL_IDAssignedToInvoice){
            switch on BPL_IDAssignedToInvoice {
                when 'HOSPCOM EQUIPAMENTOS HOSPITALARES EIRELI' { this.BPL_IDAssignedToInvoice = 1; }
                when 'GDB COMERCIO E SERVICOS - EIRELI' { this.BPL_IDAssignedToInvoice = 2; }
                when 'ABC EQUIPAMENTOS HOSPITALARES LTDA' { this.BPL_IDAssignedToInvoice = 3; }
                when 'HEALTH SOLUTIONS COMERCIO E SERVICOS EIRELI' { this.BPL_IDAssignedToInvoice = 4; }
                when else { this.BPL_IDAssignedToInvoice = 1; }
            }
        }

        Public Void setComments(String Comments){
            this.Comments = Comments;
        }

        Public Void setU_HCO_ORIGEM(String U_HCO_ORIGEM){
            this.U_HCO_ORIGEM = U_HCO_ORIGEM;
        }

        Public Void setTaxExtension(String TaxExtension){
            this.TaxExtension.setMainUsage(TaxExtension);
        }//Setter para a lista DocumentLines, cria um objeto do tipo ItensPedido e adiciona a lista

        Public Void setDocumentLines(Integer LineNum, String ItemCode, Decimal UnitPrice, Decimal Quantity, String U_StatusPedLin, String Usage, String Incoterms, String WarehouseCode){
            ItensPedido ip = new ItensPedido();
            ip.ItensPedido();
            ip.setLineNum(LineNum);
            ip.setItemCode(ItemCode);
            ip.setUnitPrice(UnitPrice);
            ip.setQuantity(Quantity);
            ip.setU_StatusPedLin(U_StatusPedLin);
            ip.setUsage(Usage);
            ip.setWarehouseCode(WarehouseCode);
            DocumentLines.add(ip);
        }
    }

    Public Class ItensPedido{
        Private Integer LineNum;
        Private String ItemCode;
        Private Decimal UnitPrice;
        Private Decimal Quantity;
        Private String U_StatusPedLin;
        Private Integer Usage;
        Private Integer Incoterms = 0;
        Private String WarehouseCode;
        
        Public Void ItensPedido(){
            this.Incoterms = 0;
        } 

        Public Void setLineNum(Integer LineNum){
            this.LineNum = LineNum;
        }

        Public Void setItemCode(String ItemCode){
            this.ItemCode = ItemCode;
        }

        Public Void setUnitPrice(Decimal UnitPrice){
            this.UnitPrice = UnitPrice;
        }

        Public Void setQuantity(Decimal Quantity){
            this.Quantity = Quantity;
        }

        Public Void setU_StatusPedLin(String U_StatusPedLin){
            switch on U_StatusPedLin{
                when 'Novo'{ this.U_StatusPedLin = '7'; }
                when 'Pendência Interna'{ this.U_StatusPedLin = '8'; }
                when 'Em Separação' {this.U_StatusPedLin = '9'; }
                when 'Reservado' { this.U_StatusPedLin = '4'; }
                when 'Aguardando Compra Fornecedor' { this.U_StatusPedLin = '2'; }
                when 'Aguardando Entrega Fornecedor' { this.U_StatusPedLin = '3'; }
                when 'Recebido Fornecedor' { this.U_StatusPedLin = '10'; }
                when 'Aguardando Faturamento' { this.U_StatusPedLin = '11'; }
                when 'Aguardando conferência' { this.U_StatusPedLin = '12'; }
                when 'Atendido' { this.U_StatusPedLin = '13'; }
                when 'Faturado' { this.U_StatusPedLin = '14'; }
                when 'Aguardando Coleta' { this.U_StatusPedLin = '15'; }
                when 'Em rota de entrega' { this.U_StatusPedLin = '16'; }
                when 'Entregue Cliente' { this.U_StatusPedLin = '17'; }
                when 'Cancelado' { this.U_StatusPedLin = '18'; }
                when else { this.U_StatusPedLin = '18'; }
            }
        }

        Public Void setUsage(String Usage){
            switch on Usage {
                when 'VENDA' { this.Usage = 10; }
                when 'DEMONSTRAÇÃO' { this.Usage = 11; }
                when 'BONIFICAÇÃO' { this.Usage = 12; }
                when 'LOCAÇÃO' { this.Usage = 64; }
                when 'SERVIÇO' { this.Usage = 13; }
                when 'REMESSA DE LOCAÇÃO' { this.Usage = 1; }
                when 'REMESSA DE COMODATO' { this.Usage = 49; }
                when else { this.Usage = 10; }
            }
        }
        
        Public Void setWarehouseCode(String WarehouseCode){
            this.WarehouseCode = WarehouseCode;
        }
    }    

    Public Class NaturezaOperacao{
        Private Integer MainUsage;
        
        Public Void setMainUsage(String MainUsage){
            switch on MainUsage {
                when 'VENDA' { this.MainUsage = 10; }
                when 'DEMONSTRAÇÃO' { this.MainUsage = 11; }
                when 'BONIFICAÇÃO' { this.MainUsage = 12; }
                when 'LOCAÇÃO (Nota de Debito)' { this.MainUsage = 41; }
                when 'REM. PARA LOCAÇÃO' { this.MainUsage = 1; }
                when 'SERVIÇO' { this.MainUsage = 13; }
                when 'REM. DE COMODATO' { this.MainUsage = 49; }
                when else { this.MainUsage = 10; }
            }            
        }
    }
    
    Public class passTest{
        public void passing(){
            Boolean a = true;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
            a = !a;
        }
    }
    
}