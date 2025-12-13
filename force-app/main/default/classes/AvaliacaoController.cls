public with sharing class AvaliacaoController {
    
    public Boolean panel 				{get;set;}
    public boolean AgeralB				{get;set;}
    public boolean AenfermagemB			{get;set;}
    public boolean AfisioterapiaB		{get;set;}
    public boolean AfonoaudiologiaB		{get;set;}
    public boolean ApsicologiaB 		{get;set;}
    public boolean AmedicaB				{get;set;}
    public boolean AterapiaocupacB		{get;set;}
    public Boolean senhaincorreta		{get;set;}
    public Boolean valid				{get;set;}
    public Boolean displayPopUp			{get;set;}
    
    public String senha					{get;set;}
    public String email					{get;set;}
    public String nameAv				{get;set;}
           
    //Geral
    public datetime dataavgeral			{get;set;}
    public String prontuariog 			{get;set;}
	public String ordemAtendg			{get;set;}
    public String AIVD					{get;set;}
    public String AVD 					{get;set;}
    public String incpsiq 				{get;set;}
    public String viasaereas 			{get;set;}
    public String incontinencia 		{get;set;}
    public String usodemedicacao 		{get;set;}
    public String suporterespiratorio 	{get;set;}
    public String presencadeulcera 		{get;set;}
    public String reabilitacao 			{get;set;}
    public String terapianutric 		{get;set;}
    
    //enfermagem
    public String prontuarioEnf			{get;set;}
	public String ordemAtendEnf			{get;set;}
    public datetime datavaliacaoenf		{get;set;}
    public Boolean acessoesgoto 		{get;set;}
    public Boolean ambientelimpo 		{get;set;}
    public Boolean ambientearejado 		{get;set;}
    public Boolean ambienteorganizado 	{get;set;}
    public String aberturaocular 		{get;set;}
    public String respostaverbal 		{get;set;}
    public String repostamotora 		{get;set;}
    public String sedacao 				{get;set;}
    public String isocoricas 			{get;set;}
    public String midriase 				{get;set;}
    public String anisocoricas 			{get;set;}
    public String reflexofotomotor 		{get;set;}
    public String miose 				{get;set;}
    public String respespontanea 		{get;set;}
    public String tuboorotraq 			{get;set;}
    public String traquesotomia 		{get;set;}
    public String usodeO2 				{get;set;}
    public String usodeO2lmin 			{get;set;}
    public String modo 					{get;set;}
    public String fio2 					{get;set;}
    public String volumecorrente 		{get;set;}
    public String pressaoinsp 			{get;set;}
    public String peep 					{get;set;}
    public String pulmaodireito 		{get;set;}
    public String pulmaodireito2 		{get;set;}
    public String pulmaoesquerdo 		{get;set;}
    public String pulmaoesquerdo2 		{get;set;}
    public String frequenciacardiaca 	{get;set;}
    public String pressaoarterial 		{get;set;}
    public String ritmocardiaco 		{get;set;}
    public String ausculta 				{get;set;}
    public String marcapasso 			{get;set;}
    public String perfusao 				{get;set;}
    public String dieta 				{get;set;}
    public String sonda 				{get;set;}
    public String abdome 				{get;set;}
    public String ruidoshidro 			{get;set;}
    public String diurese 				{get;set;}
    public String evacuacao 			{get;set;}
    public String retencao 				{get;set;}
    public String evacuacao2 			{get;set;}
    public String aspectourina 			{get;set;}
    public String dor 					{get;set;}
    public String escalador 			{get;set;}
    public String peleemucosas 			{get;set;}
    public String edemalocal 			{get;set;}
    public String dreno 				{get;set;}
    public String drenolocal 			{get;set;}
    public String cateteres 			{get;set;}
    public String catetereslocal 		{get;set;}
    public String obs 					{get;set;}
    
    //fisioterapia
    public datetime dataavfisio			{get;set;}
    public String prontuariofisio		{get;set;}
    public String ordemAtendFisio		{get;set;}
    public String estadogeral 			{get;set;}
    public String temperaturaf 			{get;set;}
    public String hidratacao 			{get;set;}
    public String hidratacao2 			{get;set;}
    public String mucosa 				{get;set;}
    public String mucosa2 				{get;set;}
    public String pressaoart 			{get;set;}
    public String FC 					{get;set;}
    public String FR 					{get;set;}
    public String SPO2F 				{get;set;}
    public String O2F 					{get;set;}
    public String obsF 					{get;set;}
    public List <String> antecpessoais 	{get;set;}
    public String grauorient 			{get;set;}
    public String estadoemocional 		{get;set;}
    public String plegia 				{get;set;}
    public String monoplegia 			{get;set;}
    public String paresia 				{get;set;}
    public String monoparesia			{get;set;}
    public String nivelconsc 			{get;set;}
    public String obsF2 				{get;set;}
    public String padraovent 			{get;set;}
    public String tosse 				{get;set;}
    public String traqueostomia 		{get;set;}
    public String traqueostomia2 		{get;set;}
    public String traqueostomia3 		{get;set;}
    public String auscultapulmonar 		{get;set;}
    public String expansibilidade 		{get;set;}
    public String dispneiaMRC 			{get;set;}
    public String cianose 				{get;set;}
    public String cianose2 				{get;set;}
    public String secrecao 				{get;set;}
    public String secrecaocor 			{get;set;}
    public String necessidadeasp 		{get;set;}
    public string naspiracoes 			{get;set;}
    public String nsonda 				{get;set;}
    public String localaspiracao 		{get;set;}
    public String dispRespiratorios 	{get;set;}
    public String usodeoxigenio 		{get;set;}
    public String usodeoxigeniolmin 	{get;set;}
    public String usodeoxigeniohdia 	{get;set;}
    public String ventilacaomec 		{get;set;}
    public String ventilador 			{get;set;}
    public String modoF 				{get;set;}
    public String Pins 					{get;set;}
    public String PEEPf 				{get;set;}
    public String vtF 					{get;set;}
    public String frF 					{get;set;}
    public String obsF3 				{get;set;}
    public String mobilidade 			{get;set;}
    public String sensibilidade 		{get;set;}
    public String edemaF 				{get;set;}
    public String edemalocalF 			{get;set;}
    public String marcha 				{get;set;}
    public String descricao 			{get;set;}
    public String ADM 					{get;set;}
    public String tonus 				{get;set;}
    public String cervical 				{get;set;}
    public String tronco				{get;set;}
    public String MSD 					{get;set;}
    public String MSE 					{get;set;}
    public String MID 					{get;set;}
    public String MIE 					{get;set;}
    public String obsF4 				{get;set;}
    public String curtoprazoF 			{get;set;}
    public String medioprazoF 			{get;set;}
    public String longoprazoF 			{get;set;}
    
    //fonoaudiologia
    public String prontuariofono    	{get;set;}
	public String ordemAtendfono		{get;set;} 
    public datetime dataavaliacaofono 	{get;set;}
    public String brevehist 			{get;set;}
    public String sinalvital 			{get;set;}
    public String sinalvital2 			{get;set;}
    public String sinalvital3 			{get;set;}
    public String nivelatencao 			{get;set;}
    public String repouso 				{get;set;}
    public String modofono 				{get;set;}
    public String setqt 				{get;set;}
    public String ventilacaofono 		{get;set;}
    public String dependencia 			{get;set;}
    public String senecessario1 		{get;set;}
    public String sinaisfadiga 			{get;set;}
    public String auscultacerv 			{get;set;}
    public String expressao 			{get;set;}
    public String compreensao 			{get;set;}
    public String fala 					{get;set;}
    public String loudnes 				{get;set;}
    public String pitch 				{get;set;}
    public String qualidade 			{get;set;}
    public String ressonancia 			{get;set;}
    public String face 					{get;set;}
    public String labios 				{get;set;}
    public String lingua 				{get;set;}
    public String bochecha 				{get;set;}
    public String palatomole 			{get;set;}
    public String mandibula 			{get;set;}
    public String denticao 				{get;set;}
    public String laringe 				{get;set;}
    public String salivacao 			{get;set;}
    public String higienizacao 			{get;set;}
    public String viaalimentacao 		{get;set;}
    public String degluticao 			{get;set;}
    public String tossefono 			{get;set;}
    public String reflexospat 			{get;set;}
    public String avaliacaodiretadeg 	{get;set;}
    public String comunicacao 			{get;set;}
    public String motricidade 			{get;set;}
    public String degluticaopard 		{get;set;}
    public String FOIS 					{get;set;}
    public String fala2 				{get;set;}
    public String comunicacao2 			{get;set;}
    public String degluticao2 			{get;set;}
    public String curtoprazofono		{get;set;}
    public String medioprazofono 		{get;set;}
    public String longoprazofono		{get;set;}
    
    //medica
    public String prontuariomed			{get;set;}
	public String ordemAtendmed			{get;set;}
    public datetime dataavmed 			{get;set;}
    public String especialidade 		{get;set;}
    public String histmolestia 			{get;set;}
    public List <String> comorbidades	{get;set;}
    public String outrascomorbidades 	{get;set;}
    public String alergia 				{get;set;}
    public String reconcmedic 			{get;set;}
    public String PAmed 				{get;set;}
    public String FCmed 				{get;set;}
    public String FRmed 				{get;set;}
    public String glasgow 				{get;set;}
    public String SPO2Med 				{get;set;}
    public String ausccard 				{get;set;}
    public String auscpulm 				{get;set;}
    public String neurologia 			{get;set;}
    public String geralmed 				{get;set;}
    public String respiratorio 			{get;set;}
    public String apcardiovasc 			{get;set;}
    public String membrosepele 			{get;set;}
    public String apdigestorio 			{get;set;}
    public String dispositivos 			{get;set;}
    public String creatinina 			{get;set;}
    public String hemoglobina 			{get;set;}
    public String leucocitos 			{get;set;}
    public String plaquetas 			{get;set;}
    public String PCR 					{get;set;}
    public String sodio 				{get;set;}
    public String potassio				{get;set;}
    public String outroslab 			{get;set;}
    public String RX 					{get;set;}
    public String TC 					{get;set;}
    public String RNM 					{get;set;}
    public String US 					{get;set;}
    public String outrosimg 			{get;set;}
    public String obsMed 				{get;set;}
    public String hipdiag 				{get;set;}
    public String prescmedic 			{get;set;}
    public String prescexam 			{get;set;}
    public String conduta 				{get;set;}
    public String curtoprazomed 		{get;set;}
    public String medioprazomed 		{get;set;}
    public String longoprazomed 		{get;set;}
    
    //psicologia
    public datetime datavaliacaopsic 	{get;set;}
    public String prontuariopsic		{get;set;}
    public String ordemAtendPsic		{get;set;}
    public String biopsicossocial		{get;set;}
    public String teminfodiag			{get;set;}
    public String compreensaodiag		{get;set;}
    public String expecfamilia			{get;set;}
    public String especificarexpect		{get;set;}
    public String etilista				{get;set;}
    public String seSimEtilista			{get;set;}
    public String freqUsoEtil			{get;set;}
    public String tentPararEtilista		{get;set;}
    public String seSimTentPararEtil	{get;set;}
    public String conseqsociofam1		{get;set;}
    public String seSimConseqsocio1		{get;set;}
    public String tabagista 			{get;set;}
    public String seSimTabagista		{get;set;}
    public String freqUsoTabag			{get;set;}
    public String tentPararTabag		{get;set;}
    public String seSimTentPararTabag	{get;set;}
    public String conseqsociofam2		{get;set;}
    public String especifConseqSocio	{get;set;}
    public String drogailicita			{get;set;}
    public String seSimDrogaIlicita		{get;set;}
    public String freqUsoDroga			{get;set;}
    public String tentPararDroga		{get;set;}
    public String seSimTentPararDroga 	{get;set;}
    public String conseqsociofam3		{get;set;}
    public String seSimEspecifConseq3	{get;set;}
    public String paciente				{get;set;}
    public List <String> seSimPaciente	{get;set;}
    public String especificarPaciente	{get;set;}
    public String familiar		 		{get;set;}
    public List <String> seSimFamiliar	{get;set;}
    public String especificarFamiliar	{get;set;}
    public String tratpsicologico 		{get;set;}
    public String seSimTratPsico 		{get;set;}
    public String tratPsiquiatrico 		{get;set;}
    public String seSimTratPsiqui 		{get;set;}
    public String tentativasExt 		{get;set;}
    public String seSimTentExt	 		{get;set;}
    public String suicTentFamilia 		{get;set;}
    public String previoadoecimento		{get;set;}
    public String seSimPrevAdoec 		{get;set;}
    public String aposadoecimento		{get;set;}
    public String seSimAposAdoec 		{get;set;}
    public String alteracaosono 		{get;set;}
    public String b134			 		{get;set;}
    public String seSimAltSono	 		{get;set;}
    public String outroAltSono			{get;set;}
    public String quandoAltSono 		{get;set;}
    public String alteracaoapetite 		{get;set;}
    public String b13402		 		{get;set;}
    public String seSimAltApetite		{get;set;}
    public String outroAltApetite 		{get;set;}
    public String quandoAltApetite 		{get;set;}
    public String usoPrevMedPsiq		{get;set;}
    public String seSimUsoPrevMP 		{get;set;}
    public String sequelasEmocion 		{get;set;}
    public String seSimSequelas 		{get;set;}
    public String conscClinica	 		{get;set;}
    public String orientAlopsiquic 		{get;set;}
    public String orientAutopsiquic		{get;set;}
    public String b156			 		{get;set;}
    public String sensoPercepcao 		{get;set;}
    public String b160			 		{get;set;}
    public String comunicacaoPsic 		{get;set;}
    public String pensamento	 		{get;set;}
    public String seDelirio		 		{get;set;}
    public String afetividade	 		{get;set;}
    public String motivacao		 		{get;set;}
    public String b1301			 		{get;set;}
    public String estrategias	 		{get;set;}
    public String autoconceito	 		{get;set;}
    public String estadoAtual	 		{get;set;}
    public List <String> manifestPsiqui	{get;set;}
    public String principaisCuidad 		{get;set;}
    public String seSimPrincpCuid 		{get;set;}
    public String postura		 		{get;set;}
    public String conflitofamiliar 		{get;set;}
    public String seSimConflitoFam		{get;set;}
    public String estadoatual2	 		{get;set;}
    public String suporteOperac 		{get;set;}
    public String e310oue315	 		{get;set;}
    public String suporteEmoc	 		{get;set;}
    public String e310oue315_2			{get;set;}
    public String principaisRiscos 		{get;set;}
    public String outrosRiscos	 		{get;set;}
    public String foramObsRiscos 		{get;set;}
    public String riscoPsicPaciente		{get;set;}
    public String familiaDemandaAcomp	{get;set;}
    
    //terapia ocupacional
    public datetime dataavterapocup		{get;set;}
    public String prontuarioTO			{get;set;}
    public String ordemAtendTO 			{get;set;}
    public String medidaindepend		{get;set;}
    public Decimal alimentar 			{get;set;}
    public Decimal arrumar 				{get;set;}
    public Decimal banhar 				{get;set;}
    public Decimal vestirsup 			{get;set;}
    public Decimal vestirinf 			{get;set;}
    public Decimal higienepess 			{get;set;}
    public Decimal controlevesical 		{get;set;}
    public Decimal controleintest 		{get;set;}
    public Decimal leito 				{get;set;}
    public Decimal sanitario 			{get;set;}
    public Decimal banheiro				{get;set;}
    public Decimal marchaCad 			{get;set;}
    public Decimal escadas 				{get;set;}
    public Decimal abrangencia 			{get;set;}
    public Decimal expressaoTO 			{get;set;}
    public Decimal interacao 			{get;set;}
    public Decimal resolucao 			{get;set;}
    public Decimal memoria 				{get;set;}
    public String curtoprazoTo 			{get;set;}
    public String medioprazoTo 			{get;set;}
    public String longoprazoTo 			{get;set;}
    
    public AvaliacaoController(){
        AgeralB = false;
        AenfermagemB = false;
        AfisioterapiaB = false;
        AfonoaudiologiaB = false;
        AmedicaB = false;
        ApsicologiaB = false;
        AterapiaocupacB = false;
        panel= false;
        valid = true;
        displayPopUp = false;
    }
    public void validar(){
        if(senha == '6jgf4fwt'){
            panel = true;
            valid = false;
        }
        else{
            senhaincorreta = true;
        }
    }           
    public void Ageral(){
        AgeralB = true;
        panel = false;
    }
    public void Aenfermagem(){
        AenfermagemB = true;
        panel = false;
    }
    public void Afisioterapia(){
        AfisioterapiaB = true;
        panel = false;

    }
    public void Afonoaudiologia(){
        AfonoaudiologiaB = true;
        panel = false;

    }
    public void Amedica(){
        AmedicaB = true;
        panel = false;

    }
	public void Apsicologia(){
        ApsicologiaB = true;
        panel = false;

    }    
    public void Aterapiaocupac(){
        AterapiaocupacB = true;
        panel = false;
    }
    public void creategeral(){
    
        Avaliacao__c geral = new Avaliacao__c();
        
        geral.Data_e_Hora_da_Avaliacao__c = dataavgeral;
        geral.Profissional_Responsavel__c = email;
		geral.ProntuarioExt__c = prontuariog;
        geral.Ordem_de_AtendimentoExt__c = ordemAtendg;
        geral.AIVD_geral__c = AIVD;
        geral.AVDs_geral__c = AVD;
        geral.Incapacidade_geral__c = incpsiq;
        geral.Vias_Aereas_Superiores_geral__c = viasaereas;
        geral.Incontinencia_geral__c = incontinencia;
        geral.Uso_de_Medicacao_geral__c = usodemedicacao;
        geral.Suporte_Respirat_rio_geral__c = suporterespiratorio;
        geral.Presenca_de_ulcera_geral__c = presencadeulcera;
        geral.Reabilitacao_geral__c = reabilitacao;
        geral.Terapia_Nutricional_geral__c = terapianutric;
        geral.RecordTypeId = '0125A000001Yb6bQAC'; 
        
        insert geral;
               	
        nameAv = geral.Id;
        displayPopUp = true;
        
    }
    public void createenfermagem(){
    
        Avaliacao__c enfermagem = new Avaliacao__c();
        
        enfermagem.ProntuarioExt__c = prontuarioEnf;
        enfermagem.Profissional_Responsavel__c = email;
        enfermagem.Ordem_de_AtendimentoExt__c = ordemAtendEnf;
        enfermagem.RecordTypeId = '0125A000001Yb62';
        enfermagem.Data_e_Hora_da_Avaliacao__c = datavaliacaoenf;
        enfermagem.Acesso_a_rede_deagua_enfermagem__c = acessoesgoto;
        enfermagem.Ambiente_Limpo_Enfermagem__c = ambientelimpo;
        enfermagem.Ambiente_Arejado_Enfermagem__c = ambientearejado;
        enfermagem.Ambiente_Organizado_Enfermagem__c = ambienteorganizado;	
        enfermagem.Abertura_ocular_Enfermagem__c = aberturaocular;
        enfermagem.Resposta_verbal_Enfermagem__c = respostaverbal;
        enfermagem.Resposta_motora_enfermagem__c = repostamotora;
        enfermagem.Sedacao_Enfermagem__c = sedacao;
        enfermagem.Isocoricas_Enfermagem__c = isocoricas;
        enfermagem.Midriase_Enfermagem__c = midriase;
        enfermagem.Anisocoricas_Enfermagem__c = anisocoricas;
        enfermagem.Reflexo_fotomotor_Enfermagem__c = reflexofotomotor;
        enfermagem.Miose_Enfermagem__c = miose;
        enfermagem.Respiracao_espontanea_Enfermagem__c = respespontanea;
        enfermagem.Tubo_orotraqueal_Enfermagem__c = tuboorotraq;
        enfermagem.Traqueostomia_Enfermagem__c = traquesotomia;
        enfermagem.Uso_de_O2_Enfermagem__c = usodeO2;
        enfermagem.Uso_de_O2L_Enfermagem__c = usodeO2lmin;
        enfermagem.Modo_Enfermagem__c = modo;
        enfermagem.FiO2_Enfermagem__c = fio2;
        enfermagem.Volume_corrente_Enfermagem__c = volumecorrente;
        enfermagem.Pressao_inspiratoria_Enfermagem__c = pressaoinsp;
        enfermagem.PEEP_cmH2O_Enfermagem__c = peep;
        enfermagem.Pulmao_direito_murm_Enfermagem__c = pulmaodireito;
        enfermagem.Pulmao_direito_Ruidos_Enfermagem__c = pulmaodireito2;
        enfermagem.Pulmao_esquerdo_murm_Enfermagem__c = pulmaoesquerdo;
        enfermagem.Pulmao_esquerdo_Ruidos_Enfermagem__c = pulmaoesquerdo2;
        enfermagem.Frequencia_cardiaca_Enfermagem__c = frequenciacardiaca;
        enfermagem.Pressao_aterial_Enfermagem__c = pressaoarterial;
        enfermagem.Ritmo_cardiaco_Enfermagem__c = ritmocardiaco;
        enfermagem.Ausculta_Enfermagem__c = ausculta;
        enfermagem.Marcapasso_cardiaco_Enfermagem__c = marcapasso;
        enfermagem.Perfusao_periferica_Enfermagem__c = perfusao;
        enfermagem.Dieta_Enfermagem__c = dieta;
        enfermagem.Sonda_Enfermagem__c = sonda;
        enfermagem.Abdome_Enfermagem__c = abdome;
        enfermagem.Ruidos_hidroaereos_Enfermagem__c = ruidoshidro;
        enfermagem.Diurese_Enfermagem__c = diurese;
        enfermagem.Evacuacao_Enfermagem__c = evacuacao;
        enfermagem.Retencao_urinaria_Enfermagem__c = retencao;
        enfermagem.Evacuacao_Outro_Enfermagem__c = evacuacao2;
        enfermagem.Aspecto_da_urina_Enfermagem__c = aspectourina;
        enfermagem.Dor_Enfermagem__c = dor;
        enfermagem.Escala_de_dor_Enfermagem__c = escalador;
        enfermagem.Pele_e_mucosas_Enfermagem__c = peleemucosas;
        enfermagem.Edema_Local_caso_se_aplique_Enfermagem__c = edemalocal;
        enfermagem.Dreno_Enfermagem__c = dreno;
        enfermagem.Dreno_Local_Enfermagem__c = drenolocal;
        enfermagem.Cateteres_Enfermagem__c = cateteres;
        enfermagem.Cateteres_Local_Enfermagem__c = catetereslocal;
        enfermagem.Observacoes_Enfermagem__c = obs;
        
        insert enfermagem;
        
        nameAv = enfermagem.Id;
        displayPopUp = true;
        
    }

    public void createfisioterapia(){
    
        Avaliacao__c fisio = new Avaliacao__c();
        
        fisio.ProntuarioExt__c = prontuariofisio;
        fisio.Profissional_Responsavel__c = email;
        fisio.Ordem_de_AtendimentoExt__c = ordemAtendFisio;
        fisio.Data_e_Hora_da_Avaliacao__c = dataavfisio;
        fisio.RecordTypeId = '0125A000001Yb5d';
        fisio.Estado_Geral_Fisioterapia__c = estadogeral;
        fisio.Temperatura_C_Fisioterapia__c = temperaturaf;
        fisio.Hidratacao_Fisioterapia__c = hidratacao;
        fisio.Hidrata_o_Indicar_Fisioterapia__c = hidratacao2;
        fisio.Mucosa_Fisioterapia__c = mucosa;
        fisio.Mucosa_Indicar_Fisioterapia__c = mucosa2;
        fisio.Pressao_arterial_fisioterapia__c = pressaoart;
        fisio.FC_BPM_Fisioterapia__c = FC;
        fisio.FR_Ipm_Fisioterapia__c = FR;
        fisio.SPO2_fisioterapia__c = SPO2F;
        fisio.O2_fisioterapia__c = O2F;
        fisio.Observa_es_Fisioterapia__c = obsF;
        fisio.Antecedentes_Pessoais_Fisioterapia__c = String.join(antecpessoais, ';');
        fisio.Grau_de_Orienta_o_fisioterapia__c = grauorient;
        fisio.Estado_Emocional_Fisioterapia__c = estadoemocional;
        fisio.Plegia_Fisioterapia__c = plegia;
        fisio.Monoplegia_fisioterapia__c = monoplegia;
        fisio.Paresia_Fisioterapia__c = paresia;
        fisio.Monoparesia_Fisioterapia__c = monoparesia;
        fisio.Nivel_de_Consciencia_Fisioterapia__c = nivelconsc;
        fisio.Observacoes2_Fisioterapia__c = obsF2;
        fisio.Padrao_Ventilatorio_Fisioterapia__c = padraovent;
        fisio.Tosse_Fisioterapia__c = tosse;
        fisio.Traqueostomia_Fisioterapia__c = traqueostomia;
        fisio.Traqueostomia2_Fisioterapia__c = traqueostomia2;
        fisio.Traqueostomia_Condi_es_Fisioterapia__c = traqueostomia3;
        fisio.Ausculta_Pulmonar_Fisioterapia__c = auscultapulmonar;
        fisio.Expansibilidade_Fisioterapia__c = expansibilidade;
        fisio.Dispn_ia_MRC_Fisioterapia__c = dispneiaMRC;
        fisio.Cianose_Fisioterapia__c = cianose;
        fisio.Cianose_Indicar_Fisioterapia__c = cianose2;
        fisio.Secrecao_Fisioterapia__c = secrecao;
        fisio.Secrecao_Cor_Fisioterapia__c = secrecaocor;
        fisio.Necessidade_de_aspiracap_Fisioterapia__c = necessidadeasp;
        fisio.N_de_Aspiracoes_Fisioterapia__c = naspiracoes;
        fisio.N_Sonda_Fisioterapia__c = nsonda;
        fisio.Local_da_aspiracao_Fisioterapia__c = localaspiracao;
        fisio.DispositivosRespiratorios_Fisioterapia__c = dispRespiratorios;
        fisio.Uso_de_Oxigenio_Fisioterapia__c = usodeoxigenio;
        fisio.Uso_de_Oxig_nio_3_Fisioterapia__c = usodeoxigeniolmin;
        fisio.Uso_de_Oxig_nio_2_Fisioterapia__c = usodeoxigeniohdia;
        fisio.Ventila_o_Mecanica_Fisioterapia__c = ventilacaomec;
        fisio.Ventilador__c = ventilador;
        fisio.Modo_Fisioterapia__c = modoF;
        fisio.Pins_Fisioterapia__c = Pins;
        fisio.PEEP__c = PEEPf;
        fisio.VT_Fisioterapia__c = vtF;
        fisio.FR_fisioterapia__c = frF;
        fisio.Observacoes3_Fisioterapia__c = obsF3;
        fisio.Mobilidade_Fisioterapia__c = mobilidade;
		fisio.Sensibilidade_Fisioterapia__c = sensibilidade;
		fisio.Edema_Fisioterapia__c = edemaF;
		fisio.Edema_Local_Fisioterapia__c = edemalocalF;
        fisio.Marcha_fisioterapia__c = marcha;
        fisio.Marcha_Descricao_Fisioterapia__c = descricao;
        fisio.ADM_Fisioterapia__c = ADM;
        fisio.Tonus_Ashwoth_Fisioterapia__c = tonus;
        fisio.Cervical_Fisioterapia__c = cervical;
        fisio.Tronco_Fisioterapia__c = tronco;
        fisio.MSD_Fisioterapia__c = MSD;
        fisio.MSE_Fisioterapia__c = MSE;
        fisio.MID_Fisioterapia__c = MID;
        fisio.MIE_Fisioterapia__c = MIE;
        fisio.Observacoes4_Fisioterapia__c = obsF4;
        fisio.Curto_Prazo__c = curtoprazoF;
        fisio.Medio_Prazo__c = medioprazoF;
        fisio.Longo_Prazo__c = longoprazoF;
        
        insert fisio;
        
        nameAv = fisio.Id;
        displayPopUp = true;
        
    }
    public void createfonoaudiologia(){
    
        Avaliacao__c fono = new Avaliacao__c();
        
        fono.RecordTypeId = '0125A000001Yb5i';
        fono.Profissional_Responsavel__c = email;
        fono.ProntuarioExt__c = prontuariofono;
        fono.Ordem_de_AtendimentoExt__c = ordemAtendfono;
        fono.Data_e_Hora_da_Avaliacao__c = dataavaliacaofono;
        fono.Breve_hist_rico_Fonoaudiologia__c = brevehist;
        fono.Sinal_vital_FC_Fonoaudiologia__c = sinalvital;
        fono.Sinal_vital_FR_Fonoaudiologia__c = sinalvital2;
        fono.Sinal_vital_SPO2_Fonoaudiologia__c = sinalvital3;
        fono.N_vel_de_aten_o_Fonoaudiologia__c	 = nivelatencao;
        fono.Repouso_Fonoaudiologia__c = repouso;
        fono.Modo_Fonoaudiologia__c = modofono;
        fono.Se_Traqueostomia_qual_Fonoaudiologia__c = setqt;
        fono.Ventila_o_2_Fonoaudiologia__c = ventilacaofono;
        fono.Depend_ncia_Fonoaudiologia__c = dependencia;
        fono.Se_necess_rio_qual_volume_Fonoaudiologia__c = senecessario1;
        fono.Sinais_de_fadiga_Fonoaudiologia__c = sinaisfadiga;
        fono.Ausculta_Cervical_Fonoaudiologia__c = auscultacerv;
        fono.Express_o_Fonoaudiologia__c = expressao;
        fono.Compreens_o_Fonoaudiologia__c = compreensao;
        fono.Fala_Fonoaudiologia__c = fala;
        fono.Loudnes_Fonoaudiologia__c = loudnes;
        fono.Pitch_Fonoaudiologia__c = pitch;
        fono.Qualidade_Fonoaudiologia__c = qualidade;
        fono.Ressonancia_Fonoaudiologia__c = ressonancia;
        fono.Face_Fonoaudiologia__c = face;
        fono.L_bios_Fonoaudiologia__c = labios;
        fono.L_ngua_Fonoaudiologia__c = lingua;
        fono.Bochecha_Fonoaudiologia__c = bochecha;
        fono.Palato_mole_Fonoaudiologia__c = palatomole;
        fono.Mand_bula_Fonoaudiologia__c = mandibula;
        fono.Denti_o_Fonoaudiologia__c = denticao;
        fono.Laringe_Fonoaudiologia__c = laringe;
        fono.Saliva_o_Fonoaudiologia__c = salivacao;
        fono.Higieniza_o_oral_Fonoaudiologia__c = higienizacao;
        fono.Via_de_alimenta_o_2_Fonoaudiologia__c = viaalimentacao;
        fono.Degluti_o_2_Fonoaudiologia__c = degluticao;
        fono.Tosse_Fonoaudiologia__c = tossefono;
        fono.Reflexos_patol_gicos_Fonoaudiologia__c = reflexospat;
        fono.Avalia_o_direta_de_deglu_Fonoaudiologia__c = avaliacaodiretadeg;
        fono.Comunica_o_2_Fonoaudiologia__c = comunicacao;
        fono.Motricidade_orofacial_Fonoaudiologia__c = motricidade;
        fono.Degluti_o_PARD_Fonoaudiologia__c = degluticaopard;
        fono.FOIS_Fonoaudiologia__c = FOIS;
        fono.Fala_2_Fonoaudiologia__c = fala2;
        fono.Comunica_o_3_Fonoaudiologia__c = comunicacao2;
        fono.Degluti_o_3_Fonoaudiologia__c = degluticao2;
        fono.Curto_Prazo__c = curtoprazofono;
        fono.Medio_Prazo__c = medioprazofono;
        fono.Longo_Prazo__c = longoprazofono;
      
        insert fono;
        
        nameAv = fono.Id;
        displayPopUp = true;
    }
    
    public void createmedica(){
        
        Avaliacao__c med = new Avaliacao__c();
        
        med.RecordTypeId = '0125A000001Yb5x';
        med.Profissional_Responsavel__c = email;
        med.ProntuarioExt__c = prontuariomed;
        med.Ordem_de_AtendimentoExt__c = ordemAtendmed;
		med.Data_e_Hora_da_Avaliacao__c = dataavmed;
        med.Especialidade_Medica__c = especialidade;
        med.Historia_da_Molestia_Medica__c = histmolestia;
        med.Comorbidades_Medica__c = String.join(comorbidades, ';');
       	med.Outras_comorbidades_medica__c = outrascomorbidades;
        med.Alergia_Medica__c = alergia;
        med.Reconciliacao_Medicamentosa__c = reconcmedic;
        med.PA__c = PAmed;
        med.FR_Medica__c = FRMed;
        med.FC_Medica__c = FCmed;
        med.Glasgow_Medica__c = glasgow;
        med.SPO2_Medica__c = SPO2Med;
        med.Ausculta_Cardiaca_Medica__c = ausccard;
       	med.Ausculta_Pulmonar_Medica__c = auscpulm;
        med.Neurologia__c = neurologia;
        med.Geral_Medica__c = geralmed;
        med.Respiratorio_Medica__c = respiratorio;
        med.Ap_Cardiovascular_Medica__c = apcardiovasc;
        med.Membros_e_pele_medica__c = membrosepele;
        med.Ap_Digestorio_Medica__c = apdigestorio;
        med.Dispositivos_Medica__c = dispositivos;
        med.Creatinina_Medica__c = creatinina;
        med.Hemoglobina_Medica__c = hemoglobina;
        med.Leucocitos_Medica__c = leucocitos;
        med.Plaquetas_Medica__c = plaquetas;
        med.PCR_Medica__c = PCR;
        med.Sodio_Medica__c = sodio;
        med.Potassio_Medica__c = potassio;
        med.Outros__c = outroslab;
        med.RX_Medica__c = RX;
        med.TC_Medica__c = TC;
        med.RNM_Medica__c = RNM;
        med.US_Medica__c = US;
        med.ExamesImagemOutros_Medica__c = outrosimg;
		med.Observacoes_Medica__c = obsMed;
		med.Hipotese_Diag_Medica__c = hipdiag;
	    med.Prescricao_Medicamentosa__c = prescmedic;
        med.Prescricao_de_Exames_Medica__c = prescexam;
        med.Conduta_Medica__c = conduta;
        med.Curto_Prazo__c = curtoprazomed;
        med.Medio_Prazo__c = medioprazomed;
        med.Longo_Prazo__c = longoprazomed;
        
        insert med;
        
        nameAv = med.Id;
        displayPopUp = true;
        
    }
    
    public void createPsicologia(){
        
        Avaliacao__c psico = new Avaliacao__c();
        
        psico.RecordTypeId = '0125A000001Yb5n';
        psico.Profissional_Responsavel__c = email;
        psico.ProntuarioExt__c = prontuariopsic;
        psico.Ordem_de_AtendimentoExt__c = ordemAtendpsic;
        psico.Data_e_Hora_da_Avaliacao__c = datavaliacaopsic;
        psico.Hist_ria_biopsicossocial_Psicologia__c = biopsicossocial;
        psico.Tem_informa_es_sobre_o_diagn_stico_Psico__c = teminfodiag;
        psico.Compreenso_do_diagnstico_Psicologia__c = compreensaodiag;
        psico.Expectativas_da_fam_lia_para_iPsicologia__c = expecfamilia;
        psico.Especificar_expectativas_Psicologia__c = especificarexpect;
        psico.Etilista_Psicologia__c = etilista;
        psico.Se_sim_Etilista_Psicologia__c = seSimEtilista;
        psico.Frequ_ncia_de_uso_Psicologia__c = freqUsoEtil;
        psico.Tentativas_de_parar_Psicologia__c = tentPararEtilista;
        psico.Se_sim_especificar_parar_Psicologia__c = seSimTentPararEtil;
        psico.Consequ_ncias_s_cio_familiare_Psicologia__c = conseqsociofam1;
        psico.Se_sim_especificar_Consequ_Psicologia__c = seSimConseqsocio1;
        psico.Tabagista_Psicologia__c = tabagista;
        psico.Se_sim_Tabagista_Psicologia__c = seSimTabagista;
        psico.Frequ_ncia_de_uso_Tabagista_Psicologia__c = freqUsoTabag;
        psico.Tentativas_de_parar_Tabagista_Psicologi__c = tentPararTabag;
        psico.Especificar_Tabagista_Psicologia__c = seSimTentPararTabag;
        psico.Consequ_familiares_Tabagista_Psicologia__c = conseqsociofam2;
        psico.Especificar2_Tabagista_Psicologia__c = especifConseqSocio;
        psico.Droga_il_cita_Psicologia__c = drogailicita;
        psico.Se_sim_Droga_Psicologia__c = seSimDrogaIlicita;
        psico.Frequ_ncia_de_uso_Droga_Psicologia__c = freqUsoDroga;
        psico.Tentativas_de_parar_Droga_Psicologia__c = tentPararDroga;
        psico.Se_sim_especificar_para_Droga_Psicologia__c = seSimTentPararDroga;
        psico.Consequ_familiares_Droga_Psicologia__c = conseqsociofam3;
        psico.Se_sim_espec_Consequ_Droga_Psicologia__c = seSimEspecifConseq3;
        psico.Paciente_Psicologia__c = paciente;
        psico.Se_sim_Paciente_Psicologia__c = String.join(seSimPaciente, ';');
        psico.Especificar_Paciente_Psicologia__c = especificarPaciente;
        psico.Familiar_Psicologia__c = familiar;
        psico.Se_sim_Familiar_Psicologia__c = String.join(seSimFamiliar, ';');
        psico.Especificar_Familiar_Psicologia__c = especificarFamiliar;
        psico.Tratamento_psicol_gico_paciente_Psicolog__c = tratpsicologico;
        psico.Se_sim_especificar_psico_paciente_Psicol__c = seSimTratPsico;
        psico.Tratamento_psiqui_trico_paciente_Psicolo__c = tratPsiquiatrico;
        psico.Se_sim_especificar_psiqui_Psicologia__c = seSimTratPsiqui;
        psico.Tentativas_de_autoexterm_nio_Psicologia__c = tentativasExt;
        psico.Se_sim_especificar_autoexterminio_Psicol__c = seSimTentExt;
        psico.Suic_dio_ou_tentativa_na_fam_lia_Psicolo__c = suicTentFamilia;
        psico.Pr_vios_ao_adoecimento_Psicologia__c = previoadoecimento;
        psico.Se_sim_especificar_previos_Psicologia__c = seSimPrevAdoec;
        psico.Ap_s_o_adoecimento_Psicologia__c = aposadoecimento;
        psico.Se_sim_especificar_apos_Psicologia__c = seSimAposAdoec;
        psico.Altera_o_do_sono_Psicologia__c = alteracaosono;
        psico.b134_sono_Psicologia__c = b134;
        psico.Se_sim_sono_Psicologia__c = seSimAltSono;
        psico.Outro_sono_Psicologia__c = outroAltSono;
        psico.Quando_sono_Psicologia__c = quandoAltSono;
        psico.Altera_o_do_apetite_Psicologia__c = alteracaoapetite;
        psico.b13402_apetite_Psicologia__c = b13402;
        psico.Se_sim_apetite_Psicologia__c = seSimAltApetite;
        psico.Outro_apetite_Psicologia__c = outroAltApetite;
        psico.Quando_apetite_Psicologia__c = quandoAltApetite;
        psico.Uso_pr_vio_de_medicamentos_Psicologia__c = usoPrevMedPsiq;
        psico.Se_sim_especificar_medicamentos_Psicolog__c = seSimUsoPrevMP;
        psico.Sequelas_emocionais_Psicologia__c = sequelasEmocion;
        psico.Se_sim_especificar_Sequelas_Psicologia__c = seSimSequelas;
        psico.Consci_ncia_cl_nica_ava_Psicologia__c = conscClinica;
        psico.Orienta_o_Alops_quica_Psicologia__c = orientAlopsiquic;
        psico.Orienta_o_Autops_quica_Psicologia__c = orientAutopsiquic;
        psico.b156_Pensamento_Psicologia__c = b156;
        psico.Senso_Percep_o_ava_Psicologia__c = sensoPercepcao;
        psico.b160_comunicacao_Psicologia__c = b160;
        psico.Comunica_o_Psicologia__c = comunicacaoPsic;
        psico.Pensamento_ava_Psicologia__c = pensamento;
        psico.Se_del_rio_qual_Psicologia__c = seDelirio;
        psico.Afetividade_humor_Psicologia__c = afetividade;
        psico.Motiva_o_e_voli_o2_Psicologia__c = motivacao;
        psico.b1301_motivacao_Psicologia__c = b1301;
        psico.Estrat_gias_de_enfrentamento_Psicologia__c = estrategias;
        psico.Autoconceito_Psicologia__c = autoconceito;
        psico.Estado_atual_a_doen_Psicologia__c = estadoAtual;
        psico.Manifesta_observadas_Psicologia__c = String.join(manifestPsiqui, ';');
        psico.Principais_cuidadores_Psicologia__c = principaisCuidad;
        psico.Se_sim_especificar_cuidadores_Psicologia__c = seSimPrincpCuid;
        psico.Postura_frente_aos_cuidados_Psicologia__c = postura;
        psico.Conflito_familiar_Psicologia__c = conflitofamiliar;
        psico.Se_sim_especificar_Conflito_Psicologia__c = seSimConflitoFam;
        psico.Estado_atual_frente_Psicologia__c = estadoatual2;
        psico.Suporte_operacional_Psicologia__c = suporteOperac;
        psico.e310_ou_e315_operacional_Psicologia__c = e310oue315;
        psico.Suporte_emocional_Psicologia__c = suporteEmoc;
        psico.e310_ou_e315_emocional_Psicologia__c = e310oue315_2;
        psico.Principais_riscos_observados_Psicologia__c = principaisRiscos;
        psico.Outros_riscos_Psicologia__c = outrosRiscos;
        psico.Foram_observados_riscos_Psicologia__c = foramObsRiscos;
        psico.Risco_Psicol_gico_do_Psicologia__c = riscoPsicPaciente;
        psico.Fam_lia_demanda_acompanhamento_Psicologi__c = familiaDemandaAcomp;
        
        insert psico;
        
        nameAv = psico.Id;
        displayPopUp = true;
    }
    
    public void createTerapiaOcup(){
        
        Avaliacao__c terap = new Avaliacao__c();
        
        terap.Data_e_Hora_da_Avaliacao__c = dataavterapocup;
        terap.Profissional_Responsavel__c = email;
        terap.ProntuarioExt__c = prontuarioTO;
        terap.Ordem_de_AtendimentoExt__c = ordemAtendTO;
        terap.RecordTypeId = '0125A000001Yb5s';
        terap.Medida_de_Independencia_TO__c = medidaindepend;
        terap.Alimentar_se_TO__c = alimentar;
        terap.Arrumar_se_TO__c = arrumar;
        terap.Banhar_se_TO__c = banhar;
        terap.Vestir_parte_superior_TO__c = vestirsup;
        terap.Vestir_parte_inferior_TO__c = vestirinf;
        terap.HigienePessoal_TO__c = higienepess;
        terap.Controle_Vesical_TO__c = controlevesical;
        terap.Controle_Intestinal_TO__c = controleintest;
        terap.Leito_Cadeira_TO__c = leito;
        terap.Sanitario_TO__c = sanitario;
        terap.Banheira_chuveiro_TO__c = banheiro;
        terap.Marcha_Cadeira_de_rodas_TO__c = marchaCad;
        terap.Escadas_TO__c = escadas;
        terap.Abrangencia_TO__c = abrangencia;
        terap.Expressao_TO__c = expressaoTO;
        terap.InteracaoSocial_TO__c = interacao;
        terap.Resolucao_de_problemas_TO__c = resolucao;
        terap.Memoria_TO__c = memoria;
        terap.Curto_Prazo__c = curtoprazoTo;
        terap.Medio_Prazo__c = medioprazoTo;
        terap.Longo_Prazo__c = longoprazoTo;
        
        insert terap;
        
        nameAv = terap.Id;
        displayPopUp = true;
    }
    public void nova(){
        
        	panel = true;
            AgeralB = false;
            AenfermagemB = false;
            AfisioterapiaB = false;
            AfonoaudiologiaB = false;
            ApsicologiaB = false;
            AmedicaB = false; 
            AterapiaocupacB = false;
            displayPopUp = false;
    }
}