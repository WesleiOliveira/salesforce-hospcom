import { LightningElement, api, wire, track } from 'lwc';
import getAtivosByContratoId from '@salesforce/apex/AtivosDoContratoController.getAtivosByContratoId';
import substituirAtivo from '@salesforce/apex/AtivosDoContratoController.substituirAtivo';
import updateEquipamentoStatus from '@salesforce/apex/AtivosDoContratoController.updateEquipamentoStatus';
import { refreshApex } from '@salesforce/apex';

export default class GerenciaAtivosContrato extends LightningElement {
    @api recordId;
    @track ativos;
    @track error;
    @track selectedAtivos = [];
    @track showDatePicker = false;
    @track selectedDate;
    @track showSubstituirInput = false;
    @track substituirId;
    @track newSerialNumber;
    @track dataSubstituicao;
    actionType;

    @wire(getAtivosByContratoId, { contratoId: '$recordId' })
    wiredAtivos(result) {
        this.wiredAtivosResult = result;
        if (result.data) {
            this.ativos = result.data.map(ativo => {
                return {
                    ...ativo,
                    isSelected: false // Adicionando campo de seleção
                };
            });
            this.error = undefined;
        } else if (result.error) {
            this.error = result.error;
            this.ativos = undefined;
        }
    }

    handleRowSelection(event) {
        const selectedRows = event.target.selectedRows;
        this.selectedAtivos = selectedRows;
    }

    handleRemoveSelecionados() {
        this.actionType = 'remover';
        this.showDatePicker = true;
    }

    handleEntregarSelecionados() {
        this.actionType = 'entregar';
        this.showDatePicker = true;
    }

    handleDateChange(event) {
        this.selectedDate = event.target.value;
    }

    handleConfirm() {
        const status = this.actionType === 'entregar';
        updateEquipamentoStatus({ ativoIds: this.selectedAtivos.map(ativo => ativo.Id), status, dataEntregaOuRetorno: this.selectedDate })
            .then(() => {
                this.showDatePicker = false;
                return refreshApex(this.wiredAtivosResult);
            })
            .catch(error => {
                this.error = error;
            });
    }

    handleSubstituirClick(event) {
        this.substituirId = event.target.dataset.id;
        this.showSubstituirInput = true;
    }

    handleSerialNumberChange(event) {
        this.newSerialNumber = event.target.value;
    }

    handleDataSubstituicaoChange(event) {
        this.dataSubstituicao = event.target.value;
    }

    handleSubstituirConfirm() {
        substituirAtivo({ ativoId: this.substituirId, novoNumeroDeSerie: this.newSerialNumber, dataSubstituicao: this.dataSubstituicao })
            .then(() => {
                this.showSubstituirInput = false;
                this.newSerialNumber = '';
                this.dataSubstituicao = '';
                return refreshApex(this.wiredAtivosResult);
            })
            .catch(error => {
                this.error = error;
            });
    }

    handleSelectAll(event) {
        const isChecked = event.target.checked;
        this.ativos.forEach(ativo => {
            ativo.isSelected = isChecked;
        });
        this.selectedAtivos = isChecked ? [...this.ativos] : [];
    }

    handleSelectOne(event) {
        const ativoId = event.target.dataset.id;
        const isChecked = event.target.checked;
        const selectedAtivo = this.ativos.find(ativo => ativo.Id === ativoId);
        if (isChecked) {
            this.selectedAtivos.push(selectedAtivo);
        } else {
            this.selectedAtivos = this.selectedAtivos.filter(ativo => ativo.Id !== ativoId);
        }
        selectedAtivo.isSelected = isChecked;
    }

    closeModal() {
        this.showSubstituirInput = false;
        this.showDatePicker = false;
    }
}