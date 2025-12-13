public class PedAtuEndClass {
    
	public static Account conta;
	
    public static String FluxoCobranca(Order pedido){
        String retorno = null;
        String msg_erro = 'Informe esse campo';
        
		if(pedido.AccountId != null){
			ObtemConta(pedido.AccountId);
			if(conta.BillingStreet != null || conta.BillingCity != null || conta.BillingPostalCode != null){
				pedido.BillingStreet = conta.BillingStreet;
				pedido.BillingCity = conta.BillingCity;
				pedido.BillingState = conta.BillingState;
				pedido.BillingPostalCode = conta.BillingPostalCode;
				pedido.BillingCountry = conta.BillingCountry;
			}
            else{
        	    retorno = msg_erro;
        	}
		}
		else{
			retorno = msg_erro;
		}
        
        return retorno;
    }
    
    public static String FluxoEntrega(Order pedido){
        String retorno = null;
        String msg_erro = 'Informe esse campo';
        
		if(pedido.AccountId != null){
			if(conta == null || conta.Id == null)
				ObtemConta(pedido.AccountId);
			if(conta.ShippingStreet != null || conta.ShippingCity != null || conta.ShippingPostalCode != null){
				pedido.ShippingStreet = conta.ShippingStreet;
				pedido.ShippingCity = conta.ShippingCity;
				pedido.ShippingState = conta.ShippingState;
				pedido.ShippingPostalCode = conta.ShippingPostalCode;
				pedido.ShippingCountry = conta.ShippingCountry;
			}
            else{
        	    retorno = msg_erro;
        	}
		}
		else{
			retorno = msg_erro;
		}
        
        return retorno;
    }
    
    public static void ObtemConta(Id conta_id){
    	conta = new Account();
        conta = [
            SELECT	Id, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry,
					ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry
            FROM 	Account
            WHERE	Id = :conta_id
        ];
    }  
        
}