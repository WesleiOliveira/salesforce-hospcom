@isTest(SeeAllData=true)
public class aprovacaoPedidoTESTE {
    
    
    static testMethod void testAprove() {
        aprovacaoPedido.aprovaPedido('04iU4000006eQgHIAU', 'TESTE');
    }
    
    
    static testMethod void testReject() {
        aprovacaoPedido.rejeitaPedido('04iU4000006eQgHIAU', 'TESTE', 'Financeiro - CNPJ Divergente', '8016e00000803mxAAA');
    }

}