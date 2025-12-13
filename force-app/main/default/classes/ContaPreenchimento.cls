public class ContaPreenchimento {
    
    @future(callout=true)
    public static void ChamarReceita(Id conta_id, String conta_cnpj){
        Http                    protocolo   = new Http();
        HttpRequest             requisicao  = new HttpRequest();
        HttpResponse            resposta;
        ContaReceitaJSON2Apex   conta_json;
        String                  resultado = null;
        
        // requisita dados ao ws
        requisicao.setEndPoint('https://www.receitaws.com.br/v1/cnpj/' + conta_cnpj.replace('/', '').replace('.', '').replace('-', ''));
        requisicao.setMethod('GET');
        if(!Test.isRunningTest())
            resposta = protocolo.send(requisicao);
        else{
            resposta = new HttpResponse();
            resposta.setBody('{\"status\": \"OK\", \"natureza_juridica\": \"230-5\", \"nome\": \"HOSPCOM\", \"uf\": \"GO\", '+
                              '\"telefone\": \"(62) 3241-5555\", \"municipio\": \"GOIÂNIA\", \"fantasia\": \"HOSPCOM\", '+
                              '\"atividade_principal\": [{\"text\": \"text\", \"code\": \"code\"}], ' +
                              '\"atividades_secundarias\": [{\"text\": \"text\", \"code\": \"code\"}]}');
        }
        conta_json = (ContaReceitaJSON2Apex)JSON.deserialize(resposta.getBody(), ContaReceitaJSON2Apex.class);
        
        // atualiza dados
        Account conta = [
            SELECT  Id, Name, Raz_o_Social__c, Ownership, Phone, Description, BillingCountry,
                    BillingStreet, BillingCity, BillingState, BillingPostalCode, Status_receita__c
            FROM    Account
            WHERE   Id = :conta_id
        ];
        
        if(conta_json.status != 'OK')
            conta.Status_receita__c = 'ERRO - ' + conta_json.message;
        else{
            
            // campo "Nome da conta" (fantasia)
            //if(conta_json.fantasia != '')
            //  conta.Name = conta_json.fantasia.toUpperCase();
            //else
            //  conta.Name = conta_json.nome.toUpperCase();
            
            // campo "Razão Social"
            if(conta_json.nome != '')
                conta.Raz_o_Social__c = conta_json.nome.toUpperCase();
    
            // campo "Propriedade"
            if(conta_json.natureza_juridica != ''){
                if(conta_json.natureza_juridica.substring(0,1) == '1')
                    conta.Ownership = 'PUBLICO';
                else if(conta_json.natureza_juridica.substring(0,1) == '2')
                    conta.Ownership = 'PRIVADO';
                else if(conta_json.natureza_juridica.substring(0,1) == '3')
                    conta.Ownership = 'FILANTROPIA';
            }
            
            // campo "Telefone"
            if(conta.Phone == null && conta_json.telefone != ''){
                if((resultado = Util.ValidarTelefone(conta_json.telefone.replace(' / ', ', '), conta_cnpj)) == null)
                    conta.Phone = conta_json.telefone.replace(' / ', ', ');
            }
            
            // campo "Descrição" (atividades)
            if(conta_json.atividade_principal != null && conta_json.atividade_principal.size()>0){
                conta.Description = 'CÓDIGO E DESCRIÇÃO DA ATIVIDADE ECONÔMICA PRINCIPAL:\n';
                for(ContaReceitaJSON2Apex.Atividade_principal atividade : conta_json.atividade_principal)
                    conta.Description += atividade.code + ' - ' + atividade.text + '\n';
            }
            if(conta_json.atividades_secundarias != null && conta_json.atividades_secundarias.size()>0){
                if(conta_json.atividade_principal.size()>0)
                    conta.Description += '\n';
                conta.Description += 'CÓDIGO E DESCRIÇÃO DAS ATIVIDADES ECONÔMICAS SECUNDÁRIAS:\n';
                for(ContaReceitaJSON2Apex.Atividade_principal atividade : conta_json.atividades_secundarias)
                    conta.Description += atividade.code + ' - ' + atividade.text + '\n';
            }
            if(conta.Description!=null)
                conta.Description = conta.Description.toUpperCase();
            
            // campo "Endereço de Cobrança"
            if(conta_json.municipio != ''){
                List<String> endereco = new list<String>();
                if(conta_json.logradouro!='')   endereco.add(conta_json.logradouro);
                if(conta_json.numero!='')       endereco.add(conta_json.numero);
                if(conta_json.complemento!='')  endereco.add(conta_json.complemento);
                if(conta_json.bairro!='')       endereco.add(conta_json.bairro);
                if(endereco.size()>0)
                    conta.BillingStreet = String.join(endereco, ', ').toUpperCase();
               conta.BillingCity = removerAcentos(conta_json.municipio)
        .replaceAll('[^a-zA-Z0-9\\s]', '')
        .toUpperCase();
                conta.BillingPostalCode = conta_json.cep;
                conta.BillingCountry    = 'BRASIL';
                conta.BillingState      = Util.ConverterEstado(conta_json.uf, 'nome').toUpperCase();
            }
            conta.Status_receita__c = 'SUCESSO';
        }
        
        integracaoSAP.logIntegracaoSap(conta + '\n\n\n' + conta_json, 'ContaPreenchimento');
        
        update conta;
    }
    private static String removerAcentos(String texto) {
    if(String.isBlank(texto)) return texto;
    
    String resultado = texto;
    resultado = resultado.replace('á', 'a').replace('à', 'a').replace('â', 'a').replace('ã', 'a');
    resultado = resultado.replace('é', 'e').replace('è', 'e').replace('ê', 'e');
    resultado = resultado.replace('í', 'i').replace('ì', 'i').replace('î', 'i');
    resultado = resultado.replace('ó', 'o').replace('ò', 'o').replace('ô', 'o').replace('õ', 'o');
    resultado = resultado.replace('ú', 'u').replace('ù', 'u').replace('û', 'u');
    resultado = resultado.replace('ç', 'c');
    resultado = resultado.replace('ñ', 'n');
    
    // Maiúsculas
    resultado = resultado.replace('Á', 'A').replace('À', 'A').replace('Â', 'A').replace('Ã', 'A');
    resultado = resultado.replace('É', 'E').replace('È', 'E').replace('Ê', 'E');
    resultado = resultado.replace('Í', 'I').replace('Ì', 'I').replace('Î', 'I');
    resultado = resultado.replace('Ó', 'O').replace('Ò', 'O').replace('Ô', 'O').replace('Õ', 'O');
    resultado = resultado.replace('Ú', 'U').replace('Ù', 'U').replace('Û', 'U');
    resultado = resultado.replace('Ç', 'C');
    resultado = resultado.replace('Ñ', 'N');
    
    return resultado;
    }
    
    }