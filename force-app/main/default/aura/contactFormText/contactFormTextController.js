({
    doInit: function(cmp) {
        // Set the attribute value. 
        // You could also fire an event here instead.
        cmp.set("v.setMeOnInit", "controller init magic!");
    },
    
    onRead : function (cmp, event, helper){
        console.log("rederizado!")
        
        $('#linhaTelefone').click(function() {
            window.open("tel:+556232415555");
        });
        
        $('#linhaEmail').click(function (event) {
            var email = 'atendimento@hospcom.net';
            var subject = 'Contato';
            var emailBody = 'Olá,';
            var attach = '';
            document.location = "mailto:"+email+"?subject="+subject+"&body="+emailBody+
                "?attach="+attach;
        });
        
        
    },

	setLocation: function (cmp, event, helper) {
        cmp.set('v.mapMarkers', [
            {
                location: {
                    Street: 'R. 89, 717',
                    City: 'Goiânia',
                    State: 'GO'
                },

                title: 'Hospcom GO',
                description: 'Equipamentos Hospitalares'
            },
            
            {
                location: {
                    Street: 'R. Antônio Vieira, 76, Jardim Bela Vista',
                    City: 'Campo Grande',
                    State: 'MS'
                },

                title: 'Hospcom MS',
                description: 'Equipamentos Hospitalares'
            },
            
            {
                location: {
                    Street: '1245, SIG - Zona Industrial - Cruzeiro / Sudoeste / Octogonal',
                    City: 'Brasília',
                    State: 'DF'
                },

                title: 'Hospcom DF',
                description: 'Equipamentos Hospitalares'
            },
            
            {
                location: {
                    Street: 'Q. 103 Sul Rua SO 11, 47 - 02 - Plano Diretor Sul',
                    City: 'Palmas',
                    State: 'TO'
                },

                title: 'Hospcom TO',
                description: 'Equipamentos Hospitalares'
            },
        ]);
        cmp.set('v.zoomLevel', 4);
    }    
    
})