trigger ValidacaoZapEmailContatos on Contact (after insert,
                                             after update) {
    
    if (Trigger.isAfter && Trigger.isInsert) {
        for (Contact novoContato : Trigger.new) {
            if(novoContato.Account.Ownership == 'PRIVADO')
                ValidacoesContato.consultaWhatsapp(novoContato.MobilePhone, novoContato.Phone, novoContato.Id);
        }
    }
}