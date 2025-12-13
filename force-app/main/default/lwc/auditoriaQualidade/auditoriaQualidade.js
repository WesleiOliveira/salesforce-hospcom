import { LightningElement, api, wire, track } from 'lwc';
import buscarAuditoria from '@salesforce/apex/AuditoriaQualidadeController.buscarAuditoria';
import salvarAuditoria from '@salesforce/apex/AuditoriaQualidadeController.salvarAuditoria';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class AuditoriaQualidade extends LightningElement {

    @api recordId;
    @track situacao;
    @track data;
    @track observacoes;
    @track auditado;
    @track objectName;
    @track recordName;
    @track botão = false;
    @track loading = false;

    situacaoOptions = [
        { label: 'Conforme', value: 'Conforme' },
        { label: 'Não Conforme' , value: 'Não Conforme' }
    ];

    connectedCallback() {
        this.loading = true;
        console.log('connectedCallback:' + this.recordId);
        buscarAuditoria({
            recordId: this.recordId
        }).then(result => {
            this.situacao = result.Situacao_Auditoria__c;
            this.data = result.Data_Auditoria__c;
            this.observacoes = result.Observacoes_Auditoria__c;
            this.auditado = result.Auditado__c;
            this.loading = false;
            console.log('result:' + JSON.stringify(result));
        })
        .catch(error => {
            console.log('error:' + JSON.stringify(error));
        })  
    }

    handleSave(){
        this.loading = true;
        salvarAuditoria({
            recordId: this.recordId,
            situacao: this.situacao,
            observacao: this.observacoes,
            dataAuditoria: this.data,
            auditado: true

        })
        .then(result => {
            this.loading = false;
            console.log('result:' + JSON.stringify(result));
            this.auditado = true;
            this.botao = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Sucesso',
                    message: 'Auditoria salva com sucesso!',
                    variant: 'success'
                })
            );
        })
        .catch(error => {
            console.log('error:' + JSON.stringify(error));
            this.loading = false;
            this.auditado = false;
            this.botao = true;
            let msg = this.getErrorMessage(error);

            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Erro ao salvar auditoria',
                    message: msg,
                    variant: 'error'
                })
            )
        })

    }

    handleSituacaoChange(event) {
        this.situacao = event.detail.value;
        this.verificarRequeridos();
    }

    handleObsChange(event) {
        this.observacoes = event.target.value;
        this.verificarRequeridos();
    }

    handleDataChange(event) {
        this.data = event.target.value;
        this.verificarRequeridos();
    }

    verificarRequeridos(){
        if (this.situacao == null || this.data == null ||  this.observacoes == null || this.observacoes == '' || this.data == '' || this.situacao == ''){
            this.botao = false;     
        }else{
            this.botao = true;
        }
    }

    getErrorMessage(error) {
        if (!error) return 'Erro desconhecido';

        // Se tiver body
        if (error.body) {
            // 1. Field Errors (ex.: FIELD_CUSTOM_VALIDATION_EXCEPTION)
            if (error.body.fieldErrors) {
                const fieldKeys = Object.keys(error.body.fieldErrors);
                if (fieldKeys.length > 0) {
                    const firstField = error.body.fieldErrors[fieldKeys[0]];
                    if (firstField && firstField.length > 0) {
                        return firstField[0].message;
                    }
                }
            }

            // 2. Page Errors
            if (error.body.pageErrors && error.body.pageErrors.length > 0) {
                return error.body.pageErrors[0].message;
            }

            // 3. Mensagem simples
            if (error.body.message) {
                return error.body.message;
            }
        }

        // 4. Mensagem no próprio erro
        if (error.message) {
            return error.message;
        }

        // 5. Fallback
        return 'Ocorreu um erro inesperado';
    }
            
}