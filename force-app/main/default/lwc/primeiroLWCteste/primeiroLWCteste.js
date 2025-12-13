import { LightningElement, track } from 'lwc';

export default class HelloWorldComponent extends LightningElement {
    @track showMessage = false;

    handleClick() {
        this.showMessage = true;
    }
}