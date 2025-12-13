import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import executeSoql from '@salesforce/apex/ApexHelperController.executeSoql';
import verificarEAtualizarValores from '@salesforce/apex/AjustaPedidosLocacao.verificarEAtualizarValores';

export default class TabelaPedidosContrato extends LightningElement {
    @api recordId; // Id do Contrato_de_Servi_o__c
    pedidos = [];
    error;
    selectedFilter = 'FATURA'; // Filtro padrão

    // Método para buscar os pedidos e faturamentos com base no filtro selecionado
    connectedCallback() {
        this.fetchPedidosAndFaturamentos();
    }

    fetchPedidosAndFaturamentos() {
        let soql = `SELECT Id, OrderNumber, EffectiveDate, Natureza_de_Opera_o__c, Data_de_ativacao_formatada__c, Status, Referencia__c, TotalAmount,
                        (SELECT Id, Name, Data__c FROM Faturamentos__r)
                    FROM Order 
                    WHERE Contrato_de_Servi_o__c = '${this.recordId}'`;

        // Aplica o filtro dependendo da seleção
        if (this.selectedFilter === 'FATURA') {
            soql += ` AND Natureza_de_Opera_o__c = 'LOCAÇÃO'`; // Filtra apenas pedidos de natureza "LOCAÇÃO"
        } else if (this.selectedFilter === 'REMESSA') {
            soql += ` AND Natureza_de_Opera_o__c = 'REMESSA DE LOCAÇÃO'`; // Filtra apenas pedidos de natureza "REMESSA DE LOCAÇÃO"
        }

        // Finaliza a consulta
        soql += ' ORDER BY EffectiveDate';

        // Executa a consulta SOQL
        executeSoql({ soql })
            .then(result => {
                this.pedidos = result.map((pedido, index) => {
                    const faturamentos = pedido.Faturamentos__r ? 
                        pedido.Faturamentos__r.map(faturamento => `${faturamento.Name}`).join(', ') 
                        : 'Sem faturamento';
                    return {
                        ...pedido,
                        rowNumber: index + 1,  // Adiciona a numeração à linha
                        orderUrl: `https://hospcom.my.site.com/Sales/s/order/${pedido.Id}/detail`, // Cria a URL do pedido
                        faturamentos // Adiciona a string de faturamentos ao pedido
                    };
                });
            })
            .catch(error => {
                this.error = error;
                console.error(error);
            });
    }

    // Método chamado ao clicar no botão "Atualizar Valores"
    handleAtualizarValores() {
        // Chama o método Apex passando o recordId
        verificarEAtualizarValores({ contratoID: this.recordId })
            .then(result => {
                // Exibe uma mensagem de sucesso
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Sucesso',
                    message: 'Valores atualizados com sucesso.',
                    variant: 'success',
                }));
            })
            .catch(error => {
                // Exibe uma mensagem de erro
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Erro',
                    message: 'Erro ao atualizar os valores.',
                    variant: 'error',
                }));
                console.error(error);
            });
        }

    // Atualiza o filtro com base na seleção
    handleFilterChange(event) {
        this.selectedFilter = event.detail.value; // Atualiza a seleção do filtro
        this.fetchPedidosAndFaturamentos(); // Recarrega os pedidos com o novo filtro
    }

    // Definindo as colunas para a tabela
    get columns() {
        return [
            { label: 'Número', fieldName: 'rowNumber' }, // Coluna de numeração
            { label: 'Número do Pedido', fieldName: 'orderUrl', type: 'url', 
              typeAttributes: { label: { fieldName: 'OrderNumber' }, target: '_blank' } },
            { label: 'Mês Referente', fieldName: 'Referencia__c' },
            { label: 'Natureza da Operação', fieldName: 'Natureza_de_Opera_o__c' },
            { label: 'Status', fieldName: 'Status' },
            { label: 'Valor', fieldName: 'TotalAmount', type: 'currency', typeAttributes: { currencyCode: 'BRL', step: '0.01' } },
            { label: 'Faturamentos', fieldName: 'faturamentos' } // Campo faturamentos adicionado aqui
        ];
    }

    // Opções do combobox
    get filterOptions() {
        return [
            { label: 'TODOS', value: 'TODOS' },
            { label: 'FATURA', value: 'FATURA' },
            { label: 'REMESSA', value: 'REMESSA' }
        ];
    }
}