trigger OT_ANEXOS on WorkOrder (before insert, before update) {

    Set<Id> recordTypeOnlyPDF = new Set<Id>{ '01231000000taxXAAQ' };
    Set<Id> recordTypeBothRequired = new Set<Id>{ '01231000001NYkSAAW' };
    Set<Id> validRecordTypeIds = new Set<Id>();
    validRecordTypeIds.addAll(recordTypeOnlyPDF);
    validRecordTypeIds.addAll(recordTypeBothRequired);

    Set<Id> workOrderIds = new Set<Id>();

    for (WorkOrder wo : Trigger.new) {
        if (wo.Status == 'FECHADO CONCLUÍDO' &&
            validRecordTypeIds.contains(wo.RecordTypeId) &&
            (Trigger.isInsert || (Trigger.isUpdate && wo.Status != Trigger.oldMap.get(wo.Id).Status))
        ) {
            workOrderIds.add(wo.Id);
        }
    }

    if (!workOrderIds.isEmpty()) {
        List<ContentDocumentLink> documentLinks = [
            SELECT ContentDocumentId, LinkedEntityId 
            FROM ContentDocumentLink 
            WHERE LinkedEntityId IN :workOrderIds
        ];

        Set<Id> documentIds = new Set<Id>();
        Map<Id, List<ContentDocumentLink>> workOrderToDocumentLinks = new Map<Id, List<ContentDocumentLink>>();

        for (ContentDocumentLink link : documentLinks) {
            documentIds.add(link.ContentDocumentId);

            if (!workOrderToDocumentLinks.containsKey(link.LinkedEntityId)) {
                workOrderToDocumentLinks.put(link.LinkedEntityId, new List<ContentDocumentLink>());
            }
            workOrderToDocumentLinks.get(link.LinkedEntityId).add(link);
        }

        Map<Id, ContentDocument> documents = new Map<Id, ContentDocument>(
            [SELECT Id, FileType FROM ContentDocument WHERE Id IN :documentIds]
        );

        for (WorkOrder wo : Trigger.new) {
            List<String> errors = new List<String>();
            Boolean possuiImagem = false;
            Boolean possuiPDF = false;

            if (workOrderToDocumentLinks.containsKey(wo.Id)) {
                for (ContentDocumentLink link : workOrderToDocumentLinks.get(wo.Id)) {
                    ContentDocument doc = documents.get(link.ContentDocumentId);
                    if (doc != null) {
                        if (doc.FileType.toUpperCase() == 'PNG' || doc.FileType.toUpperCase() == 'JPG' || doc.FileType.toUpperCase() == 'JPEG') {
                            possuiImagem = true;
                        } else if (doc.FileType.toUpperCase() == 'PDF') {
                            possuiPDF = true;
                        }
                    }
                }
            }

            if (recordTypeOnlyPDF.contains(wo.RecordTypeId)) {
                if (!possuiPDF && !possuiImagem) {
                    errors.add('A ordem de trabalho deve ter o documento da OT anexado em PDF ou Imagem.');
                }
            } else if (recordTypeBothRequired.contains(wo.RecordTypeId)) {
                if (!possuiImagem && !possuiPDF) {
                   
                     errors.add('A ordem de trabalho deve ter o documento da OT anexado em PDF ou Imagem.');
                }
                
            }

            if (!errors.isEmpty()) {
                wo.addError(String.join(errors, ' '));
            }
        }
    }
    
        String a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';
    a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';
	a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';
    a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';
	a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';
    a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';
 	a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';
    a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';
	a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';
	a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';
    a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';
	a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';
    a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';
 	a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';
    a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';
 	a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';
	a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';
    a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';
	a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';
    a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';
 	a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';
    a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';
	a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';
	a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';
    a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';
	a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';
    a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';
 	a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';
    a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';
 	a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';
	a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';
    a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';
	a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';
    a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';
 	a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';
    a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';
	a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';
	a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';
    a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';
	a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';
    a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';
 	a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';
    a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';a ='';
}