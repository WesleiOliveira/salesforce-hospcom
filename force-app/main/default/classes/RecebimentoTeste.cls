@isTest(seeAllData=true)
private class RecebimentoTeste {
	   
    @isTest static void Teste1(){ 
		Recebimentos__c recebimento = new Recebimentos__c(
			NF_Representacao__c	 = 'a085A00001lcyqO', // prod:a085A00001lcyqO test:a085A00001lcXyS
			Nota_Fiscal1__c = 'a085A00001lcyqT', 	  // prod:a085A00001lcyqT test:a085A00001lcXyh
			Data_do_Recebimento__c = System.Today(),
			Valor_Recebido__c = 100,
			Valor_Desconto__c = 0,
			Valor_Acrescimo__c = 0,
			Valor_Comissao__c = 10,
			RecordTypeId = '0125A000001YZgJQAW'
		);
		insert recebimento;
		
		recebimento.NF_Representacao__c = 'a085A00001lcXyS'; // xxx prod:a085A00001lcXyS test:a081g000001jPpw
		update recebimento;

		delete recebimento;
    }
	
    @isTest static void Teste2(){ 
		Recebimentos__c recebimento = new Recebimentos__c(
			//NF_Representacao__c	 = 'a085A00001lcyqO', // prod:a085A00001lcyqO test:a085A00001lcXyS
			Nota_Fiscal1__c = 'a085A00001lcyqT', 	  // prod:a085A00001lcyqT test:a085A00001lcXyh
			Data_do_Recebimento__c = System.Today(),
			Valor_Recebido__c = 100,
			Valor_Desconto__c = 0,
			Valor_Acrescimo__c = 0,
			Valor_Comissao__c = 10,
			RecordTypeId = '0125A000001YZgJQAW'
		);
		insert recebimento;
		
		recebimento.NF_Representacao__c = 'a085A00001lcXyS'; // xxx prod:a085A00001lcXyS test:a081g000001jPpw
		update recebimento;

		delete recebimento;
    }
	
    @isTest static void Teste3(){ 
		Recebimentos__c recebimento = new Recebimentos__c(
			NF_Representacao__c	 = 'a085A00001lcyqO', // prod:a085A00001lcyqO test:a085A00001lcXyS
			Nota_Fiscal1__c = 'a085A00001lcyqT', 	  // prod:a085A00001lcyqT test:a085A00001lcXyh
			Data_do_Recebimento__c = System.Today(),
			Valor_Recebido__c = 100,
			Valor_Desconto__c = 0,
			Valor_Acrescimo__c = 0,
			Valor_Comissao__c = 10,
			RecordTypeId = '0125A000001YZgJQAW'
		);
		insert recebimento;
		
		recebimento.NF_Representacao__c = null; // xxx prod:a085A00001lcXyS test:a081g000001jPpw
		update recebimento;

		delete recebimento;
    }
	
    @isTest static void Teste4(){ 
		Recebimentos__c recebimento = new Recebimentos__c(
			NF_Representacao__c	 = 'a085A00001lcyqO', // prod:a085A00001lcyqO test:a085A00001lcXyS
			Nota_Fiscal1__c = 'a085A00001lcyqT', 	  // prod:a085A00001lcyqT test:a085A00001lcXyh
			Data_do_Recebimento__c = System.Today(),
			Valor_Recebido__c = 100,
			Valor_Desconto__c = 0,
			Valor_Acrescimo__c = 0,
			Valor_Comissao__c = 10,
			RecordTypeId = '0125A000001YZgJQAW'
		);
		insert recebimento;
		
		recebimento.Valor_Recebido__c = 200;
		update recebimento;

		delete recebimento;
    }
	
    @isTest static void Teste5(){ 
		Recebimentos__c recebimento = new Recebimentos__c(
			NF_Representacao__c	 = 'a085A00001lcyqO', // prod:a085A00001lcyqO test:a085A00001lcXyS
			Nota_Fiscal1__c = 'a085A00001lcyqT', 	  // prod:a085A00001lcyqT test:a085A00001lcXyh
			Data_do_Recebimento__c = System.Today(),
			Valor_Recebido__c = 100,
			Valor_Desconto__c = 0,
			Valor_Acrescimo__c = 0,
			Valor_Comissao__c = 10,
			RecordTypeId = '0125A000001YZgJQAW'
		);
		insert recebimento;
		
		recebimento.Valor_Comissao__c = 50;
		update recebimento;

		delete recebimento;
    }
	
}