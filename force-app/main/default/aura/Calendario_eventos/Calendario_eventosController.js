({
    myAction : function(component, event, helper) {
        helper.consultaDados(component, event, helper);
    },
    
    filterEvents : function(component, event, helper) {
        var status = event.target.innerText.trim();
        
        // Obtendo o mês atual do calendário
        var calendarElement = $('#calendar');
        var currentView = calendarElement.fullCalendar('getView');
        var currentMonth = currentView.intervalStart.format('YYYY-MM');
        
        console.log(currentMonth);
        
        var filteredEvents = helper.eventos.filter(function(event) {
            return event.Status === status;
        });

        helper.renderFilteredCalendar(component, event, helper, filteredEvents, currentMonth);
    },

    
    showAllEvents : function(component, event, helper) {
        
                // Obtendo o mês atual do calendário
        var calendarElement = $('#calendar');
        var currentView = calendarElement.fullCalendar('getView');
        var currentMonth = currentView.intervalStart.format('YYYY-MM');
        
        console.log(currentMonth);
        
        
        helper.renderCalendar(component, event, helper, helper.eventos, currentMonth);
    }
})