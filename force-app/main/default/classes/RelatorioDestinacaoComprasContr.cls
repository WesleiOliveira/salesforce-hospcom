public class RelatorioDestinacaoComprasContr {
    
    public list <Item_de_pedido_de_compra__c> Records	{get;set;}
    
     
    public Boolean show 								{get;set;}
    public Boolean displayPopUp							{get;set;}
    public Boolean apenasDisp							{get;set;}
    public Boolean apenasDest							{get;set;}
    public Boolean apenasEquip							{get;set;}
        
    public date dataInicial								{get;set;}
    public date dataFinal								{get;set;}
    
    public String pc									{get;set;}
    public String cod									{get;set;}
    public String prod									{get;set;}
    public String marca									{get;set;}
    public String modelo								{get;set;}
    public String pv									{get;set;}

      
    public RelatorioDestinacaoComprasContr(){
        
        displayPopUp = false;
        show=true;
       		 Records = [SELECT Id, Name, Quantidade_requisitada__c, Quantidade_Recebida__c, Data_de_requisicao__c, Produto__r.ProductCode, Produto__r.Modelo__c,
                			   Pedido_de_compra__r.Data_de_inicio__c, Produto__c, Produto__r.Marca__c, (SELECT ID, Name, Fornecedor__r.Name, Fornecedor__r.Id, Fornecedor__r.Status_do_PC__c from Itens_de_fornecedor__r),
                			   Pedido_de_compra__r.Name, Pedido_de_compra__r.Origem__c, Pedido_de_compra__r.Id, (SELECT Id, Name, Quantidade_requisitada__c, Quantidade_disponivel__c, RecordTypeId, Item_de_pedido_de_venda__c, Item_de_pedido_de_venda__r.Order.OrderNumber, Item_de_pedido_de_venda__r.Order.AccountId FROM Requisicoes_de_Itens__r ORDER by RecordTypeId, Quantidade_requisitada__c )               			    
                        FROM Item_de_pedido_de_compra__c 
                        WHERE Id IN (Select Item_de_pedido_de_compra__c from Item_de_fornecedor__c WHERE Status__c = 'Aguardando Entrega Fornecedor' OR Status__c = 'Recebido Parcial') and ID IN (Select Item_de_pedido_de_compra__c from Requisicao_de_item__c where Quantidade_requisitada__c > 0)  ORDER BY Name 
                       ];
        
    }

    public void pesquisar(){
        if(pc != ''){
        	Records = [SELECT Id, Name, Quantidade_requisitada__c, Quantidade_Recebida__c, Data_de_requisicao__c, Produto__r.ProductCode, Produto__r.Modelo__c,
                			   Pedido_de_compra__r.Data_de_inicio__c, Produto__c, Produto__r.Marca__c, (SELECT ID, Name, Fornecedor__r.Name, Fornecedor__r.Id, Fornecedor__r.Status_do_PC__c from Itens_de_fornecedor__r),
                			   Pedido_de_compra__r.Name, Pedido_de_compra__r.Origem__c, Pedido_de_compra__r.Id, (SELECT Id, Name, Quantidade_requisitada__c, Quantidade_disponivel__c, RecordTypeId, Item_de_pedido_de_venda__c, Item_de_pedido_de_venda__r.Order.OrderNumber, Item_de_pedido_de_venda__r.Order.AccountId FROM Requisicoes_de_Itens__r ORDER by RecordTypeId, Quantidade_requisitada__c )               			    
                        FROM Item_de_pedido_de_compra__c 
                        WHERE (Id IN (Select Item_de_pedido_de_compra__c from Item_de_fornecedor__c WHERE (Status__c = 'Aguardando Entrega Fornecedor' OR Status__c = 'Recebido Parcial') and Fornecedor__r.Name like : '%'+ pc))  ORDER BY Name
                       ];
    }
        else if(pv != ''){
            Records = [SELECT Id, Name, Quantidade_requisitada__c, Quantidade_Recebida__c, Data_de_requisicao__c, Produto__r.ProductCode, Produto__r.Modelo__c,
                			   Pedido_de_compra__r.Data_de_inicio__c, Produto__c, Produto__r.Marca__c, (SELECT ID, Name, Fornecedor__r.Name, Fornecedor__r.Id, Fornecedor__r.Status_do_PC__c from Itens_de_fornecedor__r),
                			   Pedido_de_compra__r.Name, Pedido_de_compra__r.Origem__c, Pedido_de_compra__r.Id, (SELECT Id, Name, Quantidade_requisitada__c, Quantidade_disponivel__c, RecordTypeId, Item_de_pedido_de_venda__c, Item_de_pedido_de_venda__r.Order.OrderNumber, Item_de_pedido_de_venda__r.Order.AccountId FROM Requisicoes_de_Itens__r ORDER by RecordTypeId, Quantidade_requisitada__c )               			    
                        FROM Item_de_pedido_de_compra__c 
                        WHERE Id IN (Select Item_de_pedido_de_compra__c from Item_de_fornecedor__c WHERE Status__c = 'Aguardando Entrega Fornecedor' OR Status__c = 'Recebido Parcial') and ID IN (SELECT Item_de_pedido_de_compra__c FROM Requisicao_de_item__c WHERE Item_de_pedido_de_venda__r.Order.OrderNumber like : '%'+ pv)  ORDER BY Name 
                       ];
        }
        else if(apenasDisp == true && cod == '' && pv == '' && pc == '' && prod == '' && marca == '' && modelo == '' && apenasDest == false && apenasEquip == false){
               Records = [SELECT Id, Name, Quantidade_requisitada__c, Quantidade_Recebida__c, Data_de_requisicao__c, Produto__r.ProductCode, Produto__r.Modelo__c,
                			   Pedido_de_compra__r.Data_de_inicio__c, Produto__c, Produto__r.Marca__c, (SELECT ID, Name, Fornecedor__r.Name, Fornecedor__r.Id, Fornecedor__r.Status_do_PC__c from Itens_de_fornecedor__r),
                			   Pedido_de_compra__r.Name, Pedido_de_compra__r.Origem__c, Pedido_de_compra__r.Id, (SELECT Id, Name, Quantidade_requisitada__c, Quantidade_disponivel__c, RecordTypeId, Item_de_pedido_de_venda__c, Item_de_pedido_de_venda__r.Order.OrderNumber, Item_de_pedido_de_venda__r.Order.AccountId FROM Requisicoes_de_Itens__r ORDER by RecordTypeId, Quantidade_requisitada__c )               			    
                        FROM Item_de_pedido_de_compra__c 
                        WHERE (Id IN (Select Item_de_pedido_de_compra__c from Item_de_fornecedor__c WHERE Status__c = 'Aguardando Entrega Fornecedor' OR Status__c = 'Recebido Parcial') and ID IN (SELECT Item_de_pedido_de_compra__c FROM Requisicao_de_item__c WHERE (RecordTypeId = '0126e000001YbImAAK' and Quantidade_disponivel__c >= 1) or RecordTypeId = '0125A000001QVQCQA4'))  ORDER BY Name 
                       ];        

        }
        else if(cod != '' && pc == '' && prod == '' && marca == '' && modelo == '' && pv == '' && apenasDisp == false && apenasDest == false && apenasEquip == false ){
            	Records = [SELECT Id, Name, Quantidade_requisitada__c, Quantidade_Recebida__c, Data_de_requisicao__c, Produto__r.ProductCode, Produto__r.Modelo__c,
                			   Pedido_de_compra__r.Data_de_inicio__c, Produto__c, Produto__r.Marca__c, (SELECT ID, Name, Fornecedor__r.Name, Fornecedor__r.Id, Fornecedor__r.Status_do_PC__c from Itens_de_fornecedor__r),
                			   Pedido_de_compra__r.Name, Pedido_de_compra__r.Origem__c, Pedido_de_compra__r.Id, (SELECT Id, Name, Quantidade_requisitada__c, Quantidade_disponivel__c, RecordTypeId, Item_de_pedido_de_venda__c, Item_de_pedido_de_venda__r.Order.OrderNumber, Item_de_pedido_de_venda__r.Order.AccountId FROM Requisicoes_de_Itens__r ORDER by RecordTypeId, Quantidade_requisitada__c )               			    
                        FROM Item_de_pedido_de_compra__c 
                        WHERE (Produto__r.ProductCode = :cod and Id IN (Select Item_de_pedido_de_compra__c from Item_de_fornecedor__c WHERE Status__c = 'Aguardando Entrega Fornecedor' OR Status__c = 'Recebido Parcial') and ID IN (SELECT Item_de_pedido_de_compra__c FROM Requisicao_de_item__c))  ORDER BY Name 
                       ];   
        }
        else if(cod != '' && pc == '' && prod == '' && marca == '' && modelo == '' && pv == '' && apenasDisp == true && apenasDest == false && apenasEquip == false ){
            	Records = [SELECT Id, Name, Quantidade_requisitada__c, Quantidade_Recebida__c, Data_de_requisicao__c, Produto__r.ProductCode, Produto__r.Modelo__c,
                			   Pedido_de_compra__r.Data_de_inicio__c, Produto__c, Produto__r.Marca__c, (SELECT ID, Name, Fornecedor__r.Name, Fornecedor__r.Id, Fornecedor__r.Status_do_PC__c from Itens_de_fornecedor__r),
                			   Pedido_de_compra__r.Name, Pedido_de_compra__r.Origem__c, Pedido_de_compra__r.Id, (SELECT Id, Name, Quantidade_requisitada__c, Quantidade_disponivel__c, RecordTypeId, Item_de_pedido_de_venda__c, Item_de_pedido_de_venda__r.Order.OrderNumber, Item_de_pedido_de_venda__r.Order.AccountId FROM Requisicoes_de_Itens__r ORDER by RecordTypeId, Quantidade_requisitada__c )               			    
                        FROM Item_de_pedido_de_compra__c 
                        WHERE (Produto__r.ProductCode = :cod and Id IN (Select Item_de_pedido_de_compra__c from Item_de_fornecedor__c WHERE Status__c = 'Aguardando Entrega Fornecedor' OR Status__c = 'Recebido Parcial') and ID IN (SELECT Item_de_pedido_de_compra__c FROM Requisicao_de_item__c WHERE (RecordTypeId = '0126e000001YbImAAK' and Quantidade_disponivel__c >= 1 ) or RecordTypeId = '0125A000001QVQCQA4'))  ORDER BY Name 
                       ];   
        }
        else if(cod != '' && pc == '' && prod == '' && marca == '' && modelo == '' && pv == '' && apenasDisp == false && apenasDest == true && apenasEquip == false ){
            	Records = [SELECT Id, Name, Quantidade_requisitada__c, Quantidade_Recebida__c, Data_de_requisicao__c, Produto__r.ProductCode, Produto__r.Modelo__c,
                			   Pedido_de_compra__r.Data_de_inicio__c, Produto__c, Produto__r.Marca__c, (SELECT ID, Name, Fornecedor__r.Name, Fornecedor__r.Id, Fornecedor__r.Status_do_PC__c from Itens_de_fornecedor__r),
                			   Pedido_de_compra__r.Name, Pedido_de_compra__r.Origem__c, Pedido_de_compra__r.Id, (SELECT Id, Name, Quantidade_requisitada__c, Quantidade_disponivel__c, RecordTypeId, Item_de_pedido_de_venda__c, Item_de_pedido_de_venda__r.Order.OrderNumber, Item_de_pedido_de_venda__r.Order.AccountId FROM Requisicoes_de_Itens__r ORDER by RecordTypeId, Quantidade_requisitada__c )               			    
                        FROM Item_de_pedido_de_compra__c 
                        WHERE (Produto__r.ProductCode = :cod and Id IN (Select Item_de_pedido_de_compra__c from Item_de_fornecedor__c WHERE Status__c = 'Aguardando Entrega Fornecedor' OR Status__c = 'Recebido Parcial') and ID IN (SELECT Item_de_pedido_de_compra__c FROM Requisicao_de_item__c WHERE (RecordTypeId = '0126e000001YbImAAK' and Quantidade_disponivel__c = 0) or RecordTypeId = '0125A000001QVQAQA4'))  ORDER BY Name 
                       ]; 
        }
        else if(prod != '' && pc == '' && cod == '' && marca == '' && modelo == '' && pv == '' && apenasDisp == false && apenasDest == false && apenasEquip == false ){
            	Records = [SELECT Id, Name, Quantidade_requisitada__c, Quantidade_Recebida__c, Data_de_requisicao__c, Produto__r.ProductCode, Produto__r.Modelo__c,
                			   Pedido_de_compra__r.Data_de_inicio__c, Produto__c, Produto__r.Marca__c, (SELECT ID, Name, Fornecedor__r.Name, Fornecedor__r.Id, Fornecedor__r.Status_do_PC__c from Itens_de_fornecedor__r),
                			   Pedido_de_compra__r.Name, Pedido_de_compra__r.Origem__c, Pedido_de_compra__r.Id, (SELECT Id, Name, Quantidade_requisitada__c, Quantidade_disponivel__c, RecordTypeId, Item_de_pedido_de_venda__c, Item_de_pedido_de_venda__r.Order.OrderNumber, Item_de_pedido_de_venda__r.Order.AccountId FROM Requisicoes_de_Itens__r ORDER by RecordTypeId, Quantidade_requisitada__c )               			    
                        FROM Item_de_pedido_de_compra__c 
                        WHERE (Produto__r.Name like : '%'+prod+'%' and Id IN (Select Item_de_pedido_de_compra__c from Item_de_fornecedor__c WHERE Status__c = 'Aguardando Entrega Fornecedor' OR Status__c = 'Recebido Parcial') and ID IN (SELECT Item_de_pedido_de_compra__c FROM Requisicao_de_item__c))  ORDER BY Name 
                       ]; 
        }
        else if(prod != '' && pc == '' && cod == '' && marca == '' && modelo == '' && pv == '' && apenasDisp == true && apenasDest == false && apenasEquip == false ){
            	Records = [SELECT Id, Name, Quantidade_requisitada__c, Quantidade_Recebida__c, Data_de_requisicao__c, Produto__r.ProductCode, Produto__r.Modelo__c,
                			   Pedido_de_compra__r.Data_de_inicio__c, Produto__c, Produto__r.Marca__c, (SELECT ID, Name, Fornecedor__r.Name, Fornecedor__r.Id, Fornecedor__r.Status_do_PC__c from Itens_de_fornecedor__r),
                			   Pedido_de_compra__r.Name, Pedido_de_compra__r.Origem__c, Pedido_de_compra__r.Id, (SELECT Id, Name, Quantidade_requisitada__c, Quantidade_disponivel__c, RecordTypeId, Item_de_pedido_de_venda__c, Item_de_pedido_de_venda__r.Order.OrderNumber, Item_de_pedido_de_venda__r.Order.AccountId FROM Requisicoes_de_Itens__r ORDER by RecordTypeId, Quantidade_requisitada__c )               			    
                        FROM Item_de_pedido_de_compra__c 
                        WHERE (Produto__r.Name like : '%'+prod+'%' and Id IN (Select Item_de_pedido_de_compra__c from Item_de_fornecedor__c WHERE Status__c = 'Aguardando Entrega Fornecedor' OR Status__c = 'Recebido Parcial') and ID IN (SELECT Item_de_pedido_de_compra__c FROM Requisicao_de_item__c WHERE (RecordTypeId = '0126e000001YbImAAK' and Quantidade_disponivel__c >= 1 ) or RecordTypeId = '0125A000001QVQCQA4'))  ORDER BY Name 
                       ]; 
        }
        else if(prod != '' && pc == '' && cod == '' && marca == '' && modelo == '' && pv == '' && apenasDisp == false && apenasDest == true && apenasEquip == false){
            	Records = [SELECT Id, Name, Quantidade_requisitada__c, Quantidade_Recebida__c, Data_de_requisicao__c, Produto__r.ProductCode, Produto__r.Modelo__c,
                			   Pedido_de_compra__r.Data_de_inicio__c, Produto__c, Produto__r.Marca__c, (SELECT ID, Name, Fornecedor__r.Name, Fornecedor__r.Id, Fornecedor__r.Status_do_PC__c from Itens_de_fornecedor__r),
                			   Pedido_de_compra__r.Name, Pedido_de_compra__r.Origem__c, Pedido_de_compra__r.Id, (SELECT Id, Name, Quantidade_requisitada__c, Quantidade_disponivel__c, RecordTypeId, Item_de_pedido_de_venda__c, Item_de_pedido_de_venda__r.Order.OrderNumber, Item_de_pedido_de_venda__r.Order.AccountId FROM Requisicoes_de_Itens__r ORDER by RecordTypeId, Quantidade_requisitada__c )               			    
                        FROM Item_de_pedido_de_compra__c 
                        WHERE (Produto__r.Name like : '%'+prod+'%' and Id IN (Select Item_de_pedido_de_compra__c from Item_de_fornecedor__c WHERE Status__c = 'Aguardando Entrega Fornecedor' OR Status__c = 'Recebido Parcial') and ID IN (SELECT Item_de_pedido_de_compra__c FROM Requisicao_de_item__c WHERE (RecordTypeId = '0126e000001YbImAAK' and Quantidade_disponivel__c = 0 ) or RecordTypeId = '0125A000001QVQAQA4'))  ORDER BY Name 
                       ]; 
        }
        else if(marca != '' && pc == '' && cod == '' && prod == '' && modelo == '' && pv == '' && apenasDisp == false && apenasDest == false && apenasEquip == false ){
            	Records = [SELECT Id, Name, Quantidade_requisitada__c, Quantidade_Recebida__c, Data_de_requisicao__c, Produto__r.ProductCode, Produto__r.Modelo__c,
                			   Pedido_de_compra__r.Data_de_inicio__c, Produto__c, Produto__r.Marca__c, (SELECT ID, Name, Fornecedor__r.Name, Fornecedor__r.Id, Fornecedor__r.Status_do_PC__c from Itens_de_fornecedor__r),
                			   Pedido_de_compra__r.Name, Pedido_de_compra__r.Origem__c, Pedido_de_compra__r.Id, (SELECT Id, Name, Quantidade_requisitada__c, Quantidade_disponivel__c, RecordTypeId, Item_de_pedido_de_venda__c, Item_de_pedido_de_venda__r.Order.OrderNumber, Item_de_pedido_de_venda__r.Order.AccountId FROM Requisicoes_de_Itens__r ORDER by RecordTypeId, Quantidade_requisitada__c )               			    
                        FROM Item_de_pedido_de_compra__c 
                        WHERE (Produto__r.Marca__c like : '%'+marca+'%' and Id IN (Select Item_de_pedido_de_compra__c from Item_de_fornecedor__c WHERE Status__c = 'Aguardando Entrega Fornecedor' OR Status__c = 'Recebido Parcial') and ID IN (SELECT Item_de_pedido_de_compra__c FROM Requisicao_de_item__c))  ORDER BY Name 
                       ]; 
        }
        else if(marca != '' && pc == '' && cod == '' && prod == '' && modelo == '' && pv == '' && apenasDisp == true && apenasDest == false && apenasEquip == false ){
            	Records = [SELECT Id, Name, Quantidade_requisitada__c, Quantidade_Recebida__c, Data_de_requisicao__c, Produto__r.ProductCode, Produto__r.Modelo__c,
                			   Pedido_de_compra__r.Data_de_inicio__c, Produto__c, Produto__r.Marca__c, (SELECT ID, Name, Fornecedor__r.Name, Fornecedor__r.Id, Fornecedor__r.Status_do_PC__c from Itens_de_fornecedor__r),
                			   Pedido_de_compra__r.Name, Pedido_de_compra__r.Origem__c, Pedido_de_compra__r.Id, (SELECT Id, Name, Quantidade_requisitada__c, Quantidade_disponivel__c, RecordTypeId, Item_de_pedido_de_venda__c, Item_de_pedido_de_venda__r.Order.OrderNumber, Item_de_pedido_de_venda__r.Order.AccountId FROM Requisicoes_de_Itens__r ORDER by RecordTypeId, Quantidade_requisitada__c )               			    
                        FROM Item_de_pedido_de_compra__c 
                        WHERE (Produto__r.Marca__c like : '%'+marca+'%' and Id IN (Select Item_de_pedido_de_compra__c from Item_de_fornecedor__c WHERE Status__c = 'Aguardando Entrega Fornecedor' OR Status__c = 'Recebido Parcial') and ID IN (SELECT Item_de_pedido_de_compra__c FROM Requisicao_de_item__c  WHERE (RecordTypeId = '0126e000001YbImAAK' and Quantidade_disponivel__c >= 1 ) or RecordTypeId = '0125A000001QVQCQA4'))  ORDER BY Name 
                       ]; 
        }
        else if(marca != '' && pc == '' && cod == '' && prod == '' && modelo == '' && pv == '' && apenasDisp == false && apenasDest == true && apenasEquip == false){
            	Records = [SELECT Id, Name, Quantidade_requisitada__c, Quantidade_Recebida__c, Data_de_requisicao__c, Produto__r.ProductCode, Produto__r.Modelo__c,
                			   Pedido_de_compra__r.Data_de_inicio__c, Produto__c, Produto__r.Marca__c, (SELECT ID, Name, Fornecedor__r.Name, Fornecedor__r.Id, Fornecedor__r.Status_do_PC__c from Itens_de_fornecedor__r),
                			   Pedido_de_compra__r.Name, Pedido_de_compra__r.Origem__c, Pedido_de_compra__r.Id, (SELECT Id, Name, Quantidade_requisitada__c, Quantidade_disponivel__c, RecordTypeId, Item_de_pedido_de_venda__c, Item_de_pedido_de_venda__r.Order.OrderNumber, Item_de_pedido_de_venda__r.Order.AccountId FROM Requisicoes_de_Itens__r ORDER by RecordTypeId, Quantidade_requisitada__c )               			    
                        FROM Item_de_pedido_de_compra__c 
                        WHERE (Produto__r.Marca__c like : '%'+marca+'%' and Id IN (Select Item_de_pedido_de_compra__c from Item_de_fornecedor__c WHERE Status__c = 'Aguardando Entrega Fornecedor' OR Status__c = 'Recebido Parcial') and ID IN (SELECT Item_de_pedido_de_compra__c FROM Requisicao_de_item__c WHERE (RecordTypeId = '0126e000001YbImAAK' and Quantidade_disponivel__c = 0 ) or RecordTypeId = '0125A000001QVQAQA4'))  ORDER BY Name 
                       ]; 
        }
        else if(modelo != '' && pc == '' && cod == '' && prod == '' && marca == '' && pv == '' && apenasDisp == false && apenasDest == false && apenasEquip == false ){
            	Records = [SELECT Id, Name, Quantidade_requisitada__c, Quantidade_Recebida__c, Data_de_requisicao__c, Produto__r.ProductCode, Produto__r.Modelo__c,
                			   Pedido_de_compra__r.Data_de_inicio__c, Produto__c, Produto__r.Marca__c, (SELECT ID, Name, Fornecedor__r.Name, Fornecedor__r.Id, Fornecedor__r.Status_do_PC__c from Itens_de_fornecedor__r),
                			   Pedido_de_compra__r.Name, Pedido_de_compra__r.Origem__c, Pedido_de_compra__r.Id, (SELECT Id, Name, Quantidade_requisitada__c, Quantidade_disponivel__c, RecordTypeId, Item_de_pedido_de_venda__c, Item_de_pedido_de_venda__r.Order.OrderNumber, Item_de_pedido_de_venda__r.Order.AccountId FROM Requisicoes_de_Itens__r ORDER by RecordTypeId, Quantidade_requisitada__c )               			    
                        FROM Item_de_pedido_de_compra__c 
                        WHERE (Produto__r.Modelo__c like : '%'+modelo+'%' and Id IN (Select Item_de_pedido_de_compra__c from Item_de_fornecedor__c WHERE Status__c = 'Aguardando Entrega Fornecedor' OR Status__c = 'Recebido Parcial') and ID IN (SELECT Item_de_pedido_de_compra__c FROM Requisicao_de_item__c))  ORDER BY Name 
                       ]; 
        }
        else if(modelo != '' && pc == '' && cod == '' && prod == '' && marca == '' && pv == '' && apenasDisp == true && apenasDest == false && apenasEquip == false ){
            	Records = [SELECT Id, Name, Quantidade_requisitada__c, Quantidade_Recebida__c, Data_de_requisicao__c, Produto__r.ProductCode, Produto__r.Modelo__c,
                			   Pedido_de_compra__r.Data_de_inicio__c, Produto__c, Produto__r.Marca__c, (SELECT ID, Name, Fornecedor__r.Name, Fornecedor__r.Id, Fornecedor__r.Status_do_PC__c from Itens_de_fornecedor__r),
                			   Pedido_de_compra__r.Name, Pedido_de_compra__r.Origem__c, Pedido_de_compra__r.Id, (SELECT Id, Name, Quantidade_requisitada__c, Quantidade_disponivel__c, RecordTypeId, Item_de_pedido_de_venda__c, Item_de_pedido_de_venda__r.Order.OrderNumber, Item_de_pedido_de_venda__r.Order.AccountId FROM Requisicoes_de_Itens__r ORDER by RecordTypeId, Quantidade_requisitada__c )               			    
                        FROM Item_de_pedido_de_compra__c 
                        WHERE (Produto__r.Modelo__c like : '%'+modelo+'%' and Id IN (Select Item_de_pedido_de_compra__c from Item_de_fornecedor__c WHERE Status__c = 'Aguardando Entrega Fornecedor' OR Status__c = 'Recebido Parcial') and ID IN (SELECT Item_de_pedido_de_compra__c FROM Requisicao_de_item__c  WHERE (RecordTypeId = '0126e000001YbImAAK' and Quantidade_disponivel__c >= 1 ) or RecordTypeId = '0125A000001QVQCQA4'))  ORDER BY Name 
                       ]; 
        }
        else if(modelo != '' && pc == '' && cod == '' && prod == '' && marca == '' && pv == '' && apenasDisp == false && apenasDest == true && apenasEquip == false  ){
            	Records = [SELECT Id, Name, Quantidade_requisitada__c, Quantidade_Recebida__c, Data_de_requisicao__c, Produto__r.ProductCode, Produto__r.Modelo__c,
                			   Pedido_de_compra__r.Data_de_inicio__c, Produto__c, Produto__r.Marca__c, (SELECT ID, Name, Fornecedor__r.Name, Fornecedor__r.Id, Fornecedor__r.Status_do_PC__c from Itens_de_fornecedor__r),
                			   Pedido_de_compra__r.Name, Pedido_de_compra__r.Origem__c, Pedido_de_compra__r.Id, (SELECT Id, Name, Quantidade_requisitada__c, Quantidade_disponivel__c, RecordTypeId, Item_de_pedido_de_venda__c, Item_de_pedido_de_venda__r.Order.OrderNumber, Item_de_pedido_de_venda__r.Order.AccountId FROM Requisicoes_de_Itens__r ORDER by RecordTypeId, Quantidade_requisitada__c )               			    
                        FROM Item_de_pedido_de_compra__c 
                        WHERE (Produto__r.Modelo__c like : '%'+modelo+'%' and Id IN (Select Item_de_pedido_de_compra__c from Item_de_fornecedor__c WHERE Status__c = 'Aguardando Entrega Fornecedor' OR Status__c = 'Recebido Parcial') and ID IN (SELECT Item_de_pedido_de_compra__c FROM Requisicao_de_item__c WHERE (RecordTypeId = '0126e000001YbImAAK' and Quantidade_disponivel__c = 0 ) or RecordTypeId = '0125A000001QVQAQA4'))  ORDER BY Name 
                       ]; 
        }
        else if(modelo == '' && pc == '' && cod == '' && prod == '' && marca == '' && pv == '' && apenasDisp == false && apenasDest == false && apenasEquip == true){
            	Records = [SELECT Id, Name, Quantidade_requisitada__c, Quantidade_Recebida__c, Data_de_requisicao__c, Produto__r.ProductCode, Produto__r.Modelo__c,
                			   Pedido_de_compra__r.Data_de_inicio__c, Produto__c, Produto__r.Marca__c, (SELECT ID, Name, Fornecedor__r.Name, Fornecedor__r.Id, Fornecedor__r.Status_do_PC__c from Itens_de_fornecedor__r),
                			   Pedido_de_compra__r.Name, Pedido_de_compra__r.Origem__c, Pedido_de_compra__r.Id, (SELECT Id, Name, Quantidade_requisitada__c, Quantidade_disponivel__c, RecordTypeId, Item_de_pedido_de_venda__c, Item_de_pedido_de_venda__r.Order.OrderNumber, Item_de_pedido_de_venda__r.Order.AccountId FROM Requisicoes_de_Itens__r ORDER by RecordTypeId, Quantidade_requisitada__c )               			    
                        FROM Item_de_pedido_de_compra__c 
                        WHERE (Produto__r.Tipo_do_Produto__c = 'EQUIPAMENTO' and Id IN (Select Item_de_pedido_de_compra__c from Item_de_fornecedor__c WHERE Status__c = 'Aguardando Entrega Fornecedor' OR Status__c = 'Recebido Parcial'))  ORDER BY Name 
                       ]; 
        }
        else if(modelo == '' && pc == '' && cod == '' && prod == '' && marca == '' && pv == '' && apenasDisp == true && apenasDest == false && apenasEquip == true){
            	Records = [SELECT Id, Name, Quantidade_requisitada__c, Quantidade_Recebida__c, Data_de_requisicao__c, Produto__r.ProductCode, Produto__r.Modelo__c,
                			   Pedido_de_compra__r.Data_de_inicio__c, Produto__c, Produto__r.Marca__c, (SELECT ID, Name, Fornecedor__r.Name, Fornecedor__r.Id, Fornecedor__r.Status_do_PC__c from Itens_de_fornecedor__r),
                			   Pedido_de_compra__r.Name, Pedido_de_compra__r.Origem__c, Pedido_de_compra__r.Id, (SELECT Id, Name, Quantidade_requisitada__c, Quantidade_disponivel__c, RecordTypeId, Item_de_pedido_de_venda__c, Item_de_pedido_de_venda__r.Order.OrderNumber, Item_de_pedido_de_venda__r.Order.AccountId FROM Requisicoes_de_Itens__r ORDER by RecordTypeId, Quantidade_requisitada__c )               			    
                        FROM Item_de_pedido_de_compra__c 
                        WHERE (Produto__r.Tipo_do_Produto__c = 'EQUIPAMENTO' and Id IN (Select Item_de_pedido_de_compra__c from Item_de_fornecedor__c WHERE Status__c = 'Aguardando Entrega Fornecedor' OR Status__c = 'Recebido Parcial') and ID IN (SELECT Item_de_pedido_de_compra__c FROM Requisicao_de_item__c  WHERE (RecordTypeId = '0126e000001YbImAAK' and Quantidade_disponivel__c >= 1 ) or RecordTypeId = '0125A000001QVQCQA4'))  ORDER BY Name 
                       ]; 
        }
        else{
            
        }
        
    }
}