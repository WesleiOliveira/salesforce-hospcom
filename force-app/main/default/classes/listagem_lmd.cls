public with sharing class listagem_lmd {
    
    
    public PSQ__c psq {get; set;}
    public List<PSQ__c> procedimentos {get; set;}
    
    public listagem_lmd(ApexPages.StandardController controller){
        Id objeto_pai = ((SObject)controller.getRecord()).Id;
        
        if(objeto_pai.getSObjectType().getDescribe().getName() == 'L_M_D__c')
            listagem_lmd((L_M_D__c)controller.getRecord());
    }
    
       
         
    public void listagem_lmd(L_M_D__c lmd){
        
               List<PSQ__c> psq = [
                        SELECT  Id,Aprovado_por__c, Empresas__c, Departamentos_que_Possuem_C_pias__c, Aprovado_por__r.Name, Aplicao__c, C_digo_do_Documento__c,Data_da_Ultima_Revis_o__c,N_da_Revis_o__c, Observa_o_Revis_o__c, Data_de_Cria_o__c ,Qualidade__c,Recursos_Humanos__c,Solicita_o_reprovada__c,Status__c,T_tulo_do_Documento__c,Name,Usu_rio__c, Revisor__c,Defini_es__c, Equipamentos_e_Softwares__c,Condi_es_Gerais__c, Responsabilidade_e_Autoridade__c, Refer_ncia__c, Formul_rios_Anexos_e_Documentos__c , Registros__c        
                        FROM    PSQ__c
                        WHERE   Status__c = 'Em vigência'
                ];
        
        
                 procedimentos = new List<PSQ__c>(); 

                for(Integer i=0; i<psq.size(); i++){
                    procedimentos.add(psq[i]);
                }
           
}
}