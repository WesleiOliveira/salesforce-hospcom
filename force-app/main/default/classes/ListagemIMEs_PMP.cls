public with sharing class ListagemIMEs_PMP {
    
    public List<ManutencaoPreventivadeApoio__c> imesList { get; set; }
    public List<ManutencaoPreventivadeApoio__c> pmpList { get; set; }
    public List<Gest_o_de_Documentos__c> documentos { get; set; }
    
    
    
    public ListagemIMEs_PMP() {
        listagemIMEs();
    }
    
    public ListagemIMEs_PMP(ApexPages.StandardController controller) {
        this();
    }
    
    public void listagemIMEs() {
        
        
		documentos = GestaoDocumentos.obterDocumentosVigentes();
        
        imesList = [
            SELECT id, Name,Modelo__c, Prazo__c, Ativo__c, Local__c, Categoria_Patrimonial__c, Nome_respons_vel__c, CNPJ__c, Conta_Dias__c, CreatedById, DatadaExecucao__c, Data_de_Validade__c, Empresa__c, Equipamento_de_Apoio__c, LastModifiedById, CurrencyIsoCode, Numero_de_serie__c, Patrimanio__c, Prazo_Restante__c, OwnerId, Responsavel__c, Status__c, Status_Imagem__c ,Nome_do_Ativo__c
            FROM ManutencaoPreventivadeApoio__c 
            WHERE Categoria_Patrimonial__c = 'INSTRUMENTOS DE MEDIÇÃO E ENSAIO'
        ];      
        
        pmpList = [
            SELECT id, Name, Modelo__c, Prazo__c, Ativo__c, Local__c, Categoria_Patrimonial__c, Nome_respons_vel__c, CNPJ__c, Conta_Dias__c, CreatedById, DatadaExecucao__c, Data_de_Validade__c, Empresa__c, Equipamento_de_Apoio__c, LastModifiedById, CurrencyIsoCode, Numero_de_serie__c, Patrimanio__c, Prazo_Restante__c, OwnerId, Responsavel__c, Status__c, Status_Imagem__c, Nome_do_Ativo__c
            FROM ManutencaoPreventivadeApoio__c 
            WHERE Categoria_Patrimonial__c != 'INSTRUMENTOS DE MEDIÇÃO E ENSAIO'
        ];        
    }
}