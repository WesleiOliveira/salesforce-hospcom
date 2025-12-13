public with sharing class MktFluxo {

    Public Id                           navegacaoId         {get;set;}
    Public String                       navegacaoObjeto     {get;set;}
    
    Public String                       quebraLinha         {get;set;}
    Public String                       urlBase             {get;set;}
    Public List<Navegacao>              navegacoes          {get;set;} 
    Public Integer                      navegacaoQtd        {get;set;}  
    
    Public List<MktCategoria__c>        listaCategoria      {get;set;}
    Public List<MktMidia__c>            listaMidia          {get;set;}
    Public List<MktParte__c>            listaParte          {get;set;}
    Public List<Map<String, String>>    listaMidiaTipo      {get;set;}
    Public List<Map<String, String>>    listaParteTipo      {get;set;}
    Public List<Visualizacao>           listaVisualizacao   {get;set;}
    Public Boolean                      temListaCategoria   {get;set;}
    Public Boolean                      temListaMidia       {get;set;}
    Public Boolean                      temListaParte       {get;set;}
    
    public MktFluxo(){
        Inicializa();
        PopulaNavegacao();
        PopulaObjeto();
        PopulaMidia();
        PopulaParte();
    }
    
    public void Inicializa(){
        quebraLinha         = '</div><div class=\"row\">';
        urlBase             = URL.getSalesforceBaseUrl().toExternalForm() + Site.getPathPrefix();
        navegacaoId         = (System.currentPageReference().getParameters().containsKey('Id') && System.currentPageReference().getParameters().get('Id') != '') 
                            ? System.currentPageReference().getParameters().get('Id') : null;
        navegacaoObjeto     = (navegacaoId == null) ? 'MktInicio' : navegacaoId.getSObjectType().getDescribe().getName();
        navegacoes          = new List<Navegacao>();
        listaCategoria      = new List<MktCategoria__c>();
        listaMidia          = new List<MktMidia__c>();  
        listaParte          = new List<MktParte__c>();  
        listaMidiaTipo      = new List<Map<String, String>>();
        listaParteTipo      = new List<Map<String, String>>();
        listaVisualizacao   = new List<Visualizacao>();
        temListaCategoria   = false;
        temListaMidia       = false;
        temListaParte       = false;
    }
    
    public void PopulaNavegacao(){
        if(navegacaoObjeto == 'MktInicio'){
            navegacoes.add(new Navegacao(null, 'Home', ''));
        }
        else if(navegacaoObjeto == 'MktCategoria__c'){
            List<Navegacao>     lista_cat       = new List<Navegacao>();
            List<Navegacao>     lista_cat_inv   = new List<Navegacao>();
            MktCategoria__c     categoria       = new MktCategoria__c();

            categoria = [
                SELECT  Id, Name, Icone_url__c, Categoria_Pai__c
                FROM    MktCategoria__c
                WHERE   Id = :navegacaoId
            ];
            lista_cat.add(new Navegacao(categoria.Id, categoria.Name, categoria.Icone_url__c));
            
            while(categoria.Categoria_Pai__c != null){
                categoria = [
                    SELECT  Id, Name, Icone_url__c, Categoria_Pai__c
                    FROM    MktCategoria__c
                    Where   Id = :categoria.Categoria_Pai__c
                ];
                lista_cat.add(new Navegacao(categoria.Id, categoria.Name, categoria.Icone_url__c));
            }
            
            for(Integer cont = lista_cat.size()-1; cont >= 0; cont--)
                lista_cat_inv.add(lista_cat[cont]);
                  
            navegacoes.add(new Navegacao(null, 'Home', ''));
            navegacoes.addAll(lista_cat_inv);
        }      
        navegacaoQtd = navegacoes.size();
    }

    public void PopulaObjeto(){
        if(navegacaoObjeto == 'MktInicio'){
            listaCategoria = [
                SELECT      Id, Name, Icone_url__c
                FROM        MktCategoria__c
                WHERE       Ativo__c = true AND Categoria_pai__c = null
                ORDER BY    Name ASC
            ];
            temListaCategoria = (listaCategoria.size() > 0 ? true : false);
        }
        else if(navegacaoObjeto == 'MktCategoria__c'){
            listaCategoria = [
                SELECT      Id, Name, Icone_url__c
                FROM        MktCategoria__c
                WHERE       Categoria_Pai__c = :navegacaoId AND
                            Ativo__c = true
                ORDER BY    Ordem__c ASC NULLS LAST
            ];
            temListaCategoria = (listaCategoria.size() > 0 ? true : false);
        }
    }
    
    public void PopulaMidia(){
        
        // popula mídias ----
        if(navegacaoObjeto == 'MktCategoria__c'){
            listaMidia = [
                SELECT      Id, Name, Icone_url__c, Tipo__c, URL_do_Arquivo__c, DownloadId__c, Tamanho__c, Formato__c, CreatedDate 
                FROM        MktMidia__c
                WHERE       Categoria__c = :navegacaoId AND
                            Ativo__c = true
                ORDER BY    Tipo__c, Name
            ];
        }
        
        temListaMidia = (listaMidia.size() > 0 ? true : false);
        
        // popula tipos/qtds ----
        if(listaMidia.size() > 0){
            String  midiaTipo = '';
            Integer midiaTipoQtd = 0;
            for(Integer cont = 0; cont < listaMidia.size(); cont++){
                if((midiaTipo != listaMidia[cont].Tipo__c) && (midiaTipoQtd != 0)){
                    listaMidiaTipo.add(new Map<String, String>{'tipo'=> midiaTipo, 'qtd'=> String.valueOf(midiaTipoQtd)});
                    midiaTipoQtd = 0;
                }
                midiaTipo = listaMidia[cont].Tipo__c;
                midiaTipoQtd ++;
            }
            listaMidiaTipo.add(new Map<String, String>{'tipo'=> midiaTipo, 'qtd'=> String.valueOf(midiaTipoQtd)});
        }
        
        // popula visualizadores ----
        if(listaMidia.size() > 0){
            List<Id> listaMidiaId = new List<Id>();            
            for(Integer cont=0; cont<listaMidia.size(); cont++)
                listaMidiaId.add(listaMidia[cont].Id);
            
            List<AggregateResult> listaVisualizacaoAgreg = new List<AggregateResult>();
            listaVisualizacaoAgreg = [
                SELECT      Midia__c, Usuario__c, MAX(Usuario__r.Name) Usuario_Name, 
                            MAX(Usuario__r.SmallPhotoUrl) Usuario_Photo, MAX(CreatedDate) CreatedDate
                FROM        MktVisualizacao__c
                WHERE       Midia__c IN :listaMidiaId
                GROUP BY    Midia__c, Usuario__c
            ];
            for(Integer cont=0; cont < listaVisualizacaoAgreg.size(); cont++){
                listaVisualizacao.add(new Visualizacao(
                    (Id)listaVisualizacaoAgreg[cont].get('Midia__c'),
                    (Id)listaVisualizacaoAgreg[cont].get('Usuario__c'),
                    (String)listaVisualizacaoAgreg[cont].get('Usuario_Name'),
                    (String)listaVisualizacaoAgreg[cont].get('Usuario_Photo'),
                    String.valueOf(Datetime.valueOf(listaVisualizacaoAgreg[cont].get('CreatedDate')).format('dd/MM/yyyy HH:mm'))
                ));
            }

        }
    }
    
    public void PopulaParte(){
        
        // popula partes ----
        if(navegacaoObjeto == 'MktCategoria__c'){
            listaParte = [
                SELECT      Id, Tipo__c, Parte__c, Codigo__c, Nome__c, Modelo__c, Descricao__c, Icone__c, Valor__c, ValorKit__c, Quantidade_em_Estoque_Oficial__c
                FROM        MktParte__c
                WHERE       Categoria__c = :navegacaoId AND
                            Ativo__c = true
                ORDER BY    Tipo__c, Ordem__c NULLS LAST
            ];
        }
        
        temListaParte = (listaParte.size() > 0 ? true : false);
        
        // popula tipos/qtds ----
        if(listaParte.size() > 0){
            String  parteTipo = '';
            Integer parteTipoQtd = 0;
            for(Integer cont = 0; cont < listaParte.size(); cont++){
                if((parteTipo != listaParte[cont].Tipo__c) && (parteTipoQtd != 0)){
                    listaParteTipo.add(new Map<String, String>{'tipo'=> parteTipo, 'qtd'=> String.valueOf(parteTipoQtd)});
                    parteTipoQtd = 0;
                }
                parteTipo = listaParte[cont].Tipo__c;
                parteTipoQtd ++;
            }
            listaParteTipo.add(new Map<String, String>{'tipo'=> parteTipo, 'qtd'=> String.valueOf(parteTipoQtd)});
        }
        
        // popula valores
        if(listaParte.size() > 0){
            List<Id> listaParteProdId = new List<Id>();
            for(Integer cont = 0; cont < listaParte.size(); cont++){
                listaParteProdId.Add(listaParte[cont].Parte__c);
            }
            
            List<PriceBookEntry> entradas = new List<PriceBookEntry>(); // FY18
            entradas = [
                SELECT  Product2Id, UnitPrice
                FROM    PriceBookEntry
                WHERE   Product2Id IN :listaParteProdId AND
                        Pricebook2.Name = 'Padrão' AND PriceBookEntry.CurrencyIsoCode = 'BRL'        
            ];
            
            for(Integer cont = 0; cont < listaParte.size(); cont++){
                for(Integer cont2 = 0; cont2 < entradas.size(); cont2++){
                    if(listaParte[cont].Parte__c == entradas[cont2].Product2Id){
                        listaParte[cont].Valor__c = entradas[cont2].UnitPrice;
                    }
                }
            }
            
        }
        
    }

    public PageReference Baixar(){
        MktVisualizacao__c visualizacao = new MktVisualizacao__c();
        visualizacao.Usuario__c = UserInfo.getUserId();
        visualizacao.Midia__c = navegacaoId;
        insert visualizacao;
        
        String urlPath = null;
        for(Integer cont=0; cont<listaMidia.size(); cont++){
            if(listaMidia[cont].Id == navegacaoId){
                if(listaMidia[cont].URL_do_Arquivo__c != NULL)
                    urlPath = listaMidia[cont].URL_do_Arquivo__c;
                else
                    urlPath = '/sfc/servlet.shepherd/version/download/' + listaMidia[cont].DownloadId__c;
                break;
            }
        }
        return new PageReference(urlPath);
    }
    
    public void Abrir(){ 
        MktVisualizacao__c visualizacao = new MktVisualizacao__c();
        visualizacao.Usuario__c = UserInfo.getUserId();
        visualizacao.Midia__c = navegacaoId;
        insert visualizacao;
    }
    
    public class Navegacao{
        public Id id {get;set;}
        public String nome {get;set;}
        public String imagem {get;set;}
        
        public Navegacao(Id id_parm, String nome_parm, String imagem_parm){
            id = id_parm;
            nome = nome_parm;
            imagem = imagem_parm;
        }
    }
    
    public class Visualizacao{
        public Id midia_id {get;set;}
        public Id usuario_id {get;set;}
        public String usuario_nome {get;set;}
        public String usuario_foto {get;set;}
        public String ultimo_acesso {get;set;}
        
        public Visualizacao(Id midia_id_parm, Id usuario_id_parm, String usuario_nome_parm,
                            String usuario_foto_parm, String ultimo_acesso_parm){
            midia_id = midia_id_parm;
            usuario_id = usuario_id_parm;
            usuario_nome = usuario_nome_parm;
            usuario_foto = usuario_foto_parm;
            ultimo_acesso = ultimo_acesso_parm;
        }
    }
    
}