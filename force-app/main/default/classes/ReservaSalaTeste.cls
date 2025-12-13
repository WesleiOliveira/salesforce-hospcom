@isTest(seeAllData=true)
public class ReservaSalaTeste {

    @isTest
    private static void teste(){

        Datetime dataInicio = Datetime.newInstance(2022, 12, 10, 12, 11, 11);
        Datetime dataTermino = Datetime.newInstance(2022, 12, 10, 12, 15, 15);

        Datetime dataInicio2 = Datetime.newInstance(2024, 12, 12, 12, 11, 11);
        Datetime dataTermino2 = Datetime.newInstance(2024, 12, 12, 12, 15, 15);

        Datetime dataInicio3 = Datetime.newInstance(2024, 12, 11, 12, 11, 11);
        Datetime dataTermino3 = Datetime.newInstance(2024, 12, 11, 12, 15, 15);
        
        
        Datetime dataInicio4 = Datetime.newInstance(2024, 03, 19, 19, 11, 11);
        Datetime dataTermino4 = Datetime.newInstance(2024, 03, 20, 19, 15, 15);

        Account a = new Account();
        a.Name = 'Teste';
        a.CNPJ__c = '51.461.458/0001-89';
         try{ 
             insert a;
             
        	 
         } catch (Exception e) {
            System.debug('Exceção ao criar reserva que se choca com a primeira: ' + e.getMessage());
        }
       

        Reserva_de_Sala__c rSala  = new Reserva_de_Sala__c();
        rSala.Sala__c = 'Showroom';
        rSala.In_cio__c = dataInicio;
        rSala.Termino__c = dataTermino;
        try{
        	insert rSala;
         } catch (Exception e) {
            System.debug('Exceção ao criar reserva que se choca com a primeira: ' + e.getMessage());
        }
        Reserva_de_Sala__c rSala2  = new Reserva_de_Sala__c();
        rSala2.Sala__c = 'Showroom';
        rSala2.In_cio__c = dataInicio2;
        rSala2.Termino__c = dataTermino2;
       
         try{
        	 insert rSala2;
             
             rSala2.In_cio__c = Datetime.newInstance(2024, 12, 12, 12, 17, 15);
             
             update rSala2;
         } catch (Exception e) {
            System.debug('Exceção ao criar reserva que se choca com a primeira: ' + e.getMessage());
        }

        Reserva_de_Sala__c rSala3  = new Reserva_de_Sala__c();
        rSala3.Sala__c = 'Showroom';
        rSala3.In_cio__c = dataInicio3;
        rSala3.Termino__c = dataTermino3;
         try{
        	 insert rSala3;
         } catch (Exception e) {
            System.debug('Exceção ao criar reserva que se choca com a primeira: ' + e.getMessage());
        }
        

        // Tentando criar uma reserva que ultrapassa um dia
        try {
            Reserva_de_Sala__c rSalaMaisDeUmDia  = new Reserva_de_Sala__c();
            rSalaMaisDeUmDia.Sala__c = 'Showroom';
            rSalaMaisDeUmDia.In_cio__c = Datetime.newInstance(2024, 12, 13, 12, 0, 0);
            rSalaMaisDeUmDia.Termino__c = Datetime.newInstance(2024, 12, 14, 12, 15, 0);
            insert rSalaMaisDeUmDia;
        } catch (Exception e) {
            System.debug('Exceção ao criar reserva que ultrapassa um dia: ' + e.getMessage());
        }

        // Atualizando a primeira reserva para verificar conflitos
        try {
            rSala.In_cio__c = dataInicio3;
            rSala.Termino__c = dataTermino3;
            update rSala;
        } catch (Exception e) {
            System.debug('Exceção ao atualizar a reserva: ' + e.getMessage());
        }
        
        //Teste sucesso
        try {
       		Reserva_de_Sala__c rSala4  = new Reserva_de_Sala__c();
            rSala4.In_cio__c = dataInicio4;
            rSala4.Termino__c = dataTermino4;
            insert rSala4;
        } catch (Exception e) {
            System.debug('Exceção ao atualizar a reserva: ' + e.getMessage());
        }

        // Tentando criar uma reserva que se choca com a primeira
        try {
            Reserva_de_Sala__c rSalaConflito  = new Reserva_de_Sala__c();
            rSalaConflito.Sala__c = 'Showroom';
            rSalaConflito.In_cio__c = dataInicio2;
            rSalaConflito.Termino__c = dataTermino2;
            insert rSalaConflito;
            
            System.debug('------------ Reserva salva  -----------------------');
            
        } catch (Exception e) {
            System.debug('---------------------------------- ' + e.getMessage());
        }
    }
    
    @isTest
    private static void teste2(){
        Reserva_de_Sala__c rs = [
            SELECT id, name, Sala__c, In_cio__c, Status__c, Termino__c,Frequencia__c,recorrencia__c,Reserva_recorrente__c, RecordType.name
            FROM Reserva_de_Sala__c 
            WHERE Status__c != 'Finalizado' AND Status__c != 'Reprovado'  AND Frequencia__c != null
            LIMIT 1
        ]; 
        
        try{ 
            
            System.debug('rs: ' + rs);
            Reserva.criaRecorrencia(rs); // Chamada para criar recorrência
            
        }catch (Exception e) {
            System.debug('Erro ao criar recorrência: ' + e.getMessage());
        }
        
    }
}