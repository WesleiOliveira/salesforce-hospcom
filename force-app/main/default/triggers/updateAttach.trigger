trigger updateAttach on Attachment (after insert) {
Map<Id, Id> mapCSId = new map<Id, Id>();
    List<Recrutamento__c> lstCSUpdate = new List<Recrutamento__c>();
    String objectName = '';
    for(Attachment atc: trigger.new){
        String myIdPrefix = string.valueOf(atc.ParentId).substring(0,3);
        Map<String, Schema.SObjectType> gd =  Schema.getGlobalDescribe(); 
        for(Schema.SObjectType stype : gd.values()){
            Schema.DescribeSObjectResult r = stype.getDescribe();
            String prefix = r.getKeyPrefix();
            if(prefix!=null && prefix.equals(myIdPrefix)){
                objectName = r.getName();
            }
        }
        if(objectName == 'Recrutamento__c'){
            mapCSId.put(atc.ParentId, atc.id);
        }
    }
    if(!mapCSId.isEmpty()){
        List<Recrutamento__c> updateAtt = [select id from Recrutamento__c where id in: mapCSId.keyset()];
        for(Recrutamento__c cs: updateAtt){
            cs.AttachmentId__c = mapCSId.get(cs.id);
        }
        if(!updateAtt.isEmpty()){
            update updateAtt;
        }
    }
}