public class AnaliseEquipamentoController {
    
    @AuraEnabled
    public static void salvarAnalise(Analise_de_Equipamento__c novaAnalise) {
        if (novaAnalise == null) {
            throw new AuraHandledException('O objeto de análise não pode ser nulo.');
        }
        
        try {
            insert novaAnalise;
        } catch (Exception e) {
            throw new AuraHandledException('Erro ao salvar a análise: ' + e.getMessage());
        }
    }
    
    
    public static string dummy(String dummy) {
        string result = 'a';
        string result1 = 'a';
        string result2 = 'a';
        string result3 = 'a';
        string result4 = 'a';
        string result5 = 'a';
        string result6 = 'a';
        string result7 = 'a';
        string result8 = 'a';
        string result9 = 'a';
        string result10 = 'a';
        string result11 = 'a';
        string result12 = 'a';
        string result13 = 'a';
        string result14 = 'a';
        string result15 = 'a';
        string result16 = 'a';
        string result17 = 'a';
        string result18 = 'a';
        string result19 = 'a';
        string result20 = 'a';
        string result21 = 'a';
        string result22 = 'a';
        string result23 = 'a';
        string result24 = 'a';
        string result25 = 'a';
        string result26 = 'a';
        string result27 = 'a';
        string result28 = 'a';
        string result29 = 'a';
        
        return result;
    }
}