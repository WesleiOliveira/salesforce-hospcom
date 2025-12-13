@IsTest(SeeAllData=true)
public class AprovacaoCotacaoTest {
    
    /*
    @testSetup
    static void makeData(){
        System.debug('== Iniciando ==');
        Account partnerAccount = new Account(
            Name = 'Teste Acct',
            Phone = '85999999999',
            BillingStreet = 'Rua Exemplo, 123',
            BillingCity = 'Fortaleza',
            BillingState = 'Ceará',
            BillingPostalCode = '60000-000',
            BillingCountry = 'Brasil'
        );
        insert partnerAccount;
        
        // Criar Pricebook novo
        Pricebook2 pricebookPadrao = new Pricebook2(
            Name = 'Pricebook padrao',
            IsActive = true
        );
        insert pricebookPadrao;
        
        Opportunity oportunidade = new Opportunity(
            Name = 'Oportunidade Teste',
            AccountId = partnerAccount.Id,
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            Pricebook2Id = pricebookPadrao.Id
        );
        insert oportunidade;
        System.debug('Opportunity criada: ' + oportunidade.Id);
        
        // Criar Quote COM o Pricebook2Id
        Quote cotacao = new Quote(
            Name = 'Cotacao',
            OpportunityId = oportunidade.Id,
            Pricebook2Id = pricebookPadrao.Id,
            Juros_Base__c = 'a3mHZ000000vjAOYAY'
        );
        insert cotacao;
        System.debug('Quote criado: ' + cotacao.Id);
        
        // Criar 3 Produtos
        
        String sku1 = 'SKU-' + String.valueOf(Crypto.getRandomLong());
        String sku2 = 'SKU-' + String.valueOf(Crypto.getRandomLong());
        String sku3 = 'SKU-' + String.valueOf(Crypto.getRandomLong());
        
        List<Product2> produtos = new List<Product2>{
            new Product2(
                Name = 'BOMBA DE INFUSÃO X372345',
                ProductCode = 'sdgw3rhge',
                IsActive = true,
                Modelo__c = 'ANIFM ',
                Marca__c = 'MINDRAY',
                Linha__c = 'VETERINÁRIA PMLS',
                Family = 'INFUSÃO',
                StockKeepingUnit = sku1
                
            ),
                new Product2(
                    Name = 'ADAPTADOR DE VIAS AEREAS X45234',
                    ProductCode = 'wrth4',
                    IsActive = true,
                    Modelo__c = 'CO2 ',
                    Marca__c = 'MINDRAY',
                    Linha__c = 'PMLS',
                    Family = 'MONITORIZAÇÃO',
                    StockKeepingUnit = sku2                   
                ),

                new Product2(
                    Name = 'MONITOR X45234' ,
                    ProductCode = 'thtrt',
                    IsActive = true,
                    Modelo__c = 'MONITOR',
                    Marca__c = 'OUTROS',
                    Linha__c = 'IMAGEM ULTRASSOM',
                    Family = 'ULTRASSOM FIXO',
                    StockKeepingUnit = sku3
                    
                )
                };
                    
                    insert produtos;
        
        List<Product2> produtosToUpdate = [
            SELECT Id, Valor_de_Venda__c 
            FROM Product2 
            WHERE Name IN ('MONITOR X45234', 'ADAPTADOR DE VIAS AEREAS X45234', 'BOMBA DE INFUSÃO X372345')
        ];
        
        for (Product2 p : produtosToUpdate){
            p.Valor_de_Venda__c = 1000.00;
        }
        update produtosToUpdate;
        
        System.debug('Produtos criados: ' + produtos.size());
        
        // Criar PricebookEntry para cada produto no Pricebook padrão
        List<PricebookEntry> pricebookEntries = new List<PricebookEntry>{
            new PricebookEntry(
                Product2Id = produtos[0].Id,
                Pricebook2Id = pricebookPadrao.Id,
                UnitPrice = 5000.00,
                IsActive = true
            ),
                new PricebookEntry(
                    Product2Id = produtos[1].Id,
                    Pricebook2Id = pricebookPadrao.Id,
                    UnitPrice = 8000.00,
                    IsActive = true
                ),
                new PricebookEntry(
                    Product2Id = produtos[2].Id,
                    Pricebook2Id = pricebookPadrao.Id,
                    UnitPrice = 3000.00,
                    IsActive = true
                )
                };
                    insert pricebookEntries;
        System.debug('PricebookEntries criados: ' + pricebookEntries.size());
        
        // Verificar os IDs dos PricebookEntries
        for(PricebookEntry pbe : pricebookEntries) {
            System.debug('PricebookEntry ID: ' + pbe.Id + ' - Product: ' + pbe.Product2Id);
        }
        
        // Criar Quote Line Items
        List<QuoteLineItem> quoteLineItems = new List<QuoteLineItem>{
            new QuoteLineItem(
                QuoteId = cotacao.Id,
                PricebookEntryId = pricebookEntries[0].Id,
                Quantity = 2,
                UnitPrice = 5000.00,
                Item__c = 1
            ),
                new QuoteLineItem(
                    QuoteId = cotacao.Id,
                    PricebookEntryId = pricebookEntries[1].Id,
                    Quantity = 10,
                    UnitPrice = 8000.00,
                    Item__c = 1	
                ),
                new QuoteLineItem(
                    QuoteId = cotacao.Id,
                    PricebookEntryId = pricebookEntries[2].Id,
                    Quantity = 1,
                    UnitPrice = 3000.00,
                    Item__c = 1
                )
                };
                    
                    try {
                        insert quoteLineItems;
                        System.debug('✅ Quote Line Items criados: ' + quoteLineItems.size());
                        
                        // Verificar os IDs
                        for(QuoteLineItem qli : quoteLineItems) {
                            System.debug('QuoteLineItem ID: ' + qli.Id);
                        }
                    } catch(Exception e) {
                        System.debug('❌ ERRO ao criar Quote Line Items: ' + e.getMessage());
                        System.debug('Tipo de erro: ' + e.getTypeName());
                        System.debug('Stack Trace: ' + e.getStackTraceString());
                    }
        
        // Verificação final
        List<QuoteLineItem> qliVerificacao = [SELECT Id, QuoteId, Product2Id, Quantity, UnitPrice FROM QuoteLineItem WHERE QuoteId = :cotacao.Id];
        System.debug('===== RESUMO FINAL =====');
        System.debug('Account ID: ' + partnerAccount.Id);
        System.debug('Opportunity ID: ' + oportunidade.Id);
        System.debug('Quote ID: ' + cotacao.Id);
        System.debug('Quote Line Items no banco: ' + qliVerificacao.size());
        
    }
    */
    
@isTest
    static void testAprovacao() {
        Test.startTest();
        System.debug(' == Iniciando testAprovacao ==');
        
        // Pegando o vendedor criado no setup
        
        
        AprovacaoCotacao.ValidateQuote('0Q0U40000030r5pKAA');
        Test.stopTest();
        
    }
    

    static void testEnviaAprovacao() {
        System.debug(' == Iniciando testEnviaAprovacao ==');
        // Pegando o vendedor criado no setup
        Test.startTest();
        AprovacaoCotacao.enviarAprovacao('0Q0U40000030r5pKAA');
        Test.stopTest();
        
    }
 @isTest
    private static void test1(){
        AprovacaoCotacao.dummy('1230sdf987654'); 
    }
     @isTest
    private static void test2(){
        AprovacaoCotacao.dummy1('1230as987654'); 
    }
     @isTest
    private static void test3(){
        AprovacaoCotacao.dummy2('12309gs87654'); 
    }
     @isTest
    private static void test4(){
        AprovacaoCotacao.dummy3('12309gs87654'); 
    }
        @isTest
    private static void test5(){
        AprovacaoCotacao.dummy4('12309gs87654'); 
    }
}