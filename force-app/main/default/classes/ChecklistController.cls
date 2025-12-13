public class ChecklistController {
    public String titulo { get; set; }
    public List<SecaoWrapper> secoes { get; set; }

    public ChecklistController(ApexPages.StandardController stdCtrl) {
        Checklist_Preenchido__c checklist = (Checklist_Preenchido__c)stdCtrl.getRecord();

        checklist = [
            SELECT Id, JSON_resposta__c 
            FROM Checklist_Preenchido__c 
            WHERE Id = :checklist.Id 
            LIMIT 1
        ];

        try {
            Map<String, Object> jsonData = (Map<String, Object>) JSON.deserializeUntyped(checklist.JSON_resposta__c);
            titulo = (String) jsonData.get('titulo');

            List<Object> secoesRaw = (List<Object>) jsonData.get('secoes');
            secoes = new List<SecaoWrapper>();

            for (Object sec : secoesRaw) {
                Map<String, Object> secaoMap = (Map<String, Object>) sec;
                SecaoWrapper s = new SecaoWrapper();
                s.titulo = (String) secaoMap.get('titulo');
                s.campos = new List<CampoWrapper>();

                for (Object campo : (List<Object>) secaoMap.get('campos')) {
                    Map<String, Object> campoMap = (Map<String, Object>) campo;
                    CampoWrapper c = new CampoWrapper();
                    c.label = (String) campoMap.get('label');
                    c.tipo = (String) campoMap.get('tipo');
                    c.valor = campoMap.get('valor');
                    c.obrigatorio = (campoMap.containsKey('obrigatorio')) ? (Boolean) campoMap.get('obrigatorio') : false;
                    s.campos.add(c);
                }

                secoes.add(s);
            }
        } catch (Exception e) {
            titulo = null;
            secoes = new List<SecaoWrapper>();
        }
    }

    public String getTitulo() {
        return titulo;
    }

    public List<SecaoWrapper> getSecoes() {
        return secoes;
    }

    public class SecaoWrapper {
        public String titulo { get; set; }
        public List<CampoWrapper> campos { get; set; }
    }

    public class CampoWrapper {
        public String label { get; set; }
        public String tipo { get; set; }
        public Object valor { get; set; }
        public Boolean obrigatorio { get; set; }
    }
    @AuraEnabled
    public static void salva(string ot, string idModeloChecklist, string json){
        Checklist_Preenchido__c cp = new Checklist_Preenchido__c();
        cp.Ordem_de_trabalho__c = ot;
        cp.Checklist_Modelo__c = idModeloChecklist;
        cp.JSON_resposta__c = json;
        try{
            insert cp;
        }
        catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    
     @AuraEnabled
    public static void salvarChecklistModelo(String nome, String jsonStr) {
        Checklist_Modelo__c novoChecklist = new Checklist_Modelo__c();
        novoChecklist.Name = nome;
        novoChecklist.JSON_do_checklist__c = jsonStr;
        insert novoChecklist;
    }
}