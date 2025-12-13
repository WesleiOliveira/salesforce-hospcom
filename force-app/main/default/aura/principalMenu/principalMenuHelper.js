({
    dataMenus: [],
    
    mainHelper : function(cmp, event, helper) {
        helper.getData(cmp, event, helper)
    },
    
    getData: function(cmp, event, helper){
        var query = "select id, name, ccnavmenus__Position__c, ccnavmenus__URL__c, ccnavmenus__Menu_Item__c, Icone_Font_Awesome__c from ccnavmenus__Menu_Item__c";
        //helper.alertaErro(cmp, event, helper, "Carregando...", "Aguarde,", "info", "dismissable")
        //REALIZA A CONSULTA
        helper.soql(cmp, query)
        
        //QUANDO A SOLICITAÇÃO FOR CONCLUÍDA, FAÇA:
        .then(function (menus) {
            helper.ajustaMenu(cmp, event, helper, menus)	            
        })
        
        //trata excessão de erro
        .catch(function (error) {
            console.log(error)
        })
    },
    
    addItens:function(cmp, event, helper){
        //console.log("MENUS", helper.dataMenus)
        helper.dataMenus.forEach(item => {
            var nomeMenu = item.Name;
            var idMenu = item.Id;
            
            if(item.hasOwnProperty("submenus")){
            	var classIcon = item.Icone_Font_Awesome__c
                var html = "<div class='itemHospMenu itemExpand' data-type='drop' data-idMenu='"+idMenu+"'>\
                <i class='"+classIcon+"' aria-hidden='true'></i>\
                "+nomeMenu+"\
                <i class='fa fa-angle-down' aria-hidden='true'></i>\
                <div class='dropSubMenu'>"
            
                item.submenus.forEach(submenuItem => {
                    var nomeSubmenu = submenuItem.Name
                    var linkSubmenu = submenuItem.ccnavmenus__URL__c
            		var classIcon = submenuItem.Icone_Font_Awesome__c
                    html = html + "<a href='"+linkSubmenu+"' class='styleTaga'><div class='itemHospMenu itemSubMenu' data-type='standard'>\
                    <i class='"+classIcon+"' aria-hidden='true'></i>\
                    "+nomeSubmenu+"</div></a>"
                })
        
        		html = html + "</div></div>"
        
            }else{
                var linkMenu = item.ccnavmenus__URL__c
    			var classIcon = item.Icone_Font_Awesome__c
                var html = "<a href='"+linkMenu+"' class='styleTaga'><div class='itemHospMenu' data-type='standard' data-idMenu='"+idMenu+"'>\
                <i class='"+classIcon+"' aria-hidden='true'></i>\
                "+nomeMenu+"\
                </div></a>"
            }
 
         	$("#containerItens").append(html)
        });
        helper.eventsAfterAdd(cmp, event, helper)
    },
    
    addItensMobile: function(cmp, event, helper){
        $("#containerMestre").css("position", "unset")
        
        //console.log("MENUS", helper.dataMenus)
        
        helper.dataMenus.forEach(item => {
            var nomeMenu = item.Name;
            var idMenu = item.Id;
            
            if(item.hasOwnProperty("submenus")){
            	var classIcon = item.Icone_Font_Awesome__c
                var html = "<div class='itemHospMenu itemExpand' data-type='drop' data-idMenu='"+idMenu+"'>\
                <i class='"+classIcon+"' aria-hidden='true'></i>\
                "+nomeMenu+"\
                <i class='fa fa-angle-down' aria-hidden='true'></i>\
                <div class='dropSubMenu'><div style='max-height: 200px'>"
            
                item.submenus.forEach(submenuItem => {
                    var nomeSubmenu = submenuItem.Name
                    var linkSubmenu = submenuItem.ccnavmenus__URL__c
            		var classIcon = submenuItem.Icone_Font_Awesome__c
                    html = html + "<a href='"+linkSubmenu+"' class='styleTaga'><div class='itemHospMenu itemSubmenu' data-type='standard'>\
                    <i class='"+classIcon+"' aria-hidden='true'></i>\
                    "+nomeSubmenu+"</div></a>"
                })
        
        		html = html + "</div></div></div>"
        
            }else{
                var linkMenu = item.ccnavmenus__URL__c
    			var classIcon = item.Icone_Font_Awesome__c
                var html = "<a href='"+linkMenu+"' class='styleTaga'><div class='itemHospMenu' data-type='standard' data-idMenu='"+idMenu+"'>\
                <i class='"+classIcon+"' aria-hidden='true'></i>\
                "+nomeMenu+"\
                </div></a>"
            }
 
         	$("#innerContainerMobileMenu").append(html)
        });
        
        $("#iconMobileMenu").off().on( "click", function() {
            $("#containerMenuMobile").css("display", "flex")
        });
        
        $("#iconeClose").off().on( "click", function() {
            $("#containerMenuMobile").css("display", "none")
        });
        
        $(".itemExpand").off().on( "click", function() {
            
            
            // Fecha todos os submenus, exceto o do item clicado
            $(".dropSubMenu").not($(this).find(".dropSubMenu")).hide();
            
            // Obtém o submenu do item clicado
            var submenu = $(this).find(".dropSubMenu");
            
            // Verifica se o submenu está visível
            if (submenu.is(":visible")) {
                // Se estiver visível, esconde
                submenu.hide();
            } else {
                // Se não estiver visível, mostra com display: flex
                submenu.css("display", "flex");
            }
        });


    },
            
    detectMob: function(cmp, event, helper) {
    	if(/Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent)){
          // true for mobile device
          return true
        }else{
          // false for not mobile device
          return false
        }
  	},
        
    waitForLabel: function(cmp, attribute) {
        return new Promise((resolve, reject) => {
            const checkInterval = 50; // Intervalo para verificar a resolução (em ms)
            const timeout = 5000; // Tempo máximo para esperar a resolução (em ms)
            let elapsed = 0;

            const interval = setInterval(() => {
                const value = cmp.get(attribute);
                if (value) {
                    clearInterval(interval);
                    resolve(value);
                } else if (elapsed >= timeout) {
                    clearInterval(interval);
                    reject(new Error("Tempo limite excedido para resolver o rótulo."));
                }
                elapsed += checkInterval;
            }, checkInterval);
        });
    },
        
    ajustaMenu: function(cmp, event, helper, menus){
        
        //console.log("MENUS INIT", menus)
        
        menus.forEach(item => {
            
            var labelSubStr = item.Name;
            //console.log("ITEM SBS", labelSubStr)
			var labelReference = $A.getReference("$Label.c." + labelSubStr);
        
       		cmp.set("v.tempLabelAttr", labelReference);
			//var translatedName = cmp.get("v.tempLabelAttr");
            
            helper.waitForLabel(cmp, "v.tempLabelAttr").then(translatedName => {
                //console.log("Rótulo traduzido:", translatedName);
                
                // Coloque aqui o código que depende do rótulo traduzido
            }).catch(error => {
                console.error("Erro ao resolver o rótulo:", error);
            });

        
			//console.log("label reference", labelReference)
                      
            //const translatedName = $A.get(labelName); // Obtém o rótulo
        
            //console.log("STRING", labelReference);
            //console.log("TRANSLATED", translatedName);

            /*if (translatedName) {
                console.log("encontrado")
                item.Name = translatedName; // Substitui o Name pelo valor traduzido
            } */
        });

        //console.log("MENUS", menus)

		var rootItems = menus.filter(item => !item["ccnavmenus__Menu_Item__c"]);
        var childitens = menus.filter(item => item["ccnavmenus__Menu_Item__c"]);
        
        rootItems.sort((a, b) => parseInt(a.ccnavmenus__Position__c) - parseInt(b.ccnavmenus__Position__c));
               
        childitens.forEach(item => {
            var idRelated = item.ccnavmenus__Menu_Item__c;
            var foundItem = rootItems.find((element) => element.Id == idRelated);
            
            if (foundItem) {
              // Verifica se o item pai tem uma propriedade "submenus"
              if (!foundItem.submenus) {
                foundItem.submenus = [];
              };
              foundItem.submenus.push(item);
            } 
            
        });
            
        //Ordenar os submenus de cada item
        rootItems.forEach(item => {
            if (item.submenus) {
            	item.submenus.sort((a, b) => a.ccnavmenus__Position__c - b.ccnavmenus__Position__c);
        	}
        });
        
        helper.dataMenus = rootItems
                        
        if(helper.detectMob(cmp, event, helper)){
            helper.addItensMobile(cmp, event, helper)
        }else{
            helper.addItens(cmp, event, helper)
        }

    },
            
    eventsAfterAdd: function(cmp, event, helper){
        $(".itemHospMenu").off().on( "click", function() {
            var tipoItem = $(this).attr("data-type");
            var idmenu = $(this).attr("data-idMenu");
            
        });
        
        $(".itemExpand").off().on("click", function(event) {
            event.stopPropagation(); // Impede que o clique neste elemento propague para o document
            
            // Fecha todos os submenus, exceto o do item clicado
            $(".dropSubMenu").not($(this).find(".dropSubMenu")).hide();
            
            // Obtém o submenu do item clicado
            var submenu = $(this).find(".dropSubMenu");
            
            // Verifica se o submenu está visível
            if (submenu.is(":visible")) {
                // Se estiver visível, esconde
                submenu.hide();
            } else {
                // Se não estiver visível, mostra com display: flex
                submenu.css("display", "flex");
            }
        });
        
        // Fecha qualquer submenu aberto ao clicar em qualquer outra área da página
        $(document).on("click", function() {
            $(".dropSubMenu").hide(); // Fecha todos os submenus
        });
    },
})