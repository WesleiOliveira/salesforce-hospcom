@isTest(SeeAllData=true)
private class NotaGlobalTeste { 
    static testMethod void teste_geral(){ 
        test.startTest();    
        
        Note nota = new note(
            ParentId = Id.valueOf('0065A00000hbfo1QAA'),
            Title = 'titulo',
            IsPrivate = true,
            Body = 'corpo',
            OwnerId =  Id.valueOf('00531000006UzZsAAK')
        );
        insert nota;

		test.stopTest();
    }
}