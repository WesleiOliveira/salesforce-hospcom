trigger OportunidadeCompartilha on Opportunity (after update, before delete) {
    if (Util.AcaoInterna()) {
        return;
    }

    if (Trigger.isAfter && Trigger.isUpdate) {
        List<Opportunity> oppsParaReplica = new List<Opportunity>();

        for (Opportunity opp : Trigger.new) {
            Opportunity oldOpp = Trigger.oldMap.get(opp.Id);
            if (oldOpp == null) continue;

            // Só replica se mudou algo relevante
            Boolean mudouOwner       = opp.OwnerId != oldOpp.OwnerId;
            Boolean mudouDepartamento = opp.Departamento__c != oldOpp.Departamento__c;

            if (mudouOwner || mudouDepartamento) {
                oppsParaReplica.add(opp);
            }
        }

        if (!oppsParaReplica.isEmpty()) {
            OportunidadeCompartilhaService.replicaShares(oppsParaReplica);
        }
    }
    else if (Trigger.isBefore && Trigger.isDelete) {
        OportunidadeCompartilhaService.validaExclusao(Trigger.old);
    }
}