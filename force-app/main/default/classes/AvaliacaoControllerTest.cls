@isTest(SeeAllData=true)
private class AvaliacaoControllerTest {
	@isTest
    private static void teste1(){
        Test.startTest();
        AvaliacaoController obj = new AvaliacaoController();
        obj.senha = '6jgf4fwt';
        obj.validar();
        obj.Ageral();
        obj.Aenfermagem();
        obj.Afisioterapia();
        obj.Afonoaudiologia();
        obj.Amedica();
        obj.Apsicologia();
        obj.Aterapiaocupac();
        obj.nova();
        Test.stopTest();
    } 
    @isTest
    private static void teste2(){
        Test.startTest();
        AvaliacaoController obj = new AvaliacaoController();
        obj.senha='a';
        obj.validar();
		obj.AIVD = '1';
        obj.creategeral();        
        Test.stopTest();
    }
    @isTest
    private static void enf(){
        Test.startTest();
        AvaliacaoController obj = new AvaliacaoController();
        obj.acessoesgoto = true;
        obj.ambientearejado = true;
        obj.ambientelimpo = true;
        obj.ambienteorganizado = true;
        obj.createenfermagem();
        Test.stopTest();
    }
    @isTest
    private static void fisio(){
        Test.startTest();
        AvaliacaoController obj = new AvaliacaoController();
        List <String> teste = new List<String>();
        teste.add('Cardiopatia');
        obj.antecpessoais = teste;
        obj.createfisioterapia();        
        Test.stopTest();
    }
    @isTest
    private static void fono(){
        Test.startTest();
        AvaliacaoController obj = new AvaliacaoController();
        obj.createfonoaudiologia();        
        Test.stopTest();
    }    
    @isTest
    private static void med(){
        Test.startTest();
        AvaliacaoController obj = new AvaliacaoController();
        List <String> teste = new List<String>();
        teste.add('Hipertensão Arterial');
        teste.add('Doença Arterial Coronariana');
        obj.comorbidades = teste;
        obj.createmedica();        
        Test.stopTest();
    }
    @isTest
    private static void psico(){
        Test.startTest();
        AvaliacaoController obj = new AvaliacaoController();
        List <String> seSimm = new List<String>();
        obj.seSimPaciente = seSimm;
        obj.seSimFamiliar = seSimm;
        List <String> manifesta = new List<String>();
        obj.manifestPsiqui = manifesta;
        obj.createPsicologia();        
        Test.stopTest();
    }
    @isTest
    private static void terap(){
        Test.startTest();
        AvaliacaoController obj = new AvaliacaoController();
        obj.createTerapiaOcup();        
        Test.stopTest();
    }
}