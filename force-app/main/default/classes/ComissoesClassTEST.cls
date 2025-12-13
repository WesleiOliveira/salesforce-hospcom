@isTest
public class ComissoesClassTEST {
    @isTest
    private static void search(){
        Test.startTest();
        Comiss obj = new Comiss();
        obj.search();
        Test.stopTest();
    }
    @isTest
    private static void search2(){
        Test.startTest();
        Comiss obj = new Comiss();
        obj.pago='true';
        obj.search();
        Test.stopTest();
    }
    @isTest
    private static void search3(){
        Test.startTest();
        Comiss obj = new Comiss();
        obj.pago='false';
        obj.search();
        Test.stopTest();
    }    
    @isTest
    private static void clear(){
        Test.startTest();
        Comiss obj = new Comiss();
        obj.clear();
        Test.stopTest();
    }
    @isTest
    private static void show(){
        Test.startTest();
        Comiss obj = new Comiss();
        obj.show();
        Test.stopTest();
    }
    @isTest
    private static void page(){
        Test.startTest();
        Comiss obj = new Comiss();
        obj.page();
        Test.stopTest();
    }
    @isTest
    private static void pageclose(){
        Test.startTest();
        Comiss obj = new Comiss();
        obj.pageclose();
        Test.stopTest();
    }
     @isTest
    private static void close(){
        Test.startTest();
        Comiss obj = new Comiss();
        obj.close();
        Test.stopTest();
    }
     @isTest
    private static void print(){
        Test.startTest();
        Comiss obj = new Comiss();
        obj.print();
        Test.stopTest();
    }

   @isTest
    private static pageReference cancel(){
        Test.startTest();
        Comiss obj = new Comiss();
        obj.cancel();
        Test.stopTest();
        return null;
    } 
}