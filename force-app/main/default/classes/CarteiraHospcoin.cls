public class CarteiraHospcoin {
    
    @AuraEnabled
    public static Id criaCarteira(Id colaboradorId) {
        if (colaboradorId == null) {
            throw new AuraHandledException('O campo Colaborador__c não pode ser nulo.');
        }

        Carteira__c novaCarteira = new Carteira__c(
            Colaborador__c = colaboradorId
        );

        insert novaCarteira;

        return novaCarteira.Id;
    }
    
    
    @AuraEnabled
    public static void carteiraInsereSaldo(Id idCarteira, Decimal newSaldo) {
        if (idCarteira == null) {
            throw new AuraHandledException('Id da Carteira não foi passado.');
        }
        if (newSaldo == null) {
            throw new AuraHandledException('Não foi passado o saldo.');
        }
        
        Carteira__c carteira = verificacarteira(idCarteira);
        
        if (carteira == null) {
            throw new AuraHandledException('Carteira não encontrada.');
        }
        
        carteira.Saldo__c += newSaldo;
        
        // Atualizar a carteira no banco de dados
        update carteira;
    }

    
    @AuraEnabled
    public static Carteira__c verificacarteira(Id idCarteira) {
        try {
            return [
                SELECT Id, Name, Saldo__c, Colaborador__c 
                FROM Carteira__c
                WHERE Id = :idCarteira
                LIMIT 1
            ];
        } catch (Exception e) {
            throw new AuraHandledException('Carteira não encontrada.');
        }
    }
    
    
    @AuraEnabled
    public static void transderenciaRH(Id idCarteiraDestinataria, Id idCarteiraRemetente, Decimal saldo, String programa){
        
        HospcoinTransferencia.transderenciaRH(idCarteiraDestinataria, idCarteiraRemetente, saldo, programa);
    }
}