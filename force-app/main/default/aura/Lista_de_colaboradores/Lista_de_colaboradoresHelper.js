({
    contatos:[],
    recordId: '',
	mainFunction : function(cmp, event, helper) {
           
        helper.consultamembros(cmp, event, helper);
       var userId = $A.get("$SObjectType.CurrentUser.Id");
      
        
       var a  = cmp.get("v.recordId");
         helper.recordId = a
        console.log(helper.recordId);
        helper.consultaContatosHosp(cmp, event, helper);
       
        helper.handleCheckChange(cmp, event, helper);
        $("#continuar").click(function(){
            helper.buscaPessoasSelecionadas(cmp, event, helper)
        });
    },
    
     
    
    handleCheckChange: function(cmp, event, helper) {
        $('#todos').change(function() {
            console.log("Passou antes aaaaaaaaaaaa");
            const isChecked = this.checked;
            
            if (isChecked) {
                console.log("Passou quando marcado");
                $(".pessoas").trigger('click');
            } else {
                console.log('RETIROU: ', $("#todos").val());
                $(".pessoas").trigger('click');
            }
        });
        
        // Coloque aqui o código a ser executado quando o checkbox for marcado.
    }
       ,
    
    consultaContatosHosp: function (cmp, event, helper){
    
    
        //CONSULTA AS VARIAÇÕES DO USUARIO
        var query = "SELECT Id, Name, FirstName, LastName, Colaborador_ativo__c, Email, Title, AccountId, Phone, CPF__c   FROM Contact WHERE AccountId = '001i00000085QYb' AND Colaborador_ativo__c = true ORDER BY Name"
        
        //REALIZA A CONSULTA
        this.soql(cmp, query)
        
        //QUANDO A SOLICITAÇÃO FOR CONCLUÍDA, FAÇA:
        .then(function (listaContatos) {
            console.log("Contatos: ", listaContatos);
            helper.insereContatosNaLista(cmp, event, helper,listaContatos);
    		helper.contatos = listaContatos;
        })
        .catch(function (e) { // Correção aqui, adicionando "function"
            console.log("Membros ERROR: ", e);
        });
        
        
    },
    
    consultamembros:function(cmp, event, helper){
        
        var idEvento = cmp.get("v.recordId");
        
        console.log("id do evento na hora da consulta: ", cmp.get("v.recordId"));
        
        var query1 = "SELECT Id, name, Evento__c FROM Membro_Interno_do_Evento__c WHERE Evento__c = '" + cmp.get("v.recordId")+"'";
        
        this.soql(cmp, query1)
        
        .then(function (membrosev) {
            console.log("Membros do evento: ", membrosev);
        })
        .catch(function (ex) { // Correção aqui, adicionando "function"
            console.log("Membros do evento ERROR: ", ex);
        });
    }
    ,        
    insereContatosNaLista: function(cmp, event, helper, listaContatos ){
          console.log("Chwgou")
          listaContatos.forEach((e) => {
              // console.log("Chwgou")
              $("#corpo_list").append('<li><label><input type="checkbox" class="pessoas" name="" value="'+ e.Id+'" id="'+ e.Id+'" /><p>'+ e.Name+'</p><span></span></label></li>'); 
              
             
                  
                  $('#'+ e.Id).change(function() {
                  if (this.checked) {
              			 $("#corpo_list_selecionados").append('<li class="name" id="select-'+e.Id+'"><label for="'+e.Id+'"><p>'+ e.Name+'</p></label></li>'); 
              
                  } else {
              
              			var campo ='#select-' + e.Id;
              
              			$(campo).remove();
              			console.log('Desmarcado: ', e.Id);
                  }
              });
          });
              
              
              
      },
              
    buscaPessoasSelecionadas: function(cmp, event, helper) {
        const pessoasList = $(".pessoas").toArray();
    
        var listaCheckPessoas = pessoasList.filter(function(pessoa) {
            return $(pessoa).is(':checked');
        });
    
      //  console.log(" Selecionados",listaCheckPessoas);
        
        var arrayIds = [];
        var arrayContatos = []; 
    
        listaCheckPessoas.forEach(function(e) {
        
            arrayIds.push(e.value);
        });
    
        arrayIds.forEach((idAtual) => {
            var cc = helper.contatos.filter((contato) => contato.Id == idAtual);
            
                console.log(" Selecionados", cc);
            if(cc != null && cc != "" ){arrayContatos.push(cc[0]);}
        });
                
        
        var colaboradoresSend = []
        
        
        arrayContatos.forEach((idAtual) => {
            var variavelTemporaria; 
            
            variavelTemporaria = {
            "AccountId":idAtual.AccountId,
            "Id": idAtual.Id,
            "Name": idAtual.Name,
            "FirstName": idAtual.FirstName,
            "LastName": idAtual.LastName,
            "Email": idAtual.Email,
            "Title": idAtual.Title,
            "CPF__c": idAtual.CPF__c,
        }
                              colaboradoresSend.push(variavelTemporaria);
            
        });
              
               console.log("Contatos à serem enviados: ", colaboradoresSend);

        helper.enviaBack(cmp, event, helper, arrayContatos);
	}      ,

              enviaBack:function(cmp, event, helper, membros){
                  // semRepetidos, psq, bs64, file      
                 
                  try{
                      var action = cmp.get("c.criaMembros");
                      
                      action.setParams({
                          membros: membros, 
                          idTreinamento:helper.recordId,
                      });
                      
                      action.setCallback(this, function(response) {
                          var state = response.getState();
                          if (state === "SUCCESS") {
                              helper.exibirAlerta(cmp, event, helper, "success", "Sucesso", "Membros foram inseridos com sucesso.");
                              
                              setTimeout(() => {
                                  console.log('sucesso')
                                          }, "1000");
                              location.reload();
                          } else if (state === "ERROR") {
                              
                              var errors = response.getError();
                              if (errors){  
                                  helper.exibirAlerta(cmp, event, helper, "error", "Error", "Falha ao tentar criar membro:" + errors)
                                  
                                      setTimeout(() => {
                                          
                                  console.log('erro1')
                                      }, "1000");
                                           location.reload();
                                  } else{ 
                                  
                                 helper.exibirAlerta(cmp, event, helper, "error", "Error", "Falha ao tentar membro:" + errors)
                                  
                                          
                                      setTimeout(() => {
                                        
                                  console.log('sucesso')
                                      }, "1000");
                                           location.reload();
                              }
                          }
                      });
                      
                      $A.enqueueAction(action);
                  } catch (ex) {
                      
                     
                      console.log("Erro ao executar ação: " + ex.message);
                      
                  }
                  
              }
                

,
              
              exibirAlerta : function(component, event, helper, type, title, message) {
                  var toastEvent = $A.get("e.force:showToast");
                  toastEvent.setParams({
                      "type" : type,
                      "title": title,
                      "message": message
                  });
                  toastEvent.fire();
              }
              
              
              
})