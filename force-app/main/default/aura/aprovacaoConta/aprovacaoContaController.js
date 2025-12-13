({
    onRender : function(component, event, helper) {
        $("#button438843").off("click");

        $("#button438843").on("click", function() {
            var recordId = component.get("v.recordId");
            var url = "https://workflowwebhook.hospcom.net/webhook/f3ca8fec-fb33-43f2-9544-4da05442e304/";

            // Exibe spinner
            $("#spinner").show();

            fetch(url, {
                method: "POST",
                headers: {
                    "Content-Type": "application/json"
                },
                body: JSON.stringify({
                    recordId: recordId
                })
            })
            .then(response => {
                // Esconde spinner
                $("#spinner").hide();

                if (response.status === 200) {
                    // Se for 200, atualiza a página
                    location.reload();
                } else {
                    // Se não for 200, exibe erro
                    return response.text().then(text => {
                        alert("Erro: " + text);
                    });
                }
            })
            .catch(error => {
                // Esconde spinner em caso de erro também
                $("#spinner").hide();
                console.error(error);
                alert("Erro: " + error.message);
            });
        });
    }
})