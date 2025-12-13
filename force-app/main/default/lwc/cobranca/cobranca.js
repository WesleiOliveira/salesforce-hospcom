import { LightningElement, track } from 'lwc';
import executeSoql from '@salesforce/apex/ApexHelperController.executeSoql';
import getPicklistValue from '@salesforce/apex/ApexHelperController.listagem';
import fontAwesome from '@salesforce/resourceUrl/fontAwesome';
import JQuery from '@salesforce/resourceUrl/JQuery';
import userId from '@salesforce/user/Id';
import { loadStyle } from 'lightning/platformResourceLoader';
import { loadScript } from 'lightning/platformResourceLoader';
import * as utils from './utils/utils';
import * as conta from './querys/conta';
import * as contasAReceber from './querys/contasAReceber';
import * as pedidos from './querys/pedidos';
import * as eventos from './querys/eventos';
import * as regras from './businesRules';
import { getUser } from './querys/user';
import * as httpRequest from './utils/httpsRequests';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import * as logs from './querys/RegistrosDeSincronizacao';
import HttpsOption from '@salesforce/schema/Domain.HttpsOption';

export default class cobranca extends LightningElement {
  //Array de contas retornadas de loadContas()
  @track contas = [];
  @track contaSelecionadaId = null;
  @track conta = [];
  @track contasCarregadas = false;
  //Pedidos da conta clicada
  @track pedidos = [];
  @track pedidosIsLoading = true;
  @track pedidosContasReceber = [];

  popupLigar = false;

  secaoNegociar = false;

  //Numero selecionado para ligar
  @track numeroSelecionado = '';
  
  //Contas à erceber da conta clicada
  @track contasAReceber = [];
  @track contasAReceberIsLoading = true;
  @track contasSelecionadas = [];

  @track filtroContasAReceber = 'todos';

  //Eventos financeiros relacionados a conta selecionada
  @track eventos = [];
  @track eventosIsLoading = true;
  @track eventoSelecionado;

  //Janela lateral com detalhes da conta selecionada
  @track mostrarDetalhes = false;
  @track isLoading = true;
  @track activeTab = 'cliente';

  popUpCalcular = false;

  valoMaximoDescontoJuros = regras.VALOR_MAXIMO_DESCONTO_JUROS
  valoMaximoDescontoMulta = regras.VALOR_MAXIMO_DESCONTO_MULTA


  allPopupAreClosed = true;

  @track negociacao;
  @track proposta;

  //resultados do SELECT
  filaSelecionada = "todos";
  reguaSelecionada = '';

  // Opções para os picklists da criação de evento

  carregarEventoPickList() {

    // if (!this.contasSelecionadasEmAberto) {
    //   this.tipoOptions = [{ label: 'Pago', value: 'Pago' }]

    // } else {



    getPicklistValue({ nomeObjeto: 'Evento_financeiro__c', nomeCampo: 'Tipo__c' })
      .then(result => {
        this.tipoOptions = result.map(item => ({
          label: item,
          value: item
        }));
        this.novoEvento.tipoSelecionado = this.tipoOptions[0].value;
        console.log("Object 1: ", this.tipoOptions);
        console.log("Stringfy: ", JSON.stringify(this.tipoOptions));

      })
      .catch(error => {
        console.error(error);
      });
  }
  // get checkUser() {
  //   return this.user.Id === '00531000006UzZsAAK'
  // }

  handleChange(event) {
    this.value = event.detail.value;
  }

  handleChange(event) {
    this.value = event.detail.value;
  }

  @track user = {};
  //Registros de sincronização
  @track registroDeSincronizcao = {};

  async connectedCallback() {

    this.user = await getUser(userId, executeSoql);
    //this.loadLogs();

    this.inicializarNegociacao();
    this.handleKeyDown = this.handleKeyDown.bind(this);
    document.addEventListener('keydown', this.handleKeyDown);

    //carrega registros de sincronização


    // Load jQuery
    loadScript(this, JQuery)
      .then(() => {
        ////console.log('jQuery carregado');
      })
      .catch(error => {
        console.error('Erro ao carregar jQuery', error);
      });

    // Load Font Awesome
    loadStyle(this, fontAwesome + '/css/font-awesome.min.css')
      .then(() => {

        ////console.log('Font Awesome carregado com sucesso');
      }).finally(() => {
        conta.loadContas('', this.filaSelecionada, this.reguaSelecionada, this, utils, executeSoql);
        setTimeout(() => {
          this.openSearchBar();
        }, 3000);
      });

  }
  intervalId;
  @track atualizandoLogs = false;

  get atualizandoLogsString() {
    return this.atualizandoLogs ? 'Atualizando' : 'Clique para sincronizar com SAP'
  }

  get refreshIconClass() {
    return this.atualizandoLogs ? 'fa fa-refresh spinning' : 'fa fa-refresh refreshIcon';
  }

  async atualizarLogs() {
    if (this.atualizandoLogs === true) { return }

    this.atualizandoLogs = true;
    try {
      await httpRequest.updateNotasDoSap(this);

      //this.registroDeSincronizcao = await logs.load(executeSoql);

    } catch (error) {
      this.toast('Erro', 'Houve um erro ao tentar atualizar.', 'error', 'dismiss');
      console.error('Erro ao atualizar logs:', error);
    }
  }


  async loadLogs() {
    this.registroDeSincronizcao = await logs.load(executeSoql);

    this.intervalId = setInterval(async () => {
      this.registroDeSincronizcao = await logs.load(executeSoql);
    }, 60000);
  }

  // GETTER PARA AS OPÇÕES DO FILTRO DOS EVENTOS
  get filtroOptions() {
    return [
      { label: 'Todos', value: 'todos' },
      { label: 'Pagos', value: 'pagos' },
      { label: 'Em Aberto', value: 'em_aberto' }
    ];
  }
  get opcoesPagamento() {
    return [
      { label: 'À Vista', value: 'avista' },
      { label: 'Parcelado', value: 'parcelado' },
    ];
  }

  // HANDLER PARA MUDANÇA DO FILTRO
  handleFiltroChange(event) {
    this.filtroContasAReceber = event.target.value;
    ////console.log('Filtro selecionado:', this.filtroContasAReceber);

    // Recarrega as contas a receber com o novo filtro
    if (this.contaSelecionadaId) {
      this.recarregarContasAReceber();
    }
  }
  get getContaNameSize() {
    return this.mostrarDetalhes ? 'nome nome-reduzido' : 'nome'
  }
  get nenhumaContaEncontrada() {
    return !this.loadingContas && (!this.contas || this.contas.length === 0);
  }

  @track nomeDaContaASerBuscada = '';
  @track ultimoNomeBuscado = '';
  @track loadingContas = false;
  searchTimeout;


  buscarContaPeloNome(event) {
    const name = event.target.value;
    this.nomeDaContaASerBuscada = name;

    ////console.log("Search input:", name, "Key:", event.key);

    // Se apertar Enter, dispara imediatamente
    if (event.key === 'Enter') {
      clearTimeout(this.searchTimeout);

      if (name !== this.ultimoNomeBuscado) {
        ////console.log("🔍 SEARCH TRIGGERED BY ENTER");

        this.ultimoNomeBuscado = name;

        conta.loadContas(
          name,
          this.filaSelecionada,
          this.reguaSelecionada,
          this,
          utils,
          executeSoql
        );
      }
      return;
    }

    // Cancela o timer anterior
    clearTimeout(this.searchTimeout);

    // Só dispara a busca se houver texto (ou pode deixar '' se quiser carregar todas)
    this.searchTimeout = setTimeout(() => {
      if (name !== this.ultimoNomeBuscado) {
        ////console.log("🔍 SEARCH TRIGGERED");

        this.ultimoNomeBuscado = name;

        conta.loadContas(
          name,
          this.filaSelecionada,
          this.reguaSelecionada,
          this,
          utils,
          executeSoql
        );
      }
    }, 3000); // 3000ms = 3s
  }

  openSearchBar() {
    const bar = this.template.querySelector('.search-bar');
    bar.classList.add('open');
  }

  closeSearchBar() {
    const bar = this.template.querySelector('.search-bar');
    bar.classList.remove('open');
    ////console.log("🔄 CLEARING SEARCH");
    if (!this.nomeDaContaASerBuscada || this.nomeDaContaASerBuscada === '') {
      conta.loadContas('', this.filaSelecionada, this.reguaSelecionada, this, utils, executeSoql);
      conta.resetContas(this);
    }
    this.nomeDaContaASerBuscada = '';
    this.ultimoNomeBuscado = '';

  }

  toast(titulo, mensagem, variante = 'info', modo = 'dismissable') {
    const event = new ShowToastEvent({
      title: titulo,
      message: mensagem,
      variant: variante,  // 'success', 'error', 'warning', 'info'
      mode: modo          // 'dismissable', 'pester', 'sticky'
    });
    this.dispatchEvent(event);
  }

  // MÉTODO PARA RECARREGAR CONTAS A RECEBER COM FILTRO
  async recarregarContasAReceber() {
    // Limpa seleções anteriores
    this.contasSelecionadas = [];

    // Chama o método load passando o filtro
    await contasAReceber.load(
      this,
      this.contaSelecionadaId,
      executeSoql,
      utils,
      this.filtroContasAReceber
    );
  }

  callbackCount = 0;
  renderedCallback() {
    if (this.callbackCount === 1) { window.scrollTo(0, 0) };
    this.callbackCount++;


  }

  showSpinner() {
    this.isLoading = true;
  }

  hideSpinner() {
    this.isLoading = false;
  }

  mostrarMais() {
    //console.log("📄 MOSTRAR MAIS TRIGGERED");
    // Same function - it will detect this is pagination, not a new search
    conta.loadContas(
      this.nomeDaContaASerBuscada,
      this.filaSelecionada,
      this.reguaSelecionada,
      this,
      utils,
      executeSoql
    );
  }

  async abrirCalcularPopUp() {
    this.allPopupAreClosed = false;
    this.showSpinner();

    await pedidos.load(this, this.contaSelecionadaId, executeSoql, utils);
    await pedidos.loadPedidosDeContasAReceber(this, this.contasAReceber);
    setTimeout(() => {
      this.hideSpinner();
      this.popUpCalcular = true;

      // Aguarda o DOM renderizar antes de aplicar a animação
      setTimeout(() => {
        const popup = this.template.querySelector('.popup');
        if (popup) {
          popup.classList.add('show');
        }
      }, 50); // pequeno atraso para garantir que o DOM já tenha exibido o pop-up
    }, 1000);
  }

  fecharCalcularPopUp() {
    const popup = this.template.querySelector('.popup');
    if (popup) {
      popup.classList.add('show');
    }
    this.popUpCalcular = false;
    this.secaoNegociar = false;
    this.negociacao = [];
    this.pedidosContasReceber = [];
    this.inicializarNegociacao();
  }

  get contasAReceberNaoVazia() {
    return this.contasAReceber && this.contasAReceber.length > 0;
  }

  async handleCardClick(event) {
    this.eventosIsLoading = true;
    this.contasAReceberIsLoading = true;

    const id = event.currentTarget.dataset.id;
    const clickedCard = event.currentTarget;

    if (id === this.contaSelecionadaId) {
      this.fecharDetalhes();
      return;
    }

    this.eventos = [];
    this.activeTab = 'cliente';
    this.pedidos = [];
    this.contasAReceber = [];
    this.conta = [];
    this.contasSelecionadas = []; // Limpa seleções
    this.filtroContasAReceber = 'todos'
    // Remove classe 'selected' de todos os cards
    $(this.template.querySelectorAll('.conta-card')).removeClass('selected');
    $(clickedCard).addClass('selected');

    this.contaSelecionadaId = id;
    this.mostrarDetalhes = true;

    await conta.load(this, id, executeSoql, utils);
    await contasAReceber.load(this, this.contaSelecionadaId, executeSoql, utils);
    await eventos.load(this, this.contaSelecionadaId, executeSoql, utils);

  }

  fecharDetalhes() {
    this.eventos = [];
    this.contasAReceber = [];
    this.pedidos = [];
    this.activeTab = 'cliente';
    this.contaSelecionadaId = null;
    this.conta = [];
    this.mostrarDetalhes = false;


    $(this.template.querySelectorAll('.conta-card')).removeClass('selected');

  }
  // há mais contas á serem mostradas? 
  @track hasMore = true;
  //TODO Make it automatic with listagem method
  filas = [
    { label: 'Todos', value: 'todos' },
    { label: 'Clientes Privados', value: 'PRIVADO' },
    { label: 'Clientes público', value: 'PUBLICO' },
    { label: 'Clientes filantropia', value: 'FILANTROPIA' }
  ];
  reguas = [
    { label: 'Todos', value: '' },
    { label: '10 dias', value: 10 },
    { label: '15 dias', value: 15 },
    { label: '20 dias', value: 20 },
    { label: '30 dias', value: 30 }
  ];
  //=======Filtros=========
  handleFilaChange(e) {
    this.filaSelecionada = e.target.value;
    this.eventos = [];
    this.pedidos = [];
    this.contasAReceber = [];
    this.mostrarDetalhes = false;
    conta.offset = 0;
    conta.hasMore = true;
    //this.contas = []
    conta.loadContas(
      this.nomeDaContaASerBuscada,
      this.filaSelecionada,
      this.reguaSelecionada,
      this,
      utils,
      executeSoql
    );
    //console.log("Fila selecioanada: " + this.filaSelecionada);
  }

  handleReguaChange(e) {
    this.eventos = [];
    this.pedidos = [];
    this.contasAReceber = [];
    this.reguaSelecionada = e.target.value;
    this.mostrarDetalhes = false;
    conta.offset = 0;
    conta.hasMore = true;
    //this.contas = [];
    // Use loadContas - it will detect filter change and reset
    conta.loadContas(
      this.nomeDaContaASerBuscada,
      this.filaSelecionada,
      this.reguaSelecionada,
      this,
      utils,
      executeSoql
    );
    //console.log("Regua selecioanada: " + this.reguaSelecionada);
  }
  //======================




  //Classes css para conteiners 
  get contaContainerClass() {
    return this.mostrarDetalhes ? 'contaContainer reduzida' : 'contaContainer';
  }
  get conteudoFlex() {
    return this.mostrarDetalhes ? 'conteudo-flex flex' : 'conteudo-flex';
  }
  get contaCardClass() {
    return this.mostrarDetalhes ? 'conta-card' : 'conta-card';
  }
  //Carrega contas com base nos filtros selecionados

  // ========Handlers para tabs do card de informações==============
  handleTabClick(event) {
    this.activeTab = event.target.dataset.tab;
    if (this.activeTab === 'pedidos' && this.pedidos.length === 0) {
      pedidos.load(this, this.contaSelecionadaId, executeSoql, utils);
    }
  }
  get contatoTabClass() {
    return this.activeTab === 'contato' ? 'tab-button active' : 'tab-button';
  }

  get clienteTabClass() {
    return this.activeTab === 'cliente' ? 'tab-button active' : 'tab-button';
  }


  get pedidosTabClass() {
    return this.activeTab === 'pedidos' ? 'tab-button active' : 'tab-button';
  }

  get showContato() {
    return this.activeTab === 'contato';
  }

  get showCliente() {
    return this.activeTab === 'cliente';
  }


  get showPedidos() {
    return this.activeTab === 'pedidos';
  }
  //==================================================================


  get desabilitarSalvar() {
    return this.novoEvento.tipoSelecionado && this.novoEvento.descricao;
  }



  handleKeyDown(event) {
    if (event.key === 'Escape') {
      if (this.allPopupAreClosed) {
        this.fecharDetalhes()
      }
      else { this.closePopUps(); }

    }
  }
  closePopUps() {
    this.fecharEventoPopUp();
    this.fecharCalcularPopUp();
    this.fecharPopupLigar();
    this.eventoSelecionado = null;
    this.popupLigar = false;
    this.allPopupAreClosed = true;
    this.fecharEventoSelecionado();

  }
  get contactUrl() {
    if (!this.conta?.ultimo_contato_conta__c) return '#';
    return `/Sales/s/contact/${this.conta.ultimo_contato_conta__c}`;
  }
  orderUrl(event) {
    const orderId = event.target.dataset.id;
    window.open(`/Sales/s/order/${orderId}`, '_blank');
  }

  handleDivClick(event) {
    const contaId = event.currentTarget.dataset.id;

    // Encontra o checkbox dentro da div clicada
    const checkbox = event.currentTarget.querySelector('.linha-contasAReceber');

    // Se não há checkbox (conta paga), não faz nada
    if (!checkbox) {
      return;
    }

    // Previne que o clique no checkbox dispare o evento da div também
    if (event.target === checkbox) {
      return;
    }

    // Alterna o estado do checkbox
    checkbox.checked = !checkbox.checked;

    // Chama o método de mudança do checkbox
    this.updateContasSelecionadas(contaId, checkbox.checked);
  }

  // Método para lidar com mudanças diretas no checkbox
  handleCheckboxChange(event) {
    const contaId = event.target.dataset.id;
    const isChecked = event.target.checked;

    this.updateContasSelecionadas(contaId, isChecked);
  }

  // Método centralizado para atualizar as contas selecionadas
  updateContasSelecionadas(contaId, isChecked) {
    if (isChecked) {
      // Encontra o objeto completo da conta
      const contaCompleta = this.contasAReceber.find(conta => conta.Id === contaId);

      if (contaCompleta && !this.contasSelecionadas.find(c => c.Id === contaId)) {
        // Cria uma cópia do objeto para evitar referências
        const contaCopia = { ...contaCompleta };
        this.contasSelecionadas = [...this.contasSelecionadas, contaCopia];
      }
    } else {
      // Remove o objeto do array
      this.contasSelecionadas = this.contasSelecionadas.filter(conta => conta.Id !== contaId);
    }

    //console.log('Contas selecionadas:', this.contasSelecionadas);
  }


  // Getter principal para calcular o resumo das contas selecionadas
  get resumoCalculado() {
    ////console.log('Calculando resumo para:', this.contasSelecionadas);

    if (!this.contasSelecionadas || this.contasSelecionadas.length === 0) {
      return {
        quantidade: 0,
        valorBase: 0,
        multa: 0,
        juros: 0,
        valorPago: 0,
        totalAPagar: 0,
        valorBaseLabel: 'R$ 0,00',
        multaLabel: 'R$ 0,00',
        jurosLabel: 'R$ 0,00',
        valorPagoLabel: 'R$ 0,00',
        totalAPagarLabel: 'R$ 0,00'
      };
    }

    let valorBase = 0;
    let multa = 0;
    let juros = 0;
    let valorPago = 0;
    let totalAPagar = 0;
    let docEntry = [];

    this.contasSelecionadas.forEach(conta => {
      ////console.log('Processando conta:', conta);

      // Valor principal (recebimento) - usando valores reais
      const valorConta = conta.Valor_do_recebimento__c || 0;
      valorBase += valorConta;
      ////console.log('Valor da conta (real):', valorConta, 'Valor base acumulado:', valorBase);

      // Multa - usando valor real
      const multaConta = conta.Multa_calculada__c || 0;
      multa += multaConta;
      ////console.log('Multa da conta (real):', multaConta, 'Multa acumulada:', multa);

      // Juros - usando valor real
      const jurosConta = conta.Juros_calculado__c || 0;
      juros += jurosConta;
      ////console.log('Juros da conta (real):', jurosConta, 'Juros acumulados:', juros);

      // Valor pago - usando valor real
      const valorPagoConta = conta.Valor_pago__c || 0;
      valorPago += valorPagoConta;
      ////console.log('Valor pago da conta (real):', valorPagoConta, 'Valor pago acumulado:', valorPago);

      // Total a pagar - usando o campo calculado da conta
      const totalContaAPagar = conta.Valor_a_pagar__c || 0;
      totalAPagar += totalContaAPagar;
      ////console.log('Total a pagar da conta (real):', totalContaAPagar, 'Total a pagar acumulado:', totalAPagar);

      if (conta.docEntry) {
        docEntry.push(conta.docEntry);
      }
      ////console.log("DocEntry array so far: ", docEntry);
    });

    const resultado = {
      docEntry: docEntry,
      quantidade: this.contasSelecionadas.length,
      valorBase: valorBase,
      multa: multa,
      juros: juros,
      valorPago: valorPago,
      totalAPagar: totalAPagar,
      valorBaseLabel: utils.formatarValor(valorBase),
      multaLabel: utils.formatarValor(multa),
      jurosLabel: utils.formatarValor(juros),
      valorPagoLabel: utils.formatarValor(valorPago),
      totalAPagarLabel: utils.formatarValor(totalAPagar)
    };

    ////console.log('Resultado final do cálculo:', resultado);
    return resultado;
  }


  fecharEventoSelecionado() {
    this.eventoSelecionado = '';
  }

  abrirEventoSelecionado(event) {
    this.allPopupAreClosed = false;
    const eventoId = event.currentTarget.dataset.id;

    const eventoEncontrado = this.eventos.find(evt => evt.Id === eventoId);

    if (eventoEncontrado) {
      this.eventoSelecionado = eventoEncontrado;
      //console.log("Evento selecionado: ", JSON.stringify(this.eventoSelecionado))
    } else {
      console.warn('Evento não encontrado:', eventoId);
      this.eventoSelecionado = null;
    }
  }

  get cobradorFotoClass() {
    if (this.eventoSelecionado.isAgente) {
      return 'cobrador-info ' + 'agentFoto';
    }
    return 'cobrador-info'
  }
  //==========Pop tela de ligação==========
  async fecharPopupLigar() {
    this.popupLigar = false;
    this.isLoading = true

    this.numeroSelecionado = '';
    this.ligando = false;
    await utils.delay(2000);

    if (this.numeroSelecionado || this.ligando) {
      this.eventos = []
      eventos.load(this, this.contaSelecionadaId, executeSoql, utils);
    }
    this.isLoading = false;
  }
  abrirPopupLigar() {
    this.allPopupAreClosed = false;
    this.popupLigar = true;

  }
  get popupLigarClass() {
  }
  handleNumeroChange(event) {

    this.numeroSelecionado = event.target.value;
    //console.log("Numero selecionado: " + this.numeroSelecionado)
  }
  handleNumeroClick(event) {
    const numero = event.currentTarget.dataset.phone;
    if (this.numeroSelecionado === numero) {
      this.numeroSelecionado = '';
      return
    }
    this.numeroSelecionado = numero;
    //console.log('Telefone selecionado:', this.numeroSelecionado);
  }

  @track iframeUrl = '';
  @track ligando = false;

  async realizarLigacao() {
    this.iframeUrl = '';
    const notas = this.contasSelecionadas;
    console.log("Id contas selecionadas: ", JSON.stringify(notas))
    const accountId = this.contaSelecionadaId;
    const user_Id = userId;
    const n = this.numeroSelecionado;
    const urlBase = 'https://call.hospcom.net/?';

    if (!accountId || !user_Id || !n || !urlBase) {
      this.toast('Erro', 'Falha ao iniciar ligação! Dados não encontrados', 'error', 'sticky');
      console.error(`AccountId: ${accountId}, userId: ${user_Id}, numeroSelecionado: ${n}, urlIframe: ${urlBase}`);
      return;
    }

    let resposta = window.confirm("Deseja ligar para " + n + "?");
    if (resposta) {
      // limpa e padroniza número (com +55)
      const numeroLimpo = await utils.trataNumero(n);

      // Extrai apenas os IDs das contas selecionadas
      const idsArray = notas.map(nota => nota.Id);

      // Converte o array para string JSON e codifica para URL
      const idsParam = encodeURIComponent(JSON.stringify(idsArray));

      const urlFinal = `${urlBase}phone=${encodeURIComponent(numeroLimpo)}&accountid=${accountId}&userid=${user_Id}&ids=${idsParam}`;

      this.iframeUrl = urlFinal;

      //console.log('URL iframe:', this.iframeUrl);
      console.log('IDs enviados:', idsArray);
      this.ligando = true;
      //this.eventoLigacao();
    }
  }
  async eventoLigacao() {
    const idDasContasAReceberSelecionados = this.contasSelecionadas.map(c => c.Id)
    const user = this.user
    const conta = this.conta
    const numero = this.numeroSelecionado;
    const tipo = 'Contato com Cliente'
    const numeroLimpo = await utils.trataNumero(numero);

    const descricao = `Registro de Ligação:\n
       • Usuário: ${user?.Name}
       • Cliente: ${conta?.Name}
       • Número: ${numero}`;


    this.eventos = [];
    await httpRequest.salvarEvento(descricao, tipo, conta.Id, user.Id, numeroLimpo, idDasContasAReceberSelecionados);
    eventos.load(this, this.contaSelecionadaId, executeSoql, utils);
  }



  get verificaContaPhone() {
    return this.conta.Phone && this.conta.Phone != 'Não encontrado'
  }
  get verificaContaTelefoneUltimoContato() {
    return this.conta.Telefone_do_ultimo_contato__c && this.conta.Telefone_do_ultimo_contato__c != 'Não encontrado';
  }
  get verificaContaNomeUltimoContato() {
    return this.conta.ultimo_contato_nome
      && this.conta.ultimo_contato_nome != 'Não encontrado'
      && this.numeroSelecionado === this.conta.Telefone_do_ultimo_contato__c;
  }
  get isPhoneSelected() {
    return this.numeroSelecionado === this.conta.Phone;
  }

  get isUltimoContatoSelected() {
    return this.numeroSelecionado === this.conta.Telefone_do_ultimo_contato__c;
  }
  get getPhoneClass() {
    if (this.numeroSelecionado === this.conta.Phone) {
      return 'numberCard ' + 'phone-selected';
    }
    return 'numberCard'
  }
  get getLastContatctPhoneClass() {
    if (this.numeroSelecionado === this.conta.Telefone_do_ultimo_contato__c) {
      return 'numberCard ' + 'phone-selected';
    }
    return 'numberCard';
  }
  negociarbtn() {
    this.secaoNegociar = true;

  }

  get contentContainer() {
    return this.secaoNegociar ? 'contentContainer flex1' : 'contentContainer';
  }
  get negociacaoContainer() {
    return this.secaoNegociar ? 'negociacaoContainer' : 'negociacaoContainer hide';
  }
  get resumoDeCobranca() {
    return this.secaoNegociar ? 'resumoDeCobranca' : 'resumoDeCobranca';
  }
  get popupClass() {
    return this.secaoNegociar ? 'popup  width1000' : 'popup';
  }
  get detalhesPane() {
    return this.mostrarDetalhes ? 'detalhesPane' : 'detalhesPane fecharDetalhes';
  }
  get resumoDaNegociacao() {
    return this.secaoNegociar ? 'resumoDeCobranca' : 'resumoDeCobranca hide';
  }


  get opcoesParcelas() {
    return [
      { label: '2x', value: '2' },
      { label: '3x', value: '3' },
      { label: '4x', value: '4' },
      { label: '5x', value: '5' },
      { label: '6x', value: '6' },
      { label: '7x', value: '7' },
      { label: '8x', value: '8' },
      { label: '9x', value: '9' },
      { label: '10x', value: '10' },
      { label: '11x', value: '11' },
      { label: '12x', value: '12' }
    ];
  }




  // Handlersf
  handleDateChange(e) {
    this.negociacao.dataCalculo = e.target.value;
    //console.log("Data de Cálculo:", this.negociacao.dataCalculo);
  }

  handlePagamentoChange(e) {
    let value = e.detail.value;
    this.negociacao.pagamento = value;
    if (value == 'parcelado') {
      this.negociacao.parcelas = '2';
      this.negociacao.valorEntrada = regras.valorMinimoEntrada(this.resumoCalculado.totalAPagar)
    } else { this.negociacao.valorEntrada = 0; this.negociacao.parcelas = '1' }
    //console.log("pagamento", this.negociacao.pagamento);
  }
  handleParcelas(e) {
    this.negociacao.parcelas = e.target.value;
    //console.log("Parcelas:", this.negociacao.parcelas);
  }

  get multaFormatado() {
    return utils.formatarPercentual(this.negociacao.multa);
  }
  get jurosFormatado() {
    return utils.formatarPercentual(this.negociacao.juros);
  }

  get valorEntradaFormatado() {
    // Formata apenas se houver valor
    return this.negociacao.valorEntrada ? utils.formatarMoeda(this.negociacao.valorEntrada) : this.valorMinimoEntrada;
  }

  handleValorEntrada(event) {
    // Mantém apenas números
    let apenasNumeros = event.target.value.replace(/\D/g, "");

    // Converte para decimal (ex: 1234 -> 12,34)
    let valor = parseFloat(apenasNumeros) / 100;

    // Permite que o campo fique vazio enquanto o usuário digita
    if (event.target.value === '' || isNaN(valor)) {
      this.negociacao.valorEntrada = 0;
      return;
    }

    // Atualiza input com máscara de moeda
    event.target.value = utils.formatarMoeda(valor);

    // Não aplica mínimo ainda, só atualiza valor temporário
    this.negociacao.valorEntrada = valor;

    //console.log("Valor de Entrada (temporário):", this.negociacao.valorEntrada);
  }
  // Chame essa função no blur ou quando salvar para garantir o mínimo
  handleValorEntradaBlur() {
    const valorMinimo = regras.valorMinimoEntrada(this.resumoCalculado.totalAPagar);

    if (this.negociacao.valorEntrada < valorMinimo || this.negociacao.valorEntrada >= this.resumoCalculado.totalAPagar) {
      this.negociacao.valorEntrada = valorMinimo;
    }

  }

  get valorMinimoEntrada() {
    return utils.formatarValor((regras.VALOR_MINIMO_ENTRADA / 100) * this.resumoCalculado.totalAPagar)
  }

  handleMultaDesconto(event) {
    // Mantém apenas números
    let apenasNumeros = event.target.value.replace(/\D/g, "");

    // Converte para decimal (ex: 1234 -> 12,34)
    let valor = parseFloat(apenasNumeros) / 100;

    if (isNaN(valor)) {
      valor = 0;
    }

    // Limite máximo
    if (valor > regras.VALOR_MAXIMO_DESCONTO_MULTA) {
      valor = regras.VALOR_MAXIMO_DESCONTO_MULTA;
    }

    this.negociacao.multa = valor;

    // Atualiza input com máscara formatada
    event.target.value = valor.toLocaleString("pt-BR", {
      minimumFractionDigits: 2,
      maximumFractionDigits: 2
    });

    //console.log("Multa (%):", this.negociacao.multa);
  }

  handleJurosDesconto(event) {
    // Mantém apenas números
    let apenasNumeros = event.target.value.replace(/\D/g, "");

    // Converte para decimal (ex: 1234 -> 12,34)
    let valor = parseFloat(apenasNumeros) / 100;

    if (isNaN(valor)) {
      valor = 0;
    }

    // Limite máximo
    if (valor > regras.VALOR_MAXIMO_DESCONTO_JUROS) {
      valor = regras.VALOR_MAXIMO_DESCONTO_JUROS;
    }

    this.negociacao.juros = valor;

    // Atualiza input com máscara formatada
    event.target.value = valor.toLocaleString("pt-BR", {
      minimumFractionDigits: 2,
      maximumFractionDigits: 2
    });

    //console.log("Juros (%):", this.negociacao.juros);
  }


  get buttonLabel() {
    return this.calculando ? 'Calculando...' : 'Calcular';
  }

  get buttonClass() {
    return this.calculando ? 'btn-calcular loading' : 'btn-calcular';
  }
  get parcelamento() {
    return this.negociacao.pagamento === 'parcelado' ? 'parcelamento' : 'parcelamento hide'
  }


  //Dropdonw de ações de negociação
  @track dropdownOpen = false;

  //TODDO user permissions 
  // Lista dinâmica com permissões
  actions = [
    { label: "Gerar acordo", handler: () => this.handleGerar(), allowed: true },
    { label: "Salvar proposta", handler: () => this.handleSalvar(), allowed: false },
    { label: "Exportar", handler: () => this.handleExportar(), allowed: false }
  ];

  get allowedActions() {
    return this.actions.filter(a => a.allowed);
  }

  get mainAction() {
    return this.allowedActions[0];
  }

  get otherActions() {
    return this.allowedActions.slice(1);
  }

  get hasMoreActions() {
    return this.otherActions.length > 0 && this.negociacao;
  }

  toggleDropdown() {
    this.dropdownOpen = !this.dropdownOpen;
  }

  handleMainAction() {
    this.mainAction.handler();
  }

  handleSalvar() {
    //console.log("Salvando...");
  }


  async handleGerar() {
    const idDasContasAReceberSelecionados = this.contasSelecionadas.map(c => c.Id)

    const continuar = window.confirm("Deseja gerar o acordo?");
    if (!continuar) {
      return
    }

    this.isLoading = true;
    //console.log("gerando..")
    const proposta = this.proposta;
    const negociacao = this.negociacao;
    const docEntry = this.resumoCalculado.docEntry
    const condicaoPagamento = negociacao.parcelas;
    const user = this.user;
    const accountId = this.conta.Id
    ////console.log("doc entry: ", docEntry);

    //console.log("proposta obj: ", JSON.stringify(proposta));

    const payload = {
      DocEntry: docEntry,
      vencimento: utils.formatarDataISO(negociacao.dataCalculo),
      juros: utils.formatarNumeroAmericano(proposta.juros),
      multa: utils.formatarNumeroAmericano(proposta.multa),
      formaDePagamento: "C-BB-1280570BOL",
      condicaoDePagamento: condicaoPagamento,
      entrada: utils.formatarNumeroAmericano(proposta.valorEntrada),
      dataparcelas: proposta.parcelas.map(p => ({
        dataVencimento: utils.formatarDataISO(p.dataVencimento),
        valor: utils.formatarNumeroAmericano(p.valor)
      })),
      cobrador: user.Name
    };

    const descricao = this.gerarLog(user, negociacao, proposta);
    await utils.delay(3000);
    let novoDocEntry = '';
    try {
      console.log("Payload: ", JSON.stringify(payload));
      novoDocEntry = await httpRequest.gerarAcordo(payload);
      //console.log("Novo docentry: ", novoDocEntry);

      await httpRequest.atualizaContasAReceber(novoDocEntry, accountId, idDasContasAReceberSelecionados);
      //console.log("Novo id: ", cobrancaRecordId)

      const eventoResponse = await httpRequest.salvarEvento(descricao, 'Acordo', accountId, user.Id, null, idDasContasAReceberSelecionados);
      //console.log("Response: ", eventoResponse);
      if (eventoResponse === 200) {
        this.toast('Sucesso', 'Evento salvo com sucesso', 'success', 'pester');
        eventos.load(this, this.contaSelecionadaId, executeSoql, utils);
      }

      this.toast('Sucesso', 'Acordo gerado com sucesso', 'success', 'pester');
      this.fecharCalcularPopUp();

    } catch (error) {
      this.toast('Erro', `Erro ao gerar acordo: ${error.message || error}`, 'error', 'sticky');
      console.error("Erro ao gerar acordo: ", error);
    } finally {
      contasAReceber.load(this, this.contaSelecionadaId, executeSoql, utils);
      this.isLoading = false;
    }

  }

  gerarLog(user, negociacao, proposta) {
    const userName = user.Name;

    const dockIds = this.resumoCalculado.docEntry.join(', ');

    const descontoJuros = negociacao.juros || 0;
    const descontoMulta = negociacao.multa || 0;
    const valorEntrada = utils.formatarValor(proposta.valorEntrada) || 0;
    const qtdParcelas = proposta.qtdParcelas || 1;
    const dataCalculo = utils.formatarDataBrasileira(negociacao.dataCalculo);

    const jurosFinal = utils.formatarValor(proposta.juros) || 0;
    const multaFinal = utils.formatarValor(proposta.multa) || 0;
    const saldoDevedor = utils.formatarValor(proposta.saldoDevedor) || 0;

    // Formatar parcelas detalhadas
    let parcelasDetalhadas = '';
    if (proposta.parcelas && proposta.parcelas.length) {
      parcelasDetalhadas = proposta.parcelas.map(p => {
        const data = utils.formatarDataBrasileira(p.dataVencimento);
        const valor = utils.formatarValor(p.valor);
        return `  - ${data}: ${valor}`;
      }).join('\n');
    }

    const descricao = `Usuário: ${userName} realizou uma negociação nos títulos: [${dockIds}].

Descontos aplicados:
  - Juros: ${descontoJuros}%
  - Multa: ${descontoMulta}%

Informações da negociação:
  - Valor de entrada: ${valorEntrada}
  - Parcelas: ${qtdParcelas}
  - Data de cálculo: ${dataCalculo}

Proposta gerada:
  - Juros final: ${jurosFinal}
  - Multa final: ${multaFinal}
  - Saldo devedor: ${saldoDevedor}

Parcelas detalhadas:
${parcelasDetalhadas}`;

    return descricao;
  }




  // Formata a data de hoje como YYYY-MM-DD
  get today() {
    const hoje = new Date();
    const ano = hoje.getFullYear();
    const mes = String(hoje.getMonth() + 1).padStart(2, '0');
    const dia = String(hoje.getDate()).padStart(2, '0');
    return `${ano}-${mes}-${dia}`;
  }

  inicializarNegociacao() {
    // Inicializa objeto negociacao
    this.negociacao = {
      dataCalculo: new Date().toISOString().split("T")[0], // hoje
      pagamento: 'avista',
      valorEntrada: 0,
      multa: 0,
      juros: 0,
      parcelas: '1'
    };

    // Inicializa objeto proposta
    this.proposta = {
      juros: 0,
      jurosLabel: 'R$ 0,00',
      multa: 0,
      multaLabel: 'R$ 0,00',
      valorAPagar: 0,
      valorAPagarLabel: 'R$ 0,00',
      totalDescontado: 0,
      totalDescontadoLabel: 'R$ 0,00',
      parcelas: []
    };
  }
  get getPropostaValorEntradaLabel() {
    return this.negociacao.pagamento == 'parcelado' ? this.proposta.valorEntradaLabel : 'á vista';
  }
  @track mensageToSend = "Olá! Tudo bem?"
  defaultMessage = "Olá! Tudo bem?";
  @track abrirInput = false;

  abrirCaixa() {
    // Mostra a caixa de texto
    this.abrirInput = true;
  }
  handleInputChange(event) {
    // Atualiza normalmente enquanto digita
    this.mensageToSend = event.target.value;
  }

  handleBlur(event) {
    let valor = event.target.value.trim();

    // Se vazio ao sair do campo → volta pro padrão
    if (valor === "") {
      this.mensageToSend = this.defaultMessage;
      event.target.value = this.defaultMessage;
    }
  }

  cancelarEnvio() {
    this.abrirInput = false;
    this.mensageToSend = this.defaultMessage; // volta pro padrão
  }
  async confirmarEnvio() {
    this.isLoading = true;

    let msg = this.mensageToSend;
    let number = this.numeroSelecionado;
    let numberOk = false;

    let accountName = utils.formatarNomeConta(this.conta);

    //console.log("=== Iniciando envio de mensagem ===");
    //console.log("Mensagem original:", msg);
    //console.log("Número original:", number);
    //console.log("Nome da conta: ", accountName);
    // Validação do número
    if (utils.validaNumero(number)) {
      //console.log("Número válido antes do tratamento");
      number = await utils.trataNumero(number);
      numberOk = true;
      //console.log("Número tratado:", number);
    } else {
      //console.log("Número inválido:", number);
    }

    // Envio da mensagem
    if (numberOk) {
      try {
        //console.log("Tentando iniciar conversa...");
        const conversationId = await httpRequest.startAConversation(number, msg, userId, accountName);
        //console.log("Conversa iniciada com sucesso! ID:", conversationId);

        // Abre uma nova guia com o conversationId
        const url = `https://chat.hospcom.net/app/accounts/1/conversations/${conversationId}`;
        window.open(url, "_blank");

        await this.criarEventoChatWoot(number);

        this.eventos = [];
        eventos.load(this, this.contaSelecionadaId, executeSoql, utils);
        this.closePopUps();

      } catch (error) {
        console.error("Erro ao iniciar conversa:", error);
        this.toast('Erro', 'Não foi possível abrir uma conversa', 'error', 'sticky');
      }

    } else {
      console.warn("Número fornecido inválido, abortando envio");
      this.toast('Erro', 'Número fornecido inválido', 'error', 'sticky');
    }

    this.isLoading = false;
    this.abrirInput = false;
    //console.log("=== Fim do processo de envio ===");
  }

  async criarEventoChatWoot(n) {
    const idDasContasAReceberSelecionados = this.contasSelecionadas.map(c => c.Id)
    const conta = this.conta;
    const user = this.user
    const numeroSelecionado = n;
    const nummeroLimpo = await utils.trataNumero(numeroSelecionado);
    const tipo = 'Mensagem Enviada';
    const mensagemEnviada = this.mensageToSend;


    const descricao =
      `Contato via WhatsApp\n
   • Número: ${numeroSelecionado}
   • Usuário responsável: ${user.Name}\n
   • Mensagem enviada:\n"${mensagemEnviada}"`;

    await httpRequest.salvarEvento(descricao, tipo, conta.Id, user.Id, nummeroLimpo, idDasContasAReceberSelecionados);
  }

  handleKeyDownEnter(e) {
    if (e.key === "Enter") {
      e.preventDefault(); // evita quebra de linha
      this.confirmarEnvio();
    }
  }


  popUpEvento = false;
  //Novo evento
  @track novoEvento;
  // Métodos
  inicializaNovoEvento() {
    this.tipoOptions = [];
    this.novoEvento = {
      descricao: null,
      tipoSelecionado: null,
      idContasAReceber: []
    };
  }

  tipoOptions = [];

  novoEventoBtn() {
    //console.log("Contas selecionadas: ", this.contasSelecionadas);


    this.inicializaNovoEvento();

    this.carregarEventoPickList();

    this.novoEvento.idContasAReceber = Array.isArray(this.contasSelecionadas) ? this.contasSelecionadas.map(conta => conta.Id) : [];
    this.allPopupAreClosed = false;
    this.popUpEvento = true;
    // Limpa seleção anterior
    //console.log("Contas a receber selecionada: ", this.novoEvento.idContasAReceber);
  }
  fecharEventoPopUp() {
    this.popUpEvento = false;
    // Limpa todos os campos do formulário
    this.inicializaNovoEvento();
  }
  handleDescricaoChange(event) {
    this.novoEvento.descricao = event.target.value;
    //console.log('Descrição:', this.novoEvento.descricao);
  }
  handleTipoChange(event) {
    this.novoEvento.tipoSelecionado = event.detail.value;
    console.log('Tipo selecionado:', this.novoEvento.tipoSelecionado);
    // Limpa campos dos outros tipos quando muda
    //this.inicializaNovoEvento();
  }
  @track dataAuxiliarEvento = '';
  handleDataEventoChange(e) {
    this.dataAuxiliarEvento = e.detail.target.value;
  }
  get dataEvento() {
    return this.dataAuxiliarEvento === 'Promessa de Pagamento';
  }
  get showDescricao() {
    return this.novoEvento.tipoSelecionado || this.novoEvento.tipoSelecionado != '';
  }


  async salvarEvento() {
    this.isLoading = true;
    const idDasContasAReceberSelecionados = this.contasSelecionadas.map(c => c.Id)
    const descricao = this.novoEvento.descricao;
    const tipo = this.novoEvento.tipoSelecionado;
    const accountId = this.contaSelecionadaId;
    const user_Id = userId;

    if (!tipo || !descricao) {
      this.toast('Erro', 'Preencha os campos corretamente', 'error', 'sticky');
      return;
    }

    //console.log("Enviando evento: ", descricao, " ", tipo);
    //console.log("accountId: ", accountId);
    //console.log("userId: ", user_Id);
    //console.log("Salvando evento...")

    try {
      let response = await httpRequest.salvarEvento(descricao, tipo, accountId, user_Id, null, idDasContasAReceberSelecionados);

      if (response === 200) {
        this.toast('Sucesso', 'Evento salvo com sucesso', 'success', 'pester');
        await eventos.load(this, this.contaSelecionadaId, executeSoql, utils);
      } else {
        this.toast('Erro', `Erro ao salvar evento. Código: ${response}`, 'error', 'sticky');
        console.error('Erro ao salvar evento, status:', response);
      }
    } catch (e) {
      this.toast('Erro', 'Erro inesperado ao salvar evento', 'error', 'sticky');
      console.error("Exceção ao salvar evento:", e);
    } finally {
      this.isLoading = false;
      this.closePopUps();
    }

  }
  get hasContasAReceber() {

    if (!this.contasAReceberIsLoading && this.contasAReceber.length === 0) {
      return false
    }
    return true;
  }
  get haseventos() {

    if (!this.eventosIsLoading && this.eventos.length === 0) {
      return false
    }
    return true
  }
  get contasSelecionadasNaoVazia() {
    return this.contasSelecionadas.length > 0;

  }
  get contasSelecionadasEmAberto() {
    return this.contasSelecionadas.every(c => c.aberto === true);
  }




  //Método principal de calculo de juros do acordo 
  @track calculando = false;


  async processarCalculo() {
    this.calculando = true;

    try {
      await utils.delay(2000);

      // Validações iniciais
      this.validarDadosEntrada();

      const resumo = this.resumoCalculado;
      const negociacao = this.negociacao;
      const proposta = this.calcularPropostaPagamento(resumo, negociacao);

      this.proposta = proposta;
      //console.log("Parcelas calculadas:", JSON.stringify(this.proposta.parcelas));

    } catch (err) {
      this.toast('Erro', 'Huum.. algo deu errado com a negociação - Confira os dados e tente novamente', 'error', 'sticky');
      console.error('Erro ao calcular proposta', err);
    } finally {
      this.calculando = false;
    }
  }

  validarDadosEntrada() {
    const resumo = this.resumoCalculado;
    const negociacao = this.negociacao;

    if (!resumo || !negociacao) {
      throw new Error('Dados de resumo e negociação são obrigatórios');
    }

    if (negociacao.valorEntrada < 0) {
      throw new Error('Valor de entrada não pode ser negativo');
    }

    if (negociacao.parcelas < 1) {
      throw new Error('Número de parcelas deve ser maior que zero');
    }

    if (!negociacao.dataCalculo) {
      throw new Error('Data de cálculo é obrigatória');
    }
  }

  calcularPropostaPagamento(resumo, negociacao) {
    const arred = (v) => Math.round((v + Number.EPSILON) * 100) / 100;

    // Calcular juros e multas
    const dadosCalculo = this.calcularJurosEMultas(resumo, negociacao);
    const { juros, multa, diasDiferenca, saldoDevedor } = dadosCalculo;

    const proposta = {
      juros, // juros final (negociado + diários)
      jurosLabel: utils.formatarValor(arred(juros)),
      multa,
      multaLabel: utils.formatarValor(arred(multa)),
      totalDescontado: (resumo.juros - dadosCalculo.jurosNegociado) + (resumo.multa - dadosCalculo.multaNegociada),
      totalDescontadoLabel: utils.formatarValor(arred(
        (resumo.juros - dadosCalculo.jurosNegociado) + (resumo.multa - dadosCalculo.multaNegociada)
      )),
      diasDiferenca,
      saldoDevedor,
      saldoDevedorLabel: utils.formatarValor(arred(saldoDevedor))
    };

    // valor a pagar é só o saldo devedor já calculado
    proposta.valorAPagar = arred(saldoDevedor);
    proposta.valorAPagarLabel = utils.formatarValor(proposta.valorAPagar);

    // valor de entrada
    proposta.valorEntrada = arred(Number(negociacao.valorEntrada) || 0);
    proposta.valorEntradaLabel = utils.formatarValor(proposta.valorEntrada);

    // parcelas
    const dadosParcelas = this.gerarParcelas(proposta, negociacao, resumo);
    proposta.parcelas = dadosParcelas.parcelas;
    proposta.qtdParcelas = dadosParcelas.qtdParcelas;

    //this.logarResultadoCalculo(proposta, dadosCalculo);
    this.validarProposta(proposta);

    return proposta;
  }

  calcularJurosEMultas(resumo, negociacao) {
    //console.log("========================Calculo juros e multas========================");

    // Calcular diferença de dias
    const hoje = new Date();
    hoje.setHours(0, 0, 0, 0);

    const dataSelecionada = utils.parseDataLocal(negociacao.dataCalculo);
    dataSelecionada.setHours(0, 0, 0, 0);

    const diasDiferenca = Math.max(
      Math.round((dataSelecionada - hoje) / (1000 * 60 * 60 * 24)),
      0
    );
    //console.log("diferenca em dias: ", diasDiferenca);

    // Valor base já vem do resumo
    const valorBase = resumo.valorBase;
    //console.log("Valor base (do resumo): ", valorBase);

    if (valorBase <= 0) {
      throw new Error("Valor base deve ser maior que zero");
    }

    // Calcular juros diários sobre o valor base
    const jurosDiarios = diasDiferenca > 0 ? valorBase * ((diasDiferenca * regras.JUROS_DIARIO) / 100) : 0;
    //console.log("Juros diarios: ", jurosDiarios);

    // Juros e multa originais do resumo
    const jurosBase = resumo.juros || 0;
    const multaBase = resumo.multa || 0;

    // Percentuais de desconto negociados
    const percentualDescontoJuros = Math.max(0, Math.min(100, negociacao.juros || 0));
    const percentualDescontoMulta = Math.max(0, Math.min(100, negociacao.multa || 0));

    //console.log("percentual juros descontado: ", percentualDescontoJuros);
    //console.log("percentual multa descontada: ", percentualDescontoMulta);

    // Aplicar descontos
    const jurosNegociado = jurosBase * (1 - percentualDescontoJuros / 100);
    const multaNegociada = multaBase * (1 - percentualDescontoMulta / 100);

    //console.log("Juros negociados com desconto aplicados: ", jurosNegociado);
    //console.log("Multa negociada com desconto aplicada: ", multaNegociada);

    // Juros e multa finais
    const jurosFinal = jurosNegociado + jurosDiarios;
    const multaFinal = multaNegociada;

    // Saldo devedor final
    const saldoDevedor = valorBase + jurosFinal + multaFinal;
    //console.log("Saldo devedor final: ", saldoDevedor);

    return {
      valorBase,
      juros: jurosFinal,
      multa: multaFinal,
      diasDiferenca,
      saldoDevedor,
      jurosDiarios,
      jurosBase,
      multaBase,
      jurosNegociado,
      multaNegociada
    };
  }



  gerarParcelas(proposta, negociacao, resumo) {

    const parcelas = [];
    const qtdParcelas = parseInt(negociacao.parcelas, 10) || 1;
    let valorEntrada = Number(negociacao.valorEntrada) || 0;

    // Aplicar regra de entrada mínima para parcelamento
    if (negociacao.pagamento === 'parcelado' && valorEntrada === 0 && qtdParcelas > 1) {
      valorEntrada = regras.valorMinimoEntrada(proposta.valorAPagar); // valor cru
      proposta.valorEntrada = valorEntrada; // mantém cru internamente
      proposta.valorEntradaLabel = utils.formatarValor(valorEntrada); // arredonda só na label
    }

    // Configurar data base e feriados
    const dataBase = new Date(negociacao.dataCalculo + "T12:00:00");
    const feriadosNacionais = this.gerarListaFeriados(dataBase);

    // Calcular valor restante após entrada
    const valorRestante = proposta.valorAPagar - valorEntrada;

    if (valorEntrada > 0 && negociacao.pagamento === 'parcelado') {
      parcelas.push(this.criarParcelaEntrada(dataBase, valorEntrada, feriadosNacionais));
    }

    // Gerar parcelas normais
    const valorPorParcela = qtdParcelas > 0 ? (valorRestante / qtdParcelas) : valorRestante;

    for (let i = 1; i <= qtdParcelas; i++) {
      const vencimento = this.calcularDataVencimento(dataBase, i, negociacao.pagamento === 'parcelado' && valorEntrada > 0);
      const { data: vencimentoAjustado, reajustada } = utils.ajustarParaDiaUtil(vencimento, feriadosNacionais);

      let valorAtual = (negociacao.pagamento === 'avista') ? proposta.valorAPagar : valorPorParcela;

      // Ajustar última parcela para diferenças de arredondamento
      if (i === qtdParcelas && negociacao.pagamento === 'parcelado') {
        valorAtual = this.ajustarUltimaParcela(parcelas, valorAtual, valorRestante, valorEntrada);
      }

      parcelas.push({
        numero: parcelas.length + 1,
        dataVencimento: vencimentoAjustado,
        dataVencimentoLabel: utils.formatarDataBrasileira(vencimentoAjustado),
        valor: valorAtual,
        valorLabel: utils.formatarValor(valorAtual),
        reajustada,
        tipo: negociacao.pagamento === 'avista' ? 'avista' : 'parcela'
      });
    }
    return {
      parcelas,
      qtdParcelas: parcelas.length
    };
  }

  calcularDataVencimento(dataBase, indiceParcela, temEntrada) {
    const vencimento = new Date(dataBase);

    if (temEntrada) {
      // Se tem entrada, as parcelas começam no mês seguinte
      vencimento.setMonth(vencimento.getMonth() + indiceParcela);
    } else {
      // Se não tem entrada, a primeira parcela é no mês base
      vencimento.setMonth(vencimento.getMonth() + indiceParcela - 1);
    }

    return vencimento;
  }

  criarParcelaEntrada(dataBase, valorEntrada, feriadosNacionais) {
    const { data: vencimentoAjustado, reajustada } = utils.ajustarParaDiaUtil(new Date(dataBase), feriadosNacionais);

    return {
      numero: 1,
      dataVencimento: vencimentoAjustado,
      dataVencimentoLabel: utils.formatarDataBrasileira(vencimentoAjustado),
      valor: valorEntrada,
      valorLabel: utils.formatarValor(valorEntrada),
      reajustada,
      tipo: 'entrada'
    };
  }

  ajustarUltimaParcela(parcelas, valorAtual, valorRestante, valorEntrada) {

    // Soma apenas as parcelas normais (excluindo entrada)
    const parcelasNormais = parcelas.filter(p => p.tipo !== 'entrada');
    const somaParcelas = parcelasNormais.reduce((total, parcela) => total + parcela.valor, 0) + valorAtual;
    const diferenca = valorRestante - somaParcelas;

    return valorAtual + diferenca;
  }

  gerarListaFeriados(dataBase) {
    const anoBase = dataBase.getFullYear();
    return [
      ...utils.gerarFeriadosNacionais(anoBase),
      ...utils.gerarFeriadosNacionais(anoBase + 1),
      ...utils.gerarFeriadosNacionais(anoBase + 2) // Adiciona mais um ano para segurança
    ];
  }

  validarProposta(proposta) {
    // Validação: verifica se a soma das parcelas confere
    const somaTotalParcelas = proposta.parcelas.reduce((total, parcela) => total + parcela.valor, 0);
    const diferenca = Math.abs(somaTotalParcelas - proposta.valorAPagar);

    if (diferenca > 0.02) { // 2 centavos de tolerância
      console.warn(`Diferença na soma das parcelas: R$ ${diferenca.toFixed(2)}`);
      //console.log(`Soma parcelas: R$ ${somaTotalParcelas.toFixed(2)}`);
      //console.log(`Valor total: R$ ${proposta.valorAPagar.toFixed(2)}`);
      throw new Error(`Inconsistência no cálculo das parcelas: diferença de R$ ${diferenca.toFixed(2)}`);
    }

    // Validação: verifica valores negativos
    if (proposta.parcelas.some(p => p.valor <= 0)) {
      throw new Error('Parcelas não podem ter valor zero ou negativo');
    }

    // Validação: verifica datas
    const hoje = new Date();
    if (proposta.parcelas.some(p => p.dataVencimento < hoje)) {
      console.warn('Algumas parcelas têm vencimento no passado');
    }
  }

  logarResultadoCalculo(proposta, dadosCalculo) {
    const { diasDiferenca, saldoDevedor, jurosDiarios, jurosBase, multaBase } = dadosCalculo;

    console.group('Resultado do Cálculo');
    console.log("Dados base:", {
      diasDiferenca,
      saldoDevedor,
      jurosBase,
      multaBase,
      jurosDiarios
    });

    console.log("Valores negociados:", {
      juros: proposta.juros,
      multa: proposta.multa,
      totalDescontado: proposta.totalDescontado,
      valorAPagar: proposta.valorAPagar
    });

    console.log("Parcelas:", {
      quantidade: proposta.qtdParcelas,
      valorEntrada: proposta.valorEntrada,
      parcelas: proposta.parcelas.map(p => ({
        numero: p.numero,
        valor: p.valor,
        vencimento: p.dataVencimentoLabel,
        tipo: p.tipo
      }))
    });

    console.groupEnd();
  }

  // No seu componente LWC, adicione esta lógica

  // Getter para agrupar eventos por mês
  get eventosAgrupados() {
    if (!this.eventos || this.eventos.length === 0) {
      return [];
    }

    // Agrupa eventos por mês/ano
    const grupos = this.eventos.reduce((acc, evento) => {
      // Assume que evento.Data está no formato YYYY-MM-DD ou é um objeto Date
      const dataEvento = new Date(evento.RawData);
      const mesAno = `${dataEvento.getFullYear()}-${String(dataEvento.getMonth() + 1).padStart(2, '0')}`;

      if (!acc[mesAno]) {
        acc[mesAno] = {
          mesAno: mesAno,
          mesAnoFormatado: eventos.formatarMesAnoDetalhado(dataEvento),
          eventos: []
        };
      }

      acc[mesAno].eventos.push(evento);
      return acc;
    }, {});

    // Converte para array e ordena por data (mais recente primeiro)
    return Object.values(grupos)
      .sort((a, b) => b.mesAno.localeCompare(a.mesAno))
      .map(grupo => ({
        ...grupo,
        // Ordena eventos dentro do grupo por data (mais recente primeiro)
        eventos: grupo.eventos.sort((a, b) => new Date(b.Data) - new Date(a.Data))
      }));
  }

  async buscarBoleto(event) {
    event.stopPropagation();
    const docEntry = event.currentTarget.dataset.docentry;
    const id = event.currentTarget.dataset.id;

    // Atualiza a flag buscandoBoleto só para o item clicado
    this.contasAReceber = this.contasAReceber.map(c => {
      if (c.Id === id) {
        return { ...c, buscandoBoleto: true };
      }
      return c;
    });

    try {
      const resultado = await httpRequest.buscarBoleto(docEntry);

      if (resultado.success) {
        // Boleto encontrado - fazer download
        const pdfUrl = URL.createObjectURL(resultado.blob);

        // Criar link para download
        const a = document.createElement("a");
        a.href = pdfUrl;
        a.download = `boleto-${docEntry}.pdf`;
        document.body.appendChild(a);
        a.click();
        document.body.removeChild(a);
        ////console.log("PDF url: ", pdfUrl);
      } else {
        // Boleto não encontrado (status 201)
        this.toast("Aviso", resultado.message, "warning");
      }
    } catch (error) {
      // Simplesmente exibe a mensagem do erro
      this.toast("Erro", error.message, "error");
      console.error('Erro completo:', error);

    } finally {
      // Remove a flag de carregamento
      this.contasAReceber = this.contasAReceber.map(c =>
        c.Id === id ? { ...c, buscandoBoleto: false } : c
      );
    }
  }

  async copiarNumero(event) {
    event.stopPropagation();
    const id = event.currentTarget.dataset.id;
    const docEntry = event.currentTarget.dataset.docentry;

    // Ativa spinner
    this.contasAReceber = this.contasAReceber.map(c =>
      c.Id === id ? { ...c, copiandoBoleto: true } : c
    );

    try {
      const result = await httpRequest.obterDadosDoBoleto(docEntry);

      // Verifica se a API retornou erro
      if (!result.success) {
        throw new Error(result.message);
      }

      const numeroBoleto = result.cod;

      if (navigator.clipboard && navigator.clipboard.writeText) {
        await navigator.clipboard.writeText(numeroBoleto);
      } else {
        // fallback
        const textarea = document.createElement("textarea");
        textarea.value = numeroBoleto;
        document.body.appendChild(textarea);
        textarea.select();
        const sucesso = document.execCommand("copy");
        document.body.removeChild(textarea);

        if (!sucesso) {
          throw new Error("Falha ao copiar usando método alternativo");
        }
      }

      // Mostra tooltip de sucesso
      this.contasAReceber = this.contasAReceber.map(c =>
        c.Id === id ? { ...c, tooltipCopiado: true } : c
      );

      // Esconde tooltip após 2 segundos
      setTimeout(() => {
        this.contasAReceber = this.contasAReceber.map(c =>
          c.Id === id ? { ...c, tooltipCopiado: false } : c
        );
      }, 2000);

    } catch (error) {
      this.toast("Erro", error.message || "Erro ao copiar", "error");
      console.error(error);
    } finally {
      // Remove loading
      this.contasAReceber = this.contasAReceber.map(c =>
        c.Id === id ? { ...c, copiandoBoleto: false } : c
      );
    }
  }


  async gerarQRCode(event) {
    event.stopPropagation();
    const docEntry = event.currentTarget.dataset.docentry;
    const id = event.currentTarget.dataset.id;

    // Ativa loading só para esse item
    this.contasAReceber = this.contasAReceber.map(c =>
      c.Id === id ? { ...c, gerandoQRCode: true } : c
    );

    try {
      const result = await httpRequest.obterDadosDoBoleto(docEntry);

      // Verifica se a API retornou erro
      if (!result.success) {
        throw new Error(result.message);
      }

      const chave = result.chave;

      if (navigator.clipboard && navigator.clipboard.writeText) {
        await navigator.clipboard.writeText(chave);
      } else {
        // Fallback para copiar via textarea
        const textarea = document.createElement("textarea");
        textarea.value = chave;
        document.body.appendChild(textarea);
        textarea.select();
        const sucesso = document.execCommand("copy");
        document.body.removeChild(textarea);

        if (!sucesso) {
          throw new Error("Falha ao copiar QR Code usando método alternativo");
        }
      }

      // Mostra tooltip de sucesso
      this.contasAReceber = this.contasAReceber.map(c =>
        c.Id === id ? { ...c, tooltipCopiado: true } : c
      );

      // Esconde tooltip após 2 segundos
      setTimeout(() => {
        this.contasAReceber = this.contasAReceber.map(c =>
          c.Id === id ? { ...c, tooltipCopiado: false } : c
        );
      }, 2000);

    } catch (error) {
      this.toast("Erro", error.message || "Erro ao copiar QR Code", "error");
      console.error(error);
    } finally {
      // Remove loading
      this.contasAReceber = this.contasAReceber.map(c =>
        c.Id === id ? { ...c, gerandoQRCode: false } : c
      );
    }
  }
  disconnectedCallback() {
    // Limpa o intervalo quando o componente é destruído
    if (this.intervalId) {
      clearInterval(this.intervalId);
    }
  }



} 

//=-=-=-=-=-=-=-=-=-=-=-=--=-==-=-=-=-=--=-=-