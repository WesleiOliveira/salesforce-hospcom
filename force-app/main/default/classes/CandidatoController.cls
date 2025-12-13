public with sharing class CandidatoController {
    public  String Cargo				{get;set;}
    public  String Nome					{get;set;}
    public  String Sobrenome			{get;set;}
    public  String Email				{get;set;}
    public  date dataNasc				{get;set;}
    public  String telefone				{get;set;}
    public  String CPF					{get;set;}
    public  String Endereco				{get;set;}
    public  String RG					{get;set;}
    public  String Grau					{get;set;}
    public  String Form					{get;set;}
    public  String Ult					{get;set;}
    public  String Exp					{get;set;}
    public  String estadoCivil			{get;set;}
    public ID recId						{get;set;}
    public String tipoSanguineo			{get;set;}
    public String corRaca				{get;set;}
    public String telefoneEmergencia	{get;set;}
    public String Nacionalidade			{get;set;}
    Public Attachment myfile;
Public Attachment getmyfile()
    {
        myfile = new Attachment();
        return myfile;
    }    
    
    public  Boolean Empreg				{get;set;}
	
    public 	String 	Mensagem			{get;set;}
    public 	String  Cor					{get;set;}
    
    public CandidatoController(){
        
        Mensagem = '';
    }
    
    public void Salvar(){
        
        if(Sobrenome == '' || Nome == '' || CPF == '' || Telefone == '' || Email == '' || Ult == '' || Exp == ''){
            String error = 'Os seguintes campos são obrigatórios: Nome, Sobrenome, CPF, Telefone, Email, Experiência Profissional, Última Experiência.';
			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, error);
            ApexPages.addMessage(myMsg);
        }
        else{
            Recrutamento__c registro = new Recrutamento__c(
                Cargo_Pretendido__c = Cargo,
                Nome_do_candidato__c = Nome,
                Sobrenome__c = Sobrenome,
                Data_de_nascimento__c = dataNasc,
                Telefone_do_Candidato__c = telefone,
                CPF_do_Candidato__c = CPF,
                Endere_o_do_Candidato__c = Endereco,
                RG__c = RG,
                E_mail_do_Candidato__c = Email,
                Grau_de_Escolaridade__c = Grau,
                Atualmente_Empregado__c = Empreg,
                Forma_o_Acad_mica__c = Form,
                ltima_Experi_ncia__c = Ult,
                Tipo_Sanguineo__c = tipoSanguineo,
                Experi_ncia_Profisisonal__c = Exp,
                Estado_civil__c = estadoCivil,
                Cor_Raca__c = corRaca,
                Telefone_emergencia__c = telefoneEmergencia,
                Nacionalidade__c = Nacionalidade
            );
            
            try{insert registro;
               Mensagem = 'Registro inserido com sucesso! Agradecemos sua candidatura.';
               Cor = 'success';
               recId = registro.Id;
               }
			catch(System.DMLException e){ApexPages.addMessages(e);}
        
        }
    }
    Public Pagereference Savedoc()
    {

        Attachment a = new Attachment(parentId = recId, name=myfile.name, body = myfile.body);
         
         /* insert the attachment */
         insert a;
        return NULL;
    }   
}