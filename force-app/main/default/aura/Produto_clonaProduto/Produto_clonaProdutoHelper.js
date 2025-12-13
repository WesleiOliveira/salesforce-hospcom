({
    
    exibirAlerta : function(component, event, helper, type, title, message) {
        
        function formatarMoeda(input) {
    // Obtém o valor atual do input
    let valor = input.value;
  
    // Remove todos os caracteres que não sejam dígitos
    valor = valor.replace(/\D/g, '');
  
    // Formata o valor como uma string com ponto decimal e duas casas decimais
    valor = (valor / 100).toLocaleString('pt-BR', { style: 'currency', currency: 'BRL' });
  
    // Atualiza o valor do input
    input.value = valor;
}
        
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type" : type,
            "title": title,
            "message": message
        });
        toastEvent.fire();
    },
    helperMethod : function(cmp, event, helper) {
        
        const recordId = cmp.get("v.recordId")
        
        var produtoOBJ = {}
        var produtoOBJNEW = {}
        
        var query = " SELECT Id, Name, Elegivel_para_demo_rapida__c, Ativo_na_Loja__c,StockKeepingUnit, Linha__c, ProductCode, Family, Tipo_do_Produto__c, Marca__c, Numero_Anvisa__c, Modelo__c, IsActive, Valor_dos_Acessorios__c, Status_Commerce__c, Description,Observacoes__c,Imagem__c, Valor_de_Venda__c, Ativo_no_commerce__c FROM Product2 WHERE Id = '"+recordId+"'"
        //REALIZA A CONSULTA
        this.soql(cmp, query)
        
      

        
        //QUANDO A SOLICITAÇÃO FOR CONCLUÍDA, FAÇA:
        .then(function (produto) {
            
            
              var userId = $A.get("$SObjectType.CurrentUser.Id");
            //console.log("OBJ01", produto[0]); 
            
            //console.log("OBJ01", query); 
            
            //console.log(produto[0].Name)
            produtoOBJ["Name"] = produto[0].Name ;  
            
            //console.log(produto[0].IsActive)
            produtoOBJ["IsActive__c"] = produto[0].IsActive;
            
            //console.log(produto[0].Ativo_na_Loja__c)
            produtoOBJ["Ativo_na_Loja__c"] = produto[0].Ativo_na_Loja__c;
            
            //console.log(produto[0].Elegivel_para_demo_rapida__c)
            produtoOBJ["Elegivel_para_demo_rapida__c"] = produto[0].Elegivel_para_demo_rapida__c;
            
            // console.log(produto[0].Linha__c)
            produtoOBJ["StockKeepingUnit__c"] = produto[0].StockKeepingUnit;
            
            // console.log(produto[0].Linha__c)
            produtoOBJ["Linha__c"] = produto[0].Linha__c;
            
            // console.log(produto[0].Marca__c)
            produtoOBJ["Marca__c"] = produto[0].Marca__c;
            
            //console.log(produto[0].Description)
            produtoOBJ["Description__c"] = produto[0].Description;
            
            //console.log(produto[0].ProductCode)
            produtoOBJ["ProductCode__c"] = produto[0].ProductCode;
            
            // console.log(produto[0].Family)
            produtoOBJ["Family__c"] = produto[0].Family;
            
            // console.log(produto[0].Tipo_do_Produto__c)
            produtoOBJ["Tipo_do_Produto__c"] = produto[0].Tipo_do_Produto__c;
            
            // console.log(produto[0].Numero_Anvisa__c)
            produtoOBJ["Num_Anvisa__c"] = produto[0].Numero_Anvisa__c;
            
            // console.log(produto[0].Modelo__c)
            produtoOBJ["Modelo__c"] = produto[0].Modelo__c  ;    
            
            //console.log(produto[0].Ativo_no_commerce__c)
            produtoOBJ["Ativo_no_commerce__c"] = produto[0].Ativo_no_commerce__c;
            
            //console.log(produto[0].Observacoes__c)
            produtoOBJ["Observacoes__c"] = produto[0].Observacoes__c;
            
            //console.log(produto[0].Valor_Total__c)
            produtoOBJ["Valor_de_Venda__c"] = produto[0].Valor_de_Venda__c;
            
            console.log("-------------------------------------------------------");
            console.log(produto[0].Valor_de_Venda__c);
            console.log("-------------------------------------------------------");
            
            document.querySelector("#subTitulo").innerHTML = produtoOBJ["Name"] 
            
            /* 
             console.log(produtoOBJ.Family)
             console.log(produtoOBJ.StockKeepingUnit__c)
             console.log(produtoOBJ.Id)
             console.log(produtoOBJ.IsActive)
             console.log(produtoOBJ.Linha__c)
             console.log(produtoOBJ.Marca__c)
             console.log(produtoOBJ.Modelo__c)
             console.log(produtoOBJ.ProductCode)
             console.log(produtoOBJ.ProductCode)
           */
            

            
            $(document).ready(function() {
                var marcas = ['7LIVES','ABC','ACCUMED','ACTE','AGATA','AIR LIQUIDE','AIR SHIELD','ALBAN','ALLIAGE','ALVIMÉDICA','ANALYSER','ANESTHESIA','AOC','APK','APPLE', 'ARJO', 'ARJOHUNTLEIGH','ARKTUS','ARTROCORP','ASSUT EUROPE','ATHOS','ATRAMAT','AWAREWESS','AXMED','BALT','BAUMER','BEACON','BELMONT','BENFER','BENTO CARRINHOS','BETANI','BHIOSUPLY','BIC','BILICARE','BIOCON','BIOLINE','BIOMEDICAL','BIOMETAL','BIONNOVATION','BIONOVA','BIOSAT','BIOSENSOR','BLUE NEEM MEDICAL','BLUENNEM','BOSCH','BRALIMPIA','BRASFORMA','BRASMEDICAL','BROSMED MEDICAL','C3TECH','CAMINO','CANON','CARESTREAM','CARL ZEISS','CDK','CELER BIOTECNOL','CENTRAL MEDICA','CHANTAL','CIPAMED','CIRUVET','CITYMED','CLEANTECH','COBRASMAM','COLDMAXX','COLORMAQ','COMEN','CONDOR','CONFIDENCE MEDICAL','CONSUL','CONTEC', 'CORITON', 'COVIDIEN','COZIL','CRISTOFOLI','CRISTÓFOLI','CURAMEDICAL','CVDENTUS','DABI/D700','DABI ATLANTE','DBI MEDICAL','DEGRAUS','DELFAR','DELL','DELTRONIX','DENTSCLER','DIASYS','DIGICARE','DIXTAL','DOMAX','DREVE-OTOPLASTIK','DURACELL','EASY OFFICE','EBRAM','ECEL','EDAN','EDLO','EDWARDS','EDWARDS LIFESCIENCES','ELVI','EMAI','EMGIPLAM','ENDOSURG','ENVITEC','EPFLEX','EQUITHERM','ERBE','EVENT MEDICAL','EXPOWER','FAMI','FANEM','FERT MEDICAL','FIAC','FINE MEDICAL','FIRST LINE MEDICAL','FISHER PAYKEL','FLEXINNIUM','FORTECARE','FRESENIUS','FRIOTOMAQ','FUJIFILM','FUJI MAXIMUS','FXWIRE','GABMED','GE','GEGUTON','GE HEALTHCARE','GE HEALTHECARE','GELOPAR','GEM ITALY','GER-AR MATIC ELETRONIC','GERATHERM','GETTINGE','GETTING MAQUET','GHAMBRO','GIFEL','GLICOMED','GLOBALTEC','GNATUS','GOLGRAN','GRUPO SANTE','GRUPO VECO','G-TECH','GUEBERT','H2M','HANDLAZ','HARTE','HB','HEALTH SOLUTIONS','HEARTSINE','HERWEG','HF','HOFFRICHTER','HOMACC' , 'HOSPCOM','HP','HS','HUGEMED','HUDSON RCI','HUMANNA MEDICAL','IATRADE','IBBL','IDEAL LÍDER','IFAB','IMEX','IMFTEC','IMPOL','INALAMED','INBRAS','INCOTERM','INFLEX','INFTEC','INOMED','INSIGHTRA MEDICAL','INTEGRA LIFESCIENCES','INTEGRA NEUROSCIENCES','INTELBRAS','INTERMED','INVACARE','IONLAB','JA MOVEIS','JAGUARIBE','JESS','JG MORIYA','JJS','JOLINE','KACIL','KARL STORZ','KFF','KIM','K-MEX','KONDORTECH','KONICA MINOLTA','KTK','LABCOR','LABNEWS','LAMNEWS','LANCO','LANG E FILHOS','LCCSMED','LDF','LEPU MEDICAL','LF EQUIPAMENTOS','LG','LIFESPAN','LIGALIFE','LINET','LOKTAL','LOWESTEIN','LUCAS MEDICAL','M. G. PAULIN','MAARTEC','MACROSUL','MAGNAMED','MAQUET','MARCA MÉDICA','MARIMAR','MASIMO','MAT','MAX GEL','MCM ONE','MD','MEDCIR','MEDCLEAN','MEDEX','MEDFIRST','MEDICALWAY','MEDICATE','MEDIKA','MEDILAND','MEDI - SAUDE','MEDI-SAÚDE','MEDITRON','MEDMAX','MEDPEX','MEDPLUS','MEDSTERIL','MEDTECH','MERIL','META HOSPITALAR','MICRODENT','MICROMAR','MICROPORT' , 'MINDRAY', 'MIKATOS','MISSOURI','MJV','MOBIL','MOBILI','MOR GLACIAL','MOURE','MULLER','MULTILASER','NACIONAL','NACIONAL OSSOS','NCS DO BRASIL','NEEDS','NEODENT','NEOSOFT','NEUROTEC','NEURO TECNOLOGIA','NEVONI','NHS','NITROSPRAY','NOBRE','NOVITECH','NS','OLIDEF','OLYMPUS','OMRON','OPEN MEDICAL','ORTOBIO','ORTOBRAS','ORTOMIX','ORTOP','ORTOSSINTESE','OSCILAN','OUTROS','OXIGEL','OXY SYSTEM','PACETRONIX','PANASONIC','PANMEDICA','PATRIOT','PC MIX','PERMUTION','PHILIPS','PICC NATE','PLASVALE','POLLO MOVEIS','POSEY','PREMIUM','PRISMA','PRO LIFE','PRO-LIFE','PROTEC','PULMONETIC','PURITAN BENNETT','QIMED','RAMUZA','RASTRIALL','R-BAIÃO','REACH SURGICAL','RESGATE SP','RESMED','RESPIROX','RHOSSE','ROBONIK','ROMED','ROTAL','RTC','RZ','S&amp;S PRESTAÇÃO','SAMSUNG','SANDERS','SAWAE','SCHILLER','SCHUSTER','SCHÜTZ','SD','SDI','SELAPACK','SERCON','SHENZEN YKD MED','SHIMADZU','SHUNMEI MEDICAL','SIEMENS','SINGER','SISPACK','SITMED','SMITHS MEDICAL','SMS','SONOSCAPE','SOFT','SOLDAFORTE','SONOCA','SONY','SÖRING GMBH','SPENCER','SPLABOR','SP RESGATE','STERIS','STERMAX','STRYKER','SULMEDICA','SUPRA','SURGICAL','SUTOPAR','SUTUPAR','SWAROPLATE','SYSMED','TARCT','TEB','TECHNODRY','TECME','TECNOPRINT','TECNOVENT','TESLA','THOSHIBA','TOTAL LIFE','TOTH LIFECARE','TR-EVOLUTION','TRICUMED','TS-SHARA','TURN-O-MATIC','UMBRA','UNICARE','UNIPOWER','UNITEC','UTECH','UTI MÉDICA','VALUEMED','VBM','VECOFLOW','VENTCARE','VIDE BULA','VIERO DUDA','VMI','WD','WELCH ALLYN','WEM','WEN','WESTER','WIZ AIR','WORKMED','X-DENT','YUWELL','ZAMMI','ZIEHM IMAGING','ZIMMER BIOMET','MOLECULAR','VYTTRA','Arroyo','SHOPFISIO','PMS','PROCION','HETTICH','LAFIX','VENÂNCIO','ORTOPROX','ENDOTECH','CARLL ZEISS','Hospimetal','MK Perfil','Soniclear','Winner']; 
                var tipos = ['INSUMO','ACESSÓRIO','CONSUMÍVEL','EQUIPAMENTO','FERRAMENTA','IMPLANTE','INSTRUMENTAL','KIT SERVIÇO','MÓDULO','MOVEIS','OPCIONAL','PEÇA','SERVIÇO','SET CIRURGICO','SOFTWARE'];
                var familias = ['CIRURGIA ROBÓTICA', 'CAMAS','ALTO FLUXO','ANESTESIA','APOIO A MOBILIDADE','ARCO CIRURGICO','ASPIRADORES','BERÇOS','BERÇOS AQUECIDOS','BPAP','CADEIRAS','CAMAS HOSPITALARES','CARDIOLOGIA','CONCENTRADORES','CIRURGIA MINIMAMENTE INVASIVA','ELETROCIRURGIA','ELEVADORES','ENDOSCOPIA','FOCOS CIRÚRGICOS','FOTOTERAPIA','GERAL','GINECOLOGIA','HIGIENE','IMAGEM','INALADORES','INCUBADORAS','INFUSÃO','LABORATORIAL','LAPAROSCOPIA','LAVADORAS','MACAS','MESAS CIRÚRGICAS','MONITORIZAÇÃO','MONITORES CIRURGICOS E ENDOSCOPIA','MONITORES CLINICOS','MONITORES DIAGNOSTICOS','PLACA GRAFICA PARA MONITORES DIAGNOSTICOS','NEONATOLOGIA','OPME','OUTROS','RADIOLOGIA','SERVIÇOS','SISTEMAS DE COMPRESSAO','SUPORTE CIRÚRGICO','ULTRASSOM FIXO','ULTRASSOM POC','UNIDADES HIBRIDAS','UROLOGIA','VENTILAÇÃO','VETERINÁRIA' ,'VIDEOLARINGO'];    
                var linhas = ['CIRURGIA ROBÓTICA', 'CAMAS HOSPITALARES', 'CIRURGIA MINIMAMENTE INVASIVA', 'CAMAS HOSPITALARES','ELETROCIRURGIA','ENDOSCOPIA','IMAGEM ULTRASSOM','IMAGEM RAIO-X','MONITORES DE GRAU MEDICO','NEONATOLOGIA','OPME','OUTROS','PMLS','SURGICAL','VETERINÁRIA PMLS','VETERINÁRIA MIS', 'VETERINÁRIA IVD', 'VIAS AÉREAS DIFÍCEIS'];  
                
                var listas = [marcas, tipos, familias, linhas]
                
                // console.log("OBJ", produtoOBJ); 
                // 
                
                
                for (let chave in produto[0]) {
                    console.log(chave)
                }
                
                for (let chave in produtoOBJ) {
                    console.log(chave);
                    var i 
                    if(chave == 'Marca__c' || chave == 'Tipo_do_Produto__c' || chave == 'Family__c' || chave == 'Linha__c'){
                        
                        if(chave == 'Marca__c'){i = 0}else if(chave == 'Tipo_do_Produto__c'){i = 1}else if(chave == 'Family__c'){i = 2}else{i = 3}
                        //console.log(i);
                        listas[i].forEach((marcaAtual)=>{
                            
                            var t = "#" +chave
                            //tipo, marca, familia, linha,
                            var marcacHTML = '<option value="'+ marcaAtual +'">'+ marcaAtual +'</option>';
                            $(t).append(marcacHTML);
                        })}
                    
                    var campo = document.getElementById(chave);
                    var tipoCampo = campo.tagName;
                    
                    //console.log(chave + ":"+ produtoOBJ[chave]);
                    //console.log(tipoCampo)
                    if(produtoOBJ[chave] != undefined){
                        if(tipoCampo == "INPUT"){
                            document.getElementById(chave).checked = produtoOBJ[chave];
                        }else{ 
                            
                            document.getElementById(chave).value = produtoOBJ[chave];
                        }}
                    else{ document.getElementById(chave).value = ""}
                }
            })
            
            $("#next").click(function(){
                
                $(".texto").each(function() {
                    var id = $(this).attr("id");
                    
                    var tipoCampo = $(this).tagName;
                    if($(this).val() == "on"){
                        
                        if($(this).is(":checked")){
                            
                        //console.log(id + ": "+ "true");
                        produtoOBJNEW[id] = "true";
                        }else{
                                                    produtoOBJNEW[id] = "false";
                        }
                    }else{
                        //console.log(id + ": "+ $(this).val());
                        produtoOBJNEW[id] = $(this).val();
                    }
                    
                    
                });
                
                
                produtoOBJNEW["Produto__c"] = recordId;
                produtoOBJNEW["Responsavel_pela_Atualiza_o__c"] = userId;
                //console.log("OLD:",produto[0]);
               //console.log("NEW:",produtoOBJNEW);
                //console.log(userId)
               console.log(JSON.stringify(produtoOBJNEW))
                
                
                
                  
var objetoJSON = JSON.stringify(produtoOBJNEW)
                
                
                
			try{
                
                 var action = cmp.get("c.criarHistoricoComAprovacao");
                
                action.setParams({
                    objetoJSON: objetoJSON
                });
                
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        helper.exibirAlerta(cmp, event, helper, "success", "Sucesso", "Enviado para aprovar edição!")
                        
                         console.log("Sucessos"); 
                               
                        //location.reload();
                    } else
                        if (state === "ERROR") {
                        helper.exibirAlerta(cmp, event, helper, "error", "Error", "Falha ao tentar atualizar:" + errors)
                             console.log("Erro: " + errors[i].message); 
                            
                        var errors = response.getError();
                        if (errors) {  
                            $(".load").css("display", "none");
                            console.log("Erro: " + errors[i].message); 
                            helper.exibirAlerta(cmp, event, helper, "error", "Error", "Falha ao tentar atualizar:" + errors)
                            for (var i = 0; i < errors.length; i++) {
                                
                                console.log("Erro: " + errors[i].message); 
                                
                                
                              
                            }
                        } 
                        else {
                            $(".load").css("display", "none");
                             helper.exibirAlerta(cmp, event, helper, "error", "Error", "Falha ao tentar atualizar:" + errors)
                            
            				
                            console.log("Erro desconhecido.");
                            console.log("Erro: " + errors[i].message); 
                        }
                    }
                });
                
                $A.enqueueAction(action);
            } catch (ex) {
                
                $(".load").css("display", "none");
                console.log("Erro ao executar ação: " + ex.message);
                
            }
                
                
            })
            
            
            
            
        })
        //trata excessão de erro
        .catch(function (error) {
            console.log(error)
        })
        
        
    }
})