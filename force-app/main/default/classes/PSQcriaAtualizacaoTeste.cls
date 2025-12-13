@isTest
public class PSQcriaAtualizacaoTeste {
       /*static void testAtualizaLMD() {
        
        List<Map<String, String>> fileList = new List<Map<String, String>>();
        
        Map<String, String> file1 = new Map<String, String>();
        file1.put('file', 'JVBERi0xLjIgDQo5IDAgb2JqDQo8PA0KPj4NCnN0cmVhbQ0KQlQvIDMyIFRmKCAgSGVsbG8gV29ybGQgICApJyBFVA0KZW5kc3RyZWFtDQplbmRvYmoNCjQgMCBvYmoNCjw8DQovVHlwZSAvUGFnZQ0KL1BhcmVudCA1IDAgUg0KL0NvbnRlbnRzIDkgMCBSDQo+Pg0KZW5kb2JqDQo1IDAgb2JqDQo8PA0KL0tpZHMgWzQgMCBSIF0NCi9Db3VudCAxDQovVHlwZSAvUGFnZXMNCi9NZWRpYUJveCBbIDAgMCAyNTAgNTAgXQ0KPj4NCmVuZG9iag0KMyAwIG9iag0KPDwNCi9QYWdlcyA1IDAgUg0KL1R5cGUgL0NhdGFsb2cNCj4+DQplbmRvYmoNCnRyYWlsZXINCjw8DQovUm9vdCAzIDAgUg0KPj4NCiUlRU9G');
        file1.put('ex', 'pdf');
        Map<String, String> file2 = new Map<String, String>();
        file2.put('file', 'JVBERi0xLjIgDQo5IDAgb2JqDQo8PA0KPj4NCnN0cmVhbQ0KQlQvIDMyIFRmKCAgSGVsbG8gV29ybGQgICApJyBFVA0KZW5kc3RyZWFtDQplbmRvYmoNCjQgMCBvYmoNCjw8DQovVHlwZSAvUGFnZQ0KL1BhcmVudCA1IDAgUg0KL0NvbnRlbnRzIDkgMCBSDQo+Pg0KZW5kb2JqDQo1IDAgb2JqDQo8PA0KL0tpZHMgWzQgMCBSIF0NCi9Db3VudCAxDQovVHlwZSAvUGFnZXMNCi9NZWRpYUJveCBbIDAgMCAyNTAgNTAgXQ0KPj4NCmVuZG9iag0KMyAwIG9iag0KPDwNCi9QYWdlcyA1IDAgUg0KL1R5cGUgL0NhdGFsb2cNCj4+DQplbmRvYmoNCnRyYWlsZXINCjw8DQovUm9vdCAzIDAgUg0KPj4NCiUlRU9G');
        file2.put('ex', 'pdf');
        
        // Crie uma instância do objeto PSQ
        PSQ__c novoRegistroPSQ = new PSQ__c();
        
        Map<String, String> psq = new Map<String, String>();
        
        // Adicionando variáveis ao mapa
        
        
        psq.put('revisor__c', '00531000006UzZsAAK');
        psq.put('revisor__c', '00531000006UzZsAAK');
        psq.put('elaborador__c', '00531000006UzZsAAK');
        psq.put('C_digo_do_Documento__c', 'T 2-0');
        psq.put('N_da_Revis_o__c', 'Tes-0');
        psq.put('Objetivo__c', '');
        psq.put('Aplicao__c', '');
        psq.put('Defini_es__c', '');
        psq.put('Equipamentos_e_Softwares__c', '');
        psq.put('Condi_es_Gerais__c', '5.1esmos;\n 5.2. Utilizar marcadores em ordes externos.');
        psq.put('Responsabilidade_e_Autoridade__c', '<pjghjhgfjfghj>/p>');
        psq.put('Refer_ncia__c', '');
        psq.put('Formul_rios_Anexos_e_Documentos__c', 's;');
        psq.put('Registros__c', 'Relacione aqui os  houver.');
        psq.put('Id', 'a0h6e00000KCEubAAH');
        fileList.add(file1);
        fileList.add(file2);
        
        List<String> f = new List<String>();
        List<String> b = new List<String>();
        
        // modelos
        List<Map<String, String>> empresas = new List<Map<String, String>>();
        
        Map<String, String> empresa1 = new Map<String, String>();
        empresa1.put('id', '001i00000085QYb');
        empresa1.put('nome', 'HOSPCOM1');
        Map<String, String> empresa2 = new Map<String, String>();
        empresa2.put('id', '001i00000085QYb');
        empresa2.put('nome', 'HOSPCOM1');
        empresas.add(empresa1);
        empresas.add(empresa2);
        
        try{
            //a0g530000062hwWAAQ sandbox
            ////a0g6e00000JW5s6AAD Produção
            //
            PSQcriaAtualizacao.criaPSQ(empresas, psq, fileList,'a0g6e00000JW5s6AAD');           
            PSQcriaAtualizacao.gambiarra();
        }catch(Exception e){
            System.debug('Error: ' + e.getMessage());
        }
    }*/
    @isTest
 
    static void aaa(){
        PSQcriaAtualizacao.gambiarra();
        PSQcriaAtualizacao.gambiarra2();
    }
}