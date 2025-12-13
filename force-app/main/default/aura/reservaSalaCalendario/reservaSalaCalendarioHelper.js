({
    dataAgrupada : {},
    data : [],
    empresaSetada : "",
    salaClicada : "",
    tipoDeRegistroClicado : "",
    
	mainHelper : function(cmp, event, helper) {
        console.log("main helper")
        
        //EVENTO DE CLIQUE PARA RETORNAR
        $("#iconReturn").off().on( "click", function() {
            var breadCumbAtual = $("#breadCrumbsReservas").html()
            breadCumbAtual = breadCumbAtual.replace(/&gt;/g, ">");
            var breadCrumbPilha = breadCumbAtual.split(" > ").map(item => item.trim());
            var ultimoItem = breadCrumbPilha.slice(-1)[0];
            
            if(ultimoItem != "Início"){
                breadCrumbPilha.pop()
                ultimoItem = breadCrumbPilha.slice(-1)[0];
                var novaString = breadCrumbPilha.join(" > ");
                
                $("#breadCrumbsReservas").html(novaString)
                
                if(ultimoItem == helper.empresaSetada){
                    helper.preencheSalas(cmp, event, helper)
                }
                if(ultimoItem == "Início"){
                    helper.preencheUnidades(cmp, event, helper)
                }
            }
        });
        
        
        $("#buttonCriarNovaReserva").off().on( "click", function() {
            $("#popupRecordNovaReserva").toggle();
        });
        
        $("#buttonEfetivaCriaNovaReserva").off().on( "click", function() {
            
			var tipoRegistro = $("#customSelectOptions").val()
            if(!tipoRegistro){
                alert("Selecione uma unidade para seguir com a criação")
                return 0
            }
            
            var createRecordEvent = $A.get("e.force:createRecord");
            createRecordEvent.setParams({
                'recordTypeId' : tipoRegistro,
                'entityApiName': "Reserva_de_Sala__c"
            });
            createRecordEvent.fire();
        });

        
        // Fecha o popup ao clicar em qualquer parte do documento
        $(document).on("click", function(event) {
            var target = $(event.target);
            var popup = $("#popupRecordNovaReserva");
            var button = $("#buttonCriarNovaReserva");
            
            // Verifica se o clique foi fora do popup e do botão
            if (!target.closest(popup).length && !target.closest(button).length && popup.is(":visible")) {
                popup.hide();
            }
        });
        
        helper.consultaDados(cmp, event, helper)
	},
    
    preencheUnidades : function(cmp, event, helper){
        $("#mainBox3242").empty();
        $("#buttonCriarNovaReserva").show();
        
        for (let unidade in helper.dataAgrupada) {
            
            var descricaoUnidade = unidade.split("-");
            var tipoRegistro = helper.data.filter(reserva => (reserva.RecordType.Name == unidade))[0].RecordTypeId
            
            var html = "<div class='itemLocation34232' data-unidade='"+unidade+"' data-tipoRegistro='"+tipoRegistro+"'>\
                <div class='linha132423'>\
                    <div class='IconOrImage342'>\
                        <i class='fa fa-building-o' aria-hidden='true'></i>\
                    </div>\
                    <div class='infoItem32423'>\
                        <div class='innerInfo324233'>\
                            <div class='title453435'>\
                                "+descricaoUnidade[0]+"\
                            </div>\
                            <div class='desc453435'>\
                                "+descricaoUnidade[1]+"\
                            </div>\
                        </div>\
                    </div>\
                </div>\
                <div class='linha232423'>\
                    Clique para abrir\
                </div>\
            </div>";
            
            $("#mainBox3242").append(html)
        }
        helper.eventsAfterPreencheUnidades(cmp, event, helper)
    },
    
    eventsAfterPreencheUnidades : function(cmp, event, helper){
        
        //clique na unidade
        $(".itemLocation34232").off().on( "click", function() {
            var unidadeClicada = $(this).data("unidade")
            var tipoDeRegistro = $(this).data("tiporegistro")
            var breadCumbAtual = $("#breadCrumbsReservas").html()
            $("#breadCrumbsReservas").html(breadCumbAtual + " > " + unidadeClicada)
            
            helper.tipoDeRegistroClicado = tipoDeRegistro
			helper.empresaSetada = unidadeClicada
            helper.preencheSalas(cmp, event, helper)
        });
    },
    
    preencheSalas : function(cmp, event, helper){
        $("#mainBox3242").empty();
        $("#buttonCriarNovaReserva").hide();
        
        for (let sala in helper.dataAgrupada[helper.empresaSetada]) {
            console.log("UNIDADE", sala)
            //var descricaoUnidade = unidade.split("-");
            
            var html = "<div class='itemLocation34232 itemLocationClass' data-sala='"+sala+"'>\
                <div class='linha132423'>\
                    <div class='IconOrImage342'>\
                        <i class='fa fa-calendar' aria-hidden='true'></i>\
                    </div>\
                    <div class='infoItem32423'>\
                        <div class='innerInfo324233'>\
                            <div class='title453435'>\
                                "+sala+"\
                            </div>\
                            <div class='desc453435'>\
                                "+sala+"\
                            </div>\
                        </div>\
                    </div>\
                </div>\
                <div class='linha232423'>\
                    Clique para abrir\
                </div>\
            </div>";
            
            $("#mainBox3242").append(html)
        }
        helper.eventsAfterPreencheSalas(cmp, event, helper)
    },
    
    eventsAfterPreencheSalas : function(cmp, event, helper){
        $(".itemLocationClass").off().on( "click", function() {
            var salaClicada = $(this).data("sala")
            
            var breadCumbAtual = $("#breadCrumbsReservas").html()
            $("#breadCrumbsReservas").html(breadCumbAtual + " > " + salaClicada)
            
            helper.salaClicada = salaClicada
            helper.preencheCalendario(cmp, event, helper)
        });
    },
    
    preencheCalendario : function(cmp, event, helper){
        $("#mainBox3242").empty();
        $("#mainBox3242").append("<div class='divCalendario'><div id='calendar'></div></div>");
        
            const now = moment(); // Data e hora atuais

            const events = helper.data.filter(reserva => (reserva.Sala__c == helper.salaClicada && reserva.RecordType.Name == helper.empresaSetada))
                .map(event => {
                    const eventStart = moment(event.In_cio__c);
                    const eventEnd = moment(event.Termino__c);
                    const now = new Date();
                    let color;

                    if (eventEnd.isBefore(now)) {
                        color = '#616161'; // cinza para eventos passados
                    } else if (eventStart.isSameOrBefore(now) && eventEnd.isSameOrAfter(now)) {
                        color = '#00FF00'; // verde para eventos do dia atual
                    } else {
                        color = '#485DD0'; // azul para eventos futuros
                    }

                    return {
                        id: event.Id,
                        title: event.CreatedBy.Name + " -> " + event.Name,
                        start: eventStart.format(), // Formatar a data para o formato correto
                        end: eventEnd.format(), // Formatar a data para o formato correto
                        status: event.Status__c,
                        room: event.Sala__c,
                        recordTypeName: event.RecordType.Name,
                        color: color
                    };
                });
    
        console.log("EVENTOS EXIBIDOS", events)
        
        $('#calendar').fullCalendar('destroy');
        $('#calendar').fullCalendar({
            locale: 'pt-br',
            header: {
                left: 'prev,next today',
                center: 'title',
                right: 'month,basicWeek,basicDay'
            },
            height: $(".divCalendario").height(),
            eventLimit: true, // for all non-agenda views
            views: {
                agenda: {
                    eventLimit: 2 // adjust to 6 only for agendaWeek/agendaDay
                }
            },
            
            defaultView: 'month',
            dayClick: function(date, jsEvent, view) {
                //$(this).css('background-color', 'red');
                console.log('Clicked on: ' + date.format());
                
                var isoDate = moment(date.format()).format('YYYY-MM-DD') + 'T12:00:00Z';

                console.log("DATA FORMATED", isoDate)
                
                //2024-06-20
                var valores = {Sala__c : helper.salaClicada, In_cio__c: isoDate, Status__c : "Novo"}
                
                var createRecordEvent = $A.get("e.force:createRecord");
                createRecordEvent.setParams({
                    'entityApiName': "Reserva_de_Sala__c",
                    'recordTypeId' : helper.tipoDeRegistroClicado,
                    'defaultFieldValues': valores
                });
                createRecordEvent.fire();
            },
                eventClick: function(calEvent, jsEvent, view) {
                //EXIBE POPUP
                //$("#divPaiPopup").css("display", "flex")
                var idReservaSala = calEvent.id
                var urlReservaSala = 'https://hospcom.my.site.com/Sales/s/reserva-de-sala/' + idReservaSala
                //helper.configuraPopupCompromisso(cmp, event, helper, idCompromisso)
                console.log('Event clicked:', urlReservaSala); // Exemplo: exibe o objeto do evento no console.
                window.open(urlReservaSala, "_blank");
            },
            events: events,
        });
    },
    
    consultaDados : function(cmp, event, helper){
        
        var query = "SELECT Id, name, Status__c, RecordType.Name, RecordTypeId, CreatedBy.Name, In_cio__c, Termino__c, Sala__c from Reserva_de_Sala__c"
        
        //REALIZA A CONSULTA
        this.soql(cmp, query)
        
        //QUANDO A SOLICITAÇÃO FOR CONCLUÍDA, FAÇA:
        .then(function (reservas) {
            
            console.log("RESERVAS", reservas)
            
            const groupedData = reservas.reduce((acc, item) => {
                const recordTypeName = item.RecordType.Name;
                const sala = item.Sala__c;
            
                if (!acc[recordTypeName]) {
                    acc[recordTypeName] = {};
                }
            
                if (!acc[recordTypeName][sala]) {
                    acc[recordTypeName][sala] = [];
                }
            
                acc[recordTypeName][sala].push(item);
            
                return acc;
            }, {});
        
        
        	console.log(groupedData);
			helper.dataAgrupada = groupedData;
        	helper.data = reservas;
			helper.preencheUnidades(cmp, event, helper)
        })
        
        //trata excessão de erro
        .catch(function (error) {
            console.log(error)
        })
    }
})