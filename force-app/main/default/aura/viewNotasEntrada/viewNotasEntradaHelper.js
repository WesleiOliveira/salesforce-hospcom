({
    getColumnDefinitions: function () {
        var columnsWidths = this.getColumnWidths();
        var columns = [
            {label: 'ver DANFE', type: 'button', initialWidth: 135, typeAttributes: { label: 'Ver DANFE', name: 'ver_danfe', title: 'Clique para ver DANFE'}},
            {label: 'Emissao', fieldName: 'emissao', type: 'date', sortable: true, cellAttributes: { iconName: 'utility:event', iconAlternativeText: 'Data de Emissão' }},
            {label: 'Empresa', fieldName: 'empresa', type: 'text', sortable: true, iconName: 'standard:account'},
            {label: 'Numero', fieldName: 'numero', type: 'text', sortable: true},
            {label: 'Valor', fieldName: 'valor', type: 'currency', typeAttributes: { currencyCode: 'BRL' }, sortable: true},
            {label: 'CNPJ/CPF', fieldName: 'cnpjCpf', type: 'text', sortable: true},
            {label: 'Status', fieldName: 'status', type: 'text', sortable: true}
        ];

        if (columnsWidths.length === columns.length) {
            return columns.map(function (col, index) {
                return Object.assign(col, { initialWidth: columnsWidths[index] });
            });
        }
        return columns;
    },

    fetchData: function (cmp, fetchData, numberOfRecords) {
        var staticData = [
            {
                id: '1',
                emissao: '2024-01-01',
                empresa: 'Empresa 1',
                numero: '12345',
                valor: 1000.00,
                cnpjCpf: '12.345.678/0001-99',
                status: 'Aprovado'
            },
            {
                id: '2',
                emissao: '2024-02-01',
                empresa: 'Empresa 2',
                numero: '67890',
                valor: 2000.00,
                cnpjCpf: '98.765.432/0001-00',
                status: 'Pendente'
            },
            {
                id: '3',
                emissao: '2024-03-01',
                empresa: 'Empresa 3',
                numero: '11121',
                valor: 1500.50,
                cnpjCpf: '11.222.333/0001-44',
                status: 'Rejeitado'
            }
        ];

        return new Promise(function (resolve) {
            resolve(staticData);
        });
    },

    sortData: function (cmp, fieldName, sortDirection) {
        var data = cmp.get("v.data");
        var reverse = sortDirection !== 'asc';

        data = Object.assign([],
            data.sort(this.sortBy(fieldName, reverse ? -1 : 1))
        );
        cmp.set("v.data", data);
    },

    sortBy: function (field, reverse, primer) {
        var key = primer
            ? function(x) { return primer(x[field]); }
            : function(x) { return x[field]; };

        return function (a, b) {
            var A = key(a);
            var B = key(b);
            return reverse * ((A > B) - (B > A));
        };
    },

    storeColumnWidths: function (widths) {
        localStorage.setItem('datatable-in-action', JSON.stringify(widths));
    },

    resetLocalStorage: function () {
        localStorage.setItem('datatable-in-action', null);
    },

    getColumnWidths: function () {
        var widths = localStorage.getItem('datatable-in-action');

        try {
            widths = JSON.parse(widths);
        } catch(e) {
            return [];
        }
        return Array.isArray(widths) ? widths : [];
    },

    editRowStatus: function (cmp, row) {
        var data = cmp.get('v.data');
        data = data.map(function(rowData) {
            if (rowData.id === row.id) {
                switch(row.status) {
                    case 'Pendente':
                        rowData.status = 'Aprovado';
                        break;
                    case 'Aprovado':
                        rowData.status = 'Rejeitado';
                        break;
                    case 'Rejeitado':
                        rowData.status = 'Finalizado';
                        break;
                    default:
                        break;
                }
            }
            return rowData;
        });
        cmp.set("v.data", data);
    },

    showRowDetails : function(row) {
        // eslint-disable-next-line no-alert
        alert("Mostrando DANFE para o número " + row.numero + " emitido em " + row.emissao);
    }
});