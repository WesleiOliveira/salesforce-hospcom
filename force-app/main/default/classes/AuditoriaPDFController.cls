public class AuditoriaPDFController {
    public String recordId { get; set; }
    
    // Wrapper para organizar perguntas por seção
    public class PerguntaWrapper {
        public String perguntaId { get; set; }
        public String perguntaTexto { get; set; }
        public String resposta { get; set; }
        public String tipoPergunta { get; set; }
        public String secao { get; set; }
        public Decimal posicaoSecao { get; set; }
        public Decimal posicaoPergunta { get; set; }
        public Integer numeroSecao { get; set; }
        public Integer numeroPergunta { get; set; }
        
        // Construtor
        public PerguntaWrapper() {}
    }
    
    // Lista organizada para Visualforce
    public List<PerguntaWrapper> perguntasOrganizadas { get; set; }
    
    // Construtor para extensão de StandardController
    public AuditoriaPDFController(ApexPages.StandardController controller) {
        // Pega o Id do registro da página
        this.recordId = controller.getId();
        carregarPerguntas();
    }
    
    private void carregarPerguntas() {
        perguntasOrganizadas = new List<PerguntaWrapper>();
        
        // Query incluindo os campos de posição para ordenação e o nome da seção
        List<Resposta__c> respostas = [
            SELECT Resposta__c, 
                   Pergunta__c, 
                   Pergunta__r.Name, 
                   Pergunta__r.Pergunta__c, 
                   Pergunta__r.Posicao__c,
                   Pergunta__r.Posicao_da_Secao__c,
                   Tipo_da_Pergunta__c, 
                   Secao__c                  
            FROM Resposta__c
            WHERE Auditoria__c = :recordId
            ORDER BY Pergunta__r.Posicao_da_Secao__c ASC NULLS LAST, 
                     Pergunta__r.Posicao__c ASC NULLS LAST
        ];
        
        // Variáveis para controlar a numeração
        String secaoAtual = '';
        Integer numeroSecao = 0;
        Integer numeroPergunta = 0;
        
        for (Resposta__c r : respostas) {
            PerguntaWrapper pw = new PerguntaWrapper();
            pw.perguntaId = r.Pergunta__r.Name;
            pw.perguntaTexto = r.Pergunta__r.Pergunta__c;
            pw.resposta = r.Resposta__c;
            pw.tipoPergunta = r.Tipo_da_Pergunta__c;
            pw.secao = r.Secao__c;
            pw.posicaoSecao = r.Pergunta__r.Posicao_da_Secao__c;
            pw.posicaoPergunta = r.Pergunta__r.Posicao__c;
            
            // Gerar numeração sequencial
            if (pw.secao != secaoAtual) {
                // Nova seção
                numeroSecao++;
                numeroPergunta = 1;
                secaoAtual = pw.secao;
            } else {
                // Mesma seção
                numeroPergunta++;
            }
            
            pw.numeroSecao = numeroSecao;
            pw.numeroPergunta = numeroPergunta;
            
            perguntasOrganizadas.add(pw);
        }
    }
}