trigger NotaGlobal on Note (before insert, before update) {
    
	Trigger.new[0].isPrivate = false;   
    
}