@RestResource(urlMapping='/apiConfirma')
global class apiConfirmacao {
    @HttpPost
    global static void doPost() {
        String requestBody = RestContext.request.requestBody.toString();
        System.debug(requestBody);

        String idRequisicao = requestBody;
        
        try {
            ApiConfirmacaoService.processRequest(idRequisicao);

            // Configure a resposta de sucesso
            RestContext.response.statusCode = 200;
            RestContext.response.responseBody = Blob.valueOf('{"message": "Operação realizada com sucesso"}');
        } catch (Exception e) {
            // Capture exceções e configure a resposta de erro
            RestContext.response.statusCode = 500; // Status de erro interno do servidor
            RestContext.response.responseBody = Blob.valueOf('{"error": "' + e.getMessage() + '"}');
        }
    }
}