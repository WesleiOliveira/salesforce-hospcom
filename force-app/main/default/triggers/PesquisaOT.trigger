trigger PesquisaOT on WorkOrder (after update) {
    if(PesquisaSatisf.orderEmail==null)
        PesquisaSatisf.orderEmail = new List<String>();
    for(WorkOrder OT: Trigger.new){
        if(!PesquisaSatisf.orderEmail.contains(OT.Id) && (OT.Status == 'FECHADO CONCLUÍDO' && OT.Sub_Status__c == 'FINALIZADO') && !OT.E_mail__c.contains('hospcom.net') && OT.Pesq_Satisfacao_Enviada__c == false){
            PesquisaSatisf.orderEmail.add(OT.Id);
            PesquisaSatisf.enviarSERV(OT.Id);
        }
    }
}