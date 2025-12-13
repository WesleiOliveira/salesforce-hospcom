public with sharing class listagem_hr {
    
    
        public PSQ__c psq {get; set;}
        public List<HISTORICO_DE_REVISAO__c> historico {get; set;}
    
        public listagem_hr(ApexPages.StandardController controller){
           Id objeto_pai = ((SObject)controller.getRecord()).Id;
        
        if(objeto_pai.getSObjectType().getDescribe().getName() == 'PSQ__c')
            listagem_hr((PSQ__c)controller.getRecord());
        }
    
       
         
    public void listagem_hr(PSQ__c psq){
        
                psq = [
                        SELECT  Id,Observa_o_Revis_o__c ,Qualidade__c,Recursos_Humanos__c,Solicita_o_reprovada__c,Status__c,T_tulo_do_Documento__c,Name,Usu_rio__c, Revisor__c,  Aplicao__c,Defini_es__c, Equipamentos_e_Softwares__c,Condi_es_Gerais__c, Responsabilidade_e_Autoridade__c, Refer_ncia__c, Formul_rios_Anexos_e_Documentos__c , Registros__c        
                        FROM    PSQ__c
                        WHERE   Id = :psq.Id
                ][0];
                
        List<HISTORICO_DE_REVISAO__c> itens_hr_ord = new List<HISTORICO_DE_REVISAO__c>();    
        itens_hr_ord = [
            SELECT  Id,Procedimento_do_Sistema_de_Qualidade__c, Empresa__c, Name, Item__c, L_M_D__c, Natureza_da_Alteracao__c, Data__c
            
            FROM  HISTORICO_DE_REVISAO__c
            WHERE    Procedimento_do_Sistema_de_Qualidade__c = :psq.Id
                        ORDER BY Data__c ASC
        ];
        
        //Decimal qtd_cont=0;
                historico = new List<HISTORICO_DE_REVISAO__c>(); 
        
                for(integer cont_1=0; cont_1<itens_hr_ord.size(); cont_1++){
                    historico.add(itens_hr_ord[cont_1]);
                }
        
       
    
}
}