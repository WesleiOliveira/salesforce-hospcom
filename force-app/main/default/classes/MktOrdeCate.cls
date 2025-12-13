public with sharing class MktOrdeCate{
    
    Public String				        mensagem            {get;set;}
    Public String 						objNome				{get;set;}
    Public Id							objId				{get;set;}
    Public MktCategoria__c              categoria           {get;set;}
    Public List<MktCategoria__c>		listaCategoria   	{get;set;}
    Public List<MktParte__c>		    listaParte   	    {get;set;}
    Public Boolean                      temListaCategoria   {get;set;}
    Public Boolean                      temListaParte       {get;set;}
	
    Public String					    stringFilhaNova		{get;set;}
    Public List<String>					listaFilhaNova		{get;set;}
    
    public MktOrdeCate(ApexPages.StandardController controller) {
        Inicializa(controller);
        BuscaCategorias();
		BuscaPartes();
	}

    public void Inicializa(ApexPages.StandardController controller){
		temListaCategoria = false;
		temListaParte = false;
        objNome = controller.getRecord().Id.getSObjectType().getDescribe().getName();
        if(objNome == 'MktCategoria__c'){
            categoria 		= (MktCategoria__c)controller.getRecord(); 
            objId 			= categoria.Id;
        }
        mensagem            = '';
        stringFilhaNova      = '';
    }
    
    public void BuscaCategorias(){
        listaCategoria = [
            SELECT   Id, name, Ordem__c
            FROM     MktCategoria__c
            WHERE    Categoria_Pai__c 	= :objId
            ORDER BY Ordem__c ASC, Name ASC
        ];
        temListaCategoria = (listaCategoria.size() > 0 ? true : false);
    }
        
    public void BuscaPartes(){
        listaParte = [
            SELECT   Id, Nome__c, Modelo__c, Ordem__c, Parte__r.Tipo_do_Produto__c, Parte__r.StockKeepingUnit, Parte__r.ProductCode	
            FROM     MktParte__c
            WHERE    Categoria__c = :objId
            ORDER BY Ordem__c ASC, Name ASC
        ];
        temlistaParte = (listaParte.size() > 0 ? true : false);
    }
    
    public void SalvarOrdem(){
        listaFilhaNova = stringFilhaNova.split('\\,');
		System.Debug(LoggingLevel.INFO,'listaFilhaNova: '+listaFilhaNova);
        if(temListaCategoria){
            for(integer cont=0; cont<listaFilhaNova.size(); cont++)
            	for(MktCategoria__c categoria : listaCategoria){
                    if(listaFilhaNova[cont] == String.valueOf(categoria.Id))
                    	categoria.Ordem__c = cont+1;
				}
            for(MktCategoria__c categoria2 : listaCategoria)
				if(!listaFilhaNova.contains(categoria2.Id))
					categoria2.Ordem__c = null;
            update listaCategoria;
            BuscaCategorias();			
        }
        else if(temlistaParte){
            for(integer cont=0; cont<listaFilhaNova.size(); cont++)
            	for(MktParte__c parte : listaParte){
                    if(listaFilhaNova[cont] == String.valueOf(parte.Id))
                    	parte.Ordem__c = cont+1;
				}
            for(MktParte__c parte2 : listaParte)
				if(!listaFilhaNova.contains(parte2.Id))
					parte2.Ordem__c = null;
            update ListaParte;
            BuscaPartes();
        }
        mensagem = 'sucesso';
    }
    
}