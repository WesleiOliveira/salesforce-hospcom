@isTest(seeAllData=true)
public class NotaValidacaoTest {
    @isTest public static void teste(){
        test.startTest();
        Nota_fiscal_de_pedido_de_compra__c nfc = new Nota_fiscal_de_pedido_de_compra__c(Name = '111', 
                                                                                        Pedido_de_compra__c = 'a1b6e000006hXP7AAM', 
                                                                                        Valor_da_nota__c = 100, 
                                                                                        Data_de_emissao__c = date.parse('11/02/2023'));
        try{
            insert nfc;
        }
        catch(DmlException e){
            
        }
        test.stopTest();
        
    }
    @isTest public static void teste2(){
        test.startTest();
        Nota_fiscal_de_pedido_de_compra__c nfc = new Nota_fiscal_de_pedido_de_compra__c(Name = '62151',
                                                                                        Pedido_de_compra__c = 'a1b6e000006hXP7AAM', 
                                                                                        Valor_da_nota__c = 100, 
                                                                                        Data_de_emissao__c = SYSTEM.TODAY());
        try{
            insert nfc;
        }
        catch(DmlException e){
            
        }
        test.stopTest();
        
    }
}