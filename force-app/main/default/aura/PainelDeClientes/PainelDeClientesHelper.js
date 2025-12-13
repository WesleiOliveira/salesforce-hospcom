({
    quantidade_requisitada:5,
    empresasClientes: [],
    empresasClientes2: [],
    empresas:[],
    poiters:[],
    empresasContainer:[],
    marcasF:[],
    linhasF:[], 
    markers:[],
    markesDelit:[],
    linhaSelecionada:null,
    marcaSelecionada:null,
    btnNovaEmpresa: false, 
    map:{},
    recordId: '', 
    auxiliar: true,
    
    
    
    helperMethod: function(cmp, event, helper) {
        
        helper.recordId = $A.get("$SObjectType.CurrentUser.Id");
        
        var spinnerHTML2 = '<div id = "containerDoSpinner2">\
                                                <div class="spinner-border" role="status">\
                                                    <span class="visually-hidden"></span>\
                                                </div>\
                                            </div>'
                                   
                        $("#mapa").append(spinnerHTML2);
        
        
        $('.selectPickerLinha, .selectPickerMarca').selectpicker({
            dropupAuto: false  
        });
        
        helper.pesquisa(cmp, event, helper,"Trindade");
        
        
        
        console.log("empresas: ",helper.empresas)
        document.getElementById('meuFormulario').addEventListener('submit', function(event) {
            event.preventDefault(); // Impede o envio padrão do formulário
            // Faça qualquer ação adicional que você precise realizar com os dados do formulário aqui
        });
        
        
        
        $("#bar-empresas").click(function(){
            
            if( $("#bar-empresas").val() == false ){
                $("#empresas").css("height","0");
                $("#container-empresas").css("height","0");
                
                $("#empresas").css("padding","0");
                $("#bar-empresas").val(true)
            }else{
                $("#empresas").css("height","calc(100% - 50px)");
                $("#empresas").css("padding","20px 5px;");
                
                $("#container-empresas").css("height","98%");
                $("#bar-empresas").val(false)
            }
            
            
        });
    },
    
    pesquisa:function(cmp, event, helper,cidade){
        try{
            var action = cmp.get("c.procuraGeral");
            
            action.setParams({
                cidade: cidade,
                estado: "GO",
                limite: 20000
            });
            
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    //helper.exibirAlerta(cmp, event, helper, "success", "Sucesso", "Documento atualizado com sucesso!")
                    
                    //CONVERTE EM UM OBJETO JSON
                    helper.empresas = JSON.parse(response.getReturnValue());
                    //OBTEM APENAS AS EMPRESAS CLIENTES
                    //helper.empresasClientes = empresas.filter(cliente => cliente.Cliente == true || cliente.Cliente == 'true');
                    
                    //console.log("EMPRESAS CLIENTES: ", helper.empresas)
                    //CHAMA A FUNCAO PARA PREENCHER AS LINHAS E MARCAS PARA CADA CLIENTE
                    helper.preencheLinhasMarcas(cmp, event, helper, true); 
                    
                    helper.marketshere(cmp, event, helper, helper.empresas);
                    
                    
                    //NAO SEI OQ A FUNCAO TESTE FAZ
                } else if (state === "ERROR") {
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
                        
                        
                    } else {
                        $(".load").css("display", "none");
                        helper.exibirAlerta(cmp, event, helper, "error", "Error", "Falha ao tentar atualizar:" + errors)
                        
                        console.log("Erro desconhecido.");
                        console.log("Erro: " + errors[i].message); 
                    }
                }
            });
            
            $A.enqueueAction(action);
            
        } catch (ex) {
            console.log("Erro ao executar ação: " + ex.message);
        }
    },
    
    preencheLinhasMarcas: function(cmp, event, helper,valida1){
        
        //OBTEM O ANO ANUAL
        const dataAtual = new Date();
        const ano = dataAtual.getFullYear();
        var anoInicio = ano + '-01-01'
        
        //DEFINE A QUERY DE CONSULTA NO SALESFORCE
        var query = 'SELECT id, linha__c, Marca__c, Order.Data_de_ativacao__c, OrderId, Order.AccountId, Order.Account.CNPJ__c from orderItem where Order.Data_de_ativacao__c >= '+anoInicio+' AND Linha__c != null'
        
        //REALIZA A CONSULTA
        this.soql(cmp, query)
        
        //QUANDO A SOLICITAÇÃO FOR CONCLUÍDA, FAÇA:
        .then(function (itemsPedidoDeCompra) {
            // console.log("itemsPedidoDeCompra", itemsPedidoDeCompra)
            
            const dadosAgrupados = {};
            
            itemsPedidoDeCompra.forEach(item => {
                const orderId = item.Order.AccountId;
                const linha = item.Linha__c;
                const marca = item.Marca__c;
                
                if (!dadosAgrupados[orderId]) {
                dadosAgrupados[orderId] = { Linhas: [], Marcas: [] };
                                        }
                                        
                                        if (!dadosAgrupados[orderId].Linhas.includes(linha)) {
                dadosAgrupados[orderId].Linhas.push(linha);
            }
            
            if (!dadosAgrupados[orderId].Marcas.includes(marca)) {
                dadosAgrupados[orderId].Marcas.push(marca);
            }
            
        });
        
        helper.empresas.forEach(function(empresaAtual){
            //verifica se a empresa atual é cliente
            if(empresaAtual.Cliente == "true"){
                var idEmpresa = empresaAtual.ID
                var dadosEmpresa = dadosAgrupados[idEmpresa];
                
                if(dadosEmpresa != undefined){
                    empresaAtual.Linhas = dadosEmpresa.Linhas;
                    empresaAtual.Marcas = dadosEmpresa.Marcas;
                } 
            }
        })
        if(valida1 == true){
            
            
            /* var options = {
        position: 'topright',
        geocoder: new L.Control.Geocoder.nominatim({
            geocodingQueryParams: {
                "countrycodes": "gb"
            }
        })
    };*/    
                
                var map = L.map('map').setView([-14.235004, -51.92528], 5);  // Defina a visualização para o Brasil
                L.tileLayer('http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png').addTo(map);
                
                
                
                helper.map = map;
                helper.teste(cmp, event, helper, helper.empresas, map);
            }
        helper.listaDeOpcoes(cmp, event, helper);
        
    })

    .catch(function (error) {
    
})

helper.novascontas(cmp, event, helper, map);
},
    
    inserePotos: function (cmp, event, helper, empresasClientes, map){
        helper.empresas.forEach(function(hospital) {
            
            var endereco  = hospital.Tipo_Logradouro +" " + hospital.Logradouro+ "-"+ hospital.Bairro+  ",  " +hospital.Cidade +  "-"+ hospital.Estado +  ", " + hospital.CEP;
            var consulta = true;
            
            try{                  
                var a = helper.getLatLog(cmp, event, helper, endereco, hospital, map, consulta, true);
            } catch(errr){
                
            }    
        });
        
        
    },  
        
    teste: function(cmp, event, helper, empresasClientes, map){
            
            var zoom;           
            helper.map.on('zoomend', function (e) {
                zoom = e.target._zoom;
            });
            
            // Evento 'moveend' para log da cidade quando houver interação com o mapa
            helper.map.on('moveend', function() {
                var center = helper.map.getCenter();
                var latitude = center.lat;
                var longitude = center.lng;
                var cidade =  $("#cidadeGet").html();
                var estado =  $("#estadoGet").html();
                
                if (zoom > 10) {
                    helper.btnNovaEmpresa = true;
                    
                    
                    if(helper.auxiliar == true){
                             $("#containerDoSpinner2").css("display", "flex"); 
                            helper.auxiliar = false
                        }
                    
                    
                    $('#botaoVet').removeClass('botao_desativado');
                    $('#botao').removeClass('botao_desativado');
                    $('#botaoVet').addClass('botao'); 
                    $('#botao').addClass('botao');
                    
                       
                      
                } else {
                    helper.btnNovaEmpresa = false;
                    
                    $('#botao').removeClass('botao');
                    $('#botao').removeClass('botao_desativado');
                    $('#botao').addClass('botao_desativado');
                    
                    
                    $('#botaoVet').removeClass('botao');
                    $('#botaoVet').removeClass('botao_desativado');
                    $('#botaoVet').addClass('botao_desativado');
                }
                
                helper.getCidade(cmp, event, helper,latitude, longitude, cidade, estado, map,zoom, null, null)
                
            });
            
            var mapOptions = {
                center: [-16.6955766, -49.2603644],
                zoom: 30
            };
            
            //EVENTO DO CHANGE DOS FILTROS                   
        $('#tiposRelatorio').on('change',function() {
            $(this).selectpicker('toggle');
            if($(this).val() == "NENHUM"){
                helper.linhaSelecionada = null;
            }else{
                helper.linhaSelecionada = $(this).val();
            }
            
            helper.spinner(); 
            
            setTimeout(() => {
                
                var tipoSelecionado = $(this).val();
                var center = helper.map.getCenter();
                var latitude = center.lat;
                var longitude = center.lng;
                var cidade =  $("#cidadeGet").html();
                var estado =  $("#estadoGet").html();
                
                var marcaSelecionada = helper.marcaSelecionada;
                
                
                
                
                if(zoom >10 ){
                    helper.getCidade(cmp, event, helper,latitude, longitude, cidade, estado, map,zoom, tipoSelecionado, marcaSelecionada)
                }                
               else{                      
                      helper.getCidade(cmp, event, helper,null, null, cidade, estado, map,zoom, tipoSelecionado, marcaSelecionada)
                     }

}, 0); 
        
        });   
            //EVENTO DO CHANGE DOS FILTROS         
            $('#subtipoRelatorio').on('change',function() {
               
     
                                 $(this).selectpicker('toggle');
            if($(this).val() == "NENHUM"){
                helper.marcaSelecionada = null;
            }else{
                   helper.marcaSelecionada = $(this).val(); 
            }
            
            helper.spinner(); 
            
            setTimeout(() => { 
                
                var tipoSelecionado = $(this).val();
                var center = helper.map.getCenter();
                var latitude = center.lat;
                var longitude = center.lng;
                var cidade =  $("#cidadeGet").html();
                var estado =  $("#estadoGet").html();
                
                
                
                var linhaSelecionada = helper.linhaSelecionada;
             
                if(zoom >10 ){
                    if(tipoSelecionado  != "NENHUM" && marcaSelecionada != "NENHUM"){
						helper.exibirAlerta(cmp, event, helper, "INFORMAÇÃO", "Info", "Para ver clientes de outros estados, basta visualizar o Continente Sul-Americano por completo. " )
                    }
                    
                    helper.getCidade(cmp, event, helper,latitude, longitude, cidade, estado, map,zoom, linhaSelecionada, tipoSelecionado)
                }
                
                else{ 
                    
               
                    
                    helper.getCidade(cmp, event, helper,null, null, cidade, estado, map,zoom,linhaSelecionada, tipoSelecionado)
                    
                    if(tipoSelecionado  != "NENHUM" && marcaSelecionada != "NENHUM"){helper.exibirAlerta(cmp, event, helper, "INFORMAÇÃO", "Info", "Para ver clientes de outros estados, basta visualizar o Continente Sul-Americano por completo. " )}
                    
                 
                }
                }, 0); 
            });  
        
            var marker = null;
            var circle = null;
            
            $("#pesquisar").on('click', function(event) {     
                
                var cidade = $("#cidade").val();
                
                // Utilize um serviço de geocodificação (Nominatim) para obter as coordenadas da cidade
                var geocodeUrl = 'https://nominatim.openstreetmap.org/search?format=json&q=' + cidade;
                
                fetch(geocodeUrl)
                .then(response => response.json())
                .then(data => {
                    if (data.length > 0) {
                    var lat = data[0].lat;
                    var lon = data[0].lon;
                    helper.map.setView([lat, lon], 20);
                    // Registrar o nome da cidade e estado no console
                    var city = data[0].display_name.split(',')[0];
                    var state = data[0].display_name.split(',')[1].trim();
                    
                } else {
                      console.log('Cidade não encontrada.');
            }
                               })
            .catch(error => console.error(error));
        });

$(".telefone").each(function(){
    $(this).on('click', function(event) {
        $(this).parent().parent().parent().children().eq(2).css({"display":"flex"});
    })
});

$(".emailbtn").each(function(){
    $(this).on('click', function(event) {
        $(this).parent().parent().parent().children().eq(3).css({"display":"flex"});
    })
});



var query = "SELECT Id,name,Latitude__c,Longitude__c,Cidade__c,Endere_o__c,Numero__c  from  Cliente__c"
//REALIZA A CONSULTA
this.soql(cmp, query)
//QUANDO A SOLICITAÇÃO FOR CONCLUÍDA, FAÇA:
.then(function (cliente) {
    
})
//trata excessão de erro
.catch(function (error) {
    
})
//.children().css({"color": "red", "border": "2px solid red"});
helper.inserePotos(cmp, event, helper, empresasClientes, map);


},
    
    spinner:function(){
          $("#containerDoSpinner3").css("display","flex");
    }
,    
    formatarCNPJ: function(cmp, event, helper, cnpj) {
        // Remove todos os caracteres que não sejam dígitos numéricos
        const cnpjLimpo = cnpj.replace(/\D/g, '');
        
        // Aplica a formatação do CNPJ: 00.000.000/0000-00
        return cnpjLimpo.replace(
            /^(\d{2})(\d{3})(\d{3})(\d{4})(\d{2})$/,
            '$1.$2.$3/$4-$5'
        );
    },     
        
    listaDeOpcoes: function(cmp, event, helper){
            
            
            helper.empresas.forEach(function(empresaAtual){
                helper.filtroLinhas(cmp, event, helper, empresaAtual);
                
            });
            
            //
            ///console.log('linhas: ' +  helper.linhasF);
            
            helper.linhasF =  [...new Set(helper.linhasF)]
            var listLinhasInsert = helper.linhasF;
            $('#tiposRelatorio').empty();
            $('#tiposRelatorio').append('<option selected="true" disabled="true">FILTRO POR LINHA</option>');
            $('#tiposRelatorio').append('<option>NENHUM</option>');
            listLinhasInsert.forEach(function(linhaatual){                
                var itemImpresso = '<option class = "linhasSelect">' + linhaatual + '</option>';
                $('#tiposRelatorio').append(itemImpresso);
            });
            
            //exibe select
            $("#tiposRelatorio").show()
            
            //destrói a instancia do selectpicker caso já esteja aplciada
            $('#tiposRelatorio').selectpicker('destroy');
            
            //cria a instancia do select com selectpicker
            $('.selectPickerLinha').selectpicker({
                dropupAuto: false  
            });
            
            
            helper.marcasF =  [...new Set(helper.marcasF)]
            var listMarcasInsert = helper.marcasF;
            
            console.log('marcas: ' +  helper.marcasF);
            
            
            $('#subtipoRelatorio').empty();
            $('#subtipoRelatorio').append('<option selected="true" disabled="true">FILTRO POR MARCA</option>');
            $('#subtipoRelatorio').append('<option>NENHUM</option>');
            listMarcasInsert.forEach(function(marcaAtual){                
                var itemImpresso = '<option class = "marcasSelect">' + marcaAtual + '</option>';
                $('#subtipoRelatorio').append(itemImpresso);
            });
            
            //exibe select
            $("#subtipoRelatorio").show()
            
            //destrói a instancia do selectpicker caso já esteja aplciada
            $('#subtipoRelatorio').selectpicker('destroy');
            
            //cria a instancia do select com selectpicker
            $('.selectPickerMarca').selectpicker({
                dropupAuto: false  
            });
            
            
        },       
            
 getCidade: function(cmp, event, helper, latitude, longitude, cidade, estado, map, zoom, linhaSelecionada, marcaSelecionada) {
     if (latitude != null && longitude != null) {
         var geocodeUrl = 'https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=' + latitude + '&lon=' + longitude;
         fetch(geocodeUrl)
         .then(response => response.json())
         .then(data => {
             var neighborhood = data.address.neighbourhood || '';
             var city = data.address.city || data.address.town;
             var state = data.address.state;
             var country = data.address.country;
             var suburb = data.address.suburb;
             if (cidade == city && linhaSelecionada == null) {
             $("#cidadeGet").html(city);
             $("#estadoGet").html(state);
         } else if (zoom > 10) {
             $("#cidadeGet").html(city);
             $("#estadoGet").html(state);
             
             if (city == 'Brasília' || city == 'Ceilândia' || city == 'Samambaia' || city == 'Plano Piloto' || city == 'Taguatinga' || city == 'SIA' || city == 'Fercal' || city == 'Varjão' || city == 'Candangolândia' || city == 'Park Way' || city == 'Núcleo Bandeirante' || city == 'Lago Sul' || city == 'Cruzeiro' || city == 'SCIA' || city == 'Lago Norte' || city == 'Arniqueira' || city == 'Riacho Fundo' || city == 'Jardim Botânico' || city == 'Brazlândia' || city == 'Sudoeste' || city == 'Octogonal' || city == 'Itapoã' || city == 'Paranoá' || city == 'Vicente Pires' || city == 'Sobradinho' || city == 'Sobradinho II' || city == 'Sol Nascente' || city == 'Pôr do Sol' || city == 'Riacho Fundo II' || city == 'São Sebastião' || city == 'Santa Maria' || city == 'Recanto das Emas' || city == 'Gama' || city == 'Guará' || city == 'Planaltina') {
                 city = 'Brasília';
             }
             
             var htlmlEMpresas = helper.empresas;
             $('#empresas').empty();
             
             function removeAccentsAndToUpperCase(inputString) {
                 const normalizedString = inputString.normalize("NFD").replace(/[\u0300-\u036f]/g, "");
                 return normalizedString.toUpperCase();
             }
             
             const inputString = city || '...';
             const cidadeFormatada = removeAccentsAndToUpperCase(inputString);
             const emps = htlmlEMpresas.filter((htlmlEMpresa) => htlmlEMpresa.Cidade == cidadeFormatada);
             
             helper.marketshere(cmp, event, helper, emps);
             
             helper.linhasF = [];
             helper.markesDelit = [];
             emps.forEach((hospitalFiltrado) => {
                 if (hospitalFiltrado.Cliente == 'true') {
                 helper.filtroLinhas(cmp, event, helper, hospitalFiltrado);
             }
                          });
             
             if (linhaSelecionada == null) {
                 helper.linhasF = [...new Set(helper.linhasF)];
                 var listLinhasInsert = helper.linhasF;
                 $('#tiposRelatorio').empty();
                 $('#tiposRelatorio').append('<option selected="true" disabled="true">FILTRO POR LINHA</option>');
                 $('#tiposRelatorio').append('<option>NENHUM</option>');
                 listLinhasInsert.forEach(function (linhaatual) {
                     var itemImpresso = '<option class="linhasSelect">' + linhaatual + '</option>';
                     $('#tiposRelatorio').append(itemImpresso);
                 });
                 
                 $("#tiposRelatorio").show();
                 $('#tiposRelatorio').selectpicker('destroy');
                 $('.selectPickerLinha').selectpicker({
                     dropupAuto: false
                 });
             }
             
             var objetosFiltradosSet = new Set();
             var listaSelecionadaDeLinhas = [];
             var marcaSelecionadaDeLinhas = [];
             
             if (linhaSelecionada == null) {
                 // Nenhuma linha selecionada, nenhuma ação adicional necessária
             } else if (linhaSelecionada == "NENHUM" || marcaSelecionada == "NENHUM") {
                 helper.markesDelit.forEach(function (markerAtual) {
                     helper.map.removeLayer(markerAtual);
                 });
                 
                 helper.markesDelit = [];
                 htlmlEMpresas.forEach((hospitalFiltrado) => {
                     try {
                     helper.getLatLog(cmp, event, helper, 'endereco', hospitalFiltrado, map, true, true);
                 } catch (e) {
                     console.log("error" + e);
                 }
             });
             helper.listaDeOpcoes(cmp, event, helper);
         } else {
             listaSelecionadaDeLinhas = [linhaSelecionada];
             marcaSelecionadaDeLinhas = [marcaSelecionada];
         }
         
         var empresas3 = [];
         
         if (listaSelecionadaDeLinhas.length > 0) {
             for (const objeto of emps) {
                 if (objeto.Linhas != null) {
                     for (const linha of objeto.Linhas) {
                         if (listaSelecionadaDeLinhas.includes(linha)) {
                             empresas3.push(objeto);
                             break;
                         }
                     }
                 }
             }
             
             helper.marcasF = [];
             empresas3.forEach(function (empresaAtual) {
                 helper.filtroLinhas(cmp, event, helper, empresaAtual);
             });
             helper.marcasF = [...new Set(helper.marcasF)];
             var listMarcasInsert = helper.marcasF;
             $('#subtipoRelatorio').empty();
             $('#subtipoRelatorio').append('<option selected="true" disabled="true">FILTRO POR MARCA</option>');
             $('#subtipoRelatorio').append('<option>NENHUM</option>');
             listMarcasInsert.forEach(function (marcaAtual) {
                 var itemImpresso = '<option class="linhasSelect">' + marcaAtual + '</option>';
                 $('#subtipoRelatorio').append(itemImpresso);
             });
             
             $("#subtipoRelatorio").show();
             $('#subtipoRelatorio').selectpicker('destroy');
             $('#subtipoRelatorio').selectpicker({
                 dropupAuto: false
             });
             
             if (marcaSelecionadaDeLinhas[0] != null && marcaSelecionadaDeLinhas[0] !== undefined && marcaSelecionadaDeLinhas[0] !== "NENHUM") {
                 const empresasFiltradasPorMarcas = empresas3.filter(objeto => {
                     if (objeto.Marcas != null) {
                     return objeto.Marcas.some(marca => marcaSelecionadaDeLinhas.includes(marca));
                 }
                                                                     return false;
                                                                     });
                 empresas3 = empresasFiltradasPorMarcas;
             }
             
             helper.markesDelit.forEach(function (markerAtual) {
                 helper.map.removeLayer(markerAtual);
             });
             
             helper.markesDelit = [];
             empresas3.forEach((empresaFiltrada) => {
                 helper.getLatLog(cmp, event, helper, 'endereco', empresaFiltrada, map, true, true);
             });
             } else {
                 $('#empresas').empty();
                 emps.forEach((hospitalFiltrado) => {
                 helper.getLatLog(cmp, event, helper, 'endereco', hospitalFiltrado, map, true, false);
             });
             }
                 
                 $("#containerDoSpinner2").css("display", "none");
             }
             })
                 .catch(error => console.error(error));
             }
                 
                 else {
                 console.log(linhaSelecionada, marcaSelecionada);               
                 var objetosFiltradosSet = new Set();
                 var listaSelecionadaDeLinhas = [linhaSelecionada];
                 var marcaSelecionadaDeLinhas = [marcaSelecionada];
                 
                 if (marcaSelecionadaDeLinhas[0] != null || listaSelecionadaDeLinhas[0] != null) {
                 for (const objeto of helper.empresas) {
                 const temMarca = objeto.Marcas && objeto.Marcas.some(marca => marcaSelecionadaDeLinhas.includes(marca));
                 const temLinha = objeto.Linhas && objeto.Linhas.some(linha => listaSelecionadaDeLinhas.includes(linha));
                 console.log("debuuuug: " + marcaSelecionadaDeLinhas);
                 // Verifica se ambos são selecionados, ou apenas um dos dois.
                 if ((marcaSelecionadaDeLinhas[0] != null && listaSelecionadaDeLinhas[0] != null && temMarca && temLinha) ||
                 (marcaSelecionadaDeLinhas[0] != null && listaSelecionadaDeLinhas[0] == null && temMarca) ||
                 (listaSelecionadaDeLinhas[0] != null && marcaSelecionadaDeLinhas[0] == null && temLinha)) {
                 objetosFiltradosSet.add(objeto);
             }
             }
                 
                 helper.markesDelit.forEach(function (markerAtual) {
                 helper.map.removeLayer(markerAtual);
             });
                 
                 helper.markesDelit = [];
                 $('#empresas').empty();
                 const objetosFiltrados = [...objetosFiltradosSet];
                 objetosFiltrados.forEach((hospitalFiltrado) => {
                 helper.getLatLog(cmp, event, helper, 'endereco', hospitalFiltrado, map, true, true);
             });
             } else {
                 helper.markesDelit.forEach(function (markerAtual) {
                 helper.map.removeLayer(markerAtual);
             });
                 
                 helper.markesDelit = [];
                 $('#empresas').empty();
                 helper.empresas.forEach((hospitalFiltrado) => {
                 helper.getLatLog(cmp, event, helper, 'endereco', hospitalFiltrado, map, true, true);
             });
             }
             }
                 
                 
                 
                 if (zoom < 4 && helper.markesDelit.length < 200) {
                        
                 		$('#empresas').empty();
                        
                 		helper.markesDelit.forEach(function (markerAtual) {
						   helper.map.removeLayer(markerAtual);
                        });
                         
                         helper.marcaSelecionada = null;
                         helper.linhaSelecionada = null;
                         
                         $("#tiposRelatorio").val(null);
                         $("#subtipoRelatorio").val(null);
                         
                         helper.marketshere(cmp, event, helper, helper.empresas);
                         helper.empresas.forEach((hospitalFiltrado) => {
                         helper.getLatLog(cmp, event, helper, 'endereco', hospitalFiltrado, map, true, true);
                     });
                         
                         helper.empresas.forEach((hospitalFiltrado) => {
                         if (hospitalFiltrado.Cliente == 'true') {
                         helper.filtroLinhas(cmp, event, helper, hospitalFiltrado);
                     }
                     });
                         
                         helper.linhasF = [...new Set(helper.linhasF)];
                         var listLinhasInsert = helper.linhasF;
                         $('#tiposRelatorio').empty();
                         $('#tiposRelatorio').append('<option selected="true" disabled="true">FILTRO POR LINHA</option>');
                         $('#tiposRelatorio').append('<option>NENHUM</option>');
                         listLinhasInsert.forEach(function (linhaatual) {
                         var itemImpresso = '<option class="linhasSelect">' + linhaatual + '</option>';
                         $('#tiposRelatorio').append(itemImpresso);
                     });
                         
                         $("#tiposRelatorio").show();
                         $('#tiposRelatorio').selectpicker('destroy');
                         $('.selectPickerLinha').selectpicker({
                         dropupAuto: false
                     });
                     
                     
                     
                     
                     helper.marcasF =  [...new Set(helper.marcasF)]
                     var listMarcasInsert = helper.marcasF;
                     
                     console.log('marcas: ' +  helper.marcasF);
                     
                     
                     $('#subtipoRelatorio').empty();
                     $('#subtipoRelatorio').append('<option selected="true" disabled="true">FILTRO POR MARCA</option>');
                     $('#subtipoRelatorio').append('<option>NENHUM</option>');
                     listMarcasInsert.forEach(function(marcaAtual){                
                         var itemImpresso = '<option class = "marcasSelect">' + marcaAtual + '</option>';
                         $('#subtipoRelatorio').append(itemImpresso);
                     });
                     
                     //exibe select
                     $("#subtipoRelatorio").show()
                     
                     //destrói a instancia do selectpicker caso já esteja aplciada
                     $('#subtipoRelatorio').selectpicker('destroy');
                     
                     //cria a instancia do select com selectpicker
                     $('.selectPickerMarca').selectpicker({
                         dropupAuto: false  
                     });
            }
         
           $("#containerDoSpinner3").css("display","none");
}
,
                
    removeAccentsAndToUpperCase: function(cmp, event, helper, inputString) {
                    // Remove os caracteres especiais e acentos
                    const normalizedString = inputString.normalize("NFD").replace(/[\u0300-\u036f]/g, "");
                    // Converte para uppercase
                    const uppercaseString = normalizedString.toUpperCase();
                    return uppercaseString;
                }     ,    
                    
    getLatLog: function(cmp, event, helper, endereco, hospital, map, consulta, marcador){
                        $("#containerDoSpinner").remove();
                        
                        
                        
                        // Exemplo de uso:
                        const inputString = hospital.Cidade || '...';
                        const cidade = helper.removeAccentsAndToUpperCase(cmp, event, helper,inputString);
                        //console.log(cidade); 
                        
                        if(hospital.Latitude != null && hospital.Longitude != null){
                            
                            var poiters2= [];
                            // Processar a resposta JSON aqui
                            // Acessar as coordenadas de latitude e longitude do primeiro resultado
                            
                            var latitude = hospital.Latitude || '';
                            var longitude = hospital.Longitude || '';
                            var name =  hospital.Name || '...';
                            var logradouro =  hospital.Logradouro || '...';
                            //var cidade =  hospital.Cidade || '...';
                            
                            //hospital.Cidade = cidade.to
                            var estado =  hospital.Estado || '...';
                            var id =  hospital.ID || '';
                            
                            var CNPJ;
                            
                            if(hospital.CNPJ){
                                CNPJ = helper.formatarCNPJ(cmp, event, helper, hospital.CNPJ);
                            }
                            
                            
                            var color = {
                                borda: '',
                                botao:'',
                                color:''
                            };
                            var whatsapp;
                            var pedido;
                            
                            
                            if(hospital.Cliente == 'false'){
                                if(hospital.Linha == null){
                                     	whatsapp = 'Cliente_novo';
                                        pedido =  'Cliente_Antigo';
                                        color.borda = 'Cliente_novo_Border';
                                        color.color ='red';
                                }else{
                                    whatsapp = 'Cliente_novo';
                                    pedido =  'Cliente_Antigo';
                                    color.borda = 'Cliente_novo_vet_Border';
                                    color.color = 'green';
                                }
                            }else if(hospital.Cliente == 'true'){
                                whatsapp = 'Cliente_Antigo';
                                pedido =  'Cliente_novo';
                                color.borda = 'Cliente_Antigo_Border';
                                color.color = 'blue';
                            }
                            
                            
                            
                            var html = ('\
                            <div class="empresa '+  color.borda +' " id="'+id +'" data-lat="'+ latitude +'" data-log="'+ longitude +'"    >\
                            <div class="sigla" id="HC'+id +'" > '+' </div>\
                            <div class="dados-da-empresa">\
                            \
                            <span class="nome">'+ name +' - '+CNPJ+'</span>\
                            \
                            <span class="endereco">'+ logradouro +'</span>\
                            \
                            <span class="estado">'+ cidade +' - '+ estado +'</span>\
                            \
                            <div class="nsei" style=" display:flex; gap:5px;">\
                            <button id="wts'+ id +'" class="telefone '+ whatsapp +'">whatsapp</button>\
                            <button id="pse'+ id +'" class="btn btn-outline-success my-2 my-sm-0 maisInfo '+ pedido +'" type="submit">Pedidos</button>\
                            </div>\
                            </div>\
                            <div class="telefones-container " id="tel'+ id +'" ><div class="close"><i class="fa fa-times-circle-o fa-2x color" aria-hidden="true"></i> </div> <!--div class="maisInfo"><span class="cnpj"><span class="valor-cnpj">05.743.288/0001-08</span></span>  <span class="endereco"> 74093-140</span> <span class="email"> contato@hospcom.net</span> <span class="endereco"> <span class="valor-logradouro">Rua 89</span><span class="valor-n">, 717</span>  <span class="complemento"><span class="valor-complemento">q 55, lt1</span></span>    </span>  </div--> <div class="container-whatsapp"></div></div> <div class="container-email" > <div class="close"><i class="fa fa-times-circle-o fa-2x color" aria-hidden="true"></i> </div>  <div class="container-emails" data-cnpj="sfdasfas"> </div></div> </div>')
                           
                            //console.log('++++++++++++++++++++++++++++');
                            try{
                                $('#empresas').append(html);
                                   $("#containerDoSpinner2").css("display", "none"); 
                            }catch(ee){
                                console.log(ee);
                            }
                            // console.log('///////////////'+ html);
                            // 
                            // 
                            
                            $("#wts"+hospital.ID ).on('click', function(ev) {
                                console.log(hospital);
                                console.log(ev);
                                
                                $(".close").parent().remove();
                                
                                helper.whatsapp(cmp, event, helper, hospital);
                                
                                $(".close").on('click', function() {
                                });
                                
                            })
                            
                            
                            $("#pse"+hospital.ID ).on('click', function(ev) {
                                helper.pesquisaMaisInfo(cmp, event, helper, hospital.CNPJ);
                            })
                            
                            
                            
                            var elemento = $('#' + id);
                            
                            elemento.on('click', function(event) {
                                console.log("EVENTO CAPTURADO: ", event.target.classList[0]);
                                
                                
                                if(event.target.classList[0] != "btn" &&  event.target.classList[0] != "telefone" ){
                                    helper.map.setView([latitude, longitude],20)
                                }
                                
                                
                                
                            })
                            
                            if((longitude!= false || latitude != false) && marcador == true){
                                
                                var redIcon = L.icon({
                                    iconUrl: 'https://raw.githubusercontent.com/pointhi/leaflet-color-markers/master/img/marker-icon-2x-'+ color.color+'.png',
                                    iconSize: [25, 41],
                                    iconAnchor: [12, 41],
                                    popupAnchor: [1, -34],
                                    shadowSize: [41, 41]
                                });
                                
                                var marker = L.marker([ latitude, longitude ],  { icon: redIcon }).addTo(helper.map);
                                const markerOBJ =  marker;
                                helper.markesDelit.push(markerOBJ);
                                
                                marker.on("click", function(enert) {
                                    
                                    $("#empresas").css("height","calc(100% - 50px)");
                                    $("#empresas").css("padding","20px 5px;");
                                    
                                    $("#container-empresas").css("height","98%");
                                    $("#bar-empresas").val(false)
                                    
                                    $(document).ready(function() {
                                        
                                        var container = $("#empresas");
                                        var targetChild = $('#' + id);
                                        var targetChildPosition = $('#' + id).position().top;
                                        
                                        var scrollTop = container.scrollTop() + targetChildPosition;
                                        
                                        container.animate({
                                            scrollTop: scrollTop
                                        }, 1500);
                                        
                                        setTimeout(()=>{
                                            $('#' + hospital.ID).css("box-shadow","0px 0px 7px 5px #1a365f");
                                        }, 500); 
                                            setTimeout(()=>{
                                            $('#' + hospital.ID).css("box-shadow","0 0 5px 1px #adadad");
                                        }, 1000);
                                            setTimeout(()=>{
                                            $('#' + hospital.ID).css("box-shadow","0px 0px 7px 5px #1a365f");
                                        }, 1800);
                                            setTimeout(()=>{
                                            $('#' + hospital.ID).css("box-shadow","0 0 5px 1px #adadad");
                                        }, 2500);
                                            setTimeout(()=>{
                                            $('#' + hospital.ID).css("box-shadow","0px 0px 7px 5px #1a365f");
                                        }, 3000);
                                            setTimeout(()=>{
                                            $('#' + hospital.ID).css("box-shadow","0 0 5px 1px #adadad");
                                        }, 3500);
                                            setTimeout(()=>{
                                            $('#' + hospital.ID).css("box-shadow","0px 0px 10px 4px #1a365f");
                                        }, 4000);
                                            setTimeout(()=>{
                                            $('#' + hospital.ID).css("box-shadow","0 0 5px 1px #adadad");
                                        }, 4800);
                                        });
                                        });
                                            
                                        }
                                        }
                                        } ,                                 
                                            
    whatsapp: function(cmp, event, helper, hospital) {
                                                const palavrasArray = hospital.Whatsapps.split(', ');
                                                var linksWatsapp = palavrasArray.filter(palavra => palavra !== "null");
                                                
                                                console.log("Visão pelo objeto: ", hospital.Whatsapps);
                                                console.log("Visão do array editado: ", linksWatsapp);
                                                
                                                var tags = "#" + hospital.Id;
                                                var container_wpp = $(tags);
                                                
                                                $('#mapa').append('\
                                                                <div class="whatsapp_container">\
                                                                <div class="close"> <span></span> <span>Contato</span>  <i class="fa fa-times-circle-o fa-2x color" aria-hidden="true"></i> </div>\
                                                                <div id="numeros"></div>\
                                                                </div>');
                                                
                                                
                                                
                                                try {
                                                    linksWatsapp.forEach(function(linkatual) {
                                                        var arraynumero = linkatual.split("=");
                                                        
                                                        console.log("Número atual: ", arraynumero[1]);
                                                        var formattedNumber = helper.formatPhoneNumber(arraynumero[1]);
                                                        
                                                        $("#numeros").append('\
                                                        <div class="numero_container">\
                                                        <a href="' + linkatual + '"  target="_blank">\
                                                        <i class="fa fa-phone" aria-hidden="true"></i>\
                                                        ' + formattedNumber + '\
                                                        <br/>\
                                                        </a>\
                                                        </div>');
                                                    });
                                                } catch (error) {
                                                    console.log(error);
                                                }
                                                
                                                $(".close").on('click', function() {
                                                    $(this).parent().remove();
                                                });
                                            },
                                            
    formatPhoneNumber :function (phoneNumber) {
                                                const cleaned = ('' + phoneNumber).replace(/\D/g, '');
                                                
                                                return '+55 (' + cleaned.substr(2, 2) + ') ' + cleaned.substr(4, 1) + ' ' + cleaned.substr(5, 4) + '-' + cleaned.substr(9, 4);
                                                
                                                //return phoneNumber; // Return original number if formatting doesn't match
                                            }  ,   
                                            
    pesquisaMaisInfo : function(cmp, event, helper, cnpj){
        
                                                try{
                                                    var action = cmp.get("c.maisInformacoesDaEmpresaCliente");
                                                    
                                                    action.setParams({
                                                        cnpj: cnpj
                                                    });
                                                    
                                                    action.setCallback(this, function(response) {
                                                        var state = response.getState();
                                                        if (state === "SUCCESS") {
                                                            
                                                            const pedidosSujo = response.getReturnValue();
                                                            const pedidosLimpo = pedidosSujo.replace("Resposta", ""); // Remover a parte indesejada
                                                            const pedidos = JSON.parse(pedidosLimpo);
                                                            
                                                            if(pedidos[0].Empresa != undefined ){
                                                                
                                                                var modalPedidos = '\
                                                                <div id="detalhesProduto">\
                                                                <div class="container">\
                                                                <div class="dados-do-pedido">\
                                                                <div class="campoPedido empresaPedido">\
                                                                <div class = "valor titulo tituloComponente"  id="empresaPedido">' + pedidos[0].Empresa +'</div>\
                                                                </div><div class="campoPedido cnpj">\
                                                                </div>\
                                                                </div>\
                                                                <div class="container-pedidos" id="container-pedidos">\
                                                                </div>\
                                                                </div>\
                                                                </div>';                   
                                                                $("#mapa").append(modalPedidos);
                                                            }
                                                            
                                                            for (const pedidoAtual2 of pedidos) {
                                                                //   console.log(pedidoAtual2);
                                                                //  console.log("teste")
                                                                var query = "SELECT   Linha__c, Marca__c FROM  OrderItem WHERE OrderId = '"+ pedidoAtual2.PedidoId +"'"
                                                                //console.log(query)
                                                                $("#container-pedidos").append('\
                                                                <div class="pedido" >\
                                                                <div class="campoPedido nomepedido"> Pedido:<a class = "linkPedido" target="_blank" href="https://hospcom.my.site.com/Sales/s/order/'+ pedidoAtual2.PedidoId +'"> '+ pedidoAtual2.PedidoName +' </a>\
                                                                </div>\
                                                                <div class="campoPedido data">\
                                                                <div class = "valor"  id="data"> 09/05/2023 </div>\
                                                                </div>\
                                                                <div class="produtos-do-pedido"><div class="container-linhas">\
                                                                <h5 class="tituloProd"> Marcas </h5>\
                                                                <div class="linhas" id="marca'+ pedidoAtual2.PedidoId +'">\
                                                                </div>\
                                                                </div>\
                                                                <div class="container-linhas">\
                                                                <h5 class="tituloProd"> Linhas </h5>\
                                                                <div class="linhas" id="linha'+ pedidoAtual2.PedidoId +'">\
                                                                </div>\
                                                                </div>\
                                                                </div>\
                                                                </div>')
                                                                
                                                                this.soql(cmp, query)
                                                                
                                                                //QUANDO A SOLICITAÇÃO FOR CONCLUÍDA, FAÇA: 
                                                                .then(function (itemDoProduto) {
                                                                    
                                                                    // console.log("REALIZA A CONSULTA")
                                                                    // console.log(itemDoProduto);
                                                                    
                                                                    var marcasDupli = [];
                                                                    var linhasDupli = [];
                                                                    
                                                                    itemDoProduto.forEach(element => {
                                                                        if(element.Marca__c){
                                                                        marcasDupli.push(element.Marca__c);
                                                                    }
                                                                                          if(element.Linha__c){
                                                                        linhasDupli.push(element.Linha__c);
                                                                    }
                                                                    
                                                                });
                                                                const linhas = [...new Set(linhasDupli)];
                                                                const marcas = [...new Set(marcasDupli)];
                                                                
                                                                // console.log("linhas: " + linhas);
                                                                // console.log("marcas: " + marcas);
                                                                
                                                                linhas.forEach(linhaatua => {
                                                                    $('#linha'+pedidoAtual2.PedidoId ).append('<div class="linha">' + linhaatua +'</div>')
                                                                })
                                                                    
                                                                    marcas.forEach(marcasatua => {
                                                                    $('#marca'+pedidoAtual2.PedidoId ).append('<div class="linha">'  + marcasatua +'</div>')
                                                                })
                                                                    
                                                                    $('#detalhesProduto').click(function(event) {
                                                                    // Verifica se o alvo do clique é a própria div pai
                                                                    if (event.target === this) {
                                                                    // console.log("Clique na div pai");
                                                                    
                                                                    $('#detalhesProduto').remove();
                                                                    // Coloque aqui a ação que você deseja disparar quando houver clique na div pai
                                                                }
                                                                });
                                                                })
                                                                    //trata excessão de erro
                                                                    .catch(function (error) {
                                                                    console.log("error")
                                                                    console.log(error)
                                                                })
                                                                }
                                                                    
                                                                } 
                                                                    else
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
                                                                    
                                                                } else {
                                                                    $(".load").css("display", "none");
                                                                    helper.exibirAlerta(cmp, event, helper, "error", "Error", "Falha ao tentar atualizar:" + errors)
                                                                    
                                                                    console.log("Erro desconhecido.");
                                                                    console.log("Erro: " + errors[i].message); 
                                                                }
                                                                }
                                                                    
                                                                });
                                                                    
                                                                    $A.enqueueAction(action);
                                                                    
                                                                } 
                                                                    catch (ex) {
                                                                    console.log("Erro ao executar ação: " + ex.message);
                                                                }
                                                                },    
                                                                    
    filtroLinhas: function(cmp, event, helper, hospital){
                                                                        if(hospital.Marcas){
                                                                            
                                                                            
                                                                            var marcaArray = hospital.Marcas
                                                                            marcaArray.forEach(function(marcaAtual){helper.marcasF.push(marcaAtual); })
                                                                            helper.marcasF =  [...new Set(helper.marcasF)]; 
                                                                            helper.marcasF = helper.marcasF.sort()
                                                                        }
                                                                        
                                                                        
                                                                        if(hospital.Linhas){
                                                                            var linhaArray = hospital.Linhas
                                                                            
                                                                            linhaArray.forEach(function(linhaAtual){ helper.linhasF.push(linhaAtual); })
                                                                            helper.linhasF =  [...new Set(  helper.linhasF)];
                                                                            helper.linhasF= helper.linhasF.sort(); 
                                                                        }
                                                                        
                                                                        // console.log(helper.linhasF);
                                                                    } ,   
                                                                    
    insereLisLinhas:function(cmp, event, helper, hospital, city){    
                                                                        const inputString = city || '...';
                                                                        
                                                                        const cidadeFormatada = helper.removeAccentsAndToUpperCase(inputString);
                                                                        
                                                                        const emps = htlmlEMpresas.filter((htlmlEMpresa) =>  helper.removeAccentsAndToUpperCase(htlmlEMpresa.Cidade) == cidadeFormatada);
                                                                        
                                                                        console.log('Empresas anteste da inserção: ', emps);
                                                                        // helper.getLatLog(cmp, event, helper, 'endereco', emps, map);            
                                                                    } ,   
                                                                    
    novascontas: function(cmp, event, helper,map){
                                                                        
                                                                        var query = "SELECT id, name, Profile.name FROM user WHERE id = '"+helper.recordId+"'"
                                                                        //REALIZA A CONSULTA
                                                                        this.soql(cmp, query)
                                                                        .then(function(usuario) {
                                                                            try{
                                                                                console.log("Usuario: ",usuario);
                                                                                var perfil = usuario[0].Profile.Name;
                                                                                
                                                                                
                                                                                console.log("User: ",usuario[0]);
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                if(perfil == "Administrador do sistema" || usuario[0].Id == "005U4000000nr81IAA" ||  usuario[0].Id == "005U4000000nr81" ){
                                                                                    
                                                                                    
                                                                                    console.log("*//**//**/");
                                                                                    
                                                                                    $('.container_botao_parent').empty();
                                                                                    
                                                                                    $(".container_botao_parent").append("\
                                                                                    <div class='container_botao' width ='100%'>\
                                                                                    <div class='botao_desativado' id='botao'>\
                                                                                    Novas Empresas\
                                                                                    </div>\
																					<div class='botao_desativado' id='botaoVet'>\
                                                                                    Novas Empresas VET\
                                                                                    </div>\
                                                                                    </div>       ")
                                                                                    
                                                                                    
                                                                                    
                                                                                    
                                                                                    
                                                                                    $("#botao").click(function(){
                                                                                        
                                                                                        var cidade = $("#cidadeGet").html();
                                                                                        var estado = $("#estadoGet").html();
                                                                                        estado = helper.pegaSiglaEstado(cmp, event, helper, estado);
                                                                                        //alert( cidade +"-"  + estado  + ' - '+  helper.btnNovaEmpresa);
                                                                                        
                                                                                        
                                                                                        if(helper.btnNovaEmpresa == true){
                                                                                            
                                                                                            var spinnerHTML = '<div id = "containerDoSpinner">\
                                                                                            <div class="spinner-border" role="status">\
                                                                                            <span class="visually-hidden"></span>\
                                                                                            </div>\
                                                                                            </div>'
                                                                                            
                                                                                            $("#mapa").append(spinnerHTML);
                                                                                            
                                                                                            
                                                                                            helper.consultaNovasEmpresas(cmp, event, helper, estado, cidade, null);
                                                                                            
                                                                                            
                                                                                            //helper.getCidade(cmp, event, helper,null, null, null, estado, map,10, "NENHUM", null);
                                                                                        }
                                                                                        
                                                                                        //console.log( cidade ,"-"  , estado  , ' - ',  helper.btnNovaEmpresa)
                                                                                    });    
                                                                                    
                                                                                    
                                                                                    
                                                                                    
                                                                                    
                                                                                    $("#botaoVet").click(function(){
                                                                                        
                                                                                        var cidade = $("#cidadeGet").html();
                                                                                        var estado = $("#estadoGet").html();
                                                                                        estado = helper.pegaSiglaEstado(cmp, event, helper, estado);
                                                                                        //alert( cidade +"-"  + estado  + ' - '+  helper.btnNovaEmpresa);
                                                                                        
                                                                                        
                                                                                        if(helper.btnNovaEmpresa == true){
                                                                                            
                                                                                            var spinnerHTML = '<div id = "containerDoSpinner">\
                                                                                            <div class="spinner-border" role="status">\
                                                                                            <span class="visually-hidden"></span>\
                                                                                            </div>\
                                                                                            </div>'
                                                                                            
                                                                                            $("#mapa").append(spinnerHTML);
                                                                                            
                                                                                            let vet= true;
                                                                                            
                                                                                            helper.consultaNovasEmpresas(cmp, event, helper, estado, cidade, vet);
                                                                                            
                                                                                            
                                                                                            //helper.getCidade(cmp, event, helper,null, null, null, estado, map,10, "NENHUM", null);
                                                                                        }
                                                                                        
                                                                                        //console.log( cidade ,"-"  , estado  , ' - ',  helper.btnNovaEmpresa)
                                                                                    });    
                                                                                    
                                                                                    
                                                                                }
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                            }catch(error){
                                                                                console.log(error)
                                                                            }
                                                                            
                                                                        })
                                                                        .catch(function(error) {
                                                                            console.log(error);
                                                                        });
                                                                        
                                                                        
                                                                        
                                                                    },
                                                                    
    consultaNovasEmpresas: function(cmp, event, helper, estado, cidade, vet){
                                                                        
                                                                        try{
                                                                            var action = cmp.get("c.consultaEmpresasAPI");
                                                                            
                                                                            action.setParams({
                                                                                cidade: cidade,
                                                                                estado: estado,

                                                                                vet: vet
                                                                                
                                                                            });
                                                                            
                                                                            action.setCallback(this, function(response) {
                                                                                var state = response.getState();
                                                                                if (state === "SUCCESS") {
                                                                                    //helper.exibirAlerta(cmp, event, helper, "success", "Sucesso", "Documento atualizado com sucesso!")
                                                                                    
                                                                                    try{
                                                                                        var action = cmp.get("c.procuraGeral");
                                                                                        
                                                                                        action.setParams({
                                                                                            cidade: cidade,
                                                                                            estado: estado,
                                                                                            limite: 20000
                                                                                        });
                                                                                        
                                                                                        action.setCallback(this, function(response) {
                                                                                            var state = response.getState();
                                                                                            if (state === "SUCCESS") {
                                                                                                helper.exibirAlerta(cmp, event, helper, "success", "Sucesso", "Novos clientes inserindos no mapa na cidade: "+ cidade)
                                                                                                
                                                                                                //CONVERTE EM UM OBJETO JSON
                                                                                                helper.empresas = JSON.parse(response.getReturnValue());
                                                                                                helper.preencheLinhasMarcas(cmp, event, helper, false); 
                                                                                                
                                                                                                try{
                                                                                                    var s = helper.novasEmpresasMetodos(cmp, event, helper,cidade);
                                                                                                }catch(e){
                                                                                                    console.log(e);
                                                                                                }
                                                                                                //  console.log(s)
                                                                                                
                                                                                            } else if (state === "ERROR") {
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
                                                                                                    
                                                                                                } else {
                                                                                                    $(".load").css("display", "none");
                                                                                                    helper.exibirAlerta(cmp, event, helper, "error", "Error", "Falha ao tentar atualizar:" + errors)
                                                                                                    
                                                                                                    console.log("Erro desconhecido.");
                                                                                                    console.log("Erro: " + errors[i].message); 
                                                                                                }
                                                                                            }
                                                                                        });
                                                                                        
                                                                                        $A.enqueueAction(action);
                                                                                        
                                                                                    } catch (ex) {
                                                                                        console.log("Erro ao executar ação: " + ex.message);
                                                                                    }
                                                                                    //helper.inserePotos(cmp, event, helper, helper.empresas, map);                    
                                                                                    //NAO SEI OQ A FUNCAO TESTE FAZ
                                                                                    
                                                                                    
                                                                                } else if (state === "ERROR") {
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
                                                                                        
                                                                                    } else {
                                                                                        $(".load").css("display", "none");
                                                                                        helper.exibirAlerta(cmp, event, helper, "error", "Error", "Falha ao tentar atualizar:" + errors)
                                                                                        
                                                                                        console.log("Erro desconhecido.");
                                                                                        console.log("Erro: " + errors[i].message); 
                                                                                    }
                                                                                }
                                                                            });
                                                                            
                                                                            $A.enqueueAction(action);
                                                                            
                                                                        } catch (ex) {
                                                                            console.log("Erro ao executar ação: " + ex.message);
                                                                        }
                                                                        
                                                                        // $("#containerDoSpinner").remove();
                                                                    },
                                                                    
    pegaSiglaEstado :function(cmp, event, helper, estado){                                                     
                                                                        const estados = {
                                                                            'Acre': 'AC',
                                                                            'Alagoas': 'AL',
                                                                            'Amapá': 'AP',
                                                                            'Amazonas': 'AM',
                                                                            'Bahia': 'BA',
                                                                            'Ceará': 'CE',
                                                                            'Distrito Federal': 'DF',
                                                                            'Espírito Santo': 'ES',
                                                                            'Goiás': 'GO',
                                                                            'Maranhão': 'MA',
                                                                            'Mato Grosso': 'MT',
                                                                            'Mato Grosso do Sul': 'MS',
                                                                            'Minas Gerais': 'MG',
                                                                            'Pará': 'PA',
                                                                            'Paraíba': 'PB',
                                                                            'Paraná': 'PR',
                                                                            'Pernambuco': 'PE',
                                                                            'Piauí': 'PI',
                                                                            'Rio de Janeiro': 'RJ',
                                                                            'Rio Grande do Norte': 'RN',
                                                                            'Rio Grande do Sul': 'RS',
                                                                            'Rondônia': 'RO',
                                                                            'Roraima': 'RR',
                                                                            'Santa Catarina': 'SC',
                                                                            'São Paulo': 'SP',
                                                                            'Sergipe': 'SE',
                                                                            'Tocantins': 'TO'
                                                                        };
                                                                        
                                                                        const sigla = estados[estado];
                                                                        return sigla || 'Estado não encontrado';
                                                                    },
                                                                    
    novasEmpresasMetodos: function(cmp, event, helper, cidadeatual){
                                                                        
                                                                        $('#empresas').empty(); 
        
                                                                        
                                                                        
                                                                        helper.markesDelit.forEach(function(markerAtual){
                                                                            helper.map.removeLayer(markerAtual);
                                                                        })                 
                                                                        helper.markesDelit=[];
                                                                        
                                                                        
                                                                        function removeAccentsAndToUpperCase(inputString) {
                                                                            const normalizedString = inputString.normalize("NFD").replace(/[\u0300-\u036f]/g, "");
                                                                            const uppercaseString = normalizedString.toUpperCase();
                                                                            
                                                                            return uppercaseString;
                                                                        }
                                                                        
                                                                        cidadeatual =  removeAccentsAndToUpperCase(cidadeatual);
                                                                        
                                                                        var empresasF = helper.empresas.filter((htlmlEMpresa) => htlmlEMpresa.Cidade == cidadeatual);
                                                                        
                                                                        
                                                                        console.log(empresasF)
                                                                        empresasF.forEach(function(empresaAtual){
                                                                            try{
                                                                                
                                                                                helper.getLatLog(cmp, event, helper, 'endereco', empresaAtual, map, true,true); 
                                                                                
                                                                            } catch(error){
                                                                                console.log(error)
                                                                            }
                                                                        })
                                                                        
                                                                        return 'passou aqui';
                                                                        
                                                                    },
                                                                    
    marketshere:function(cmp, event, helper, espaco_amostal){
                                                                        
                                                                        espaco_amostal = espaco_amostal.filter((empresaAtual) =>  empresaAtual.Latitude != null );
                                                                        var espaco_amostal_size = espaco_amostal.length; 
                                                                        helper.empresasClientes2 = espaco_amostal.filter((empresaAtual) => empresaAtual.Cliente == "true");
                                                                        var evento = helper.empresasClientes2.length; 
                                                                        var market_shere = (evento/espaco_amostal_size)*100;
                                                                        
                                                                        if(!(isNaN(market_shere))){
                                                                            market_shere = market_shere.toFixed(1) + "%"
                                                                        }else{
                                                                            market_shere = ""
                                                                        }
                                                                        console.log("EMPRESAS: ",espaco_amostal);
                                                                        console.log("CLIENTE: ", evento)
                                                                        console.log("QUANTIDADE: ", market_shere)
                                                                        $("#valorMTS").html(market_shere)
                                                                        
                                                                    } ,
                                                                    
    exibirAlerta : function(cmp, event, helper, type, title, message) {
                                                                        
                                                                        var toastEvent = $A.get("e.force:showToast");
                                                                        toastEvent.setParams({
                                                                            "type" : type,
                                                                            "title": title,
                                                                            "message": message
                                                                        });
                                                                        toastEvent.fire();
                                                                    }
                                                                    
 })