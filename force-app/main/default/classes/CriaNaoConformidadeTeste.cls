@isTest
public class CriaNaoConformidadeTeste {
    
    static testMethod void testMethod1() {
        // Lógica de teste aqui
        Auditoria__c aud = new Auditoria__c();
   //------------   não conformidade  2  --------------------

//------------   não conformidade  77  --------------------
aud.x77__c = true;
//------------   não conformidade  78  --------------------
aud.x78__c = true;
//------------   não conformidade  79  --------------------
aud.x79__c = true;
//------------   não conformidade  80  --------------------
aud.x80__c = true;
//------------   não conformidade  81  --------------------
aud.x81__c = true;
//------------   não conformidade  82  --------------------
aud.x82__c = true;
//------------   não conformidade  83  --------------------
aud.x83__c = true;
//------------   não conformidade  84  --------------------
aud.x84__c = true;
//------------   não conformidade  85  --------------------
aud.x85__c = true;
//------------   não conformidade  86  --------------------
aud.x86__c = true;
//------------   não conformidade  87  --------------------
aud.x87__c = true;
//------------   não conformidade  88  --------------------
aud.x88__c = true;
//------------   não conformidade  89  --------------------
aud.x89__c = true;
//------------   não conformidade  90  --------------------
aud.x90__c = true;
//------------   não conformidade  91  --------------------
aud.x91__c = true;
//------------   não conformidade  92  --------------------
aud.x92__c = true;
//------------   não conformidade  93  --------------------
aud.x93__c = true;
//------------   não conformidade  94  --------------------
aud.x94__c = true;
//------------   não conformidade  95  --------------------
aud.x95__c = true;
//------------   não conformidade  96  --------------------
aud.x96__c = true;
//------------   não conformidade  97  --------------------
aud.x97__c = true;
//------------   não conformidade  98  --------------------
aud.x98__c = true;
//------------   não conformidade  99  --------------------
aud.x99__c = true;
//------------   não conformidade  100  --------------------
aud.x100__c = true;
//------------   não conformidade  101  --------------------
aud.x101__c = true;
//------------   não conformidade  102  --------------------
aud.x102__c = true;
//------------   não conformidade  103  --------------------
aud.x103__c = true;
//------------   não conformidade  104  --------------------
aud.x104__c = true;
//------------   não conformidade  105  --------------------
aud.x105__c = true;
//------------   não conformidade  106  --------------------
aud.x106__c = true;
//------------   não conformidade  107  --------------------
aud.x107__c = true;
//------------   não conformidade  108  --------------------
aud.x108__c = true;
//------------   não conformidade  109  --------------------
aud.x109__c = true;
//------------   não conformidade  110  --------------------
aud.x110__c = true;
//------------   não conformidade  111  --------------------
aud.x111__c = true;
//------------   não conformidade  112  --------------------
aud.x112__c = true;
//------------   não conformidade  113  --------------------
aud.x113__c = true;
//------------   não conformidade  114  --------------------
aud.x114__c = true;
//------------   não conformidade  115  --------------------
aud.x115__c = true;
//------------   não conformidade  116  --------------------
aud.x116__c = true;
//------------   não conformidade  117  --------------------
aud.x117__c = true;
//------------   não conformidade  118  --------------------
aud.x118__c = true;
//------------   não conformidade  119  --------------------
aud.x119__c = true;
//------------   não conformidade  120  --------------------
aud.x120__c = true;
//------------   não conformidade  121  --------------------
aud.x121__c = true;
//------------   não conformidade  122  --------------------
aud.x122__c = true;
//------------   não conformidade  123  --------------------
aud.x123__c = true;
//------------   não conformidade  124  --------------------
aud.x124__c = true;
//------------   não conformidade  125  --------------------
aud.x125__c = true;
//------------   não conformidade  126  --------------------
aud.x126__c = true;
//------------   não conformidade  127  --------------------
aud.x127__c = true;
//------------   não conformidade  128  --------------------
aud.x128__c = true;
//------------   não conformidade  129  --------------------
aud.x129__c = true;
//------------   não conformidade  130  --------------------
aud.x130__c = true;
//------------   não conformidade  131  --------------------
aud.x131__c = true;
//------------   não conformidade  132  --------------------
aud.x132__c = true;
//------------   não conformidade  133  --------------------
aud.x133__c = true;
//------------   não conformidade  134  --------------------
aud.x134__c = true;
//------------   não conformidade  135  --------------------
aud.x135__c = true;
//------------   não conformidade  136  --------------------
aud.x136__c = true;
//------------   não conformidade  137  --------------------
aud.x137__c = true;
//------------   não conformidade  138  --------------------
aud.x138__c = true;
//------------   não conformidade  139  --------------------
aud.x139__c = true;
//------------   não conformidade  140  --------------------
aud.x140__c = true;
//------------   não conformidade  141  --------------------
aud.x141__c = true;
//------------   não conformidade  142  --------------------
aud.x142__c = true;
//------------   não conformidade  143  --------------------
aud.x143__c = true;
//------------   não conformidade  144  --------------------

        insert aud;
        
        aud.Status__c = 'CONCLUIDO';
        
        try{
        update aud; 
        }catch(Exception e ){
            system.debug('Error' + e );
        }
        
        
        
        
        
    }
}