import { LightningElement, track, api, wire } from 'lwc';
import JQuery from '@salesforce/resourceUrl/JQuery';
import fontAwesome from '@salesforce/resourceUrl/fontAwesome';
import { loadStyle } from 'lightning/platformResourceLoader';
import { loadScript } from 'lightning/platformResourceLoader';
import executeSoql from '@salesforce/apex/ApexHelperController.executeSoql';
import * as soqls from './soqls';
import userId from '@salesforce/user/Id';
import * as utils from './utils'
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CurrentPageReference } from 'lightning/navigation';


export default class SolicitacaoDeDevolucaoSeletorDeProduto extends LightningElement {
    @api recordId;
    @track sd;
    @track isParcial;
    @track statusIgualANovo;

    @track orderItens = []; // Todos os order items
    @track availableItems = []; // Itens disponíveis para seleção
    @track returnItems = []; // Itens selecionados para devolução

    @track itensDaDevolucao = [];

    @track isPopupOpen = false;
    @track isLoading = false;

    @wire(CurrentPageReference)

    setCurrentPageReference(currentPageReference) {
        console.log('currentPageReference:', currentPageReference);
        if (currentPageReference) {
            // Para páginas de registro padrão
            if (currentPageReference.attributes && currentPageReference.attributes.recordId) {
                this.recordId = currentPageReference.attributes.recordId;
            }
            // Para parâmetros na URL (c__recordId por exemplo)
            else if (currentPageReference.state && currentPageReference.state.c__recordId) {
                this.recordId = currentPageReference.state.c__recordId;
            }
            // Para outros parâmetros personalizados
            else if (currentPageReference.state && currentPageReference.state.recordId) {
                this.recordId = currentPageReference.state.recordId;
            }

            console.log('recordId capturado:', this.recordId);
        }
    }

    async connectedCallback() {
        this.boundHandleKeyDown = this.handleKeyDown.bind(this);
        document.addEventListener('keydown', this.boundHandleKeyDown);
        console.log("userId: ", userId);
        const record2 = this.recordId;
        console.log('recordId:', record2);
        loadScript(this, JQuery);
        loadStyle(this, fontAwesome + '/css/font-awesome.min.css');
        await soqls.querySolicitacao(this, record2, executeSoql)
        console.log(this.sd)
    }

    disconnectedCallback() {
        document.removeEventListener('keydown', this.boundHandleKeyDown);
        // Restore body scroll se popup estava aberto
        document.body.style.overflow = 'auto';
    }

    toast(titulo, mensagem, variante = 'info', modo = 'dismissable') {
        const event = new ShowToastEvent({
            title: titulo,
            message: mensagem,
            variant: variante,  // 'success', 'error', 'warning', 'info'
            mode: modo          // 'dismissable', 'pester', 'sticky'
        });
        this.dispatchEvent(event);
    }

    showErro(msg) {
        this.toast('Erro', `Erro: ${msg}`, 'error', 'sticky');
    }

    showSucesso() {
        this.toast('Sucesso', 'Sucesso', 'success', 'pester');
    }
    get userIsDev() {
        return userId === '00531000006UzZsAAK'
    }



    // Getter para classe do container
    get popupContainerClass() {
        return this.isPopupOpen ? 'popup-container show' : 'popup-container';
    }

    // Getter para classe do popup
    get popupClass() {
        return this.isPopupOpen ? 'pop-up show' : 'pop-up';
    }



    // Método para abrir popup
    abrirPopup() {
        this.isPopupOpen = true;

        // Prevent body scroll quando popup estiver aberto
        document.body.style.overflow = 'hidden';
    }

    // Método para fechar popup
    fecharPopup() {
        this.isPopupOpen = false;

        // Restore body scroll
        document.body.style.overflow = 'auto';
    }
    // Handle click no overlay (fora do popup)
    handleKeyDown(event) {
        if (event.key === 'Escape' && this.isPopupOpen) {
            this.fecharPopup();
        }
    }


    async devolverProdutoBtn() {
        this.isLoading = true;
        const tipo = this.sd.Tipo__c;
        console.log("Tipo: ", tipo);
        const status = this.sd.Status__c;
        console.log("Status: ", status);

        try {
            // Carregar itens disponíveis e já devolvidos em paralelo

            await this.queryOrderItens();
            await this.queryItensDaDevolucao();


            this.initializeItems();
            this.abrirPopup();

        } catch (error) {
            console.error('Erro ao abrir popup de devolução:', error);
            alert('Erro ao carregar itens do pedido. Tente novamente.');
        } finally {
            this.isLoading = false;

            /*   if (tipo === 'Total') {
                  this.returnItems = this.availableItems;
              } */

        }
    }

    async queryOrderItens() {
        const orderId = this.sd.Pedido__c;
        console.log('orderId:', orderId);

        if (!orderId) {
            console.warn('No orderId found');
            this.orderItens = [];
            return;
        }

        try {
            // Passar o recordId também
            await soqls.queryOrderItens(this, orderId, this.recordId, executeSoql, utils);
        } catch (e) {
            console.error('Erro ao carregar order items:', e);
            this.orderItens = [];
        }
    }

    async queryItensDaDevolucao() {
        const recordId = this.recordId;
        try {
            await soqls.queryItensDaDevolucao(this, recordId, executeSoql, utils);
        } catch (e) {
            console.error(e)
        }


    }
    // Handle click no overlay (fora do popup)r
    handleOverlayClick(event) {
        if (event.target.classList.contains('overlay')) {
            this.fecharPopup();
        }
    }

    get availableItemsCount() {
        return this.availableItems.length;
    }

    get returnItemsCount() {
        return this.returnItems.length;
    }

    get isAvailableItemsEmpty() {
        return this.availableItems.length === 0;
    }

    get isReturnItemsEmpty() {
        return this.returnItems.length === 0;
    }

    get hasReturnItems() {
        return this.returnItems.length > 0;
    }
    get totalReturnValue() {
        const total = this.returnItems.reduce((sum, item) => {
            const quantity = item.returnQuantity || item.quantity;
            return sum + (item.unitPrice * quantity);
        }, 0);
        return utils.formatarValor(total);
    }


    // Inicializa os itens (simula dados para exemplo)
    initializeItems() {
        // Os availableItems já foram carregados pela queryOrderItens (excluindo os já devolvidos)
        if (this.orderItens) {
            this.availableItems = [...this.orderItens];
        } else {
            this.availableItems = [];
        }

        // Os returnItems já foram carregados pela queryItensDaDevolucao

        if (!this.returnItems) {
            this.returnItems = [];
        }

        console.log("22", JSON.stringify(this.returnItems))

        console.log(`Inicializado - Disponíveis: ${this.availableItems.length}, Para devolver: ${this.returnItems.length}`);
    }

    // Move item da coluna disponível para devolução
    moveToReturn(event) {
        const itemId = event.currentTarget.dataset.itemId;
        const itemIndex = this.availableItems.findIndex(item => item.id === itemId);

        if (itemIndex !== -1) {
            const item = this.availableItems[itemIndex];

            // Adiciona propriedades para controle de quantidade de devolução
            const itemWithReturn = {
                ...item,
                returnQuantity: item.quantity, // Inicia com a quantidade máxima
                originalQuantity: item.quantity, // Mantém referência da quantidade original
                returnQuantityIsMin: item.quantity <= 1,
                returnQuantityIsMax: true
            };

            // Calcula o preço total baseado na quantidade de devolução
            itemWithReturn.totalPrice = item.unitPrice * itemWithReturn.returnQuantity;
            itemWithReturn.totalPriceFormatado = utils.formatarValor(itemWithReturn.totalPrice);

            // Remove da lista de disponíveis
            this.availableItems = this.availableItems.filter((_, index) => index !== itemIndex);

            // Adiciona na lista de devolução
            this.returnItems = [...this.returnItems, itemWithReturn];
        }
    }

    // Move item da coluna de devolução para disponível
    moveToAvailable(event) {
        const itemId = event.currentTarget.dataset.itemId;
        const itemIndex = this.returnItems.findIndex(item => item.id === itemId);

        if (itemIndex !== -1) {
            const item = this.returnItems[itemIndex];

            // Remove propriedades específicas de devolução e restaura item original
            const originalItem = {
                ...item,
                quantity: item.originalQuantity || item.quantity,
                totalPrice: item.unitPrice * (item.originalQuantity || item.quantity)
            };

            // Remove propriedades de controle de devolução
            delete originalItem.returnQuantity;
            delete originalItem.originalQuantity;
            delete originalItem.returnQuantityIsMin;
            delete originalItem.returnQuantityIsMax;
            delete originalItem.totalPriceFormatado;

            // Recalcula o totalPriceFormatado original
            originalItem.totalPriceFormatado = utils.formatarValor(originalItem.totalPrice);

            // Remove da lista de devolução
            this.returnItems = this.returnItems.filter((_, index) => index !== itemIndex);

            // Adiciona na lista de disponíveis
            this.availableItems = [...this.availableItems, originalItem];
        }
    }


    async confirmarDevolucao() {


        const itens = this.returnItems;
        const recordId = this.recordId;

        const a = window.confirm(`Devolvendo ${itens.length} itens.\nDeseja proceguir?`); { if (!a) { return } }

        try {
            if (this.isParcial) {
                const hasInvalidDescription = itens.some(item => item.Description === 'N/A');
                if (hasInvalidDescription) {
                    throw new Error("Número de séries são obrigatórios");
                }
            }
        } catch (e) {
            this.showErro(e.message);
            return;
        }
        if (!recordId || !itens || itens.length === 0) {
            console.log('Nenhum item selecionado para devolução');
            return;
        }

        console.log('Itens para devolver:', itens);

        try {
            const response = await this.salvarDados(itens, recordId);
            if (response === 200) {
                this.showSucesso();
                window.location.reload();
            }
        } catch (e) {
            this.showErro(e.message);
            console.error(e);
        }

        this.fecharPopup();
    }

    async salvarDados(itens, recordId) {
        this.isLoading = true;
        if (!itens || !recordId) {
            this.showErro('Erro');
            console.error(`itens: '${itens}', recordId: '${recordId}'`);
            return;
        }


        const url = 'https://workflowwebhook.hospcom.net/webhook/4835d646-c595-4049-8dc0-41013231155c';

        const body = {
            itens: itens,
            recordId: recordId
        };

        console.log("payload webhook: ", body);
        console.log("Enviando POST para salvar dados:", body);

        try {
            const response = await fetch(url, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(body)
            });

            if (!response.ok) {
                throw new Error(`HTTP error! status: ${response.status}`);
            }

            const result = response;
            console.log("Resposta do webhook:", result);

            // Remove this duplicate call since success is handled in confirmarDevolucao()
            // this.showSucesso();

            return response.status; // Return the status code (200)

        } catch (error) {
            console.error("Erro na requisição salvarDados:", error);
            this.showErro('Erro durante a requisição');
            throw error;
        } finally { this.isLoading = false; }
    }


    // Manipular mudança de quantidade
    moveToReturn(event) {
        const itemId = event.currentTarget.dataset.itemId;
        const itemIndex = this.availableItems.findIndex(item => item.id === itemId);

        if (itemIndex !== -1) {
            const item = this.availableItems[itemIndex];

            // Adiciona propriedades para controle de quantidade de devolução
            const itemWithReturn = {
                ...item,
                returnQuantity: item.quantity, // Inicia com a quantidade máxima
                originalQuantity: item.quantity, // Mantém referência da quantidade original
                returnQuantityIsMin: item.quantity <= 1,
                returnQuantityIsMax: true,
                Description: item.Description
            };

            // Calcula o preço total baseado na quantidade de devolução
            itemWithReturn.totalPrice = item.unitPrice * itemWithReturn.returnQuantity;
            itemWithReturn.totalPriceFormatado = utils.formatarValor(itemWithReturn.totalPrice);

            // Remove da lista de disponíveis
            this.availableItems = this.availableItems.filter((_, index) => index !== itemIndex);

            // Adiciona na lista de devolução
            this.returnItems = [...this.returnItems, itemWithReturn];
        }
    }

    handleQuantityChange(event) {
        const itemId = event.target.dataset.itemId;
        const newQuantity = parseInt(event.target.value);

        this.updateItemQuantity(itemId, newQuantity);
    }

    // Diminuir quantidade
    decreaseQuantity(event) {
        const itemId = event.currentTarget.dataset.itemId;
        const item = this.returnItems.find(item => item.id === itemId);

        if (item && item.returnQuantity > 1) {
            this.updateItemQuantity(itemId, item.returnQuantity - 1);
        }
    }

    // Aumentar quantidade
    increaseQuantity(event) {
        const itemId = event.currentTarget.dataset.itemId;
        const item = this.returnItems.find(item => item.id === itemId);

        if (item && item.returnQuantity < item.originalQuantity) {
            this.updateItemQuantity(itemId, item.returnQuantity + 1);
        }
    }

    // Método centralizado para atualizar quantidade
    updateItemQuantity(itemId, newQuantity) {
        const itemIndex = this.returnItems.findIndex(item => item.id === itemId);

        if (itemIndex !== -1) {
            const item = this.returnItems[itemIndex];
            const maxQuantity = item.originalQuantity;

            // Valida os limites
            if (newQuantity < 1) newQuantity = 1;
            if (newQuantity > maxQuantity) newQuantity = maxQuantity;

            // Atualiza o item
            const updatedItem = {
                ...item,
                returnQuantity: newQuantity,
                returnQuantityIsMin: newQuantity <= 1,
                returnQuantityIsMax: newQuantity >= maxQuantity,
                totalPrice: item.unitPrice * newQuantity
            };

            // Atualiza o preço total formatado
            updatedItem.totalPriceFormatado = utils.formatarValor(updatedItem.totalPrice);

            // Atualiza a lista
            this.returnItems = this.returnItems.map((returnItem, index) =>
                index === itemIndex ? updatedItem : returnItem
            );
        }
    }
    handleSerialNumberChange(event) {
        const itemId = event.currentTarget.dataset.itemId;
        const newSerialNumber = event.detail.value;

        const itemIndex = this.returnItems.findIndex(item => item.id === itemId);
        if (itemIndex !== -1) {
            const item = this.returnItems[itemIndex];

            const updatedItem = {
                ...item,
                Description: newSerialNumber
            };

            this.returnItems = this.returnItems.map((returnItem, index) =>
                index === itemIndex ? updatedItem : returnItem
            );
        }
    }
    throwPdf(){
         window.open('https://hospcom--c.vf.force.com/apex/PDF_Itens_da_solicitacao_de_devolucao?scontrolCaching=1&id=' + this.recordId, '_blank');
    }


}