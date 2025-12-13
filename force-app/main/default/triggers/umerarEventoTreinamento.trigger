trigger umerarEventoTreinamento on Campaign (before insert) {
    for (Campaign c : Trigger.new) {
        numerarNovoEvento.numerarNovoEvento(c);
    }
}