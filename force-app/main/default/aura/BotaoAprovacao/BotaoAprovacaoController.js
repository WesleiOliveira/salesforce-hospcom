({
	onRecordSubmit : function(component, event, helper) {
                        var button = component.find("botao");
        				button.set("v.label", "Contratado");
        				button.set("v.disabled",true); 
        				button.set("v.iconName","utility:check");
	},
    
    doInit : function(component, event, helper){
        	var botao = component.find("botao");
        	var status = component.find("status").get("v.value");
        if(status == 'Aprovado'){
            botao.set("v.label", 'Contratado');
            botao.set("v.disabled",true);
            botao.set("v.iconName", "utility:check");
        }
    }
})