import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import saveRespostas from '@salesforce/apex/FormularioAvaliacaoExperienciaController.saveRespostas';
import getRespostas from '@salesforce/apex/FormularioAvaliacaoExperienciaController.getRespostas';

export default class FormularioAvaliacaoExperiencia extends LightningElement {

    @api recordId;

    @track blockEdicao = false;
    @track justificativaObrigatoria = false;
    @track periodo;
    @track aprovado;

    options = [
        { label: 'Não Atendeu', value: 'Não Atendeu' },
        { label: 'Atendeu Parcialmente' , value: 'Atendeu Parcialmente' },
        { label: 'Atendeu Totalmente', value: 'Atendeu Totalmente' },
        { label: 'Superou', value: 'Superou' }
    ];

    optionsAprovado = [
        { label: 'Sim', value: 'Sim' },
        { label: 'Não', value: 'Não' }
    ];

    @track respostas = {
        Pergunta_1__c: '',
        Pergunta_2__c: '',
        Pergunta_3__c: '',
        Pergunta_4__c: '',
        Pergunta_5__c: '',
        Pergunta_6__c: '',
        Pergunta_7__c: '',
        Pergunta_8__c: ''
    };

    @track justificativas = {
        Justificativa_1__c: '',
        Justificativa_2__c: '',
        Justificativa_3__c: '',
        Justificativa_4__c: '',
        Justificativa_5__c: '',
        Justificativa_6__c: '',
        Justificativa_7__c: '',
        Justificativa_8__c: ''
    }

    @track observacoes;

    connectedCallback() {
        this.buscarRespostas();

    }



    handleChange(event) {
        const { name, value } = event.target;
        this.respostas[name] = value;
    }

    handleJustificativa(event){
        const { name, value } = event.target;
        this.justificativas[name] = value;
    }

    handleAprovado(event) {
        const { value } = event.target;
        this.aprovado = value;
    }

    handleObservacao(event) {
        this.observacoes = event.target.value;
    }

    handleSave() {
        console.log('Aprovado: ' + this.aprovado)
        if (this.verificarPrenchimento() || this.aprovado == undefined) {
            this.showToast('Atenção', 'Preencha todos as respostas e justificativas!', 'error', );
            return;
        } else {
            console.log(JSON.stringify(this.respostas));
            saveRespostas({ recordId: this.recordId, 
                            respostasJSON: JSON.stringify(this.respostas), 
                            justificativasJSON: JSON.stringify(this.justificativas),
                            observacoes: this.observacoes,
                            aprovado: this.aprovado })
                .then(result => {
                    console.log(result);
                    this.blockEdicao = true;
                })
                .catch(error => {
                    this.error = error;
                })
        }
    }

    buscarRespostas() {
        getRespostas({ recordId: this.recordId })
            .then(result => {
                console.log(result);
                if (result.Avaliacao_Finalizada__c) {
                    this.blockEdicao = true;
                }
                this.respostas.Pergunta_1__c = result.Pergunta_1__c;
                this.respostas.Pergunta_2__c = result.Pergunta_2__c;
                this.respostas.Pergunta_3__c = result.Pergunta_3__c;
                this.respostas.Pergunta_4__c = result.Pergunta_4__c;
                this.respostas.Pergunta_5__c = result.Pergunta_5__c;
                this.respostas.Pergunta_6__c = result.Pergunta_6__c;
                this.respostas.Pergunta_7__c = result.Pergunta_7__c;
                this.respostas.Pergunta_8__c = result.Pergunta_8__c;

                this.justificativas.Justificativa_1__c = result.Justificativa_1__c;
                this.justificativas.Justificativa_2__c = result.Justificativa_2__c;
                this.justificativas.Justificativa_3__c = result.Justificativa_3__c;
                this.justificativas.Justificativa_4__c = result.Justificativa_4__c;
                this.justificativas.Justificativa_5__c = result.Justificativa_5__c;
                this.justificativas.Justificativa_6__c = result.Justificativa_6__c;
                this.justificativas.Justificativa_7__c = result.Justificativa_7__c;
                this.justificativas.Justificativa_8__c = result.Justificativa_8__c;

                this.periodo = result.Periodo_da_Avaliacao__c;
                this.aprovado = result.Aprovado__c;

                this.observacoes = result.Observacoes__c;
            })
            .catch(error => {
                this.error = error;
            })
    }

    showToast(titulo, messagem, variante) {
        const event = new ShowToastEvent({
            title: titulo,
            message: messagem,
            variant: variante,
            mode: 'dismissible' 
        });
        this.dispatchEvent(event);
    }

    verificarPrenchimento(){
        console.log('Aprovado: ' + this.aprovado);
       // Verifica se todas as respostas estão preenchidas
        const respostasVazias = Object.values(this.respostas).some(resp => !resp || resp.trim() === '');

        // Verifica se justificativas obrigatórias estão preenchidas
        let justificativaObrigatoriaVazia = false;

        for (let i = 1; i <= 8; i++) {
            const resposta = this.respostas[`Pergunta_${i}__c`];
            const justificativa = this.justificativas[`Justificativa_${i}__c`];

            // Se a resposta for diferente de "Atendeu Totalmente", a justificativa é obrigatória
            if (resposta !== 'Atendeu Totalmente') {
                if (!justificativa || justificativa.trim() === '') {
                    justificativaObrigatoriaVazia = true;
                    break;
                }
            }
        }

        return respostasVazias || justificativaObrigatoriaVazia;

    }
}