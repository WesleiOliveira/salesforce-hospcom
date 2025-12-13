import { LightningElement, wire, track } from 'lwc';
import getDashboardData from '@salesforce/apex/DashboardBacklogController.getDashboardData';
import { NavigationMixin } from 'lightning/navigation';
import chartjs from '@salesforce/resourceUrl/ChartLWC';
import fontAwesome from '@salesforce/resourceUrl/fontAwesome';
import { loadScript, loadStyle  } from 'lightning/platformResourceLoader';

export default class DashboardBacklog extends NavigationMixin(LightningElement) {
    @track data = {
        totalAbertos: 0,
        totalEmAndamento: 0,
        ticketsRapidos: 0,
        totalFinalizados: 0,
        recentes: [],
        chartData: []
    };

    meses = new Map([
        [1, "Janeiro"],
        [2, "Fevereiro"],
        [3, "Março"],
        [4, "Abril"],
        [5, "Maio"],
        [6, "Junho"],
        [7, "Julho"],
        [8, "Agosto"],
        [9, "Setembro"],
        [10, "Outubro"],
        [11, "Novembro"],
        [12, "Dezembro"]
    ]);
    chart;
    chartStatus;
    chartDepartamento;
    chartExcedidos;
    chartjsInitialized = false;

    async connectedCallback() {
        try {
            // Busca dados do Apex
            const apexData = await getDashboardData();
            this.data = apexData;

            // Carrega Chart.js
            await Promise.all([
                loadScript(this, chartjs),
                loadStyle(this, fontAwesome + '/css/font-awesome.min.css') // caminho dentro do zip do Static Resource
            ]);
            this.chartjsInitialized = true;

            // Renderiza gráfico
            this.renderChart();
            this.renderChartStatus();
            this.renderChartDepartamento();
            this.renderChartExcedidos();

        } catch (error) {
            console.error('Erro ao carregar dashboard:', error);
        }
    }

    renderChart() {
        if (!this.chartjsInitialized || !this.data) return;

        const ctx = this.template.querySelector('.lineChart');
        if (!ctx) return;

        // Destrói gráfico antigo se existir
        if (this.chart) this.chart.destroy();

        const labels = this.data.chartData.map(c => this.meses.get(c.mes));
        let labelChart = [];
        labels.forEach(l => {
            labelChart.push(l);
        });
        const values = this.data.chartData.map(c => c.total);
        let dataChart = [];
        values.forEach(v => {
            dataChart.push(v);
        });
        this.chart = new window.Chart(ctx, {
            type: 'line',
            data: {
                labels: labelChart,
                datasets: [{
                    label: 'Tickets Finalizados',
                    data: dataChart,
                    fill: true,
                    borderColor: '#e46b09ff',
                    backgroundColor: '#ffd2acff',
                    tension: 0.5
                }]
            },
            options: {
                responsive: false,
                maintainAspectRatio: false,
                plugins: {
                    legend: { display: true }
                }
            }
        });
        this.chart.resize();
    }

    renderChartStatus() {
        if (!this.chartjsInitialized || !this.data) return;

        const ctx = this.template.querySelector('.doughnutChart');
        if (!ctx) return;

        // Destrói gráfico antigo se existir
        if (this.chartStatus) this.chartStatus.destroy();

        const labels = this.data.chartDataStatus.map(c => c.Status__c);
        let labelChart = [];
        labels.forEach(l => {
            labelChart.push(l);
        });
        const values = this.data.chartDataStatus.map(c => c.total);
        let dataChart = [];
        values.forEach(v => {
            dataChart.push(v);
        });
        this.chartStatus = new window.Chart(ctx, {
            type: 'doughnut',
            data: {
                labels: labelChart,
                datasets: [{
                    label: 'Tickets por Status',
                    data: dataChart,
                    hoverOffset: 4,
                    circumference : 180,
                    rotation : 270,
                    borderColor: '#f1f5f7ff',
                    backgroundColor: [
                        '#FFB03B',
                        '#FFD69E',
                        '#0E9EFF',
                        '#E6E6E6',
                        '#666666',
                        '#9966FF',
                        '#FF9F40',
                    ],
                    
                }]
            },
            options: {
                responsive: false,
                maintainAspectRatio: true,
                plugins: {
                    legend: {
                        position: 'top',
                    },
                    title: {
                        display: true,
                        text: 'Tickets por Status'
                    }
                }
            }
        });
    }

    renderChartDepartamento() {
        if (!this.chartjsInitialized || !this.data) return;

        const ctx = this.template.querySelector('.barChart');
        if (!ctx) return;

        // Destrói gráfico antigo se existir
        if (this.chartDepartamento) this.chartDepartamento.destroy();

        const labels = this.data.chartDataDepartamento.map(c => c.Departamento__c);
        let labelChart = [];
        labels.forEach(l => {
            labelChart.push(l);
        });
        const values = this.data.chartDataDepartamento.map(c => c.total);
        let dataChart = [];
        values.forEach(v => {
            dataChart.push(v);
        });
        this.chartDepartamento = new window.Chart(ctx, {
            type: 'bar',
            data: {
                labels: labelChart,
                datasets: [{
                    label: 'Tickets por Departamento',
                    data: dataChart,
                    hoverOffset: 4,
                    circumference : 180,
                    rotation : 270,
                    borderColor: '#f1f5f7ff',
                    backgroundColor: [
                        '#FFB03B',
                        '#FFD69E',
                        '#0E9EFF',
                        '#E6E6E6',
                        '#666666',
                        '#9966FF',
                        '#FF9F40',
                    ],
                    
                }]
            },
            options: {
                responsive: false,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        position: 'top',
                    },
                    title: {
                        display: true,
                        text: 'Tickets por Departamento'
                    }
                }
            }
        });
        this.chartDepartamento.resize();
    }

    renderChartExcedidos() {
        if (!this.chartjsInitialized || !this.data) return;

        const ctx = this.template.querySelector('.pieChart');
        if (!ctx) return;

        // Destrói gráfico antigo se existir
        if (this.chartExcedidos) this.chartExcedidos.destroy();

        const labels = this.data.chartDataExcedidos.map(c => c.Excedeu_Tempo_Estimado__c ? 'Excedido' : 'No Prazo');
        let labelChart = [];
        labels.forEach(l => {
            labelChart.push(l);
        });
        const values = this.data.chartDataExcedidos.map(c => c.total);
        let dataChart = [];
        values.forEach(v => {
            dataChart.push(v);
        });
        this.chartExcedidos = new window.Chart(ctx, {
            type: 'pie',
            data: {
                labels: labelChart,
                datasets: [{
                    label: 'Tickets por Prazo',
                    data: dataChart,
                    borderColor: '#f1f5f7ff',
                    backgroundColor: [
                        '#ff4b3bff',
                        '#4ae910ff'
                    ],
                    
                }]
            },
            options: {
                responsive: false,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        position: 'top',
                    },
                    title: {
                        display: true,
                        text: 'Tickets por Prazo'
                    }
                }
            }
        });
        this.chartExcedidos.resize();
    }


    navigateToRecord(event) {
        const idTkt = event.currentTarget.dataset.id;
        console.log('navigateToRecord:', idTkt);

        this[NavigationMixin.GenerateUrl]({
            type: 'standard__recordPage',
            attributes: {
                recordId: idTkt,
                objectApiName: 'Backlog__c',
                actionName: 'view'
            }
        }).then(url => {
            window.open(url, '_blank'); // abre em nova aba
        });
    }
}