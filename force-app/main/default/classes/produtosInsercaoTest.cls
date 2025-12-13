@isTest
public class produtosInsercaoTest {
    @isTest
    public static void testaInsercao(){
        try{
        produtosInsercao.inserirProdutos('[{"Código do Fabricante":"HAYSUA75363H","Nome":"Produto Teste","Marca":"Mindray","Modelo":"Modelo EP TESTE","Linha":"IMAGEM","Família":"ULTRASSOM POC","Tipo":"Equipamento","Valor de venda":"8000","Descrição":"Equipamento teste de envio upload","NCM":"5421042"},{"Código do Fabricante":"5451656TRA","Nome":"Produto Teste","Marca":"Mindray","Modelo":"Modelo EP TESTE","Linha":"IMAGEM","Família":"ULTRASSOM POC","Tipo":"Equipamento","Valor de venda":"8000","Descrição":"Equipamento teste de envio upload","NCM":"5421042"}]');
    
        }
        catch(Exception e){
            
        }
    }
    @isTest
    public static void testaInsercao2(){
        try{
        produtosInsercao.inserirProdutosConsumo('[{"Nome":"Produto Teste","Modelo":"Modelo EP TESTE","Categoria de Compra":"ALIMENTAÇÃO","Descrição":"Equipamento teste de envio upload","NCM":"5421042"},{"Nome":"Produto Teste 2","Modelo":"Modelo EP TESTE","Categoria de Compra":"ALIMENTAÇÃO","Descrição":"Equipamento teste de envio upload","NCM":"5421042"}]');    
        }
        catch(Exception e){
            
        }
    }
}