@isTest(SeeAllData=true)
public class EvitaDuplicarAtivoTeste {
    
    static testMethod void teste_1(){ 
        
        Asset ativo = new Asset(
            ACCOUNTID = Id.valueOf('0013100001roa96AAA') ,
            NAME = 'MACRO CENTRÍFUGA' ,
            SERIALNUMBER = 'SN0001' ,
            ID_Tag__c = 'ID0001',
            patrimonio__c = 'PT0001',
            STATUS = 'OPERACIONAL' ,
            RECORDTYPEID = Id.valueOf('01231000000tbAWAAY') ,
            MARCA__C = 'FANEM' ,
            TIPO_DE_AQUISI_O__C = 'PRÓPRIA' ,
            MODELO__C = '206 BL'
        );
        
        test.startTest();
        
        insert ativo;
        
        ativo.SERIALNUMBER = 'SN0002';
        update ativo;
         
        ativo.ID_Tag__c = 'ID0002';
        update ativo;
        
        ativo.patrimonio__c = 'PT0002';
        update ativo;
         
        test.stopTest();
    }
    
    
}