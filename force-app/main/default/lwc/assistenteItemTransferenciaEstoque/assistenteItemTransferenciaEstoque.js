import { LightningElement, api, wire} from 'lwc';
import soql from '@salesforce/apex/ApexHelperController.executeSoql';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import criaItem from '@salesforce/apex/transferenciaEstoque.cria';

export default class AssistenteItemTransferenciaEstoque extends LightningElement {
    @api recordId;
    
    quantidadeEstoque = 0;
    estoqueOrigem = '';
    idProduto = '';
    estoqueDestino = '';
    quantidadeEstoqueDestino = 0;
    quantidadeATransferir = 0;

    // Lista de opções estáticas
    options = [
        { label: "153 - HOSPCOM - ESTOQUE GALPÃO LOG1", value: "153" },
        { label: 'BR153 - HOSPCOM - BR153', value: 'BR153' },
        { label: '04 - HOSPCOM - EM LOCACAO', value: '04' },
        { label: '89 - HEALTH', value: '89' },
        { label: '01 - HOSPCOM - ESTOQUE LOCAÇÃO 104', value: '01' },
        { label: '03 - HOSPCOM - ASSISTENCIA', value: '03' },
        { label: "01-NC - HOSPCOM NÃO CONFORME LOCAÇÃO 104", value: "01-NC" },
        { label: "02 - HOSPCOM - EM DEMONSTRACAO", value: "02" },
        { label: "05 - HOSPCOM - COMODATO", value: "05" },
        { label: "06 - HOSPCOM - COMPRAS", value: "06" },
        { label: "07 - HOSPCOM - AJUSTE TO", value: "07" },
        { label: "08 - HOSPCOM - IMOBILIZADOS", value: "08" },
        { label: "09 - HOSPCOM - SEM MOVIMENTO", value: "09" },
        { label: "10 - HOSPCOM - BRASILIA", value: "10" },
        { label: "100 - TRANSITORIO HOSPCOM", value: "100" },
        { label: "1000 - HOSPCOM - TRANSITAÇÃO PREVIA DE ESTOQUES", value: "1000" },
        { label: "101 - TRANSITORIO GDB", value: "101" },
        { label: "1010 - HOSPCOM - AJUSTE DE INVENTARIO", value: "1010" },
        { label: "102 - TRANSITORIO HEALTH", value: "102" },
        { label: "1020 - GDB - JUSTE DE INVENTARIO", value: "1020" },
        { label: "1030 - HEALTH - JUSTE DE INVENTARIO", value: "1030" },
        { label: "109 - GDB - ESTOQUE 89", value: "109" },
        { label: "11 - GDB - ESTOQUE OFICIAL CG", value: "11" },
        { label: "1111 - HOSPCOM-NÃO REGISTRAR NO SPED FISCAL BL H", value: "1111" },
        { label: "12 - GDB - AJUSTE TO", value: "12" },
        { label: "13 - GDB - ASSISTENCIA", value: "13" },
        { label: "14 - GDB - LOCACAO", value: "14" },
        { label: "15 - GDB - DEMONSTRACAO", value: "15" },
        { label: "153-NC - HOSPCOM - NÃO CONFORME GALPÃO LOG1", value: "153-NC" },
        { label: "154 - GDB - ESTOQUE GALPÃO LOG1", value: "154" },
        { label: "155 - HEALTH - ESTOQUE GALPÃO LOG1", value: "155" },
        { label: "156 - ABC TO - ESTOQUE GALPÃO LOG1", value: "156" },
        { label: "16 - GDB - COMODATO", value: "16" },
        { label: "17 - GDB - IMOBILIZADOS", value: "17" },
        { label: "19 - GDB - SEM MOVIMENTO", value: "19" },
        { label: "199 - GDB-CONSUMO", value: "199" },
        { label: "20 - GDB - BRASILIA", value: "20" },
        { label: "21 - HEALTH - ESTOQUE LOCAÇÃO 104", value: "21" },
        { label: "22 - HEALTH - DEMONTRAÇOES", value: "22" },
        { label: "23 - HEALTH - ASSISTENCIA", value: "23" },
        { label: "24 - HEALTH - AJUSTE TO", value: "24" },
        { label: "25 - HEALTH - LOCACAO", value: "25" },
        { label: "26 - HEALTH - COMODATO", value: "26" },
        { label: "27 - HEALTH - IMOBILIZADOS", value: "27" },
        { label: "289 - HEALTH - ESTOQUE 89", value: "289" },
        { label: "29 - HEALTH - SEM MOVIMENTO", value: "29" },
        { label: "299 - HEALTH- CONSUMO", value: "299" },
        { label: "30 - HEALTH - BRASILIA", value: "30" },
        { label: "300 - ABC MT", value: "300" },
        { label: "301 - HOSPCOM- ESTOQUE OESTE GYN", value: "301" },
        { label: "301-NC - HOSPCOM - NAO CONFORME", value: "301-NC" },
        { label: "302 - GDB- ESTOQUE OESTE GYN", value: "302" },
        { label: "303 - HEALTH- ESTOQUE OESTE GYN", value: "303" },
        { label: "304 - ABC TO - ESTOQUE OESTE GYN", value: "304" },
        { label: "305 - HOSPCOM - GALPAO", value: "305" },
        { label: "305-NC - HOSPCOM- NÃO CONFORME GALPÃO SG", value: "305-NC" },
        { label: "306 - HOSPCOM-LOCAÇÃO SANTA GENOVEVA-DESATIVADO", value: "306" },
        { label: "307 - HOSPCOM - QUARENTENA OESTE GYN", value: "307" },
        { label: "308 - HEALTH - IMPORTACAO", value: "308" },
        { label: "309 - GDB- LOCAÇÃO SANTA GENOVEVA", value: "309" },
        { label: "31 - HOSPCOM - CAMPO GRANDE", value: "31" },
        { label: "310 - ABC TO - AJUSTE TO", value: "310" },
        { label: "316 - HOSPCOM- LOCAÇÃO SANTA GENOVEVA", value: "316" },
        { label: "32 - HOSPCOM - TOCANTINS", value: "32" },
        { label: "33 - GDB - TOCANTINS", value: "33" },
        { label: "34 - HEALTH - TOCANTINS", value: "34" },
        { label: "35 - GDB - ESTOQUE DE LOCAÇÃO 104", value: "35" },
        { label: "350 - INATIVO", value: "350" },
        { label: "352 - ABC Sorocaba Imobilizado", value: "352" },
        { label: "36 - HEALTH - CAMPO GRANDE", value: "36" },
        { label: "37 - HOSPCOM- MATO GROSSO", value: "37" },
        { label: "38 - HEALTH- MATO GROSSO", value: "38" },
        { label: "389 - ABC TO - ESTOQUE 89", value: "389" },
        { label: "39 - ABC TO - SEM MOVIMENTO", value: "39" },
        { label: "390 - ABC TO - ESTOQUE DE LOCAÇÃO 104", value: "390" },
        { label: "399 - ABC TO - CONSUMO", value: "399" },
        { label: "40 - ABC GYN - ESTOQUE OESTE GYN", value: "40" },
        { label: "401 - HOSPCOM SÃO PAULO", value: "401" },
        { label: "402 - GDB - SÃO PAULO", value: "402" },
        { label: "406 - HOSPCOM FILIAL SOROCABA", value: "406" },
        { label: "407 - HOSPCOM SOROCABA SEM MOV ESTOQUE", value: "407" },
        { label: "408 - HOSPCOM FILIAL SOROCABA EM LOCAÇÃO", value: "408" },
        { label: "41 - ABC Equipamentos -  Filial INDEFINIDO", value: "41" },
        { label: "42 - HOSPCOM SHOW ROOM PALMAS", value: "42" },
        { label: "49 - ABC GYN - SEM MOVIMENTO", value: "49" },
        { label: "50 - HOSPCOM - RESERVADO OESTE GYN", value: "50" }
    ]

    handleProdutoChange(event) {
        // Obtém o valor do registro selecionado
        const produtoId = event.target.value; // Utilize event.target.value para acessar o valor diretamente
        this.idProduto = produtoId;
        console.log('Registro selecionado:', produtoId);
        this.consultaDadosRegistro()
    }

    async consultaDadosRegistro(){
        var query = "select id, name, Estoque_de_destino__c, Estoque_de_origem__c from Solicitacao_transferencia_estoque__c where id = '"+this.recordId+"'"
        console.log("QUERY", query)
        var resultado = await soql({ soql: query })
        console.log("RESULTADO REGISTRO", resultado)

        const regex = /^(\S+)\s+-/;
        const match = resultado[0].Estoque_de_origem__c.match(regex);
        const codigo = match[1];

        const regex2 = /^(\S+)\s+-/;
        const match2 = resultado[0].Estoque_de_destino__c.match(regex2);
        const codigo2 = match2[1];

        console.log("ESTOQUES", codigo, codigo2)

        this.estoqueOrigem = codigo
        this.estoqueDestino = codigo2

        this.obtemQuantidadeEstoque()
    }

    handleQuantidadeChange(event) {
        this.quantidadeATransferir = event.target.value; // Atualiza a variável com o novo valor
    }

    // Função chamada quando uma opção é selecionada
    handleChange(event) {
        const estoqueSelecionado = event.detail.value;
        this.estoqueOrigem = estoqueSelecionado;

        console.log('Opção selecionada:', estoqueSelecionado);
        console.log('Produto selecionado:', this.idProduto);
        this.obtemQuantidadeEstoque()
    }

    // Função chamada quando uma opção é selecionada
    handleChange2(event) {
        const estoqueSelecionado = event.detail.value;
        this.estoqueDestino = estoqueSelecionado;

        console.log('Opção selecionada:', estoqueSelecionado);
        this.obtemQuantidadeDestino()
    }

    async obtemQuantidadeEstoque(){
        var query = "SELECT SUM(Em_estoque__c) totalEstoque FROM Entrada_de_Estoque__c WHERE Produto__c = '"+this.idProduto+"' AND CodigoEstoque__c = '"+this.estoqueOrigem+"'"
        var resultado = await soql({ soql: query })
        console.log("QUANTIDADE", resultado[0].totalEstoque)
        this.quantidadeEstoque = resultado[0].totalEstoque
    }

    async obtemQuantidadeDestino(){
        var query = "SELECT SUM(Em_estoque__c) totalEstoque FROM Entrada_de_Estoque__c WHERE Produto__c = '"+this.idProduto+"' AND CodigoEstoque__c = '"+this.estoqueDestino+"'"
        var resultado = await soql({ soql: query })
        console.log("QUANTIDADE", resultado[0].totalEstoque)
        this.quantidadeEstoqueDestino = resultado[0].totalEstoque
    }

    async criaItemSolicitacao(){

        var idSolicitacao = this.recordId

        console.log("ID DO REGISTRO", idSolicitacao)

        var idProduto = this.idProduto
        var quantidade = this.quantidadeATransferir
        var estoqueOrigem = this.estoqueOrigem
        var estoqueDestino = this.estoqueDestino

        console.log("QUANTIDADE", quantidade)

        try {
            var resultado = await criaItem({ 
                solicitacao: idSolicitacao,
                produto: idProduto,
                quantidade: quantidade,
                estoqueOrigem: "",
                estoqueDestino: ""
            })
            this.showToast('Sucesso', 'Item da solicitação criado!', 'success');
            console.log("RESULTADO CRIACAO", resultado)
            //window.location.reload();

        } catch (err) {
            // Captura e armazena o erro
            var erro = err.body ? err.body.message : err.message;
            this.showToast('Erro', erro, 'error');
            console.log("RESULTADO CRIACAO", erro)
        }
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant, // Variants: success, error, warning, info
        });
        this.dispatchEvent(event);
    }


}