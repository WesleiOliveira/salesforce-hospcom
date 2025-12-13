public with sharing class BuscaCandidato {
    public List<Recrutamento__c> Records{get;set;}
    public String pesquisa {get;set;}
    public String status {get;set;}
    public String searchKey {get;set;}
    public BuscaCandidato() {
    }
    public void search(){
        if (status != null){
        string searchquery='select Id, Name, Nome_do_Candidato__c, Nome_Completo__c, Sobrenome__c, Imagem_del__c, Telefone_do_Candidato__c, Idade__c, Status__c,  Vaga_Dispon_vel__r.Cargo_Ofertado__c FROM Recrutamento__c WHERE (Vaga_Dispon_vel__r.Cargo_Ofertado__c like \'%'+searchKey+'%\'and Nome_Completo__c like \'%'+pesquisa+'%\') and Status__c =:status ORDER BY Name';
            Records = Database.query(searchquery);
        }
        else {
            string searchquery='select Id, Name, Nome_do_Candidato__c, Sobrenome__c, Nome_Completo__c, Imagem_del__c, Telefone_do_Candidato__c, Idade__c, Status__c, Vaga_Dispon_vel__r.Cargo_Ofertado__c FROM Recrutamento__c WHERE (Vaga_Dispon_vel__r.Cargo_Ofertado__c like \'%'+searchKey+'%\'and Nome_Completo__c like \'%'+pesquisa+'%\') ORDER BY Name';
            Records = Database.query(searchquery); 
        }
      }
     public void clear(){
         if (Records != null) {Records.clear();
         status = null;
         searchKey = null;
	     pesquisa = null;
         }                  
         else{ 
         status = null;
         searchKey = null;
         pesquisa = null;
         }
     }
     public void alfabetica(){
        string searchquery= + 'ORDER BY Nome_do_Candidato__c';
            }
}