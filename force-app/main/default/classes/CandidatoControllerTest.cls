@isTest
public class CandidatoControllerTest {
	@isTest
    private static void save(){
        Test.startTest();
        CandidatoController obj = new CandidatoController();
        obj.Cargo = 'Teste';
        obj.Nome = 'Nome';
        obj.Sobrenome = 'Sobrenome';
        obj.Email = 'teste@teste.com';
        obj.CPF = '299.092.970-35';
        obj.telefone = '62997745662';
        obj.salvar();
        Test.stopTest();
    }
    @isTest
    private static void save2(){
        Test.startTest();
        CandidatoController obj = new CandidatoController();
        obj.Nome = '';
        obj.Cargo = 'Teste';
        obj.Sobrenome = 'Sobrenome';
        obj.Email = 'teste@teste.com';
        obj.CPF = '493.072.220-96';
        obj.telefone = '62997745662';
        obj.salvar();
        Test.stopTest();
    }
}