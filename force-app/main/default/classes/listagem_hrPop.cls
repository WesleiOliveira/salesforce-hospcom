public with sharing class listagem_hrPop {
    
    
        public POP__c pop {get; set;}
        public List<HISTORICO_DE_REVISAO__c> historico {get; set;}
    
        public listagem_hrPop(ApexPages.StandardController controller){
           Id objeto_pai = ((SObject)controller.getRecord()).Id;
        
        if(objeto_pai.getSObjectType().getDescribe().getName() == 'POP__c')
            listagem_hr((POP__c)controller.getRecord());
        }
    
       
         
    public void listagem_hr(POP__c pop){
        
                pop = [
                        SELECT  Id, Qualidade__c,Recursos_Humanos__c,Status__c,T_tulo_do_Documento__c,Name,Usu_rio__c, Revisor__c, Aplica_o__c,Defini_es__c, Equipamentos_e_Softwares__c,Condi_es_Gerais__c, Condi_es_Espec_ficas__c, Responsabilidade_e_Autoridade__c, Formul_rios_Anexos_e_Documentos__c        
                        FROM    POP__c
                        WHERE   Id = :pop.Id
                ][0];	
                
        List<HISTORICO_DE_REVISAO__c> itens_hr_ord = new List<HISTORICO_DE_REVISAO__c>();    
        itens_hr_ord = [
            SELECT  Id,Procedimento_Operacional_Padr_o__c, Empresa__c, Name, Item__c, Natureza_da_Alteracao__c, Data__c
            
            FROM  HISTORICO_DE_REVISAO__c
            WHERE    Procedimento_Operacional_Padr_o__c = :pop.Id
                        ORDER BY Data__c ASC
        ];
        
        //Decimal qtd_cont=0;
                historico = new List<HISTORICO_DE_REVISAO__c>(); 
        
                for(integer cont_1=0; cont_1<itens_hr_ord.size(); cont_1++){
                 historico.add(itens_hr_ord[cont_1]);
                }
        
       
    
}
}