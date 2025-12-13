import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import saveAvaliacao from '@salesforce/apex/CienteAvaliacaoExperienciaController.saveAvaliacao';
import getAvaliacao from '@salesforce/apex/CienteAvaliacaoExperienciaController.getAvaliacao';

export default class CienteAvaliacaoExperiencia extends LightningElement {
    @api recordId;

    @track periodo;
    @track nomeColaborador;
    @track dataHoje;
    @track blockEdicao = false;
    @track vizualizavel = false;


    @track ciente = false;

    connectedCallback() {
        this.buscarAvaliacao();
    }

    handleCheckbox(event) {
        this.ciente = event.target.checked;
        console.log('Ciente:', this.ciente);
    }

    handleSave() {
        console.log('dataHoje:', this.dataHoje);
        if (!this.ciente) {
            this.showToast('Ciente?', 'Por favor, marque a caixa para confirmar o Ciente.', 'error');
            return;
        } else {
        saveAvaliacao({ recordId: this.recordId})
           
        .then(result => {
            console.log(result);
            this.blockEdicao = true;
        })
        .catch(error => {
            console.log(error);
        })};
    }

    buscarAvaliacao() {
        console.log('buscarAvaliacao: ' + this.recordId);
        getAvaliacao({ recordId: this.recordId })
            .then(result => {
                console.log(result.Aprovado__c);
                console.log('Aprovado: ' + result.Aprovado__c == 'Sim');
                this.periodo = result.Periodo_da_Avaliacao__c;
                this.nomeColaborador = result.NotificacaoNomeColaborador__c;
                this.ciente = result.Ciente__c;
                if(result.Aprovado__c == 'Sim' || result.Aprovado__c.toString() == 'Não'){
                    this.vizualizavel = true;
                }
                
                if(result.Ciente__c){
                    this.blockEdicao = true;
                    this.dataHoje = result.Data_de_Ciencia__c;
                }else{
                    this.dataHoje = new Date().toLocaleDateString();
                }
            })
            .catch(error => { 
                this.error = error;
            })}

    showToast(titulo, messagem, variante) {
            const event = new ShowToastEvent({
                title: titulo,
                message: messagem,
                variant: variante,
                mode: 'dismissible' 
            });
            this.dispatchEvent(event);
        }
    
}