public with sharing class ProjectCalloutService {
    public with sharing class QueueablePMSCall implements Queueable, Database.AllowsCallouts{
        private Opportunity opportunity;
        private string projectServiceToken;

        public QueueablePMSCall(Opportunity opportunity, string projectServiceToken){
            this.opportunity = opportunity;
            this.projectServiceToken = projectServiceToken;
        }

        public void execute(QueueableContext qc){
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setMethod('POST');
            request.setEndpoint('callout:ProjectService');
            request.setHeader('token', projectServiceToken);
            request.setHeader('Content-Type', 'application/json');
            request.setBody(GenerateJSONOpportunity());
            HttpResponse response = http.send(request);

            if(response.getStatuscode() == 201){
                opportunity.StageName = 'Submitted Project';
            }else{
                opportunity.StageName = 'Resubmit Project';
            }
            update opportunity;
        }

        private string GenerateJSONOpportunity(){
            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();
            gen.writeStringField('opportunityId', opportunity.Id);
            gen.writeStringField('opportunityName', opportunity.Name);
            gen.writeStringField('accountName', opportunity.Account.Name);
            gen.writeDateField('closeDate', opportunity.CloseDate);
            gen.writeNumberField('amount', opportunity.Amount);
            gen.writeEndObject();

            return gen.getAsString();
        }
    }
    @InvocableMethod
    public static void PostOpportunityToPMS(List<Id> ids){
        Id id = ids[0];
        Opportunity opportunity = [SELECT Id, Name, Account.Name, Amount, CloseDate, StageName
                                            FROM Opportunity 
                                            WHERE Id = :id];
        
        QueueablePMSCall pmsCall = new QueueablePMSCall(opportunity, 
                                            ServiceTokens__c.getValues('ProjectServiceToken').Token__c);
        Id jobId = System.enqueueJob(pmsCall);
    }

    
}
