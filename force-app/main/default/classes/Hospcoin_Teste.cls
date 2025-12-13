@isTest(seeAllData=true)
public class Hospcoin_Teste {
    
    @isTest
    private static void teste1() {
        Id carteiraId1;
        Id carteiraId2;
 
        
        try {
            Contact validContact = new Contact(
                FirstName = 'John',
                LastName = 'Doe',
                Email = 'test@example.com'
            );
            Contact validContact2 = new Contact(
                FirstName = 'Jane',
                LastName = 'Doe',
                Email = 'test2@example.com'
            );

            insert new List<Contact>{validContact, validContact2};

                
            Id idContato1 = validContact.Id;
            Id idContato2 = validContact2.Id;

            
            carteiraId1 = CarteiraHospcoin.criaCarteira(idContato1);
            carteiraId2 = CarteiraHospcoin.criaCarteira(idContato2);
        } catch (Exception e) {
            System.debug('Erro ao criar contatos ou carteiras: ' + e.getMessage());
        }

        System.debug('----------------------------'); 
        System.debug(carteiraId1 + '|' + carteiraId2); 
        System.debug('----------------------------');    

        HospcoinTransferencia.transderenciaRH(carteiraId1, carteiraId2, 10, '5S');
        CarteiraHospcoin.transderenciaRH(carteiraId1, carteiraId2, 10, '5S');
        
        try {
            CarteiraHospcoin.carteiraInsereSaldo(carteiraId1, 100);
        } catch (Exception e) {
            System.debug('Erro ao inserir saldo: ' + e.getMessage());
        }

        
        

        
        try {
            Carteira__c carteira1 = CarteiraHospcoin.verificacarteira(carteiraId1);
            Carteira__c carteira2 = CarteiraHospcoin.verificacarteira(carteiraId2);
        } catch (Exception e) {
            System.debug('Erro ao verificar carteiras: ' + e.getMessage());
        }

        
        try {
            Id carteiraIdNula = CarteiraHospcoin.criaCarteira(null);
        } catch (Exception e) {
            System.debug('Erro ao criar carteira com valor nulo: ' + e.getMessage());
        }

        /*
        try {
            Id carteiraRemetenteId = null;
            Id carteiraDestinatariaId = null;
            Decimal quantidade = null;
            String programa = null;

            HospcoinTransferencia.registrarTransferencia(carteiraRemetenteId, carteiraDestinatariaId, quantidade, programa);
        } catch (Exception e) {
            System.debug('Erro ao registrar transferência com valores nulos: ' + e.getMessage());
        }
*/
        
        try {
            Id carteiraRemetenteId = null;
            Decimal quantidade = null;

            CarteiraHospcoin.carteiraInsereSaldo(carteiraRemetenteId, quantidade);
        } catch (Exception e) {
            System.debug('Erro ao inserir saldo com valores nulos: ' + e.getMessage());
        }
    }
}