public class AprovacoesController {
    public List <ProcessInstance> aprovacoesPend {get;set;}
    public ID aprovId {get;set;}
    
    public AprovacoesController(){
        aprovacoesPend = [SELECT Id, status, TargetObjectId, TargetObject.Type, ProcessDefinitionId, CreatedById, CreatedDate, (SELECT Id, ActorId, ProcessInstanceId FROM Workitems) FROM ProcessInstance WHERE Status = 'Pending' and ID IN (SELECT ProcessInstanceId FROM ProcessInstanceWorkItem WHERE ActorId =: SYSTEM.UserInfo.getUserId())];
    }
    public pageReference aprovarInd(){
        
        List<ProcessInstanceWorkitem> workItems = [
         SELECT Id, ProcessInstanceId 
        FROM ProcessInstanceWorkitem 
            WHERE ProcessInstanceId =: aprovId
                ];
        List<Approval.ProcessWorkitemRequest> requests = new List<Approval.ProcessWorkitemRequest>();
                for(ProcessInstanceWorkitem workItem : workItems){
                Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
                req.setWorkitemId(workItem.Id);
                req.setAction('Approve');
                requests.add(req);
                }
                Approval.ProcessResult[] processResults = Approval.process(requests);
        PageReference pr = new PageReference('/apex/Aprovacoes');
                                pr.setRedirect(true);
                                return pr;
        }
    
    public void reprovarInd(){
        
        List<ProcessInstanceWorkitem> workItems = [
         SELECT Id, ProcessInstanceId 
        FROM ProcessInstanceWorkitem 
            WHERE ProcessInstanceId =: aprovId
                ];
        List<Approval.ProcessWorkitemRequest> requests = new List<Approval.ProcessWorkitemRequest>();
                for(ProcessInstanceWorkitem workItem : workItems){
                Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
                req.setWorkitemId(workItem.Id);
                req.setAction('Reject');
                requests.add(req);
                }
                Approval.ProcessResult[] processResults = Approval.process(requests);
        }
    
    public void AprovarTodos(){
        
        List<ProcessInstanceWorkitem> workItems = [
         SELECT Id, ProcessInstanceId 
        FROM ProcessInstanceWorkitem 
            WHERE ProcessInstanceId =: aprovId
                ];
        List<Approval.ProcessWorkitemRequest> requests = new List<Approval.ProcessWorkitemRequest>();
                for(ProcessInstanceWorkitem workItem : workItems){

                }
                Approval.ProcessResult[] processResults = Approval.process(requests);
        }
}