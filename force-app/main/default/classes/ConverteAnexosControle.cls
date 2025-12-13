public with sharing class ConverteAnexosControle{
    
    private static boolean executar = true;
    
    public static boolean ExecutarUmaVez(){
        if(executar){
            executar = false;
            return true;
        }
        else{
            return executar;
        }
    }
}