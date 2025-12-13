export async function registrarRespostas(payload) {
    console.log("Payload final: ", payload);

    if (!payload) {
        throw new Error("Payload vazio");
    }

    const URL = "https://workflow.hospcom.net/webhook/79359252-51d2-40e1-a16d-1ab08188df49";

    const response = await fetch(URL, {
        method: "POST",
        headers: {
            "Content-Type": "application/json",
        },
        body: JSON.stringify(payload),
    });

    const status = response.status;
    console.log("Status recebido:", status);

    if (status !== 200) {
        throw new Error(`Erro na requisição. Status Code: ${status}`);
    }
}