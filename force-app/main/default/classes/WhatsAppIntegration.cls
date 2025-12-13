public class WhatsAppIntegration {

    @future(callout=true)
    public static void isWhatsApp(Integer form, String clientNumber, String orderNumber){
        String res, method = 'POST', url = 'http://177.153.60.164:3000/isWhatsApp';
        
        IsWhatsAppJson iwa = new IsWhatsAppJson();
        iwa.setClient_number(formatWhatsAppNumber(clientNumber));
        String body = SYSTEM.JSON.serialize(iwa);
        
        Map<String, String> header = new Map<String, String>();
        header.put('Accept', 'application/json, text/plain, */*');
        header.put('Content-Type', 'application/json;charset=utf-8');

        HttpConsult req = new HttpConsult();
		res = req.request(url, method, body, header);
        
        Map<String, Object> mapJson = (Map<String, Object>)JSON.deserializeUntyped(res); 

        if(mapJson.get('status') == 'success' && mapJson.get('data') == true){
            startForm(form, formatWhatsAppNumber(clientNumber), orderNumber);
        }
    }
    
    public static void startForm(Integer form, String clientNumber, String orderNumber){
        String res, method = 'POST', url = 'http://177.153.60.164:3000/startform';
        
        StartFormJson sfj = new StartFormJson();
        sfj.setClient_number(clientNumber);
        sfj.setForm_id(form);
        sfj.setForm_number(orderNumber);
        String body = SYSTEM.JSON.serialize(sfj);

        Map<String, String> header = new Map<String, String>();
        header.put('Accept', 'application/json, text/plain, */*');
        header.put('Content-Type', 'application/json;charset=utf-8');

        HttpConsult req = new HttpConsult();
		res = req.request(url, method, body, header);
    }
    
    Public Static String formatWhatsAppNumber(String clientNumber){
        clientNumber = clientNumber.replaceAll('[^a-zA-Z0-9+]', '');
		clientNumber = setNineNumber(clientNumber);
        clientNumber = '55' + clientNumber + '@c.us';
		return clientNumber;
    }
    
    Public Static String setNineNumber(String clientNumber){
        if(clientNumber.length() <= 10){
            return clientNumber;
        }
		
        String DDD = clientNumber.substring(0,2);
        switch on DDD {
            when '11' { return clientNumber; }
            when '12' { return clientNumber; }
            when '13' { return clientNumber; }
            when '14' { return clientNumber; }
            when '15' { return clientNumber; }
            when '16' { return clientNumber; }
            when '17' { return clientNumber; }
            when '18' { return clientNumber; }
            when '19' { return clientNumber; }
            when '21' { return clientNumber; }
            when '22' { return clientNumber; }
            when '24' { return clientNumber; }
            when '27' { return clientNumber; }
            when '28' { return clientNumber; }
            when '31' { return clientNumber.substring(0,2) + clientNumber.substring(3,11); }
            when '32' { return clientNumber.substring(0,2) + clientNumber.substring(3,11); }
            when '33' { return clientNumber.substring(0,2) + clientNumber.substring(3,11); }
            when '34' { return clientNumber.substring(0,2) + clientNumber.substring(3,11); }
            when '35' { return clientNumber.substring(0,2) + clientNumber.substring(3,11); }
            when '37' { return clientNumber.substring(0,2) + clientNumber.substring(3,11); }
            when '38' { return clientNumber.substring(0,2) + clientNumber.substring(3,11); }
            when '41' { return clientNumber.substring(0,2) + clientNumber.substring(3,11); }
            when '42' { return clientNumber.substring(0,2) + clientNumber.substring(3,11); }
            when '43' { return clientNumber.substring(0,2) + clientNumber.substring(3,11); }
            when '44' { return clientNumber.substring(0,2) + clientNumber.substring(3,11); }
            when '45' { return clientNumber.substring(0,2) + clientNumber.substring(3,11); }
            when '46' { return clientNumber.substring(0,2) + clientNumber.substring(3,11); }
            when '47' { return clientNumber.substring(0,2) + clientNumber.substring(3,11); }
            when '48' { return clientNumber.substring(0,2) + clientNumber.substring(3,11); }
            when '49' { return clientNumber.substring(0,2) + clientNumber.substring(3,11); }
            when '51' { return clientNumber.substring(0,2) + clientNumber.substring(3,11); }
            when '53' { return clientNumber.substring(0,2) + clientNumber.substring(3,11); }
            when '54' { return clientNumber.substring(0,2) + clientNumber.substring(3,11); }
            when '55' { return clientNumber.substring(0,2) + clientNumber.substring(3,11); }
            when '61' { return clientNumber.substring(0,2) + clientNumber.substring(3,11); }
            when '62' { return clientNumber.substring(0,2) + clientNumber.substring(3,11); }
            when '63' { return clientNumber.substring(0,2) + clientNumber.substring(3,11); }
            when '64' { return clientNumber.substring(0,2) + clientNumber.substring(3,11); }
            when '65' { return clientNumber.substring(0,2) + clientNumber.substring(3,11); }
            when '66' { return clientNumber.substring(0,2) + clientNumber.substring(3,11); }
            when '67' { return clientNumber.substring(0,2) + clientNumber.substring(3,11); }
            when '68' { return clientNumber.substring(0,2) + clientNumber.substring(3,11); }
            when '69' { return clientNumber.substring(0,2) + clientNumber.substring(3,11); }
            when '71' { return clientNumber.substring(0,2) + clientNumber.substring(3,11); }
            when '73' { return clientNumber.substring(0,2) + clientNumber.substring(3,11); }
            when '74' { return clientNumber.substring(0,2) + clientNumber.substring(3,11); }
            when '75' { return clientNumber.substring(0,2) + clientNumber.substring(3,11); }
            when '77' { return clientNumber.substring(0,2) + clientNumber.substring(3,11); }
            when '79' { return clientNumber.substring(0,2) + clientNumber.substring(3,11); }
            when '81' { return clientNumber.substring(0,2) + clientNumber.substring(3,11); }
            when '82' { return clientNumber.substring(0,2) + clientNumber.substring(3,11); }
            when '83' { return clientNumber.substring(0,2) + clientNumber.substring(3,11); }
            when '84' { return clientNumber.substring(0,2) + clientNumber.substring(3,11); }
            when '85' { return clientNumber.substring(0,2) + clientNumber.substring(3,11); }
            when '86' { return clientNumber.substring(0,2) + clientNumber.substring(3,11); }
            when '87' { return clientNumber.substring(0,2) + clientNumber.substring(3,11); }
            when '88' { return clientNumber.substring(0,2) + clientNumber.substring(3,11); }
            when '89' { return clientNumber.substring(0,2) + clientNumber.substring(3,11); }
            when '91' { return clientNumber.substring(0,2) + clientNumber.substring(3,11); }
            when '92' { return clientNumber.substring(0,2) + clientNumber.substring(3,11); }
            when '93' { return clientNumber.substring(0,2) + clientNumber.substring(3,11); }
            when '94' { return clientNumber.substring(0,2) + clientNumber.substring(3,11); }
            when '95' { return clientNumber.substring(0,2) + clientNumber.substring(3,11); }
            when '96' { return clientNumber.substring(0,2) + clientNumber.substring(3,11); }
            when '97' { return clientNumber.substring(0,2) + clientNumber.substring(3,11); }
            when '98' { return clientNumber.substring(0,2) + clientNumber.substring(3,11); }
            when '99' { return clientNumber.substring(0,2) + clientNumber.substring(3,11); }
            when else { return clientNumber.substring(0,2) + clientNumber.substring(3,11); }
        }
    }
    
    Public Class IsWhatsAppJson {
        Private String client_number;
                
        Public void setClient_number(String client_number){
            this.client_number = client_number;
        }
    }
    
    Public Class StartFormJson{
        Private String client_number;
        Private Integer form_id;
        Private String form_number;
                
        Public void setClient_number(String client_number){
            this.client_number = client_number;
        }
        
        Public Void setForm_id(Integer form_id){
            this.form_id = form_id;
        }

        Public Void setForm_number(String form_number){
            this.form_number = form_number;
        }

    }

}