@isTest
public class WhatsAppIntegrationTEST {

    @isTest
    public static void teste(){
        WhatsAppIntegration.IsWhatsAppJson iwaj = new WhatsAppIntegration.IsWhatsAppJson();
        iwaj.setClient_number('556232415555@c.us');
        
        WhatsAppIntegration.StartFormJson sfj = new WhatsAppIntegration.StartFormJson();
        sfj.setClient_number('556232415555@c.us');
        sfj.setForm_id(1);
        sfj.setForm_number('1');
        
        WhatsAppIntegration.formatWhatsAppNumber('62900000000');
        WhatsAppIntegration.setNineNumber('99984919854');

        
    }
    
}