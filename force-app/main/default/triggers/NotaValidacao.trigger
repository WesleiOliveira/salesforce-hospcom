trigger NotaValidacao on Nota_fiscal_de_pedido_de_compra__c (before insert) {
    public Id pc {get; set;}
    
    for(Nota_fiscal_de_pedido_de_compra__c nota : Trigger.new){
        pc = nota.Pedido_de_compra__c;
    }
    
    if(!Util.IgnorarErros()){            
            Fornecedor__c pedido = [
                SELECT  Id, Contrato_de_compra__c
                FROM    Fornecedor__c
                WHERE   Id = : pc
            ];
            
            List<Nota_fiscal_de_pedido_de_compra__c> notas = [SELECT ID, Name, Valor_da_nota__c, Data_de_emissao__c, Pedido_de_compra__r.Name 
                                                              FROM Nota_fiscal_de_pedido_de_compra__c 
                                                              WHERE Contrato_de_compra__c =: pedido.Contrato_de_compra__c AND Contrato_de_compra__c != null];
            
            for(Nota_fiscal_de_pedido_de_compra__c nota : Trigger.new){
                if(notas.size()>0){
                    for(Nota_fiscal_de_pedido_de_compra__c nf : notas){
                        if(nota.Data_de_emissao__c == nf.Data_de_emissao__c){
                            nota.addError('Já existe uma nota lançada para esse período em um pedido vinculado a esse contrato. Número do pedido de compra: ' + nf.Pedido_de_compra__r.Name);
                        }
                        else if(nota.Name == nf.Name){
                            nota.addError('Já existe uma nota com esse número em um pedido vinculado a esse contrato. Número do pedido de compra: ' + nf.Pedido_de_compra__r.Name);
                        }
                    }
                }             
            }
    }
}