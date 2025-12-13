public with sharing class opp_alt_user{
    public 	String				url_base {get;set;}
    public 	String				url_prefixo {get;set;}
    
    public Opportunity 			oportunidade {get;set;}
    public List<User>			usuarios {get;set;}
    public User					usuario {get;set;}
    public List<SelectOption> 	opcoes {get;set;} 
    public Id 					opcao {get;set;} 

    public opp_alt_user(ApexPages.StandardController controller) {
        url_base = URL.getSalesforceBaseUrl().toExternalForm() + Site.getPathPrefix();
        url_prefixo = Site.getPathPrefix();
        
        oportunidade = (Opportunity)controller.getRecord();
        usuarios = new List<User>();
        usuario = new User();
        opcoes = new List<SelectOption>();
        
        List<User> usuarios = [
            SELECT 	Id, Name, UserType, IsActive
            FROM 	User
            WHERE 	IsActive = true 	AND 
            		UserType IN ('PowerPartner', 'Standard') 
            ORDER BY Name ASC
        ];  
        
        if(usuarios.size()>0){
            for(User usu1 : usuarios){
                String usuTipo;
                if (usu1.UserType == 'PowerPartner')
                    usuTipo = '';
                else
                    usuTipo = '*';
                opcoes.add(new SelectOption(usu1.Id, usu1.Name + usuTipo));
            }
        }
	}
    
    public PageReference opp_save_user(){
        oportunidade.OwnerId = opcao;
        update oportunidade;
        return new PageReference('/' + String.valueOf(oportunidade.Id));
    }
}