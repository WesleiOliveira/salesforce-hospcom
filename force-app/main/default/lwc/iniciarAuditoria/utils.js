import { ShowToastEvent } from 'lightning/platformShowToastEvent';


export function showErro(msg = 'Erro desconhecido') {
    toast('Erro', `Erro: ${msg}`, 'error', 'sticky');
}

export function showSucesso(msg = 'Sucesso') {
    toast('Sucesso', `${msg}`, 'success', 'pester');
}

export function showAlerta(mensagem) {
    toast('Atenção', `${mensagem}`, 'sticky');
}


function toast(titulo, mensagem, variante = 'info', modo = 'dismissable') {
    const event = new ShowToastEvent({
        title: titulo,
        message: mensagem,
        variant: variante,  // 'success', 'error', 'warning', 'info'
        mode: modo          // 'dismissable', 'pester', 'sticky'
    });
    dispatchEvent(event);
}

export function travaPageReload() {
    window.onbeforeunload = function (event) {
        event.returnValue = "Sair agora descartará alterações não salvas";
        return "Sair agora descartará alterações não salvas";
    }
}
export function removeTravaPageReload(){
    window.onbeforeunload = null;
}