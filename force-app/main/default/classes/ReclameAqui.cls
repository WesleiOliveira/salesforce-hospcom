public with sharing class ReclameAqui {

    public  String Nome					{get;set;}
    public  String Empresa				{get;set;}
    public  String Email				{get;set;}
    public  String Telefone				{get;set;}
    public  String Assunto				{get;set;}
    public  String Categoria			{get;set;}
    public  String Descricao			{get;set;}
	
    public 	String 	Mensagem			{get;set;}
    public 	String  Cor					{get;set;}
    
    public ReclameAqui(){
        Mensagem = '';
    }
    
    public void Salvar(){
        
        if(Nome=='' || (Email=='' && Telefone=='') || Descricao == ''){
            Mensagem = 'Os seguintes campos são obrigatórios: Nome, Email ou Telefone, e Descrição';
            Cor = 'danger';
        }
        else{
            Registro_de_Servi_o_2__c registro = new Registro_de_Servi_o_2__c(
                RecordTypeId = '0125A000001cljXQAQ',
                Tipo_do_Documento__c = 'a0z5A0000094SeGQAU',            
                Descri_o__c = 	(Nome!='' 	 	? 'NOME: '+Nome : '') +
                                (Empresa!='' 	? '\nEMPRESA: '+Empresa : '') +
                                (Email!='' 	 	? '\nEMAIL: '+Email : '') +
                                (Telefone!=''  	? '\nTELEFONE: '+Telefone : '') +
                                (Assunto!='' 	? '\nASSUNTO: '+Assunto : '') +
                                (Categoria!='' 	? '\nCATEGORIA: '+Categoria : '') +
                                (Descricao!=''	? '\nDESCRIÇÃO: '+Descricao : '')
            );
            insert registro;
            Mensagem = 'Registro inserido com sucesso! Agradecemos seu feedback.';
            Cor = 'success';
        }
            
    }
}