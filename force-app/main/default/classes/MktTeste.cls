@isTest(SeeAllData=true)
public class MktTeste { 
	
    static testMethod void MktTesteVazio(){ 
        test.startTest();
            PageReference pageRef = Page.MktMenu;
        	Test.setCurrentPageReference(pageRef);
            pageRef.getParameters().put('Id', '');
        	MktFluxo fluxo = new MktFluxo();
        test.stopTest();
    }
    
    static testMethod void MktTesteMarca(){ 
        test.startTest();
            PageReference pageRef = Page.MktMenu;
        	Test.setCurrentPageReference(pageRef);
            pageRef.getParameters().put('Id', '01J5A00000QEX28'); // a1M0q000000BUdT a1S5A00000xFQCc
        	MktFluxo fluxo = new MktFluxo();
        test.stopTest();
    }

    static testMethod void MktTesteCategoria(){ 
        test.startTest();
            PageReference pageRef = Page.MktMenu;
        	Test.setCurrentPageReference(pageRef);
            pageRef.getParameters().put('Id', 'a1R5A000005Hegy'); // a1N0q000000IouZ a1R5A000005Hegy
        	MktFluxo fluxo = new MktFluxo();
        test.stopTest();
    }


    static testMethod void MktTesteSubCategoria(){ 
        test.startTest();
            PageReference pageRef = Page.MktMenu;
        	Test.setCurrentPageReference(pageRef);
            pageRef.getParameters().put('Id', 'a1R5A000005MNP1'); // a1N0q000000Ioue a1R5A000005Heh8
        	MktFluxo fluxo = new MktFluxo();
        test.stopTest();
    }

    static testMethod void MktTesteProduto(){ 
        test.startTest();
            PageReference pageRef = Page.MktMenu;
        	Test.setCurrentPageReference(pageRef);
            pageRef.getParameters().put('Id', '01t5A000008KobIQAS'); // a1O0q000000AqSk a1U5A000008BrfB
        	MktFluxo fluxo = new MktFluxo();
        test.stopTest();
    }
        
}