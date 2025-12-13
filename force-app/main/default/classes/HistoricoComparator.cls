public class HistoricoComparator implements Comparable {
    public HISTORICO_DE_REVISAO__c historicalRecord;

    public HistoricoComparator(HISTORICO_DE_REVISAO__c hr) {
        this.historicalRecord = hr;
    }

    public Integer compareTo(Object other) {
        HistoricoComparator otherRecord = (HistoricoComparator)other;
        if (historicalRecord.Data__c > otherRecord.historicalRecord.Data__c) {
            return 1;
        } else if (historicalRecord.Data__c < otherRecord.historicalRecord.Data__c) {
            return -1;
        } else {
            return 0;
        }
    }
}