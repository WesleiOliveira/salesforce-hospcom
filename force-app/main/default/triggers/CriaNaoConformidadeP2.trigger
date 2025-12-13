trigger CriaNaoConformidadeP2 on Auditoria__c (after update) {
    
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
    questoes.add('189 – Existe pendência de documentação de demonstração no sistema?');
    //Questão 190
    questoes.add('190 – Abrir aleatoriamente um contrato de locação no sistema e verificar assinatura.');
    //Questão 191
    questoes.add('191 – Abrir aleatoriamente uma O.T. de demonstração e verificar os anexos.');
    //Questão 192
    questoes.add('192 – Estão anexados contrato, checklist, registro, nota fiscal e lista de presença?');
    //Questão 193
    questoes.add('193 – Existem produtos higienizados sem a devida etiqueta com data e assinatura de higienização e verificação? ');
    //Questão 194
    questoes.add('194 - Foram encontrados insetos, roedores ou qualquer praga nos ambientes da empresa?');
    
    //Questão 195
    questoes.add('195 - Se sim: eles se encontravam vivos, no momento da auditoria?');
    
    //Questão 196
    questoes.add('196 - Os laudos de dedetização estão em dia e de forma organizada?');
    
    //Questão 197
    questoes.add('197 - O certificado de dedetização está na recepção da empresa e dentro do prazo de validade?!');
    
    //Questão 198
    questoes.add('198 -Como são controlados os indicadores e os objetivos da qualidade da empresa?');
    
    //Questão 199
    questoes.add('199 - Transportadora que presta serviço ao Grupo Hospcom está inserida no Sistema Salesforce na aba “Transporte” e com sua documentação exigida anexada?');
    
    //Questão 200
    questoes.add('200 - Toda frota veicular do grupo Hospcom estão cadastrados em Sistema Salesforce?');
    
    //Questão 201
    questoes.add('201 - Histórico de Revisão da manutenção está em dia ou existe carro com manutenção preventiva atrasada? ');
    
    //Questão 202
    questoes.add('202 - Veículos destinados a transporte de Equipamentos Hospitalares possuem o Certificado Veicular da Vigilância Sanitária Municipal? Se sim, está em vigência?');
    
    //Questão 203
    questoes.add('203 - Técnicos/Auxiliares técnicos estão com a Ficha de EPI, Ordem de Serviço, Certificados Acadêmicos e Ficha de Vacina devidamente organizadas em uma pasta digital?');
    
    //Questão 204
    questoes.add('204 - PCMSO e PGR estão disponíveis no CNPJ da empresa dentro do Salesforce?');
    
    //Questão 205
    questoes.add('205 - ASO está sendo controlada?');
    
    //Questão  206
    questoes.add('206 - Existem fios elétricos soltos, estrutura comprometida ou qualquer situação que ofereça risco a saúde e vida dos colaboradores? ');
    
    //Questão  207
    questoes.add('207 - O Kit de primeiros socorros está disponível na empresa?');
    
    //Questão 208 
    questoes.add('208 - Existe algum item vencido no kit de primeiros socorros?');
    
    //Questão  209
    questoes.add('209 - O tempo médio de resposta ao cliente é condizente com as políticas internas estabelecidas pela empresa?');
    
    //Questão  210
    questoes.add('210 - A média de avaliação do cliente quanto ao atendimento é igual ou maior do que a média estabelecida pela empresa? ');
    
    //Questão  211
    questoes.add('211 - A média de avaliação do cliente quanto a satisfação com o produto/serviço oferecido é igual ou maior do que a média estabelecida pela empresa? ');
    
    //Questão  212
    questoes.add('212 - Todas as reclamações de clientes estão sendo concluídas?');
    
    //Questão  213
    questoes.add('213 - Todos os casos possuem anexo ou alguma forma de comprovação de atendimento ao cliente?');
    
    //Questão  214
    questoes.add('214 - O projeto arquitetônico da unidade tem aprovação do órgão regulador responsável?');
    
    //Questão  215
    questoes.add('215 - O último projeto arquitetônico aprovado foi disponibilizado de forma impressa e assinada?');
    
    //Questão  216
    questoes.add('216 - O último projeto arquitetônico aprovado foi executado? As áreas estão de acordo com o projeto?');
    
    
    
    
    
    
    Nao_Conformidade__c nc = new Nao_Conformidade__c();
    
    
    for(Auditoria__c rs : Trigger.new){
        
        String id = rs.id;
        if(rs.Status__c == 'CONCLUIDO'){
            
            
            
            
            //------------   não conformidade  151  --------------------        
            if(rs.x151__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[151];
                nc.Auditoria__c  = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                
                
                nc.RecordtypeId = '012U4000000uiPlIAI';                nc.tipo__c = 'Documental';
                insert nc;
            }
            
            //------------   não conformidade  152  --------------------        
            if(rs.x152__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[152];
                nc.Auditoria__c       = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                
                
                nc.RecordtypeId = '012U4000000uiPlIAI';                nc.tipo__c = 'Documental';
                insert nc;
            }
            
            //------------   não conformidade  153  --------------------        
            if(rs.x153__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[153];
                nc.Auditoria__c       = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                
                
                
                nc.RecordtypeId = '012U4000000uiPlIAI';                nc.tipo__c = 'Processo';
                insert nc;
            }
            
            //------------   não conformidade  154  --------------------        
            if(rs.x154__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[154];
                nc.Auditoria__c       = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                
                
                
                nc.RecordtypeId = '012U4000000uiPlIAI';                nc.tipo__c = 'Processo';
                insert nc;
            }
            
            //------------   não conformidade  155  --------------------        
            if(rs.x155__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[155];
                nc.Auditoria__c       = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                
                
                nc.RecordtypeId = '012U4000000uiPlIAI';                nc.tipo__c = 'Documental';
                insert nc;
            }
            
            //------------   não conformidade  156  --------------------        
            if(rs.x156__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[156];
                nc.Auditoria__c       = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                
                
                
                nc.RecordtypeId = '012U4000000uiPlIAI';                nc.tipo__c = 'Processo';
                insert nc;
            }
            
            //------------   não conformidade  157  --------------------        
            if(rs.x157__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[157];
                nc.Auditoria__c       = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                
                
                nc.RecordtypeId = '012U4000000uiPlIAI';                nc.tipo__c = 'Documental';
                insert nc;
            }
            
            //------------   não conformidade  158  --------------------        
            if(rs.x158__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[158];
                nc.Auditoria__c       = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                
                
                nc.RecordtypeId = '012U4000000uiPlIAI';                nc.tipo__c = 'Documental';
                insert nc;
            }
            
            //------------   não conformidade  159  --------------------        
            if(rs.x159__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[159];
                nc.Auditoria__c       = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                
                
                nc.RecordtypeId = '012U4000000uiPlIAI';                nc.tipo__c = 'Documental';
                insert nc;
            }
            
            //------------   não conformidade  160  --------------------        
            if(rs.x160__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[160];
                nc.Auditoria__c       = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                
                
                nc.RecordtypeId = '012U4000000uiPlIAI';                nc.tipo__c = 'Documental';
                insert nc;
            }
            
            //------------   não conformidade  161  --------------------        
            if(rs.x161__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[161];
                nc.Auditoria__c       = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                
                
                nc.RecordtypeId = '012U4000000uiPlIAI';                nc.tipo__c = 'Documental';
                insert nc;
            }
            
            //------------   não conformidade  162  --------------------        
            if(rs.x162__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[162];
                nc.Auditoria__c       = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                
                
                nc.RecordtypeId = '012U4000000uiPlIAI';                nc.tipo__c = 'Documental';
                insert nc;
            }
            
            //------------   não conformidade  163  --------------------        
            if(rs.x163__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[163];
                nc.Auditoria__c       = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                
                
                nc.RecordtypeId = '012U4000000uiPlIAI';                nc.tipo__c = 'Documental';
                insert nc;
            }
            
            //------------   não conformidade  164  --------------------        
            if(rs.x164__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[164];
                nc.Auditoria__c       = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                
                
                nc.RecordtypeId = '012U4000000uiPlIAI';                nc.tipo__c = 'Documental';
                insert nc;
            }
            
            //------------   não conformidade  165  --------------------        
            if(rs.x165__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[165];
                nc.Auditoria__c       = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                
                
                nc.RecordtypeId = '012U4000000uiPlIAI';                nc.tipo__c = 'Documental';
                insert nc;
            }
            
            //------------   não conformidade  166  --------------------        
            if(rs.x166__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[166];
                nc.Auditoria__c       = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                
                
                nc.RecordtypeId = '012U4000000uiPlIAI';                nc.tipo__c = 'Documental';
                insert nc;
            }
            
            //------------   não conformidade  167  --------------------        
            if(rs.x167__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[167];
                nc.Auditoria__c       = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                
                
                nc.RecordtypeId = '012U4000000uiPlIAI';                nc.tipo__c = 'Documental';
                insert nc;
            }
            
            //------------   não conformidade  168  --------------------        
            if(rs.x168__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[168];
                nc.Auditoria__c       = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                
                
                nc.RecordtypeId = '012U4000000uiPlIAI';                nc.tipo__c = 'Documental';
                insert nc;
            }
            
            //------------   não conformidade  169  --------------------        
            if(rs.x169__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[169];
                nc.Auditoria__c       = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                
                
                nc.RecordtypeId = '012U4000000uiPlIAI';                nc.tipo__c = 'Documental';
                insert nc;
            }
            
            //------------   não conformidade  170  --------------------        
            if(rs.x170__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[170];
                nc.Auditoria__c       = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                
                
                nc.RecordtypeId = '012U4000000uiPlIAI';                nc.tipo__c = 'Documental';
                insert nc;
            }
            
            //------------   não conformidade  171  --------------------        
            if(rs.x171__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[171];
                nc.Auditoria__c       = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                
                
                nc.RecordtypeId = '012U4000000uiPlIAI';                nc.tipo__c = 'Documental';
                insert nc;
            }
            
            //------------   não conformidade  172  --------------------        
            if(rs.x172__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[172];
                nc.Auditoria__c       = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                
                
                nc.RecordtypeId = '012U4000000uiPlIAI';                nc.tipo__c = 'Documental';
                insert nc;
            }
            
            //------------   não conformidade  173  --------------------
            if(rs.x173__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[173];
                nc.Auditoria__c       = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                
                
                nc.RecordtypeId = '012U4000000uiPlIAI';                nc.tipo__c = 'Documental';
                insert nc;
            }
            
            //------------   não conformidade  174  --------------------        
            if(rs.x174__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[174];
                nc.Auditoria__c       = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                
                
                nc.RecordtypeId = '012U4000000uiPlIAI';                nc.tipo__c = 'Documental';
                insert nc;
            }
            
            //------------   não conformidade  175  --------------------        
            if(rs.x175__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[175];
                nc.Auditoria__c       = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                
                
                nc.RecordtypeId = '012U4000000uiPlIAI';                nc.tipo__c = 'Documental';
                insert nc;
            }
            
            //------------   não conformidade  176  --------------------
            if(rs.x176__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[176];
                nc.Auditoria__c       = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                
                
                nc.RecordtypeId = '012U4000000uiPlIAI';                nc.tipo__c = 'Documental';
                insert nc;
            }
            
            //------------   não conformidade  177  --------------------        
            if(rs.x177__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[177];
                nc.Auditoria__c       = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                
                
                nc.RecordtypeId = '012U4000000uiPlIAI';                nc.tipo__c = 'Documental';
                insert nc;
            }
            
            //------------   não conformidade  178  --------------------        
            if(rs.x178__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[178];
                nc.Auditoria__c       = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                
                
                nc.RecordtypeId = '012U4000000uiPlIAI';                nc.tipo__c = 'Documental';
                insert nc;
            }
            
            //------------   não conformidade  179  --------------------
            if(rs.x179__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[179];
                nc.Auditoria__c       = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                
                
                nc.RecordtypeId = '012U4000000uiPlIAI';                nc.tipo__c = 'Documental';
                insert nc;
            }
            
            //------------   não conformidade  180  --------------------        
            if(rs.x180__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[180];
                nc.Auditoria__c       = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                
                
                
                nc.RecordtypeId = '012U4000000uiPlIAI';                nc.tipo__c = 'Processo';
                insert nc;
            }
            
            //------------   não conformidade  181  --------------------        
            if(rs.x181__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[181];
                nc.Auditoria__c       = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                
                
                nc.RecordtypeId = '012U4000000uiPlIAI';                nc.tipo__c = 'Documental';
                insert nc;
            }
            
            //------------   não conformidade  182  --------------------        
            if(rs.x182__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[182];
                nc.Auditoria__c       = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                
                
                nc.RecordtypeId = '012U4000000uiPlIAI';                nc.tipo__c = 'Documental';
                insert nc;
            }
            
            //------------   não conformidade  183  --------------------        
            if(rs.x183__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[183];
                nc.Auditoria__c       = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                
                
                nc.RecordtypeId = '012U4000000uiPlIAI';                nc.tipo__c = 'Documental';
                insert nc;
            }
            
            //------------   não conformidade  184  --------------------        
            if(rs.x184__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[184];
                nc.Auditoria__c       = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                
                
                nc.RecordtypeId = '012U4000000uiPlIAI';                nc.tipo__c = 'Documental';
                insert nc;
            }
            
            //------------   não conformidade  185  --------------------        
            if(rs.x185__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[185];
                nc.Auditoria__c       = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                
                
                nc.RecordtypeId = '012U4000000uiPlIAI';                nc.tipo__c = 'Documental';
                insert nc;
            }
            
            //------------   não conformidade  186  --------------------        
            if(rs.x186__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[186];
                nc.Auditoria__c       = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                
                
                nc.RecordtypeId = '012U4000000uiPlIAI';                nc.tipo__c = 'Documental';
                insert nc;
            }
            
            //------------   não conformidade  187  --------------------        
            if(rs.x187__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[187];
                nc.Auditoria__c       = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                
                
                nc.RecordtypeId = '012U4000000uiPlIAI';                nc.tipo__c = 'Documental';
                insert nc;
            }
            
            
            //------------   não conformidade  188   --------------------        
            if(rs.x188__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[188];
                nc.Auditoria__c       = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                
                
                nc.RecordtypeId = '012U4000000uiPlIAI';                nc.tipo__c = 'Estrutural';
                insert nc;
            }
            
            
            //------------   não conformidade  189  --------------------        
            if(rs.x189__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[189];
                nc.Auditoria__c       = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                
                
                nc.RecordtypeId = '012U4000000uiPlIAI';                nc.tipo__c = 'Documental';
                insert nc;
            }
            
            
            //------------   não conformidade  190  --------------------        
            if(rs.x190__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[190];
                nc.Auditoria__c       = rs.id;
                
                nc.tipo__c = 'Documental';
                
                
                nc.RecordtypeId = '012U4000000uiPlIAI';   nc.Data_de_Abertura_do_RNC__c = Date.today();
                insert nc;
            }
            
            
            //------------   não conformidade 191  --------------------        
            if(rs.x191__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[191];
                nc.Auditoria__c       = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                
                
                
                nc.RecordtypeId = '012U4000000uiPlIAI';                nc.tipo__c = 'Documental';
                insert nc;
            }
            
            
            //------------   não conformidade  192  --------------------        
            if(rs.x192__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[192];
                nc.Auditoria__c       = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                
                
                
                nc.RecordtypeId = '012U4000000uiPlIAI';                nc.tipo__c = 'Documental';
                insert nc;
            }
            
            
            //------------   não conformidade  193  --------------------        
            if(rs.x193__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                nc.N_o_conformidade__c = questoes[193];
                nc.Auditoria__c       = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                
                nc.tipo__c = 'Processo';
                
                
                nc.RecordtypeId = '012U4000000uiPlIAI';     
                insert nc;
            }
            
            
            
            
            //------------   não conformidade  194  --------------------        
            if(rs.x194__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                
                nc.N_o_conformidade__c = questoes[194];
                nc.Auditoria__c = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                nc.tipo__c = 'Estrutural';
                
                
                nc.RecordtypeId = '012U4000000uiPlIAI';     
                insert nc;
            }           
            
            
            //------------   não conformidade  195   --------------------        
            if(rs.x195__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                
                nc.N_o_conformidade__c = questoes[195];
                nc.Auditoria__c = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                nc.tipo__c = 'Estrutural';
                
                
                nc.RecordtypeId = '012U4000000uiPlIAI';     
                insert nc;
            }           
            
            
            //------------   não conformidade 196   --------------------        
            if(rs.x196__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                
                nc.N_o_conformidade__c = questoes[196];
                nc.Auditoria__c = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                nc.tipo__c = 'Documental';
                
                
                nc.RecordtypeId = '012U4000000uiPlIAI';     
                insert nc;
            }           
            
            
            //------------   não conformidade    --------------------        
            if(rs.x197__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                
                nc.N_o_conformidade__c = questoes[197];
                nc.Auditoria__c = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                nc.tipo__c = 'Estrutural';
                
                
                nc.RecordtypeId = '012U4000000uiPlIAI';     
                insert nc;
            }           
            
            
            //------------   não conformidade 198   --------------------        
            if(rs.x198__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                
                nc.N_o_conformidade__c = questoes[198];
                nc.Auditoria__c = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                nc.tipo__c = 'Documental';
                
                
                nc.RecordtypeId = '012U4000000uiPlIAI';     
                insert nc;
            }           
            
            
            //------------   não conformidade    --------------------        
            if(rs.x199__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                
                nc.N_o_conformidade__c = questoes[199];
                nc.Auditoria__c = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                nc.tipo__c = 'Processo';
                
                
                nc.RecordtypeId = '012U4000000uiPlIAI';     
                insert nc;
            }           
            
            
            //------------   não conformidade 200   --------------------        
            if(rs.x200__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                
                nc.N_o_conformidade__c = questoes[200];
                nc.Auditoria__c = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                nc.tipo__c = 'Processo';
                
                
                nc.RecordtypeId = '012U4000000uiPlIAI';     
                insert nc;
            }           
            
            
            //------------   não conformidade    --------------------        
            if(rs.x201__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                
                nc.N_o_conformidade__c = questoes[201];
                nc.Auditoria__c = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                nc.tipo__c = 'Processo';
                
                
                nc.RecordtypeId = '012U4000000uiPlIAI';     
                insert nc;
            }           
            
            
            //------------   não conformidade 202   --------------------        
            if(rs.x202__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                
                nc.N_o_conformidade__c = questoes[202];
                nc.Auditoria__c = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                nc.tipo__c = 'Documental';
                
                
                nc.RecordtypeId = '012U4000000uiPlIAI';     
                insert nc;
            }           
            
            
            //------------   não conformidade  203  --------------------        
            if(rs.x203__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                
                nc.N_o_conformidade__c = questoes[203];
                nc.Auditoria__c = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                nc.tipo__c = 'Documental';
                
                
                nc.RecordtypeId = '012U4000000uiPlIAI';     
                insert nc;
            }           
            
            
            //------------   não conformidade    --------------------        
            if(rs.x204__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                
                nc.N_o_conformidade__c = questoes[204];
                nc.Auditoria__c = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                nc.tipo__c = 'Documental';
                
                
                nc.RecordtypeId = '012U4000000uiPlIAI';     
                insert nc;
            }           
            
            
            //------------   não conformidade 205  --------------------        
            if(rs.x205__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                
                nc.N_o_conformidade__c = questoes[205];
                nc.Auditoria__c = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                nc.tipo__c = 'Processo';
                
                
                nc.RecordtypeId = '012U4000000uiPlIAI';     
                insert nc;
            }   
            
            //------------   não conformidade 206  --------------------        
            if(rs.x206__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                
                nc.N_o_conformidade__c = questoes[206];
                nc.Auditoria__c = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                nc.tipo__c = 'Estrutural';
                
                
                nc.RecordtypeId = '012U4000000uiPlIAI';     
                insert nc;
            }  
            
            
            //------------   não conformidade 207  --------------------        
            if(rs.x207__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                
                nc.N_o_conformidade__c = questoes[207];
                nc.Auditoria__c = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                nc.tipo__c = 'Estrutural';
                
                
                nc.RecordtypeId = '012U4000000uiPlIAI';     
                insert nc;
            }  
            
            
            //------------   não conformidade  208 --------------------        
            if(rs.x208__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                
                nc.N_o_conformidade__c = questoes[208];
                nc.Auditoria__c = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                nc.tipo__c = 'Estrutural';
                
                
                nc.RecordtypeId = '012U4000000uiPlIAI';     
                insert nc;
            } 
            
            
            
            //------------   não conformidade   --------------------        
            if(rs.x210__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                
                nc.N_o_conformidade__c = questoes[210];
                nc.Auditoria__c = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                nc.tipo__c = 'Processo';
                
                
                nc.RecordtypeId = '012U4000000uiPlIAI';     
                insert nc;
            }             
            
            
            //------------   não conformidade   --------------------        
            if(rs.x211__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                
                nc.N_o_conformidade__c = questoes[211];
                nc.Auditoria__c = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                nc.tipo__c = 'Processo';
                
                
                nc.RecordtypeId = '012U4000000uiPlIAI';     
                insert nc;
            }             
            
            
            //------------   não conformidade   --------------------        
            if(rs.x212__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                
                nc.N_o_conformidade__c = questoes[212];
                nc.Auditoria__c = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                nc.tipo__c = 'Processo';
                
                
                nc.RecordtypeId = '012U4000000uiPlIAI';     
                insert nc;
            }             
            
            
            //------------   não conformidade 213  --------------------        
            if(rs.x213__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                
                nc.N_o_conformidade__c = questoes[213];
                nc.Auditoria__c = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                nc.tipo__c = 'Documental';
                
                
                nc.RecordtypeId = '012U4000000uiPlIAI';     
                insert nc;
            }        
            
            
            //------------   não conformidade   --------------------        
            if(rs.x214__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                
                nc.N_o_conformidade__c = questoes[214];
                nc.Auditoria__c = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                nc.tipo__c = 'Processo';
                
                
                nc.RecordtypeId = '012U4000000uiPlIAI';     
                insert nc;
            }             
            
            
            //------------   não conformidade   --------------------        
            if(rs.x215__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                
                nc.N_o_conformidade__c = questoes[215];
                nc.Auditoria__c = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                nc.tipo__c = 'Estrutural';
                
                
                nc.RecordtypeId = '012U4000000uiPlIAI';     
                insert nc;
            }             
            
            //------------   não conformidade   --------------------  
            
            if(rs.x216__c == false){
                Nao_Conformidade__c nc = new Nao_Conformidade__c();
                
                nc.N_o_conformidade__c = questoes[216];
                nc.Auditoria__c = rs.id;
                nc.Data_de_Abertura_do_RNC__c = Date.today();
                nc.tipo__c = 'Estrutural';
                
                
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
            
        } 
    }
}