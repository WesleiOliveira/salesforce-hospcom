import { LightningElement, api, wire } from 'lwc';
import soql from '@salesforce/apex/ApexHelperController.executeSoql';
import USER_ID from '@salesforce/user/Id';
import { createRecord } from 'lightning/uiRecordApi';
import ACAO_OBJECT from '@salesforce/schema/Acao_corretiva__c';
import CAUSAS from '@salesforce/schema/Acao_corretiva__c.Causas__c';
import DATA_ABERTURA from '@salesforce/schema/Acao_corretiva__c.Data_da_abertura_do_RCA__c';
import DESCRICAO_OCORRENCIA from '@salesforce/schema/Acao_corretiva__c.Descri_o_da_Ocorr_ncia__c';
import ENTREGUE_POR from '@salesforce/schema/Acao_corretiva__c.Entregue_por__c';
import OCORRENCIA_FIELD from '@salesforce/schema/Acao_corretiva__c.Ocorrencia__c';
import ORIGEM from '@salesforce/schema/Acao_corretiva__c.Origem__c';
import RECORDTYPEID from '@salesforce/schema/Acao_corretiva__c.RecordTypeId';
import RESUMO from '@salesforce/schema/Acao_corretiva__c.Resumo_da_Ocorr_ncia__c';
import STATUS from '@salesforce/schema/Acao_corretiva__c.Status__c';
import SUGESTAO_RESOLUCAO from '@salesforce/schema/Acao_corretiva__c.Sugest_o_para_Resolu_o__c';
import { getRecord } from 'lightning/uiRecordApi';
import Name from '@salesforce/schema/Ocorrencia__c.Name';

export default class BotaoCriarAcaoCorretiva extends LightningElement {
    @api recordId; // 🚨 Salesforce injeta aqui o ID do registro da Record Page

    @wire(getRecord, { recordId: '$recordId', fields: [Name] })
    ocorrencia__c;

    access = false;
    USER_BYPASS_IDS = ['00531000006UzZsAAK'];
    ocorrencia = {};

    async connectedCallback() {
        console.log("UserID: ", USER_ID);
        console.log(this.ocorrencia__c.recordId);
        this.access = await this.queryUser(USER_ID, soql);
        console.log('accesso liberado:', this.access);
    }
    async renderedCallback() {
        console.log("recordid: ", this.recordId)
    }
    get name() {
        return this.ocorrencia__c.data ? getFieldValue(this.ocorrencia__c.data, Name) : '';
    }
    async queryUser(userId, soql) {
        console.log('Querying user...');

        if (!userId) {
            console.error("Erro ao consultar usuário: ID não informado");
            return false;
        }

        const query = `SELECT Id, Name, E_gerente__c 
                       FROM User 
                       WHERE IsActive = true AND Id = '${userId}'`;

        try {
            const result = await soql({ soql: query });

            if (result && result.length > 0) {
                const user = result[0];
                const isGerente = user.E_gerente__c === true;
                const isBypass = this.USER_BYPASS_IDS.includes(user.Id);

                return isBypass;
            } else {
                console.warn("Nenhum usuário encontrado para o Id:", userId);
                return false;
            }
        } catch (error) {
            console.error("Erro ao consultar usuário:", error);
            return false;
        }
    }

    async criarAc() {
        if (this.access) {
            await this.queryOc();
            await this.createAcao();
        }

    }
    async queryOc() {
        const query = `SELECT 
        Id,
        Name,
        CreatedDate,
        Descri_o_Detalhada_da_Ocorr_ncia__c,
        Possiveis_causas__c,
        Sugest_o_para_Resolu_o__c,
        Departamento__c,
        Observacoes__c,
        datahora_abertura__c,
        Responsavel_pela_ocorrencia__r.Id,
        Responsavel_pela_ocorrencia__r.FirstName,
        Responsavel_pela_ocorrencia__r.LastName,
        CreatedBy.Id,
        CreatedBy.FirstName,
        CreatedBy.LastName
    FROM Ocorrencia__c
    WHERE Id = '${this.recordId}'`;

        try {
            const result = await soql({ soql: query });

            if (result && result.length > 0) {
                this.ocorrencia = result[0];
                console.log('Ocorrência carregada:', this.ocorrencia);
            } else {
                console.warn('Nenhuma ocorrência encontrada para este Id:', this.recordId);
            }

        } catch (error) {
            console.error('Erro ao consultar ocorrência:', error);
        }
    }
    async createAcao() {
        if (!this.ocorrencia) {
            console.error('Ocorrência não carregada.');
            return;
        }

        const oc = this.ocorrencia;

        // Montar HTML do resumo
        const resumoHTML = `
<h2 style="text-align: center;"><span style="color: rgb(1, 8, 118);">Resumo da Ocorrência</span></h2>
<table style="width: 100%; border-collapse: collapse; margin-bottom: 20px;">
    <tbody>
        <tr><td style="font-weight: bold;">Ocorrência:</td><td>${oc.Name}</td></tr>
        <tr><td style="font-weight: bold;">Departamento:</td><td>${oc.Departamento__c}</td></tr>
        <tr><td style="font-weight: bold;">Descrição:</td><td>${oc.Descri_o_Detalhada_da_Ocorr_ncia__c}</td></tr>
        <tr><td style="font-weight: bold;">Possíveis causas:</td><td>${oc.Possiveis_causas__c}</td></tr>
        <tr><td style="font-weight: bold;">Sugestão para resolução:</td><td>${oc.Sugest_o_para_Resolu_o__c}</td></tr>
        <tr><td style="font-weight: bold;">Responsável:</td><td>${oc.Responsavel_pela_ocorrencia__r?.FirstName || ''} ${oc.Responsavel_pela_ocorrencia__r?.LastName || ''}</td></tr>
        <tr><td style="font-weight: bold;">Observações:</td><td>${oc.Observacoes__c}</td></tr>
    </tbody>
</table>
<p><em style="font-size: 11px;">Criado por</em> <strong style="font-size: 11px;">${oc.CreatedBy?.FirstName || ''} ${oc.CreatedBy?.LastName || ''}</strong>
<em style="font-size: 11px;"> em </em> <strong style="font-size: 11px;">${oc.datahora_abertura__c}</strong></p>
`;

        const fields = {};
        fields[CAUSAS.fieldApiName] = oc.Possiveis_causas__c;
        fields[DATA_ABERTURA.fieldApiName] = oc.CreatedDate;
        fields[DESCRICAO_OCORRENCIA.fieldApiName] = oc.Descri_o_Detalhada_da_Ocorr_ncia__c;
        fields[ENTREGUE_POR.fieldApiName] = oc.ContactId;
        fields[OCORRENCIA_FIELD.fieldApiName] = oc.Id;
        fields[ORIGEM.fieldApiName] = 'OCORRÊNCIA';
        fields[RECORDTYPEID.fieldApiName] = '012U4000008K7YbIAK'; // RecordType Ocorrência
        fields[RESUMO.fieldApiName] = resumoHTML;
        fields[STATUS.fieldApiName] = 'Pendente';
        fields[SUGESTAO_RESOLUCAO.fieldApiName] = oc.Sugest_o_para_Resolu_o__c;

        const recordInput = { apiName: ACAO_OBJECT.objectApiName, fields };

        try {
            const ac = await createRecord(recordInput);
            console.log('Ação Corretiva criada com Id:', ac.id);
        } catch (error) {
            console.error('Erro ao criar Ação Corretiva:', error);
        }
    }

}