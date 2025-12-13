@isTest
public class RelatorioDestinacaoComprasContrTest {
    @isTest
    public static void teste(){
        Test.startTest();
        RelatorioDestinacaoComprasContr cls = new RelatorioDestinacaoComprasContr();
        cls.dataInicial = system.today() - 30;
        cls.dataFinal = system.today();
        cls.pc = '616';
        cls.pv = '';
        cls.apenasDisp = false;
        cls.apenasEquip = false;
        cls.pesquisar();
        Test.stopTest();
    }
    @isTest
    public static void pc(){
        Test.startTest();
        RelatorioDestinacaoComprasContr cls = new RelatorioDestinacaoComprasContr();
        cls.pc = '';
        cls.cod = 'MA-H11A';
        cls.pesquisar();
        Test.stopTest();
    }
    @isTest
    public static void apD(){
        Test.startTest();
        RelatorioDestinacaoComprasContr cls = new RelatorioDestinacaoComprasContr();
        cls.apenasDisp = true;
        cls.apenasEquip = false;
        cls.cod = '';
        cls.pv = '';
        cls.pc = '';
        cls.prod = '';
        cls.marca = '';
        cls.modelo = '';
        cls.apenasDest = false;
        cls.pesquisar();
        Test.stopTest();
    }
    @isTest
    public static void cod(){
        Test.startTest();
        RelatorioDestinacaoComprasContr cls = new RelatorioDestinacaoComprasContr();
        cls.apenasDisp = false;
        cls.apenasEquip = false;
        cls.cod = 'MA-H11A';
        cls.pv = '';
        cls.pc = '';
        cls.prod = '';
        cls.marca = '';
        cls.modelo = '';
        cls.apenasDest = false;
        cls.pesquisar();
        Test.stopTest();
    }
    @isTest
    public static void cod2(){
        Test.startTest();
        RelatorioDestinacaoComprasContr cls = new RelatorioDestinacaoComprasContr();
        cls.apenasDisp = true;
        cls.apenasEquip = false;
        cls.cod = 'MA-H11A';
        cls.pv = '';
        cls.pc = '';
        cls.prod = '';
        cls.marca = '';
        cls.modelo = '';
        cls.apenasDest = false;
        cls.pesquisar();
        Test.stopTest();
    }
    @isTest
    public static void cod3(){
        Test.startTest();
        RelatorioDestinacaoComprasContr cls = new RelatorioDestinacaoComprasContr();
        cls.apenasDisp = false;
        cls.apenasEquip = false;
        cls.cod = 'MA-H11A';
        cls.pv = '';
        cls.pc = '';
        cls.prod = '';
        cls.marca = '';
        cls.modelo = '';
        cls.apenasDest = true;
        cls.pesquisar();
        Test.stopTest();
    }
    @isTest
    public static void prod(){
        Test.startTest();
        RelatorioDestinacaoComprasContr cls = new RelatorioDestinacaoComprasContr();
        cls.apenasDisp = false;
        cls.apenasEquip = false;
        cls.cod = '';
        cls.pv = '';
        cls.pc = '';
        cls.prod = 'GAVETA';
        cls.marca = '';
        cls.modelo = '';
        cls.apenasDest = false;
        cls.pesquisar();
        Test.stopTest();
    }
    @isTest
    public static void prod2(){
        Test.startTest();
        RelatorioDestinacaoComprasContr cls = new RelatorioDestinacaoComprasContr();
        cls.apenasEquip = false;
        cls.apenasDisp = true;
        cls.cod = '';
        cls.pv = '';
        cls.pc = '';
        cls.prod = 'GAVETA';
        cls.marca = '';
        cls.modelo = '';
        cls.apenasDest = false;
        cls.pesquisar();
        Test.stopTest();
    }
    @isTest
    public static void prod3(){
        Test.startTest();
        RelatorioDestinacaoComprasContr cls = new RelatorioDestinacaoComprasContr();
        cls.apenasDisp = false;
        cls.apenasEquip = false;
        cls.cod = '';
        cls.pv = '';
        cls.pc = '';
        cls.prod = 'GAVETA';
        cls.marca = '';
        cls.modelo = '';
        cls.apenasDest = true;
        cls.pesquisar();
        Test.stopTest();
    }
    @isTest
    public static void marca(){
        Test.startTest();
        RelatorioDestinacaoComprasContr cls = new RelatorioDestinacaoComprasContr();
        cls.apenasDisp = false;
        cls.apenasEquip = false;
        cls.cod = '';
        cls.pv = '';
        cls.pc = '';
        cls.prod = '';
        cls.marca = 'MINDRAY';
        cls.modelo = '';
        cls.apenasDest = false;
        cls.pesquisar();
        Test.stopTest();
    }
    @isTest
    public static void marca2(){
        Test.startTest();
        RelatorioDestinacaoComprasContr cls = new RelatorioDestinacaoComprasContr();
        cls.apenasDisp = true;
        cls.apenasEquip = false;
        cls.cod = '';
        cls.pv = '';
        cls.pc = '';
        cls.prod = '';
        cls.marca = 'MINDRAY';
        cls.modelo = '';
        cls.apenasDest = false;
        cls.pesquisar();
        Test.stopTest();
    }
    @isTest
    public static void marca3(){
        Test.startTest();
        RelatorioDestinacaoComprasContr cls = new RelatorioDestinacaoComprasContr();
        cls.apenasDisp = false;
        cls.apenasEquip = false;
        cls.cod = '';
        cls.pv = '';
        cls.pc = '';
        cls.prod = '';
        cls.marca = 'MINDRAY';
        cls.modelo = '';
        cls.apenasDest = true;
        cls.pesquisar();
        Test.stopTest();
    }
    @isTest
    public static void modelo(){
        Test.startTest();
        RelatorioDestinacaoComprasContr cls = new RelatorioDestinacaoComprasContr();
        cls.apenasDisp = false;
        cls.apenasEquip = false;
        cls.cod = '';
        cls.pv = '';
        cls.pc = '';
        cls.prod = '';
        cls.marca = '';
        cls.modelo = 'Vision';
        cls.apenasDest = false;
        cls.pesquisar();
        Test.stopTest();
    }
    @isTest
    public static void modelo2(){
        Test.startTest();
        RelatorioDestinacaoComprasContr cls = new RelatorioDestinacaoComprasContr();
        cls.apenasDisp = true;
        cls.apenasEquip = false;
        cls.cod = '';
        cls.pv = '';
        cls.pc = '';
        cls.prod = '';
        cls.marca = '';
        cls.modelo = 'Vision';
        cls.apenasDest = false;
        cls.pesquisar();
        Test.stopTest();
    }
    @isTest
    public static void modelo3(){
        Test.startTest();
        RelatorioDestinacaoComprasContr cls = new RelatorioDestinacaoComprasContr();
        cls.apenasDisp = false;
        cls.apenasEquip = false;
        cls.cod = '';
        cls.pv = '';
        cls.pc = '';
        cls.prod = '';
        cls.marca = '';
        cls.modelo = 'Vision';
        cls.apenasDest = true;
        cls.pesquisar();
        Test.stopTest();
    }
    @isTest
    public static void apD2(){
        Test.startTest();
        RelatorioDestinacaoComprasContr cls = new RelatorioDestinacaoComprasContr();
        cls.apenasDisp = true;
        cls.apenasEquip = false;
        cls.cod = '';
        cls.pv = '';
        cls.pc = '';
        cls.prod = '';
        cls.marca = '';
        cls.modelo = '';
        cls.apenasDest = false;
        cls.pesquisar();
        Test.stopTest();
    }
}