@isTest
private class EvitarDuplicarEntradaEstoqueTest {

    // Usa dados reais da produção
    private static Entrada_de_Estoque__c criarEntrada(String chave) {
        return new Entrada_de_Estoque__c(          
            chave_integracao__c = chave,
            Produto__c = '01t5A000008BVNCQA4',   // ID real do Produto
            Estoque__c = 'a1A5A00000CX2o7UAD'    // ID real do Estoque
        );
    }

    @isTest
    static void deveBloquearInsercaoComChaveDuplicada() {
        // Primeiro registro com chave única
        Entrada_de_Estoque__c entradaOriginal = criarEntrada('CHAVE-002');
        insert entradaOriginal;

        // Tentativa de duplicar com a mesma chave
        Entrada_de_Estoque__c entradaDuplicada = criarEntrada('CHAVE-002');

        Test.startTest();
        try {
            insert entradaDuplicada;
            System.assert(false, 'Esperado erro de duplicidade não ocorreu.');
        } catch (DmlException e) {
            System.assert(
                e.getMessage().contains('Já existe uma entrada de estoque com essa chave'),
                'Mensagem de erro inesperada: ' + e.getMessage()
            );
        }
        Test.stopTest();
    }
}