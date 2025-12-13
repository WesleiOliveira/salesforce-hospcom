@isTest(seealldata = true)
public class ContatosValidacaoZapEmail_Test {

    @isTest
    static void testConsultaWhatsapp() {
        
        Contact contatoTeste = new Contact();
        contatoTeste.AccountId = '001i00000085QYb';//0015300000R5SUL
        contatoTeste.FirstName = 'class';
        contatoTeste.LastName = 'teste';
        contatoTeste.Cargo__c = 'Outros';
        contatoTeste.Title = 'Executivo de vendas';
        contatoTeste.CPF__c = '617.259.750-76'; 
        contatoTeste.Phone = '(62) 99999-5702';
        contatoTeste.Email = 'sousawitor@gmail.com';

        insert contatoTeste;

        Test.setMock(HttpCalloutMock.class, new MonkverificaWhatsapp());

        ValidacoesContato.consultaWhatsapp(contatoTeste.Phone,contatoTeste.MobilePhone,contatoTeste.Id );
        ValidacoesContato.consultaEmail(contatoTeste.Email,contatoTeste.Id);
    }    
}