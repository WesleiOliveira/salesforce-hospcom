@isTest(SeeAllData=true)

public class CloneCLTest {

    static testMethod void testAdder() {
        
        Asset X = New Asset(AccountId='0013100001kNhtUAAS',Name='TesteA', SerialNumber ='TesteB');
        insert X;
    
		Asset A = new Asset(Id='02i7b00000E8RkQ',AccountId='0013100001kNhtUAAS',SerialNumber='TESTEX2',Name='TESTE1');
   
        Asset B = A.clone(false,true,false,false);
        insert B;
        
        Checklist_do_Ativo__c cl = new Checklist_do_Ativo__c(Nome_do_Item__c='Test', Ativo_Relacionado__c=B.ID, Ativo__c = true, Quantidade__c = 1);
        insert cl;     
}
    
        static testMethod void testAdder2() {
            
    	Asset X = New Asset(AccountId='0013100001kNhtUAAS',Name='TesteA', SerialNumber ='TesteB');
        insert X;
    
		Asset A = new Asset(Id='02i31000006fOSV',AccountId='0013100001kNhtUAAS',SerialNumber='TESTEX2',Name='TESTE1');
   
        Asset B = A.clone(false,true,false,false);
        insert B;
        
        Checklist_do_Ativo__c cl = new Checklist_do_Ativo__c(Nome_do_Item__c='Test', Ativo_Relacionado__c=B.ID, Ativo__c = true, Quantidade__c = 1);
        insert cl;
}
    static testMethod void testAdder3() {
            
    	Asset X = New Asset(AccountId='0013100001kNhtUAAS',Name='TesteA', SerialNumber ='TesteB');
        insert X;
    
		Asset A = new Asset(Id='02i7b00000E8RlE',AccountId='0013100001kNhtUAAS',SerialNumber='TESTEX2',Name='TESTE1');
   
        Asset B = A.clone(false,true,false,false);
        insert B;
        
        Checklist_do_Ativo__c cl = new Checklist_do_Ativo__c(Nome_do_Item__c='Test', Ativo_Relacionado__c=B.ID, Ativo__c = true, Quantidade__c = 1);
        insert cl;
}
    static testMethod void testAdder5() {
       	Asset X = New Asset(AccountId='0013100001kNhtUAAS',Name='TesteA', SerialNumber ='TesteB');
        insert X;
    
		Asset A = new Asset(Id='02i31000006fOSa',AccountId='0013100001kNhtUAAS',SerialNumber='TESTEX2',Name='TESTE1');
            
        Checklist_do_Ativo__c c1 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test1', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c2 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test2', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c3 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test3', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c4 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test4', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c5 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test5', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
            insert c1;
            insert c2;
            insert c3;
            insert c4;
            insert c5;

        Asset B = A.clone(false,true,false,false);
        insert B;
        
        Checklist_do_Ativo__c cl = new Checklist_do_Ativo__c(Nome_do_Item__c='Test', Ativo_Relacionado__c=B.ID, Ativo__c = true, Quantidade__c = 1);
        insert cl;     

}
    static testMethod void testAdder6() {
       	Asset X = New Asset(AccountId='0013100001kNhtUAAS',Name='TesteA', SerialNumber ='TesteB');
        insert X;
    
		Asset A = new Asset(Id='02i31000006fOSa',AccountId='0013100001kNhtUAAS',SerialNumber='TESTEX2',Name='TESTE1');
            
        Checklist_do_Ativo__c c1 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test1', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c2 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test2', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c3 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test3', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c4 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test4', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c5 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test5', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c6 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test6', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
            insert c1;
            insert c2;
            insert c3;
            insert c4;
            insert c5;
            insert c6;

        Asset B = A.clone(false,true,false,false);
        insert B;
        
        Checklist_do_Ativo__c cl = new Checklist_do_Ativo__c(Nome_do_Item__c='Test', Ativo_Relacionado__c=B.ID, Ativo__c = true, Quantidade__c = 1);
        insert cl;     

}    
  static testMethod void testAdder7() {
       	Asset X = New Asset(AccountId='0013100001kNhtUAAS',Name='TesteA', SerialNumber ='TesteB');
        insert X;
    
		Asset A = new Asset(Id='02i31000006fOSa',AccountId='0013100001kNhtUAAS',SerialNumber='TESTEX2',Name='TESTE1');
            
        Checklist_do_Ativo__c c1 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test1', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c2 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test2', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c3 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test3', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c4 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test4', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c5 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test5', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c6 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test6', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c7 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test7', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
            insert c1;
            insert c2;
            insert c3;
            insert c4;
            insert c5;
            insert c6;
            insert c7;

        Asset B = A.clone(false,true,false,false);
        insert B;
        
        Checklist_do_Ativo__c cl = new Checklist_do_Ativo__c(Nome_do_Item__c='Test', Ativo_Relacionado__c=B.ID, Ativo__c = true, Quantidade__c = 1);
        insert cl;     

}  
    static testMethod void testAdder8() {
       	Asset X = New Asset(AccountId='0013100001kNhtUAAS',Name='TesteA', SerialNumber ='TesteB');
        insert X;
    
		Asset A = new Asset(Id='02i31000006fOSa',AccountId='0013100001kNhtUAAS',SerialNumber='TESTEX2',Name='TESTE1');
            
        Checklist_do_Ativo__c c1 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test1', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c2 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test2', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c3 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test3', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c4 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test4', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c5 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test5', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c6 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test6', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c7 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test7', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c8 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test8', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
            insert c1;
            insert c2;
            insert c3;
            insert c4;
            insert c5;
            insert c6;
            insert c7;
            insert c8;

        Asset B = A.clone(false,true,false,false);
        insert B;
        
        Checklist_do_Ativo__c cl = new Checklist_do_Ativo__c(Nome_do_Item__c='Test', Ativo_Relacionado__c=B.ID, Ativo__c = true, Quantidade__c = 1);
        insert cl;     

}
    static testMethod void testAdder9() {
       	Asset X = New Asset(AccountId='0013100001kNhtUAAS',Name='TesteA', SerialNumber ='TesteB');
        insert X;
    
		Asset A = new Asset(Id='02i31000006fOSa',AccountId='0013100001kNhtUAAS',SerialNumber='TESTEX2',Name='TESTE1');
            
        Checklist_do_Ativo__c c1 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test1', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c2 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test2', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c3 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test3', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c4 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test4', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c5 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test5', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c6 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test6', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c7 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test7', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c8 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test8', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c9 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test9', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
            insert c1;
            insert c2;
            insert c3;
            insert c4;
            insert c5;
            insert c6;
            insert c7;
            insert c8;
            insert c9;

        Asset B = A.clone(false,true,false,false);
        insert B;
        
        Checklist_do_Ativo__c cl = new Checklist_do_Ativo__c(Nome_do_Item__c='Test', Ativo_Relacionado__c=B.ID, Ativo__c = true, Quantidade__c = 1);
        insert cl;     

}
        static testMethod void testAdder10() {
       	Asset X = New Asset(AccountId='0013100001kNhtUAAS',Name='TesteA', SerialNumber ='TesteB');
        insert X;
    
		Asset A = new Asset(Id='02i31000006fOSa',AccountId='0013100001kNhtUAAS',SerialNumber='TESTEX2',Name='TESTE1');
            
        Checklist_do_Ativo__c c1 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test1', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c2 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test2', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c3 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test3', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c4 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test4', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c5 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test5', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c6 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test6', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c7 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test7', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c8 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test8', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c9 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test9', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c10 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test10', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
            insert c1;
            insert c2;
            insert c3;
            insert c4;
            insert c5;
            insert c6;
            insert c7;
            insert c8;
            insert c9;
            insert c10;

        Asset B = A.clone(false,true,false,false);
        insert B;
        
        Checklist_do_Ativo__c cl = new Checklist_do_Ativo__c(Nome_do_Item__c='Test', Ativo_Relacionado__c=B.ID, Ativo__c = true, Quantidade__c = 1);
        insert cl;     

}
 static testMethod void testAdder11() {
       	Asset X = New Asset(AccountId='0013100001kNhtUAAS',Name='TesteA', SerialNumber ='TesteB');
        insert X;
    
		Asset A = new Asset(Id='02i31000006fOSa',AccountId='0013100001kNhtUAAS',SerialNumber='TESTEX2',Name='TESTE1');
            
        Checklist_do_Ativo__c c1 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test1', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c2 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test2', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c3 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test3', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c4 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test4', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c5 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test5', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c6 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test6', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c7 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test7', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c8 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test8', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c9 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test9', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c10 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test10', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c11 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test11', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);

     		insert c1;
            insert c2;
            insert c3;
            insert c4;
            insert c5;
            insert c6;
            insert c7;
            insert c8;
            insert c9;
            insert c10;
            insert c11;

        Asset B = A.clone(false,true,false,false);
        insert B;
        
        Checklist_do_Ativo__c cl = new Checklist_do_Ativo__c(Nome_do_Item__c='Test', Ativo_Relacionado__c=B.ID, Ativo__c = true, Quantidade__c = 1);
        insert cl;     

}
    static testMethod void testAdder12() {
       	Asset X = New Asset(AccountId='0013100001kNhtUAAS',Name='TesteA', SerialNumber ='TesteB');
        insert X;
    
		Asset A = new Asset(Id='02i31000006fOSa',AccountId='0013100001kNhtUAAS',SerialNumber='TESTEX2',Name='TESTE1');
            
        Checklist_do_Ativo__c c1 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test1', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c2 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test2', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c3 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test3', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c4 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test4', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c5 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test5', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c6 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test6', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c7 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test7', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c8 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test8', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c9 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test9', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c10 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test10', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c11 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test11', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c12 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test12', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);

     		insert c1;
            insert c2;
            insert c3;
            insert c4;
            insert c5;
            insert c6;
            insert c7;
            insert c8;
            insert c9;
            insert c10;
            insert c11;
            insert c12;

        Asset B = A.clone(false,true,false,false);
        insert B;
        
        Checklist_do_Ativo__c cl = new Checklist_do_Ativo__c(Nome_do_Item__c='Test', Ativo_Relacionado__c=B.ID, Ativo__c = true, Quantidade__c = 1);
        insert cl;     

}
        static testMethod void testAdder13() {
       	Asset X = New Asset(AccountId='0013100001kNhtUAAS',Name='TesteA', SerialNumber ='TesteB');
        insert X;
    
		Asset A = new Asset(Id='02i31000006fOSa',AccountId='0013100001kNhtUAAS',SerialNumber='TESTEX2',Name='TESTE1');
            
        Checklist_do_Ativo__c c1 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test1', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c2 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test2', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c3 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test3', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c4 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test4', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c5 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test5', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c6 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test6', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c7 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test7', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c8 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test8', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c9 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test9', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c10 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test10', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c11 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test11', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c12 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test12', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c13 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test13', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);

     		insert c1;
            insert c2;
            insert c3;
            insert c4;
            insert c5;
            insert c6;
            insert c7;
            insert c8;
            insert c9;
            insert c10;
            insert c11;
            insert c12;
            insert c13;

        Asset B = A.clone(false,true,false,false);
        insert B;
        
        Checklist_do_Ativo__c cl = new Checklist_do_Ativo__c(Nome_do_Item__c='Test', Ativo_Relacionado__c=B.ID, Ativo__c = true, Quantidade__c = 1);
        insert cl;     

}
            static testMethod void testAdder14() {
       	Asset X = New Asset(AccountId='0013100001kNhtUAAS',Name='TesteA', SerialNumber ='TesteB');
        insert X;
    
		Asset A = new Asset(Id='02i31000006fOSa',AccountId='0013100001kNhtUAAS',SerialNumber='TESTEX2',Name='TESTE1');
            
        Checklist_do_Ativo__c c1 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test1', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c2 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test2', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c3 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test3', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c4 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test4', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c5 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test5', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c6 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test6', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c7 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test7', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c8 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test8', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c9 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test9', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c10 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test10', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c11 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test11', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c12 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test12', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c13 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test13', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c14 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test14', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);

     		insert c1;
            insert c2;
            insert c3;
            insert c4;
            insert c5;
            insert c6;
            insert c7;
            insert c8;
            insert c9;
            insert c10;
            insert c11;
            insert c12;
            insert c13;
            insert c14;

        Asset B = A.clone(false,true,false,false);
        insert B;
        
        Checklist_do_Ativo__c cl = new Checklist_do_Ativo__c(Nome_do_Item__c='Test', Ativo_Relacionado__c=B.ID, Ativo__c = true, Quantidade__c = 1);
        insert cl;     

}
    static testMethod void testAdder15() {
       	Asset X = New Asset(AccountId='0013100001kNhtUAAS',Name='TesteA', SerialNumber ='TesteB');
        insert X;
    
		Asset A = new Asset(Id='02i31000006fOSa',AccountId='0013100001kNhtUAAS',SerialNumber='TESTEX2',Name='TESTE1');
            
        Checklist_do_Ativo__c c1 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test1', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c2 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test2', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c3 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test3', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c4 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test4', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c5 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test5', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c6 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test6', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c7 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test7', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c8 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test8', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c9 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test9', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c10 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test10', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c11 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test11', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c12 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test12', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c13 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test13', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c14 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test14', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c15 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test15', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);

     		insert c1;
            insert c2;
            insert c3;
            insert c4;
            insert c5;
            insert c6;
            insert c7;
            insert c8;
            insert c9;
            insert c10;
            insert c11;
            insert c12;
            insert c13;
            insert c14;
            insert c15;

        Asset B = A.clone(false,true,false,false);
        insert B;
        
        Checklist_do_Ativo__c cl = new Checklist_do_Ativo__c(Nome_do_Item__c='Test', Ativo_Relacionado__c=B.ID, Ativo__c = true, Quantidade__c = 1);
        insert cl;     

}
    static testMethod void testAdder16() {
       	Asset X = New Asset(AccountId='0013100001kNhtUAAS',Name='TesteA', SerialNumber ='TesteB');
        insert X;
    
		Asset A = new Asset(Id='02i31000006fOSa',AccountId='0013100001kNhtUAAS',SerialNumber='TESTEX2',Name='TESTE1');
            
        Checklist_do_Ativo__c c1 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test1', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c2 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test2', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c3 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test3', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c4 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test4', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c5 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test5', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c6 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test6', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c7 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test7', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c8 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test8', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c9 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test9', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c10 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test10', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c11 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test11', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c12 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test12', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c13 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test13', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c14 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test14', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c15 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test15', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c16 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test16', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);

     		insert c1;
            insert c2;
            insert c3;
            insert c4;
            insert c5;
            insert c6;
            insert c7;
            insert c8;
            insert c9;
            insert c10;
            insert c11;
            insert c12;
            insert c13;
            insert c14;
            insert c15;
            insert c16;

        Asset B = A.clone(false,true,false,false);
        insert B;
        
        Checklist_do_Ativo__c cl = new Checklist_do_Ativo__c(Nome_do_Item__c='Test', Ativo_Relacionado__c=B.ID, Ativo__c = true, Quantidade__c = 1);
        insert cl;     

}
    static testMethod void testAdder17() {
       	Asset X = New Asset(AccountId='0013100001kNhtUAAS',Name='TesteA', SerialNumber ='TesteB');
        insert X;
    
		Asset A = new Asset(Id='02i31000006fOSa',AccountId='0013100001kNhtUAAS',SerialNumber='TESTEX2',Name='TESTE1');
            
        Checklist_do_Ativo__c c1 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test1', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c2 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test2', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c3 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test3', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c4 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test4', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c5 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test5', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c6 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test6', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c7 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test7', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c8 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test8', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c9 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test9', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c10 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test10', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c11 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test11', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c12 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test12', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c13 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test13', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c14 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test14', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c15 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test15', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c16 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test16', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c17 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test17', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);

     		insert c1;
            insert c2;
            insert c3;
            insert c4;
            insert c5;
            insert c6;
            insert c7;
            insert c8;
            insert c9;
            insert c10;
            insert c11;
            insert c12;
            insert c13;
            insert c14;
            insert c15;
            insert c16;
            insert c17;

        Asset B = A.clone(false,true,false,false);
        insert B;
        
        Checklist_do_Ativo__c cl = new Checklist_do_Ativo__c(Nome_do_Item__c='Test', Ativo_Relacionado__c=B.ID, Ativo__c = true, Quantidade__c = 1);
        insert cl;     

}
    static testMethod void testAdder18() {
       	Asset X = New Asset(AccountId='0013100001kNhtUAAS',Name='TesteA', SerialNumber ='TesteB');
        insert X;
    
		Asset A = new Asset(Id='02i31000006fOSa',AccountId='0013100001kNhtUAAS',SerialNumber='TESTEX2',Name='TESTE1');
            
        Checklist_do_Ativo__c c1 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test1', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c2 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test2', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c3 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test3', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c4 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test4', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c5 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test5', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c6 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test6', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c7 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test7', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c8 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test8', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c9 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test9', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c10 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test10', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c11 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test11', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c12 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test12', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c13 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test13', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c14 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test14', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c15 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test15', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c16 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test16', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c17 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test17', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c18 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test18', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);

     		insert c1;
            insert c2;
            insert c3;
            insert c4;
            insert c5;
            insert c6;
            insert c7;
            insert c8;
            insert c9;
            insert c10;
            insert c11;
            insert c12;
            insert c13;
            insert c14;
            insert c15;
            insert c16;
            insert c17;
            insert c18;

        Asset B = A.clone(false,true,false,false);
        insert B;
        
        Checklist_do_Ativo__c cl = new Checklist_do_Ativo__c(Nome_do_Item__c='Test', Ativo_Relacionado__c=B.ID, Ativo__c = true, Quantidade__c = 1);
        insert cl;     

}
    static testMethod void testAdder19() {
       	Asset X = New Asset(AccountId='0013100001kNhtUAAS',Name='TesteA', SerialNumber ='TesteB');
        insert X;
    
		Asset A = new Asset(Id='02i31000006fOSa',AccountId='0013100001kNhtUAAS',SerialNumber='TESTEX2',Name='TESTE1');
            
        Checklist_do_Ativo__c c1 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test1', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c2 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test2', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c3 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test3', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c4 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test4', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c5 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test5', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c6 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test6', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c7 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test7', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c8 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test8', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c9 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test9', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c10 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test10', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c11 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test11', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c12 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test12', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c13 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test13', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c14 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test14', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c15 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test15', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c16 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test16', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c17 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test17', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c18 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test18', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c19 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test19', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);

     		insert c1;
            insert c2;
            insert c3;
            insert c4;
            insert c5;
            insert c6;
            insert c7;
            insert c8;
            insert c9;
            insert c10;
            insert c11;
            insert c12;
            insert c13;
            insert c14;
            insert c15;
            insert c16;
            insert c17;
            insert c18;
            insert c19;

        Asset B = A.clone(false,true,false,false);
        insert B;
        
        Checklist_do_Ativo__c cl = new Checklist_do_Ativo__c(Nome_do_Item__c='Test', Ativo_Relacionado__c=B.ID, Ativo__c = true, Quantidade__c = 1);
        insert cl;     

}
    static testMethod void testAdder20() {
       	Asset X = New Asset(AccountId='0013100001kNhtUAAS',Name='TesteA', SerialNumber ='TesteB');
        insert X;
    
		Asset A = new Asset(Id='02i31000006fOSa',AccountId='0013100001kNhtUAAS',SerialNumber='TESTEX2',Name='TESTE1');
            
        Checklist_do_Ativo__c c1 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test1', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c2 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test2', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c3 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test3', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c4 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test4', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c5 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test5', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c6 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test6', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c7 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test7', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c8 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test8', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c9 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test9', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c10 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test10', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c11 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test11', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c12 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test12', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c13 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test13', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c14 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test14', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c15 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test15', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c16 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test16', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c17 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test17', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c18 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test18', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c19 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test19', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);
        Checklist_do_Ativo__c c20 = new Checklist_do_Ativo__c(Nome_do_Item__c='Test20', Ativo_Relacionado__c=A.ID, Ativo__c = true, Quantidade__c = 1);

     		insert c1;
            insert c2;
            insert c3;
            insert c4;
            insert c5;
            insert c6;
            insert c7;
            insert c8;
            insert c9;
            insert c10;
            insert c11;
            insert c12;
            insert c13;
            insert c14;
            insert c15;
            insert c16;
            insert c17;
            insert c18;
            insert c19;
            insert c20;

        Asset B = A.clone(false,true,false,false);
        insert B;
        
        Checklist_do_Ativo__c cl = new Checklist_do_Ativo__c(Nome_do_Item__c='Test', Ativo_Relacionado__c=B.ID, Ativo__c = true, Quantidade__c = 1);
        insert cl;     

} 
}