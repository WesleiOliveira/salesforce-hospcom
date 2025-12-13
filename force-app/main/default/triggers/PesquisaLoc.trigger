trigger PesquisaLoc on Contrato_de_Servi_o__c (after update) {
    if(PesquisaSatisf.orderEmail==null)
        PesquisaSatisf.orderEmail = new List<String>();
    for(Contrato_de_Servi_o__c CL: Trigger.new){
        if(!PesquisaSatisf.orderEmail.contains(CL.Id) && (CL.Status_do_Contrato__c == 'CONCLUÍDO' && CL.Pesq_Satisfacao_Enviada__c == false)){
            PesquisaSatisf.orderEmail.add(CL.Id);
            PesquisaSatisf.enviarLOCAC(CL.Id);
        }
    }
}