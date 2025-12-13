@isTest
public class ChatPDF_Test {

    @isTest
    static void testeChatPDF() {
                    
        String key = 'sec_vexyaM9KizzGxNlRksUtYCnTfr2lcfmM';
        String doc = 'src_7oVFG8gjvHav5Hp6opADi';

        try{
        	String a = ChatPDF.sendMessage(doc,  key , 'Is the information contained in this manual subject to changes without prior notice?');
             // Test.setMock(HttpCalloutMock.class, new MonkChatPDF());
            System.debug('Resposta: '+ a);
        }catch(Exception e){
            System.debug('Error: '+ e);
        }

    }
}