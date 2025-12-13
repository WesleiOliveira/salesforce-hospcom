({
    handleSearch: function(component, event, helper) {
        const soql = component.get("v.soql");
        if (!soql) {
            console.log("erro: consulta vazia");
            helper.alertaErro(component, event, helper, "Erro", "Digite uma consulta SOQL!", "error");
            return;
        }

        const url = 'https://integracao.hospcom.net/consulta/sales?sql=' + encodeURIComponent(soql);

     fetch(url)
    .then(function(response) {
        if (!response.ok) {
            return response.json().then(function(errorData) {
                var message = errorData && errorData.error ? errorData.error : "Erro inesperado ao executar a consulta.";
                throw new Error(message);
            });
        }
        return response.json();
    })
    .then(function(data) {
        if (!data || data.length === 0) {
            component.set("v.columns", []);
            component.set("v.rows", []);
            return;
        }

        var keys = Object.keys(data[0]).filter(function(k) { return k !== "attributes"; });
        var rows = data.map(function(item) {
            return keys.map(function(key) {
                var val = item[key];
                if (val && typeof val === 'object') {
                    var nestedValue = Object.entries(val)
                        .filter(function(entry) { return typeof entry[1] !== 'object'; })
                        .map(function(entry) { return entry[0] + ": " + entry[1]; })
                        .join(', ');
                    return nestedValue || '[objeto]';
                }
                return val;
            });
        });

        component.set("v.columns", keys);
        component.set("v.rows", rows);
    })
    .catch(function(error) {
        console.error("Erro na consulta:", error.message);
        helper.alertaErro(component, event, helper, "Erro na consulta", error.message, "error");
    });

    }
})