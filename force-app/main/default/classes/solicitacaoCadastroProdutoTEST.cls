@isTest(SeeAllData=true)
public class solicitacaoCadastroProdutoTEST {
    
    static testMethod void testCreateSolicitacaoDeCadastro() {
        //String assinaturaCliente, String assinaturaHospcom, String nomeCliente, String nomeHospcom, String orderId
        //teste 801HZ00000Fl3hoYAB
        //produ 801U4000001ib8BIAQ
        
        String nome = 'Nome do Produto Excedendo o Tamanho Máximo Permitido';
        String descricao = 'Descrição do Produto Excedendo o Tamanho Máximo Permitido';
        String modelo = 'OUTROS';
        String marca = 'OUTROS';
        String c_d_Fabricante = 'OUTROS';
        String unidadeDeMedida = 'UN';
        String categoriaCompra = 'MATERIAL LIMPEZA';
        
        solicitacaoCadastroProduto.createSolicitacaoDeCadastro(
            categoriaCompra,
            nome, 
            descricao, 
            modelo, 
            marca, 
            c_d_Fabricante, 
            unidadeDeMedida
        );
    }
}