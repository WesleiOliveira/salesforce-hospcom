public class ApexTeste {
    public class Mensagem {
        public String titulo;
        public String conteudo;
        public String email;
    }

    public static void enviaMSG(String titulo, String conteudo, String email) {
        Mensagem msg = new Mensagem();
        msg.titulo = titulo;
        msg.conteudo = conteudo;
        msg.email = email;
        
        System.debug('MENSAGEM: ' + msg.titulo + ' ' + msg.conteudo + msg.email );
    }
}