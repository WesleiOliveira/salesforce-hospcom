public class PegaUrlImagemAnexada {
    public PegaUrlImagemAnexada(ApexPages.StandardController controller) {
        // Construtor obrigatório para funcionar com Visualforce Pages
    }

    public List<String> getFileURLs() {
        List<String> fileURLs = new List<String>();

        // Obtém o ID do registro da página Visualforce
        String recordId = ApexPages.currentPage().getParameters().get('id');

        // Busca os arquivos associados ao registro
        List<ContentDocumentLink> fileLinks = [
            SELECT ContentDocumentId 
            FROM ContentDocumentLink 
            WHERE LinkedEntityId = :recordId
        ];

        for (ContentDocumentLink link : fileLinks) {
            ContentVersion file = [
                SELECT Id 
                FROM ContentVersion 
                WHERE ContentDocumentId = :link.ContentDocumentId 
                ORDER BY VersionNumber DESC 
                LIMIT 1
            ];
            fileURLs.add('/sfc/servlet.shepherd/version/download/' + file.Id);
        }
        return fileURLs;
    }
}