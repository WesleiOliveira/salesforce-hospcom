({
    // FUNÇÃO QUE EXIBE ERROS AO USUÁRIO -------------------------------------------------------------
    alertaErro: function (cmp, event, helper, error, title, type, tipoMensagem, mode) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": tipoMensagem + " " + error,
            "type": type,
            "mode": mode
        });
        toastEvent.fire();
    },
    // ----------------------------------------------------------------------------------------------
    
    // FUNÇÃO QUE EXIBE O SPINNER DE CARREGAMENTO
    showSpinner: function (cmp) {
        $('#spinnerDiv').css("display", "flex");
    },
    // ---------------------------------------------------------------------------------------------
    
    // FUNÇÃO QUE OCULTA O SPINNER DE CARREGAMENTO
    hideSpinner: function (cmp) {
        $('#spinnerDiv').css("display", "none");
    },
    // ---------------------------------------------------------------------------------------------
    
    helperMethod: function (cmp, event, helper) {
        helper.consultaTarefas(cmp, event, helper);
        helper.setColumns(cmp);

        $("#periodoAtual345345").change(function () {
            var mes = $(this).val();
            helper.consultaTarefasFiltro(cmp, event, helper, mes);
        });
    },

    COLUMNS: [
        { label: 'Name', fieldName: 'name', sortable: true },
        { label: 'Gestor', fieldName: 'gestor' }
    ],

    setColumns: function (cmp) {
        cmp.set('v.columns', this.COLUMNS);
    },

    // Used to sort the 'Age' column
    sortBy: function (field, reverse, primer) {
        var key = primer
            ? function (x) {
                return primer(x[field]);
            }
            : function (x) {
                return x[field];
            };

        return function (a, b) {
            a = key(a);
            b = key(b);
            return reverse * ((a > b) - (b > a));
        };
    },

    handleSort: function (cmp, event) {
        var sortedBy = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');

        var cloneData = this.DATA.slice(0);
        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));

        cmp.set('v.data', cloneData);
        cmp.set('v.sortDirection', sortDirection);
        cmp.set('v.sortedBy', sortedBy);
    },

    consultaTarefasFiltro: function (cmp, event, helper, mes) {
        
        const anoAtual = new Date().getFullYear();
        var x = Number(mes)

        // Primeiro dia do mês
        const firstDayFormatted = `${anoAtual}-${String(x + 1).padStart(2, '0')}-01`;
        
        // Último dia do mês
        const ultimoDia = new Date(anoAtual, mes + 1, 0);
        const lastDayFormatted = `${anoAtual}-${String(x + 1).padStart(2, '0')}-${String(ultimoDia.getDate()).padStart(2, '0')}`;

        helper.showSpinner(cmp);

        var query = "select id, name, Gestor__c from contact where Tipo_de_premiass_o__c = 'Meta Administrativo' AND Colaborador_ativo__c = true AND AccountId = '001i00000085QYb'";
        console.log("QUERY CONTATOS", query);
        helper.alertaErro(cmp, event, helper, "...", "Filtrando", "success", "", "dismissible");

        this.soql(cmp, query)
            .then(function (contatos) {
                console.log("contatos", contatos);

                var query = "select id, Contato__c, ActivityDate from task where Meta__c = true AND Contato__c != null AND ActivityDate >= " + firstDayFormatted + " AND ActivityDate <= " + lastDayFormatted + "";
                console.log("QUERY task", query);
                helper.alertaErro(cmp, event, helper, "...", "Filtrando", "success", "", "dismissible");

                helper.soql(cmp, query)
                    .then(function (tasks) {
                        console.log("tasks", tasks);

                        var query = "select id, name, Gestor__r.Name, contactid from user where contactid != null";
                        console.log("QUERY user", query);
                        helper.alertaErro(cmp, event, helper, "...", "Filtrando", "success", "", "dismissible");

                        helper.soql(cmp, query)
                            .then(function (users) {
                                console.log("users", users);

                                var contatoIdsComTarefas = new Set(tasks.map(tarefa => tarefa.Contato__c));
                                var contatosSemTarefas = contatos.filter(contato => !contatoIdsComTarefas.has(contato.Id));

                                console.log("CONTATOS SEM TAREFAS", contatosSemTarefas);

                                var contatosComGestores = contatosSemTarefas.map(contato => {
                                    let gestorName = null;

                                    users.forEach(usuario => {
                                        if (usuario.ContactId == contato.Id && usuario.Gestor__r) {
                                            gestorName = usuario.Gestor__r.Name;
                                        }
                                    });
                                
                                    if(!gestorName){
                                        gestorName = contato.Gestor__c
                                    }

                                    return {
                                        Id: contato.Id,
                                        Name: contato.Name,
                                        Gestor: gestorName
                                    };
                                });
                        
                        		contatosComGestores.sort((a, b) => {
                                    const nameA = a.Name.toUpperCase();
                                    const nameB = b.Name.toUpperCase();
                                    if (nameA < nameB) return -1;
                                    if (nameA > nameB) return 1;
                                    return 0;
                                });

                                var formattedOutput = contatosComGestores.map((contato, index) => ({
                                    id: index + 1,
                                    name: contato.Name,
                                    gestor: contato.Gestor
                                }));
                        
                        		contatosComGestores.sort((a, b) => {
                                    const nameA = a.Name.toUpperCase();
                                    const nameB = b.Name.toUpperCase();
                                    if (nameA < nameB) return -1;
                                    if (nameA > nameB) return 1;
                                    return 0;
                                });
                                console.log(contatosComGestores);

                                cmp.set('v.data', formattedOutput);
                                helper.hideSpinner(cmp);
                            })
                            .catch(function (error) {
                                console.log(error);
                            });
                    })
                    .catch(function (error) {
                        console.log(error);
                    });
            })
            .catch(function (error) {
                console.log(error);
            });
    },

    consultaTarefas: function (cmp, event, helper) {
        const currentDate = new Date();
        
        const firstDay = new Date(currentDate.getFullYear(), currentDate.getMonth(), 1);
        const lastDay = new Date(currentDate.getFullYear(), currentDate.getMonth() + 1, 0);
        
        $("#periodoAtual345345").val(currentDate.getMonth());

        const formatDate = (date) => {
            const year = date.getFullYear();
            const month = String(date.getMonth() + 1).padStart(2, '0');
            const day = String(date.getDate()).padStart(2, '0');
            return `${year}-${month}-${day}`;
        };

        const firstDayFormatted = formatDate(firstDay);
        const lastDayFormatted = formatDate(lastDay);

        var query = "select id, name, Gestor__c from contact where Tipo_de_premiass_o__c = 'Meta Administrativo' AND Colaborador_ativo__c = true AND AccountId = '001i00000085QYb'";
        console.log("QUERY contatos", query);

        this.soql(cmp, query)
            .then(function (contatos) {
                console.log("contatos", contatos);

                var query = "select id, Contato__c, ActivityDate from task where Meta__c = true AND Contato__c != null AND ActivityDate >= " + firstDayFormatted + " AND ActivityDate <= " + lastDayFormatted + "";
                console.log("QUERY task", query);

                helper.soql(cmp, query)
                    .then(function (tasks) {
                        console.log("tasks", tasks);

                        var query = "select id, name, Gestor__r.Name, contactid from user where contactid != null";
                        console.log("QUERY user", query);

                        helper.soql(cmp, query)
                            .then(function (users) {
                                console.log("users", users);

                                var contatoIdsComTarefas = new Set(tasks.map(tarefa => tarefa.Contato__c));
                                var contatosSemTarefas = contatos.filter(contato => !contatoIdsComTarefas.has(contato.Id));

                                console.log("CONTATOS SEM TAREFAS", contatosSemTarefas);

                                var contatosComGestores = contatosSemTarefas.map(contato => {
                                    let gestorName = null;

                                    users.forEach(usuario => {
                                        if (usuario.ContactId == contato.Id && usuario.Gestor__r) {
                                            gestorName = usuario.Gestor__r.Name;
                                        }
                                    });
                                                                
                                    if(!gestorName){
                                        gestorName = contato.Gestor__c
                                    }

                                    return {
                                        Id: contato.Id,
                                        Name: contato.Name,
                                        Gestor: gestorName
                                    };
                                });
                        
                        		contatosComGestores.sort((a, b) => {
                                    const nameA = a.Name.toUpperCase();
                                    const nameB = b.Name.toUpperCase();
                                    if (nameA < nameB) return -1;
                                    if (nameA > nameB) return 1;
                                    return 0;
                                });

                                var formattedOutput = contatosComGestores.map((contato, index) => ({
                                    id: index + 1,
                                    name: contato.Name,
                                    gestor: contato.Gestor
                                }));
                        

                                console.log(contatosComGestores);

                                cmp.set('v.data', formattedOutput);
                            })
                            .catch(function (error) {
                                console.log(error);
                            });
                    })
                    .catch(function (error) {
                        console.log(error);
                    });
            })
            .catch(function (error) {
                console.log(error);
            });
    }
})