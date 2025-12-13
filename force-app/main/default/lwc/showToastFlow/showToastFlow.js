import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class showToastFlow extends LightningElement {
    @api message;
    @api variant; // success, error, warning, info
    @api title;

    connectedCallback() {
        this.dispatchEvent(
            new ShowToastEvent({
                title: this.title || 'Aviso',
                message: this.message || '',
                variant: this.variant || 'info'
            })
        );
    }
}