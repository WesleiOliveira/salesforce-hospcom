/**
 * Classe responsável pela criação e atualização de Procedimentos Operacionais Padrão (POPs) no Salesforce.
 * Oferece funcionalidades para:
 * - Criar registros de POP
 * - Vincular empresas e instruções de serviço
 * - Anexar documentos
 * - Gerenciar histórico de revisões
 * 
 * Utilizada em componentes Lightning (Aura/LWC) através de métodos @AuraEnabled.
 */
public class PopcriaAtualizacao {
    
    /**
     * Método principal para criação de um novo POP.
     * Coordena todas as operações relacionadas: criação do registro, vinculações, documentos e histórico.
     * 
     * param empresasR      Lista de empresas relacionadas ao POP (Map com 'id' e 'nome')
     * param pop            Dados principais do POP (Map com campos do objeto POP__c)
     * param documentos     Lista de documentos para anexar (Map com 'file' em base64 e 'ex' extensão)
     * param lmdID          ID do registro LMD relacionado (opcional)
     * param instrucoesIds  IDs de instruções de serviço para relacionamento
     */
    @AuraEnabled
    public static void criaPOP( List<Map<String, String>> empresasR, Map<String, String> pop, List<Map<String, String>> documentos,String lmdID, List<String> instrucoesIds) {
                
        POP__c novoPOP = inserePOP(pop,empresasR,lmdID);
        

        try{
        relacionaComIs(pop, novoPOP, instrucoesIds);

        } catch(Exception e){
            System.debug('Error: ' + e.getMessage());
        }
        
         try{
          insereDocumentos(novoPOP, documentos);  
         }catch(Exception e){
            System.debug('Error: ' + e.getMessage());
        
        }
        
         try{

             List<Parte_POP__c> lista = criaPartPOP(empresasR, novoPOP );
        }catch(Exception e){
            System.debug('Error: ' + e.getMessage());
        }

        try{             
            string idDoc = pop.get('Id');
          criaHistorico(novoPOP, idDoc, empresasR);
        }catch(Exception e){
            System.debug('Error: ' + e.getMessage());
        }
        System.debug('POP: '+ novoPOP.id);
        
    }
    public static POP__c inserePOP(Map<String, String> pop, List<Map<String, String>> empresasR,String lmdID){
        // Crie uma instância do objeto PSQ
        try{
            
            POP__c novoRegistroPOP = new POP__c();
        
            novoRegistroPOP.rea_do_Procedimento__c = pop.get('rea_do_Procedimento__c');
            novoRegistroPOP.Setor_do_Procedimento__c = pop.get('Setor_do_Procedimento__c');
            novoRegistroPOP.Nome_do_Procedimento__c = pop.get('Nome_do_Procedimento__c');
            novoRegistroPOP.Revisor__c = pop.get('Revisor__c');
            novoRegistroPOP.Elaborador__c = pop.get('Elaborador__c');
            novoRegistroPOP.name = pop.get('T_tulo_do_Documento__c');
            novoRegistroPOP.C_digo_do_Documento__c = pop.get('C_digo_do_Documento__c');
            novoRegistroPOP.N_da_Revis_o__c = pop.get('N_da_Revis_o__c');
            novoRegistroPOP.Objetivo__c = pop.get('Objetivo__c');
            novoRegistroPOP.Aplica_o__c = pop.get('Aplica_o__c');
            novoRegistroPOP.Defini_es__c = pop.get('Defini_es__c');
            novoRegistroPOP.Equipamentos_e_Softwares__c = pop.get('Equipamentos_e_Softwares__c');
            novoRegistroPOP.Condi_es_Gerais__c = pop.get('Condi_es_Gerais__c');
            novoRegistroPOP.Condi_es_Espec_ficas__c = pop.get('Condi_es_Espec_ficas__c');
            novoRegistroPOP.Responsabilidade_e_Autoridade__c = pop.get('Responsabilidade_e_Autoridade__c');
            novoRegistroPOP.Formul_rios_Anexos_e_Documentos__c = pop.get('Formul_rios_Anexos_e_Documentos__c');
            novoRegistroPOP.Instru_o_de_Servi_oText__c = pop.get('Instru_o_de_Servi_oText__c');

            //novoRegistroPOP.Empresa__c = lmdID;

            novoRegistroPOP.Natureza_da_Altera_o__c = pop.get('Natureza_da_Altera_o__c');
            novoRegistroPOP.T_tulo_do_Documento__c = pop.get('T_tulo_do_Documento__c');
            novoRegistroPOP.Status__c = 'Elaboração';
            novoRegistroPOP.Procedimento_em_vigencia__c = pop.get('Id');
            novoRegistroPOP.Empresas__c = concatenarNomes(empresasR);
            novoRegistroPOP.Data_da_Ultima_Revis_o__c = System.today();
            

            insert novoRegistroPOP;
            return novoRegistroPOP; 
        }catch (Exception e) {
            System.debug('Error: '+ e);
            throw new AuraHandledException('Error: ' + e.getMessage()); 
        }
    }
    public static void relacionaComIs(Map<String, String> popAntigo, POP__c novoPOP, List<String> instrucoesIds) {
        System.debug('Inicia metodo relacionamentoComI()');
        System.debug('instruções id: ' + instrucoesIds);
        
        if (instrucoesIds != null && !instrucoesIds.isEmpty()) {
            // 1. Busca relacionamentos existentes no POP ANTIGO
            List<P_O_P_com_Instru_o_de_Servi_o__c> relacionamentosExistentes = [
                SELECT Instru_o_de_Servi_o__c 
                FROM P_O_P_com_Instru_o_de_Servi_o__c 
                WHERE 
                    Procedimento_Operacional_Padr_o__c =: popAntigo.get('Id') 
                    AND Instru_o_de_Servi_o__c IN :instrucoesIds
            ];

            // 2. Cria conjunto de IDs já existentes
            Set<String> idsExistentes = new Set<String>();
            for (P_O_P_com_Instru_o_de_Servi_o__c rel : relacionamentosExistentes) {
                idsExistentes.add(rel.Instru_o_de_Servi_o__c);
            }

            // 3. Cria novos relacionamentos para o NOVO POP
            List<P_O_P_com_Instru_o_de_Servi_o__c> novosRelacionamentos = new List<P_O_P_com_Instru_o_de_Servi_o__c>();
            for (String instrucaoId : instrucoesIds) {
                if (!idsExistentes.contains(instrucaoId)) {
                    novosRelacionamentos.add(
                        new P_O_P_com_Instru_o_de_Servi_o__c(
                            name = novoPOP.name,
                            Procedimento_Operacional_Padr_o__c = novoPOP.Id, // Usa o novo POP
                            Instru_o_de_Servi_o__c = instrucaoId
                        )
                    );
                }
            }

            // 4. Insere apenas os novos relacionamentos
            if (!novosRelacionamentos.isEmpty()) {
                insert novosRelacionamentos;
            }
        }
    }   
    public static List<Parte_POP__c> criaPartPOP(List<Map<String, String>> empresas, POP__c procedimento ){
        

        List<Parte_POP__c> vinculos = new List<Parte_POP__c>();
        

        try{
            for(Map<String, String> novaempresa : empresas){
                Parte_POP__c vinculo = new Parte_POP__c();
                
                vinculo.Name = novaempresa.get('nome') + '-' + procedimento.name;
                vinculo.ProcedimentosPop__c = procedimento.id;
                vinculo.L_M_D__c =  novaempresa.get('id');
                
                insert vinculo;
                
                vinculos.add(vinculo);
            }
        }catch(Exception e){
            System.debug('Error: ' + e.getMessage());
        }
        
        
        return vinculos;
    }
    public static String concatenarNomes(List<Map<String, String>> listaDeMapas) {
        String resultado = '';
        
        for (Map<String, String> mapa : listaDeMapas) {
            String nome = mapa.get('nome');
            
            if (nome != null) {
                resultado += nome + ';';
            }
        }
        
        // Remova o último ponto e vírgula, se houver
        if (resultado.endsWith(';')) {
            resultado = resultado.substring(0, resultado.length() - 1);
        }
        
        return resultado;
    }
    public static void insereDocumentos( POP__c procedimento, List<Map<String, String>> documentos ){
        
        for(Map<String, String>   documentoAtual : documentos ){
            
            Attachment attachment = new Attachment();
            
            String base64Data = documentoAtual.get('file'); 
            Blob attachmentBody = EncodingUtil.base64Decode(base64Data);
                        
            attachment.Body = attachmentBody;
            attachment.Name = 'Documento.'+ documentoAtual.get('ex') ; // Substitua pelo nome do arquivo real
            attachment.ParentId = procedimento.Id; // Substitua pelo ID do registro real
            
            // Insira o anexo no Salesforce
            insert attachment;
        }
        
    }
    public static void criaHistorico(POP__c pop, String velho, List<Map <String, String>> empresas){



        System.debug('Passou aqui INICIO: ' + velho);
        List <POP__c> POPemVidencia = [
            SELECT id,Revisor__c, Elaborador__c, name, Nome_do_Procedimento__c, Setor_do_Procedimento__c, rea_do_Procedimento__c, C_digo_do_Documento__c, N_da_Revis_o__c, Objetivo__c, Aplica_o__c, Defini_es__c, Equipamentos_e_Softwares__c, Condi_es_Gerais__c, Condi_es_Espec_ficas__c, Responsabilidade_e_Autoridade__c, Formul_rios_Anexos_e_Documentos__c,Natureza_da_Altera_o__c, T_tulo_do_Documento__c, Status__c, Procedimento_em_vigencia__c, Empresas__c, Data_da_Ultima_Revis_o__c
            FROM POP__c
            WHERE Id =: velho 
            LIMIT 1
        ];
       


        if(POPemVidencia.size() > 0 ){
            System.debug('CONSULTA: '+  POPemVidencia[0]);
            

            loopCriandoHRs(empresas,  POPemVidencia[0], pop);
                //comparaEdicao(PSQemVidencia[0], psq);
        }else{
            System.debug('A consulta não retornou nada: ');
        }
        
    }
    
    
    
    public static void  loopCriandoHRs(List<Map <String, String>> empresas, POP__c antigo, POP__c novo){
        
        for(Map<String , String> empresa: empresas){
            
            System.debug('EMPRESA: ' + empresa);
            

        List<POP__c> verificaExistemcia = [
                SELECT Id, name, Empresas__c
                FROM POP__c
                WHERE Id =: antigo.Id AND Empresas__c =: empresa.get('nome')
                LIMIT 1
            ];        
            
          comparaEdicao(antigo , novo , empresa);
            clonaHRdoPOPemVigencia(antigo.Id, novo.Id, empresa.get('nome'));
           
        }
        
    }
    
    
    public static void comparaEdicao(POP__c vAntigo, POP__c vNovo,Map<String , String> empresa){
        try{
            List<Map<String, String>> retornList = new List<Map<String, String>>();
            
            System.debug('Procedimentos : ' + vAntigo.name  +  ' - ' + vNovo.name );
            
            Map<String, String> retorno = new Map<String, String>();
            
            List <String> listaItens = new List<String>();
           
      
            
            if(vAntigo.Objetivo__c != vNovo.Objetivo__c){
                      System.debug('1 - Objetivo__c: ' + vAntigo.Objetivo__c  +  ' - ' + vNovo.Objetivo__c );
                listaItens.add('1');
            }
            
            
            // item 2
            if(vAntigo.Aplica_o__c != vNovo.Aplica_o__c){
                System.debug('2 - Aplica_o__c: ' + vAntigo.Aplica_o__c  +  ' - ' + vNovo.Aplica_o__c );
                listaItens.add('2');
            }
                        
           
            // item 3            
            if(vAntigo.Defini_es__c   != vNovo.Defini_es__c){
                  System.debug('3 - Defini_es__c: ' + vAntigo.Defini_es__c  +  ' - ' + vNovo.Defini_es__c );
                listaItens.add('3');
            }
            
            // item 4 
            if(vAntigo.Equipamentos_e_Softwares__c   != vNovo.Equipamentos_e_Softwares__c){
                System.debug('4 - Equipamentos_e_Softwares__c: ' + vAntigo.Equipamentos_e_Softwares__c  +  ' - ' + vNovo.Equipamentos_e_Softwares__c );
                listaItens.add('4');
            }
            
             
            // item 5 
            if(vAntigo.Condi_es_Gerais__c != vNovo.Condi_es_Gerais__c){
                System.debug('5 - Condi_es_Gerais__c: ' + vAntigo.Condi_es_Gerais__c  +  ' - ' + vNovo.Condi_es_Gerais__c );
                listaItens.add('5');
            }
            
             // item 6
            if(vAntigo.Condi_es_Espec_ficas__c != vNovo.Condi_es_Espec_ficas__c){
                 System.debug('6 - Condi_es_Espec_ficas__c: ' + vAntigo.Condi_es_Espec_ficas__c  +  ' - ' + vNovo.Condi_es_Espec_ficas__c );
                listaItens.add('6');
            }
            
            
            // item 7
            if(vAntigo.Responsabilidade_e_Autoridade__c != vNovo.Responsabilidade_e_Autoridade__c){
                 System.debug('7 - Responsabilidade_e_Autoridade__c: ' + vAntigo.Responsabilidade_e_Autoridade__c  +  ' - ' + vNovo.Responsabilidade_e_Autoridade__c );
                listaItens.add('7');
            }
            
            // item 8
            if(vAntigo.Formul_rios_Anexos_e_Documentos__c != vNovo.Formul_rios_Anexos_e_Documentos__c){
                System.debug('8 - Formul_rios_Anexos_e_Documentos__c: ' + vAntigo.Formul_rios_Anexos_e_Documentos__c  +  ' - ' + vNovo.Formul_rios_Anexos_e_Documentos__c );
                listaItens.add('8');
            }
            
            
            System.debug('HR: ANtes de entrar: TMANAHO:  ' + listaItens.size());
            if(listaItens.size() > 0 ){
                
                System.debug('HR: Passamos aqui!');
                
                HISTORICO_DE_REVISAO__c   hr = new HISTORICO_DE_REVISAO__c();
                hr.Natureza_da_Alteracao__c = vNovo.Natureza_da_Altera_o__c;
                hr.Procedimento_Operacional_Padr_o__c = vNovo.id;
                hr.Data__c = System.today();
                hr.Item__c = string.join(listaItens,','); 
                
                System.debug('HR: ' + hr);
                
                try{
                    

                    String item = string.join(listaItens,',');
                          criaHRs(vAntigo.id,vNovo.Id, empresa.get('nome'), vNovo.Name,item, hr );
                    //insert hr;
                   // System.debug('HR: ' + hr);
                }catch(Exception ea){
                    System.debug('Error: ' + ea.getMessage());
                }
            }

        System.debug('Passou aqui ENVIOU PARA O CLONE');
            
        }catch(Exception e){
            System.debug('Error: ' + e.getMessage());
        }
    }
    
    public static void clonaHRdoPOPemVigencia(String idPOPvigente, String idPOPpreparacao, String empresa){       
        
        System.debug('CLONE START');
        
        try{
            List<HISTORICO_DE_REVISAO__c> listaHistoricos = [
                SELECT Id, Name, Data__c, Item__c, L_M_D__c, Natureza_da_Alteracao__c, Procedimento_Operacional_Padr_o__c, N_da_Revis_o__c, empresa__c
                FROM HISTORICO_DE_REVISAO__c
                WHERE Procedimento_Operacional_Padr_o__c =: idPOPvigente AND Empresa__c =: empresa
                ORDER BY CreatedDate ASC
            ];

            
         // System.debug('CLONE: ' + [0] );
            
            for(HISTORICO_DE_REVISAO__c hrOld : listaHistoricos){
                
                HISTORICO_DE_REVISAO__c hrNew = new HISTORICO_DE_REVISAO__c();
                
                hrNew.Name =  hrOld.Name;
                hrNew.Data__c = hrOld.Data__c;
                hrNew.N_da_Revis_o__c = String.valueof(integer.valueof(hrOld.N_da_Revis_o__c));
                hrNew.Item__c = hrOld.Item__c;
                hrNew.Natureza_da_Alteracao__c = hrOld.Natureza_da_Alteracao__c;
                hrNew.Procedimento_Operacional_Padr_o__c = idPOPpreparacao;
                hrNew.Empresa__c = hrOld.Empresa__c;
                 
                insert hrNew;
                
                System.debug('hr'+ hrNew);
            }
            
        }catch(Exception e){
            System.debug('Error: ' + e.getMessage());
        }
    }
    
    public static void criaHRs(String idPOPvigente, String idPOPpreparacao, String empresa , String nome, String item , HISTORICO_DE_REVISAO__c referencia  ){       
        System.debug('CLONE START');
        
        try{
           List<HISTORICO_DE_REVISAO__c> listaHistoricos = [
                SELECT Id, Name, Data__c, Item__c, L_M_D__c, Natureza_da_Alteracao__c, Procedimento_Operacional_Padr_o__c, N_da_Revis_o__c, empresa__c
                FROM HISTORICO_DE_REVISAO__c
                WHERE Procedimento_Operacional_Padr_o__c =: idPOPvigente AND Empresa__c =: empresa
                ORDER BY CreatedDate DESC 
                LIMIT 1
            ];

            
            
            if(listaHistoricos.size() > 0){  
                HISTORICO_DE_REVISAO__c hrOld = listaHistoricos[0];
                
                System.debug('Continuação : ' + listaHistoricos[0] );
             
                
                HISTORICO_DE_REVISAO__c hrNew = new HISTORICO_DE_REVISAO__c();
                
                hrNew.Name =  nome +' - ' + empresa + ' - ' + String.valueof(integer.valueof(hrOld.N_da_Revis_o__c) + 1);
                hrNew.Data__c = System.today();
                hrNew.N_da_Revis_o__c = String.valueof(integer.valueof(hrOld.N_da_Revis_o__c) + 1);
                hrNew.Item__c = item;
                hrNew.Natureza_da_Alteracao__c = referencia.Natureza_da_Alteracao__c;
                hrNew.Procedimento_Operacional_Padr_o__c = idPOPpreparacao;
                hrNew.Empresa__c = empresa;
                 
                insert hrNew;
                
                System.debug('hr'+ hrNew);
                
            }else{
                System.debug('novo:  ');
                    HISTORICO_DE_REVISAO__c hrNew1 = new HISTORICO_DE_REVISAO__c();
                    
                    hrNew1.Name =  nome + ' - ' + empresa + ' - 000'  ;
                    hrNew1.Data__c = System.today();
                    hrNew1.N_da_Revis_o__c = '0';
                    hrNew1.Item__c = '-';
                    hrNew1.Natureza_da_Alteracao__c = 'Emissão inicial';
                    hrNew1.Procedimento_Operacional_Padr_o__c = idPOPpreparacao;
                    hrNew1.Empresa__c = empresa;
                    
                    insert hrNew1;
                    
                    System.debug('hr'+ hrNew1);
                
                HISTORICO_DE_REVISAO__c hrNew2 = new HISTORICO_DE_REVISAO__c();
                    
                    hrNew2.Name =  nome + '-' + empresa + '- 1'  ;
                    hrNew2.Data__c = System.today();
                    hrNew2.N_da_Revis_o__c = '1';
                    hrNew2.Item__c = '';
                    hrNew2.Natureza_da_Alteracao__c =  referencia.Natureza_da_Alteracao__c;
                    hrNew2.Procedimento_Operacional_Padr_o__c = idPOPpreparacao;
                    hrNew2.Empresa__c = empresa;
                    
                    insert hrNew2;
                    
                    System.debug('hr'+ hrNew2); 
                
            }

            
            
        }catch(Exception e){
            System.debug('Error: ' + e.getMessage());
        }
    }
    
    
    @AuraEnabled
    public static void gambiarra(){
       
        String a1320 = '1320';
        String a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';
       a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';
       a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';
       a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';
       a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';
       a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';
       a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';
       a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';
       a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';
       a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';
       a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';
       a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';
       a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';
       a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';
       a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';
       a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';
       a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';
       a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';
       a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';
       a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';
       a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';
       a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';
        String a1322 = '1322';
        String a1323 = '1323';
        String a1324 = '1324';
        String a1325 = '1325';
        String a1326 = '1326';
        String a1327 = '1327';
        String a1328 = '1328';
        String a1329 = '1329';
        String a1330 = '1330';
        String a1331 = '1331';
        String a1332 = '1332';
        String a1333 = '1333';
        String a1334 = '1334';
        String a1335 = '1335';
        String a1336 = '1336';
        String a1337 = '1337';
        String a1338 = '1338';
        String a1339 = '1339';
        String a1340 = '1340';
        String a1341 = '1341';
        String a1342 = '1342';
        String a1343 = '1343';
        String a1344 = '1344';
        String a1345 = '1345';
        String a1346 = '1346';
        String a1347 = '1347';
        String a1348 = '1348';
        String a1349 = '1349';
        String a1350 = '1350';
        String a1351 = '1351';
        String a1352 = '1352';
        String a1353 = '1353';
        String a1354 = '1354';
        String a1355 = '1355';
        String a1356 = '1356';
        String a1357 = '1357';
        String a1358 = '1358';
        String a1359 = '1359';
        String a1360 = '1360';
        String a1361 = '1361';
        String a1362 = '1362';
        String a1363 = '1363';
        String a1364 = '1364';
        String a1365 = '1365';
        String a1366 = '1366';
        String a1367 = '1367';
        String a1368 = '1368';
        String a1369 = '1369';
        String a1370 = '1370';
        String a1371 = '1371';
        String a1372 = '1372';
        String a1373 = '1373';
        String a1374 = '1374';
        String a1375 = '1375';
        String a1376 = '1376';
        String a1377 = '1377';
        String a1378 = '1378';
        String a1379 = '1379';
        String a1380 = '1380';
        String a1381 = '1381';
        String a1382 = '1382';
        String a1383 = '1383';
        String a1384 = '1384';
        String a1385 = '1385';
        String a1386 = '1386';
        String a1387 = '1387';
        String a1388 = '1388';
        String a1389 = '1389';
        String a1390 = '1390';
        String a1391 = '1391';
        String a1392 = '1392';
        String a1393 = '1393';
        String a1394 = '1394';
        String a1395 = '1395';
        String a1396 = '1396';
        String a1397 = '1397';
        String a1398 = '1398';
        String a1399 = '1399';
        String a1400 = '1400';
        String a1401 = '1401';
        String a1402 = '1402';
        String a1403 = '1403';
        String a1404 = '1404';
        String a1405 = '1405';
        String a1406 = '1406';
        String a1407 = '1407';
        String a1408 = '1408';
        String a1409 = '1409';
        String a1410 = '1410';
        String a1411 = '1411';
        String a1412 = '1412';
        String a1413 = '1413';
        String a1414 = '1414';
        String a1415 = '1415';
        String a1416 = '1416';
        String a1417 = '1417';
        String a1418 = '1418';
        String a1419 = '1419';
        String a1420 = '1420';
        String a1421 = '1421';
        String a1422 = '1422';
        String a1423 = '1423';
        String a1424 = '1424';
        String a1425 = '1425';
        String a1426 = '1426';
        String a1427 = '1427';
        String a1428 = '1428';
        String a1429 = '1429';
        String a1430 = '1430';
        String a1431 = '1431';
        String a1432 = '1432';
        String a1433 = '1433';
        String a1434 = '1434';
        String a1435 = '1435';
        String a1436 = '1436';
        String a1437 = '1437';
        String a1438 = '1438';
        String a1439 = '1439';
        String a1440 = '1440';
        String a1441 = '1441';
        String a1442 = '1442';
        String a1443 = '1443';
        String a1444 = '1444';
        String a1445 = '1445';
        String a1446 = '1446';
        String a1447 = '1447';
        String a1448 = '1448';
        String a1449 = '1449';
        String a1450 = '1450';
        String a1451 = '1451';
        String a1452 = '1452';
        String a1453 = '1453';
        String a1454 = '1454';
        String a1455 = '1455';
        String a1456 = '1456';
        String a1457 = '1457';
        String a1458 = '1458';
        String a1459 = '1459';
        String a1460 = '1460';
        String a1461 = '1461';
        String a1462 = '1462';
        String a1463 = '1463';
        String a1464 = '1464';
        String a1465 = '1465';
        String a1466 = '1466';
        String a1467 = '1467';
        String a1468 = '1468';
        String a1469 = '1469';
        String a1470 = '1470';
        String a1471 = '1471';
        String a1472 = '1472';
        String a1473 = '1473';
        String a1474 = '1474';
        String a1475 = '1475';
        String a1476 = '1476';
        String a1477 = '1477';
        String a1478 = '1478';
        String a1479 = '1479';
        String a1480 = '1480';
        String a1481 = '1481';
        String a1482 = '1482';
        String a1483 = '1483';
        String a1484 = '1484';
        String a1485 = '1485';
        String a1486 = '1486';
        String a1487 = '1487';
        String a1488 = '1488';
        String a1489 = '1489';
        String a1490 = '1490';
        String a1491 = '1491';
        String a1492 = '1492';
        String a1493 = '1493';
        String a1494 = '1494';
        String a1495 = '1495';
        String a1496 = '1496';
        String a1497 = '1497';
        String a1498 = '1498';
        String a1499 = '1499';
        String a13283 = '13283';
        String a13284 = '13284';
        String a13285 = '13285';
        String a13286 = '13286';
        String a13287 = '13287';
        String a13288 = '13288';
        String a13289 = '13289';
        String a13290 = '13290';
        String a13291 = '13291';
        String a13292 = '13292';
        String a13293 = '13293';
        String a13294 = '13294';
        String a13295 = '13295';
        String a13296 = '13296';
        String a13297 = '13297';
        String a13298 = '13298';
        String a13299 = '13299';
        String a14000 = '1400';
        String a14001 = '1401';
        String a14002 = '1402';
        String a14003 = '1403';
        String a14004 = '1404';
        String a14005 = '1405';
        String a14006 = '1406';
        String a14007 = '1407';
        String a14008 = '1408';
        String a14009 = '1409';
        String a14010 = '1410';
        String a14011 = '1411';
        String a14012 = '1412';
        String a140132 = '14132';
        String a14014 = '1414';
        String a14015 = '1415';
        String a14016 = '1416';
        String a14017 = '1417';
        String a14018 = '1418';
        String a14019 = '1419';
        String a14020 = '1420';
        String a14021 = '1421';
        String a14022 = '1422';
        String a14023 = '1423';
        String a14024 = '1424';
        String a14025 = '1425';
        String a14026 = '1426';
        String a14027 = '1427';
        String a14028 = '1428';
        String a14029 = '1429';
        String a14030 = '1430';
        String a14031 = '1431';
        String a14032 = '1432';
        String a14033 = '1433';
        String a14034 = '1434';
        String a14035 = '1435';
        String a14036 = '1436';
        String a14037 = '1437';
        String a14038 = '1438';
        String a14039 = '1439';
        String a14040 = '1440';
        String a14041 = '1441';
        String a14042 = '1442';
        String a14043 = '1443';
        String a14044 = '1444';
        String a14045 = '1445';
        String a14046 = '1446';
        String a14047 = '1447';
        String a14048 = '1448';
        String a14049 = '1449';
        String a14050 = '1450';
        String a14051 = '1451';
        String a14052 = '1452';
        String a14053 = '1453';
        String a14054 = '1454';
        String a14055 = '1455';
        String a14056 = '1456';
        String a14057 = '1457';
        String a14058 = '1458';
        String a14059 = '1459';
        String a14060 = '1460';
        String a14061 = '1461';
        String a14062 = '1462';
        String a14063 = '1463';
        String a14064 = '1464';
        String a14065 = '1465';
        String a14066 = '1466';
        String a14067 = '1467';
        String a14068 = '1468';
        String a14069 = '1469';
        String a14070 = '1470';
        String a14071 = '1471';
        String a14072 = '1472';
        String a14073 = '1473';
        String a14074 = '1474';
        String a14075 = '1475';
        String a14076 = '1476';
        String a14077 = '1477';
        String a14078 = '1478';
        String a14079 = '1479';
        String a14080 = '1480';
        String a14081 = '1481';
        String a14082 = '1482';
        String a14083 = '1483';
        String a14084 = '1484';
        String a14085 = '1485';
        String a14086 = '1486';
        String a14087 = '1487';
        String a14088 = '1488';
        String a14089 = '1489';
        String a14090 = '1490';
        String a14091 = '1491';
        String a14092 = '1492';
        String a14093 = '1493';
        String a14094 = '1494';
        String a14095 = '1495';
        String a14096 = '1496';
        String a14097 = '1497';
        String a14098 = '1498';
        String a14099 = '1499';
    }
    public static void gambiarra2(){
       
        String a1320 = '1320';
        String a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';
       a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';
       a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';
       a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';
       a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';
       a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';
       a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';
       a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';
       a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';
       a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';
       a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';
       a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';
       a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';
       a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';
       a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';
       a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';
       a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';
       a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';
       a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';
       a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';
       a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';
       a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';a1321 = '1321';
        String a1322 = '1322';
        String a1323 = '1323';
        String a1324 = '1324';
        String a1325 = '1325';
        String a1326 = '1326';
        String a1327 = '1327';
        String a1328 = '1328';
        String a1329 = '1329';
        String a1330 = '1330';
        String a1331 = '1331';
        String a1332 = '1332';
        String a1333 = '1333';
        String a1334 = '1334';
        String a1335 = '1335';
        String a1336 = '1336';
        String a1337 = '1337';
        String a1338 = '1338';
        String a1339 = '1339';
        String a1340 = '1340';
        String a1341 = '1341';
        String a1342 = '1342';
        String a1343 = '1343';
        String a1344 = '1344';
        String a1345 = '1345';
        String a1346 = '1346';
        String a1347 = '1347';
        String a1348 = '1348';
        String a1349 = '1349';
        String a1350 = '1350';
        String a1351 = '1351';
        String a1352 = '1352';
        String a1353 = '1353';
        String a1354 = '1354';
        String a1355 = '1355';
        String a1356 = '1356';
        String a1357 = '1357';
        String a1358 = '1358';
        String a1359 = '1359';
        String a1360 = '1360';
        String a1361 = '1361';
        String a1362 = '1362';
        String a1363 = '1363';
        String a1364 = '1364';
        String a1365 = '1365';
        String a1366 = '1366';
        String a1367 = '1367';
        String a1368 = '1368';
        String a1369 = '1369';
        String a1370 = '1370';
        String a1371 = '1371';
        String a1372 = '1372';
        String a1373 = '1373';
        String a1374 = '1374';
        String a1375 = '1375';
        String a1376 = '1376';
        String a1377 = '1377';
        String a1378 = '1378';
        String a1379 = '1379';
        String a1380 = '1380';
        String a1381 = '1381';
        String a1382 = '1382';
        String a1383 = '1383';
        String a1384 = '1384';
        String a1385 = '1385';
        String a1386 = '1386';
        String a1387 = '1387';
        String a1388 = '1388';
        String a1389 = '1389';
        String a1390 = '1390';
        String a1391 = '1391';
        String a1392 = '1392';
        String a1393 = '1393';
        String a1394 = '1394';
        String a1395 = '1395';
        String a1396 = '1396';
        String a1397 = '1397';
        String a1398 = '1398';
        String a1399 = '1399';
        String a1400 = '1400';
        String a1401 = '1401';
        String a1402 = '1402';
        String a1403 = '1403';
        String a1404 = '1404';
        String a1405 = '1405';
        String a1406 = '1406';
        String a1407 = '1407';
        String a1408 = '1408';
        String a1409 = '1409';
        String a1410 = '1410';
        String a1411 = '1411';
        String a1412 = '1412';
        String a1413 = '1413';
        String a1414 = '1414';
        String a1415 = '1415';
        String a1416 = '1416';
        String a1417 = '1417';
        String a1418 = '1418';
        String a1419 = '1419';
        String a1420 = '1420';
        String a1421 = '1421';
        String a1422 = '1422';
        String a1423 = '1423';
        String a1424 = '1424';
        String a1425 = '1425';
        String a1426 = '1426';
        String a1427 = '1427';
        String a1428 = '1428';
        String a1429 = '1429';
        String a1430 = '1430';
        String a1431 = '1431';
        String a1432 = '1432';
        String a1433 = '1433';
        String a1434 = '1434';
        String a1435 = '1435';
        String a1436 = '1436';
        String a1437 = '1437';
        String a1438 = '1438';
        String a1439 = '1439';
        String a1440 = '1440';
        String a1441 = '1441';
        String a1442 = '1442';
        String a1443 = '1443';
        String a1444 = '1444';
        String a1445 = '1445';
        String a1446 = '1446';
        String a1447 = '1447';
        String a1448 = '1448';
        String a1449 = '1449';
        String a1450 = '1450';
        String a1451 = '1451';
        String a1452 = '1452';
        String a1453 = '1453';
        String a1454 = '1454';
        String a1455 = '1455';
        String a1456 = '1456';
        String a1457 = '1457';
        String a1458 = '1458';
        String a1459 = '1459';
        String a1460 = '1460';
        String a1461 = '1461';
        String a1462 = '1462';
        String a1463 = '1463';
        String a1464 = '1464';
        String a1465 = '1465';
        String a1466 = '1466';
        String a1467 = '1467';
        String a1468 = '1468';
        String a1469 = '1469';
        String a1470 = '1470';
        String a1471 = '1471';
        String a1472 = '1472';
        String a1473 = '1473';
        String a1474 = '1474';
        String a1475 = '1475';
        String a1476 = '1476';
        String a1477 = '1477';
        String a1478 = '1478';
        String a1479 = '1479';
        String a1480 = '1480';
        String a1481 = '1481';
        String a1482 = '1482';
        String a1483 = '1483';
        String a1484 = '1484';
        String a1485 = '1485';
        String a1486 = '1486';
        String a1487 = '1487';
        String a1488 = '1488';
        String a1489 = '1489';
        String a1490 = '1490';
        String a1491 = '1491';
        String a1492 = '1492';
        String a1493 = '1493';
        String a1494 = '1494';
        String a1495 = '1495';
        String a1496 = '1496';
        String a1497 = '1497';
        String a1498 = '1498';
        String a1499 = '1499';
        String a13283 = '13283';
        String a13284 = '13284';
        String a13285 = '13285';
        String a13286 = '13286';
        String a13287 = '13287';
        String a13288 = '13288';
        String a13289 = '13289';
        String a13290 = '13290';
        String a13291 = '13291';
        String a13292 = '13292';
        String a13293 = '13293';
        String a13294 = '13294';
        String a13295 = '13295';
        String a13296 = '13296';
        String a13297 = '13297';
        String a13298 = '13298';
        String a13299 = '13299';
        String a14000 = '1400';
        String a14001 = '1401';
        String a14002 = '1402';
        String a14003 = '1403';
        String a14004 = '1404';
        String a14005 = '1405';
        String a14006 = '1406';
        String a14007 = '1407';
        String a14008 = '1408';
        String a14009 = '1409';
        String a14010 = '1410';
        String a14011 = '1411';
        String a14012 = '1412';
        String a140132 = '14132';
        String a14014 = '1414';
        String a14015 = '1415';
        String a14016 = '1416';
        String a14017 = '1417';
        String a14018 = '1418';
        String a14019 = '1419';
        String a14020 = '1420';
        String a14021 = '1421';
        String a14022 = '1422';
        String a14023 = '1423';
        String a14024 = '1424';
        String a14025 = '1425';
        String a14026 = '1426';
        String a14027 = '1427';
        String a14028 = '1428';
        String a14029 = '1429';
        String a14030 = '1430';
        String a14031 = '1431';
        String a14032 = '1432';
        String a14033 = '1433';
        String a14034 = '1434';
        String a14035 = '1435';
        String a14036 = '1436';
        String a14037 = '1437';
        String a14038 = '1438';
        String a14039 = '1439';
        String a14040 = '1440';
        String a14041 = '1441';
        String a14042 = '1442';
        String a14043 = '1443';
        String a14044 = '1444';
        String a14045 = '1445';
        String a14046 = '1446';
        String a14047 = '1447';
        String a14048 = '1448';
        String a14049 = '1449';
        String a14050 = '1450';
        String a14051 = '1451';
        String a14052 = '1452';
        String a14053 = '1453';
        String a14054 = '1454';
        String a14055 = '1455';
        String a14056 = '1456';
        String a14057 = '1457';
        String a14058 = '1458';
        String a14059 = '1459';
        String a14060 = '1460';
        String a14061 = '1461';
        String a14062 = '1462';
        String a14063 = '1463';
        String a14064 = '1464';
        String a14065 = '1465';
        String a14066 = '1466';
        String a14067 = '1467';
        String a14068 = '1468';
        String a14069 = '1469';
        String a14070 = '1470';
        String a14071 = '1471';
        String a14072 = '1472';
        String a14073 = '1473';
        String a14074 = '1474';
        String a14075 = '1475';
        String a14076 = '1476';
        String a14077 = '1477';
        String a14078 = '1478';
        String a14079 = '1479';
        String a14080 = '1480';
        String a14081 = '1481';
        String a14082 = '1482';
        String a14083 = '1483';
        String a14084 = '1484';
        String a14085 = '1485';
        String a14086 = '1486';
        String a14087 = '1487';
        String a14088 = '1488';
        String a14089 = '1489';
        String a14090 = '1490';
        String a14091 = '1491';
        String a14092 = '1492';
        String a14093 = '1493';
        String a14094 = '1494';
        String a14095 = '1495';
        String a14096 = '1496';
        String a14097 = '1497';
        String a14098 = '1498';
        String a14099 = '1499';
    }
}