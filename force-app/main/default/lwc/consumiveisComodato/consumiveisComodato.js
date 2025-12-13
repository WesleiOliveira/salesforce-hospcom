import { LightningElement, api, track } from 'lwc';
import executeSoql from '@salesforce/apex/ApexHelperController.executeSoql';
import sendSelectedItems from '@salesforce/apex/vinculaConsumiveis.sendSelectedItems';
import './consumiveisComodato.css'; // Importando o CSS personalizado
import { ShowToastEvent } from 'lightning/platformShowToastEvent'; // Importando ShowToastEvent

export default class DemoProductOrderItems extends LightningElement {
    @api recordId;
    @track comodatoItems = [];
    @track orderItems = [];
    @track showQuantityInput = false;
    @track quantity = 1;
    selectedComodatoItem = null;
    selectedOrderItem = null;

    connectedCallback() {
        this.fetchComodatoItems();
        this.fetchOrderItems();
    }

    fetchComodatoItems() {
        const query = `SELECT ID, Ativo__r.Name, Ativo__r.Product2.ProductCode, Numero_de_serie__c FROM Produto_da_Demonstracao__c WHERE Demonstracao__c = '${this.recordId}'`;
        executeSoql({ soql: query })
            .then(result => {
                this.comodatoItems = result;
            })
            .catch(error => {
                console.error('Error fetching comodato items', error);
            });
    }

    fetchOrderItems() {
        const query = `SELECT ID, Product2.Name, Product2.ProductCode, Order.Data_de_ativacao_formatada__c, Quantity, Quantidade_vinculada_comodato__c
                       FROM OrderItem 
                       WHERE Order.Natureza_de_Opera_o__c = 'VENDA' 
                       AND Order.Status IN ('Ativo', 'Em Andamento', 'Entregue Total', 'Entregue Parcial') 
                       AND Order.Demonstracao__c = '${this.recordId}' 
                       ORDER BY Order.Data_de_ativacao__c`;
        executeSoql({ soql: query })
            .then(result => {
                // Processar os itens de pedido e calcular se o checkbox deve ser desabilitado
                this.orderItems = result.map(item => ({
                    ...item,
                    isCheckboxDisabled: item.Quantity === item.Quantidade_vinculada_comodato__c,
                    isSelected: this.selectedOrderItem === item.Id // Atualiza o estado de seleção dos itens
                }));
                this.fetchVinculos(result.map(item => item.Id));
            })
            .catch(error => {
                console.error('Error fetching order items', error);
            });
    }

    fetchVinculos(orderItemIds) {
        const query = `SELECT ID, Produto_do_pedido__c, Quantidade__c, Ativo_do_comodato__r.Name, NS_do_Ativo__c, Nome_do_Ativo__c
                       FROM Vinculo_de_venda_consumivel__c 
                       WHERE Produto_do_pedido__c IN (${orderItemIds.map(id => `'${id}'`).join(',')})`;
        executeSoql({ soql: query })
            .then(result => {
                // Agora agrupamos os vínculos por ID do produto do pedido
                const vinculosPorProduto = result.reduce((acc, vinculo) => {
                    const produtoId = vinculo.Produto_do_pedido__c;
                    if (!acc[produtoId]) {
                        acc[produtoId] = [];
                    }
                    acc[produtoId].push({
                        vinculoId: vinculo.Id,
                        nsAtivo: vinculo.NS_do_Ativo__c ? vinculo.NS_do_Ativo__c : 'Desconhecido',
                        nomeAtivo: vinculo.Nome_do_Ativo__c ? vinculo.Nome_do_Ativo__c : 'Desconhecido',
                        quantidade: vinculo.Quantidade__c
                    });
                    return acc;
                }, {});
    
                // Agora vamos associar os vínculos aos itens de pedido
                this.orderItems = this.orderItems.map(item => {
                    const vinculos = vinculosPorProduto[item.Id] || [];
                    return {
                        ...item,
                        vinculos: vinculos
                    };
                });
            })
            .catch(error => {
                console.error('Error fetching vinculo items', error);
            });
    }

    handleComodatoSelection(event) {
        this.selectedComodatoItem = event.target.dataset.id;
    }

    handleOrderSelection(event) {
        const itemId = event.target.dataset.id;
        if (event.target.checked) {
            // Desmarcar qualquer item previamente selecionado
            if (this.selectedOrderItem) {
                const prevSelectedItem = this.template.querySelector(`input[data-id="${this.selectedOrderItem}"]`);
                if (prevSelectedItem) {
                    prevSelectedItem.checked = false;
                }
            }
            this.selectedOrderItem = itemId;
        } else {
            this.selectedOrderItem = null;
        }
        // Atualiza o estado de seleção dos itens
        this.orderItems = this.orderItems.map(item => ({
            ...item,
            isSelected: this.selectedOrderItem === item.Id
        }));
    }

    handleSubmit() {
        this.showQuantityInput = true;
    }

    handleQuantityChange(event) {
        this.quantity = event.target.value;
    }

    handleFinalSubmit() {
        const comodatoItemId = this.selectedComodatoItem;
        const orderItemIds = this.selectedOrderItem ? [this.selectedOrderItem] : []; // Enviar como lista
        const quantity = this.quantity;
        
        sendSelectedItems({ comodatoItemId, orderItemIds, quantity })
            .then(result => {
                console.log('Items sent successfully', result);
                
                // Refaz a consulta para atualizar a tabela de itens de pedido
                this.fetchOrderItems();  
    

                // Atualiza o estado de seleção dos itens
                this.orderItems = this.orderItems.map(item => ({
                    ...item,
                    isSelected: false // Desmarca todos os itens
                }));

                // Forçar a atualização do DOM
                this.template.querySelectorAll('input[type="checkbox"]').forEach(checkbox => {
                    checkbox.checked = false;
                });

                this.showQuantityInput = false;
   
                // Exibe o Toast de sucesso
                this.showToast('Sucesso', 'Itens vinculados com sucesso.', 'success');
            })
            .catch(error => {
                console.error('Error sending selected items', error);
                const errorMessage = error.body ? error.body.message : 'Ocorreu um erro inesperado.';
                this.showToast('Erro', errorMessage, 'error');
            });
    }

    // Função para exibir o Toast
    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant, 
            mode: 'dismissable' // O toast será fechável
        });
        this.dispatchEvent(event); // Dispara o evento
    }
}