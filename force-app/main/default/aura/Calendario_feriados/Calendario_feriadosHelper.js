({
    buscarFeriados: function(component) {
        var action = component.get("c.buscarFeriados");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var feriados = response.getReturnValue();
                component.set("v.feriados", feriados);
                this.renderCalendar(component, feriados);
            } else {
                console.error("Erro ao buscar feriados: ", response.getError());
            }
        });
        $A.enqueueAction(action);
    },

    renderCalendar: function(component, feriados) {
        // Mapeia as cores por departamento
        var departmentColors = {
            "Administrativo": "#1f77b4",
            "Comercial": "#aec7e8",
            "Compras": "#ff7f0e",
            "Contabilidade": "#ffbb78",
            "Controladoria": "#2ca02c",
            "Departamento Pessoal": "#98df8a",
            "Desenvolvimento": "#d62728",
            "Facilites": "#ff9896",
            "Faturamento": "#9467bd",
            "Financeiro": "#c5b0d5",
            "Fiscal": "#8c564b",
            "Governo": "#c49c94",
            "Jurídico": "#e377c2",
            "Limpeza": "#f7b6d2",
            "Locação": "#7f7f7f",
            "Logística": "#c7c7c7",
            "Manutenção": "#bcbd22",
            "Marketing": "#dbdb8d",
            "Operações": "#17becf",
            "OPME": "#9edae5",
            "Qualidade": "#1f77b4",
            "RH": "#ff7f0e",
            "Serviço": "#2ca02c",
            "T.I.": "#d62728",
            "TODOS": "#ff9896"
        };


        $("#mainBox3242").empty();
        $("#mainBox3242").append("<div id='calendar'></div>");

        var events = feriados.map(function(feriado) {
            var departamento = feriado.Description; // Certifique-se que esse campo está correto
            console.log('Departamento:', departamento); // Verifica o valor retornado no console

            var color = departmentColors[departamento] || '#FFA500'; // Cor padrão caso o departamento não seja encontrado

            return {
                id: feriado.Id,
                title: feriado.Name,
                start: moment(feriado.ActivityDate).format('YYYY-MM-DD'),
                color: color
            };
        });

        $('#calendar').fullCalendar({
            locale: 'pt-br',
            header: {
                left: 'prev,next today',
                center: 'title',
                right: 'month,basicWeek,basicDay'
            },
            height: 650,
            dayClick: function(date) {
                component.set("v.dataFeriado", moment(date).format('YYYY-MM-DD'));
                component.set("v.showModal", true);
            },

            eventClick: function(calEvent) {
                if (confirm('Apagar feriado "' + calEvent.title + '"?')) {
                    var action = component.get("c.excluirFeriado");
                    action.setParams({ feriadoId: calEvent.id });
                    action.setCallback(this, function(response) {
                        if (response.getState() === "SUCCESS") {
                            this.buscarFeriados(component);
                        } else if (response.getState() === "ERROR") {
                            var errors = response.getError();
                            if (errors && errors[0] && errors[0].message) {
                                this.showToast("Erro", errors[0].message, "error");
                            }
                        }
                    }.bind(this));
                    $A.enqueueAction(action);
                }
            }.bind(this),

            events: events
        });
    },

    criarFeriado: function(component) {
        var dataFeriado = component.get("v.dataFeriado");
        var nomeFeriado = component.get("v.nomeFeriado");
        var descricaoFeriado = component.get("v.descricaoFeriado");

        if (!nomeFeriado || !descricaoFeriado) {
            this.showToast("Erro", "Preencha todos os campos.", "error");
            return;
        }

        var action = component.get("c.criarFeriado");
        action.setParams({
            dataFeriado: dataFeriado,
            nome: nomeFeriado,
            descricao: descricaoFeriado
        });

        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                this.closeModal(component);
                this.buscarFeriados(component);
            } else if (response.getState() === "ERROR") {
                var errors = response.getError();
                if (errors && errors[0] && errors[0].message) {
                    this.showToast("Erro", errors[0].message, "error");
                }
            }
        }.bind(this));
        $A.enqueueAction(action);
    },

    closeModal: function(component) {
        component.set("v.showModal", false);
    },

    showToast: function(title, message, type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": message,
            "type": type
        });
        toastEvent.fire();
    }
})