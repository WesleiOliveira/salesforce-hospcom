import { LightningElement, track, wire } from 'lwc';
import getBacklog from '@salesforce/apex/KanbanBacklogController.getBacklog';
import updateStatus from '@salesforce/apex/KanbanBacklogController.updateStatus';
import { refreshApex } from '@salesforce/apex';
import { NavigationMixin } from 'lightning/navigation';

const STATUS_COLUMNS = [
    'Novo',
    'Em Refinamento',
    'Em Desenvolvimento',
    'Analise de Qualidade',
    'Finalizado',
    'Recusado'
];

export default class KanbanBacklog extends NavigationMixin(LightningElement) {
    @track columns = [];
    @track devs = [];
    @track tipos = [];
    @track departamentos = [];
    @track devSelecionado = '';
    @track tipoSelecionado = '';
    @track departamentoSelecionado = '';
    @track cssClass = '';
    draggedRecordId;
    wiredResult;
    allRecords = [];

    @wire(getBacklog)
    wiredBacklog(result) {
        this.wiredResult = result;
        if (result.data) {
            this.allRecords = result.data;
            this.prepararDados(result.data);
        } else if (result.error) {
            console.error(result.error);
        }
    }

    prepararDados(data) {
        const grouped = {};
        STATUS_COLUMNS.forEach(status => grouped[status] = []);
        const devs = new Set();
        const tipos = new Set();
        const departamentos = new Set();

        data.forEach(record => {
            const status = record.Status__c || 'Novo';
            const nomeDev = record.Atribuido__r?.Name;
            const tipo = record.Tipo__c;
            const departamento = record.Departamento__c;

            // filtros aplicados
            const deveMostrar =
                (!this.devSelecionado || nomeDev === this.devSelecionado) &&
                (!this.tipoSelecionado || tipo === this.tipoSelecionado) &&
                (!this.departamentoSelecionado || departamento === this.departamentoSelecionado);

            if (deveMostrar && grouped[status]) {
                grouped[status].push({
                    ...record,
                    isProjeto: record.Tipo__c === 'Projeto'
                });
            }

            if (nomeDev) devs.add(nomeDev);
            if (tipo) tipos.add(tipo);
            if (departamento) departamentos.add(departamento);
        });

        this.columns = STATUS_COLUMNS.map(status => ({
            status,
            records: grouped[status]
        }));

        this.devs = [{ label: 'Todos', value: '' }, ...Array.from(devs).map(nome => ({
            label: nome,
            value: nome
        }))];

        this.tipos = [{ label: 'Todos', value: '' }, ...Array.from(tipos).map(tipo => ({
            label: tipo,
            value: tipo
        }))];

        this.departamentos = [{ label: 'Todos', value: '' }, ...Array.from(departamentos).map(departamento => ({
            label: departamento,
            value: departamento
        }))];
    }

    handleDragStart(event) {
        this.draggedRecordId = event.currentTarget.dataset.id;
    }

    handleDragOver(event) {
        event.preventDefault();
    }

    handleDrop(event) {
        event.preventDefault();
        const newStatus = event.currentTarget.dataset.status;
        const recordId = this.draggedRecordId;
        if (!recordId || !newStatus) return;

        updateStatus({ recordId, newStatus })
            .then(() => {
                this.draggedRecordId = null;
                return refreshApex(this.wiredResult);
            })
            .catch(error => {
                console.error('Erro ao atualizar status:', error);
            });
    }

    handleDev(event) {
        this.devSelecionado = event.detail.value;
        this.prepararDados(this.allRecords);
    }

    handleTipo(event) {
        this.tipoSelecionado = event.detail.value;
        this.prepararDados(this.allRecords);
    }

    handleDepartamento(event) {
        this.departamentoSelecionado = event.detail.value;
        this.prepararDados(this.allRecords);
    }

    navigateToRecord(event) {
        const idTkt = event.target.closest('.kanban-card').dataset.id;

        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: idTkt,
                objectApiName: 'Backlog__c',
                actionName: 'view'
            }
        });
    }

    navigateToNewCasePage() {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Backlog__c',
                actionName: 'new'
            },
        });
    }

    handleRefresh() {
        refreshApex(this.wiredResult);
    }
}