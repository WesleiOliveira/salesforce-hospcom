trigger RegistroDeDemoRapidaValida on Registro_de_Demo_Rapida__c (before insert, before update) {
    for (Registro_de_Demo_Rapida__c newRecord : Trigger.new) {
        // Query para verificar sobreposição de datas para o mesmo Comodato__c
        List<Registro_de_Demo_Rapida__c> conflictingRecords = [
            SELECT Id, Data_da_Demonstracao__c, Data_de_Termino_da_Demonstracao__c
            FROM Registro_de_Demo_Rapida__c
            WHERE Comodato__c = :newRecord.Comodato__c
            AND Id != :newRecord.Id
            AND Status__c NOT IN ('Cancelada')
            AND (
                (Data_da_Demonstracao__c <= :newRecord.Data_de_Termino_da_Demonstracao__c 
                AND Data_de_Termino_da_Demonstracao__c >= :newRecord.Data_da_Demonstracao__c)
                OR
                (Data_da_Demonstracao__c <= :newRecord.Data_da_Demonstracao__c 
                AND Data_de_Termino_da_Demonstracao__c >= :newRecord.Data_da_Demonstracao__c)
                OR
                (Data_da_Demonstracao__c <= :newRecord.Data_de_Termino_da_Demonstracao__c 
                AND Data_de_Termino_da_Demonstracao__c >= :newRecord.Data_de_Termino_da_Demonstracao__c)
                OR
                (Data_da_Demonstracao__c >= :newRecord.Data_da_Demonstracao__c 
                AND Data_de_Termino_da_Demonstracao__c <= :newRecord.Data_de_Termino_da_Demonstracao__c)
            )
        ];

        // Se encontrar registros conflitantes, adicionar uma mensagem de erro
        if (!conflictingRecords.isEmpty()) {
            newRecord.addError('As datas da demonstração sobrepõem com outra demonstração existente para o mesmo comodato.');
        }
    }
}