({
    carregarTelefone: function(cmp, event, helper) {
        try{
            let recordId = '001U400000A6zsfIAB';
            console.log("📌 ID da conta:", recordId);           
            let query = `SELECT Id, Phone FROM Account WHERE Id = '${recordId}'`;
            console.log("📄 Consulta SOQL:", query);           
            const url = `https://integracao.hospcom.net/consulta/sales?sql=${encodeURIComponent(query)}`;
            fetch(url, {
                method: 'GET'
            })
            .then(response => {
                if (!response.ok) {
                    throw new Error("Erro na requisição: " + response.statusText);
                }
                  console.log("response json", response);
                return response.json();
            })
            .then(result => {
                console.log("📥 Resultado da API:", result);

                if (result && result.length > 0 && result[0].Phone) {
                    let phones = result[0].Phone;
                let phone = '+5565981700029';

                    // Monta o iframe com o número de telefone
                    let iframeUrl = "https://call.hospcom.net/?phone=" + encodeURIComponent(phone);
                    cmp.set("v.iframeSrc", iframeUrl);
                } else {
                    console.warn("⚠️ Nenhum telefone encontrado no resultado.");
                }
            })
            .catch(error => {
                console.error("❌ Erro ao buscar telefone:", error);
            });

        } catch (erro) {
            console.error("❌ Erro inesperado:", erro);
        }
    }
});