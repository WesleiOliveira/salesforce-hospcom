import { LightningElement, track, api } from 'lwc';
import searchProducts from '@salesforce/apex/InsumoController.searchProducts';
import sendSelectedProducts from '@salesforce/apex/InsumoController.sendSelectedProducts';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class ProductSearch extends LightningElement {
    @api recordId;
    @track productCode = '';
    @track products = [];
    @track selectedProducts = [];
    @track isLoading = false; // Para controlar o spinner

    handleInputChange(event) {
        this.productCode = event.target.value;
    }

    handleSearch() {
        searchProducts({ productCode: this.productCode })
            .then(result => {
                // Adicionar cada produto encontrado diretamente à lista de produtos selecionados
                const newSelectedProducts = result.map(product => ({
                    ...product,
                    quantity: 1,
                    value: product.Valor_de_Venda__c
                }));

                // Manter os produtos já selecionados e adicionar os novos ao início da lista
                this.selectedProducts = [...newSelectedProducts, ...this.selectedProducts];
                this.products = []; // Limpar a lista de produtos encontrados
            })
            .catch(error => {
                console.error('Error:', error);
            });
    }

    handleQuantityChange(event) {
        const productId = event.target.dataset.id;
        const quantity = event.target.value;
        const productIndex = this.selectedProducts.findIndex(product => product.Id === productId);

        if (productIndex !== -1) {
            this.selectedProducts[productIndex].quantity = quantity;
        }
    }

    handleValueChange(event) {
        const productId = event.target.dataset.id;
        const value = event.target.value;
        const productIndex = this.selectedProducts.findIndex(product => product.Id === productId);

        if (productIndex !== -1) {
            this.selectedProducts[productIndex].value = value;
        }
    }

    handleRemove(event) {
        const productId = event.target.dataset.id;
        this.selectedProducts = this.selectedProducts.filter(product => product.Id !== productId);
    }

    handleSubmit() {
        this.isLoading = true; // Exibir o spinner
        // Cria um objeto com os dados dos produtos selecionados (incluindo quantidade e valor)
        const productData = this.selectedProducts.map(product => ({
            Id: product.Id,
            quantity: product.quantity,
            value: product.value
        }));

        // Envia os dados para o Apex com o recordId
        sendSelectedProducts({ productData: JSON.stringify(productData), idRegistro: this.recordId })
            .then(result => {
                this.isLoading = false; // Ocultar o spinner
                // Mostrar notificação de sucesso
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Sucesso',
                    message: 'Produtos enviados com sucesso.',
                    variant: 'success',
                }));
                // Recarregar a página
                window.location.reload();
            })
            .catch(error => {
                this.isLoading = false; // Ocultar o spinner
                // Mostrar notificação de erro
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Erro',
                    message: 'Erro ao enviar produtos: ' + error.body.message,
                    variant: 'error',
                }));
            });
    }
}