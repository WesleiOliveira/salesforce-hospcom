trigger ContratoLocacao on Contrato_de_Servi_o__c (before insert, before update) {
    public Account Cliente {get;set;}
    public Account Hospital {get;set;}
     
    
    for (Contrato_de_Servi_o__c cs:trigger.new) {
        if(cs.Editar_Timbre__c == false){
            if(cs.Locador_a__c == '0015A00001yGbVZQA0')
            {
                cs.Timbre__c = 'GDB';
            }
            if(cs.Locador_a__c == '001i00000085QYbAAM')
            {
                cs.Timbre__c = 'HOSPCOM';
            }
            if(cs.Locador_a__c == '0015A00001tSrPaQAK')
            {
                cs.Timbre__c = 'HEALTH SOLUTIONsss';
            } 
        }
        
                
        
        if(cs.RecordTypeId == '0125A000001Qydf' & cs.Cl_usula_Primeira_Editada__c == false){
             cs.Cl_usula_Primeira__c = '<p style="text-decoration: underline"><b>CLÁUSULA PRIMEIRA – DOS DOCUMENTOS INTEGRANTES E COMPLEMENTARES DESTE CONTRATO</b><p>';
             cs.Cl_usula_Primeira__c +='<p style="text-align: justify"> Integram o presente <b>CONTRATO</b>, como se nele estivessem transcritos em seu inteiro teor, para todos os efeitos de direito, os seguintes documentos:</p>';
             cs.Cl_usula_Primeira__c +='<p style="text-align: justify"><b>Anexo I</b> – RESUMO DE INFORMAÇÕES COMERCIAIS, a seguir designado simplesmente <b>RIC;</b></p>';
             cs.Cl_usula_Primeira__c +='<p style="text-align: justify"><b>Anexo II</b> – TERMO DE RECEBIMENTO E VISTORIA DO EQUIPAMENTO;</b></p>';            
             cs.Cl_usula_Primeira__c +='<p style="text-align: justify"><b>1.1.</b> Incluem-se também seus <b>ANEXOS</b>, sendo certo que o inadimplemento pelo(a/s) <b>LOCATÁRIO(A/S)</b> de qualquer dispositivo dos instrumentos mencionados acima possibilita à <b>LOCADORA</b> optar pela rescisão unilateral de todos os pactos firmados entre as partes contratantes.</p>';            
             cs.Cl_usula_Primeira__c +='<p style="text-align: justify"><b>1.2.</b> O(A/S) <b>LOCATÁRIO(A/S)</b>, confessa(m) conhecer os documentos acima, aos quais expressamente declara(m) aderir e, por isso, passam a ser parte integrante e indissociável deste <b>CONTRATO</b>. Neste ato, os documentos indicados nos Itens de I a II são entregues pela <b>LOCADORA</b> ao(à/s)<b> LOCATÁRIO(A/S)</b>.</p>';   
        }
        
        if(cs.RecordTypeId == '0125A000001Qydf' & cs.Cl_usula_Segunda_Editada__c == false) {
             cs.Cl_usula_Segunda__c ='<p style="text-decoration: underline"><b>CLÁUSULA SEGUNDA – DO OBJETO DA LOCAÇÃO</b></p>';
             cs.Cl_usula_Segunda__c += '<p style="text-align: justify"><b>2.1.</b> A <b>LOCADORA</b>, na qualidade de proprietária, cede em locação ao(à/s) LOCATÁRIO(A/S) os Equipamentos Hospitalares especificados no item 03 do RIC, pelo preço e prazo certos e ajustados, consignados nos Itens <b>04</b> e <b>05</b> do <b>RIC.</b></p>';             
         }
        
        if(cs.RecordTypeId == '0125A000001Qydf' & cs.Cl_usula_Terceira_Editada__c == false) {
             cs.Cl_usula_Terceira__c ='<p style="text-decoration: underline"><b>CLÁUSULA TERCEIRA – DO VALOR E VENCIMENTO DO ALUGUEL</b></p>';
             cs.Cl_usula_Terceira__c += '<p style="text-align: justify">O Aluguel será cobrado na modalidade <b>CTL – Custo Total de Locação.</b></p>';
             cs.Cl_usula_Terceira__c += '<p style="text-align: justify"><b>3.1.</b> O valor do <b>CTL – Custo Total de Locação</b> é a importância constante no <b>Item 05 do RIC</b> com vencimento em até 30 dias após a entrega do equipamento, conforme data constatada no Termo de Recebimento e Vistoria do Equipamento, sendo certo que seu reajuste se dará anualmente através da variação do índice INPC.</p>';
             cs.Cl_usula_Terceira__c += '<p style="text-align: justify"><b>3.2.</b> O(A/S) <b>LOCATÁRIO(A/S)</b> se obriga a pagar o valor do aluguel à <b>LOCADORA</b> através de transferência bancária, em conta bancária ou outro meio a ser indicado pela LOCADORA. </p>';
             cs.Cl_usula_Terceira__c += '<p style="text-align: justify"><b>3.3.</b> Caso o(a/s) <b>LOCATÁRIO(A/S)</b> não efetue(m) o pagamento do aluguel na data de vencimento, serão aplicadas as seguintes sanções, calculadas sempre sobre o valor total da obrigação e até o seu efetivo pagamento:</p>';            
             cs.Cl_usula_Terceira__c += '<p style="text-align: justify; margin-left:20px;"><b>a )</b> Juros de mora a razão de 1% (um por cento) ao mês;</b></p>';
             cs.Cl_usula_Terceira__c += '<p style="text-align: justify; margin-left:20px;"><b>b )</b> Multa moratória de 2% (dois por cento) ao mês sobre o valor total da obrigação em atraso;</p>';
             cs.Cl_usula_Terceira__c += '<p style="text-align: justify; margin-left:20px;"><b>c )</b> Correção monetária, “pró rata tempore”, com base na variação do índice do INPC;</p>';
             cs.Cl_usula_Terceira__c += '<p style="text-align: justify; margin-left:20px;"><b>d )</b> Todas as despesas de cobrança, custas judiciais, extrajudiciais e honorários advocatícios na monta de 10% sobre o valor total do débito;</p>';

             cs.Cl_usula_Terceira__c += '<p style="text-align: justify"><b>3.4.</b> Nos casos de pagamentos em cheques, a quitação dos aluguéis, encargos ou quaisquer outros débitos oriundos deste contrato só operar-se-á de pleno direito, após a sua compensação e o crédito respectivo ser efetivado na conta da <b> LOCADORA</p>';
        }
        if(cs.Contrato_de_AltoFluxo__c == 'NÃO'){
            if(cs.RecordTypeId == '0125A000001Qydf' & cs.Cl_usula_Quarta_Editada__c == false){
                 cs.Cl_usula_Quarta__c ='<p style="text-decoration: underline"><b>CLÁUSULA QUARTA – DO PRAZO DA LOCAÇÃO</b></p>';
                 cs.Cl_usula_Quarta__c += '<p style="text-align: justify"><b>4.1.</b> A locação vigorará pelo prazo estabelecido no <b>Item 04</b> do <b>RIC</b>, extinguindo-se ao seu termo, de pleno direito, independentemente de qualquer aviso, notificação judicial ou extrajudicial, sendo que sua eventual prorrogação, renovação ou recondução se regulará mediante formalização de TERMO ADITIVO, respeitadas, contudo, as condições estabelecidas e acordadas no presente instrumento e seus <b>ANEXOS.</b> Sendo que, em caso de ausência de devolução dos equipamentos no término do prazo contratual, a locação vigorará por prazo indeterminado.</p>';
                 cs.Cl_usula_Quarta__c += '<p style="text-align: justify"><b>4.2.</b> Em caso de eventual prorrogação da locação por prazo indeterminado poderá a <b>LOCADORA</b> denunciá-la, a qualquer tempo, mediante simples notificação por escrito.</p>';
                 cs.Cl_usula_Quarta__c += '<p style="text-align: justify"><b>4.3.</b> Independentemente do(a) <b>LOCATÁRIO(A)</b> iniciar ou não, o tratamento com os Equipamentos Objeto deste contrato e, ainda, sem prejuízos das penalidades por infração contratual, passará a ser devido, a partir da data prevista no <b> Item 04 do RIC</b>, o aluguel e demais encargos locatícios ora pactuados.</p>';
                 cs.Cl_usula_Quarta__c += '<p style="text-align: justify"><b>4.4.</b> Finda a locação, independentemente do motivo (rescisão, resilição ou resolução contratual), da forma e da época, deverá o(a) <b>LOCATÁRIO(A)</b> devolver os Equipamentos livres de objetos e coisas, em perfeito estado de conservação e limpeza, totalmente adequado ao uso a que se destinava de maneira imediata, não tendo direito à indenização ou retenção por quaisquer benfeitorias ou instalações realizadas, mesmo que necessárias, porquanto as mesmas aderirão e ficarão incorporadas ao referido Equipamento para todos os fins de direito, sendo tais obrigações assumidas pelo(a)<b> LOCATÁRIO(A)</b>, sob pena de serem adotadas as medidas judiciais cabíveis.</p>';
                 cs.Cl_usula_Quarta__c += '<p style="text-align: justify"><b>4.5.</b> Em caso de rescisão antecipada por parte do(a) <b>LOCATÁRIO(A)</b> fica estipulada a multa de 30% (trinta por cento) do valor residual do contrato. A multa será calculada sobre o valor proporcional de cada equipamento locado e devolvido antecipadamente ou total em caso de rescisão integral do contrato. A multa por rescisão antecipada não é tida como fidelidade e será aplicada durante todo o prazo contratual, independentemente do prazo de vigência prolongado após a assinatura do contrato originário.</p>';
                 cs.Cl_usula_Quarta__c += '<p style="text-align: justify"><b>4.6.</b> A rescisão antecipada por parte do <b>LOCATÁRIO</b> será realizada tão somente através de notificação extrajudicial através do envio de uma carta registrada a <b>LOCADORA</b>, com antecedência de 30 dias.</p>';               
                 cs.Cl_usula_Quarta__c += '<p style="text-align: justify"><b>4.7.</b> As Partes estabelecem desde já que não serão considerados caso fortuito ou força maior e, portanto, não haverá a exclusão de responsabilidade de qualquer das Partes, a ocorrência de qualquer dos seguintes eventos: (i) alterações no cenário econômico regional ou global; (ii) problemas ou dificuldades econômico-financeiras de qualquer das Partes; (iii) roubo, furto ou danificação do equipamento enquanto em posse do LOCATÁRIO (A); e (iv) degradação do equipamento em razão do uso, efeitos do tempo e da natureza, enquanto em posse do <b>LOCATÁRIO(A)</b>.</p>';
                
              }
        }
        if(cs.Contrato_de_AltoFluxo__c == 'SIM'){
            if(cs.RecordTypeId == '0125A000001Qydf' & cs.Cl_usula_Quarta_Editada__c == false){
                 cs.Cl_usula_Quarta__c ='<p style="text-decoration: underline"><b>CLÁUSULA QUARTA – DO PRAZO DA LOCAÇÃO</b></p>';
                 cs.Cl_usula_Quarta__c += '<p style="text-align: justify"><b>4.1.</b> A locação vigorará pelo prazo determinado conforme estabelecido no <b>Item 04</b> do <b>RIC</b>, extinguindo-se ao seu termo, de pleno direito, independentemente de qualquer aviso, notificação judicial ou extrajudicial, sendo que sua eventual prorrogação, renovação ou recondução se regulará mediante formalização de TERMO ADITIVO, respeitadas, contudo, as condições estabelecidas e acordadas no presente instrumento e seus <b>ANEXOS.</b></p>';
                 cs.Cl_usula_Quarta__c += '<p style="text-align: justify"><b>4.2.</b> Em caso de eventual prorrogação da locação por prazo indeterminado poderá a LOCADORA denunciá-la, a qualquer tempo, mediante simples notificação por escrito.</p>';
                 cs.Cl_usula_Quarta__c += '<p style="text-align: justify"><b>4.3.</b> Finda a locação, independentemente do motivo (rescisão, resilição ou resolução contratual), da forma e da época, deverá o(a) <b>LOCATÁRIO(A)</b> devolver os Equipamentos livres de objetos e coisas, em perfeito estado de conservação e limpeza, totalmente adequado ao uso a que se destinava, não tendo direito à indenização ou retenção por quaisquer benfeitorias ou instalações realizadas, mesmo que necessárias, porquanto as mesmas aderirão e ficarão incorporadas ao referido Equipamento para todos os fins de direito, sendo tais obrigações assumidas pelo(a)<b> LOCATÁRIO(A)</b>, sob pena de serem adotadas as medidas judiciais cabíveis.</p>';
                 cs.Cl_usula_Quarta__c += '<p style="text-align: justify"><b>4.4.</b> As Partes estabelecem desde já que não serão considerados caso fortuito ou força maior e, portanto, não haverá a exclusão de responsabilidade de qualquer das Partes, a ocorrência de qualquer dos seguintes eventos: (i) alterações no cenário econômico regional ou global; (ii) problemas ou dificuldades econômico-financeiras de qualquer das Partes; (iii) roubo, furto ou danificação do equipamento enquanto em posse do LOCATÁRIO (A); e (iv) degradação do equipamento em razão do uso, efeitos do tempo e da natureza, enquanto em posse do LOCATÁRIO (A).</p>';
                
    
              }
        }
        if(cs.Contrato_de_AltoFluxo__c == 'SIM'){
            if(cs.RecordTypeId == '0125A000001Qydf' & cs.Cl_usula_Quinta_Editada__c == false){
                 cs.Cl_usula_Quinta__c ='<p style="text-decoration: underline"><b>CLÁUSULA QUINTA – DA IMPOSSIBILIDADE DE DEVOLUÇÃO DE VALORES</b></p>';
                 cs.Cl_usula_Quinta__c += '<p style="text-align: justify"><b>5.1.</b>Independentemente do(a) <b>LOCATÁRIO(A)</b> iniciar ou não, o tratamento com os Equipamentos Objeto deste contrato e, ainda, sem prejuízos das penalidades por infração contratual, passará a ser devido, a partir da data prevista no <b> Item 04 do RIC</b>, o aluguel e demais encargos locatícios ora pactuados sendo certa a impossibilidade de restituição de quaisquer valores referentes à locação.</p>';
            }
        }
        if(cs.Contrato_de_AltoFluxo__c == 'NÃO'){
            if(cs.RecordTypeId == '0125A000001Qydf' & cs.Cl_usula_Quinta_Editada__c == false){
                 cs.Cl_usula_Quinta__c ='<p style="text-decoration: underline"><b>CLÁUSULA QUINTA – DA DESTINAÇÃO DOS EQUIPAMENTOS</b></p>';
                 cs.Cl_usula_Quinta__c += '<p style="text-align: justify"><b>5.1.</b> O Equipamento ora locado destina-se exclusivamente para o tratamento hospitalar, não podendo o(a/s) <b>LOCATÁRIO(A/S) </b>alterar sua destinação, ceder ou transferir para outrem, bem como alterar os itens por si comercializados e previamente acertados entre as partes, sob pena de serem aplicadas as penalidades previstas e considerado rescindido o presente instrumento.</p>';
                 cs.Cl_usula_Quinta__c += '<p style="text-align: justify"><b>5.2.</b> O presente instrumento poderá ser imediatamente rescindido, sem que caiba direito a indenização ou qualquer outra forma de ressarcimento, no caso de reclamação contumaz contra o(a/s)<b> LOCATÁRIO(A/S) </b>vindo de terceiros, referente ao mau uso do Equipamento Locado.</p>';
             }
        }
        if(cs.Contrato_de_AltoFluxo__c == 'NÃO'){
        if(cs.RecordTypeId == '0125A000001Qydf' & cs.Cl_usula_Sexta_Editada__c == false){
             cs.Cl_usula_Sexta__c ='<p style="text-decoration: underline"><b>CLÁUSULA SEXTA – DA CESSÃO, SUBLOCAÇÃO OU TRANSFERÊNCIA</b></p>';
             cs.Cl_usula_Sexta__c += '<p style="text-align: justify"><b>6.1.</b> O(A) <b>LOCATÁRIO(A) </b>não poderá ceder, sublocar ou transferir, no todo ou em parte, ainda que por empréstimo, o objeto deste<b> CONTRATO</b>, sem prévio e expresso consentimento, por escrito, da<b> LOCADORA.</b></p>';
             cs.Cl_usula_Sexta__c += '<p style="text-align: justify"><b>6.2.</b> A <b>LOCADORA</b> poderá ceder ou utilizar, total ou parcialmente, os créditos decorrentes do presente contrato de locação, oriundos de pagamentos já realizados ou a realizar, como garantia de obrigações próprias ou de terceiros, perante instituições financeiras, fornecedores ou quaisquer outros credores.';
         }
        }
        
        if(cs.Contrato_de_AltoFluxo__c == 'SIM'){
            
            cs.Cl_usula_Sexta__c ='<p style="text-decoration: underline"><b>CLÁUSULA SEXTA – DA DESTINAÇÃO DOS EQUIPAMENTOS</b></p>';
            cs.Cl_usula_Sexta__c += '<p style="text-align: justify"><b>6.1.</b> O Equipamento ora locado destina-se exclusivamente para o tratamento hospitalar, não podendo o(a/s) <b>LOCATÁRIO(A/S) </b>alterar sua destinação, ceder ou transferir para outrem, bem como alterar os itens por si comercializados e previamente acertados entre as partes, sob pena de serem aplicadas as penalidades previstas e considerado rescindido o presente instrumento.</p>';
            cs.Cl_usula_Sexta__c += '<p style="text-align: justify"><b>6.2.</b> O presente instrumento poderá ser imediatamente rescindido, sem que caiba direito a indenização ou qualquer outra forma de ressarcimento, no caso de reclamação contumaz contra o(a/s)<b> LOCATÁRIO(A/S) </b>vindo de terceiros, referente ao mau uso do Equipamento Locado.</p>';                    
        }
        
        if(cs.Contrato_de_AltoFluxo__c == 'SIM'){
            if(cs.RecordTypeId == '0125A000001Qydf' & cs.Cl_usula_S_tima_Editada__c == false){
                
                Cliente = [
            SELECT  Name, CPF__pc
            FROM    Account
            WHERE   Id = :cs.Cliente__c
        	];
        Hospital = [
            SELECT  Name, CNPJ__c
            FROM    Account
            WHERE   Id = :cs.Internado_no_Hospital__c
        	];
             cs.Cl_usula_S_tima__c ='<p style="text-decoration: underline"><b>CLÁUSULA SÉTIMA – DA DESTINAÇÃO DA LOCAÇÃO</b></p>';
             cs.Cl_usula_S_tima__c += '<p style="text-align: justify"><b>7.1.</b> O(A) <b>LOCATÁRIO(A) </b> declara que o(s) equipamento(s) objeto(s) da presente locação será utilização pelo cliente '+ cs.Nome_do_Paciente__c +' inscrito(a) no CPF sob o n° '+cs.CPF__c+', em tratamento junto ao ' +Hospital.Name+ ',&nbsp;' +cs.Endere_o_Hospital__c+ ', sendo resguardado o direito da LOCADORA quanto a informação da localização de seu(s) equipamento(s).</p>';
         }

        }
                
        if(cs.RecordTypeId == '0125A000001Qydf' & cs.Clausulas_Especiais_Editadas__c == false){
            string numero;
            if(cs.Fiador__c == null && cs.Conjuge_do_fiador__c == null)
                numero = '6';
            else if(cs.Fiador__c != null && cs.Conjuge_do_fiador__c == null)
                numero = '7';
            else if(cs.Fiador__c != null && cs.Conjuge_do_fiador__c != null)
                numero = '8';
            
             cs.Clausulas_Especiais__c = '<p><b>' + numero + '. CLÁUSULAS ESPECIAIS </b><p>';
             cs.Clausulas_Especiais__c +='<p style="text-align: justify"><b>' + numero + '.1. </b>As partes ajustam que as condições abaixo estabelecidas serão válidas durante o período que vigorar a presente Locação e prevalecerão sobre as condições estipuladas no <b>CONTRATO DE LOCAÇÃO</b> e nos seus anexos.</p>';
        }
        
        if(cs.Contrato_de_AltoFluxo__c == 'NÃO'){
            if(cs.RecordTypeId == '0125A000001Qydf' & cs.Cl_usula_S_tima_Editada__c == false){
                 cs.Cl_usula_S_tima__c ='<p style="text-decoration: underline"><b>CLÁUSULA SÉTIMA – DA ENTREGA DOS EQUIPAMENTOS, GARANTIA E DEVOLUÇÃO</b></p>';
                 cs.Cl_usula_S_tima__c += '<p style="text-align: justify">A <b>LOCADORA</b> em conjunto com o <b>LOCATÁRIO(A)</b> definem que a entrega e a devolução dos equipamentos nas perfeitas condições do uso a que se destina, deverão seguir da seguinte forma:</p>';
                 cs.Cl_usula_S_tima__c += '<p style="text-align: justify"><b>1. Entrega do(s) Equipamentos: </b>' +cs.Tipo_de_Entrega__c+ ';</p>';
                 cs.Cl_usula_S_tima__c += '<p style="text-align: justify"><b>2. Devolução do(s) Equipamentos: </b>' +cs.Tipo_de_Devolu_o__c+ '.</p>';
                 cs.Cl_usula_S_tima__c += '<p style="text-align: justify"><b>7.1.</b> As instalações dos equipamentos locados serão realizadas de segunda à sexta-feira, das 08h às 18h, salvo feriados. Em caso de necessidade manifestada pelo <b>LOCATÁRIO(A/S)</b> de que sejam prestados os serviços em referência fora do horário comercial ora estipulado, as despesas de atendimento extraordinário serão cobradas pela <b>LOCADORA</b>, em valores previamente estipulados entre <b>LOCADORA</b> e <b>LOCATÁRIO(A/S)</b>. Nas localidades de difícil acesso ou por necessidades técnicas, onde não haja condições de atendimento in loco pela <b>LOCADORA</b>, ou por terceiros credenciados, a assistência será prestada em local previamente acordado entre as partes.</p>';
                 cs.Cl_usula_S_tima__c += '<p style="text-align: justify"><b>7.2.</b> Para o cenário de garantia, não caracterizado o mau uso e quando se fizer necessário a substituição de partes e peças originais e estas não estiverem disponíveis no mercado, a <b>LOCADORA</b> utilizará partes e peças, novas ou não, desde que sejam mantidas as especificações técnicas do fabricante.</p>';
                 cs.Cl_usula_S_tima__c += '<p style="text-align: justify"><b>7.3.</b> A <b>LOCADORA</b> oferece garantia do perfeito funcionamento dos equipamentos, quando da respectiva instalação, obedecidas as especificações técnicas, podendo os equipamentos objeto do presente contrato, serem previamente revisados, dentro dos mais rigorosos padrões técnicos e de controle de qualidade.</p>';
                 cs.Cl_usula_S_tima__c += '<p style="text-align: justify"><b>7.4.</b> A <b>LOCADORA</b>, ou terceiros por ela credenciados, sem qualquer ônus para o <b>LOCATÁRIO(A/S)</b>, fornecerá os serviços técnicos, manutenção e reparo dos equipamentos, incluindo todas as peças, caso a manutenção se faça necessária, salvo em caso de mau uso e dano caracterizado por culpa exclusiva do <b>LOCATÁRIO(A/AS)</b>, ocasião em que os custos decorrentes do serviço prestado e das peças substituídas para o conserto serão incluídos na fatura de locação do mês subsequente, ficando o <b>LOCATÁRIO(A/AS)</b> obrigado em todos encargos previstos no item 3.3 em caso de inadimplemento verificado.</p>';
                 cs.Cl_usula_S_tima__c += '<p style="text-align: justify"><b>7.5.</b> Obriga-se o(a/s) <b>LOCATÁRIO(A/S)</b> a conservar o Equipamento locado, caso em que, ocorrendo qualquer dano à sua exclusiva culpa, efetuará o pagamento de todos os danos causados, ressarcindo a <b>LOCADORA</b> de todos os gastos e despesas necessárias à reparação do Equipamento danificado.</p>';
                 cs.Cl_usula_S_tima__c += '<p style="text-align: justify"><b>7.6.</b> O(A/S) <b>LOCATÁRIO(A/S)</b> fica(m) obrigado(a/s), no curso da locação, satisfazer às suas próprias custas, a todas e quaisquer intimações dos poderes competentes a que der causa, mesmo que expedidas em nome da <b>LOCADORA.</b></p>';
                 cs.Cl_usula_S_tima__c += '<p style="text-align: justify"><b>7.7.</b> Caso haja atraso no pagamento do aluguel por um período superior a 15 (quinze) dias, ficam automaticamente suspensos os atendimentos técnicos corretivos até que a <b>LOCATÁRIA</b> promova a regularização dos débitos. O atraso no pagamento de locação por período superior a 30 (trinta) dias implicará na resolução de pleno direito do contrato, com a retirada imediata dos aparelhos sem qualquer pré-aviso ou comunicado, aplicando-se também a multa do item 10.2.</p>';
                
            }
          }
        if(cs.Contrato_de_AltoFluxo__c == 'SIM'){
            if(cs.RecordTypeId == '0125A000001Qydf' & cs.Cl_usula_Oitava_Editada__c == false){
                
                cs.Cl_usula_Oitava__c ='<p style="text-decoration: underline"><b>CLÁUSULA OITAVA – DA ENTREGA DOS EQUIPAMENTOS, GARANTIA E DEVOLUÇÃO</b></p>';
                 cs.Cl_usula_Oitava__c += '<p style="text-align: justify">A <b>LOCADORA</b> em conjunto com o LOCATÁRIO(A) definem que a entrega e a devolução dos equipamentos nas perfeitas condições do uso a que se destina, deverão seguir da seguinte forma:</p>';
                 cs.Cl_usula_Oitava__c += '<p style="text-align: justify"><b>1. Entrega do(s) Equipamentos: </b>' +cs.Tipo_de_Entrega__c+ ';</p>';
                 cs.Cl_usula_Oitava__c += '<p style="text-align: justify"><b>2. Devolução do(s) Equipamentos: </b>' +cs.Tipo_de_Devolu_o__c+ '.</p>';
                 cs.Cl_usula_Oitava__c += '<p style="text-align: justify"><b>8.1.</b> As instalações dos equipamentos locados serão realizadas de segunda à sexta-feira, das 08h às 18h, salvo feriados. Em caso de necessidade manifestada pelo <b>LOCATÁRIO(A/S)</b> de que sejam prestados os serviços em referência fora do horário comercial ora estipulado, as despesas de atendimento extraordinário serão cobradas pela <b>LOCADORA</b>, em valores previamente estipulados entre <b>LOCADORA</b> e <b>LOCATÁRIO(A/S)</b>. Nas localidades de difícil acesso ou por necessidades técnicas, onde não haja condições de atendimento in loco pela <b>LOCADORA</b>, ou por terceiros credenciados, a assistência será prestada em local previamente acordado entre as partes.</p>';
                 cs.Cl_usula_Oitava__c += '<p style="text-align: justify"><b>8.2.</b> Quando se fizer necessário a substituição de partes e peças originais e estas não estiverem disponíveis no mercado, a <b>LOCADORA</b> utilizará partes e peças, novas ou não, desde que sejam mantidas as especificações técnicas do fabricante.</p>';
                 cs.Cl_usula_Oitava__c += '<p style="text-align: justify"><b>8.3.</b> A <b>LOCADORA</b> oferece garantia do perfeito funcionamento dos equipamentos, quando da respectiva instalação, obedecidas as especificações técnicas, podendo os equipamentos objeto do presente contrato, serem previamente revisados, dentro dos mais rigorosos padrões técnicos e de controle de qualidade.</p>';
                 cs.Cl_usula_Oitava__c += '<p style="text-align: justify"><b>8.4.</b> A <b>LOCADORA</b>, ou terceiros por ela credenciados, sem qualquer ônus para o <b>LOCATÁRIO(A/S)</b>, fornecerá os serviços técnicos, manutenção e reparo dos equipamentos, incluindo todas as peças, caso a manutenção se faça necessária, salvo em caso de dano por culpa exclusiva do <b>LOCATÁRIO(A/AS)</b>, caso em que será realizado novo orçamento a parte.</p>';
                 cs.Cl_usula_Oitava__c += '<p style="text-align: justify"><b>8.5.</b> Obriga-se o(a/s) <b>LOCATÁRIO(A/S)</b> a conservar o Equipamento locado, caso em que, ocorrendo qualquer dano à sua exclusiva culpa, efetuará o pagamento de todos os danos causados, ressarcindo a <b>LOCADORA</b> de todos os gastos e despesas necessárias à reparação do Equipamento danificado.</p>';
                 cs.Cl_usula_Oitava__c += '<p style="text-align: justify"><b>8.6.</b> O(A/S) <b>LOCATÁRIO(A/S)</b> fica(m) obrigado(a/s), no curso da locação, satisfazer às suas próprias custas, a todas e quaisquer intimações dos poderes competentes a que der causa, mesmo que expedidas em nome da <b>LOCADORA.</b></p>';  
            }
        }
        if(cs.Contrato_de_AltoFluxo__c == 'NÃO'){
            if(cs.RecordTypeId == '0125A000001Qydf' & cs.Cl_usula_Oitava_Editada__c == false){
                 cs.Cl_usula_Oitava__c ='<p style="text-decoration: underline"><b>CLÁUSULA OITAVA – DOS MATERIAIS DE CONSUMO</b></p>';
                 cs.Cl_usula_Oitava__c += '<p style="text-align: justify"><b> 8.1.</b> No valor do aluguel dos equipamentos aqui descritos, não estão inclusos os consumíveis necessários ao seu funcionamento, sendo certo que a aquisição dos consumíveis necessários, deverá ser realizada através de um pedido de venda próprio, de acordo com a demanda da <b>LOCATÁRIA</b>.</p>';
                 cs.Cl_usula_Oitava__c += '<p style="text-align: justify"><b> 8.2.</b> Caso a <b>LOCATÁRIA</b> manifeste a intenção de adquirir os componentes, consumíveis e os serviços de manutenção do equipamento de outras fontes, desde já declara a ciência de que eventual aquisição correrá por sua estrita e exclusiva responsabilidade, sendo certo que em caso de eventuais danos causados ao equipamento, os valores referentes aos custos para o reparo, serão de sua responsabilidade. </p>';
                 cs.Cl_usula_Oitava__c += '<p style="text-align: justify"><b> 8.3.</b> Toda e qualquer aquisição de componentes, consumíveis e, ainda, serviços de manutenção do equipamento que sejam realizadas pela <b>LOCATÁRIA</b> e adquiridos através de outras fontes, não serão reembolsadas pela <b>LOCADORA</b>, bem como, não haverá qualquer abatimento no valor da locação. </p>';
                    
            }
        }
        if(cs.Contrato_de_AltoFluxo__c == 'SIM'){
            if(cs.RecordTypeId == '0125A000001Qydf' & cs.Cl_usula_Nona_Editada__c == false){
                 cs.Cl_usula_Nona__c ='<p style="text-decoration: underline"><b>CLÁUSULA NONA – DOS MATERIAIS DE CONSUMO</b></p>';
                 cs.Cl_usula_Nona__c += '<p style="text-align: justify"><b> 9.1.</b>No valor do aluguel dos equipamentos aqui descritos, não estão inclusos os consumíveis necessários ao seu funcionamento, sendo certo que eventuais consumíveis necessários, deverão ser adquiridos em um pedido de venda próprio, de acordo com a demanda da LOCATÁRIA; </p>';
                 cs.Cl_usula_Nona__c += '<p style="text-align: justify"><b> 9.2. </b> Caso a LOCATÁRIA manifeste a intenção de adquirir os componentes, consumíveis e os serviços de manutenção do equipamento de outras fontes, desde já declara a ciência de que eventual aquisição correrá por sua estrita e exclusiva responsabilidade, sendo certo que em caso de eventuais danos causados ao equipamento, os valores referentes aos custos para o reparo, serão de sua responsabilidade. </p>';
                 cs.Cl_usula_Nona__c += '<p style="text-align: justify"><b> 9.3. </b> Toda e qualquer aquisição de componentes, consumíveis e, ainda, serviços de manutenção do equipamento que sejam realizadas pela LOCATÁRIA e adquiridos através de outras fontes, não serão reembolsadas pela LOCADORA, bem como, não haverá qualquer abatimento no valor da locação. </p>';
            }
        }
        if(cs.Contrato_de_AltoFluxo__c == 'NÃO'){
            if(cs.RecordTypeId == '0125A000001Qydf' & cs.Cl_usula_Nona_Editada__c == false){
                 cs.Cl_usula_Nona__c ='<p style="text-decoration: underline"><b>CLÁUSULA NONA – DA CIÊNCIA QUANTO AO USO ADEQUADO DOS EQUIPAMENTOS</b></p>';
                 cs.Cl_usula_Nona__c += '<p style="text-align: justify"><b>9.1.</b> Declara a <b>LOCATÁRIA</b> ciência quanto ao dever de adequado uso dos equipamentos e acessórios objeto do contrato de locação, bem como quanto ao dever de observância ao treinamento dado pela <b>LOCADORA</b> quanto a não reutilização de acessórios considerados descartáveis, devendo zelar sempre pela boa higiene e segurança do paciente tratado.</p>';
                 cs.Cl_usula_Nona__c += '<p style="text-align: justify"><b>9.2.</b> Diante dos treinamentos e orientações repassadas à <b>LOCATÁRIA</b>, declara esta ciência quanto a ausência de responsabilidade da <b>LOCADORA</b> quanto ao uso inadequado dos equipamentos e acessórios, dando ainda seu aceite quanto a sua exclusiva responsabilidade por eventuais riscos, perdas e danos ou quaisquer questionamentos ou responsabilidades administrativas ou judiciais advindas de atos decorrentes de imprudência, imperícia ou negligência da <b>LOCATÁRIA</b>.</p>';             
             }
        }        
        if(cs.Contrato_de_AltoFluxo__c == 'SIM'){
            if(cs.RecordTypeId == '0125A000001Qydf' & cs.Cl_usula_D_cima_Editada__c == false){
                 cs.Cl_usula_D_cima__c ='<p style="text-decoration: underline"><b>CLÁUSULA DÉCIMA – DA CIÊNCIA QUANTO AO USO ADEQUADO DOS EQUIPAMENTOS</b></p>';
                 cs.Cl_usula_D_cima__c += '<p style="text-align: justify"><b>10.1.</b> Declara a <b>LOCATÁRIA</b> ciência quanto ao dever de adequado uso dos equipamentos e acessórios objeto do contrato de locação, bem como quanto ao dever de observância ao treinamento dado pela <b>LOCADORA</b> quanto a não reutilização de acessórios considerados descartáveis, devendo zelar sempre pela boa higiene e segurança do paciente tratado.</p>';
                 cs.Cl_usula_D_cima__c += '<p style="text-align: justify"><b>10.2.</b> Diante dos treinamentos e orientações repassadas à <b>LOCATÁRIA</b>, declara esta ciência quanto a ausência de responsabilidade da <b>LOCADORA</b> quanto ao uso inadequado dos equipamentos e acessórios, dando ainda seu aceite quanto a sua exclusiva responsabilidade por eventuais riscos, perdas e danos ou quaisquer questionamentos ou responsabilidades administrativas ou judiciais advindas de atos decorrentes de imprudência, imperícia ou negligência da <b>LOCATÁRIA</b>.</p>';             
             }
        }
        if(cs.Contrato_de_AltoFluxo__c == 'NÃO'){
            if(cs.RecordTypeId == '0125A000001Qydf' & cs.Cl_usula_D_cima_Editada__c == false){
                 cs.Cl_usula_D_cima__c ='<p style="text-decoration: underline"><b>CLÁUSULA DÉCIMA – DA RESCISÃO E PENALIDADE</b></p>';
                 cs.Cl_usula_D_cima__c += '<p style="text-align: justify"><b>10.1.</b> Considerar-se-á rescindido de pleno direito o presente Contrato de Locação independentemente de qualquer aviso, notificação ou interpelação judicial ou extrajudicial e sem obrigação da <b>LOCADORA</b>, de indenizar o(a/s) <b>LOCATÁRIO(A/S)</b> a qualquer título: </p>';
                 cs.Cl_usula_D_cima__c += '<p style="text-align: justify; margin-left:20px;"><b>a )</b> No término do respectivo prazo de locação; </p>';
                 cs.Cl_usula_D_cima__c += '<p style="text-align: justify; margin-left:20px;"><b>b )</b>No caso de infração por parte do(a/s) <b>LOCATÁRIO(A/S)</b> de qualquer das obrigações aqui estipuladas; </p>';
             }
        }
        if(cs.Contrato_de_AltoFluxo__c == 'NÃO'){
            if(cs.RecordTypeId == '0125A000001Qydf' & cs.Cl_usula_D_cima_Primeira_Editada__c == false){
                 cs.Cl_usula_D_cima_Primeira__c ='<p style="text-decoration: underline"><b>CLÁUSULA DÉCIMA PRIMEIRA – DA NECESSIDADE DE APROVAÇÃO EM ANÁLISE DE CRÉDITO</b></p>';
                 cs.Cl_usula_D_cima_Primeira__c += '<p style="text-align: justify"><b>11.1.</b> Declara a LOCATÁRIA a ciência de que a presente tratativa comercial somente perdurará mediante aprovação da LOCATÁRIA em análise de crédito a ser realizada pela CONTRATADA e, ainda, tão somente mediante assinatura do presente instrumento por parte de pessoa com poderes para assinar pela LOCADORA.</p>';
             }
        }
        if(cs.Contrato_de_AltoFluxo__c == 'SIM'){
            if(cs.RecordTypeId == '0125A000001Qydf' & cs.Cl_usula_D_cima_Primeira_Editada__c == false){
                 cs.Cl_usula_D_cima_Primeira__c ='<p style="text-decoration: underline"><b>CLÁUSULA DÉCIMA PRIMEIRA – DA RESCISÃO E PENALIDADE</b></p>';
                 cs.Cl_usula_D_cima_Primeira__c += '<p style="text-align: justify"><b>11.1.</b>Considerar-se-á rescindido de pleno direito o presente Contrato de Locação independentemente de qualquer aviso, notificação ou interpelação judicial ou extrajudicial e sem obrigação da <b>LOCADORA</b>, de indenizar o(a/s) <b>LOCATÁRIO(A/S)</b> a qualquer título: </p>';
                 cs.Cl_usula_D_cima_Primeira__c += '<p style="text-align: justify; margin-left:20px;"><b> a )</b> No término do respectivo prazo de locação; </p>';
                 cs.Cl_usula_D_cima_Primeira__c += '<p style="text-align: justify; margin-left:20px;"><b> b )</b> No caso de infração por parte do(a/s) <b>LOCATÁRIO(A/S)</b> de qualquer das obrigações aqui estipuladas; </p>';
                 cs.Cl_usula_D_cima_Primeira__c += '<p style="text-align: justify"><b>11.2.</b> Na hipótese de descumprimento ou infração de suas cláusulas o contrato será rescindido, sendo devido o aluguel em sua totalidade, com aplicação de multa de 20% (vinte por cento) do valor do aluguel, podendo ser cobrado judicialmente pela<b> LOCADORA</b>, com todos os encargos previstos e pactuados entre as partes.</p>';
              
             }
        }
        if(cs.Contrato_de_AltoFluxo__c == 'SIM'){
            if(cs.RecordTypeId == '0125A000001Qydf' & cs.Cl_usula_D_cima_Segunda_Editada__c == false){
                cs.Cl_usula_D_cima_Segunda__c ='<p style="text-decoration: underline"><b>CLÁUSULA DÉCIMA SEGUNDA – DA NECESSIDADE DE APROVAÇÃO EM ANÁLISE DE CRÉDITO</b></p>';
                cs.Cl_usula_D_cima_Segunda__c += '<p style="text-align: justify"><b>12.1.</b>Declara a LOCATÁRIA a ciência de que a presente tratativa comercial somente perdurará mediante aprovação da LOCATÁRIA em análise de crédito a ser realizada pela CONTRATADA e, ainda, tão somente mediante assinatura do presente instrumento por parte de pessoa com poderes para assinar pela CONTRATADA.</p>'; 
                             
             }
        }
        if(cs.Contrato_de_AltoFluxo__c == 'NÃO'){
            if(cs.RecordTypeId == '0125A000001Qydf' & cs.Cl_usula_D_cima_Segunda_Editada__c == false){
                 cs.Cl_usula_D_cima_Segunda__c	 ='<p style="text-decoration: underline"><b>CLÁUSULA DÉCIMA SEGUNDA – DAS DISPOSIÇÕES GERAIS</b></p>';
                 cs.Cl_usula_D_cima_Segunda__c	 += '<p style="text-align: justify"><b>12.1.</b> Sendo os equipamentos locados destinados ao uso de tratamento hospitalar, o <b>LOCATÁRIO(A/AS)</b> declara estar ciente de todos os riscos inerentes ao seu uso, expressando ciência acerca da impossibilidade da <b>LOCADORA</b> assumir qualquer certeza de resultado que seja de expectativa do <b>LOCATÁRIO(A/AS)</b>, ressalvado o necessário cumprimento integral das funcionalidades do equipamento, haja vista se tratarem de atividades de meio e não de fim, o que resulta na impossibilidade de devolução de valores em caso de ausência do resultado final esperado. Para os casos em que fiquem caracterizadas perdas e danos por mau funcionamento decorrente de defeito de fábrica do equipamento, a <b>LOCADORA</b> será responsabilizada e custeará as perdas e danos decorrentes do mau funcionamento apontado.</p>';
                 cs.Cl_usula_D_cima_Segunda__c	 += '<p style="text-align: justify"><b>12.2.</b> Poderá a <b>LOCADORA</b>, a qualquer tempo, vistoriar o Equipamento locado, mediante combinação prévia de dia e hora.</p>';
                 cs.Cl_usula_D_cima_Segunda__c	 += '<p style="text-align: justify"><b>12.3.</b> O presente <b>CONTRATO</b> vincula as Partes ao seu fiel cumprimento, por si, seus herdeiros e sucessores a qualquer título. </p>';
                // cs.Cl_usula_D_cima_Primeira__c += '<p style="text-align: justify"><b>Parágrafo Terceiro: Das Práticas Anticorrupção</b> – As Partes obrigam-se a observar, cumprir e/ ou fazer cumprir, por si, suas afiliadas (entidades controladoras, controladas, coligadas ou sob controle comum) e representantes (diretores, membros do conselho de administração, quaisquer terceiros, incluindo assessores ou prestadores de serviços) toda e qualquer lei anticorrupção, em especial a Lei Federal nº 12.846/13, conforme aplicável.</p>';             
             }
        }
        if(cs.Contrato_de_AltoFluxo__c == 'SIM'){
            if(cs.RecordTypeId == '0125A000001Qydf' & cs.Cl_usula_D_cima_Terceira_Editada__c == false){
                
                cs.Cl_usula_D_cima_Terceira__c ='<p style="text-decoration: underline"><b>CLÁUSULA DÉCIMA TERCEIRA – DAS DISPOSIÇÕES GERAIS</b></p>';
                 cs.Cl_usula_D_cima_Terceira__c += '<p style="text-align: justify"><b>13.1.</b> Sendo os Equipamentos locados, destinados ao uso de tratamento hospitalar, o <b>LOCATÁRIO(A/AS)</b>, declara desde já, estar ciente de todos os riscos, isentando a <b>LOCADORA</b> de toda e qualquer responsabilidade decorrente do tratamento, não se responsabilizando a <b>LOCADORA</b> acerca de qualquer certeza de resultado ou benefício que seja de expectativa do <b>LOCATÁRIO(A/AS)</b>, ficando desde já, ciente, da impossibilidade de devolução de valores em caso de ausência do resultado esperado.</p>';
                 cs.Cl_usula_D_cima_Terceira__c += '<p style="text-align: justify"><b>13.2.</b> Poderá a <b>LOCADORA</b>, a qualquer tempo, vistoriar o Equipamento locado, mediante combinação prévia de dia e hora.</p>';
                 cs.Cl_usula_D_cima_Terceira__c += '<p style="text-align: justify"><b>13.3.</b> O presente <b>CONTRATO</b> vincula as Partes ao seu fiel cumprimento, por si, seus herdeiros e sucessores a qualquer título. </p>';
                // cs.Cl_usula_D_cima_Primeira__c += '<p style="text-align: justify"><b>Parágrafo Terceiro: Das Práticas Anticorrupção</b> – As Partes obrigam-se a observar, cumprir e/ ou fazer cumprir, por si, suas afiliadas (entidades controladoras, controladas, coligadas ou sob controle comum) e representantes (diretores, membros do conselho de administração, quaisquer terceiros, incluindo assessores ou prestadores de serviços) toda e qualquer lei anticorrupção, em especial a Lei Federal nº 12.846/13, conforme aplicável.</p>';
             }
        }
        if(cs.Contrato_de_AltoFluxo__c == 'NÃO'){
            if(cs.RecordTypeId == '0125A000001Qydf' & cs.Cl_usula_D_cima_Terceira_Editada__c == false){
                cs.Cl_usula_D_cima_Terceira__c = '<p style="text-decoration: underline"><b>CLÁUSULA DÉCIMA TERCEIRA – DAS PRÁTICAS ANTICORRUPÇÃO</b></p>';
                cs.Cl_usula_D_cima_Terceira__c += '<p style="text-align: justify"><b>13.1.</b> As Partes obrigam-se a observar, cumprir e/ou fazer cumprir, por si, suas afiliadas (entidades controladoras, controladas, coligadas ou sob controle comum) e representantes (diretores, membros do conselho de administração, quaisquer terceiros, incluindo assessores ou prestadores de serviços) toda e qualquer lei anticorrupção, em especial a Lei Federal nº 12.846/13, conforme aplicável.</p>';              
             }
        }
        if(cs.Contrato_de_AltoFluxo__c == 'SIM'){
            if(cs.RecordTypeId == '0125A000001Qydf' & cs.Cl_usula_D_cima_Quarta_Editada__c == false){
                cs.Cl_usula_D_cima_Quarta__c = '<p style="text-decoration: underline"><b>CLÁUSULA DÉCIMA QUARTA – DAS PRÁTICAS ANTICORRUPÇÃO</b></p>';
                cs.Cl_usula_D_cima_Quarta__c += '<p style="text-align: justify"><b>14.1.</b> As Partes obrigam-se a observar, cumprir e/ou fazer cumprir, por si, suas afiliadas (entidades controladoras, controladas, coligadas ou sob controle comum) e representantes (diretores, membros do conselho de administração, quaisquer terceiros, incluindo assessores ou prestadores de serviços) toda e qualquer lei anticorrupção, em especial a Lei Federal nº 12.846/13, conforme aplicável.</p>';              
                
             }
        }
        if(cs.Contrato_de_AltoFluxo__c == 'NÃO'){
            if(cs.RecordTypeId == '0125A000001Qydf' & cs.Cl_usula_D_cima_Quarta_Editada__c == false){
                cs.Cl_usula_D_cima_Quarta__c = '<p style="text-decoration: underline"><b>CLÁUSULA DÉCIMA QUARTA – DA ASSINATURA ELETRÔNICA</b></p>';
                cs.Cl_usula_D_cima_Quarta__c += '<p style="text-align: justify"><b>14.1.</b> Caso o presente instrumento seja assinado de forma digital ou eletronicamente, cada parte declara e garante que sua assinatura digital ou eletrônica tem o mesmo efeito vinculativo que teria a assinatura manuscrita, possuindo caráter irrevogável e irretratável, sendo realizada através de plataforma de conhecida confiabilidade, estando as partes atentas ao disposto na Medida Provisória 2.200-2/2001 ou em outra legislação que venha a substituí-la.</p>';              
             }
        }
        if(cs.Contrato_de_AltoFluxo__c == 'SIM'){
            if(cs.RecordTypeId == '0125A000001Qydf' & cs.Cl_usula_D_cima_Quinta_Editada__c == false){
                cs.Cl_usula_D_cima_Quinta__c = '<p style="text-decoration: underline"><b>CLÁUSULA DÉCIMA QUINTA – DA ASSINATURA ELETRÔNICA</b></p>';
                cs.Cl_usula_D_cima_Quinta__c += '<p style="text-align: justify"><b>15.1.</b> Caso o presente instrumento seja assinado de forma digital ou eletronicamente, cada parte declara e garante que sua assinatura digital ou eletrônica tem o mesmo efeito vinculativo que teria a assinatura manuscrita, possuindo caráter irrevogável e irretratável, sendo realizada através de plataforma de conhecida confiabilidade, estando as partes atentas ao disposto na Medida Provisória 2.200-2/2001 ou em outra legislação que venha a substituí-la.</p>';              
             
             }
         }
         if(cs.Contrato_de_AltoFluxo__c == 'NÃO'){
             if(cs.RecordTypeId == '0125A000001Qydf' & cs.Cl_usula_D_cima_Quinta_Editada__c == false){
                cs.Cl_usula_D_cima_Quinta__c = '<p style="text-decoration: underline"><b>CLÁUSULA DÉCIMA QUINTA – DA PROTEÇÃO DE DADOS</b></p>';
                cs.Cl_usula_D_cima_Quinta__c += '<p style="text-align: justify"><b>15.1.</b> As partes, por si e por seus colaboradores, obrigam-se a atuar no presente Contrato em conformidade com a Legislação vigente sobre Proteção de Dados Pessoais e as determinações de órgãos reguladores/fiscalizadores sobre a matéria, tudo conforme o que rege a Lei 13.709/2018. No que tange à utilização dos dados a de cada uma deverão:</p>';
                cs.Cl_usula_D_cima_Quinta__c += '<p style="text-align: justify; margin-left:20px;">(i) Tratar os dados pessoais a que tiver acesso de acordo com o que a cada uma lhe direcionar sempre em conformidade com estas cláusulas. Para os casos em que forem obrigadas e não mais puderem cumprir estas obrigações, por qualquer razão, concordam em informar de modo formal este fato à outra parte.</p>';
                cs.Cl_usula_D_cima_Quinta__c += '<p style="text-align: justify; margin-left:20px;">(ii) Manter e utilizar medidas de segurança para que possam proteger a confidencialidade e integridade de todos os dados pessoais mantidos ou transmitidos eletronicamente, a fim de que possam garantir a proteção desses dados contra acesso não autorizado, destruição, uso, modificação, divulgação ou perda acidental ou indevida.</p>';
                cs.Cl_usula_D_cima_Quinta__c += '<p style="text-align: justify; margin-left:20px;">(iii) Acessar os dados dentro de seu escopo e na medida abrangida pela autorização de cada uma, não podendo estes serem modificados sem expressa autorização da outra parte.</p>';
                cs.Cl_usula_D_cima_Quinta__c += '<p style="text-align: justify; margin-left:20px;">(iv) Garantir, por si próprias ou quaisquer de seus empregados, prepostos, sócios, diretores, representantes ou terceiros contratados, a confidencialidade dos dados processados, bem como a manter quaisquer Dados Pessoais estritamente confidenciais e de não os utilizar para outros fins, com exceção do objeto deste contrato.</p>';              
             }
         }
        if(cs.Contrato_de_AltoFluxo__c == 'SIM'){
            if(cs.RecordTypeId == '0125A000001Qydf' & cs.Cl_usula_D_cima_Sexta_Editada__c == false){
				cs.Cl_usula_D_cima_Sexta__c = '<p style="text-decoration: underline"><b>CLÁUSULA DÉCIMA SEXTA – DA PROTEÇÃO DE DADOS</b></p>';
                cs.Cl_usula_D_cima_Sexta__c += '<p style="text-align: justify"><b>16.1.</b> As partes, por si e por seus colaboradores, obrigam-se a atuar no presente Contrato em conformidade com a Legislação vigente sobre Proteção de Dados Pessoais e as determinações de órgãos reguladores/fiscalizadores sobre a matéria, tudo conforme o que rege a Lei 13.709/2018. No que tange à utilização dos dados a de cada uma deverão:</p>';
                cs.Cl_usula_D_cima_Sexta__c += '<p style="text-align: justify; margin-left:20px;">(i) Tratar os dados pessoais a que tiver acesso de acordo com o que a cada uma lhe direcionar sempre em conformidade com estas cláusulas. Para os casos em que forem obrigadas e não mais puderem cumprir estas obrigações, por qualquer razão, concordam em informar de modo formal este fato à outra parte.</p>';
                cs.Cl_usula_D_cima_Sexta__c += '<p style="text-align: justify; margin-left:20px;">(ii) Manter e utilizar medidas de segurança para que possam proteger a confidencialidade e integridade de todos os dados pessoais mantidos ou transmitidos eletronicamente, a fim de que possam garantir a proteção desses dados contra acesso não autorizado, destruição, uso, modificação, divulgação ou perda acidental ou indevida.</p>';
                cs.Cl_usula_D_cima_Sexta__c += '<p style="text-align: justify; margin-left:20px;">(iii) Acessar os dados dentro de seu escopo e na medida abrangida pela autorização de cada uma, não podendo estes serem modificados sem expressa autorização da outra parte.</p>';
                cs.Cl_usula_D_cima_Sexta__c += '<p style="text-align: justify; margin-left:20px;">(iv) Garantir, por si próprias ou quaisquer de seus empregados, prepostos, sócios, diretores, representantes ou terceiros contratados, a confidencialidade dos dados processados, bem como a manter quaisquer Dados Pessoais estritamente confidenciais e de não os utilizar para outros fins, com exceção do objeto deste contrato.</p>';              
                
               }
        }
        if(cs.Contrato_de_AltoFluxo__c == 'NÃO'){
             if(cs.RecordTypeId == '0125A000001Qydf' & cs.Cl_usula_D_cima_Sexta_Editada__c == false){
                cs.Cl_usula_D_cima_Sexta__c = '<p style="text-decoration: underline"><b>CLÁUSULA DÉCIMA SEXTA – DO FORO</b></p>';
                cs.Cl_usula_D_cima_Sexta__c += '<p style="text-align: justify"><b>16.1</b> Fica eleito como competente o foro da Comarca de Goiânia, Goiás, para solução de quaisquer dúvidas ou litígios decorrentes deste <b>CONTRATO</b>, renunciando os contratantes a qualquer outro que tenham ou venham a ter, por mais privilegiado que seja.</p>';   
             }
        }
        
        if(cs.Contrato_de_AltoFluxo__c == 'SIM'){
            if(cs.RecordTypeId == '0125A000001Qydf' & cs.Cl_usula_D_cima_S_tima_Editada__c == false){
        	cs.Cl_usula_D_cima_S_tima__c = '<p style="text-decoration: underline"><b>CLÁUSULA DÉCIMA SÉTIMA – DO FORO</b></p>';
            cs.Cl_usula_D_cima_S_tima__c += '<p style="text-align: justify"><b>17.1.</b> Fica eleito como competente o foro da Comarca de Goiânia, Goiás, para solução de quaisquer dúvidas ou litígios decorrentes deste <b>CONTRATO</b>, renunciando os contratantes a qualquer outro que tenham ou venham a ter, por mais privilegiado que seja.</p>';
         }
        }
      
        if(cs.RecordTypeId == '0126e000001YbJL' & cs.Cl_usula_Primeira_Editada__c == false){
             cs.Cl_usula_Primeira__c = '<p style="text-decoration: underline"><b>CLÁUSULA PRIMEIRA – DAS DEFINIÇÕES</b><p>';
             cs.Cl_usula_Primeira__c +='<p style="text-align: justify"><b>1.1. </b>Os serviços de <b>INTERNAÇÃO/ ASSISTÊNCIA DOMICILIAR – HOME CARE</b> possuem as seguintes definições:</p>';
             cs.Cl_usula_Primeira__c +='<p style="text-align: justify"><b>1.2. </b> <b>Beneficiários: </b> todos os indivíduos a serem tratados pela CONTRATADA e pelo CUIDADOR seja através de assistência domiciliar ou através de internação domiciliar.</p>';
             cs.Cl_usula_Primeira__c +='<p style="text-align: justify"><b>1.3. </b> <b>Internação Domiciliar: </b>consiste em atendimento de equipe multiprofissional, uso de equipamentos, materiais e medicamentos, de acordo com a gravidade do caso, podendo ser de baixa, média e alta complexidade, o que será desenvolvido mediante a contratação de diárias na residência do BENEFICIÁRIO ou naresidência do CONTRATANTE.</p>';
        	 cs.Cl_usula_Primeira__c +='<p style="text-align: justify"><b>1.4. </b> <b>Assistência Domiciliar: </b>consiste em atendimento de equipe multriprofissional, uso de equipamentos, materiais e medicamentos, de acordo com a gravidade do caso, podendo ser de baixa, média e alta complexidade, o que será desenvolvido mediante a contratação de visitas na residência do BENEFICIÁRIO ou na residência do CONTRATANTE.</p>';
        	 cs.Cl_usula_Primeira__c +='<p style="text-align: justify"><b>1.5. </b> <b>Cuidador: </b>profissionais que compõem a equipe técnica da internação domiciliar, com a função de prestar assistência ao BENEFICIÁRIO.</p>';
             cs.Cl_usula_Primeira__c +='<p style="text-align: justify"><b>1.6. </b> <b>Programa: </b>plano de atendimento estruturado no perfil de complexidade clínica e social.</p>';       
        }
        
        if(cs.RecordTypeId == '0126e000001YbJL' & cs.Cl_usula_Segunda_Editada__c == false) {
             cs.Cl_usula_Segunda__c ='<p style="text-decoration: underline"><b>CLÁUSULA SEGUNDA – DO OBJETO</b></p>';
             cs.Cl_usula_Segunda__c += '<p style="text-align: justify"><b>2.1. </b>A <b>CONTRATADA</b>, por força do presente instrumento, obriga-se a prestar os serviços de INTERNAÇÃO OU ASSISTÊNCIA DOMICILIAR – HOME CARE aos <b>BENEFICIÁRIOS</b> vinculados à <b>CONTRATANTE</b>, observando os padrões técnicos e éticos usualmente aceitos pela prática profissional, em caráter não exclusivo, autônomo e sem qualquer vínculo empregatício, conforme Cláusulas ora estipuladas neste contrato, no Código de Ética Médica e demais legislações pertinentes aplicáveis.</p>';
             cs.Cl_usula_Segunda__c += '<p style="text-align: justify"><b>2.2. </b>As especialidades e os serviços e atividades atendidos pela <b>CONTRATADA</b>, estão descritos no anexo I – Serviços Inclusos.</p>';
             cs.Cl_usula_Segunda__c += '<p style="text-align: justify"><b>2.3. </b>A eventual necessidade de alteração da Tabela de Preços, bem como a inclusão ou exclusão de serviços abrangidos, mediante Termo Aditivo a ser formalizado entre as partes.</p>';
         }
        
        if(cs.RecordTypeId == '0126e000001YbJL' & cs.Cl_usula_Terceira_Editada__c == false) {
             cs.Cl_usula_Terceira__c ='<p style="text-decoration: underline"><b>CLÁUSULA TERCEIRA – DO ATENDIMENTO AOS BENEFICIÁRIOS</b></p>';
             cs.Cl_usula_Terceira__c += '<p style="text-align: justify"><b>3.1. </b>Para atendimento pela <b>CONTRATADA</b>, os <b>BENEFICIÁRIOS</b> da <b>CONTRATANTE</b> deverão ter seu nome vinculado ao presente instrumento, sendo certo que BENEFICIÁRIOS não inclusos pela CONTRANTE neste rol, não poderão usufruir dos serviços aqui estipulados.</p>';
             cs.Cl_usula_Terceira__c += '<p style="text-align: justify"><b>3.2. </b>Nos casos de comprovada urgência e/ou emergência em que o <b>BENEFICIÁRIO</b> não estiver vinculado ao presente instrumento, a <b>CONTRATADA</b> poderá realizar o atendimento e orientar a <b>CONTRATANTE</b> acerca do prazo de até 12 (doze) horas, após o início do atendimento, para o cumprimento da referida exigência, sob pena de cobrança de multa de 30% (trinta por cento) do valor global deste instrumento por dia de atraso.</p>';
        }
        
        if(cs.RecordTypeId == '0126e000001YbJL' & cs.Cl_usula_Quarta_Editada__c == false){
             cs.Cl_usula_Quarta__c ='<p style="text-decoration: underline"><b>CLÁUSULA QUARTA – DA PRESTAÇÃO DOS SERVIÇOS</b></p>';
             cs.Cl_usula_Quarta__c += '<p style="text-align: justify"><b>4.1. </b>Os serviços deverão ser prestados aos <b>BENEFICIÁRIOS</b> do <b>CONTRATANTE</b> dentro dos limites, padrões e condições de atendimento aqui pactuados, conforme constam no Item 4 do RIC – Serviços Inclusos.</p>';
             cs.Cl_usula_Quarta__c += '<p style="text-align: justify"><b>Parágrafo Único: </b>Eventuais serviços não inclusos no Item 4 do RIC e que venham a ser realizados em razão de emergência ou requerimento do <b>BENEFICIÁRIO</b> ou da <b>CONTRATANTE</b>, poderão ser cobrados e inclusos neste instrumento mediante Termo Adivito.</p>';
       		 cs.Cl_usula_Quarta__c += '<p style="text-align: justify"><b>4.2. </b>A avaliação inicial somente poderá ser efetivada após solicitação por escrito e autorização da médica.</p>';
             cs.Cl_usula_Quarta__c += '<p style="text-align: justify"><b>4.3. </b>Após a avaliação inicial, mediante constatação da elegibilidade para assistência ou internação domiciliar, a <b>CONTRATADA</b> poderá em conjunto com a <b>CONTRATANTE</b> formular um Plano de Atenção Domiciliar (PAD) para melhor atendimento e adequação do caso.</p>';
        	 cs.Cl_usula_Quarta__c += '<p style="text-align: justify"><b>4.4. </b>A indicação para monitoramento será de responsabilidade da <b>CONTRATANTE</b> que encaminhará à <b>CONTRATADA</b> os dados de cadastro do <b>BENEFICIÁRIO</b> e a prescrição médica para tanto.</p>'; 
        }
        
        if(cs.RecordTypeId == '0126e000001YbJL' & cs.Cl_usula_Quinta_Editada__c == false){
             cs.Cl_usula_Quinta__c ='<p style="text-decoration: underline"><b>CLÁUSULA QUINTA – DAS AUTORIZAÇÕES PRÉVIAS</b></p>';
             cs.Cl_usula_Quinta__c += '<p style="text-align: justify"><b>5.1. </b> A internação e assistência domiciliar, bem como outros procedimentos que eventualmente se façam necessários, somente terão início mediante prévia e expressa autorização da <b>CONTRATANTE</b>, devendo as autorizações serem solicitadas pela <b>CONTRATADA</b>.</p>';
             cs.Cl_usula_Quinta__c += '<p style="text-align: justify"><b>5.2. </b>A internação ou assistência domiciliar tem o prazo estipulado no item 6 do RIC, podendo ser renovada mensalmente por prorrogações orçamentárias, conforme a evolução do BENEFICIÁRIO.</p>';
        	 cs.Cl_usula_Quinta__c += '<p style="text-align: justify"><b>5.3. </b>As indicações das altas da internação ou assistência domiciliar serão sempre precedidas de um período mínimo de 48 (quarenta e oito) horas úteis, sendo as mesmas previamente definidas após discussão e consenso entre a <b>CONTRATADA</b> e a <b>CONTRATANTE</b>.</p>'; 
        }
        
        if(cs.RecordTypeId == '0126e000001YbJL' & cs.Cl_usula_Sexta_Editada__c == false){
             cs.Cl_usula_Sexta__c ='<p style="text-decoration: underline"><b>CLÁUSULA SEXTA – DAS OBRIGAÇÕES DO CONTRATANTE</b></p>';
             cs.Cl_usula_Sexta__c += '<p style="text-align: justify"><b>6.1. </b>O <b>CONTRATANTE</b> se coloca à disposição da <b>CONTRATADA</b> para fornecer todo e qualquer dado e/ou informação necessária para manter e preservar o bom relacionamento entre as partes.</p>';
             cs.Cl_usula_Sexta__c += '<p style="text-align: justify"><b>6.2. </b>O <b>CONTRATANTE</b> compromete-se a comunicar, por escrito à <b>CONTRATADA</b> eventuais novas necessidades que advierem no curso deste instrumento, sendo certo que aquelas não comunicadas e que forem de seu conhecimento pretérito, não poderão ser exigidas da <b>CONTRATADA</b> ou imputadas à sua culpa.</p>';
        	 cs.Cl_usula_Sexta__c += '<p style="text-align: justify"><b>6.3. </b>Fica o <b>CONTRATANTE</b> ciente da impossibilidade de subcontratação de quaisquer dos <b>CUIDADORES</b> disponibilizados pela <b>CONTRATADA</b> no tratamento do <b>BENEFICIÁRIO</b>, sendo certo que eventual subcontratação caracterizará em quebra das disposições contratuais ensejando na cobrança de multa contratual na monta de 05 (cinco) vezes o valor global deste instrumento, sem prejuízo de eventuais perdas e danos.</p>'; 
        	 cs.Cl_usula_Sexta__c += '<p style="text-align: justify"><b>6.4. </b>Efetuar o pagamento à <b>CONTRATADA</b> referente aos serviços prestados aos <b>BENEFICIÁRIOS</b> conforme valores constantes no item 4 do RIC que é parte integrante deste instrumento que é parte integrante e vinculante a este contrato.</p>';
             cs.Cl_usula_Sexta__c += '<p style="text-align: justify"><b>6.5. </b>Comunicar à <b>CONTRATADA</b>, por escrito, sobre eventuais alterações cadastrais, como: endereço para faturamento, endereço de Nota Fiscal, número de telefones, CPF/CNPJ, Razão Social/Nome Completo do <b>BENEFICIÁRIO</b>, no prazo máximo de até 02 (duas) horas.</p>';
             cs.Cl_usula_Sexta__c += '<p style="text-align: justify"><b>6.6. </b>A <b>CONTRATANTE</b> desde já se obriga a apresentar à <b>CONTRATADA</b> no momento de formalização da assistência ou internação domiciliar, a prescrição médica necessária para tanto, o que será requisito essencial para o início da prestação de serviços, constando também como Anexo I do presente instrumento.</p>';
             cs.Cl_usula_Sexta__c += '<p style="text-align: justify"><b>6.7. </b>Manter a <b>CONTRATADA</b> informada, por escrito e de maneira imediata, sobre alterações de rotinas, sintomas, reações ao tratamento e procedimentos de forma geral.</p>';
             cs.Cl_usula_Sexta__c += '<p style="text-align: justify"><b>Parágrafo Único: </b>Eventuais alterações de rotina, sintomas, reações ao tratamento e procedimentos de formal geral não informados de maneira imeadiata à <b>CONTRATADA</b> não poderão dela serem cobradas ou imputados quaisquer resultados não esperados ou não satisfatórios e que venham a prejudicar o tratamento que já estava em curso.</p>';        
        }
        
        if(cs.RecordTypeId == '0126e000001YbJL' & cs.Cl_usula_S_tima_Editada__c == false){
             cs.Cl_usula_S_tima__c ='<p style="text-decoration: underline"><b>CLÁUSULA SÉTIMA – DAS OBRIGAÇÕES DA CONTRATADA</b></p>';
             cs.Cl_usula_S_tima__c += '<p style="text-align: justify"><b>7.1. </b>A <b>CONTRATADA</b> obriga-se comunicar imediatamente ao <b>CONTRATANTE</b>, as alterações havidas na relação de especialidades e serviços constantes do Item 4 do RIC, bem como eventuais procedimentos emergenciais necessários que não estiverem aqui especificados, sendo estes desde já autorizados para o devido fim de resguardar a vida e o bem-estar do <b>BENEFICIÁRIO</b>, podendo ser cobrados da <b>CONTRATANTE</b> posteriormente.</p>';
             cs.Cl_usula_S_tima__c += '<p style="text-align: justify"><b>7.2. </b>A <b>CONTRATADA</b> obriga-se, também, a comunicar ao <b>CONTRATANTE</b> caso seja compelida por autoridade judicial competente a fornecer atendimento de responsabilidade da mesma, apesar de ser contra sua vontade e/ ou entendimento.</p>';          
        }
        
        if(cs.RecordTypeId == '0126e000001YbJL' & cs.Cl_usula_Oitava_Editada__c == false){
             cs.Cl_usula_Oitava__c ='<p style="text-decoration: underline"><b>CLÁUSULA OITAVA – DOS CRITÉRIOS DE PAGAMENTO DOS SERVIÇOS</b></p>';
             cs.Cl_usula_Oitava__c += '<p style="text-align: justify"><b>8.1. </b>Para os serviços prestados de internação ou assistência domiciliar, a <b>CONTRATADA</b> encaminhará relatório dos <b>BENEFICIÁRIOS</b> atendidos.</p>';
             cs.Cl_usula_Oitava__c += '<p style="text-align: justify"><b>8.2. </b>O <b>CONTRATANTE</b> obriga-se a efetuar os pagamentos à <b>CONTRATADA</b> conforme estabelecido no cronograma de pagamento previstos no RIC, sendo certo que eventuais atrasos no pagamento incorrerão nas seguintes penalidades:</p>';
             cs.Cl_usula_Oitava__c += '<p style="text-align: justify"><b>&nbsp;&nbsp;&nbsp;&nbsp;a) </b>Juros de mora a razão de 1% (um por cento) ao mês;</p>';
             cs.Cl_usula_Oitava__c += '<p style="text-align: justify"><b>&nbsp;&nbsp;&nbsp;&nbsp;b) </b>Multa moratória de 2% (dois por cento) ao dia sobre o valor total da obrigação em atraso;</p>';
             cs.Cl_usula_Oitava__c += '<p style="text-align: justify"><b>&nbsp;&nbsp;&nbsp;&nbsp;c) </b>Correção monetária, “pró rata tempore”, com base na variação do índice do INPC;</p>';
             cs.Cl_usula_Oitava__c += '<p style="text-align: justify"><b>&nbsp;&nbsp;&nbsp;&nbsp;d) </b>Todas as despesas de cobrança, custas judiciais, extrajudiciais e honorários advocatícios na monta de 20% sobre o valor total do débito;</p>';
             cs.Cl_usula_Oitava__c += '<p style="text-align: justify"><b>8.3. </b>A <b>CONTRATADA</b> reconhecerá como quitação das faturas apresentadas os respectivos créditos em conta da <b>CONTRATADA</b>.</p>';
             cs.Cl_usula_Oitava__c += '<p style="text-align: justify"><b>8.4. </b>Caso a <b>CONTRATANTE</b> não concorde com os serviços apresentados e valores cobrados pela <b>CONTRATADA</b>, esta deverá protocolar de forma escrita junto à <b>CONTRATADA</b> suas eventuais impugnações, as quais serão respondidas em um prazo de até 10 (dez) dias úteis.</p>';
        }
        
        if(cs.RecordTypeId == '0126e000001YbJL' & cs.Cl_usula_Nona_Editada__c == false){
             cs.Cl_usula_Nona__c ='<p style="text-decoration: underline"><b>CLÁUSULA NONA – DA RESPONSABILIDADE</b></p>';
             cs.Cl_usula_Nona__c += '<p style="text-align: justify"><b>9.1. </b>Os <b>CUIDADORES</b> são os únicos responsáveis pela qualidade e eficiência dos serviços prestados aos usuários, respondendo civil e penalmente pelos mesmos, sendo certo que a <b>CONTRATADA</b> é tão somente intermediadora dos serviços e que eventuais reclamações ou cobranças relativas aos serviços prestados deverão ser direcionados aos <b>CUIDADORES</b>, cada um respondendo por sua respectiva função.</p>';
             cs.Cl_usula_Nona__c += '<p style="text-align: justify"><b>9.2. </b>A <b>CONTRATADA</b> não se responsabilizará por eventual dano, decorrente de negligência imprudência ou imperícia causada pelos <b>CUIDADORES</b> aos <b>BENEFICIÁRIOS</b>.</p>';
             cs.Cl_usula_Nona__c += '<p style="text-align: justify"><b>9.3. </b>A <b>CONTRATADA</b> assume o compromisso de observar rigidamente os princípios e normas que regem a sua atividade, e pelo cumprimento das exigências emanadas pelos Órgãos Públicos.</p>';
             cs.Cl_usula_Nona__c += '<p style="text-align: justify"><b>9.4. </b>A <b>CONTRATADA</b> fornecerá os dados assistenciais dos atendimentos prestados aos <b>BENEFICIÁRIOS</b> da <b>CONTRATANTE</b>, observadas as questões éticas e de sigilo profissional quando requisitados pela ANS – Agência Nacional de Saúde Suplementar, à <b>CONTRATANTE</b>, conforme disposto no inciso XXXI do artigo 4º da Lei n º 9.961 de 2000.</p>';
             cs.Cl_usula_Nona__c += '<p style="text-align: justify"><b>9.5. </b>É de inteira responsabilidade da <b>CONTRATADA</b> a negociação e compra de todos os materiais (inclusive os especiais), medicamentos e todos os insumos necessários ao bom atendimento ao <b>BENEFICIÁRIO</b>, sendo que estes serão repassados ao <b>CONTRATANTE</b> para que arque com todo e qualquer valor referente a tais insumos.</p>';
             cs.Cl_usula_Nona__c += '<p style="text-align: justify"><b>9.6. </b>A <b>CONTRATADA</b> obriga-se a manter, durante toda a execução deste contrato, em compatibilidade com nas obrigações por ela assumidas, todas as condições de habilitação exigidas no procedimento de credenciamento.</p>';
            
         }
        
        if(cs.RecordTypeId == '0126e000001YbJL' & cs.Cl_usula_D_cima_Editada__c == false){
             cs.Cl_usula_D_cima__c ='<p style="text-decoration: underline"><b>CLÁUSULA DÉCIMA – DA ABRANGÊNCIA GEOGRÁFICA</b></p>';
             cs.Cl_usula_D_cima__c += '<p style="text-align: justify"><b>10.1. </b>A prestação dos serviços abrangerá tão somente o local indicado no item 2 do RIC, em razão da tratativa exclusiva de home care aqui disposta.</p>';
             cs.Cl_usula_D_cima__c += '<p style="text-align: justify"><b>Parágrafo Único: </b>Em caso de requerimento por parte do <b>CONTRATANTE</b> ou do <b>BENEFICIÁRIO</b> de que seja o endereço de tratamento alterado, será cobrado taxa de mudança no valor de R$ 500,00 (quinhentos reais).</p>';
         }
        
        if(cs.RecordTypeId == '0126e000001YbJL' & cs.Cl_usula_D_cima_Primeira_Editada__c == false){
             cs.Cl_usula_D_cima_Primeira__c ='<p style="text-decoration: underline"><b>CLÁUSULA DÉCIMA PRIMEIRA – DO PRAZO DE VIGÊNCIA</b></p>';
             cs.Cl_usula_D_cima_Primeira__c += '<p style="text-align: justify"><b>11.1. </b>O presente contrato terá a vigência indicada no item 6 do RIC, a contar da data de sua assinatura.</p>';
             cs.Cl_usula_D_cima_Primeira__c += '<p style="text-align: justify"><b>11.2. </b>A rescisão ou encerramento do presente contrato não surtirá efeito algum sobre eventuais direitos e obrigações das partes, desde que originadas em data anterior daqueles eventos, principalmente no que tange aos tratamentos iniciados aos <b>BENEFICIÁRIOS</b>, sendo o serviço prestado devidamente remunerado pelo <b>CONTRATANTE</b>.</p>';
        	 cs.Cl_usula_D_cima_Primeira__c += '<p style="text-align: justify"><b>11.3. </b>O presente contrato poderá ser rescindido por justa causa pela CONTRATADA, sendo garantido seu direito à cobrança de multa contratual na monta de 30% (trinta) do valor previsto no item 7 do RIC, em razão de :</p>';
			 cs.Cl_usula_D_cima_Primeira__c += '<p style="text-align: justify"><b>✓</b>&nbsp;&nbsp;&nbsp;&nbsp;a) Necessidade de paralisação dos serviços em razão da inadequação ou má conduta do <b>BENEFICIÁRIO</b>;</p>';
             cs.Cl_usula_D_cima_Primeira__c += '<p style="text-align: justify"><b>✓</b>&nbsp;&nbsp;&nbsp;&nbsp;b) Inadimplemento comprovado por parte do <b>CONTRATANTE</b> superior a 60 (sessenta) dias;</p>';
             cs.Cl_usula_D_cima_Primeira__c += '<p style="text-align: justify"><b>✓</b>&nbsp;&nbsp;&nbsp;&nbsp;c) Não cumprimento de qualquer cláusula do contrato por parte do <b>CONTRATANTE</b>;;</p>';            
             cs.Cl_usula_D_cima_Primeira__c += '<p style="text-align: justify"><b>11.4. </b>Na hipótese de rescisão antecipada do presente instrumento, por infração do <b>CONTRATANTE</b> ou no que tange aos casos dispostos no item 11.3, será devida multa correspondente ao valor de 30% (trinta por cento) do valor global deste instrumento, podendo ser cobrada pela <b>CONTRATADA</b>, com todos os encargos previstos e pactuados entre as partes.</p>';
             cs.Cl_usula_D_cima_Primeira__c += '<p style="text-align: justify"><b>Parágrafo Único: </b>Aqui entende-se como inadequação do <b>BENEFICIÁRIO</b> qualquer evento que venha e constranger ou forçar o <b>CUIDADOR</b> a não prosseguir com a prestação da assistência ou internação domiciliar.</p>';
        
        }
        
        if(cs.RecordTypeId == '0126e000001YbJL' & cs.Cl_usula_D_cima_Segunda_Editada__c == false){
        	cs.Cl_usula_D_cima_Segunda__c = '<p style="text-decoration: underline"><b>CLÁUSULA DÉCIMA SEGUNDA – DA SUBSTITUIÇÃO DE CUIDADORES</b></p>';
            cs.Cl_usula_D_cima_Segunda__c += '<p style="text-align: justify"><b>12.1. </b>Em caso de expressa necessidade de substituição manifestada pelo <b>CONTRATANTE</b> de algum dos <b>CUIDADORES</b> dispostos no item 4 do RIC, o caso será analisado pela <b>CONTRATADA</b> e, no prazo de até 15 (quinze) dias indicará ao <b>CONTRATANT</b>E as possibilidades ou não de substituição destes com a devida motivação para o caso.</p>';
            cs.Cl_usula_D_cima_Segunda__c += '<p style="text-align: justify"><b>12.2. </b>Em caso de necessidade de substituição manifestada pela <b>CONTRATADA</b> de algum dos <b>CUIDADORES</b>, em razão de inadequação ou má conduta dos <b>BENEFICIÁRIOS</b>, o caso será repassado ao <b>CONTRATANTE</b>, sendo certo que este deverá arcar com os custos da substituição necessária, neste ato dispostos de maneira individual no ITEM 4 do RIC.</p>';        
         }
        
        if(cs.RecordTypeId == '0126e000001YbJL' & cs.Cl_usula_D_cima_Terceira_Editada__c == false){
        	cs.Cl_usula_D_cima_Terceira__c = '<p style="text-decoration: underline"><b>CLÁUSULA DÉCIMA TERCEIRA – DAS PRÁTICAS ANTICORRUPÇÃO</b></p>';
            cs.Cl_usula_D_cima_Terceira__c += '<p style="text-align: justify"><b>13.1. </b>As Partes obrigam-se a observar, cumprir e/ou fazer cumprir, por si, suas afiliadas (entidades controladoras, controladas, coligadas ou sob controle comum) e representantes (diretores, membros do conselho de administração, quaisquer terceiros, incluindo assessores ou prestadores de serviços) toda e qualquer lei anticorrupção, em especial a Lei Federal nº 12.846/13, conforme aplicável.</p>';              
         }
        
        if(cs.RecordTypeId == '0126e000001YbJL' & cs.Cl_usula_D_cima_Terceira_Editada__c == false){
        	cs.Cl_usula_D_cima_Terceira__c = '<p style="text-decoration: underline"><b>CLÁUSULA DÉCIMA TERCEIRA – DAS PRÁTICAS ANTICORRUPÇÃO</b></p>';
            cs.Cl_usula_D_cima_Terceira__c += '<p style="text-align: justify"><b>13.1. </b>As Partes obrigam-se a observar, cumprir e/ou fazer cumprir, por si, suas afiliadas (entidades controladoras, controladas, coligadas ou sob controle comum) e representantes (diretores, membros do conselho de administração, quaisquer terceiros, incluindo assessores ou prestadores de serviços) toda e qualquer lei anticorrupção, em especial a Lei Federal nº 12.846/13, conforme aplicável.</p>';              
         }
        
        if(cs.RecordTypeId == '0126e000001YbJL' & cs.Cl_usula_D_cima_Quarta_Editada__c == false){
        	cs.Cl_usula_D_cima_Quarta__c = '<p style="text-decoration: underline"><b>CLÁUSULA DÉCIMA QUARTA – DA ASSINATURA ELETRÔNICA</b></p>';
            cs.Cl_usula_D_cima_Quarta__c += '<p style="text-align: justify"><b>14.1. </b>Caso o presente instrumento seja assinado de forma digital ou eletronicamente, cada parte declara e garante que sua assinatura digital ou eletrônica tem o mesmo efeito vinculativo que teria a assinatura manuscrita, possuindo caráter irrevogável e irretratável, sendo realizada através de plataforma de conhecida confiabilidade, estando as partes atentas ao disposto na Medida Provisória 2.200-2/2001 ou em outra legislação que venha a substituí-la.</p>';              
         }
        
        if(cs.RecordTypeId == '0126e000001YbJL' & cs.Cl_usula_D_cima_Quinta_Editada__c == false){
        	cs.Cl_usula_D_cima_Quinta__c = '<p style="text-decoration: underline"><b>CLÁUSULA DÉCIMA QUINTA – DA PROTEÇÃO DE DADOS</b></p>';
            cs.Cl_usula_D_cima_Quinta__c += '<p style="text-align: justify"><b>15.1. </b>A CONTRATADA, por si e por seus colaboradores, obriga-se a atuar no presente Contrato em conformidade com a Legislação vigente sobre Proteção de Dados Pessoais e as determinações de órgãos reguladores/fiscalizadores sobre a matéria, tudo conforme o que rege a Lei 13.709/2018. No que tange à utilização dos dados a CONTRATADA deverá:</p>';
            cs.Cl_usula_D_cima_Quinta__c += '<p style="text-align: justify">(i) Tratar os dados pessoais a que tiver acesso de acordo com o que a CONTRATANTE lhe direcionar sempre em conformidade com estas cláusulas. Para os casos em que for obrigada e não mais puder cumprir estas obrigações, por qualquer razão, concorda em informar de modo formal este fato à CONTRATANTE.</p>';
            cs.Cl_usula_D_cima_Quinta__c += '<p style="text-align: justify">(ii) Manter e utilizar medidas de segurança para que possa proteger a confidencialidade e integridade de todos os dados pessoais mantidos ou transmitidos eletronicamente, a fim de que possa garantir a proteção desses dados contra acesso não autorizado, destruição, uso, modificação, divulgação ou perda acidental ou indevida.</p>';
            cs.Cl_usula_D_cima_Quinta__c += '<p style="text-align: justify">(iii) Acessar os dados dentro de seu escopo e na medida abrangida pela autorização da CONTRATANTE, não podendo estes serem modificados sem expressa autorização da CONTRATANTE.</p>';
            cs.Cl_usula_D_cima_Quinta__c += '<p style="text-align: justify">(iv) Garantir, por si própria ou quaisquer de seus empregados, prepostos, sócios, diretores, representantes ou terceiros contratados, a confidencialidade dos dados processados, bem como a manter quaisquer Dados Pessoais estritamente confidenciais e de não os utilizar para outros fins, com exceção da prestação de serviços à CONTRATANTE.</p>';              
         }
                       
        if(cs.RecordTypeId == '0126e000001YbJL' & cs.Cl_usula_D_cima_Sexta_Editada__c == false){
        	cs.Cl_usula_D_cima_Sexta__c = '<p style="text-decoration: underline"><b>CLÁUSULA DÉCIMA SEXTA – DO FORO DO CONTRATO</b></p>';
            cs.Cl_usula_D_cima_Sexta__c += '<p style="text-align: justify"><b>16.1. </b>Fica eleito como competente o foro da Comarca de Goiânia, Goiás, para solução de quaisquer dúvidas ou litígios decorrentes deste contrato, renunciando os contratantes a qualquer outro que tenham ou venham a ter, por mais privilegiado que seja.</p>';
         }
        
    }      
}