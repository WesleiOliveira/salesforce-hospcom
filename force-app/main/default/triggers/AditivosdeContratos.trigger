trigger AditivosdeContratos on Aditivos_Contratuais__c (before insert, before update) {
public Contrato_de_Servi_o__c contrato {get;set;}    
public string valorAtual;
    
    for (Aditivos_Contratuais__c cs:trigger.new) {
        
            contrato = [
            SELECT N_mero_da_Proposta_Contrato__c, Valor_Mensal_da_Proposta__c
            FROM Contrato_de_Servi_o__c
            WHERE Id = :cs.Contrato_de_Servi_o_Relacionado__c
                
        ];
                
        if((cs.Quantidade_de_Ativos_no_Aditivo__c <= 0 || cs.Quantidade_de_produtos_na_proposta__c <= 0) && cs.Dura_o_Adicional__c > 0 && cs.Atualizacao_monetaria__c == false && cs.Editar_Clausulas__c == false){ // Aditivo apenas de prazo
            cs.Cl_usula_s_Alterada_s__c = '<b>CLAUSULA PRIMEIRA - DO PRAZO/ RENOVAÇÃO</b>';
            cs.Cl_usula_s_Alterada_s__c += '<p style="text-align:justify;"><b>1.1.</b> Fica prorrogado o prazo de vigência do contrato de locação nº ' + contrato.N_mero_da_Proposta_Contrato__c + ' pelo período de mais '+ cs.Dura_o_Adicional__c + '&nbsp;' +cs.Tipo_da_Dura_o__c +' contados da data de ' + cs.Incio_da_vigencia2__c +', permanecendo a locação no valor anteriormente contratado.</p>';
            cs.Cl_usula_s_Alterada_s__c += '<br/>';
            cs.Cl_usula_s_Alterada_s__c += '<b>CLAUSULA SEGUNDA - DA RATIFICAÇÃO DAS CLÁUSULAS</b>';
            cs.Cl_usula_s_Alterada_s__c += '<p style="text-align:justify;"><b>2.1.</b> Ficam ratificadas todas as demais cláusulas e condições estabelecidas no Contrato n° ' + contrato.N_mero_da_Proposta_Contrato__c + ' que não colidirem com o presente termo aditivo.</p>';
        }
        
        if((cs.Quantidade_de_Ativos_no_Aditivo__c <= 0 || cs.Quantidade_de_produtos_na_proposta__c <= 0) && cs.Dura_o_Adicional__c > 0 && cs.Atualizacao_monetaria__c == true && cs.Editar_Clausulas__c == false){ // Aditivo de prazo e atualização monetária
            cs.Cl_usula_s_Alterada_s__c = '<b>CLAUSULA PRIMEIRA - DO PRAZO/ RENOVAÇÃO</b>';
            cs.Cl_usula_s_Alterada_s__c += '<p style="text-align:justify;"><b>1.1.</b> Fica prorrogado o prazo de vigência do contrato de nº ' + contrato.N_mero_da_Proposta_Contrato__c + ' pelo período de mais '+ cs.Dura_o_Adicional__c + '&nbsp;' +cs.Tipo_da_Dura_o__c +' contados da data de ' +  cs.Incio_da_vigencia2__c +'.</p>';
            cs.Cl_usula_s_Alterada_s__c += '<br/>';
            cs.Cl_usula_s_Alterada_s__c += '<b>CLAUSULA SEGUNDA - DO VALOR/ REAJUSTE DO CONTRATO</b>';
            cs.Cl_usula_s_Alterada_s__c += '<p style="text-align:justify;"><b>2.1.</b> Em razão da previsão de atualização monetária anual prevista no contrato de locação, o valor da presente locação passa a ser de R$ ' + cs.Valor_atualizado__c + '.</p>';
            cs.Cl_usula_s_Alterada_s__c += '<br/>';
            cs.Cl_usula_s_Alterada_s__c += '<b>CLAUSULA TERCEIRA - DA RATIFICAÇÃO DAS CLÁUSULAS</b>';
            cs.Cl_usula_s_Alterada_s__c += '<p style="text-align:justify;"><b>3.1.</b> Ficam ratificadas todas as demais cláusulas e condições estabelecidas no Contrato de locação n° ' + contrato.N_mero_da_Proposta_Contrato__c + ' que não colidirem com o presente termo aditivo.</p>';
        }
        
        if((cs.Quantidade_de_Ativos_no_Aditivo__c > 0 || cs.Quantidade_de_produtos_na_proposta__c > 0) && cs.Dura_o_Adicional__c > 0 && cs.Atualizacao_monetaria__c == false && cs.Editar_Clausulas__c == false){ //Aditivo de prazo + adição/supressão sem atualização monetária
            cs.Cl_usula_s_Alterada_s__c = '<p style="text-align:justify;"><b>1.2.</b> Em razão da adição e/ou supressão dos equipamentos ora mencionados, fica alterado o valor do contrato de locação de ' + contrato.Valor_Mensal_da_Proposta__c + ' para ' + cs.Valor_Total_Geral__c + '.</p>';
            cs.Cl_usula_s_Alterada_s__c += '<br/>';
            cs.Cl_usula_s_Alterada_s__c += '<b>CLAUSULA SEGUNDA - DO PRAZO/ RENOVAÇÃO</b>';
            cs.Cl_usula_s_Alterada_s__c += '<p style="text-align:justify;"><b>2.1.</b> Fica prorrogado o prazo de vigência do contrato de locação de nº ' + contrato.N_mero_da_Proposta_Contrato__c +' pelo período de mais '+ cs.Dura_o_Adicional__c + '&nbsp;' +cs.Tipo_da_Dura_o__c +' contados da data de ' +  cs.Incio_da_vigencia2__c +'.</p>';
            cs.Cl_usula_s_Alterada_s__c += '<br/>';
            cs.Cl_usula_s_Alterada_s__c += '<b>CLAUSULA TERCEIRA - DA RATIFICAÇÃO DAS CLÁUSULAS</b>';
            cs.Cl_usula_s_Alterada_s__c += '<p style="text-align:justify;"><b>3.1.</b> Ficam ratificadas todas as demais cláusulas e condições estabelecidas no contrato n° ' + contrato.N_mero_da_Proposta_Contrato__c + ' que não colidirem com o presente termo aditivo.</p>';
        }
        
        if((cs.Quantidade_de_Ativos_no_Aditivo__c > 0 || cs.Quantidade_de_produtos_na_proposta__c > 0) && cs.Dura_o_Adicional__c > 0 && cs.Atualizacao_monetaria__c == true && cs.Editar_Clausulas__c == false){ //Aditivo de prazo + adição/supressão com atualização monetária
            cs.Cl_usula_s_Alterada_s__c = '<b>CLAUSULA SEGUNDA - DO PRAZO/ RENOVAÇÃO</b>';
            cs.Cl_usula_s_Alterada_s__c += '<p style="text-align:justify;"><b>2.1.</b> Fica prorrogado o prazo de vigência do contrato de locação de nº' + contrato.N_mero_da_Proposta_Contrato__c + ' pelo período de mais '+ cs.Dura_o_Adicional__c + '&nbsp;' +cs.Tipo_da_Dura_o__c +' contados da data de ' +  cs.Incio_da_vigencia2__c +'.</p>';
            cs.Cl_usula_s_Alterada_s__c += '<br/>';
            cs.Cl_usula_s_Alterada_s__c += '<b>CLAUSULA TERCEIRA - DO VALOR/ REAJUSTE DO CONTRATO</b>';
            cs.Cl_usula_s_Alterada_s__c += '<p style="text-align:justify;"><b>3.1.</b> Em razão da previsão de atualização monetária anual prevista no contrato de locação, o valor da presente locação passa a ser de R$ ' + cs.Valor_atualizado__c + '.</p>';
            cs.Cl_usula_s_Alterada_s__c += '<br/>';
            cs.Cl_usula_s_Alterada_s__c += '<b>CLAUSULA QUARTA - DA RATIFICAÇÃO DAS CLÁUSULAS</b>';
            cs.Cl_usula_s_Alterada_s__c += '<p style="text-align:justify;"><b>4.1.</b> Ficam ratificadas todas as demais cláusulas e condições estabelecidas no contrato n° ' + contrato.N_mero_da_Proposta_Contrato__c + ' que não colidirem com o presente termo aditivo.</p>';
        }
        
        if((cs.Quantidade_de_Ativos_no_Aditivo__c > 0 || cs.Quantidade_de_produtos_na_proposta__c > 0) && (cs.Dura_o_Adicional__c <= 0 || cs.Dura_o_Adicional__c == null) && cs.Editar_Clausulas__c == false){ //Aditivo apenas de adição/supressão sem prazo adicional
            cs.Cl_usula_s_Alterada_s__c = '<p style="text-align:justify;"><b>1.2.</b> Em razão da adição e/ou supressão dos equipamentos ora mencionados, fica alterado o valor do contrato de locação de ' + contrato.Valor_Mensal_da_Proposta__c + ' para ' + cs.Valor_Total_Geral__c + ' a partir da data a partir da data de entrega para os casos de adição ou da data de retirada, para os casos de supressão.</p>';
            cs.Cl_usula_s_Alterada_s__c += '<br/>';
            cs.Cl_usula_s_Alterada_s__c += '<b>CLAUSULA SEGUNDA - DA RATIFICAÇÃO DAS CLÁUSULAS</b>';
            cs.Cl_usula_s_Alterada_s__c += '<p style="text-align:justify;"><b>2.1.</b> Ficam ratificadas todas as demais cláusulas e condições estabelecidas no Contrato n° ' + contrato.N_mero_da_Proposta_Contrato__c + ' que não colidirem com o presente termo aditivo.</p>';
        }
        if((cs.Quantidade_de_Ativos_no_Aditivo__c > 0 || cs.Quantidade_de_produtos_na_proposta__c > 0) && (cs.Dura_o_Adicional__c <= 0 || cs.Dura_o_Adicional__c == null) && cs.Editar_Clausulas__c == false && cs.Atualizacao_monetaria__c == true){ //Aditivo apenas de adição/supressão sem prazo adicional com atualização monetária
            cs.Cl_usula_s_Alterada_s__c = '<p style="text-align:justify;"><b>1.2.</b> Em razão da adição e/ou supressão dos equipamentos ora mencionados, fica alterado o valor do contrato de locação de ' + contrato.Valor_Mensal_da_Proposta__c + ' para ' + cs.Valor_atualizado__c + ' a partir da data a partir da data de entrega para os casos de adição ou da data de retirada, para os casos de supressão. </p>';
            cs.Cl_usula_s_Alterada_s__c += '<br/>';
            cs.Cl_usula_s_Alterada_s__c += '<b>CLAUSULA SEGUNDA - DA RATIFICAÇÃO DAS CLÁUSULAS</b>';
            cs.Cl_usula_s_Alterada_s__c += '<p style="text-align:justify;"><b>2.1.</b> Ficam ratificadas todas as demais cláusulas e condições estabelecidas no Contrato n° ' + contrato.N_mero_da_Proposta_Contrato__c + ' que não colidirem com o presente termo aditivo.</p>';
        }
    }
}