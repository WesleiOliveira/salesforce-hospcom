@isTest
public with sharing class updateAttachTest{

	public 	Attachment 	file 		{ set; get; }
    public Recrutamento__c id       { set; get; }
	public 	Boolean 	hasPicture 	{ set; get; }
	private String		parentId 	{ set; get; }
	
	/**
	* Constructor
	*/
   	public updateAttachTest( ApexPages.StandardController stdController ){
		
       	this.parentId 		= String.escapeSingleQuotes(stdController.getId());
       	this.hasPicture 	= false;
        
        List<Recrutamento__c> rec =[select Id, AttachmentId__c 
                                    from Recrutamento__c 
                                    Where Id='a105A00000Ioz0sQAB'];
       	       	
       	List<Attachment> attList = [ Select ParentId, Name, Id, ContentType, BodyLength 
       									From Attachment 
       									where ParentId =: this.parentId and name = 'Contact Picture' limit 1];
                
       	if( attList.size() > 0 ){
       		this.file 		= attList.get( 0 );
       		this.file.Body 	= Blob.valueOf('AuxString');
       		this.hasPicture = true;
       	}
   	}
    
	public static testMethod void pictureAndUploadOther(){
		
	    TestUtilities tu = TestUtilities.generateTest();
	    
	    Test.startTest();
		ApexPages.StandardController sc = new ApexPages.StandardController( tu.aContac );
        
		tu.aAttachment.ParentId = 'a105A00000Ioz0sQAB';
		tu.aAttachment.name = 'Contact Picture';
		insert tu.aAttachment;
        
        //Replace
        tu.aAttachment.Body = Blob.valueOf('String Othe value');
        update tu.aAttachment;
        ShowPicture cTest = new ShowPicture( sc );
          
        
	    Test.stopTest();
	}
}