({
	
	
	doInit: function (cmp, event, helper) {
		cmp.set("v.setMeOnInit", "controller init magic!");
	},

	//FUNÇÃO EXECUTADA APÓS O TÉRMINO DA RENDERIZAÇAO DO COMPONENTE-----------------------------------------------------------
	afterScriptsLoad: function (cmp, event, helper) {

		helper.helperMethod(cmp, event, helper)

		

	},
})