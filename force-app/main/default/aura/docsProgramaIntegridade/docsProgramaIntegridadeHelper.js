({
	helperMethod : function(cmp, event, helper) {
		console.log("HELPER WORK")
        
        var nomeDocumentos = [
            "ANEXO I - Política - Relacionamentos Interpessoais - Grupo Hospcom",
            "ANEXO II - Política - brindes, presentes e hospitalidades - Grupo Hospcom",
            "ANEXO III - Política de Licitações e Contratações Públicas",
            "ANEXO IV - Políticas de Compras",
            "ANEXO V - Política do canal de denúncias",
            "Política de Compliance"
        ]
        
        var tipoDocumentos =[
            "application/pdf",
            "application/pdf",
            "application/pdf",
            "application/pdf",
            "application/pdf"
        ]
        
        var linkDocumentos = [
            "https://hospcomhospitalar-my.sharepoint.com/:b:/g/personal/willyan_arruda_hospcom_net/EZx-MpFZp8pCheZUcdVlF7sBQSnVyr2wXgc-ELiqdjc04g?e=AZVjGm",
            "https://hospcomhospitalar-my.sharepoint.com/:b:/g/personal/willyan_arruda_hospcom_net/EcsA2ZAjqPVNh1ct_mTihW0BBsPXXMpRcr_wz1Yeo7ioyA?e=9TTXmg",
            "https://hospcomhospitalar-my.sharepoint.com/:b:/g/personal/luiz_peixoto_hospcom_net/EQr-9zmECIBDlkbi0POTQxYB7XCPEyVg2tizuvhqhMsVnQ?e=EDNYY0",
            "https://hospcomhospitalar-my.sharepoint.com/:b:/g/personal/willyan_arruda_hospcom_net/EZF473briURMiCQWICTmWm8BVGx10ELQckewGPplIEhiRw?e=dXxMaF",
            "https://hospcomhospitalar-my.sharepoint.com/:b:/g/personal/luiz_peixoto_hospcom_net/EUvNjyZ8NLhPiO53R1A3UcIBnOeBtvY2JVxKMitN1VmQtg?e=UlBamn",
            "https://hospcomhospitalar-my.sharepoint.com/:b:/g/personal/luiz_peixoto_hospcom_net/EbW8wcgi-utOih3hdkbWTaoB0DV6-IWJl-HrhNFZufG79g?e=M1wkzg",
        ];
            
           
        linkDocumentos.forEach((documentoAtual, index) => {
                
                var nomeDoc = nomeDocumentos[index]
                var type = tipoDocumentos[index]
                
                
                var html = "<div class='item' data-urlDoc='"+documentoAtual+"'>\
                    <div class='filename'>\
                        <p>"+nomeDoc+"</p>\
                        <div class='filedata'>\
                            <span>1 file</span>\
                            <span>●</span>\
                            <span>"+type+"</span>\
                        </div>\
                    </div>\
                    <button class='buttonDownload'>Download</button>\
                </div>"
                
                $("#boxContain").append(html)
                
                console.log(documentoAtual)
            });
            
            $(".buttonDownload").on( "click", function() {
                var urlDoc = $(this).parents('.item').attr('data-urlDoc')
                helper.downloadsPDF(cmp, event, helper, urlDoc);

                console.log(urlDoc)
            });
    },
    
    downloadsPDF : function(cmp, event, helper, url) {
        const linkSource = url
        const downloadLink = document.createElement("a");
        const fileName = "Download.pdf";
        downloadLink.href = linkSource;
        downloadLink.download = fileName;
        downloadLink.click();
        
	},
 })