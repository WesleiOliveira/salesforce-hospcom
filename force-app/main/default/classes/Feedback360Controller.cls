public with sharing class Feedback360Controller {
    public  String Email				{get;set;}
    public  String Assunto				{get;set;}
    public  String Tipo					{get;set;}
    public  String Descricao			{get;set;}
	
    public 	String 	Mensagem			{get;set;}
    public 	String  Cor					{get;set;}
    
    public Feedback360Controller(){
        Mensagem = '';
    }
    
    public void Salvar(){
        
        if(Assunto =='' || Descricao == '' || Tipo == null){
            Mensagem = 'Os seguintes campos são obrigatórios: Assunto, Tipo e Descrição';
            Cor = 'danger';	
        }
        else{
            Feedback_360__c registro = new Feedback_360__c(
                Name = assunto,
                Tipo__c = tipo,
                Descricao__c = 	descricao,
                Email__c = email
            );
            insert registro;
            Mensagem = 'Registro inserido com sucesso! Agradecemos seu feedback.';
            Cor = 'success';
        }           
    }
}