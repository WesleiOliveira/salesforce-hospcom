@isTest(seeAllData=true)
public class LinkPropostaTest {
    @isTest static void teste1(){
        Quote cot = [SELECT Id, Forma_de_pagamento__c FROM Quote WHERE ID = '0Q06e00000407WACAY'];
        cot.Forma_de_pagamento__c = 'Pix';
        update cot;
    } 
}