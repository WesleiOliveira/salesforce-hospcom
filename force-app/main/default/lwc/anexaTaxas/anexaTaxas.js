import { LightningElement, api, track } from 'lwc';
import uploadPdfAndGetPublicUrl from '@salesforce/apex/anexaTaxasPC.uploadPdfAndGetPublicUrl';
import processarPdfViaChatPdf from '@salesforce/apex/anexaTaxasPC.processarPdfViaChatPdf';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class AnexoFornecedor extends LightningElement {
    @api recordId;
    tipoSelecionado = '';
    arquivoSelecionado;
    @track isLoading = false;

    tipoOptions = [
        { label: 'Efetivo', value: 'Efetivo' },
        { label: 'Estimado', value: 'Estimado' }
    ];

    handleTipoChange(event) {
        this.tipoSelecionado = event.detail.value;
    }

    handleFileChange(event) {
        this.arquivoSelecionado = event.target.files[0];
    }

    async handleUpload() {
        if (!this.tipoSelecionado || !this.arquivoSelecionado) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Aviso',
                message: 'Selecione o tipo e o arquivo.',
                variant: 'warning'
            }));
            return;
        }

        this.isLoading = true;

        const reader = new FileReader();
        reader.onload = async () => {
            const base64 = reader.result.split(',')[1];
            const fileName = `Impostos e Taxas - ${this.tipoSelecionado}`;

            try {
                const publicUrl = await uploadPdfAndGetPublicUrl({
                    recordId: this.recordId,
                    fileName: fileName,
                    base64Data: base64
                });

                console.log('URL pública recebida do Apex:', publicUrl);

                if (!publicUrl) {
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'Erro',
                        message: 'Não foi possível gerar a URL pública do PDF.',
                        variant: 'error'
                    }));
                    return;
                }

                await processarPdfViaChatPdf({
                    publicUrl: publicUrl,
                    fileName: fileName,
                    recordId: this.recordId
                });

                this.dispatchEvent(new ShowToastEvent({
                    title: 'Sucesso',
                    message: 'Arquivo processado com sucesso!',
                    variant: 'success'
                }));
            } catch (error) {
                console.error('Erro durante o processamento:', error);
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Erro',
                    message: error.body?.message || error.message,
                    variant: 'error'
                }));
            } finally {
                this.isLoading = false;
            }
        };

        reader.onerror = () => {
            this.isLoading = false;
            this.dispatchEvent(new ShowToastEvent({
                title: 'Erro',
                message: 'Erro ao ler o arquivo.',
                variant: 'error'
            }));
        };

        reader.readAsDataURL(this.arquivoSelecionado);
    }
}