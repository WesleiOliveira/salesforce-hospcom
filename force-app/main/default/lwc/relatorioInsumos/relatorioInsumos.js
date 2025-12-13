// relatorioComodato.js
import { LightningElement, track } from 'lwc';
import executeSoql from '@salesforce/apex/ApexHelperController.executeSoql';

export default class RelatorioComodato extends LightningElement {
    @track anoSelecionado = '2025';
    @track linhaSelecionada = 'PM';
    @track regiaoSelecionada = 'Região MT/MS';
    comodatoData = [];
    orderItems = [];
    finalData = [];
    meses = ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'];

    get opcoesAno() {
        return [
            { label: '2024', value: '2024' },
            { label: '2025', value: '2025' }
        ];
    }

    get linhaOptions() {
        return [
            { label: 'PMLS', value: 'PMLS' },
            { label: 'PM', value: 'PM' },
            { label: 'VIAS AÉREAS DIFÍCEIS', value: 'VIAS AÉREAS DIFÍCEIS' }
        ];
    }

    get regiaoOptions() {
        return [
            { label: 'Região GO/TO', value: 'Região GO/TO' },
            { label: 'Região MT/MS', value: 'Região MT/MS' },
            { label: 'Região SP', value: 'Região SP' },
            { label: 'Região Norte', value: 'Região Norte' },
            { label: 'Região RJ/ES/Sul', value: 'Região RJ/ES/Sul' }
        ];
    }

    handleLinhaChange(event) {
        this.linhaSelecionada = event.detail.value;
        this.fetchData(); // Recarrega os dados quando muda a linha
    }

    handleAnoChange(event) {
        this.anoSelecionado = event.detail.value;
        this.fetchData();
    }

    handleRegiaoChange(event) {
        this.regiaoSelecionada = event.detail.value;
        this.fetchData();
        console.log('regiaoChange');
    }

    fetchData() {
        console.log('funcao fetchdata');
        this.fetchComodatoData();
        this.fetchOrderItems();
    }

    fetchComodatoData() {
        const soql = `SELECT Id, Name, Data_Prevista__c, Data_Final__c,
                  (SELECT Id, Produto__r.ProductCode, Produto__r.Name, Quantidade__c, N_Comodato__c FROM Consumiveis_de_comodato__r),
                  (SELECT Id, Name, Nome_do_ativo__c FROM Produtos_da_demonstracao__r WHERE Equipamento__c = true)
                  FROM Demonstracao__c
                  WHERE Status__c NOT IN('Rascunho') 
                  AND Regiao__c = '${this.regiaoSelecionada}'
                  AND ID IN (
                      SELECT Demonstracao__c 
                      FROM Produto_da_demonstracao__c 
                      WHERE Linha__c = '${this.linhaSelecionada}'
                  )`;

                  console.log('Consulta: ' + soql);
                  
        executeSoql({ soql })
            .then(result => {
                this.comodatoData = result;
                this.processData();
            })
            .catch(error => {
                console.error('Erro ao buscar dados de comodato', error);
            });
    }

    fetchOrderItems() {
        const inicioDoAno = `${this.anoSelecionado}-01-01`;
        const fimDoAno = `${this.anoSelecionado}-12-31`;

        const soql = `SELECT Id, Product2.ProductCode, Quantity, Mes__c, Order.Demonstracao__c 
                      FROM OrderItem 
                      WHERE Marca__c = 'MEDTRONIC' 
                      AND Order.Data_de_ativacao__c >= ${inicioDoAno} 
                      AND Order.Data_de_ativacao__c <= ${fimDoAno}`;

        executeSoql({ soql })
            .then(result => {
                this.orderItems = result;
                this.processData();
            })
            .catch(error => {
                console.error('Erro ao buscar pedidos', error);
            });
    }

    processData() {
        let finalData = [];
        const anoSelecionadoInt = parseInt(this.anoSelecionado, 10);

        this.comodatoData.forEach(comodato => {
            let produtosMap = new Map();
            comodato.Produtos_da_demonstracao__r.forEach(produto => {
                produtosMap.set(produto.Nome_do_ativo__c, (produtosMap.get(produto.Nome_do_ativo__c) || 0) + 1);
            });

            let consumiveis = comodato.Consumiveis_de_comodato__r;
            //console.log('data do comodato ' + comodato.Data_prevista__c);
            let dataInicio = new Date(comodato.Data_prevista__c);
            let dataFinal = comodato.Data_Final__c ? new Date(comodato.Data_Final__c) : null;

            consumiveis.forEach((consumivel, index) => {
                let produtos = Array.from(produtosMap.entries()).map(([nome, qtd]) => `${qtd} ${nome}`).join('\n');
                let quantidadeMensal = consumivel.Quantidade__c || 0;

                let qtdMesesAno = 0;

                const anoInicio = dataInicio.getFullYear();
                const anoFinal = dataFinal ? dataFinal.getFullYear() : anoSelecionadoInt;

                //console.log('inicial ' + anoInicio + ' final: ' + anoFinal);

                // Só calcula se o anoSelecionado estiver dentro do intervalo do comodato
                    const primeiroMes = (anoSelecionadoInt === anoInicio) ? dataInicio.getMonth() : 0;
                    const ultimoMes = (anoSelecionadoInt === anoFinal)
                        ? (dataFinal ? dataFinal.getMonth() : 11)
                        : 11;

                    qtdMesesAno = ultimoMes - primeiroMes + 1;

                let qtdTotalAno = qtdMesesAno * quantidadeMensal;

                //console.log('qtd meses ano ' + qtdMesesAno);
                //console.log('qtd mensal ' + quantidadeMensal);

                let row = {
                    numero: consumivel.N_Comodato__c,
                    produtosDaDemonstracao: index === 0 ? produtos : '',
                    rowspan: index === 0 ? consumiveis.length : '',
                    produto: consumivel.Produto__r.Name,
                    productCode: consumivel.Produto__r.ProductCode,
                    quantidadeRequerida: quantidadeMensal,
                    quantidadeVendida: Array(12).fill().map((_, i) => ({
                        key: `${consumivel.Produto__r.ProductCode}-${i}`,
                        value: 0,
                        class: ''
                    })),
                    totalVendido: 0,
                    qtdTotalAno: qtdTotalAno,
                    diferenca: 0,
                    diferencaClass: ''
                };

                this.orderItems.forEach(item => {
                    if (item.Product2.ProductCode === consumivel.Produto__r.ProductCode &&
                        item.Order.Demonstracao__c === comodato.Id) {
                        let mesIndex = item.Mes__c - 1;
                        if (mesIndex >= 0 && mesIndex < 12) {
                            row.quantidadeVendida[mesIndex].value += item.Quantity;
                        }
                    }
                });

                row.quantidadeVendida.forEach((mes, i) => {
                    mes.class = mes.value >= quantidadeMensal ? 'green-cell' : 'red-cell';
                });

                row.totalVendido = row.quantidadeVendida.reduce((sum, mes) => sum + mes.value, 0);
                row.diferenca = row.totalVendido - qtdTotalAno;
                row.diferencaClass = row.diferenca < 0 ? 'red-cell' : 'green-cell';

                finalData.push(row);
            });
        });

        this.finalData = finalData;
    }

    connectedCallback() {
        this.fetchData();
    }
}