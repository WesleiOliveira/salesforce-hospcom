public without sharing class ApiConfirmacaoService {
    public static void processRequest(String idRequisicao) {
        Requisicao_de_item__c destinacao = [SELECT ID, Item_de_pedido_de_venda__c, Item_do_pedido_de_compra2__c, Quantidade_requisitada__c, Quantidade_predestinada__c FROM Requisicao_de_item__c WHERE id =: idRequisicao];
        Integer quantidade = Integer.valueOf(destinacao.Quantidade_predestinada__c);
        destinacao.Quantidade_requisitada__c = quantidade;

        update destinacao;

        Item_de_fornecedor__c itemPC = [SELECT ID, Fornecedor__c, Fornecedor__r.Name, Produto2__c, Quantidade_destinada__c, Quantidade_disponivel__c, Prazo_de_recebimento2__c FROM Item_de_fornecedor__c WHERE ID =: destinacao.Item_do_pedido_de_compra2__c];
        if (quantidade <= itemPC.Quantidade_disponivel__c) {
            Integer quantidadeDestinadaItemPC = Integer.valueOf(itemPC.Quantidade_destinada__c);
            Integer quantidadeDestinadaItemPC_nova = quantidadeDestinadaItemPC + quantidade;
            itemPC.Quantidade_destinada__c = quantidadeDestinadaItemPC_nova;
            update itemPC;

            OrderItem itemPV = [SELECT ID, Status__c, Quantidade_requisitada2__c, Quantity, PriceBookEntryId, Product2Id, OrderId, UnitPrice FROM OrderItem WHERE ID =: destinacao.Item_de_pedido_de_venda__c];
            Integer quantidadeRequisitadaItemPV = Integer.valueOf(itemPV.Quantidade_requisitada2__c);
            Integer quantidadeRequisitadaItemPV_nova = quantidadeRequisitadaItemPV + quantidade;
            itemPV.Quantidade_requisitada2__c = quantidadeRequisitadaItemPV_nova;
            itemPV.Acao_interna__c = true;
            update itemPV;

            itemPV.Status__c = 'Aguardando Entrega Fornecedor';
            itemPV.Prazo_de_recebimento_da_compra__c = itemPC.Prazo_de_recebimento2__c;
            itemPV.Numero_do_pedido_de_compra__c = itemPC.Fornecedor__r.Name;
            itemPV.ID_do_Pedido_de_Compra__c = itemPC.Fornecedor__c;
            update itemPV;
            itemPV.Acao_interna__c = false;
            update itemPV;

            Integer quantidadeFaltante = Integer.valueOf(itemPV.Quantity) - quantidadeRequisitadaItemPV_nova;
            System.debug(quantidadeFaltante);

            if (quantidadeFaltante > 0) {
                OrderItem novaOrderItem = new OrderItem(
                    OrderId = itemPV.OrderId,
                    PriceBookEntryId = itemPV.PriceBookEntryId,
                    Product2Id = itemPV.Product2Id,
                    UnitPrice = itemPV.UnitPrice,
                    Quantity = quantidadeFaltante,
                    Status__c = 'Aguardando Compra Fornecedor'
                );
                insert novaOrderItem;

                itemPV.Quantity = quantidadeRequisitadaItemPV_nova;
                update itemPV;
            }

            Product2 produto = [SELECT ID, Aguardando_recebimento__c FROM Product2 WHERE ID =: itemPC.Produto2__c];
            Integer aguardandoRecebimento = Integer.valueOf(produto.Aguardando_recebimento__c);
            Integer aguardandoRecebimento_nova = aguardandoRecebimento - quantidade;
            produto.Aguardando_recebimento__c = aguardandoRecebimento_nova;
            update produto;
        } else {
            throw new CustomException('Quantidade requisitada excede a quantidade disponível.');
        }
    }

    public class CustomException extends Exception {}
}