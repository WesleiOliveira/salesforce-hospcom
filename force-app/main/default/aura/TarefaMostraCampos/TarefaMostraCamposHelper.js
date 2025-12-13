({
  recordId: "",

  initialize: function(cmp, event, helper, subject) {
          helper.verificarPerfilJuridico(cmp, event, helper);
    //PESQUISA ASSUNTO DO JURIDICO SE SUBJECT == 'Departamento Juridico'
    if (subject === "Departamento Juridico") {
      helper.recordId = cmp.get("v.recordId");
      let query = `SELECT Id, AssuntoJuridco__c FROM Task WHERE Id = '${
        helper.recordId
      }'`;

      helper
        .soql(cmp, query)
        .then(function(result) {
          let assunto = result[0].AssuntoJuridco__c;
          cmp.set("v.assunto", assunto);
          helper.carregaCampos(cmp, event, helper, assunto);
          
        })
        .catch(function(error) {
          console.error("❌ Erro ao buscar AssuntoJuridico__c:", error);
        });
    }
  },

  carregaCampos: function(cmp, event, helper, subAssunto) {
    cmp.set("v.showFields", false)
    if (
      subAssunto === "Defesa de processo administrativo" ||
      subAssunto === "Prorrogação de entrega" ||
      subAssunto === "Defesa processo judicial" ||
      subAssunto === "Resposta a notificação"
    ) {
      let query = `
        SELECT Qual_a_data_de_recebimento_do_primei__c,
               Qual_a_data_prevista_para_a_resol__c,
               Qual_o_motivo_do_envio_da_ocorr_nc__c,
               Inclua_as_demais_informa_es_necess__c,
               Acontecer_alguma_troca_de_modelo_ou__c
        FROM Task 
        WHERE Id = '${helper.recordId}'`;
    
      helper
        .soql(cmp, query)
        .then(function(result) {
          if (result && result.length > 0) {
            let task = result[0];
            cmp.set("v.showFields", true);
			console.log("Passou aqui");
          

            setTimeout(function() {
              for (let campo in task) {
                if (task.hasOwnProperty(campo)) {
                  let valor = task[campo] || "";

                  if (valor instanceof Date) {
                    valor = valor.toISOString().split("T")[0]; // Fica no formato YYYY-MM-DD
                  } else if (
                    typeof valor === "string" &&
                    /^\d{4}-\d{2}-\d{2}T/.test(valor)
                  ) {
                    valor = valor.split("T")[0]; // Se vier em ISO string
                  }

                  // Preenche a div com o ID correspondente ao nome do campo
                  $(`#${campo}`).text(valor);
                }
                    
              }
            }, 100); // espera o DOM estar pronto
          }
        })
        .catch(function(error) {
          console.error(error);
        });
    }
  },
  verificarPerfilJuridico: function(cmp, event, helper) {
    let perfilJuridico = "00e6e000002JQUaAAO";
    var userId = $A.get("$SObjectType.CurrentUser.Id");

    let query = `SELECT ProfileId FROM User WHERE Id = '${userId}'`;
    console.log("UserId: ", query);
 
        helper.soql(cmp, query).then(function(result) {
            
        let idPerfil = result[0].ProfileId;
            
        console.log("let funcionando ", idPerfil);
            
        if (idPerfil === perfilJuridico || userId === "005U400000AkKZ3IAN") {
          cmp.set("v.mostrarBotao", true);
        } else {
          console.log("ababa");
        }
      })
      .catch(function(error) {
        console.error("Erro ao buscar perfil do usuário:", error);
      });
  }
});