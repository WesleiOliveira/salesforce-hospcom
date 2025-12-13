public with sharing class ContratoServicoService {
    final static List<String> FORMAS_PAGAMENTOS_ADIANTADOS = new List<String>{
            'Boleto Bancário',
            'Transferência Bancária',
            'Pix',
            'Dinheiro',
            'E-commerce',
            'Cruzamento de Saldos (Permuta) Recebido',
            'Sem Mov. Financeiro',
            'Cartao Credito / Debito'
        };
    
    public static void processaContratos(List<Contrato_de_servi_o__c> novosContratos, Map<Id, Contrato_de_servi_o__c> antigosContratosMap) {
        List<Order> pedidos = new List<Order>();
        List<OrderItem> itensPedidos = new List<OrderItem>();
        Set<String> codigosProdutos = new Set<String>();
        Map<String, String> nomesProdutos = new Map<String, String>();
        Map<String, Decimal> quantidades = new Map<String, Decimal>();
        Map<String, Decimal> valoresTotais = new Map<String, Decimal>();
        PedidoData dados = new PedidoData();
        String emails;

        for (Contrato_de_servi_o__c contrato : novosContratos) {
            Contrato_de_servi_o__c contratoAntigo = antigosContratosMap.get(contrato.Id);
            
            if (deveCriarPedido(contrato, contratoAntigo)) {
                dados = preparaDadosContrato(contrato);
                emails = contrato.Emails_para_faturamento__c;
                processaAtivosContrato(contrato, codigosProdutos, nomesProdutos, quantidades, valoresTotais);
                criaPedidosPorMes(contrato, dados, pedidos, emails);
            }
        }

        if (!pedidos.isEmpty()) {
            insert pedidos;
            Map<String, PricebookEntry> pbes = buscaPBEs(codigosProdutos);
            criaOrderItems(pedidos, pbes, quantidades, valoresTotais, nomesProdutos, dados, itensPedidos, emails);
            insert itensPedidos;
            update pedidos;
        }
    }

    public static Boolean deveCriarPedido(Contrato_de_servi_o__c atual, Contrato_de_servi_o__c antigo) {
        return atual.Status_do_Contrato__c == 'CONTRATO VIGENTE' &&
               antigo.Status_do_Contrato__c != 'CONTRATO VIGENTE' &&
               atual.Id != 'a1YU4000000qY7FMAU';
    }

    public static PedidoData preparaDadosContrato(Contrato_de_servi_o__c contrato) {
        PedidoData dados = new PedidoData();
        dados.contato = [SELECT ID, FirstName, Email, MobilePhone, Phone FROM Contact WHERE ID = :contrato.Contato_do_Locat_rio__c LIMIT 1];
        dados.locatario = [SELECT Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, 
                           ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry, CurrencyIsoCode 
                           FROM Account WHERE ID = :contrato.Locat_rio_a__c LIMIT 1];
        dados.locador = [SELECT Id, Name, Raz_o_Social__c, CNPJ__c FROM Account WHERE id = :contrato.Locador_a__c LIMIT 1];
        dados.dadosBancarios = getDadosBancarios(String.valueOf(contrato.Forma_de_pagamento2__c));
        String cond = contrato.Condicao_de_pagamento__c;
        dados.numeroDias = (cond == 'À Vista') ? 0 : Integer.valueOf(cond.split(' ')[0]);
        dados.telefone = (dados.contato.MobilePhone != null && dados.contato.MobilePhone != '') ? dados.contato.MobilePhone : dados.contato.Phone;
        dados.dataInicial = Date.today();
        return dados;
    }

    public static void processaAtivosContrato(
        Contrato_de_servi_o__c contrato,
        Set<String> codigosProdutos,
        Map<String, String> nomesProdutos,
        Map<String, Decimal> quantidades,
        Map<String, Decimal> valoresTotais
    ) {
        List<Ativos_do_Contrato__c> ativos = [
            SELECT Ativo_Locado__r.Product2.ProductCode, Ativo_Locado__r.Product2.Name, Valor_Total_Mensal__c, 
                   Valor_Unitario_Mensal__c, Quantidade__c, CurrencyIsoCode
            FROM Ativos_do_Contrato__c 
            WHERE Contrato_de_Servico__c = :contrato.Id AND Equipamento_no_cliente__c = true
        ];

        for (Ativos_do_Contrato__c ativo : ativos) {
            String codigo = ativo.Ativo_Locado__r.Product2.ProductCode + 'LOCACAO';
            codigosProdutos.add(codigo);
            nomesProdutos.put(codigo, ativo.Ativo_Locado__r.Product2.Name);

            Decimal qtd = quantidades.get(codigo) != null ? quantidades.get(codigo) : 0;
            Decimal val = valoresTotais.get(codigo) != null ? valoresTotais.get(codigo) : 0;
            quantidades.put(codigo, qtd + ativo.Quantidade__c);
            valoresTotais.put(codigo, val + ativo.Valor_Total_Mensal__c);
        }
    }

    public static void criaPedidosPorMes(
        Contrato_de_servi_o__c contrato,
        PedidoData dados,
        List<Order> pedidos,
        String emails
    ) {
        for (Integer i = 0; i < contrato.Dura_o_do_Contrato_meses__c; i++) {
            Date vencimento = contrato.Primeiro_faturamento__c.addMonths(i).addDays(dados.numeroDias);
            Order pedido = new Order(
                AccountId = contrato.Locat_rio_a__c,
                Contrato_de_Servi_o__c = contrato.Id,
                EffectiveDate = dados.dataInicial.addMonths(i),
                Prazo_de_Entrega__c = contrato.Primeiro_faturamento__c.addMonths(i),
                Periodo_do_contrato_inicio__c = contrato.Primeiro_faturamento__c.addMonths(i),
                Per_odo_do_contrato_Fim__c = contrato.Primeiro_faturamento__c.addMonths(i + 1),
                Status = 'Rascunho',
                Data_de_vencimento__c = vencimento,
                BillingCity = dados.locatario.BillingCity,
                BillingCountry = dados.locatario.BillingCountry,
                BillingPostalCode = dados.locatario.BillingPostalCode,
                BillingState = dados.locatario.BillingState,
                BillingStreet = dados.locatario.BillingStreet,
                Comentarios__c = 'Pedido criado automaticamente a partir da aprovação do contrato.',
                Condicao_de_pagamento__c = contrato.Condicao_de_pagamento__c,
                Departamento3__c = 'Locação',
                E_mail_Contato__c = dados.contato.Email,
                Entrega_parcial__c = 'Não Autorizada',
                Faturamento_Feito__c = contrato.Locador_a__c,
                Forma_de_pagamento2__c = contrato.Forma_de_pagamento2__c,
                Frete__c = contrato.Tipo_de_Entrega__c,
                Ignora_validacao__c = true,
                Locado_em__c = '-',
                Natureza_de_Opera_o__c = 'LOCAÇÃO',
                Necess_rio_Treinamento__c = 'NÃO',
                Nome_Contato_Financeiro__c = dados.contato.FirstName,
                Pricebook2Id = '01s5A000004fbcR',
                ShippingCity = dados.locatario.ShippingCity,
                ShippingCountry = dados.locatario.ShippingCountry,
                ShippingPostalCode = dados.locatario.ShippingPostalCode,
                ShippingState = dados.locatario.ShippingState,
                ShippingStreet = dados.locatario.ShippingStreet,
                Telefone_Contato__c = dados.telefone,
                Unidade_Hospitalar__c = contrato.Unidade_Hospitalar__c,
                Vendedor__c = contrato.Vendedor_do_Contrato__c,
                Prioridade__c = 'NORMAL',
                Entrega_liberada_pelo_financeiro__c = 'NÃO',
                Pedido_da_Linha_de_OPME__c = 'NÃO',
                CurrencyIsoCode = contrato.CurrencyIsoCode
            );
            pedidos.add(pedido);
        }
    }

    public static Map<String, PricebookEntry> buscaPBEs(Set<String> codigos) {
        Map<String, PricebookEntry> result = new Map<String, PricebookEntry>();
        for (PricebookEntry p : [
            SELECT Id, Product2Id, Product2.ProductCode, CurrencyIsoCode, UnitPrice 
            FROM PricebookEntry 
            WHERE Product2.ProductCode IN :codigos AND Pricebook2Id = '01s5A000004fbcR'
        ]) {
            result.put(p.Product2.ProductCode + 'LOCACAO', p);
        }
        return result;
    }

    public static void criaOrderItems(
        List<Order> pedidos,
        Map<String, PricebookEntry> pbes,
        Map<String, Decimal> quantidades,
        Map<String, Decimal> valores,
        Map<String, String> nomes,
        PedidoData info,
        List<OrderItem> itens,
        String emails
    ) {
        for (Order pedido : pedidos) {
            Integer index = 1;
            for (String codigo : quantidades.keySet()) {
                Decimal qtd = quantidades.get(codigo);
                Decimal total = valores.get(codigo);
                Decimal precoUnit = total / qtd;

                PricebookEntry pbe = pbes.get(codigo);
                OrderItem item = new OrderItem(
                    OrderId = pedido.Id,
                    Product2Id = (pbe != null ? pbe.Product2Id : '01t6e000009ZTsV'),
                    PricebookEntryId = (pbe != null ? pbe.Id : '01u6e000019dnXM'),
                    Quantity = qtd,
                    UnitPrice = precoUnit,
                    Item__c = index++,
                    Status__c = 'Novo'
                );
                itens.add(item);
            }

            pedido.Observacoes_Gerais__c = gerarObservacoes(quantidades, nomes, pedido.Periodo_do_contrato_inicio__c, pedido.Per_odo_do_contrato_Fim__c, info,  emails);
        }
    }

    public static String gerarObservacoes(Map<String, Decimal> quantidades, Map<String, String> nomes, Date inicio, Date fim, PedidoData info, String emails) {
        String obs = 'REFERENTE A LOCAÇÃO DE ';
    
        for (String codigo : quantidades.keySet()) {
            obs += quantidades.get(codigo) + ' ' + nomes.get(codigo) + '\n';
        }
        
        obs += 'PERÍODO: ' + formatDate(inicio) + ' A ' + formatDate(fim) +  '\n';
        
        if(info.dadosBancarios.pagamentoAdiantado == true){
            obs += 'ENVIAR PARA : ' + emails + '\n';
        } else {
            obs += 'Empresa: ' + info.locador.Raz_o_Social__c + '\n'
                + 'Banco: ' + info.dadosBancarios.banco + '\n'
                + 'Agência: ' + info.dadosBancarios.agencia + '\n'
                + 'Conta Corrente: ' + info.dadosBancarios.contaCorrente + '\n'
                + 'CNPJ: ' + info.locador.CNPJ__c + '\n'
                + 'ENVIAR PARA : ' + emails + '\n';
        }

        return obs;
    }

    public static String formatDate(Date d) {
         return (d.day() < 10 ? '0' + String.valueOf(d.day()) : String.valueOf(d.day())) + '/' + 
           (d.month() < 10 ? '0' + String.valueOf(d.month()) : String.valueOf(d.month())) + '/' + 
           String.valueOf(d.year());
    }

    public static DadosBancarios getDadosBancarios(String original){

        DadosBancarios dados = new DadosBancarios();

        if(FORMAS_PAGAMENTOS_ADIANTADOS.contains(original)){
            dados.pagamentoAdiantado = true;
            return dados;
        }

        if(original == 'R- Banco Caixa Econômica Federal Ag.2512 C/C 4001-4 - Hospcom'){
            dados.banco = 'Caixa Econômica Federal';
            dados.agencia = '2512';
            dados.contaCorrente = '4001-4';
            return dados;
        }
        
        String modificado = original.replace('Ag: ', '');
        String modificado2 = modificado.replace('Cc: ', ' - ');
        List<String> partes = modificado2.split(' - ');

        dados.banco = partes[1];
        dados.agencia = partes[2];
        dados.contaCorrente = partes[3];

        return dados;
    }

    public class PedidoData {
        public Contact contato;
        public Account locatario;
        public Account locador;
        public Integer numeroDias;
        public String telefone;
        public Date dataInicial;
        public DadosBancarios dadosBancarios;
    }

    public class DadosBancarios {
        public String banco;
        public String agencia;
        public String contaCorrente;
        public Boolean pagamentoAdiantado;
    }
}