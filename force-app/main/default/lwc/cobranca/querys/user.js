export async function getUser(userId, soql) {
    console.log('Querying user...');

    if (!userId) {
        console.error("Erro ao consultar usuário: ID não informado");
        return null;
    }

    const query = `SELECT Id, Name, ProfileId, Profile.Name
                   FROM User
                   WHERE IsActive = true
                   AND Id = '${userId}'`;

    try {
        const result = await soql({ soql: query });

        if (result && result.length > 0) {
            // Retorna o primeiro usuário encontrado
            console.log("userdata: ", JSON.stringify(result[0]))
            return result[0];
        } else {
            console.warn("Nenhum usuário encontrado para o Id:", userId);
            return null;
        }
    } catch (error) {
        console.error("Erro ao consultar usuário:", error);
        return null;
    }
}