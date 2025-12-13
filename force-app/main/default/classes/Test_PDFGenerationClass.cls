@isTest
private class Test_PDFGenerationClass {
	static testMethod void Test_PDFGen() {
		test.startTest();
        //Opportunity Opp = new Opportunity();
        //Opp = [SELECT Id FROM Opportunity LIMIT 1];
		//PDFGenerationClass.GenerateCustomPDFAndEmail(Opp.Id);
		PDFGenerationClass.GenerateCustomPDFAndEmail(Id.valueOf('0065A00000hbfo1QAA'));
		test.stopTest();
    }
}