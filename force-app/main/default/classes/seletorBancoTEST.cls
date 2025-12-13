@isTest(seeAllData=true)
public class seletorBancoTEST {

    @isTest
    static void testeAtualizarOuCriarRegistro() {
        seletorBanco.atualizarOuCriarRegistro('banco_dia', 'Dados de teste');
        seletorBanco.atualizarOuCriarRegistro('opt_dft', 'Dados de teste');
    }
}