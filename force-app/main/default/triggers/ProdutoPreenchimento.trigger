trigger ProdutoPreenchimento on Product2 (before insert) {

    // seta dados iniciais
    Boolean buscar = false;
    
    for(Product2 produto : Trigger.new){
    
        // código hospcom vazio pt1
        if(Trigger.isInsert || (Trigger.isUpdate && produto.StockKeepingUnit == null)){
            buscar = true;
            break;
        }
        
    }
    
    // código hospcom vazio pt2
    if(buscar){
        List<Product2> ultimo_produto = [
            SELECT   StockKeepingUnit
            FROM     Product2
            WHERE    StockKeepingUnit != null
            ORDER BY StockKeepingUnit DESC
            LIMIT    1
        ];
        Integer ultimo_valor = ultimo_produto.size()!=1 ? 0 : Integer.ValueOf(ultimo_produto[0].StockKeepingUnit);
        for(Product2 produto : Trigger.new)
            if(Trigger.isInsert || (Trigger.isUpdate && produto.StockKeepingUnit == null))
                produto.StockKeepingUnit = String.valueOf(++ultimo_valor).leftPad(8,'0');
    }
    
}