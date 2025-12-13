@isTest(seeAllData=true)
public class Ativo_ProdutoLocacaoClassTest {


    @isTest
    static void testCriarProdutosCopia() {
        // Consulta o produto criado no setup
        Product2 produto = [SELECT Id, ProductCode FROM Product2 WHERE ProductCode = 'PROD001' LIMIT 1];

        // Cria um ativo associado ao produto
        Asset ativo = new Asset(
            Name = 'Ativo Teste',
            Product2Id = produto.Id,
            AccountId = '0016e00003FBzFG'
        );

        Test.startTest();
        insert ativo;
        Test.stopTest();

        // Verifica se o produto "cópia" foi criado
        Product2 produtoCopia = [SELECT Id, ProductCode FROM Product2 WHERE ProductCode = 'PROD001LOCACAO' LIMIT 1];

        // Asserções para garantir que o produto "cópia" foi criado corretamente
        System.assertNotEquals(null, produtoCopia, 'O produto "cópia" deve ser criado.');
        System.assertEquals('PROD001LOCACAO', produtoCopia.ProductCode, 'O código do produto "cópia" deve ser PROD001LOCACAO.');
    }

    @isTest
    static void testNaoCriarProdutosCopiaExistentes() {
        Product2 produto = [SELECT Id, ProductCode FROM Product2 WHERE ProductCode = 'PROD001' LIMIT 1];

        // Cria um produto "cópia" manualmente
        Product2 produtoCopia = new Product2(
            Name = 'Produto Teste LOCACAO',
            ProductCode = 'PROD001LOCACAO',
            IsActive = true
        );
        insert produtoCopia;

        // Cria um ativo associado ao produto
        Asset ativo = new Asset(
            Name = 'Ativo Teste 2',
            Product2Id = produto.Id,
            AccountId = '0016e00003FBzFG'            
        );

        Test.startTest();
        insert ativo;
        Test.stopTest();

 
    }
}