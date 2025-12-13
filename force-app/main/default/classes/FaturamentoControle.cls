public Class FaturamentoControle{
    public static boolean runBefore=true, runAfter=true, retorno=true;
	
    public static boolean PrimeiraExecucao(String momento){
        if(momento == 'before'){
			if(runBefore){
				runBefore=false;
				retorno=true;
			}else{
				retorno = runBefore;
			}
		}
		else if(momento == 'after'){
			if(runAfter){
				runAfter=false;
				retorno = true;
			}else{
				retorno = runAfter;
			}
		}
		return retorno;
    }
}