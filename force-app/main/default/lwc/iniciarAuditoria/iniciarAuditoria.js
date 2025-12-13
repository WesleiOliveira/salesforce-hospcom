import { LightningElement, track, wire } from 'lwc';
import userId from '@salesforce/user/Id';
import fontAwesome from '@salesforce/resourceUrl/fontAwesome';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
import JQuery from '@salesforce/resourceUrl/JQuery';
import { CurrentPageReference } from 'lightning/navigation';
import * as AuditoriaHelper from './elements/Auditoria';
import * as secaoComPerguntasHelper from './elements/secaoComPerguntas';
import { registrarRespostas } from './elements/respostas';
import executeSoql from '@salesforce/apex/ApexHelperController.executeSoql';

import * as utils from './utils';

export default class IniciarAuditoria extends LightningElement {
    @track disponivelParaAuditar = false;
    @track auditoria = {};
    @track secaoComPerguntas = [];
    modalPreenchido = false;
    modal = false;
    recordId;
    @track isLoading = false;

    showSpinner() {
        this.isLoading = true;
    }

    hideSpinner() {
        this.isLoading = false;
    }

    @wire(CurrentPageReference)
    setCurrentPageReference(currentPageReference) {
        console.log('currentPageReference:', currentPageReference);
        if (currentPageReference) {
            if (currentPageReference.attributes && currentPageReference.attributes.recordId) {
                this.recordId = currentPageReference.attributes.recordId;
            } else if (currentPageReference.state && currentPageReference.state.c__recordId) {
                this.recordId = currentPageReference.state.c__recordId;
            } else if (currentPageReference.state && currentPageReference.state.recordId) {
                this.recordId = currentPageReference.state.recordId;
            }

            if (!this.recordId) {
                utils.showErro(this, "recordId não encontrado");
                return;
            }
            console.log('recordId capturado:', this.recordId);
        }
    }

    async connectedCallback() {
        try {
            await loadScript(this, JQuery);
            await loadStyle(this, fontAwesome + '/css/font-awesome.min.css');
            console.log("userId: ", userId);

            if (!this.recordId) {
                utils.showErro("recordId não disponível no connectedCallback");
                return;
            }

            const auditoriaData = await AuditoriaHelper.load(executeSoql, this.recordId);
            console.log("Auditoria carregada: ", JSON.stringify(auditoriaData));

            if (auditoriaData && auditoriaData.disponivelParaAuditar) {
                this.auditoria = auditoriaData;
                this.disponivelParaAuditar = auditoriaData.disponivelParaAuditar || false;
            }
        } catch (error) {
            console.error("Erro completo:", error);
            utils.showErro(error.message || "Erro desconhecido ao carregar auditoria");
        }
    }
    async iniciarAuditoria() {
        this.showSpinner();
        console.log("Iniciando auditoria...");

        if (userId != this.auditoria.proprietario) {
            utils.showErro("Somente o proprietário da auditoria pode iniciar a auditoria");
            this.hideSpinner();
            return;
        }

        const tipoAuditoria = this.auditoria.tipoDaAuditoria

        console.log("Tipo da auditoria: ", tipoAuditoria);

        if (!tipoAuditoria || tipoAuditoria == 'Error') {
            utils.showErro("Tipo não encontrado");
            this.hideSpinner();
            return
        }
        this.abrirModal();


        if (!this.modalPreenchido) {
            try {

                const secaoComPerguntasData = await secaoComPerguntasHelper.load(executeSoql, tipoAuditoria);

                console.log('Dados retornados do helper:', secaoComPerguntasData);

                if (!secaoComPerguntasData || secaoComPerguntasData.length == 0) {
                    throw new Error("Nenhuma seção encontrada");
                }

                this.secaoComPerguntas = secaoComPerguntasData;
                this.modalPreenchido = true;

                console.log('Seções carregadas com sucesso:', this.secaoComPerguntas);

            } catch (e) {
                console.error('Erro completo:', e);
                utils.showErro(e.message);

            }
            this.hideSpinner();
        }
    }

    get temObservacao() {
        return this.auditoria.observacao && this.auditoria.observacao !== 'Não encontrado';
    }
    toggleHeader() {
        console.log('Tentando encontrar modalHeader...');

        // Tente primeiro pela classe
        const modalHeader = this.template.querySelector('.modal-header');
        console.log('modalHeader por classe:', modalHeader);

        if (modalHeader) {
            modalHeader.classList.toggle('collapsed');
            console.log('Toggle aplicado! Classes:', modalHeader.classList.toString());
        } else {
            console.error('modalHeader NÃO encontrado!');

            // Debug melhor - lista elementos específicos
            const overlay = this.template.querySelector('.overlay');
            const modal = this.template.querySelector('.modal');
            console.log('Overlay:', overlay);
            console.log('Modal:', modal);
            console.log('Modal está aberto?', this.modal);
        }
    }
    abrirModal() {
        utils.travaPageReload();
        // Bloqueia scroll do body
        const body = document.querySelector('.siteforcePrmBody') || document.body;
        body.style.overflow = 'hidden';
        this.modal = true;


    }

    fecharModal() {
        const temRespostas = this.template.querySelectorAll('input[type="radio"]:checked').length > 0;
        const modalHeader = this.template.querySelector('#modalHeader');
        const body = document.querySelector('.siteforcePrmBody') || document.body;

        console.log("tem respostas? ", temRespostas)

        // Se não está salvando E tem respostas preenchidas, perguntar ao usuário
        if (temRespostas && !confirm('Tem certeza que deseja fechar? Os dados não salvos serão perdidos.')) {
            this.hideSpinner();
            return
        }

        // Liberar scroll do body
        body.style.overflow = 'auto';

        if (modalHeader) {
            modalHeader.classList.remove('collapsed');
        }

        this.modal = false;

        utils.removeTravaPageReload();
    }


    confirmarAuditoria() {
        // Verificar se todas as perguntas foram respondidas
        const validacao = this.validarRespostas();

        if (!validacao.completo) {
            utils.showErro(`Por favor, responda todas as perguntas. Faltam ${validacao.perguntasNaoRespondidas.length} pergunta(s).`);

            // Destacar perguntas não respondidas e rolar até a primeira
            this.destacarPerguntasNaoRespondidas(validacao.perguntasNaoRespondidas);
 this.hideSpinner();
            return;
        }

        // Coletar respostas
        const respostas = this.coletarRespostas();
        console.log('Respostas coletadas:', respostas);

        const quantidadeDeNC = respostas.filter(resposta => resposta.resposta === 'NC').length;
        if (quantidadeDeNC > 0) {
            utils.showAlerta(`Houve um total de ${quantidadeDeNC} NCs, por favor anexar imagens em relacionado`);
        }

        // Processar respostas...
        this.salvarRespostas(respostas);
    }

    validarRespostas() {
        const todasPerguntas = [];
        const perguntasNaoRespondidas = [];

        // Coletar todas as perguntas
        this.secaoComPerguntas.forEach(secao => {
            secao.perguntas.forEach(pergunta => {
                todasPerguntas.push({
                    id: pergunta.id,
                    radioName: pergunta.radioName,
                    perguntaTexto: pergunta.pergunta
                });
            });
        });

        // Verificar quais não foram respondidas
        todasPerguntas.forEach(pergunta => {
            const radio = this.template.querySelector(`input[name="${pergunta.radioName}"]:checked`);

            if (!radio) {
                perguntasNaoRespondidas.push(pergunta);
            }
        });

        return {
            completo: perguntasNaoRespondidas.length === 0,
            totalPerguntas: todasPerguntas.length,
            perguntasRespondidas: todasPerguntas.length - perguntasNaoRespondidas.length,
            perguntasNaoRespondidas: perguntasNaoRespondidas
        };
    }

    destacarPerguntasNaoRespondidas(perguntasNaoRespondidas) {
        // Remover destaques anteriores
        const cardsAnteriores = this.template.querySelectorAll('.card-pergunta.nao-respondida');
        cardsAnteriores.forEach(card => {
            card.classList.remove('nao-respondida');
        });

        // Adicionar destaque nas perguntas não respondidas
        perguntasNaoRespondidas.forEach(pergunta => {
            const card = this.template.querySelector(`.card-pergunta[data-id="${pergunta.id}"]`);

            if (card) {
                card.classList.add('nao-respondida');
            }
        });

        // Rolar até a primeira pergunta não respondida
        if (perguntasNaoRespondidas.length > 0) {
            const primeiraCard = this.template.querySelector(`.card-pergunta[data-id="${perguntasNaoRespondidas[0].id}"]`);

            if (primeiraCard) {
                // Scroll suave até o elemento
                primeiraCard.scrollIntoView({
                    behavior: 'smooth',
                    block: 'center'
                });

                // Opcional: adicionar animação de "shake" ou pulsar
                primeiraCard.classList.add('shake');
                setTimeout(() => {
                    primeiraCard.classList.remove('shake');
                }, 600);
            }
        }
    }

    coletarRespostas() {
        const respostas = [];
        const radios = this.template.querySelectorAll('input[type="radio"]:checked');

        radios.forEach(radio => {
            const cardPergunta = radio.closest('.card-pergunta');
            const perguntaId = cardPergunta?.dataset.id;

            if (perguntaId) {
                respostas.push({
                    perguntaId: perguntaId,
                    resposta: radio.value
                });
            }
        });

        return respostas;
    }

    handleRadioChange(event) {
        const card = event.target.closest('.card-pergunta');

        if (card && card.classList.contains('nao-respondida')) {
            card.classList.remove('nao-respondida');
        }

    }
    async salvarRespostas(respostas) {
        console.log(">>> salvarRespostas FOI CHAMADO aa");
        try {
            this.showSpinner();

            // Implementar lógica de salvamento
            console.log('Salvando respostas:', respostas);

            const payload = {
                respostas: respostas,
                auditoria_id: this.recordId,
                user_id: userId
            }
            await registrarRespostas(payload);

            utils.showSucesso('Respostas salvas com sucesso!');
            this.disponivelParaAuditar = false;

            const modalHeader = this.template.querySelector('#modalHeader');
            const body = document.querySelector('.siteforcePrmBody') || document.body;



            // Liberar scroll do body
            body.style.overflow = 'auto';
            if (modalHeader) {
                modalHeader.classList.remove('collapsed');
            }
            utils.removeTravaPageReload();
            this.modal = false;
        } catch (error) {
            console.error('Erro ao salvar:', error);
            utils.showErro('Erro ao salvar as respostas: ' + error.message);
        } finally {
            this.hideSpinner();
        }
    }

}