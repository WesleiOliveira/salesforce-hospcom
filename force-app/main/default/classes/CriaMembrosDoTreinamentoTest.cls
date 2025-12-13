@IsTest
public class CriaMembrosDoTreinamentoTest {
    @IsTest
    public static void teste() {
        
        List <String> ids = new List<String>();
        List<Map<String, String>> listaDeMapas = new List<Map<String, String>>();

List<Object> arrayDeObjs = new List<Object>{
    new Map<String, Object>{
        'Id' => '0036e00004Hl2lkAAB',
        'Name' => 'Adelson Souza de Macedo',
        'FirstName' => 'Adelson',
        'LastName' => 'Souza de Macedo',
        'Colaborador_ativo__c' => true,
        'AccountId' => '001i00000085QYbAAM',
        'Email' => 'adelsonsouzademacedo@gmail.com',
        'Title' => 'Motorista',
        'CPF__c' => '003.380.395-11',
        'Account' => new Map<String, String>{
            'Name' => 'HOSPCOM',
            'Id' => '001i00000085QYbAAM'
        }
    },
    new Map<String, Object>{
        'Id' => '0036e00004FczvvAAB',
        'Name' => 'Adevaldo Dos Santos Andrade',
        'FirstName' => 'Adevaldo',
        'LastName' => 'Dos Santos Andrade',
        'Colaborador_ativo__c' => true,
        'AccountId' => '001i00000085QYbAAM',
        'Email' => 'adevaldo.andrade@hospcom.net',
        'Title' => 'Instrumentador Cirúrgico',
        'CPF__c' => '804.885.012-53',
        'Account' => new Map<String, String>{
            'Name' => 'HOSPCOM',
            'Id' => '001i00000085QYbAAM'
        }
    },
    new Map<String, Object>{
        'Id' => '0036e00004AXAJhAAP',
        'Name' => 'Adrian Arantes',
        'FirstName' => 'Adrian',
        'LastName' => 'Arantes',
        'Colaborador_ativo__c' => true,
        'AccountId' => '001i00000085QYbAAM',
        'Email' => 'adriangerber@live.com',
        'Title' => 'Assistente de Facilites I',
        'CPF__c' => '750.178.141-91',
        'Account' => new Map<String, String>{
            'Name' => 'HOSPCOM',
            'Id' => '001i00000085QYbAAM'
        }
    },
    new Map<String, Object>{
        'Id' => '0036e00004IuX8lAAF',
        'Name' => 'Adriano Silva de Brito',
        'FirstName' => 'Adriano',
        'LastName' => 'Silva de Brito',
        'Colaborador_ativo__c' => true,
        'AccountId' => '001i00000085QYbAAM',
        'Email' => 'compras02@hospcom.net',
        'Title' => 'Analista de Compras II',
        'CPF__c' => '832.064.691-04',
        'Account' => new Map<String, String>{
            'Name' => 'HOSPCOM',
            'Id' => '001i00000085QYbAAM'
        }
    }
};

for (Object obj : arrayDeObjs) {
    Map<String, String> mapa = new Map<String, String>();
    for (String key : ((Map<String, Object>)obj).keySet()) {
        if (((Map<String, Object>)obj).get(key) instanceof String) {
            mapa.put(key, (String)((Map<String, Object>)obj).get(key));
        }
    }
    listaDeMapas.add(mapa);
    CriaMembrosDoTreinamento.gambiarra();
        CriaMembrosDoTreinamento.criaMembros(listaDeMapas, '701U4000000Vy81IAC');
}

        
        
        
        
    }
}