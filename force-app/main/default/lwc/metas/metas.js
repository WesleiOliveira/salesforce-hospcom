import { LightningElement, track, wire } from 'lwc';
import getGoals from '@salesforce/apex/meta.getGoals';
import saveGoals from '@salesforce/apex/meta.saveGoals';
import executeSoql from '@salesforce/apex/ApexHelperController.executeSoql';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class GoalSpreadsheet extends LightningElement {
    @track goals = [];
    @track vendedorId;
    @track vendedorOptions = [];
    @track linhas = [];
    @track novaLinha = '';
    @track metasMap = new Map();
    @track meses = [
        { label: 'Jan', inicio: '2025-01-01', final: '2025-01-31' },
        { label: 'Feb', inicio: '2025-02-01', final: '2025-02-28' },
        { label: 'Mar', inicio: '2025-03-01', final: '2025-03-31' },
        { label: 'Apr', inicio: '2025-04-01', final: '2025-04-30' },
        { label: 'May', inicio: '2025-05-01', final: '2025-05-31' },
        { label: 'Jun', inicio: '2025-06-01', final: '2025-06-30' },
        { label: 'Jul', inicio: '2025-07-01', final: '2025-07-31' },
        { label: 'Aug', inicio: '2025-08-01', final: '2025-08-31' },
        { label: 'Sep', inicio: '2025-09-01', final: '2025-09-30' },
        { label: 'Oct', inicio: '2025-10-01', final: '2025-10-31' },
        { label: 'Nov', inicio: '2025-11-01', final: '2025-11-30' },
        { label: 'Dec', inicio: '2025-12-01', final: '2025-12-31' }
    ];

    connectedCallback() {
        this.loadVendedores();
    }

    loadVendedores() {
        executeSoql({ soql: "SELECT ID, NAME FROM USER WHERE PROFILE.NAME = 'Executivo de Contas' AND IsActive = true" })
            .then(result => {
                this.vendedorOptions = result.map(user => ({ label: user.Name, value: user.Id }));
            })
            .catch(error => {
                console.error(error);
            });
    }

    @wire(getGoals, { vendedorId: '$vendedorId' })
    wiredGoals({ error, data }) {
        if (data) {
            this.goals = data;
            this.linhas = [...new Set(data.map(goal => goal.Linha__c))];
            this.metasMap.clear();
            data.forEach(goal => {
                this.metasMap.set(`${goal.Linha__c}-${goal.Inicio__c}`, goal.Meta__c);
            });
        } else if (error) {
            console.error(error);
        }
    }

    handleVendedorChange(event) {
        this.vendedorId = event.detail.value;
    }

    handleNovaLinhaChange(event) {
        this.novaLinha = event.detail.value;
    }

    handleAdicionarLinha() {
        if (this.novaLinha && !this.linhas.includes(this.novaLinha)) {
            this.linhas = [...this.linhas, this.novaLinha];
            this.novaLinha = '';
        }
    }

    handleInputChange(event) {
        const { dataset, value } = event.target;
        const { linha, inicio } = dataset;
        const goal = this.goals.find(g => g.Linha__c === linha && g.Inicio__c === inicio);
        if (goal) {
            goal.Meta__c = value;
        } else {
            this.goals.push({
                Vendedor__c: this.vendedorId,
                Linha__c: linha,
                Inicio__c: inicio,
                Final__c: this.meses.find(m => m.inicio === inicio).final,
                Meta__c: value
            });
        }
        this.metasMap.set(`${linha}-${inicio}`, value);
    }

    handleSave() {
        saveGoals({ goals: this.goals })
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Metas salvas com sucesso!',
                        variant: 'success'
                    })
                );
            })
            .catch(error => {
                console.error(error);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Erro',
                        message: 'Erro ao salvar metas.',
                        variant: 'error'
                    })
                );
            });
    }
}