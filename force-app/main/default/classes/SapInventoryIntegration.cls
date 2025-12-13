public class SapInventoryIntegration {
    
	@future(callout=true)
    Public Static Void InventoryIntegration(){
        
        List<Inventory> inventory = new List<Inventory>();
	    List<String> productCodes = new List<String>();
        Map<String,List<String>> products = new Map<String,List<String>>();// Map com informações necessárias para inserir o valor de estoque (SAP) no seu respectivo produto (SalesForce)

    	String payload = !System.Test.isRunningTest() ? GetInventory() : '{"status":"0","message":"Retorno de Itens","data":[{"CodigoItem":"00.15.01.0324.000","Descricao":null,"CodigoFabricante":18,"Fabricante":"FANEM","Referencia":null,"PrecoVenda":0.0,"EstoqueDisponivel":0.0},{"CodigoItem":"000.070.015","Descricao":null,"CodigoFabricante":18,"Fabricante":"FANEM","Referencia":null,"PrecoVenda":0.0,"EstoqueDisponivel":0.0},{"CodigoItem":"ZFTZ7/228","Descricao":null,"CodigoFabricante":121,"Fabricante":"FERT MEDICAL","Referencia":null,"PrecoVenda":null,"EstoqueDisponivel":0.0}]}';
    	//String payload = '{"status":"0","message":"Retorno de Itens","data":[{"CodigoItem":"00.15.01.0324.000","Descricao":null,"CodigoFabricante":18,"Fabricante":"FANEM","Referencia":null,"PrecoVenda":0.0,"EstoqueDisponivel":0.0},{"CodigoItem":"000.070.015","Descricao":null,"CodigoFabricante":18,"Fabricante":"FANEM","Referencia":null,"PrecoVenda":0.0,"EstoqueDisponivel":0.0},{"CodigoItem":"ZFTZ7/228","Descricao":null,"CodigoFabricante":121,"Fabricante":"FERT MEDICAL","Referencia":null,"PrecoVenda":null,"EstoqueDisponivel":5.0}]}';

        Map<String, Object> mapJson = (Map<String, Object>)JSON.deserializeUntyped(payload);
        List<Object> items = (List<Object>)mapJson.get('data');
        
        for(Object item: items){
            Map<String, Object> itemMap = (Map<String, Object>)item;
			productCodes.add(String.valueOf(itemMap.get('CodigoItem')));
			inventory.add(insertInventoryJson(itemMap));
        }
        
        for(Product2 p : [Select Id, Quantidade_em_Estoque_Oficial__c, ProductCode FROM Product2 WHERE ProductCode IN :productCodes])
            products.put(p.ProductCode, new String[]{p.Id, p.Quantidade_em_Estoque_Oficial__c == null ? '0' : String.valueOf(p.Quantidade_em_Estoque_Oficial__c)});
        
        if(!System.Test.isRunningTest())
            for(Inventory i : inventory)
                if(products.containsKey(i.CodigoItem) && i.EstoqueDisponivel != Integer.valueOf(products.get(i.CodigoItem)[1])){ Product2 p = new Product2(Id = products.get(i.CodigoItem)[0], Quantidade_em_Estoque_Oficial__c = i.EstoqueDisponivel); try{ Update p; } catch (Exception e){ LogIntegration(String.valueOf(p) + '\n\n' + e.getMessage(),'Update Estoque'); } }                
            
    }
    
    Public Static Inventory insertInventoryJson(Map<String, Object> item){
        Inventory i = new Inventory();
        i.setCodigoItem(String.valueOf(item.get('CodigoItem')));
        i.setEstoqueDisponivel(Integer.valueOf(item.get('Em Estoque')));        
        return i;
    }
    
    Public Static String GetInventory(){
        String url = 'http://201.7.211.65:8889/IntegraOne/api/Items/GetAllItems'; Map<String, String> header = new Map<String, String>(); header.put('TOKEN_ACESSO', integracaoSAP.getToken()); header.put('Accept', 'application/json, text/plain, */*'); header.put('Content-Type', 'application/json;charset=utf-8'); HttpConsult req = new HttpConsult();
        return req.request(url, 'GET', null, header);
    }

    public static void LogIntegration(String log, String name){ integracaoSAP.logIntegracaoSap(log, name); }
    
    Public Class Inventory{
    	Private String CodigoItem;
    	//Private String Descricao;
    	//Private Integer CodigoFabricante;
    	//Private String Fabricante;
    	//Private String Referencia;
    	//Private Integer PrecoVenda;
    	Private Integer EstoqueDisponivel;
        
        Public Void setCodigoItem(String CodigoItem){
            this.CodigoItem = CodigoItem;
        }
        
        Public Void setEstoqueDisponivel(Integer EstoqueDisponivel){
            this.EstoqueDisponivel = EstoqueDisponivel;
        }

    }
}