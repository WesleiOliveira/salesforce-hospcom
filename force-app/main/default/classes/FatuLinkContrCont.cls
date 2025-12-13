public Class FatuLinkContrCont{
    public static boolean run = true;
    public static boolean PrimeiraExecucao(){
        if(run){
            run=false;
            return true;
        }else{
            return run;
        }
    }
}