@isTest
public class CompromissoValidacaoTest {
@isTest
    static void teste() {
        // Criação de um novo compromisso
        Event compromisso = new Event();
		compromisso.OwnerID = '005i0000005d2fF';
        compromisso.WhatId = '0016e00003FBzFG';
        compromisso.StartDateTime = system.now();
        
        // Chama o método de criação de compromisso
        Test.startTest();
        try{
            insert compromisso;
        }
        catch(DmlException e){}
        Test.stopTest();
    }
}