({
    loadMoreData : function(component) {
        
          let  limit_c = 7
        
        let idComodato = component.get("v.recordId"); 
        // idtipo = null; 
        
       // console.log('teste: ' + idtipo);
        if(component.get("v.recordId").substring(0, 3) == 'a0K'){
        try {
            var action = component.get("c.documentosOts");
            
                  
            action.setParams({
                idComodato: idComodato,
                limit_1 :   limit_c,
                offset_1: component.get("v.offset")
            });
            
            action.setCallback(this, function(response) {
                var state = response.getState();
                
                if (state === "SUCCESS") {
                    var documentos = response.getReturnValue();
                    var container = document.getElementById('tr_linha');
                    
                    if(documentos.length < limit_c){
                        
                        $('#botao').css('display', 'none');
                    }
                    documentos.forEach(function(doc) {
                        var row = document.createElement('div');
                        row.className = 'td_linha';
                        
                        var ativo = document.createElement('div');
                        ativo.className = 'td_linha2';
                        var ativoLink = document.createElement('a');
                        ativoLink.href = 'https://hospcom.my.site.com/Sales/s/asset/' + doc.idAtivo;
                        ativoLink.textContent = doc.nomeAtivo;
                        ativoLink.target = '_blank'; 
                        ativo.appendChild(ativoLink);
                        
                        var ordem = document.createElement('div');
                        ordem.className = 'td_linha2';
                        var ordemLink = document.createElement('a');
                        ordemLink.href = 'https://hospcom.my.site.com/Sales/s/workorder/' + doc.idOrdemTrabalho;
                        ordemLink.textContent = doc.nomeOrdemTrabalho;
                        ordemLink.target = '_blank'; 
                        ordem.appendChild(ordemLink);
                        
                        var nomeArquivo = document.createElement('div');
                        nomeArquivo.className = 'td_linha2';
                        nomeArquivo.textContent = doc.nomeDocumento;
                        
                        var download = document.createElement('div');
                        download.className = 'td_linha2 icon';
                        var icon = document.createElement('i');
                        icon.className = 'fa fa-download';
                        icon.style.fontSize = '20px';
                        icon.style.color = '#0c375a';
                        download.appendChild(icon);
                        
                        
                        download.addEventListener('click', function() {
                            var link = document.createElement('a');
                            link.href = 'data:application/pdf;base64,' + doc.base64;
                            link.download = doc.nomeDocumento + '.pdf';
                            link.click();
                        });
                        
                        row.appendChild(ativo);
                        row.appendChild(ordem);
                        row.appendChild(nomeArquivo);
                        row.appendChild(download);
                        
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
        else  if(component.get("v.recordId").substring(0, 3) == 'a1Y'){
            
                        console.log("Entrou: ", idComodato);

            try {
            var action = component.get("c.documentosOts_contratos");
            
                     
            action.setParams({
                idContrato: idComodato,
                limit_1 :   limit_c,
                offset_1: component.get("v.offset")
            });
            
            action.setCallback(this, function(response) {
                var state = response.getState();
                
                if (state === "SUCCESS") {
                    var documentos = response.getReturnValue();
                    var container = document.getElementById('tr_linha');
                    
                    console.log('Tamanho: ' + documentos.length);
                    if(documentos.length < limit_c){
                        
                        $('#botao').css('display', 'none');
                    }
                    documentos.forEach(function(doc) {
                        var row = document.createElement('div');
                        row.className = 'td_linha';
                        
                        var ativo = document.createElement('div');
                        ativo.className = 'td_linha2';
                        var ativoLink = document.createElement('a');
                        ativoLink.href = 'https://hospcom.my.site.com/Sales/s/asset/' + doc.idAtivo;
                        ativoLink.textContent = doc.nomeAtivo;
                        ativoLink.target = '_blank'; // Abre em uma nova aba
                        ativo.appendChild(ativoLink);
                        
                        var ordem = document.createElement('div');
                        ordem.className = 'td_linha2';
                        var ordemLink = document.createElement('a');
                        ordemLink.href = 'https://hospcom.my.site.com/Sales/s/workorder/' + doc.idOrdemTrabalho;
                        ordemLink.textContent = doc.nomeOrdemTrabalho;
                        ordemLink.target = '_blank'; // Abre em uma nova aba
                        ordem.appendChild(ordemLink);
                        
                        var nomeArquivo = document.createElement('div');
                        nomeArquivo.className = 'td_linha2';
                        nomeArquivo.textContent = doc.nomeDocumento;
                        
                        var download = document.createElement('div');
                        download.className = 'td_linha2 icon';
                        var icon = document.createElement('i');
                        icon.className = 'fa fa-download';
                        icon.style.fontSize = '20px';
                        icon.style.color = '#0c375a';
                        download.appendChild(icon);
                        
                        
                        download.addEventListener('click', function() {
                            var link = document.createElement('a');
                            link.href = 'data:application/pdf;base64,' + doc.base64;
                            link.download = doc.nomeDocumento + '.pdf';
                            link.click();
                        });
                        
                        row.appendChild(ativo);
                        row.appendChild(ordem);
                        row.appendChild(nomeArquivo);
                        row.appendChild(download);
                        
                        container.appendChild(row);
                    });
                } else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.error("Erro: " + errors[0].message);
                            console.error("Erro: " + errors[0]);
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
        
        else {
            
            
            
            try {
            var action = component.get("c.documentosOts_Demo");
            
                     
            action.setParams({
                idPedido: idComodato,
                limit_1 :   limit_c,
                offset_1: component.get("v.offset")
            });
            
            action.setCallback(this, function(response) {
                var state = response.getState();
                
                if (state === "SUCCESS") {
                    var documentos = response.getReturnValue();
                    var container = document.getElementById('tr_linha');
                    
                    console.log('Tamanho: ' + documentos.length);
                    if(documentos.length < limit_c){
                        
                        $('#botao').css('display', 'none');
                    }
                    documentos.forEach(function(doc) {
                        var row = document.createElement('div');
                        row.className = 'td_linha';
                        
                        var ativo = document.createElement('div');
                        ativo.className = 'td_linha2';
                        var ativoLink = document.createElement('a');
                        ativoLink.href = 'https://hospcom.my.site.com/Sales/s/asset/' + doc.idAtivo;
                        ativoLink.textContent = doc.nomeAtivo;
                        ativoLink.target = '_blank'; // Abre em uma nova aba
                        ativo.appendChild(ativoLink);
                        
                        var ordem = document.createElement('div');
                        ordem.className = 'td_linha2';
                        var ordemLink = document.createElement('a');
                        ordemLink.href = 'https://hospcom.my.site.com/Sales/s/workorder/' + doc.idOrdemTrabalho;
                        ordemLink.textContent = doc.nomeOrdemTrabalho;
                        ordemLink.target = '_blank'; // Abre em uma nova aba
                        ordem.appendChild(ordemLink);
                        
                        var nomeArquivo = document.createElement('div');
                        nomeArquivo.className = 'td_linha2';
                        nomeArquivo.textContent = doc.nomeDocumento;
                        
                        var download = document.createElement('div');
                        download.className = 'td_linha2 icon';
                        var icon = document.createElement('i');
                        icon.className = 'fa fa-download';
                        icon.style.fontSize = '20px';
                        icon.style.color = '#0c375a';
                        download.appendChild(icon);
                        
                        
                        download.addEventListener('click', function() {
                            var link = document.createElement('a');
                            link.href = 'data:application/pdf;base64,' + doc.base64;
                            link.download = doc.nomeDocumento + '.pdf';
                            link.click();
                        });
                        
                        row.appendChild(ativo);
                        row.appendChild(ordem);
                        row.appendChild(nomeArquivo);
                        row.appendChild(download);
                        
                        container.appendChild(row);
                    });
                } else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.error("Erro: " + errors[0].message);
                            console.error("Erro: " + errors[0]);
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
        
    }
})