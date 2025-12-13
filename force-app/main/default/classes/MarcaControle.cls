public class MarcaControle {
    public static boolean 
        runBeforeInsert=true, runAfterInsert=true, 
        runBeforeUpdate=true, runAfterUpdate=true,
        runBeforeDelete=true, runAfterDelete=true,
        retorno=true;
	
    public static boolean PrimeiraExecucao(String momento, String operacao){
        if(momento=='before' && operacao=='insert'){
			if(runBeforeInsert){
				runBeforeInsert=false;
				retorno=true;
			}else{
				retorno = runBeforeInsert;
			}
		}
		else if(momento=='after' && operacao=='insert'){
			if(runAfterInsert){
				runAfterInsert=false;
				retorno=true;
			}else{
				retorno = runAfterInsert;
			}
		}
		else if(momento=='before' && operacao=='update'){
			if(runBeforeUpdate){
				runBeforeUpdate=false;
				retorno=true;
			}else{
				retorno = runBeforeUpdate;
			}
		}
		else if(momento=='after' && operacao=='update'){
			if(runAfterUpdate){
				runAfterUpdate=false;
				retorno=true;
			}else{
				retorno = runAfterUpdate;
			}
		}
		else if(momento=='before' && operacao=='delete'){
			if(runBeforeDelete){
				runBeforeDelete=false;
				retorno=true;
			}else{
				retorno = runBeforeDelete;
			}
		}
		else if(momento=='after' && operacao=='delete'){
			if(runAfterDelete){
				runAfterDelete=false;
				retorno=true;
			}else{
				retorno = runAfterDelete;
			}
		}
		return retorno;
    }
}