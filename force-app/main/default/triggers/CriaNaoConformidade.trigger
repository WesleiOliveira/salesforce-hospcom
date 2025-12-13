trigger CriaNaoConformidade on Auditoria__c (after update){

//DESTIVADO
    
    String[] questoes = new String[1];
    
    
    // Questão 1 01 – Existe um manual de boas práticas na empresa? Ele está impresso e disponível na recepção?
    questoes.add('01 – Existe um manual de boas práticas na empresa? Ele está impresso e disponível na recepção?');   
    // Questão 2
    questoes.add('02 - Existe uma política da qualidade na empresa?');
    // Questão 3   
    questoes.add('03 - A política da qualidade está descrita no manual da Qualidade?');
    // Questão 4   
    questoes.add('04 - Os objetivos estabelecidos pela empresa são coerentes com a política da qualidade?');
    // Questão 5 
    questoes.add('05 - Os objetivos estabelecidos pela empresa são coerentes com a política da qualidade ?');
    // Questão 6  
    questoes.add('06 - Os funcionários foram informados sobre a política da qualidade? Como?');
    // Questão 7 
    questoes.add('07 - Foi oferecido treinamento na política da qualidade para os funcionários?');
    // Questão 8   
    questoes.add('08 - Os treinamentos oferecidos tiveram sua eficácia avaliada?');
    // Questão 9 
    questoes.add('09 - A empresa possui um organograma estabelecido?');
    // Questão 10   
    questoes.add('10 - Há pessoal suficiente na organização?');
    // Questão 11   
    questoes.add('11 - Ficou evidenciado algum tipo de conflito de interesse entre as áreas técnicas/qualidade e outras áreas?');
    // Questão 12 
    questoes.add('  12 - Como foram estabelecidas as autoridades e as responsabilidades dentro do Sistema de Gestão da Qualidade?');
    // Questão 13  
    questoes.add('13 - O método utilizado para estabelecer autoridade e responsabilidade é apropriado e contempla todos os itens da RDC 16/2013?');
    // Questão 14    
    questoes.add('14 - Quais atividades de verificação existem na empresa?');
    //Questão 15
    questoes.add('15 - Foram designadas pessoas para as tarefas de verificação?');
    //Questão 16
    questoes.add('16 - As pessoas designadas foram treinadas? Estão conscientes dos critérios utilizados para aceitação ou reprovação?');
    //Questão 17 
    questoes.add('17 - Existe um representante da gerência (RG) na Organização?');
    //Questão 18 
    questoes.add('18 - Existe um representante da gerência (RG) na Organização?');
    //Questão 19
    questoes.add('19 - Como o RG foi nomeado?Pode ter sido através de termo de nomeação, ata de reunião, no manual ou outras formas.');
    //Questão 20
    questoes.add('20 - Quais atividades foram atribuídas ao RG? Constam as atividades abaixo?');
    //Questão 21
    questoes.add('21 - Existe procedimento de análise crítica / revisão gerencial?');
    //Questão 22 
    questoes.add('22 - Foi estabelecida a periodicidade desta revisão?');
    //Questão 23 
    questoes.add('23 - Foi realizada alguma revisão gerencial?');
    //Questão 24
    questoes.add('24 - Como foi documentada a revisão gerencial?');
    //Questão 25
    questoes.add('25 - Quem participou da revisão?');
    //Questão 26
    questoes.add('26 - No mínimo os tópicos a seguir constam no relatório / ata da reunião como pontos que foram analisados?');
    //Questão 27
    questoes.add('27 - Foi estabelecido a descrição para todas as funções/cargos constantes no organograma?');
    //Questão 28
    questoes.add('28 - A descrição estabelecida apresenta critérios de formação (escolaridade), experiência (tempo de exercício na função), habilidades (perfil) e treinamentos (formação específica, interna ou externa, na função)?');
    //Questão 29
    questoes.add('29 - Existe comprovação que os empregados atendem a descrição?');
    //Questão 30
    questoes.add('30 - Existe procedimento de treinamento?');
    //Questão 31
    questoes.add('31 - Existe evidência que o pessoal foi treinado para as atividades das quais são responsáveis?');
    //Questão 32
    questoes.add('32 - Existe comprovação da competência desse consultor? ');
    //Questão 33
    questoes.add('33 - Os empregados foram advertidos de defeitos em produtos que poderão ocorrer como resultado do desempenho incorreto de suas funções específicas?');
    //Questão 34
    questoes.add('34 - Foi ultilozado algum consultor em seu processo de produção e na qualidade?');
    //Questão 35
    questoes.add('35 - Existe comprovação da competência desse consultor?');
    //Questão 36
    questoes.add('36 - Existe um plano de gerenciamento de riscos?');
    //Questão 37
    questoes.add('37 - Os riscos foram identificados, avaliados e estabelecido planos de ações ?');
    //Questão 38
    questoes.add('38 - O plano de gerenciamento de riscos contempla toda cadeia, desde o recebimento do material, passando pela fabricação até a distribuição?');
    //Questão 39
    questoes.add('39 - Existe monitoramento do plano de gerenciamento de risco?');
    //Questão 40
    questoes.add('40 - Foram designados responsáveis pelo gerenciamento dos riscos identificados?');
    //Questão 41
    questoes.add('41 - Existe previsão de revisão do plano? Com que frequência?');
    //Questão 42
    questoes.add('42 - Quem é o responsável pela revisão?');
    //Questão 43
    questoes.add('43 - Existe procedimento de aquisição ou equivalente?');
    //Questão 44
    questoes.add('44 - Existe procedimento de avaliação de fornecedores e prestadores de serviços?');
    //Questão 45
    questoes.add('45 - Quais critérios foram estabelecidos?');
    //Questão 46
    questoes.add('46 -Todos os prestadores de serviços cujos resultados possam ter impacto sobre o produto são avaliados? Quais foram considerados pela empresa');
    //Questão 47
    questoes.add('47 - Existe documentação / registros que comprove que o fornecedor ou prestador atende aos requisitos especificados?');
    //Questão 48
    questoes.add('48 - São mantidos registros das compras?');
    //Questão 49
    questoes.add('04 - Esses registros apresentam a especificação dos itens a serem adquiridos?');
    //Questão 50
    questoes.add('  50 - A especificação enviada ao fornecedor deixa claro o produto e suas especificações? Pode haver ambiguidade?');
    //Questão 51
    questoes.add('51 - Esses registros identificam os responsáveis pela aprovação e a data?');
    //Questão 52
    questoes.add('52 - Existe procedimento para controle de documentos?');
    //Questão 53
    questoes.add('53 - Existe procedimento para aprovação de documentos?');
    //Questão 54
    questoes.add('54 - Os documentos são aprovados por pessoas designadas?');
    //Questão 55
    questoes.add('55 - Verifique se os documentos estão assinados.');
    //Questão 56
    questoes.add('56 - Verifique se a pessoa que assinou os documentos está autorizada a assinar.');
    //Questão 57
    questoes.add('57 - Existe procedimento para emissão de documentos?');
    //Questão 58
    questoes.add('58 - Existe procedimento para distribuição de documentos?');
    //Questão 59
    questoes.add('59 - Escolha um setor aleatório e verifique se os documentos estão disponíveis para uso. Verifique se os documentos estão nas versões atuais.');
    //Questão 60
    questoes.add('60 - O documento em vigência encontra-se assinado pelo Elaborador, Revisor e Aprovador?');
    //Questão 61
    questoes.add('61 - Existe procedimento para alteração / revisão de documentos?');
    //Questão 62
    questoes.add('62 - Os documentos estão atualizados de acordo com os procedimentos de revisão de documentos?');
    //Questão 63
    questoes.add('63 - Existe procedimento para remoção de documentos obsoletos?');
    //Questão 64
    questoes.add('64 - São mantidas cópias obsoletas?');
    //Questão 65
    questoes.add('65 - Os obsoletos são identificados?');
    //Questão 66
    questoes.add('66 - Onde são arquivadas?');
    //Questão 67
    questoes.add('67 - Por quanto tempo é mantido?');
    //Questão 68
    questoes.add('68 - A empresa mantém procedimentos para alteração e revisão de documentos?');
    //Questão 69
    questoes.add('69 - Há procedimentos para distribuição e recolhimento de documentos identificados como documentos controlados?');
    //Questão 70
    questoes.add('70 - Há previsão de treinamento antes dos documentos entrarem em vigor?');
    //Questão 71
    questoes.add('71 - Existem procedimentos para o arquivo dos registros dos documentos referentes ao sistema de qualidade?');
    //Questão 72
    questoes.add('72 - Os registros são arquivados pelo prazo estabelecido pelas boas práticas de fabricação para produtos médicos?');
    //Questão 73
    questoes.add('73 - Qual o prazo estabelecido para armazenamento dos registros referentes aos produtos? É igual a vida útil do produto?');
    //Questão 74
    questoes.add('74 - Os demais registros são armazenados por quanto tempo? ');
    //Questão 75
    questoes.add('75 - Existe controle dos registros eletrônicos ?');
    //Questão 76
    questoes.add('76 - Existe backup para esses registros? Qual a rotina?');
    //Questão 77
    questoes.add('77 - Existem registros confidenciais? ');
    //Questão 78
    questoes.add('78 - As inspeções estão mantidas, estão sendo executadas as inspeções?');
    //Questão 79
    questoes.add('79 - São mantidos registros?');
    //Questão 80
    questoes.add('80 - Os registros apresentam os critérios de aceitação, os resultados, o equipamento/instrumento usado e data e assinatura manual ou eletrônica do responsável?');
    //Questão 81
    questoes.add('81 - As instalações da empresa são adequadas para o negócio fim da organização?');
    //Questão 82 
    questoes.add('82 - A empresa estabeleceu os devidos controles ambientais para seu processo?');
    //Questão 83
    questoes.add('83 - Existe procedimento para tal?');
    //Questão 84
    questoes.add('84 - O controle ambiental está em vigor? Existem registros?');
    //Questão 85
    questoes.add('85 - Os responsáveis pela execução das atividades de controle ambiental e... ?');
    //Questão 86
    questoes.add('86 - São abertas ações corretivas para os desvios verificados o control ...?');
    //Questão 87
    questoes.add('87 - Existe procedimento, instrução ou equivalente de limpeza?');
    //Questão 88
    questoes.add('88 - Existe uma programação de limpeza?');
    //Questão 89
    questoes.add('89 - Existe evidência que a programação está em vigor?');
    //Questão 90
    questoes.add('90 - Os produtos utilizados na limpeza são registrados o Ministério da Saúde?');
    //Questão 91
    questoes.add('91 - Os ambientes apresentam-se limpos para os fins da organização?');
    //Questão 92
    questoes.add('92 - O pessoal utiliza uniformes e calçados adequados à tarefa realizada?');
    //Questão 93
    questoes.add('93 - O pessoal foi treinado sobre o uso dos EPIs?');
    //Questão 94
    questoes.add('94 - Existem placas sinalizadoras?');
    //Questão 95
    questoes.add('95 - Existem evidências de que os empregados não comem, não bebem e não fumam nas áreas onde podem afetar o produto?');
    //Questão 96
    questoes.add('96 - Os funcionários foram treinados?');
    //Questão 97
    questoes.add('97 - Existem placas sinalizadoras?');
    //Questão 98
    questoes.add('98 - Quais cuidados foram estabelecidos para evitar a contaminação de equipamentos, componentes, materiais de fabricação, produtos e acabados por materiais de limpeza e desinfecção pelo processo de fabricação?');
    //Questão 99
    questoes.add('99 - A empresa gera algum resíduo químico em seu processo?');
    //Questão 100
    questoes.add('100 - Se sim para a questão anterior, quais os cuidados são tomados?');
    //Questão 101
    questoes.add('101 - Se sim para a questão anterior, existe Programa de Gerenciamento de Resíduos em Serviço de Saúde(PGRSS)?');
    //Questão 102 
    questoes.add('102 - A empresa gera algum resíduo biológico ou seu processo apresenta algum risco biológico?');
    //Questão 103
    questoes.add('103 - Se sim para a questão anterior, quais os cuidados são tomados?');
    //Questão 104
    questoes.add('104 - Se sim para a questão anterior, existe Programa de Gerenciamento de Resíduos em Serviço de Saúde (PGRSS)?');
    //Questão 105
    questoes.add('105 - Existe PGR e PCMSO na empresa?');
    //Questão 106
    questoes.add('106 - São disponibilizados os EPIs aos funcionários?');
    //Questão 107
    questoes.add('107 - Foram ministrados os treinamentos previsto no PGR?');
    //Questão 108
    questoes.add('108 - Há um programa documentado de limpeza e manutenção de máquinas e equipamentos?');
    //Questão 109
    questoes.add('109 - O programa está em vigor? Existes os devidos registros?');
    //Questão 110
    questoes.add('110 - Selecione aleatoriamente uma máquina e verifique todas as manutenções (preventivas e corretivas) pelas quais ela passou. Verifique quem realizou a três últimas manutenções e se tem competência comprovada.');
    //Questão 111
    questoes.add('111 - Há procedimentos para inspeção e, quando aplicável, testes de componentes e materiais de fabricação recebidos, para assegurar que os requisitos especificados foram atendidos?');
    //Questão 112
    questoes.add('112 - Os produtos ficam em área específica aguardando a inspeção antes da entrada dos mesmos?');
    //Questão 113
    questoes.add('113 - Existem relatórios de inspeção comprovando que os componentes e materiais de fabricação recebidos foram inspecionados antes de serem transferidos para a produção e estão conforme as especificações?');
    //Questão 114
    questoes.add('114 - Como é feita a inspeção? Quem faz?');
    //Questão 115
    questoes.add('115 - Quais os critérios para aprovação?');
    //Questão 116
    questoes.add('116 - É utilizado plano de amostragem para inspeção de recebimento?');
    //Questão 117
    questoes.add('117 - Existe em programa documentado para calibração e aferição de instrumentos?');
    //Questão 118
    questoes.add('118 - Os instrumentos de inspeção, medição e testes estão identificados indicando se estão aferidos ou calibrados?');
    //Questão 119
    questoes.add('119 - Há procedimentos para garantir que instrumentos não calibrados ou aferidos não sejam instalados e usados?');
    //Questão 120
    questoes.add('120 - A empresa protege corretamente suas instalações para evitar que os instrumentos de medição não sejam danificados de forma intencional ou não intencional?');
    //Questão 121
    questoes.add('121 - Os instrumentos de medição são corretamente mantidos?');
    //Questão 122
    questoes.add('122 - Caso não existam padrões nacionais a aferição e calibração são referidas a padrões próprios, confiáveis e reproduzíveis?');
    //Questão 123
    questoes.add('123 - Há registros que comprovem a confiabilidade desses padrões?');
    //Questão 124
    questoes.add('124 - A empresa estabeleceu procedimento para controle de mudança?');
    //Questão 125
    questoes.add('125 - O procedimento prevê as atividades de solicitação, análise crítica, implementação e avaliação após a implementação da mudança?');
    //Questão 126
    questoes.add('126 - As mudanças são registradas?');
    //Questão 127
    questoes.add('127 - A empresa mantém procedimentos para o manuseio de produtos acabados?');
    //Questão 128...? 
    questoes.add('128 - O procedimento assegura que quando a qualidade ou a condição de adequado ao uso de um componente, material de fabricação, produto intermediário ou produto acabado se deteriorar ao longo do tempo, os mesmos não sejam utilizados ou distribuídos?');
    //Questão 129
    questoes.add('129 - Os produtos acabados são armazenados conforme estabelecido nos procedimentos?');
    //Questão 130
    questoes.add('130 - O armazenamento obedece ao empilhamento máximo constante nas embalagens?');
    //Questão 131
    questoes.add('131 - O armazenamento obedece aos requisitos de temperatura e umidade constante nas embalagens e nas especificações dos fornecedores?');
    //Questão 132
    questoes.add('132 - Os produtos são armazenados afastados de parede, teto e qualquer outra superfície que possa danificá-lo?');
    //Questão 133
    questoes.add('133 - Os produtos são armazenados (temporária ou permanentemente) no chão?');
    //Questão 134
    questoes.add('134 - A área de armazenamento apresenta condições adequadas de higiene e limpeza de modo a evitar danos e contaminações no produto acabado?');
    //Questão 135
    questoes.add('135 - A sala apresenta mofo? Umidade? Sujeira?');
    //Questão 136
    questoes.add('136 - Os produtos distribuídos ao mercado são registrados de forma a identificar-se o nome e o endereço do consignatário, as quantidades distribuídas e o número de controle ou número do lote ou partida de fabricação que permita sua rastreabilidade?');
    //Questão 137
    questoes.add('137 - Existe procedimento de identificação e rastreabilidade de materiais, componentes e/ou produtos acabados?');
    //Questão 138
    questoes.add('138 - A rastreabilidade é baseada em número de lotes ou de série?');
    //Questão 139
    questoes.add('139 - A rastreabilidade envolve todo o processo da empresa?');
    //Questão 140
    questoes.add('140 - Existem procedimentos que assegurem que componentes, materiais de fabricação, produtos acabados ou devolvidos, não-conformes com as especificações não sejam utilizados?');
    //Questão 141
    questoes.add('141 - Os materiais de fabricação, os componentes, os produtos acabados ou devolvidos não-conformes são claramente identificados e segregados?');
    //Questão 142
    questoes.add('142 - Como são identificados? Área? Marcadores? Paletes? Containers?');
    //Questão 143
    questoes.add('143 - Existem responsáveis designados para decidir pela segregação e liberação destes materiais, componentes, produtos acabados ou devolvidos?');
    //Questão 144
    questoes.add('144 - Quem é o responsável? Onde está designado? O que é feito para liberar? Como é registrado a liberação?');
    //Questão 145
    questoes.add('145 - Existe rotina de reprocessamento de produtos?');
    //Questão 146
    questoes.add('146 - Se sim para a questão anterior, quem avalia a possibilidade de reprocessamento?');
    //Questão 147
    questoes.add('147 - Como é registrada a avaliação?');
    //Questão 148
    questoes.add('148 - Como são identificados os produtos em reprocessamento?');
    //Questão 149
    questoes.add('149 - Os produtos em reprocessamento ficam sujeitos a total inspeção?');
    //Questão 150
    questoes.add('150 - Existe procedimento para investigar as causas de não conformidades ou não conformidade potencial do sistema de qualidade?');
    //Questão 151
    questoes.add('151 - Como são investigados os problemas? É utilizado lgum método ?');
    //Questão 152
    questoes.add('151 - Como são investigados os problemas? É utilizado algum método (Ishikawa, 5 Porquês, 6M, Brainstorming, outros?');
    //Questão 153
    questoes.add('153 - É avaliada a eficácia das ações tomadas?');
    //Questão 154
    questoes.add('154 - A responsabilidade e a autoridade para decidir sobre avaliação, implementação e monitoração das ações corretivas aprovadas estão claramente definidas?');
    //Questão 155
    questoes.add('155 - Quem é o responsável? Onde está designado');
    //Questão 156
    questoes.add('156 - Há procedimentos para gerenciamento das reclamações dos clientes?');
    //Questão 157
    questoes.add('157 - As reclamações são registradas conforme os requisitos das boas práticas de fabricação para produtos médicos?');
    //Questão 158
    questoes.add('158 - Quando aplicável as reclamações dos clientes são examinadas, investigadas e ações corretivas são tomadas para prevenir repetição da ocorrência?');
    //Questão 159
    questoes.add('159 - Quem recebe a reclamação? Como é registrada a reclamação?');
    //Questão 160
    questoes.add('160 - As investigações são documentadas?');
    //Questão 161
    questoes.add('161 - Como são investigadas?');
    //Questão 162
    questoes.add('162 - A autoridade sanitária é cientificada caso a reclamação seja referente a óbito, lesão ou doença grave envolvida?' );
    //Questão 163
    questoes.add('163 - Existem registros de que as ações corretivas aprovadas, decorrentes de reclamações, foram implementadas?');
    //Questão 164
    questoes.add('164 - A empresa tem procedimentos de auditorias internas para verificar se o sistema de qualidade está conforme os requisitos estabelecidos nas boas práticas de fabricação de produtos médicos?');
    //Questão 165
    questoes.add('165 - Existem registros de treinamento dos auditores internos do sistema ...?');
    //Questão 166
    questoes.add('166 - Quando foi o treinamento?');
    //Questão 167
    questoes.add('167 - Quem ou que empresa ofereceu?');
    //Questão 168
    questoes.add('168 - Os auditores têm consciência da importância de seu papel no processo de melhoria continua da organização?');
    //Questão 169
    questoes.add('169 - Existem relatórios de auditoria interna da qualidade indicando as não-conformidades encontradas?');
    //Questão 170
    questoes.add('170 - O relatório está assinado pelo responsável pela área auditada?');
    //Questão 171
    questoes.add('171 - O pessoal que executa as auditorias internas da qualidade é independente das áreas auditadas?');
    //Questão 172
    questoes.add('172 - Não pertencem a mesma área?');
    //Questão 173
    questoes.add('173 - Não são parentes? Namorados ou algo parecido?');
    //Questão 174
    questoes.add('174 - Existem registros da implementação das ações corretivas recomendadas nos relatórios de auditoria interna?');
    //Questão 175
    questoes.add('175 - Foram abertas ações corretivas para todas as não conformidades identificadas na auditoria?');
    //Questão 176
    questoes.add('176 - As ações corretivas foram tratadas corretamente conforme procedimento de ação corretiva? (7.1)');
    //Questão 177
    questoes.add('177 - Quando aplicável, existe procedimento de instalação de produtos?');
    //Questão 178
    questoes.add('178 - A instalação é documentada?');
    //Questão 179
    questoes.add('179 - Quando aplicável, existe procedimento de assistência técnica de produtos?');
    //Questão 180
    questoes.add('180 - A assistência técnica é registrada?');
    //Questão 181
    questoes.add('181 - No registro da assistência técnica constam pelo menos os dados abaixo?');
    //Questão 182
    questoes.add('182 - Existe comprovação da competência dos técnicos envolvidos com o proce?');
    
    //Questão 183
    questoes.add('183 - Os registros de assistência são analisados periodicamente para verificar a necessidade de ações corretivas, preventivas ou outras ações?');
    //Questão 184
    questoes.add('184 - Os planos de amostragem adotados pelo fabricante estão formalizados por escrito?');
    //Questão 185
    questoes.add('185 - Em que fases do processo são utilizados os planos de amostragem?');
    //Questão 186
    questoes.add('186 - Existem procedimentos para revisão periódica dos planos de amostragem visando verificar a adequação da técnica estatística ao resultado pretendido? Conforme procedimento de controle de documentos?');
    //Questão 187
    questoes.add('187 - Existe pessoal designado qualificado para realizar esta revisão e propor técnicas estatísticas adequadas?');
    //Questão 189
    questoes.add('188 -Como são controlados os indicadores e os objetivos da qualidade da empresa?');
    //Questão 189
    questoes.add('189 – EXISTE PENDÊNCIA DE DOCUMENTAÇÃO DE DEMONSTRAÇÃO NO SISTEMA?');
    //Questão 190
    questoes.add('190 – ABRIR ALEATORIAMENTE UM CONTRATO DE LOCAÇÃO NO SISTEMA E VERIFICAR ASSINATURAS');
    //Questão 191
    questoes.add('191 – ABRIR ALEATORIAMENTE UMA OT DE DEMONSTRAÇÃO E VERIFICAR OS ANEXOS');
    //Questão 192
    questoes.add('192 – ESTÃO ANEXADOS CONTRATO, CHECKLIST, REGISTRO, NOTA FISCAL E LISTA DE PRESENÇA?');
    //Questão 193
    questoes.add('193 – EXISTEM PRODUTOS HIGIENIZADOS SEM A DEVIDA ETIQUETA COM DATA E ASSINATURA DE HIGIENIZAÇÃO E VERIFICAÇÃO?');
    //Questão 194
    //questoes.add('188 -Como são controlados os indicadores e os objetivos da qualidade da empresa?');
    
    
    
    
    
    Nao_Conformidade__c nc = new Nao_Conformidade__c();
    
    Boolean falso = false; 
    //N_o_conformidade__c   
    
    for(Auditoria__c rs : Trigger.new){
        
        String id = rs.id;
        if( (Trigger.isAfter && Trigger.isUpdate) && rs.Status__c == 'CONCLUIDO'){
            
            //------------   não conformidade  1  --------------------
            if(rs.x1__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c ='01 - Existe uma política da qualidade na empresa?';
                nc.Auditoria__c = id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                nc.tipo__c = 'Estrutural';
                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            //------------   não conformidade  2  --------------------
            if(rs.x2__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c ='02 - Existe uma política da qualidade na empresa?';
                nc.Auditoria__c = id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                nc.tipo__c = 'Documental';
                
                nc.RecordtypeId = '012U4000000uiPlIAI';
                
                insert nc;
            }
            //------------   não conformidade  3  --------------------
            if(rs.x3__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = '03 - A política da qualidade está descrita no manual da Qualidade?';
                nc.Auditoria__c = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                nc.tipo__c = 'Documental';

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            //------------   não conformidade  4  --------------------
            if(rs.x4__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = '04 - Os objetivos estabelecidos pela empresa são coerentes com a política d... ?';
                nc.Auditoria__c = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                nc.tipo__c = 'Processo';

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            //------------   não conformidade  5  --------------------
            if(rs.x5__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = '05 - Os objetivos estabelecidos pela empresa são coerentes com a política d... ?';
                nc.Auditoria__c = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                nc.tipo__c = 'Processo';

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            //------------   não conformidade  6  --------------------
            if(rs.x6__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = '06 - Os funcionários foram informados sobre a política da qualidade? Como?';
                nc.Auditoria__c = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                nc.tipo__c = 'Processo';

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            //------------   não conformidade  7  --------------------
            if(rs.x7__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = '07 - Foi oferecido treinamento na política da qualidade para os funcionários?';
                nc.Auditoria__c = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                nc.tipo__c = 'Documental';

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            //------------   não conformidade  8  --------------------
            if(rs.x8__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c ='08 - Os treinamentos oferecidos tiveram sua eficácia avaliada?';
                nc.Auditoria__c = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                nc.tipo__c = 'Documental';

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            //------------   não conformidade  9  --------------------
            if(rs.x9__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c ='09 - A empresa possui um organograma estabelecido?';
                nc.Auditoria__c = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                nc.tipo__c = 'Documental';

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            //------------   não conformidade  10  --------------------
            if(rs.x10__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[10];
                nc.Auditoria__c        = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                nc.tipo__c = 'Processo';

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            //------------   não conformidade  11  --------------------
            if(rs.x11__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[11];
                nc.Auditoria__c        = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                nc.tipo__c = 'Processo';

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            //------------   não conformidade  12  --------------------
            if(rs.x12__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[12];
                nc.Auditoria__c        = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                nc.tipo__c = 'Documental';

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            //------------   não conformidade  13  --------------------
            if(rs.x13__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[13];
                nc.Auditoria__c        = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                nc.tipo__c = 'Processo';

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            //------------   não conformidade  14  --------------------
            if(rs.x14__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[14];
                nc.Auditoria__c        = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                nc.tipo__c = 'Processo';

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            //------------   não conformidade  15  --------------------
            if(rs.x15__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[15];
                nc.Auditoria__c        = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                nc.tipo__c = 'Processo';

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            
            //------------   não conformidade  16  --------------------
            if(rs.x16__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[16];
                nc.Auditoria__c        = rs.id;
                nc.tipo__c = 'Documental';
                nc.Data_de_Abertura_do_RNC__c = Date.today();

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            
            //------------   não conformidade  17  --------------------
            if(rs.x17__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[17];
                nc.Auditoria__c        = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                nc.tipo__c = 'Documental';

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            
            /*------------   não conformidade  18  --------------------
if(rs.x18__c == false){
Nao_Conformidade__c nc = new Nao_Conformidade__c();
nc.N_o_conformidade__c = questoes[18];
nc.Auditoria__c        = rs.id;
nc.Data_de_Abertura_do_RNC__c = Date.today();
insert nc;
}*/            
            
            //------------   não conformidade  19  --------------------
            if(rs.x19__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[19];
                nc.Auditoria__c        = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                nc.tipo__c = 'Documental';

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            
            //------------   não conformidade  20  --------------------
            if(rs.x20__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[20];
                nc.Auditoria__c        = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            
            //------------   não conformidade  21  --------------------
            if(rs.x21__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[21];
                nc.Auditoria__c        = rs.id;
                nc.tipo__c = 'Documental';
                nc.Data_de_Abertura_do_RNC__c = Date.today();

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            
            //------------   não conformidade  22  --------------------
            if(rs.x22__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[22];
                nc.Auditoria__c        = rs.id;
                nc.tipo__c = 'Documental';
                nc.Data_de_Abertura_do_RNC__c = Date.today();

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            
            //------------   não conformidade  23  --------------------
            if(rs.x23__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[23];
                nc.Auditoria__c        = rs.id;
                nc.tipo__c = 'Documental';
                nc.Data_de_Abertura_do_RNC__c = Date.today();

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            
            //------------   não conformidade  24  --------------------
            if(rs.x24__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[24];
                nc.Auditoria__c        = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            
            //------------   não conformidade  25  --------------------
            if(rs.x25__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[25];
                nc.Auditoria__c = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                nc.tipo__c = 'Documental';

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            
            //------------   não conformidade  26  --------------------
            if(rs.x26__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[26];
                nc.Auditoria__c        = rs.id;
                nc.tipo__c = 'Documental';
                nc.Data_de_Abertura_do_RNC__c = Date.today();

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            
            //------------   não conformidade  27  --------------------
            if(rs.x27__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[27];
                nc.Auditoria__c        = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                nc.tipo__c = 'Documental';

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            
            //------------   não conformidade  28  --------------------
            if(rs.x28__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[28];
                nc.Auditoria__c        = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                nc.tipo__c = 'Documental';

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            
            //------------   não conformidade  29  --------------------
            if(rs.x29__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[29];
                nc.Auditoria__c        = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                nc.tipo__c = 'Documental';

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            
            //------------   não conformidade  30  --------------------
            if(rs.x30__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[30];
                nc.Auditoria__c        = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                nc.tipo__c = 'Documental';

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            
            //------------   não conformidade  31  --------------------
            if(rs.x31__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[31];
                nc.Auditoria__c        = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                nc.tipo__c = 'Documental';
                

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            
            //------------   não conformidade  32  --------------------
            if(rs.x32__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[32];
                nc.Auditoria__c        = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                nc.tipo__c = 'Documental';

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            
            //------------   não conformidade  33  --------------------
            if(rs.x33__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[33];
                nc.Auditoria__c        = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                nc.tipo__c = 'Processo';

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            
            //------------   não conformidade  34  --------------------
            if(rs.x34__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[34];
                nc.Auditoria__c        = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                nc.tipo__c = 'Processo';

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            
            //------------   não conformidade  35  --------------------
            if(rs.x35__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[35];
                nc.Auditoria__c        = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                nc.tipo__c = 'Documental';

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            
            //------------   não conformidade  36  --------------------
            if(rs.x36__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[36];
                nc.Auditoria__c        = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                nc.tipo__c = 'Documental';

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            
            //------------   não conformidade  37  --------------------
            if(rs.x37__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[37];
                nc.Auditoria__c        = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                nc.tipo__c = 'Processo';

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            
            //------------   não conformidade  38  --------------------
            if(rs.x38__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[38];
                nc.Auditoria__c        = rs.id;
                nc.tipo__c = 'Documental';
                nc.Data_de_Abertura_do_RNC__c = Date.today();

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            
            //------------   não conformidade  39  --------------------
            if(rs.x39__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[39];
                nc.Auditoria__c        = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                nc.tipo__c = 'Processo';

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            
            //------------   não conformidade  40  --------------------
            if(rs.x40__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[40];
                nc.Auditoria__c        = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                nc.tipo__c = 'Documental';

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            
            //------------   não conformidade  41  --------------------
            if(rs.x41__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[41];
                nc.Auditoria__c        = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                nc.tipo__c = 'Documental';

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            
            //------------   não conformidade  42  --------------------
            if(rs.x42__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[42];
                nc.Auditoria__c        = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                nc.tipo__c = 'Documental';

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            
            //------------   não conformidade  43  --------------------
            if(rs.x43__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[43];
                nc.Auditoria__c        = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                nc.tipo__c = 'Documental';

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            
            //------------   não conformidade  44  --------------------
            if(rs.x44__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[44];
                nc.Auditoria__c        = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                nc.tipo__c = 'Documental';

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            
            //------------   não conformidade  45  --------------------
            if(rs.x45__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[45];
                nc.Auditoria__c = rs.id;
                nc.tipo__c = 'Documental';
                nc.Data_de_Abertura_do_RNC__c = Date.today();

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            
            //------------   não conformidade  46  --------------------
            if(rs.x46__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[46];
                nc.Auditoria__c        = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                nc.tipo__c = 'Documental';

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            
            //------------   não conformidade  47  --------------------
            if(rs.x47__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[47];
                nc.Auditoria__c        = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                nc.tipo__c = 'Documental';

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            
            //------------   não conformidade  48  --------------------
            if(rs.x48__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[48];
                nc.Auditoria__c        = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                nc.tipo__c = 'Documental';

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            
            //------------   não conformidade  49  --------------------
            if(rs.x49__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[49];
                nc.Auditoria__c        = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                nc.tipo__c = 'Documental';

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            
            //------------   não conformidade  50  --------------------
            if(rs.x50__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[50];
                nc.Auditoria__c        = rs.id;
                nc.tipo__c = 'Documental';
                nc.Data_de_Abertura_do_RNC__c = Date.today();

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            
            //------------   não conformidade  51  --------------------
            if(rs.x51__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[51];
                nc.Auditoria__c        = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                nc.tipo__c = 'Documental';

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            
            //------------   não conformidade  52  --------------------
            if(rs.x52__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[52];
                nc.Auditoria__c        = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                nc.tipo__c = 'Documental';

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            
            //------------   não conformidade  53  --------------------
            if(rs.x53__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[53];
                nc.Auditoria__c        = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                nc.tipo__c = 'Documental';

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            
            //------------   não conformidade  54  --------------------
            if(rs.x54__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[54];
                nc.Auditoria__c        = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                
                nc.tipo__c = 'Documental';

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            
            //------------   não conformidade  55  --------------------
            if(rs.x55__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[55];
                nc.Auditoria__c        = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                nc.tipo__c = 'Documental';

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            
            //------------   não conformidade  56  --------------------
            if(rs.x56__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[56];
                nc.Auditoria__c        = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                nc.tipo__c = 'Documental';

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            
            //------------   não conformidade  57  --------------------
            if(rs.x57__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[57];
                nc.Auditoria__c        = rs.id;
                
                nc.tipo__c = 'Documental';
                nc.Data_de_Abertura_do_RNC__c = Date.today();

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            
            //------------   não conformidade  58  --------------------
            if(rs.x58__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[58];
                nc.Auditoria__c        = rs.id;
                
                nc.tipo__c = 'Documental';
                nc.Data_de_Abertura_do_RNC__c = Date.today();

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            
            //------------   não conformidade  59  --------------------
            if(rs.x59__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[59];
                nc.Auditoria__c        = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                nc.tipo__c = 'Processo';

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            
            //------------   não conformidade  60  --------------------
            if(rs.x60__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[60];
                nc.Auditoria__c        = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                nc.tipo__c = 'Processo';

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            
            //------------   não conformidade  61  --------------------
            if(rs.x61__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[61];
                nc.Auditoria__c        = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                nc.tipo__c = 'Documental';

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            
            //------------   não conformidade  62  --------------------
            if(rs.x62__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[62];
                nc.Auditoria__c        = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                nc.tipo__c = 'Documental';

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            
            //------------   não conformidade  63  --------------------
            if(rs.x63__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[63];
                nc.Auditoria__c        = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                nc.tipo__c = 'Documental';

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            
            //------------   não conformidade  64  --------------------
            if(rs.x64__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[64];
                nc.Auditoria__c        = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                nc.tipo__c = 'Documental';

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            
            //------------   não conformidade  65  --------------------
            if(rs.x65__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[65];
                nc.Auditoria__c        = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                nc.tipo__c = 'Processo';

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            
            //------------   não conformidade  66  --------------------
            if(rs.x66__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[66];
                nc.Auditoria__c        = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                nc.tipo__c = 'Processo';

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            //------------   não conformidade  67  --------------------
            if(rs.x67__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[67];
                nc.Auditoria__c       = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                
                nc.tipo__c = 'Documental';

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            //------------   não conformidade  68  --------------------
            if(rs.x68__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[68];
                nc.Auditoria__c       = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                nc.tipo__c = 'Documental';

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            //------------   não conformidade  69  --------------------
            if(rs.x69__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[69];
                nc.Auditoria__c       = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                nc.tipo__c = 'Documental';

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            //------------   não conformidade  70  --------------------
            if(rs.x70__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[70];
                nc.Auditoria__c       = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                nc.tipo__c = 'Processo';

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            //------------   não conformidade  71  --------------------
            if(rs.x71__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[71];
                nc.Auditoria__c       = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                nc.tipo__c = 'Documental';

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            //------------   não conformidade  72  --------------------
            if(rs.x72__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[72];
                nc.Auditoria__c       = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                nc.tipo__c = 'Processo';

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            //------------   não conformidade  73  --------------------
            if(rs.x73__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[73];
                nc.Auditoria__c       = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                nc.tipo__c = 'Documental';

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            //------------   não conformidade  74  --------------------
            if(rs.x74__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[74];
                nc.Auditoria__c       = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                nc.tipo__c = 'Processo';

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            //------------   não conformidade  75  --------------------
            if(rs.x75__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[75];
                nc.Auditoria__c       = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                nc.tipo__c = 'Documental';

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            //------------   não conformidade  76  --------------------
            if(rs.x76__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[76];
                nc.Auditoria__c       = rs.id;
                
                nc.tipo__c = 'Processo';
                nc.Data_de_Abertura_do_RNC__c = Date.today();

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            //------------   não conformidade  77  --------------------
            if(rs.x77__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[77];
                nc.Auditoria__c       = rs.id;
                nc.tipo__c = 'Documental';
                nc.Data_de_Abertura_do_RNC__c = Date.today();

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            //------------   não conformidade  78  --------------------
            if(rs.x78__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[78];
                nc.Auditoria__c       = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                nc.tipo__c = 'Processo';

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            //------------   não conformidade  79  --------------------
            if(rs.x79__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[79];
                nc.Auditoria__c       = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                nc.tipo__c = 'Documental';

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            //------------   não conformidade  80  --------------------
            if(rs.x80__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[80];
                nc.Auditoria__c       = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                nc.tipo__c = 'Documental';

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            //------------   não conformidade  81  --------------------
            if(rs.x81__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[81];
                nc.Auditoria__c       = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                nc.tipo__c = 'Estrutural';

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            //------------   não conformidade  82  --------------------
            if(rs.x82__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[82];
                nc.Auditoria__c       = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                
                nc.tipo__c = 'Processo';

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            //------------   não conformidade  83  --------------------
            if(rs.x83__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[83];
                nc.Auditoria__c       = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                nc.tipo__c = 'Documental';

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            //------------   não conformidade  84  --------------------
            if(rs.x84__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[84];
                nc.Auditoria__c       = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                nc.tipo__c = 'Documental';

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            //------------   não conformidade  85  --------------------
            if(rs.x85__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[85];
                nc.Auditoria__c       = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                nc.tipo__c = 'Documental';

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            
            //------------   não conformidade  86  --------------------
            if(rs.x86__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[86];
                nc.Auditoria__c       = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                nc.tipo__c = 'Documental';

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            //------------   não conformidade  87  --------------------
            if(rs.x87__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[87];
                nc.Auditoria__c       = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                nc.tipo__c = 'Documental';

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            //------------   não conformidade  88  --------------------
            if(rs.x88__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[88];
                nc.Auditoria__c       = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                nc.tipo__c = 'Documental';

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            //------------   não conformidade  89  --------------------
            if(rs.x89__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[89];
                nc.Auditoria__c       = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                nc.tipo__c = 'Documental';

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            //------------   não conformidade  90  --------------------
            if(rs.x90__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[90];
                nc.Auditoria__c       = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                nc.tipo__c = 'Documental';

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            //------------   não conformidade  91  --------------------
            if(rs.x91__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[91];
                nc.Auditoria__c       = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                nc.tipo__c = 'Estrutural';

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            //------------   não conformidade  92  --------------------
            if(rs.x92__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[92];
                nc.Auditoria__c       = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                
                nc.tipo__c = 'Processo';

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            //------------   não conformidade  93  --------------------
            if(rs.x93__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[93];
                nc.Auditoria__c       = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                
                nc.tipo__c = 'Documental';

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            //------------   não conformidade  94  --------------------
            if(rs.x94__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[94];
                nc.Auditoria__c       = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                nc.tipo__c = 'Estrutural';

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            //------------   não conformidade  95  --------------------
            if(rs.x95__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[95];
                nc.Auditoria__c       = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                nc.tipo__c = 'Estrutural';

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            //------------   não conformidade  96  --------------------
            if(rs.x96__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[96];
                nc.Auditoria__c       = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                nc.tipo__c = 'Documental';

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            
            
            //------------   não conformidade  97  --------------------
            if(rs.x97__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[97];
                nc.Auditoria__c       = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                nc.tipo__c = 'Estrutural';

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            //------------   não conformidade  98  --------------------
            if(rs.x98__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[98];
                nc.Auditoria__c       = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                nc.tipo__c = 'Documental';

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            //------------   não conformidade  99  --------------------
            if(rs.x99__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[99];
                nc.Auditoria__c       = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                
                nc.tipo__c = 'Processo';

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            //------------   não conformidade  100  --------------------        
            if(rs.x100__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[100];
                nc.Auditoria__c       = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                
                nc.tipo__c = 'Processo';

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            //------------   não conformidade  101  --------------------        
            if(rs.x101__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[101];
                nc.Auditoria__c       = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                nc.tipo__c = 'Documental';

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            //------------   não conformidade  102  --------------------        
            if(rs.x102__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[102];
                nc.Auditoria__c       = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            //------------   não conformidade  103  --------------------        
            if(rs.x103__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[103];
                nc.Auditoria__c       = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                
                nc.tipo__c = 'Processo';

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            //------------   não conformidade  104  --------------------        
            if(rs.x104__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[104];
                nc.Auditoria__c       = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                nc.tipo__c = 'Documental';

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            //------------   não conformidade  105  --------------------        
            if(rs.x105__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[105];
                nc.Auditoria__c       = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                nc.tipo__c = 'Documental';

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            //------------   não conformidade  106  --------------------        
            if(rs.x106__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[106];
                nc.Auditoria__c       = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                nc.tipo__c = 'Estrutural';

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            //------------   não conformidade  107  --------------------        
            if(rs.x107__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[107];
                nc.Auditoria__c       = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                nc.tipo__c = 'Documental';

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            //------------   não conformidade  108  --------------------        
            if(rs.x108__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[108];
                nc.Auditoria__c       = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                nc.tipo__c = 'Documental';

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            //------------   não conformidade  109  --------------------        
            if(rs.x109__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[109];
                nc.Auditoria__c       = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                nc.tipo__c = 'Documental';

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            //------------   não conformidade  110  --------------------        
            if(rs.x110__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[110];
                nc.Auditoria__c       = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                nc.tipo__c = 'Documental';

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            //------------   não conformidade  111  --------------------        
            if(rs.x111__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[111];
                nc.Auditoria__c       = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                nc.tipo__c = 'Documental';

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            //------------   não conformidade  112  --------------------        
            if(rs.x112__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[112];
                nc.Auditoria__c       = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                nc.tipo__c = 'Estrutural';

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            //------------   não conformidade  113  --------------------        
            if(rs.x113__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[113];
                nc.Auditoria__c       = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                nc.tipo__c = 'Documental';

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            //------------   não conformidade  114  --------------------        
            if(rs.x114__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[114];
                nc.Auditoria__c       = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                
                nc.tipo__c = 'Processo';

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            //------------   não conformidade  115  --------------------        
            if(rs.x115__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[115];
                nc.Auditoria__c       = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                nc.tipo__c = 'Documental';

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            //------------   não conformidade  116  --------------------        
            if(rs.x116__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[116];
                nc.Auditoria__c       = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            //------------   não conformidade  117  --------------------        
            if(rs.x117__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[117];
                nc.Auditoria__c       = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                nc.tipo__c = 'Documental';

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            //------------   não conformidade  118  --------------------        
            if(rs.x118__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[118];
                nc.Auditoria__c       = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                nc.tipo__c = 'Documental';

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            //------------   não conformidade  119  --------------------        
            if(rs.x119__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[119];
                nc.Auditoria__c       = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                nc.tipo__c = 'Documental';

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            //------------   não conformidade  120  --------------------        
            if(rs.x120__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[120];
                nc.Auditoria__c       = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                nc.tipo__c = 'Estrutural';

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            //------------   não conformidade  121  --------------------        
            if(rs.x121__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[121];
                nc.Auditoria__c       = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                nc.tipo__c = 'Estrutural';

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            //------------   não conformidade  122  --------------------        
            if(rs.x122__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[122];
                nc.Auditoria__c       = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                
                nc.tipo__c = 'Processo';

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            //------------   não conformidade  123  --------------------        
            if(rs.x123__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[123];
                nc.Auditoria__c       = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                nc.tipo__c = 'Documental';

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            //------------   não conformidade  124  --------------------        
            if(rs.x124__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[124];
                nc.Auditoria__c       = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                nc.tipo__c = 'Documental';

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            //------------   não conformidade  125  --------------------        
            if(rs.x125__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[125];
                nc.Auditoria__c       = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                nc.tipo__c = 'Documental';

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            //------------   não conformidade  126  --------------------        
            if(rs.x126__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[126];
                nc.Auditoria__c       = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                nc.tipo__c = 'Documental';

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            //------------   não conformidade  127  --------------------        
            if(rs.x127__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[127];
                nc.Auditoria__c       = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                nc.tipo__c = 'Documental';

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            //------------   não conformidade  128  --------------------        
            if(rs.x128__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[128];
                nc.Auditoria__c       = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                nc.tipo__c = 'Documental';

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            //------------   não conformidade  129  --------------------        
            if(rs.x129__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[129];
                nc.Auditoria__c       = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                
                nc.tipo__c = 'Estrutural';

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            //------------   não conformidade  130  --------------------
            if(rs.x130__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[130];
                nc.Auditoria__c       = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                nc.tipo__c = 'Estrutural';

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            //------------   não conformidade  131  --------------------        
            if(rs.x131__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[131];
                nc.Auditoria__c       = rs.id;
                nc.tipo__c = 'Estrutural';
                nc.Data_de_Abertura_do_RNC__c = Date.today();

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            //------------   não conformidade  132  --------------------        
            if(rs.x132__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[132];
                nc.Auditoria__c       = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                nc.tipo__c = 'Documental';

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            //------------   não conformidade  133  --------------------        
            if(rs.x133__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[133];
                nc.Auditoria__c       = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                nc.tipo__c = 'Documental';
                

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            //------------   não conformidade  134  --------------------        
            if(rs.x134__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[134];
                nc.Auditoria__c       = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                
                
                nc.tipo__c = 'Processo';

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            //------------   não conformidade  135  --------------------        
            if(rs.x135__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[135];
                nc.Auditoria__c       = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                
                nc.tipo__c = 'Documental';

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            //------------   não conformidade  136  --------------------        
            if(rs.x136__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[136];
                nc.Auditoria__c       = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                
                nc.tipo__c = 'Estrutural';

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            //------------   não conformidade  137  --------------------        
            if(rs.x137__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[137];
                nc.Auditoria__c       = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                
                nc.tipo__c = 'Estrutural';

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            //------------   não conformidade  138  --------------------        
            if(rs.x138__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[138];
                nc.Auditoria__c       = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                
                
                nc.tipo__c = 'Processo';

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            //------------   não conformidade  139  --------------------        
            if(rs.x139__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[139];
                nc.Auditoria__c       = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                
                nc.tipo__c = 'Documental';

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            //------------   não conformidade  140  --------------------        
            if(rs.x140__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[140];
                nc.Auditoria__c       = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                
                nc.tipo__c = 'Documental';

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            //------------   não conformidade  141  --------------------        
            if(rs.x141__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[141];
                nc.Auditoria__c       = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                
                nc.tipo__c = 'Processo';

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            //------------   não conformidade  142  --------------------        
            if(rs.x142__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[142];
                nc.Auditoria__c       = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                nc.tipo__c = 'Documental';

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            //------------   não conformidade  143  --------------------        
            if(rs.x143__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[143];
                nc.Auditoria__c       = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                nc.tipo__c = 'Estrutural';

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            //------------   não conformidade  144  --------------------        
            if(rs.x144__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[144];
                nc.Auditoria__c       = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                nc.tipo__c = 'Estrutural';

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            //------------   não conformidade  145  --------------------        
            if(rs.x145__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[145];
                nc.Auditoria__c       = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                nc.tipo__c = 'Documental';

                nc.RecordtypeId = '012U4000000uiPlIAI';
                insert nc;
            }
            
            String a1 = '1';
            String a2 = '2';
            String a3 = '3';
            String a4 = '4';
            String a5 = '5';
            String a6 = '6';
            String a7 = '7';
            String a8 = '8';
            String a9 = '9';
            String a10 = '10';
            String a11 = '11';
            String a12 = '12';
            String a13 = '13';
            String a14 = '14';
            String a15 = '15';
            String a16 = '16';
            String a17 = '17';
            String a18 = '18';
            String a19 = '19';
            String a20 = '20';
            String a21 = '21';
            String a22 = '22';
            String a23 = '23';
            String a24 = '24';
            String a25 = '25';
            String a26 = '26';
            String a27 = '27';
            String a28 = '28';
            String a29 = '29';
            String a30 = '30';
            String a31 = '31';
            String a32 = '32';
            String a33 = '33';
            String a34 = '34';
            String a35 = '35';
            String a36 = '36';
            String a37 = '37';
            String a38 = '38';
            String a39 = '39';
            String a40 = '40';
            String a41 = '41';
            String a42 = '42';
            String a43 = '43';
            String a44 = '44';
            String a45 = '45';
            String a46 = '46';
            String a47 = '47';
            String a48 = '48';
            String a49 = '49';
            String a50 = '50';
            String a51 = '51';
            String a52 = '52';
            String a53 = '53';
            String a54 = '54';
            String a55 = '55';
            String a56 = '56';
            String a57 = '57';
            String a58 = '58';
            String a59 = '59';
            String a60 = '60';
            String a61 = '61';
            String a62 = '62';
            String a63 = '63';
            String a64 = '64';
            String a65 = '65';
            String a66 = '66';
            String a67 = '67';
            String a68 = '68';
            String a69 = '69';
            String a70 = '70';
            String a71 = '71';
            String a72 = '72';
            String a73 = '73';
            String a74 = '74';
            String a75 = '75';
            String a76 = '76';
            String a77 = '77';
            String a78 = '78';
            String a79 = '79';
            String a80 = '80';
            String a81 = '81';
            String a82 = '82';
            String a83 = '83';
            String a84 = '84';
            String a85 = '85';
            String a86 = '86';
            String a87 = '87';
            String a88 = '88';
            String a89 = '89';
            String a90 = '90';
            String a91 = '91';
            String a92 = '92';
            String a93 = '93';
            String a94 = '94';
            String a95 = '95';
            String a96 = '96';
            String a97 = '97';
            String a98 = '98';
            String a99 = '99';
            String a100 = '100';
            String a101 = '101';
            String a102 = '102';
            String a103 = '103';
            String a104 = '104';
            String a105 = '105';
            String a106 = '106';
            String a107 = '107';
            String a108 = '108';
            String a109 = '109';
            String a110 = '110';
            String a111 = '111';
            String a112 = '112';
            String a113 = '113';
            String a114 = '114';
            String a115 = '115';
            String a116 = '116';
            String a117 = '117';
            String a118 = '118';
            String a119 = '119';
            String a120 = '120';
            String a121 = '121';
            String a122 = '122';
            String a123 = '123';
            String a124 = '124';
            String a125 = '125';
            String a126 = '126';
            String a127 = '127';
            String a128 = '128';
            String a129 = '129';
            String a130 = '130';
            String a131 = '131';
            String a132 = '132';
            String a133 = '133';
            String a134 = '134';
            String a135 = '135';
            String a136 = '136';
            String a137 = '137';
            String a138 = '138';
            String a139 = '139';
            String a140 = '140';
            String a141 = '141';
            String a142 = '142';
            String a143 = '143';
            String a144 = '144';
            String a145 = '145';
            String a146 = '146';
            String a147 = '147';
            String a148 = '148';
            String a149 = '149';
            String a150 = '150';
            String a151 = '151';
            String a152 = '152';
            String a153 = '153';
            String a154 = '154';
            String a155 = '155';
            String a156 = '156';
            String a157 = '157';
            String a158 = '158';
            String a159 = '159';
            String a160 = '160';
            String a161 = '161';
            String a162 = '162';
            String a163 = '163';
            String a164 = '164';
            String a165 = '165';
            String a166 = '166';
            String a167 = '167';
            String a168 = '168';
            String a169 = '169';
            String a170 = '170';
            String a171 = '171';
            String a172 = '172';
            String a173 = '173';
            String a174 = '174';
            String a175 = '175';
            String a176 = '176';
            String a177 = '177';
            String a178 = '178';
            String a179 = '179';
            String a180 = '180';
            String a181 = '181';
            String a182 = '182';
            String a183 = '183';
            String a184 = '184';
            String a185 = '185';
            String a186 = '186';
            String a187 = '187';
            String a188 = '188';
            String a189 = '189';
            String a190 = '190';
            String a191 = '191';
            String a192 = '192';
            String a193 = '193';
            String a194 = '194';
            String a195 = '195';
            String a196 = '196';
            String a197 = '197';
            String a198 = '198';
            String a199 = '199';
            String a200 = '200';
            String a201 = '201';
            String a202 = '202';
            String a203 = '203';
            String a204 = '204';
            String a205 = '205';
            String a206 = '206';
            String a207 = '207';
            String a208 = '208';
            String a209 = '209';
            String a210 = '210';
            String a211 = '211';
            String a212 = '212';
            String a213 = '213';
            String a214 = '214';
            String a215 = '215';
            String a216 = '216';
            String a217 = '217';
            String a218 = '218';
            String a219 = '219';
            String a220 = '220';
            String a221 = '221';
            String a222 = '222';
            String a223 = '223';
            String a224 = '224';
            String a225 = '225';
            String a226 = '226';
            String a227 = '227';
            String a228 = '228';
            String a229 = '229';
            String a230 = '230';
            String a231 = '231';
            String a232 = '232';
            String a233 = '233';
            String a234 = '234';
            String a235 = '235';
            String a236 = '236';
            String a237 = '237';
            String a238 = '238';
            String a239 = '239';
            String a240 = '240';
            String a241 = '241';
            String a242 = '242';
            String a243 = '243';
            String a244 = '244';
            String a245 = '245';
            String a246 = '246';
            String a247 = '247';
            String a248 = '248';
            String a249 = '249';
            String a250 = '250';
            String a251 = '251';
            String a252 = '252';
            String a253 = '253';
            String a254 = '254';
            String a255 = '255';
            String a256 = '256';
            String a257 = '257';
            String a258 = '258';
            String a259 = '259';
            String a260 = '260';
            String a261 = '261';
            String a262 = '262';
            String a263 = '263';
            String a264 = '264';
            String a265 = '265';
            String a266 = '266';
            String a267 = '267';
            String a268 = '268';
            String a269 = '269';
            String a270 = '270';
            String a271 = '271';
            String a272 = '272';
            String a273 = '273';
            String a274 = '274';
            String a275 = '275';
            String a276 = '276';
            String a277 = '277';
            String a278 = '278';
            String a279 = '279';
            String a280 = '280';
            String a281 = '281';
            String a282 = '282';
            String a283 = '283';
            String a284 = '284';
            String a285 = '285';
            String a286 = '286';
            String a287 = '287';
            String a288 = '288';
            String a289 = '289';
            String a290 = '290';
            String a291 = '291';
            String a292 = '292';
            String a293 = '293';
            String a294 = '294';
            String a295 = '295';
            String a296 = '296';
            String a297 = '297';
            String a298 = '298';
            String a299 = '299';
            String a300 = '300';
            String a301 = '301';
            String a302 = '302';
            String a303 = '303';
            String a304 = '304';
            String a305 = '305';
            String a306 = '306';
            String a307 = '307';
            String a308 = '308';
            String a309 = '309';
            String a310 = '310';
            String a311 = '311';
            String a312 = '312';
            String a313 = '313';
            String a314 = '314';
            String a315 = '315';
            String a316 = '316';
            String a317 = '317';
            String a318 = '318';
            String a319 = '319';
            String a320 = '320';
            String a321 = '321';
            String a322 = '322';
            String a323 = '323';
            String a324 = '324';
            String a325 = '325';
            String a326 = '326';
            String a327 = '327';
            String a328 = '328';
            String a329 = '329';
            String a330 = '330';
            String a331 = '331';
            String a332 = '332';
            String a333 = '333';
            String a334 = '334';
            String a335 = '335';
            String a336 = '336';
            String a337 = '337';
            String a338 = '338';
            String a339 = '339';
            String a340 = '340';
            String a341 = '341';
            String a342 = '342';
            String a343 = '343';
            String a344 = '344';
            String a345 = '345';
            String a346 = '346';
            String a347 = '347';
            String a348 = '348';
            String a349 = '349';
            String a350 = '350';
            String a351 = '351';
            String a352 = '352';
            String a353 = '353';
            String a354 = '354';
            String a355 = '355';
            String a356 = '356';
            String a357 = '357';
            String a358 = '358';
            String a359 = '359';
            String a360 = '360';
            String a361 = '361';
            String a362 = '362';
            String a363 = '363';
            String a364 = '364';
            String a365 = '365';
            String a366 = '366';
            String a367 = '367';
            String a368 = '368';
            String a369 = '369';
            String a370 = '370';
            String a371 = '371';
            String a372 = '372';
            String a373 = '373';
            String a374 = '374';
            String a375 = '375';
            String a376 = '376';
            String a377 = '377';
            String a378 = '378';
            String a379 = '379';
            String a380 = '380';
            String a381 = '381';
            String a382 = '382';
            String a383 = '383';
            String a384 = '384';
            String a385 = '385';
            String a386 = '386';
            String a387 = '387';
            String a388 = '388';
            String a389 = '389';
            String a390 = '390';
            String a391 = '391';
            String a392 = '392';
            String a393 = '393';
            String a394 = '394';
            String a395 = '395';
            String a396 = '396';
            String a397 = '397';
            String a398 = '398';
            String a399 = '399';
            String a400 = '400';
            String a401 = '401';
            String a402 = '402';
            String a403 = '403';
            String a404 = '404';
            String a405 = '405';
            String a406 = '406';
            String a407 = '407';
            String a408 = '408';
            String a409 = '409';
            String a410 = '410';
            String a411 = '411';
            String a412 = '412';
            String a413 = '413';
            String a414 = '414';
            String a415 = '415';
            String a416 = '416';
            String a417 = '417';
            String a418 = '418';
            String a419 = '419';
            String a420 = '420';
            String a421 = '421';
            String a422 = '422';
            String a423 = '423';
            String a424 = '424';
            String a425 = '425';
            String a426 = '426';
            String a427 = '427';
            String a428 = '428';
            String a429 = '429';
            String a430 = '430';
            String a431 = '431';
            String a432 = '432';
            String a433 = '433';
            String a434 = '434';
            String a435 = '435';
            String a436 = '436';
            String a437 = '437';
            String a438 = '438';
            String a439 = '439';
            String a440 = '440';
            String a441 = '441';
            String a442 = '442';
            String a443 = '443';
            String a444 = '444';
            String a445 = '445';
            String a446 = '446';
            String a447 = '447';
            String a448 = '448';
            String a449 = '449';
            String a450 = '450';
            String a451 = '451';
            String a452 = '452';
            String a453 = '453';
            String a454 = '454';
            String a455 = '455';
            String a456 = '456';
            String a457 = '457';
            String a458 = '458';
            String a459 = '459';
            String a460 = '460';
            String a461 = '461';
            String a462 = '462';
            String a463 = '463';
            String a464 = '464';
            String a465 = '465';
            String a466 = '466';
            String a467 = '467';
            String a468 = '468';
            String a469 = '469';
            String a470 = '470';
            String a471 = '471';
            String a472 = '472';
            String a473 = '473';
            String a474 = '474';
            String a475 = '475';
            String a476 = '476';
            String a477 = '477';
            String a478 = '478';
            String a479 = '479';
            String a480 = '480';
            String a481 = '481';
            String a482 = '482';
            String a483 = '483';
            String a484 = '484';
            String a485 = '485';
            String a486 = '486';
            String a487 = '487';
            String a488 = '488';
            String a489 = '489';
            String a490 = '490';
            String a491 = '491';
            String a492 = '492';
            String a493 = '493';
            String a494 = '494';
            String a495 = '495';
            String a496 = '496';
            String a497 = '497';
            String a498 = '498';
            String a499 = '499';
            String a500 = '500';
            String a501 = '501';
            String a502 = '502';
            String a503 = '503';
            String a504 = '504';
            String a505 = '505';
            String a506 = '506';
            String a507 = '507';
            String a508 = '508';
            String a509 = '509';
            String a510 = '510';
            String a511 = '511';
            String a512 = '512';
            String a513 = '513';
            String a514 = '514';
            String a515 = '515';
            String a516 = '516';
            String a517 = '517';
            String a518 = '518';
            String a519 = '519';
            String a520 = '520';
            String a521 = '521';
            String a522 = '522';
            String a523 = '523';
            String a524 = '524';
            String a525 = '525';
            String a526 = '526';
            String a527 = '527';
            String a528 = '528';
            String a529 = '529';
            String a530 = '530';
            String a531 = '531';
            String a532 = '532';
            String a533 = '533';
            String a534 = '534';
            String a535 = '535';
            String a536 = '536';
            String a537 = '537';
            String a538 = '538';
            String a539 = '539';
            String a540 = '540';
            String a541 = '541';
            String a542 = '542';
            String a543 = '543';
            String a544 = '544';
            String a545 = '545';
            String a546 = '546';
            String a547 = '547';
            String a548 = '548';
            String a549 = '549';
            String a550 = '550';
            String a551 = '551';
            String a552 = '552';
            String a553 = '553';
            String a554 = '554';
            String a555 = '555';
            String a556 = '556';
            String a557 = '557';
            String a558 = '558';
            String a559 = '559';
            String a560 = '560';
            String a561 = '561';
            String a562 = '562';
            String a563 = '563';
            String a564 = '564';
            String a565 = '565';
            String a566 = '566';
            String a567 = '567';
            String a568 = '568';
            String a569 = '569';
            String a570 = '570';
            String a571 = '571';
            String a572 = '572';
            String a573 = '573';
            String a574 = '574';
            String a575 = '575';
            String a576 = '576';
            String a577 = '577';
            String a578 = '578';
            String a579 = '579';
            String a580 = '580';
            String a581 = '581';
            String a582 = '582';
            String a583 = '583';
            String a584 = '584';
            String a585 = '585';
            String a586 = '586';
            String a587 = '587';
            String a588 = '588';
            String a589 = '589';
            String a590 = '590';
            String a591 = '591';
            String a592 = '592';
            String a593 = '593';
            String a594 = '594';
            String a595 = '595';
            String a596 = '596';
            String a597 = '597';
            String a598 = '598';
            String a599 = '599';
            String a600 = '600';
            String a601 = '601';
            String a602 = '602';
            String a603 = '603';
            String a604 = '604';
            String a605 = '605';
            String a606 = '606';
            String a607 = '607';
            String a608 = '608';
            String a609 = '609';
            String a610 = '610';
            String a611 = '611';
            String a612 = '612';
            String a613 = '613';
            String a614 = '614';
            String a615 = '615';
            String a616 = '616';
            String a617 = '617';
            String a618 = '618';
            String a619 = '619';
            String a620 = '620';
            String a621 = '621';
            String a622 = '622';
            String a623 = '623';
            String a624 = '624';
            String a625 = '625';
            String a626 = '626';
            String a627 = '627';
            String a628 = '628';
            String a629 = '629';
            String a630 = '630';
            String a631 = '631';
            String a632 = '632';
            String a633 = '633';
            String a634 = '634';
            String a635 = '635';
            String a636 = '636';
            String a637 = '637';
            String a638 = '638';
            String a639 = '639';
            String a640 = '640';
            String a641 = '641';
            String a642 = '642';
            String a643 = '643';
            String a644 = '644';
            String a645 = '645';
            String a646 = '646';
            String a647 = '647';
            String a648 = '648';
            String a649 = '649';
            String a650 = '650';
            String a651 = '651';
            String a652 = '652';
            String a653 = '653';
            String a654 = '654';
            String a655 = '655';
            String a656 = '656';
            String a657 = '657';
            String a658 = '658';
            String a659 = '659';
            String a660 = '660';
            String a661 = '661';
            String a662 = '662';
            String a663 = '663';
            String a664 = '664';
            String a665 = '665';
            String a666 = '666';
            String a667 = '667';
            String a668 = '668';
            String a669 = '669';
            String a670 = '670';
            String a671 = '671';
            String a672 = '672';
            String a673 = '673';
            String a674 = '674';
            String a675 = '675';
            String a676 = '676';
            String a677 = '677';
            String a678 = '678';
            String a679 = '679';
            String a680 = '680';
            String a681 = '681';
            String a682 = '682';
            String a683 = '683';
            String a684 = '684';
            String a685 = '685';
            String a686 = '686';
            String a687 = '687';
            String a688 = '688';
            String a689 = '689';
            String a690 = '690';
            String a691 = '691';
            String a692 = '692';
            String a693 = '693';
            String a694 = '694';
            String a695 = '695';
            String a696 = '696';
            String a697 = '697';
            String a698 = '698';
            String a699 = '699';
            String a700 = '700';
            String a701 = '701';
            String a702 = '702';
            String a703 = '703';
            String a704 = '704';
            String a705 = '705';
            String a706 = '706';
            String a707 = '707';
            String a708 = '708';
            String a709 = '709';
            String a710 = '710';
            String a711 = '711';
            String a712 = '712';
            String a713 = '713';
            String a714 = '714';
            String a715 = '715';
            String a716 = '716';
            String a717 = '717';
            String a718 = '718';
            String a719 = '719';
            String a720 = '720';
            String a721 = '721';
            String a722 = '722';
            String a723 = '723';
            String a724 = '724';
            String a725 = '725';
            String a726 = '726';
            String a727 = '727';
            String a728 = '728';
            String a729 = '729';
            String a730 = '730';
            String a731 = '731';
            String a732 = '732';
            String a733 = '733';
            String a734 = '734';
            String a735 = '735';
            String a736 = '736';
            String a737 = '737';
            String a738 = '738';
            String a739 = '739';
            String a740 = '740';
            String a741 = '741';
            String a742 = '742';
            String a743 = '743';
            String a744 = '744';
            String a745 = '745';
            String a746 = '746';
            String a747 = '747';
            String a748 = '748';
            String a749 = '749';
            String a750 = '750';
            String a751 = '751';
            String a752 = '752';
            String a753 = '753';
            String a754 = '754';
            String a755 = '755';
            String a756 = '756';
            String a757 = '757';
            String a758 = '758';
            String a759 = '759';
            String a760 = '760';
            String a761 = '761';
            String a762 = '762';
            String a763 = '763';
            String a764 = '764';
            String a765 = '765';
            String a766 = '766';
            String a767 = '767';
            String a768 = '768';
            String a769 = '769';
            String a770 = '770';
            String a771 = '771';
            String a772 = '772';
            String a773 = '773';
            String a774 = '774';
            String a775 = '775';
            String a776 = '776';
            String a777 = '777';
            String a778 = '778';
            String a779 = '779';
            String a780 = '780';
            String a781 = '781';
            String a782 = '782';
            String a783 = '783';
            String a784 = '784';
            String a785 = '785';
            String a786 = '786';
            String a787 = '787';
            String a788 = '788';
            String a789 = '789';
            String a790 = '790';
            String a791 = '791';
            String a792 = '792';
            String a793 = '793';
            String a794 = '794';
            String a795 = '795';
            String a796 = '796';
            String a797 = '797';
            String a798 = '798';
            String a799 = '799';
            String a800 = '800';
            String a801 = '801';
            String a802 = '802';
            String a803 = '803';
            String a804 = '804';
            String a805 = '805';
            String a806 = '806';
            String a807 = '807';
            String a808 = '808';
            String a809 = '809';
            String a810 = '810';
            String a811 = '811';
            String a812 = '812';
            String a813 = '813';
            String a814 = '814';
            String a815 = '815';
            String a816 = '816';
            String a817 = '817';
            String a818 = '818';
            String a819 = '819';
            String a820 = '820';
            String a821 = '821';
            String a822 = '822';
            String a823 = '823';
            String a824 = '824';
            String a825 = '825';
            String a826 = '826';
            String a827 = '827';
            String a828 = '828';
            String a829 = '829';
            String a830 = '830';
            String a831 = '831';
            String a832 = '832';
            String a833 = '833';
            String a834 = '834';
            String a835 = '835';
            String a836 = '836';
            String a837 = '837';
            String a838 = '838';
            String a839 = '839';
            String a840 = '840';
            String a841 = '841';
            String a842 = '842';
            String a843 = '843';
            String a844 = '844';
            String a845 = '845';
            String a846 = '846';
            String a847 = '847';
            String a848 = '848';
            String a849 = '849';
            String a850 = '850';
            String a851 = '851';
            String a852 = '852';
            String a853 = '853';
            String a854 = '854';
            String a855 = '855';
            String a856 = '856';
            String a857 = '857';
            String a858 = '858';
            String a859 = '859';
            String a860 = '860';
            String a861 = '861';
            String a862 = '862';
            String a863 = '863';
            String a864 = '864';
            String a865 = '865';
            String a866 = '866';
            String a867 = '867';
            String a868 = '868';
            String a869 = '869';
            String a870 = '870';
            String a871 = '871';
            String a872 = '872';
            String a873 = '873';
            String a874 = '874';
            String a875 = '875';
            String a876 = '876';
            String a877 = '877';
            String a878 = '878';
            String a879 = '879';
            String a880 = '880';
            String a881 = '881';
            String a882 = '882';
            String a883 = '883';
            String a884 = '884';
            String a885 = '885';
            String a886 = '886';
            String a887 = '887';
            String a888 = '888';
            String a889 = '889';
            String a890 = '890';
            String a891 = '891';
            String a892 = '892';
            String a893 = '893';
            String a894 = '894';
            String a895 = '895';
            String a896 = '896';
            String a897 = '897';
            String a898 = '898';
            String a899 = '899';
            String a900 = '900';
            String a901 = '901';
            String a902 = '902';
            String a903 = '903';
            String a904 = '904';
            String a905 = '905';
            String a906 = '906';
            String a907 = '907';
            String a908 = '908';
            String a909 = '909';
            String a910 = '910';
            String a911 = '911';
            String a912 = '912';
            String a913 = '913';
            String a914 = '914';
            String a915 = '915';
            String a916 = '916';
            String a917 = '917';
            String a918 = '918';
            String a919 = '919';
            String a920 = '920';
            String a921 = '921';
            String a922 = '922';
            String a923 = '923';
            String a924 = '924';
            String a925 = '925';
            String a926 = '926';
            String a927 = '927';
            String a928 = '928';
            String a929 = '929';
            String a930 = '930';
            String a931 = '931';
            String a932 = '932';
            String a933 = '933';
            String a934 = '934';
            String a935 = '935';
            String a936 = '936';
            String a937 = '937';
            String a938 = '938';
            String a939 = '939';
            String a940 = '940';
            String a941 = '941';
            String a942 = '942';
            String a943 = '943';
            String a944 = '944';
            String a945 = '945';
            String a946 = '946';
            String a947 = '947';
            String a948 = '948';
            String a949 = '949';
            String a950 = '950';
            String a951 = '951';
            String a952 = '952';
            String a953 = '953';
            String a954 = '954';
            String a955 = '955';
            String a956 = '956';
            String a957 = '957';
            String a958 = '958';
            String a959 = '959';
            String a960 = '960';
            String a961 = '961';
            String a962 = '962';
            String a963 = '963';
            String a964 = '964';
            String a965 = '965';
            String a966 = '966';
            String a967 = '967';
            String a968 = '968';
            String a969 = '969';
            String a970 = '970';
            String a971 = '971';
            String a972 = '972';
            String a973 = '973';
            String a974 = '974';
            String a975 = '975';
            String a976 = '976';
            String a977 = '977';
            String a978 = '978';
            String a979 = '979';
            String a980 = '980';
            String a981 = '981';
            String a982 = '982';
            String a983 = '983';
            String a984 = '984';
            String a985 = '985';
            String a986 = '986';
            String a987 = '987';
            String a988 = '988';
            String a989 = '989';
            String a990 = '990';
            String a991 = '991';
            String a992 = '992';
            String a993 = '993';
            String a994 = '994';
            String a995 = '995';
            String a996 = '996';
            String a997 = '997';
            String a998 = '998';
            String a999 = '999';
            String a1000 = '1000';
String a1001 = '1001';
String a1002 = '1002';
String a1003 = '1003';
String a1004 = '1004';
String a1005 = '1005';
String a1006 = '1006';
String a1007 = '1007';
String a1008 = '1008';
String a1009 = '1009';
String a1010 = '1010';
String a1011 = '1011';
String a1012 = '1012';
String a1013 = '1013';
String a1014 = '1014';
String a1015 = '1015';
String a1016 = '1016';
String a1017 = '1017';
String a1018 = '1018';
String a1019 = '1019';
String a1020 = '1020';
String a1021 = '1021';
String a1022 = '1022';
String a1023 = '1023';
String a1024 = '1024';
String a1025 = '1025';
String a1026 = '1026';
String a1027 = '1027';
String a1028 = '1028';
String a1029 = '1029';
String a1030 = '1030';
String a1031 = '1031';
String a1032 = '1032';
String a1033 = '1033';
String a1034 = '1034';
String a1035 = '1035';
String a1036 = '1036';
String a1037 = '1037';
String a1038 = '1038';
String a1039 = '1039';
String a1040 = '1040';
String a1041 = '1041';
String a1042 = '1042';
String a1043 = '1043';
String a1044 = '1044';
String a1045 = '1045';
String a1046 = '1046';
String a1047 = '1047';
String a1048 = '1048';
String a1049 = '1049';
String a1050 = '1050';
String a1051 = '1051';
String a1052 = '1052';
String a1053 = '1053';
String a1054 = '1054';
String a1055 = '1055';
String a1056 = '1056';
String a1057 = '1057';
String a1058 = '1058';
String a1059 = '1059';
String a1060 = '1060';
String a1061 = '1061';
String a1062 = '1062';
String a1063 = '1063';
String a1064 = '1064';
String a1065 = '1065';
String a1066 = '1066';
String a1067 = '1067';
String a1068 = '1068';
String a1069 = '1069';
String a1070 = '1070';
String a1071 = '1071';
String a1072 = '1072';
String a1073 = '1073';
String a1074 = '1074';
String a1075 = '1075';
String a1076 = '1076';
String a1077 = '1077';
String a1078 = '1078';
String a1079 = '1079';
String a1080 = '1080';
String a1081 = '1081';
String a1082 = '1082';
String a1083 = '1083';
String a1084 = '1084';
String a1085 = '1085';
String a1086 = '1086';
String a1087 = '1087';
String a1088 = '1088';
String a1089 = '1089';
String a1090 = '1090';
String a1091 = '1091';
String a1092 = '1092';
String a1093 = '1093';
String a1094 = '1094';
String a1095 = '1095';
String a1096 = '1096';
String a1097 = '1097';
String a1098 = '1098';
String a1099 = '1099';
String a1100 = '1100';
String a1101 = '1101';
String a1102 = '1102';
String a1103 = '1103';
String a1104 = '1104';
String a1105 = '1105';
String a1106 = '1106';
String a1107 = '1107';
String a1108 = '1108';
String a1109 = '1109';
String a1110 = '1110';
String a1111 = '1111';
String a1112 = '1112';
String a1113 = '1113';
String a1114 = '1114';
String a1115 = '1115';
String a1116 = '1116';
String a1117 = '1117';
String a1118 = '1118';
String a1119 = '1119';
String a1120 = '1120';
String a1121 = '1121';
String a1122 = '1122';
String a1123 = '1123';
String a1124 = '1124';
String a1125 = '1125';
String a1126 = '1126';
String a1127 = '1127';
String a1128 = '1128';
String a1129 = '1129';
String a1130 = '1130';
String a1131 = '1131';
String a1132 = '1132';
String a1133 = '1133';
String a1134 = '1134';
String a1135 = '1135';
String a1136 = '1136';
String a1137 = '1137';
String a1138 = '1138';
String a1139 = '1139';
String a1140 = '1140';
String a1141 = '1141';
String a1142 = '1142';
String a1143 = '1143';
String a1144 = '1144';
String a1145 = '1145';
String a1146 = '1146';
String a1147 = '1147';
String a1148 = '1148';
String a1149 = '1149';
String a1150 = '1150';
String a1151 = '1151';
String a1152 = '1152';
String a1153 = '1153';
String a1154 = '1154';
String a1155 = '1155';
String a1156 = '1156';
String a1157 = '1157';
String a1158 = '1158';
String a1159 = '1159';
String a1160 = '1160';
String a1161 = '1161';
String a1162 = '1162';
String a1163 = '1163';
String a1164 = '1164';
String a1165 = '1165';
String a1166 = '1166';
String a1167 = '1167';
String a1168 = '1168';
String a1169 = '1169';
String a1170 = '1170';
String a1171 = '1171';
String a1172 = '1172';
String a1173 = '1173';
String a1174 = '1174';
String a1175 = '1175';
String a1176 = '1176';
String a1177 = '1177';
String a1178 = '1178';
String a1179 = '1179';
String a1180 = '1180';
String a1181 = '1181';
String a1182 = '1182';
String a1183 = '1183';
String a1184 = '1184';
String a1185 = '1185';
String a1186 = '1186';
String a1187 = '1187';
String a1188 = '1188';
String a1189 = '1189';
String a1190 = '1190';
String a1191 = '1191';
String a1192 = '1192';
String a1193 = '1193';
String a1194 = '1194';
String a1195 = '1195';
String a1196 = '1196';
String a1197 = '1197';
String a1198 = '1198';
String a1199 = '1199';
String a1200 = '1200';
String a1201 = '1201';
String a1202 = '1202';
String a1203 = '1203';
String a1204 = '1204';
String a1205 = '1205';
String a1206 = '1206';
String a1207 = '1207';
String a1208 = '1208';
String a1209 = '1209';
String a1210 = '1210';
String a1211 = '1211';
String a1212 = '1212';
String a1213 = '1213';
String a1214 = '1214';
String a1215 = '1215';
String a1216 = '1216';
String a1217 = '1217';
String a1218 = '1218';
String a1219 = '1219';
String a1220 = '1220';
String a1221 = '1221';
String a1222 = '1222';
String a1223 = '1223';
String a1224 = '1224';
String a1225 = '1225';
String a1226 = '1226';
String a1227 = '1227';
String a1228 = '1228';
String a1229 = '1229';
String a1230 = '1230';
String a1231 = '1231';
String a1232 = '1232';
String a1233 = '1233';
String a1234 = '1234';
String a1235 = '1235';
String a1236 = '1236';
String a1237 = '1237';
String a1238 = '1238';
String a1239 = '1239';
String a1240 = '1240';
String a1241 = '1241';
String a1242 = '1242';
String a1243 = '1243';
String a1244 = '1244';
String a1245 = '1245';
String a1246 = '1246';
String a1247 = '1247';
String a1248 = '1248';
String a1249 = '1249';
String a1250 = '1250';
String a1251 = '1251';
String a1252 = '1252';
String a1253 = '1253';
String a1254 = '1254';
String a1255 = '1255';
String a1256 = '1256';
String a1257 = '1257';
String a1258 = '1258';
String a1259 = '1259';
String a1260 = '1260';
String a1261 = '1261';
String a1262 = '1262';
String a1263 = '1263';
String a1264 = '1264';
String a1265 = '1265';
String a1266 = '1266';
String a1267 = '1267';
String a1268 = '1268';
String a1269 = '1269';
String a1270 = '1270';
String a1271 = '1271';
String a1272 = '1272';
String a1273 = '1273';
String a1274 = '1274';
String a1275 = '1275';
String a1276 = '1276';
String a1277 = '1277';
String a1278 = '1278';
String a1279 = '1279';
String a1280 = '1280';
String a1281 = '1281';
String a1282 = '1282';
String a1283 = '1283';
String a1284 = '1284';
String a1285 = '1285';
String a1286 = '1286';
String a1287 = '1287';
String a1288 = '1288';
String a1289 = '1289';
String a1290 = '1290';
String a1291 = '1291';
String a1292 = '1292';
String a1293 = '1293';
String a1294 = '1294';
String a1295 = '1295';
String a1296 = '1296';
String a1297 = '1297';
String a1298 = '1298';
String a1299 = '1299';
String a1300 = '1300';
String a1301 = '1301';
String a1302 = '1302';
String a1303 = '1303';
String a1304 = '1304';
String a1305 = '1305';
String a1306 = '1306';
String a1307 = '1307';
String a1308 = '1308';
String a1309 = '1309';
String a1310 = '1310';
String a1311 = '1311';
String a1312 = '1312';
String a1313 = '1313';
String a1314 = '1314';
String a1315 = '1315';
String a1316 = '1316';
String a1317 = '1317';
String a1318 = '1318';
String a1319 = '1319';
String a1320 = '1320';
String a1321 = '1321';
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
            
        } 
        
        
    }
}