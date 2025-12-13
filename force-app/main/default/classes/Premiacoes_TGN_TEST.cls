@isTest
private class Premiacoes_TGN_TEST{
    @isTest
    private static void search_TGN_TEST(){
        Test.startTest();
        PremiacoesClass obj = new PremiacoesClass();
        obj.search();
        Test.stopTest();
    }
    @isTest
    private static void clear_TGN_TEST(){
        Test.startTest();
        PremiacoesClass obj = new PremiacoesClass();
        obj.clear();
        Test.stopTest();
    }
    @isTest
    private static void fechar_TGN_TEST(){
        Test.startTest();
        PremiacoesClass obj = new PremiacoesClass();
        obj.fechar();
        Test.stopTest();
    }
    @isTest
    private static void abrir_TGN_TEST(){
        Test.startTest();
        PremiacoesClass obj = new PremiacoesClass();
        obj.abrir();
        Test.stopTest();
    }
    @isTest
    private static PageReference enviar(){
        Test.startTest();
        PremiacoesClass obj = new PremiacoesClass();
        obj.passValue();
        Test.stopTest();
        return null;
    }
}