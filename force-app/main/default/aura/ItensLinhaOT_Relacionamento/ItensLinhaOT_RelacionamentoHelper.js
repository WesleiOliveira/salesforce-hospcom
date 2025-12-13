({
    loadMoreData : function(component) {
        try {
            let limit_c = 7;
            let idComodato = component.get("v.recordId"); 
            var action = component.get("c.itens");
            
            action.setParams({
                idOt: idComodato,
            });
            
            action.setCallback(this, function(response) {
                var state = response.getState();
                
                if (state === "SUCCESS") {
                    var documentos = response.getReturnValue();
                    var container = document.getElementById('tr_linha');
                    
                    console.log('Tamanho: ' + documentos.length);
                    if (documentos.length < limit_c) {
                        $('#botao').css('display', 'none');
                    }
                    
                    documentos.forEach(function(doc) {
                        var row = document.createElement('div');
                        row.className = 'td_linha';
                        
                        var ativo = document.createElement('div');
                        ativo.className = 'td_linha2';
                        var ativoLink = document.createElement('a');
                        ativoLink.href = 'https://hospcom.my.site.com/Sales/s/asset/' + doc.ID;
                        ativoLink.textContent = doc.LineItemNumber;
                        ativoLink.target = '_blank'; // Abre em uma nova aba
                        ativo.appendChild(ativoLink);
                        
                        var ordem = document.createElement('div');
                        ordem.className = 'td_linha2';
                        var ordemLink = document.createElement('a');
                        ordemLink.href = 'https://hospcom.my.site.com/Sales/s/workorder/' + doc.Produto__c;
                        ordemLink.textContent = doc.Nome_do_produto__c;
                        ordemLink.target = '_blank'; // Abre em uma nova aba
                        ordem.appendChild(ordemLink);
                        
                        var nomeArquivo = document.createElement('div');
                        nomeArquivo.className = 'td_linha2';
                        nomeArquivo.textContent = doc.nomeDocumento;
                        
                        var nomeArquivo2 = document.createElement('div');
                        nomeArquivo2.className = 'td_linha2';
                        nomeArquivo2.textContent = doc.C_digo_do_Produto__c;
                        
                        row.appendChild(ativo);
                        row.appendChild(ordem);
                        row.appendChild(nomeArquivo);
                        row.appendChild(nomeArquivo2);
                        
                        container.appendChild(row);
                    });
                } else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.error("Erro: " + errors[0].message);
                        }
                    } else {
                        console.error("Erro desconhecido");
                    }
                }
            });
            
            $A.enqueueAction(action);
        } catch (e) {
            console.error("Exceção: " + e.message);
        }
    }
})