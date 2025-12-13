trigger SAPProductIntegration on Product2 (after insert,after update) {
    
    if(RecursiveHandler.IsNotRecursive){
        RecursiveHandler.IsNotRecursive = false;
        String opt = Trigger.isInsert ? 'I' : ( Trigger.isUpdate ? 'U' : null);
        if(opt != null){
            //JsonProduct json = new JsonProduct();
            //json.JsonProduct();
            for(Product2 p : Trigger.new){
                //json.setManufacturer(p.Marca__c);
                //json.setU_nfe_cProdANVISA(p.Numero_Anvisa__c);
                //json.setItemsGroupCode(p.Family);
                //json.setItemCode(p.ProductCode);
                //json.setItemName(p.Name);
                //json.setMainsupplier(p.Fornecedor__c);
                //json.setSalesUnit(p.Unidade_de_medida_de_venda__c);
                //json.setPurchaseUnit(p.Unidade_de_medida_de_compra__c);
                //json.setInventoryUOM(p.Unidade_de_medida_do_estoque__c);
                //json.setProductSource(p.Fonte_do_Produto__c);
                //json.setNCMCode(p.NCM_do_Produto__c != null ? Integer.valueOf(p.NCM_do_Produto__c) : null);
            }            
            //String body = SYSTEM.JSON.serialize(json);
            
            //if(!System.IsBatch() && !System.isFuture() && !System.Test.isRunningTest()) integracaoSAP.doSAPProductIntegration(body,opt);
        }
    }
    

    Public class JsonProduct {
        //Private Integer Series;
        //Private Integer Manufacturer;
        //Private String U_nfe_cProdANVISA;
        //Private Integer ItemsGroupCode;
        //Private String ItemCode;
        //Private String ItemName;
        //Private String ManageSerialNumbers;
        //Private String ManageBatchNumbers;
        //Private String SRIAndBatchManageMethod;
        //Private String Mainsupplier;
        //Private String SalesUnit;
        //Private String PurchaseUnit;
        //Private String InventoryUOM;
        //Private Integer ProductSource;
        //Private Integer NCMCode;
        //Private String PurchaseItem;
        //Private String SalesItem;
        //Private String InventoryItem;
        //Private String ItemType;
        //Private String ItemClass;
        
        /*Public void JsonProduct(){
            this.Series = 3;
            this.ManageSerialNumbers = 'tNO';
            this.ManageBatchNumbers = 'tNO';
            this.SRIAndBatchManageMethod = 'bomm_OnEveryTransaction';
            this.PurchaseItem = 'tYES';
            this.SalesItem = 'tYES';
            this.InventoryItem = 'tYES';
            this.ItemType = 'itItems';
            this.ItemClass = 'itcMaterial';
        }*/

/*        Public void setManufacturer(String Manufacturer){
            switch on Manufacturer {
                when '3GREEN' { this.Manufacturer = -1; }
                when 'ABC' { this.Manufacturer = 1; }
                when 'ACCUMED' { this.Manufacturer = -1; }
                when 'ACROSS' { this.Manufacturer = -1; }
                when 'AGATA' { this.Manufacturer = -1; }
                when 'AGILE MED' { this.Manufacturer = 110; }
                when 'AIR LIQUIDE' { this.Manufacturer = 179; }
                when 'AIR SHIELD' { this.Manufacturer = -1; }
                when 'AJEL' { this.Manufacturer = -1; }
                when 'ALBAN' { this.Manufacturer = -1; } 
                when 'ALLIAGE' { this.Manufacturer = -1; }
                when 'ALPHARAD' { this.Manufacturer = -1; }
                when 'ALVIMÉDICA' { this.Manufacturer = -1; }
                when 'ANALYSER' { this.Manufacturer = -1; }
                when 'ANATONIC' { this.Manufacturer = -1; }
                when 'AOC' { this.Manufacturer = 254; }
                when 'APC' { this.Manufacturer = -1; }
                when 'APK' { this.Manufacturer = 228; }
                when 'APPLE' { this.Manufacturer = 229; }
                when 'ARJO' { this.Manufacturer = 257; }
                when 'ARJOHUNTLEIGH' { this.Manufacturer = -1; }
                when 'ARTIS' { this.Manufacturer = 141; }
                when 'ASSUT EUROPE' { this.Manufacturer = 269; }
                when 'ATA' { this.Manufacturer = 157; }
                when 'ATHOS' { this.Manufacturer = -1; }
                when 'ATRAMAT' { this.Manufacturer = 176; }
                when 'ATRIUM MEDICAL' { this.Manufacturer = -1; }
                when 'AWAREWESS' { this.Manufacturer = -1; }
                when 'AXMED' { this.Manufacturer = 2; }
                when 'BABYMAG' { this.Manufacturer = 202; }
                when 'BALT' { this.Manufacturer = 277; }
                when 'BAUMER' { this.Manufacturer = -1; }
                when 'BEACON' { this.Manufacturer = 3; }
                when 'BELMONT' { this.Manufacturer = 231; }
                when 'BELMONT MEDICAL TECHNOLOGIES' { this.Manufacturer = -1; }
                when 'BENEFIT EAN' { this.Manufacturer = -1; }
                when 'BENFER' { this.Manufacturer = 4; }
                when 'BENTO CARRINHOS' { this.Manufacturer = 105; }
                when 'BESMED' { this.Manufacturer = 160; }
                when 'BETANI' { this.Manufacturer = -1; }
                when 'BHIOSUPLY' { this.Manufacturer = 146; }
                when 'BHIO SUPPLY' { this.Manufacturer = 146; }
                when 'BIC' { this.Manufacturer = 5; }
                when 'BILICARE' { this.Manufacturer = 246; }
                when 'BIO ART' { this.Manufacturer = -1; }
                when 'BIOCON' { this.Manufacturer = -1; }
                when 'BIOLINE' { this.Manufacturer = 170; }
                when 'BIO-MED' { this.Manufacturer = -1; }
                when 'BIOMEDICAL' { this.Manufacturer = 334; }
                when 'BIOMETAL' { this.Manufacturer = -1; }
                when 'BIONET' { this.Manufacturer = 6; }
                when 'BIONNOVATION' { this.Manufacturer = 136; }
                when 'BIOPACK' { this.Manufacturer = 116; }
                when 'BIOSAT' { this.Manufacturer = -1; }
                when 'BIOSENSOR' { this.Manufacturer = 114; }
                when 'BIOTEC' { this.Manufacturer = 117; }
                when 'BLUE NEEM MEDICAL' { this.Manufacturer = 118; }
                when 'BLUENNEM' { this.Manufacturer = -1; }
                when 'BOJIN' { this.Manufacturer = 7; }
                when 'BOSCH' { this.Manufacturer = -1; }
                when 'BRALIMPIA' { this.Manufacturer = -1; }
                when 'BRAMSYS' { this.Manufacturer = -1; }
                when 'BRASFORMA' { this.Manufacturer = -1; }
                when 'BRASMEDICAL' { this.Manufacturer = 129; }
                when 'BRASUTURE' { this.Manufacturer = 193; }
                when 'C3TECH' { this.Manufacturer = 255; }
                when 'CALMAQ' { this.Manufacturer = -1; }
                when 'CAMINO' { this.Manufacturer = -1; }
                when 'CANON' { this.Manufacturer = -1; }
                when 'CARDINAL' { this.Manufacturer = -1; }
                when 'CARESTREAM' { this.Manufacturer = -1; }
                when 'CARL ZEISS' { this.Manufacturer = -1; }
                when 'CAUMAQ' { this.Manufacturer = 186; }
                when 'CDK' { this.Manufacturer = -1; }
                when 'CELER BIOTECNOL' { this.Manufacturer = -1; }
                when 'CELITRON' { this.Manufacturer = -1; }
                when 'CENTRAL MEDICA' { this.Manufacturer = -1; }
                when 'CHANTAL' { this.Manufacturer = 9; }
                when 'CHEMWELL' { this.Manufacturer = -1; }
                when 'CIPAMED' { this.Manufacturer = -1; }
                when 'CIRUVET' { this.Manufacturer = 304; }
                when 'CISA' { this.Manufacturer = -1; }
                when 'CITYMED' { this.Manufacturer = -1; }
                when 'CLEANTECH' { this.Manufacturer = -1; }
                when 'CMOS DRAKE' { this.Manufacturer = -1; }
                when 'COBRASMAM' { this.Manufacturer = 185; }
                when 'COLDMAXX' { this.Manufacturer = -1; }
                when 'COLEMAN' { this.Manufacturer = -1; }
                when 'COLORMAQ' { this.Manufacturer = -1; }
                when 'COMEN' { this.Manufacturer = 10; }
                when 'COMFEE HI WALL' { this.Manufacturer = -1; }
                when 'CONDOR' { this.Manufacturer = 134; }
                when 'CONFIDENCE MEDICAL' { this.Manufacturer = -1; }
                when 'CONMED' { this.Manufacturer = 11; }
                when 'CONSUL' { this.Manufacturer = 106; }
                when 'CONTEC' { this.Manufacturer = 243; }
                when 'COSMAN' { this.Manufacturer = 133; }
                when 'COVIDIEN' { this.Manufacturer = -1; }
                when 'COZIL' { this.Manufacturer = -1; }
                when 'CREATE MEDIC CO.' { this.Manufacturer = -1; }
                when 'CRISTOFOLI' { this.Manufacturer = 13; }
                when 'CRISTÓFOLI' { this.Manufacturer = 13; }
                when 'CRM MEDIC' { this.Manufacturer = 159; }
                when 'CURAMEDICAL' { this.Manufacturer = 171; }
                when 'CVDENTUS' { this.Manufacturer = -1; }
                when 'DABASONS' { this.Manufacturer = 165; }
                when 'DABI/D700' { this.Manufacturer = -1; }
                when 'DABI ATLANTE' { this.Manufacturer = -1; }
                when 'DARU' { this.Manufacturer = 14; }
                when 'DEGRAUS' { this.Manufacturer = 174; }
                when 'DELF' { this.Manufacturer = 190; }
                when 'DELFAR' { this.Manufacturer = -1; }
                when 'DELL' { this.Manufacturer = -1; }
                when 'DELTAMED' { this.Manufacturer = 242; }
                when 'DELTRONIX' { this.Manufacturer = 15; }
                when 'DENTSCLER' { this.Manufacturer = -1; }
                when 'DIAGNO' { this.Manufacturer = -1; }
                when 'DIASYS' { this.Manufacturer = -1; }
                when 'DIGICARE' { this.Manufacturer = 16; }
                when 'DIGIPET' { this.Manufacturer = -1; }
                when 'DIXTAL' { this.Manufacturer = 189; }
                when 'DOMAX' { this.Manufacturer = 128; }
                when 'DORMED' { this.Manufacturer = -1; }
                when 'DREVE-OTOPLASTIK' { this.Manufacturer = -1; }
                when 'DURACELL' { this.Manufacturer = -1; }
                when 'DYASIS' { this.Manufacturer = -1; }
                when 'EASY OFFICE' { this.Manufacturer = -1; }
                when 'EBRAM' { this.Manufacturer = -1; }
                when 'ECAFIX' { this.Manufacturer = -1; }
                when 'ECEL' { this.Manufacturer = 17; }
                when 'EDAN' { this.Manufacturer = 40; }
                when 'EDLO' { this.Manufacturer = -1; }
                when 'EDWARDS' { this.Manufacturer = 98; }
                when 'EDWARDS LIFESCIENCES' { this.Manufacturer = 98; }
                when 'ELECTROLUX' { this.Manufacturer = -1; }
                when 'ELVI' { this.Manufacturer = -1; }
                when 'EMAI' { this.Manufacturer = -1; }
                when 'EMBRAMED' { this.Manufacturer = -1; }
                when 'EMGIPLAM' { this.Manufacturer = -1; }
                when 'ENGIMPLAN' { this.Manufacturer = 210; }
                when 'ENVITEC' { this.Manufacturer = 138; }
                when 'EPFLEX' { this.Manufacturer = 119; }
                when 'EPSON' { this.Manufacturer = 117; }
                when 'EQUITHERM' { this.Manufacturer = -1; }
                when 'ESSENCE DENTAL VH' { this.Manufacturer = -1; }
                when 'EVENT MEDICAL' { this.Manufacturer = 178; }
                when 'EXPOWER' { this.Manufacturer = 145; }
                when 'FAMI' { this.Manufacturer = -1; }
                when 'FANEM' { this.Manufacturer = 18; }
                when 'FENGH' { this.Manufacturer = 235; }
                when 'FERT MEDICAL' { this.Manufacturer = 121; }
                when 'FIAC' { this.Manufacturer = -1; }
                when 'FIGLABS' { this.Manufacturer = -1; }
                when 'FINE MEDICAL' { this.Manufacturer = 265; }
                when 'FIRST LINE MEDICAL' { this.Manufacturer = -1; }
                when 'FIRTSMED' { this.Manufacturer = -1; }
                when 'FISHER & PAYKEL' { this.Manufacturer = 19; }
                when 'FLEXINNIUM' { this.Manufacturer = -1; }
                when 'FLUKE' { this.Manufacturer = 150; }
                when 'FORTECARE' { this.Manufacturer = -1; }
                when 'FRANCISCO REPRESENTAÇÕES' { this.Manufacturer = 111; }
                when 'FREEDOM' { this.Manufacturer = -1; }
                when 'FRESENIUS' { this.Manufacturer = 20; } 
                when 'FRIOTOMAQ' { this.Manufacturer = -1; }
                when 'FRISOKAR' { this.Manufacturer = -1; }
                when 'FUJI MAXIMUS' { this.Manufacturer = 196; }
                when 'FULL GAUGE' { this.Manufacturer = -1; } 
                when 'FXWIRE' { this.Manufacturer = 162; }
                when 'GABMED' { this.Manufacturer = 263; }
                when 'GADALI MEDICAL' { this.Manufacturer = 329; }
                when 'GE' { this.Manufacturer = -1; }
                when 'GEGUTON' { this.Manufacturer = -1; }
                when 'GEHAKA' { this.Manufacturer = -1; }
                when 'GE HEALTHCARE' { this.Manufacturer = 21; }
                when 'GE HEALTHECARE' { this.Manufacturer = 21; }
                when 'GELITA MEDICAL' { this.Manufacturer = 226; }
                when 'GELOPAR' { this.Manufacturer = 167; }
                when 'GEM ITALY' { this.Manufacturer = -1; }
                when 'GENERAL MEDITECH' { this.Manufacturer = -1; }
                when 'GER-AR MATIC ELETRONIC' { this.Manufacturer = -1; }
                when 'GERATHERM' { this.Manufacturer = -1; }
                when 'GERIUM MEDICAL' { this.Manufacturer = -1; }
                when 'GETTINGE' { this.Manufacturer = 324; }
                when 'GETTING MAQUET' { this.Manufacturer = 324; }
                when 'GF LABOR' { this.Manufacturer = 204; }
                when 'GHAMBRO' { this.Manufacturer = -1; }
                when 'GIFEL' { this.Manufacturer = 22; }
                when 'GIGABYTE' { this.Manufacturer = 247; }
                when 'GLICOMED' { this.Manufacturer = -1; }
                when 'GLOBALTEC' { this.Manufacturer = 23; }
                when 'GLUBRAN' { this.Manufacturer = 140; }
                when 'GNATUS' { this.Manufacturer = -1; }
                when 'GOLGRAN' { this.Manufacturer = 24; }
                when 'GRIFFCLAVE' { this.Manufacturer = 25; }
                when 'GRUPO VECO' { this.Manufacturer = 144; }
                when 'GTECH' { this.Manufacturer = 164; }
                when 'G-TECH' { this.Manufacturer = 164; }
                when 'GUEBERT' { this.Manufacturer = -1; }
                when 'GYNFLEX' { this.Manufacturer = 194; }
                when 'H2M' { this.Manufacturer = 218; }
                when 'HANDLAZ' { this.Manufacturer = 212; }
                when 'HANGZHOU' { this.Manufacturer = 148; }
                when 'HARTE' { this.Manufacturer = 156; }
                when 'HB' { this.Manufacturer = 294; }
                when 'HEALTH QUALITY' { this.Manufacturer = -1; } 
                when 'HEALTH SOLUTIONS' { this.Manufacturer = 297; }
                when 'HEARTSINE' { this.Manufacturer = 26; }
                when 'Heart Sine' { this.Manufacturer = 26; }
                when 'HERWEG' { this.Manufacturer = -1; } 
                when 'HF' { this.Manufacturer = 295; }
                when 'HIRTZ' { this.Manufacturer = -1; }
                when 'HOFFRICHTER' { this.Manufacturer = 27; } 
                when 'HOMACC' { this.Manufacturer = -1; }
                when 'HOSPCOM' { this.Manufacturer = -1; }
                when 'HP' { this.Manufacturer = 236; }
                when 'HS' { this.Manufacturer = 230; }
                when 'HUDSON RCI' { this.Manufacturer = 28; }
                when 'HUMANNA MEDICAL' { this.Manufacturer = 175; }
                when 'HYPERBRANCH' { this.Manufacturer = 302; }
                when 'IATRADE' { this.Manufacturer = -1; }
                when 'IBBL' { this.Manufacturer = -1; }
                when 'ICEL' { this.Manufacturer = 241; }
                when 'IDEAL LÍDER' { this.Manufacturer = -1; } 
                when 'IFAB' { this.Manufacturer = 29; }
                when 'IMFTEC' { this.Manufacturer = 126; } 
                when 'IMPLAMED' { this.Manufacturer = -1; }
                when 'IMPOL' { this.Manufacturer = 201; }
                when 'INALAMED' { this.Manufacturer = 30; }
                when 'INALOCLIN' { this.Manufacturer = -1; }
                when 'INBRAS' { this.Manufacturer = -1; }
                when 'INCOTERM' { this.Manufacturer = 31; }
                when 'INDUSBELLO' { this.Manufacturer = -1; }
                when 'INFLEX' { this.Manufacturer = -1; }
                when 'INFTEC' { this.Manufacturer = -1; }
                when 'INGAMED' { this.Manufacturer = 120; }
                when 'INOMED' { this.Manufacturer = -1; } 
                when 'INSIGHTRA MEDICAL' { this.Manufacturer = -1; }
                when 'INSTRAMED' { this.Manufacturer = 32; }
                when 'INTEGRA LIFESCIENCES' { this.Manufacturer = -1; }
                when 'INTEGRA NEUROSCIENCES' { this.Manufacturer = 213; }
                when 'INTEL' { this.Manufacturer = 248; }
                when 'INTELBRAS' { this.Manufacturer = -1; }
                when 'INTERMED' { this.Manufacturer = 34; }
                when 'INTERTECK KATAL' { this.Manufacturer = -1; }
                when 'INVACARE' { this.Manufacturer = -1; }
                when 'IONLAB' { this.Manufacturer = -1; }
                when 'ITS-MC' { this.Manufacturer = -1; }
                when 'J&A MOVEIS' { this.Manufacturer = -1; }
                when 'JAGUARIBE' { this.Manufacturer = -1; }
                when 'JAGUARIBE / AGILE' { this.Manufacturer = -1; }
                when 'JESS' { this.Manufacturer = 158; }
                when 'JG MORIYA' { this.Manufacturer = 35; }
                when 'JIUHONG' { this.Manufacturer = -1; }
                when 'JJS' { this.Manufacturer = 130; } 
                when 'JOLINE' { this.Manufacturer = -1; } 
                when 'JV MEDIC' { this.Manufacturer = 181; }
                when 'KACIL' { this.Manufacturer = 161; }
                when 'KARL STORZ' { this.Manufacturer = -1; }
                when 'KAVO' { this.Manufacturer = -1; }
                when 'KFF' { this.Manufacturer = -1; }
                when 'KIM' { this.Manufacturer = -1; }
                when 'KINGSTON' { this.Manufacturer = 249; }
                when 'K-MEX' { this.Manufacturer = -1; }
                when 'KONDORTECH' { this.Manufacturer = -1; }
                when 'KONEX' { this.Manufacturer = -1; }
                when 'KONICA MINOLTA' { this.Manufacturer = -1; }
                when 'KTK' { this.Manufacturer = 195; }
                when 'KYOCERA' { this.Manufacturer = 102; }
                when 'LABCOR' { this.Manufacturer = 317; }
                when 'LABNEWS' { this.Manufacturer = -1; }
                when 'LACERDA' { this.Manufacturer = -1; }
                when 'LAMNEWS' { this.Manufacturer = -1; }
                when 'LANCO' { this.Manufacturer = -1; }
                when 'LANG' { this.Manufacturer = 216; }
                when 'LANG E FILHOS' { this.Manufacturer = 113; } 
                when 'LCCSMED' { this.Manufacturer = -1; }
                when 'LCSS MEDICAL' { this.Manufacturer = -1; }
                when 'LDF' { this.Manufacturer = 314; }
                when 'LF EQUIPAMENTOS' { this.Manufacturer = -1; }
                when 'LG' { this.Manufacturer = 288; }
                when 'LIFEMED'{ this.Manufacturer = 36; }
                when 'LIFESPAN' { this.Manufacturer = -1; }
                when 'LIGALIFE' { this.Manufacturer = -1; }
                when 'LIGA LIFE' { this.Manufacturer = 209; }
                when 'LINET' { this.Manufacturer = -1; }
                when 'LOKTAL' { this.Manufacturer = 37; }
                when 'LONGFEI' { this.Manufacturer = 220; }
                when 'LOWESTEIN' { this.Manufacturer = -1; }
                when 'LUCAS MEDICAL' { this.Manufacturer = 215; }
                when 'LUMIAR SAUDE' { this.Manufacturer = 206; }
                when 'M. G. PAULIN' { this.Manufacturer = 205; }
                when 'MAARTEC' { this.Manufacturer = 100; }
                when 'MACOM' { this.Manufacturer = 310; }
                when 'MACROSUL' { this.Manufacturer = 38; }
                when 'MAGNAMED' { this.Manufacturer = 109; }
                when 'MALTEC' { this.Manufacturer = -1; }
                when 'MAQUET' { this.Manufacturer = -1; }
                when 'MARCA MÉDICA' { this.Manufacturer = -1; }
                when 'MARGIROS' { this.Manufacturer = -1; }
                when 'MARIMAR' { this.Manufacturer = 39; }
                when 'MASIMO' { this.Manufacturer = -1; }
                when 'MASTER MEDIKAL' { this.Manufacturer = 41; } 
                when 'MAT' { this.Manufacturer = -1; }
                when 'MAX GEL' { this.Manufacturer = -1; }
                when 'MAXTEC' { this.Manufacturer = 208; }
                when 'MCM ONE' { this.Manufacturer = 264; }
                when 'MD' { this.Manufacturer = 42; }
                when 'MEDAX' { this.Manufacturer = -1; }
                when 'MEDCIR' { this.Manufacturer = -1; }
                when 'MEDCLEAN' { this.Manufacturer = 200; } 
                when 'MEDELA' { this.Manufacturer = 43; }
                when 'MEDEX' { this.Manufacturer = 123; }
                when 'MEDICAL SYSTEMS' { this.Manufacturer = 101; }
                when 'MEDICALWAY' { this.Manufacturer = 311; }
                when 'MEDICATE' { this.Manufacturer = -1; }
                when 'MEDICONE' { this.Manufacturer = 45; }
                when 'MEDIKA' { this.Manufacturer = 308; }
                when 'MEDILAND' { this.Manufacturer = -1; }
                when 'MEDINOVAÇÃO' { this.Manufacturer = -1; }
                when 'MEDI - SAUDE' { this.Manufacturer = -1; }
                when 'MEDI-SAÚDE' { this.Manufacturer = -1; }
                when 'MEDITECH' { this.Manufacturer = -1; }
                when 'MEDITRON' { this.Manufacturer = -1; }
                when 'MEDMAX' { this.Manufacturer = 147; }
                when 'MEDPEJ' { this.Manufacturer = 305; }
                when 'MEDPEX' { this.Manufacturer = 99; }
                when 'MEDSHARP' { this.Manufacturer = 224; }
                when 'MEDSTERIL' { this.Manufacturer = 127; }
                when 'MEDTECH' { this.Manufacturer = 244; }
                when 'MEDTRONIC' { this.Manufacturer = 303; }
                when 'MERIL' { this.Manufacturer = 239; }
                when 'META HOSPITALAR' { this.Manufacturer = -1; }
                when 'METAL BREY' { this.Manufacturer = 46; }
                when 'MICRODENT' { this.Manufacturer = 115; }
                when 'MICROMAR' { this.Manufacturer = 47; }
               when 'MICROMED' { this.Manufacturer = -1; }
                when 'MICROPORT' { this.Manufacturer = -1; }
                when 'MIKATOS' { this.Manufacturer = 48; }
                when 'MINDRAY' { this.Manufacturer = 49; }
                when 'MISSOURI' { this.Manufacturer = -1; }
                when 'MJV' { this.Manufacturer = 51; }
                when 'MJV SILICONES' { this.Manufacturer = -1; }
                when 'MOBIL' { this.Manufacturer = 217; }
                when 'MOBILI' { this.Manufacturer = -1; }
                when 'MOR' { this.Manufacturer = -1; }
                when 'MOR GLACIAL' { this.Manufacturer = -1; }
                when 'MOURE' { this.Manufacturer = -1; }
                when 'MRM' { this.Manufacturer = -1; }
                when 'MULLER' { this.Manufacturer = 225; }
                when 'MYSORE' { this.Manufacturer = -1; }
                when 'NACIONAL' { this.Manufacturer = -1; } 
                when 'NCS' { this.Manufacturer = 184; }
                when 'NCS DO BRASIL' { this.Manufacturer = -1; }
                when 'NEEDS' { this.Manufacturer = -1; }
                when 'NELLCOR' { this.Manufacturer = 52; }
                when 'NEODENT' { this.Manufacturer = -1; }
                when 'NETRA' { this.Manufacturer = -1; }
                when 'NEUROTEC' { this.Manufacturer = -1; }
                when 'NEURO TECNOLOGIA' { this.Manufacturer = -1; }
                when 'NEUROVIRTUAL' { this.Manufacturer = -1; }
                when 'NEVONI' { this.Manufacturer = 53; }
                when 'NHS' { this.Manufacturer = 149; }
                when 'NIHON KOHDEN' { this.Manufacturer = -1; }
                when 'NITROSPRAY' { this.Manufacturer = -1; }
                when 'NOBRE' { this.Manufacturer = 107; }
                when 'NORTEMEDICA' { this.Manufacturer = -1; }
                when 'NOVITECH' { this.Manufacturer = -1; }
                when 'NS' { this.Manufacturer = 104; }
                when 'NVIDIA' { this.Manufacturer = 252; }
                when 'OLYMPUS' { this.Manufacturer = -1; }
                when 'OMNIMED' { this.Manufacturer = 55; }
                when 'OMRON' { this.Manufacturer = -1; }
                when 'OPEN MEDICAL' { this.Manufacturer = -1; }
                when 'OPTON' { this.Manufacturer = -1; }
                when 'ORTOBIO' { this.Manufacturer = 188; }
                when 'ORTOMED' { this.Manufacturer = -1; }
                when 'ORTOMIX' { this.Manufacturer = -1; }
                when 'ORTOSINTESE' { this.Manufacturer = 173; }
                when 'ORTOSSINTESE' { this.Manufacturer = 173; }
                when 'OSCILAN' { this.Manufacturer = -1; }
                when 'OSRAM' { this.Manufacturer = -1; }
                when 'OUTROS' { this.Manufacturer = -1; }
                when 'OXIGEL' { this.Manufacturer = 56; }
                when 'OXYMAG' { this.Manufacturer = 266; }
                when 'OXY SYSTEM' { this.Manufacturer = -1; }
                when 'PACETRONIX' { this.Manufacturer = -1; }
                when 'PAMED' { this.Manufacturer = -1; }
                when 'PANASONIC' { this.Manufacturer = 57; }
                when 'PANMEDICA' { this.Manufacturer = 58; }
                when 'PATRIOT' { this.Manufacturer = 261; }
                when 'PC MIX' { this.Manufacturer = -1; }
                when 'PENTAX' { this.Manufacturer = -1; }
                when 'PERMUTION' { this.Manufacturer = -1; }
                when 'PHILIPS' { this.Manufacturer = 219; }
                when 'PHS NUPORT' { this.Manufacturer = -1; }
                when 'PICC NATE' { this.Manufacturer = 240; }
                when 'PLASVALE' { this.Manufacturer = -1; }
                when 'PLATINA' { this.Manufacturer = 207; }
                when 'POLLO MOVEIS' { this.Manufacturer = -1; }
                when 'POSEY' { this.Manufacturer = -1; }
                when 'POWER COLOR' { this.Manufacturer = 251; }
                when 'PREMIUM' { this.Manufacturer = 59; }
                when 'PRISMA' { this.Manufacturer = 180; }
                when 'PRISMATEC' { this.Manufacturer = 61; }
                when 'PRO LIFE' { this.Manufacturer = 63; }
                when 'PRO-LIFE' { this.Manufacturer = 63; }
                when 'PROMM' { this.Manufacturer = -1; }
                when 'PROTEC' { this.Manufacturer = 64; }
                when 'PULMONETIC' { this.Manufacturer = 163; }
                when 'PURIGEL' { this.Manufacturer = 282; }
                when 'PURITAN BENNETT' { this.Manufacturer = 187; }
                when 'QIMED' { this.Manufacturer = -1; }
                when 'QUIMIS' { this.Manufacturer = -1; }
                when 'RAMUZA' { this.Manufacturer = -1; }
                when 'RASTRIALL' { this.Manufacturer = 137; }
                when 'RAZEK' { this.Manufacturer = -1; }
                when 'REACH SURGICAL' { this.Manufacturer = -1; }
                when 'RESGATE' { this.Manufacturer = 65; }
                when 'RESGATE SP' { this.Manufacturer = 66; }
                when 'RESMED' { this.Manufacturer = -1; }
                when 'RESPIRONICS' { this.Manufacturer = 223; }
                when 'RESPIROX' { this.Manufacturer = 203; }
                when 'RHOSSE' { this.Manufacturer = -1; }
                when 'RICHARD WOLF' { this.Manufacturer = 67; }
                when 'ROBONIK' { this.Manufacturer = -1; }
                when 'ROMED' { this.Manufacturer = 69; }
                when 'ROSSMAX' { this.Manufacturer = 70; }
                when 'ROTAL' { this.Manufacturer = 71; }
                when 'RTC' { this.Manufacturer = 183; }
                when 'RVENT' { this.Manufacturer = -1; }
                when 'RZ' { this.Manufacturer = 222; }
                when 'S&S PRESTAÇÃO' { this.Manufacturer = -1; }
                when 'SAEVO' { this.Manufacturer = -1; }
                when 'SAMSUNG' { this.Manufacturer = 94; }
                when 'SANDERS' { this.Manufacturer = -1; }
                when 'SARTORI' { this.Manufacturer = 192; }
                when 'SAWAE' { this.Manufacturer = -1; }
                when 'SCHILLER' { this.Manufacturer = -1; }
                when 'SCHOLLY' { this.Manufacturer = -1; }
                when 'SCHUSTER' { this.Manufacturer = -1; }
                when 'SCHÜTZ' { this.Manufacturer = -1; }
                when 'SCITECH' { this.Manufacturer = 234; }
                when 'SD' { this.Manufacturer = 125; }
                when 'SDI' { this.Manufacturer = -1; }
                when 'SEATWELL' { this.Manufacturer = -1; }
                when 'SELAPACK' { this.Manufacturer = -1; }
                when 'SERCON' { this.Manufacturer = 72; }
                when 'SHANGHAI' { this.Manufacturer = 273; }
                when 'SHENZEN YKD MED' { this.Manufacturer = 154; }
                when 'SHIMADZU' { this.Manufacturer = 168; } 
                when 'SHR' { this.Manufacturer = -1; }
                when 'SHUNMEI MEDICAL' { this.Manufacturer = -1; }
                when 'SIEMENS' { this.Manufacturer = 103; }
                when 'SIGNO VINCES' { this.Manufacturer = -1; }
                when 'SIMILAR & COMPATIVEL' { this.Manufacturer = 73; }
                when 'SINGER' { this.Manufacturer = -1; }
                when 'SISMATEC' { this.Manufacturer = 74; }
                when 'SISPACK' { this.Manufacturer = 75; }
                when 'SITMED' { this.Manufacturer = 191; }
                when 'SMART' { this.Manufacturer = -1; }
                when 'SMITHS MEDICAL' { this.Manufacturer = 151; }
                when 'SMS' { this.Manufacturer = 132; }
                when 'SNOW LAMBE' { this.Manufacturer = -1; }
                when 'SOFT' { this.Manufacturer = -1; }
                when 'SOLIDA' { this.Manufacturer = 124; }
                when 'SONOCA' { this.Manufacturer = -1; }
                when 'SONY' { this.Manufacturer = 77; }
                when 'SORING' { this.Manufacturer = 135; }
                when 'SÖRING GMBH' { this.Manufacturer = -1; }
                when 'SPENCER' { this.Manufacturer = 78; }
                when 'SPIRIT' { this.Manufacturer = 79; }
                when 'SPLABOR' { this.Manufacturer = -1; }
                when 'SP RESGATE' { this.Manufacturer = -1; }
                when 'STAMP STEEL' { this.Manufacturer = 214; }
                when 'STERIS' { this.Manufacturer = 81; }
                when 'STERMAX' { this.Manufacturer = 82; }
                when 'STREMA' { this.Manufacturer = 122; }
                when 'STRYKER' { this.Manufacturer = 142; }
                when 'SULMEDICA' { this.Manufacturer = -1; }
                when 'SULMEDICAL' { this.Manufacturer = 153; }
                when 'SUPRA' { this.Manufacturer = 112; }
                when 'SURGICAL' { this.Manufacturer = -1; }
                when 'SUTOPAR' { this.Manufacturer = 232; }
                when 'SUTUPAR' { this.Manufacturer = 60; }
                when 'SUZUKI' { this.Manufacturer = -1; }
                when 'SWAROPLATE' { this.Manufacturer = 211; }
                when 'SYSMED' { this.Manufacturer = -1; }
                when 'TAKAOKA' { this.Manufacturer = 197; }
                when 'TARCT' { this.Manufacturer = 262; }
                when 'TEB' { this.Manufacturer = 198; }
                when 'TECHNEW' { this.Manufacturer = 139; }
                when 'TECHNODRY' { this.Manufacturer = 260; }
                when 'TECME' { this.Manufacturer = 259; }
                when 'TECNOPRINT' { this.Manufacturer = 83; }
                when 'TECNOVENT' { this.Manufacturer = -1; }
                when 'TERRAGENE' { this.Manufacturer = -1; }
                when 'TESLA' { this.Manufacturer = -1; }
                when 'THERMO FISHER SCIENTIFIC' { this.Manufacturer = -1; }
                when 'TORNECAD' { this.Manufacturer = 155; }
                when 'TOTAL LIFE' { this.Manufacturer = 275; } 
                when 'TOTH LIFECARE' { this.Manufacturer = -1; }
                when 'TREND MEDICAL' { this.Manufacturer = 84; }
                when 'TR-EVOLUTION' { this.Manufacturer = -1; }
                when 'TRICUMED' { this.Manufacturer = -1; }
                when 'TS-SHARA' { this.Manufacturer = 245; }
                when 'TURN-O-MATIC' { this.Manufacturer = -1; }
                when 'ULTRA HOSPITALAR' { this.Manufacturer = 227; }
                when 'UMBRA' { this.Manufacturer = -1; }
                when 'UNICARE' { this.Manufacturer = 172; }
                when 'UNIMED' { this.Manufacturer = 152; }
                when 'UNIPOWER' { this.Manufacturer = 85; }
                when 'UNITEC' { this.Manufacturer = 87; }
                when 'UROMED' { this.Manufacturer = -1; }
                when 'UTECH' { this.Manufacturer = 89; }
                when 'UTI MÉDICA' { this.Manufacturer = -1; }
                when 'VADI' { this.Manufacturer = 90; }
                when 'VALUEMED' { this.Manufacturer = -1; }
                when 'VBM' { this.Manufacturer = 182; }
                when 'VCOMIN' { this.Manufacturer = -1; }
                when 'VECOFLOW' { this.Manufacturer = 166; }
                when 'VENTCARE' { this.Manufacturer = 131; }
                when 'VERT-MAXX' { this.Manufacturer = 258; }
                when 'VIDE BULA' { this.Manufacturer = -1; }
                when 'VIERO DUDA' { this.Manufacturer = -1; }
                when 'VIP VYZUNY' { this.Manufacturer = -1; }
                when 'VMI' { this.Manufacturer = 335; }
                when 'VUP VYZUMNY USTAV PLETARSKY' { this.Manufacturer = -1; }
                when 'VYAIRE' { this.Manufacturer = -1; }
                when 'WD' { this.Manufacturer = 250; } 
                when 'WELCH ALLYN' { this.Manufacturer = 92; }
                when 'WELMY' { this.Manufacturer = 96; }
                when 'WEM' { this.Manufacturer = -1; }
                when 'WEN' { this.Manufacturer = 97; }
                when 'WERFEN' { this.Manufacturer = -1; }
                when 'WESTER' { this.Manufacturer = 256; }
                when 'WIZ AIR' { this.Manufacturer = -1; }
                when 'WORD' { this.Manufacturer = -1; }
                when 'WORKMED' { this.Manufacturer = -1; }
                when 'X-DENT' { this.Manufacturer = -1; }
                when 'XENONIO' { this.Manufacturer = -1; }
                when 'YUWELL' { this.Manufacturer = 221; }
                when 'ZAMMI' { this.Manufacturer = 233; }
                when 'ZEISS' { this.Manufacturer = 143; }
                when 'ZIEHM IMAGING' { this.Manufacturer = -1; }
                when 'ZOLL' { this.Manufacturer = 108; }
                when else { this.Manufacturer = -1; }
            }
        }*/
        
        /*Public void setU_nfe_cProdANVISA(String U_nfe_cProdANVISA){
            this.U_nfe_cProdANVISA = U_nfe_cProdANVISA;
        }*/
        
        /*Public void setItemsGroupCode(String ItemsGroupCode){
            switch on ItemsGroupCode {
                when 'ALTO FLUXO' { this.ItemsGroupCode = 112; }
                when 'ANESTESIA' { this.ItemsGroupCode = 101; }
                when 'APOIO A MOBILIDADE' { this.ItemsGroupCode = 100; }
                when 'ARCO CIRURGICO' { this.ItemsGroupCode = 100; }
                when 'CARDIOLOGIA' { this.ItemsGroupCode = 102; }
                when 'CIRURGIA MINIMAMENTE INVASIVA' { this.ItemsGroupCode = 124; }
                when 'ELETRO CIRURGIA' { this.ItemsGroupCode = 100; }
                when 'GINECOLOGIA' { this.ItemsGroupCode = 124; }
                when 'INFUSÃO' { this.ItemsGroupCode = 106; }
                when 'LABORATORIAL' { this.ItemsGroupCode = 107; }
                when 'LAPAROSCOPIA' { this.ItemsGroupCode = 124; }
                when 'MONITORIZAÇÃO' { this.ItemsGroupCode = 108; }
                when 'NEONATOLOGIA' { this.ItemsGroupCode = 110; }
                when 'OPME' { this.ItemsGroupCode = 123; }
                when 'OUTROS' { this.ItemsGroupCode = 115; }
                when 'SERVIÇOS' { this.ItemsGroupCode = 118; }
                when 'SUPORTE CIRÚRGICO' { this.ItemsGroupCode = 125; }
                when 'ULTRASSOM' { this.ItemsGroupCode = 105; }
                when 'UROLOGIA' { this.ItemsGroupCode = 124; }
                when 'VENTILAÇÃO' { this.ItemsGroupCode = 112; }
                when 'VETERINÁRIA' { this.ItemsGroupCode = 136; }
                when else { this.ItemsGroupCode = 100; }
            }
        }*/
            
        /*Public void setItemCode(String ItemCode){
            this.ItemCode = ItemCode;
        }*/
        
        /*Public void setItemName(String ItemName){
            this.ItemName = ItemName;
        }*/
        
        /*Public void setMainsupplier(String Mainsupplier){
            this.Mainsupplier = Mainsupplier;
        }*/
        
        /*Public void setSalesUnit(String SalesUnit){
            this.SalesUnit = SalesUnit == null ? 'UN' : SalesUnit;
        }*/
        
        /*Public void setPurchaseUnit(String PurchaseUnit){
            this.PurchaseUnit = PurchaseUnit == null ? 'UN' : PurchaseUnit;
        }*/
        
        /*Public void setInventoryUOM(String InventoryUOM){
            this.InventoryUOM = InventoryUOM == null ? 'UN' : InventoryUOM ;
        }*/
        
        /*Public void setProductSource(String ProductSource){
            Switch on ProductSource{
                when 'Nacional' { this.ProductSource = 0; }
                when 'Internacional' { this.ProductSource = 1; }
                when else { this.ProductSource = 0; }
            }
        }*/
        
        /*Public void setNCMCode(Integer NCMCode){
            this.NCMCode = NCMCode;
        }*/
        
    }    
}