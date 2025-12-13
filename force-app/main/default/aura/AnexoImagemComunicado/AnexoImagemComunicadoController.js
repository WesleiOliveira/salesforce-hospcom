({
    handleFileChange: function(component, event, helper) {
        const fileInput = event.getSource();
        const file = fileInput.get("v.files")[0]; 
        console.log("file", file);
        
        if (file) {            
            component.set("v.fileName", file.name);            
            const reader = new FileReader();
            reader.onload = function(e) {                
                const base64Image = e.target.result;               
                component.set("v.fileContent", base64Image);
            };
            reader.readAsDataURL(file);  
        } else {
            component.set("v.fileName", "Nenhum arquivo selecionado");
        }
    },

    handleSave: function(component, event, helper) {
        const base64Image = component.get("v.fileContent"); 

        if (!base64Image) {
            alert('Por favor, selecione um arquivo de imagem!');
            return;
        }

       
        const formData = new FormData();        
        
        const byteCharacters = atob(base64Image.replace(/^data:image\/\w+;base64,/, ''));
        const byteArrays = [];
        for (let offset = 0; offset < byteCharacters.length; offset += 512) {
            const slice = byteCharacters.slice(offset, offset + 512);
            const byteNumbers = new Array(slice.length);
            for (let i = 0; i < slice.length; i++) {
                byteNumbers[i] = slice.charCodeAt(i);
            }
            byteArrays.push(new Uint8Array(byteNumbers));
        }
        const blob = new Blob(byteArrays, { type: 'image/png' }); 

        formData.append('imagem', blob, component.get("v.fileName"));
        
        fetch('https://integracao.hospcom.net/uploads', {
            method: 'POST',
            body: formData  
        })
        .then(response => response.json())
        .then(data => {
            console.log("data", data);
            if (data && data.url) {
                const imageUrl = data.url;  
                component.set("v.imageSrc", imageUrl); 
                component.set("v.URL", imageUrl); 
                
                var action = component.get("c.updateImageUrl");
                action.setParams({
                    recordId: component.get("v.recordId"), 
                    imageUrl: imageUrl 
                });

                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        alert('Imagem enviada e URL atualizada com sucesso!');
                        window.location.reload();
                    } else {
                        alert('Erro ao atualizar a URL da imagem!');
                    }
                });

                $A.enqueueAction(action);  
            } else {
                alert('Erro: ' + (data.error || 'Erro desconhecido'));
            }
        })
        .catch(error => {
            console.error("Erro ao enviar imagem", error);
            alert('Erro ao enviar a imagem. Tente novamente.');
        });
    }
})