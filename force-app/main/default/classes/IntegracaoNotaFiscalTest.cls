@isTest(seeAllData=true)
public class IntegracaoNotaFiscalTest {
    @isTest
    static void testProcessarNotasFiscais() {
        // Insere uma nota fiscal já existente para verificar a prevenção de duplicatas
        Nota_Fiscal_de_Pedido_de_Compra__c notaExistente = new Nota_Fiscal_de_Pedido_de_Compra__c();
        notaExistente.Name = '123456';
        notaExistente.Chave_de_Acesso__c = '12345678901234567890123456789012345678901234';
        notaExistente.Pedido_de_Compra__c = 'a1bU4000002GceUIAS';
        notaExistente.Valor_da_nota__c = 100.00;
        notaExistente.Data_de_emissao__c = Date.today();
        insert notaExistente;
        
        // Cria uma simulação de resposta HTTP com um XML base64 codificado
        String fakeXml = '<nfeProc><NFe><infNFe><ide><dhEmi>2024-08-13T12:00:00</dhEmi></ide><emit><xNome>Fornecedor Teste</xNome></emit><total><ICMSTot><vNF>500.00</vNF></ICMSTot></total><ide><nNF>654321</nNF></ide></infNFe></NFe></nfeProc>';
        String xmlBase64 = EncodingUtil.base64Encode(Blob.valueOf(fakeXml));
        
        String jsonResponse = '{"data":[{"access_key":"98765432109876543210987654321098765432109876","xml":"' + xmlBase64 + '"}]}';
        
        // Simula uma resposta HTTP de sucesso
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerato2r(jsonResponse));
        
        // Chama o método a ser testado
        Test.startTest();
        IntegracaoNotaFiscal.processarNotasFiscais();
        Test.stopTest();
        
        // Verifica se a nova nota fiscal foi inserida corretamente
        Nota_buscada__c novaNota = [
            SELECT Name, Nome_do_Fornecedor__c, Chave_de_Acesso__c, Valor_da_nota__c, Data_de_emissao__c 
            FROM Nota_buscada__c 
            WHERE Chave_de_Acesso__c = '98765432109876543210987654321098765432109876' 
            LIMIT 1
        ];
        
        System.assertEquals('654321', novaNota.Name);
        System.assertEquals('Fornecedor Teste', novaNota.Nome_do_Fornecedor__c);
        System.assertEquals('98765432109876543210987654321098765432109876', novaNota.Chave_de_Acesso__c);
        System.assertEquals(500.00, novaNota.Valor_da_nota__c);
        System.assertEquals(Date.valueOf('2024-08-13'), novaNota.Data_de_emissao__c);
        
        // Verifica se a nota fiscal duplicada não foi inserida
        List<Nota_Fiscal_de_Pedido_de_Compra__c> notasExistentes = [
            SELECT Id 
            FROM Nota_Fiscal_de_Pedido_de_Compra__c 
            WHERE Chave_de_Acesso__c = '12345678901234567890123456789012345678901234'
        ];
        System.assertEquals(1, notasExistentes.size());
    }
    @isTest
    static void testProcessarNotasFiscaiServ() {
        // Insere uma nota fiscal já existente para verificar a prevenção de duplicatas
        Nota_Fiscal_de_Pedido_de_Compra__c notaExistente = new Nota_Fiscal_de_Pedido_de_Compra__c();
        notaExistente.Name = '123456';
        notaExistente.Chave_de_Acesso__c = '12345678901234567890123456789012345678901234';
        notaExistente.Pedido_de_Compra__c = 'a1bU4000002GceUIAS';
        notaExistente.Valor_da_nota__c = 100.00;
        notaExistente.Data_de_emissao__c = Date.today();
        insert notaExistente;
        
        // Cria uma simulação de resposta HTTP com um XML base64 codificado
        String fakeXml = '<?xml version="1.0" encoding="UTF-8"?><CompNfse xmlns="http://www.abrasf.org.br/nfse.xsd"><Nfse versao="2.02"><InfNfse Id="NFS52087072250930748000161000000000000424088875792063"><Numero>4</Numero><CodigoVerificacao>NFS52087072250930748000161000000000000424088875792063</CodigoVerificacao><DataEmissao>2024-08-08T17:02:32</DataEmissao><ValoresNfse><ValorLiquidoNfse>1300.00</ValorLiquidoNfse></ValoresNfse><PrestadorServico><IdentificacaoPrestador><CpfCnpj><Cnpj>50930748000161</Cnpj></CpfCnpj></IdentificacaoPrestador><RazaoSocial>50.930.748 THAIS FERREIRA ROSSI</RazaoSocial><Endereco><Endereco>C155</Endereco><Numero>0</Numero><Bairro>JARDIM AMERICA</Bairro><CodigoMunicipio>5208707</CodigoMunicipio><Uf>GO</Uf><Cep>74275150</Cep></Endereco><Contato><Telefone>62981890315</Telefone><Email>cheesetruckgoiania@hotmail.com</Email></Contato></PrestadorServico><OrgaoGerador><CodigoMunicipio>5208707</CodigoMunicipio></OrgaoGerador><DeclaracaoPrestacaoServico><InfDeclaracaoPrestacaoServico Id="DPS520870725093074800016100900000000000000004"><Rps Id="DPS520870725093074800016100900000000000000004"><IdentificacaoRps><Numero>4</Numero><Serie>900</Serie></IdentificacaoRps><DataEmissao>2024-08-08</DataEmissao><Status>1</Status></Rps><Competencia>2024-08-08</Competencia><Servico><Valores><ValorServicos>1300.00</ValorServicos></Valores><IssRetido>2</IssRetido><ItemListaServico>1711</ItemListaServico><Discriminacao>Fornecimento de frios durante período de tempo determinado por contrato</Discriminacao><CodigoMunicipio>5208707</CodigoMunicipio><CodigoPais>1058</CodigoPais><ExigibilidadeISS>1</ExigibilidadeISS><MunicipioIncidencia>5208707</MunicipioIncidencia></Servico><Prestador><CpfCnpj><Cnpj>50930748000161</Cnpj></CpfCnpj></Prestador><Tomador><IdentificacaoTomador><CpfCnpj><Cnpj>05743288000108</Cnpj></CpfCnpj></IdentificacaoTomador><RazaoSocial>HOSPCOM EQUIPAMENTOS HOSPITALARES LTDA</RazaoSocial><Endereco><Endereco>104</Endereco><Numero>74</Numero><Bairro>SETOR SUL</Bairro><CodigoMunicipio>5208707</CodigoMunicipio><Cep>74083300</Cep></Endereco><Contato><Telefone>6232415555</Telefone><Email>administrativo@hospcom.net</Email></Contato></Tomador><RegimeEspecialTributacao>0</RegimeEspecialTributacao><OptanteSimplesNacional>1</OptanteSimplesNacional><IncentivoFiscal>2</IncentivoFiscal></InfDeclaracaoPrestacaoServico></DeclaracaoPrestacaoServico></InfNfse></Nfse></CompNfse>';
        String xmlBase64 = EncodingUtil.base64Encode(Blob.valueOf(fakeXml));
        
        String jsonResponse = '{"data":[{"id":"98765432109876543210987654321098765432109876","xml":"' + xmlBase64 + '"}]}';
        
        // Simula uma resposta HTTP de sucesso
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerato2r(jsonResponse));
        
        // Chama o método a ser testado
        Test.startTest();
        IntegracaoNotaFiscal.processarNotasFiscaisServ();
        Test.stopTest();
        
        // Verifica se a nova nota fiscal foi inserida corretamente
        Nota_buscada__c novaNota = [
            SELECT Name, Nome_do_Fornecedor__c, Chave_de_Acesso__c, Valor_da_nota__c, Data_de_emissao__c 
            FROM Nota_buscada__c 
            WHERE Chave_de_Acesso__c = 'NFS52087072250930748000161000000000000424088875792063' 
            LIMIT 1
        ];
        
        System.assertEquals('4', novaNota.Name);
        System.assertEquals('50.930.748 THAIS FERREIRA ROSSI', novaNota.Nome_do_Fornecedor__c);
        System.assertEquals('NFS52087072250930748000161000000000000424088875792063', novaNota.Chave_de_Acesso__c);
        System.assertEquals(1300.00, novaNota.Valor_da_nota__c);
        System.assertEquals(Date.valueOf('2024-08-08'), novaNota.Data_de_emissao__c);
        
        // Verifica se a nota fiscal duplicada não foi inserida
        List<Nota_Fiscal_de_Pedido_de_Compra__c> notasExistentes = [
            SELECT Id 
            FROM Nota_Fiscal_de_Pedido_de_Compra__c 
            WHERE Chave_de_Acesso__c = '12345678901234567890123456789012345678901234'
        ];
        System.assertEquals(1, notasExistentes.size());
    }
}