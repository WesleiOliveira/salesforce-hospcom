import { LightningElement, api, track } from 'lwc';
import executeSoql from '@salesforce/apex/ApexHelperController.executeSoql';
import sendSelectedItems from '@salesforce/apex/vinculaConsumiveis.sendSelectedItems2';
import './consumiveisComodatoInicial.css'; // Importando o CSS personalizado
import { ShowToastEvent } from 'lightning/platformShowToastEvent'; // Importando ShowToastEvent

export default class DemoProductOrderItems2 extends LightningElement {
    @api recordId;
    @track comodatoItems = [];
    @track orderItems = [];
    @track showQuantityInput = false;
    @track quantity = 1;
    selectedComodatoItem = null;
    selectedOrderItem = null; // Mudar de Set para uma variável única

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
        const query = `SELECT ID, Nome_do_produto__c, Produto__r.ProductCode, Quantidade__c, Quantidade_vinculada__c
                       FROM Consumivel_de_comodato__c 
                       WHERE Comodato__c = '${this.recordId}'`;
        executeSoql({ soql: query })
            .then(result => {
                // Processar os itens de pedido e calcular se o checkbox deve ser desabilitado
                this.orderItems = result.map(item => ({
                    ...item,
                    isCheckboxDisabled: item.Quantidade__c === item.Quantidade_vinculada__c,
                    isSelected: this.selectedOrderItem === item.Id // Atualiza o estado de seleção dos itens
                }));
                this.fetchVinculos(result.map(item => item.Id));
            })
            .catch(error => {
                console.error('Error fetching order items', error);
            });
    }

    fetchVinculos(orderItemIds) {
        const query = `SELECT ID, Quantidade__c, Ativo_do_comodato__r.Name, Consum_vel_de_comodato__c, Nome_do_Ativo__c
                       FROM Vinculo_consumivel_requerido__c 
                       WHERE Consum_vel_de_comodato__c IN (${orderItemIds.map(id => `'${id}'`).join(',')})`;
        executeSoql({ soql: query })
            .then(result => {
                // Agora agrupamos os vínculos por ID do produto do pedido
                const vinculosPorProduto = result.reduce((acc, vinculo) => {
                    const produtoId = vinculo.Consum_vel_de_comodato__c;
                    if (!acc[produtoId]) {
                        acc[produtoId] = [];
                    }
                    acc[produtoId].push({
                        vinculoId: vinculo.Id,
                        quantidade: vinculo.Quantidade__c,
                        nome: vinculo.Nome_do_Ativo__c,
                        NS: 'NS'
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
        const consumiveis = this.selectedOrderItem ? [this.selectedOrderItem] : []; // Enviar como lista
        const quantity = this.quantity;
        
        sendSelectedItems({ comodatoItemId, consumiveis, quantity })
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