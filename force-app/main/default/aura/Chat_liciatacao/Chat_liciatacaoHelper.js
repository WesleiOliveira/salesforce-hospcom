({
    mainFunction : function(cmp, event, helper) {
        helper.enviaMensagem(cmp,event,helper);
    }, 
    
    enviaMensagem:function(cmp,event,helper){
        
        
        $(document).ready(function() {
            var input = $("#message-input");
            var div =$('#send-button');
            
            // Ouvinte de evento para o input
            input.on("keydown", function(event) {
                // Verifica se a tecla pressionada é "Enter" (código de tecla 13)
                if (event.which === 13 && !event.shiftKey) {
                    // Dispara ação de clique na div
                    div.click();
                }
            });
            
            
        });
        
        
        
        var env_btn = $('#send-button');
        
        env_btn.click(function(){
            
            var chat_box_text = $("#message-input").val();
            
            
            
            $("#chat-messages").append('<div class="message user"  id="asd" data-aura-rendered-by="211:2;a">'+ chat_box_text + ' </div>');
            $("#message-input").val('');
            $("#chat-messages").scrollTop($("#chat-messages").height()+1000)
        });
    }
})