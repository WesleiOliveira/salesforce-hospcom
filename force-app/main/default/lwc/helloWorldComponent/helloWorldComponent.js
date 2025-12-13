import { LightningElement, track } from 'lwc';

export default class HelloWorldComponent extends LightningElement {
    @track showMessage = false;
    api = 'global';
    handleClick() {
        this.showMessage = true;
    }
}