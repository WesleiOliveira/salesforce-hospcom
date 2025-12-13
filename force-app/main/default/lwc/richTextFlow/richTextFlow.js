import { LightningElement, api } from 'lwc';

export default class RichTextFlow extends LightningElement {
    @api value; // recebe valor inicial do Flow

    handleChange(event) {
        this.value = event.target.value;

        // envia para o Flow
        const valueChangeEvent = new CustomEvent('valuechange', {
            detail: this.value
        });
        this.dispatchEvent(valueChangeEvent);
    }
}