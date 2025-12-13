public class checklistDemo {
    
    @AuraEnabled
    public static string finalizaEnvio(String idsItems, String assinaturaCliente, String assinaturaHospcom, String nomeCliente, String nomeHospcom, String orderId){
        
        String folderName = 'Imagens';
      	List<Folder> pastaLog = ([SELECT id FROM Folder WHERE Name = :folderName]);
        List<String> listaItens = idsItems.split(',');
        List<OrderItem> recordsToUpdate = new List<OrderItem>();
        
        // Itera sobre os IDs dos registros e adiciona os registros à lista para atualização
        for (String listaItem : listaItens) {
            OrderItem record = new OrderItem(Id = listaItem);
            record.put('checklist_envio__c', true);
            recordsToUpdate.add(record);
        }
        
        // Atualiza os registros
        if (!recordsToUpdate.isEmpty()) {
            update recordsToUpdate;
        }
        
		Document imageDoc = new Document(
			Name = 'DEMO_SIGNATURE',
			Body = EncodingUtil.base64Decode(assinaturaCliente),
			ContentType = 'image/jpg',
			Type = 'jpg',
			IsPublic = true,
			FolderId = pastaLog[0].Id        
        );
        insert imageDoc;
        
        Document imageDoc2 = new Document(
			Name = 'DEMO_SIGNATURE',
			Body = EncodingUtil.base64Decode(assinaturaHospcom),
			ContentType = 'image/jpg',
			Type = 'jpg',
			IsPublic = true,
			FolderId = pastaLog[0].Id        
        );
        insert imageDoc2;
        
        String assinaturaClienteUrl = 'https://hospcom--c.na170.content.force.com/servlet/servlet.ImageServer?id=' + imageDoc.Id + '&oid=00Di0000000JVhH';
        String assinaturaHospcomUrl = 'https://hospcom--c.na170.content.force.com/servlet/servlet.ImageServer?id=' + imageDoc2.Id + '&oid=00Di0000000JVhH';
        
        Order pedidoDemo = new Order();
        pedidoDemo.id = orderId;
        pedidoDemo.Nome_Cliente_Envio__c = nomeCliente;
        pedidoDemo.Nome_Hospcom_Envio__c = nomeHospcom;
        pedidoDemo.Assinatura_Cliente_Envio__c = assinaturaClienteUrl;
        pedidoDemo.Assinatura_Hospcom_Envio__c = assinaturaHospcomUrl;
        pedidoDemo.Checklist_Envio_Assinado__c = true;
        
        update pedidoDemo;
        return 'https://hospcom--c.na170.content.force.com/servlet/servlet.ImageServer?id=' + imageDoc.Id + '&oid=00Di0000000JVhH';
    }
    
    @AuraEnabled
    public static string finalizaRetorno(String idsItems, String assinaturaCliente, String assinaturaHospcom, String nomeCliente, String nomeHospcom, String orderId){
        
        String folderName = 'Imagens';
      	List<Folder> pastaLog = ([SELECT id FROM Folder WHERE Name = :folderName]);
        List<String> listaItens = idsItems.split(',');
        List<OrderItem> recordsToUpdate = new List<OrderItem>();
        
        // Itera sobre os IDs dos registros e adiciona os registros à lista para atualização
        for (String listaItem : listaItens) {
            OrderItem record = new OrderItem(Id = listaItem);
            record.put('checklist_retorno__c', true);
            recordsToUpdate.add(record);
        }
        
        // Atualiza os registros
        if (!recordsToUpdate.isEmpty()) {
            update recordsToUpdate;
        }
        
		Document imageDoc = new Document(
			Name = 'DEMO_SIGNATURE',
			Body = EncodingUtil.base64Decode(assinaturaCliente),
			ContentType = 'image/jpg',
			Type = 'jpg',
			IsPublic = true,
			FolderId = pastaLog[0].Id        
        );
        insert imageDoc;
        
        Document imageDoc2 = new Document(
			Name = 'DEMO_SIGNATURE',
			Body = EncodingUtil.base64Decode(assinaturaHospcom),
			ContentType = 'image/jpg',
			Type = 'jpg',
			IsPublic = true,
			FolderId = pastaLog[0].Id        
        );
        insert imageDoc2;
        
        String assinaturaClienteUrl = 'https://hospcom--c.na170.content.force.com/servlet/servlet.ImageServer?id=' + imageDoc.Id + '&oid=00Di0000000JVhH';
        String assinaturaHospcomUrl = 'https://hospcom--c.na170.content.force.com/servlet/servlet.ImageServer?id=' + imageDoc2.Id + '&oid=00Di0000000JVhH';
        
        Order pedidoDemo = new Order();
        pedidoDemo.id = orderId;
        pedidoDemo.Nome_Cliente_Retorno__c = nomeCliente;
        pedidoDemo.Nome_Hospcom_Retorno__c = nomeHospcom;
        pedidoDemo.Assinatura_Cliente_Retorno__c = assinaturaClienteUrl;
        pedidoDemo.Assinatura_Hospcom_Retorno__c = assinaturaHospcomUrl;
        pedidoDemo.Checklist_Retorno_Assinado__c = true;
        
        update pedidoDemo;
        return 'https://hospcom--c.na170.content.force.com/servlet/servlet.ImageServer?id=' + imageDoc.Id + '&oid=00Di0000000JVhH';
    }

}