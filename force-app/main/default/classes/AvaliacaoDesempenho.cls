public class AvaliacaoDesempenho {
    
    public List<AggregateResult> avaliacao {get;set;}
    public List<Avaliacao_de_Desempenho__c> comentarios {get;set;}
    public ID ide {get;set;} 

 public AvaliacaoDesempenho(ApexPages.StandardController controlador){
     
    ide = ApexPages.currentPage().getParameters().get('id');
    Avaliacao_de_Desempenho__c av = [SELECT OwnerId, Referencia__c FROM Avaliacao_de_Desempenho__c WHERE ID =: ide];
    
    avaliacao = [SELECT AVG(CG1__c) media1, AVG(CG2__c) media2, AVG(CG3__c) media3, AVG(CG4__c) media4, AVG(CG5__c) media5, AVG(CG6__c) media6, AVG(CG7__c) media7, AVG(CG8__c) media8, AVG(CG9__c) media9,
                                       AVG(CG10__c) media10, AVG(CG11__c) media11, AVG(CG14__c) media14, AVG(CG15__c) media15, AVG(CG16__c) media16, 
                 					   AVG(CGAD3__c) mediaAD3, AVG(CGHO3__c) mediaHO3, AVG(CGSO3__c) mediaSO3, AVG(CGRESPEITO3__c) mediaRESPEITO3,
                 					   Gestor__c gestor
                                       FROM Avaliacao_de_Desempenho__c
                 					   WHERE Referencia__c =: av.Referencia__c
                                       GROUP BY Gestor__c];
     
    comentarios = [SELECT CG12__c, CG13__c, Nome_do_colaborador__c FROM Avaliacao_de_Desempenho__c WHERE Gestor__r.Id =: av.OwnerId AND Referencia__c =: av.Referencia__c];
     
}
}