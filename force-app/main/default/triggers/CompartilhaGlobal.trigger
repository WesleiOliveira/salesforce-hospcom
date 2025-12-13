trigger CompartilhaGlobal on ContentDocumentLink (before insert) {
    
    //String IdStr	=	String.valueOf(Trigger.new[0].LinkedEntityId);
    //String Prefix 	= 	IdStr.substring(0,3);
    
    // 005 = USERS
    // 058 = CONTENTWORKSPACE
    // 069 = CONTENTDOCUMENT "PACKS"
    
    //if((Prefix != '005') && (Prefix != '058') && (Prefix != '069')){
		
    //}
	
    for(integer cont = 0;  cont < Trigger.new.size(); cont++){
    	Trigger.new[cont].Visibility = 'AllUsers';    
    }
    
    
}