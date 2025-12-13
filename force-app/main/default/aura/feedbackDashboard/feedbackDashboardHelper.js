({
    mainFunction : function(cmp, event, helper) {
        console.log("ok mainFunction")
        
        var ctx = cmp.find("lineChart").getElement().getContext("2d");
        
        // Criando o gradiente
        var grad=ctx.createLinearGradient(0,0, 280,0);
        grad.addColorStop(0, "lightblue");
        grad.addColorStop(1, "darkblue");
        
        ctx.fillStyle = grad;
        ctx.fillRect(10,10, 280,130);
        
        var myChart = new Chart(ctx, {
            type: 'line',
            data: {
                labels: ["Jan", "Fev", "Mar", "Abr", "Mai", "Jun"],
                datasets: [{
                    label: 'Feedbacks concluídos',
                    data: [10, 25, 18, 30, 45, 40],
                    borderColor: 'rgba(255, 176, 59, 1)', // Cor da linha
                    backgroundColor: 'rgba(255, 176, 59, 0.5)', // Gradiente aplicado
                    borderWidth: 3,
                    fill: true // Preenchimento ativado
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                scales: {
                    yAxes: [{
                        ticks: { beginAtZero: true }
                    }]
                }
            }
        });
        
        cmp.set("v.chartInstance", myChart);
        
        console.log("ok mainFunction")
        
    }
})