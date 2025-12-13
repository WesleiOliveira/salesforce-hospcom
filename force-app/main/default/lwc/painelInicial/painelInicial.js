import { LightningElement } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
import jQuery from '@salesforce/resourceUrl/JQuery'; // Nome do recurso estático
import soql from '@salesforce/apex/ApexHelperController.executeSoql';
import fontAwesome from '@salesforce/resourceUrl/fontAwesome';
import ChartJs from '@salesforce/resourceUrl/chartjs214';
import currentUserId from '@salesforce/user/Id';
console.log(currentUserId);

export default class YourComponent extends LightningElement {

    isResourcesLoaded = false; // Variável para controlar o carregamento
    negocios = [];
    dataUser = {};
    atividadesTeams = [];
    ativos = [];
    pendencias = [];
    metaMensalVenda = "";
    metaMensalValor = 0
    atingidoMetaAnual = 0;
    porcentagemAtingido = 0;
    metaAnual = "";
    quantidadeOpps = 0;
    winRate = 0;
    gapMensal = 0;
    saldoFerias = 0;
    diasFerias = 0;
    rotasViagem = [];
    ferias = [];

    renderedCallback() {
        if (this.isResourcesLoaded) {
            return;
        }
        this.isResourcesLoaded = true;

        // Carregar jQuery
        loadScript(this, jQuery)
            .then(() => {
                console.log('jQuery loaded successfully');
                this.onRender(); // Chama o método para usar jQuery após o carregamento
            })
            .catch(error => {
                console.error('Error loading jQuery:', error);
                alert('Error loading jQuery: ' + error.message); // Alertar sobre erro
            });

        // Load the Chart.js library
        loadScript(this, ChartJs)
        .then(() => {
            this.initializeChart();
        })
        .catch(error => {
            console.error('Error loading Chart.js:', error);
        });

        // Carregar Font Awesome
        loadStyle(this, fontAwesome + '/css/font-awesome.min.css')
            .then(() => {
                console.log('Font Awesome carregado com sucesso');
            })
            .catch(error => {
                console.error('Erro ao carregar o Font Awesome', error);
            });
    }


    initializeChart() {
        const ctx = this.template.querySelector('canvas').getContext('2d');
    
        // Configuração inicial do gráfico de acelerômetro
        this.chart = new Chart(ctx, {
            type: 'doughnut',
            data: {
                labels: ['Ponteiro', 'Espaço vazio'],
                datasets: [{
                    data: [30, 70], // 30 é o valor atual, 70 é o restante (total = 100)
                    backgroundColor: ['#FF0000', '#e0e0e0'], // Cor do ponteiro e espaço
                    borderWidth: 0
                }]
            },
            options: {
                maintainAspectRatio: false, // Vírgula aqui
                rotation: 1 * Math.PI, // Início do gráfico
                circumference: 1 * Math.PI, // Final do gráfico (meia-lua)
                cutoutPercentage: 80, // Cria o "anel" para efeito de ponteiro
                responsive: true,
                tooltips: { enabled: false }, // Remove tooltips para simplificar visualização
                legend: { display: false }
            }
        });
    }

    async onRender() {
        await this.getUserInfo()
        this.getMetaMensal()
        await this.getAtingidoMeta()
        this.getOppsAbertasMes()
        this.getMetaAnual()
        this.consultaOpps()
        this.consultaAtividades()
        this.consultaAtivos()
        this.consultaPendencias()
        this.getWinRate()
        this.getGapMensal()
        this.getRotas()
        this.getFerias()
    }

    async getAtingidoMeta(){
        const dataAtual = new Date();
        const ano = dataAtual.getFullYear();
        var dataInicio = ano + "-01-01";
        var dataFim = ano + "-12-31";

        var query = "SELECT OrderItem.Order.OrderNumber, OrderItem.Order.Natureza_de_opera_o__c, OrderItem.Order.Mes_de_ativacao__c, OrderItem.Order.Data_de_ativacao__c, TotalPrice, Fam_lia__c, OrderItem.Order.Departamento3__c, Linha__c FROM OrderItem WHERE OrderItem.Order.natureza_de_opera_o__c IN ('VENDA', 'SERVIÇO', 'LOCAÇÃO') AND OrderItem.Order.status not in ('Rascunho', 'Aguardando Aprovação Comercial', 'Aguardando Aprovação Financeira', 'Reprovado', 'Aprovado', 'Cancelado', 'Desativado', 'Pendente') and OrderItem.Order.vendedor__c = '"+currentUserId+"' AND OrderItem.Order.Data_de_ativacao__c >= "+dataInicio+" AND OrderItem.Order.Data_de_ativacao__c <= "+dataFim+""
        console.log("QUERY ATINGIDO VENDEDOR", query)
        var atingidoVendedor = await soql({ soql: query });
        var somaTotalPrice = atingidoVendedor.reduce((total, item) => total + item.TotalPrice, 0);
        var valor = new Intl.NumberFormat('pt-BR', { style: 'currency', currency: 'BRL' }).format(somaTotalPrice);

        console.log("ATINGIDO VENDEDOR", atingidoVendedor)
        console.log("SOMATORIO TOTAL ATINGIDO", valor)
        console.log("SOMA TOTAL PRICE", somaTotalPrice)

        this.atingidoMetaAnual = somaTotalPrice
    }

    async getMetaMensal(){
        console.log("GET META MENSAL", )

        const dataAtual = new Date();
        const ano = dataAtual.getFullYear();
        const mes = dataAtual.getMonth() + 1;

        var query = "select id, name, Meta__c from Goal__c where vendedor__c = '"+currentUserId+"' AND Mes__c = "+mes+" AND Ano__c = "+ano+" AND Tipo__c LIKE '%GERAL%'" 
        console.log("QUERY META MENSAL", query)
        
        var metasVendedor = await soql({ soql: query });
        var metaVendedor = new Intl.NumberFormat('pt-BR', { style: 'currency', currency: 'BRL' }).format(metasVendedor[0].Meta__c);
        this.metaMensalVenda = metaVendedor
        this.metaMensalValor = metasVendedor[0].Meta__c
    }

    async getMetaAnual(){
        const dataAtual = new Date();
        const ano = dataAtual.getFullYear();

        var query = "select id, name, Meta__c, Tipo__c from Goal__c where vendedor__c = '"+currentUserId+"' AND Ano__c = "+ano+" AND Name LIKE '%FY%' AND Tipo__c LIKE '%GERAL%'"
        var metaAnualVendedor = await soql({ soql: query });

        var metaAnual = metaAnualVendedor[0].Meta__c
        this.metaAnual = metaAnual

        var porcentagem = (this.atingidoMetaAnual / metaAnual) * 100;
        this.porcentagemAtingido = Math.round(porcentagem)

        const divElement = this.template.querySelector('[data-id="porcentagemDiv"]');

        // Define estilos diretamente
        if (divElement) {
            divElement.style.width = this.porcentagemAtingido + '%';
        }
    }

    async consultaAtivos(){
        var contatoResponsavel = this.dataUser.idContato

        if(contatoResponsavel){
            var query = "select Id, Name, SerialNumber, Modelo__c from asset where contatoResponsavel = '"+contatoResponsavel+"' OR usuarioResponsavel__c = '"+currentUserId+"'";
        }else{
            var query = "select Id, Name, SerialNumber, Modelo__c from asset where usuarioResponsavel__c = '"+currentUserId+"'";
        }
        
        console.log("QUERY ATIVOS", query)
        var ativos = await soql({ soql: query });

        ativos.forEach((ativoAtual) => {
            var id = ativoAtual.Id
            var nome = ativoAtual.Name
            var numeroSerie = ativoAtual.SerialNumber
            var modelo = ativoAtual.Modelo__c
            var url = "https://hospcom.my.site.com/Sales/s/asset/"+ id

            // Cria um objeto de negócio com as informações da oportunidade
            const novoAtivo = {
                id: id, // Gera um ID único
                nome: nome,
                numeroSerie: numeroSerie,
                modelo: modelo,
                url : url
            };

            // Adiciona o novo objeto de negócio ao array de negócios
            this.ativos = [...this.ativos, novoAtivo];
        });

        console.log("ATIVOS", this.ativos)
    }

    async consultaPendencias(){
        //console.log("CONSULTA PENDENCIAS")
        var query = "select id, Responsavel__r.name, Status__c, Name, Prazo_de_Finalizacao__c, Situacao__c, Dias_em_atraso__c from Pendencia__c WHERE Status__c != 'Fechado' ORDER BY Dias_em_atraso__c DESC"
        //console.log("QUERY PENDENCIAS", query)
        var pendencias = await soql({ soql: query });
        //console.log("PENDENCIAS RESULTADO", pendencias)

        pendencias.forEach((pendenciaAtual) => {
            var id = pendenciaAtual.Id
            var nome = pendenciaAtual.Name
            var status = pendenciaAtual.Status__c
            var situacao = pendenciaAtual.Situacao__c
            var prazo = pendenciaAtual.Prazo_de_Finalizacao__c
            var prazoData = new Date(prazo);
            var prazoFormatado = prazoData.toLocaleDateString('pt-BR');

            var url = "https://hospcom.my.site.com/Sales/s/pendencia/"+ id

            const novaPendencia = {
                id: id, // Gera um ID único
                nome: nome,
                status: status,
                situacao: situacao,
                prazo: prazoFormatado,
                url: url
            };

            this.pendencias = [...this.pendencias, novaPendencia];
        });
    }

    async getUserInfo(){

        var query = "SELECT FirstName, Id_do_contato__c, MiddleName, LastName, Username, Saldo_de_ferias__c FROM user WHERE Id = '"+currentUserId+"'";
        console.log("QUERY USUARIO", query)
        var usuario = await soql({ soql: query });

        var id = usuario[0].Id
        var idContato = usuario[0].Id_do_contato__c
        var primeiroNome = usuario[0].FirstName
        var Username = usuario[0].Username
        var saldoFerias = usuario[0].Saldo_de_ferias__c

        this.saldoFerias = saldoFerias

        const dataUser = {
            id: id,
            primeiroNome: primeiroNome,
            Username: Username,
            saldoFerias: saldoFerias,
            idContato: idContato
        };

        this.dataUser = dataUser
        console.log("DATA USER", this.dataUser)
    }

    async getWinRate(){
        var query = "select Id, Name, Amount, StageName from opportunity WHERE StageName in ('LOSS', 'WIN') and Amount >= 100000 ORDER BY Amount";
        var oportunidades = await soql({ soql: query });

        console.log("OPORTUNIDADES", oportunidades)

        // Contar quantidades de WIN e LOSS
        const winCount = oportunidades.filter(o => o.StageName === "WIN").length;
        const lossCount = oportunidades.filter(o => o.StageName === "LOSS").length;

        // Calcular Win Rate
        const totalCount = winCount + lossCount;
        const winRate = totalCount > 0 ? (winCount / totalCount) * 100 : 0;

        this.winRate = Math.round(winRate)

        const divElement = this.template.querySelector('[data-id="divWinRate"]');

        // Define estilos diretamente
        if (divElement) {
            divElement.style.width = this.winRate + '%';
        }


        console.log("WINRATE", winRate)
    }

    async getRotas(){
        var query = "select id, Name, Origem__c, Destino__c, Confirmada__c, Data_de_saida__c, Departamento__c from Rota_de_Viagem__c";
        var rotas = await soql({ soql: query });

        rotas.forEach((rotaAtual) => {
            var nome = rotaAtual.Name
            var origem = rotaAtual.Origem__c
            var destino = rotaAtual.Destino__c
            var confirmada = rotaAtual.Confirmada__c ? "Confirmada" : "Não confirmada"
            var dataSaida = rotaAtual.Data_de_saida__c
            var prazoData = new Date(dataSaida);
            var prazoFormatado = prazoData.toLocaleDateString('pt-BR');
            var departamento = rotaAtual.Departamento__c
            var id = rotaAtual.Id
            var url = "https://hospcom.my.site.com/Sales/s/rota-de-viagem/" + id

            const novaRota = {
                id: id, 
                nome: nome,
                origem: origem,
                destino: destino,
                confirmada: confirmada,
                dataSaida: prazoFormatado,
                departamento: departamento,
                url: url
            };

            this.rotasViagem = [...this.rotasViagem, novaRota];
        });

        console.log("ROTAS", this.negocios)
    }

    async getFerias(){
        var query = "select id, name, Data_Inicial__c, Status__c, Data_Final__c, Dias_totais__c  from Ferias__c limit 10"
        var ferias = await soql({ soql: query });

        ferias.forEach((feriasAtual) => {
            var id = feriasAtual.Id

            var nome = feriasAtual.Name
            var dataInicial = feriasAtual.Data_Inicial__c
            var status = feriasAtual.Status__c
            var diasTotais = feriasAtual.Dias_totais__c
            var dataFinal = feriasAtual.Data_Final__c
            var dataFinalTemp = new Date(dataFinal);
            var dataFinalFormatada = dataFinalTemp.toLocaleDateString('pt-BR');
            var dataInicialTemp = new Date(dataInicial);
            var dataInicialFormatada = dataInicialTemp.toLocaleDateString('pt-BR');
            
            var url = "https://hospcom.my.site.com/Sales/s/ferias/" + id

            const novaFerias = {
                id: id, 
                nome: nome,
                dataInicial: dataInicialFormatada,
                status: status,
                dataFinal: dataFinalFormatada,
                diasTotal: diasTotais,
                url: url
            };

            this.ferias = [...this.ferias, novaFerias];
        });

        console.log("FERIAS", this.ferias)
    
    }

    //PRINCIPAIS NEGÓCIOS
    async consultaOpps(){
        var query = "select Id, Name, Amount, StageName from opportunity WHERE StageName not in ('LOSS', 'WIN') and Amount >= 100000 ORDER BY Amount DESC limit 10";
        var oportunidades = await soql({ soql: query });

        oportunidades.forEach((oportunidadeAtual) => {
            var nome = oportunidadeAtual.Name
            var fase = oportunidadeAtual.StageName
            var valor = new Intl.NumberFormat('pt-BR', { style: 'currency', currency: 'BRL' }).format(oportunidadeAtual.Amount);
            var id = oportunidadeAtual.Id
            var url = "https://hospcom.my.site.com/Sales/s/opportunity/" + id

            // Cria um objeto de negócio com as informações da oportunidade
            const novoNegocio = {
                id: id, // Gera um ID único
                nome: nome,
                status: fase,
                valor: valor,
                url: url
            };

            // Adiciona o novo objeto de negócio ao array de negócios
            this.negocios = [...this.negocios, novoNegocio];
        });

        console.log("NEGOCIOS", this.negocios)
    }

    async getGapMensal(){
        const dataAtual = new Date();
        const ano = dataAtual.getFullYear();
        const mes = dataAtual.getMonth() + 1;

        var query = "select id, ordernumber, totalamount, data_de_ativacao__c, Mes_de_ativacao__c from order where status in ('ativo', 'em andamento', 'atendido total', 'atendido parcial', 'entregue parcial', 'entregue total') AND Mes_de_ativacao__c = "+mes+" AND anoAtivacao__c = "+ano+"" 
        var pedidos = await soql({ soql: query });
        console.log("pedidos", pedidos)

        const totalSum = pedidos.reduce((sum, order) => sum + order.TotalAmount, 0);

        console.log("META MENSAL VALOR", this.metaMensalValor)
        console.log("TOTAL SUM", totalSum)

        var gapPercent = ((1 - totalSum / this.metaMensalValor) * 100).toFixed(2);

        // Verifica se o gap é negativo e ajusta para no mínimo 0
        gapPercent = gapPercent < 0 ? 0 : gapPercent;

                
        this.gapMensal = Math.round(gapPercent)

        console.log("GAP", gapPercent)

        const divElement = this.template.querySelector('[data-id="divGapMensal"]');

        // Define estilos diretamente
        if (divElement) {
            divElement.style.width = this.gapMensal + '%';
        }

    }

    async consultaAtividades() {
        try {
            var userEmail = this.dataUser.Username

            // Substitua 'URL_DO_ENDPOINT' pela URL real do endpoint que você está chamando
            const response = await fetch('https://integracao.hospcom.net/teams-events?email='+userEmail+'', {
                method: 'GET',
                headers: {
                    'Content-Type': 'application/json'
                }
            });
    
            // Verifica se a resposta é bem-sucedida
            if (!response.ok) {
                throw new Error(`Erro na requisição: ${response.status}`);
            }
    
            // Converte a resposta para JSON
            const data = await response.json();
    
            // Acessa e trabalha com os eventos recebidos
            const eventos = data.events;
            console.log("EVENTOS", eventos)

            // Obter a data de hoje
            var hoje = new Date();
            hoje.setHours(0, 0, 0, 0); // Zerar a hora para comparar apenas datas

            // Filtrar os eventos que são de hoje em diante
            var eventosFuturos = eventos.filter(function(evento) {
                var dataEvento = new Date(evento.startDateTime);
                dataEvento.setHours(0, 0, 0, 0); // Zerar a hora para comparar apenas datas
                return dataEvento >= hoje; // Verifica se a data do evento é hoje ou no futuro
            });

            // Exemplo: iterar sobre os eventos
            eventosFuturos.forEach(evento => {

                var nomeEvento = evento.subject
                var inicioEvento = evento.startDateTime
                var fimEvento = evento.endDateTime
                var status = this.traduzirStatus(evento.status)
                var url = evento.meetingLink
                
                var data = new Date(inicioEvento);
                // Cria uma nova data com base no UTC ajustado
                var offset = -3; // Fuso horário em relação ao UTC (Brasil, por exemplo, é UTC-3)
                var dataComAjuste = new Date(data.getTime() + offset * 60 * 60 * 1000);

                var dataFormatada = dataComAjuste.toLocaleString('pt-BR');

                var amanha = new Date();
                amanha.setDate(hoje.getDate() + 1);

                // Resetando a hora para comparação apenas de data
                hoje.setHours(0, 0, 0, 0);
                amanha.setHours(0, 0, 0, 0);
                data.setHours(0, 0, 0, 0);

                var resultado = '';
                if (data.getTime() === hoje.getTime()) {
                    resultado = 'Hoje - ';
                } else if (data.getTime() === amanha.getTime()) {
                    resultado = 'Amanhã - ';
                }

                //Cria um objeto de negócio com as informações da oportunidade
                const novaAtividade = {
                    nomeAtividade: nomeEvento,
                    inicioAtividade: dataFormatada,
                    fimAtividade: fimEvento,
                    diaData: resultado,
                    origem: "Microsoft Teams",
                    status: status,
                    url: url
                };

                //Adiciona o novo objeto de negócio ao array de negócios
                this.atividadesTeams = [...this.atividadesTeams, novaAtividade];

            });
    
            
            // Retorna ou processa os eventos conforme necessário
            return eventos;
            
        } catch (error) {
            console.error('Erro ao buscar atividades:', error);
        }
    }

    async getOppsAbertasMes(){
        const dataAtual = new Date();
        const ano = dataAtual.getFullYear();
        const mes = dataAtual.getMonth() + 1;

        var query = "SELECT COUNT(Id) FROM Opportunity WHERE mesCriacao__c = "+mes+" AND anoCriacao__c = "+ano+""
        var quantidadeOpps = await soql({ soql: query });

        console.log("QUANTIDADE OPPS", quantidadeOpps[0].expr0)

        this.quantidadeOpps = quantidadeOpps[0].expr0
    }

    traduzirStatus(status) {
        let statusTraduzido;
    
        switch (status) {
            case 'busy':
                statusTraduzido = 'Ocupado';
                break;
            case 'free':
                statusTraduzido = 'Livre';
                break;
            case 'tentative':
                statusTraduzido = 'Provisório';
                break;
            case 'cancelado':
                statusTraduzido = 'Cancelado';
                break;
            default:
                statusTraduzido = 'Status desconhecido'; // Para lidar com valores inesperados
        }
    
        return statusTraduzido;
    }

    //ATUALIZAR VALORES DO GRÁFICO
    updateChart(newValue) {
        if (this.chart) {
            const total = 100; // Total de referência para o gráfico
            const restante = total - newValue;

            // Atualiza os dados do dataset
            this.chart.data.datasets[0].data = [newValue, restante];

            // Aplica a atualização ao gráfico
            this.chart.update();
        } else {
            console.error('O gráfico ainda não foi inicializado.');
        }
    }

    async handleQuery() {
        try {
            const soqlQuery = 'SELECT Id, Name FROM Account'; // Substitua pelo SOQL desejado
            var resultado = await soql({ soql: soqlQuery });
            console.log('Records:', resultado); // Exibe os resultados no console
        } catch (error) {
            //this.error = error;
            console.error('Error:', error);
        }
    }
}