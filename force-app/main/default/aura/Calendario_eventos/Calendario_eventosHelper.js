({
    eventos:[],
    
    consultaDados: function(cmp, event, helper){
        var query = "SELECT Id, Name, Status, Data_de_in_cio2__c, Data_de_t_rmino2__c FROM Campaign WHERE RecordTypeId = '0125A000001dwebQAA'";
        
        this.soql(cmp, query)
        .then(function(campaigns) {
            console.log("CAMPAIGNS", campaigns);
            
            return helper.consultaSubEventos(cmp, event, helper, campaigns);
        })
        .then(function(combinedArray) {
            console.log("Combined Array:", combinedArray);
            
            helper.renderCalendar(cmp, event, helper, combinedArray);
        })
        .catch(function(error) {
            console.log("Error fetching campaigns:", error);
        });
    },
    
    consultaSubEventos: function(cmp, event, helper, campaigns){
        var subevents = [];
        var campaignsWithoutSubevents = [];
        
        var campaignIds = campaigns.map(function(campaign) {
            return "'" + campaign.Id + "'";
        }).join(', ');
        
        var querySubevents = "SELECT Id, Name, Inicio__c, Fim__c, Evento__c FROM Subevento__c WHERE Evento__c IN (" + campaignIds + ")";
        
        return this.soql(cmp, querySubevents)
        .then(function(result) {
            result.forEach(function(subevent) {
                
                var formattedSubevent = {
                    Id: subevent.Id,
                    Name: subevent.Name,
                    Status: 'Subevento', 
                    Data_de_in_cio2__c: subevent.Inicio__c,
                    Data_de_t_rmino2__c: subevent.Fim__c 
                };
                
                subevents.push(formattedSubevent);
            });
            
            // Filtra as campanhas que têm subeventos
            var campaignIdsWithSubevents = result.map(function(subevent) {
                return subevent.Evento__c;
            });
            
            campaignsWithoutSubevents = campaigns.filter(function(campaign) {
                return !campaignIdsWithSubevents.includes(campaign.Id);
            });
            
            // Concatena os arrays subevents e campaignsWithoutSubevents em um único array
            var combinedArray = subevents.concat(campaignsWithoutSubevents);
            
            helper.eventos = combinedArray
            return combinedArray;
        })
        .catch(function(error) {
            console.error("Error fetching subevents:", error);
            throw error; 
        });
    }, 
    
    renderCalendar: function(cmp, event, helper, campaigns, currentMonth){
        $("#mainBox3242").empty();
        $("#mainBox3242").append("<div class='divCalendario'><div id='calendar'></div></div>");
        
        const events = campaigns
        .filter(campaign => campaign.Status !== '')
        .map(campaign => {
            const eventStart = moment(campaign.Data_de_in_cio2__c);
            const eventEnd = moment(campaign.Data_de_t_rmino2__c);
            let color;
            
            switch (campaign.Status) {
            case "Aprovação do Lançamento":
            color = '#FFA500'; // laranja
            break;
            case "Cancelado":
            color = '#FF0000'; // vermelho
            break;
            case "Rejeitado":
            color = '#800000'; // marrom
            break;
            case "Concluído":
            color = '#008000'; // verde
            break;
            case "Em andamento":
            color = '#0000FF'; // azul
            break;
            case "Confirmado":
            color = '#00008B'; // azul escuro
            break;
            case "Planejado":
            color = '#808000'; // verde oliva
            break;
            case "Aprovado":
            color = '#4682B4'; // azul aço
            break;
            case "Rascunho":
            color = '#bababa'; // cinza claro
            break;
            case "Subevento":
            color = '#6714ba'; // roxo
            break;
            default:
            color = '#485DD0'; // cor padrão
        }
             
             return {
             id: campaign.Id,
             title: campaign.Name,
             start: eventStart.format(),
            end: eventEnd.format(),
                status: campaign.Status,
                    color: color
    };
});


$('#calendar').fullCalendar('destroy');
$('#calendar').fullCalendar({
    locale: 'pt-br',
    header: {
        left: 'prev,next today',
        center: 'title',
        right: 'month,basicWeek,basicDay'
    },
    height: 650,
    eventLimit: true,
    views: {
        agenda: {
            eventLimit: 2
        }
    },
    defaultView: 'month',
    defaultDate: currentMonth ? moment(currentMonth + '-01') : moment(),  // Define a data padrão para o mês atual se currentMonth for null
    dayClick: function(date, jsEvent, view) {
        var isoDate = moment(date.format()).format('YYYY-MM-DD') + 'T12:00:00Z';
        console.log("DATA FORMATED", isoDate);
        
        var valores = { Data_de_in_cio2__c: isoDate, Status: "Planejado" };
        
        var createRecordEvent = $A.get("e.force:createRecord");
        createRecordEvent.setParams({
            'entityApiName': "Campaign",
            'defaultFieldValues': valores
        });
        createRecordEvent.fire();
    },
    eventClick: function(calEvent, jsEvent, view) {
        var idCampanha = calEvent.id;
        var urlCampanha = 'https://hospcom.my.site.com/Sales/s/campaign/' + idCampanha + '/view';
        console.log('Event clicked:', urlCampanha);
        window.open(urlCampanha, "_blank");
    },
    events: events,
});
}, 
    
    renderFilteredCalendar: function(cmp, event, helper, filteredCampaigns, datacalender){
        const filteredEvents = filteredCampaigns.map(campaign => {
            const eventStart = moment(campaign.Data_de_in_cio2__c);
            const eventEnd = moment(campaign.Data_de_t_rmino2__c);
            let color;
            
            switch (campaign.Status) {
            case "Aprovação do Lançamento":
            color = '#FFA500'; // laranja
            break;
            case "Cancelado":
            color = '#FF0000'; // vermelho
            break;
            case "Rejeitado":
            color = '#800000'; // marrom
            break;
            case "Concluído":
            color = '#008000'; // verde
            break;
            case "Em andamento":
            color = '#0000FF'; // azul
            break;
            case "Confirmado":
            color = '#00008B'; // azul escuro
            break;
            case "Planejado":
            color = '#808000'; // verde oliva
            break;
            case "Aprovado":
            color = '#4682B4'; // azul aço
            break;
            case "Rascunho":
            color = '#bababa'; // cinza claro
            break;
            case "Subevento":
            color = '#6714ba'; // roxo
            break;
            default:
            color = '#485DD0'; // cor padrão
        }
                                                     
    return {
            id: campaign.Id,
            title: campaign.Name,
            start: eventStart.format(),
            end: eventEnd.format(),
            status: campaign.Status,
            color: color
    };
});

$('#calendar').fullCalendar('destroy');
$('#calendar').fullCalendar({
    locale: 'pt-br',
    header: {
        left: 'prev,next today',
        center: 'title',
        right: 'month,basicWeek,basicDay'
    },
    height: 650,
    eventLimit: true,
    views: {
        agenda: {
            eventLimit: 2
        }
    },
    defaultView: 'month',
    defaultDate: moment(datacalender + '-01'),  
    dayClick: function(date, jsEvent, view) {
        var isoDate = date.format('YYYY-MM-DD') + 'T12:00:00Z';
        console.log("DATA FORMATED", isoDate);
        
        var valores = { Data_de_in_cio2__c: isoDate, Status: "Planejado" };
        
        var createRecordEvent = $A.get("e.force:createRecord");
        createRecordEvent.setParams({
            'entityApiName': "Campaign",
            'defaultFieldValues': valores
        });
        createRecordEvent.fire();
    },
    eventClick: function(calEvent, jsEvent, view) {
        var idCampanha = calEvent.id;
        var urlCampanha = 'https://hospcom.my.site.com/Sales/s/campaign/' + idCampanha + '/view';
        console.log('Event clicked:', urlCampanha);
        window.open(urlCampanha, "_blank");
    },
    events: filteredEvents,
});
}

})