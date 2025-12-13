trigger RecebimentoPreencheVinculos on Recebimentos__c (before insert, before update) {
    // Coleções para armazenar valores únicos
    Set<String> numerosPedido = new Set<String>();
    Set<String> numerosFaturamento = new Set<String>();
    Set<String> numerosTitulo = new Set<String>();
    Set<String> nomesVendedor = new Set<String>();
    
    // Iterar pelos registros para coletar os números de pedido, faturamento e título
    for (Recebimentos__c recebimento : Trigger.new) {
        
        String originalString; 
        if(recebimento.Numero_Pedido__c != '')
            originalString = recebimento.Numero_Pedido__c;
        else
            originalString = '00000000';
        
        String regex = '\\d{8}'; // Expressão regular para 8 dígitos consecutivos
        
        Pattern p = Pattern.compile(regex);
        Matcher m = null;
        
        if(originalString != null && originalString != '') {
            m = p.matcher(originalString);
        }
        
        String resultString = null;
        if (m != null && m.find()) {
            resultString = m.group(0); // Extrai os 8 dígitos
        } else {
            system.debug('Número do pedido não encontrado no recebimento.');           
        }
        
        if (resultString != null) {
            numerosPedido.add(resultString);
        }
        
        System.debug('Resultado: ' + resultString);
        
        if (recebimento.Numero_Faturamento__c != null && recebimento.Numero_Faturamento__c != '') {
            numerosFaturamento.add(recebimento.Numero_Faturamento__c);
        }
        if (recebimento.Titulo_SAP__c != null && recebimento.Titulo_SAP__c != '') {
            numerosTitulo.add(recebimento.Titulo_SAP__c);
        }
        if (recebimento.Vendedor_do_recebimento__c != null && recebimento.Vendedor_do_recebimento__c != '') {
            nomesVendedor.add(recebimento.Vendedor_do_recebimento__c);
        }
    }
    
    // Consultar os pedidos, faturamentos e títulos correspondentes
    Map<String, Id> pedidoMap = new Map<String, Id>();
    Map<String, Id> faturamentoMap = new Map<String, Id>();
    Map<String, Id> tituloMap = new Map<String, Id>();
    Map<String, Id> vendedorMap = new Map<String, Id>();
    
    for (Order pedido : [SELECT Id, OrderNumber FROM Order WHERE OrderNumber IN :numerosPedido]) {
        pedidoMap.put(pedido.OrderNumber, pedido.Id);
    }
    
    if (!numerosFaturamento.isEmpty()) {
        // Criar uma lista com os IDs dos pedidos presentes no pedidoMap
        Set<Id> pedidoIds = new Set<Id>(pedidoMap.values());
        
        // Fazer a consulta em Faturamento__c usando esses IDs
        for (Faturamento__c faturamento : [SELECT Id, Name FROM Faturamento__c WHERE Name IN :numerosFaturamento AND Pedido__c IN :pedidoIds]) {
            faturamentoMap.put(faturamento.Name, faturamento.Id);
        }
    }
    
    if (!numerosTitulo.isEmpty()) {
        for (Titulo__c titulo : [SELECT Id, Name FROM Titulo__c WHERE Name IN :numerosTitulo]) {
            tituloMap.put(titulo.Name, titulo.Id);
        }
    }
    
    if (!nomesVendedor.isEmpty()) {
        for (User usuario : [SELECT Id, Name FROM User WHERE Name IN :nomesVendedor]) {
            vendedorMap.put(usuario.Name, usuario.Id);
        }
    }
    
    // Preencher os campos em Recebimentos__c com os IDs correspondentes
    for (Recebimentos__c recebimento : Trigger.new) {
        if(Trigger.isInsert){
            
            String originalString = recebimento.Numero_Pedido__c; 
            String regex = '\\d{8}'; // Expressão regular para 8 dígitos consecutivos
            
            Pattern p = Pattern.compile(regex);
            Matcher m = null;
            
            if(originalString != null && originalString != '') {
                m = p.matcher(originalString);
            }
            
            String resultString = null;
            if (m != null && m.find()) {
                resultString = m.group(0); // Extrai os 8 dígitos
            } else {
                system.debug('Número do pedido não encontrado no recebimento.');           
            }
            
            if (resultString != null && pedidoMap.containsKey(resultString)) {
                recebimento.Pedido__c = pedidoMap.get(resultString);
            }
            
            if (recebimento.Titulo_SAP__c != null && tituloMap.containsKey(recebimento.Titulo_SAP__c)) {
                recebimento.Titulo__c = tituloMap.get(recebimento.Titulo_SAP__c);
            }
            if (recebimento.Vendedor_do_recebimento__c != null && vendedorMap.containsKey(recebimento.Vendedor_do_recebimento__c)) {
                recebimento.Vendedor2__c = vendedorMap.get(recebimento.Vendedor_do_recebimento__c);
            }       
            if (recebimento.Numero_Faturamento__c != null && faturamentoMap.containsKey(recebimento.Numero_Faturamento__c)) {
                recebimento.Nota_Fiscal1__c = faturamentoMap.get(recebimento.Numero_Faturamento__c);
            } else {
                recebimento.Nota_Fiscal1__c = Id.valueOf('a086e00001uNn4GAAS');  // Valor padrão como Id
            }
        }
        else if(Trigger.isUpdate){
            if (pedidoMap.containsKey(recebimento.Numero_Pedido__c)) {
                recebimento.Pedido__c = pedidoMap.get(recebimento.Numero_Pedido__c);
            }
            
            if (recebimento.Titulo_SAP__c != null && tituloMap.containsKey(recebimento.Titulo_SAP__c)) {
                recebimento.Titulo__c = tituloMap.get(recebimento.Titulo_SAP__c);
            }
            if (recebimento.Vendedor_do_recebimento__c != null && vendedorMap.containsKey(recebimento.Vendedor_do_recebimento__c)) {
                recebimento.Vendedor2__c = vendedorMap.get(recebimento.Vendedor_do_recebimento__c);
            }       
        }
    }
}