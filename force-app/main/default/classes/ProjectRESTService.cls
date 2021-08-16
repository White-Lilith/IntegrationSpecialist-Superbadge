@RestResource(urlMapping = '/project/*')
global class ProjectRESTService {
    //Implement service logic here
    @HttpPost
    global static string postProjectData(String ProjectRef, 
                                String ProjectName,
                                String OpportunityId,
                                Date StartDate,
                                Date EndDate,
                                Double Amount,
                                String Status){
        Savepoint sp = Database.setSavepoint();
        try{
            Project__c project = new Project__c(ProjectRef__c = ProjectRef,
                                            Name = ProjectName,
                                            Opportunity__c = OpportunityId,
                                            Start_Date__c = StartDate,
                                            End_Date__c = EndDate,
                                            Billable_Amount__c = Amount,
                                            Status__c = Status);
            upsert(project);
            updateOpportunityStatus(opportunityId);
            
        }catch(DmlException ex){
            Database.Rollback(sp);
            return ex.getDmlMessage(0);
        }   
        return 'OK';     
    }
    private static void updateOpportunityStatus(Id opportunityId){
        Opportunity opportunity = [SELECT Id, DeliveryInstallationStatus__c 
                                    FROM Opportunity
                                    WHERE Id = :opportunityId];
        opportunity.DeliveryInstallationStatus__c = 'In progress';
        update opportunity;
    }
}