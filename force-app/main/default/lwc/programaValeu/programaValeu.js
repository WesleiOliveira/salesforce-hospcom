import { LightningElement, track } from 'lwc';
import executeSoql from '@salesforce/apex/programaValeu.executeSoql';
import criaSolicitacao from '@salesforce/apex/programaValeu.criaSolicitacao';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import USER_ID from '@salesforce/user/Id';


export default class LwcSelectContact extends LightningElement {
    @track contacts = [];
    @track contactsNoUser = [];
    @track selectedContact;
    @track selectedContact2;
    @track justificativa = '';
    @track nome = '';
    @track userName = '';
    userDepartment;
    userId = USER_ID;
    @track loggedInContactId;;

    connectedCallback() {
        if (this.userId) {
            this.loadUserDepartment();
            console.log(this.userId);
            this.checkDate();

        }        else {
            console.log("NAO TEM ID");
            this.showNomeInput = true; // Se o userId for undefined, habilita o input "Nome"
            this.loadContactsWithoutDepartment();
            this.loadContactsWithoutUser();
            this.checkDate();
        }
    }

    checkDate() {
        
  
        const today = new Date();
        const day = today.getDate();
        const lastDay = new Date(today.getFullYear(), today.getMonth() + 1, 0).getDate();

        // O botão aparece entre o dia 25 e o último dia do mês
        //this.showButton = day >= 25 && day <= lastDay;
        this.showButton = true;    
    }
    

    loadUserDepartment() {
        const userSoql = `SELECT Departamento3__c, Name, ContactId FROM User WHERE Id = '${USER_ID}'`;
        executeSoql({ soql: userSoql })
            .then(result => {
                if (result.length > 0) {
                    this.userName = result[0].Name;  
                    this.loggedInContactId = result[0].ContactId;              
                    this.userDepartment = result[0].Departamento3__c;
                    this.loadContacts();
                }
            })
            .catch(error => {
                console.error('Erro ao obter informações do usuário', error);
            });
    }

    loadContacts() {
        console.log("Carrega contatos com departamento");
        const soql = `SELECT Id, FirstName, LastName FROM Contact WHERE AccountID = '001i00000085QYb' AND Department != '${this.userDepartment}' AND Colaborador_Ativo__c = true ORDER BY FirstName`;
        executeSoql({ soql })
            .then(result => {
                this.contacts = result.map(contact => ({
                    label: `${contact.FirstName} ${contact.LastName}`,
                    value: contact.Id
                }));
            })
            .catch(error => {
                console.error('Erro ao buscar contatos:', error);
            });
    }

    loadContactsWithoutDepartment() {
        console.log("Carrega contatos sem departamento");
        const soql = `SELECT Id, FirstName, LastName FROM Contact WHERE AccountID = '001i00000085QYb' AND Colaborador_Ativo__c = true ORDER BY FirstName`;
        executeSoql({ soql })
            .then(result => {
                this.contacts = result.map(contact => ({
                    label: `${contact.FirstName} ${contact.LastName}`,
                    value: contact.Id
                }));
            })
            .catch(error => {
                console.error('Erro ao buscar contatos:', error);
            });
    }

    loadContactsWithoutUser() {
    console.log("Carrega contatos sem usuário");

    // Garante que selectedContact está definido para evitar erro de string mal formada
    const excludedId = this.selectedContact ? `'${this.selectedContact}'` : null;

    const soql = `
        SELECT Id, FirstName, LastName 
        FROM Contact 
        WHERE AccountId = '001i00000085QYb'
          AND Id NOT IN (SELECT ContactId FROM User where isActive = true)
          ${excludedId ? `AND Id != ${excludedId}` : ''}
          AND Colaborador_Ativo__c = true
        ORDER BY FirstName
    `;

    executeSoql({ soql })
        .then(result => {
            this.contactsNoUser = result.map(contact => ({
                label: `${contact.FirstName} ${contact.LastName}`,
                value: `${contact.FirstName} ${contact.LastName}`
            }));
        })
        .catch(error => {
            console.error('Erro ao buscar contatos:', error);
        });
}


    handleContactChange(event) {
        this.selectedContact = event.target.value;
    }

    handleJustificativaChange(event) {
        console.log("ENTROU");
        this.justificativa = event.target.value;
    }

    handleNomeChange(event) {
        this.nome = event.target.value;
    }

    handleSubmit() {
        console.log("ENTROU");
        if (!this.selectedContact || !this.justificativa) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Erro',
                    message: 'Selecione um contato e preencha a justificativa.',
                    variant: 'error'
                })
            );
            return;
        }

        if (this.selectedContact === this.loggedInContactId) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Erro',
                message: 'Você não pode enviar para si mesmo.',
                variant: 'error'
            })
        );
        return;
    }

        criaSolicitacao({ idContato: this.selectedContact, justificativa: this.justificativa, nome: this.nome })
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Sucesso',
                        message: 'Dados enviados com sucesso!',
                        variant: 'success'
                    })
                );
                this.selectedContact = '';
                this.justificativa = '';
                this.showButton = false;
            })
            .catch(error => {
                console.error('Erro ao enviar dados:', error);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Erro',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            });
    }
}