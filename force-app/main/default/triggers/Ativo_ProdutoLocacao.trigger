trigger Ativo_ProdutoLocacao on Asset (after insert) {
    if (Trigger.isAfter && Trigger.isInsert) {
        for (Asset ativo : Trigger.new) {
            if(!ativo.isclone())
                Ativo_ProdutoLocacaoClass.handleAfterInsert(Trigger.new);
        }
    }
}