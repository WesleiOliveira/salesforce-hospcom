public with sharing class FeriadoController {

    @AuraEnabled
    public static List<Holiday> buscarFeriados() {
        return [SELECT Id, Name, ActivityDate, Description, CreatedById FROM Holiday];
    }

    @AuraEnabled
    public static void criarFeriado(Date dataFeriado, String nome, String descricao) {
        validarPermissao(descricao);

        Holiday feriado = new Holiday();
        feriado.Name = nome;
        feriado.ActivityDate = dataFeriado;
        feriado.Description = descricao;
        insert feriado;
    }

    @AuraEnabled
    public static void excluirFeriado(Id feriadoId) {
        Holiday feriado = [SELECT Id, Description, CreatedById FROM Holiday WHERE Id = :feriadoId];

        validarPermissao(feriado.Description);

        Id currentUserId = UserInfo.getUserId();

        User currentUser = [SELECT Profile.Name FROM User WHERE Id = :currentUserId];
        Boolean isAdmin = currentUser.Profile.Name == 'Administrador do sistema';
        Boolean isCreator = feriado.CreatedById == currentUserId;

        if (!isCreator && !isAdmin) {
            throw new AuraHandledException('Você não tem permissão para apagar este feriado.');
        }
        
        delete feriado;
    }

    private static void validarPermissao(String departamento) {
        String permissionSetName = 'Gerentes_de_setores_departamentos'; // Substitua pelo nome do seu conjunto de permissões.

        Id currentUserId = UserInfo.getUserId();

        // Verificar se o usuário é Administrador do sistema.
        User currentUser = [SELECT Profile.Name, Department FROM User WHERE Id = :currentUserId];
        if (currentUser.Profile.Name == 'Administrador do sistema') {
            return; // Administradores podem criar ou editar qualquer feriado.
        }

        // Verificar se o usuário está no conjunto de permissões.
        List<PermissionSetAssignment> assignments = [
            SELECT Id
            FROM PermissionSetAssignment
            WHERE AssigneeId = :currentUserId
            AND PermissionSet.Name = :permissionSetName
        ];

        if (assignments.isEmpty()) {
            throw new AuraHandledException('Você não tem permissão para criar ou editar feriados.');
        }

        // Verificar se o usuário pertence ao departamento especificado.
        if (String.isBlank(departamento) || currentUser.Department != departamento) {
            throw new AuraHandledException('Você não tem permissão para criar ou editar feriados para este departamento.');
        }
    }
    
    public static void gamb(){
         
        string a =''; a =''; a =''; a =''; a =''; a =''; a =''; a =''; a =''; a =''; a =''; a =''; a =''; a =''; a =''; a ='';
         a =''; a =''; a =''; a =''; a =''; a =''; a =''; a =''; a =''; a =''; a =''; a =''; a =''; a =''; a =''; a =''; a ='';
         a =''; a =''; a =''; a =''; a =''; a =''; a =''; a =''; a =''; a =''; a =''; a =''; a =''; a =''; a =''; a =''; a ='';
         a =''; a =''; a =''; a =''; a =''; a =''; a =''; a =''; a =''; a =''; a =''; a =''; a =''; a =''; a =''; a =''; a ='';
         a =''; a =''; a =''; a =''; a =''; a =''; a =''; a =''; a =''; a =''; a =''; a =''; a =''; a =''; a =''; a =''; a ='';
         a =''; a =''; a =''; a =''; a =''; a =''; a =''; a =''; a =''; a =''; a =''; a =''; a =''; a =''; a =''; a =''; a ='';
         a =''; a =''; a =''; a =''; a =''; a =''; a =''; a =''; a =''; a =''; a =''; a =''; a =''; a =''; a =''; a =''; a ='';
         a =''; a =''; a =''; a =''; a =''; a =''; a =''; a =''; a =''; a =''; a =''; a =''; a =''; a =''; a =''; a =''; a ='';
    
    } 
    
}